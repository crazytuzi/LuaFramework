require "ui.dialog"

local T = {}
setmetatable(T, Dialog)
T.__index = T
function T:GetSingletonDialogAndShowIt()
	if not self._instance then
		self._instance = self.new()
	end
	if not self._instance:IsVisible() then
		self._instance:SetVisible(true)
	end
	return self._instance
end

function T:DestroyDialog()
	if self._instance then
		self:OnClose()
		getmetatable(self)._instance = nil
	end
end

function T:getInstanceOrNot()
	return self._instance
end

function T:getInstance()
	if not self._instance then
		self._instance = self.new()
	end
	return self._instance
end

return T
