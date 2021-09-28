-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_game_notice = i3k_class("wnd_game_notice",ui.wnd_base)

function wnd_game_notice:ctor()

end

function wnd_game_notice:configure()
	local widgets = self._layout.vars
	
	self.scroll = widgets.scroll
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		g_i3k_game_handler:RoleBreakPoint("Game_Confirm_Announcement", "")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Login, "playAnimation")
	end)
	
	self.typeButton = {widgets.noticeBtn, widgets.activityBtn, widgets.updateBtn}
	self.typeButton[1]:stateToPressed()
	for i, e in ipairs(self.typeButton) do
		e:onClick(self, self.onTypeChanged, i)
	end
end

function wnd_game_notice:refresh()
	self:updateText(g_Game_Notice)
	self:updateVisible()
end

function wnd_game_notice:onTypeChanged(sender, tag)
	self:updateText(tag)
end

function wnd_game_notice:updateText(tag)
	if self._type ~= tag then
		self._type = tag
		self:updateBtnState()
		self.scroll:removeAllChildren()
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local annText = require("ui/widgets/ggt1")()
			annText.vars.text:setText(i3k_get_announcement_content(tag))
			self.scroll:addItem(annText)
			g_i3k_ui_mgr:AddTask(self, {annText}, function(ui)
				local textUI = annText.vars.text
				local size = annText.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = size.height > height and size.height or height
				annText.rootVar:changeSizeInScroll(self.scroll, width, height, true)
			end, 1)
		end, 1)
	end
end

function wnd_game_notice:updateVisible()
	for i, e in ipairs(self.typeButton) do
		e:setVisible((i3k_get_announcement_content(i) ~= ""))	
	end
end

function wnd_game_notice:updateBtnState()
	for _, e in ipairs(self.typeButton) do
		e:stateToNormal()
	end
	self.typeButton[self._type]:stateToPressed()
end
	
function wnd_create(layout)
	local wnd = wnd_game_notice.new()
	wnd:create(layout)
	return wnd
end
	