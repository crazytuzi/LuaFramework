--
-- eUIID_OutCastBattle
--
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_outCastBattle = i3k_class("wnd_outCastBattle", ui.wnd_base)

function wnd_outCastBattle:ctor()
	
end

function wnd_outCastBattle:configure()
	local widgets = self._layout.vars
	self.attFriend_slider2 = widgets.attFriend_slider2
	self.xunlu_btn = widgets.xunlu_btn
	self.xunlu_btn = widgets.xunlu_btn
	self.show_btn = widgets.show_btn
	self.taskDesc = widgets.taskDesc
	widgets.titleName:setText("探索外传副本中...")
end

function wnd_outCastBattle:onShowData()
	local outCastID = g_i3k_game_context:getCurOutCastID()
	local id, value, reward = g_i3k_game_context:getOutCastTskIdAndValueById(id)
	local index = g_i3k_game_context:getOutCastTaskIndexByID(outCastID, id)
	local count = g_i3k_game_context:getOutCastTaskCountByID(outCastID)
	if id == 0 then
		count = 0
	end

	self.attFriend_slider2:setPercent(index/count * 100)
	
	local outCastcfg = i3k_db_out_cast[outCastID]
	local cfg = i3k_db_out_cast_task[id]
	if outCastID == 0 or not outCastcfg then
		self:finishAll()
		return
	end
	if id == 0 then
		local cfg = i3k_db_out_cast_task[outCastcfg.taskID]
		local nocompleteNpcID = cfg.npcID
		local completeNpcID = cfg.completeNpcID
		local taskType = cfg.taskType
		local arg1 = cfg.arg1
		local arg2 = cfg.arg2
		local is_ok = g_i3k_game_context:IsTaskFinished(taskType,arg1,arg2,value)
		self.xunlu_btn:onClick(self, self.firstToDoLifeTask,{cfg = cfg, outCastID = outCastID, id = outCastcfg.taskID})
		local desc
		if nocompleteNpcID ~= 0 then
			desc = g_i3k_db.i3k_db_get_task_desc(12, nocompleteNpcID, nil, nil, false,nil)
		else
			desc = (is_ok and id ~= 0) and g_i3k_db.i3k_db_get_outcast_task_finish_reward_desc(outCastID, id) or g_i3k_db.i3k_db_get_task_desc(taskType,arg1,arg2,value,is_ok,nil)
			g_i3k_game_context:GetOutCastTaskDialogue(outCastID,outCastcfg.taskID,g_i3k_game_context:getOutCastTaskAward(outCastcfg.taskID),str)
		end
		local name = string.format("%s%s",cfg.prename,cfg.taskName)
		local str = string.format("%s\n%s",name, desc)
		self.taskDesc:setText(str)
		return
	end
	if (cfg.afterTaskID == 0 and reward == 1) then
		self:finishAll()
		return
	end 
	if reward == 1 then -- 上个任务已完成
		local cfg = i3k_db_out_cast_task[id + 1]
		if cfg and cfg.outCastID == outCastID then
			id = id + 1
		end
		value = 0
	end
	local cfg = i3k_db_out_cast_task[id]
	local completeNpcID = cfg.completeNpcID
	local nocompleteNpcID = cfg.npcID
	local taskType = cfg.taskType
	local arg1 = cfg.arg1
	local arg2 = cfg.arg2
	local is_ok = g_i3k_game_context:IsTaskFinished(taskType,arg1,arg2,value)
	local taskDesc = g_i3k_db.i3k_db_get_task_desc(taskType,arg1,arg2,0,false,nil)
	if reward == 0 then -- 奖励没有领取正在做任务
		if is_ok then	--是否完成
			if completeNpcID == 0 then --完成任务npc是否为0
				g_i3k_game_context:FinishOutCastDialogue(outCastID,id,g_i3k_game_context:isBagEnoughOutTaskAward(outCastID,id),g_i3k_game_context:getOutCastTaskAward(id))
			else
				if dialog then
					g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(completeNpcID), g_i3k_db.i3k_db_get_npc_pos(completeNpcID), TASK_CATEGORY_OUT_CAST,outCastID)
				else
					if isOK and isOK == true then
						if taskType ~= g_TASK_REACH_LEVEL and taskType ~=g_TASK_TRANSFER then 
							g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(completeNpcID), g_i3k_db.i3k_db_get_npc_pos(completeNpcID), TASK_CATEGORY_OUT_CAST,outCastID)
						end
					end
				end
			end
			self.xunlu_btn:onClick(self, self.onFinishLifeTask, {id = id , outCastID = outCastID, reward = reward})
		else
			if isOK then
				local data = {outCastID = outCastID, id = id, reward = reward, isOK = isOK}
				self:toDoLifeTask(nil, data)
			end
			self.xunlu_btn:onClick(self, self.toDoLifeTask, {outCastID = outCastID, id = id, reward = reward})
		end
		local desc = (is_ok and id ~= 0) and g_i3k_db.i3k_db_get_outcast_task_finish_reward_desc(outCastID, id) or g_i3k_db.i3k_db_get_task_desc(taskType,arg1,arg2,value,is_ok,nil)
		local name = string.format("%s%s",cfg.prename,cfg.taskName)
		local str = string.format("%s\n%s",name, desc)
		self.taskDesc:setText(str)
	elseif reward == 1 then -- 上个任务已经完成并且领取了奖励
		if nocompleteNpcID == 0 then
			local taskDesc = g_i3k_db.i3k_db_get_task_desc(taskType, cfg.arg1, cfg.arg2, 0, false, nil)
			g_i3k_game_context:GetOutCastTaskDialogue(outCastID,id,g_i3k_game_context:getOutCastTaskAward(id),taskDesc)
		else
			if dialog then
				g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(completeNpcID), g_i3k_db.i3k_db_get_npc_pos(completeNpcID), TASK_CATEGORY_OUT_CAST,outCastID)
			else
				local oldCfg = i3k_db_out_cast_task[id-1]
				if oldCfg and oldCfg.completeNpcID == nocompleteNpcID then
					g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(nocompleteNpcID), g_i3k_db.i3k_db_get_npc_pos(nocompleteNpcID), TASK_CATEGORY_OUT_CAST,outCastID)
				end
			end
		end
		is_ok = false
		if nocompleteNpcID ~= 0 then
			desc = g_i3k_db.i3k_db_get_task_desc(12, nocompleteNpcID, nil, nil, false,nil)
		else
			desc = is_ok and g_i3k_db.i3k_db_get_outcast_task_finish_reward_desc(outCastID,id)  or g_i3k_db.i3k_db_get_task_desc(taskType,arg1,arg2,value,is_ok,nil)
		end
		local name = string.format("%s%s",cfg.prename,cfg.taskName)
		local str = string.format("%s\n%s",name, desc)
		self.taskDesc:setText(str)
		self.xunlu_btn:onClick(self, self.toDoLifeTask, {outCastID = outCastID, id = id, reward = reward, dialog = dialog})
	end

end

function wnd_outCastBattle:finishAll()
	local info = g_i3k_game_context:getOutCastInfo()
	g_i3k_ui_mgr:OpenUI(eUIID_OutCastFinish)
	g_i3k_ui_mgr:RefreshUI(eUIID_OutCastFinish, info)
	self.attFriend_slider2:setPercent(1 * 100)
	g_i3k_ui_mgr:PopupTipMessage("外传任务全部完成，请退出查看")
	self.taskDesc:setText("外传任务全部完成\n退出副本")
	self.show_btn:hide()
	self.xunlu_btn:hide()
	info.curTaskValue = 1 
	info.curTaskReward = 1
	g_i3k_game_context:OnCompleteOutCastTask(info.curUnlockID)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleTXFinishTask) -- 播放完成任务特效
end 

function wnd_outCastBattle:toDoLifeTask(sender,data)
	local outCastID, id = data.outCastID, data.id
	local cfg = i3k_db_out_cast_task[id]
	local taskType = cfg.taskType
	if data.reward == 1 then -- 上个任务已完成
		if data.dialog then
			g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(cfg.completeNpcID), g_i3k_db.i3k_db_get_npc_pos(cfg.completeNpcID), TASK_CATEGORY_OUT_CAST,outCastID)
		else
			local npcID = cfg.npcID
			if npcID == 0 then
				local taskDesc = g_i3k_db.i3k_db_get_task_desc(taskType, cfg.arg1, cfg.arg2, 0, false, nil)
				g_i3k_game_context:GetOutCastTaskDialogue(outCastID,id,g_i3k_game_context:getOutCastTaskAward(id),taskDesc)
			else
				g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(npcID), g_i3k_db.i3k_db_get_npc_pos(npcID), TASK_CATEGORY_OUT_CAST,outCastID)
			end
		end
	else
		local point = nil
		local mapId = nil
		if taskType == g_TASK_KILL then
			point = g_i3k_db.i3k_db_get_monster_pos(cfg.arg1);
			mapId = g_i3k_db.i3k_db_get_monster_map_id(cfg.arg1);
		elseif taskType == g_TASK_COLLECT then
			point = g_i3k_db.i3k_db_get_res_pos(cfg.arg1);
			mapId = g_i3k_db.i3k_db_get_res_map_id(cfg.arg1);
		elseif taskType == g_TASK_NPC_DIALOGUE then
			point = g_i3k_db.i3k_db_get_npc_pos(cfg.arg1);
			mapId = g_i3k_db.i3k_db_get_npc_map_id(cfg.arg1);
		elseif taskType == g_TASK_USE_ITEM_AT_POINT then
			local pos = {x=cfg.arg3,y=cfg.arg4,z=cfg.arg5}
			point = pos
			mapId = cfg.arg2   --已经约定的参数
		elseif taskType == g_TASK_TRANSFER then
			if i3k_game_get_map_type() == g_FIELD then
				local now_mapID =  g_i3k_game_context:GetWorldMapID()
				local targetMaps = g_i3k_db.i3k_db_get_all_npcs_map_id_by_funcId(TASK_FUNCTION_TRANSFER)
				mapId,point = g_i3k_db.i3k_db_find_nearest_map(now_mapID,targetMaps)
			end
		elseif taskType == g_TASK_NEW_NPC_DIALOGUE then
			mapId = g_i3k_db.i3k_db_get_npc_map_id(cfg.arg1);
			point = self:getRandomPos(cfg.arg1)
		end
		
		if taskType == g_TASK_GET_TO_FUBEN then
			if cfg.arg1 then
				g_i3k_logic:OpenDungeonUI(false,cfg.arg1)
			end
		elseif taskType == g_TASK_CLEARANCE_ACTIVITYPAD then
			g_i3k_logic:OpenShiLianUI()
		elseif taskType == g_TASK_PERSONAL_ARENA then
			g_i3k_logic:OpenArenaUI()
		else
			if data.isOK == nil then
				if point then
					g_i3k_game_context:SeachPathWithMap(mapId,point, TASK_CATEGORY_OUT_CAST,outCastID)
				end
			end
		end
	end
end

function wnd_outCastBattle:onFinishLifeTask(sender,args)
	local id = args.id
	local outCastID = args.outCastID
	local cfg = i3k_db_out_cast_task[id]
	local completeNpcID = cfg.completeNpcID
	if completeNpcID == 0 then
		g_i3k_game_context:FinishOutCastDialogue(outCastID,id,g_i3k_game_context:isBagEnoughOutTaskAward(outCastID,id),g_i3k_game_context:getOutCastTaskAward(id))
	else
		g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(completeNpcID), g_i3k_db.i3k_db_get_npc_pos(completeNpcID), TASK_CATEGORY_OUT_CAST,outCastID)
	end
end

function wnd_outCastBattle:firstToDoLifeTask(sender, data)
	local cfg = data.cfg
	local outCastID = data.outCastID
	if cfg.npcID == 0 then
		local taskDesc = g_i3k_db.i3k_db_get_task_desc(cfg.taskType, cfg.arg1, cfg.arg2, 0, false, nil)
		g_i3k_game_context:GetOutCastTaskDialogue(outCastID,data.id,g_i3k_game_context:getOutCastTaskAward(data.id),taskDesc)
	else
		g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(cfg.npcID), g_i3k_db.i3k_db_get_npc_pos(cfg.npcID), TASK_CATEGORY_OUT_CAST, outCastID)
	end
end

function wnd_outCastBattle:getRandomPos(NPCID)
	local mapId = g_i3k_db.i3k_db_get_npc_map_id(NPCID)
	local areaId = g_i3k_db.i3k_db_getNpcAreaId_By_npcId(NPCID,mapId)
	local angle = i3k_db_npc_area[areaId].dir.y
	angle = math.pi * 2 - math.rad(angle)
	local a = math.random(angle-math.pi*3/8, angle+math.pi*3/8)
	local x = math.cos(a)*3.7
	local z = math.sin(a)*3.7
	local pos = g_i3k_db.i3k_db_get_npc_pos(NPCID)

	local newpos = {}
	newpos.x = pos.x+x
	newpos.y = pos.y
	newpos.z = pos.z+z
	return newpos
end

function wnd_outCastBattle:refresh()
	self:onShowData()
end

function wnd_create(layout)
	local wnd = wnd_outCastBattle.new();
		wnd:create(layout);
	return wnd;
end
