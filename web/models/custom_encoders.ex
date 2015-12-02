defimpl Poison.Encoder, for: ProjectStatus.EmailRecipient do
  def encode(model, opts) do
    model |> Map.take([:name, :id, :email]) |> Poison.Encoder.encode(opts)
  end
end

defimpl Poison.Encoder, for: ProjectStatus.StatusEmail do
  def encode(model, opts) do
    model |> Map.take([:name, :id, :email, :subject, :content, :project_id, :sent_date, :status_date]) |> Poison.Encoder.encode(opts)
  end
end


defimpl Poison.Encoder, for: Tuple do
  def encode(tuple, opts) do
    tuple |> Tuple.to_list |> Poison.Encoder.encode(opts)
  end
end
