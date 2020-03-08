local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CorpsCheckDlg = Lplus.Extend(ECPanelBase, "CorpsCheckDlg")
local CorpsDuty = require("consts.mzm.gsp.corps.confbean.CorpsDuty")
local GUIUtils = require("GUI.GUIUtils")
local CorpsUtils = require("Main.Corps.CorpsUtils")
local def = CorpsCheckDlg.define
local instance
def.static("=>", CorpsCheckDlg).Instance = function()
  if instance == nil then
    instance = CorpsCheckDlg()
  end
  return instance
end
def.field("table").data = nil
def.static("table").ShowCorpsCheck = function(data)
  local dlg = CorpsCheckDlg.Instance()
  if dlg:IsCreated() then
    dlg:DestroyPanel()
  end
  dlg.data = data
  dlg:CreatePanel(RESPATH.PREFAB_CHECK_CORPS, 2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateCorpsInfo()
  self:UpdateMemberInfo()
end
def.method().UpdateCorpsInfo = function(self)
  local name = GetStringFromOcts(self.data.corpsBriefInfo.name)
  local declare = GetStringFromOcts(self.data.corpsBriefInfo.declaration)
  local badgeId = self.data.corpsBriefInfo.corpsBadgeId
  local nameLbl = self.m_panel:FindDirect("Img_Bg0/TeamInfo/Label_TeamName")
  nameLbl:GetComponent("UILabel"):set_text(name)
  local declareLbl = self.m_panel:FindDirect("Img_Bg0/TeamInfo/Label_Tips01")
  declareLbl:GetComponent("UILabel"):set_text(declare)
  local badgeTex = self.m_panel:FindDirect("Img_Bg0/TeamInfo/Texture_Team")
  local badgeCfg = CorpsUtils.GetCorpsBadgeCfg(badgeId)
  GUIUtils.FillIcon(badgeTex:GetComponent("UITexture"), badgeCfg.iconId)
end
def.method().UpdateMemberInfo = function(self)
  local scroll = self.m_panel:FindDirect("Img_Bg0/Group_RankList/Group_List/Scrolllist")
  local list = scroll:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  local memberSort = {}
  for k, v in pairs(self.data.members) do
    table.insert(memberSort, v)
  end
  table.sort(memberSort, function(a, b)
    if a.baseInfo.duty < b.baseInfo.duty then
      return true
    elseif a.baseInfo.duty > b.baseInfo.duty then
      return false
    else
      return a.baseInfo.joinTime < b.baseInfo.joinTime
    end
  end)
  local count = #memberSort
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = memberSort[i]
    self:FillMemberInfo(uiGo, info, i)
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method("userdata", "table", "number").FillMemberInfo = function(self, uiGo, info, index)
  if index % 2 == 1 then
    uiGo:FindDirect("Img_Bg1"):SetActive(true)
    uiGo:FindDirect("Img_Bg2"):SetActive(false)
  else
    uiGo:FindDirect("Img_Bg2"):SetActive(true)
    uiGo:FindDirect("Img_Bg1"):SetActive(false)
  end
  uiGo:FindDirect("Label_Level"):GetComponent("UILabel"):set_text(info.baseInfo.level)
  uiGo:FindDirect("Label_PlayerName"):GetComponent("UILabel"):set_text(GetStringFromOcts(info.baseInfo.name))
  uiGo:FindDirect("Label_FightPoint"):GetComponent("UILabel"):set_text(info.otherInfo.multiFightValue)
  uiGo:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(info.otherInfo.mfvRank > 0 and info.otherInfo.mfvRank or textRes.RankList[1])
  uiGo:FindDirect("Img_Camp"):GetComponent("UISprite"):set_spriteName(GUIUtils.GetOccupationSmallIcon(info.baseInfo.occupationId))
  local head = uiGo:FindDirect("Group_Head")
  head:FindDirect("Img_Sex"):GetComponent("UISprite"):set_spriteName(GUIUtils.GetGenderSprite(info.baseInfo.gender))
  local headIcon = head:FindDirect("Icon_Team")
  SetAvatarIcon(headIcon, info.baseInfo.avatarId)
  local frame = head:FindDirect("Icon_BgTeam")
  SetAvatarFrameIcon(frame, info.baseInfo.avatarFrameId)
  local leader = head:FindDirect("Img_Leader")
  if info.baseInfo.duty == CorpsDuty.CAPTAIN then
    leader:SetActive(true)
  else
    leader:SetActive(false)
  end
end
def.override().OnDestroy = function(self)
  self.data = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
return CorpsCheckDlg.Commit()
