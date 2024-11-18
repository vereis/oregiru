defmodule Ore.QuestsTest do
  use Ore.DataCase, async: true

  alias Ore.Quests
  alias Ore.Quests.Quest
  alias Ore.Repo

  setup do
    guild = insert(:guild)
    member_1 = insert(:member, guild: guild)
    member_2 = insert(:member, guild: guild)
    member_3 = insert(:member, guild: guild)
    quest = insert(:quest, guild: guild, members: [member_1, member_2, member_3])
    {:ok, binding()}
  end

  describe "create_quest/2" do
    test "creates a new quest", ctx do
      assert {:ok, %Quest{} = quest} =
               Quests.create_quest(ctx.guild, %{
                 name: "Embrace Ragnarok!!",
                 status: "proposed",
                 min_level: 10,
                 max_level: 30
               })

      assert quest.name == "Embrace Ragnarok!!"
      assert quest.state == :proposed
      assert quest.min_level == 10
      assert quest.max_level == 30
      assert quest.guild_id == ctx.guild.id
    end
  end

  describe "update_guild/2" do
    test "updates a quest with the given attrs", ctx do
      assert {:ok, %Quest{} = quest} =
               Quests.update_quest(ctx.quest, %{
                 min_level: 0,
                 name: "Another quest begins!"
               })

      assert quest.id == ctx.quest.id
      assert quest.guild_id == ctx.quest.guild_id
      assert quest.name == "Another quest begins!"
      assert quest.min_level == 0
    end
  end

  describe "transition_quest/2" do
    all_states = Map.keys(Quest.state_transitions())

    for {state, valid_states} <- Quest.state_transitions() do
      for valid_state <- valid_states do
        test "allows transitioning from #{state} to #{valid_state}" do
          quest = insert(:quest, state: unquote(state))
          assert {:ok, %Quest{} = response} = Quests.transition_quest(quest, unquote(valid_state))
          assert quest.state == unquote(state)
          assert response.state == unquote(valid_state)
        end
      end

      for invalid_state <- all_states -- valid_states, invalid_state != state do
        test "does not allow transitioning from #{state} to #{invalid_state}" do
          quest = insert(:quest, state: unquote(state))

          assert {:error, %Ecto.Changeset{} = changeset} =
                   Quests.transition_quest(quest, unquote(invalid_state))

          assert [
                   state:
                     {"invalid state transition",
                      new_state: unquote(invalid_state), old_state: unquote(state), valid_states: unquote(valid_states)}
                 ] = changeset.errors
        end
      end
    end
  end

  describe "enroll_quest/2" do
    test "enrolls a member in a quest", ctx do
      member = insert(:member, guild: ctx.guild, level: 15)
      quest = insert(:quest, guild: ctx.guild, min_level: 10, max_level: 20, state: :pending)
      assert {:ok, %Quest{} = quest} = Quests.enroll_quest(quest, member)
      assert [result] = Repo.preload(quest, :members).members
      assert result.id == member.id
      assert quest.state == :active
    end

    test "enrolls multiple members in a quest", ctx do
      quest = insert(:quest, guild: ctx.guild, min_level: 10, max_level: 30, state: :pending)
      member_1 = insert(:member, guild: ctx.guild, level: 10)
      member_2 = insert(:member, guild: ctx.guild, level: 20)
      member_3 = insert(:member, guild: ctx.guild, level: 30)

      assert {:ok, %Quest{} = quest} =
               Quests.enroll_quest(quest, [member_1, member_2, member_3])

      assert [result_1, result_2, result_3] =
               quest |> Repo.preload(:members) |> Map.get(:members, []) |> Enum.sort_by(& &1.id)

      assert result_1.id == member_1.id
      assert result_2.id == member_2.id
      assert result_3.id == member_3.id
      assert quest.state == :active
    end

    test "does not enroll members that do not meet the level requirements", ctx do
      member = insert(:member, guild: ctx.guild, level: 15)
      quest = insert(:quest, guild: ctx.guild, min_level: 5, max_level: 10, state: :pending)

      assert {:error, {:level_range_mismatch, ineligible_members: [ineligible_member], range: range}} =
               Quests.enroll_quest(quest, member)

      assert range == 5..10
      assert ineligible_member.id == member.id
      assert quest.state == :pending
    end

    for state <- Map.keys(Quest.state_transitions()), state != :pending do
      test "does not enroll members for quests in state #{state}", ctx do
        member = insert(:member, guild: ctx.guild, level: 15)

        quest =
          insert(:quest, guild: ctx.guild, min_level: 10, max_level: 20, state: unquote(state))

        assert {:error, {:invalid_state, unquote(state)}} = Quests.enroll_quest(quest, member)
      end
    end
  end

  describe "get_quest/2" do
    test "returns nil when a quest does not exist" do
      assert is_nil(Quests.get_quest(0))
    end

    test "returns quest given its id", ctx do
      assert %Quest{} = Quests.get_quest(ctx.quest.id)
    end

    test "returns guild given its id and filters", ctx do
      assert %Quest{} = Quests.get_quest(ctx.quest.id, state: ctx.quest.state)
      assert is_nil(Quests.get_quest(ctx.quest.id, name: "whatever"))
    end
  end

  describe "list_quests/2" do
    test "returns all quests for a guild" do
      guild = insert(:guild)
      quest_1 = insert(:quest, guild: guild)
      quest_2 = insert(:quest, guild: guild)

      assert [result_1, result_2] = Quests.list_quests(guild)
      assert result_1.id in [quest_1.id, quest_2.id]
      assert result_2.id in [quest_1.id, quest_2.id]
      refute result_1.id == result_2.id
    end

    test "returns all quests for a guild w/ filter" do
      guild = insert(:guild)
      quest_1 = insert(:quest, guild: guild, state: :active)
      quest_2 = insert(:quest, guild: guild, state: :completed)

      assert [result] = Quests.list_quests(guild, state: :active)
      assert result.id == quest_1.id

      assert [result] = Quests.list_quests(guild, state: :completed)
      assert result.id == quest_2.id

      assert [] = Quests.list_quests(guild, state: :proposed)
    end

    test "returns all quests w/ filter", ctx do
      assert [result] = Quests.list_quests(name: ctx.quest.name)
      assert result.id == ctx.quest.id
    end
  end
end
