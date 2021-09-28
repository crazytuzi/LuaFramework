RechargeFanliView = class("RechargeFanliView", CcsSubView)
function RechargeFanliView:ctor(para)
  para = para or {}
  local curVIPLv = g_LocalPlayer:getVipLv()
  self.m_InitVIPIndex = para.VIPIndex or curVIPLv
  RechargeFanliView.super.ctor(self, "views/rechargefanli.json", {isAutoCenter = true, opacityBg = 0})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_MyTouchEnabledFlag = true
  self.m_Items = nil
  self:InitPage()
end
function RechargeFanliView:InitPage()
  if self.m_Items == nil then
    self.m_Items = {}
    self:getNode("list"):removeAllItems()
    self.m_Items = {}
    local showIdList = {}
    for tId, _ in pairs(data_ChongZhiExtraAward) do
      showIdList[#showIdList + 1] = tId
    end
    table.sort(showIdList)
    for _, tId in ipairs(showIdList) do
      local item = RechargeFanliItem.new(tId)
      self:getNode("list"):pushBackCustomItem(item:getUINode())
      self.m_Items[#self.m_Items + 1] = item
    end
  end
  self:setMyTouchEnabled(true)
  self:getNode("list"):sizeChangedForShowMoreTips()
end
function RechargeFanliView:setMyTouchEnabled(flag)
  self.m_MyTouchEnabledFlag = flag
  self:getNode("list"):setEnabled(flag)
  self:getNode("list"):setVisible(flag)
end
function RechargeFanliView:OnBtn_Close(btnObj, touchType)
  g_StoreView:CloseSelf()
end
