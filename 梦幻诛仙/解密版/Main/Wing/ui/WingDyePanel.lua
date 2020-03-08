local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WingDyePanel = Lplus.Extend(ECPanelBase, "WingDyePanel")
local WingModule = require("Main.Wing.WingModule")
local WingUtils = require("Main.Wing.WingUtils")
local GUIUtils = require("GUI.GUIUtils")
local RoleAndWingModel = require("Main.Wing.ui.RoleAndWingModel")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local def = WingDyePanel.define
local instance
def.static("=>", WingDyePanel).Instance = function()
  if instance == nil then
    instance = WingDyePanel()
  end
  return instance
end
def.field("number").wingId = 0
def.field("table").dyeLib = nil
def.field("number").curIndex = 1
def.field("boolean").isDrag = false
def.field(RoleAndWingModel).modelAndWing = nil
def.field("boolean").useYuanbao = false
def.static("number", "number").ShowDyeWing = function(wingId, oldDyeId)
  local self = WingDyePanel.Instance()
  if self:IsShow() then
    if self.wingId == wingId then
      for k, v in ipairs(self.dyeLib) do
        if v == oldDyeId then
          self.curIndex = k
          break
        end
      end
      self:SelectColor(self.curIndex)
    end
    return
  end
  self.dyeLib = WingUtils.GetWingDyeLibByWingId(wingId)
  if self.dyeLib == nil then
    return
  end
  for k, v in ipairs(self.dyeLib) do
    if v == oldDyeId then
      self.curIndex = k
      break
    end
  end
  self.wingId = wingId
  self.useYuanbao = false
  self:CreatePanel(RESPATH.PANEL_WINGDYE, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WingDyePanel.OnItemChange, self)
  self:UpdateInfo()
  self:CreateColorSelect()
  self:SelectColor(self.curIndex)
  self:CreateModel()
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow and self.modelAndWing then
    self.modelAndWing:Stand()
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WingDyePanel.OnItemChange)
  if self.modelAndWing then
    self.modelAndWing:Destroy()
    self.modelAndWing = nil
  end
end
def.method("table").OnItemChange = function(self, params)
  self:UpdateInfo()
end
def.method().CreateModel = function(self)
  local uiModel = self.m_panel:FindDirect("Img_Bg/Model")
  local uiModelCmp = uiModel:GetComponent("UIModel")
  if self.modelAndWing == nil then
    self.modelAndWing = RoleAndWingModel()
  else
    self.modelAndWing:Destroy()
    self.modelAndWing = RoleAndWingModel()
  end
  local wingCfg = WingUtils.GetWingCfg(self.wingId)
  local outlook = wingCfg.outlook
  local wingDyeId = self.dyeLib[self.curIndex] or 0
  self.modelAndWing:Create(outlook, wingDyeId, function()
    if uiModelCmp.isnil then
      return
    end
    uiModelCmp.mCanOverflow = true
    local camera = uiModelCmp:get_modelCamera()
    camera:set_orthographic(true)
    uiModelCmp.modelGameObject = self.modelAndWing:GetModelGameObject()
  end)
end
def.method().CreateColorSelect = function(self)
  local colorCardRoot = self.m_panel:FindDirect("Img_Bg/Group_Color/Container")
  local childCout = colorCardRoot:get_childCount()
  for i = 1, childCout do
    local card = colorCardRoot:FindDirect("WingColor" .. i)
    if card then
      local dyeId = self.dyeLib[i]
      if dyeId then
        card:SetActive(true)
        self:FillDyeCard(card, dyeId)
        if i == self.curIndex then
          card:GetComponent("UIToggle"):set_value(true)
        end
      else
        card:SetActive(false)
      end
    end
  end
end
def.method("userdata", "number").FillDyeCard = function(self, cardGo, dyeId)
  local dyeData = GetModelColorCfg(dyeId)
  if dyeData then
    local alpha = (dyeData.part2_a < 128 and dyeData.part2_a or 128) / 255 * 2
    GUIUtils.SetColor(cardGo, Color.Color(dyeData.part2_r / 255 * alpha, dyeData.part2_g / 255 * alpha, dyeData.part2_b / 255 * alpha, 1), GUIUtils.COTYPE.SPRITE)
  end
end
def.method("number").SelectColor = function(self, index)
  self.curIndex = index
  local colorCardRoot = self.m_panel:FindDirect("Img_Bg/Group_Color/Container")
  local card = colorCardRoot:FindDirect("WingColor" .. index)
  if card then
    card:GetComponent("UIToggle"):set_value(true)
  end
  if self.modelAndWing then
    local wingCfg = WingUtils.GetWingCfg(self.wingId)
    local outlook = wingCfg.outlook
    local wingDyeId = self.dyeLib[index]
    self.modelAndWing:UpdateWing(outlook, wingDyeId)
  end
end
def.method().UpdateInfo = function(self)
  local dyeItemId = constant.WingConsts.WING_DYE_ITEM_ID
  local needNum = 1
  local dyeItemBase = ItemUtils.GetItemBase(dyeItemId)
  local itemNum = ItemModule.Instance():GetItemCountById(dyeItemId)
  local tex = self.m_panel:FindDirect("Img_Bg/Img_Item/Texture_Item"):GetComponent("UITexture")
  GUIUtils.FillIcon(tex, dyeItemBase.icon)
  local numlbl = self.m_panel:FindDirect("Img_Bg/Img_Item/Label_Num"):GetComponent("UILabel")
  numlbl:set_text(string.format("%d/%d", itemNum, needNum))
  local nameLabel = self.m_panel:FindDirect("Img_Bg/Img_Item/Label_ItemName"):GetComponent("UILabel")
  nameLabel:set_text(dyeItemBase.name)
  self:TryUseYuanbao(self.useYuanbao)
end
def.method("boolean").TryUseYuanbao = function(self, use)
  if use then
    local dyeItemId = constant.WingConsts.WING_DYE_ITEM_ID
    local needNum = 1
    local itemNum = ItemModule.Instance():GetItemCountById(dyeItemId)
    if needNum <= itemNum then
      Toast(textRes.Wing[28])
      self:UseYuanbao(false, 0)
    else
      local diff = needNum - itemNum
      self:UseYuanbao(true, diff)
    end
  else
    self:UseYuanbao(false, 0)
  end
end
def.method("boolean", "number").UseYuanbao = function(self, use, needNun)
  local toggle = self.m_panel:FindDirect("Img_Bg/Img_Item/Btn_UseGold"):GetComponent("UIToggle")
  self.useYuanbao = use
  toggle:set_value(use)
  local dyeBtn = self.m_panel:FindDirect("Img_Bg/Btn_Dye")
  local yuanbaoDye = dyeBtn:FindDirect("Group_Yuanbao")
  local normalDye = dyeBtn:FindDirect("Label")
  if use then
    yuanbaoDye:SetActive(true)
    normalDye:SetActive(false)
    do
      local yuanbaoLbl = yuanbaoDye:FindDirect("Label_Money"):GetComponent("UILabel")
      yuanbaoLbl:set_text("----")
      require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(constant.WingConsts.WING_DYE_ITEM_ID, function(result)
        if yuanbaoLbl.isnil then
          return
        end
        yuanbaoLbl:set_text(tostring(result * needNun))
      end)
    end
  else
    yuanbaoDye:SetActive(false)
    normalDye:SetActive(true)
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true then
    self.modelAndWing:SetDir(self.modelAndWing:GetDir() - dx / 2)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Dye" then
    if CheckCrossServerAndToast() then
      return
    end
    local ret = WingModule.Instance():DyeWingRandom(self.wingId, self.useYuanbao)
    if ret == -1 then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm(textRes.Wing[38], textRes.Wing[39], function(select)
        if select == 1 then
          self:TryUseYuanbao(true)
        end
      end, nil)
    end
  elseif string.sub(id, 1, 9) == "WingColor" then
    local index = tonumber(string.sub(id, 10))
    self:SelectColor(index)
  elseif id == "Texture_Item" then
    local dyeItemId = constant.WingConsts.WING_DYE_ITEM_ID
    local go = self.m_panel:FindDirect("Img_Bg/Img_Item/" .. id)
    if go then
      require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(dyeItemId, go, 0, true)
    end
  elseif id == "Btn_Tips" then
    WingUtils.ShowQA(constant.WingConsts.WING_DYE_TIP_ID)
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if id == "Btn_UseGold" then
    if active then
      self:TryUseYuanbao(true)
    else
      self:TryUseYuanbao(false)
    end
  end
end
return WingDyePanel.Commit()
