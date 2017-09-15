defmodule KeyPair do

  def keypair do

    private_key_file = "ec_private_key.pem"
    public_key_file = "ec_public_key.pem"

    :os.cmd('openssl ecparam -genkey -name secp256k1 -noout -out ec_private_key.pem')
    :os.cmd('openssl ec -in ec_private_key.pem -pubout -out ec_public_key.pem')
    private_key = :os.cmd('openssl ec -in ec_private_key.pem -outform DER|tail -c +8|head -c 32|xxd -p -c 32')
    public_key = :os.cmd('openssl ec -in ec_private_key.pem -pubout -outform DER|tail -c 65|xxd -p -c 65')

    private_key = private_key |> to_string() |> String.split("\n") |> Enum.at(2) |> String.upcase
    public_key = public_key |> to_string() |> String.split("\n") |> Enum.at(2) |> String.upcase

    # Overwrite with random to ensure non-retrieval of keys
    {:ok, priv} = File.read(private_key_file)
    {:ok, pub} = File.read(public_key_file)
    
    File.copy("/dev/random", private_key_file, byte_size(priv))
    File.copy("/dev/random", public_key_file, byte_size(pub))

    {_, 0} = System.cmd "rm", ["-f", private_key_file]
    {_, 0} = System.cmd "rm", ["-f", public_key_file]

    # Return tuple for key pair
    {private_key, public_key}
  end
end
