-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");

-------------------------------------------------------
wnd_gemExchangeOperate = i3k_class("wnd_gemExchangeOperate", ui.wnd_base)

local WIDGET = "ui/widgets/baoshizht"

function wnd_gemExchangeOperate:ctor()
	self._id = 0
	self._targetId = 0
	self._cost = nil
	self._isUp = nil
	self._costFalg = false
end

function wnd_gemExchangeOperate:configure()
	local widget = self._layout.vars
	widget.close_btn:onClick(self, self.onCloseUI)
	widget.exchange_btn:onClick(self, self.onExchangeBt)
end

function wnd_gemExchangeOperate:refresh(value)
	self._id = value.falg and value.gemId or - value.gemId
	local newId = value.gemId
	local cfg = g_i3k_db.i3k_db_get_gem_exchange_cfg(newId)
	local widget = self._layout.vars
	local fun = function(wid, funId)
		wid.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(funId, g_i3k_game_context:IsFemaleRole()))
		wid.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(funId))		
		wid.item_count:setText(1)
	end
	
	widget.suo:setVisible(self._id > 0)
	widget.item_btn:onClick(self, self.onClickItem, newId)
	fun(widget, newId)

	self._cost = cfg.costs
	self:refreshConsume()
	widget.itemScroll:removeAllChildren()	
	
	for _, v in ipairs(cfg.targetId) do
		local wid =  require(WIDGET)()
		local vas = wid.vars
		fun(vas, v)
		vas.bt:onClick(self, self.onSelectItem, {id = v, widget = vas.isUp})
		vas.isUp:setVisible(false)
		vas.name:setText(g_i3k_db.i3k_db_get_common_item_name(v))
		local item_rank = g_i3k_db.i3k_db_get_common_item_rank(v)
		vas.name:setTextColor(g_i3k_get_color_by_rank(item_rank))
		widget.itemScroll:addItem(wid)
	end
end

function wnd_gemExchangeOperate:refreshConsume()
	local widget = self._layout.vars
	local comsumecfg = self._cost[1]	
	widget.consumeIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(comsumecfg.id, g_i3k_game_context:IsFemaleRole()))
	widget.consumeBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(comsumecfg.id))
	local hascount = g_i3k_game_context:GetCommonItemCanUseCount(comsumecfg.id)
	self._costFalg = comsumecfg.count <= hascount
	widget.coin_cost:setTextColor(g_i3k_get_cond_color(self._costFalg))
	widget.coin_cost:setText(hascount .. "/" .. comsumecfg.count)
	widget.consumeBt:onClick(self, self.onClickItem, comsumecfg.id)
	widget.consumeLock:setVisible(comsumecfg.id > 0)
end

function wnd_gemExchangeOperate:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_gemExchangeOperate:onSelectItem(sender, value)
	if self._targetId == value.id then
		return 
	end
	
	if self._isUp then
		self._isUp:setVisible(false)
	end
	
	value.widget:setVisible(true)
	self._isUp = value.widget
	self._targetId = value.id
end

function wnd_gemExchangeOperate:onExchangeBt()
	if self._targetId == 0 then 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18074))
		return
	end
	
	if not self._costFalg then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18073))
		return
	end
	
	local callfunc = function (isOk)
		if isOk then
			i3k_sbean.gem_exchange(self._id, self._targetId, self._cost)
			self:onCloseUI()
		end
	end
	
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18075, g_i3k_db.i3k_db_get_common_item_name(self._id), g_i3k_db.i3k_db_get_common_item_name(self._targetId)), callfunc)
end

function wnd_create(layout, ...)
	local wnd = wnd_gemExchangeOperate.new()
	wnd:create(layout, ...)
	return wnd
end