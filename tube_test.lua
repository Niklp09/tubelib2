--[[

	Tube Library 2
	==============

	Copyright (C) 2017-2018 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	tube_test.lua
	
	THIS FILE IS ONLY FOR TESTING PURPOSES

]]--

-- for lazy programmers
local P = minetest.pos_to_string
local S = minetest.string_to_pos
local M = minetest.get_meta

-- Test tubes

local Tube = tubelib2.Tube:new({
	max_tube_length = 1000, 
	show_infotext = true,
	primary_node_names = {"tubelib2:tubeS", "tubelib2:tubeA"}, 
	secondary_node_names = {"default:chest", "default:chest_open"},
})

minetest.register_node("tubelib2:tubeS", {
	description = "Tubelib2 Test tube",
	tiles = { -- Top, base, right, left, front, back
		"tubelib2_tube.png",
		"tubelib2_tube.png",
		"tubelib2_tube.png",
		"tubelib2_tube.png",
		"tubelib2_hole.png",
		"tubelib2_hole.png",
	},
	
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local nodes = Tube:update_tubes_after_place_node(pos, placer, pointed_thing)
		--print("nodes"..dump(nodes))
		if #nodes > 0 then
			for _,item in ipairs(nodes) do
				--print("after_place_node", item.type, item.param2)
				minetest.set_node(item.pos, {name = "tubelib2:tube"..item.type, param2 = item.param2})
			end
			return false
		else
			minetest.remove_node(pos)
			return true
		end
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		for _,item in ipairs(Tube:update_tubes_after_dig_node(pos, oldnode)) do
			--print("after_dig_node", item.type, item.param2)
			minetest.set_node(item.pos, {name = "tubelib2:tube"..item.type, param2 = item.param2})
		end
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-2/8, -2/8, -4/8,  2/8, 2/8, 4/8},
		},
	},
	node_placement_prediction = "", -- important!
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("tubelib2:tubeA", {
	description = "Tubelib2 Test tube",
	tiles = { -- Top, base, right, left, front, back
		"tubelib2_tube.png",
		"tubelib2_hole.png",
		"tubelib2_tube.png",
		"tubelib2_tube.png",
		"tubelib2_tube.png",
		"tubelib2_hole.png",
	},
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		for _,item in ipairs(Tube:update_tubes_after_dig_node(pos, oldnode)) do
			--print("after_dig_node", item.type, item.param2)
			minetest.set_node(item.pos, {name = "tubelib2:tube"..item.type, param2 = item.param2})
		end
	end,
	
	paramtype2 = "facedir", -- important!
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-2/8, -4/8, -2/8,  2/8, 2/8,  2/8},
			{-2/8, -2/8, -4/8,  2/8, 2/8, -2/8},
		},
	},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {crumbly = 3, cracky = 3, snappy = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	drop = "tubelib2:tubeS",
})

local function read_test_type(itemstack, placer, pointed_thing)
	local param2
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)	
		param2 = node.param2
	else
		param2 = 0
	end
	local num = math.floor(param2/32)
	local axis = math.floor(param2/4) % 8
	local rot = param2 % 4	
	minetest.chat_send_player(placer:get_player_name(), "[Tubelib2] param2 = "..param2.."/"..num.."/"..axis.."/"..rot)
	
	return itemstack
end

local function TEST_determine_tube_dirs(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.above
		local preferred_pos = pointed_thing.under
		local fdir = Tube:fdir(placer)
		local dir1, dir2, num_tubes = Tube:determine_tube_dirs(pos, preferred_pos, fdir)
		print("num_tubes="..num_tubes.." dir1="..(dir1 or "nil").." dir2="..(dir2 or "nil"))
	end
end

local function TEST_update_tubes_after_place_node(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.above
		local nodes = Tube:update_tubes_after_place_node(pos, placer, pointed_thing)
		print("nodes"..dump(nodes))
	end
end

local function TEST_add_tube_dir(itemstack, placer, pointed_thing)
	read_test_type(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.above
		local fdir = Tube:fdir(placer)
		local npos, d1, d2, num = Tube:add_tube_dir(pos, fdir)
		print("npos, d1, d2, num", npos and P(npos), d1, d2, num)
	end
end

local function TEST_del_tube_dir(itemstack, placer, pointed_thing)
	read_test_type(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.above
		local fdir = Tube:fdir(placer)
		local npos, d1, d2, num = Tube:del_tube_dir(pos, fdir)
		print("npos, d1, d2, num", npos and P(npos), d1, d2, num)
	end
end

local function read_param2(pos, player)
	local node = minetest.get_node(pos)	
	local num = math.floor(node.param2/32)
	local axis = math.floor(node.param2/4) % 8
	local rot = node.param2 % 4	
	minetest.chat_send_player(player:get_player_name(), "[Tubelib2] param2 = "..node.param2.."/"..num.."/"..axis.."/"..rot)
end

local function repair_tubes(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		if placer:get_player_control().sneak then
			local end_pos, dir = Tube:get_tube_end_pos(pos)
			minetest.chat_send_player(placer:get_player_name(), "[Tubelib2] end_pos = "..P(end_pos)..", dir = "..dir)
		else
			local pos1, pos2, dir1, dir2, cnt1, cnt2 = Tube:repair_tubes(pos)
			minetest.chat_send_player(placer:get_player_name(), "[Tubelib2] 1: "..P(pos1)..", dir = "..dir1..", "..cnt1.." tubes")
			minetest.chat_send_player(placer:get_player_name(), "[Tubelib2] 2: "..P(pos2)..", dir = "..dir2..", "..cnt2.." tubes")
		end
	end
end

local function remove_tube(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		if placer:get_player_control().sneak then
			read_param2(pos, placer)
		else
			Tube:remove_tube(pos, "default_break_glass")
		end
	end
end

-- Tool for tube workers to crack a tube line
minetest.register_node("tubelib2:tool", {
	description = "Tubelib2 Tool",
	inventory_image = "tubelib2_tool.png",
	wield_image = "tubelib2_tool.png",
	use_texture_alpha = true,
	groups = {cracky=1, book=1},
	on_use = remove_tube,
	on_place = repair_tubes,
	node_placement_prediction = "",
	stack_max = 1,
})

