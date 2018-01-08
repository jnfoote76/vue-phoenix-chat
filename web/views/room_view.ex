defmodule Vuechat.RoomView do
  use Vuechat.Web, :view

  def render("index.json", %{rooms: rooms}) do
    %{data: render_many(rooms, Vuechat.RoomView, "room.json")}
  end

  def render("show.json", %{room: room}) do
    %{data: render_one(room, Vuechat.RoomView, "room.json")}
  end

  def render("room.json", %{room: room}) do
    %{id: room.id,
      name: room.name}
  end
end
