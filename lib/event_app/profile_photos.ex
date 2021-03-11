# Credit lecture notes at https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/12-uploads/notes.md
defmodule EventApp.ProfilePhotos do
  def save_profile_photo(name, path) do
    data = File.read!(path)
    hash = sha256(data)
    meta = read_meta(hash)
    save_profile_photo(name, data, hash, meta)
  end

  def save_profile_photo(name, data, hash, nil) do
    File.mkdir_p!(base_path(hash))
    meta = %{
      name: name,
      refs: 0,
    }
    save_profile_photo(name, data, hash, meta)
  end

  def save_profile_photo(name, data, hash, meta) do
    meta = Map.update!(meta, :refs, &(&1 + 1))
    File.write!(meta_path(hash), Jason.encode!(meta))
    File.write!(data_path(hash), data)
    {:ok, hash}
  end

  def load_profile_photo(hash) do
    data = File.read!(data_path(hash))
    meta = read_meta(hash)
    {:ok, Map.get(meta, :name), data}
  end

  def read_meta(hash) do
    with {:ok, data} <- File.read(meta_path(hash)),
         {:ok, meta} <- Jason.decode(data, keys: :atoms)
    do
      meta
    else
      _ -> nil
    end
  end

  def base_path(hash) do
    Path.expand("~/.local/data/event_app")
    |> Path.join("#{Mix.env}")
    |> Path.join(String.slice(hash, 0, 2))
    |> Path.join(String.slice(hash, 2, 30))
  end

  def data_path(hash) do
    Path.join(base_path(hash), "profile_photo.jpg")
  end

  def meta_path(hash) do
    Path.join(base_path(hash), "meta.json")
  end

  def sha256(data) do
    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
  end
end