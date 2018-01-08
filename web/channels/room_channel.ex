defmodule Vuechat.RoomChannel do
  use Vuechat.Web, :channel
  alias Vuechat.Presence

  #def join("rooms:lobby", payload, socket) do
#    send(self, :after_join)
#    {:ok, socket}
#  end

  def join("rooms:" <> room_id_str, _params, socket) do
    room_id = String.to_integer(room_id_str)
    message_query =
      from m in Vuechat.Message,
      where: m.room == ^room_id

    messages = Vuechat.Repo.all(message_query)
    response = %{
      messages: Phoenix.View.render_many(messages, Vuechat.MessageView, "message.json"),
    }

    send(self(), :after_join)
    {:ok, response, assign(socket, :room, room_id)}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    message = %{
      body: body,
      username: socket.assigns.username,
      received_at: System.system_time(:seconds)
    }

    broadcast! socket, "new_msg", message
    %Vuechat.Message{body: message.body, username: message.username, room: socket.assigns.room}
      |> Vuechat.Repo.insert

    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.username, %{
      online_at: inspect(System.system_time(:milliseconds))
    })
    push socket, "presence_state", Presence.list(socket)

    {:noreply, socket}
  end
end
