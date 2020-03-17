_G.script = function( bot )
	bot:delay( 1000 )

	bot.userdata.bossline = nil
	bot.userdata.inboss = false

	while bot.userdata.guildId == '0_0' do
		bot:outguildop(2)
		bot:delay( 1000 )
	end

	while true do
		bot:delay( 1000 )

		if bot.userdata.inboss then
			bot:runto(-100, 0)
			if bot.userdata.dead == true then
				bot:delay(6000)
				local revive = ReqReviveMsg:new()
				revive.reviveType = 2
				bot:sendrpc( revive, MsgType.SC_Revive )
				bot:delay(1000)
			else
				bot:runto( 0, 0 )
				bot:test_skill()
			end
		elseif bot.userdata.openboss then
			local msg = ReqUnionBossActivityEnterMsg:new()
			bot:sendrpc(msg, MsgType.WC_UnionBossActivityEnterResult)
			if bot.userdata.bossline then
				if bot.userdata.bossline ~= bot:getline() then
					bot:goline(bot.userdata.bossline)
				end

				local msgEnter = ReqUnionBossActivitySureEnterMsg:new()
				bot:sendrpc(msgEnter, MsgType.SC_SCENE_ENTER_SCENE_RET)
				bot.userdata.inboss = true
			end
		else
			bot:inguildop()
			local msg = ReqUnionBossActivityOpenMsg:new()
			msg.Id = math.random(1, 15)
			bot:sendrpc(msg, MsgType.WC_UnionBossActivityOpen)
		end
	end

	bot:quit()
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.WC_UnionBossActivityRemind then
		if msg.result == 2 then
			bot.userdata.openboss = true
		else
			bot.userdata.openboss = false
			bot.userdata.inboss = false
		end
	elseif msg.msgId == MsgType.WC_UnionBossActivityEnterResult then
		if msg.result == 0 then
			bot.userdata.bossline = msg.lineID
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