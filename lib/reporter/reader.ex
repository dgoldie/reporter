defmodule Reporter.Reader do
  @files_path Path.expand("../../files", __DIR__)

  def read(filename) do
    filename
    |> read_file()
    |> decode_stream()
    |> get_valid_rows()
    |> Keyword.values()
  end

  defp read_file(filename) do
    @files_path
    |> Path.join(filename <> ".csv")
    |> File.stream!([read_ahead: 100_000], 1000)
  end

  defp decode_stream(stream) do
    stream
    |> CSV.decode(headers: true)
    |> Enum.to_list()
  end

  ## TODO: handle bad?
  defp get_valid_rows(list) do
    {good, bad} = Enum.split_with(list, fn {k, _v} -> k == :ok end)
    IO.puts("good is #{Enum.count(good)}")
    IO.puts("bad is #{Enum.count(bad)}")
    good
  end
end
