local monster_pos = {
	 {x=-510, z=712},
	 {x=-486, z=628},
	 {x=-514, z=556},
	 {x=-679, z=641},
	 {x=-725, z=552},
	 {x=-594, z=741},
	 {x=-638, z=458},
	 {x=-440, z=587},
	 
	 {x=-382, z=-53},
	 {x=-584, z=-24},
	 {x=-658, z=-43},
	 {x=-217, z=-36},
	 {x=-460, z=-25},
	 {x=-554, z=-46},
	 {x=-742, z=-41},
	 {x=-710, z=-27},
	 
	 {x=551, z=-669},
	 {x=717, z=-618},
	 {x=807, z=-509},
	 {x=518, z=-580},
	 {x=827, z=-676},
	 {x=423, z=-755},
	 {x=575, z=-294},
	 {x=532, z=-566},
	 
	 {x=770, z=575},	 
	 {x=580, z=690},
	 {x=711, z=721},
	 {x=879, z=720},
	 {x=490, z=516},
	 {x=320, z=678},
	 {x=741, z=402},
	 {x=921, z=744},
};

local boss_pos = {
	 {x=-591, z=449},
	 {x=-334, z=-317},
	 {x=652, z=-333},
	 {x=577, z=555},
};

local actid = 10006

_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 3000 )
	bot.userdata.isinact = false
	bot.userdata.dead = false
	
	while true do
		bot:delay( 1000 )
		Debug('hh', bot.account)
		local act = bot:activityInfo(actid)
		if act and act.state == 1 then
			Debug('open beichangjie', bot.account)
			if act.line ~= bot:getline() then
				bot:goline(act.line)
			end
			
			local msgEnter = ReqActivityEnterMsg:new()
			msgEnter.id = actid
			bot:sendrpc(msgEnter, MsgType.SC_SCENE_ENTER_SCENE_RET)
			bot:delay( 1000 )
			
			if bot.userdata.isinact then
				Debug('in beichangjie', bot.account)

				if bot.userdata.dead == true then
					bot:delay(6000)
					local revive = ReqReviveMsg:new()
					revive.reviveType = 2
					bot:sendrpc( revive, MsgType.SC_Revive )
				else
					local idx = math.random(1, 2)
					if idx == 1 then
						local pos = monster_pos[math.random(1, #monster_pos)]
						bot:runto(pos.x, pos.z)
					elseif idx == 2 then
						local pos = boss_pos[math.random(1, #boss_pos)]
						bot:runto(pos.x, pos.z)
					end	
					
					bot:test_skill()
				end
			else
				bot:chat(1, '/levelup/'.. tostring(t_activity[actid]['needLvl']))
			end				
		end
	end
	
	bot:quit()
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.WC_ActivityState then
		if bot.userdata.actinfo == nil then
			bot.userdata.actinfo = {}
		end
		for i, act in pairs(msg.list) do
			bot.userdata.actinfo[act.id] = act 
		end
	elseif msg.msgId == MsgType.SC_ActivityEnter then
		if msg.result == 0 then
			bot.userdata.isinact = true;
		end
	elseif msg.msgId == MsgType.SC_ActivityQuit then
		if msg.result == 0 then
			bot.userdata.isinact = false;
		end
	elseif msg.msgId == MsgType.SC_ObjDeadInfo then
		if bot.guid == msg.deadid then
			bot.userdata.dead = true
		end
	elseif msg.msgId == MsgType.SC_Revive then
		if bot.guid == msg.roleID  and msg.result == 0 then
			bot.userdata.dead = false
		end
	end
end