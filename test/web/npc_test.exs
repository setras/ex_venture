defmodule Web.NPCTest do
  use Data.ModelCase

  alias Web.NPC
  alias Web.Room
  alias Web.Zone

  test "create a new npc" do
    params = %{
      "name" => "Bandit",
      "hostile" => "false",
      "level" => "1",
      "experience_points" => "124",
      "stats" => %{
        health: 25,
        max_health: 25,
        strength: 10,
        intelligence: 10,
        dexterity: 10,
        skill_points: 10,
        max_skill_points: 10,
      } |> Poison.encode!(),
    }

    {:ok, npc} = NPC.create(params)

    assert npc.name == "Bandit"
  end

  test "updating a npc" do
    npc = create_npc(%{name: "Fighter"})

    {:ok, zone} = Zone.create(%{name: "The Forest"})
    {:ok, room} = Room.create(zone, %{name: "Forest Path", description: "A small forest path", x: 1, y: 1})
    {:ok, npc_spawner} = NPC.add_spawner(npc, %{zone_id: zone.id, room_id: room.id, spawn_interval: 15})

    {:ok, npc} = NPC.update(npc.id, %{name: "Barbarian"})

    assert npc.name == "Barbarian"

    state = Game.NPC._get_state(npc_spawner.id)
    assert state.npc.name == "Barbarian"
  end

  test "adding a new spawner" do
    {:ok, zone} = Zone.create(%{name: "The Forest"})
    {:ok, room} = Room.create(zone, %{name: "Forest Path", description: "A small forest path", x: 1, y: 1})

    _state = Game.Zone._get_state(zone.id)

    npc = create_npc(%{name: "Fighter"})

    {:ok, npc_spawner} = NPC.add_spawner(npc, %{zone_id: zone.id, room_id: room.id, spawn_interval: 15})

    assert npc_spawner.zone_id == zone.id

    assert Game.Zone._get_state(zone.id)
    state = Game.NPC._get_state(npc_spawner.id)
    assert state.npc.name == "Fighter"
  end

  test "deleting a spawner" do
    npc = create_npc(%{name: "Fighter"})

    {:ok, zone} = Zone.create(%{name: "The Forest"})
    {:ok, room} = Room.create(zone, %{name: "Forest Path", description: "A small forest path", x: 1, y: 1})
    {:ok, npc_spawner} = NPC.add_spawner(npc, %{zone_id: zone.id, room_id: room.id, spawn_interval: 15})

    assert {:ok, _npc_spanwer} = NPC.delete_spawner(npc_spawner.id)
  end
end
