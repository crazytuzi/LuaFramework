------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =require("logic/entity/i3k_entity_trap").i3k_entity_trap;

i3k_entity_resourcepoint = i3k_class("i3k_entity_resourcepoint",BASE);
------------------------------------------------------

local releaseTime = 5

local RESOURCR_NONE = 1 --可采
local RESOURCR_TIME = 0 --计时
local RESOURCR_END = -1 --结束

------------------------------------------------------
function i3k_entity_resourcepoint:ctor(guid)
	self._entityType		= eET_ResourcePoint;
	self._PVPColor			= -2;
	self._showmode			= true
	self._aiController		= nil;
	self._trapaiController  = nil;
	self._ownType 			= 0; --帮派战中资源归属 -1 中立 1 蓝方 2 红方
	self._titleState        = nil --荒漠宝箱 -1 没了， 1可采 0 未刷新
	self._state = nil --宝箱状态 1 是能采集 0是不能采集
end

function i3k_entity_resourcepoint:Create(gid)
	local gcfg = i3k_db_resourcepoint[gid];
	if not gcfg then
		return false;
	end
	
	self._gid	= gid;
	self._gcfg	= gcfg;
	local trapaiMgr = require("logic/entity/ai/i3k_trap_mgr");
	if not trapaiMgr then
		return false;
	end

	if gcfg.nType then 
		self._trapaiController = trapaiMgr.create_mgr(self);
	end
	self._entityType	= eET_ResourcePoint;
	self._activeonce	= true;	--only for logic trans

	self._cfg	= cfg;
	self._name	= gcfg.name;

	self:CreateResSync(gcfg.modelID);
	if gcfg.nType == 1 then
		self:ShowTitleNode(false);
	else
		self:ShowTitleNode(true);
	end

	return true;
end

function i3k_entity_resourcepoint:setOwnType(ownType)
	
	if not ownType then
		return
	end
	
	self._ownType = ownType
	
	if self._gcfg.nType == 9 then
		--小旗
		if ownType == -1 then
			self:Play("stand", -1, true)
		elseif ownType == 1 then
			self:Play("stand1", -1, true)
		elseif ownType == 2 then
			self:Play("stand2", -1, true)
		end
	elseif self._gcfg.nType == 10 then
		--大旗
		self:RestoreModelFacade()
		if ownType == -1 then
			self:ChangeModelFacade(438)
		elseif ownType == 1 then
			self:ChangeModelFacade(440)
		elseif ownType == 2 then
			self:ChangeModelFacade(439)
		end
		self:Play("stand", -1, true)
		--self:UpdateFactionFlagLable()
	elseif self._gcfg.nType == 15 then  -- 城战	
		local cfg = i3k_db_defenceWar_cfg and i3k_db_defenceWar_cfg.group[ownType]
		
		if cfg then
			self:ChangeModelFacade(cfg.factionFlagModelID)
		else
			self:RestoreModelFacade()
		end
			
		self:Play("stand", -1, true)
	end
end

--更新标题
function i3k_entity_resourcepoint:updataDesertTitleState(count, RoleID)

	if count == 0 then
		self:SetDesertTitleState(RESOURCR_END)
	else
		local isCanOpen, refreshTime = g_i3k_db.i3k_desert_resource_can_open(RoleID)
		if isCanOpen then
			self:SetDesertTitleState(RESOURCR_NONE)
		else
			self:SetDesertTitleState(RESOURCR_TIME, refreshTime)
		end
	end
	
end


--更新状态
function i3k_entity_resourcepoint:SetDesertTitleState(state, refreshTime)
	
	if self._title then
		if not self._title.typeName then return end
		self._titleState = state
		local effectId = i3k_db_desert_battle_base.effectId
		if self._titleCo then
			g_i3k_coroutine_mgr:StopCoroutine(self._titleCo)
			self._titleCo = nil
		end
		if self._titleState == RESOURCR_NONE then
			--self:SetResourceTitleImageVisiable(true)
			self:SetTypeNameVisiable(false)
			self:AddSpecialEffect(effectId)
			
		elseif 	self._titleState == RESOURCR_END then
			self:SetTypeNameVisiable(true)
			--self:SetResourceTitleImageVisiable(false)
			self._title.node:UpdateTextLable(self._title.typeName, i3k_get_string(17604), true, tonumber("0xffff0000", 16), true)
			self:ClearSpecialEffect()
		elseif 	self._titleState == RESOURCR_TIME then
			self:SetTypeNameVisiable(true)
			--self:SetResourceTitleImageVisiable(false)
			if refreshTime == -1 then
				self._title.node:UpdateTextLable(self._title.typeName, i3k_get_string(17604), true, tonumber("0xffff0000", 16), true)
				return
			end
			self:AddSpecialEffect(effectId)
			local openTime =  g_i3k_db.i3k_desert_resource_open_state(refreshTime) or self._name  --宝箱倒计时
			self._title.node:UpdateTextLable(self._title.typeName, openTime, true, tonumber("0xffff0000", 16), true)
			self._titleCo = g_i3k_coroutine_mgr:StartCoroutine(function()
				while true do
					g_i3k_coroutine_mgr.WaitForSeconds(1)
					local openTime =  g_i3k_db.i3k_desert_resource_open_state(refreshTime) --宝箱倒计时
					if openTime then
						self._title.node:UpdateTextLable(self._title.typeName, openTime, true, tonumber("0xffff0000", 16), true)
					else
						self._titleState = RESOURCR_NONE
						--self:SetResourceTitleImageVisiable(true)
						self:SetTypeNameVisiable(false)
						g_i3k_coroutine_mgr:StopCoroutine(self._titleCo)
						self._titleCo = nil
						break
					end
				end
			end)
		end
	end
end


--显隐图标
function i3k_entity_resourcepoint:SetResourceTitleImageVisiable(vis)
	if self._title and self._title.node then
		if self._title.FuncTitle then
			self._title.node:SetElementVisiable(self._title.FuncTitle, vis)
		end
	end
end

function i3k_entity_resourcepoint:IsDestory()
	return self._entity == nil;
end

function i3k_entity_resourcepoint:CreateTitle()
	local _T = require("logic/entity/i3k_entity_title");

	local title = { };
	local color = tonumber("0xffffffff", 16)
	if self._gcfg.nType == 5 then
		if g_i3k_game_context:GetCurrentMapFlagId() == 0 then
			--color = tonumber(g_i3k_get_white_color(), 16)
		elseif g_i3k_game_context:GetCurrentMapFlagId() == g_i3k_game_context:GetSectId() then
			self._name = g_i3k_game_context:GetCurrentMapFlagName()
			color = tonumber("ff28c7ef", 16)
		else
			self._name = g_i3k_game_context:GetCurrentMapFlagName()
			color = tonumber("fff93939", 16)
		end 
	end
	
	title.node = _T.i3k_entity_title.new();
	if title.node:Create("resourcepoint_title_node_" .. self._guid) then
		if self._gcfg.nType == 17 then --决战荒漠
			local color = tonumber("0xffffff00", 16)
			title.typeName = title.node:AddTextLable(-0.5, 1, -0.25, 0.5, color, self._name);
		else
			title.name = title.node:AddTextLable(-0.5, 1, -0.25, 0.5, color, self._name);
			if self._gcfg.nType == 12 then --帮派驻地龙运之柱
				title.bbar	= title.node:AddBloodBar(-0.5, 1, 0.5, 0.25 * 0.5);
			end
		end
	else
		title.node = nil;
	end

	return title;
end

--龙运之柱气运改变
function i3k_entity_resourcepoint:UpdateBarPercent(percent)
	if self._title and self._title.node then
		self._title.node:UpdateBloodBar(self._title.bbar, percent)
		if percent <= i3k_db_faction_dragon.destiny.minPercent / 10000 then
			self._title.node:UpdateTextLable(self._title.name, "", false, tonumber("0xffff0000", 16), true)
		end
	end
end

function i3k_entity_resourcepoint:UpdateFactionFlagLable()
	local color = tonumber("0xffffffff", 16)
	if g_i3k_game_context:GetCurrentMapFlagId() == 0 then
		--color = tonumber(g_i3k_get_white_color(), 16)
	elseif g_i3k_game_context:GetCurrentMapFlagId() == g_i3k_game_context:GetSectId() then
		self._name = g_i3k_game_context:GetCurrentMapFlagName()
		color = tonumber("ff28c7ef", 16)
	else
		self._name = g_i3k_game_context:GetCurrentMapFlagName()
		color = tonumber("fff93939", 16)
	end 
	if self._title and self._title.node then
		self._title.node:UpdateTextLable(self._title.name,self._name,true, color,true)
	end
end

function i3k_entity_resourcepoint:InitProperties()
	local gid	= self._gid;
	local gcfg_base	= self._gcfg_base;
	local gcfg_external	= self._gcfg_external;

	-- 鍩虹灞炴€?
	
	local properties =
	{
		[ePropID_TrapType] = i3k_entity_trap_property.new(self, ePropID_TrapType,1),
		[ePropID_skillId] = i3k_entity_trap_property.new(self, ePropID_skillId,	2),
		[ePropID_LogicId] =  i3k_entity_trap_property.new(self, ePropID_LogicId,3),
		[ePropID_TargetId] = {},
	};
	
	local lvl = 1;
	if gcfg_base then
		lvl = gcfg_base.lvl
	end
	local ntype = 0;
	if gcfg_base then
		ntype = gcfg_base.TrapType;  --TODO 涓存椂鐢╯ex灞炴€т唬鏇块櫡闃辩被鍒紝绋嶅悗淇敼
	end
	
	local skillId = -1;
	if gcfg_base then
		skillId = gcfg_base.SkillID;
	end

	local LogicId = -1;
	if gcfg_external then
		LogicId = gcfg_external.TrapLogicID;
	end
	-- update all properties
	properties[ePropID_lvl		]:Set(lvl,ePropType_Base);
	properties[ePropID_TrapType	]:Set(ntype,ePropType_Base);
	properties[ePropID_skillId	]:Set(skillId,ePropType_Base);
	properties[ePropID_LogicId	]:Set(LogicId,ePropType_Base);
	return properties;
end

function i3k_entity_resourcepoint:IsAttackable(attacker)
	return false;
end

function i3k_entity_resourcepoint:SetAiComp(atype)
	if self._trapaiController then
		self._trapaiController:ChangeTrap(atype);
	end
end


function i3k_entity_resourcepoint:OnUpdate(dTime)
	if self._turnMode then
		self._turnTick = self._turnTick + dTime;
		if self._turnTick <= 0.1 then
			local d = self._turnTick / 0.1;

			local f = i3k_vec3_lerp(self._turnOriDir, self._turnDir, d);

			self:SetFaceDir(f.x, f.y, f.z);
		else
			self._turnMode = false;

			self:SetFaceDir(self._turnDir.x, self._turnDir.y, self._turnDir.z);
		end
	end

	if self._trapaiController then
		self._trapaiController:OnUpdate(dTime);
	end
end

function i3k_entity_resourcepoint:OnLogic(dTick)
	if self._trapaiController then
		self._trapaiController:OnLogic(dTick);
	end
	
	if not self:IsInLeaveCache() and not self._showmode then
		self._showmode = true;
		if self:IsShow() == false then
			self:Show(true);
		end
	end

	if self:IsInLeaveCache() then
		self:UpdateCacheTime(dTick * i3k_engine_get_tick_step());
		if self:IsShow() then
			self:Show(false);
		end
		self._showmode = false;
		if self:GetLeaveCacheTime() > releaseTime then
			local world = i3k_game_get_world();
			if world then
				local guid = string.split(self._guid, "|")								
				local RoleID = tonumber(guid[2])
				local entitResourcePoint = world._ResourcePoints[RoleID];
				if entitResourcePoint then
					--world._ResourcePoints[RoleID] = nil
					world:RmvEntity(entitResourcePoint);
					entitResourcePoint:Release()
					self._showmode = true
				end			
			end
			self:ShowTitleNode(false)
			self:ResetLeaveCache();
		end
	end
end



function i3k_entity_resourcepoint:SetTrapBehavior(ntype,activeonce)	
	if not activeonce then
		self._activeonce = false;
	end
	self._behavior:Set(ntype);
    self:SetAiComp(ntype);

end

function i3k_entity_resourcepoint:GetStatus()
	if self and self._trapaiController then
		return self._trapaiController._statu;
	end
	return -1;
end

function i3k_entity_resourcepoint:OnDamage(attacker, val, atr, cri, stype, showInfo, update, SourceType, direct, buffid)
end


function i3k_entity_resourcepoint:InitSkill(id)
end


function i3k_entity_resourcepoint:UseSkill(skill)
	local res = false;

	return res;
end

function i3k_entity_resourcepoint:IsDead()
	return self:GetStatus() ~= eSTrapMine;
end

function i3k_entity_resourcepoint:OnSelected(val)
	BASE.OnSelected(self, val);

	if self:GetStatus() == eSTrapMine and self._selected == true then
		local logic = i3k_game_get_logic()
		local player = logic:GetPlayer()
		local hero = player:GetHero()
		if not hero then
			return
		end

		BASE.OnSelected(self, false);
		
		local dist = i3k_vec3_sub1(self._curPos, hero._curPos);
		local DigMineDistance = i3k_db_common.digmine.DigMineDistance
		if self._gcfg.nType == g_TYPE_MINE_JUBILEE then 
			DigMineDistance = i3k_db_jubilee_base.stage3.digMineDistance
		end

		if DigMineDistance < i3k_vec3_len(dist) or not hero:CanUseSkill() then
			hero:DigMineCancel()
			return;
		end
		
		g_i3k_game_context:SetMineInfo(self)
		g_i3k_game_context:remmberMineTaskType(0)
		g_i3k_game_context:clearMineTaskInfo()
		--TODO
		if self._gcfg.nType == 1 then		--任务矿 self._cfg.nQuest   nTool   bToolexpend nLevel
			local id = self._gcfg.ID

			local mId,mVlue = g_i3k_game_context:getMainTaskIdAndVlaue()
			local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
			if main_task_cfg and main_task_cfg.type == g_TASK_COLLECT and id == main_task_cfg.arg1 then
				if mVlue < main_task_cfg.arg2 then
					g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_MAIN)
					hero:SetDigStatus(1)
					return
				end
			end
			
			--支线任务
			local subLineTaskData = g_i3k_game_context:getSubLineTask()
			for k,v in pairs(subLineTaskData) do
				if v.id > 0 and v.state == 1 then
					local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(k,v.id)
					if cfg.arg1 == id then
						if cfg.arg2 > v.value then
							g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_SUBLINE)
							hero:SetDigStatus(1)
							return
						end
					end
				end
			end	
			
			--身世任务
			local petID = g_i3k_game_context:GetLifeTaskRecorkPetID()
			if petID ~= 0 then
				local isTrue = false
				local taskId, valueCount, reward = g_i3k_game_context:getPetLifeTskIdAndValueById(petID)
				local cfg = i3k_db_from_task[petID][taskId]
				local arg1 = cfg.arg1
				local arg2 = cfg.arg2
				if arg1 == id then
					if arg2 >= valueCount then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_LIFE)
						hero:SetDigStatus(1)
						return;
					end
				end
			end
			
			--外传任务
			local petID = g_i3k_game_context:getCurOutCastID()
			if petID ~= 0 then
				local isTrue = false
				local taskId, valueCount, reward = g_i3k_game_context:getOutCastTskIdAndValueById(petID)
				local cfg = i3k_db_out_cast_task[taskId]
				local arg1 = cfg.arg1
				local arg2 = cfg.arg2
				if arg1 == id then
					if arg2 >= valueCount then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_OUT_CAST)
						hero:SetDigStatus(1)
						return;
					end
				end
			end
			
			--帮派任务
			local fct_taskID, fct_value = g_i3k_game_context:getFactionTaskIdValueTime()	
			fct_value = fct_value or 0
			if fct_taskID then
				local faction_task_cfg = g_i3k_db.i3k_db_get_faction_task_cfg(fct_taskID)
				if faction_task_cfg.type == g_TASK_COLLECT and id == faction_task_cfg.arg1 then			
					if fct_value < faction_task_cfg.arg2 then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_SECT)
						hero:SetDigStatus(1)
						return;
					end
				end
			end 
			
			--结婚任务
			local mrg_data = g_i3k_game_context:GetMarriageTaskData()	
			if mrg_data.id ~= 0 then
				local cfg = g_i3k_db.i3k_db_marry_task(mrg_data.id, mrg_data.groupID)
				if cfg.type == g_TASK_COLLECT and id == cfg.arg1 then				
					if mrg_data.value < cfg.arg2 then
						g_i3k_game_context:remmberMineTaskType(i3k_get_MrgTaskCategory())
						hero:SetDigStatus(1)
						return;
					end
				end
			end 

			local epic_data = g_i3k_game_context:getCurrEpicTaskData()
			if epic_data and epic_data.id and epic_data.id > 0 and epic_data.state and epic_data.state > 0 then
				local cfg = g_i3k_db.i3k_db_epic_task_cfg(epic_data.seriesID, epic_data.groupID, epic_data.id)
				if cfg.type == g_TASK_COLLECT and id == cfg.arg1 then				
					if epic_data.value < cfg.arg2 then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_EPIC)
						hero:SetDigStatus(1)
						return;
					end
				end
			end
			--神兵任务
			local wId,wType = g_i3k_game_context:getWeaponTaskIdAndLoopType()
			if wId and wId > 0 then
				local weapon_task_cfg = g_i3k_db.i3k_db_get_weapon_task_cfg(wId,wType)
				if weapon_task_cfg.type1 == g_TASK_COLLECT or weapon_task_cfg.type2 == g_TASK_COLLECT then
					local value1,value2 = g_i3k_game_context:getWeaponTaskArgsCountAndArgs()
					if weapon_task_cfg.arg11 == id then
						if value1 < weapon_task_cfg.arg12 then
							g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_WEAPON)
							hero:SetDigStatus(1)
							return
						end
					end
					if weapon_task_cfg.arg21 == id then
						if value2 < weapon_task_cfg.arg22 then
							g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_WEAPON)
							hero:SetDigStatus(1)
							return
						end
					end
				end
			end

			local petTask = g_i3k_game_context:GetPetTask()
			for k,v in pairs(petTask) do
				local taskID = v.id 
				local value = v.value 
				local pet_task_cfg = g_i3k_db.i3k_db_get_pet_task_cfg(taskID)
				if pet_task_cfg then
					local arg1 = pet_task_cfg.arg1
					local arg2 = pet_task_cfg.arg2
					if arg1 == id then 
						if value < arg2 then
							g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_PET)
							hero:SetDigStatus(1)
							return
						end
					end
				end
			end
			
			--龙穴任务
			local dragonHoleTask = g_i3k_game_context:GetAcceptDragonHoleTask()
			for k, v in ipairs(dragonHoleTask) do
				local taskId = v.id
				local value = v.value
				local taskCfg = g_i3k_db.i3k_db_get_dragon_task_cfg(taskId)
				if taskCfg then
					local arg1 = taskCfg.arg1
					local arg2 = taskCfg.arg2
					if arg1 == id then
						if value < arg2 then
							g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_DRAGON_HOLE)
							hero:SetDigStatus(1)
							return
						end
					end
				end
			end
			
			local data = g_i3k_game_context:getAdventureTask()
			if data and data.id and data.state == 1 and data.id > 0 then
				local cfg = i3k_db_adventure.tasks[data.id]
				if cfg.type == g_TASK_COLLECT and id == cfg.arg1 then
					if cfg.arg4 ~= 0 and not g_i3k_game_context:getPusslePicIsFinish() then
						g_i3k_ui_mgr:OpenUI(eUIID_puzzlePic)
						g_i3k_ui_mgr:RefreshUI(eUIID_puzzlePic, cfg.arg4, function( )
							g_i3k_game_context:TaskCollect(cfg.arg1)
						end)
					else
						if data.value < cfg.arg2 then
							g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_ADVENTURE)
							hero:SetDigStatus(1)
							return;
						end
					end
				end
			end

			local data = g_i3k_game_context:getFactionBusinessTask()
			if data.id > 0 then
				local cfg = i3k_db_factionBusiness_task[data.id]
				if cfg.type == g_TASK_COLLECT and id == cfg.arg1 then				
					if data.value < cfg.arg2 then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_FCBS)
						hero:SetDigStatus(1)
						return;
					end
				end
			end
			
			local chess = g_i3k_game_context:getChessTask()
			if chess and chess.curTaskID and chess.curTaskID > 0 and chess.state > 0 then
				local cfg = i3k_db_chess_task[chess.curTaskID]
				if cfg.type == g_TASK_COLLECT and id == cfg.arg1 then				
					if chess.curValue < cfg.arg2 then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_CHESS)
						hero:SetDigStatus(1)
						return;
					end
				end
			end
			
			local powerRep = g_i3k_game_context:getAllPowerRepTasks()
			for k, v in pairs(powerRep) do
				local cfg = g_i3k_db.i3k_db_power_rep_get_taskCfg_by_hash(k)
				if cfg.taskConditionType == g_TASK_COLLECT and id == cfg.args[1] then
					if v.value < cfg.args[2] then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_POWER_REP)
						hero:SetDigStatus(1)
						return;
					end
				end
			end
			
			local festival = g_i3k_game_context:getFestivalLimitTask()
			for k, v in pairs(festival) do
				if v.curTask and v.curTask.state == 1 then
					local taskCfg = i3k_db_festival_task[v.curTask.groupId][v.curTask.index]
					if taskCfg.type == g_TASK_COLLECT and id == taskCfg.arg1 then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_FESTIVAL)
						hero:SetDigStatus(1)
						return;
					elseif taskCfg.type == g_TASK_SCENE_MINE then
						local mineIndex = g_i3k_db.i3k_db_get_scene_mine_index(taskCfg.arg1, id)
						local data = g_i3k_game_context:getFestivalTaskValue(v.curTask.groupId, v.curTask.index)
						local havePlace = g_i3k_db.i3k_db_get_scene_mine_have_place(data.value, taskCfg.arg1, id)
						if mineIndex and not havePlace then
							g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_FESTIVAL)
							g_i3k_game_context:remmberMineTaskInfo(taskCfg.arg1, mineIndex)
							hero:SetDigStatus(1)
							return;
						end
					end
				end
			end

			local jubilee = g_i3k_game_context:GetJubileeStep2Task()
			if jubilee and jubilee.id and jubilee.id > 0 and jubilee.state > 0 then
				local cfg = g_i3k_db.i3k_db_get_jubilee_task_cfg(jubilee.id)
				if cfg.type == g_TASK_COLLECT and id == cfg.arg1 then				
					g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_JUBILEE)
					hero:SetDigStatus(1)
					return;
				elseif cfg.type == g_TASK_SCENE_MINE then
					local mineIndex = g_i3k_db.i3k_db_get_scene_mine_index(cfg.arg1, id)
					local havePlace = g_i3k_db.i3k_db_get_scene_mine_have_place(jubilee.value, cfg.arg1, id)
					if mineIndex and not havePlace then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_JUBILEE)
						g_i3k_game_context:remmberMineTaskInfo(cfg.arg1, mineIndex)
						hero:SetDigStatus(1)
						return;
					end
				end
			end
			local taskId, value, state = g_i3k_game_context:getSwordsmanCircleTask()
			if taskId and taskId ~= 0 then
				local taskCfg = i3k_db_swordsman_circle_tasks[taskId]
				if taskCfg.type == g_TASK_COLLECT and id == taskCfg.arg1 then			
					if value < taskCfg.arg2 then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_SWORDSMAN)
						hero:SetDigStatus(1)
						return;
					end
				end
			end 
			--赏金任务
			local globalTaskData = g_i3k_game_context:GetGlobalWorldTaskDataCfgByNPCID(id)
			if globalTaskData.id and globalTaskData.id > 0 then
				local taskCfg = i3k_db_war_zone_map_task[globalTaskData.id]
				if globalTaskData.curValue < taskCfg.arg2 then
					g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_GLOBALWORLD)
					hero:SetDigStatus(1)
				end
				return;
			end
			local taskId, value, state = g_i3k_game_context:getBiographyTask()
			local careerId = g_i3k_game_context:getCurBiographyCareerId()
			if taskId and taskId ~= 0 and state > 0 then
				local taskCfg = i3k_db_wzClassLand_task[careerId][taskId]
				if taskCfg.type == g_TASK_COLLECT and id == taskCfg.arg1 then			
					if value < taskCfg.arg2 then
						g_i3k_game_context:remmberMineTaskType(TASK_CATEGORY_BIOGRAPHY)
						hero:SetDigStatus(1)
						return;
					end
				end
			end
			hero:SetDigStatus(0)	
		elseif self._gcfg.nType == 2 then	--副本矿 nLevel
			if i3k_game_get_map_type() == g_MAZE_BATTLE then
				local mInfo = self._gcfg
				if not g_i3k_db.i3k_db_get_maze_mine_isIn_Area(self._gid) then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17791))
					return  --ncount 17763 上限
				end
				if self:getResourcepointState() == 0 then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17763))
				return
				end			
				if (mInfo.nTool > 0 and g_i3k_game_context:GetCommonItemCanUseCount(mInfo.nTool) < mInfo.bToolexpend) then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17792))
					return 
				end
			end
			hero:SetDigStatus(1)
		elseif self._gcfg.nType == 3 then	--彩蛋矿
			hero:SetDigStatus(1)
		elseif self._gcfg.nType == 4 then
 			local mInfo = self._gcfg
 			
			if g_i3k_game_context:GetLevel() < mInfo.nLevel then
				return g_i3k_ui_mgr:PopupTipMessage(string.format("請達到%d級再來開啓",mInfo.nLevel))
			end
			if (mInfo.nTool > 0 and g_i3k_game_context:GetCommonItemCanUseCount(mInfo.nTool) >= mInfo.bToolexpend) or mInfo.nTool == 0 then
 				hero:SetDigStatus(1)
 			else
 				g_i3k_ui_mgr:PopupTipMessage(string.format("請尋找<c=hlred>%d</c>個<c=hlred>%s</c>打開",mInfo.bToolexpend,i3k_db_new_item[mInfo.nTool].name))
			end
		elseif self._gcfg.nType == 5 then
			hero:SetDigStatus(1)
		elseif self._gcfg.nType == 6 then --婚宴
			hero:SetDigStatus(1)
		elseif self._gcfg.nType == 7 then --婚宴礼盒
			hero:SetDigStatus(1)
		elseif self._gcfg.nType == 8 then --太玄碑文矿
			local mInfo = self._gcfg
			local stlData = g_i3k_game_context:getStelaActivityData()
			if stlData.allFinish == 1 then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(887))
			end
			if stlData.index == 0 then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(886))
			end
			for i , v in ipairs(i3k_db_steleAct.stale[stlData.stlType]) do
				if v.mineId == mInfo.ID then
					if i < stlData.index then
						return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(890))
					elseif i > stlData.index then
						return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(903))
					end
				end
			end
			if g_i3k_game_context:GetLevel() < mInfo.nLevel then
				return g_i3k_ui_mgr:PopupTipMessage(string.format("請達到%d級再來%s",mInfo.nLevel,mInfo.mineText))
			end
			hero:SetDigStatus(1)
		elseif self._gcfg.nType == 9 or self._gcfg.nType == 10 then
			if self._ownType ~= hero:GetForceType() then
				hero:SetDigStatus(1)
			else
				hero:SetDigStatus(0)
			end
		elseif self._gcfg.nType == 11 then --帮战内宝箱
			hero:SetDigStatus(1)
		elseif self._gcfg.nType == 12 then --帮派驻地内龙运之柱
			if g_i3k_game_context:GetIsOwnFactionZone() then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16750))
			else
				hero:SetDigStatus(1)
			end
		elseif self._gcfg.nType == 13 then --武道会复活球
			if not g_i3k_game_context:GetIsGuard() then
				if self._ownType == hero:GetForceType() then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1242))
				else
					hero:SetDigStatus(1)
				end
			end
		elseif self._gcfg.nType == 14 then
			if g_i3k_game_context:getPveBattleKey() >= i3k_db_crossRealmPVE_cfg.needBattleCoin then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1329))
			else
				hero:SetDigStatus(1)
			end
		elseif self._gcfg.nType == 15 then  --城战复活点
			if hero:GetForceType() == self._ownType then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(779))
				hero:SetDigStatus(0)
			else
				hero:SetDigStatus(1)
			end	
		elseif self._gcfg.nType == 16 then  --宠物试炼采集
			if g_i3k_game_context:getPetDungeonGatherCount() >= i3k_db_PetDungeonBase.gatherAllCount then
				g_i3k_ui_mgr:PopupTipMessage(string.format("本次試煉已經採集%s次，無法繼續採集", i3k_db_PetDungeonBase.gatherAllCount))
			else
				local cfg = g_i3k_db.i3k_db_get_PetDungeonGather_By_MiniID(self._gid)
				
				if cfg then
					g_i3k_logic:OpenPetDungeonGatherOperationUI(cfg, false)
				end
			end
		elseif self._gcfg.nType == 17 then  --决战荒漠
			if hero._missionMode.valid and hero._missionMode.type == g_TASK_TRANSFORM_STATE_SKULL then return end
			if self._titleState then
				if self._titleState == RESOURCR_END then 
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17604))
				elseif self._titleState == RESOURCR_NONE then
					hero:SetDigStatus(1)
				end
			end
		elseif self._gcfg.nType == 18 then  --天魔迷宫
			if not g_i3k_game_context:isCanGatherInMaze() then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17749))
			else
				if g_i3k_db.i3k_db_get_maze_mine_isIn_Area(self._gid) then
					hero:SetDigStatus(1)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17791))
				end
			end		
		elseif self._gcfg.nType == g_TYPE_MINE_JUBILEE then  --周年庆活动矿物
			local joinLevel = i3k_db_jubilee_base.commonCfg.joinLevel
			if g_i3k_game_context:GetLevel() < joinLevel then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17943, joinLevel))
			end
			local num = i3k_db_jubilee_base.stage3.bagGrid
			if not g_i3k_game_context:checkBagCanAddCell(num, true) then
				return
			end
			local mineralTimes = g_i3k_game_context:GetubileeStep3MineralTimes()
			if mineralTimes and mineralTimes >= i3k_db_jubilee_base.stage3.dayLimitTimes then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15396))
			else
				hero:SetDigStatus(1)
			end		
		elseif self._gcfg.nType == g_TYPE_MINE_PRINCESSMARRY then  --公主出嫁
			hero:SetDigStatus(1)
		elseif self._gcfg.nType == g_TYPE_MINE_HOMELANDGUARD then  --家园保卫战
			hero:SetDigStatus(1)
		elseif self._gcfg.nType == g_TYPE_MINE_LONGEVITY_PAVILION then  --万寿阁
			hero:SetDigStatus(1)
		elseif self._gcfg.nType == g_TYPE_MINE_SPY_STORY then  --密探
			hero:SetDigStatus(1)
		end
	else
		local isSendMsg = true
		if self._gcfg.nType == 1 then
			local id = self._gcfg.ID
			local festival = g_i3k_game_context:getFestivalLimitTask()
			for k, v in pairs(festival) do
				if v.curTask and v.curTask.state == 1 then
					local taskCfg = i3k_db_festival_task[v.curTask.groupId][v.curTask.index]
					if taskCfg.type == g_TASK_SCENE_MINE then
						local mineIndex = g_i3k_db.i3k_db_get_scene_mine_index(taskCfg.arg1, id)
						local data = g_i3k_game_context:getFestivalTaskValue(v.curTask.groupId, v.curTask.index)
						local havePlace = g_i3k_db.i3k_db_get_scene_mine_have_place(data.value, taskCfg.arg1, id)
						if mineIndex and not havePlace then
							isSendMsg = false
						end
					end
				end
			end
			local jubilee = g_i3k_game_context:GetJubileeStep2Task()
			if jubilee and jubilee.state == 1 then
				local taskCfg = g_i3k_db.i3k_db_get_jubilee_task_cfg(jubilee.id)
				if taskCfg.type == g_TASK_SCENE_MINE then
					local mineIndex = g_i3k_db.i3k_db_get_scene_mine_index(taskCfg.arg1, id)
					local havePlace = g_i3k_db.i3k_db_get_scene_mine_have_place(jubilee.value, taskCfg.arg1, id)
					if mineIndex and not havePlace then
						isSendMsg = false
					end
				end
			end
		end
		if isSendMsg then
			local hero = i3k_game_get_player_hero()
			if hero then
				hero:DigMineCancel()
			end
		else
			g_i3k_game_context:playPlayerStandAction()
			g_i3k_ui_mgr:CloseUI(eUIID_BattleProcessBar)
		end
	end
end

function i3k_entity_resourcepoint:breakCollectedAction( )
	if self._gcfg.collectedAction ~= "0.0" then
		self:Play(i3k_db_common.engine.defaultStandAction, -1)
	end
end

function i3k_entity_resourcepoint:playCollectedAction()
	if self._gcfg.collectedAction ~= "0.0" then
		self:Play(self._gcfg.collectedAction, 1)
	end
end

function i3k_entity_resourcepoint:playDestroyAction()
	if self._gcfg.destroyAction ~= "0.0" then
		self:Play(self._gcfg.destroyAction, -1)
	end
end

--添加挂载特效
function i3k_entity_resourcepoint:AddSpecialEffect(effectId)
	local world = i3k_game_get_world()
	if effectId ~= 0 then
		local ecfg = i3k_db_effects[effectId]
		self._resSpecialEffID = self._entity:LinkHosterChild(ecfg.path, string.format("entity_target_specail_%s", self._guid), ecfg.hs, "", 0.0, ecfg.radius * self._selEffScale);
	end
	if self._resSpecialEffID and self._resSpecialEffID > 0 then
		self._entity:LinkChildPlay(self._resSpecialEffID, -1, true);
	end
end

--清除挂载特效
function i3k_entity_resourcepoint:ClearSpecialEffect()
	if self._resSpecialEffID and self._resSpecialEffID > 0  then --removeEffect为1时取消怪物挂载特效
		self._entity:RmvHosterChild(self._resSpecialEffID);
		self._resSpecialEffID = nil;
	end
end

function i3k_entity_resourcepoint:Release()
	self:ClearSpecialEffect()
	BASE.Release(self);
	if self._titleCo then
		g_i3k_coroutine_mgr:StopCoroutine(self._titleCo)
		self._titleCo = nil
	end
	
end
function i3k_entity_resourcepoint:setResourcepointState(value, isFirst)
	self._state = value
	if value == 0 and self._gcfg.nType == 2 and i3k_game_get_map_type() == g_MAZE_BATTLE then
		if isFirst then
			local alist = {}
			table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadAction, actloopTimes = 1})
			table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadLoopAction, actloopTimes = -1})
			self:PlayActionList(alist, 1);
		else
			self:Play(i3k_db_common.engine.defaultDeadLoopAction, -1)
		end
	end
end
function i3k_entity_resourcepoint:getResourcepointState()
	return self._state
end
