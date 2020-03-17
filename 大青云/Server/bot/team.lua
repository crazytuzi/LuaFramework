_G.script = function( bot )
	bot:goscene(10100001)
	
	bot.userdata.teamId = "0_0"
	bot.userdata.applys = {}
	bot.userdata.invites = {}
	
	bot:chat(1, '/levelup/10')
	
	while true do
		bot:delay( 3000 )
		
		local msgReq = ReqTeamInfoMsg:new()
		msgReq.teamId = "0_0"
		bot:sendrpc(msgReq, MsgType.WC_TeamInfo)
		
		Debug('teamid ' .. bot.userdata.teamId .. bot.account)
		if bot.userdata.teamId == "0_0" then
			local op = math.random(1, 3)
			
			if op == 1 then
				Debug('create team ' .. bot.account)		
				local msgCreate = ReqTeamCreateMsg:new()
				msgCreate.targetRoleID = "0_0"
				bot:sendrpc(msgCreate, 0)
			elseif op == 2 then
				Debug('req near by' .. bot.account)
				bot:runto(0, 0)
				local msgNearby = ReqTeamNearbyTeamMsg:new()
				bot:sendrpc(msgNearby, MsgType.WC_TeamNearbyTeam)
				
				if bot.userdata.nearby and bot.userdata.nearby ~= {} then
					for k, team in pairs(bot.userdata.nearby) do
						local msgApply = ReqTeamApplyMsg:new()
						msgApply.teamId = team.teamId
						bot:sendrpc(msgApply, 0)
					end
				end
			elseif op == 3 then
				for k, v in pairs(bot.userdata.invites) do
					local msgInvApprove = ReqTeamInviteApprove:new()
					msgInvApprove.teamId = v
					msgInvApprove.operate =  math.random(1, 2) - 1
					bot:sendrpc(msgInvApprove, MsgType.WC_TeamInfo)
				end
			end
		else
			local op = math.random(1, 5)
			
			if op == 1 then
				Debug('join approve ' .. bot.account)
				if bot.userdata.applys ~= {} then
					for k, v in pairs(bot.userdata.applys) do
						local msgApprove = ReqTeamJoinApproveMsg:new()
						msgApprove.targetRoleID = v
						msgApprove.operate = math.random(1, 2) - 1
						bot:sendrpc(msgApprove, 0)
					end
				end
				bot.userdata.applys = {}
			elseif op == 2 then
				Debug('quit team ' .. bot.account)		
				local msgQuit = ReqTeamQuitMsg:new()
				bot:sendrpc(msgQuit, MsgType.WC_TeamRoleExit)
			elseif op == 3 then
				Debug('fire mem ' .. bot.account)				
				for k, v in pairs(bot.userdata.teamMem) do
					local msgFire = ReqTeamFireMsg:new()
					msgFire.targetRoleID = v.roleID
					bot:sendrpc(msgFire, MsgType.WC_TeamRoleExit)
				end
			elseif op == 4 then
				Debug('transfer leader ' .. bot.account)
				for k, v in pairs(bot.userdata.teamMem) do
					if v.roleID ~= bot.guid then
						local msgTransfer = ReqTeamTransferMsg:new()
						msgTransfer.targetRoleID = v.roleID
						bot:sendrpc(msgTransfer, 0)
					end
				end
			elseif op == 5 then
				Debug('invite ' .. bot.account)
				local msgReqRole = ReqTeamNearbyRoleMsg:new()
				bot:sendrpc(msgReqRole, MsgType.WC_TeamNearbyRole)
				
				if bot.userdata.nearbyRole and bot.userdata.nearbyRole ~= {} then
					for k, v in pairs(bot.userdata.nearbyRole) do
						local msgInvite = ReqTeamInviteMsg:new()
						msgInvite.targetRoleID = v.roleID
						bot:sendrpc(msgInvite, 0)
					end
				end
			end
		end
		
		local quitidx = math.random(1, 10000)
		if quitidx == 1 then
			break
		end
	end
	
	bot:quit()
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.WC_TeamInfo then
		bot.userdata.teamId = msg.teamId
		bot.userdata.teamMem = msg.roleList
	elseif msg.msgId == MsgType.WC_TeamNearbyTeam then
		bot.userdata.nearby = msg.teamList
	elseif msg.msgId == MsgType.WC_TeamJoinRequest then
		bot.userdata.applys[msg.roleID] = msg.roleID
	elseif msg.msgId == MsgType.WC_TeamInviteRequest then
		bot.userdata.invites[msg.teamId] = msg.teamId
	elseif msg.msgId == MsgType.WC_TeamNearbyRole then
		bot.userdata.nearbyRole = msg.roleList
	end
end