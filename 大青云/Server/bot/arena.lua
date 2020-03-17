_G.script = function( bot )
	bot:delay( 2000 )
	
	bot:chat(1, '/arenaop/1')
	
	for i = 1, 9 do
		local req = ReqArenaBeChallengeRolelistMsg:new()
		req.type = 1
		bot:sendrpc( req, MsgType.WC_ArenaRolelist )
		
		local arenaList = bot.userdata.arenalist
		if arenaList and arenaList ~= {} then
			for k,arena in pairs(arenaList) do
				local reqChall = ReqArenaChallengeMsg:new()
				reqChall.rank = arena.rank
				bot:sendrpc( reqChall, -1)
				bot:delay(2000)
			end
		end
	end
	bot:delay(2000)
	bot:quit()
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.WC_ArenaRolelist then
		bot.userdata.arenalist = {}
		bot.userdata.arenalist = msg.ArenaList
	end
end