local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QingYuanInfoPanel = Lplus.Extend(ECPanelBase, "QingYuanInfoPanel")
local QingYuanMgr = require("Main.QingYuan.QingYuanMgr")
local GUIUtils = require("GUI.GUIUtils")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = QingYuanInfoPanel.define
local instance
def.field("table").uiObjs = nil
def.static("=>", QingYuanInfoPanel).Instance = function()
  if instance == nil then
    instance = QingYuanInfoPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_QINGYUAN_INFO_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.RECEIVE_QINGYUAN_INFO, QingYuanInfoPanel.OnReceiveQingYuanInfo)
  Event.RegisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.QINGYUAN_INFO_CHANGE, QingYuanInfoPanel.OnQingYuanInfoChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, QingYuanInfoPanel.OnFeatureOpenChange)
  QingYuanMgr.Instance():GetQingYuanInfo()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.RECEIVE_QINGYUAN_INFO, QingYuanInfoPanel.OnReceiveQingYuanInfo)
  Event.UnregisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.QINGYUAN_INFO_CHANGE, QingYuanInfoPanel.OnQingYuanInfoChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, QingYuanInfoPanel.OnFeatureOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.ScrollView = self.uiObjs.Img_Bg:FindDirect("Group_List/Scroll View")
  self.uiObjs.List_Left = self.uiObjs.ScrollView:FindDirect("List_Left")
  local uiList = self.uiObjs.List_Left:GetComponent("UIList")
  uiList.itemCount = 0
  uiList:Resize()
end
def.method().FillQingYuanInfo = function(self)
  local qingYuanInfoList = QingYuanMgr.Instance():GetQingYuanRoleList()
  local uiList = self.uiObjs.List_Left:GetComponent("UIList")
  uiList.itemCount = #qingYuanInfoList
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, uiList.itemCount do
    local uiItem = uiItems[i]
    self:FillQingYuanInfoItem(i, uiItem, qingYuanInfoList[i])
  end
  local scrollView = self.uiObjs.ScrollView:GetComponent("UIScrollView")
  scrollView:ResetPosition()
end
def.method("number", "userdata", "table").FillQingYuanInfoItem = function(self, idx, item, data)
  local Label_Name = item:FindDirect("Label_Name_" .. idx)
  local Label_Level = item:FindDirect("Label_Level_" .. idx)
  local Label_Status = item:FindDirect("Label_Status_" .. idx)
  local Label_Num = item:FindDirect("Label_Num_" .. idx)
  local Img_HeadIcon = item:FindDirect(string.format("Img_HeadIconBg_%d/Img_HeadIcon_%d", idx, idx))
  GUIUtils.SetText(Label_Name, data.role_name)
  GUIUtils.SetText(Label_Level, data.role_level)
  local friendData = require("Main.friend.FriendData").Instance()
  local friendInfo = friendData:GetFriendInfo(data.role_id)
  local qinmidu = friendInfo ~= nil and friendInfo.relationValue or 0
  GUIUtils.SetText(Label_Num, qinmidu)
  if Int64.lt(data.offline_time, 0) then
    GUIUtils.SetText(Label_Status, textRes.QingYuan[1])
  else
    local t = AbsoluteTimer.GetServerTimeTable(Int64.ToNumber(data.offline_time) / 1000)
    GUIUtils.SetText(Label_Status, string.format("%02d/%02d", t.month, t.day))
  end
  GUIUtils.SetSprite(Img_HeadIcon, GUIUtils.GetHeadSpriteName(data.occupation_id, data.gender))
end
def.method("table", "userdata").ShowPlayerInfo = function(self, roleInfo, source)
  local position = source.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  require("Main.Pubrole.PubroleTipsMgr").Instance():ShowTipXY(roleInfo, screenPos.x, screenPos.y, nil)
end
def.static("table", "table").OnReceiveQingYuanInfo = function(params, context)
  local self = instance
  if self ~= nil then
    self:FillQingYuanInfo()
  end
end
def.static("table", "table").OnQingYuanInfoChange = function(params, context)
  local self = instance
  if self ~= nil then
    QingYuanMgr.Instance():GetQingYuanInfo()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local objName = obj.name
  if string.find(objName, "Img_HeadIconBg_") then
    local idx = tonumber(string.sub(objName, #"Img_HeadIconBg_" + 1))
    QingYuanMgr.Instance():GetQingYuanRoleInfoByIdx(idx, function(roleInfo)
      self:ShowPlayerInfo(roleInfo, obj)
    end)
  else
    self:onClick(objName)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif string.find(id, "Btn_Delete_") then
    do
      local idx = tonumber(string.sub(id, #"Btn_Delete_" + 1))
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.QingYuan[3], constant.QingYuanConsts.friendValueAfterRelieve), function(result, tag)
        if result == 1 then
          QingYuanMgr.Instance():DeleteQingYuanByIdx(idx)
        end
      end, nil)
    end
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  local self = instance
  if self ~= nil and not QingYuanMgr.Instance():IsQingYuanFunctionOpen() then
    Toast(textRes.QingYuan[26])
    self:Close()
  end
end
QingYuanInfoPanel.Commit()
return QingYuanInfoPanel
