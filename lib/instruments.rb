module Instruments

  def self.defaults=(args)
    @logger = args[:logger]
    @method = args[:method]
    @default_data = args[:default_data]
  end

  def self.logger
    @logger || Kernel
  end

  def self.method
    @method || :puts
  end

  def self.default_data
    @default_data || {}
  end

  def self.write(data={})
    logger.send(method, default_data.merge(data))
  end

  if defined?(::Sinatra)
    module ::Sinatra
      module Instrumentation
        def route(verb, action, *)
          condition {@instrumented_route = action}
          super
        end


        def instrument_routes
          before do
            @start_request = Time.now
          end
          after do
            #cleanup route name
            instrumented_route = @instrumented_route.
                                    gsub(/\/:\w+/,'').            #remove param names from path
                                    gsub("/","-").                #remove slash from path
                                    gsub(/[^A-Za-z0-9\-\_]/, ''). #only keep subset of chars
                                    slice(1..-1)

            t = Integer((Time.now - @start_request)*1000)
            # request times
            Instruments.write({
              :lib => "sinatra",
              :fn => instrumented_route.empty? ? 'index' : instrumented_route,
              :measure => true,
              :elapsed => t,
              :method => env["REQUEST_METHOD"].downcase,
              :status => response.status
            }.merge(params))

            # status counter
            Instruments.write({
              :at => "web-#{response.status}",
              :measure => true
            })
          end
        end
      end
      register Instrumentation
    end
  end

  if defined?(::Sequel)
    module ::Sequel
      class Database
        def log_yield(sql, args=nil)
          sql = "#{sql}; #{args.inspect}" if args
          t0 = Time.now
          begin
            yield
          rescue => e
            log_exception(e, sql)
            raise
          ensure
            t1 = Time.now
            log_duration(Integer((t1-t0)*1000), sql) unless e
          end
        end

        def log_duration(t, sql)
          Instruments.write(:mesaure => true, :fn => action(sql), :elapsed => t, :sql => sql)
        end

        def log_exception(e, sql)
          Instruments.write(:at => 'sequel-exception', :measure => true, :exception => e.class, :sql => sql)
        end

        def action(sql)
          sql[/(\w+){1}/].downcase
        end
      end
    end
  end

end
