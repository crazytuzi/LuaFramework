local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local UIModelWrap = require("Model.UIModelWrap")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local ECModel = require("Model.ECModel")
local PartnerInterface = require("Main.partner.PartnerInterface")
local PartnerNew = Lplus.Extend(ECPanelBase, "PartnerNew")
local def = PartnerNew.define
local instance
local EXIST_TIME_BEFORE_BE_DESTROY = 5
def.field("number")._partnerID = 0
def.field(ECModel)._mModel = nil
def.field("userdata")._uiModel = nil
def.field("number")._mTimer = 0
def.field("boolean")._mTweenFinished = false
def.static("=>", PartnerNew).Instance = function()
  if instance == nil then
    instance = PartnerNew()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
  self._mTweenFinished = false
end
def.method("number").ShowDlg = function(self, partnerID)
  self._partnerID = partnerID
  if self.m_panel == nil or self.m_panel.isnil then
    print("PartnerMain CreatePanel()")
    self:CreatePanel(RESPATH.PREFAB_UI_PARTNER_NEW, 1)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Model = Img_Bg0:FindDirect("Img_BgModel/Group_BgModel1/Model")
  local uiModel = Model:GetComponent("UIModel")
  local camera = uiModel:get_modelCamera()
  camera:set_orthographic(true)
  self._uiModel = uiModel
end
def.override().OnDestroy = function(self)
  self._mTweenFinished = false
  self._uiModel = nil
  if self._mModel then
    self._mModel:Destroy()
    self._mModel = nil
  end
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_New_Dlg_Close, nil)
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
    if 0 == self._mTimer then
      self._mTimer = GameUtil.AddGlobalLateTimer(EXIST_TIME_BEFORE_BE_DESTROY, true, function()
        if self._mTimer ~= 0 then
          self._mTimer = 0
          self:HideDlg()
        end
      end)
    end
  else
  end
end
def.method("string", "string").onTweenerFinish = function(self, id1, id2)
  if "Img_BgModel" == id1 then
    self._mTweenFinished = true
  end
end
def.method().Fill = function(self)
  local partnerCfg = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, self._partnerID)
  partnerCfg.name = record:GetStringValue("name")
  partnerCfg.modelId = record:GetIntValue("modelId")
  local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, partnerCfg.modelId)
  local resourcePath = DynamicRecord.GetStringValue(modelinfo, "modelResPath")
  if resourcePath and resourcePath ~= nil and self._uiModel then
    local modelPath = resourcePath .. ".u3dext"
    local function callBack(ret)
      if self._mModel and self._mModel.m_model and self._uiModel then
        self._mModel.m_model:SetLayer(ClientDef_Layer.UI_Model1)
        self._uiModel.modelGameObject = self._mModel.m_model
        self._mModel:SetPos(0, 0)
        self._mModel:SetScale(1)
        self._mModel:SetDir(180)
        self._mModel:Play(ActionName.Idle1)
        self._mModel:CrossFadeQueued(ActionName.Magic, 0.3)
        self._mModel:CrossFadeQueued(ActionName.Attack1, 0.3)
        self._mModel:CrossFadeQueued(ActionName.Idle1, 0.3)
        self._mModel:CrossFadeQueued(ActionName.Stand, 0.3)
      end
    end
    if self._mModel == nil or self._mModel.m_model == nil then
      self._mModel = ECModel.new(partnerCfg.modelId)
      self._mModel.m_bUncache = true
      self._mModel:Load(modelPath, callBack)
    else
      callBack()
    end
  end
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_Name = Img_Bg0:FindDirect("Img_BgModel/Label_Name")
  Label_Name:GetComponent("UILabel"):set_text(partnerCfg.name)
  local partnerCfg = PartnerInterface.Instance():GetPartnerCfgById(self._partnerID)
  local pinjieLabel = Img_Bg0:FindDirect("Img_BgModel/Label_PingJie")
  if pinjieLabel and partnerCfg then
    local rankNum = partnerCfg.rank
    pinjieLabel:GetComponent("UILabel"):set_text(rankNum)
  end
  local Img_Tpye = Img_Bg0:FindDirect("Img_BgModel/Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(partnerCfg.classType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
end
def.method("string").onClick = function(self, id)
  if (id == "Img_Bg0" or "Img_BgModel" == id) and self._mTweenFinished then
    self:HideDlg()
    return
  end
end
PartnerNew.Commit()
return PartnerNew
