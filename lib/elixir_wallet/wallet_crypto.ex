defmodule WalletCrypto do

  alias Cryptex.KeyGenerator
  alias Cryptex.MessageEncryptor

  def decrypt_wallet(filename, password) do
    {:ok, data} = File.read(filename)
    encryptor = generate_encryptor(password)
    decrypted = MessageEncryptor.decrypt_and_verify(encryptor, data)
    IO.inspect(decrypted)
  end

  def encrypt_wallet(data,password) do
    encryptor = generate_encryptor(password)
    MessageEncryptor.encrypt_and_sign(encryptor, data)
  end

  defp generate_encryptor(password) do
    secret_key_base = :crypto.hash(:sha256, password) |> Base.encode16()
    encrypted_cookie_salt = "encrypted cookie"
    encrypted_signed_cookie_salt = "signed encrypted cookie"
    secret = KeyGenerator.generate(secret_key_base, encrypted_cookie_salt)
    sign_secret = KeyGenerator.generate(secret_key_base, encrypted_signed_cookie_salt)
    MessageEncryptor.new(secret, sign_secret)
  end

end
