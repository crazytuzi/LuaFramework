local function my_skill(bot)
	local skills = {
		1001001,
		1002001,
		1003001,
		1004001,
		1005001,
		1006001,
	}
	id = math.random(1, #skills)
	--print(skills[id])
	bot:skill( skills[id] )
end

local function my_run(bot)
	local pos = {
		[1] = {x = -6, y = 30 },
		[1] = {x = -321, y = 358},
		[2] = {x = 204, y = 252},
		[3] = {x = -169, y = -384},
		[1] = {x = -180, y = 563},
		[2] = {x = 104, y = 558},
		[3] = {x = 275, y = 232},
		[4] = {x = 221, y = 123},
		[5] = {x = 291, y = -168},
	}
	id = math.random(1, #pos)
	--print(id)
	bot:runto( pos[id].x, pos[id].y )
end

_G.script = function( bot )
	bot:delay( 1000 )

	local botGid = bot.userdata.guildId
	if botGid ~= '0_0' then
		local msg = ReqUnionWarActMsg:new()
		bot:sendrpc( msg, MsgType.WC_UnionWarAct )
		if bot.userdata.lineID ~= nil then
			bot:goline(bot.userdata.lineID)
			bot:delay(3000)
			--if bot.userdata.golineResult == 0 then
				local enter = ReqEnterGuildWarMsg:new()
				bot:sendrpc( enter, MsgType.SC_SCENE_ENTER_SCENE_RET )
				bot:delay(3000)
				bot:chat(1, '/whosyourdaddy')
				for i = 1, 50 do
					if bot.userdata.succ == 1 then
						bot.userdata.type = 1
						bot:delay(10000)
					end
					if bot.userdata.type == 0 then
						bot:runto(5, -34)
						my_skill(bot)
						bot:delay(3000)
					else
						my_run(bot)
						my_skill(bot)
						bot:delay(3000)
					end			
				end
			--end
		end
	end
	
	bot:delay( 2000 )
	bot:quit()
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.WC_QueryMyGuildInfo then
		bot.userdata.guildId = msg.guildId
	elseif msg.msgId == MsgType.WC_UnionWarAct then
		bot.userdata.lineID = msg.lineID
		bot.userdata.type = msg.type
	elseif msg.msgId == MsgType.WC_SwitchLineRet then
		bot.userdata.golineResult = msg.result
	elseif msg.msgId == MsgType.SC_UnionWarNpcHungUp then
		bot.userdata.succ = 1
	end
end