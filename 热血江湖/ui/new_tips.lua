-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_new_tips = i3k_class("wnd_new_tips", ui.wnd_base)

function wnd_new_tips:ctor()
	
end

function wnd_new_tips:configure()
	self.desc = self._layout.vars.desc
	self.tips_root = self._layout.vars.tips_root
	self.tips_bg = self._layout.vars.tips_bg
end

function wnd_new_tips:onShow()
	
end

function wnd_new_tips:refresh(str, data)
	self.tips_bg:hide()
	local pos = data.pos
	self:updateText(str)
	self.tips_root:setPosition(pos.x - data.width / 2, pos.y - data.height /2)
	g_i3k_ui_mgr:AddTask(self, {}, function(self)
		if not self.desc then
			self.desc = self._layout.vars.desc
			self.tips_root = self._layout.vars.tips_root
			self.tips_bg = self._layout.vars.tips_bg
		end
		local nwidth = self.desc:getInnerSize().width
		local nheight = self.desc:getInnerSize().height
		local bgwidth = self.tips_bg:getContentSize().width
		local bgheight = self.tips_bg:getContentSize().height
		nwidth = nwidth>bgwidth and nwidth+20 or bgwidth
		nheight = nheight>bgheight and nheight+20 or bgheight
		self.tips_bg:setContentSize(nwidth, nheight)
		self.tips_bg:show()
	end, 1)
	
end 

function wnd_new_tips:updateText(str)
	self.desc:setText(str)
end 

function wnd_create(layout)
	local wnd = wnd_new_tips.new()
		wnd:create(layout)
	return wnd
end

