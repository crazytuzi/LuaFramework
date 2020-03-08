local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ToBeMasterPanel = Lplus.Extend(ECPanelBase, "ToBeMasterPanel")
local ShituUtils = require("Main.Shitu.ShituUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ShiTuConst = require("netio.protocol.mzm.gsp.shitu.ShiTuConst")
local def = ToBeMasterPanel.define
local instance
def.field("table")._checkTag = nil
def.field("table")._confirmDlg = nil
def.static("=>", ToBeMasterPanel).Instance = function()
  if instance == nil then
    instance = ToBeMasterPanel()
    instance._checkTag = {}
  end
  return instance
end
def.method().ShowToBeMasterPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_SHITU_COMMON_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:CheckLocalContionStatus()
  self:CheckServerConditionStatus()
end
def.method().InitUI = function(self)
  local panelTitle = self.m_panel:FindDirect("Img_Bg/Img_Title/Label"):GetComponent("UILabel")
  panelTitle:set_text(textRes.Shitu[5])
  self.m_panel:FindDirect("Img_Bg/Label_Info"):SetActive(false)
  self.m_panel:FindDirect("Img_Bg/Btn_Apply"):SetActive(false)
  self.m_panel:FindDirect("Img_Bg/Btn_Chushi"):SetActive(true)
  local conditionIds = {
    constant.ShiTuConsts.apprenticeLevelConditionIdChuShi,
    constant.ShiTuConsts.relationTimeConditionIdChuShi,
    constant.ShiTuConsts.qinMiDuConditionIdChuShi
  }
  local conditionArgs = {
    {
      constant.ShiTuConsts.chuShiApprenticeMinLevel
    },
    {
      constant.ShiTuConsts.chuShiRelationMinTime
    },
    {
      constant.ShiTuConsts.chuShiMinQinMiDu
    }
  }
  local conditionDesc = {}
  for i = 1, #conditionIds do
    local condition = ShituUtils.GetChushiConditionById(conditionIds[i])
    condition = string.format(condition, conditionArgs[i][1])
    table.insert(conditionDesc, condition)
  end
  local conditionList = self.m_panel:FindDirect("Img_Bg/Img_ConditionList/Scroll View_PetList/List_PetList")
  local conditionUIList = conditionList:GetComponent("UIList")
  conditionUIList.itemCount = #conditionIds
  conditionUIList:Resize()
  for i = 1, #conditionIds do
    local item = conditionList:FindDirect(string.format("Img_BgPet01_%d", i))
    if item then
      local conditionLabel = item:FindDirect(string.format("Pet01_%d/Label_PetName01_%d", i, i)):GetComponent("UILabel")
      local imgGou = item:FindDirect(string.format("Pet01_%d/Img_Gou_%d", i, i))
      local imgCha = item:FindDirect(string.format("Pet01_%d/Img_Cha_%d", i, i))
      conditionLabel:set_text(conditionDesc[i])
      imgGou:SetActive(false)
      imgCha:SetActive(true)
      local tag = {}
      tag.tagGou = imgGou
      tag.tagCha = imgCha
      tag.status = false
      self._checkTag[conditionIds[i]] = tag
    end
  end
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if self.m_panel ~= nil then
        self.m_panel:FindDirect("Img_Bg/Img_ConditionList/Scroll View_PetList"):GetComponent("UIScrollView"):ResetPosition()
      end
    end)
  end)
end
def.method().CheckLocalContionStatus = function(self)
  local checkFunction = {
    ToBeMasterPanel.CheckChushiLevel
  }
  local conditionIds = {
    constant.ShiTuConsts.apprenticeLevelConditionIdChuShi
  }
  for i = 1, #conditionIds do
    local checked = checkFunction[i]()
    self:SetConditionTagStatus(conditionIds[i], checked)
  end
end
def.method("number", "boolean").SetConditionTagStatus = function(self, id, status)
  local tag = self._checkTag[id]
  tag.status = status
  if status then
    tag.tagGou:SetActive(true)
    tag.tagCha:SetActive(false)
  else
    tag.tagGou:SetActive(false)
    tag.tagCha:SetActive(true)
  end
end
def.static("=>", "boolean").CheckChushiLevel = function()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local apprenticeLevel = heroProp.level
  return apprenticeLevel >= constant.ShiTuConsts.chuShiApprenticeMinLevel
end
def.method().CheckServerConditionStatus = function(self)
  local chushiConditionCheck = require("netio.protocol.mzm.gsp.shitu.CChuShiConditionCheck").new()
  gmodule.network.sendProtocol(chushiConditionCheck)
end
def.method("table").OnReceiveServerConditionStatus = function(self, p)
  self:SetServerCheckStatus(p)
  self:CheckTotalConditionStatus()
end
def.method("table").SetServerCheckStatus = function(self, p)
  local result = p.result
  for conditionId, status in pairs(result) do
    local checked = status == ShiTuConst.SUCCESS and true or false
    self:SetConditionTagStatus(conditionId, checked)
  end
end
def.method().CheckTotalConditionStatus = function(self)
  local checkPassed = true
  for conditionId, tag in pairs(self._checkTag) do
    if tag.status == false then
      checkPassed = false
      break
    end
  end
  local btnDisable = self.m_panel:FindDirect("Img_Bg/Btn_Chushi/Img_Zhihui")
  if checkPassed then
    btnDisable:SetActive(false)
  else
    btnDisable:SetActive(true)
  end
  if self._confirmDlg ~= nil then
    if checkPassed then
      local chushiReq = require("netio.protocol.mzm.gsp.shitu.CChuShiReq").new()
      gmodule.network.sendProtocol(chushiReq)
      self:Close()
    else
      Toast(textRes.Shitu[28])
    end
    self._confirmDlg = nil
  end
end
def.method().ToBeMaster = function(self)
  self._confirmDlg = CommonConfirmDlg.ShowConfirm("", textRes.Shitu[15], function(result, tag)
    if result == 1 then
      self:CheckLocalContionStatus()
      self:CheckServerConditionStatus()
    end
  end, nil)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif id == "Btn_Cancel" then
    self:Close()
  elseif id == "Btn_Chushi" then
    self:ToBeMaster()
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self._checkTag = {}
  self._confirmDlg = nil
end
ToBeMasterPanel.Commit()
return ToBeMasterPanel
