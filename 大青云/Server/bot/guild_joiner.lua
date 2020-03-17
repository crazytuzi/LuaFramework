_G.script = function( bot )
	bot:delay( 2000 )

	while true do
		bot:delay( 1000 )
		if bot.userdata.guildId == '0_0' then
			bot:outguildop(2)
		else
			bot:inguildop()
		end
	end
	
	bot:quit()
end

_G.process = function( bot, msg )

end