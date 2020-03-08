local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChildSayHelloPanel = Lplus.Extend(ECPanelBase, "ChildSayHelloPanel")
local GUIUtils = require("GUI.GUIUtils")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ECUIModel = require("Model.ECUIModel")
local EC = require("Types.Vector3")
local def = ChildSayHelloPanel.define
local instance
def.field("table").uiObjs = nil
def.field("userdata").childId = nil
def.field("string").content = ""
def.field(ECUIModel).model = nil
def.static("=>", ChildSayHelloPanel).Instance = function()
  if instance == nil then
    instance = ChildSayHelloPanel()
  end
  return instance
end
def.method("userdata", "string").ShowPanel = function(self, childId, content)
  if self.m_panel ~= nil then
    return
  end
  self.childId = childId
  self.content = content
  self:CreatePanel(RESPATH.PREFAB_CHILD_SAY_HELLO_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.childId = nil
  self.content = ""
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_BgTarget = self.m_panel:FindDirect("Img_BgTarget")
  self.uiObjs.Texture_IconHead = self.uiObjs.Img_BgTarget:FindDirect("Texture_IconHead")
  self.uiObjs.HalfHeadModel = self.uiObjs.Texture_IconHead:FindDirect("Model")
  self.uiObjs.Label_Content = self.uiObjs.Img_BgTarget:FindDirect("Img_BgContent/Label_Content")
  local child = ChildrenDataMgr.Instance():GetChildById(self.childId)
  local childHalfHeadIcon = require("Main.Children.ChildrenUtils").GetChildHalfBofyIcon(child:GetModelCfgId())
  local uiModel = self.uiObjs.HalfHeadModel:GetComponent("UIModel")
  if uiModel.mCanOverflow ~= nil then
    uiModel.mCanOverflow = true
  end
  local iconCfg = GetHalfBodyCfg(childHalfHeadIcon)
  if iconCfg then
    local modelPath = iconCfg.path
    if self.model ~= nil then
      self.model:Destroy()
    end
    self.model = ECUIModel.new(0)
    self.model:LoadUIModel(modelPath, function(ret)
      if ret == nil then
        return
      end
      uiModel.modelGameObject = self.model.m_model
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end)
  end
  local parentTitle = ""
  local heroProp = require("Main.Hero.mgr.HeroPropMgr").Instance().heroProp
  local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  if heroProp.gender == GenderEnum.MALE then
    parentTitle = textRes.Children.ParentTitle[1]
  else
    parentTitle = textRes.Children.ParentTitle[2]
  end
  GUIUtils.SetText(self.uiObjs.Label_Content, string.format(self.content, parentTitle))
end
def.method("string").onClick = function(self, id)
  self:DestroyPanel()
end
ChildSayHelloPanel.Commit()
return ChildSayHelloPanel
