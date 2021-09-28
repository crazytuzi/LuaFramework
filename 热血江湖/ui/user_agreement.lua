-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_user_agreement = i3k_class("wnd_user_agreement",ui.wnd_base)

function wnd_user_agreement:ctor()

end

function wnd_user_agreement:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self.sureBtn = widgets.sureBtn
	
	widgets.sureBtn:onClick(self, self.onSure)
end

function wnd_user_agreement:refresh()
	self:updateTxt()
end

function wnd_user_agreement:updateTxt()
	self.scroll:removeAllChildren()
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local annText = require("ui/widgets/xieyit")()
		annText.vars.text:setText(i3k_get_string(16361))
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

function wnd_user_agreement:onSure(sender)
	local cfg = g_i3k_game_context:GetUserCfg()
	cfg:SetIsAgreement(1)
	self:onCloseUI()
end
	
function wnd_create(layout)
	local wnd = wnd_user_agreement.new()
	wnd:create(layout)
	return wnd
end
	