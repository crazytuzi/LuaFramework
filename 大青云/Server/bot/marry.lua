local ringcfgId = {
	140640113,
	140640114,
	140640115,
};

_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 3000 )

	bot:chat(1, '/levelup/150')

	while true do
		local marrystate = bot.userdata.marryinfo.marryState
		bot:runto(0, 0)
		if marrystate == 0 then							--单身
			local msgRelation = ReqRelationChangeList:new()
			bot:sendrpc(msgRelation, MsgType.WC_RelationList)

			if bot.userdata.relationinfo and #bot.userdata.relationinfo > 0 then

				bot:chat(1, '/createitem/' .. ringcfgId[math.random(1, #ringcfgId)] .. "/1")

				local rndidx = math.random(1, 2)
				if bot.userdata.beproinfo ~= nil and rndidx == 1 then
					local beProChoose = ReqBeProposaledChooseMsg:new()
					beProChoose.name = bot.userdata.beproinfo.name
					beProChoose.ringId = bot.userdata.beproinfo.ringId
					beProChoose.result = math.random(1, 2) - 1
					bot:sendrpc(beProChoose, 0)
					Debug('req be pro choose', bot.account)
				else
					for k,v in pairs(bot.userdata.relationinfo) do
						local reqPro = ReqProposalMsg:new()
						reqPro.roleID = v.roleID
						reqPro.desc = "hhhhh"
						reqPro.ringId = ringcfgId[math.random(1, #ringcfgId)]
						bot:sendrpc(reqPro, MsgType.WC_ProposalRes)
					end
					Debug('req proposal', bot.account)
				end
			else
				if bot.userdata.reconinfo and #bot.userdata.reconinfo > 0 then
					local msgReq = ReqAddFriendRecommend:new()
					msgReq.AddFriendList = {}
					for k,v in pairs(bot.userdata.reconinfo) do
						local friendVo = {}
						friendVo.roleID = v.roleID
						table.insert(msgReq.AddFriendList, friendVo)
					end
					bot:sendrpc(msgReq, 0)
					Debug('req add friends', bot.account)
				else
					local msgReq = ReqAskRecommendList:new()
					bot:sendrpc(msgReq, MsgType.WC_RecommendList)
					Debug('req recommand friends', bot.account)
				end
			end
		elseif marrystate == 1 then						--订婚
			if bot.userdata.applymarry.lineId == nil or bot.userdata.applymarry.lineId <= -1 then
				local msgFly = ReqFlyToMateMsg:new()
				bot:sendrpc(msgFly, MsgType.WC_FlyToMate)
				Debug('fly to mate', bot.account)
			else
				bot:goline(bot.userdata.applymarry.lineId)

				local msgFlyOk = ReqFlyToMateOkMsg:new()
				bot:sendrpc(msgFlyOk, MsgType.WC_FlyToMate)
				Debug('fly to mate ok', bot.account)

				if bot.userdata.applymarry and bot.userdata.applymarry.TimeList and #bot.userdata.applymarry.TimeList > 0 then
					for k,v in pairs(bot.userdata.applymarry.TimeList) do
						local reqApply = ReqApplyMarryMsg:new()
						reqApply.time = bot.userdata.applymarry.time
						reqApply.timeIndex = v.TimeID
						bot:sendrpc(reqApply, MsgType.WC_ApplyMarry)
					end
					Debug('req apply marry info', bot.account)
				else
					local reqAooky = ReqAookyNarryDataMsg:new()
					reqAooky.time = _timestamp()
					bot:sendrpc(reqAooky, MsgType.WC_ApplyMarryData)
					Debug('req book marry info', bot.account)
				end
			end
		elseif marrystate == 2 then						--已婚

		elseif marrystate == 3 then						--离婚

		end

		bot:delay( 1000 )

	end
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.SC_MarryingState then
		bot.userdata.marryinfo = {}
		bot.userdata.marryinfo = msg
	elseif msg.msgId == MsgType.WC_RelationList then
		bot.userdata.relationinfo = {}
		bot.userdata.relationinfo = msg.RelationList
	elseif msg.msgId == MsgType.WC_ProposalRes then

	elseif msg.msgId == MsgType.WC_RecommendList then
		bot.userdata.reconinfo = {}
		bot.userdata.reconinfo = msg.RecommendList
	elseif msg.msgId == MsgType.WC_ApplyMarryData then
		bot.userdata.applymarry = {}
		bot.userdata.applymarry.time = msg.time
		bot.userdata.applymarry.TimeList = msg.TimeList
	elseif msg.msgId == MsgType.WC_FlyToMate then
		bot.userdata.applymarry.lineId = msg.lineId
	elseif msg.msgId == MsgType.WC_BeProposaled then
		bot.userdata.beproinfo = {}
		bot.userdata.beproinfo = msg
	end
end