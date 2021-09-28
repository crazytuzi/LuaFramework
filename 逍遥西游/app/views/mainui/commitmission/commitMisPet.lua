COMMITPET_TYPE_SMAndSJ = 1
local selectCondition = {
  [COMMITPET_TYPE_SMAndSJ] = function(petObj)
    if petObj == nil then
      return false
    end
    local hasNeiDan = petObj:HasNeidanObj() or 0
    if hasNeiDan > 0 then
      return false
    end
    return true
  end
}
commitMisPet = class("commitMisPet", CcsSubView)
function commitMisPet:ctor(param)
  commitMisPet.super.ctor(self, "views/commitpet.csb")
  param = param or {}
  local btnBatchListener = {
    btn_commit = {
      listener = handler(self, self.OnBtn_Commit),
      variName = "btn_commit",
      param = {2}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_curSelectPet = nil
  self.m_curPlayerId = param.playerId
  self.m_commitListener = param.commitListener
  self.m_commitType = param.commitType or 0
  if self.m_curPlayerId == nil then
    local mainHero = g_LocalPlayer:getMainHero()
    self.m_curPlayerId = mainHero:getPlayerId()
  end
  self.m_petObjIdList = param.petObjIdList
  self.m_ly_petlist = self:getNode("ly_petlist")
  self.m_right_layer = self:getNode("ly_right")
  self.m_ly_petlist:setVisible(false)
  self.m_right_layer:setVisible(false)
  local parent = self.m_ly_petlist:getParent()
  local px, py = self.m_ly_petlist:getPosition()
  local zOrder = self.m_ly_petlist:getZOrder()
  if self.m_petObjIdList == nil then
    self.m_petObjIdList = {}
    self.m_petTypeList = {}
    local temptb = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
    self.m_petObjIdList = DeepCopyTable(temptb)
    local length = #self.m_petObjIdList
    for index = length, 1, -1 do
      local petId = self.m_petObjIdList[index]
      local petObj = g_LocalPlayer:getObjById(petId)
      if petObj then
        local sc = selectCondition[self.m_commitType]
        local need = true
        if sc == nil then
          need = true
        elseif type(sc) == "function" and sc(petObj) == false then
          need = false
        else
          need = true
        end
        if need then
          local petTypeId = petObj:getTypeId()
          table.insert(self.m_petTypeList, 1, petTypeId)
        else
          table.remove(self.m_petObjIdList, index)
        end
      else
        table.remove(self.m_petObjIdList, index)
      end
    end
  end
  if self.m_petTypeList == nil then
    self.m_petTypeList = {}
    for index, petId in pairs(self.m_petObjIdList) do
      local petObj = g_LocalPlayer:getObjById(petId)
      if petObj then
        local petTypeId = petObj:getTypeId()
        self.m_petTypeList[#self.m_petTypeList + 1] = petTypeId
      end
    end
  end
  self.m_PetListBoard_Normal = CDisplayPetBoard.new({
    petTypeList = self.m_petTypeList,
    petObjIdList = self.m_petObjIdList,
    clickListener = handler(self, self.SelectPet),
    xySpace = ccp(3, 2),
    headSize = CCSize(70, 70),
    xySpace = ccp(22, 22),
    pageLines = 4,
    showPagePoint = false
  })
  parent:addChild(self.m_PetListBoard_Normal, zOrder)
  self.m_PetListBoard_Normal:setPosition(ccp(px, py))
end
function commitMisPet:flushRightPanel(petId)
  if self.m_arrtPanel then
    self.m_arrtPanel:CloseSelf()
    self.m_arrtPanel = nil
  end
  local parent = self.m_right_layer:getParent()
  local px, py = self.m_right_layer:getPosition()
  self.m_arrtPanel = CChatDetail_Pet.new(self.m_curPlayerId, petId, nil, {
    extClose = false,
    closeListener = handler(self, self.OnBtn_Close)
  })
  self.m_arrtPanel:setPosition(ccp(px, py))
  parent:addChild(self.m_arrtPanel.m_UINode, 999999)
end
function commitMisPet:SelectPet(petTypeId, petObjId)
  if self.m_curSelectPet == petObjId then
    return
  end
  self.m_curSelectPet = petObjId
  if self.m_PetListBoard_Normal then
    self.m_PetListBoard_Normal:ClearSelectItem()
  end
  self:flushRightPanel(petObjId)
end
function commitMisPet:OnBtn_Commit()
  if self.m_commitListener then
    self.m_commitListener(self.m_curSelectPet)
  end
  self:OnBtn_Close()
end
function commitMisPet:OnBtn_Close()
  self:CloseSelf()
  if self.m_arrtPanel then
    self.m_arrtPanel:CloseSelf()
    self.m_arrtPanel = nil
  end
end
function commitMisPet:Clear()
  if g_commitPetView == self then
    g_commitPetView = nil
  end
  self.m_commitListener = nil
end
function OpenMissionCommitPetView(param)
  if g_commitPetView then
    g_commitPetView:CloseSelf()
    g_commitPetView = nil
  end
  g_commitPetView = commitMisPet.new(param)
  getCurSceneView():addSubView({
    subView = g_commitPetView,
    zOrder = MainUISceneZOrder.menuView
  })
end
