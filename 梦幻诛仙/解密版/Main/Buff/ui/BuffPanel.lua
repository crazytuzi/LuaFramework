local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BuffPanel = Lplus.Extend(ECPanelBase, "BuffPanel")
local def = BuffPanel.define
local BuffMgr = require("Main.Buff.BuffMgr")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local EffectType = require("consts.mzm.gsp.buff.confbean.EffectType")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
def.field("table")._sortedBuffList = nil
def.field("number")._timerId = 0
def.field("number")._focusIndex = 0
def.field("userdata").ui_List_Buff = nil
def.field("table").btnOriginalPos = nil
local instance
def.static("=>", BuffPanel).Instance = function()
  if instance == nil then
    instance = BuffPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  self:CreatePanel(RESPATH.PREFAB_BUFF_PANEL, 2)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.SYNC_BUFF_LIST, BuffPanel.OnSyncBuffList)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.ADD_BUFF, BuffPanel.OnAddBuff)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.REMOVE_BUFF, BuffPanel.OnRemoveBuff)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.BUFF_INFO_UPDATE, BuffPanel.OnBuffInfoUpdate)
  self:Fill()
  self._timerId = GameUtil.AddGlobalTimer(1, false, BuffPanel.OnTimer)
end
def.method().InitUI = function(self)
  self.m_panel:SetActive(true)
  local ui_List_Buff = self.m_panel:FindDirect("Img_Bg0/Scroll View_Buff/List_Buff")
  ui_List_Buff:GetComponent("UIList").itemCount = 0
  self.ui_List_Buff = ui_List_Buff
  self.btnOriginalPos = ui_List_Buff:FindDirect("Img_BgBuff01/FixHeight_Group/Btn_Add").localPosition
end
def.override().OnDestroy = function(self)
  self._focusIndex = 0
  self._sortedBuffList = nil
  self:ClearUI()
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.SYNC_BUFF_LIST, BuffPanel.OnSyncBuffList)
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.ADD_BUFF, BuffPanel.OnAddBuff)
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.REMOVE_BUFF, BuffPanel.OnRemoveBuff)
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.BUFF_INFO_UPDATE, BuffPanel.OnBuffInfoUpdate)
  if self._timerId then
    GameUtil.RemoveGlobalTimer(self._timerId)
    self._timerId = 0
  end
end
def.method().ClearUI = function(self)
  self.ui_List_Buff = nil
  self.btnOriginalPos = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Modal" then
    self:HidePanel()
  elseif string.sub(id, 1, #"Btn_Add_") == "Btn_Add_" then
    local index = tonumber(string.sub(id, #"Btn_Add_" + 1, -1))
    self:OnSupplementButtonClick(index)
    GUIUtils.SetLightEffect(obj, GUIUtils.Light.None)
  elseif string.sub(id, 1, #"Btn_Cancel_") == "Btn_Cancel_" then
    local index = tonumber(string.sub(id, #"Btn_Cancel_" + 1, -1))
    self:OnDeleteButtonClick(index)
  elseif string.sub(id, 1, #"Btn_Mini_") == "Btn_Mini_" then
    local index = tonumber(string.sub(id, #"Btn_Mini_" + 1, -1))
    self:OnCustomButtonClick(index)
  end
end
def.static("table", "table").OnSyncBuffList = function()
  local self = instance
  self:Fill()
end
def.static("table", "table").OnAddBuff = function()
  local self = instance
  self:Fill()
end
def.static("table", "table").OnRemoveBuff = function(params)
  local buffId = params[1]
  local self = instance
  if self._sortedBuffList == nil then
    return
  end
  for i, buff in ipairs(self._sortedBuffList) do
    if buff.id == buffId then
      self._focusIndex = i
    end
  end
  self:AdjustFocusedIndex()
  self:Fill()
end
def.static("table", "table").OnBuffInfoUpdate = function(params)
  local self = instance
  if self._sortedBuffList == nil then
    return
  end
  local index = 0
  local buffId = params[1]
  for i, buff in ipairs(self._sortedBuffList) do
    if buffId == buff.id then
      index = i
    end
  end
  if index > 0 then
    local ui_List_Buff = self.ui_List_Buff
    local uiList = ui_List_Buff:GetComponent("UIList")
    local listItems = uiList:get_children()
    local item = listItems[index]
    self:SetBuffItemInfo(item, index, self._sortedBuffList[index])
  else
    warn(string.format("try to update the information of buff(%d), but it isn't exist.", buffId))
  end
end
def.method().AdjustFocusedIndex = function(self)
  if self._sortedBuffList == nil then
    return
  end
  self._focusIndex = self._focusIndex - 1
end
def.method().Fill = function(self)
  local BuffMgr = require("Main.Buff.BuffMgr")
  self._sortedBuffList = BuffMgr.Instance():GetBuffList()
  self:SetBuffList(self._sortedBuffList)
end
def.method("table").SetBuffList = function(self, buffList)
  local buffAmount = #buffList
  local ui_List_Buff = self.ui_List_Buff
  local uiList = ui_List_Buff:GetComponent("UIList")
  uiList.itemCount = buffAmount
  uiList:Resize()
  local listItems = uiList:get_children()
  for i = 1, buffAmount do
    local item = listItems[i]
    local buff = buffList[i]
    self:SetBuffItemInfo(item, i, buff)
  end
  uiList:Reposition()
  GameUtil.AddGlobalLateTimer(true, 0, function()
    GameUtil.AddGlobalLateTimer(true, 0, function()
      if uiList and not uiList.isnil then
        uiList:Reposition()
      end
    end)
  end)
  if 0 < self._focusIndex then
    do
      local uiScrollView = self.ui_List_Buff.transform.parent:GetComponent("UIScrollView")
      local item = listItems[self._focusIndex]
      GameUtil.AddGlobalLateTimer(true, 0, function()
        GameUtil.AddGlobalLateTimer(true, 0, function()
          if item and not item.isnil then
            uiScrollView:DragToMakeVisible(item.transform, 10)
          end
        end)
      end)
      self._focusIndex = 0
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "number", "table").SetBuffItemInfo = function(self, item, index, buff)
  local icon = buff:GetIcon()
  local buffName = buff:GetName()
  local FixHeight_Group = item:FindDirect(string.format("FixHeight_Group_%d", index))
  local ui_Label_Title = FixHeight_Group:FindDirect(string.format("Img_BgTitle01_%d/Label_Title01_%d", index, index))
  ui_Label_Title:GetComponent("UILabel"):set_text(buffName)
  local ui_Img_Icon = FixHeight_Group:FindDirect(string.format("Img_BgIcon01_%d/Img_Icon01_%d", index, index))
  local uiTexture = ui_Img_Icon:GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, icon)
  self:SetBuffItemRemainValue(item, index, buff)
  self:SetBuffItemDesc(item, index, buff)
  local btnSupplement = FixHeight_Group:FindDirect(string.format("Btn_Add_%d", index))
  local btnDelete = FixHeight_Group:FindDirect(string.format("Btn_Cancel_%d", index))
  local btnCustom = FixHeight_Group:FindDirect(string.format("Btn_Mini_%d", index))
  local activeBtns = {}
  local function setBtnActive(btn, isActive)
    GUIUtils.SetActive(btn, isActive)
    if isActive then
      table.insert(activeBtns, btn)
    end
  end
  local hasCustomAction = buff:HasCustomAction()
  setBtnActive(btnCustom, hasCustomAction)
  if hasCustomAction then
    local Label = btnCustom:FindDirect(string.format("Label_%d", index))
    GUIUtils.SetText(Label, buff:GetCustomActionName())
  end
  local canSupplement = buff:CanSupplement()
  setBtnActive(btnSupplement, canSupplement)
  if canSupplement then
    local showLight = buff:NeedShowLight()
    if showLight then
      GUIUtils.SetLightEffect(btnSupplement, GUIUtils.Light.Square)
    end
  end
  local canDelete = buff:CanDelete()
  setBtnActive(btnDelete, canDelete)
  local Img_TagPic = FixHeight_Group:FindDirect(string.format("Img_TeamPVP_%d", index))
  GUIUtils.SetActive(Img_TagPic, true)
  GUIUtils.SetTexture(Img_TagPic, buff:GetChartlet())
  self:ArrangeBtnsPos(activeBtns)
  item:GetComponent("UITableResizeBackground"):Reposition()
end
def.method("table").ArrangeBtnsPos = function(self, btns)
  local offsetX, offsetY = 0, 0
  local originalPos = self.btnOriginalPos
  local margin = 4
  local MAX_NUM_PER_ROW = 2
  local col = 0
  for i, btn in ipairs(btns) do
    local localPosition = btn.localPosition
    btn.localPosition = originalPos + Vector.Vector3.new(offsetX, offsetY, 0)
    local uiWidget = btn:GetComponent("UIWidget")
    col = col + 1
    if MAX_NUM_PER_ROW > col then
      offsetX = offsetX - uiWidget.width - margin
    else
      col = 0
      offsetX = 0
      offsetY = offsetY - uiWidget.height - margin
    end
  end
end
def.method("userdata", "number", "table").SetBuffItemDesc = function(self, item, index, buff)
  local buffDesc = buff:GetDescription()
  local ui_Label_Discribe = item:FindDirect(string.format("Label_Discribe_%d", index))
  ui_Label_Discribe:GetComponent("UILabel"):set_text(buffDesc)
end
def.method("userdata", "number", "table").SetBuffItemRemainValue = function(self, item, index, buff)
  local FixHeight_Group = item:FindDirect(string.format("FixHeight_Group_%d", index))
  local ui_Label_Time = FixHeight_Group:FindDirect(string.format("Label_Time_%d", index))
  local formatText = buff:GetStateDescription()
  ui_Label_Time:SetActive(formatText ~= "")
  if formatText ~= "" then
    ui_Label_Time:GetComponent("UILabel"):set_text(formatText)
  end
end
def.static().OnTimer = function()
  local self = instance
  if self._sortedBuffList == nil then
    return
  end
  local ui_List_Buff = self.ui_List_Buff
  local listItems = ui_List_Buff:GetComponent("UIList"):get_children()
  for i, buff in ipairs(self._sortedBuffList) do
    local item = listItems[i]
    if buff:NeedTickStateDescription() then
      self:SetBuffItemRemainValue(item, i, buff)
    end
    if buff:NeedTickDescription() then
      self:SetBuffItemDesc(item, i, buff)
    end
  end
end
def.method("number").OnSupplementButtonClick = function(self, index)
  local buff = self._sortedBuffList[index]
  buff:OnSupplement()
end
def.method("number").OnDeleteButtonClick = function(self, index)
  local buff = self._sortedBuffList[index]
  buff:OnDelete()
end
def.method("number").OnCustomButtonClick = function(self, index)
  local buff = self._sortedBuffList[index]
  buff:OnCustomAction()
end
BuffPanel.Commit()
return BuffPanel
