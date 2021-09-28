CRebirthPetShow = class(".CRebirthPetShow", CcsSubView)
function CRebirthPetShow:ctor()
  CRebirthPetShow.super.ctor(self, "views/select_pet.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_PetList = self:getNode("scrollList")
  local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
  self.m_OwnerInfo = {}
  local roleList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
  for _, roleId in pairs(roleList) do
    local petd = g_LocalPlayer:getObjProperty(roleId, PROPERTY_PETID)
    if petd ~= nil and petd ~= 0 then
      self.m_OwnerInfo[petd] = roleId
    end
  end
  table.sort(petIds, function(id_a, id_b)
    if id_a == nil or id_b == nil then
      return false
    end
    local owner_a = self.m_OwnerInfo[id_a]
    local owner_b = self.m_OwnerInfo[id_b]
    local mainHeroID = g_LocalPlayer:getMainHeroId()
    if owner_a == mainHeroID and owner_b ~= mainHeroID then
      return true
    elseif owner_a ~= mainHeroID and owner_b == mainHeroID then
      return false
    else
      local petObj_a = g_LocalPlayer:getObjById(id_a)
      local petObj_b = g_LocalPlayer:getObjById(id_b)
      local ltype_a = data_getPetLevelType(petObj_a:getTypeId())
      local ltype_b = data_getPetLevelType(petObj_b:getTypeId())
      if ltype_a ~= ltype_b then
        return ltype_a > ltype_b
      elseif owner_a == nil and owner_b ~= nil then
        return false
      elseif owner_a ~= nil and owner_b == nil then
        return true
      else
        local zs_a = petObj_a:getProperty(PROPERTY_ZHUANSHENG)
        local zs_b = petObj_b:getProperty(PROPERTY_ZHUANSHENG)
        local lv_a = petObj_a:getProperty(PROPERTY_ROLELEVEL)
        local lv_b = petObj_b:getProperty(PROPERTY_ROLELEVEL)
        if zs_a ~= zs_b then
          return zs_a > zs_b
        elseif lv_a ~= lv_b then
          return lv_a > lv_b
        else
          return id_a < id_b
        end
      end
    end
  end)
  for _, petId in pairs(petIds) do
    local petItem = selectPetItem.new(petId)
    self.m_PetList:pushBackCustomItem(petItem:getUINode())
  end
  self.m_PetList:addTouchItemListenerListView(handler(self, self.onSelected))
end
function CRebirthPetShow:onSelected(item, index, listObj)
  local tempPetItem = item.m_UIViewParent
  local petId = tempPetItem:getPetID()
  local petIns = g_LocalPlayer:getObjById(petId)
  if petIns == nil then
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  local heroZs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local petZs = petIns:getProperty(PROPERTY_ZHUANSHENG)
  local petLv = petIns:getProperty(PROPERTY_ROLELEVEL)
  if petZs >= 4 then
    ShowNotifyTips("这个召唤兽已经4转，不能再转生")
    return
  end
  if heroZs <= petZs then
    ShowNotifyTips(string.format("你的主角角色必须%d转后,这个召唤兽才能转生", petZs + 1))
    return
  end
  if petLv < data_getMaxPetLevel(petZs) then
    ShowNotifyTips(string.format("这个召唤兽等级必须到%d级后才能转生", data_getMaxPetLevel(petZs)))
    return
  end
  local close = petIns:getProperty(PROPERTY_CLOSEVALUE)
  if close < data_getPetNeedClose(petZs + 1) then
    ShowNotifyTips(string.format("召唤兽的亲密度必须到%d后才能转生", data_getPetNeedClose(petZs + 1)))
    return
  end
  local exNum = data_getPetExLianyaoNum(petZs)
  local newLv = data_getPetRBNewLv(petZs)
  local initPro = data_getPetRBinitPro(petZs)
  local text
  if exNum > 0 then
    text = string.format("召唤兽转生后等级将会下降为%d级，额外获得%d点属性点，炼妖次数+%d。您确定要转生吗？", newLv, initPro, exNum)
  else
    text = string.format("召唤兽转生后等级将会下降为%d级，额外获得%d点属性点。您确定要转生吗？", newLv, initPro)
  end
  local tempPop = CPopWarning.new({
    title = nil,
    text = text,
    confirmFunc = function()
      self:CloseSelf()
      netsend.netbaseptc.requestPetZS(petId)
    end,
    align = CRichText_AlignType_Left,
    confirmText = "确定",
    cancelText = "取消"
  })
  tempPop:ShowCloseBtn(false)
end
function CRebirthPetShow:Btn_Close(obj, t)
  self:CloseSelf()
end
function CRebirthPetShow:Clear()
end
