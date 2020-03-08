local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UICarnivalSign = Lplus.Extend(ECPanelBase, "UICarnivalSign")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector3 = require("Types.Vector3").Vector3
local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
local ActivityInterface = require("Main.activity.ActivityInterface")
local LimitTimeSignInMgr = require("Main.CustomActivity.LimitTimeSignInMgr")
local limitTimeSignInMgr = LimitTimeSignInMgr.Instance()
local CarnivalSignMgr = require("Main.WelcomeParty.CarnivalSignMgr")
local def = UICarnivalSign.define
local instance
def.field("table")._uiGOs = nil
def.field("table").signCfgList = nil
def.field("number").curSelectedIndex = 0
def.static("=>", UICarnivalSign).Instance = function()
  if instance == nil then
    instance = UICarnivalSign()
  end
  return instance
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:setActivityInfo()
    self:setSignInAwardList()
    Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_TIME_SIGNIN_INFO_CHANGE, UICarnivalSign.OnSignInfoChange)
  else
    Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_TIME_SIGNIN_INFO_CHANGE, UICarnivalSign.OnSignInfoChange)
    if CarnivalSignMgr.Instance():isFinishAllSign() then
      local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
      Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, {
        nodeId = NodeId.CarnivalSign
      })
    end
  end
end
def.static("table", "table").OnSignInfoChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setSignInAwardList()
    instance:UpdateNotifyState()
  end
end
def.method().UpdateNotifyState = function(self)
  local isNotify = CarnivalSignMgr.Instance():isHaveCarnivalSignAward()
  local UIWelcomePartyBasic = require("Main.WelcomeParty.ui.UIWelcomePartyBasic")
  UIWelcomePartyBasic.Instance():SetTabNotify(UIWelcomePartyBasic.NodeId.CarnivalSign, isNotify)
end
def.method().setActivityInfo = function(self)
  local activityId = constant.CLoginAwardCfgConsts.BEGINNER_LOGIN_SIGN_ACTIVITY_CFG_ID
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local cfg = CustomActivityInterface.GetBeginnerLoginSignCfg(activityId)
  local banner = cfg.banner
  if banner ~= 0 then
    local Img_BgTitle = self.m_panel:FindDirect("Group_QianDao/Img_BgTitle")
    local UITexture = Img_BgTitle:GetComponent("UITexture")
    GUIUtils.FillIcon(UITexture, banner)
  end
  local startTime, endTime = CarnivalSignMgr.Instance():getCarnivalSignStartAndEndTime()
  local Label_Time = self.m_panel:FindDirect("Group_QianDao/Img_BgTitle/Label_Time")
  if startTime == 0 or endTime == 0 then
    Label_Time:GetComponent("UILabel"):set_text("")
  else
    local getTimeStr = function(time)
      local nYear = tonumber(os.date("%Y", time))
      local nMonth = tonumber(os.date("%m", time))
      local nDay = tonumber(os.date("%d", time))
      return string.format(textRes.customActivity[9], nYear, nMonth, nDay)
    end
    Label_Time:GetComponent("UILabel"):set_text(getTimeStr(startTime) .. "-" .. getTimeStr(endTime - 86400))
  end
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_CARVINAL_SIGN, 0)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif strs[1] == "item" then
    local index = tonumber(strs[2])
    if index then
      self:itemClick(index, clickObj)
    end
  end
end
def.method("number", "userdata").itemClick = function(self, index, clickObj)
  local ScrollView = self.m_panel:FindDirect("Group_QianDao/Group_Items/Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  if index ~= self.curSelectedIndex then
    local item = Grid:FindDirect("item_" .. self.curSelectedIndex)
    if item then
      local Img_Select = item:FindDirect("Img_Select")
      Img_Select:SetActive(false)
    end
    item = Grid:FindDirect("item_" .. index)
    if item then
      local Img_Select = item:FindDirect("Img_Select")
      Img_Select:SetActive(true)
    end
    self.curSelectedIndex = index
  end
  if CarnivalSignMgr.Instance():canGetCarnivalSignAward(index) then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local level = 0
    if heroProp ~= nil then
      level = heroProp.level
    end
    local activityId = constant.CLoginAwardCfgConsts.BEGINNER_LOGIN_SIGN_ACTIVITY_CFG_ID
    local cfg = CustomActivityInterface.GetBeginnerLoginSignCfg(activityId)
    local needLv = cfg.openLevel
    if level >= needLv then
      local req = require("netio.protocol.mzm.gsp.loginaward.CGetLoginSignAward").new(activityId, index)
      gmodule.network.sendProtocol(req)
    else
      Toast(string.format(textRes.customActivity[201], needLv))
    end
    return
  end
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local itemInfo = self:getAwardItemInfo(index)
  if itemInfo then
    local itemId = itemInfo.itemId
    local source = clickObj
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = source:GetComponent("UIWidget")
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
  end
end
def.method().setSignInAwardList = function(self)
  local activityId = constant.CLoginAwardCfgConsts.BEGINNER_LOGIN_SIGN_ACTIVITY_CFG_ID
  local signCfgs = CustomActivityInterface.GetLimitTimeSingInCfgByActivityId(activityId)
  self.signCfgList = signCfgs
  local ScrollView = self.m_panel:FindDirect("Group_QianDao/Group_Items/Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local uilist = Grid:GetComponent("UIList")
  uilist.itemCount = #signCfgs
  uilist:Resize()
  local selectedIdx = 0
  local signInInfo = limitTimeSignInMgr:getLimitTimeSingInInfo(activityId)
  local curSortId = 0
  warn("---------curSortId:", signInInfo, signInInfo.sortid)
  if signInInfo then
    curSortId = signInInfo.sortid
  end
  local carnivalSignMgr = CarnivalSignMgr.Instance()
  for i = 1, #signCfgs do
    local curCfg = signCfgs[i]
    local item = Grid:FindDirect("item_" .. i)
    local itemInfo = self:getAwardItemInfo(i)
    if itemInfo then
      local Img_Bg1 = item:FindDirect("Img_Bg1")
      local Img_Select = item:FindDirect("Img_Select")
      local Label_Day = item:FindDirect("Label_Day")
      local Label_Name = item:FindDirect("Label_Name")
      local Img_YiLing = item:FindDirect("Img_YiLing")
      local Img_KeLing = item:FindDirect("Img_KeLing")
      local Img_Gray = item:FindDirect("Img_Gray")
      local Img_BgIcon = item:FindDirect("Img_BgIcon")
      local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon"):GetComponent("UITexture")
      local Label_Num = Img_BgIcon:FindDirect("Label_Num")
      local uiSprite = Img_BgIcon:GetComponent("UISprite")
      local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
      if curCfg.precious then
        Img_Bg1:SetActive(true)
      else
        Img_Bg1:SetActive(false)
      end
      Img_Select:SetActive(false)
      Label_Day:GetComponent("UILabel"):set_text(string.format(textRes.customActivity[200], i))
      Label_Name:GetComponent("UILabel"):set_text(itemBase.name)
      GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
      Label_Num:GetComponent("UILabel"):set_text(itemInfo.num)
      if i <= curSortId then
        Img_Gray:SetActive(true)
        Img_YiLing:SetActive(true)
        Img_KeLing:SetActive(false)
        GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Gray)
        uiSprite:set_spriteName("Cell_07")
      else
        GUIUtils.SetTextureEffect(Texture_Icon, GUIUtils.Effect.Normal)
        Img_Gray:SetActive(false)
        Img_YiLing:SetActive(false)
        local quality = itemBase.namecolor
        uiSprite:set_spriteName(string.format("Cell_%02d", quality))
        if carnivalSignMgr:canGetCarnivalSignAward(i) then
          Img_KeLing:SetActive(true)
          selectedIdx = i
        else
          Img_KeLing:SetActive(false)
        end
      end
    else
      warn("!!!!!!invalid awardId:", curCfg.awardCfgId)
    end
  end
  if selectedIdx == 0 then
    selectedIdx = curSortId
  end
  if selectedIdx > 0 then
    GameUtil.AddGlobalTimer(0, true, function()
      uilist:DragToMakeVisible(selectedIdx, 100)
    end)
  end
end
def.method("number", "=>", "table").getAwardItemInfo = function(self, index)
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local curCfg = self.signCfgList[index]
  if curCfg then
    local key = string.format("%d_%d_%d", curCfg.awardCfgId, occupation.ALL, gender.ALL)
    local awardCfg = ItemUtils.GetGiftAwardCfg(key)
    if awardCfg.itemList and awardCfg.itemList[1] then
      return awardCfg.itemList[1]
    end
  end
  return nil
end
return UICarnivalSign.Commit()
