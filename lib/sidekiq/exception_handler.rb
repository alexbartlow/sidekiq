require 'sidekiq'

module Sidekiq
  module ExceptionHandler
    class Logger
      def call(ex, ctxHash)
        exception_backtrace_depth = ENV.fetch("SIDEKIQ_EXCEPTION_BACKTRACE_DEPTH", -1).to_i
        Sidekiq.logger.warn(ctxHash) if !ctxHash.empty?
        Sidekiq.logger.warn ex
        Sidekiq.logger.warn ex.backtrace[0..exception_backtrace_depth].join("\n") unless ex.backtrace.nil?
      end

      # Set up default handler which just logs the error
      Sidekiq.error_handlers << Sidekiq::ExceptionHandler::Logger.new
    end

    def handle_exception(ex, ctxHash={})
      Sidekiq.error_handlers.each do |handler|
        begin
          handler.call(ex, ctxHash)
        rescue => ex
          Sidekiq.logger.error "!!! ERROR HANDLER THREW AN ERROR !!!"
          Sidekiq.logger.error ex
          Sidekiq.logger.error ex.backtrace.join("\n") unless ex.backtrace.nil?
        end
      end
    end

  end
end
