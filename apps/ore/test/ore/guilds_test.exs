defmodule Ore.GuildsTest do
  use Ore.DataCase, async: true

  alias Ore.Guilds
  alias Ore.Guilds.Guild

  setup do
    guild = insert(:guild)
    {:ok, binding()}
  end

  describe "create_guild/1" do
    test "creates a new guild" do
      assert {:ok, %Guild{} = guild} =
               Guilds.create_guild(%{
                 name: "The Guild",
                 slogan: "We are the best!",
                 level: 100
               })

      assert guild.name == "The Guild"
      assert guild.slogan == "We are the best!"
      assert guild.level == 100
    end
  end

  describe "update_guild/2" do
    test "updates a guild with the given attrs", ctx do
      assert {:ok, %Guild{} = guild} =
               Guilds.update_guild(ctx.guild, %{
                 slogan: "We are definitely the best!",
                 level: 25
               })

      assert guild.slogan == "We are definitely the best!"
      assert guild.level == 25

      assert guild.id == ctx.guild.id
      assert guild.name == ctx.guild.name
      refute guild.slogan == ctx.guild.slogan
      refute guild.level == ctx.guild.level
    end
  end

  describe "get_guild/2" do
    test "returns nil when a guild does not exist" do
      assert is_nil(Guilds.get_guild(0))
    end

    test "returns guild given its id", ctx do
      assert %Guild{} = Guilds.get_guild(ctx.guild.id)
    end

    test "returns guild given its id and filters", ctx do
      assert %Guild{} = Guilds.get_guild(ctx.guild.id, level: ctx.guild.level)
      assert is_nil(Guilds.get_guild(ctx.guild.id, level: ctx.guild.level + 1))
    end
  end

  describe "list_guilds/1" do
    test "returns guilds matching the given filters", ctx do
      guild_1 = ctx.guild
      guild_2 = insert(:guild, level: 50)
      guild_3 = insert(:guild, level: 101)

      guilds = [guild_1, guild_2, guild_3]
      result = Guilds.get_guilds(level: {:>=, 0}, level: {:<=, 100}, order_by: {:asc, :id})
      assert length(result) == 2

      for {guild, idx} <- Enum.with_index(result) do
        assert guild.id == Enum.at(guilds, idx).id
      end

      [result] = Guilds.get_guilds(level: {:>=, 100}, order_by: {:asc, :id})
      assert result.id == guild_3.id
    end
  end
end
