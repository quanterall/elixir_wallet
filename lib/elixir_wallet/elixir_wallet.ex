defmodule Wallet do

  alias Cryptex.KeyGenerator
  alias Cryptex.MessageEncryptor

  def create_wallet(password) do
    {{year, month, day}, {hours, minutes, seconds}} = :calendar.local_time()
    file = "wallet--#{year}-#{month}-#{day}-#{hours}-#{minutes}-#{seconds}"
    {:ok, file} = File.open file, [:write]
    {private, public} = KeyPair.keypair()

    pub_sha256_1 = :crypto.hash(:sha256, public) |> Base.encode16()
    pub_ripemd160 = :crypto.hash(:ripemd160, pub_sha256_1) |> Base.encode16()
    pub_netbytes = "00" <> pub_ripemd160
    pub_sha256_netbytes = :crypto.hash(:sha256, pub_netbytes) |> Base.encode16()
    pub_sha256_netbytes_2 = :crypto.hash(:sha256, pub_sha256_netbytes) |> Base.encode16()
    slice_four_bytes = pub_sha256_netbytes_2 |> to_string() |> String.slice(0..7)
    append_four_bytes_to_netbytes = pub_netbytes <> slice_four_bytes
    #We couldnt find a working lib for base58 and used online base58 one to create the address
    #TODO
    #address = append_four_bytes_to_netbytes |> Base58.encode

    data = %{private_key: private, public: public, address: append_four_bytes_to_netbytes}
    encrypted = encrypt_wallet(data, password)

    IO.binwrite(file, encrypted)
    File.close(file)

  end

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

  def generate_encryptor(password) do
    secret_key_base = :crypto.hash(:sha256, password) |> Base.encode16()
    encrypted_cookie_salt = "encrypted cookie"
    encrypted_signed_cookie_salt = "signed encrypted cookie"
    secret = KeyGenerator.generate(secret_key_base, encrypted_cookie_salt)
    sign_secret = KeyGenerator.generate(secret_key_base, encrypted_signed_cookie_salt)
    MessageEncryptor.new(secret, sign_secret)
  end

end
