
_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 2000 )
	bot:chat(1, "/levelup/100")
	local curr = 10100001
	while true do
		bot:delay( 2000 )
		if curr == 10100001 then
			curr = 10100002
		else
			curr = 10100001
		end
		bot:goscene(curr)
		bot:runto(0, 0)
	end

	bot:quit()
end

_G.process = function( bot, msg )
	
end
