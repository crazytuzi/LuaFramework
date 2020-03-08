local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector3 = require("Types.Vector3").Vector3
local LimitTimeSignInPanel = Lplus.Extend(ECPanelBase, "LimitTimeSignInPanel")
local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
local ActivityInterface = require("Main.activity.ActivityInterface")
local LimitTimeSignInMgr = require("Main.CustomActivity.LimitTimeSignInMgr")
local limitTimeSignInMgr = LimitTimeSignInMgr.Instance()
local customActivityInterface = CustomActivityInterface.Instance()
local def = LimitTimeSignInPanel.define
local instance
def.field("string").curTabName = ""
def.field("table").signCfgList = nil
def.field("number").curSelectedIndex = 0
def.static("=>", LimitTimeSignInPanel).Instance = function()
  if instance == nil then
    instance = LimitTimeSignInPanel()
    instance:Init()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Init = function(self)
end
def.method("string").ShowPanel = function(self, tabName)
  if self:IsShow() then
    return
  end
  self.curTabName = tabName
  self:CreatePanel(RESPATH.PREFAB_PRIZE_ACTIVITY_QIANDAO, 0)
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setActivityInfo()
    self:setSignInAwardList()
    Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_TIME_SIGNIN_INFO_CHANGE, LimitTimeSignInPanel.OnSignInfoChange)
  else
    Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_TIME_SIGNIN_INFO_CHANGE, LimitTimeSignInPanel.OnSignInfoChange)
  end
end
def.static("table", "table").OnSignInfoChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setSignInAwardList()
  end
end
def.method().Hide = function(self)
  self.signCfgList = nil
  self.curSelectedIndex = 0
  self:DestroyPanel()
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
def.method().setActivityInfo = function(self)
  local activityId = customActivityInterface:GetLimitTimeSingInActivityId()
  local activityCfg = ActivityInterface.GetActivityCfgById(activityId)
  local banner = constant.CLoginAwardCfgConsts.LOGIN_SIGN_ACTIVITY_BANNER
  if banner ~= 0 then
    local Img_BgTitle = self.m_panel:FindDirect("Group_QianDao/Img_BgTitle")
    local UITexture = Img_BgTitle:GetComponent("UITexture")
    GUIUtils.FillIcon(UITexture, banner)
  end
  local Label_Time = self.m_panel:FindDirect("Group_QianDao/Img_BgTitle/Label_Time")
  Label_Time:GetComponent("UILabel"):set_text(activityCfg.timeDes)
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
  if limitTimeSignInMgr:canGetSignInAward(index) then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local level = 0
    if heroProp ~= nil then
      level = heroProp.level
    end
    local needLv = constant.CLoginAwardCfgConsts.LOGIN_SIGN_ACTIVITY_LEVEL_LIMIT
    if level >= needLv then
      local activityId = customActivityInterface:GetLimitTimeSingInActivityId()
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
def.method().setSignInAwardList = function(self)
  local signCfgs = CustomActivityInterface.GetLoginSignActivityCfg()
  self.signCfgList = signCfgs
  local ScrollView = self.m_panel:FindDirect("Group_QianDao/Group_Items/Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local uilist = Grid:GetComponent("UIList")
  uilist.itemCount = #signCfgs
  uilist:Resize()
  local selectedIdx = 0
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
      local curSortId = limitTimeSignInMgr.curSortId
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
        if limitTimeSignInMgr:canGetSignInAward(i) then
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
    selectedIdx = limitTimeSignInMgr.curSortId
  end
  if selectedIdx > 0 then
    GameUtil.AddGlobalTimer(0, true, function()
      uilist:DragToMakeVisible(selectedIdx, 100)
    end)
  end
end
return LimitTimeSignInPanel.Commit()
