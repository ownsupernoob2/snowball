extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
#
#func _ready() -> void:
	#multiplayer.peer_connected.connect(add_player)
	#multiplayer.peer_disconnected.connect(del_player)
#
#func _on_host_pressed() -> void:
	#var result = peer.create_server(9999)
	#if result != OK:
		#print("Failed to create server: ", result)
		#return
	#print("Server started on port 9999")
	#multiplayer.multiplayer_peer = peer
	#add_player(multiplayer.get_unique_id())
	#$CanvasLayer.hide()
#
#func _on_join_pressed() -> void:
	#var result = peer.create_client("127.0.0.1", 9999)
	#if result != OK:
		#print("Failed to join server: ", result)
		#return
	#print("Connected to server")
	#multiplayer.multiplayer_peer = peer
	#$CanvasLayer.hide()
#
#func add_player(id: int) -> void:
	#print("Adding player with ID:", id)
	#var player = player_scene.instantiate()
	#player.name = str(id)
	#print(id)
	#player.set_multiplayer_authority(id)
	#call_deferred("add_child", player)
#
#func del_player(id: int) -> void:
	#print("Removing player with ID:", id)
	#rpc("_del_player", id)
#
#@rpc("any_peer", "call_local")
#func _del_player(id: int) -> void:
	#var player_node = get_node_or_null(str(id))
	#if player_node:
		#player_node.queue_free()
