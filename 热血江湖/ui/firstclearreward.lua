module(..., package.seeall)

local require = require

local ui = require("ui/base")

wnd_firstClearReward = i3k_class("wnd_firstClearReward", ui.wnd_base)

local MAIN_ITEM = 1

function wnd_firstClearReward:ctor()
end

function wnd_firstClearReward:configure()
	local widget = self._layout.vars
	self.desc = widget.desc
	self.equip_icon = widget.equip_icon
	self.equip_rank = widget.equip_rank
	self.equip_cnt = widget.equip_cnt
	self.equip_name = widget.equip_name
	self.equip_btn = widget.equip_btn
	self.reward_btn = widget.reward_btn
	self.close_btn = widget.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
end

function wnd_firstClearReward:refresh(id)
	local cfg = i3k_db_first_clear_reward.RewardConfig[id]
	self.desc:setText(i3k_get_string(cfg.stringID))
	local bwType = g_i3k_game_context:GetTransformBWtype()
	local roleType = g_i3k_game_context:GetRoleType()
	local gender = g_i3k_game_context:GetRoleGender()
	local equipID = cfg.specialReward[bwType][roleType]
	self.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, gender == eGENDER_FEMALE))
	self.equip_rank:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
	self.equip_cnt:setText("x" .. 1)
	self.equip_name:setText(g_i3k_db.i3k_db_get_common_item_name(equipID))
	self.equip_btn:onClick(self, self.onEquipBtnClick, equipID)
	local widget = self._layout.vars
	local index = 1
	for k, v in ipairs(cfg.normalReward) do
		widget["item_btn" .. index]:onClick(self, self.onItemBtnClick, v.id)
		widget["item_icon" .. index]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, i3k_game_context:IsFemaleRole()))
		widget["item_rank" .. index]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		widget["item_count" .. index]:setText("x" .. v.count)
		index = index + 1
	end
	local info = g_i3k_game_context:getFirstClearInfo(id)
	if not (info and info.enter and not info.reward) then
		self.reward_btn:disableWithChildren()
	end
	self.reward_btn:onClick(self, self.onRewardBtnClick, id)
end

function wnd_firstClearReward:onEquipBtnClick(sender, equipID)
	g_i3k_ui_mgr:OpenAndRefresh(eUIID_ShowEquipTips, equipID)
end

function wnd_firstClearReward:onItemBtnClick(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_firstClearReward:onRewardBtnClick(sender, id)
	local info = g_i3k_game_context:getFirstClearInfo(id)
	local cfg = i3k_db_first_clear_reward.RewardConfig[id]
	local bwType = g_i3k_game_context:GetTransformBWtype()
	local roleType = g_i3k_game_context:GetRoleType()
	local items = i3k_clone(cfg.normalReward)
	local specialItemID = cfg.specialReward[bwType][roleType]
	table.insert(items, 1, {['id'] = specialItemID, ['count'] = 1})
	local itemData = {}
	for k, v in ipairs(items) do
		itemData[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(itemData)
	if info and info.enter and not info.reward and isEnough then
		i3k_sbean.getFinishReward(id, items)
	elseif not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_firstClearReward.new()
	wnd:create(layout)
	return wnd
end