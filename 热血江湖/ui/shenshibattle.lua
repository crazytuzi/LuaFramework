module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_shenshiBattle = i3k_class("wnd_shenshiBattle", ui.wnd_base)

function wnd_shenshiBattle:ctor()
	
end

function wnd_shenshiBattle:configure()
	local widgets = self._layout.vars
	self.attFriend_slider2 = widgets.attFriend_slider2
	self.xunlu_btn = widgets.xunlu_btn
	self.xunlu_btn = widgets.xunlu_btn
	self.show_btn = widgets.show_btn
	self.taskDesc = widgets.taskDesc
	
end
function wnd_shenshiBattle:onShowData(petID, isOK, dialog)
	local id, value, reward = g_i3k_game_context:getPetLifeTskIdAndValueById(petID)
	local count = (id - 1)/#i3k_db_from_task[petID]
	if id == 0 then
		count = 0
	end
	self.attFriend_slider2:setPercent(count * 100)
	if id == 0 then
		local cfg = i3k_db_from_task[petID][1]
		local nocompleteNpcID = cfg.npcID
		local completeNpcID = cfg.completeNpcID
		local taskType = cfg.taskType
		local arg1 = cfg.arg1
		local arg2 = cfg.arg2
		local is_ok = g_i3k_game_context:IsTaskFinished(taskType,arg1,arg2,value)
		self.xunlu_btn:onClick(self, self.firstToDoLifeTask,{cfg = cfg, petID = petID, id = 1})
		local desc
		if nocompleteNpcID ~= 0 then
			desc = g_i3k_db.i3k_db_get_task_desc(12, nocompleteNpcID, nil, nil, false,nil)
		else
			desc = is_ok and g_i3k_db.i3k_db_get_life_task_finish_reward_desc(petID,id)  or g_i3k_db.i3k_db_get_task_desc(taskType,arg1,arg2,value,is_ok,nil)
			g_i3k_game_context:GetLifeTaskDialogue(petID,1,g_i3k_game_context:getLifeTaskAward(petID,1),str)
		end
		local name = string.format("%s%s",cfg.prefixTaskName,cfg.taskName)
		local str = string.format("%s\n%s",name, desc)
		self.taskDesc:setText(str)
		self.show_btn:onClick(self, self.openShenshiInfo,{petID = petID, taskId = 1})
		return
	end
	
	if id == #i3k_db_from_task[petID] and reward == 1 then
		self.attFriend_slider2:setPercent(1 * 100)
		g_i3k_ui_mgr:PopupTipMessage("身世任务全部完成，请退出查看")
		self.taskDesc:setText("身世任务全部完成\n退出副本开启喂养")
		self.show_btn:hide()
		self.xunlu_btn:hide()
		g_i3k_game_context:setOnePetLifeTask(petID, #i3k_db_from_task[petID], 1, 1)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleTXFinishTask) -- 播放完成任务特效
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "onExit")
		return
	end
	if reward == 1 then
		local cfg = i3k_db_from_task[petID][id]
		if cfg.postTaskID ~= 0 then
			id = cfg.postTaskID
		end
		value = 0
		--g_i3k_game_context:setOnePetLifeTask(petID,id,value,reward)
	end
	local cfg = i3k_db_from_task[petID][id]
	local completeNpcID = cfg.completeNpcID
	local nocompleteNpcID = cfg.npcID
	local taskType = cfg.taskType
	local arg1 = cfg.arg1
	local arg2 = cfg.arg2
	local is_ok = g_i3k_game_context:IsTaskFinished(taskType,arg1,arg2,value)
	local taskDesc = g_i3k_db.i3k_db_get_task_desc(taskType,arg1,arg2,0,false,nil)
	if reward == 0 then --接任务
		if is_ok then	--是否完成
			if completeNpcID == 0 then --完成任务npc是否为0
				g_i3k_game_context:FinishLifeTaskDialogue(petID,id,g_i3k_game_context:isBagEnoughLifeTaskAward(petID,id),g_i3k_game_context:getLifeTaskAward(petID,id))
			else
				if dialog then
					--g_i3k_game_context:FinishLifeTaskDialogue(petID,id,g_i3k_game_context:isBagEnoughLifeTaskAward(petID,id),g_i3k_game_context:getLifeTaskAward(petID,id))
					g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(completeNpcID), g_i3k_db.i3k_db_get_npc_pos(completeNpcID), TASK_CATEGORY_LIFE,petID)
				else
					if isOK and isOK == true then
						if taskType ~= g_TASK_REACH_LEVEL and taskType ~=g_TASK_TRANSFER then 
							g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(completeNpcID), g_i3k_db.i3k_db_get_npc_pos(completeNpcID), TASK_CATEGORY_LIFE,petID)
						end
					end
				end
			end
			self.xunlu_btn:onClick(self, self.onFinishLifeTask, {id = id , petID = petID, reward = reward})
		else
			if isOK then
				local data = {petID = petID, id = id, reward = reward, isOK = isOK}
				self:toDoLifeTask(nil, data)
			end
			self.xunlu_btn:onClick(self, self.toDoLifeTask, {petID = petID, id = id, reward = reward})
		end
		local desc = is_ok and g_i3k_db.i3k_db_get_life_task_finish_reward_desc(petID,id)  or g_i3k_db.i3k_db_get_task_desc(taskType,arg1,arg2,value,is_ok,nil)
		local name = string.format("%s%s",cfg.prefixTaskName,cfg.taskName)
		local str = string.format("%s\n%s",name, desc)
		self.taskDesc:setText(str)
	elseif reward == 1 then --交任务
		if nocompleteNpcID == 0 then
			local taskDesc = g_i3k_db.i3k_db_get_task_desc(taskType, cfg.arg1, cfg.arg2, 0, false, nil)
			g_i3k_game_context:GetLifeTaskDialogue(petID,id,g_i3k_game_context:getLifeTaskAward(petID,id),taskDesc)
		else
			if dialog then
				g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(completeNpcID), g_i3k_db.i3k_db_get_npc_pos(completeNpcID), TASK_CATEGORY_LIFE,petID)
				--g_i3k_game_context:FinishLifeTaskDialogue(petID,id,g_i3k_game_context:isBagEnoughLifeTaskAward(petID,id),g_i3k_game_context:getLifeTaskAward(petID,id))
			else
				local oldCfg = i3k_db_from_task[petID][id-1]
				if oldCfg and oldCfg.completeNpcID == nocompleteNpcID then
					--g_i3k_game_context:GetLifeTaskDialogue(petID,id,g_i3k_game_context:getLifeTaskAward(petID,id),taskDesc)
					g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(nocompleteNpcID), g_i3k_db.i3k_db_get_npc_pos(nocompleteNpcID), TASK_CATEGORY_LIFE,petID)
				end
			end
		end
		is_ok = false
		if nocompleteNpcID ~= 0 then
			desc = g_i3k_db.i3k_db_get_task_desc(12, nocompleteNpcID, nil, nil, false,nil)
		else
			desc = is_ok and g_i3k_db.i3k_db_get_life_task_finish_reward_desc(petID,id)  or g_i3k_db.i3k_db_get_task_desc(taskType,arg1,arg2,value,is_ok,nil)
		end
		--local taskDesc = g_i3k_db.i3k_db_get_task_desc(taskDesc, nocompleteNpcID, cfg.arg2, 0, false, nil)
		local name = string.format("%s%s",cfg.prefixTaskName,cfg.taskName)
		local str = string.format("%s\n%s",name, desc)
		self.taskDesc:setText(str)
		self.xunlu_btn:onClick(self, self.toDoLifeTask, {petID = petID, id = id, reward = reward, dialog = dialog})
	end
	
	self.show_btn:onClick(self, self.openShenshiInfo,{petID = petID, taskId = id})
end

function wnd_shenshiBattle:toDoLifeTask(sender,data)
	local petID, id = data.petID, data.id
	local cfg = i3k_db_from_task[petID][id]
	local taskType = cfg.taskType
	if data.reward == 1 then
		if data.dialog then
			g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(cfg.completeNpcID), g_i3k_db.i3k_db_get_npc_pos(cfg.completeNpcID), TASK_CATEGORY_LIFE,petID)
			--g_i3k_game_context:FinishLifeTaskDialogue(petID,id,g_i3k_game_context:isBagEnoughLifeTaskAward(petID,id),g_i3k_game_context:getLifeTaskAward(petID,id))
		else
			local npcID = cfg.npcID
			if npcID == 0 then
				local taskDesc = g_i3k_db.i3k_db_get_task_desc(taskType, cfg.arg1, cfg.arg2, 0, false, nil)
				g_i3k_game_context:GetLifeTaskDialogue(petID,id,g_i3k_game_context:getLifeTaskAward(petID,id),taskDesc)
			else
				g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(npcID), g_i3k_db.i3k_db_get_npc_pos(npcID), TASK_CATEGORY_LIFE,petID)
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
					g_i3k_game_context:SeachPathWithMap(mapId,point, TASK_CATEGORY_LIFE,petID)
				end
			end
		end
	end
end

function wnd_shenshiBattle:onFinishLifeTask(sender,args)
	local id = args.id
	local petID = args.petID
	local cfg = i3k_db_from_task[petID][id]
	local completeNpcID = cfg.completeNpcID
	if completeNpcID == 0 then
		g_i3k_game_context:FinishLifeTaskDialogue(petID,id,g_i3k_game_context:isBagEnoughLifeTaskAward(petID,id),g_i3k_game_context:getLifeTaskAward(petID,id))
	else
		g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(completeNpcID), g_i3k_db.i3k_db_get_npc_pos(completeNpcID), TASK_CATEGORY_LIFE,petID)
	end
end

function wnd_shenshiBattle:firstToDoLifeTask(sender, data)
	local cfg = data.cfg
	local petID = data.petID
	if cfg.npcID == 0 then
		local taskDesc = g_i3k_db.i3k_db_get_task_desc(cfg.taskType, cfg.arg1, cfg.arg2, 0, false, nil)
		g_i3k_game_context:GetLifeTaskDialogue(petID,data.id,g_i3k_game_context:getLifeTaskAward(petID,data.id),taskDesc)
	else
		g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(cfg.npcID), g_i3k_db.i3k_db_get_npc_pos(cfg.npcID), TASK_CATEGORY_LIFE,petID)
	end
end

function wnd_shenshiBattle:openShenshiInfo(sender, data)
	g_i3k_ui_mgr:OpenUI(eUIID_ShenshiExplore)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenshiExplore, data.petID, data.taskId, true)
end

function wnd_shenshiBattle:getRandomPos(NPCID)
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
	return newpos--i3k_getRandomPos(pos ,2.5)
end

function wnd_shenshiBattle:refresh(petID)
	self:onShowData(petID)
end

function wnd_create(layout)
	local wnd = wnd_shenshiBattle.new();
		wnd:create(layout);
	return wnd;
end
