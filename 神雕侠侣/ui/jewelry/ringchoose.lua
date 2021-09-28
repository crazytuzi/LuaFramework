local single = require "ui.singletondialog"

local RingChoose = {}
setmetatable(RingChoose, single)
RingChoose.__index = RingChoose

function RingChoose.new()
	local self = {}
	setmetatable(self, RingChoose)
	function self.GetLayoutFileName()
		return "ringchoose.layout"
	end
	require "ui.dialog".OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.normal = {} 
	self.normal.item = CEGUI.toItemCell(winMgr:getWindow("ringchoose/normal"))
	self.normal.name = winMgr:getWindow("ringchoose/normalname")
	self.normal.left = winMgr:getWindow("ringchoose/title/normalleft")
	self.normal.light = winMgr:getWindow("ringchoose/light0")
	self.better = {}
	self.better.item = CEGUI.toItemCell(winMgr:getWindow("ringchoose/better"))
	self.better.name = winMgr:getWindow("ringchoose/bettername")
	self.better.left = winMgr:getWindow("ringchoose/title/betterleft")
	self.better.light = winMgr:getWindow("ringchoose/light1")
	self.special = {}
	self.special.item = CEGUI.toItemCell(winMgr:getWindow("ringchoose/special"))
	self.special.name = winMgr:getWindow("ringchoose/specialname")
	self.special.left = winMgr:getWindow("ringchoose/title/betterspecial")
	self.special.light = winMgr:getWindow("ringchoose/light2")
	self.morespecial = {}
	self.morespecial.item = CEGUI.toItemCell(winMgr:getWindow("ringchoose/morespecial"))
	self.morespecial.name = winMgr:getWindow("ringchoose/morespecialname")
	self.morespecial.left = winMgr:getWindow("ringchoose/title/morespecialleft")
	self.morespecial.light = winMgr:getWindow("ringchoose/light3")
	self.okbtn = CEGUI.toPushButton(winMgr:getWindow("ringchoose/ok"))
	
	self.closebtn = CEGUI.toPushButton(winMgr:getWindow("ringchoose/close"))
	self.closebtn:subscribeEvent("Clicked", RingChoose.DestroyDialog, self)
	self.normal.light:setVisible(false)
	self.better.light:setVisible(false)
	self.special.light:setVisible(false)
	self.morespecial.light:setVisible(false)
--	require "utils.mhsdutils".SetWindowShowtips(self.normal.item)
--	require "utils.mhsdutils".SetWindowShowtips(self.better.item)
--	require "utils.mhsdutils".SetWindowShowtips(self.special.item)
	self.normal.item:subscribeEvent("MouseClick", RingChoose.HandleChoosePaper, self)
	self.better.item:subscribeEvent("MouseClick", RingChoose.HandleChoosePaper, self)
	self.special.item:subscribeEvent("MouseClick", RingChoose.HandleChoosePaper, self)
	self.morespecial.item:subscribeEvent("MouseClick", RingChoose.HandleChoosePaper, self)
	self:GetWindow():setTopMost(true)
	return self
end

function RingChoose:setSelectedpaper(itemid)
	if self.selectedpaper then
		local wnd = self.selectedpaper == 1 and self.normal.light or 
			(self.selectedpaper == 2 and self.better.light or self.special.light)
		wnd:setVisible(false)
	end
	if self.normal.item:getID() == itemid then
		self.normal.light:setVisible(true)
		self.selectedpaper = 1
	elseif self.better.item:getID() == itemid then
		self.better.light:setVisible(true)
		self.selectedpaper = 2
	elseif self.special.item:getID() == itemid then
		self.special.light:setVisible(true)
		self.selectedpaper = 3
	elseif self.morespecial.item:getID() == itemid then
		self.morespecial.light:setVisible(true)
		self.selectedpaper = 4
	else
		assert(false)
	end
	
end

function RingChoose:HandleChoosePaper(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	
	if self.selectedpaper then
		local wnd = (self.selectedpaper == 1 and self.normal.light) or 
					(self.selectedpaper == 2 and self.better.light) or 
					(self.selectedpaper == 3 and self.special.light) or 
					(self.selectedpaper == 4 and self.morespecial.light)
		wnd:setVisible(false)
	end

	self.selectedpaper = (mouseArgs.window == self.normal.item and 1) or
						 (mouseArgs.window == self.better.item and 2) or 
						 (mouseArgs.window == self.special.item and 3) or
						 (mouseArgs.window == self.morespecial.item and 4)

	local wnd = (self.selectedpaper == 1 and self.normal.light) or
				(self.selectedpaper == 2 and self.better.light) or 
				(self.selectedpaper == 3 and self.special.light) or 
				(self.selectedpaper == 4 and self.morespecial.light)
	wnd:setVisible(true)
	return true
end

return RingChoose