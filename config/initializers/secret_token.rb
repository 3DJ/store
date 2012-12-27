# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# old, probably compromised, open on GitHub
#Threedeejay::Application.config.secret_token = 'c54c2bb87f11e2b2c97a9ec073236f77907722af494ac7f208b1562520bf54f213f687295743cbbcaa51aef193d4a4f788538d30233bb861745d831bb19a4763'
begin
  token_file = Rails.root.to_s + "/secret_token"
  to_load = open(token_file).read
  Threedeejay::Application.configure do
    config.secret_token = to_load
  end
rescue LoadError, Errno::ENOENT => e
  raise "Secret token couldn't be loaded! Error: #{e}"
end
