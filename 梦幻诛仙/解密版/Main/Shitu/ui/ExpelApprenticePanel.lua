local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ExpelApprenticePanel = Lplus.Extend(ECPanelBase, "ExpelApprenticePanel")
local ShituUtils = require("Main.Shitu.ShituUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = ExpelApprenticePanel.define
local instance
def.field("userdata")._apprenceList = nil
def.field("number")._selectIndex = 0
def.static("=>", ExpelApprenticePanel).Instance = function()
  if instance == nil then
    instance = ExpelApprenticePanel()
  end
  return instance
end
def.method().ShowExpelApprenticePanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_EXPEL_APPRENTICE_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateApprenticeList()
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ShituRelationChange, ExpelApprenticePanel.OnShituChange)
end
def.method().InitUI = function(self)
  self._apprenceList = self.m_panel:FindDirect("Img_Bg/Scroll View/List_Name")
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if self.m_panel ~= nil then
        self.m_panel:FindDirect("Img_Bg/Scroll View"):GetComponent("UIScrollView"):ResetPosition()
      end
    end)
  end)
end
def.method().UpdateApprenticeList = function(self)
  local shituData = require("Main.Shitu.ShituData").Instance()
  local apprenticeCount = shituData:GetNowApprenticeCount()
  local uiList = self._apprenceList:GetComponent("UIList")
  uiList.itemCount = apprenticeCount
  uiList:Resize()
  for i = 1, apprenticeCount do
    local item = self._apprenceList:FindDirect(string.format("Group_NameList_%d", i))
    if item then
      local apprenticeNameLabel = item:FindDirect(string.format("Label_PupilName_%d", i)):GetComponent("UILabel")
      apprenticeNameLabel:set_text(shituData:GetApprenticeByIdx(i).roleName)
    end
  end
  self.m_msgHandler:Touch(self._apprenceList)
  if apprenticeCount > 0 and self._selectIndex == 0 then
    self._selectIndex = 1
  end
end
def.static("table", "table").OnShituChange = function(params, tbl)
  instance:UpdateApprenticeList()
end
def.method().ExpelApprentice = function(self)
  if self._selectIndex <= 0 then
    return
  end
  CommonConfirmDlg.ShowConfirm("", textRes.Shitu[14], function(result, tag)
    if result == 1 then
      local shituData = require("Main.Shitu.ShituData").Instance()
      local apprentice = shituData:GetApprenticeByIdx(self._selectIndex)
      local preApprenticeCount = shituData:GetNowApprenticeCount()
      local roleId = apprentice.roleId
      local expelReq = require("netio.protocol.mzm.gsp.shitu.CMasterRelieveShiTuRelation").new(roleId)
      gmodule.network.sendProtocol(expelReq)
      if preApprenticeCount <= 1 then
        self:Close()
      end
    end
  end, nil)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Cancel" then
    self:Close()
  elseif id == "Btn_Confirm" then
    self:ExpelApprentice()
  elseif string.sub(id, 1, 15) == "Group_NameList_" then
    self._selectIndex = tonumber(string.sub(id, 16))
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ShituRelationChange, ExpelApprenticePanel.OnShituChange)
end
ExpelApprenticePanel.Commit()
return ExpelApprenticePanel
