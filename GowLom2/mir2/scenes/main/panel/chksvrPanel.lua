local chksvrPanel = class("chksvrPanel", function ()
	return display.newNode()
end)

table.merge(slot0, {})

local respath = g_data.login:getChkResPath()
local configpath = g_data.login:getChkConfigPath()
local closepos = parseJson(configpath .. "ui_close.json")
chksvrPanel.ctor = function (self, param)
	self._supportMove = true
	self.bg = display.newNode():addto(self, 20)

	if param == nil then
		param = {}
	end

	local bgName = param.bg or "bg1"
	local newbg = res.get2(respath .. bgName .. ".png"):anchor(0, 0):addto(self)

	self.size(self, cc.size(newbg.getContentSize(newbg).width, newbg.getContentSize(newbg).height))
	self.setPosition(self, display.cx - self.getw(self)/2, display.cy - self.geth(self)/2)

	local data = {}

	for _, v in ipairs(closepos) do
		if v.key == bgName then
			data = v
		end
	end

	local x = data.x or 14
	local y = data.y or 14

	an.newBtn(res.gettex2(respath .. "close.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2(respath .. "close.png"),
		size = cc.size(64, 64)
	}).anchor(slot7, 1, 1):pos(self.getw(self) - x, self.geth(self) - y):addto(self, 20)

	return 
end

return chksvrPanel
