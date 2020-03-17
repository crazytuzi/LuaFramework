_G.script = function( bot )

	bot:delay(3000)

	local id = bot:id()
	--bot:loginaccount(accountlist[id])

	while true do 
		bot:runto( 0, 0 )
		bot:delay( 3000 )
		bot:test_skill()
	end
end

_G.process = function( bot, msg )

end