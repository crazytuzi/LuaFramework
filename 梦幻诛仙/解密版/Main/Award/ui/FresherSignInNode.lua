local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local FresherSignInNode = Lplus.Extend(AwardPanelNodeBase, "FresherSignInNode")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local FresherSignInMgr = require("Main.Award.mgr.FresherSignInMgr")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = FresherSignInNode.define
def.field("table").awardItemsId = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
  self.awardType = GiftType.SIGN_GIFT
end
def.override().OnShow = function(self)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.SIGN_BEFORE_UPDATE, FresherSignInNode.onSignBeforeUpdate)
  self:updateSignBeforeInfo()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.SIGN_BEFORE_UPDATE, FresherSignInNode.onSignBeforeUpdate)
end
def.override("=>", "boolean").IsOpen = function(self)
  return FresherSignInMgr.Instance():IsOpen()
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  warn("clickobj:" .. id)
  if string.sub(id, 1, 9) == "Btn_Sign_" then
    local idx = tonumber(string.sub(id, 10))
    warn("onClickObj" .. idx)
    if idx == FresherSignInMgr.Instance().awardBeforeSignInfo.day then
      FresherSignInMgr.Instance():getFresherSignInAward(idx)
    end
  elseif string.sub(id, 1, 11) == "Img_BgIcon_" then
    local idx = tonumber(string.sub(id, 12))
    self:showAwardItemTip(idx)
  else
    self:onClick(id)
  end
end
def.method("number").showAwardItemTip = function(self, idx)
  local source = self.m_node:FindDirect(string.format("List_Qiandao2/Group_Qiandao2_%d/Group_Icon_%d/Img_BgIcon_%d", idx, idx, idx))
  if source ~= nil then
    local itemid = self.awardItemsId[idx]
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemid, source, 0, true)
  end
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return FresherSignInMgr.Instance():IsHaveNotifyMessage()
end
def.static("table", "table").onSignBeforeUpdate = function(params)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  local instance = AwardPanel.Instance().nodes[AwardPanel.NodeId.DailySignIn]
  instance:updateSignBeforeInfo()
end
def.method().updateSignBeforeInfo = function(self)
  if self.m_node == nil then
    return
  end
  self.awardItemsId = {}
  local totalDays = 8
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local fillInfo = FresherSignInMgr.Instance().fillInfo
  if fillInfo == nil then
    return
  end
  local listItem = self.m_node:FindDirect("List_Qiandao2")
  local uilist = listItem:GetComponent("UIList")
  uilist.itemCount = totalDays
  uilist:Resize()
  local idx = 1
  local signStatus = FresherSignInMgr.Instance().signStatus
  for k, v in pairs(fillInfo) do
    if totalDays < idx then
      break
    end
    local item = listItem:FindDirect(string.format("Group_Qiandao2_%d", idx))
    item:FindDirect(string.format("Img_Title_%d/Label_Num_%d", idx, idx)):GetComponent("UILabel"):set_text(string.format("%d", idx))
    local signBtn = item:FindDirect(string.format("Group_BtnQD_%d/Btn_Sign_%d", idx, idx))
    if v.status == signStatus.SIGNED then
      signBtn:FindDirect(string.format("Label_Sign_%d", idx)):GetComponent("UILabel"):set_text(textRes.Award[59])
      signBtn:GetComponent("UIButton"):set_isEnabled(false)
    elseif v.status == signStatus.UNOPEN then
      signBtn:FindDirect(string.format("Label_Sign_%d", idx)):GetComponent("UILabel"):set_text(string.format(textRes.Award[60], idx - FresherSignInMgr.Instance().awardBeforeSignInfo.day))
      signBtn:GetComponent("UIButton"):set_isEnabled(false)
    elseif v.status == signStatus.CAN_SIGN then
      signBtn:FindDirect(string.format("Label_Sign_%d", idx)):GetComponent("UILabel"):set_text(textRes.Award[57])
      signBtn:GetComponent("UIButton"):set_isEnabled(true)
    elseif v.status == signStatus.PASS_DUE then
      signBtn:FindDirect(string.format("Label_Sign_%d", idx)):GetComponent("UILabel"):set_text(textRes.Award[58])
      signBtn:GetComponent("UIButton"):set_isEnabled(false)
    end
    local key = string.format("%d_%d_%d", v.rewardid, occupation.ALL, gender.ALL)
    local awardcfg = ItemUtils.GetGiftAwardCfg(key)
    for ki, vi in ipairs(awardcfg.itemList) do
      local itemBase = ItemUtils.GetItemBase(vi.itemId)
      local title = item:FindDirect(string.format("Group_Icon_%d/Img_BgIcon_%d/Label_Num_%d", idx, idx, idx)):GetComponent("UILabel")
      title:set_text(string.format("%d", vi.num))
      local uiTexture = item:FindDirect(string.format("Group_Icon_%d/Img_BgIcon_%d/Texture_Icon_%d", idx, idx, idx)):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
      item:FindDirect(string.format("Group_Icon_%d/Img_BgIcon_%d/Label_ItemName_%d", idx, idx, idx)):GetComponent("UILabel"):set_text(itemBase.name)
      self.awardItemsId[idx] = vi.itemId
      break
    end
    idx = idx + 1
  end
  self.m_base.m_msgHandler:Touch(listItem)
end
return FresherSignInNode.Commit()
