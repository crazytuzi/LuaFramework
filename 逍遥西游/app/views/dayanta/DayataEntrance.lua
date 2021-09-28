DayataEntrance = class("DayataEntrance", CcsSubView)
DayataEntrance._bossTypeIdForLayer = nil
function DayataEntrance:ctor(cengShu)
  DayataEntrance.super.ctor(self, "views/dayanta.csb", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    bg_floor_1 = {
      listener = function()
        self:showCanGetObj(1)
      end,
      variName = "bg_floor_1"
    },
    bg_floor_2 = {
      listener = function()
        self:showCanGetObj(2)
      end,
      variName = "bg_floor_2"
    },
    bg_floor_3 = {
      listener = function()
        self:showCanGetObj(3)
      end,
      variName = "bg_floor_3"
    },
    bg_floor_4 = {
      listener = function()
        self:showCanGetObj(4)
      end,
      variName = "bg_floor_4"
    },
    bg_floor_5 = {
      listener = function()
        self:showCanGetObj(5)
      end,
      variName = "bg_floor_5"
    },
    bg_floor_6 = {
      listener = function()
        self:showCanGetObj(6)
      end,
      variName = "bg_floor_6"
    },
    bg_floor_7 = {
      listener = function()
        self:showCanGetObj(7)
      end,
      variName = "bg_floor_7"
    },
    bg_floor_8 = {
      listener = function()
        self:showCanGetObj(8)
      end,
      variName = "bg_floor_8"
    },
    bg_floor_9 = {
      listener = function()
        self:showCanGetObj(9)
      end,
      variName = "bg_floor_9"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  print("lv:", lv)
  local needColorRedIdx = -1
  for i = 1, 9 do
    local lvRange = data_DayantaLevel[i]
    if lvRange and lvRange.minlv ~= nil and lv < lvRange.minlv then
      needColorRedIdx = i
      break
    end
  end
  if needColorRedIdx ~= -1 then
    for i = needColorRedIdx, 9 do
      local txtNode = self:getNode("txtlv_" .. tostring(i))
      if txtNode then
        txtNode:setColor(ccc3(255, 0, 0))
      end
    end
  end
  if DayataEntrance._bossTypeIdForLayer == nil then
    local bossTypeIds = {}
    for i = 1, 9 do
      local missionId = 51000 + 10 * i + 9
      local data = data_Mission_Dayanta[missionId]
      local warId
      if data ~= nil then
        local dst1 = data.dst1
        if dst1 ~= nil then
          local dstData = dst1.data
          if dstData ~= nil then
            warId = dstData[1]
          end
        end
      end
      if warId ~= nil then
        local roleTypeId = data_getBossForWar(warId)
        if roleTypeId ~= nil then
          bossTypeIds[i] = roleTypeId
        end
      end
    end
    DayataEntrance._bossTypeIdForLayer = bossTypeIds
    dump(DayataEntrance._bossTypeIdForLayer, "DayataEntrance._bossTypeIdForLayer")
  end
  local defaultHeadTypeId = 50071
  for i = 1, 9 do
    do
      local head = createClickHead({
        roleTypeId = DayataEntrance._bossTypeIdForLayer[i] or defaultHeadTypeId,
        clickListener = function()
          self:Click(i)
        end,
        noBgFlag = false
      })
      local bg_floor = self:getNode(string.format("bg_floor_%d", i))
      local p = bg_floor:getParent()
      p:addChild(head, 15)
      local x, y = bg_floor:getPosition()
      local s = bg_floor:getSize()
      head:setPosition(ccp(x - head:getSize().width / 2, y + s.height / 2 - 5))
      if i == cengShu then
        local arrow = display.newSprite("xiyou/pic/pic_arrow.png")
        local size = head:getContentSize()
        local x, y = size.width / 2, size.height / 2
        arrow:setPosition(ccp(x, y))
        head:addNode(arrow, 100)
        arrow:setAnchorPoint(ccp(1, 0.5))
        arrow:setRotation(90)
        arrow:setPosition(x, y)
        local act1 = CCMoveBy:create(0.5, ccp(0, 30))
        local act2 = CCMoveBy:create(0.5, ccp(0, -30))
        arrow:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
      end
    end
  end
end
function DayataEntrance:Click(layerIdx)
  print("Click:", layerIdx)
  local teamCaptainPro = g_LocalPlayer:getObjProperty(1, PROPERTY_ISCAPTAIN)
  local isSendToServer = true
  if teamCaptainPro == TEAMCAPTAIN_YES then
    local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
    print("lv:", lv)
    local lvRange = data_DayantaLevel[layerIdx]
    if lvRange and lvRange.minlv and lv < lvRange.minlv then
      isSendToServer = false
      CPopWarning.new({
        title = "提示",
        text = "大雁塔内妖气冲天，如无视等级盲目进入恐怕有危险！",
        confirmText = "确定进入",
        cancelText = "取消",
        confirmFunc = function()
          self:reqEnter(layerIdx)
        end
      })
    end
  end
  if isSendToServer then
    self:reqEnter(layerIdx)
  end
end
function DayataEntrance:showCanGetObj(layer)
  local mainHero = g_LocalPlayer:getMainHero()
  local typeID = mainHero:getTypeId()
  local heroInfo = data_Hero[typeID]
  local worldPos = self:getPosition()
  local size = self:getContentSize()
  local JuanZhou_itemID
  if heroInfo.RACE == 1 then
    if heroInfo.GENDER == 1 then
      print(" 人族男")
      if layer == 1 or layer == 2 then
        JuanZhou_itemID = ITEM_DEF_STUFF_RENZU_NANREN
      elseif layer == 3 or layer == 4 then
        JuanZhou_itemID = ITEM_DEF_STUFF_RENZU_NANREN2
      elseif layer == 5 or layer == 6 or layer == 7 then
        JuanZhou_itemID = ITEM_DEF_STUFF_RENZU_NANREN3
      elseif layer == 8 or layer == 9 then
        JuanZhou_itemID = ITEM_DEF_STUFF_RENZU_NANREN4
      end
    else
      print("人族女")
      if layer == 1 or layer == 2 then
        JuanZhou_itemID = ITEM_DEF_STUFF_RENZU_NUREN1
      elseif layer == 3 or layer == 4 then
        JuanZhou_itemID = ITEM_DEF_STUFF_RENZU_NUREN2
      elseif layer == 5 or layer == 6 or layer == 7 then
        JuanZhou_itemID = ITEM_DEF_STUFF_RENZU_NUREN3
      elseif layer == 8 or layer == 9 then
        JuanZhou_itemID = ITEM_DEF_STUFF_RENZU_NUREN4
      end
    end
  elseif heroInfo.RACE == 2 then
    if heroInfo.GENDER == 1 then
      print(" 魔族男")
      if layer == 1 or layer == 2 then
        JuanZhou_itemID = ITEM_DEF_STUFF_MOZU_NANMO1
      elseif layer == 3 or layer == 4 then
        JuanZhou_itemID = ITEM_DEF_STUFF_MOZU_NANMO2
      elseif layer == 5 or layer == 6 or layer == 7 then
        JuanZhou_itemID = ITEM_DEF_STUFF_MOZU_NANMO3
      elseif layer == 8 or layer == 9 then
        JuanZhou_itemID = ITEM_DEF_STUFF_MOZU_NANMO4
      end
    else
      print("魔族女")
      if layer == 1 or layer == 2 then
        JuanZhou_itemID = ITEM_DEF_STUFF_MOZU_NUMO1
      elseif layer == 3 or layer == 4 then
        JuanZhou_itemID = ITEM_DEF_STUFF_MOZU_NUMO2
      elseif layer == 5 or layer == 6 or layer == 7 then
        JuanZhou_itemID = ITEM_DEF_STUFF_MOZU_NUMO3
      elseif layer == 8 or layer == 9 then
        JuanZhou_itemID = ITEM_DEF_STUFF_MOZU_NUMO4
      end
    end
  elseif heroInfo.RACE == 3 then
    if heroInfo.GENDER == 1 then
      print(" 仙族男")
      if layer == 1 or layer == 2 then
        JuanZhou_itemID = ITEM_DEF_STUFF_XIANZU_NANXIAN1
      elseif layer == 3 or layer == 4 then
        JuanZhou_itemID = ITEM_DEF_STUFF_XIANZU_NANXIAN2
      elseif layer == 5 or layer == 6 or layer == 7 then
        JuanZhou_itemID = ITEM_DEF_STUFF_XIANZU_NANXIAN3
      elseif layer == 8 or layer == 9 then
        JuanZhou_itemID = ITEM_DEF_STUFF_XIANZU_NANXIAN4
      end
    else
      print("仙族女")
      if layer == 1 or layer == 2 then
        JuanZhou_itemID = ITEM_DEF_STUFF_XIANZU_NUXIAN1
      elseif layer == 3 or layer == 4 then
        JuanZhou_itemID = ITEM_DEF_STUFF_XIANZU_NUXIAN2
      elseif layer == 5 or layer == 6 or layer == 7 then
        JuanZhou_itemID = ITEM_DEF_STUFF_XIANZU_NUXIAN3
      elseif layer == 8 or layer == 9 then
        JuanZhou_itemID = ITEM_DEF_STUFF_XIANZU_NUXIAN4
      end
    end
  elseif heroInfo.RACE == 4 then
    if heroInfo.GENDER == 1 then
      print("鬼族男")
      if layer == 1 or layer == 2 then
        JuanZhou_itemID = ITEM_DEF_STUFF_GUIZU_NANGUI1
      elseif layer == 3 or layer == 4 then
        JuanZhou_itemID = ITEM_DEF_STUFF_GUIZU_NANGUI2
      elseif layer == 5 or layer == 6 or layer == 7 then
        JuanZhou_itemID = ITEM_DEF_STUFF_GUIZU_NANGUI3
      elseif layer == 8 or layer == 9 then
        JuanZhou_itemID = ITEM_DEF_STUFF_GUIZU_NANGUI4
      end
    else
      print("鬼族女")
      if layer == 1 or layer == 2 then
        JuanZhou_itemID = ITEM_DEF_STUFF_GUIZU_NVGUI1
      elseif layer == 3 or layer == 4 then
        JuanZhou_itemID = ITEM_DEF_STUFF_GUIZU_NVGUI2
      elseif layer == 5 or layer == 6 or layer == 7 then
        JuanZhou_itemID = ITEM_DEF_STUFF_GUIZU_NVGUI3
      elseif layer == 8 or layer == 9 then
        JuanZhou_itemID = ITEM_DEF_STUFF_GUIZU_NVGUI4
      end
    end
  end
  if layer == 1 then
    self:createItem({
      ITEM_DEF_STUFF_XT,
      ITEM_DEF_STUFF_CYJZ,
      ITEM_DEF_STUFF_LSSP,
      ITEM_DEF_STUFF_KDCC1,
      ITEM_DEF_STUFF_KDCC2,
      JuanZhou_itemID
    }, layer)
  elseif layer == 2 then
    self:createItem({
      ITEM_DEF_STUFF_XT,
      ITEM_DEF_STUFF_CYJZ,
      ITEM_DEF_STUFF_LSSP,
      ITEM_DEF_STUFF_KDCC1,
      ITEM_DEF_STUFF_KDCC2,
      JuanZhou_itemID
    }, layer)
  elseif layer == 3 then
    self:createItem({
      ITEM_DEF_STUFF_XY,
      ITEM_DEF_STUFF_CYJZ,
      ITEM_DEF_STUFF_LSSP,
      ITEM_DEF_STUFF_KDCC1,
      ITEM_DEF_STUFF_KDCC2,
      JuanZhou_itemID
    }, layer)
  elseif layer == 4 then
    self:createItem({
      ITEM_DEF_STUFF_XY,
      ITEM_DEF_STUFF_CYJZ,
      ITEM_DEF_STUFF_LSSP,
      ITEM_DEF_STUFF_KDCC1,
      ITEM_DEF_STUFF_KDCC2,
      JuanZhou_itemID
    }, layer)
  elseif layer == 5 then
    self:createItem({
      ITEM_DEF_STUFF_XY,
      ITEM_DEF_STUFF_XQSP,
      ITEM_DEF_STUFF_LSSP,
      ITEM_DEF_STUFF_CYJZ,
      ITEM_DEF_STUFF_KDCC1,
      ITEM_DEF_STUFF_KDCC2,
      JuanZhou_itemID
    }, layer)
  elseif layer == 6 then
    self:createItem({
      ITEM_DEF_STUFF_XY,
      ITEM_DEF_STUFF_XQSP,
      ITEM_DEF_STUFF_LSSP,
      ITEM_DEF_STUFF_CYJZ,
      ITEM_DEF_STUFF_SSSP,
      ITEM_DEF_STUFF_KDCC1,
      ITEM_DEF_STUFF_KDCC2,
      JuanZhou_itemID
    }, layer)
  elseif layer == 7 then
    self:createItem({
      ITEM_DEF_STUFF_XY,
      ITEM_DEF_STUFF_XQSP,
      ITEM_DEF_STUFF_LSSP,
      ITEM_DEF_STUFF_CYJZ,
      ITEM_DEF_STUFF_SSSP,
      ITEM_DEF_STUFF_KDCC1,
      ITEM_DEF_STUFF_KDCC2,
      JuanZhou_itemID
    }, layer)
  elseif layer == 8 then
    self:createItem({
      ITEM_DEF_STUFF_XY,
      ITEM_DEF_STUFF_XQSP,
      ITEM_DEF_STUFF_CYJZ,
      ITEM_DEF_STUFF_SSSP,
      ITEM_DEF_STUFF_KDCC2,
      ITEM_DEF_STUFF_KDCC3,
      JuanZhou_itemID
    }, layer)
  elseif layer == 9 then
    self:createItem({
      ITEM_DEF_STUFF_XY,
      ITEM_DEF_STUFF_XQSP,
      ITEM_DEF_STUFF_CYJZ,
      ITEM_DEF_STUFF_SSSP,
      ITEM_DEF_STUFF_KDCC2,
      ITEM_DEF_STUFF_KDCC3,
      JuanZhou_itemID
    }, layer)
  end
end
function DayataEntrance:createItem(params, layer)
  if params == nil then
    return
  end
  local sortIdTableFucn = function(itmeId_1, itmeId_2)
    if itmeId_1 == nil or itmeId_2 == nil then
      return
    end
    local itmePJ_1 = data_getItemPinjie(itmeId_1)
    local itemPJ_2 = data_getItemPinjie(itmeId_2)
    if itmePJ_1 ~= nil and itemPJ_2 ~= nil then
      return itmePJ_1 < itemPJ_2
    else
      return
    end
  end
  table.sort(params, sortIdTableFucn)
  local bg_floor = self:getNode(string.format("bg_floor_%d", layer))
  local pos = bg_floor:getPosition()
  local size = bg_floor:getSize()
  local worldPos = bg_floor:convertToWorldSpace(ccp(0, 0))
  local itemView = DayantaItemView.new(params, false, {
    x = worldPos.x,
    y = worldPos.y,
    w = size.width,
    h = size.height,
    dirList = {TipsShow_Up_Dir, TipsShow_Down_Dir}
  }, ENTER_DAYANTA_BOSSTAG)
end
function DayataEntrance:reqEnter(layerIdx)
  activity.dayanta:sendEnterReq(layerIdx)
  self:CloseSelf()
end
function DayataEntrance:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
