-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_wujueUseItems = i3k_class("wnd_wujueUseItems", ui.wnd_base)

-- 武诀一键使用道具
-- [eUIID_WujueUseItems]	= {name = "wujueUseItems", layout = "wujueyjsy", order = eUIO_TOP_MOST,},
-------------------------------------------------------
local USE_ITEM_TIME_INTERVAL = 0.2 --长按道具使用间隔

function wnd_wujueUseItems:ctor()
	self._pressTime = 0
	self._isPress = false
	self._waiting = false
end

function wnd_wujueUseItems:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.Ok:onClick(self, self.onOkBtn)
	self.wujueItems = {}
	for k, v in pairs(i3k_db_new_item) do
		if v.type == UseItemWuJueExp then
			table.insert(self.wujueItems, k)
		end
	end
end

function wnd_wujueUseItems:refresh()
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	self._countWidgets = {}
	for k, v in ipairs(self.wujueItems) do
		local ui = require("ui/widgets/wujueyjsyt")()
		ui.vars.cover:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v,i3k_game_context:IsFemaleRole()))
		ui.vars.lock:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v))
		ui.vars.count:setText("x"..g_i3k_game_context:GetCommonItemCanUseCount(v))
		ui.vars.Item:setTag(v)
		ui.vars.Item:onTouchEvent(self, self.onItemTouchEvent)
		ui.vars.value:setText(g_i3k_db.i3k_db_get_other_item_cfg(v).args1)
		self._countWidgets[v] = ui.vars.count
		scroll:addItem(ui)
	end
end

function wnd_wujueUseItems:onOkBtn(sender)
	g_i3k_db.i3k_db_wujue_on_key_use_item()
end

function wnd_wujueUseItems:RefreshLeftCounts()
	for k, v in pairs(self._countWidgets) do
		v:setText("x"..g_i3k_game_context:GetCommonItemCanUseCount(k))
	end
end

function wnd_wujueUseItems:onItemTouchEvent(sender, eventType)
	local itemID = sender:getTag()
	if g_i3k_game_context:GetCommonItemCanUseCount(itemID) == 0 then
		if eventType == ccui.TouchEventType.ended then
			g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
		end
		return
	end
	if not g_i3k_db.i3k_db_wujue_can_get_exp() then
		if eventType == ccui.TouchEventType.began then
			g_i3k_ui_mgr:PopupTipMessage("武诀等级已达上限，无法继续使用")
		end
		return
	end
	if eventType == ccui.TouchEventType.began then
		self._curId = itemID
		self._isPress = true
		self._pressTime = USE_ITEM_TIME_INTERVAL
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self._isPress = false
		self._curId = nil
	end
end

function wnd_wujueUseItems:onUpdate(dTime)
	if not self._waiting then
		if self._isPress then
			self._pressTime = self._pressTime + dTime
			if self._pressTime > USE_ITEM_TIME_INTERVAL and self._curId and g_i3k_game_context:GetCommonItemCanUseCount(self._curId) > 0 then
				if not g_i3k_db.i3k_db_wujue_can_get_exp() then
					self._isPress = false
				else
					i3k_sbean.useWujueExpItems({[self._curId] = 1})
					self:setIsWaitingProtocol(true)
					self._pressTime = 0
				end
			end
		else
			self._pressTime = 0
		end
	end
end

function wnd_wujueUseItems:setIsWaitingProtocol(state)
	self._waiting = state
end
----------------------------------------------
function wnd_create(layout, ...)
	local wnd = wnd_wujueUseItems.new()
	wnd:create(layout, ...)
	return wnd;
end
