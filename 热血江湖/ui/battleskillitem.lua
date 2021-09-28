module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleSkillItem = i3k_class("wnd_battleSkillItem", ui.wnd_base)

local SKILLITEM = "ui/widgets/jndjt"

function wnd_battleSkillItem:ctor()

end

function wnd_battleSkillItem:configure()
	self._layout.vars.closeThisBtn:onClick(self, self.onClose)
	self.scroll = self._layout.vars.itemScroll
end

function wnd_battleSkillItem:refresh()
	self:addWidgets()
end

function wnd_battleSkillItem:onShow()

end

function wnd_battleSkillItem:onUpdate(dTime)
	self:updateCDTime(dTime)
end

function wnd_battleSkillItem:updateCDTime(dTime)
	local items = self.scroll:getAllChildren()
	if items and next(items) then
		for k,v in pairs(items) do
			local widget = v.vars.itemCD
			local hero = i3k_game_get_player_hero()
			local totalTime, cdTime = hero:GetItemSkillCoolLeftTime(v.itemId)
			local percent = cdTime == 0 and 0 or (1-(cdTime / totalTime)) * 100
			widget:setPercent(percent)
		end
	end
end

function wnd_battleSkillItem:addWidgets()
	self.scroll:removeAllChildren()
	local items =  g_i3k_game_context:getSkillItems()
	if not next(items) then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "checkShowSkillItem")
		g_i3k_ui_mgr:CloseUI(eUIID_BattleSkillItem)
		return ;
	end
	local count = 0
	local itemHeight = nil
	local itemsList = {}
	for k ,v in pairs(items) do
		local item = self:constructWidget(v.id, v.count)
		item.sortId = g_i3k_db.i3k_db_get_bag_item_order(v.id)
		if g_i3k_game_context:GetLevel() >= g_i3k_db.i3k_db_get_common_item_level_require(v.id) then
			table.insert(itemsList, item)
			itemHeight = item.rootVar:getSize()
			count = count + 1
		end
	end
	table.sort(itemsList,function (a,b)
		return a.sortId < b.sortId
	end)
	local scrollSize = self.scroll:getContentSize()
	local bgSize = self._layout.vars.bg:getSize()
	count = count > 5 and 5 or count
	self._layout.vars.bg:setContentSize(itemHeight.width* count, bgSize.height)
	self.scroll:setContainerSize(itemHeight.width* count, itemHeight.height)
	self.scroll:setContentSize(itemHeight.width* count, itemHeight.height)

	for k ,v in ipairs(itemsList) do
		self.scroll:addItem(v)
	end
end


function wnd_battleSkillItem:constructWidget(id, count)
	local item = g_i3k_db.i3k_db_get_other_item_cfg(id)
	if item == nil then
		return nil;
	end
	if item.type ~= UseItemSkill then --25
		return nil;
	end
	local widget = require(SKILLITEM)()
	if id < 0 then
		widget.vars.lockImg:hide()
	end
	widget.vars.iconBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(item.icon))
	widget.vars.itemName:setText(item.name)
	widget.vars.itemCount:setText(count)
	widget.vars.itemCD:setPercent(10)
	widget.vars.onClickBtn:onClick(self, self.onSkillItemClick, id)
	--local item_rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	--widget.vars.itemName:setTextColor(g_i3k_get_color_by_rank(item_rank))
	widget.itemId = id
	return widget;
end


function wnd_battleSkillItem:onSkillItemClick(sender, id)
	if g_i3k_game_context:GetLevel() < g_i3k_db.i3k_db_get_common_item_level_require(id) then
		g_i3k_ui_mgr:PopupTipMessage("未达到使用等级")
	else
		local hero = i3k_game_get_player_hero()
		hero:CreateItemSkill(id)
		local status = hero:UseSkillWithItem(id)
	end
end

function wnd_battleSkillItem:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_BattleSkillItem)
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleSkillItem.new();
		wnd:create(layout);
	return wnd;
end
