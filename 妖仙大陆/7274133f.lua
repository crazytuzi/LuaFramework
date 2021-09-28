



local _M = {}
_M.__index = _M

local msgboxs = {
}
local count = 1

local function OnClose(displayNode)
  local index = displayNode.UserData
   msgboxs[index].menu:Close()
   msgboxs[index] = nil
end

function _M.Init(self, xml, Onloaded)
	print("MsgBox.init")
	self.menu = LuaMenu.Create(xml, 0)
  msgboxs[count] = self
  self.ID = count
  count = count + 1
	
	
  Onloaded(self, OnClose)
	return self.menu
end

local function New(xml, Onloaded)
	local self = {}
  _M.Init(self, xml, Onloaded)
	return setmetatable(self, _M)
end

return {New = New}
