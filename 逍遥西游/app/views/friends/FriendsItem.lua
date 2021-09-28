local CFriendItemBase = class("CFriendItemBase", CcsSubView)
function CFriendItemBase:ctor(pid, info, jsonpath)
  CFriendItemBase.super.ctor(self, jsonpath)
  self.m_PlayerId = pid
  self.m_Info = info
  self:setContent(info)
end
function CFriendItemBase:setContent(info)
  if info.name ~= nil then
    local name = info.name
    self.txt_name = self:getNode("txt_name")
    self.txt_name:setText(name)
    self.m_Info.name = info.name
    if self.m_Info.zs ~= nil then
      local color = NameColor_MainHero[self.m_Info.zs] or NameColor_MainHero[0]
      self.txt_name:setColor(color)
    end
  end
  if info.rtype ~= nil then
    local race = data_getRoleRace(info.rtype)
    local raceTxt = RACENAME_DICT[race] or ""
    self.txt_race = self:getNode("txt_race")
    self.txt_race:setText(raceTxt)
    self.m_Info.rtype = info.rtype
  end
  if info.zs ~= nil then
    self.m_Info.zs = info.zs
  end
  if info.level ~= nil then
    self.m_Info.level = info.level
  end
  if info.zs ~= nil or info.level ~= nil then
    local zs = self.m_Info.zs or 0
    local level = self.m_Info.level or 0
    self.txt_level = self:getNode("txt_level")
    self.txt_level:setText(string.format("%d转%d级", zs, level))
  end
  if info.status ~= nil then
    self.m_Status = info.status
    self.m_Info.status = info.status
    self:setStatus(info.status)
  end
  if info.rtype ~= nil then
    if self.m_HeadIcon ~= nil then
      self.m_HeadIcon:removeFromParentAndCleanup(true)
      self.m_HeadIcon = nil
    end
    self.headbg = self:getNode("headbg")
    self.headbg:setVisible(false)
    local parent = self.headbg:getParent()
    local x, y = self.headbg:getPosition()
    local size = self.headbg:getContentSize()
    local zOrder = self.headbg:getZOrder()
    self.m_HeadIcon = createClickHead({
      roleTypeId = info.rtype,
      clickListener = handler(self, self.OnClickHead)
    })
    parent:addChild(self.m_HeadIcon, zOrder + 1)
    self.m_HeadIcon:setPosition(ccp(x - size.width / 2, y - size.height / 2))
  end
  if info.fValue ~= nil then
    local txt_fvalue = self:getNode("txt_fvalue")
    if txt_fvalue then
      txt_fvalue:setText(string.format("友好:%d", info.fValue))
    end
  end
end
function CFriendItemBase:setStatus(status)
  self.staus_outline = self:getNode("staus_outline")
  self.staus_outline:setVisible(self.m_Status == GAMESTATUS_OUTLINE)
end
function CFriendItemBase:checkFriendRelation()
  if self:getNode("txt_fvalue") == nil then
    return
  end
  if self.btn_more == nil then
    return
  end
  local banlvId = g_FriendsMgr:getBanLvId()
  if banlvId ~= nil and banlvId == self.m_PlayerId then
    local iconPath
    if g_FriendsMgr:getIsBanLv(banlvId) then
      iconPath = "views/banlv/pic_jiehunicon.png"
    else
      iconPath = "views/banlv/pic_jieqiicon.png"
    end
    if self.m_MarryIcon ~= nil then
      self.m_MarryIcon:removeFromParentAndCleanup(true)
    end
    local p = self.btn_more:getParent()
    local x, y = self.btn_more:getPosition()
    local size = self.btn_more:getSize()
    local z = self.btn_more:getZOrder()
    self.m_MarryIcon = display.newSprite(iconPath)
    p:addNode(self.m_MarryIcon, z)
    local offx = -30
    local offy = -5
    self.m_MarryIcon:setPosition(ccp(x - size.width / 2 + offx, y + offy))
  elseif self.m_MarryIcon ~= nil then
    self.m_MarryIcon:removeFromParentAndCleanup(true)
    self.m_MarryIcon = nil
  end
end
function CFriendItemBase:getPlayerId()
  return self.m_PlayerId
end
function CFriendItemBase:getStatus()
  return self.m_Status
end
CFriendItem = class("CFriendItem", CFriendItemBase)
function CFriendItem:ctor(pid, info, clickHeadListener, moreListener, isNew)
  CFriendItem.super.ctor(self, pid, info, "views/frienditem.json")
  local btnBatchListener = {
    btn_more = {
      listener = handler(self, self.Btn_More),
      variName = "btn_more"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_ClickHeadListener = clickHeadListener
  self.m_MoreListener = moreListener
  self.txt_new = self:getNode("txt_new")
  self:SetIsNewFriend(isNew)
  self:checkFriendRelation()
end
function CFriendItem:SetIsNewFriend(isNew)
  if isNew == true then
    self.txt_new:setVisible(true)
    self:getNode("txt_fvalue"):setVisible(false)
  else
    self.txt_new:setVisible(false)
    self:getNode("txt_fvalue"):setVisible(true)
  end
end
function CFriendItem:OnClickHead()
  if self.m_ClickHeadListener then
    self.m_ClickHeadListener(self.m_PlayerId)
  end
end
function CFriendItem:Btn_More(obj, t)
  if self.m_MoreListener then
    local x, y = self.btn_more:getPosition()
    local wPos = self.btn_more:getParent():convertToWorldSpace(ccp(x, y))
    self.m_MoreListener(self.m_PlayerId, self.m_Info, wPos)
  end
end
function CFriendItem:Clear()
  self.m_ClickHeadListener = nil
  self.m_MoreListener = nil
end
CFriendItemRecently = class("CFriendItemRecently", CFriendItemBase)
function CFriendItemRecently:ctor(pid, info, clickHeadListener, moreListener)
  CFriendItem.super.ctor(self, pid, info, "views/frienditemrecently.json")
  local btnBatchListener = {
    btn_more = {
      listener = handler(self, self.Btn_More),
      variName = "btn_more"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.pic_tipnew_friend = self:getNode("pic_tipnew_friend")
  self.unread_friend = self:getNode("unread_friend")
  self.m_ClickHeadListener = clickHeadListener
  self.m_MoreListener = moreListener
  self:CheckUnreadMsg()
  self:checkFriendRelation()
end
function CFriendItemRecently:CheckUnreadMsg()
  local unreadCnt = g_MessageMgr:existUnreadPrivateMessage(self.m_PlayerId)
  self:SetUnreadMsgFlag(unreadCnt)
end
function CFriendItemRecently:SetUnreadMsgFlag(unreadCnt)
  self.m_UnreadMsgCnt = unreadCnt
  if unreadCnt > 99 then
    unreadCnt = 99
  end
  self.pic_tipnew_friend:setVisible(self.m_UnreadMsgCnt > 0)
  self.unread_friend:setText(tostring(unreadCnt))
end
function CFriendItemRecently:getUnreadMsgCnt()
  return self.m_UnreadMsgCnt
end
function CFriendItemRecently:OnClickHead()
  if self.m_ClickHeadListener then
    self.m_ClickHeadListener(self.m_PlayerId)
  end
end
function CFriendItemRecently:Btn_More(obj, t)
  if self.m_MoreListener then
    local x, y = self.btn_more:getPosition()
    local wPos = self.btn_more:getParent():convertToWorldSpace(ccp(x, y))
    self.m_MoreListener(self.m_PlayerId, self.m_Info, wPos)
  end
end
function CFriendItemRecently:Clear()
  self.m_ClickHeadListener = nil
  self.m_MoreListener = nil
end
CFindFriendItem = class("CFindFriendItem", CFriendItemBase)
function CFindFriendItem:ctor(pid, info, confirmListener, moreListener)
  CFindFriendItem.super.ctor(self, pid, info, "views/frienditem_find.json")
  local btnBatchListener = {
    btn_addfriend = {
      listener = handler(self, self.Btn_AddFriend),
      variName = "btn_addfriend"
    },
    btn_more = {
      listener = handler(self, self.Btn_More),
      variName = "btn_more"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_ConfirmListener = confirmListener
  self.m_MoreListener = moreListener
  if self.m_HeadIcon then
    self.m_HeadIcon:setTouchEnabled(false)
  end
  if pid == g_LocalPlayer:getPlayerId() then
    self.btn_more:setVisible(false)
    self.btn_more:setTouchEnabled(false)
    self.btn_addfriend:setVisible(false)
    self.btn_addfriend:setTouchEnabled(false)
  elseif g_FriendsMgr:isLocalPlayerFriend(pid) then
    self.btn_addfriend:setVisible(false)
    self.btn_addfriend:setTouchEnabled(false)
  else
    self.btn_more:setVisible(false)
    self.btn_more:setTouchEnabled(false)
  end
end
function CFindFriendItem:OnClickHead()
end
function CFindFriendItem:Btn_AddFriend(obj, t)
  g_FriendsMgr:send_addFriend(self.m_PlayerId)
  if self.m_ConfirmListener then
    self.m_ConfirmListener()
  end
end
function CFindFriendItem:Btn_More(obj, t)
  if self.m_MoreListener then
    local x, y = self.btn_more:getPosition()
    local wPos = self.btn_more:getParent():convertToWorldSpace(ccp(x, y))
    self.m_MoreListener(self.m_PlayerId, self.m_Info, wPos)
  end
end
function CFriendItem:Clear()
  self.m_ConfirmListener = nil
  self.m_MoreListener = nil
end
CFriendRequestItem = class("CFriendRequestItem", CFriendItemBase)
function CFriendRequestItem:ctor(pid, info)
  CFriendRequestItem.super.ctor(self, pid, info, "views/frienditem_request.json")
  local btnBatchListener = {
    btn_addfriend_agree = {
      listener = handler(self, self.Btn_Agree),
      variName = "btn_addfriend_agree"
    },
    btn_addfriend_refuse = {
      listener = handler(self, self.Btn_Refuse),
      variName = "btn_addfriend_refuse"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  if self.m_HeadIcon then
    self.m_HeadIcon:setTouchEnabled(false)
  end
end
function CFriendRequestItem:setStatus(status)
end
function CFriendRequestItem:OnClickHead()
end
function CFriendRequestItem:Btn_Agree(obj, t)
  g_FriendsMgr:send_agreeFriendRequest(self.m_PlayerId)
end
function CFriendRequestItem:Btn_Refuse(obj, t)
  g_FriendsMgr:send_refuseFriendRequest(self.m_PlayerId)
end
CFriendMoMoItem = class("CFriendMoMoItem", CcsSubView)
function CFriendMoMoItem:ctor()
  CFriendMoMoItem.super.ctor(self, "views/friendmomoitem.json")
  self.bg = self:getNode("bg")
end
function CFriendMoMoItem:setTouchStatus(touch)
  if touch then
    self.bg:setColor(ccc3(180, 180, 180))
  else
    self.bg:setColor(ccc3(255, 255, 255))
  end
end
CFriendItem_MoMo = class("CFriendItem_MoMo", CcsSubView)
function CFriendItem_MoMo:ctor(momoInfo)
  CFriendItem_MoMo.super.ctor(self, "views/frienditem_momo.json")
  local btnBatchListener = {
    btn_invite = {
      listener = handler(self, self.Btn_Invite),
      variName = "btn_invite"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_UserId = momoInfo.userId
  self.m_ShowDetail = false
  local txt_name = self:getNode("txt_name")
  txt_name:setText(momoInfo.name or "")
  self.defaulthead = self:getNode("defaulthead")
  self.headpos = self:getNode("headpos")
  self.headpos:setVisible(false)
  self.headpos:setOpacity(0)
  local headUrl = momoInfo.smallHeadImageURL
  if headUrl then
    local fileName = string.format("icon_%s", self.m_UserId)
    g_HeadImgRequest:reqHeadImg(fileName, headUrl, handler(self, self.OnDownLoadHeadIcon), false)
  end
  self.bg = self:getNode("bg")
  self:setHasGameRole(true)
end
function CFriendItem_MoMo:OnDownLoadHeadIcon(isSucceed, filePath, fileName)
  if self.m_ItemHasClear == true then
    return
  end
  if not isSucceed or filePath == nil then
    return
  end
  if self.m_HeadIcon ~= nil then
    return
  end
  local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(filePath)
  if not os.exists(fullPath) then
    print("------->>>>>>>陌陌头像回调异常！ 收到了回调但是图片获取不到", filePath, fileName)
    return
  end
  self.defaulthead:setVisible(false)
  self.headpos:setVisible(true)
  local size = self.headpos:getContentSize()
  local x, y = self.headpos:getPosition()
  self.m_HeadIcon = display.newSprite(filePath)
  self.headpos:addNode(self.m_HeadIcon, 99)
  self.m_HeadIcon:setPosition(ccp(size.width / 2, size.height / 2))
  local hSize = self.m_HeadIcon:getContentSize()
  local s1 = size.width / hSize.width
  local s2 = size.height / hSize.height
  local s = math.max(s1, s2)
  self.m_HeadIcon:setScale(s)
end
function CFriendItem_MoMo:getUserId()
  return self.m_UserId
end
function CFriendItem_MoMo:getIsShowDetail()
  return self.m_ShowDetail
end
function CFriendItem_MoMo:setIsShowDetail(iShow)
  self.m_ShowDetail = iShow
end
function CFriendItem_MoMo:setTouchStatus(touch)
  if touch then
    self.bg:setColor(ccc3(180, 180, 180))
  else
    self.bg:setColor(ccc3(255, 255, 255))
  end
end
function CFriendItem_MoMo:setHasGameRole(flag)
  self.m_HasGameRole = flag
  self.btn_invite:setVisible(not flag)
  self.btn_invite:setTouchEnabled(not flag)
end
function CFriendItem_MoMo:getHasGameRole()
  return self.m_HasGameRole
end
function CFriendItem_MoMo:Btn_Invite()
  netsend.login.queryMoMoPlayerInviteTimes(self.m_UserId)
end
function CFriendItem_MoMo:Clear()
  self.m_ItemHasClear = true
end
CFriendItem_MoMo_Split = class("CFriendItem_MoMo_Split", CcsSubView)
function CFriendItem_MoMo_Split:ctor(listener, showPreBtn, showNextBtn)
  CFriendItem_MoMo_Split.super.ctor(self, "views/frienditem_momo_pagesplit.json")
  local btnBatchListener = {
    btn_prepage = {
      listener = handler(self, self.Btn_PrePage),
      variName = "btn_prepage"
    },
    btn_nextpage = {
      listener = handler(self, self.Btn_NextPage),
      variName = "btn_nextpage"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_Listener = listener
  self.btn_prepage:setVisible(showPreBtn)
  self.btn_prepage:setTouchEnabled(showPreBtn)
  self.btn_nextpage:setVisible(showNextBtn)
  self.btn_nextpage:setTouchEnabled(showNextBtn)
end
function CFriendItem_MoMo_Split:Btn_PrePage()
  if self.m_Listener then
    self.m_Listener(false)
  end
end
function CFriendItem_MoMo_Split:Btn_NextPage()
  if self.m_Listener then
    self.m_Listener(true)
  end
end
function CFriendItem_MoMo_Split:setTouchStatus(touch)
end
function CFriendItem_MoMo_Split:Clear()
  self.m_Listener = nil
end
CFriendItem_MoMo_Role = class("CFriendItem_MoMo_Role", CcsSubView)
function CFriendItem_MoMo_Role:ctor(userId, roleInfo, moreListener)
  CFriendItem_MoMo_Role.super.ctor(self, "views/frienditem_momo_role.json")
  local btnBatchListener = {
    btn_more = {
      listener = handler(self, self.Btn_More),
      variName = "btn_more"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_UserId = userId
  self.m_MoreListener = moreListener
  self.m_PlayerId = roleInfo.rid
  local localSvrId, _, _ = g_DataMgr:getChoosedLoginServerInfo()
  if localSvrId == roleInfo.kid then
    self.btn_more:setVisible(true)
    self.btn_more:setTouchEnabled(true)
    if self.m_PlayerId ~= nil then
      local tempInfo = g_TeamMgr:getPlayerInfo(self.m_PlayerId)
      if tempInfo ~= nil then
        if tempInfo.zs > roleInfo.rb or tempInfo.zs == roleInfo.rb and tempInfo.level > roleInfo.rb then
          roleInfo.name = tempInfo.name
          roleInfo.rtype = tempInfo.rtype
          roleInfo.rb = tempInfo.zs
          roleInfo.lv = tempInfo.level
          print("--->>>从组队信息里更新到更新的信息", self.m_PlayerId)
        else
          tempInfo = nil
        end
      end
      if tempInfo == nil then
        tempInfo = g_FriendsMgr:getPlayerInfo(self.m_PlayerId)
        if tempInfo ~= nil and (tempInfo.zs > roleInfo.rb or tempInfo.zs == roleInfo.rb and tempInfo.level > roleInfo.rb) then
          roleInfo.name = tempInfo.name
          roleInfo.rtype = tempInfo.rtype
          roleInfo.rb = tempInfo.zs
          roleInfo.lv = tempInfo.level
          print("--->>>从好友信息里更新到更新的信息", self.m_PlayerId)
        end
      end
    end
  else
    self.btn_more:setVisible(false)
    self.btn_more:setTouchEnabled(false)
  end
  self.m_Info = {
    name = roleInfo.name,
    rtype = roleInfo.rtype,
    zs = roleInfo.rb,
    level = roleInfo.lv,
    momoUserId = userId
  }
  local txt_name = self:getNode("txt_name")
  txt_name:setText(roleInfo.name or "")
  local color = NameColor_MainHero[roleInfo.rb] or NameColor_MainHero[0]
  txt_name:setColor(color)
  local txt_svr = self:getNode("txt_svr")
  local serverId = roleInfo.kid
  local serList = g_DataMgr:getServerList()
  local serData = serList[serverId] or {}
  if serData.name ~= nil then
    txt_svr:setText(serData.name)
    txt_svr:setVisible(true)
  else
    txt_svr:setVisible(false)
  end
  local race = data_getRoleRace(roleInfo.rtype)
  local raceTxt = RACENAME_DICT[race] or ""
  local txt_race = self:getNode("txt_race")
  txt_race:setText(raceTxt)
  local zs = roleInfo.rb or 0
  local level = roleInfo.lv or 0
  local txt_level = self:getNode("txt_level")
  txt_level:setText(string.format("%d转%d级", zs, level))
  self.headbg = self:getNode("headbg")
  local parent = self.headbg:getParent()
  local x, y = self.headbg:getPosition()
  local size = self.headbg:getContentSize()
  local zOrder = self.headbg:getZOrder()
  local s = 0.6
  self.m_HeadIcon = createHeadIconByRoleTypeID(roleInfo.rtype)
  parent:addNode(self.m_HeadIcon, zOrder + 1)
  self.m_HeadIcon:setPosition(ccp(x + HEAD_OFF_X * s, y + HEAD_OFF_Y * s))
  self.m_HeadIcon:setScale(s)
end
function CFriendItem_MoMo_Role:getUserId()
  return self.m_UserId
end
function CFriendItem_MoMo_Role:Btn_More()
  if self.m_MoreListener then
    local x, y = self.btn_more:getPosition()
    local wPos = self.btn_more:getParent():convertToWorldSpace(ccp(x, y))
    self.m_MoreListener(self.m_PlayerId, self.m_Info, wPos)
  end
end
function CFriendItem_MoMo_Role:showArrowIcon()
end
function CFriendItem_MoMo_Role:Clear()
  self.m_MoreListener = nil
end
