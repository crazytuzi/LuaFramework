-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/add_sub");

-------------------------------------------------------
wnd_national_add_oil = i3k_class("wnd_national_add_oil", ui.wnd_add_sub)

function wnd_national_add_oil:ctor()
	self._consumeID = 0
	self._consumeMax = 0
end

function wnd_national_add_oil:configure()
	local widgets = self._layout.vars

	widgets.cancel:onClick(self, self.cancelBtn)
	widgets.ok:onClick(self, self.sureBtn)

	self.desc = widgets.desc
	self.sale_count = widgets.sale_count

	self.add_btn = widgets.jia_btn
	self.sub_btn = widgets.jian_btn
	self.max_btn = widgets.max_btn
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self, self.onSub)
	self.max_btn:onTouchEvent(self, self.onMax)
end

function wnd_national_add_oil:refresh(dayOilTimes)
	self.desc:setText(i3k_get_string(16377))

	self._consumeID = i3k_db_national_activity_cfg.consume_item  		--道具ID
	self._consumeMax = i3k_db_national_activity_cfg.maxTimes - dayOilTimes 	--最大可使用数量

	local have_count = g_i3k_game_context:GetCommonItemCanUseCount(self._consumeID)
	self.current_add_num = have_count < self._consumeMax and have_count or self._consumeMax
	self.cheerTimes = g_i3k_game_context:getNationalCheerTimes()

	self:updateFun()
	self:setNumCount(self.current_num)
end

function wnd_national_add_oil:setNumCount(count)
	self.sale_count:setText(count)
end

function wnd_national_add_oil:updateFun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_NationalAddOil, "setNumCount", self.current_num)
	end
end

function wnd_national_add_oil:sureBtn(sender)
	local residueTimes = i3k_db_national_activity_cfg.maxTimes - self.cheerTimes
	if residueTimes < self.current_num then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18556))
		return
	elseif self.current_add_num <= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16378))
		return
	end
	local callback = function()
		local isDownFlag = false
		local isUpFlag = true
		i3k_sbean.sync_national_activity(isDownFlag, isUpFlag)
		g_i3k_ui_mgr:CloseUI(eUIID_NationalAddOil)
	end
	i3k_sbean.role_add_oil(self.current_num, self._consumeID, callback)
end

function wnd_national_add_oil:cancelBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_NationalAddOil)
end

function wnd_create(layout, ...)
	local wnd = wnd_national_add_oil.new();
		wnd:create(layout, ...);
	return wnd;
end
