defmodule Mnemonic do
  @wordlist_count Mnemonic.get_wordlist_count()
  def get_wordlist do
    {:ok,words} = File.read "wordlist.txt"
    String.replace(words, "\n", ",")
    |>String.split(",")
    |>List.to_tuple
  end

  def get_wordlist_count do
    get_wordlist()
    |>Tuple.to_list
    |>Enum.count()
  end

  def generate_phrase(word_count) do
    generate_phrase([], 0, word_count)
  end

  defp generate_phrase(result, current_word_count, word_count) when current_word_count < word_count
  and current_word_count <= @wordlist_count do
    word = generate_word()
    if(Enum.any?(result, fn(x) -> x == word end)) do
      generate_phrase([generate_word()<>" " | result], current_word_count + 1, word_count)
    end
    generate_phrase([word<>" " | result], current_word_count + 1, word_count)
  end

  defp generate_phrase(result, current_word_count, word_count) do
    Enum.reverse(result)
    List.to_string(result)
    |> String.trim()

  end

  def generate_word do
    elem(get_wordlist(),
    (get_wordlist()
    |>Tuple.to_list
    |>Enum.count()
    |>:rand.uniform)-1)
  end
end
