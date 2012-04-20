module Instruments

  HTTP_WARN = ENV["HTTP_WARN"] || 300
  HTTP_ERROR = ENV["HTTP_ERROR"] || 1000

  DB_WARN = ENV["DB_WARN"] || 300
  DB_ERROR = ENV["DB_ERROR"] || 1000

  def self.defaults=(args)
    @logger = args[:logger]
    @method = args[:method]
    @default_data = args[:data]
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
    logger.send(method, data.merge(default_data))
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
            t = Integer((Time.now - @start_request)*1000)
            level = if t > HTTP_ERROR
              :error
            elsif t > HTTP_WARN
              :warn
            else
              :info
            end
            Instruments.write({
              :level => level,
              :lib => "sinatra",
              :action => "http-request",
              :route => @instrumented_route,
              :elapsed => t,
              :method => env["REQUEST_METHOD"].downcase,
              :status => response.status
            }.merge(params))
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
          level = if t > DB_ERROR
            :error
          elsif t > DB_WARN
            :warn
          else
            :info
          end
          Instruments.write(:level => level, :action => action(sql), :elapsed => t, :sql => sql)
        end

        def log_exception(e, sql)
          Instruments.write(:error => true, :exception => e.class, :sql => sql)
        end

        def action(sql)
          sql[/(\w+){1}/].downcase
        end
      end
    end
  end

  if defined?(::Excon)
    module ::Excon
      module Instrumentation
        def self.instrument(name, params={}, &blk)
          t0 = Time.now
          res = yield if block_given?
          t1 = Time.now
          Instruments.write(
            :lib => "excon",
            :action => "http-request",
            :elapsed => Integer((t1-t0)*1000)
          )
        end
      end
    end
    Excon.defaults[:instrumentor] = ::Excon::Instrumentation
  end

end
