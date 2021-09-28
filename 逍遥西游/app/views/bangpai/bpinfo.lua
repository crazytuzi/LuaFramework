g_CBpInfoHandler = nil
CBpInfo = class("CBpInfo", CcsSubView)
function CBpInfo:ctor()
  CBpInfo.super.ctor(self, "views/bangpai.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_page_base = {
      listener = handler(self, self.OnBtn_Page_Base),
      variName = "btn_page_base"
    },
    btn_page_tuteng = {
      listener = handler(self, self.OnBtn_Page_Tuteng),
      variName = "btn_page_tuteng"
    },
    btn_page_huodong = {
      listener = handler(self, self.OnBtn_Page_Huodong),
      variName = "btn_page_huodong"
    },
    btn_page_fuli = {
      listener = handler(self, self.OnBtn_Page_Fuli),
      variName = "btn_page_fuli"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.btn_page_base:setTitleText("帮\n派\n信\n息")
  self.btn_page_tuteng:setTitleText("守\n护\n图\n腾")
  self.btn_page_huodong:setTitleText("帮\n派\n活\n动")
  self.btn_page_fuli:setTitleText("帮\n派\n福\n利")
  local size = self.btn_page_base:getContentSize()
  self:adjustClickSize(self.btn_page_base, size.width + 30, size.height, true)
  local size = self.btn_page_tuteng:getContentSize()
  self:adjustClickSize(self.btn_page_tuteng, size.width + 30, size.height, true)
  local size = self.btn_page_huodong:getContentSize()
  self:adjustClickSize(self.btn_page_huodong, size.width + 30, size.height, true)
  local size = self.btn_page_fuli:getContentSize()
  self:adjustClickSize(self.btn_page_fuli, size.width + 30, size.height, true)
  self:addBtnSigleSelectGroup({
    {
      self.btn_page_base,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    },
    {
      self.btn_page_tuteng,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    },
    {
      self.btn_page_huodong,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    },
    {
      self.btn_page_fuli,
      nil,
      ccc3(251, 248, 145),
      ccp(-3, 0)
    }
  })
  self.title_txt_p1 = self:getNode("title_txt_p1")
  self.title_txt_p2 = self:getNode("title_txt_p2")
  self.layer_pagepos = self:getNode("layer_pagepos")
  self.layer_pagepos:setVisible(false)
  self.layer_pagepos:setTouchEnabled(false)
  self.m_Page_Base = nil
  self.m_Page_Tuteng = nil
  self.m_Page_Huodong = nil
  self.m_Page_Fuli = nil
  self.layer_msg = self:getNode("layer_msg")
  self.layer_msg:setTouchEnabled(true)
  self.layer_msg:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN and self.m_Page_Base then
      self.m_Page_Base:ClearSeleted()
    end
  end)
  self:ListenMessage(MsgID_BP)
  if g_CBpInfoHandler then
    g_CBpInfoHandler:CloseSelf()
    g_CBpInfoHandler = nil
  end
  g_CBpInfoHandler = self
  g_BpMgr:send_requestBpBaseInfo()
  g_BpMgr:send_getBpTotemInfo()
  self:OnBtn_Page_Base()
  if g_BpMgr:getBpNewBpWarTip() then
    self:OnBtn_Page_Huodong()
  end
end
function CBpInfo:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_OldInfoIsInvalid then
    self:CloseSelf()
  elseif msgSID == MsgID_BP_LocalInfo and not g_BpMgr:localPlayerHasBangPai() then
    self:CloseSelf()
  end
end
function CBpInfo:addPage(pageObj)
  local p = self.layer_pagepos:getParent()
  local x, y = self.layer_pagepos:getPosition()
  local z = self.layer_pagepos:getZOrder()
  p:addChild(pageObj.m_UINode, z)
  pageObj:setPosition(ccp(x, y))
end
function CBpInfo:ShowPage(pageObj)
  for _, obj in pairs({
    self.m_Page_Base,
    self.m_Page_Tuteng,
    self.m_Page_Huodong,
    self.m_Page_Fuli
  }) do
    if obj then
      obj:setEnabled(pageObj == obj)
    end
  end
end
function CBpInfo:OnBtn_Page_Base()
  if self.m_Page_Base == nil then
    self.m_Page_Base = CBpInfoPageBase.new()
    self:addPage(self.m_Page_Base)
  end
  self.title_txt_p1:setText("帮派")
  self.title_txt_p2:setText("信息")
  self:ShowPage(self.m_Page_Base)
  self:setGroupBtnSelected(self.btn_page_base)
end
function CBpInfo:OnBtn_Page_Tuteng()
  if self.m_Page_Tuteng == nil then
    self.m_Page_Tuteng = CBpInfoPageTotem.new()
    self:addPage(self.m_Page_Tuteng)
  end
  self.title_txt_p1:setText("守护")
  self.title_txt_p2:setText("图腾")
  self:ShowPage(self.m_Page_Tuteng)
  self:setGroupBtnSelected(self.btn_page_tuteng)
end
function CBpInfo:OnBtn_Page_Huodong()
  if self.m_Page_Huodong == nil then
    self.m_Page_Huodong = CBpInfoPageHuodong.new(self)
    self:addPage(self.m_Page_Huodong)
  end
  self.title_txt_p1:setText("帮派")
  self.title_txt_p2:setText("活动")
  self:ShowPage(self.m_Page_Huodong)
  self:setGroupBtnSelected(self.btn_page_huodong)
  g_BpMgr:send_getTodayBpPaoShangTimes()
end
function CBpInfo:OnBtn_Page_Fuli()
  if self.m_Page_Fuli == nil then
    self.m_Page_Fuli = CBpInfoPageFuli.new()
    self:addPage(self.m_Page_Fuli)
  end
  self.title_txt_p1:setText("帮派")
  self.title_txt_p2:setText("福利")
  self:ShowPage(self.m_Page_Fuli)
  self:setGroupBtnSelected(self.btn_page_fuli)
end
function CBpInfo:OnBtn_Close()
  self:CloseSelf()
end
function CBpInfo:Clear()
  if g_CBpInfoHandler == self then
    g_CBpInfoHandler = nil
  end
  SendMessage(MsgID_BP_BpDlgIsInvalid)
  g_BpMgr:send_closeBpInfoDlg()
end
