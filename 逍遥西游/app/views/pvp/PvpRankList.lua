local CPvpRankListItem = class("CPvpRankListItem", CcsSubView)
function CPvpRankListItem:ctor(info)
  CPvpRankListItem.super.ctor(self, "views/ranklistitem.json")
  self.rank_txt = self:getNode("rank_txt")
  self.rank_txt:setText(tostring(info.i_rank))
  self.headbg = self:getNode("headbg")
  local p = self.headbg:getParent()
  local z = self.headbg:getZOrder()
  local x, y = self.headbg:getPosition()
  local scale = self.headbg:getScale()
  local headIcon = createHeadIconByRoleTypeID(info.i_ltype)
  p:addNode(headIcon, z + 1)
  headIcon:setPosition(ccp(x, y + 3))
  headIcon:setScale(scale)
  self.name = self:getNode("name")
  self.name:setText(info.s_name)
  self.level = self:getNode("level")
  self.level:setText(string.format("%d转%d级", info.i_zs, info.i_level))
  self.honour = self:getNode("honour")
  self.honour:setText(tostring(info.i_honour))
  if info.i_rank % 2 == 1 then
    self.bg = self:getNode("bg")
    self.bg:setVisible(false)
  end
end
function CPvpRankListItem:Clear()
end
CPvpRankList = class("CPvpRankList", CcsSubView)
function CPvpRankList:ctor(closeListener)
  CPvpRankList.super.ctor(self, "views/ranklist.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.list_rank = self:getNode("list_rank")
  self.list_rank:addLoadMoreListenerScrollView(function()
    self:LoadMoreRankInfo()
  end)
  self.list_rank:setCanLoadMore(false)
  self:ListenMessage(MsgID_Pvp)
  self.m_CloseListener = closeListener
end
function CPvpRankList:onEnterEvent()
  self:LoadMoreRankInfo()
end
function CPvpRankList:LoadMoreRankInfo()
  local index = self.list_rank:getCount()
  local infoList, isloading = g_PvpMgr:getRankInfo(index)
  self:showLoading(isloading)
  if infoList ~= nil then
    self:LoadRankInfo(infoList)
  end
end
function CPvpRankList:LoadRankInfo(infoList)
  for _, info in ipairs(infoList) do
    local item = CPvpRankListItem.new(info)
    self.list_rank:pushBackCustomItem(item:getUINode())
  end
  self.list_rank:refreshView()
  if #infoList > 0 then
    self.list_rank:setCanLoadMore(true)
  end
  self:showLoading(false)
end
function CPvpRankList:ClearRankList()
  self.list_rank:removeAllItems()
end
function CPvpRankList:showLoading(isloading)
  if isloading then
    if self.m_LoadingImg == nil then
      self.m_LoadingImg = CreateALoadingSprite()
      local p = self.list_rank:getParent()
      local x, y = self.list_rank:getPosition()
      local size = self.list_rank:getContentSize()
      p:addNode(self.m_LoadingImg, 999)
      self.m_LoadingImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    end
  elseif self.m_LoadingImg then
    self.m_LoadingImg:removeFromParent()
    self.m_LoadingImg = nil
  end
end
function CPvpRankList:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Pvp_NewRankInfo then
    local infoList = arg[1]
    self:LoadRankInfo(infoList)
  elseif msgSID == MsgID_Pvp_ClearRankList then
    self:ClearRankList()
  elseif msgSID == MsgID_Pvp_RankInfoFinish then
    self:showLoading(false)
  elseif msgSID == MsgID_Pvp_RankIsOk then
    self:showLoading(false)
  end
end
function CPvpRankList:Btn_Close(obj, t)
  self:CloseSelf()
end
function CPvpRankList:Clear()
  if self.m_CloseListener then
    self.m_CloseListener()
    self.m_CloseListener = nil
  end
end
