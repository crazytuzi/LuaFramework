local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local CatNode = Lplus.Extend(TabNode, "CatNode")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ECPanelBase = require("GUI.ECPanelBase")
local BTGCat = require("Main.BackToGame.mgr.BTGCat")
local BackToGameUtils = require("Main.BackToGame.BackToGameUtils")
local def = CatNode.define
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:ShowBasicInfo()
  self:UpdateRechargeData()
  self:UpdateCatTokenData()
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.RechargeDataChange, CatNode.OnRechargeDataChange, self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.CatTokenChange, CatNode.OnCatTokenChange, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.RechargeDataChange, CatNode.OnRechargeDataChange)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.CatTokenChange, CatNode.OnCatTokenChange)
end
def.method().ShowBasicInfo = function(self)
  local cfg = BTGCat.Instance():GetBasicCfg()
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(cfg.tipId)
  local Label_CatTips = self.m_node:FindDirect("Label_CatTips")
  GUIUtils.SetText(Label_CatTips, tipContent)
  local Group_Slider = self.m_node:FindDirect("Group_Slider")
  local Img_BgSlider = Group_Slider:FindDirect("Img_BgSlider")
  local Group_Item = Group_Slider:FindDirect("Group_Item")
  GUIUtils.SetActive(Group_Item, false)
  local totalWidth = Img_BgSlider:GetComponent("UIWidget").width
  local maxRechargeCount = cfg.accumulateRecharge[#cfg.accumulateRecharge].accumulateRechargeCount
  for i = 1, #cfg.accumulateRecharge do
    local rechargeCfg = cfg.accumulateRecharge[i]
    local Item = GameObject.Instantiate(Group_Item)
    GUIUtils.SetActive(Item, true)
    Item.name = "Group_Item_" .. i
    Item.parent = Group_Slider
    Item.localScale = Vector.Vector3.one
    Item.localPosition = Vector.Vector3.new(i / #cfg.accumulateRecharge * totalWidth, 0, 0)
    self:FillRechareNodeInfo(Item, rechargeCfg)
  end
end
def.method("userdata", "table").FillRechareNodeInfo = function(self, item, rechargeCfg)
  local Group_Money = item:FindDirect("Group_Money")
  local Label_NeedMoney = Group_Money:FindDirect("Label_NeedMoney")
  GUIUtils.SetText(Label_NeedMoney, rechargeCfg.accumulateRechargeCount)
  local Group_Reward = item:FindDirect("Group_Reward")
  for i = 1, #rechargeCfg.rechargeAwards do
    local award = Group_Reward:FindDirect(string.format("Group_%02d", i))
    if not _G.IsNil(award) then
      GUIUtils.SetActive(award, true)
      local Img_Icon = award:FindDirect("Img_Icon")
      local Label_Num = award:FindDirect("Label_Num")
      local tokenCfg = BackToGameUtils.GetRechargeAwardCfg(rechargeCfg.rechargeAwards[i].manekiTokenCfgId)
      GUIUtils.SetTexture(Img_Icon, tokenCfg.manekiTokenIconId)
      GUIUtils.SetText(Label_Num, "x" .. rechargeCfg.rechargeAwards[i].manekiTokenCount)
    end
  end
  local unusedIdx = #rechargeCfg.rechargeAwards + 1
  while true do
    local award = Group_Reward:FindDirect(string.format("Group_%02d", unusedIdx))
    if _G.IsNil(award) then
      break
    end
    GUIUtils.SetActive(award, false)
    unusedIdx = unusedIdx + 1
  end
  Group_Reward:GetComponent("UIGrid"):Reposition()
end
def.method().UpdateRechargeData = function(self)
  local cfg = BTGCat.Instance():GetBasicCfg()
  local curRecharge = BTGCat.Instance():GetCurrentRechargeCount()
  local completeStoneIdx = 0
  for i = #cfg.accumulateRecharge, 1, -1 do
    local rechargeCfg = cfg.accumulateRecharge[i]
    if not Int64.lt(curRecharge, rechargeCfg.accumulateRechargeCount) then
      completeStoneIdx = i
      break
    end
  end
  local progress = 0
  if completeStoneIdx == #cfg.accumulateRecharge then
    progress = 1
  else
    local curCompleteAmount = cfg.accumulateRecharge[completeStoneIdx] and cfg.accumulateRecharge[completeStoneIdx].accumulateRechargeCount or 0
    local nextAmount = cfg.accumulateRecharge[completeStoneIdx + 1] and cfg.accumulateRecharge[completeStoneIdx + 1].accumulateRechargeCount or 0
    local completePart = completeStoneIdx / #cfg.accumulateRecharge
    local incompletePart = Int64.ToNumber(curRecharge - curCompleteAmount) / (nextAmount - curCompleteAmount) * (1 / #cfg.accumulateRecharge)
    progress = completePart + incompletePart
  end
  local Group_Slider = self.m_node:FindDirect("Group_Slider")
  local Img_BgSlider = Group_Slider:FindDirect("Img_BgSlider")
  GUIUtils.SetProgress(Img_BgSlider, GUIUtils.COTYPE.PROGRESS, progress)
end
def.method().UpdateCatTokenData = function(self)
  local allAward = BackToGameUtils.GetAllRechargeAwardCfg()
  local Group_Cat = self.m_node:FindDirect("Group_Cat")
  for i = 1, #allAward do
    local award = Group_Cat:FindDirect(string.format("Cat_%02d", i))
    if not _G.IsNil(award) then
      self:FillAwardNodeInfo(award, allAward[i])
    end
  end
  local unusedIdx = #allAward + 1
  while true do
    local award = Group_Cat:FindDirect(string.format("Cat_%02d", unusedIdx))
    if _G.IsNil(award) then
      break
    end
    GUIUtils.SetActive(award, false)
    unusedIdx = unusedIdx + 1
  end
end
def.method("userdata", "table").FillAwardNodeInfo = function(self, item, awardCfg)
  local Label_MoneyNum = item:FindDirect("Label_MoneyNum")
  local Label_GetNum = item:FindDirect("Label_GetNum")
  local Img_Cat = item:FindDirect("Img_Cat")
  local Img_CatM = item:FindDirect("Img_CatM")
  local curNum = BTGCat.Instance():GetCurrentTokenCount(awardCfg.id)
  if curNum > 0 then
    GUIUtils.SetActive(Img_CatM, true)
    GUIUtils.SetTexture(Img_Cat, awardCfg.manekiNekoHappyIconId)
  else
    GUIUtils.SetActive(Img_CatM, false)
    GUIUtils.SetTexture(Img_Cat, awardCfg.manekiNekoUnhappyIconId)
  end
  GUIUtils.SetText(Label_GetNum, curNum)
  GUIUtils.SetText(Label_MoneyNum, awardCfg.getYuanBaoCount)
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Charge" then
    self:OnClickBuyYuanBao()
  elseif string.find(id, "Cat_") then
    local idx = tonumber(string.sub(id, #"Cat_" + 1))
    if idx ~= nil then
      self:OnGetTokenYuanBao(idx)
    end
  end
end
def.method().OnClickBuyYuanBao = function(self)
  local MallPanel = require("Main.Mall.ui.MallPanel")
  require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
end
def.method("number").OnGetTokenYuanBao = function(self, idx)
  local allAward = BackToGameUtils.GetAllRechargeAwardCfg()
  if allAward[idx] == nil then
    warn("award not exist at index:" .. idx)
    return
  end
  BTGCat.Instance():UseToken(allAward[idx].id)
end
def.method("=>", "boolean").IsOpen = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_RECHARGE)
  return open
end
def.method("table").OnRechargeDataChange = function(self, params)
  self:UpdateRechargeData()
end
def.method("table").OnCatTokenChange = function(self, params)
  self:UpdateCatTokenData()
end
CatNode.Commit()
return CatNode
