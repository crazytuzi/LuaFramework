CQuickUseBoard = class("CQuickUseBoard", CcsSubView)
function CQuickUseBoard:ctor(objType, objId)
  CQuickUseBoard.super.ctor(self, "views/quickuseboard.json")
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  local x, y = self:getNode("box_btnuse"):getPosition()
  local size = self:getNode("box_btnuse"):getSize()
  self.btn_use = createClickButton("views/common/btn/btn_2words.png", "views/common/btn/btn_2words.png", handler(self, self.OnBtn_Use))
  self:getNode("bg"):addChild(self.btn_use)
  self.btn_use:setPosition(ccp(x, y))
  self.btn_use:setTouchEnabled(true)
  self.m_BtnText = ui.newTTFLabel({
    text = "     使用",
    font = KANG_TTF_FONT,
    size = 22,
    color = ccc3(0, 0, 0)
  })
  self.m_BtnText:setAnchorPoint(ccp(0.5, 0.5))
  self.m_BtnText:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:getNode("bg"):addNode(self.m_BtnText, 1)
  self:addBatchBtnListener(btnBatchListener)
  self:reSetData(objType, objId)
  self:ListenMessage(MsgID_ItemInfo)
  self.lasttime = 0
end
function CQuickUseBoard:getTypeItemid()
  if self.m_ObjType == BoxOpenType_Item then
    local item = g_LocalPlayer:GetOneItem(self.m_ObjId)
    if item == nil then
      return nil
    end
    local itemType = item:getType()
    local itemTypeId = item:getTypeId()
    return itemType, itemTypeId
  end
  return nil
end
function CQuickUseBoard:reSetData(objType, objId)
  self.m_LastClickTime = nil
  if self.m_ObjType == objType and self.m_ObjId == objId then
    return
  end
  self.m_ObjType = objType
  self.m_ObjId = objId
  if objType == BoxOpenType_Pet then
    local pet = g_LocalPlayer:getObjById(objId)
    local name = pet:getProperty(PROPERTY_NAME)
    local zs = pet:getProperty(PROPERTY_ZHUANSHENG)
    local color = NameColor_Pet[zs]
    if color == nil then
      color = ccc3(255, 255, 255)
    end
    self:getNode("itemName"):setColor(color)
    self:getNode("itemName"):setText(name)
    self.m_BtnText:setString("     出战")
  elseif objType == BoxOpenType_Item then
    local item = g_LocalPlayer:GetOneItem(objId)
    local name = item:getProperty(ITEM_PRO_NAME)
    self:getNode("itemName"):setText(name)
    local itemPj = data_getItemPinjie(item:getTypeId())
    local color = NameColor_Item[itemPj] or NameColor_Item[0]
    self:getNode("itemName"):setColor(color)
    self.m_BtnText:setString("     使用")
  elseif objType == BoxOpenType_Hero then
    local hero = g_LocalPlayer:getObjById(objId)
    local name = hero:getProperty(PROPERTY_NAME)
    local zs = hero:getProperty(PROPERTY_ZHUANSHENG)
    local color = NameColor_MainHero[zs]
    if color == nil then
      color = ccc3(255, 255, 255)
    end
    self:getNode("itemName"):setColor(color)
    self:getNode("itemName"):setText(name)
    self.m_BtnText:setString("     出战")
  end
  self:reSetImg()
  AutoLimitObjSize(self:getNode("itemName"), 130)
end
function CQuickUseBoard:reSetImg()
  if self.m_Img then
    self.m_Img:removeFromParent()
    self.m_Img = nil
  end
  local pos = self:getNode("Img")
  local s = pos:getContentSize()
  if self.m_ObjType == BoxOpenType_Item then
    local item = g_LocalPlayer:GetOneItem(self.m_ObjId)
    local itemType = item:getType()
    local itemTypeId = item:getTypeId()
    local num = item:getProperty(ITEM_PRO_NUM)
    local canMerge = item:getProperty(ITEM_PRO_CANMERGE)
    if canMerge == 0 or canMerge == 1 then
      num = 0
    end
    local icon = createClickItem({
      itemID = itemTypeId,
      autoSize = nil,
      num = num,
      LongPressTime = 0.01,
      clickListener = nil,
      LongPressListener = nil,
      LongPressEndListner = nil,
      clickDel = nil,
      noBgFlag = false
    })
    pos:addChild(icon)
    local size = icon:getContentSize()
    icon:setPosition(ccp(s.width / 2 - size.width / 2, s.height / 2 - size.height / 2))
    self.m_Img = icon
  elseif self.m_ObjType == BoxOpenType_Pet then
    local pet = g_LocalPlayer:getObjById(self.m_ObjId)
    local icon = createClickPetHead({
      roleTypeId = pet:getTypeId(),
      autoSize = nil,
      clickListener = nil,
      noBgFlag = nil,
      offx = nil,
      offy = nil,
      clickDel = nil,
      LongPressTime = 0.01,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    pos:addChild(icon)
    local size = icon:getContentSize()
    icon:setPosition(ccp(s.width / 2 - size.width / 2, s.height / 2 - size.height / 2))
    self.m_Img = icon
  elseif self.m_ObjType == BoxOpenType_Hero then
    local hero = g_LocalPlayer:getObjById(self.m_ObjId)
    local icon = createClickHead({
      roleTypeId = hero:getTypeId(),
      autoSize = nil,
      clickListener = nil,
      noBgFlag = nil,
      offx = nil,
      offy = nil,
      clickDel = nil,
      LongPressTime = 0,
      LongPressListener = nil,
      LongPressEndListner = nil
    })
    pos:addChild(icon)
    local size = icon:getContentSize()
    icon:setPosition(ccp(s.width / 2 - size.width / 2, s.height / 2 - size.height / 2))
    self.m_Img = icon
  end
end
function CQuickUseBoard:OnBtn_Close(obj, t)
  if g_CMainMenuHandler then
    g_CMainMenuHandler:delItemFromQuickUseBoard(self.m_ObjType, self.m_ObjId)
  end
end
function CQuickUseBoard:OnBtn_Use(obj, t)
  if not self:isEnabled() then
    return
  end
  local curTime = cc.net.SocketTCP.getTime()
  if self.m_LastClickTime ~= nil then
    local delTime = 0.3
    if self.m_ObjType == BoxOpenType_Item then
      local item = g_LocalPlayer:GetOneItem(self.m_ObjId)
      if item ~= nil then
        local itemTypeId = item:getTypeId()
        if itemTypeId == ITEM_DEF_OTHER_RS or itemTypeId == ITEM_DEF_OTHER_RSG or itemTypeId == ITEM_DEF_OTHER_RSGW then
          delTime = 1
        end
      end
    end
    if delTime > curTime - self.m_LastClickTime then
      return
    end
  end
  self.m_LastClickTime = curTime
  if self.m_ObjType == BoxOpenType_Pet then
    if JudgeIsInWar() then
      ShowNotifyTips("战斗中不能执行此操作")
      return
    end
    netsend.netbaseptc.setEquipPet(g_LocalPlayer:getMainHeroId(), self.m_ObjId)
  elseif self.m_ObjType == BoxOpenType_Hero then
    local zs = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ZHUANSHENG)
    local lv = g_LocalPlayer:getMainHero():getProperty(PROPERTY_ROLELEVEL)
    local warsetting = DeepCopyTable(g_LocalPlayer:getWarSetting())
    local warNum = 0
    for _, pos in ipairs({
      3,
      2,
      4,
      1,
      5
    }) do
      if warsetting[pos] ~= nil then
        warNum = warNum + 1
      end
    end
    if warNum >= data_getWarNumLimit(zs, lv) + 1 then
      ShowNotifyTips("出战人数满")
      if g_CMainMenuHandler then
        g_CMainMenuHandler:delItemFromQuickUseBoard(self.m_ObjType, self.m_ObjId)
      end
    else
      local changeFlag = false
      for _, pos in ipairs({
        3,
        2,
        4,
        1,
        5
      }) do
        if warsetting[pos] == nil then
          warsetting[pos] = self.m_ObjId
          changeFlag = true
          break
        end
      end
      if changeFlag then
        netsend.netwar.submitWarSetting(DeepCopyTable(warsetting))
        ShowWarningInWar()
      end
    end
  elseif self.m_ObjType == BoxOpenType_Item then
    local item = g_LocalPlayer:GetOneItem(self.m_ObjId)
    if item == nil then
      return
    end
    local itemType = item:getType()
    local itemTypeId = item:getTypeId()
    if itemType == ITEM_LARGE_TYPE_EQPT or itemType == ITEM_LARGE_TYPE_SENIOREQPT or itemType == ITEM_LARGE_TYPE_SHENBING or itemType == ITEM_LARGE_TYPE_XIANQI then
      RequestToAddItemToRole(self.m_ObjId, g_LocalPlayer:getMainHeroId())
      ShowWarningInWar()
      return
    elseif itemType == ITEM_LARGE_TYPE_GIFT then
      netsend.netitem.requestUseItem(self.m_ObjId)
      return
    elseif itemTypeId == ITEM_DEF_OTHER_LABA then
      if g_LBMgr then
        g_LBMgr:showInputView()
      end
      return
    elseif itemTypeId == ITEM_DEF_OTHER_ZBT or itemTypeId == ITEM_DEF_OTHER_GJZBT then
      local mapId = item:getProperty(ITME_PRO_ZBT_SCENE)
      local pos = item:getProperty(ITME_PRO_ZBT_POS)
      local rIndex = item:getProperty(ITEM_PRO_ZBT_RESULTINDEX)
      self.m_LastClickTime = curTime + 3
      if mapId ~= 0 and mapId ~= nil and pos ~= nil and #pos >= 2 and rIndex ~= nil and rIndex ~= 0 then
        g_MapMgr:UseZBT(self.m_ObjId, mapId, pos, rIndex)
        return
      else
        netsend.netitem.requestUseItem(self.m_ObjId)
        return
      end
    elseif itemTypeId == ITEM_DEF_OTHER_BPGP then
      if g_BpMgr:localPlayerHasBangPai() ~= true then
        ShowNotifyTips("加入帮派才能使用贡品")
        return
      else
        netsend.netitem.requestUseItem(self.m_ObjId)
        ShowWarningInWar()
        return
      end
    else
      local doubleExpData = g_LocalPlayer:getDoubleExpData()
      local useSBDTimes = doubleExpData.useSBDTimes or 0
      local curVipLv = g_LocalPlayer:getVipLv()
      for _, tempId in pairs(QuickUseItemList) do
        if tempId == itemTypeId then
          if itemTypeId == ITEM_DEF_OTHER_SBD then
            if useSBDTimes >= data_getCanUseSBDNum(curVipLv) then
              if curTime - self.lasttime > 0.5 then
                UseDoubleExpItem(self.m_ObjId)
              end
            elseif curTime - self.lasttime > 0.1 then
              UseDoubleExpItem(self.m_ObjId)
            end
            self.lasttime = curTime
          else
            netsend.netitem.requestUseItem(self.m_ObjId)
          end
          return
        end
      end
      local mainRole = g_LocalPlayer:getMainHero()
      if mainRole == nil then
        print("没有主角")
        return
      end
      local petId = mainRole:getProperty(PROPERTY_PETID)
      if petId == nil or petId == 0 then
        print("没有出战宠物主角")
        return
      end
      local petObj = g_LocalPlayer:getObjById(petId)
      if petObj then
        for _, tempId in pairs(QuickUseItemList_Pet) do
          if tempId == itemTypeId then
            if itemTypeId == ITEM_DEF_OTHER_SSD or itemTypeId == ITEM_DEF_OTHER_GJSSD or itemTypeId == ITEM_DEF_OTHER_CJSSD then
              local petLv = petObj:getProperty(PROPERTY_ROLELEVEL)
              local petZs = petObj:getProperty(PROPERTY_ZHUANSHENG)
              local name = petObj:getProperty(PROPERTY_NAME)
              local heroLv = mainRole:getProperty(PROPERTY_ROLELEVEL)
              local heroZs = mainRole:getProperty(PROPERTY_ZHUANSHENG)
              local itemName = item:getProperty(ITEM_PRO_NAME)
              if petZs > heroZs or heroZs == petZs and petLv >= heroLv + PETLV_HEROLV_MAXDEL then
                ShowNotifyTips(string.format("%s超过你的等级%d级,无法使用%s", name, PETLV_HEROLV_MAXDEL, itemName))
                return
              else
                netsend.netitem.requestUseItem(self.m_ObjId, petId)
                return
              end
            elseif itemTypeId == ITEM_DEF_OTHER_QMD or itemTypeId == ITEM_DEF_OTHER_GJQMD or itemTypeId == ITEM_DEF_OTHER_CJQMD then
              local maxClose = data_PetClose[#data_PetClose].closeValue
              local petClose = petObj:getProperty(PROPERTY_CLOSEVALUE)
              if maxClose and maxClose <= petClose then
                ShowNotifyTips("召唤兽亲密度已满，不能使用亲密丹")
                return
              else
                netsend.netitem.requestUseItem(self.m_ObjId, petId)
                return
              end
            else
              netsend.netitem.requestUseItem(self.m_ObjId, petId)
              return
            end
          end
        end
      end
    end
  end
end
function CQuickUseBoard:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_ItemInfo_ItemUpdate then
    local para = arg[1]
    local objId = para.itemId
    local newNum = para.pro[ITEM_PRO_NUM]
    if objId == self.m_ObjId and self.m_ObjType == BoxOpenType_Item and newNum ~= nil then
      self:reSetImg()
    end
  end
end
function CQuickUseBoard:Clear()
end
