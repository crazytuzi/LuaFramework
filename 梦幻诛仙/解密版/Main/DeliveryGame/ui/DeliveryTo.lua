local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DeliveryTo = Lplus.Extend(ECPanelBase, "DeliveryTo")
local ECUIModel = require("Model.ECUIModel")
local GUIUtils = require("GUI.GUIUtils")
local DeliveryGameUtils = require("Main.DeliveryGame.DeliveryGameUtils")
local def = DeliveryTo.define
local instance
def.static("=>", DeliveryTo).Instance = function()
  if instance == nil then
    instance = DeliveryTo()
  end
  return instance
end
def.field("number").activityId = 0
def.field("table").roleList = nil
def.field("userdata").selectRoleId = nil
def.field("number").timer = 0
def.field("table").model = nil
def.static("number", "table").ShowDeliveryTo = function(activityId, roleList)
  local self = DeliveryTo.Instance()
  self.roleList = roleList
  self.selectRoleId = nil
  if self.activityId == activityId then
    if self:IsCreated() then
      if self:IsLoaded() then
        self.selectRoleId = nil
        if self.model then
          self.model:Destroy()
          self.model = nil
        end
        self:UpdateList()
      end
    else
      local res = DeliveryGameUtils.GetActivityRes(activityId)
      self:CreatePanel(res.PREFAB_DELIVERY_TO, 1)
    end
  else
    self:DestroyPanel()
    self.activityId = activityId
    local res = DeliveryGameUtils.GetActivityRes(activityId)
    self:CreatePanel(res.PREFAB_DELIVERY_TO, 1)
  end
end
def.static().Close = function()
  local self = DeliveryTo.Instance()
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:UpdateStatic()
  self:UpdateList()
  self:UpdateCountDown()
end
def.override().OnDestroy = function(self)
  self.selectRoleId = nil
  self.roleList = nil
  GameUtil.RemoveGlobalTimer(self.timer)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.method("userdata", "table", "number").FillItem = function(self, uiGo, info, index)
  local nameLbl = uiGo:FindDirect(string.format("Label_1_%d", index))
  nameLbl:GetComponent("UILabel"):set_text(info.name)
  local lvLbl = uiGo:FindDirect(string.format("Label_2_%d", index))
  lvLbl:GetComponent("UILabel"):set_text(tostring(info.lv))
  local head = uiGo:FindDirect(string.format("Head_%d/Img_Head_%d", index, index))
  if info.avatarId then
    SetAvatarIcon(head, info.avatarId)
  else
    head:GetComponent("UISprite"):set_spriteName(GUIUtils.GetHeadSpriteName(info.occupation, info.gender))
  end
  local bg = uiGo:FindDirect(string.format("Img_Bg1_%d", index))
  if index % 2 == 0 then
    bg:SetActive(false)
  else
    bg:SetActive(true)
  end
  uiGo:GetComponent("UIToggle"):set_value(info.id == self.selectRoleId)
end
def.method().UpdateList = function(self)
  local scroll = self.m_panel:FindDirect("Img_Bg0/Group_FriendList/Group_Scrollview/ScrollView_Friend")
  local list = scroll:FindDirect("Group_List")
  local listCmp = list:GetComponent("UIList")
  local count = #self.roleList
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local roleInfo = self.roleList[i]
    self:FillItem(uiGo, roleInfo, i)
    self.m_msgHandler:Touch(uiGo)
  end
  local empty = self.m_panel:FindDirect("Img_Bg0/Group_Empty")
  if count > 0 then
    empty:SetActive(false)
  else
    empty:SetActive(true)
  end
end
def.method("userdata", "number", "string").FillTime = function(self, lbl, time, endStr)
  if lbl and not lbl.isnil then
    if time <= 0 then
      lbl:GetComponent("UILabel"):set_text(endStr)
    else
      lbl:GetComponent("UILabel"):set_text(tostring(time) .. textRes.Common.Second)
    end
  end
end
def.method().UpdateCountDown = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  local res = DeliveryGameUtils.GetActivityRes(self.activityId)
  local deliveryGameModule = require("Main.DeliveryGame.DeliveryGameModule").Instance()
  local deliveryInfo = deliveryGameModule:GetDeliveryState(self.activityId)
  local lbl = self.m_panel:FindDirect("Img_Bg0/Group_Trans/Group_FalseTime/Label_FalseTime")
  if deliveryInfo then
    do
      local leftTime = deliveryInfo.endTime - GetServerTime()
      self:FillTime(lbl, leftTime, res.text[7])
      self.timer = GameUtil.AddGlobalTimer(1, false, function()
        leftTime = deliveryInfo.endTime - GetServerTime()
        self:FillTime(lbl, leftTime, res.text[7])
        if leftTime <= 0 then
          GameUtil.RemoveGlobalTimer(self.timer)
        end
      end)
    end
  else
    self:FillTime(lbl, -1, res.text[7])
  end
end
def.method().UpdateStatic = function(self)
  local res = DeliveryGameUtils.GetActivityRes(self.activityId)
  local info1 = self.m_panel:FindDirect("Img_Bg0/Label_Tips")
  info1:GetComponent("UILabel"):set_text(res.text[12])
end
def.method("number").SelectRole = function(self, index)
  local roleInfo = self.roleList[index]
  if roleInfo and self.selectRoleId ~= roleInfo.id then
    self.selectRoleId = roleInfo.id
    local toggle = self.m_panel:FindDirect(string.format("Img_Bg0/Group_FriendList/Group_Scrollview/ScrollView_Friend/Group_List/FriendList_%d", index))
    toggle:GetComponent("UIToggle").value = true
    local pubroleModule = require("Main.Pubrole.PubroleModule").Instance()
    pubroleModule:GetServerRoleModelInfo(self.selectRoleId, function(modelInfo)
      self:UpdateModel(modelInfo)
    end)
  end
end
def.method("table").UpdateModel = function(self, modelInfo)
  if self.m_panel and not self.m_panel.isnil then
    do
      local uiModel = self.m_panel:FindDirect("Img_Bg0/Group_Trans/Model"):GetComponent("UIModel")
      if self.model then
        self.model:Destroy()
      end
      self.model = ECUIModel.new(modelInfo.modelid)
      self.model:AddOnLoadCallback("delivery", function()
        uiModel.modelGameObject = self.model.m_model
        if uiModel.mCanOverflow ~= nil then
          uiModel.mCanOverflow = true
          local camera = uiModel:get_modelCamera()
          camera:set_orthographic(true)
        end
      end)
      LoadModel(self.model, modelInfo, 0, 0, 180, false, false)
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Fresh" then
    require("Main.DeliveryGame.DeliveryGameModule").Instance():RequestRelatedPlayers(self.activityId)
  elseif id == "Btn_Trans" then
    if self.selectRoleId then
      require("Main.DeliveryGame.DeliveryGameModule").Instance():Delivery(self.activityId, self.selectRoleId)
    else
      local res = DeliveryGameUtils.GetActivityRes(self.activityId)
      Toast(res.text[8])
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, value)
  if string.sub(id, 1, 11) == "FriendList_" and value then
    local index = tonumber(string.sub(id, 12))
    if index then
      self:SelectRole(index)
    end
  end
end
DeliveryTo.Commit()
return DeliveryTo
