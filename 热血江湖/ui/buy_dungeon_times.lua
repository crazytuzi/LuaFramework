-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/add_sub");
require("i3k_global")

-------------------------------------------------------

wnd_buy_dungeon_times = i3k_class("wnd_buy_dungeon_times",ui.wnd_add_sub)

function wnd_buy_dungeon_times:ctor()
	self.name = ""
	self.dayBuyTimes = 0
	self.needDiamond = 0
	self.mapType = 1 --两种副本配置不同，1表示主线副本，2表示试炼副本
end

function wnd_buy_dungeon_times:configure()
	local widgets = self._layout.vars
	self.times_desc = widgets.times_desc
	self.detaile_desc = widgets.detaile_desc
	widgets.cancel:onClick(self, self.cancelBtn)
	self.ok = widgets.ok
	self.add_btn = widgets.jia_btn
	self.sub_btn = widgets.jian_btn
	self.max_btn = widgets.max_btn
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self, self.onSub)
	self.max_btn:onTouchEvent(self, self.onMax)
	self.sale_count = widgets.sale_count
end

function wnd_buy_dungeon_times:refresh(data)
	local times = 0
	self.mapType = data.mapType
	if self.mapType == 1 then
		times = g_i3k_game_context:GetNormalMapDayBuyTimes(data.mapId)
		self.name = i3k_db_new_dungeon[data.mapId].name
		self.needDiamond = i3k_db_common.wipe.needDiamond[times + 1]
	else
		times = g_i3k_game_context:getActDayBuyTimes(data.mapId)
		self.name = i3k_db_activity[data.mapId].name
		self.needDiamond = i3k_db_common.activity.buyTimesNeedDiamond[times + 1]
	end
	self.dayBuyTimes = times
	self.current_add_num = data.buyTimes - self.dayBuyTimes
	self.times_desc:setText(i3k_get_string(266, data.vipLevel, data.buyTimes))
	self.detaile_desc:setText(i3k_get_string(267, i3k_get_diamond_desc(self.needDiamond), self.current_num, self.name))
	self.sale_count:setText(self.current_num.."/"..self.current_add_num)
	self.ok:onClick(self, self.sureBtn, data.mapId)
	self:updatefunc()
end

function wnd_buy_dungeon_times:sureBtn(sender, mapId)
	local needDiamond = self.needDiamond
	if g_i3k_game_context:GetDiamondCanUse(false) < needDiamond then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(216))
	else
		if self.mapType == 1 then
			local callback = function()
				g_i3k_game_context:UseDiamond(needDiamond, false, AT_BUY_NORMAL_MAPCOPY_TIMES)
			end
			i3k_sbean.normalmap_buytimes(mapId, self.current_num, callback)
		else
			local callback = function ()
				g_i3k_game_context:UseDiamond(needDiamond, false, AT_BUY_ACTIVITY_MAPCOPY_TIMES)
				g_i3k_ui_mgr:CloseUI(eUIID_BuyDungeonTimes)
			end
			i3k_sbean.buy_act_times(mapId, self.current_num, callback)
		end
	end
end

function wnd_buy_dungeon_times:cancelBtn(sender)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "resetActivityPercent")
	g_i3k_ui_mgr:CloseUI(eUIID_BuyDungeonTimes)
end

function wnd_buy_dungeon_times:updatefunc()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BuyDungeonTimes, "updateBuyInfo")
	end
end

function wnd_buy_dungeon_times:updateBuyInfo()
	self.needDiamond = 0
	if self.mapType == 1 then
		for k = 1, self.current_num do
			self.needDiamond = self.needDiamond + i3k_db_common.wipe.needDiamond[self.dayBuyTimes + k]
		end
	else
		for k = 1, self.current_num do
			self.needDiamond = self.needDiamond + i3k_db_common.activity.buyTimesNeedDiamond[self.dayBuyTimes + k]
		end
	end
	self.sale_count:setText(self.current_num.."/"..self.current_add_num)
	self.detaile_desc:setText(i3k_get_string(267, i3k_get_diamond_desc(self.needDiamond), self.current_num, self.name))
end

function wnd_create(layout)
	local wnd = wnd_buy_dungeon_times.new()
		wnd:create(layout)
	return wnd
end
