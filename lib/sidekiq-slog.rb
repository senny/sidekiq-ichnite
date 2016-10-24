require_relative 'sidekiq-slog/middleware'

Sidekiq::Logging.logger.level = Logger::WARN

Sidekiq.configure_server do |config|
  # Remove Sidekiqs default backtrace logging
  unless Rails.env.development?
    config.error_handlers.delete_if { |h| Sidekiq::ExceptionHandler::Logger === h }
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Slog::ClientMiddleware
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Slog::ClientMiddleware
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::Slog::ServerMiddleware
  end
end
