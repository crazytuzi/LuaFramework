local ssskill_select_item = class("ssskill_select_item", CcsSubView)
function ssskill_select_item:ctor(petObj)
  ssskill_select_item.super.ctor(self, "views/pet_ssskill_sel_item.json")
  self.m_Id = petObj:getObjId()
  self.m_BgPic = self:getNode("itembg")
  local headbg = self:getNode("headbg")
  local headParent = headbg:getParent()
  local x, y = headbg:getPosition()
  local petTypeId = petObj:getTypeId()
  local head = createHeadIconByRoleTypeID(petTypeId)
  headParent:addNode(head, 1)
  head:setPosition(ccp(x + HEAD_OFF_X, y + HEAD_OFF_Y))
  local petName = petObj:getProperty(PROPERTY_NAME)
  local zs = petObj:getProperty(PROPERTY_ZHUANSHENG)
  local lv = petObj:getProperty(PROPERTY_ROLELEVEL)
  local color = NameColor_Pet[zs] or ccc3(255, 255, 255)
  local name = self:getNode("name")
  name:setText(petName)
  name:setColor(color)
  local level = self:getNode("level")
  level:setText(string.format("%d转%d级", zs, lv))
end
function ssskill_select_item:setTouchStatus(isTouch)
  self.m_BgPic:stopAllActions()
  if isTouch then
    self.m_BgPic:setScaleX(0.95)
    self.m_BgPic:setScaleY(0.95)
  else
    self.m_BgPic:setScaleX(1)
    self.m_BgPic:setScaleY(1)
    self.m_BgPic:runAction(transition.sequence({
      CCScaleTo:create(0.1, 1.05, 1.05),
      CCScaleTo:create(0.1, 1, 1)
    }))
  end
end
function ssskill_select_item:getId()
  return self.m_Id
end
function ssskill_select_item:Clear()
end
local ssskill_select = class("ssskill_select", CcsSubView)
function ssskill_select:ctor(sslist)
  ssskill_select.super.ctor(self, "views/pet_ssskill_sel.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "btn_close"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local _ssSortFunc = function(a, b)
    if a == nil or b == nil then
      return false
    end
    local zs_a = a:getProperty(PROPERTY_ZHUANSHENG)
    local zs_b = b:getProperty(PROPERTY_ZHUANSHENG)
    if zs_a ~= zs_b then
      return zs_a > zs_b
    else
      local lv_a = a:getProperty(PROPERTY_ROLELEVEL)
      local lv_b = b:getProperty(PROPERTY_ROLELEVEL)
      if lv_a ~= lv_b then
        return lv_a > lv_b
      else
        return a:getObjId() < b:getObjId()
      end
    end
  end
  self.list_detail = self:getNode("list_detail")
  self.list_detail:addTouchItemListenerListView(handler(self, self.ChooseItem), handler(self, self.ListEventListener))
  table.sort(sslist, _ssSortFunc)
  for _, petObj in pairs(sslist) do
    local item = ssskill_select_item.new(petObj)
    self.list_detail:pushBackCustomItem(item.m_UINode)
  end
end
function ssskill_select:Btn_Close()
  self:CloseSelf()
end
function ssskill_select:ChooseItem(item, index, listObj)
  if item then
    item = item.m_UIViewParent
    local petId = item:getId()
    ShowSSSKillLearnDlg(petId)
  end
  self:setVisible(false)
  local act1 = CCDelayTime:create(0.01)
  local act2 = CCCallFunc:create(function()
    self:Btn_Close()
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function ssskill_select:ListEventListener(item, index, listObj, status)
  if status == LISTVIEW_ONSELECTEDITEM_START then
    if item then
      item = item.m_UIViewParent
      item:setTouchStatus(true)
      self.m_TouchStartItem = item
    end
  elseif status == LISTVIEW_ONSELECTEDITEM_END then
    if self.m_TouchStartItem then
      self.m_TouchStartItem:setTouchStatus(false)
      self.m_TouchStartItem = nil
    end
    if item then
      item = item.m_UIViewParent
      item:setTouchStatus(false)
    end
  end
end
function ssskill_select:Clear()
  self.m_TouchStartItem = nil
end
function ShowSelectListOfAllSS()
  local allpetlist = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  local sslist = {}
  for _, petId in pairs(allpetlist) do
    local petObj = g_LocalPlayer:getObjById(petId)
    if petObj then
      local petTypeId = petObj:getTypeId()
      if data_getPetTypeIsHasShenShouSkill(petTypeId) then
        sslist[#sslist + 1] = petObj
      end
    end
  end
  if #sslist <= 0 then
    ShowNotifyTips("你没有神兽")
  else
    getCurSceneView():addSubView({
      subView = ssskill_select.new(sslist),
      zOrder = MainUISceneZOrder.menuView
    })
  end
end
function ShowLearSSSkillRequire(npcId)
  local shapeId, npcName = data_getRoleShapeAndName(npcId)
  local costCoin = data_Variables.SS_Skill_CostCoin
  local costCloseV = data_Variables.SS_Skill_CostCloseV
  local desc = string.format("想习得神兽技能，必须满足四点要求:1.前三个技能栏中已学会技能；2.需要花费%d万#<IR1>#；3.花费神兽亲密度%d万；4.神兽技能专属栏已解封。", math.floor(costCoin / 10000), math.floor(costCloseV / 10000))
  local shapePath = data_getBigHeadPathByShape(shapeId)
  getCurSceneView():ShowInformView(npcName, {
    {"", desc}
  }, nil, shapePath, ccc3(255, 255, 0))
end
