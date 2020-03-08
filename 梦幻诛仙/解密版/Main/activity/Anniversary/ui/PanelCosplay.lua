local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AnniversaryData = require("Main.activity.Anniversary.data.AnniversaryData")
local AnniversaryUtils = require("Main.activity.Anniversary.AnniversaryUtils")
local PanelCosplay = Lplus.Extend(ECPanelBase, "PanelCosplay")
local def = PanelCosplay.define
local instance, confirmDlg
def.static("=>", PanelCosplay).Instance = function()
  if instance == nil then
    instance = PanelCosplay()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("table").optIds = nil
def.static("table").ShowPanel = function(opts)
  PanelCosplay.Instance().optIds = opts
  if PanelCosplay.Instance():IsShow() then
    if confirmDlg then
      confirmDlg:DestroyPanel()
    end
    PanelCosplay.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_ACTIVITY_COSPLAY, 0)
end
def.override().OnCreate = function(self)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Btn_Up = self.m_panel:FindDirect("Group_Bottom/Btn_Up")
  self._uiObjs.Btn_Down = self.m_panel:FindDirect("Group_Bottom/Btn_Down")
  self._uiObjs.Group_Item = self.m_panel:FindDirect("Group_Bottom/Group_Item")
  self._uiObjs.List_Item = self.m_panel:FindDirect("Group_Bottom/Group_Item/List_Item")
end
def.override("boolean").OnShow = function(self, show)
  if not show then
    return
  end
  self:UpdateUI()
end
def.method().UpdateUI = function(self)
  if self.m_panel == nil or self.optIds == nil then
    return
  end
  local uiList = self._uiObjs.List_Item:GetComponent("UIList")
  uiList.itemCount = #self.optIds
  uiList:Resize()
  for i = 1, #self.optIds do
    local opt = AnniversaryUtils.GetMakeUpOptionCfg(self.optIds[i])
    local item_panel = self._uiObjs.List_Item:FindDirect("Item_" .. i)
    local icon = item_panel:FindDirect("Img_Icon_" .. i)
    local uiTexture = icon:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, opt.optionIcon)
    local label_name = item_panel:FindDirect("Label_Item_" .. i)
    GUIUtils.SetText(label_name, opt.optionName)
  end
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
  if confirmDlg then
    confirmDlg:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Item_") == 1 then
    do
      local mgr = gmodule.moduleMgr:GetModule(ModuleId.ANNIVERSARY)
      if mgr:CheckMakeUpOutOfRange() then
        Toast(textRes.activity.Anniversary[15])
        mgr:GotoCosplay()
        return
      end
      local idx = tonumber(string.sub(id, #"Item_" + 1, -1))
      local item_panel = self._uiObjs.List_Item:FindDirect("Item_" .. idx)
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local makeupCfg = AnniversaryUtils.GetMakeUpOptionCfg(self.optIds[idx])
      local desc = string.format(textRes.activity.Anniversary[16], makeupCfg.optionName)
      confirmDlg = CommonConfirmDlg.ShowConfirmCoundDown("", desc, "", "", 1, 10, function(s)
        if s == 1 then
          if mgr:CheckMakeUpOutOfRange() then
            Toast(textRes.activity.Anniversary[28])
            return
          end
          local p = require("netio.protocol.mzm.gsp.makeup.CAnswerMakeUpQuestion").new()
          p.activityId = constant.CMakeUpConsts.ACTIVITY_ID
          p.optionId = self.optIds[idx]
          gmodule.network.sendProtocol(p)
          instance:DestroyPanel()
        end
      end, nil)
    end
  end
end
PanelCosplay.Commit()
return PanelCosplay
