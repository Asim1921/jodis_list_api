# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.env.development? ? ['localhost:3001', 'localhost:3000', '127.0.0.1:3001', '127.0.0.1:3000'] : ['jodislist.com', 'www.jodislist.com']
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization']
  end
end