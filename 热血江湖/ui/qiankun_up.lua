-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_qiankun_up = i3k_class("wnd_qiankun_up", ui.wnd_base)

local LAYER_QKSJT = "ui/widgets/qksjt"

function wnd_qiankun_up:ctor()
	self._id = 0
	self._needPoint = 0
	self._needItems = {}
end

function wnd_qiankun_up:configure( )
	local widgets = self._layout.vars
	
	self.nowDesc = widgets.nowDesc
	self.nextDesc = widgets.nextDesc
	self.needPoint = widgets.needPoint
	self.scroll = widgets.scroll
	widgets.upBtn:onClick(self, self.onUpBtn)
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_qiankun_up:refresh(id, lvl)
	self._id = id
	local nowCfg = i3k_db_experience_universe[id][lvl]
	local nextCfg = i3k_db_experience_universe[id][lvl+1]
	self.nowDesc:setText(self:getDesc(lvl, nowCfg.propertyId, nowCfg.propertyValue))
	self.nextDesc:setText(self:getDesc(lvl+1, nextCfg.propertyId, nextCfg.propertyValue))
	local canUsePoint = g_i3k_game_context:getCanUseQiankunPoint()
	self.needPoint:setText(i3k_get_string(922, nextCfg.needPoint))
	self.needPoint:setTextColor(g_i3k_get_cond_color(nextCfg.needPoint <= canUsePoint))
	self:initNeedItems(nextCfg)
	self:loadScroll()
end

function wnd_qiankun_up:initNeedItems(data)
	self._needItems = {}
	self._needPoint = data.needPoint
	for i, e in ipairs(data.rewards) do
		local count = data.rewardsNum[i]
		if e ~= 0 and count ~= 0 then
			table.insert(self._needItems, {itemID = e, itemCount = count})
		end
	end
end

function wnd_qiankun_up:loadScroll()
	self.scroll:removeAllChildren()
	for _, e in ipairs(self._needItems) do
		local widget = require(LAYER_QKSJT)()
		widget.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemID))
		widget.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID, g_i3k_game_context:IsFemaleRole()))
		widget.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.itemID))
		widget.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.itemID)))
		if math.abs(e.itemID) == g_BASE_ITEM_DIAMOND or math.abs(e.itemID) == g_BASE_ITEM_COIN then
			widget.vars.item_count:setText(e.itemCount)
		else
			widget.vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemID).."/"..e.itemCount)
		end
		widget.vars.item_count:setTextColor(g_i3k_get_cond_color(e.itemCount <= g_i3k_game_context:GetCommonItemCanUseCount(e.itemID)))
		widget.vars.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
		widget.vars.tip_btn:onClick(self, self.onItemTips, e.itemID)
		self.scroll:addItem(widget)
	end
end

function wnd_qiankun_up:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_qiankun_up:getDesc(lvl, propId, propValue)
	return string.format("%s级：%s%s", lvl, g_i3k_db.i3k_db_get_attribute_name(propId), i3k_get_prop_show(propId, propValue))
end

function wnd_qiankun_up:getIsCanUpLvl()
	local num = 0
	for _, e in ipairs(self._needItems) do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(e.itemID)
		if canUseCount >= e.itemCount then
			num = num + 1
		end
	end
	return num == #self._needItems
end

function wnd_qiankun_up:onUpBtn(sender)
	if g_i3k_game_context:getCanUseQiankunPoint() < self._needPoint then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(923))
		return
	end
	if self:getIsCanUpLvl() then
		i3k_sbean.dmgtransfer_lvlup(self._id, self._needItems, self._needPoint)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(924))
	end
end

function wnd_create(layout)
	local wnd = wnd_qiankun_up.new()
	wnd:create(layout)
	return wnd
end
