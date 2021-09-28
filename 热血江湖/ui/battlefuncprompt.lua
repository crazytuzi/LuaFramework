module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battlefuncPrompt = i3k_class("wnd_battlefuncPrompt", ui.wnd_base)

function wnd_battlefuncPrompt:ctor()

end

function wnd_battlefuncPrompt:configure()
	local widgets = self._layout.vars
	local closeBtn = widgets.okBtn
	closeBtn:onClick(self,self.onCloseUI)
	self._cfg = nil
	self._clickCloseBtnFlag = false
end

function wnd_battlefuncPrompt:refresh(id)
	self:InitUI(id)
end

function wnd_battlefuncPrompt:InitUI(id)
	local info = i3k_db_function_open_cfg[id]
	self._cfg = info
	local widgets = self._layout.vars
--	widgets.descLabel
	widgets.percentLabel:setText(info.titleId);
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(info.iconId))
	self:onOpenUI()
end


function wnd_battlefuncPrompt:onOpenUI()
	g_i3k_game_context:setFuncOpenTime(i3k_game_get_time())--os.time())
end

function wnd_battlefuncPrompt:onCloseUI(sender)
	self._layout.vars.ysjm_root:setVisible(false)
	self:onPlayAnis()
	if not self._clickCloseBtnFlag then
		self._clickCloseBtnFlag = true
	else
		self:closeUI()
	end
end

function wnd_battlefuncPrompt:onPlayAnis()
	if self._cfg then
		local widgetName = self._cfg.anisName
		local t = string.find(widgetName, "-1.0")
		if t then
			widgetName = nil
		end
		self:setAnisImg(widgetName, self._cfg.iconId)
		if widgetName then
			if self._layout.anis and self._layout.anis[widgetName] then
				local anis = self._layout.anis[widgetName]
				if anis then
					anis.stop()
					anis.play(function ()
						self:closeUI()
					end)
				end
			end
		else
			self:closeUI()
		end
	end
end

function wnd_battlefuncPrompt:setAnisImg(widgetName, imgID)
	if widgetName then
		if widgetName == "c_fei1" or widgetName == "c_fei2" then
			self._layout.vars.fxt:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
		elseif widgetName == "c_fei3" then
			self._layout.vars.fxt2:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
		end
	end
end

function wnd_battlefuncPrompt:closeUI()
	local sendTime = g_i3k_game_context:getFuncOpenTime()
	if sendTime~= nil then
		local timeNow = i3k_game_get_time()
		local timeValue = timeNow-sendTime
		if timeValue > i3k_db_common.mission.Opentime or timeValue==0 then
			g_i3k_ui_mgr:CloseUI(eUIID_BattleFuncPrompt)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_battlefuncPrompt.new();
		wnd:create(layout);
	return wnd;
end
