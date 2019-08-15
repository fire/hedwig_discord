defmodule HedwigDiscord.Connection do
  use Coxir
  require Logger

  def handle_event({:READY, _user}, state) do
    game = %{
      type: 0,
      name: "with the time"
    }
    Coxir.Gateway.set_status("dnd", game)

    {:ok, state}
  end

  def handle_event({:MESSAGE_CREATE, message}, %{robot: robot} = state) do
    Logger.debug(inspect(message))
    msg = %Hedwig.Message{
      ref: make_ref(),
      robot: robot,
      room: message.channel_id,
      text: message.content,
      type: "message",
      user: %Hedwig.User{
        id: message.author.id,
        name: message.author.username
      }
    }
    :ok = Hedwig.Robot.handle_in(robot, msg)
    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
