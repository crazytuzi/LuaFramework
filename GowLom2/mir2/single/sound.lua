local sound = {
	enable = true,
	suffix = ".mp3",
	root = "mp3/",
	init = function ()
		local lastName = cache.getLastPlayerName()

		if lastName and lastName ~= "" then
			local saves = cache.getSetting(lastName, "base")

			if saves and saves.soundEnable ~= nil then
				sound.setEnable(saves.soundEnable)
			end
		end

		return 
	end,
	setEnable = function (b)
		sound.enable = b

		return 
	end,
	preloadSound = function (filename)
		if not sound.enable then
			return 
		end

		audio.preloadSound(sound.root .. filename .. sound.suffix)

		return 
	end,
	playMusic = function (filename, isLoop)
		if not sound.enable then
			return 
		end

		audio.playMusic(sound.root .. filename .. sound.suffix, isLoop)

		return 
	end,
	stopMusic = function ()
		audio.stopMusic()

		return 
	end,
	playSound = function (filename, sync)
		if not sound.enable then
			return 
		end

		return audio.playSound(sound.root .. filename .. sound.suffix, sync)
	end,
	stopSound = function (handle)
		audio.stopSound(handle)

		return 
	end,
	getFullPathWithoutAssetsPrefix = function (filename)
		local path = cc.FileUtils:getInstance():fullPathForFilename(sound.root .. filename .. sound.suffix)

		if string.find(path, "assets/") then
			path = string.sub(path, string.len("assets/"))
		end

		return path
	end,
	setPriority = function (filename, priority)
		if device.platform == "android" then
			filename = sound.getFullPathWithoutAssetsPrefix(filename)

			luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "setEffectPriority", {
				filename,
				priority
			}, "(Ljava/lang/String;I)V")
		end

		return 
	end,
	stopAllSounds = function ()
		return audio.stopAllSounds()
	end,
	play = function (type, params)
		if not sound.enable then
			return 
		end

		local handler = sound["handle_" .. type]

		if handler then
			local filename, delayTime = handler(params)

			if filename then
				local function play()
					audio.playSound(sound.root .. filename .. sound.suffix)

					return 
				end

				if delayTime then
					scheduler.performWithDelayGlobal(slot5, delayTime)
				else
					play()
				end
			end
		end

		return 
	end,
	handle_item = function (data)
		local stdMode = data.getVar(data, "stdMode")

		if stdMode == 0 then
			local shape = data.getVar(data, "shape")

			if shape ~= 3 then
				sound.playSound(sound.s_click_drug)
			else
				sound.playSound(sound.s_itmclick)
			end
		elseif stdMode == 31 then
			if checkIn(data.getVar(data, "aniCount"), 1, 3) then
				sound.playSound(sound.s_click_drug)
			else
				sound.playSound(sound.s_itmclick)
			end
		elseif checkExist(stdMode, 5, 6) then
			sound.playSound(sound.s_click_weapon)
		elseif checkExist(stdMode, 10, 11) then
			sound.playSound(sound.s_click_armor)
		elseif checkExist(stdMode, 22, 23) then
			sound.playSound(sound.s_click_ring)
		elseif checkExist(stdMode, 24, 26) then
			local name = data.getVar(data, "name")

			if string.find(name, " ÷ÔÌ") or string.find(name, " ÷Ã◊") then
				sound.playSound(sound.s_click_grobes)
			else
				sound.playSound(sound.s_click_armring)
			end
		elseif checkExist(stdMode, 19, 20, 21) then
			sound.playSound(sound.s_click_necklace)
		elseif stdMode == 15 then
			sound.playSound(sound.s_click_helmet)
		else
			sound.playSound(sound.s_itmclick)
		end

		return 
	end,
	handle_appr = function (soundid)
		return soundid
	end,
	handle_born = function (soundid)
		return soundid
	end,
	handle_mon = function (params)
		local role = params.role
		local act = params.act

		if act.type == "attack" then
			return role.sounds.attack
		elseif act.type == "struck" then
			sound.play("mon_weapon", params)

			return role.sounds.scream
		elseif act.type == "die" and not act.corpse and not act.gutou then
			return role.sounds.die
		end

		return 
	end,
	handle_mon_weapon = function (params)
		local hiter = params.act.hiter
		local role = params.map:findRole(hiter)

		if role then
			if not checkExist(role.getRace(role), 0, 1, 150) then
				return 
			end

			local filename = nil
			local weapon = role.getWeapon(role)

			if checkExist(weapon, 6, 20) then
				filename = sound.s_struck_short
			elseif weapon == 1 then
				filename = sound.s_struck_wooden
			elseif checkExist(weapon, 2, 13, 9, 5, 14, 22) then
				filename = sound.s_struck_sword
			elseif checkExist(weapon, 4, 17, 10, 15, 16, 23) then
				filename = sound.s_struck_do
			elseif checkExist(weapon, 3, 7, 11) then
				filename = sound.s_struck_axe
			elseif checkExist(weapon, 24) then
				filename = sound.s_struck_club
			elseif checkExist(weapon, 8, 12, 18, 21) then
				filename = sound.s_struck_wooden
			end

			return filename
		end

		return 
	end,
	handle_footStep = function (params)
		local map = params.map
		local role = params.role
		local delay = params.delay

		if not map or not role then
			return 
		end

		local mapfile = res.loadmap(map.replaceMapid or map.mapid)
		local data = mapfile.gettile(mapfile, math.floor(role.x/2)*2, math.floor(role.y/2)*2)

		if not data then
			return 
		end

		local function get()
			local footstepsound = nil
			local idx = ycFunction:band(data.bgidx, 32767)
			local uidx = data.objFileIdx
			idx = (uidx*10000 + idx) - 1

			if checkIn(idx, {
				330,
				349
			}, {
				450,
				454
			}, {
				550,
				554
			}, {
				750,
				754
			}, {
				950,
				954
			}, {
				1250,
				1254
			}, {
				1400,
				1424
			}, {
				1455,
				1474
			}, {
				1500,
				1524
			}, {
				1550,
				1574
			}) then
				footstepsound = sound.s_walk_lawn_l
			elseif checkIn(idx, {
				250,
				254
			}, {
				1005,
				1009
			}, {
				1050,
				1054
			}, {
				1060,
				1064
			}, {
				1450,
				1454
			}, {
				1650,
				1654
			}) then
				footstepsound = sound.s_walk_rough_l
			elseif checkIn(idx, {
				605,
				609
			}, {
				650,
				654
			}, {
				660,
				664
			}, {
				2000,
				2049
			}, {
				3025,
				3049
			}, {
				2400,
				2424
			}, {
				4625,
				4649
			}, {
				4675,
				4678
			}) then
				footstepsound = sound.s_walk_stone_l
			elseif checkIn(idx, {
				1825,
				1924
			}, {
				2150,
				2174
			}, {
				3075,
				3099
			}, {
				3325,
				3349
			}, {
				3375,
				3399
			}) then
				footstepsound = sound.s_walk_cave_l
			elseif checkExist(idx, 3230, 3231, 3246, 3277) then
				footstepsound = sound.s_walk_wood_l
			elseif checkIn(idx, {
				3780,
				3799
			}) then
				footstepsound = sound.s_walk_wood_l
			elseif checkIn(idx, {
				3825,
				4434
			}) then
				if (idx - 3825)%25 == 0 then
					footstepsound = sound.s_walk_wood_l
				else
					footstepsound = sound.s_walk_ground_l
				end
			elseif checkIn(idx, {
				2075,
				2099
			}, {
				2125,
				2149
			}) then
				footstepsound = sound.s_walk_room_l
			elseif checkIn(idx, {
				1800,
				1824
			}) then
				footstepsound = sound.s_walk_water_l
			else
				footstepsound = sound.s_walk_ground_l
			end

			if checkIn(idx, {
				825,
				1349
			}) and math.floor((idx - 825)/25)%2 == 0 then
				footstepsound = sound.s_walk_stone_l
			end

			if checkIn(idx, {
				1375,
				1799
			}) and math.floor((idx - 1375)/25)%2 == 0 then
				footstepsound = sound.s_walk_cave_l
			end

			if checkExist(1385, 1386, 1391, 1392) then
				footstepsound = sound.s_walk_wood_l
			end

			idx = ycFunction:band(data.mididx, 32767)
			idx = idx - 1

			if checkIn(idx, {
				0,
				115
			}) then
				footstepsound = sound.s_walk_ground_l
			elseif checkIn(idx, {
				120,
				124
			}) then
				footstepsound = sound.s_walk_lawn_l
			end

			idx = ycFunction:band(data.objidx, 32767)
			idx = idx - 1

			if checkIn(idx, {
				221,
				289
			}, {
				583,
				658
			}, {
				1183,
				1206
			}, {
				7163,
				7295
			}, {
				7404,
				7414
			}) then
				footstepsound = sound.s_walk_stone_l
			elseif checkIn(idx, {
				3125,
				3267
			}, {
				3757,
				3948
			}, {
				6030,
				6999
			}) then
				footstepsound = sound.s_walk_wood_l
			elseif checkIn(idx, {
				3316,
				3589
			}) then
				footstepsound = sound.s_walk_room_l
			end

			return footstepsound
		end

		local ret = slot6()

		sound.playSound(ret)

		return ret + 1, delay/2
	end,
	handle_hit = function (params)
		local role = params.role
		local effect = params.effect
		local delay = params.delay

		if effect and effect.type == "long" then
			return "m12-1", delay/2
		elseif effect and effect.type == "sword" then
			if role.sex == 0 then
				idx = 0
			else
				idx = 3
			end

			return "m56-" .. idx, delay/2
		elseif effect and effect.magicId then
			local magicId = tonumber(effect.magicId)
			local idx = 1

			if checkExist(magicId, 7) then
				idx = role.sex + 1
			elseif magicId == 26 then
				idx = 3
			end

			return "m" .. magicId .. "-" .. idx, delay/2
		else
			local race = role.getRace(role)

			if not checkExist(race, 0, 1, 150) then
				return 
			end

			local filename = nil
			local weapon = role.getWeapon(role)

			if checkExist(weapon, 6, 20) then
				filename = sound.s_hit_short
			elseif weapon == 1 then
				filename = sound.s_hit_wooden
			elseif checkExist(weapon, 2, 13, 9, 5, 14, 22) then
				filename = sound.s_hit_sword
			elseif checkExist(weapon, 4, 17, 10, 15, 16, 23) then
				filename = sound.s_hit_do
			elseif checkExist(weapon, 3, 7, 11) then
				filename = sound.s_hit_axe
			elseif checkExist(weapon, 24) then
				filename = sound.s_hit_club
			elseif checkExist(weapon, 8, 12, 18, 21) then
				filename = sound.s_hit_long
			else
				filename = sound.s_hit_fist
			end

			return filename, delay/2
		end

		return 
	end,
	handle_skillSpell = function (params)
		local role = params.role
		local magicId = tonumber(params.magicId)

		if not role or not magicId then
			return 
		end

		if checkExist(magicId, 8) then
			return 
		end

		local idx = 1

		if checkExist(magicId, 43, 58) then
			idx = 0
		end

		if magicId == 59 then
			magicId = 58
			idx = 0
		elseif magicId == 36 then
			magicId = 37
			idx = 1
		elseif magicId == 34 then
			magicId = 100
			idx = 2
		end

		return "m" .. magicId .. "-" .. idx
	end,
	handle_skillPlay = function (params)
		local magicId = tonumber(params.magicId)

		if not magicId then
			return 
		end

		if checkExist(magicId, 24) then
			return 
		end

		local idx = nil

		if params.idx then
			idx = params.idx
		else
			idx = 2

			if checkExist(magicId, 2, 9, 16, 20, 23, 28, 29, 30, 32, 33) then
				idx = 3
			end
		end

		if magicId == 59 then
			magicId = 58
			idx = 3
		end

		if magicId == 6 and idx == 2 then
			return 
		end

		return "m" .. magicId .. "-" .. idx
	end,
	monSounds = function (appr)
		local ret = appr*10 + 200
		ret = sound.monReplaceTable[ret] or ret

		if type(ret) == "table" then
			return {
				appr = ret[1],
				born = ret[2],
				attack = ret[3],
				weapon = ret[4],
				scream = ret[5],
				die = ret[6]
			}
		else
			return {
				appr = ret .. "-0",
				born = ret .. "-1",
				attack = ret .. "-2",
				weapon = ret .. "-3",
				scream = ret .. "-4",
				die = ret .. "-5"
			}
		end

		return 
	end,
	monReplaceTable = {
		[1120.0] = 1360,
		[1300.0] = 1310,
		[1270.0] = 1260,
		[2780.0] = 1200,
		[1250.0] = 1240,
		[1130.0] = 1360,
		[2810.0] = 900,
		[2800.0] = 1100,
		[690.0] = 680,
		[2840.0] = 210,
		[2820.0] = 1200,
		[300] = {
			"300-1",
			"300-1",
			"300-2",
			nil,
			"300-4",
			"300-5"
		},
		[570] = {
			"m17-3",
			nil,
			"54",
			"64",
			nil,
			"570-5"
		},
		[1900] = {
			"m30-3",
			"1900-1",
			nil,
			nil,
			"1900-4",
			"1900-5"
		},
		[1920] = {
			"1920-0",
			"1920-1",
			"m11-1",
			"m11-2",
			"1920-4",
			"1920-5"
		},
		[2140] = {
			nil,
			"2140-1",
			"2130-2",
			"2140-3",
			"2130-4",
			"2130-5"
		},
		[2150] = {
			nil,
			"2150-1",
			"2130-2",
			"2150-3",
			"2130-4",
			"2130-5"
		},
		[2380] = {
			nil,
			"2370-1",
			nil,
			"2380-3",
			"2370-4",
			"2370-5"
		},
		[2790] = {
			nil,
			"630-1",
			"65",
			nil,
			"630-4",
			"630-5"
		},
		[8220] = {
			nil,
			nil,
			"8220-6"
		},
		[9220] = {
			"9210-0",
			nil,
			nil,
			nil,
			"9220-4",
			"9210-5"
		},
		[9230] = {
			"9210-0",
			nil,
			nil,
			nil,
			"9220-4",
			"9210-5"
		}
	}
}

table.merge(slot0, {
	bmg_field = "field2",
	s_run_room_r = 28,
	s_walk_wood_r = 18,
	s_click_necklace = 115,
	s_struck_body_longstick = 72,
	s_walk_water_r = 30,
	s_run_lawn_r = 12,
	s_hit_long = 56,
	s_click_ring = 113,
	s_eat_drug = 107,
	s_walk_ground_l = 1,
	s_struck_sword = 62,
	s_walk_stone_l = 5,
	s_glass_button_click = 105,
	s_click_armor = 112,
	s_run_rough_l = 15,
	s_hit_do = 53,
	powerup_ground = "powerup",
	hero_login = "herologin",
	s_run_water_r = 32,
	s_walk_lawn_l = 9,
	s_meltstone = 101,
	bmg_intro = "log-in-long2",
	s_spacemove_out = 109,
	s_spacemove_in = 110,
	s_hit_club = 55,
	s_money = 106,
	s_main_theme = 102,
	s_hit_wooden = 51,
	s_struck_armor_axe = 81,
	s_rock_button_click = 104,
	s_struck_armor_sword = 80,
	s_run_stone_r = 8,
	s_walk_cave_l = 21,
	s_yedo_man = 130,
	s_struck_armor_fist = 83,
	s_yedo_woman = 131,
	s_longhit = 132,
	s_struck_body_fist = 73,
	s_run_cave_l = 23,
	s_widehit = 133,
	bmg_select = "sellect-loop2",
	s_rush_l = 134,
	s_firehit_ready = 136,
	s_wom_struck = 139,
	s_unitehit0 = 138,
	s_firehit = 137,
	s_man_die = 144,
	s_walk_cave_r = 22,
	s_run_room_l = 27,
	s_click_armring = 114,
	s_struck_armor_longstick = 82,
	hero_logout = "herologout",
	s_click_weapon = 111,
	s_click_helmet = 116,
	s_run_wood_r = 20,
	s_intro_theme = 102,
	s_struck_short = 60,
	s_rush_r = 135,
	s_struck_body_axe = 71,
	s_walk_rough_l = 13,
	s_man_struck = 138,
	s_walk_room_r = 26,
	s_struck_wooden = 61,
	s_hit_short = 50,
	s_norm_button_click = 103,
	s_struck_do = 63,
	s_hit_axe = 54,
	s_struck_club = 65,
	s_struck_axe = 64,
	s_struck_body_sword = 70,
	s_run_lawn_l = 11,
	s_run_cave_r = 24,
	s_hit_sword = 52,
	s_run_stone_l = 7,
	s_run_ground_r = 4,
	s_run_water_l = 31,
	s_walk_water_l = 29,
	s_walk_rough_r = 14,
	s_unionhit1 = 123,
	s_walk_ground_r = 2,
	s_unionhit0 = 122,
	s_run_ground_l = 3,
	s_run_rough_r = 16,
	s_walk_lawn_r = 10,
	bmg_gameover = "game_over2",
	s_walk_room_l = 25,
	s_click_drug = 108,
	s_run_wood_l = 19,
	s_hit_fist = 57,
	s_unionhit2 = 124,
	s_click_grobes = 117,
	s_drop_stonepiece = 92,
	s_itmclick = 118,
	s_strike_stone = 91,
	s_rock_door_open = 100,
	s_walk_stone_r = 6,
	s_wom_die = 145,
	s_walk_wood_l = 17
})

return sound
