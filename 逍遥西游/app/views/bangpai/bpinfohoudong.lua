CBpInfoPageHuodong = class("CBpInfoPageHuodong", CcsSubView)
function CBpInfoPageHuodong:ctor(bpInfoHandler)
  CBpInfoPageHuodong.super.ctor(self, "views/bangpai_huodong.json")
  local btnBatchListener = {
    btn_go = {
      listener = handler(self, self.OnBtn_Go),
      variName = "btn_go"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_BpInfoHandler = bpInfoHandler
  self.huodong_select = self:getNode("huodong_select")
  self.huodongdesc = self:getNode("huodongdesc")
  self.txt_money = self:getNode("txt_money")
  self.title_times = self:getNode("title_times")
  self.title_times_0 = self:getNode("title_times_0")
  self.bg_times = self:getNode("bg_times")
  self.txt_times = self:getNode("txt_times")
  self.title_money = self:getNode("title_money")
  self.bg_money = self:getNode("bg_money")
  self.huodong_select:setVisible(false)
  self.txt_times:setText(g_BpMgr:getPaoShangTimes())
  self:SetTotalMoney()
  self.m_HuodongItem = {}
  for huodongId = 1, 4 do
    local temp = self:getNode(string.format("huodong_%d", huodongId))
    self[string.format("huodong_%d", huodongId)] = temp
    temp:setVisible(false)
    if data_Org_Huodong[huodongId] ~= nil then
      local x, y = temp:getPosition()
      local tSize = temp:getContentSize()
      local z = temp:getZOrder()
      local huodongItem = CBpInfoPageHuodongIcon.new(huodongId, handler(self, self.OnSelectHuodong))
      self:addChild(huodongItem, z + 1)
      huodongItem:setPosition(ccp(x + tSize.width / 2, y + tSize.height / 2))
      self.m_HuodongItem[huodongId] = huodongItem
    end
  end
  if g_BpMgr:getBpNewBpWarTip() then
    self:OnSelectHuodong(4)
  else
    self:OnSelectHuodong(1)
  end
  self:SetAttrTips()
  self:ListenMessage(MsgID_BP)
end
function CBpInfoPageHuodong:SetAttrTips()
  clickArea_check.extend(self)
  self:attrclick_check_withWidgetObj(self.title_money, "bpdesc_5")
  self:attrclick_check_withWidgetObj(self.bg_money, "bpdesc_5", self.title_money)
end
function CBpInfoPageHuodong:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_Detail then
    local arg = {
      ...
    }
    local info = arg[1]
    if info.i_money ~= nil then
      self:SetTotalMoney()
    end
  elseif msgSID == MsgID_BP_PaoShang then
    local arg = {
      ...
    }
    local times = arg[1]
    self.txt_times:setText(tostring(times))
  end
end
function CBpInfoPageHuodong:SetTotalMoney()
  self.txt_money:setText(tostring(g_BpMgr:getBpMoney()))
end
function CBpInfoPageHuodong:OnSelectHuodong(huodongId)
  if self.m_LastSelectHuodong and self.m_LastSelectHuodong:getHuodongId() == huodongId then
    return
  end
  if self.m_LastSelectHuodong then
    local oldHuodongId = self.m_LastSelectHuodong:getHuodongId()
    local oldHuodongItem = self.m_HuodongItem[oldHuodongId]
    if oldHuodongItem then
      oldHuodongItem:setSelected(false)
    end
    self.m_LastSelectHuodong:removeFromParent()
    self.m_LastSelectHuodong = nil
  end
  local x, y = self.huodong_select:getPosition()
  local tSize = self.huodong_select:getContentSize()
  local z = self.huodong_select:getZOrder()
  local huodongItem = CBpInfoPageHuodongIcon.new(huodongId, nil)
  self:addChild(huodongItem, z + 1)
  huodongItem:setPosition(ccp(x + tSize.width / 2, y + tSize.height / 2))
  self.m_LastSelectHuodong = huodongItem
  local desc = data_getHuodongDesc(huodongId)
  self.huodongdesc:setText("     " .. desc)
  local currHuodongItem = self.m_HuodongItem[huodongId]
  if currHuodongItem then
    currHuodongItem:setSelected(true)
  end
  if huodongId == 1 then
    self.title_times:setVisible(true)
    self.bg_times:setVisible(true)
    self.txt_times:setVisible(true)
    self.title_times_0:setVisible(true)
    self.txt_money:setVisible(true)
    self.title_money:setVisible(true)
    self.bg_money:setVisible(true)
  else
    self.title_times:setVisible(false)
    self.bg_times:setVisible(false)
    self.txt_times:setVisible(false)
    self.title_times_0:setVisible(false)
    self.txt_money:setVisible(false)
    self.title_money:setVisible(false)
    self.bg_money:setVisible(false)
  end
  if huodongId == 4 then
    if g_BpMgr:getBpNewBpWarTip() then
      self:getNode("pic_tip"):setVisible(true)
    else
      self:getNode("pic_tip"):setVisible(false)
    end
  else
    self:getNode("pic_tip"):setVisible(false)
  end
end
function CBpInfoPageHuodong:OnBtn_Go()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  print(" CBpInfoPageHuodong:OnBtn_Go  =====>>> ", self.m_LastSelectHuodong, self.m_LastSelectHuodong:getHuodongId())
  if self.m_LastSelectHuodong == nil then
    return
  end
  local huodongId = self.m_LastSelectHuodong:getHuodongId()
  local lvEable = true
  local baseLv = {0, 0}
  local trackId
  if huodongId == 1 and g_LocalPlayer:isNpcOptionUnlock(1059) == false then
    lvEable = false
    local tblimit = data_NpcTypeInfo[1059] or {}
    baseLv = {
      tblimit.zs,
      tblimit.lv
    }
    trackId = nil
  elseif huodongId == 2 then
    if g_LocalPlayer:isNpcOptionUnlock(1057) == false then
      lvEable = false
      local tblimit = data_NpcTypeInfo[1057] or {}
      baseLv = {
        tblimit.zs,
        tblimit.lv
      }
    end
    if BangPaiChuMo.lefttime_ ~= nil and 0 < BangPaiChuMo.lefttime_ and BangPaiChuMo.MissionId ~= -1 then
      trackId = BangPaiChuMo.MissionId
    end
    if g_BpMgr:getOpenChuMoFlag() ~= true and BangPaiChuMo.getMissionState() ~= 1 and BangPaiChuMo.getMissionState() ~= 2 then
      ShowNotifyTips("活动尚未开启（与帮派暗战任务交替开放）")
      return
    end
    if BangPaiChuMo.serviceState == false and BangPaiChuMo.MissionId == -1 then
      ShowNotifyTips("你今日已经完成帮派除奸这个任务了，请明日再来吧。")
      return
    end
  elseif huodongId == 3 then
    if g_LocalPlayer:isNpcOptionUnlock(1065) == false then
      lvEable = false
      local tblimit = data_NpcTypeInfo[1065] or {}
      baseLv = {
        tblimit.zs,
        tblimit.lv
      }
    end
    if BangPaiAnZhan.todayTime ~= nil and -1 < BangPaiAnZhan.todayTime and BangPaiAnZhan.MissionId ~= -1 then
      trackId = BangPaiAnZhan.MissionId
    end
    if g_BpMgr:getOpenAnZhanFlag() ~= true and BangPaiAnZhan.getMissionState() ~= 1 and BangPaiAnZhan.getMissionState() ~= 2 then
      ShowNotifyTips("活动尚未开启（与帮派除奸任务交替开放）")
      return
    end
    print("  请明日再来吧   BangPaiAnZhan.todayTime  ", BangPaiAnZhan.todayTime, BangPaiAnZhan.hadDone, BangPaiAnZhan.state_)
    if BangPaiAnZhan.hadDone == true and BangPaiAnZhan.todayTime > 11 or BangPaiAnZhan.hadDone == true and 0 > BangPaiAnZhan.todayTime or BangPaiAnZhan.hadCommit == true then
      ShowNotifyTips("你今日已经完成帮派暗战这个任务了，请明日再来吧。")
      return
    end
  elseif huodongId == 4 and g_LocalPlayer:isNpcOptionUnlock(1056) == false then
    lvEable = false
  end
  if trackId ~= nil and trackId ~= -1 then
    g_MissionMgr:TraceMission(trackId)
  else
    if JudgeIsInWar() then
      ShowNotifyTips("处于战斗中，不能跳转")
      return
    end
    do
      local npcId = data_getHuodongJumpNpc(huodongId)
      if npcId == nil then
        return
      end
      local function route_cb(isSucceed)
        if isSucceed and CMainUIScene.Ins then
          CMainUIScene.Ins:ShowNormalNpcViewById(npcId)
        end
      end
      g_MapMgr:AutoRouteToNpc(npcId, route_cb)
    end
  end
  self.m_BpInfoHandler:OnBtn_Close()
end
function CBpInfoPageHuodong:Clear()
  self.m_BpInfoHandler = nil
end
CBpInfoPageHuodongIcon = class("CBpInfoPageHuodongIcon", function()
  return Widget:create()
end)
function CBpInfoPageHuodongIcon:ctor(huodongId, clickListener)
  self.m_HuodongId = huodongId
  self.m_ClickListener = clickListener
  local iconPath = string.format("views/bphdicon/bphdicon_%d.png", huodongId)
  local icon = display.newSprite(iconPath)
  self:addNode(icon, 0)
  icon:setAnchorPoint(ccp(0.5, 0.5))
  local iconSize = icon:getContentSize()
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iconSize.width, iconSize.height))
  self:setNodeEventEnabled(true)
  if self.m_ClickListener ~= nil then
    clickArea_check.extend(self)
    self:click_check_withObj(self, handler(self, self.OnClick), handler(self, self.OnTouchIcon))
  end
end
function CBpInfoPageHuodongIcon:getHuodongId()
  return self.m_HuodongId
end
function CBpInfoPageHuodongIcon:setSelected(isel)
  if isel then
    if self._SelectObjList then
      for _, obj in pairs(self._SelectObjList) do
        obj:setVisible(true)
      end
    else
      local bgSize = self:getSize()
      local temp1 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp2 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp3 = display.newSprite("views/pic/pic_selectcorner.png")
      local temp4 = display.newSprite("views/pic/pic_selectcorner.png")
      local del = 5
      local w = bgSize.width / 2
      local h = bgSize.height / 2
      self:addNode(temp1)
      temp1:setPosition(ccp(-w - del, -h - del - 16))
      temp1:setAnchorPoint(ccp(0, 1))
      temp1:setScaleY(-1)
      self:addNode(temp2)
      temp2:setPosition(ccp(-w - del, h + del))
      temp2:setAnchorPoint(ccp(0, 1))
      self:addNode(temp3)
      temp3:setPosition(ccp(w + del, -h - del - 16))
      temp3:setAnchorPoint(ccp(0, 1))
      temp3:setScaleX(-1)
      temp3:setScaleY(-1)
      self:addNode(temp4)
      temp4:setPosition(ccp(w + del, h + del))
      temp4:setAnchorPoint(ccp(0, 1))
      temp4:setScaleX(-1)
      self._SelectObjList = {
        temp1,
        temp2,
        temp3,
        temp4
      }
    end
  elseif self._SelectObjList then
    for _, obj in pairs(self._SelectObjList) do
      obj:setVisible(false)
    end
  end
end
function CBpInfoPageHuodongIcon:OnClick()
  if self.m_ClickListener then
    self.m_ClickListener(self.m_HuodongId)
  end
end
function CBpInfoPageHuodongIcon:OnTouchIcon(touchInside)
  if touchInside then
    self:setScale(1.05)
  else
    self:setScale(1)
  end
end
function CBpInfoPageHuodongIcon:onCleanup()
  self.m_ClickListener = nil
end
