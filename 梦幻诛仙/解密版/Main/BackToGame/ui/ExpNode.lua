local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ExpNode = Lplus.Extend(TabNode, "ExpNode")
local BTGExp = require("Main.BackToGame.mgr.BTGExp")
local BTGTask = require("Main.BackToGame.mgr.BTGTask")
local GUIUtils = require("GUI.GUIUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ECPanelBase = require("GUI.ECPanelBase")
local def = ExpNode.define
def.field("table").m_expList = nil
def.field("number").m_total = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ExpUpdate, ExpNode.OnExpUpdate, self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.TaskUpdate, ExpNode.OnTaskUpdate, self)
  Event.RegisterEventWithContext(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, ExpNode.OnActivityInfoChanged, self)
  self:UpdateExpList()
  self:UpdateTotal()
  self:UpdateLingQi()
  self:UpdateTask()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ExpUpdate, ExpNode.OnExpUpdate)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.TaskUpdate, ExpNode.OnTaskUpdate)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, ExpNode.OnActivityInfoChanged)
  self.m_expList = nil
  self.m_total = 0
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Join" then
    self.m_base:DestroyPanel()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {
      constant.LingQiFengYinConsts.LINGQIFENGYIN_ACTIVITYID
    })
  elseif id == "Btn_Tip" then
    local tipsId = BTGTask.Instance():GetTipsId()
    GUIUtils.ShowHoverTip(tipsId)
  elseif id == "Btn_CreatTeam" then
    local teamPlatformId = BTGTask.Instance():GetTeamPlatformId()
    require("Main.TeamPlatform.ui.TeamPlatformPanel").Instance():FocusOnTarget(teamPlatformId)
  elseif id == "Btn_GetMission" then
    BTGTask.Instance():GetTask()
  elseif string.sub(id, 1, 8) == "Btn_Get_" then
    local index = tonumber(string.sub(id, 9))
    if index then
      local info = self.m_expList[index]
      if info then
        if not info.signed then
          if info.leftDay <= 0 then
            BTGExp.Instance():Draw(index)
          else
            Toast(string.format(textRes.BackToGame.Exp[4], info.leftDay))
          end
        else
          Toast(textRes.BackToGame.Exp[3])
        end
      end
    end
  end
end
def.method("table").OnExpUpdate = function(self, param)
  self:UpdateExpList()
end
def.method("table").OnTaskUpdate = function(self, param)
  self:UpdateTask()
end
def.method().UpdateTotal = function(self)
  local totalLbl = self.m_node:FindDirect("Label_ExpNum")
  totalLbl:GetComponent("UILabel"):set_text(tostring(self.m_total))
end
def.method().UpdateExpList = function(self)
  self.m_expList, self.m_total = BTGExp.Instance():GetExpData()
  local scroll = self.m_node:FindDirect("Group_List/Scroll View_LeiDeng")
  local list = scroll:FindDirect("List_LeiDeng")
  local listCmp = list:GetComponent("UIList")
  local count = #self.m_expList
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = self.m_expList[i]
    self:FillItem(uiGo, info, i)
    self.m_base.m_msgHandler:Touch(uiGo)
  end
  local showItemIdx = 0
  for i = 1, #items do
    local info = self.m_expList[i]
    if info and not info.signed then
      showItemIdx = i
      break
    end
  end
  local showItem = items[showItemIdx]
  if showItem ~= nil then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if _G.IsNil(scroll) or _G.IsNil(showItem) then
        return
      end
      local itemBg = showItem:FindDirect("Sprite_" .. showItemIdx)
      local width = itemBg:GetComponent("UIWidget").width
      local pos = showItem.localPosition.x - width / 2
      scroll:GetComponent("UIScrollView"):SetDragDistance(pos, 0, false)
    end)
  end
end
def.method("userdata", "table", "number").FillItem = function(self, uiGo, info, index)
  local indexLbl = uiGo:FindDirect(string.format("Img_Ti_%d/Label_Num_%d", index, index))
  local item1 = uiGo:FindDirect(string.format("Group_Icon_%d/Img_BgIcon1_%d", index, index))
  local item2 = uiGo:FindDirect(string.format("Group_Icon_%d/Img_BgIcon2_%d", index, index))
  local btn = uiGo:FindDirect(string.format("Btn_Get_%d", index))
  indexLbl:GetComponent("UILabel"):set_text(info.index)
  if info.item1 then
    item1:SetActive(true)
    local icon = item1:FindDirect(string.format("Texture_Icon_%d", index))
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), info.item1.iconId)
    local num = item1:FindDirect(string.format("Label_Num_%d", index))
    num:GetComponent("UILabel"):set_text(info.item1.num)
  else
    item1:SetActive(false)
  end
  if info.item2 then
    item1:SetActive(true)
    local icon = item2:FindDirect(string.format("Texture_Icon_%d", index))
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), info.item2.iconId)
    local num = item2:FindDirect(string.format("Label_Num_%d", index))
    num:GetComponent("UILabel"):set_text(info.item2.num)
  else
    item2:SetActive(false)
  end
  local get = btn:FindDirect(string.format("Label_Get_%d", index))
  local wait = btn:FindDirect(string.format("Group_Date_%d", index))
  local old = btn:FindDirect(string.format("Img_YiLing_%d", index))
  if info.signed then
    get:SetActive(false)
    wait:SetActive(false)
    old:SetActive(true)
    GUIUtils.SetLightEffect(btn, GUIUtils.Light.None)
  elseif info.leftDay <= 0 then
    get:SetActive(true)
    wait:SetActive(false)
    old:SetActive(false)
    GUIUtils.SetLightEffect(btn, GUIUtils.Light.Square)
  elseif info.leftDay > 0 then
    get:SetActive(false)
    wait:SetActive(true)
    old:SetActive(false)
    local day = wait:FindDirect(string.format("Label_Num_%d", index))
    day:GetComponent("UILabel"):set_text(info.leftDay)
    GUIUtils.SetLightEffect(btn, GUIUtils.Light.None)
  end
end
def.method("table").OnActivityInfoChanged = function(self, param)
  local activityId = param[1]
  if activityId == constant.LingQiFengYinConsts.LINGQIFENGYIN_ACTIVITYID then
    self:UpdateLingQi()
  end
end
def.method().UpdateLingQi = function(self)
  local icon = self.m_node:FindDirect("Group_LingQi/Img_BgIcon")
  local name = icon:FindDirect("Label_Name")
  local btnLbl = self.m_node:FindDirect("Group_LingQi/Btn_Join/Label_Join")
  local actCfg = ActivityInterface.GetActivityCfgById(constant.LingQiFengYinConsts.LINGQIFENGYIN_ACTIVITYID)
  GUIUtils.FillIcon(icon:GetComponent("UITexture"), actCfg.activityIcon)
  name:GetComponent("UILabel"):set_text(actCfg.activityName)
  btnLbl:GetComponent("UILabel"):set_text(textRes.BackToGame.Exp[2])
end
def.method().UpdateTask = function(self)
  local lbl = self.m_node:FindDirect("Group_FuBen/Btn_GetMission/Label_Join")
  if BTGTask.Instance():GetTaskState() then
    lbl:GetComponent("UILabel"):set_text(textRes.BackToGame.Task[3])
  else
    lbl:GetComponent("UILabel"):set_text(textRes.BackToGame.Task[2])
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_EXP)
  return open
end
ExpNode.Commit()
return ExpNode
