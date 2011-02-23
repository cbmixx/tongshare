require 'openssl'
require 'digest/sha2'
require 'base64'

module AuthHelper
  #AUTH_SERVER_PATH = "http://thuauth.tongshare.com/thuauth/auth_with_xls_and_get_name/"

  def encrypt(content, key)
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.encrypt
    c.key = Digest::SHA2.hexdigest(key)
    e = c.update(content)
    e << c.final
    return Base64.encode64(e)
  end

  def decrypt(content, key)
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.decrypt
    c.key = Digest::SHA2.hexdigest(key)
    d = c.update(Base64.decode64(content))
    d << c.final
    return d
  end

  def auth_path(username, redirect_to)
    AUTH_SERVER_PATH + "?username=#{URI.escape(username)}&redirect_to=#{URI.escape(redirect_to)}"
  end

  def auth_path_with_password(username, password, redirect_to)
    result = AUTH_SERVER_PATH + "?username=#{URI.escape(username)}&redirect_to=#{URI.escape(redirect_to)}"
    e = encrypt(password, SECRET)
    result << "&aes=#{URI.escape(e)}"
  end
end
