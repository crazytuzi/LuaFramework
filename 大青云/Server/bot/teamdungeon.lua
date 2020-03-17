local dungeonids = {
	201,
	202,
	203,
	204,
	205,
	301,
	302,
	303,
	304,
	305,
}

local function enter_team_dungeon(bot)
	local idx = math.random(1, #dungeonids)
	Debug('enter dungeon ' .. dungeonids[idx] .. bot.account)
	bot:godungeon(dungeonids[idx])
	bot.userdata.dungeonid = dungeonids[idx]
end

local function create_team(bot)
	Debug('create team ' .. bot.account)		
	local msgCreate = ReqTeamCreateMsg:new()
	msgCreate.targetRoleID = "0_0"
	bot:sendrpc(msgCreate, 0)
end

local function mem_cnt(bot)
	local cnt = 0
	for k, v in pairs(bot.userdata.teamMem) do
		if v.online == 1 then
			cnt = cnt + 1
		end
	end
	
	return cnt
end

local function join_approve(bot)
	Debug('join approve ' .. bot.account)
	if bot.userdata.applys ~= {} then
		for k, v in pairs(bot.userdata.applys) do
			local msgApprove = ReqTeamJoinApproveMsg:new()
			msgApprove.targetRoleID = v
			msgApprove.operate = 1
			bot:sendrpc(msgApprove, 0)
		end
	end
	bot.userdata.applys = {}
end

_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 3000 )
	
	bot.userdata.teamId = "0_0"
	bot.userdata.applys = {}
	bot.userdata.teamMem = {}
	bot.userdata.dungeonid = 0
	bot.userdata.stepId = 0
	bot.userdata.killnum = 0
	
	bot:chat(1, '/levelup/300')
	bot:chat(1, '/debug/1')
	bot:chat(1, '/funcopen/13')
	
	while true do
		bot:delay( 1000 )

		bot.currScene = bot:getMapId()
		bot:wuhun(math.random(0, 1))

		local msgReq = ReqTeamInfoMsg:new()
		msgReq.teamId = "0_0"
		bot:sendrpc(msgReq, MsgType.WC_TeamInfo)
		
		Debug('teamid ' .. bot.userdata.teamId .. bot.account)
		if bot.userdata.teamId == "0_0" then
			create_team(bot)
		else		
			if bot.userdata.dungeonid == 0 then
				join_approve(bot)
				if mem_cnt(bot) >= 3 then
					enter_team_dungeon(bot)			
				end
			end
		end

		if bot.userdata.dungeonid ~= 0 and bot.userdata.stepId ~= 0 then
			Debug('in dugenon ', bot.userdata.dungeonid, bot.userdata.stepId, bot.account)
			local dunstep = _G.t_dunstep[bot.userdata.stepId]
			local dundiff = bot.userdata.dungeonid % 100
			if dunstep ~= nil then
				local goals = dunstep['goals' .. dundiff]

				Debug('step ', bot.userdata.dungeonid, bot.userdata.stepId, goals, dunstep.type, bot.account)

				if dunstep.type == 1 then													--寻路
					local pos = t_position[tonumber(goals)].pos
					bot:goTo(pos)
					if dunstep.auto_fight == 1 then
						bot:test_skill()
						local tmp = split(dunstep.targetNum, '#')
						local num = split(tmp[dundiff], ',')
						bot.userdata.killnum = bot.userdata.killnum + 1
						if bot.userdata.killnum > tonumber(num[2]) then
							bot.userdata.killnum = 0
							bot:chat(1, "/storyfinish/" .. tostring(bot.userdata.stepId))
						end
					end
				elseif dunstep.type == 2 then												--杀怪
					local tmp = split(goals, ',')
					local monsterid = tonumber(tmp[1])
					local num = tonumber(tmp[2])
					local pos = t_position[tonumber(tmp[3])].pos
					bot:goTo(pos)
					bot:test_skill()
					bot.userdata.killnum = bot.userdata.killnum + 1
					if bot.userdata.killnum > num then
						bot.userdata.killnum = 0
						bot:chat(1, "/storyfinish/" .. tostring(bot.userdata.stepId))
					end
				elseif dunstep.type == 3 then												--对话
					local tmp = split(goals, ',')
					local npcid = tonumber(tmp[1])
					local pos = t_position[tonumber(tmp[2])].pos
					bot:goTo(pos)
					bot:chat(1, "/storyfinish/" .. tostring(bot.userdata.stepId))
				elseif dunstep.type == 4 then												--采集
					local tmp = split(goals, ',')
					local gatherid = tonumber(tmp[1])
					local num = tonumber(tmp[2])
					local pos = t_position[tonumber(tmp[3])].pos
					bot:goTo(pos)
					bot:chat(1, "/storyfinish/" .. tostring(bot.userdata.stepId))
				elseif dunstep.type == 5 then												--使用物品
					bot:chat(1, "/storyfinish/" .. tostring(bot.userdata.stepId))
				elseif dunstep.type == 6 then												--开关空气墙
					bot:chat(1, "/storyfinish/" .. tostring(bot.userdata.stepId))
				elseif dunstep.type == 7 then												--跳跃到某位置
					bot:chat(1, "/storyfinish/" .. tostring(bot.userdata.stepId))
				else
					Debug('error dunstep ' .. dunstep.type .. bot.account)
				end
				bot:delay( 1000 )
			end
		end
	end
	
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.WC_TeamInfo then
		bot.userdata.teamId = msg.teamId
		bot.userdata.teamMem = msg.roleList
	elseif msg.msgId == MsgType.WC_TeamJoinRequest then
		bot.userdata.applys[msg.roleID] = msg.roleID
	elseif msg.msgId == MsgType.SC_EnterDungeonResult then
		bot.userdata.stepId = msg.stepId
	elseif msg.msgId == MsgType.SC_StoryEndResult then
		bot.userdata.stepId = msg.stepId
	elseif msg.msgId == MsgType.SC_StoryStep then
		bot.userdata.stepId = msg.stepId
	elseif msg.msgId == MsgType.SC_LeaveDungeonResult then
		bot.userdata.dungeonid = 0
		bot.userdata.stepId = 0
		bot.userdata.killnum = 0
	end
end