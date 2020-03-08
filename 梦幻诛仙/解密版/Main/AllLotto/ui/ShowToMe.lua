local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ShowToMe = Lplus.Extend(ECPanelBase, "ShowToMe")
local GUIUtils = require("GUI.GUIUtils")
local AllLottoUtils = require("Main.AllLotto.AllLottoUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ECUIModel = require("Model.ECUIModel")
local def = ShowToMe.define
def.field("number").m_activityId = 0
def.field("number").m_turn = 0
def.field("table").m_model = nil
def.field("boolean").m_isDrag = false
def.static("number", "number").ShowToMe = function(activityId, turn)
  local dlg = ShowToMe()
  dlg.m_activityId = activityId
  dlg.m_turn = turn
  dlg:CreatePanel(RESPATH.PREFAB_ALLLOTTO_TO_ME, 1)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
end
def.override("boolean").OnShow = function(self, show)
end
def.override().OnDestroy = function(self)
  if self.m_model then
    self.m_model:Destroy()
    self.m_model = nil
  end
end
def.method().UpdateInfo = function(self)
  local turnCfg = AllLottoUtils.GetAllLottoTurnCfg(self.m_activityId, self.m_turn)
  if turnCfg then
    local items = ItemUtils.GetAwardItems(turnCfg.awardId)
    if items and items[1] then
      local itemBase = ItemUtils.GetItemBase(items[1].itemId)
      if itemBase then
        local name = self.m_panel:FindDirect("Img_Bg0/Label_ItemName")
        name:GetComponent("UILabel"):set_text(itemBase.name)
        if turnCfg.modelId > 0 then
          self:UpdateModel(turnCfg.modelId)
        else
          self:UpdateIcon(itemBase.icon)
        end
      end
    end
  end
end
def.method("number").UpdateIcon = function(self, iconId)
  self.m_panel:FindDirect("Img_Bg0/Model_Item"):SetActive(false)
  self.m_panel:FindDirect("Img_Bg0/Img_BgIcon1"):SetActive(true)
  local icon = self.m_panel:FindDirect("Img_Bg0/Img_BgIcon1/Texture_Icon")
  GUIUtils.FillIcon(icon:GetComponent("UITexture"), iconId)
end
def.method("number").UpdateModel = function(self, modelId)
  self.m_panel:FindDirect("Img_Bg0/Model_Item"):SetActive(true)
  self.m_panel:FindDirect("Img_Bg0/Img_BgIcon1"):SetActive(false)
  local uiModel = self.m_panel:FindDirect("Img_Bg0/Model_Item"):GetComponent("UIModel")
  self.m_model = ECUIModel.new(modelId)
  local modelPath = GetModelPath(modelId)
  self.m_model:LoadUIModel(modelPath, function(ret)
    if ret == nil then
      return
    end
    if uiModel.isnil then
      self.m_model:Destroy()
      self.m_model = nil
      return
    end
    uiModel.modelGameObject = self.m_model.m_model
    uiModel.mCanOverflow = true
    local camera = uiModel:get_modelCamera()
    if camera then
      camera:set_orthographic(true)
    end
  end)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Texture_Icon" then
    local turnCfg = AllLottoUtils.GetAllLottoTurnCfg(self.m_activityId, self.m_turn)
    if turnCfg then
      local items = ItemUtils.GetAwardItems(turnCfg.awardId)
      if items and items[1] then
        local itemId = items[1].itemId
        local icon = self.m_panel:FindDirect("Img_Bg0/Img_BgIcon1/Texture_Icon")
        require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(itemId, icon, 0, false)
      end
    end
  elseif id == "Btn_Share" then
    require("Main.AllLotto.AllLottoModule").Instance():Share()
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model_Item" then
    self.m_isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.m_isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.m_isDrag == true then
    self.m_model:SetDir(self.m_model.m_ang - dx / 2)
  end
end
ShowToMe.Commit()
return ShowToMe
