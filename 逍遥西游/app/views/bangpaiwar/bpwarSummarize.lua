CBpWarSummarize = class("CBpWarSummarize", CcsSubView)
function CBpWarSummarize:ctor(data)
  CBpWarSummarize.super.ctor(self, "views/bpwarsummarize.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_RankData = data
  self.contentlist = self:getNode("contentlist")
  self.contentlist:addLoadMoreListenerScrollView(function()
    self:ShowNextListPart()
  end)
  self:ShowNextListPart()
end
function CBpWarSummarize:ShowNextListPart()
  local cnt = self.contentlist:getCount()
  local flag = false
  for index = cnt + 1, cnt + 15 do
    local info = self.m_RankData[index]
    if info ~= nil then
      local item = CBpWarSummarizeItem.new(index, info)
      self.contentlist:pushBackCustomItem(item.m_UINode)
      flag = true
    else
      break
    end
  end
  self.contentlist:refreshView()
  if flag then
    self.contentlist:setCanLoadMore(true)
  end
end
function CBpWarSummarize:Btn_Close()
  self:CloseSelf()
end
function CBpWarSummarize:Clear()
end
CBpWarSummarizeItem = class("CBpWarSummarizeItem", CcsSubView)
function CBpWarSummarizeItem:ctor(index, info)
  CBpWarSummarizeItem.super.ctor(self, "views/bpwarsummarizeitem.json")
  local bpId = info.orgid
  local teamId = info.teamid
  local attFlag = g_BpWarMgr:getIsAttacker(bpId)
  local teamName = info.teamname or ""
  teamName = string.format("%s的队伍", teamName)
  local wincnt = info.wincnt or 0
  local losecnt = info.losecnt or 0
  self:getNode("txt_rank"):setText(tostring(index))
  self:getNode("txt_team"):setText(teamName)
  self:getNode("txt_win"):setText(tostring(wincnt))
  self:getNode("txt_lose"):setText(tostring(losecnt))
  if attFlag then
    self:getNode("txt_team"):setColor(BpNameColorOfBpWarAttacker)
  else
    self:getNode("txt_team"):setColor(BpNameColorOfBpWarDefender)
  end
  AutoLimitObjSize(self:getNode("txt_team"), 240)
  if teamId == g_TeamMgr:getLocalPlayerTeamId() then
    local bg = display.newScale9Sprite("views/common/bg/bg1064.png", 4, 4, CCSize(10, 10))
    bg:setAnchorPoint(ccp(0, 0))
    local size = self:getContentSize()
    bg:setContentSize(CCSize(size.width, size.height))
    self:addNode(bg, 0)
    bg:setPosition(ccp(0, 0))
  end
end
function CBpWarSummarizeItem:Clear()
end
