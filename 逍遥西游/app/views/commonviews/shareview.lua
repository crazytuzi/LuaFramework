function ShowShareView_DaShuMovie()
  print("达叔电影票分享")
  if g_ChannelMgr == nil then
    print("没有g_ChannelMgr,不能分享")
    return
  end
  local momoFlag = false
  if channel.showMoMoFriendList == true then
    local userInfo = g_ChannelMgr:getUserInfo()
    if userInfo.userType == 3 then
      momoFlag = true
    end
  end
  if momoFlag == false then
    print("不是陌陌账号登陆,不能分享")
    return
  end
  local showMoMoShare = function(isSucceed, infoList)
    if not isSucceed then
      print("获取陌陌好友失败,不能分享")
      return
    end
    local hasFriendFlag = false
    for userId, userInfo in pairs(infoList) do
      userInfo.userId = userId
      hasFriendFlag = true
    end
    if hasFriendFlag == false then
      print("没有陌陌好友,不能分享")
      return
    end
    local shareTextList = {
      "[还达叔一张电影票] 达叔，这张电影票，补给您，也送给我逝去的岁月。",
      "[还达叔一张电影票] 那些年我们欠达叔的电影票，今天补上……",
      "[还达叔一张电影票] 这一次，让我们帮昔日的你，票房大卖！"
    }
    local shareMessage = shareTextList[math.random(1, #shareTextList)]
    ShowShareView_MOMO({
      shareBtnText = "分享心情",
      showText = "已经成功购买了“达叔的电影票套餐”，是否要向好友分享此刻的心情？",
      shareMessage = shareMessage,
      friendList = infoList
    })
  end
  g_ChannelMgr:getFriendList(showMoMoShare)
end
function ShowShareView_MOMO(para)
  getCurSceneView():addSubView({
    subView = CShare_MoMo.new(para),
    zOrder = MainUISceneZOrder.menuView
  })
end
CShare_MoMo = class("CShare_MoMo", CcsSubView)
function CShare_MoMo:ctor(para)
  para = para or {}
  CShare_MoMo.super.ctor(self, "views/share_momo.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_share = {
      listener = handler(self, self.OnBtn_Share),
      variName = "m_Btn_Share"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_ShareBtnText = para.shareBtnText or "分享心情"
  self.m_ShowText = para.showText or "向好友分享玩[缘定星辰]的心情?"
  self.m_ShareMessage = para.shareMessage or "[缘定星辰]我邀请你一起来玩游戏，来试试。"
  self.m_FriendList = para.friendList or {}
  self.m_SelectFriendList = {}
  self:setShowText(self.m_ShowText)
  self:setFriendList(self.m_FriendList)
  self:setShareBtnText(self.m_ShareBtnText)
end
function CShare_MoMo:setShowText(text)
  local x, y = self:getNode("txt_pos"):getPosition()
  local size = self:getNode("txt_pos"):getContentSize()
  if self.m_TextBox == nil then
    self.m_TextBox = CRichText.new({
      width = size.width,
      verticalSpace = 0,
      font = KANG_TTF_FONT,
      fontSize = 22,
      color = ccc3(0, 0, 0),
      align = CRichText_AlignType_Left
    })
    self.m_TextBox:addRichText(text)
    self:addChild(self.m_TextBox)
  else
    self.m_TextBox:clearAll()
    self.m_TextBox:addRichText(text)
  end
  local h = self.m_TextBox:getContentSize().height
  self.m_TextBox:setPosition(ccp(x, y + (size.height - h) / 2))
end
function CShare_MoMo:setFriendList(friendList)
  self.friendsList = self:getNode("list_friend")
  local index = 1
  for userId, info in pairs(friendList) do
    if info.name ~= "陌陌" then
      local item = CShareFriendItem_MoMo.new(info, self)
      self.friendsList:pushBackCustomItem(item:getUINode())
      item:setSelected(true)
      index = index + 1
      self:setFriendSelectFlag(userId, true)
    end
    if index == 20 then
      break
    end
  end
  self.friendsList:sizeChangedForShowMoreTips()
end
function CShare_MoMo:setFriendSelectFlag(userId, flag)
  self.m_SelectFriendList[userId] = flag
end
function CShare_MoMo:setShareBtnText(shareBtnText)
  if shareBtnText then
    self.m_Btn_Share:setTitleText(shareBtnText)
  end
end
function CShare_MoMo:OnBtn_Share(obj, t)
  local shareFlag = false
  for userid, flag in pairs(self.m_SelectFriendList) do
    if flag == true then
      shareFlag = true
      g_ChannelMgr:shareToUser(userid, function(isSucceed)
        if isSucceed then
          print("分享成功")
        end
      end, self.m_ShareMessage)
    end
  end
  if shareFlag == true then
    ShowNotifyTips("分享已经发送")
    self:CloseSelf()
  else
    ShowNotifyTips("请勾选需要分享心情的陌陌好友")
  end
end
function CShare_MoMo:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CShare_MoMo:Clear()
end
CShareFriendItem_MoMo = class("CShareFriendItem_MoMo", CcsSubView)
function CShareFriendItem_MoMo:ctor(momoInfo, shareView)
  CShareFriendItem_MoMo.super.ctor(self, "views/sharefriend_momo.json")
  local btnBatchListener = {
    btn_share = {
      listener = handler(self, self.Btn_Select),
      variName = "btn_share"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_UserId = momoInfo.userId
  local txt_name = self:getNode("txt_name")
  txt_name:setText(momoInfo.name or "")
  self.defaulthead = self:getNode("defaulthead")
  self.headpos = self:getNode("headpos")
  self.headpos:setVisible(false)
  self.headpos:setOpacity(0)
  self.m_SelectFlag = false
  self.m_ShareView = shareView
  local headUrl = momoInfo.smallHeadImageURL
  if headUrl then
    local fileName = string.format("icon_%s", self.m_UserId)
    g_HeadImgRequest:reqHeadImg(fileName, headUrl, handler(self, self.OnDownLoadHeadIcon), false)
  end
end
function CShareFriendItem_MoMo:OnDownLoadHeadIcon(isSucceed, filePath, fileName)
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
function CShareFriendItem_MoMo:getUserId()
  return self.m_UserId
end
function CShareFriendItem_MoMo:setSelected(flag)
  local btn = self.btn_share
  if flag == false then
    if btn and btn._SelectFlag then
      btn._SelectFlag:removeFromParent()
      btn._SelectFlag = nil
    end
  elseif btn and btn._SelectFlag == nil then
    local tempSprite = display.newSprite("views/common/btn/selected.png")
    tempSprite:setAnchorPoint(ccp(0.3, 0.3))
    btn:addNode(tempSprite, 1)
    btn._SelectFlag = tempSprite
  end
  self.m_SelectFlag = flag
end
function CShareFriendItem_MoMo:Btn_Select()
  self:setSelected(not self.m_SelectFlag)
  if self.m_ShareView then
    self.m_ShareView:setFriendSelectFlag(self.m_UserId, self.m_SelectFlag)
  end
end
function CShareFriendItem_MoMo:Clear()
  self.m_ShareView = nil
end
