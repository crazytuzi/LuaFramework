local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BackExpPanel = Lplus.Extend(ECPanelBase, "BackExpPanel")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local BackExpMgr = require("Main.Award.mgr.BackExpMgr")
local backExpMgr = BackExpMgr.Instance()
local def = BackExpPanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
def.field("table").activityList = nil
local instance
def.static("=>", BackExpPanel).Instance = function()
  if not instance then
    instance = BackExpPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_PANEL_PRIZE_BACKEXP, 0)
end
def.override().OnCreate = function(self)
  local Group_Item = self.m_panel:FindDirect("Group_DayGift/Container/Scroll View/Group_Item")
  local grid = Group_Item:GetComponent("UIGrid")
  local Img_Item1 = Group_Item:FindDirect("Img_Item1")
  if Img_Item1 then
    Img_Item1:set_name("Img_Item_1")
  end
  self:setActivityInfo()
  if backExpMgr:isNeedRefresh() then
    local p = require("netio.protocol.mzm.gsp.award.CGetAllLostExpInfoReq").new()
    gmodule.network.sendProtocol(p)
  end
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.BACK_EXP_INFO_CHANGE, BackExpPanel.OnBackExpInfoChange)
end
def.override().OnDestroy = function(self)
  self.activityList = nil
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.BACK_EXP_INFO_CHANGE, BackExpPanel.OnBackExpInfoChange)
end
def.static("table", "table").OnBackExpInfoChange = function(p1, p2)
  if instance and instance.m_panel then
    instance:setActivityInfo()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Get" then
    local parentName = obj.parent.name
    local strs = string.split(parentName, "_")
    local idx = tonumber(strs[3])
    if idx then
      self:clickGetExp(idx)
    end
  end
end
def.method("number").clickGetExp = function(self, index)
  if backExpMgr:isInCollectTime() then
    Toast(textRes.Award[90])
  else
    local curCfg = self.activityList[index]
    local activityId = curCfg.activityid
    local backExpInfo = backExpMgr:getBackExpInfo(activityId)
    if backExpInfo then
      local activityInfo = ActivityInterface.Instance():GetActivityInfo(activityId)
      local count = 0
      if activityInfo then
        count = activityInfo.count
      end
      if count >= curCfg.finishCount then
        if 0 < backExpInfo.canGetValue then
          local p = require("netio.protocol.mzm.gsp.award.CGetLostExpReq").new(activityId)
          gmodule.network.sendProtocol(p)
        else
          Toast(textRes.Award[91])
        end
      else
        Toast(textRes.Award[92])
      end
    end
  end
end
def.method().setActivityInfo = function(self)
  local Group_Item = self.m_panel:FindDirect("Group_DayGift/Container/Scroll View/Group_Item")
  local grid = Group_Item:GetComponent("UIGrid")
  local Img_Item1 = Group_Item:FindDirect("Img_Item_1")
  local activityList = BackExpMgr.GetAllActivityLostExpCfg()
  local activityInterface = ActivityInterface.Instance()
  local function comp(cfg1, cfg2)
    local flag1 = backExpMgr:canGetBackInfoAward(cfg1.activityid)
    local flag2 = backExpMgr:canGetBackInfoAward(cfg2.activityid)
    if flag1 or flag2 then
      if flag1 and not flag2 then
        return true
      elseif not flag1 and flag2 then
        return false
      else
        return cfg1.sort < cfg2.sort
      end
    else
      local backExpInfo1 = backExpMgr:getBackExpInfo(cfg1.activityid)
      local backExpInfo2 = backExpMgr:getBackExpInfo(cfg2.activityid)
      local isAlreadyGet1 = 0
      local isAlreadyGet2 = 0
      if backExpInfo1 and backExpInfo2 then
        isAlreadyGet1 = backExpInfo1.alreadyGetExp
        isAlreadyGet2 = backExpInfo2.alreadyGetExp
      end
      if isAlreadyGet1 == 0 or isAlreadyGet2 == 0 then
        if isAlreadyGet1 == 0 and isAlreadyGet2 ~= 0 then
          return true
        elseif isAlreadyGet1 ~= 0 and isAlreadyGet2 == 0 then
          return false
        else
          return cfg1.sort < cfg2.sort
        end
      else
        return cfg1.sort < cfg2.sort
      end
    end
  end
  table.sort(activityList, comp)
  self.activityList = activityList
  for i, v in ipairs(activityList) do
    local Img_Item = Group_Item:FindDirect(string.format("Img_Item_%d", i))
    if Img_Item then
    else
      Img_Item = Object.Instantiate(Img_Item1)
      Img_Item:set_name(string.format("Img_Item_%d", i))
      Img_Item.parent = Group_Item
      Img_Item:set_localScale(Vector.Vector3.one)
    end
    local Label_Name = Img_Item:FindDirect("Label_Name")
    local Label_CiShu = Img_Item:FindDirect("Label_CiShu")
    local Img_HaveLing = Img_Item:FindDirect("Img_HaveLing")
    local Group_Info = Img_Item:FindDirect("Group_Info")
    local Btn_Get = Img_Item:FindDirect("Btn_Get")
    local Label_AllExp = Group_Info:FindDirect("Label_AllNum/Label_CiShu")
    local Label_ReceiveExp = Group_Info:FindDirect("Label_ReciveNum/Label_CiShu")
    local Label_CanReceiveExp = Group_Info:FindDirect("Label_CanReciveNum/Label_CiShu")
    local Texture = Img_Item:FindDirect("Texture")
    local icon_texture = Texture:GetComponent("UITexture")
    local activityId = v.activityid
    local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
    Label_Name:GetComponent("UILabel"):set_text(activityCfg.activityName)
    GUIUtils.FillIcon(icon_texture, activityCfg.activityIcon)
    local activityInfo = activityInterface:GetActivityInfo(activityId)
    local count = 0
    if activityInfo then
      count = activityInfo.count
    else
      warn("-----actvityInfo is nil:", activityCfg.activityName)
    end
    Label_CiShu:GetComponent("UILabel"):set_text(count .. "/" .. v.finishCount)
    local backExpInfo = backExpMgr:getBackExpInfo(activityId)
    if backExpInfo then
      Label_AllExp:GetComponent("UILabel"):set_text(backExpInfo.totalValue)
      Label_ReceiveExp:GetComponent("UILabel"):set_text(backExpInfo.alreadyGetValue)
      Label_CanReceiveExp:GetComponent("UILabel"):set_text(backExpInfo.canGetValue)
      if count >= v.finishCount then
        if backExpInfo.alreadyGetExp == 0 then
          Btn_Get:SetActive(true)
          Img_HaveLing:SetActive(false)
          if not backExpMgr:isInCollectTime() and 0 < backExpInfo.canGetValue then
            GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.Square)
          end
        else
          Btn_Get:SetActive(false)
          Img_HaveLing:SetActive(true)
          GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
        end
      else
        Btn_Get:SetActive(true)
        Img_HaveLing:SetActive(false)
        GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
      end
    end
  end
  grid:Reposition()
end
return BackExpPanel.Commit()
