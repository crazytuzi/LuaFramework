CBpMemberMenu = class("CBpMemberMenu", CcsSubView)
function CBpMemberMenu:ctor(pInfo)
  CBpMemberMenu.super.ctor(self, "views/bpmembermenu.json")
  self.m_PlayerInfo = pInfo
  local btnBatchListener = {
    btn_friend = {
      listener = handler(self, self.OnBtn_Friend),
      variName = "btn_friend"
    },
    btn_banword = {
      listener = handler(self, self.OnBtn_BanWord),
      variName = "btn_banword"
    },
    btn_manage = {
      listener = handler(self, self.OnBtn_Manage),
      variName = "btn_manage"
    },
    btn_team = {
      listener = handler(self, self.OnBtn_Team),
      variName = "btn_team"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:enableCloseWhenTouchOutside(self:getNode("bg"), true)
  self:ListenMessage(MsgID_BP)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CBpMemberMenu:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_BpDlgIsInvalid then
    self:CloseSelf()
  end
end
function CBpMemberMenu:OnBtn_Friend()
  if g_FriendsMgr:isLocalPlayerFriend(self.m_PlayerInfo.pid) then
    local nameColor = NameColor_MainHero[self.m_PlayerInfo.zs] or ccc3(255, 255, 255)
    ShowNotifyTips(string.format("#<r:%d,g:%d,b:%d>%s##<W>已经是你的好友#", nameColor.r, nameColor.g, nameColor.b, self.m_PlayerInfo.name))
  else
    local nameColor = NameColor_MainHero[self.m_PlayerInfo.zs] or ccc3(255, 255, 255)
    CPopWarning.new({
      title = "提示",
      text = string.format("你申请添加好友:#<r:%d,g:%d,b:%d>%s#", nameColor.r, nameColor.g, nameColor.b, self.m_PlayerInfo.name),
      confirmFunc = function()
        self:CloseSelf()
        g_FriendsMgr:send_addFriend(self.m_PlayerInfo.pid)
      end
    })
  end
end
function CBpMemberMenu:OnBtn_BanWord()
  local place = g_BpMgr:getLocalBpPlace()
  local bpData = data_Org_Auth[place]
  if bpData and bpData.AuthBanSpeak == 1 then
    self:CloseSelf()
    CBpBanWord.new(self.m_PlayerInfo)
  else
    ShowNotifyTips("你没有相关的权限哟")
  end
end
function CBpMemberMenu:OnBtn_Manage()
  local place = g_BpMgr:getLocalBpPlace()
  local bpData = data_Org_Auth[place]
  if bpData and not table_is_empty(bpData.AuthSetJob) and not table_is_empty(bpData.AuthDelJob) then
    self:CloseSelf()
    CBpManage.new(self.m_PlayerInfo)
  else
    ShowNotifyTips("你没有相关的权限哟")
  end
end
function CBpMemberMenu:OnBtn_Team()
  if self.m_PlayerInfo.st < 0 then
    local pid = self.m_PlayerInfo.pid
    if pid ~= g_LocalPlayer:getPlayerId() then
      self:CloseSelf()
      g_TeamMgr:send_InvitePlayer(pid)
    end
  else
    ShowNotifyTips("该玩家不在线，不能进行组队")
  end
end
CBpBanWord = class("CBpBanWord", CcsSubView)
function CBpBanWord:ctor(pInfo)
  CBpBanWord.super.ctor(self, "views/bpbanword.json", {isAutoCenter = true, opacityBg = 100})
  self.m_PlayerInfo = pInfo
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_ban = {
      listener = handler(self, self.OnBtn_BanWord),
      variName = "btn_ban"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local pos_head = self:getNode("pos_head")
  pos_head:setVisible(false)
  local parent = pos_head:getParent()
  local x, y = pos_head:getPosition()
  local size = pos_head:getContentSize()
  local head = createWidgetFrameHeadIconByRoleTypeID(pInfo.sid)
  parent:addChild(head)
  head:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:getNode("txt_name"):setText(pInfo.name)
  local nameColor = NameColor_MainHero[pInfo.zs] or ccc3(255, 255, 255)
  self:getNode("txt_name"):setColor(nameColor)
  local race = data_getRoleRace(pInfo.sid)
  self:getNode("txt_race"):setText(RACENAME_DICT[race] or "")
  self:getNode("txt_level"):setText(string.format("%d转%d级", pInfo.zs, pInfo.lv))
  local place = pInfo.jid
  self:getNode("txt_place"):setText(data_getBangpaiPlaceName(place))
  self:getNode("txt_time"):setText(os.date("%Y-%m-%d", pInfo.t))
  self:getNode("txt_gx"):setText(tostring(pInfo.off))
  self.m_BanWordTime = 0
  self:SetTime()
  self:ListenMessage(MsgID_BP)
  self:ListenMessage(MsgID_Connect)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
  g_BpMgr:send_getBanWordTime(self.m_PlayerInfo.pid)
  self.m_Handler = scheduler.scheduleGlobal(handler(self, self.updateTime), 1)
end
function CBpBanWord:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_BanWordTime then
    local arg = {
      ...
    }
    local pid = arg[1]
    local time = arg[2]
    if pid == self.m_PlayerInfo.pid then
      self.m_BanWordTime = time
      self:SetTime()
    end
  elseif msgSID == MsgID_BP_BpDlgIsInvalid then
    self:CloseSelf()
  elseif msgSID == MsgID_ServerTime then
    g_BpMgr:send_getBanWordTime(self.m_PlayerInfo.pid)
  end
end
function CBpBanWord:updateTime()
  if self.m_BanWordTime < 0 then
    return
  end
  self.m_BanWordTime = self.m_BanWordTime - 1
  self:SetTime()
end
function CBpBanWord:SetTime()
  if self.m_BanWordTime > 0 then
    self:getNode("title_banword"):setVisible(true)
    self:getNode("txt_banword"):setVisible(true)
    self:getNode("txt_banword"):setText(string.format("%d分钟", math.ceil(self.m_BanWordTime / 60)))
  else
    self:getNode("title_banword"):setVisible(false)
    self:getNode("txt_banword"):setVisible(false)
  end
end
function CBpBanWord:OnBtn_Close()
  self:CloseSelf()
end
function CBpBanWord:OnBtn_BanWord()
  self:CloseSelf()
  g_BpMgr:send_banWordOfPlayer(self.m_PlayerInfo.pid)
end
function CBpBanWord:OnBtn_Cancel()
  self:CloseSelf()
  g_BpMgr:send_cancelBanWordOfPlayer(self.m_PlayerInfo.pid)
end
function CBpBanWord:Clear()
  if self.m_Handler then
    scheduler.unscheduleGlobal(self.m_Handler)
    self.m_Handler = nil
  end
end
CBpManage = class("CBpManage", CcsSubView)
function CBpManage:ctor(pInfo)
  CBpManage.super.ctor(self, "views/bpmanage.json", {isAutoCenter = true, opacityBg = 100})
  self.m_PlayerInfo = pInfo
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_appoint = {
      listener = handler(self, self.OnBtn_Appoint),
      variName = "btn_appoint"
    },
    btn_kickout = {
      listener = handler(self, self.OnBtn_KickOut),
      variName = "btn_kickout"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local pos_head = self:getNode("pos_head")
  pos_head:setVisible(false)
  local parent = pos_head:getParent()
  local x, y = pos_head:getPosition()
  local size = pos_head:getContentSize()
  local head = createWidgetFrameHeadIconByRoleTypeID(pInfo.sid)
  parent:addChild(head)
  head:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:getNode("txt_name"):setText(pInfo.name)
  local nameColor = NameColor_MainHero[pInfo.zs] or ccc3(255, 255, 255)
  self:getNode("txt_name"):setColor(nameColor)
  local race = data_getRoleRace(pInfo.sid)
  self:getNode("txt_race"):setText(RACENAME_DICT[race] or "")
  self:getNode("txt_level"):setText(string.format("%d转%d级", pInfo.zs, pInfo.lv))
  local place = pInfo.jid
  self:getNode("txt_place"):setText(data_getBangpaiPlaceName(place))
  self:getNode("txt_time"):setText(os.date("%Y-%m-%d", pInfo.t))
  self:getNode("txt_gx"):setText(tostring(pInfo.off))
  self:ListenMessage(MsgID_BP)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
end
function CBpManage:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_UpdateMemberInfo then
    local arg = {
      ...
    }
    local pid = arg[1]
    if pid == self.m_PlayerInfo.pid then
      local info = arg[2]
      if info.jid ~= nil then
        self:getNode("txt_place"):setText(data_getBangpaiPlaceName(info.jid))
      end
    end
  elseif msgSID == MsgID_BP_BpDlgIsInvalid then
    self:CloseSelf()
  end
end
function CBpManage:OnBtn_Close()
  self:CloseSelf()
end
function CBpManage:OnBtn_Appoint()
  local place = g_BpMgr:getLocalBpPlace()
  local bpData = data_Org_Auth[place]
  if bpData and listContain(bpData.AuthSetJob, self.m_PlayerInfo.jid) then
    print_lua_table(bpData.AuthSetJob)
    self:setDlgShow(false)
    CBpAppoint.new(self.m_PlayerInfo, function()
      self:setDlgShow(true)
    end)
  else
    ShowNotifyTips("你不能任命比你高职位的人哟")
  end
end
function CBpManage:OnBtn_KickOut()
  local place = g_BpMgr:getLocalBpPlace()
  local bpData = data_Org_Auth[place]
  if bpData and listContain(bpData.AuthDelJob, self.m_PlayerInfo.jid) then
    self:setDlgShow(false)
    local dlg = CPopWarning.new({
      text = "你确定要逐出该玩家吗?",
      confirmFunc = handler(self, self.kickOut),
      clearFunc = handler(self, self.kickOutCanceled),
      cancelText = "取消",
      confirmText = "确定"
    })
    dlg:ShowCloseBtn(false)
  else
    ShowNotifyTips("你不能开除比你高职位的人哟")
  end
end
function CBpManage:kickOut()
  self:CloseSelf()
  g_BpMgr:send_kickOutBpMember(self.m_PlayerInfo.pid)
end
function CBpManage:kickOutCanceled()
  self:setDlgShow(true)
end
function CBpManage:setDlgShow(iShow)
  self:setEnabled(iShow)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setEnabled(iShow)
  end
end
CBpAppoint = class("CBpAppoint", CcsSubView)
function CBpAppoint:ctor(pInfo, closeListener)
  CBpAppoint.super.ctor(self, "views/bpappoint.json", {isAutoCenter = true, opacityBg = 100})
  self.m_PlayerInfo = pInfo
  self.m_CloseListener = closeListener
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local lastHidePlaceBtn
  local offy = 0
  local localPlace = g_BpMgr:getLocalBpPlace()
  local bpData = data_Org_Auth[localPlace] or {}
  local setJobList = bpData.AuthSetJob or {}
  for placeId = 2, 9 do
    do
      local placeBtn = self:addBtnListener(string.format("btn_place_%d", placeId), function()
        self:OnBtn_Place(placeId)
      end)
      local placeName = self:getNode(string.format("txt_place_%d", placeId))
      local placeNum = self:getNode(string.format("txt_num_%d", placeId))
      local helpBtn = self:getNode(string.format("btn_help_%d", placeId))
      if listContain(setJobList, placeId) then
        if lastHidePlaceBtn ~= nil then
          local _, y1 = lastHidePlaceBtn:getPosition()
          local _, y2 = placeBtn:getPosition()
          offy = y1 - y2
          lastHidePlaceBtn = nil
        end
        local x, y = placeBtn:getPosition()
        placeBtn:setPosition(ccp(x, y + offy))
        local x, y = placeName:getPosition()
        placeName:setPosition(ccp(x, y + offy))
        local x, y = placeNum:getPosition()
        placeNum:setPosition(ccp(x, y + offy))
        local x, y = helpBtn:getPosition()
        helpBtn:setPosition(ccp(x, y + offy))
        placeNum:setEnabled(false)
      else
        placeBtn:setEnabled(false)
        placeName:setEnabled(false)
        placeNum:setEnabled(false)
        helpBtn:setEnabled(false)
        if lastHidePlaceBtn == nil then
          lastHidePlaceBtn = placeBtn
        end
      end
    end
  end
  self.img_selected = self:getNode("img_selected")
  self:selectAtPlace(self.m_PlayerInfo.jid)
  self:SetAttrTips()
  self:ListenMessage(MsgID_BP)
  getCurSceneView():addSubView({
    subView = self,
    zOrder = MainUISceneZOrder.menuView
  })
  g_BpMgr:send_getBpPlaceNumInfo()
end
function CBpAppoint:SetAttrTips()
  clickArea_check.extend(self)
  for placeId = 2, 9 do
    local helpBtn = self:getNode(string.format("btn_help_%d", placeId))
    if helpBtn:isEnabled() then
      local descKey = string.format("bpplace_%d", placeId)
      self:attrclick_check_withWidgetObj(helpBtn, descKey)
    end
  end
end
function CBpAppoint:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_PlaceNumInfo then
    local arg = {
      ...
    }
    local info = arg[1]
    for placeId = 1, 9 do
      self:setPlaceNumInfo(placeId, info[placeId])
    end
  elseif msgSID == MsgID_BP_BpDlgIsInvalid then
    self:CloseSelf()
  end
end
function CBpAppoint:setPlaceNumInfo(placeId, num)
  if num == nil then
    num = 0
  end
  local placeName = self:getNode(string.format("txt_place_%d", placeId))
  local placeNumTxt = self:getNode(string.format("txt_num_%d", placeId))
  if placeName and placeNumTxt and placeName:isEnabled() then
    local maxNum = data_getBangpaiPlaceNumLimit(placeId)
    placeNumTxt:setText(string.format("%d/%d", num, maxNum))
    placeNumTxt:setEnabled(true)
  end
end
function CBpAppoint:selectAtPlace(placeId)
  local placeBtn = self:getNode(string.format("btn_place_%d", placeId))
  if placeBtn then
    local x, y = placeBtn:getPosition()
    self.img_selected:setPosition(ccp(x + 18, y + 8))
    self.m_SelectPlaceId = placeId
    self.img_selected:setVisible(true)
  else
    self.img_selected:setVisible(false)
  end
end
function CBpAppoint:OnBtn_Place(placeId)
  self:selectAtPlace(placeId)
end
function CBpAppoint:OnBtn_Confirm()
  print("--->>OnBtn_Confirm:", self.m_PlayerInfo.jid, self.m_SelectPlaceId)
  if self.m_PlayerInfo.jid ~= self.m_SelectPlaceId then
    g_BpMgr:send_setBangPaiPlace(self.m_PlayerInfo.pid, self.m_SelectPlaceId)
  end
  self:CloseSelf()
end
function CBpAppoint:OnBtn_Cancel()
  self:CloseSelf()
end
function CBpAppoint:OnBtn_Close()
  self:CloseSelf()
end
function CBpAppoint:Clear()
  if self.m_CloseListener then
    self.m_CloseListener()
    self.m_CloseListener = nil
  end
end
