defmodule Mnemonic do

  def get_wordlist do
    {:ok,words} = File.read "priv/wordlist.txt"
    String.replace(words, "\n", ",")
    |>String.split(",")
    |>List.to_tuple
  end

  def generate_phrase(word_count) do
    generate_phrase([], 0, word_count)
  end

  defp generate_phrase(result, current_word_count, word_count) when current_word_count < word_count do
    generate_phrase([generate_word()<>" "| result], current_word_count + 1, word_count)
  end

  defp generate_phrase(result, current_word_count, word_count) do
    result
    |> List.to_string()
    |> String.trim()
  end

  def generate_word do
    :crypto.rand_seed()
    elem(get_wordlist(),
    (get_wordlist()
    |>Tuple.to_list
    |>Enum.count()
    |>:rand.uniform)-1)
  end
end
IO.inspect(Mnemonic.generate_phrase(12))
