module(..., package.seeall)

--Reserve Start--
function EncodePos(t)
	for k, v in pairs(t) do
		t[k] =  v * 1000
	end
	return t
end
function DecodePos(t)
	for k, v in pairs(t) do
		t[k] =  v / 1000
	end
	return t
end
--Reserve End--

--GS2C--

function GS2CShowScene(pbdata)
	local scene_id = pbdata.scene_id
	local map_id = pbdata.map_id
	local scene_name = pbdata.scene_name
	local new_man = pbdata.new_man
	local type = pbdata.type --0为实场景，1为虚拟场景
	--todo
	g_WarCtrl:ShowSceneEndWar()
	-- if not g_WarCtrl:IsPlayRecord() then
	
	if not g_GuideCtrl:IsCustomGuideFinishByKey("welcome_three_end") then		
		g_NotifyCtrl:ShowAniSwitchBlackBg(2)
	end

	if not g_NetCtrl:IsProtoRocord() then
		g_MapCtrl:ShowScene(scene_id, map_id, scene_name, new_man, type)
	end
end

function GS2CEnterScene(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local pos_info = pbdata.pos_info
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	--tzq临时屏蔽宅邸场景跳转
	if g_MapCtrl.m_MapID == 501000 then
		--在宅邸进入战斗后，退出宅邸
		Utils.AddTimer(function ()
			if g_MapCtrl.m_MapID == 501000 and not g_HouseCtrl:IsInHouse() then
				g_HouseCtrl:LeaveHouse()
			end
		end, 0.3, 0.3)
		return
	--登录时直接加载开篇动画的地图
	-- elseif not g_GuideCtrl:IsCustomGuideFinishByKey("welcome_one") then
	-- 	g_GuideCtrl:LoginCheckStarAni(scene_id, eid)
	-- 	return

	--隐藏boss战
	-- elseif not g_GuideCtrl:IsCustomGuideFinishByKey("welcome_two") then
	-- 	g_GuideCtrl:LoadShowWarGuide()
	-- 	return

	elseif not g_GuideCtrl:IsCustomGuideFinishByKey("welcome_three_end") then			
		if g_AttrCtrl.grade <= 5 then
			g_DialogueAniCtrl:InsetUnPlayList(888)
		end

	elseif g_HouseCtrl:IsInHouse() then
		g_HouseCtrl:LeaveHouse()
	end
	g_MapCtrl:EnterScene(eid, DecodePos(pos_info))
	if g_TeamPvpCtrl:IsInTeamPvpScene() and not g_WarCtrl:IsWar() then
		CTeamPvpRankView:ShowView()
	end
end

function GS2CEnterAoiBlock(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local type = pbdata.type --1 player,2 npc
	local aoi_player = pbdata.aoi_player
	local aoi_npc = pbdata.aoi_npc
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	g_MapCtrl:AddAoiBlockCache(eid, {scene_id, type, aoi_player, aoi_npc})
end

function GS2CEnterAoiPos(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local type = pbdata.type --1 player,2 npc
	local pos_info = pbdata.pos_info
	--todo
	local dData = g_MapCtrl:GetAoiBlockCache(eid)
	if not dData then
		return
	end
	g_MapCtrl:ClearAoiBlockCache(eid)
	if dData[1] ~= scene_id or dData[2] ~= type then
		return
	end
	local aoi_player = dData[3]
	local aoi_npc = dData[4]
	if type == 1 then
		local aoiPlayer = table.copy(aoi_player)
		aoiPlayer.block = g_NetCtrl:DecodeMaskData(aoiPlayer.block, "PlayerAoiBlock")
		pos_info = table.copy(pos_info)
		aoiPlayer.pos_info = DecodePos(pos_info)
		local bAddPlayer = false
		if aoiPlayer.pid == g_AttrCtrl.pid then
			g_AttrCtrl:UpdateAttr({model_info = aoiPlayer.block.model_info})
			g_MapCtrl:AddPlayer(eid, aoiPlayer)
		else
			--新手地图，只出现自己
			if g_MapCtrl.m_IsNewMan == 1 then
				return
			end
			if g_MapCtrl.m_SameScreenHandler:IsProirPlayer(aoiPlayer) then
				g_MapCtrl:AddPlayer(eid, aoiPlayer)
			else
				g_MapCtrl.m_SameScreenHandler:AddAoi(eid, aoiPlayer)
			end
		end
	elseif type == 2 then
		local aoiNpc = table.copy(aoi_npc)
		pos_info = table.copy(pos_info)
		aoiNpc.pos_info = DecodePos(pos_info)
		aoiNpc.block = g_NetCtrl:DecodeMaskData(aoiNpc.block, "NpcAoiBlock")
		if aoiNpc.block.owner then
			--owner:判断是否为据点npc
			g_MapCtrl:AddTerrawarNpc(eid, aoiNpc)
		else
			g_MapCtrl:AddNpc(eid, aoiNpc)
		end
	end
end

function GS2CLeaveAoi(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	if g_MapCtrl.m_SameScreenHandler:IsContainAoi(eid) then
		g_MapCtrl.m_SameScreenHandler:RemoveAoi(eid)
	else
		g_MapCtrl:DelWalker(eid)
		g_MapCtrl.m_SameScreenHandler:CheckAddPlayer()
	end
end

function GS2CSyncAoi(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local type = pbdata.type --1 player,2 npc
	local aoi_player_block = pbdata.aoi_player_block
	local aoi_npc_block = pbdata.aoi_npc_block
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	local function getblock()
		local block
		if type == 1 then
			block = g_NetCtrl:DecodeMaskData(aoi_player_block, "PlayerAoiBlock")
		elseif type == 2 then
			block = g_NetCtrl:DecodeMaskData(aoi_npc_block, "NpcAoiBlock")
		end
		return block
	end
	local oWalker = g_MapCtrl:GetWalker(eid)
	local block = getblock()
	if oWalker then
		if block then
			if type == 1 and oWalker.m_Pid and oWalker.m_Pid == g_AttrCtrl.pid then
				g_AttrCtrl:UpdateAttr({model_info = block.model_info, name = block.name})
			end
			oWalker:SyncBlockInfo(eid, block)
		end
	elseif g_MapCtrl.m_SameScreenHandler:IsContainAoi(eid) then
		g_MapCtrl.m_SameScreenHandler:AddBlock(eid, block)
	end

end

function GS2CSyncPosQueue(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local poslist = pbdata.poslist
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	local iLen = #poslist
	if iLen > 0 then
		if g_MapCtrl.m_SameScreenHandler:IsContainAoi(eid) then
			g_MapCtrl.m_SameScreenHandler:SetPos(eid, DecodePos(poslist[iLen].pos))
		else
			g_MapCtrl:SyncPos(eid, DecodePos(poslist[iLen].pos))
		end
	end
end

function GS2CSTrunBackPos(pbdata)
	local scene_id = pbdata.scene_id
	local eid = pbdata.eid
	local pos_info = pbdata.pos_info
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	local oWalker = g_MapCtrl:GetWalker(eid)
	if oWalker then
		g_MapCtrl:UpdateByPosInfo(oWalker, DecodePos(pos_info))
	elseif g_MapCtrl.m_SameScreenHandler:IsContainAoi(eid) then
		g_MapCtrl.m_SameScreenHandler:SetPos(eid, DecodePos(pos_info))
	end
end

function GS2CAutoFindPath(pbdata)
	local npcid = pbdata.npcid
	local map_id = pbdata.map_id
	local pos_x = pbdata.pos_x
	local pos_y = pbdata.pos_y
	local autotype = pbdata.autotype --自动寻路类型,1:先跳场景,再寻路,2:通过跳转点寻路
	local callback_sessionidx = pbdata.callback_sessionidx
	local system = pbdata.system --发起寻路的系统：1：修行
	--todo
	--延时1帧执行寻路操作
	local function wrap()
		g_MapCtrl:AutoFindPath(pbdata)
	end
	Utils.AddTimer(wrap, 0 , 0)
end

function GS2CSceneCreateTeam(pbdata)
	local scene_id = pbdata.scene_id
	local team_id = pbdata.team_id
	local pid_list = pbdata.pid_list
	local team_type = pbdata.team_type
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	g_MapCtrl:UpdateTeam(team_id, pid_list)
end

function GS2CSceneRemoveTeam(pbdata)
	local scene_id = pbdata.scene_id
	local team_id = pbdata.team_id
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	g_MapCtrl:RemoveTeam(team_id)
end

function GS2CSceneUpdateTeam(pbdata)
	local scene_id = pbdata.scene_id
	local team_id = pbdata.team_id
	local pid_list = pbdata.pid_list
	local team_type = pbdata.team_type
	--todo
	if scene_id ~= g_MapCtrl:GetSceneID() then
		return
	end
	g_MapCtrl:UpdateTeam(team_id, pid_list)
end

function GS2CSceneModel(pbdata)
	local scene_model = pbdata.scene_model
	--todo
end


--C2GS--

function C2GSSyncPosQueue(scene_id, eid, poslist)
	local t = {
		scene_id = scene_id,
		eid = eid,
		poslist = poslist,
	}
	g_NetCtrl:Send("scene", "C2GSSyncPosQueue", t)
end

function C2GSTransfer(scene_id, eid, transfer_id)
	local t = {
		scene_id = scene_id,
		eid = eid,
		transfer_id = transfer_id,
	}
	g_NetCtrl:Send("scene", "C2GSTransfer", t)
end

function C2GSClickWorldMap(scene_id, eid, map_id)
	local t = {
		scene_id = scene_id,
		eid = eid,
		map_id = map_id,
	}
	g_NetCtrl:Send("scene", "C2GSClickWorldMap", t)
end

function C2GSClickTrapMineMap(scene_id, map_id)
	local t = {
		scene_id = scene_id,
		map_id = map_id,
	}
	g_NetCtrl:Send("scene", "C2GSClickTrapMineMap", t)
end

function C2GSChangeSceneModel(scene_model)
	local t = {
		scene_model = scene_model,
	}
	g_NetCtrl:Send("scene", "C2GSChangeSceneModel", t)
end

function C2GSFlyToPos(pos_info, map_id)
	local t = {
		pos_info = pos_info,
		map_id = map_id,
	}
	g_NetCtrl:Send("scene", "C2GSFlyToPos", t)
end

