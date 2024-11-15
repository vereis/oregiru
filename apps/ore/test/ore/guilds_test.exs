defmodule Ore.GuildsTest do
  use Ore.DataCase, async: true

  alias Ore.Guilds
  alias Ore.Guilds.Guild
  alias Ore.Guilds.Member

  setup do
    guild = insert(:guild)
    member = insert(:member, guild: guild)
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
      result = Guilds.list_guilds(level: {:>=, 0}, level: {:<=, 100}, order_by: {:asc, :id})
      assert length(result) == 2

      for {guild, idx} <- Enum.with_index(result) do
        assert guild.id == Enum.at(guilds, idx).id
      end

      [result] = Guilds.list_guilds(level: {:>=, 100}, order_by: {:asc, :id})
      assert result.id == guild_3.id
    end
  end

  describe "create_member/2" do
    test "creates a new member for the given guild", ctx do
      assert {:ok, %Member{} = member} =
               Guilds.create_member(ctx.guild, %{given_name: "Alice", family_name: "Einhardt", gender: :female, level: 10})

      assert member.guild_id == ctx.guild.id
      assert member.given_name == "Alice"
      assert member.family_name == "Einhardt"
      assert member.name == "Alice Einhardt"
      assert member.level == 10
      assert member.gender == :female
    end

    test "gender is undefined if not provided", ctx do
      assert {:ok, %Member{} = member} =
               Guilds.create_member(ctx.guild, %{given_name: "Alice", family_name: "Einhardt", level: 10})

      assert is_nil(member.gender)
    end
  end

  describe "update_member/2" do
    test "updates a member with the given attrs", ctx do
      assert {:ok, %Member{} = member} =
               Guilds.update_member(ctx.member, %{given_name: "Samantha", family_name: "Carter", level: 50})

      assert member.id == ctx.member.id
      assert member.guild_id == ctx.member.guild_id
      assert member.given_name == "Samantha"
      assert member.family_name == "Carter"
      assert member.name == "Samantha Carter"
      assert member.level == 50

      refute member.given_name == ctx.member.given_name
      refute member.family_name == ctx.member.family_name
      refute member.level == ctx.member.level
    end
  end

  describe "get_member/2" do
    test "returns nil when a member does not exist" do
      assert is_nil(Guilds.get_member(0))
    end

    test "returns member given its id", ctx do
      assert %Member{} = Guilds.get_member(ctx.member.id)
    end

    test "returns member given its id and filters", ctx do
      assert %Member{} = Guilds.get_member(ctx.member.id, level: ctx.member.level)
      assert is_nil(Guilds.get_member(ctx.member.id, level: ctx.member.level + 1))
    end
  end

  describe "list_members/1" do
    test "returns members matching the given filters", ctx do
      guild = ctx.guild
      member_1 = ctx.member
      member_2 = insert(:member, guild: guild, level: 50)
      member_3 = insert(:member, guild: guild, level: 101)

      members = [member_1, member_2, member_3]
      result = Guilds.list_members(guild_id: guild.id, level: {:>=, 0}, level: {:<=, 100}, order_by: {:asc, :id})
      assert length(result) == 2

      for {member, idx} <- Enum.with_index(result) do
        assert member.id == Enum.at(members, idx).id
      end

      [result] = Guilds.list_members(guild_id: guild.id, level: {:>=, 100}, order_by: {:asc, :id})
      assert result.id == member_3.id
    end
  end
end
