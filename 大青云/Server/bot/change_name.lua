local function randname(bot)
	local name = ''
	if bot.prof == 2 or bot.prof == 3 then
		name = t_mansurname[math.random(1, #t_mansurname)].name .. t_manname[math.random(1, #t_manname)].name
	elseif bot.prof == 1 or bot.prof == 4 then
		name = t_womansurname[math.random(1, #t_womansurname)].name .. t_womanname[math.random(1, #t_womanname)].name
	end

	return name
end

_G.script = function( bot )

	bot.userdata.items = {}

	bot:goscene(10100001)

	bot:delay(3000)

	while true do
		bot:chat(1, "/createitem/140649408/1")
		bot:delay(1000)

		for k,v in pairs(bot.userdata.items) do
			local req = ReqChangePlayerNameMsg:new()
			req.itemId = k
			req.roleName = randname(bot)
			bot:sendrpc(req, 0)

			bot:delay(1000)

			bot:runto(0, 0)
		end

		bot:delay(3000)
	end
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.SC_ItemAdd then
		bot.userdata.items[msg.id] = msg.id
	elseif msg.msgId == MsgType.SC_ItemDel then
		bot.userdata.items[msg.id] = nil
	elseif msg.msgId == MsgType.SC_QueryItemResult then
		for k,v in pairs(msg.items) do
			bot.userdata.items[v.id] = v.id
		end
	end
end