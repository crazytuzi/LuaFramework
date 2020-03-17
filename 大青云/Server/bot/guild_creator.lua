_G.script = function( bot )
	bot:delay( 1000 )

	while true do
		bot:delay( 1000 )
		if bot.userdata.guildId == '0_0' then
			bot:outguildop(1)
			
			local auto = ReqSetAutoVerify:new()
			auto.bAuto = 1
			auto.level = 1
			bot:sendrpc(auto, 0)
		else
			bot:inguildop()
		end
	end
	
	bot:delay( 2000 )
	bot:quit()
end

_G.process = function( bot, msg )
	
end