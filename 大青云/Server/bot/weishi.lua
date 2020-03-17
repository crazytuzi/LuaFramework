_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 2000 )

	while true do
		local lv = math.random(1, 6)
		bot:chat(1, '/reqweishi/'.. tostring(lv))
		bot:delay( 1000 )
	end

	bot:quit()
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.SC_PrerogativeReward then
		print("Type:" .. msg.type .. ", Ret:" .. msg.result .. ", Param:" .. msg.param)
	end
end