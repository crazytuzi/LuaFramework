MapJiehunObjBase = class("MapJiehunObjBase", function()
  return Widget:create()
end)
function MapJiehunObjBase:ctor()
  self:setNodeEventEnabled(true)
  self.m_IsExist = true
  local function listener(event)
    local name = event.name
    if name == "cleanup" then
      self.m_IsExist = false
      self:Clear()
    end
  end
  self:addNodeEventListener(cc.NODE_EVENT, listener)
end
function MapJiehunObjBase:Clear()
end
