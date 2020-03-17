_G.script = function( bot )
	bot:delay( 2000 )
	
	for i = 1, 10 do
		local id = math.random(1, #activation_code)
		local req = ReqActivationCodeMsg.new()
		req.code = activation_code[id]
		bot:sendrpc(req, -1, 1000)
	end
	bot:delay( 5000 )
	bot:quit()
end

_G.process = function( bot, msg )
	
end