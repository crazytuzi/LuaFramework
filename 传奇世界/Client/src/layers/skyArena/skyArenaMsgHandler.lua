G_SKYARENA_DATA = {}
TMP_G_SKILLPROP_POS = {}
TMP_G_SKILLPROP_POS_SHOWN_INBATTLE = {}
isInArenaScene = false
G_SKYARENA_DATA.EnergyData={}
G_SKYARENA_DATA.EnergyData.energy=0
G_SKYARENA_DATA.tipsLimit=nil
-----------------------------------------------------------
--  if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
-- G_MAINSCENE.map_layer:xxxx()
local SkyArena_FuncRoleUpdate = function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("P3V3RoleUpdateProtocol", buff)
    local data = {t.count,t.energy,t.shutKey,t.keys,t.winCnt}	
    if G_SKYARENA_DATA.EnergyData then
		G_SKYARENA_DATA.EnergyData.energy=t.energy
		if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena and G_MAINSCENE.map_layer.arenaEnergy then
	 		G_MAINSCENE.map_layer.arenaEnergy:energyUpdate()
	 	end
	end
	
    -- 有些情况 key 不推送过来，这里需要保存原来的备份
    local oldKeys = nil
    if TMP_G_SKILLPROP_POS and TMP_G_SKILLPROP_POS.keys then
        oldKeys = TMP_G_SKILLPROP_POS.keys;
    end

    TMP_G_SKILLPROP_POS = t

    if not t.shutKey then
        -- 还原key，如果当前协议中没有带过来的话
        if (t.keys == nil or #(t.keys) == 0) and oldKeys then
            TMP_G_SKILLPROP_POS.keys = oldKeys;
        end

        return
    end

    TMP_G_SKILLPROP_POS_SHOWN_INBATTLE = {}
    for k,v in pairs(t.keys) do
        local pos = v.key
        local sId = v.skillId
        table.insert(TMP_G_SKILLPROP_POS_SHOWN_INBATTLE,{pos,1,sId})
    end

    --[[
	
	-- local ranking = trd.rank
	-- local count = trd.count
	-- local score = trd.score
 --    -- 开始时间
 --    local endTick = trd.endTick;
 --    -- 结束时间
 --    local startTick = trd.startTick;
    
    

	-- cclog("[SkyArena_FuncRoleUpdate] called. ranking = %s, count = %s, score = %s.", ranking, count, score)

	-- G_SKYARENA_DATA.SelfData = {}
	-- G_SKYARENA_DATA.SelfData.SRanking = ranking
	-- G_SKYARENA_DATA.SelfData.SCount = count
	-- G_SKYARENA_DATA.SelfData.SScore = score
 --    G_SKYARENA_DATA.SelfData.SEndTick = endTick;
 --    G_SKYARENA_DATA.SelfData.SStartTick = startTick;
 --    -- 赛季
 --    G_SKYARENA_DATA.SelfData.SId = trd.id

 --    -- reward - 是否领取了赛季奖励 0未领取 1领取了
 --    G_SKYARENA_DATA.SelfData.SReward = trd.reward;
    ]]
end
--符文能量更新
local SkyArena_FuncEnergyUpdate = function(buff)
   local t = g_msgHandlerInst:convertBufferToTable("P3V3PickFlagProtocol", buff)
   if G_SKYARENA_DATA.EnergyData then
   		print("t.energy="..t.energy)
		if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena and G_MAINSCENE.map_layer.arenaEnergy then
	 		if userInfo.currRoleId ==t.id then
				G_SKYARENA_DATA.EnergyData.energy=t.energy
	 			G_MAINSCENE.map_layer.arenaEnergy:energyUpdate()
	 		end
	 		--for k,v in pairs(G_SKYARENA_DATA.RoleData) do
	 			local node = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(t.id), "SpritePlayer")
	        	if node then
	        		local effect = Effects:create(false)
				    effect:setPlistNum(-1)
				    effect:setAnchorPoint(cc.p(0.5,0.5))
				    effect:setPosition(cc.p(0, 20))
				    addEffectWithMode(effect, 1)
				   	local buff_effect_node = node:getBuffSkillNode()
				    effect:playActionData2("competegetenergy", 100, 2, 0)
				    effect:setName("competegetenergy")
				    buff_effect_node:addChild(effect, 99999999)
	        	end
	 		--end
	 	end
	end
end

local SkyArena_FuncFightUpdate = function(buff)
	local trd = g_msgHandlerInst:convertBufferToTable("P3V3FightUpdateProtocol", buff)

	local role_id = trd.id
	local TA_kill_count = trd.killA
	local TB_kill_count = trd.killB
	local role_killed_count = trd.killNum
	local role_killother_count = trd.killOther
	local state = trd.status

	cclog("[SkyArena_FuncFightUpdate] called. role_id = %s, TA_kill_count = %s, TB_kill_count = %s, role_killed_count = %s, role_killother_count = %s, state = %s.",
	role_id, TA_kill_count, TB_kill_count, role_killed_count, role_killother_count, state)

	-------------------------------------------------------

    if G_SKYARENA_DATA then
        if G_SKYARENA_DATA.TeamData then
	        G_SKYARENA_DATA.TeamData.TA_kill_count = TA_kill_count
	        G_SKYARENA_DATA.TeamData.TB_kill_count = TB_kill_count
        end

	    if G_SKYARENA_DATA.RoleData then
		    for k,v in pairs(G_SKYARENA_DATA.RoleData) do
		    	if role_id == v.role_id then
				   	v.killed_count = role_killed_count
				    v.killother_count = role_killother_count
				    v.state = state
					break
			    end
		    end
	    end

	    -------------------------------------------------------

	    if G_MAINSCENE then
		    G_MAINSCENE:updateSkyArena(1)
	    end
    end
end

local SkyArena_FuncFightResult = function(buff)

	local trd = g_msgHandlerInst:convertBufferToTable("P3V3FightResultProtocol", buff)

	local result = trd.winner
	--local count = #trd.scores
	dump(trd,"SkyArena_FuncFightResultSkyArena_FuncFightResultSkyArena_FuncFightResult")


--	G_SKYARENA_DATA.ResultData = {}
--	G_SKYARENA_DATA.ResultData.result = result
--	G_SKYARENA_DATA.ResultData.count = count

--	for i = 1, count do
--		local role_id = buff:popInt()
--		local score = buff:popShort()

--		G_SKYARENA_DATA.ResultData.item[i] = {}
--		G_SKYARENA_DATA.ResultData.item[i].role_id = role_id
--		G_SKYARENA_DATA.ResultData.item[i].score = score

--	end

	-------------------------------------------------------

	if G_SKYARENA_DATA.TeamData then
		G_SKYARENA_DATA.TeamData.result = result
	end

	-- local role_count = 0
	-- if G_SKYARENA_DATA.RoleData then
	-- 	role_count = #G_SKYARENA_DATA.RoleData
	-- end

	-- for i = 1, count do
	-- 	local role_id = trd.scores[i].id
	-- 	local score = trd.scores[i].score


	-- 	for j = 1, role_count do
	-- 		if role_id == G_SKYARENA_DATA.RoleData[j].role_id then
	-- 			G_SKYARENA_DATA.RoleData[j].score = score

	-- 			break
	-- 		end
	-- 	end
	-- end

	-------------------------------------------------------

	if G_MAINSCENE then
		G_MAINSCENE:updateSkyArena(2);
	end
end

local SkyArena_FuncStartMatch = function(buff)
    local commConst = require("src/config/CommDef")
	print("[SkyArena_FuncStartMatch] called.")
    if getRunScene():getChildByTag(commConst.TAG_3V3_MATCHINGOPPONENT) == nil then
	    local node = require("src/layers/skyArena/skyArenaMatchingOpponent").new()
        node:setTag(commConst.TAG_3V3_MATCHINGOPPONENT)
    end

    local name = "a224"
    local skyArenaLayer = getRunScene():getChildByName(name)
    if skyArenaLayer ~= nil then
        skyArenaLayer:reEnableBtns()
    end
end

local SkyArena_FuncMatchOpen = function(buff)
	local index = 1
	print("SkyArena_FuncMatchOpen")

	local trd = g_msgHandlerInst:convertBufferToTable("P3V3MatchOpenProtocol", buff)

	local TA_count = #trd.teamA
	local TA_id = trd.teamIdA

	G_SKYARENA_DATA.TeamData = {}
	G_SKYARENA_DATA.RoleData = {}

	G_SKYARENA_DATA.TeamData.TA_kill_count = 0
	G_SKYARENA_DATA.TeamData.TB_kill_count = 0

	G_SKYARENA_DATA.TeamData.TA_count = TA_count
	G_SKYARENA_DATA.TeamData.TA_id = TA_id

	

	for i = 1, TA_count do
		local role_id = trd.teamA[i].id
		local role_name = trd.teamA[i].name
		local battle = trd.teamA[i].battle
		print("role_id=========================================================="..role_id)
		G_SKYARENA_DATA.RoleData[index] = {}
		G_SKYARENA_DATA.RoleData[index].role_id = role_id
		G_SKYARENA_DATA.RoleData[index].role_name = role_name
		G_SKYARENA_DATA.RoleData[index].battle_power = battle

		G_SKYARENA_DATA.RoleData[index].killed_count = 0
		G_SKYARENA_DATA.RoleData[index].killother_count = 0
		G_SKYARENA_DATA.RoleData[index].state = 1   --1 代表"活着"; 0 代表"死亡"
		G_SKYARENA_DATA.RoleData[index].score = 0

        -- 保存队伍id
        G_SKYARENA_DATA.RoleData[index].teamId = TA_id;

		index = index + 1
	end


	local TB_count = #trd.teamB
	local TB_id = trd.teamIdB

	G_SKYARENA_DATA.TeamData.TB_count = TB_count
	G_SKYARENA_DATA.TeamData.TB_id = TB_id
	index=4
	for i = 1, TB_count do
		local role_id = trd.teamB[i].id
		local role_name = trd.teamB[i].name
		local battle = trd.teamB[i].battle

		G_SKYARENA_DATA.RoleData[index] = {}
		G_SKYARENA_DATA.RoleData[index].role_id = role_id
		G_SKYARENA_DATA.RoleData[index].role_name = role_name
		G_SKYARENA_DATA.RoleData[index].battle_power = battle

		G_SKYARENA_DATA.RoleData[index].killed_count = 0
		G_SKYARENA_DATA.RoleData[index].killother_count = 0
		G_SKYARENA_DATA.RoleData[index].state = 1   --1 代表"活着"; 0 代表"死亡"
		G_SKYARENA_DATA.RoleData[index].score = 0

        G_SKYARENA_DATA.RoleData[index].teamId = TB_id;

		index = index + 1
	end

	cclog("[SkyArena_FuncMatchOpen] called. TA_count = %s, TA_id = %s, TB_count = %s, TB_id = %s.", TA_count, TA_id, TB_count, TB_id)
	-------------------------------------------------------

	if G_MAINSCENE then
		G_MAINSCENE:updateSkyArena(1)
	end
	--开始录制视频
	if getLocalRecordByKey(3,"isAutoRecorder") and isSupportReplay() then
		startRecording()
	end
	if G_MAINSCENE.taskBaseNode then
		G_MAINSCENE.taskBaseNode:setVisible(false)
	end
end
local SkyArena_MatchOver = function(buff)
	if getRunScene() then
		local commConst = require("src/config/CommDef")
		getRunScene():removeChildByTag(commConst.TAG_3V3_MATCHINGOPPONENT)
		TIPS( { type = 1 , str = game.getStrByKey("sky_arena_matching_cancel") } ) 
	end
end
-----------------------------------------------------------

g_msgHandlerInst:registerMsgHandler(PVP3V3_SC_ROLE_UPDATE, SkyArena_FuncRoleUpdate)
g_msgHandlerInst:registerMsgHandler(PVP3V3_SC_FIGHT_UPDATE, SkyArena_FuncFightUpdate)
g_msgHandlerInst:registerMsgHandler(PVP3V3_SC_FIGHT_RESULT, SkyArena_FuncFightResult)
g_msgHandlerInst:registerMsgHandler(PVP3V3_SC_START_MATCH, SkyArena_FuncStartMatch)
g_msgHandlerInst:registerMsgHandler(PVP3V3_SC_MATCH_OPEN, SkyArena_FuncMatchOpen)
g_msgHandlerInst:registerMsgHandler(PVP3V3_SC_PICK_FLAG, SkyArena_FuncEnergyUpdate)
g_msgHandlerInst:registerMsgHandler(PVP3V3_SC_MATCH_OVER, SkyArena_MatchOver)--过了开启时间，取消匹配

cclog("Lua file skyArenaMsgHandler.lua loaded.")
