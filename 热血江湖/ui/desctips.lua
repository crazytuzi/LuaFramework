-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_descTips = i3k_class("wnd_descTips", ui.wnd_base)

function wnd_descTips:ctor()
	
end

function wnd_descTips:configure()
	self.nameLabel = self._layout.vars.nameLabel
	self.desc = self._layout.vars.desc
	self.tips_root = self._layout.vars.tips_root
	self.tips_bg = self._layout.vars.tips_bg
end

function wnd_descTips:onShow()
	
end

function wnd_descTips:refresh(name, str, data)
	self.tips_bg:hide()
	local pos = data.pos
	self:updateText(name, str)
	self.tips_root:setPosition(pos.x - data.width / 2, pos.y + data.height)
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

function wnd_descTips:updateText(name, str)
	self.nameLabel:setText(name)
	self.desc:setText(str)
end 

function wnd_create(layout)
	local wnd = wnd_descTips.new()
		wnd:create(layout)
	return wnd
end

