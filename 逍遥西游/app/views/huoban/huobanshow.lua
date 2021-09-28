g_HuobanView = nil
CHuobanShow = class("CHuobanShow", CcsSubView)
function CHuobanShow:ctor(para)
  para = para or {}
  self.m_ViewPara = para
  self.m_InitViewNum = para.viewNum or HuobanShow_ShowHuobanView
  self.m_InitHuobanId = para.huobanID
  self.m_InitSubViewNum = para.subViewNum or HuobanShow_InitShow_PackageView
  local heroIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
  if #heroIds <= 1 then
    self.m_InitViewNum = HuobanShow_GetHuobanView
  end
  CHuobanShow.super.ctor(self, "views/huoban.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_showhuoban = {
      listener = handler(self, self.OnBtn_ShowHuoban),
      variName = "btn_showhuoban"
    },
    btn_gethuoban = {
      listener = handler(self, self.OnBtn_GetHuoban),
      variName = "btn_gethuoban"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_showhuoban,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_gethuoban,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.btn_showhuoban:setTitleText("我\n的\n伙\n伴")
  self.btn_gethuoban:setTitleText("招\n募\n伙\n伴")
  local size = self.btn_showhuoban:getContentSize()
  self:adjustClickSize(self.btn_showhuoban, size.width + 30, size.height, true)
  local size = self.btn_gethuoban:getContentSize()
  self:adjustClickSize(self.btn_gethuoban, size.width + 30, size.height, true)
  self:setGroupAllNotSelected(self.btn_showhuoban)
  self.title_p1 = self:getNode("title_p1")
  self.title_p2 = self:getNode("title_p2")
  self.m_GetHuobanView = nil
  self.m_ShowHuobanView = nil
  self:getNode("layerPos"):setVisible(false)
  self:getNode("layerPos"):setTouchEnabled(false)
  self:SelectHuobanView(self.m_InitViewNum)
  self:ListenMessage(MsgID_MoveScene)
  g_HuobanView = self
end
function CHuobanShow:CreateHuobanView(viewNum)
  local tempViewNameDict = {
    [HuobanShow_ShowHuobanView] = "m_ShowHuobanView",
    [HuobanShow_GetHuobanView] = "m_GetHuobanView"
  }
  local viewObj = self[tempViewNameDict[viewNum]]
  if viewObj == nil then
    local tempView
    if viewNum == HuobanShow_ShowHuobanView then
      tempView = CHuobanList.new(self.m_ViewPara)
      self.m_ShowHuobanView = tempView
    elseif viewNum == HuobanShow_GetHuobanView then
      tempView = CJiuguanShow.new()
      self.m_GetHuobanView = tempView
    end
    if tempView ~= nil then
      self:addChild(tempView.m_UINode)
      local x, y = self:getNode("layerPos"):getPosition()
      tempView:setPosition(ccp(x, y))
    end
  end
end
function CHuobanShow:SelectHuobanView(viewNum)
  if viewNum == HuobanShow_GetHuobanView then
    self.title_p1:setText("招募")
    self.title_p2:setText("伙伴")
  else
    self.title_p1:setText("我的")
    self.title_p2:setText("伙伴")
  end
  local viewNumList = {HuobanShow_ShowHuobanView, HuobanShow_GetHuobanView}
  local tempViewNameDict = {
    [HuobanShow_ShowHuobanView] = "m_ShowHuobanView",
    [HuobanShow_GetHuobanView] = "m_GetHuobanView"
  }
  local tempBtnNameDict = {
    [HuobanShow_ShowHuobanView] = self.btn_showhuoban,
    [HuobanShow_GetHuobanView] = self.btn_gethuoban
  }
  local viewObj = self[tempViewNameDict[viewNum]]
  if viewObj == nil then
    self:CreateHuobanView(viewNum)
  end
  for _, i in pairs(viewNumList) do
    local viewObj = self[tempViewNameDict[i]]
    if viewObj ~= nil then
      viewObj:setVisible(i == viewNum)
      viewObj:setEnabled(i == viewNum)
    end
  end
  self:setGroupBtnSelected(tempBtnNameDict[viewNum])
end
function CHuobanShow:OnBtn_ShowHuoban(btnObj, touchType)
  local heroIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
  if #heroIds <= 1 then
    ShowNotifyTips("请先招募伙伴")
    self:SelectHuobanView(HuobanShow_GetHuobanView)
    return
  end
  self:SelectHuobanView(HuobanShow_ShowHuobanView)
end
function CHuobanShow:OnBtn_GetHuoban(btnObj, touchType)
  self:SelectHuobanView(HuobanShow_GetHuobanView)
end
function CHuobanShow:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CHuobanShow:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemSource_Jump then
    local arg = {
      ...
    }
    local d = arg[1][1]
    for _, t in pairs(Item_Source_MoveMapList) do
      if d == t then
        self:CloseSelf()
        break
      end
    end
  end
end
function CHuobanShow:Clear()
  if g_HuobanView == self then
    g_HuobanView = nil
  end
end
