local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local PartnerTips2 = Lplus.Extend(ECPanelBase, "PartnerTips2")
local def = PartnerTips2.define
local inst
local PartnerInterface = require("Main.partner.PartnerInterface")
local partnerInterface = PartnerInterface.Instance()
local Vector = require("Types.Vector")
local MathHelper = require("Common.MathHelper")
def.static("=>", PartnerTips2).Instance = function()
  if inst == nil then
    inst = PartnerTips2()
    inst:Init()
  end
  return inst
end
def.field("number")._loveID = 0
def.field("table")._position = nil
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("number", "number", "number", "number", "number", "number").ShowDlg = function(self, LoveID, sourceX, sourceY, sourceW, sourceH, prefer)
  self._position = {
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  self._loveID = LoveID
  if self.m_panel == nil or self.m_panel.isnil then
    print("PartnerMain CreatePanel()")
    self:CreatePanel(RESPATH.PREFAB_UI_PARTNER_TIPS2, 2)
    self:SetOutTouchDisappear()
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  local Img_Item = self.m_panel:FindDirect("Img_Bg/Group_Partner/Grid_Partner/Img_Item")
  Img_Item:set_name("Img_Item_1")
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
  else
  end
end
def.method().Fill = function(self)
  local LoveDataCfg = PartnerInterface.GetPartnerLoveDataCfg(self._loveID)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Title = Img_Bg:FindDirect("Group_Title")
  local Label_Name = Group_Title:FindDirect("Label_Name")
  local Label_Describe = Group_Title:FindDirect("Label_Describe")
  local Text_Head = Group_Title:FindDirect("Img_BgHead/Text_Head")
  Label_Name:GetComponent("UILabel"):set_text(LoveDataCfg.loveName)
  Label_Describe:GetComponent("UILabel"):set_text(LoveDataCfg.loveDes)
  local uiTexture = Text_Head:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, LoveDataCfg.loveIconId)
  local Grid_Partner = Img_Bg:FindDirect("Group_Partner/Grid_Partner")
  local Img_Item1 = Grid_Partner:FindDirect("Img_Item_1")
  local grid = Grid_Partner:GetComponent("UIGrid")
  local tablePartner = {
    LoveDataCfg.toPartner1,
    LoveDataCfg.toPartner2,
    LoveDataCfg.toPartner3
  }
  local j = 0
  for i = 1, 3 do
    local toPartner = tablePartner[i]
    if toPartner > 0 then
      j = j + 1
      local Img_Item = Grid_Partner:FindDirect(string.format("Img_Item_%d", j))
      if Img_Item == nil then
        Img_Item = Object.Instantiate(Img_Item1)
        Img_Item:set_name(string.format("Img_Item_%d", j))
        Img_Item.parent = Img_Item1.parent
        Img_Item:set_localScale(Vector.Vector3.one)
      end
      local Text_Head = Img_Item:FindDirect("Text_Head")
      local uiTexture = Text_Head:GetComponent("UITexture")
      local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, toPartner)
      local cfg = {}
      cfg.modelId = record:GetIntValue("modelId")
      local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, cfg.modelId)
      local headidx = DynamicRecord.GetIntValue(modelinfo, "headerIconId")
      if headidx == 0 then
        headidx = 3002
      end
      GUIUtils.FillIcon(uiTexture, headidx)
    end
  end
  grid:Reposition()
  local bg = Img_Bg:GetComponent("UISprite")
  local x, y = MathHelper.ComputeTipsAutoPosition(self._position.sourceX, self._position.sourceY, self._position.sourceW, self._position.sourceH, bg:get_width(), bg:get_height(), self._position.prefer)
  Img_Bg:set_localPosition(Vector.Vector3.new(x, y + bg:get_height() / 2, 0))
end
PartnerTips2.Commit()
return PartnerTips2
