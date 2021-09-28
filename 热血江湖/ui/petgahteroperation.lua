module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_petGahterOperation = i3k_class("wnd_petGahterOperation", ui.wnd_base)

local SKILLITEM = "ui/widgets/chongwushiliancjt1"
local REWARDITEM = "ui/widgets/chongwushiliancjt2"

function wnd_petGahterOperation:ctor()
	self._cfg = nil
	self._count = 0
	self._flag = 0
end

function wnd_petGahterOperation:configure()
	local weight = self._layout.vars
	weight.close:onClick(self, self.onCloseUI)
	weight.get_five_btn:onClick(self, self.ongatherFiveBt)
	weight.gatherBt:onClick(self, self.ongatherBt)	
	weight.forceBt:onClick(self, self.ongatherForceBt)
	weight.gotobt:onClick(self, self.onGotoBt)
end

function wnd_petGahterOperation:refresh(cfg, isGoto)
	self._cfg = cfg
	self:refreshSkillScoll(cfg)
	self:refreshRewardScoll(cfg)
	self._layout.vars.exp:setText(i3k_get_string(1508, cfg.exp))
	self:refreshButtonState(isGoto, cfg)
	self:refreshGatherCountText(cfg)
end

function wnd_petGahterOperation:refreshSkillScoll(cfg)
	local scoll = self._layout.vars.scoll	
	scoll:removeAllChildren()

	for _, v in ipairs(cfg.skills) do
		if v.skillID ~= 0 then
			local id = v.skillID
			local ui = require(SKILLITEM)()
			local skillCfg = i3k_db_pet_skill[id]
			--算宠物装备 算幸运事件)(不算强制) 和各个技能的和 
			local level = g_i3k_game_context:getPetDungeonSkillLevel(id, true, true)
			local weight = ui.vars
			weight.name:setText(skillCfg.name)
			weight.des:setText(i3k_get_string(1509, level, v.skillLevel))
			weight.icon:setImage(i3k_db_icons[skillCfg.icon].path)
			weight.des:setTextColor(g_i3k_get_cond_color(level >= v.skillLevel))
			scoll:addItem(ui)
		end
	end
end

function wnd_petGahterOperation:refreshRewardScoll(cfg)
	local scoll = self._layout.vars.reward
	scoll:removeAllChildren()
	
	for _, v in ipairs(cfg.rewards) do
		local ui = require(REWARDITEM)()
		local weight = ui.vars
		weight.count:hide()
		weight.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v))
		weight.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
		weight.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(v))
		weight.bt:onClick(self, self.onItemTip, v)
		scoll:addItem(ui)
	end
end

function wnd_petGahterOperation:refreshButtonState(isGoto, cfg)
	local weight = self._layout.vars
	
	if isGoto then
		weight.get_five_btn:hide()
		weight.gatherBt:hide()		
		weight.forceBt:hide()
		weight.remain:hide()
		weight.gotobt:show()
	else
		--算宠物装备 算幸运事件)(不算强制) 和各个技能的和
		self._flag  = g_i3k_game_context:getPetDungeonGatherState(cfg.id)--0 不可采集 1 可采集 2 强制采集
		
		if self._flag  == 2 then
			weight.forceBt:show()
			weight.remain:show()
			weight.gatherBt:hide()
			weight.get_five_btn:hide()
			weight.gotobt:hide()
			weight.remain:setText(i3k_get_string(1510, g_i3k_game_context:getPetDungeonBuffs(g_FORCEGATHER)))
		else
			weight.forceBt:hide()
			weight.remain:hide()
			weight.gotobt:hide()
			weight.gatherBt:show()
			weight.get_five_btn:show()
		end
	end
end

function wnd_petGahterOperation:refreshGatherCountText(cfg)
	local weight = self._layout.vars
	local remainCount = i3k_db_PetDungeonBase.gatherAllCount - g_i3k_game_context:getPetDungeonGatherCount()
	
	if self._flag ~= 1 then -- 不可采集
		self._count = remainCount
	else
		local flag, count = g_i3k_game_context:petDungeonGatherisNeedBuffs(cfg.id) --可采集状态下需要的buff数
		
		if flag then
			self._count = count
		else
			self._count = i3k_db_PetDungeonBase.gatherOneTimeCount
		end
		
		self._count = self._count > remainCount and remainCount or self._count
	end
	
	self._count = i3k_db_PetDungeonBase.gatherOneTimeCount >= self._count and self._count or i3k_db_PetDungeonBase.gatherOneTimeCount	
	weight.goLabel2:setText(i3k_get_string(1511, self._count))
end

function wnd_petGahterOperation:onGotoBt()
	local pos = g_i3k_db.i3k_db_get_res_pos(self._cfg.mineId)
	local mapId = g_i3k_game_context:GetWorldMapID()
	local tbl = {flage = 2, mapId = mapId, areaId = self._cfg.mineId}
	g_i3k_game_context:SeachPathWithMap(mapId, pos, nil,nil, tbl, nil, nil, nil)	
	g_i3k_ui_mgr:CloseUI(eUIID_PetDungeonGatherDetail)
	self:onCloseUI()
end
 
function wnd_petGahterOperation:ongatherBt(sender)
	if self:checkCondition() then
		return
	end
	
	self:sendMessage(1, 0)
end

function wnd_petGahterOperation:ongatherFiveBt(sender)
	if self:checkCondition() then
		return
	end
	
	self:sendMessage(self._count, 0)
end

function wnd_petGahterOperation:ongatherForceBt(sender)
	self:sendMessage(1, 1)
end

function wnd_petGahterOperation:onItemTip(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_petGahterOperation:checkCondition()
	local flag = false
	
	if self._flag ~= 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1512))
		flag = true
	elseif g_i3k_game_context:getPetDungeonGatherCount() >= i3k_db_PetDungeonBase.gatherAllCount then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1513, i3k_db_PetDungeonBase.gatherAllCount))
		flag = true
	end
	
	return flag
end

function wnd_petGahterOperation:sendMessage(count, isForce)
	local mapId = g_i3k_game_context:GetWorldMapID()
	local pos = i3k_db_res_map[self._cfg.mineId].resPosId
	g_i3k_logic:OpenPetDungeonReadingBarUI(self._cfg, {mineralId = self._cfg.id, time = count, mapId = mapId, mineralPosition = pos, ignoreCondition = isForce})
	self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_petGahterOperation.new();
	wnd:create(layout);
	return wnd;
end
