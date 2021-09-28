-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_activityShow = i3k_class("wnd_activityShow", ui.wnd_base)

function wnd_activityShow:ctor()
	self._list = {}
	self._isAuto = false
end

function wnd_activityShow:configure()
	local widgets = self._layout.vars
	widgets.okBtn:onClick(self, self.onOkBtn)
	
	widgets.shareBtn:onClick(self, self.onShare)
end

function wnd_activityShow:showActivity(isAuto)
	self._list = g_i3k_db.i3k_db_get_activity_show_list()
	table.sort(self._list, function(a, b)
		local cfg = i3k_db_activity_show
		return cfg[a].order < cfg[b].order
	end)
	self:jumpToNextActivity(isAuto)
end

function wnd_activityShow:refresh()

end

-- 维护一个队列
function wnd_activityShow:jumpToNextActivity(isAuto)
	self._isAuto = isAuto
	if #self._list <= 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_ActivityShow)
		return
	else
		local id = self._list[#self._list]
		local cfg = i3k_db_activity_show[id]
		local userCfg = g_i3k_game_context:GetUserCfg()
		local activityShowTimes = userCfg:GetActivityShowTimes(g_i3k_game_context:GetRoleId(), id)
		table.remove(self._list, #self._list)
		if self._isAuto and cfg.isLimit ~= -1 and cfg.isLimit > activityShowTimes then
			userCfg:AddActivityShowTimes(g_i3k_game_context:GetRoleId(), id)
		elseif self._isAuto and cfg.isLimit ~= -1 and cfg.isLimit <= activityShowTimes then
			self:jumpToNextActivity(self._isAuto)
			return
		end
		if cfg.isShare == 0 then
			self._layout.vars.shareBtn:setVisible(false)
		end
		self:setTitle(cfg.name)
		self:setDesc(cfg.desc)
		local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai
		if anis then
			anis.stop()
			anis.play()
		end
	end
end


function wnd_activityShow:setTitle(text)
	local widgets = self._layout.vars
	widgets.title:setText(text)
end

function wnd_activityShow:setDesc(text)
	local widgets = self._layout.vars
	widgets.desc:setText(text)
end

function wnd_activityShow:onOkBtn(sender)
	-- TODO 遍历一个返回的队列，每次点击按钮，删除掉一个，然后再添加一个，直到队列为空
	if self._isAuto then
		self:jumpToNextActivity(self._isAuto)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_ActivityShow)
	end
end

function wnd_activityShow:onShare(sender)
	if i3k_game_get_os_type() == eOS_TYPE_IOS then
		g_i3k_game_handler:ShareTaskID(i3k_db_common.shareIosSdkId)
	elseif i3k_game_get_os_type() == eOS_TYPE_OTHER then
		g_i3k_game_handler:ShareTaskID(i3k_db_common.shareAndroidSdkId)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_activityShow.new()
	wnd:create(layout, ...)
	return wnd;
end
