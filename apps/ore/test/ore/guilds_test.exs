defmodule Ore.GuildsTest do
  use Ore.DataCase, async: true

  alias Ore.Guilds
  alias Ore.Guilds.Guild
  alias Ore.Guilds.Leader
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
    test "returns all guilds", ctx do
      assert [result] = Guilds.list_guilds()
      assert result.id == ctx.guild.id
    end

    test "returns no guilds if filters don't match", _ctx do
      assert [] = Guilds.list_guilds(level: {:>, 300})
    end

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
               Guilds.create_member(ctx.guild, %{
                 given_name: "Alice",
                 family_name: "Einhardt",
                 gender: :female,
                 level: 10
               })

      assert member.guild_id == ctx.guild.id
      assert member.given_name == "Alice"
      assert member.family_name == "Einhardt"
      assert member.name == "Alice Einhardt"
      assert member.level == 10
      assert member.gender == :female
    end

    test "gender is undefined if not provided", ctx do
      assert {:ok, %Member{} = member} =
               Guilds.create_member(ctx.guild, %{
                 given_name: "Alice",
                 family_name: "Einhardt",
                 level: 10
               })

      assert is_nil(member.gender)
    end
  end

  describe "update_member/2" do
    test "updates a member with the given attrs", ctx do
      assert {:ok, %Member{} = member} =
               Guilds.update_member(ctx.member, %{
                 given_name: "Samantha",
                 family_name: "Carter",
                 level: 50
               })

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

  describe "list_members/2" do
    test "returns nothing if no members exist" do
      guild = insert(:guild)
      assert [] = Guilds.list_members(guild)
    end

    test "returns nothing if no members match the given filters" do
      assert [] = Guilds.list_members(level: 999)
    end

    test "returns members for the given guild", ctx do
      guild_1 = ctx.guild
      guild_2 = insert(:guild, name: "The Other Guild")
      member_1 = ctx.member
      member_2 = insert(:member, guild: guild_2)

      assert [result] = Guilds.list_members(guild_1)
      assert result.id == member_1.id

      assert [result] = Guilds.list_members(guild_2)
      assert result.id == member_2.id
    end

    test "returns members for the given guild and filters", ctx do
      guild = ctx.guild
      member_1 = ctx.member
      member_2 = insert(:member, guild: guild, level: 50)
      member_3 = insert(:member, guild: guild, level: 101)

      guild_2 = insert(:guild)
      member_4 = insert(:member, guild: guild_2, level: 50)

      result =
        Guilds.list_members(guild, level: {:>=, 0}, level: {:<=, 100}, order_by: {:asc, :id})

      assert length(result) == 2
      assert Enum.at(result, 0).id == member_1.id
      assert Enum.at(result, 1).id == member_2.id

      [result] = Guilds.list_members(guild, level: {:>, 100}, order_by: {:asc, :id})
      assert result.id == member_3.id

      assert [] = Guilds.list_members(guild_2, level: {:>, 100})
      assert [result] = Guilds.list_members(guild_2, level: {:>=, 0}, level: {:<=, 100})
      assert result.id == member_4.id
    end

    test "returns members matching the given filters", ctx do
      guild = ctx.guild
      member_1 = ctx.member
      member_2 = insert(:member, guild: guild, level: 50)
      member_3 = insert(:member, guild: guild, level: 101)

      members = [member_1, member_2, member_3]

      result =
        Guilds.list_members(
          guild_id: guild.id,
          level: {:>=, 0},
          level: {:<=, 100},
          order_by: {:asc, :id}
        )

      assert length(result) == 2

      for {member, idx} <- Enum.with_index(result) do
        assert member.id == Enum.at(members, idx).id
      end

      [result] = Guilds.list_members(guild_id: guild.id, level: {:>, 100}, order_by: {:asc, :id})
      assert result.id == member_3.id
    end
  end

  describe "create_leader/2" do
    setup ctx do
      {:ok, member: insert(:member, guild: ctx.guild)}
    end

    test "creates a new leader for the given guild", ctx do
      assert {:ok, %Leader{} = leader} =
               Guilds.create_leader(ctx.guild, ctx.member, %{
                 email: "hello@example.com",
                 password: "hunter2"
               })

      assert leader.guild_id == ctx.guild.id
      assert leader.member_id == ctx.member.id
      assert leader.email == "hello@example.com"
      refute leader.password_hash == "hunter2"
    end

    test "fails to create a leader if the email is not an email", ctx do
      assert {:error, changeset} =
               Guilds.create_leader(ctx.guild, ctx.member, %{
                 email: "hello",
                 password: "hunter2"
               })

      assert [email: {"has invalid format", [validation: :format]}] = changeset.errors
    end

    test "fails to create a leader if the email is not unique", ctx do
      assert {:ok, _leader} =
               Guilds.create_leader(ctx.guild, ctx.member, %{
                 email: "hello@example.com",
                 password: "hunter2"
               })

      assert {:error, changeset} =
               Guilds.create_leader(ctx.guild, ctx.member, %{
                 email: "hello@example.com",
                 password: "hunter2"
               })

      assert [email: {"has already been taken", [{:constraint, :unique} | _metadata]}] =
               changeset.errors
    end
  end

  describe "update_leader/2" do
    setup ctx do
      {:ok, leader: insert(:leader, guild: ctx.guild)}
    end

    test "updates a leader with the given attrs", ctx do
      assert {:ok, %Leader{} = leader} =
               Guilds.update_leader(ctx.leader, %{email: "new_email@example.com"})

      assert leader.id == ctx.leader.id
      assert leader.guild_id == ctx.leader.guild_id
      assert leader.member_id == ctx.leader.member_id
      assert leader.email == "new_email@example.com"
      assert leader.password_hash == ctx.leader.password_hash
    end

    test "sets new hashed password given new password in attrs", ctx do
      assert {:ok, %Leader{} = leader} =
               Guilds.update_leader(ctx.leader, %{password: "something_new"})

      assert leader.id == ctx.leader.id
      assert leader.guild_id == ctx.leader.guild_id
      assert leader.member_id == ctx.leader.member_id
      refute leader.password_hash == ctx.leader.password_hash
    end
  end

  describe "get_leader/2" do
    setup ctx do
      {:ok, leader: insert(:leader, guild: ctx.guild)}
    end

    test "returns nil when a leader does not exist" do
      assert is_nil(Guilds.get_leader(0))
    end

    test "returns leader given its id", ctx do
      assert %Leader{} = leader = Guilds.get_leader(ctx.leader.id)
      assert leader.id == ctx.leader.id
    end

    test "returns leader given its guild", ctx do
      assert %Leader{} = leader = Guilds.get_leader(ctx.guild)
      assert leader.id == ctx.leader.id
    end

    test "returns leader given its id and filters", ctx do
      assert is_nil(Guilds.get_leader(ctx.leader.id, email: "random-email@example.com"))
      assert %Leader{} = leader = Guilds.get_leader(ctx.leader.id, email: ctx.leader.email)
      assert leader.id == ctx.leader.id
    end

    test "returns leader given its guild and filters", ctx do
      assert is_nil(Guilds.get_leader(ctx.guild, email: "random-email@example.com"))
      assert %Leader{} = leader = Guilds.get_leader(ctx.guild, email: ctx.leader.email)
      assert leader.id == ctx.leader.id
    end

    test "returns leader when searching by password", ctx do
      password = Ecto.UUID.generate()

      {:ok, leader} =
        Guilds.create_leader(ctx.guild, insert(:member, guild: ctx.guild), %{
          email: "jblow@example.com",
          password: password
        })

      # Obviously, we don't expect anything to be returned if the password is incorrect
      assert is_nil(Guilds.get_leader(leader.id, password: "random-password"))

      # You also can't just search by the hashed password itself
      assert is_nil(Guilds.get_leader(leader.id, password: leader.password_hash))

      assert %Leader{} = result = Guilds.get_leader(leader.id, password: password)
      assert result.id == leader.id
      assert result.password_hash == leader.password_hash
    end
  end

  describe "list_leaders/1" do
    test "returns nothing if no leaders exist" do
      assert [] = Guilds.list_leaders()
    end

    test "returns nothing if no leaders match the given filters" do
      assert [] = Guilds.list_leaders(email: "donquihote@example.com")
    end

    test "returns leaders for the given guild" do
      leader_1 = insert(:leader)
      leader_2 = insert(:leader)

      assert [_result_1, _result_2] = Guilds.list_leaders()
      assert [result_1] = Guilds.list_leaders(guild_id: leader_1.guild_id)
      assert [result_2] = Guilds.list_leaders(guild_id: leader_2.guild_id)
      refute result_1 == result_2
    end
  end
end
