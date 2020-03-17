_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 3000 )

	bot.userdata.dead = false
	bot.userdata.actID = math.random(1, 5)
	bot.userdata.inact = false

	while true do
		if not bot.userdata.inact then
			bot:chat(1, '/levelup/1')

			local reqAct = ReqWorldBossMsg:new()
			bot:sendrpc( reqAct, MsgType.WC_ActivityState )

			if bot.userdata.lineID ~= nil and bot.userdata.lineID ~= bot:getline() then
				bot:goline(bot.userdata.lineID)
				bot:delay(3000)
			end

			local enter = ReqActivityEnterMsg:new()
			enter.id    = bot.userdata.actID
			bot:sendrpc( enter, MsgType.SC_ActivityEnter )
		else
			bot:wuhun(math.random(0,1))
			bot:runto( -27, -76 )
			if bot.userdata.dead == true then
				bot:delay(6000)
				local revive = ReqReviveMsg:new()
				revive.reviveType = 2
				bot:sendrpc( revive, MsgType.SC_Revive )
				bot:delay(1000)
			else
				bot:test_skill()
				bot:runto( 0, 0 )
			end
		end
	end

	bot:quit()
end

_G.process = function( bot, msg )
	
	if msg.msgId == MsgType.WC_WorldBoss then
		for i,vo in ipairs(msg.list) do
			if vo.id == bot.userdata.actID  then
				bot.userdata.lineID = vo.line
				break
			end
		end
	end

	if msg.msgId == MsgType.SC_ObjDeadInfo then
		if bot.guid == msg.deadid then
			bot.userdata.dead = true
		end
	end

	if msg.msgId == MsgType.SC_Revive then
		if bot.guid == msg.roleID  and msg.result == 0 then
			bot.userdata.dead = false
		end
	end

	if msg.msgId == MsgType.SC_ActivityEnter then
		if msg.result == 0 then
			bot.userdata.inact = true
		end
	end

	if msg.msgId == MsgType.SC_ActivityQuit then
		if msg.result == 0 then
			bot.userdata.inact = false
		end
	end
end