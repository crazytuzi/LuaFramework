local function my_pos(bot)
	local pos = {
		[1] = {
			["Boss"] = { x = 669, y = 26, dir = 8},
			["Human"]  = { x = 733, y = 26, dir = 4.3},
		},
		[2] = {
			["Boss"] = { x = 88, y = 16, dir = 8},
			["Human"]  = { x = 163, y = 16, dir = 4.3},
		},
		[3] = {
			["Boss"] = { x = -584, y = 37, dir = 8},
			["Human"]  = { x = -495, y = 37, dir = 4.3},
		},	
	}
	local idx = (bot.userdata.layer -1)%3 + 1
	bot:runto( pos[idx]["Boss"].x, pos[idx]["Boss"].y)
end


_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 2000 )

	bot.userdata.layer = 1
	bot.userdata.status = 0

	local lv = math.random(40, 100)
	bot:chat(1, '/levelup/' .. lv)
	--bot:chat(1, '/whosyourdaddy')
	bot:delay( 1000 )

	local req_info = ReqGetBabelInfoMsg:new()
	req_info.layer = 0
	bot:sendrpc( req_info, MsgType.SC_BackBabel )
	bot:delay( 1000 )

	while true do
		local enter = ReqEnterIntoMsg:new()
		enter.layer = bot.userdata.layer
		bot:sendrpc( enter, MsgType.SC_BackBabelNowInfo )
		bot:delay( 2000 )
		Debug("Enter OK", bot.userdata.status, bot.account)
		while bot.userdata.status == 1 do
			local start = ReqsSendStoryEndMsg:new()
			start.type = 1
			bot:sendrpc( start, MsgType.SC_BackStoryEnd )
			bot:delay( 1000 )
			Debug("Babel Start", bot.userdata.status, bot.account)
			while bot.userdata.status >= 2 do
				Debug("Babel kill", bot.userdata.status, bot.account)
				my_pos(bot)
				bot:test_skill()
				bot:delay(1000)

				if bot.userdata.status == 3 then
					local quit = ReqOutBabelMsg:new()
					quit.state = 2
					bot:sendrpc( quit, MsgType.SC_BackBabelOut )
					bot:chat(1, '/levelup/1')
					bot:delay( 2000 )
				elseif bot.userdata.status == 4 then
					local quit = ReqOutBabelMsg:new()
					quit.state = math.random(1, 2)
					bot:sendrpc( quit, MsgType.SC_BackBabelOut )
					bot:delay( 2000 )
				end
			end
		end
	end
end


_G.process = function( bot, msg )
	if msg.msgId == MsgType.SC_BackBabel then
		bot.userdata.layer = msg.layer
	end

	if msg.msgId == MsgType.SC_BackBabelNowInfo then
		bot.userdata.status = 1
	end

	if msg.msgId == MsgType.SC_BackStoryEnd then
		bot.userdata.status = 2
	end

	if msg.msgId == MsgType.SC_BackBabelResultInfo then
		print("Babel End", msg.state)
		if msg.state == 0 then
			bot.userdata.status = 3
		else
			bot.userdata.layer = bot.userdata.layer + 1
			if bot.userdata.layer > 100 then
				bot.userdata.layer = 1
			end
			bot.userdata.status = 4
		end 	
	end
	if msg.msgId == MsgType.SC_BackBabelOut then
		if msg.state == 0 then
			print("Quit OK")
			bot.userdata.status = 1
		else
			print("Quit Err ~")
		end
	end

end