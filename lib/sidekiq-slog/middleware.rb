module Sidekiq
  module Slog
    def self.job_id(msg)
      msg['jid']
    end

    def self.job_class(msg)
      aj_job_class(msg) || msg['class']
    end

    def self.aj_job_class(msg)
      msg['wrapped']
    end

    def self.job_args(msg)
      args = msg['args']
      aj_job_args(args) || args
    end

    def self.aj_job_args(args)
      first_arg = args.first

      # check if the first argument looks like a AJ metadata hash
      if first_arg.is_a?(Hash) && first_arg.key?('arguments')
        first_arg['arguments'].map do |arg|
          if arg.is_a?(Hash) && arg.key?('_aj_globalid')
            arg['_aj_globalid']
          else
            arg
          end
        end
      end
    end

    class ClientMiddleware
      def call(worker_class, msg, queue, _redis_pool)
        context = {
          queue: queue,
          job_class: Sidekiq::Slog.job_class(msg),
          job_id: Sidekiq::Slog.job_id(msg)
        }
        if at = msg['at']
          context[:scheduled_at] = Time.at(at).utc
          SLog.log('job_schedule', context)
        else
          context[:args] = Sidekiq::Slog.job_args(msg)
          SLog.log('job_enqueue', context)
        end
        yield
      end
    end

    class ServerMiddleware
      def call(worker, msg, queue)
        Thread.current[:aj_job_id] = Sidekiq::Slog.job_id(msg)
        Thread.current[:aj_job_class] = Sidekiq::Slog.job_class(msg)

        context = { queue: queue }

        ts = Time.now.to_f
        # We are currently not logging start events.
        # This would most likely blow our SumoLogic limit.
        # start context, ts
        yield
        stop context, msg, ts
      rescue => ex
        error context, ex, ts
        raise ex
      ensure
        Thread.current[:aj_job_id] = nil
        Thread.current[:aj_job_class] = nil
      end

      def start(context, _time)
        SLog.log('job_start', context)
      end

      def error(context, error, start)
        data = context.merge(
          at: :error,
          duration: duration_ms(start),
          error: error.class.name,
          message: error.message[/\A.+$/].inspect)
        SLog.log('job_error', data)
      end

      def stop(context, _msg, start)
        data = context.merge(
          # It looks like this number is subject to clock drift.
                             # TODO: Figure out a way to make this accurate.
          # queued_duration: duration_ms(msg['enqueued_at'], start),
                             duration: duration_ms(start))

        SLog.log('job_stop', data)
      end

      def duration_ms(from, to = Time.now.to_f)
        ((to - from) * 1000).round
      end
    end

  end
end
