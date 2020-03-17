local function join_team(bot)
	Debug('req near by' .. bot.account)
	bot:runto(0, 0)
	local msgNearby = ReqTeamNearbyTeamMsg:new()
	bot:sendrpc(msgNearby, MsgType.WC_TeamNearbyTeam)
	
	if bot.userdata.nearby ~= {} then
		for k, team in pairs(bot.userdata.nearby) do
			Debug('req apply' .. team.teamId .. bot.account)
			
			local msgApply = ReqTeamApplyMsg:new()
			msgApply.teamId = team.teamId
			bot:sendrpc(msgApply, 0)
		end
	end
end

local function reply_enter(bot)
	Debug('reply enter ' .. bot.userdata.dungeonid .. bot.account)
	local msgReply = ReqReplyTeamDungeonMsg:new()
	msgReply.reply = 1
	bot:sendrpc(msgReply, 0)
	bot.userdata.indungeon = true
end


_G.script = function( bot )
	bot:goscene(10100001)
	bot:delay( 3000 )

	bot.userdata.teamId = "0_0"
	bot.userdata.dungeonid = 0
	bot.userdata.indungeon = false
	bot.userdata.killnum = 0
	bot.userdata.nearby = {}
	
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
			join_team(bot)
		else	
			if not bot.userdata.indungeon then
				Debug('indungeon ' .. bot.userdata.teamId .. bot.account)
				if bot.userdata.dungeonid ~= 0 then
					Debug('dungeonid ' .. bot.userdata.teamId .. bot.account)
					if bot.userdata.teamlineid ~= nil and bot.userdata.teamlineid ~= bot:getline() then
						Debug('goline ' .. bot.userdata.teamlineid .. bot.account)
						bot:goline(bot.userdata.teamlineid)					
					end
					reply_enter(bot)
					bot:delay( 3000 )
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
	elseif msg.msgId == MsgType.WC_TeamNearbyTeam then
		bot.userdata.nearby = msg.teamList
	elseif msg.msgId == MsgType.WC_TeamDungeonUpdate then
		bot.userdata.dungeonid = msg.dungeonId
		bot.userdata.teamlineid = msg.line
	elseif msg.msgId == MsgType.SC_EnterDungeonResult then
		bot.userdata.stepId = msg.stepId
	elseif msg.msgId == MsgType.SC_StoryEndResult then
		bot.userdata.stepId = msg.stepId
	elseif msg.msgId == MsgType.SC_StoryStep then
		bot.userdata.stepId = msg.stepId
	elseif msg.msgId == MsgType.SC_LeaveDungeonResult then
		bot.userdata.dungeonid = 0
		bot.userdata.stepId = 0
		bot.userdata.indungeon = false
		bot.userdata.killnum = 0
	end
end