_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 3000 )

	while true do
		bot:delay(math.random(1000,10000))
		if bot.isconn then
			bot:runto(0, 0)
			bot:test_skill()
			bot:quit(false)
			bot:connect(false)
		end
	end
end

_G.process = function( bot, msg )

end