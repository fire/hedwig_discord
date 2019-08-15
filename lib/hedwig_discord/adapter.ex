defmodule Hedwig.Adapters.Discord do
  use Hedwig.Adapter
  use Coxir
  require Logger


  defmodule State do
    defstruct conn: nil,
              conn_ref: nil,
              channels: %{},
              guilds: %{},
              id: nil,
              name: nil,
              opts: nil,
              robot: nil,
              token: nil,
              users: %{}
  end

  def init({robot, opts}) do
    {token, opts} = Keyword.pop(opts, :token)
    {:ok, %State{opts: opts, robot: robot, token: token}}
  end

  def handle_cast({:send, msg}, state) do
    Coxir.Struct.Channel.send_message(msg.room, msg.txt)
    {:noreply, state}
  end

  def handle_cast({:reply, %{user: user, text: text} = msg}, state) do
    Coxir.Struct.Channel.send_message(msg.room, "<@#{user.id}|#{user.name}>: #{text}")
    {:noreply, state}
  end

  def handle_info(%{"user" => user}, %{id: user} = state) do
    {:noreply, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end
end
