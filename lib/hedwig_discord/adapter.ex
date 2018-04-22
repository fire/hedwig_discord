defmodule Hedwig.Adapters.Discord do
  use Hedwig.Adapter
  alias Nostrum.Api

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
    Api.create_message(msg.room, msg.text)
    {:noreply, state}
  end

  def handle_cast({:reply, %{user: user, text: text} = msg}, state) do
    Api.create_message(msg.room, "<@#{user.id}|#{user.name}>: #{text}")
    {:noreply, state}
  end

  def handle_info(%{"user" => user}, %{id: user} = state) do
    {:noreply, state}
  end

  def handle_info(
        %{"type" => "message", "user" => user} = msg,
        %{robot: robot, users: users} = state
      ) do
    msg = %Hedwig.Message{
      ref: make_ref(),
      robot: robot,
      room: msg["channel"],
      text: msg["text"],
      type: "message",
      user: %Hedwig.User{
        id: user,
        name: users[user]["name"]
      }
    }

    if msg.text do
      :ok = Hedwig.Robot.handle_in(robot, msg)
    end

    {:noreply, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end
end
