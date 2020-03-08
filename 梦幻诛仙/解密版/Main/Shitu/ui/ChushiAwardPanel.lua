local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChushiAwardPanel = Lplus.Extend(ECPanelBase, "ChushiAwardPanel")
local ShituUtils = require("Main.Shitu.ShituUtils")
local GUIUtils = require("GUI.GUIUtils")
local ShituData = Lplus.ForwardDeclare("ShituData")
local ShituModule = Lplus.ForwardDeclare("ShituModule")
local def = ChushiAwardPanel.define
local instance
def.field("table")._uiObjs = nil
def.field("table")._awardData = nil
def.static("=>", ChushiAwardPanel).Instance = function()
  if instance == nil then
    instance = ChushiAwardPanel()
  end
  return instance
end
def.method().ShowAwardPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_CHENGWEI_PRIZE_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:_InitUI()
  self:_LoadAwardData()
  self:_SetAwardList()
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.ReceiveNewAward, ChushiAwardPanel._OnReceiveNewAward)
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.ScrollView = self.m_panel:FindDirect("Img_Bg0/Scroll View")
  self._uiObjs.AwardList = self._uiObjs.ScrollView:FindDirect("Grid")
end
def.method()._LoadAwardData = function(self)
  local awardData = ShituUtils.GetChushiAwardCfg()
  self._awardData = awardData
end
def.method()._SetAwardList = function(self)
  local awardData = self._awardData
  local awardCount = #awardData
  local shituData = ShituData.Instance()
  local chushiApprenticeNum = shituData:GetChushiApprenticeCount()
  local listItems = GUIUtils.InitUIList(self._uiObjs.AwardList, awardCount)
  for i = 1, awardCount do
    local item = listItems[i]
    local Label_Number = item:FindDirect(string.format("Label_Number_%d", i))
    local Label_Chengwei = item:FindDirect(string.format("Label_Chengwei_%d", i))
    GUIUtils.SetText(Label_Number, awardData[i].chuShiApprenticeNum)
    GUIUtils.SetText(Label_Chengwei, awardData[i].appellationName)
    local Btn_Get = item:FindDirect(string.format("Btn_Get_%d", i))
    local Img_Receive = item:FindDirect(string.format("Sprite_%d", i))
    local Label_Unreach = item:FindDirect(string.format("Label_Weiwancheng_%d", i))
    if chushiApprenticeNum >= awardData[i].chuShiApprenticeNum then
      if shituData:HasReceiveAward(awardData[i].cfgId) then
        GUIUtils.SetActive(Btn_Get, false)
        GUIUtils.SetActive(Img_Receive, true)
        GUIUtils.SetActive(Label_Unreach, false)
      else
        GUIUtils.SetActive(Btn_Get, true)
        GUIUtils.SetActive(Img_Receive, false)
        GUIUtils.SetActive(Label_Unreach, false)
      end
    else
      GUIUtils.SetActive(Btn_Get, false)
      GUIUtils.SetActive(Img_Receive, false)
      GUIUtils.SetActive(Label_Unreach, true)
    end
  end
end
def.method()._UpdateAwardList = function(self)
  self:_SetAwardList()
end
def.method("number")._ReceiveAwardByIdx = function(self, idx)
  local cfgId = self._awardData[idx].cfgId
  ShituModule.Instance():GetApprenticeNumAward(cfgId)
end
def.static("table", "table")._OnReceiveNewAward = function(params, contex)
  instance:_UpdateAwardList()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif string.find(id, "Btn_Get_") == 1 then
    local idx = tonumber(string.sub(id, 9))
    self:_ReceiveAwardByIdx(idx)
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
ChushiAwardPanel.Commit()
return ChushiAwardPanel
