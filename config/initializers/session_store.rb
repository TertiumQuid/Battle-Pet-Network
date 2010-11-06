# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_battle-pet-network_session',
  :secret      => '33740c0d8efdd7ef6ecb3e0827792460ebabf2ec99a9e221abdc4b7a129c7473602fe91c5015cc6bcf518c37342faf324ed476e2504c9260b138d81379b802a6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
