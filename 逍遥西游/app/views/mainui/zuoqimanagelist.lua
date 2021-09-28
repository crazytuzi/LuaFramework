local DefinePetState_CannotManaged = -1
local DefinePetState_NotManaged = 0
local DefinePetState_Managed = 1
local CZuoqiManageListItem = class("CZuoqiManageListItem")
function CZuoqiManageListItem:ctor(petId, warFlag, clickHandler)
  self.m_PetId = petId
  local player = g_DataMgr:getPlayer()
  local itemObj = player:getObjById(petId)
  local itemView = createClickHead({
    roleTypeId = itemObj:getTypeId(),
    autoSize = nil,
    clickListener = function(...)
      clickHandler(petId)
    end,
    noBgFlag = nil,
    offx = nil,
    offy = nil,
    clickDel = nil,
    LongPressTime = nil,
    LongPressListener = nil,
    LongPressEndListner = nil
  })
  self.m_ItemView = itemView
  local size = self.m_ItemView:getContentSize()
  if warFlag then
    local warIcon = display.newSprite("views/mainviews/pic_mission_wartips.png")
    warIcon:setAnchorPoint(ccp(1, 0))
    self.m_ItemView:addNode(warIcon, 1)
    warIcon:setPosition(size.width - 5, 5)
  end
  local zs = itemObj:getProperty(PROPERTY_ZHUANSHENG)
  local lv = itemObj:getProperty(PROPERTY_ROLELEVEL)
  local levelTxt = ui.newTTFLabel({
    text = string.format("%d转%d级", zs, lv),
    size = 20,
    font = KANG_TTF_FONT,
    color = ccc3(255, 255, 255)
  })
  self.m_ItemView:addNode(levelTxt, 0)
  levelTxt:setPosition(ccp(size.width / 2, -10))
  self.m_IsManageState = DefinePetState_NotManaged
  self.m_ManageIcon = display.newSprite("views/zuoqi/managestate.png")
  self.m_ItemView:addNode(self.m_ManageIcon, 10)
  self.m_ManageIcon:setPosition(size.width / 2 - 1, size.height / 2 + 2)
  self.m_ManageDisableIcon = display.newSprite("views/zuoqi/managedisablestate.png")
  self.m_ItemView:addNode(self.m_ManageDisableIcon, 10)
  self.m_ManageDisableIcon:setPosition(size.width / 2 - 1, size.height / 2 + 2)
end
function CZuoqiManageListItem:getItemView()
  return self.m_ItemView
end
function CZuoqiManageListItem:setManageState(iManage)
  self.m_IsManageState = iManage
  if self.m_IsManageState == DefinePetState_Managed then
    self.m_ManageIcon:setVisible(true)
    self.m_ManageDisableIcon:setVisible(false)
  elseif self.m_IsManageState == DefinePetState_CannotManaged then
    self.m_ManageIcon:setVisible(false)
    self.m_ManageDisableIcon:setVisible(true)
  else
    self.m_ManageIcon:setVisible(false)
    self.m_ManageDisableIcon:setVisible(false)
  end
end
function CZuoqiManageListItem:getManageState()
  return self.m_IsManageState
end
CZuoqiManageList = class("CZuoqiManageList", function()
  return Widget:create()
end)
function CZuoqiManageList:ctor(petList, petWarPos, clicklistener, listParam)
  self.m_ClickListener = clicklistener
  self:setNodeEventEnabled(true)
  self:SetPetList(petList, petWarPos, listParam)
end
function CZuoqiManageList:SetPetList(petList, petWarPos, listParam)
  local typeList = {}
  self.m_ObjViewList = {}
  self.m_ItemNum = #petList
  local delW = 5
  local delH = 0
  local oneLineW = 100
  local oneLineH = 125
  local oneLineNum = 3
  local w = listParam.width or 290
  local h = oneLineH * math.floor((self.m_ItemNum + oneLineNum - 1) / oneLineNum)
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(w, h))
  self:setContentSize(CCSize(w, h))
  self:setAnchorPoint(ccp(0, 1))
  for index, petId in pairs(petList) do
    local warFlag = petWarPos[petId] ~= nil
    local itemObj = CZuoqiManageListItem.new(petId, warFlag, handler(self, self.ClickPetItem))
    self.m_ObjViewList[petId] = itemObj
    local itemView = itemObj:getItemView()
    itemView:setPosition(ccp(delW + (index - 1) % oneLineNum * oneLineW, h - oneLineH - (math.ceil(index / oneLineNum) - 1) * oneLineH - delH + 20))
    self:addChild(itemView)
  end
end
function CZuoqiManageList:ReloadManageInfo(manageList, manageListByOther)
  print_lua_table(manageList)
  print_lua_table(manageListByOther)
  for petId, petObj in pairs(self.m_ObjViewList) do
    if manageList[petId] == true then
      petObj:setManageState(DefinePetState_Managed)
    elseif manageListByOther[petId] == true then
      petObj:setManageState(DefinePetState_CannotManaged)
    else
      petObj:setManageState(DefinePetState_NotManaged)
    end
  end
end
function CZuoqiManageList:ClickPetItem(petId)
  print("-->>>ClickPetItem:", petId)
  local petObj = self.m_ObjViewList[petId]
  if petObj == nil then
    return
  end
  local iManage = petObj:getManageState()
  if iManage == DefinePetState_CannotManaged then
    ShowNotifyTips("该召唤兽已被其他坐骑管制")
  elseif iManage == DefinePetState_Managed then
    if self.m_ClickListener then
      self.m_ClickListener(petId, false)
    end
  elseif iManage == DefinePetState_NotManaged and self.m_ClickListener then
    self.m_ClickListener(petId, true)
  end
end
function CZuoqiManageList:onCleanup()
  self.m_ObjViewList = {}
  self.m_ClickListener = nil
end
