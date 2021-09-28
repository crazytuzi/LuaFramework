------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_monster").i3k_monster;
require("logic/entity/i3k_entity")
local ENTITYBASE = i3k_entity;

------------------------------------------------------
i3k_npc = i3k_class("i3k_npc", BASE);
function i3k_npc:ctor(guid)
	self._entityType	= eET_NPC;
	self._special = false;
end

function i3k_npc:Create(id, agent, isSpecial)
	local basecfg = i3k_db_npc[id]
	if not basecfg then
		return false;
	end

	local cfg = i3k_db_monsters[basecfg.monsterID];
	if not cfg then
		return false;
	end

	local skills = { };
	if cfg.skills then
		for k, v in ipairs(cfg.skills) do
			skills[v] = { id = v, lvl = cfg.slevel[k] or 0 };
		end
	end
	self._baseCfg = basecfg;
	if isSpecial then
		self._special = isSpecial;
	end

	return self:CreateFromCfg(id, basecfg.remarkName, cfg, cfg.level, skills, false);

end

function i3k_npc:OnUpdate(dTime)
	ENTITYBASE.OnUpdate(self, dTime);
end

function i3k_npc:OnLogic(dTick)
	ENTITYBASE.OnLogic(self, dTick);
end

function i3k_npc:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };
	title.node = _T.i3k_entity_title.new();

	local list = self:getNpcTitleShowList()
	local npcID = self._id
	local inList, show = g_i3k_db.i3k_db_power_rep_check_npc_in_list(list, npcID)
	local flag = true
	if inList then
		if not show then
			flag = false
		end
	end
	local festivalIconID = g_i3k_game_context:getFestivalNpcHeadIcon(i3k_db_npc[npcID], "npcIconPath")
	local festivalIcon = g_i3k_db.i3k_db_get_scene_icon_path(festivalIconID)
	if title.node:Create("npc_title_node_" .. self._guid) then
		local titleMul = {}
		local color = tonumber("0xffffff00", 16)
		if self._baseCfg.typeDesc ~= "" then
			titleMul = {
				[1] = {isText = true, x = -0.5, w = 1.4, y = -1, h = 0.5, name = self._baseCfg.typeDesc},
				[2] = {isText = true, x = -0.6, w = 0.4, y = -0.5, h = 0.5, name = self._name},
				[3] = {isText = false, x = -0.7, w = 1.2, y = -1.2, h = 1.3},
			}
		else
			titleMul = {
				[1] = {isText = true, x = -0.5, w = 1, y = -0.5, h = 0.5, name = self._name},
				[2] = {isText = false, x = -0.6, w = 1.1, y = -1.0, h = 1.1},
			}
		end
		title.nameTb = {}
		for i, e in ipairs(titleMul) do
			if e.isText then
				title.nameTb[i] = title.node:AddTextLable(e.x, e.w, e.y, e.h, color, e.name);
			else
				local index = self._baseCfg.FunctionID[1]
				local path
				if index and index ~= 0 and i3k_db_npc_function_show[index] then
					local titleIconID = i3k_db_npc_function_show[index].npcTitleImgPath
					path = g_i3k_db.i3k_db_get_scene_icon_path(titleIconID)
				end
				if festivalIcon ~= "" then
					path = festivalIcon
				end
				if index == TASK_FUNCTION_SUBLINE_TASK then
					local taskData = g_i3k_game_context:getSubLineIdAndValueBytype(self._baseCfg.exchangeId[1])
					if (not taskData) or (taskData.id == 1 and taskData.state == 0) then
						
					else
						path = nil
					end
				elseif index == TASK_NEW_FESTIVAL_ACCEPT then
					local newFestivalTask = g_i3k_game_context:getNewFestival_tasks()
					if not newFestivalTask or not newFestivalTask[self._baseCfg.ID] or (newFestivalTask[self._baseCfg.ID].state == g_POWER_NEW_FESTIVAL_STATE_UNACCEPT) then 
					else
						path = nil
					end
				end
				if path then
					if flag then -- 势力声望显示头顶图片逻辑
						title.FuncTitle = title.node:AddImgLable(e.x, e.w, e.y, e.h, path)
					end
				end
			end
		end
	
	else
		title.node = nil;
	end

	return title;
end

function i3k_npc:ChangeSpringRollIcon()
	if self._title and self._title.node then
		self._title.node:Release()
		self._title.node = nil
		self._title = self:CreateTitle()
		if self._title and self._title.node then
			self._title.node:SetVisible(true);
			self._title.node:EnterWorld();
			self._entity:AddTitleNode(self._title.node:GetTitle(), 3.6);
		end
	end
end

function i3k_npc:SetNpcTitleImageVisiable(vis)
	if self._title and self._title.node then
		if self._title.FuncTitle then
			self._title.node:SetElementVisiable(self._title.FuncTitle, vis)
		end
	end
end


function i3k_npc:IsAttackable(attacker)
	return false;
end

function i3k_npc:OnSelected(val, ready)
	if self._baseCfg.ID == eExpTreeId and not ready then
		i3k_sbean.request_exp_tree_sync_req(function ()
			self:OnSelected(val, true);
		end)
		return
	end

	BASE.OnSelected(self, val);

	if val == false then
		g_i3k_game_context:OnCancelSelectHandler()
	else
		local id = self._baseCfg.ID
		local name = self._baseCfg.remarkName
		local maxhp = self:GetPropertyValue(ePropID_maxHP)
		local curhp = self:GetPropertyValue(ePropID_hp)
		local buffs = { };
		for k, v in pairs (self._buffs) do
			buffs[v._id] = v._endTime - v._timeLine;
		end

		g_i3k_game_context:OnSelectNPCHandler(id, name, curhp, maxhp,self._curPosE, self:GetGuidID())
	end
end

function i3k_npc:ReplaceNpcAction()
	local basecfg = self._baseCfg
	local ActTypeId = basecfg.replActionTaskId

	if ActTypeId < 0 then
		self:ReplaceActName(i3k_db_common.engine.defaultStandAction, basecfg.replActionName)
		return
	elseif ActTypeId > 0 then
		local world = i3k_game_get_world()
		local npcid = nil
		local replActionName = nil
		if world._mapType == g_Life then
			local petID = g_i3k_game_context:GetLifeTaskRecorkPetID()
			if petID ~= 0 then
				local data = g_i3k_game_context:getLifeIdAndValueBytype(petID)
				local cfg = i3k_db_from_task[petID][data.id]
				npcid = cfg.replActionNpcId
				replActionName = basecfg.replActionName
			end
		else
			local mId = g_i3k_game_context:getMainTaskIdAndVlaue()
			--local tbl = { }
			local cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
			--g_i3k_game_context:CheckSceneTriggerEffect(cfg, 7, tbl)
			if cfg then
				npcid = cfg.replActionNpcId
				replActionName = basecfg.replActionName
			end
		end

		if npcid and replActionName and npcid == basecfg.ID then
			self:ReplaceActName(i3k_db_common.engine.defaultStandAction, replActionName)
			return
		end
	end
end

function i3k_npc:getNpcTitleShowList()
	local fun = 
	{
		[g_PET_ACTIVITY_DUNGEON] = function() return g_i3k_game_context:getPetDungeonHideTitleNpcs() end,
		[g_FIELD] = function() return g_i3k_game_context:getPowerRepHideTitleNpcs() end
	}
	
	local call = fun[i3k_game_get_map_type()]
	return call and call() or {}
end
