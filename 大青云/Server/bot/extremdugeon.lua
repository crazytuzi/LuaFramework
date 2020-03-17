_G.script = function( bot )
	bot:delay( 1000 )
	bot.userdata.inextrem = false
	
	while true do
		bot:delay(1000)
		if not bot.userdata.inextrem then
			math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
			local msg = ReqExtremityEnterDataMsg:new()
			msg.state = math.random(1, 2)
			bot:sendrpc( msg, MsgType.SC_SCENE_ENTER_GAME )
		else
			bot:runto(0, 0)
			bot:test_skill()			
			local idx = math.random(1, 10000)
			if idx == 1 then
				break;
			end
		end
	end
	
	bot:quit()
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.SC_BackExtremityEnterData then
		if msg.result == 0 then
			bot.userdata.inextrem = true
		end
	elseif msg.msgId == MsgType.SC_BackExtremityQuit then
		bot.userdata.inextrem = false
	end
end