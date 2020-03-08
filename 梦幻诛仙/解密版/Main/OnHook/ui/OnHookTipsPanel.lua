local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local OnHookTipsPanel = Lplus.Extend(ECPanelBase, "OnHookTipsPanel")
local def = OnHookTipsPanel.define
local dlg
def.field("table").tipsTbl = nil
def.field("number").lastSelectedIndex = 1
def.static("=>", OnHookTipsPanel).Instance = function(self)
  if nil == dlg then
    dlg = OnHookTipsPanel()
    dlg.tipsTbl = {}
    dlg.lastSelectedIndex = 1
  end
  return dlg
end
def.override().OnCreate = function(self)
  self.lastSelectedIndex = 1
  self:InitCfgData()
  self:FillTipsList()
  self:FillSelectedTip()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_ON_HOOK_TIPS_PANEL, 0)
end
def.method().InitCfgData = function(self)
  self.tipsTbl = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ON_HOOK_TIPS_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local tipInfo = {}
    tipInfo.tipName = DynamicRecord.GetStringValue(entry, "playName")
    tipInfo.tipId = DynamicRecord.GetIntValue(entry, "playInfo")
    tipInfo.rank = DynamicRecord.GetIntValue(entry, "rank")
    table.insert(self.tipsTbl, tipInfo)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(self.tipsTbl, function(a, b)
    return a.rank < b.rank
  end)
end
def.method().FillTipsList = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Tab = Img_Bg:FindDirect("Group_Tab")
  local ScrollView_Tab = Group_Tab:FindDirect("ScrollView_Tab")
  local Grid_Tab = ScrollView_Tab:FindDirect("Grid_Tab"):GetComponent("UIList")
  local amount = #self.tipsTbl
  Grid_Tab:set_itemCount(amount)
  Grid_Tab:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not Grid_Tab.isnil then
      Grid_Tab:Reposition()
    end
  end)
  local items = Grid_Tab:get_children()
  for i = 1, amount do
    do
      local item = items[i]
      local tipInfo = self.tipsTbl[i]
      self:FillTipInfo(item, i, tipInfo)
      local uiToggle = item:GetComponent("UIToggle")
      GameUtil.AddGlobalTimer(0.1, true, function()
        if self.m_panel and false == self.m_panel.isnil then
          if self.lastSelectedIndex == i then
            uiToggle:set_value(true)
          else
            uiToggle:set_value(false)
          end
        end
      end)
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "number", "table").FillTipInfo = function(self, item, index, tipInfo)
  local Label_Tab = item:FindDirect(string.format("Label_Tab_%d", index)):GetComponent("UILabel")
  Label_Tab:set_text(tipInfo.tipName)
end
def.method().FillSelectedTip = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Tips = Img_Bg:FindDirect("Group_Tips")
  local ScrollView_Tips = Group_Tips:FindDirect("ScrollView_Tips")
  local Label_Tips = ScrollView_Tips:FindDirect("Label_Tips"):GetComponent("UILabel")
  local tipInfo = self.tipsTbl[self.lastSelectedIndex]
  if tipInfo then
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipInfo.tipId)
    Label_Tips:set_text(tipContent)
  else
    Label_Tips:set_text("")
  end
end
def.method("number").OnTipSelected = function(self, index)
  self.lastSelectedIndex = index
  self:FillSelectedTip()
end
def.method("string").onClick = function(self, id)
  if string.sub(id, 1, #"Btn_Tab_") == "Btn_Tab_" then
    local index = tonumber(string.sub(id, #"Btn_Tab_" + 1, -1))
    self:OnTipSelected(index)
  elseif "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif "Modal" == id then
    self:DestroyPanel()
    self = nil
  end
end
def.override().OnDestroy = function(self)
end
OnHookTipsPanel.Commit()
return OnHookTipsPanel
