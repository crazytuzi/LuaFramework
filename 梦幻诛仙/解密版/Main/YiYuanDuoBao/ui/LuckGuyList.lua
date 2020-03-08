local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local LuckGuyList = Lplus.Extend(ECPanelBase, "LuckGuyList")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local YiYuanDuoBaoUtils = require("Main.YiYuanDuoBao.YiYuanDuoBaoUtils")
local def = LuckGuyList.define
def.field("table").m_data = nil
def.field("number").m_turn = 0
def.field("number").m_sortId = 0
local instance
def.static("=>", LuckGuyList).Instance = function()
  if instance == nil then
    instance = LuckGuyList()
  end
  return instance
end
def.static("table", "number", "number").ShowLuckGuyList = function(data, turn, sortId)
  local self = LuckGuyList.Instance()
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_data = data
  self.m_turn = turn
  self.m_sortId = sortId
  if self.m_data == nil or #self.m_data == 0 then
    self.m_data = nil
    Toast(textRes.YiYuanDuoBao[19])
    return
  end
  self:CreatePanel(RESPATH.PREFAB_YIYUANDUOBAO_HISTORY_LIST_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitScrollList()
end
def.override().OnDestroy = function(self)
  self.m_data = nil
end
def.override("boolean").OnShow = function(self, show)
end
def.method().InitScrollList = function(self)
  local list = self.m_panel:FindDirect("Img_Bg0/Group_Log/Scrollview/List")
  local listCmp = list:GetComponent("UIScrollList")
  local GUIScrollList = list:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    list:AddComponent("GUIScrollList")
  end
  ScrollList_setUpdateFunc(listCmp, function(item, i)
    local info = self.m_data[i]
    item:FindDirect("Label_PlayerNum"):GetComponent("UILabel"):set_text(string.format(textRes.YiYuanDuoBao[7], YiYuanDuoBaoUtils.ConvertToDisplayNumber(info.award_number, YiYuanDuoBaoUtils.CalcOffset(self.m_turn, self.m_sortId))))
    local serverName = textRes.YiYuanDuoBao[9]
    local roleId = info.roleid
    if roleId then
      local serverInfo = GetRoleServerInfo(roleId)
      if serverInfo then
        serverName = serverInfo.name
      end
    end
    local name = GetStringFromOcts(info.role_name) or textRes.YiYuanDuoBao[10]
    local roleInfoStr = string.format(textRes.YiYuanDuoBao[8], serverName, name)
    item:FindDirect("Label_Content"):GetComponent("UILabel"):set_text(roleInfoStr)
  end)
  ScrollList_setCount(listCmp, #self.m_data)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
LuckGuyList.Commit()
return LuckGuyList
