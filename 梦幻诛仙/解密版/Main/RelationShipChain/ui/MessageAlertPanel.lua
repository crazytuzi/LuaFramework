local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECMSDK = require("ProxySDK.ECMSDK")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local MessageAlertPanel = Lplus.Extend(ECPanelBase, "MessageAlertPanel")
local def = MessageAlertPanel.define
def.field("number").m_CurIndex = 0
def.field("table").m_ListData = nil
def.field("table").m_ToggleGO = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", MessageAlertPanel).Instance = function()
  if not instance then
    instance = MessageAlertPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_MESSAGE_ALERT, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitData()
  self:Update()
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.Subscribe, MessageAlertPanel.OnSwitchSubscribe)
end
def.override().OnDestroy = function(self)
  self.m_CurIndex = 0
  self.m_ListData = nil
  self.m_UIGO = nil
  self.m_ToggleGO = nil
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.Subscribe, MessageAlertPanel.OnSwitchSubscribe)
end
def.static("table", "table").OnSwitchSubscribe = function(params)
  local index = instance.m_CurIndex
  if instance.m_ToggleGO and instance.m_ToggleGO[index] then
    local onGO = instance.m_ToggleGO[index].onGO
    local offGO = instance.m_ToggleGO[index].offGO
    GUIUtils.SetActive(onGO, not onGO.activeSelf)
    GUIUtils.SetActive(offGO, not offGO.activeSelf)
  end
  instance.m_CurIndex = 0
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id:find("Btn_Reminder_") == 1 then
    local _, lastIndex = id:find("Btn_Reminder_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    if self.m_ListData[index] then
      RelationShipChainMgr.SendToFriend(1, self.m_ListData[index].content)
    end
  elseif id:find("Toggle_On_") == 1 then
    local _, lastIndex = id:find("Toggle_On_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    local data = self.m_ListData[index]
    if not data or self.m_CurIndex ~= 0 then
      return
    end
    self.m_CurIndex = index
    RelationShipChainMgr.SetDataToURL(data.indexId, 1)
  elseif id:find("Toggle_Off_") == 1 then
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.RelationShipChain[20], textRes.RelationShipChain[21], "", "", 0, 0, function(selection, tag)
      if selection == 1 then
        local _, lastIndex = id:find("Toggle_Off_")
        local index = tonumber(id:sub(lastIndex + 1, id:len()))
        local data = self.m_ListData[index]
        if not data or self.m_CurIndex ~= 0 then
          return
        end
        self.m_CurIndex = index
        RelationShipChainMgr.SetDataToURL(data.indexId, 0)
      end
    end, nil)
  end
end
def.method().InitData = function(self)
  self.m_ListData = RelationShipChainMgr.GetSubscribeData()
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.List_Activity = self.m_panel:FindDirect("Img_Bg/Group_List/Scroll View_List/List_Activity")
end
def.method().UpdateListView = function(self)
  self.m_ToggleGO = {}
  local uiListGO = self.m_UIGO.List_Activity
  local itemCount = #self.m_ListData
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local activityGO = itemGO:FindDirect(("Label_Activity_%d"):format(i))
    local frequencyGO = itemGO:FindDirect(("Label_Frequency_%d"):format(i))
    local timeGO = itemGO:FindDirect(("Label_Time_%d"):format(i))
    local typeGO = itemGO:FindDirect(("Label_Type_%d"):format(i))
    local toggleOnGO = itemGO:FindDirect(("Toggle_On_%d"):format(i))
    local toggleOffGO = itemGO:FindDirect(("Toggle_Off_%d"):format(i))
    local itemData = self.m_ListData[i]
    GUIUtils.SetText(activityGO, itemData.activityName)
    GUIUtils.SetText(frequencyGO, itemData.cycle)
    GUIUtils.SetText(timeGO, itemData.time)
    GUIUtils.SetText(typeGO, itemData.type)
    GUIUtils.SetActive(toggleOnGO, itemData.status)
    GUIUtils.SetActive(toggleOffGO, not itemData.status)
    self.m_ToggleGO[i] = {}
    self.m_ToggleGO[i].onGO = toggleOnGO
    self.m_ToggleGO[i].offGO = toggleOffGO
  end
  GUIUtils.Reposition(uiListGO, GUIUtils.COTYPE.LIST, 0)
end
def.method().Update = function(self)
  self:UpdateListView()
end
return MessageAlertPanel.Commit()
