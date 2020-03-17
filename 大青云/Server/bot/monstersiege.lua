local boss_pos = {
	{x=80, z=-723}
}
local actid = 10007

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
			Debug('open monster siege', bot.account)
			if act.line ~= bot:getline() then
				bot:goline(act.line)
			end

			local msgEnter = ReqActivityEnterMsg:new()
			msgEnter.id = actid
			bot:sendrpc(msgEnter, MsgType.SC_SCENE_ENTER_SCENE_RET)
			bot:delay( 1000 )
			
			if bot.userdata.isinact then
				Debug('in monster siege', bot.account)

				if bot.userdata.dead == true then
					bot:delay(6000)
					local revive = ReqReviveMsg:new()
					revive.reviveType = 2
					bot:sendrpc( revive, MsgType.SC_Revive )
				else
					-- local idx = math.random(1, 2)
					-- if idx == 1 then
					-- 	local pos = monster_pos[math.random(1, #monster_pos)]
					-- 	bot:runto(pos.x, pos.z)
					-- elseif idx == 2 then
					-- 	local pos = boss_pos[math.random(1, #boss_pos)]
					-- 	bot:runto(pos.x, pos.z)
					-- end	
					local pos = boss_pos[math.random(1, #boss_pos)]
					bot:runto(pos.x, pos.z)
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