CMapTreasure = class("CMapTreasure", function()
  return Widget:create()
end)
function CMapTreasure:ctor(id, data)
  self.m_Id = id
  self.m_BoxPos = data.loc
  self.m_SceneId = data.scene
  self.m_ItemId = data.itemid
  local shape = data_getItemShapeID(self.m_ItemId)
  local itempath = data_getItemPathByShape_ForMap(shape)
  local treasure = display.newSprite(itempath)
  treasure:setAnchorPoint(ccp(0.5, 0))
  self:addNode(treasure, 1)
  self.m_TreasureImg = treasure
  local treasureName = data_getItemName(self.m_ItemId)
  local nameTxt = ui.newTTFLabelWithShadow({
    text = treasureName,
    font = KANG_TTF_FONT,
    size = 20
  })
  nameTxt.shadow1:realign(1, 0)
  nameTxt:setColor(NameColor_Item[0])
  self:addNode(nameTxt, 2)
  local s = nameTxt:getContentSize()
  nameTxt:setPosition(ccp(-s.width / 2, -8))
  local w, h = 90, 90
  self:ignoreContentAdaptWithSize(false)
  self:setAnchorPoint(ccp(0.5, 0.2))
  self:setSize(CCSize(w, h))
  clickArea_check.extend(self)
  self:click_check_withObj(self, handler(self, self.OnClicked))
end
function CMapTreasure:setOpaque(isOpaque)
  if isOpaque then
    self.m_TreasureImg:setOpacity(120)
  else
    self.m_TreasureImg:setOpacity(255)
  end
end
function CMapTreasure:OnClicked()
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    return
  end
  local picupDis = 250
  if g_MapMgr then
    do
      local mapView = g_MapMgr:getMapViewIns()
      if mapView then
        do
          local tx, ty = self.m_BoxPos.x, self.m_BoxPos.y
          local mx, my = g_MapMgr:getLocalPlayerPos()
          local dis = ((mx - tx) ^ 2 + (my - ty) ^ 2) ^ 0.5
          local gx, gy = mapView:getGridByPos(tx, ty)
          local mapSize = g_MapMgr:getMapSize(self.m_SceneId)
          local gridX = gx
          local gridY = mapSize[2] - gy
          local desPos = {gx, gridY}
          local facePos = {
            gx,
            gridY - 1
          }
          if dis > 150 then
            g_MapMgr:AutoRoute(self.m_SceneId, desPos, function(isSucceed)
              if self.OnPicUpTreasure ~= nil then
                self:OnPicUpTreasure()
              else
                ShowNotifyTips("该物品已不存在")
              end
              mapView:setLocalRoleFacetoGridPos(facePos, true)
            end)
          else
            self:OnPicUpTreasure()
            mapView:setLocalRoleFacetoGridPos(facePos, true)
          end
        end
      end
    end
  end
end
function CMapTreasure:OnPicUpTreasure()
  if self.m_ItemId == ITEM_HuoDong_Gift_Marry then
    ClearAllShowProgressBar()
    local function func()
      netsend.netmap.pickupMapTreasure(self.m_Id)
    end
    CShowProgressBar.new("正在抢礼包", func)
  elseif self.m_ItemId == ITEM_HuoDong_BpWar_ItemBox then
    if g_TeamMgr:localPlayerIsCaptain() then
      netsend.netmap.pickupMapTreasure(self.m_Id)
    else
      ShowNotifyTips("只有队长才能打开宝箱")
    end
  elseif self.m_ItemId == ITEM_DEF_OTHER_BXSP then
    ClearAllShowProgressBar()
    local function func()
      netsend.netmap.pickupMapTreasure(self.m_Id)
    end
    CShowProgressBar.new("正在拾取中", func, 2)
  elseif self.m_ItemId == ITEM_DEF_OTHER_JBX then
    ShowGoldBoxViewDlg(self.m_Id)
  end
end
CTreasureAnimation = class("CTreasureAnimation", CcsSubView)
function CTreasureAnimation:ctor(data)
  CTreasureAnimation.super.ctor(self, "views/gettreasure.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.btn_close:setEnabled(false)
  self.btn_confirm:setEnabled(false)
  self.btn_close:setScale(0)
  self.btn_confirm:setScale(0)
  local pos_body = self:getNode("pos_body")
  pos_body:setVisible(false)
  local x, y = pos_body:getPosition()
  local size = pos_body:getContentSize()
  x = x + size.width / 2
  y = y + size.height / 2
  local z = pos_body:getZOrder()
  local aniParent = pos_body:getParent()
  local imgPath = "views/peticon/boxlight1.png"
  local imgSprite = display.newSprite(imgPath)
  imgSprite:setPosition(ccp(x, y))
  aniParent:addNode(imgSprite, z)
  imgSprite:setScale(0)
  imgSprite:runAction(transition.sequence({
    CCScaleTo:create(0.3, 1.4),
    CCCallFunc:create(function()
      soundManager.playSound("xiyou/sound/openbox.wav")
    end),
    CCScaleTo:create(0.2, 1)
  }))
  imgSprite:runAction(CCRepeatForever:create(CCRotateBy:create(1.5, 360)))
  local title_name = self:getNode("title_name")
  title_name:setText("")
  local treasureAni
  if data.gold ~= nil or data.silver ~= nil or data.coin ~= nil then
    local resType
    local resNum = 0
    if data.gold ~= nil then
      resNum = data.gold
      resType = RESTYPE_GOLD
    elseif data.silver ~= nil then
      resNum = data.silver
      resType = RESTYPE_SILVER
    elseif data.coin ~= nil then
      resNum = data.coin
      resType = RESTYPE_COIN
    end
    if resType ~= nil then
      title_name:setText(data_getResNameByResID(resType))
      treasureAni = createClickResItem({
        resID = resType,
        num = resNum,
        noBgFlag = false
      })
    end
  elseif data.itemids ~= nil then
    for _, v in pairs(data.itemids) do
      local itemId = v[1]
      local itemNum = v[2]
      treasureAni = createClickItem({
        itemID = itemId,
        autoSize = nil,
        num = itemNum,
        noBgFlag = false
      })
      title_name:setText(data_getItemName(itemId))
      break
    end
  end
  if treasureAni then
    aniParent:addChild(treasureAni, z + 2)
    local tsize = treasureAni:getContentSize()
    treasureAni:setPosition(ccp(x - tsize.width / 2, y - tsize.height / 2))
    treasureAni._BgIcon:setColor(ccc3(0, 0, 0))
    treasureAni._Icon:setColor(ccc3(0, 0, 0))
    if treasureAni._numLabel then
      treasureAni._numLabel:setVisible(false)
    end
    title_name:setVisible(false)
    treasureAni:runAction(transition.sequence({
      CCDelayTime:create(0.7),
      CCShow:create(),
      CCCallFunc:create(function()
        treasureAni._BgIcon:runAction(CCTintTo:create(1, 255, 255, 255))
        treasureAni._Icon:runAction(CCTintTo:create(1, 255, 255, 255))
      end),
      CCDelayTime:create(1),
      CCCallFunc:create(function()
        self.btn_close:setEnabled(true)
        self.btn_confirm:setEnabled(true)
        self.btn_close:runAction(CCScaleTo:create(0.2, 1))
        self.btn_confirm:runAction(CCScaleTo:create(0.2, 1))
        if treasureAni._numLabel then
          treasureAni._numLabel:setVisible(true)
        end
        title_name:setVisible(true)
      end)
    }))
  end
end
function CTreasureAnimation:OnBtn_Confirm()
  self:OnBtn_Close()
end
function CTreasureAnimation:OnBtn_Close()
  self:CloseSelf()
end
function CTreasureAnimation:Clear()
end
function ShowMapTreasureResult(data)
  getCurSceneView():addSubView({
    subView = CTreasureAnimation.new(data),
    zOrder = MainUISceneZOrder.menuView
  })
end
