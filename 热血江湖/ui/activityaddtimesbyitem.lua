------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_activity_add_times_by_item = i3k_class("wnd_activity_add_times_by_item",ui.wnd_base)

function wnd_activity_add_times_by_item:ctor()
	local cfg = g_i3k_db.i3k_db_get_activity_add_times_cfg()
	assert(cfg, "没有配置可以增加试炼次数的道具")
	self.itemId = cfg.id
	self.cfg = cfg
end

function wnd_activity_add_times_by_item:configure()
	local widget = self._layout.vars
	widget.cancel:onClick(self,self.onCloseUI)
	widget.ok:onClick(self, self.onOk)
	widget.jia_btn:onClick(self, self.onCalculate, 1)
	widget.jian_btn:onClick(self, self.onCalculate, -1)
	widget.max_btn:onClick(self, self.onCalculate, math.huge)
	widget.desc:setText(i3k_get_string(18698))
	self._curSel = 1
	self:onCalculate(nil, 0)
end

function wnd_activity_add_times_by_item:onCalculate(sender, num)
	local count = g_i3k_game_context:GetCommonItemCanUseCount(self.itemId)
	local use = g_i3k_game_context:getActDayItemAddTimes()
	local vip = g_i3k_game_context:GetVipLevel() + 1
	local vipMaxBuyTimes = self.cfg.vipDayBuyTimes[vip]
	local leftCanUse = vipMaxBuyTimes - use
	count = math.min(count, leftCanUse)
	self._curSel = self._curSel + num
	self._curSel = math.max(0, math.min(count, self._curSel))
	self._layout.vars.count:setText(self._curSel)
	self._layout.vars.leftTime:setText(i3k_get_string(15594, leftCanUse))
	self._layout.vars.leftTime:setTextColor(g_i3k_get_cond_color(leftCanUse ~= 0))
end

function wnd_activity_add_times_by_item:onOk(sender)
	if self._curSel ~= 0  then
		if not g_i3k_db.i3k_db_check_now_activity_is_open() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18708))
			return
		else
			i3k_sbean.bag_useitem_add_activity_map_cnt(self.itemId, self._curSel)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("数量不能为0")
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_activity_add_times_by_item.new()
	wnd:create(layout,...)
	return wnd
end
