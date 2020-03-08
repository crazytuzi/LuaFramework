local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChatRedGiftRankPanel = Lplus.Extend(ECPanelBase, "ChatRedGiftRankPanel")
local def = ChatRedGiftRankPanel.define
local ChatRedGiftData = require("Main.ChatRedGift.ChatRedGiftData")
local instance
def.field("table").redGiftRankInfo = nil
def.field("number").bestIndex = 1
def.static("=>", ChatRedGiftRankPanel).Instance = function()
  if not instance then
    instance = ChatRedGiftRankPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.method("table").ShowPanel = function(self, _redGiftRankInfo)
  if self:IsShow() or not _redGiftRankInfo then
    return
  end
  ChatRedGiftData.Instance():OpenChatRedGift(_redGiftRankInfo)
  self.redGiftRankInfo = _redGiftRankInfo
  self:CreatePanel(RESPATH.PREFAB_CHATREDGIFT_RANK_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.redGiftRankInfo = nil
  self.bestIndex = 1
end
def.method().UpdateUI = function(self)
  if self:IsShow() then
    local label_name = self.m_panel:FindDirect("Img_Bg/Label_Provider/Label_Name"):GetComponent("UILabel")
    label_name:set_text(self.redGiftRankInfo.roleInfo.name)
    local memberCount = #self.redGiftRankInfo.memberList
    local allGetGold = 0
    for i = 1, memberCount do
      if self.redGiftRankInfo.memberList[i].moneyNum > self.redGiftRankInfo.memberList[self.bestIndex].moneyNum then
        self.bestIndex = i
      end
      allGetGold = allGetGold + self.redGiftRankInfo.memberList[i].moneyNum
    end
    local scrollViewObj = self.m_panel:FindDirect("Img_Bg/Img_BgList/Container/Scroll View")
    local scrollListObj = scrollViewObj:FindDirect("List_Member")
    local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
    if not GUIScrollList then
      scrollListObj:AddComponent("GUIScrollList")
    end
    local uiScrollList = scrollListObj:GetComponent("UIScrollList")
    ScrollList_setUpdateFunc(uiScrollList, function(item, i)
      self:FillRankInfo(item, i, self.redGiftRankInfo.memberList[i])
    end)
    ScrollList_setCount(uiScrollList, memberCount)
    scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
    local label_rednum = self.m_panel:FindDirect("Img_Bg/Label_RedBag/Label_Num"):GetComponent("UILabel")
    label_rednum:set_text(string.format(textRes.ChatRedGift[12], memberCount, self.redGiftRankInfo.maxNum))
    local label_redgold = self.m_panel:FindDirect("Img_Bg/Label_Gold/Label_Num"):GetComponent("UILabel")
    label_redgold:set_text(string.format(textRes.ChatRedGift[13], allGetGold, self.redGiftRankInfo.maxGold))
  end
end
def.method("userdata", "number", "table").FillRankInfo = function(self, memberUI, index, memberInfo)
  local label_num = memberUI:FindDirect("Label_Num"):GetComponent("UILabel")
  local label_name = memberUI:FindDirect("Label_Name"):GetComponent("UILabel")
  local img_luck = memberUI:FindDirect("Img_GoodLuck")
  label_name:set_text(memberInfo.roleName)
  label_num:set_text(tostring(memberInfo.moneyNum))
  if index == self.bestIndex then
    img_luck:SetActive(true)
  else
    img_luck:SetActive(false)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  warn("onClickObj" .. id)
  if "Btn_Close" == id then
    self:DestroyPanel()
  end
end
ChatRedGiftRankPanel.Commit()
return ChatRedGiftRankPanel
