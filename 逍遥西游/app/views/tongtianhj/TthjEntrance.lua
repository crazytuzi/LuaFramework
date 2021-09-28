local CDisplayPetBoardItem = class("CDisplayPetBoardItem", function()
  return Widget:create()
end)
function CDisplayPetBoardItem:ctor(index, petTypeId, isopen, mlistener)
  self.m_PetTypeId = petTypeId
  self.m_listener = mlistener
  self.m_index = index
  self.m_IsOpen = isopen ~= false
  if self.m_IsOpen then
    self.m_PetHeandBg = display.newSprite("views/mainviews/pic_headiconbg.png")
  else
    self.m_PetHeandBg = display.newGraySprite("views/mainviews/pic_headiconbg.png")
  end
  self.m_PetHeandBg:setAnchorPoint(ccp(0.5, 0.5))
  self:addNode(self.m_PetHeandBg)
  local pWidget = Widget:create()
  self:addChild(pWidget, 0)
  self.m_PetHead = createHeadIconByShape(self.m_PetTypeId, nil, not self.m_IsOpen)
  self.m_PetHead:setAnchorPoint(ccp(0.5, 0.5))
  pWidget:addNode(self.m_PetHead, 0)
  self.m_PetHead:setPosition(HEAD_OFF_X, HEAD_OFF_Y)
  local size = self.m_PetHead:getContentSize()
  pWidget:ignoreContentAdaptWithSize(false)
  pWidget:setSize(CCSize(size.width, size.height))
  self.m_doneSign = display.newSprite("views/common/btn/selected.png")
  self.m_doneSign:setAnchorPoint(ccp(0.3, 0.8))
  self.m_doneSign:setPosition(HEAD_OFF_X, HEAD_OFF_Y)
  self:addNode(self.m_doneSign, 1)
  self.m_doneSign:setVisible(false)
  self:setSize(self.m_PetHeandBg:getContentSize())
  self.m_SelectScale = 1
  self.m_UnSelectScale = 1
  self.m_SelectOpacity = 255
  self.m_UnSelectOpacity = 255
  self.m_IsSelected = false
  self:ignoreContentAdaptWithSize(false)
  pWidget:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      soundManager.playSound(string.format("xiyou/sound/clickbutton_%d.wav", 1))
      if self.m_listener then
        self.m_listener(self.m_index, petTypeId)
      end
    elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
      soundManager.playSound(string.format("xiyou/sound/clickbutton_%d.wav", 0))
    end
  end)
  pWidget:setTouchEnabled(true)
end
function CDisplayPetBoardItem:getIsOpen()
  return true
end
function CDisplayPetBoardItem:getPetTypeID()
  return self.m_PetTypeId
end
function CDisplayPetBoardItem:setHadDone(bool)
  if self.m_doneSign == nil then
    self.m_doneSign = display.newSprite("views/common/btn/selected.png")
    self.m_doneSign:setAnchorPoint(ccp(0.3, 0.8))
    self.m_doneSign:setPosition(HEAD_OFF_X, HEAD_OFF_Y)
    self:addNode(self.m_doneSign, 1)
  end
  self.m_doneSign:setVisible(bool == true)
end
function CDisplayPetBoardItem:setFadeIn()
  local dt = 0.5
  local opacity = self.m_UnSelectOpacity
  if self.m_ChoosedFrame and self.m_ChoosedFrame:isVisible() then
    opacity = self.m_SelectOpacity
  end
  self.m_PetHeandBg:setOpacity(0)
  self.m_PetHeandBg:runAction(CCFadeTo:create(dt, opacity))
  self.m_PetHead:setOpacity(0)
  self.m_PetHead:runAction(CCFadeTo:create(dt, opacity))
  if self.m_ChoosedFrame then
    self.m_ChoosedFrame:setOpacity(0)
    self.m_ChoosedFrame:runAction(CCFadeTo:create(dt, opacity))
  end
end
function CDisplayPetBoardItem:setSelected(flag)
  self:stopAllActions()
  self.m_IsSelected = flag
  if flag then
    self:runAction(CCScaleTo:create(0.15, self.m_SelectScale))
    if self.m_ChoosedFrame == nil then
      self.m_ChoosedFrame = display.newSprite("views/rolelist/pic_role_selected.png")
      self:addNode(self.m_ChoosedFrame, 2)
      local x, y = self.m_PetHeandBg:getPosition()
      self.m_ChoosedFrame:setPosition(x, y)
    end
    self.m_ChoosedFrame:setVisible(true)
    self:SetOpacity(self.m_SelectOpacity)
  else
    self:runAction(CCScaleTo:create(0.15, self.m_UnSelectScale))
    if self.m_ChoosedFrame then
      self.m_ChoosedFrame:setVisible(false)
    end
    self:SetOpacity(self.m_UnSelectOpacity)
  end
end
function CDisplayPetBoardItem:SetOpacity(a)
  self.m_PetHeandBg:setOpacity(a)
  self.m_PetHead:setOpacity(a)
  if self.m_ChoosedFrame then
    self.m_ChoosedFrame:setOpacity(a)
  end
end
function CDisplayPetBoardItem:onCleanup()
  if self.m_listener then
    self.m_listener = nil
  end
end
TthjEntrance = class("TthjEntrance", CcsSubView)
function TthjEntrance:ctor(playerInfo)
  TthjEntrance.super.ctor(self, "views/fb_tthj.csb", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  clickArea_check.extend(self)
  self.curSelectInd = 1
  self.playerInfo = {}
  self.playerParam = playerInfo
  self.isclean = false
  if self.playerInfo == nil then
    self:CloseSelf()
    return
  end
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
    },
    btn_help = {
      listener = handler(self, self.OnBtn_Help),
      variName = "btn_help"
    },
    btn_enter = {
      listener = handler(self, self.onEnter),
      variName = "btn_enter"
    }
  }
  self.txt_restime = self:getNode("txt_restime")
  self:addBatchBtnListener(btnBatchListener)
  self:initMosterHead()
end
function TthjEntrance:initMosterHead()
  self.curMoster = {}
  self:flushPlayerPro(self.playerParam)
  self:setWinPetInfo(self.playerParam.itemid)
end
function TthjEntrance:selectMoster(index, pid)
  print(" ***************  index========= ", index, self.curSelectInd)
  if index > self.curSelectInd + 1 then
    ShowNotifyTips("此关卡还没解锁")
  end
end
function TthjEntrance:showCanGetObj(layer)
  local mainHero = g_LocalPlayer:getMainHero()
  local typeID = mainHero:getTypeId()
  local heroInfo = data_Hero[typeID]
  local worldPos = self:getPosition()
  local size = self:getContentSize()
  local dataTable
  if layer == 1 then
    dataTable = data_TongTian1
  elseif layer == 2 then
    dataTable = data_TongTian2
  elseif layer == 3 then
    dataTable = data_TongTian3
  elseif layer == 4 then
    dataTable = data_TongTian4
  elseif layer == 5 then
    dataTable = data_TongTian5
  elseif layer == 6 then
    dataTable = data_TongTian6
  end
  if dataTable == nil then
    return
  end
  if self.m_monsterlv == nil then
    print("服务器拿回来的怪物等级为空   直接拿本地的某个等级 作为显示")
    for k, v in pairs(dataTable) do
      if v ~= nil then
        self.m_monsterlv = k
        break
      end
    end
  end
  local listtemple = dataTable[self.m_monsterlv].Item or {}
  local itemList = {}
  for k, v in pairs(listtemple) do
    if v ~= nil then
      itemList[#itemList + 1] = v
    end
  end
  local ptb = {}
  if itemList ~= nil then
    table.sort(itemList, function(a, b)
      if a == nil or b == nil then
        return false
      elseif a.order == nil or b.order == nil then
        return false
      else
        return a.order < b.order
      end
      return false
    end)
  end
  for k, v in pairs(itemList) do
    if type(v) == "table" then
      for itemid, num in pairs(v) do
        if itemid ~= "order" then
          local iscontent = false
          for mk, mv in pairs(ptb) do
            if mv == num[1] then
              iscontent = true
              break
            end
          end
          if iscontent == false then
            ptb[#ptb + 1] = num[1]
          end
        end
      end
    end
  end
  if layer == 6 then
    local rwtb = data_TongTianFinalAward.Item
    if rwtb and type(rwtb) == "table" then
      for itemid, num in pairs(rwtb) do
        local iscontent = false
        for mk, mv in pairs(ptb) do
          if mv == itemid then
            iscontent = true
            break
          end
        end
        if iscontent == false then
          ptb[#ptb + 1] = itemid
        end
      end
    end
  end
  if #ptb == 0 then
    return
  end
  self:createItem(ptb, layer)
end
function TthjEntrance:createItem(params, layer)
  if params == nil then
    return
  end
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
  })
end
function TthjEntrance:flushPlayerPro(param)
  if self.isclean == true then
    print("this class had be clean up !!! ")
    return
  end
  if param == nil then
    print(" flush  fail  param  is nil ")
    return
  end
  local curpro
  local lc = 0
  local teamId = g_TeamMgr:getLocalPlayerTeamId()
  local captainId
  if teamId ~= nil and teamId ~= 0 then
    captainId = g_TeamMgr:getTeamCaptain(teamId)
  end
  self.m_monsterlv = param.monsterlv
  for k, v in pairs(param.lst) do
    if v.pid == g_LocalPlayer:getPlayerId() then
      lc = v.leftcnt
    end
    self.playerInfo[k] = v
    if v ~= nil and type(v.progress) == "number" then
      if captainId ~= nil then
        if v.pid == captainId then
          curpro = v.progress
        elseif curpro == nil then
          curpro = v.progress
        end
      elseif curpro == nil then
        curpro = v.progress
      elseif v.pid == g_LocalPlayer:getPlayerId() then
        curpro = v.progress
      end
    end
  end
  if curpro == nil then
    curpro = 0
  end
  self.curSelectInd = curpro
  self:flushMonsterState(curpro)
  if self.txt_restime then
    lc = lc or 0
    self.txt_restime:setText(string.format("剩余次数: %d", lc))
  end
end
function TthjEntrance:setWinPetInfo(itemid)
  local petTypeId = itemid or 20009
  local role_aureole = self:getNode("role_aureole")
  local x, y = role_aureole:getPosition()
  local roleParent = role_aureole:getParent()
  local z = role_aureole:getZOrder()
  if self.m_RoleAni ~= nil then
    if self.m_RoleAni._addClickWidget then
      self.m_RoleAni._addClickWidget:removeFromParentAndCleanup(true)
      self.m_RoleAni._addClickWidget = nil
    end
    self.m_RoleAni:removeFromParentAndCleanup(true)
    self.m_RoleAni = nil
  end
  local shape = data_getRoleShape(petTypeId)
  self.m_DynamicLoadShape = shape
  local path = data_getWarBodyPngPathByShape(shape, DIRECTIOIN_RIGHTDOWN)
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.__isExist and self.m_DynamicLoadShape == shape then
      local offx, offy = 0, 0
      self.m_RoleAni, offx, offy = createWarBodyByShape(shape, DIRECTIOIN_RIGHTDOWN)
      self.m_RoleAni:playAniWithName("guard_4", -1)
      roleParent:addNode(self.m_RoleAni, z + 1)
      self.m_RoleAni:setPosition(x + offx, y + offy)
      self.m_RoleAni:setOpacity(0)
      self.m_RoleAni:runAction(CCFadeIn:create(0.3))
      self:addclickAniForPetAni(self.m_RoleAni, role_aureole)
    end
  end)
  if self.m_RoleAureole == nil then
    self.m_RoleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
    roleParent:addNode(self.m_RoleAureole, z)
    self.m_RoleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  end
  if self.m_RoleShadow == nil then
    self.m_RoleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
    roleParent:addNode(self.m_RoleShadow, z)
    self.m_RoleShadow:setPosition(x, y)
  end
  local pet_quality_box = self:getNode("pet_quality_box")
  if self.m_QualityIcon ~= nil then
    self.m_QualityIcon:removeFromParent()
  end
  local iconPath = data_getPetIconPath(petTypeId)
  local iconImg = display.newSprite(iconPath)
  local x, y = pet_quality_box:getPosition()
  local z = pet_quality_box:getZOrder()
  local size = pet_quality_box:getSize()
  local roleParent = pet_quality_box:getParent()
  iconImg:setAnchorPoint(ccp(0, 1))
  iconImg:setPosition(ccp(x, y + size.height))
  roleParent:addNode(iconImg, z + 10)
  self.m_QualityIcon = iconImg
  local txt_petname = self:getNode("txt_petname")
  local petName = data_getPetName(petTypeId)
  txt_petname:setText(petName)
end
function TthjEntrance:onEnter(btnObj, touchType)
  print("  进入关卡   self.curSelectInd = ", self.curSelectInd, g_LocalPlayer:getPlayerInTeamAndIsCaptain())
  activity.tthj:starWar(self.curSelectInd + 1)
  if self.curSelectInd and self.curSelectInd >= 0 and self.curSelectInd < 6 then
    self:CloseSelf()
  else
  end
end
function TthjEntrance:flushMonsterState(curpro)
  print("  TthjEntrance:flushMonsterState    ", curpro)
  if self.curMoster then
    for index = #self.curMoster, 1, -1 do
      if self.curMoster[index] ~= nil then
        self.curMoster[index]:removeFromParentAndCleanup(true)
      end
      self.curMoster[index] = nil
    end
  end
  self.curMoster = {}
  local defaultHeadTypeId = 20001
  for i = 1, 6 do
    local bossshape = data_TongTianBossShape[i] or {}
    local shapeId = bossshape.ShapeId
    local head = CDisplayPetBoardItem.new(i, shapeId or defaultHeadTypeId, i <= curpro + 1, function(mindex, pid)
      self:selectMoster(mindex, pid)
    end)
    local bg_floor = self:getNode(string.format("bg_floor_%d", i))
    if bg_floor == nil then
      return
    end
    local p = bg_floor:getParent()
    p:addChild(head, 15)
    local x, y = bg_floor:getPosition()
    local s = bg_floor:getSize()
    local hsize = head:getSize()
    head:setPosition(ccp(x, y + hsize.height / 2 + s.height / 2 - 3))
    self.curMoster[i] = head
  end
  if self.curMoster then
    for k, v in pairs(self.curMoster) do
      v:setSelected(k == curpro + 1)
      v:setHadDone(curpro >= k)
    end
  end
end
function TthjEntrance:mgrCallback(param)
  if param.sign == 1 then
    self:flushPlayerPro(param.param)
  end
end
function TthjEntrance:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
  self:onCleanup()
end
function TthjEntrance:OnBtn_Help()
  getCurSceneView():addSubView({
    subView = CTthjRule.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function TthjEntrance:onCleanup()
  self.isclean = false
  if self.curMoster then
    for index = #self.curMoster, 1, -1 do
      if self.curMoster[index] ~= nil then
      end
      self.curMoster[index] = nil
    end
  end
  g_tthjEnter = nil
end
function TthjEntrance:Clear()
  self:onCleanup()
end
CTthjRule = class("CTthjRule", CcsSubView)
function CTthjRule:ctor()
  CTthjRule.super.ctor(self, "views/tthjrule.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
end
function CTthjRule:Btn_Close(obj, t)
  self:CloseSelf()
end
function CTthjRule:Clear()
end
