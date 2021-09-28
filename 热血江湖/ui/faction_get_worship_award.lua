-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_get_worship_award = i3k_class("wnd_faction_get_worship_award", ui.wnd_base)

function wnd_faction_get_worship_award:ctor()
	self._times = 0
	self._value = 0
end

function wnd_faction_get_worship_award:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local get_award = self._layout.vars.get_award
	get_award:onTouchEvent(self,self.onGetAward)
	self.count = self._layout.vars.count
	self.value = self._layout.vars.value
end

function wnd_faction_get_worship_award:onShow()

end

function wnd_faction_get_worship_award:refresh(Times,reward)
	self._times = Times
	self._value = reward
	local my_data = g_i3k_game_context:GetRoleInfo()
	local my_vipLvl = my_data.curChar._viplvl
	self:setData(my_vipLvl)
end

function wnd_faction_get_worship_award:getCountByVipLevel(vipLvl)
	local max = 0
	for k,v in ipairs(i3k_db_faction_worship) do
		if vipLvl >= v.vipOpen then
			if max < k then
				max = k
			end
		end
	end
	return i3k_db_faction_worship[max].vipByCount
end

function wnd_faction_get_worship_award:setData(my_vipLvl)
	local max_count = self:getCountByVipLevel(my_vipLvl)

	local colour

	if self._times == max_count then
		colour = g_i3k_get_cond_color(false)
	else
		colour = g_i3k_get_cond_color(true)
	end
	local last_times = max_count-self._times
	if last_times < 0 then
		last_times = 0
	end

	desc = g_i3k_make_color_string(last_times,colour)
	self.count:setText(desc)
	self.value:setText(self._value)
end

function wnd_faction_get_worship_award:onGetAward(sender,eventType)
	if eventType == ccui.TouchEventType.ended then

		if self._value == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10069))
			return
		end
		local data = i3k_sbean.sect_takeworshipreward_req.new()
		data.value = self._value
		i3k_game_send_str_cmd(data,i3k_sbean.sect_takeworshipreward_res.getName())
	end
end

--[[function wnd_faction_get_worship_award:onClose(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionGetWorshipAward)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_get_worship_award.new();
		wnd:create(layout, ...);

	return wnd;
end
