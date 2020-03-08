local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GuideUtils = require("Main.Guide.GuideUtils")
local ECUIModel = require("Model.ECUIModel")
local Vector = require("Types.Vector")
local SendPet = Lplus.Extend(ECPanelBase, "SendPet")
local def = SendPet.define
local _instance
def.static("=>", SendPet).Instance = function()
  if _instance == nil then
    _instance = SendPet()
  end
  return _instance
end
def.field("number").petId = 0
def.field("table").petModel = nil
def.field("function").callback = nil
def.field("boolean").drag = false
def.field("number").time = 0
def.field("number").timer = 0
def.static("number", "number", "function").ShowSendPet = function(petId, time, cb)
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
  local dlg = SendPet.Instance()
  dlg.petId = petId
  dlg.callback = cb
  dlg.time = time
  dlg:SetDepth(4)
  dlg:CreatePanel(RESPATH.PREFAB_SEND_PET, 0)
  dlg:SetModal(true)
end
def.static().Close = function()
  local dlg = SendPet.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  require("GUI.ECGUIMan").Instance():LockUI(false)
  self:UpdatePet()
  if self.time > 0 then
    self.timer = GameUtil.AddGlobalTimer(self.time, true, function()
      if self.callback then
        self.callback()
      end
    end)
  end
  gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
end
def.override().OnDestroy = function(self)
  if self.petModel then
    self.petModel:Destroy()
  end
  GameUtil.RemoveGlobalTimer(self.timer)
end
def.method().UpdatePet = function(self)
  local PetUtils = require("Main.Pet.PetUtility").Instance()
  local petCfg = PetUtils:GetPetCfg(self.petId)
  local uiModel = self.m_panel:FindDirect("Img_Bg/Img_PetBg/Model"):GetComponent("UIModel")
  if uiModel.mCanOverflow ~= nil then
    uiModel.mCanOverflow = true
    local camera = uiModel:get_modelCamera()
    camera:set_orthographic(true)
  end
  local modelPath = GetModelPath(petCfg.modelId)
  self.petModel = ECUIModel.new(petCfg.modelId)
  self.petModel:LoadUIModel(modelPath, function(ret)
    if self.m_panel and not self.m_panel.isnil then
      self.petModel:SetDir(180)
      self.petModel:SetScale(1)
      self.petModel:Play("Stand_c")
      uiModel.modelGameObject = self.petModel.m_model
      if petCfg.colorId > 0 then
        local colorcfg = GetModelColorCfg(petCfg.colorId)
        self.petModel:SetColoration(colorcfg)
      else
        self.petModel:SetColoration(nil)
      end
    end
  end)
  local name = self.m_panel:FindDirect("Img_Bg/Img_PetBg/Img_BgName/Label"):GetComponent("UILabel")
  name:set_text(petCfg.templateName)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    if self.callback then
      self.callback()
    end
  elseif id == "Img_PetBg" then
    self.petModel:PlayAnim("Run_c", function()
      self.petModel:Play("Stand_c")
    end)
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Img_PetBg" then
    self.drag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.drag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.drag then
    self.petModel:SetDir(self.petModel.m_ang - dx / 2)
  end
end
SendPet.Commit()
return SendPet
