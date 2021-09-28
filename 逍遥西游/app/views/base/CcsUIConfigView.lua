CcsUIConfigView = class("CcsUIConfigView", nil)
function CcsUIConfigView:ctor(uifilePath)
  CcsUIConfig.load(self, uifilePath)
  self.m_UINode.m_UIViewParent = self
  self._execNodeEvent = true
  self._extcUIConfigViewClear = true
  local funcs = {
    "getParent",
    "setPosition",
    "getPosition",
    "setVisible",
    "runAction",
    "removeFromParentAndCleanup",
    "getContentSize",
    "setContentSize",
    "setEnabled",
    "isEnabled",
    "setTouchEnabled",
    "addNode",
    "addChild",
    "stopAllActions",
    "stopAction",
    "removeFromParent",
    "isVisible",
    "setScale",
    "getScale",
    "setBackGroundColorOpacity",
    "getBackGroundColorOpacity",
    "setBackGroundColor",
    "getBackGroundColor",
    "getBackGroundStartColor",
    "getBackGroundEndColor",
    "addNodeEventListener",
    "scheduleUpdate",
    "pauseSchedulerAndActions",
    "resumeSchedulerAndActions",
    "getZOrder",
    "getSize"
  }
  for i, f in ipairs(funcs) do
    if self[f] == nil then
      self[f] = function(viewObj, ...)
        if self.m_UINode == nil then
          return
        end
        local func = self.m_UINode[f]
        if func then
          return func(self.m_UINode, ...)
        else
          print(string.format("找不到函数%s", f))
        end
      end
    end
  end
  local function listener(event)
    local name = event.name
    if name == "cleanup" then
      self:execEventCleanup()
    elseif name == "enter" then
      if self.onEnterEvent then
        self:onEnterEvent()
      end
      if g_MissionMgr then
        g_MissionMgr:registerClassObj(self, self.__cname)
      end
      local adjustDatas = Text_Title_Bold_Adjust[self.__cname]
      if adjustDatas then
        for nodeName, t in pairs(adjustDatas) do
          local node = self:getNode(nodeName)
          if node and node.enableBoldLua then
            node:enableBoldLua(true, t)
          end
        end
      end
    end
  end
  local handle = self.m_UINode:addNodeEventListener(cc.NODE_EVENT, listener)
  MessageEventExtend.extend(self)
end
function CcsUIConfigView:execEventCleanup()
  if self._execNodeEvent ~= false then
    self:ConfigViewClear()
    if g_MissionMgr then
      g_MissionMgr:unRegisterClassObj(self, self.__cname)
    end
  end
end
function CcsUIConfigView:setUIConfigViewClear(flag)
  self._extcUIConfigViewClear = flag
end
function CcsUIConfigView:doCcsUIConfigViewClear()
  self.m_ButtonGruop = {}
  if self.m_UINode then
    self.m_UINode.m_UIViewParent = nil
    self.m_UINode = nil
  end
  self:RemoveAllMessageListener()
end
function CcsUIConfigView:addTo(p, z, t)
  if z ~= nil then
    self.m_ViewZOrder = z
  end
  if t ~= nil then
    self.m_ViewTag = t
  end
  if p == nil then
    printLog("ERROR", "父节点不能为空")
  end
  self.m_UINode:addTo(p, self.m_ViewZOrder, self.m_ViewTag)
  return self.m_UINode
end
function CcsUIConfigView:getUINode()
  return self.m_UINode
end
function CcsUIConfigView:ConfigViewClear()
  if self._extcUIConfigViewClear ~= false then
    self:doCcsUIConfigViewClear()
  end
end
function CcsUIConfigView:OnMessage(msgSID, ...)
  print("CcsUIConfigView:OnMessage msgSID, ... = ", msgSID, ...)
end
