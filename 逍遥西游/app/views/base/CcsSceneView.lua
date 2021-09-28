CcsSceneView = class("CcsSceneView", CcsUIView)
g_CurSceneView = nil
function CcsSceneView:ctor(uifilePath, addToUigroupZorder, param)
  CcsSceneView.super.ctor(self, uifilePath, addToUigroupZorder, param)
  self.m_CurShowModelView = nil
  self.m_ModelViewStack = {}
end
function CcsSceneView:Show(transitionType, time, more)
  self:ShowAsScene(transitionType, time, more)
  g_CurSceneView = self
end
function CcsSceneView:getChildMaxZ()
  return getMaxZ(self.getUINode())
end
function CcsSceneView:addSubView(param)
  local addToNode = param.addToNode or self.m_UINode
  local subView = param.subView
  local isModelView = param.isModelView
  local z = param.zOrder or 0
  local tag = param.tag
  local childNode = subView
  if subView.m_UINode then
    childNode = subView.m_UINode
  end
  if subView.createBlackBg_CcsSubView then
    local widget = subView:createBlackBg_CcsSubView()
    if widget then
      addToNode:addChild(widget, z)
      local p = widget:convertToWorldSpace(ccp(0, 0))
      widget:setPosition(p)
    end
  end
  if tag then
    addToNode:addChild(childNode, z, tag)
  else
    addToNode:addChild(childNode, z)
  end
  if isModelView then
    self:_addNewModelView(subView)
    if subView.CloseSelf == nil then
      function subView.CloseSelf()
        local p = getCurSceneView()
        if p then
          p:SubViewClosing(subView)
        end
        subView:removeSelf()
      end
    end
  end
  return subView
end
function CcsSceneView:SubViewClosing(subView)
  if subView._ccsSceneView_IsModelView == true then
    if self.m_CurShowModelView == subView then
      table.remove(self.m_ModelViewStack, 1)
      self:_setTopModelView()
    else
      for i, v in ipairs(self.m_ModelViewStack) do
        if v == subView then
          table.remove(self.m_ModelViewStack, i)
          break
        end
      end
    end
  end
end
function CcsSceneView:ShowInformView(strTitle, items, callback, pngPath, titleColor)
  return CShowInformView.new(strTitle, items, self, callback, pngPath, titleColor)
end
function CcsSceneView:ShowTalkView(talId, listener, missionId)
  self:TalkViewWillShow()
  if g_CurShowTalkView and g_CurShowTalkView.GetTalkId and g_CurShowTalkView:GetTalkId() == talId then
    print("请求创建的对话，和当前显示的对话id一样，所以不创建", talId)
    return
  end
  CMissionTalkView.new(talId, self, function()
    self:TalkViewShowFinished()
    if listener then
      listener(talId)
    end
  end, missionId)
end
function CcsSceneView:TalkViewWillShow()
end
function CcsSceneView:TalkViewShowFinished()
end
function CcsSceneView:_addNewModelView(subView)
  subView._ccsSceneView_IsModelView = true
  table.insert(self.m_ModelViewStack, 1, subView)
  self:_setTopModelView()
end
function CcsSceneView:_setTopModelView()
  if self.m_CurShowModelView then
    self.m_CurShowModelView:setVisible(false)
    self.m_CurShowModelView:setTouchEnabled(false)
  end
  if #self.m_ModelViewStack > 0 then
    self.m_CurShowModelView = self.m_ModelViewStack[1]
    self.m_CurShowModelView:setVisible(true)
    self.m_CurShowModelView:setTouchEnabled(true)
  else
    self.m_CurShowModelView = nil
  end
end
function CcsSceneView:onCleanup()
  if g_CurSceneView == self then
    g_CurSceneView = nil
  end
  self.m_CurShowModelView = nil
  self.m_ModelViewStack = {}
  CcsSceneView.super.onCleanup(self)
end
function getCurSceneView()
  return g_CurSceneView
end
