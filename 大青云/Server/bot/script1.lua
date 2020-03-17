-- script1.lua
_G.script = function( bot )
	bot:delay( 2000 )
	bot:rtrace('script1')
	local lines = 
	{
		1,
		2,
		3,
		4,
		5,
		6,
	}
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
	local id = math.random(1, #lines)
	bot:goline(lines[id])
	bot:delay( 2000 )
	
	local scenes = {
		11000001,
		11000005,
		11000003,
		11000004,
		11000006,
	}
	id = math.random(1, #scenes)
	bot:goscene(scenes[id])
	bot:delay( 2000 )
	
	for i = 1, 10 do
		bot:delay( 5000 )
		bot:chat(2, 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
		bot:runto( 0, 0 )
		bot:delay( 5000 )
		bot:chat(3, 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')
	end
	
	bot:quit()
end

_G.process = function( bot, msg )

end