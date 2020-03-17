local crosshost = "192.168.1.220:8201"

local bronpos = {
	{x = 8, y = 111, dir = 6.25},
	{x = 2, y = -135, dir = 2.83}
}

_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 3000 )

	bot:chat(1, '/levelup/100')
	bot:chat(1, '/funcopen/64')

	bot.userdata.crossinfo = nil
	bot.userdata.matchinfo = nil

	while true do
		bot:delay( 1000 )

		if bot.userdata.matchinfo == nil then
			local reqMatch = ReqStartMatchPvpMsg:new()
			bot:sendrpc(reqMatch, 0)
			Debug('match ', bot.account)
		elseif bot.userdata.crossinfo ~= nil then
			if bot.userdata.crossinfo.state == 1 then
				bot.userdata.crossinfo.state = 2
				Debug('start cross ', bot.account)
				bot:quit(false)
				bot:connect(true, crosshost)
			elseif bot.userdata.crossinfo.state == 2 and bot.isconn then
				bot.userdata.crossinfo.state = 3
				Debug('con cross ', bot.account)
				local reqEnter = ReqConCrossFightMsg:new()
				reqEnter.guid = bot.guid
				reqEnter.accountID = bot.account
				reqEnter.sign = bot.userdata.crossinfo.sign
				bot:sendrpc(reqEnter, MsgType.RC_ConCrossFightResult)
			elseif bot.userdata.crossinfo.state == 4 then
				bot.userdata.crossinfo.state = 5
				Debug('enter cross ', bot.account)
				local reqEnter = ReqEnterCrossFightMsg:new()
				bot:sendrpc(reqEnter, MsgType.RC_EnterCrossFight)
			elseif bot.userdata.crossinfo.state == 6 then
				local pos = bronpos[math.random(1, #bronpos)]
				bot:runto(pos.x, pos.y)
				bot:runto(0, 0)
				bot:test_skill()
				Debug('in cross ', bot.account)
			elseif bot.userdata.crossinfo.state == 7 then
				bot.userdata.crossinfo.state = 8
				Debug('quit cross ', bot.account)
				local reqQuit = ReqQuitCrossFightPvpMsg:new()
				bot:sendrpc(reqQuit, MsgType.RC_EnterCrossFight)
			elseif bot.userdata.crossinfo.state == 9 then
				bot.userdata.crossinfo.state = 10
				Debug('start game ', bot.account)
				bot:quit(false)
				bot:connect(true)
			elseif bot.userdata.crossinfo.state == 10 and bot.isconn then
				bot.userdata.crossinfo.state = 11
				Debug('con game ', bot.account)
				local reqEnter = ReqReEnterGameMsg:new()
				reqEnter.guid = bot.guid
				reqEnter.accountID = bot.account
				reqEnter.sign = bot.userdata.crossinfo.endsign
				bot:sendrpc(reqEnter, MsgType.WC_ReEnterGame)
			elseif bot.userdata.crossinfo.state == 12 then
				bot.userdata.crossinfo.state = 13
				Debug('enter game ', bot.account)
				local reqEnter = ReqReEnterSceneMsg:new()
				bot:sendrpc(reqEnter, MsgType.WC_ReEnterScene)
			elseif bot.userdata.crossinfo.state == 14 then
				Debug('in game ', bot.account)
				bot:delay( 10000 )
				bot.userdata.matchinfo = nil
				bot.userdata.crossinfo = nil
			end
		end
	end
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.WC_CrossFightInfo then
		bot.userdata.crossinfo = {}
		bot.userdata.crossinfo.sign = msg.sign
		bot.userdata.crossinfo.state = 1
	elseif msg.msgId == MsgType.WC_StartMatchPvpRet then
		if msg.result == 0 then
			bot.userdata.matchinfo = true
		end
		Debug('match result ', bot.account, msg.result)
	elseif msg.msgId == MsgType.RC_ConCrossFightResult then
		if msg.result == 0 then
			bot.userdata.crossinfo.state = 4
		end
		Debug('con cross result ', bot.account, msg.result)
	elseif msg.msgId == MsgType.RC_EnterCrossFight then
		if msg.result == 0 then
			bot.userdata.crossinfo.state = 6
		end
		Debug('enter cross result ', bot.account, msg.result)
	elseif msg.msgId == MsgType.SC_RewardFightPvp1 then
		bot.userdata.crossinfo.state = 7
	elseif msg.msgId == MsgType.RC_EndCrossFight then
		bot.userdata.crossinfo.state = 9
		bot.userdata.crossinfo.endsign = msg.sign
	elseif msg.msgId == MsgType.WC_ReEnterGame then
		if msg.result == 0 then
			bot.userdata.crossinfo.state = 12
		end
		Debug('con game result ', bot.account, msg.result)
	elseif msg.msgId == MsgType.WC_ReEnterScene then
		if msg.result == 0 then
			bot.userdata.crossinfo.state = 14
		end
		Debug('enter game result ', bot.account, msg.result)
	end
end