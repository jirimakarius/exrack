import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exrack_ui, ExRackUIWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "xQohIokOxYre9xkLsXd9rFWaf0IpZnm2XxrODH/jDTGZ3eAyOQf0pEN1gQQVUihK",
  server: false

# In test we don't send emails.
config :exrack_ui, ExRackUI.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
