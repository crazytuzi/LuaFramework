local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local LuckList = Lplus.Extend(ECPanelBase, "LuckList")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local AllLottoUtils = require("Main.AllLotto.AllLottoUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = LuckList.define
def.field("table").m_infos = nil
def.field("number").m_activityId = 0
def.static("number", "table").ShowLuckList = function(activityId, infos)
  local dlg = LuckList()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg.m_infos = infos
  dlg.m_activityId = activityId
  dlg:CreatePanel(RESPATH.PREFAB_ALLLOTTO_LIST, 2)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.ALLLOTTO, gmodule.notifyId.AllLotto.NewLuckyGuy, LuckList.OnNewLuckGuy, self)
  self:InitScrollList()
end
def.method("table").OnNewLuckGuy = function(self, params)
  if self.m_infos == nil then
    self.m_infos = {}
  end
  table.insert(self.m_infos, 1, params)
  self:UpdateList()
end
def.override("boolean").OnShow = function(self, show)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ALLLOTTO, gmodule.notifyId.AllLotto.NewLuckyGuy, LuckList.OnNewLuckGuy)
  self.m_infos = nil
  self.m_activityId = 0
end
def.method().InitScrollList = function(self)
  local list = self.m_panel:FindDirect("Img_Bg0/Group_Log/Scrollview/List")
  local listCmp = list:GetComponent("UIScrollList")
  local GUIScrollList = list:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    list:AddComponent("GUIScrollList")
  end
  ScrollList_setUpdateFunc(listCmp, function(item, i)
    local info = self.m_infos[i]
    local roleInfo = info.role_info
    local turn = info.turn
    local serverName = ""
    local serverInfo = GetRoleServerInfo(roleInfo.roleid)
    if serverInfo then
      serverName = serverInfo.name
    end
    local name = GetStringFromOcts(roleInfo.role_name) or ""
    local itemName = ""
    local timeStr = ""
    local turnCfg = AllLottoUtils.GetAllLottoTurnCfg(self.m_activityId, turn)
    if turnCfg then
      local items = ItemUtils.GetAwardItems(turnCfg.awardId)
      if items and items[1] then
        local itemBase = ItemUtils.GetItemBase(items[1].itemId)
        if itemBase then
          itemName = itemBase.name
        end
      end
      local timeTbl = AbsoluteTimer.GetServerTimeTable(turnCfg.time)
      timeStr = string.format(textRes.AllLotto[4], timeTbl.year, timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min)
    end
    local playerName = string.format("%s-%s", serverName, name)
    item:FindDirect("Label_Time"):GetComponent("UILabel"):set_text(timeStr)
    item:FindDirect("Label_Player"):GetComponent("UILabel"):set_text(playerName)
    item:FindDirect("Label_Reward"):GetComponent("UILabel"):set_text(itemName)
  end)
  self:UpdateList()
end
def.method().UpdateList = function(self)
  local scroll = self.m_panel:FindDirect("Img_Bg0/Group_Log/Scrollview")
  local list = scroll:FindDirect("List")
  local listCmp = list:GetComponent("UIScrollList")
  scroll:GetComponent("UIScrollView"):ResetPosition()
  ScrollList_setCount(listCmp, #self.m_infos)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
LuckList.Commit()
return LuckList
