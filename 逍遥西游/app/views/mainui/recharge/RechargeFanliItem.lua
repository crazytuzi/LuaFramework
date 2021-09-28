RechargeFanliItem = class("RechargeFanliItem", CcsSubView)
function RechargeFanliItem:ctor(itemId)
  RechargeFanliItem.super.ctor(self, "views/rechargefanli_item.csb")
  local btnBatchListener = {
    btn_recive = {
      listener = handler(self, self.OnBtn_Recive),
      variName = "btn_recive"
    },
    btn_title = {
      listener = handler(self, self.OnBtn_CheckTitle),
      variName = "btn_title"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_ItemID = itemId
  self.btn_title:setTitleText("")
  self:setData()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ChongZhi)
end
function RechargeFanliItem:setData()
  local picPath = "views/gift/pic_gift_libao.png"
  local tempPic = display.newSprite(picPath)
  self:addNode(tempPic, 1000)
  local x, y = self:getNode("box_pic"):getPosition()
  tempPic:setAnchorPoint(ccp(0, 0))
  tempPic:setPosition(ccp(x, y))
  local data = data_getChongZhiExtraAward(self.m_ItemID)
  self:getNode("title"):setText(data.Desc or "")
  self:updateData()
  if data.PetId ~= nil and data.PetId ~= 0 then
    self:createPetReward(data.PetId)
  else
    self:createReward(data.Award)
  end
  local data = data_getChongZhiExtraAward(self.m_ItemID)
  local titleId = data.Title
  if titleId ~= nil and titleId ~= 0 then
    self.btn_title:setVisible(true)
    self.btn_title:setTouchEnabled(true)
  else
    self.btn_title:setVisible(false)
    self.btn_title:setTouchEnabled(false)
  end
end
function RechargeFanliItem:updateData()
  local fanliData = g_LocalPlayer:getFanliData()
  local state = fanliData[self.m_ItemID] or 1
  local data = data_getChongZhiExtraAward(self.m_ItemID)
  if state == 1 then
    self.btn_recive:setVisible(false)
    self.btn_recive:setTouchEnabled(false)
    self:getNode("txt1"):setVisible(true)
    self:getNode("txt2"):setVisible(false)
    self:getNode("pic2"):setVisible(false)
    self:getNode("txt1"):setText(string.format("%d/%d", g_LocalPlayer:getVipAddGold(), data.NeedAccuGold or 99999999))
    AutoLimitObjSize(self:getNode("txt1"), 150)
    self:getNode("txt1"):setColor(ccc3(72, 40, 13))
  elseif state == 2 then
    self.btn_recive:setVisible(true)
    self.btn_recive:setTouchEnabled(true)
    self:getNode("txt1"):setVisible(false)
    self:getNode("txt2"):setVisible(false)
    self:getNode("pic2"):setVisible(false)
  else
    self.btn_recive:setVisible(false)
    self.btn_recive:setTouchEnabled(false)
    self:getNode("txt1"):setVisible(false)
    self:getNode("txt2"):setVisible(true)
    self:getNode("pic2"):setVisible(true)
  end
end
function RechargeFanliItem:createPetReward(petId)
  local zOrder = 10000
  local rewardItem = {}
  local x, _ = self:getNode("title"):getPosition()
  local _, y = self:getNode("box_pic"):getPosition()
  local scale = 0.65
  local item = createClickPetHead({
    roleTypeId = petId,
    autoSize = nil,
    clickListener = function()
      local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Zhaohuanshou)
      if openFlag == false then
        ShowNotifyTips(tips)
        return
      end
      local tempView = CPetList.new(PetShow_InitShow_TuJianView, nil, nil, petId)
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
    end,
    noBgFlag = nil,
    offx = nil,
    offy = nil,
    clickDel = nil,
    LongPressTime = 0,
    LongPressListener = nil,
    LongPressEndListner = nil
  })
  if item then
    item:setScale(scale)
    self:addChild(item, zOrder)
    item:setPosition(ccp(x, y))
    local s = item:getSize()
    x = x + s.width * scale + 10
    rewardItem[#rewardItem + 1] = item
  end
end
function RechargeFanliItem:createReward(rewardList)
  local zOrder = 10000
  local rewardItem = {}
  local x, _ = self:getNode("title"):getPosition()
  local _, y = self:getNode("box_pic"):getPosition()
  local scale = 0.65
  for i, rewardInfo in ipairs(rewardList) do
    local t = rewardInfo[1]
    local num = rewardInfo[2]
    local item
    if num and num > 0 then
      if t == RESTYPE_GOLD then
        item = createClickResItem({
          resID = RESTYPE_GOLD,
          num = num,
          autoSize = nil,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      elseif t == RESTYPE_COIN then
        item = createClickResItem({
          resID = RESTYPE_COIN,
          num = num,
          autoSize = nil,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      elseif t == RESTYPE_SILVER then
        item = createClickResItem({
          resID = RESTYPE_SILVER,
          num = num,
          autoSize = nil,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      elseif t == RESTYPE_EXP then
        item = createClickResItem({
          resID = RESTYPE_EXP,
          num = num,
          autoSize = nil,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      elseif t == RESTYPE_HUOLI then
        item = createClickResItem({
          resID = RESTYPE_HUOLI,
          num = num,
          autoSize = nil,
          clickListener = nil,
          clickDel = nil,
          noBgFlag = nil,
          LongPressTime = 0.2,
          LongPressListener = nil,
          LongPressEndListner = nil
        })
      else
        item = createClickItem({
          itemID = t,
          autoSize = nil,
          num = num,
          LongPressTime = 0.2,
          clickListener = nil,
          LongPressListener = nil,
          LongPressEndListner = nil,
          clickDel = nil,
          noBgFlag = nil
        })
      end
      if item then
        item:setScale(scale)
        self:addChild(item, zOrder)
        item:setPosition(ccp(x, y))
        local s = item:getSize()
        x = x + s.width * scale + 10
        rewardItem[#rewardItem + 1] = item
      end
    end
  end
  return rewardItem
end
function RechargeFanliItem:OnBtn_Recive(btnObj, touchType)
  netsend.netbaseptc.GetChongZhiFanliAward(self.m_ItemID)
end
function RechargeFanliItem:OnBtn_CheckTitle(btnObj, touchType)
  local data = data_getChongZhiExtraAward(self.m_ItemID)
  local titleId = data.Title
  if titleId ~= nil and titleId ~= 0 then
    getCurSceneView():addSubView({
      subView = settingDlg_CW_Info.new(titleId),
      zOrder = MainUISceneZOrder.popDetailView
    })
  end
end
function RechargeFanliItem:OnMessage(msgSID, ...)
  if msgSID == MsgID_VIPUpdateAddGold then
    self:updateData()
  elseif msgSID == MsgID_ChongZhiFanli_Update then
    self:updateData()
  end
end
