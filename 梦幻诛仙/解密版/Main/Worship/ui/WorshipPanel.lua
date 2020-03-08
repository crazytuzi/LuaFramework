local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WorshipPanel = Lplus.Extend(ECPanelBase, "WorshipPanel")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local WorshipInterface = require("Main.Worship.WorshipInterface")
local worshipInterface = WorshipInterface.Instance()
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local def = WorshipPanel.define
local instance
def.field("number").selectedIdx = 0
def.static("=>", WorshipPanel).Instance = function()
  if instance == nil then
    instance = WorshipPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_GANG_GET_MONEY, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.WORSHIP, gmodule.notifyId.Worship.Worship_Info_Change, WorshipPanel.OnWorshipInfoChange)
  Event.RegisterEvent(ModuleId.WORSHIP, gmodule.notifyId.Worship.Worship_Record_Change, WorshipPanel.OnWorshipRecordChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.WORSHIP, gmodule.notifyId.Worship.Worship_Info_Change, WorshipPanel.OnWorshipInfoChange)
  Event.UnregisterEvent(ModuleId.WORSHIP, gmodule.notifyId.Worship.Worship_Record_Change, WorshipPanel.OnWorshipRecordChange)
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setWorshipInfo()
    self:setWorshipRecord()
    local p = require("netio.protocol.mzm.gsp.worship.CGetFactionWorshipReq").new()
    gmodule.network.sendProtocol(p)
  else
    self.selectedIdx = 0
  end
end
def.static("table", "table").OnWorshipInfoChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setWorshipInfo()
  end
end
def.static("table", "table").OnWorshipRecordChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setWorshipRecord()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("------OnClickObj:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Img_Add" then
    local position = clickObj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local com = clickObj:GetComponent("UIWidget")
    if com == nil then
      return
    end
    ItemTipsMgr.Instance():ShowBasicTips(constant.CWorShipConst.facitonFileId, screenPos.x, screenPos.y, com:get_width(), com:get_height(), 0, true)
  elseif id == "Img_Help" then
    local tipStr = require("Main.Common.TipsHelper").GetHoverTip(constant.CWorShipConst.functionTipId)
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipStr, {x = 0, y = 0})
  elseif id == "Img_Bg" then
    if 0 < worshipInterface.myWorshipId then
      return
    end
    local subStrs = string.split(clickObj.parent.name, "_")
    local idx = tonumber(subStrs[2])
    if idx then
      local worshipCfg = WorshipInterface.GetWorshipCfgByIndex(idx)
      if worshipCfg and self.selectedIdx ~= idx then
        local Grid_Oper = self.m_panel:FindDirect("Img_Bg0/Group_Oper/Grid_Oper")
        local Oper = Grid_Oper:FindDirect("Oper_0" .. self.selectedIdx)
        if Oper then
          local Img_Select = Oper:FindDirect("Img_Select")
          if Img_Select then
            Img_Select:SetActive(false)
          end
        end
        Oper = Grid_Oper:FindDirect("Oper_0" .. idx)
        if Oper then
          local Img_Select = Oper:FindDirect("Img_Select")
          if Img_Select then
            self.selectedIdx = idx
            Img_Select:SetActive(true)
          end
        end
      end
    end
  elseif id == "Btn_Get" then
    self:sendWorship(self.selectedIdx)
  elseif strs[1] == "Btn" and strs[2] == "Select" then
    local idx = tonumber(strs[3])
    if idx then
      self:sendWorship(idx)
    end
  end
end
def.method("number").sendWorship = function(self, idx)
  local worshipCfg = WorshipInterface.GetWorshipCfgByIndex(idx)
  if worshipCfg then
    local p = require("netio.protocol.mzm.gsp.worship.CWorshipReq").new(worshipCfg.id)
    gmodule.network.sendProtocol(p)
  else
    warn("!!!!!!!!!invalid idx:", idx)
  end
end
def.method().setWorshipInfo = function(self)
  local Group_Info = self.m_panel:FindDirect("Img_Bg0/Group_Info")
  local Label_LWNum = Group_Info:FindDirect("Group_LW/Label_LWNum")
  Label_LWNum:GetComponent("UILabel"):set_text(worshipInterface.lastCycleNum)
  local Label_TWNum = Group_Info:FindDirect("Group_TK/Label_TWNum")
  Label_TWNum:GetComponent("UILabel"):set_text(worshipInterface.curCycleNum)
  local Label_MoneyNum = Group_Info:FindDirect("Group_Money/Label_MoneyNum")
  Label_MoneyNum:GetComponent("UILabel"):set_text(worshipInterface.canGetSalary)
  local Grid_Oper = self.m_panel:FindDirect("Img_Bg0/Group_Oper/Grid_Oper")
  local uiGrid = Grid_Oper:GetComponent("UIGrid")
  local num = uiGrid.transform.childCount
  local myWorshipId = worshipInterface.myWorshipId
  local Btn_Get = self.m_panel:FindDirect("Img_Bg0/Group_Info/Btn_Get")
  local btnGet = Btn_Get:GetComponent("UIButton")
  local Label_Select = Btn_Get:FindDirect("Label_Select")
  if myWorshipId == 0 then
    self.selectedIdx = math.random(1, num)
    btnGet.isEnabled = true
    Label_Select:GetComponent("UILabel"):set_text(textRes.Worship[4])
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.Square)
  else
    btnGet.isEnabled = false
    Label_Select:GetComponent("UILabel"):set_text(textRes.Worship[5])
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
  end
  for i = 1, num do
    local worshipCfg = WorshipInterface.GetWorshipCfgByIndex(i)
    if worshipCfg then
      local Oper = Grid_Oper:FindDirect("Oper_0" .. i)
      local Label_Name = Oper:FindDirect("Label_Name")
      Label_Name:GetComponent("UILabel"):set_text(worshipCfg.actionName)
      local Label_Num = Oper:FindDirect("Label_Num_0" .. i)
      Label_Num:GetComponent("UILabel"):set_text(worshipInterface:getWorshipNumById(worshipCfg.id))
      local Img_Select = Oper:FindDirect("Img_Select")
      if worshipCfg.id == myWorshipId then
        self.selectedIdx = i
      end
      if self.selectedIdx == i then
        Img_Select:SetActive(true)
      else
        Img_Select:SetActive(false)
      end
    end
  end
end
def.method().setWorshipRecord = function(self)
  local recordStr = worshipInterface:getWorshipRecordStr()
  local Drag_Tips = self.m_panel:FindDirect("Img_Bg0/Group_Note/Scrollview_Note/Drag_Tips")
  Drag_Tips:GetComponent("UILabel"):set_text(recordStr)
end
return WorshipPanel.Commit()
