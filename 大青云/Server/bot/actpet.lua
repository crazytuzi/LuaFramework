local function randop(bot)
	local op = math.random(1, 4)
	if op == 1 then
		local reqmsg = ReqAdjunctionWuHunMsg:new()
		reqmsg.wuhunId = bot.userdata.wuhunid
		reqmsg.wuhunFlag = math.random(1, 2) - 1
		bot:sendrpc(reqmsg, 0)
	elseif op == 2 then
		local reqmsg = ReqFeedWuHunMsg:new()
		reqmsg.wuhunId = bot.userdata.wuhunid
		reqmsg.feedNum = math.random(1, 10)
		bot:sendrpc(reqmsg, 0)
	elseif op == 3 then
		local reqmsg = ReqProceWuHunMsg:new()
		reqmsg.wuhunId = bot.userdata.wuhunid
		reqmsg.autobuy = math.random(0,2)
	elseif op == 4 then
		bot:randompack(1000, 2000, math.random(0, 100), false)
	end
end

_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 3000 )

	bot:chat(1, '/funcopen/4')
	bot:chat(1, '/levelup/50')

	while true do
		bot:delay( 3000 )
		randop(bot)
		bot:runto(0, 0)
		bot:test_skill()
	end
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.SC_WuHunLingshouInfoResult then
		bot.userdata.wuhunid = msg.wuhunId
	end
end