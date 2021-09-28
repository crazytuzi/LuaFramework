-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/add_sub");

-------------------------------------------------------
wnd_longyinSpeedup = i3k_class("wnd_longyinSpeedup", ui.wnd_add_sub)

function wnd_longyinSpeedup:ctor()

end

function wnd_longyinSpeedup:configure()
	local widgets = self._layout.vars
	widgets.cancelBtn:onClick(self, self.onCloseUI)
	widgets.speedUpBtn:onClick(self, self.onSpeedUpBtn)
	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian
	self.max_btn = widgets.max
	self.count = widgets.count
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self, self.onMax)
	local needItemID = i3k_db_LongYin_arg.hunyuWenyang.needItemID
	self.current_add_num = self:getCanUseMaxCount()

	self.current_num = 1	--当前实际的数值


	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_longyinSpeedup,"setCount",self.current_num)
	end
	self:setItemUI()
end

function wnd_longyinSpeedup:setItemUI()
	local needItemID = i3k_db_LongYin_arg.hunyuWenyang.needItemID
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(needItemID)
	local cfg = g_i3k_db.i3k_db_get_common_item_cfg(needItemID)
	local widgets = self._layout.vars
	widgets.lock:setVisible(needItemID > 0)
	widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needItemID))
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needItemID, i3k_game_context:IsFemaleRole()))
	widgets.item_name:setText(cfg.name)
	widgets.item_desc:setText(cfg.desc)
	widgets.item_type:setText(haveCount)
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(needItemID)
	widgets.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))

	widgets.iconBtn:onClick(self, self.onTip, needItemID)
	self:setCount(self.current_num)
end
function wnd_longyinSpeedup:onTip(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_longyinSpeedup:setCount(count)
	self._layout.vars.count:setText(count)
	local deltTime = count * i3k_db_LongYin_arg.hunyuWenyang.time
	local hour = math.modf(deltTime/3600)
	local minute = math.modf(deltTime%3600/60)
	self._layout.vars.timeLabel:setText("加速时长："..hour.."小时"..minute.."分钟")
	local needItemID = i3k_db_LongYin_arg.hunyuWenyang.needItemID
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(needItemID)
	if haveCount < count then
		self._layout.vars.count:setTextColor(g_i3k_get_cond_color(false))
	end
end

function wnd_longyinSpeedup:onSpeedUpBtn(sender)
	local itemNum = tonumber(self._layout.vars.count:getText())
	local needItemID = i3k_db_LongYin_arg.hunyuWenyang.needItemID
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(needItemID)
	if self.current_num > haveCount then
		g_i3k_ui_mgr:PopupTipMessage("道具数量不足")
		return
	end
	i3k_sbean.seal_awaken_accelerate(itemNum)
end

function wnd_longyinSpeedup:getCanUseMaxCount()
	local needItemID = i3k_db_LongYin_arg.hunyuWenyang.needItemID
	local bagItemCount =  g_i3k_game_context:GetCommonItemCanUseCount(needItemID)
	local info = g_i3k_game_context:getRoleSealAwaken()
	local allAwakenTime = info.allAwakenTime
	local maxUseCount = 0
	if allAwakenTime > 0 then
		local nowTime = i3k_game_get_time()
		local cfg = g_i3k_db.i3k_db_get_longyin_ban(info.rank)
		local targetTime = allAwakenTime + cfg.allUnlockTime
		local deltTime = targetTime - nowTime
		if deltTime > 0 then
			maxUseCount = math.ceil(deltTime / i3k_db_LongYin_arg.hunyuWenyang.time)
		end
	end
	return maxUseCount > bagItemCount and bagItemCount or maxUseCount
end

function wnd_create(layout, ...)
	local wnd = wnd_longyinSpeedup.new()
		wnd:create(layout, ...)
	return wnd
end
