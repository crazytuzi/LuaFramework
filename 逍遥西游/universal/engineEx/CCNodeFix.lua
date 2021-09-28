if CCNode.__func__removeFromParent == nil then
  CCNode.__func__removeFromParent = CCNode.removeFromParent
end
function CCNode:removeFromParent(...)
  if self.addNode ~= nil and self.removeNode ~= nil then
    CCNode.__func__removeFromParent(self, ...)
  else
    local p = self:getParent()
    if p and p.addNode ~= nil and p.removeNode ~= nil then
      p:removeNode(self)
    else
      CCNode.__func__removeFromParent(self, ...)
    end
  end
end
if CCNode.__func__removeFromParentAndCleanup == nil then
  CCNode.__func__removeFromParentAndCleanup = CCNode.removeFromParentAndCleanup
end
function CCNode:removeFromParentAndCleanup(...)
  if self.addNode ~= nil and self.removeNode ~= nil then
    CCNode.__func__removeFromParentAndCleanup(self, ...)
  else
    local p = self:getParent()
    if p and p.addNode ~= nil and p.removeNode ~= nil then
      local arg = {
        ...
      }
      if arg[1] == false then
        CCNode.__func__removeFromParentAndCleanup(self, ...)
      else
        p:removeNode(self)
      end
    else
      CCNode.__func__removeFromParentAndCleanup(self, ...)
    end
  end
end
if CCNode.__func__removeChild == nil then
  CCNode.__func__removeChild = CCNode.removeChild
end
function CCNode:removeChild(childNode, ...)
  if self.addNode ~= nil and self.removeNode ~= nil then
    if childNode.addNode ~= nil and childNode.removeNode ~= nil then
      CCNode.__func__removeChild(self, childNode, ...)
    else
      self:removeNode(childNode)
    end
  else
    CCNode.__func__removeChild(self, childNode, ...)
  end
end
function CCNode:onEnterEvent()
end
function CCNode:onExitEvent()
end
function CCNode:onEnterTransitionFinishEvent()
end
function CCNode:onExitTransitionStartEvent()
end
function CCNode:setNodeEventEnabled(enabled, listener)
  local handle
  if enabled then
    listener = listener or function(event)
      local name = event.name
      if self._execNodeEvent ~= false and self[string.format("_execNodeEvent_%s", name)] == nil then
        self[string.format("_execNodeEvent_%s", name)] = true
        if name == "enter" then
          self:onEnterEvent()
        elseif name == "exit" then
          self:onExitEvent()
        elseif name == "enterTransitionFinish" then
          self:onEnterTransitionFinishEvent()
        elseif name == "exitTransitionStart" then
          self:onExitTransitionStartEvent()
        elseif name == "cleanup" then
          self:onCleanup()
        end
      end
    end
    handle = self:addNodeEventListener(cc.NODE_EVENT, listener)
  else
    self:removeNodeEventListener(handle)
  end
  return self
end
