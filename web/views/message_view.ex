defmodule Vuechat.MessageView do
  use Vuechat.Web, :view

  def render("index.json", %{messages: messages}) do
    %{data: render_many(messages, Vuechat.RoomView, "message.json")}
  end

  def render("show.json", %{message: message}) do
    %{data: render_one(message, Vuechat.MessageView, "message.json")}
  end

  def render("message.json", %{message: message}) do
    %{id: message.id,
      body: message.body,
      username: message.username,
      inserted_at: (message.inserted_at
      |> Ecto.DateTime.to_erl
      |> :calendar.datetime_to_gregorian_seconds)
|> Kernel.-(62_167_219_200)}
  end
end
