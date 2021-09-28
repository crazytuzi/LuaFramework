CPlayerInfoOfMapBase = class("CPlayerInfoOfMapBase", CcsSubView)
function CPlayerInfoOfMapBase:ctor(pid, viewPath)
  CPlayerInfoOfMapBase.super.ctor(self, viewPath)
  self.m_PlayerId = pid
  self.m_Name = ""
  self.txt_name = self:getNode("txt_name")
  self.txt_race = self:getNode("txt_race")
  self.txt_level = self:getNode("txt_level")
  self.txt_id = self:getNode("txt_id")
  self.txt_bp = self:getNode("txt_bp")
  if self.txt_bp then
    self.txt_bp:setColor(BpNameColor)
  end
  self.txt_id:setFontSize(20)
  self.txt_id:setText(string.format("ID:%s", tostring(self.m_PlayerId)))
  local btnBatchListener = {
    btn_chat = {
      listener = handler(self, self.Btn_Chat),
      variName = "btn_chat"
    },
    btn_hyd = {
      listener = handler(self, self.Btn_HaoYouDu),
      variName = "btn_hyd"
    },
    btn_friend = {
      listener = handler(self, self.Btn_Friend),
      variName = "btn_friend"
    },
    btn_delfriend = {
      listener = handler(self, self.Btn_DelelteFriend),
      variName = "btn_delfriend"
    },
    btn_makecaptain = {
      listener = handler(self, self.Btn_MakeCaptain),
      variName = "btn_makecaptain"
    },
    btn_kickout = {
      listener = handler(self, self.Btn_KickOut),
      variName = "btn_kickout"
    },
    btn_maketeam = {
      listener = handler(self, self.Btn_MakeTeam),
      variName = "btn_maketeam"
    },
    btn_pvp = {
      listener = handler(self, self.Btn_Pvp),
      variName = "btn_pvp"
    },
    btn_requestcaptain = {
      listener = handler(self, self.Btn_RequestCaptain),
      variName = "btn_requestcaptain"
    },
    btn_pingbi = {
      listener = handler(self, self.Btn_PingBi),
      variName = "btn_pingbi"
    },
    btn_jubao = {
      listener = handler(self, self.Btn_JuBao),
      variName = "btn_jubao"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:SetButtons()
  self:enableCloseWhenTouchOutside(self:getNode("bg"), true)
  self:ListenMessage(MsgID_BP)
end
function CPlayerInfoOfMapBase:OnMessage(msgSID, ...)
  if msgSID == MsgID_BP_OtherPlayerBPInfo then
    local arg = {
      ...
    }
    local pid = arg[1]
    local bpName = arg[2]
    if pid == self.m_PlayerId and bpName ~= nil and self.txt_bp then
      self.txt_bp:setText(bpName)
    end
  end
end
function CPlayerInfoOfMapBase:SetInfo(name, race, zs, lv, bpName)
  self.m_Name = name
  self.m_Zs = zs
  if self.txt_name then
    self.txt_name:setText(name)
    local nameColor = NameColor_MainHero[zs]
    if nameColor then
      self.txt_name:setColor(nameColor)
    end
  end
  if self.txt_race then
    local raceTxt = RACENAME_DICT[race] or ""
    self.txt_race:setText(raceTxt)
  end
  if self.txt_level then
    self.txt_level:setText(string.format("%d转%d级", zs, lv))
  end
  if bpName == nil then
    local role = g_TeamMgr:getPlayerMainHero(self.m_PlayerId)
    if role then
      bpName = role:getProperty(PROPERTY_BPNAME)
      print("---->>>优先从场景里读取玩家缓存的帮派帮派信息:", bpName)
    end
    if bpName == nil or bpName == 0 or bpName == "" then
      bpName = g_BpMgr:getPlayerBangPaiName(self.m_PlayerId)
      print("----->>读取本地缓存信息", self.m_PlayerId, bpName)
    end
  end
  if bpName == nil then
    self.txt_bp:setText("")
    print("----->查询帮派信息:", self.m_PlayerId)
    netsend.netmap.queryPlayerBangPaiName(self.m_PlayerId)
  elseif self.txt_bp then
    if type(bpName) == "string" then
      self.txt_bp:setText(bpName)
    else
      self.txt_bp:setText("")
    end
  end
end
function CPlayerInfoOfMapBase:HideInfo()
  if self.txt_name then
    self.txt_name:setVisible(false)
  end
  if self.txt_race then
    self.txt_race:setVisible(false)
  end
  if self.txt_level then
    self.txt_level:setVisible(false)
  end
  if self.txt_id then
    self.txt_id:setVisible(false)
  end
  if self.txt_bp then
    self.txt_bp:setVisible(false)
  end
end
function CPlayerInfoOfMapBase:SetButtons()
  if g_TeamMgr:IsPlayerOfLocalPlayerTeam(self.m_PlayerId) then
    if g_TeamMgr:localPlayerIsCaptain() then
      self.btn_requestcaptain:setEnabled(false)
    else
      self.btn_makecaptain:setEnabled(false)
      self.btn_kickout:setEnabled(false)
    end
    if self.btn_maketeam then
      self.btn_maketeam:setEnabled(false)
    end
    if self.btn_pvp then
      self.btn_pvp:setEnabled(false)
    end
    if self.btn_watch ~= nil then
      self.btn_watch:setEnabled(false)
    end
  else
    self.btn_makecaptain:setEnabled(false)
    self.btn_kickout:setEnabled(false)
    self.btn_requestcaptain:setEnabled(false)
    local pvpBtnFlag = true
    local warType = g_MapMgr:getPlayerInWarType(self.m_PlayerId)
    if self.btn_watch ~= nil then
      if not IsCanWatchWarType(warType) then
        self.btn_watch:setEnabled(false)
      else
        pvpBtnFlag = false
      end
    end
    if self.btn_pvp then
      self.btn_pvp:setEnabled(pvpBtnFlag)
    end
    if self.btn_maketeam then
      if g_TeamMgr:getLocalPlayerTeamId() == 0 then
        self.btn_maketeam:setTitleText("组队")
      else
        self.btn_maketeam:setTitleText("邀请入队")
      end
    end
  end
  if self.btn_pingbi ~= nil then
    self.btn_pingbi:setEnabled(self:isShowPingBi())
    if self.btn_pingbi:isEnabled() then
      local pingbi = g_MessageMgr:getPlayerIsPintBi(self.m_PlayerId)
      if pingbi then
        self.btn_pingbi:setTitleText("取消屏蔽")
      else
        self.btn_pingbi:setTitleText("屏蔽")
      end
    end
  end
  if self.btn_jubao ~= nil then
    self.btn_jubao:setEnabled(self:isShowJuBao())
  end
  if g_FriendsMgr:isLocalPlayerFriend(self.m_PlayerId) then
    self.btn_friend:setEnabled(false)
    self.btn_hyd:setEnabled(true)
  else
    self.btn_delfriend:setEnabled(false)
    self.btn_hyd:setEnabled(false)
  end
end
function CPlayerInfoOfMapBase:isShowPingBi()
  return false
end
function CPlayerInfoOfMapBase:isShowJuBao()
  return false
end
function CPlayerInfoOfMapBase:adjustPos()
  local x, y = self:getPosition()
  local parent = self:getParent()
  local size = self:getSize()
  local wPos = parent:convertToWorldSpace(ccp(x, y))
  local offy = 0
  if 0 > wPos.y then
    offy = -wPos.y
  elseif wPos.y + size.height > display.height then
    offy = display.height - wPos.y - size.height
  end
  if offy ~= 0 then
    self:setPosition(ccp(x, y + offy))
    if self.m_Arrrow ~= nil then
      local ax, ay = self.m_Arrrow:getPosition()
      self.m_Arrrow:setPosition(ccp(ax, ay - offy))
    end
  end
end
function CPlayerInfoOfMapBase:Btn_Chat(obj, t)
  if g_FriendsMgr:isLocalPlayerFriend(self.m_PlayerId) then
    self:CloseSelf()
    SendMessage(MsgID_Scene_Open_PrivateChat, self.m_PlayerId)
  else
    ShowNotifyTips("只能跟好友进行聊天")
  end
end
function CPlayerInfoOfMapBase:Btn_HaoYouDu(obj, t)
  self:CloseSelf()
  ShowYouHaoDuView({
    fID = self.m_PlayerId
  })
end
function CPlayerInfoOfMapBase:Btn_Friend(obj, t)
  local nameColor = NameColor_MainHero[self.m_Zs] or ccc3(255, 255, 255)
  CPopWarning.new({
    title = "提示",
    text = string.format("你申请添加好友:#<r:%d,g:%d,b:%d>%s#", nameColor.r, nameColor.g, nameColor.b, self.m_Name),
    confirmFunc = function()
      self:CloseSelf()
      g_FriendsMgr:send_addFriend(self.m_PlayerId)
    end
  })
  self:CloseSelf()
end
function CPlayerInfoOfMapBase:Btn_DelelteFriend(obj, t)
  local nameColor = NameColor_MainHero[self.m_Zs] or ccc3(255, 255, 255)
  CPopWarning.new({
    title = "提示",
    text = string.format("确定要删除好友#<r:%d,g:%d,b:%d>%s#吗?", nameColor.r, nameColor.g, nameColor.b, self.m_Name),
    confirmFunc = function()
      self:CloseSelf()
      g_FriendsMgr:send_deleteFriend(self.m_PlayerId)
    end
  })
  self:CloseSelf()
end
function CPlayerInfoOfMapBase:Btn_MakeCaptain(obj, t)
  if not g_TeamMgr:localPlayerIsCaptain() then
    ShowNotifyTips("必须是队长才能进行此项操作")
    return
  end
  if not g_TeamMgr:IsPlayerOfLocalPlayerTeam(self.m_PlayerId) then
    ShowNotifyTips("玩家不在你的队伍中")
    return
  end
  if g_TeamMgr:getPlayerTeamState(self.m_PlayerId) == TEAMSTATE_LEAVE then
    ShowNotifyTips("该玩家未归队，不能成为队长")
    return
  end
  self:CloseSelf()
  g_TeamMgr:send_MakeTeamCaptain(self.m_PlayerId)
end
function CPlayerInfoOfMapBase:Btn_KickOut(obj, t)
  if not g_TeamMgr:localPlayerIsCaptain() then
    ShowNotifyTips("必须是队长才能进行此项操作")
    return
  end
  if not g_TeamMgr:IsPlayerOfLocalPlayerTeam(self.m_PlayerId) then
    ShowNotifyTips("玩家不在你的队伍中")
    return
  end
  self:CloseSelf()
  g_TeamMgr:send_KickOutPlayer(self.m_PlayerId)
end
function CPlayerInfoOfMapBase:Btn_MakeTeam(obj, t)
  self:CloseSelf()
  local teamId = g_TeamMgr:getPlayerTeamId(self.m_PlayerId)
  if teamId == 0 then
    g_TeamMgr:send_InvitePlayer(self.m_PlayerId)
  else
    local localPlayerTeamId = g_TeamMgr:getLocalPlayerTeamId()
    if localPlayerTeamId == 0 then
      g_TeamMgr:send_ApplyToTeam(teamId, self.m_Name)
    elseif localPlayerTeamId == teamId then
      ShowNotifyTips("该玩家已在你的队伍中")
    else
      ShowNotifyTips("该玩家已在另一个队伍中")
    end
  end
end
function CPlayerInfoOfMapBase:Btn_Pvp(obj, t)
  self:CloseSelf()
  if g_TeamMgr:IsPlayerOfLocalPlayerTeam(self.m_PlayerId) then
    ShowNotifyTips("不能与队友进行切磋")
    return
  end
  if g_MapMgr:getPlayerInWarType(self.m_PlayerId) then
    ShowNotifyTips("对方正在战斗中,不能进行切磋")
    return
  end
  if g_LocalPlayer:getPlayerIsInTeam() and not g_LocalPlayer:getPlayerInTeamAndIsCaptain() then
    ShowNotifyTips("必须是队长才能进行此项操作")
    return
  end
  if g_TeamMgr:getPlayerTeamId(self.m_PlayerId) ~= 0 and g_TeamMgr:getPlayerTeamState(self.m_PlayerId) == TEAMSTATE_LEAVE then
    ShowNotifyTips("不能对暂离状态的玩家发起切磋")
    return
  end
  netsend.netteamwar.requestQieCuo(self.m_PlayerId)
end
function CPlayerInfoOfMapBase:Btn_RequestCaptain()
  self:CloseSelf()
  g_TeamMgr:send_RequestCaptain()
end
function CPlayerInfoOfMapBase:Btn_Watch(obj, t)
  self:CloseSelf()
  local warType = g_MapMgr:getPlayerInWarType(self.m_PlayerId)
  if IsCanWatchWarType(warType) then
    netsend.netteamwar.requestWatchWar(self.m_PlayerId)
  end
end
function CPlayerInfoOfMapBase:Btn_PingBi()
  self:CloseSelf()
  local pingbi = g_MessageMgr:getPlayerIsPintBi(self.m_PlayerId)
  local pid = self.m_PlayerId
  local name = self.m_Name
  local nameColor = NameColor_MainHero[self.m_Zs]
  if pingbi then
    local dlg = CPopWarning.new({
      title = "提示",
      text = string.format(" 你确定要移除屏蔽玩家#<r:%d,g:%d,b:%d>%s#吗？ ", nameColor.r, nameColor.g, nameColor.b, name),
      confirmFunc = function(...)
        netsend.netbaseptc.removePingbiName(pid)
      end,
      confirmText = "确定",
      cancelText = "取消"
    })
    dlg:ShowCloseBtn(false)
  else
    local dlg = CPopWarning.new({
      title = "提示",
      text = string.format(" 你确定要屏蔽玩家#<r:%d,g:%d,b:%d>%s#在世界频道的信息吗？ ", nameColor.r, nameColor.g, nameColor.b, self.m_Name),
      confirmFunc = function()
        netsend.netbaseptc.addPingbiName(pid)
      end,
      confirmText = "确定",
      cancelText = "取消"
    })
    dlg:ShowCloseBtn(false)
  end
end
function CPlayerInfoOfMapBase:Btn_JuBao()
  self:CloseSelf()
  getCurSceneView():addSubView({
    subView = CJuBaoView.new(self.m_PlayerId, self.m_Name, self.m_msg),
    zOrder = MainUISceneZOrder.menuView
  })
  print("--->>>Btn_JuBao")
end
function CPlayerInfoOfMapBase:adjustBtnPos(objNameList, offy, dyBtnFlag)
  local anyObj = false
  local offAddFlag = true
  for _, name in pairs(objNameList) do
    local obj = self:getNode(name)
    if obj then
      if obj:isEnabled() then
        local x, y = obj:getPosition()
        obj:setPosition(ccp(x, y - offy))
        offAddFlag = false
      end
      anyObj = true
    end
  end
  if anyObj and offAddFlag and dyBtnFlag ~= false then
    offy = offy + 65
  end
  return offy
end
function CPlayerInfoOfMapBase:Clear()
end
CPlayerInfoOfMap = class("CPlayerInfoOfMap", CPlayerInfoOfMapBase)
function CPlayerInfoOfMap:ctor(pid, closeListener, jsonPath)
  jsonPath = jsonPath or "views/playerInfoOfMap.json"
  CPlayerInfoOfMap.super.ctor(self, pid, jsonPath)
  self.m_CloseListener = closeListener
  self:setRoleInfo(pid)
  self:updateSize()
end
function CPlayerInfoOfMap:updateSize()
  local offy = 0
  offy = self:adjustBtnPos({"btn_jubao"}, offy)
  offy = self:adjustBtnPos({"btn_pingbi"}, offy)
  offy = self:adjustBtnPos({
    "btn_pvp",
    "btn_watch",
    "btn_kickout"
  }, offy)
  offy = self:adjustBtnPos({
    "btn_maketeam",
    "btn_makecaptain",
    "btn_requestcaptain"
  }, offy)
  offy = self:adjustBtnPos({
    "btn_friend",
    "btn_delfriend"
  }, offy)
  offy = self:adjustBtnPos({"btn_hyd"}, offy)
  offy = self:adjustBtnPos({"btn_chat"}, offy)
  self:adjustBtnPos({
    "bg_2",
    "txt_race",
    "txt_level",
    "txt_name",
    "txt_id",
    "txt_bp",
    "pic_headbg"
  }, offy)
  if offy > 0 then
    self.bg = self:getNode("bg")
    local size = self.bg:getSize()
    local w = size.width
    local h = size.height - offy
    self.bg:setSize(CCSize(w, h))
    self.m_UINode:setSize(CCSize(w, h))
  end
end
function CPlayerInfoOfMap:setRoleInfo(pid)
  local role = g_TeamMgr:getPlayerMainHero(pid)
  if role then
    local name = role:getProperty(PROPERTY_NAME)
    local race = role:getProperty(PROPERTY_RACE)
    local zs = role:getProperty(PROPERTY_ZHUANSHENG)
    local lv = role:getProperty(PROPERTY_ROLELEVEL)
    local bpName = role:getProperty(PROPERTY_BPNAME)
    self:SetInfo(name, race, zs, lv, bpName)
  else
    self:HideInfo()
  end
end
function CPlayerInfoOfMap:SetButtons()
  if self.btn_watch == nil then
    local btnBatchListener = {
      btn_watch = {
        listener = handler(self, self.Btn_Watch),
        variName = "btn_watch"
      }
    }
    self:addBatchBtnListener(btnBatchListener)
  end
  CPlayerInfoOfMap.super.SetButtons(self)
end
function CPlayerInfoOfMap:Clear()
  CPlayerInfoOfMap.super.Clear(self)
  if self.m_CloseListener then
    self.m_CloseListener(self)
  end
end
