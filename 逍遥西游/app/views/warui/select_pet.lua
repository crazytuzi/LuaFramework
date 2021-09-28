selectPet = class("selectPet", CcsSubView)
function selectPet:ctor(waruiObj)
  selectPet.super.ctor(self, "views/select_pet.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_WarUIObj = waruiObj
  self.m_PetList = self:getNode("scrollList")
  local petIdList = {}
  local tempData = g_WarScene:getInitWarPetList()
  for tempPID, _ in pairs(tempData) do
    petIdList[#petIdList + 1] = tempPID
  end
  table.sort(petIdList, function(id_a, id_b)
    if id_a == nil or id_b == nil then
      return false
    end
    local petObj_a = g_LocalPlayer:getObjById(id_a)
    local petObj_b = g_LocalPlayer:getObjById(id_b)
    local ltype_a = data_getPetLevelType(petObj_a:getTypeId())
    local ltype_b = data_getPetLevelType(petObj_b:getTypeId())
    local zs_a = petObj_a:getProperty(PROPERTY_ZHUANSHENG)
    local zs_b = petObj_b:getProperty(PROPERTY_ZHUANSHENG)
    local lv_a = petObj_a:getProperty(PROPERTY_ROLELEVEL)
    local lv_b = petObj_b:getProperty(PROPERTY_ROLELEVEL)
    if lv_a ~= lv_b then
      return lv_a > lv_b
    elseif zs_a ~= zs_b then
      return zs_a > zs_b
    elseif ltype_a ~= ltype_b then
      return ltype_a > ltype_b
    else
      return id_a < id_b
    end
  end)
  for _, petId in pairs(petIdList) do
    local playerId = g_LocalPlayer:getPlayerId()
    if not g_WarScene:petIsInWar(petId) and g_LocalPlayer:getObjById(petId) ~= nil then
      local petItem = selectPetItem.new(petId)
      self.m_PetList:pushBackCustomItem(petItem:getUINode())
    end
  end
  self.m_PetList:addTouchItemListenerListView(handler(self, self.onSelected))
end
function selectPet:onSelected(item, index, listObj)
  print("selectPet:onSelected(item, index, listObj)", item, index, listObj)
  local tempPetItem = item.m_UIViewParent
  local petId = tempPetItem:getPetID()
  if g_WarScene:petIsDead(petId) then
    ShowNotifyTips("宠物已经战亡,不能召唤")
    return
  end
  if g_WarScene:petIsHasInWar(petId) then
    ShowNotifyTips("同一场战斗不可再次出战")
    return
  end
  self:ShowWarSelectView(false)
  self.m_WarUIObj:SelectPet(petId)
end
function selectPet:Btn_Close(obj, t)
  self:CloseSelf()
end
function selectPet:ShowWarSelectView(flag)
  self:setEnabled(flag)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setEnabled(flag)
  end
end
function selectPet:Clear()
  self.m_WarUIObj:CancelAction()
  self.m_WarUIObj = nil
end
return selectPet
