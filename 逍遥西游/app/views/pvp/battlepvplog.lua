CBattleLogItem = class("CBattleLogItem", CcsSubView)
function CBattleLogItem:ctor(data, index, lastOneFlag)
  CBattleLogItem.super.ctor(self, "views/battlelog.json")
  self.m_Data = data
  local btnBatchListener = {
    btn_watch = {
      listener = handler(self, self.OnBtn_Watch),
      variName = "btn_watch"
    },
    btn_fight = {
      listener = handler(self, self.OnBtn_Fight),
      variName = "btn_fight"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local bgPath
  if index % 2 == 0 then
    bgPath = "views/common/bg/bg1062.png"
  else
    bgPath = "views/common/bg/bg1063.png"
  end
  local bg = display.newScale9Sprite(bgPath, 4, 4, CCSize(10, 10))
  bg:setAnchorPoint(ccp(0, 0))
  local size = self:getContentSize()
  bg:setContentSize(CCSize(size.width, size.height))
  self:addNode(bg, 0)
  bg:setPosition(ccp(0, 0))
  local icon
  local logtxt = ""
  local tp = data.i_type
  if tp == 0 then
    if data.i_result == 0 then
      logtxt = string.format("你挑战#<W>%s#失败了,排名不变", data.s_name)
    elseif data.i_rank_start ~= nil and data.i_rank_end < data.i_rank_start then
      icon = display.newSprite("views/pic/pic_bwc_up.png")
      logtxt = string.format("你挑战#<W>%s#胜利了,排名上升至第#<R>%d#名", data.s_name, data.i_rank_end)
    elseif data.i_rank_start == 1 then
      logtxt = string.format("你挑战#<W>%s#胜利了", data.s_name)
    else
      logtxt = string.format("你挑战#<W>%s#胜利了,排名不变", data.s_name)
    end
  elseif data.i_result == 0 then
    icon = display.newSprite("views/pic/pic_bwc_down.png")
    logtxt = string.format("#<W>%s#战胜了你,排名下降至第#<G>%d#名", data.s_name, data.i_rank_end)
  else
    logtxt = string.format("#<W>%s#挑战你失败了,排名不变", data.s_name)
  end
  self.btn_fight:setEnabled(false)
  if data.i_cf == 1 and data.i_p ~= nil then
    self.btn_fight:setEnabled(true)
  end
  self.btn_watch:setEnabled(false)
  if data.i_cw == 1 and data.i_w ~= nil then
    self.btn_watch:setEnabled(true)
  end
  if icon ~= nil then
    local x, y = self:getNode("box_icon"):getPosition()
    local size = self:getNode("box_icon"):getContentSize()
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon:setPosition(ccp(x + size.width / 2, y + size.height / 2))
    self:addNode(icon)
  end
  if logtxt ~= "" then
    local w = self:getContentSize().width - 100
    local desc = CRichText.new({
      width = w,
      color = ccc3(79, 48, 26),
      fontSize = 22
    })
    if lastOneFlag == true then
      logtxt = string.format("%s#<r:255,g:255,b:255>(最近)#", logtxt)
    end
    desc:addRichText(logtxt)
    self:addChild(desc)
    local x, y = self:getNode("box_icon"):getPosition()
    local size = self:getNode("box_icon"):getContentSize()
    local cSize = desc:getContentSize()
    desc:setPosition(ccp(x + size.width + 10, y + size.height / 2 - cSize.height / 2))
  end
end
function CBattleLogItem:OnBtn_Watch()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr and g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if g_MapMgr and g_MapMgr:IsInYiZhanDaoDiMap() then
    ShowNotifyTips("当前地图无法使用此功能")
    return
  end
  if g_MapMgr and g_MapMgr:IsInXueZhanShaChangMap() then
    ShowNotifyTips("当前地图无法使用此功能")
    return
  end
  if g_WarScene and g_WarScene:getIsWatching() then
    ShowNotifyTips("观战中，不能观看战斗回放")
    return
  end
  if g_WarScene and g_WarScene:getIsReview() then
    ShowNotifyTips("回放中，不能观看战斗回放")
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("在战斗中,不能观看战斗回放")
    return
  end
  local wId = self.m_Data.i_w
  if self.m_Data.i_cw == 1 and wId then
    netsend.netpvp.watchBWCBaseHistoryData(wId)
  end
end
function CBattleLogItem:OnBtn_Fight()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if g_MapMgr and g_MapMgr:IsInBangPaiWarMap() then
    ShowNotifyTips("帮战地图无法使用此功能")
    return
  end
  if g_MapMgr and g_MapMgr:IsInYiZhanDaoDiMap() then
    ShowNotifyTips("当前地图无法使用此功能")
    return
  end
  if g_MapMgr and g_MapMgr:IsInXueZhanShaChangMap() then
    ShowNotifyTips("当前地图无法使用此功能")
    return
  end
  if g_LocalPlayer and g_LocalPlayer:getIsFollowTeamCommon() >= 0 then
    ShowNotifyTips("组队情况下,不能进行比武")
    return
  end
  if g_WarScene and g_WarScene:getIsWatching() then
    ShowNotifyTips("观战中，不能进行比武")
    return
  end
  if g_WarScene and g_WarScene:getIsReview() then
    ShowNotifyTips("回放中，不能进行比武")
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("在战斗中,不能进行比武")
    return
  end
  local pId = self.m_Data.i_p
  if self.m_Data.i_cf == 1 and pId then
    netsend.netpvp.BWCReFight(pId)
  end
end
function CBattleLogItem:Clear()
end
