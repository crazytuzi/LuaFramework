selectDrug = class("selectDrug", CcsSubView)
function selectDrug:ctor(waruiObj, canUseDrugList)
  selectDrug.super.ctor(self, "views/select_drug.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.Btn_Close),
      variName = "m_Btn_Close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_WarUIObj = waruiObj
  self.m_DrugList = self:getNode("scrollList")
  local tempDict = {}
  for objShapeId, objNum in pairs(canUseDrugList) do
    tempDict[#tempDict + 1] = objShapeId
  end
  table.sort(tempDict)
  for _, objShapeId in pairs(tempDict) do
    local objNum = canUseDrugList[objShapeId]
    if objNum > 0 then
      local drugItem = selectDrugItem.new(objShapeId, objNum)
      self.m_DrugList:pushBackCustomItem(drugItem:getUINode())
    end
  end
  self.m_DrugList:addTouchItemListenerListView(handler(self, self.onSelected))
end
function selectDrug:onSelected(item, index, listObj)
  local tempDrugItem = item.m_UIViewParent
  local drugShape = tempDrugItem:getDrugShape()
  self:ShowWarSelectView(false)
  self.m_WarUIObj:SelectDrug(drugShape)
end
function selectDrug:Btn_Close(obj, t)
  self:CloseSelf()
end
function selectDrug:ShowWarSelectView(flag)
  self:setEnabled(flag)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setEnabled(flag)
  end
end
function selectDrug:Clear()
  self.m_WarUIObj:CancelAction()
  self.m_WarUIObj = nil
end
return selectDrug
