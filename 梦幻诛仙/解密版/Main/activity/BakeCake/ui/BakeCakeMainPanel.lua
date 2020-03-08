local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BakeCakeMainPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = BakeCakeMainPanel.define
local BakeCakeMgr = require("Main.activity.BakeCake.BakeCakeMgr")
local BakeCakeUtils = require("Main.activity.BakeCake.BakeCakeUtils")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local ItemModule = require("Main.Item.ItemModule")
local CakeDetailInfo = require("netio.protocol.mzm.gsp.cake.CakeDetailInfo")
local GangData = require("Main.Gang.data.GangData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIFxMan = require("Fx.GUIFxMan")
local CAKE_MAX_LEVEL = 5
def.field("table").m_UIGOs = nil
def.field(BakeCakeMgr).m_bakeCakeMgr = nil
def.field("number").m_updateTimerId = 0
def.field("number").m_activityId = 0
def.field("table").m_activityInfo = nil
def.field("number").m_prepareEndTime = 0
def.field("userdata").m_viewRoleId = nil
def.field("userdata").m_myRoleId = nil
def.field("table").m_memberList = nil
local instance
def.static("=>", BakeCakeMainPanel).Instance = function()
  if instance == nil then
    instance = BakeCakeMainPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_BAKECAKE_MAIN_PANEL, 1)
end
def.override().OnCreate = function(self)
  if self:InitData() then
    self:InitUI()
    self:UpdateUI()
    self:AddUpdateTimer()
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, BakeCakeMainPanel.OnBagInfoSyncronized)
    Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_BakeCake_Cake_Info_Change, BakeCakeMainPanel.OnCakeInfoChange)
    Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_BakeCake_Round_Reset, BakeCakeMainPanel.OnRoundReset)
    Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_BakeCake_Cake_List_Change, BakeCakeMainPanel.OnCakeListChange)
  else
    warn("BakeCakeMainPanel: Init data failed, no activity information founded!")
    self:DestroyPanel()
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_BakeCake_Cake_List_Change, BakeCakeMainPanel.OnCakeListChange)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_BakeCake_Round_Reset, BakeCakeMainPanel.OnRoundReset)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_BakeCake_Cake_Info_Change, BakeCakeMainPanel.OnCakeInfoChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, BakeCakeMainPanel.OnBagInfoSyncronized)
  GUIFxMan.Instance():RemoveFx(self.m_UIGOs.bakingFXGO)
  self:RemoveUpdateTimer()
  self.m_UIGOs = nil
  self.m_activityId = 0
  self.m_activityInfo = nil
  self.m_prepareEndTime = 0
  self.m_viewRoleId = nil
  self.m_myRoleId = nil
  self.m_memberList = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id:sub(1, #"item_") == "item_" and obj.parent.name == "List" then
    local index = tonumber(id:split("_")[2])
    if index then
      self:OnClickMember(index)
    end
  elseif id == "Img_PrimaryCook" then
    if obj.parent.name == "Group_PrimaryCook" then
      self:OnClickPrimaryCookBtn()
    elseif obj.parent.name == "Group_SeniorCook" then
      self:OnClickSeniorCookBtn()
    end
  elseif id == "Btn_AddCake" then
    self:OnClickAddCakeBtn()
  elseif id == "Btn_Help" then
    self:OnClickHelpBtn()
  end
end
def.method("=>", "boolean").InitData = function(self)
  self.m_myRoleId = _G.GetMyRoleID()
  self.m_viewRoleId = self.m_myRoleId
  self.m_bakeCakeMgr = BakeCakeMgr.Instance()
  self.m_activityId = self.m_bakeCakeMgr:GetActiveActivityId()
  self.m_activityInfo = self.m_bakeCakeMgr:GetActivityInfo(self.m_activityId)
  local dataOk = self.m_activityInfo ~= nil
  if dataOk then
    local cakeInfo = self.m_bakeCakeMgr:GetRoleCakeInfo(self.m_activityId, self.m_viewRoleId)
    local cakeId = cakeInfo and cakeInfo.cakeId or 0
    if cakeId ~= 0 then
      self.m_bakeCakeMgr:LoadGangMembersCakeInfos(self.m_activityId, function()
        if not self:IsLoaded() then
          return
        end
        if self.m_UIGOs == nil then
          return
        end
        self:UpdateMemberList()
        self:UpdateViewInfos()
      end)
      self:LoadViewRoleHistroyList()
    end
    CAKE_MAX_LEVEL = self.m_bakeCakeMgr:GetMaxCakeLevel()
  end
  return dataOk
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Group_Open = self.m_UIGOs.Img_Bg0:FindDirect("Group_Open")
  self.m_UIGOs.Group_Close = self.m_UIGOs.Img_Bg0:FindDirect("Group_Close")
  self.m_UIGOs.Group_Cake = self.m_UIGOs.Group_Open:FindDirect("Group_Cake")
end
def.method().UpdateUI = function(self)
  local stage, stageBeginTime, stageEndTime = self.m_bakeCakeMgr:GetActiveActivityStage()
  if stage <= BakeCakeMgr.Stage.Prepare then
    self:UpdateCloseGroup(stage, stageEndTime)
  else
    self:UpdateOpenGroup()
  end
end
def.method("number", "number").UpdateCloseGroup = function(self, stage, stageEndTime)
  self.m_UIGOs.Group_Open:SetActive(false)
  self.m_UIGOs.Group_Close:SetActive(true)
  self.m_prepareEndTime = stageEndTime
  self:UpdatePrepareCountDown()
end
def.method().AddUpdateTimer = function(self)
  self.m_updateTimerId = GameUtil.AddGlobalTimer(1, false, function()
    if self.m_UIGOs == nil then
      return
    end
    self:OnUpdateTimer()
  end)
end
def.method().RemoveUpdateTimer = function(self)
  if self.m_updateTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_updateTimerId)
    self.m_updateTimerId = 0
  end
end
def.method().OnUpdateTimer = function(self)
  if self.m_UIGOs.Group_Open:get_activeSelf() then
    self:OnUpdateOpenGroup()
  elseif self.m_UIGOs.Group_Close:get_activeSelf() then
    self:OnUpdateCloseGroup()
  end
end
def.method().OnUpdateCloseGroup = function(self)
  self:UpdatePrepareCountDown()
end
def.method().UpdatePrepareCountDown = function(self)
  local stageEndTime = self.m_prepareEndTime
  local curTime = _G.GetServerTime()
  local leftSeconds = stageEndTime - curTime
  if leftSeconds < 0 then
    local stage = self.m_bakeCakeMgr:GetActiveActivityStage()
    if stage > BakeCakeMgr.Stage.Prepare then
      self:UpdateOpenGroup()
      return
    end
  end
  leftSeconds = math.max(0, leftSeconds)
  local timeText = _G.SeondsToTimeText(leftSeconds)
  local content = textRes.BakeCake[6]:format(timeText)
  local Img_Talk = self.m_UIGOs.Group_Close:FindDirect("Img_Talk")
  local Label = Img_Talk:FindDirect("Label")
  GUIUtils.SetText(Label, content)
end
def.method().UpdateOpenGroup = function(self)
  self.m_UIGOs.Group_Open:SetActive(true)
  self.m_UIGOs.Group_Close:SetActive(false)
  self:UpdateRoundCountDown()
  self:UpdateBakeCakeTimes()
  self:UpdateFlavoringNums()
  self:UpdateMemberList()
  self:UpdateHistoryList()
  self:UpdateViewInfos()
end
def.method().OnUpdateOpenGroup = function(self)
  self:UpdateRoundCountDown()
  self:UpdateFlavoringProgress()
end
def.method().UpdateRoundCountDown = function(self)
  local desc, timeText
  local stageInfo = self.m_bakeCakeMgr:GetActiveActivityStageInfo()
  if stageInfo.stage == BakeCakeMgr.Stage.BakeTime then
    desc = textRes.BakeCake[7]:format(stageInfo.round)
  else
    desc = textRes.BakeCake[8]
  end
  local curTime = _G.GetServerTime()
  local leftTimes = stageInfo.stageEndTime - curTime
  leftTimes = math.max(0, leftTimes)
  local t = _G.Seconds2HMSTime(leftTimes)
  local timeText = string.format("%02d:%02d", t.m, t.s)
  local Group_RestTime = self.m_UIGOs.Group_Open:FindDirect("Group_RestTime")
  local Label_Name = Group_RestTime:FindDirect("Label_Name")
  local Label_Time = Group_RestTime:FindDirect("Label_Time")
  GUIUtils.SetText(Label_Name, desc)
  GUIUtils.SetText(Label_Time, timeText)
end
def.method().UpdateBakeCakeTimes = function(self)
  self:UpdateBakeSelfsCakeTimes()
  self:UpdateBakeOthersCakeTimes()
end
def.method().UpdateBakeSelfsCakeTimes = function(self)
  local Group_MyCake = self.m_UIGOs.Group_Open:FindDirect("Group_MyCake")
  local Label_Times = Group_MyCake:FindDirect("Label_Time")
  local leftTimes = self.m_bakeCakeMgr:GetBakeSelfsCakeLeftTimes(self.m_activityId)
  GUIUtils.SetText(Label_Times, leftTimes)
end
def.method().UpdateBakeOthersCakeTimes = function(self)
  local Group_OtherCake = self.m_UIGOs.Group_Open:FindDirect("Group_OtherCake")
  local Label_Times = Group_OtherCake:FindDirect("Label_Time")
  local leftTimes = self.m_bakeCakeMgr:GetBakeOthersCakeLeftTimes(self.m_activityId)
  GUIUtils.SetText(Label_Times, leftTimes)
end
def.method().UpdateFlavoringNums = function(self)
  local Group_PrimaryCook = self.m_UIGOs.Group_Open:FindDirect("Group_PrimaryCook")
  local Group_SeniorCook = self.m_UIGOs.Group_Open:FindDirect("Group_SeniorCook")
  local Label_PrimaryNum = Group_PrimaryCook:FindDirect("Label_RestTime")
  local Label_SeniorNum = Group_SeniorCook:FindDirect("Label_RestTime")
  local bakeCakeCfg = BakeCakeUtils.GetBakeCakeActivityCfg(self.m_activityId)
  local primaryNum = ItemModule.Instance():GetItemCountById(bakeCakeCfg.giftMaterialItemId)
  local seniorNum = ItemModule.Instance():GetItemCountById(bakeCakeCfg.collectMaterialItemId)
  local numText = textRes.BakeCake[9]:format(primaryNum)
  GUIUtils.SetText(Label_PrimaryNum, numText)
  numText = textRes.BakeCake[9]:format(seniorNum)
  GUIUtils.SetText(Label_SeniorNum, numText)
end
def.method().UpdateViewInfos = function(self)
  self:UpdateCakeInfo()
  self:UpdateFlavoringProgress()
end
def.method().UpdateCakeInfo = function(self)
  local cakeInfo = self.m_bakeCakeMgr:GetRoleCakeInfo(self.m_activityId, self.m_viewRoleId)
  local cakeId = cakeInfo and cakeInfo.cakeId or 0
  if cakeId == 0 then
    self:ShowAddCakeView()
  else
    self:ShowCakeView(cakeId)
  end
end
def.method().ShowAddCakeView = function(self)
  local Group_Cake = self.m_UIGOs.Group_Open:FindDirect("Group_Cake")
  local Btn_AddCake = Group_Cake:FindDirect("Btn_AddCake")
  GUIUtils.SetActive(Btn_AddCake, true)
  for i = 0, CAKE_MAX_LEVEL do
    local levelGO = Group_Cake:FindDirect("LeveL_" .. i)
    GUIUtils.SetActive(levelGO, false)
  end
  self:SetCakeStar(0)
  local Group_CakeName = self.m_UIGOs.Group_Open:FindDirect("Group_CakeName")
  local Label_CakeName = Group_CakeName:FindDirect("Label_Name")
  GUIUtils.SetText(Label_CakeName, "")
end
def.method("number").ShowCakeView = function(self, cakeId)
  local Btn_AddCake = self.m_UIGOs.Group_Open:FindDirect("Group_Cake/Btn_AddCake")
  GUIUtils.SetActive(Btn_AddCake, false)
  local cakeCfg
  if cakeId ~= 0 then
    cakeCfg = BakeCakeUtils.GetCakeCfg(cakeId)
  end
  local Group_CakeName = self.m_UIGOs.Group_Open:FindDirect("Group_CakeName")
  local Label_CakeName = Group_CakeName:FindDirect("Label_Name")
  local cakeName = cakeCfg and cakeCfg.cakeName or "?"
  local cakeLevel = cakeCfg and cakeCfg.range or 0
  local roleName = self.m_bakeCakeMgr:GetRoleNameInActivity(self.m_activityId, self.m_viewRoleId)
  local namecolor = HtmlHelper.NameColor[cakeLevel]
  local coloredCakeName = string.format("[%s]%s[-]", namecolor or HtmlHelper.NameColor[1], cakeName)
  local fullCakeName = textRes.BakeCake[10]:format(roleName, coloredCakeName)
  GUIUtils.SetText(Label_CakeName, fullCakeName)
  self:SetCakeModel(cakeLevel)
  self:SetCakeStar(cakeLevel)
end
def.method("number").SetCakeStar = function(self, cakeLevel)
  local Group_CakeStar = self.m_UIGOs.Group_Open:FindDirect("Group_CakeStar")
  for i = 1, CAKE_MAX_LEVEL do
    local starGO = Group_CakeStar:FindDirect(string.format("Star%02d", i))
    local Img_Act = starGO:FindDirect("Img_Act")
    GUIUtils.SetActive(Img_Act, i <= cakeLevel)
  end
end
def.method("number").SetCakeModel = function(self, cakeLevel)
  local Group_Cake = self.m_UIGOs.Group_Open:FindDirect("Group_Cake")
  for i = 0, CAKE_MAX_LEVEL do
    local levelGO = Group_Cake:FindDirect("LeveL_" .. i)
    if i <= cakeLevel then
      GUIUtils.SetActive(levelGO, true)
    else
      GUIUtils.SetActive(levelGO, false)
    end
  end
end
def.method().UpdateFlavoringProgress = function(self)
  local Group_CookTime = self.m_UIGOs.Group_Open:FindDirect("Group_CookTime")
  local cakeInfo = self.m_bakeCakeMgr:GetRoleCakeInfo(self.m_activityId, self.m_viewRoleId)
  local cakeState = (not cakeInfo or not cakeInfo.state) and 0
  local baking = false
  if cakeState == CakeDetailInfo.STAGE_MAKE_ING then
    baking = true
    local Label_Time = Group_CookTime:FindDirect("Label_Time")
    local curTime = _G.GetServerTime()
    local bakeCakeCfg = BakeCakeUtils.GetBakeCakeActivityCfg(self.m_activityId)
    local leftTimes = cakeInfo.cookStartTime:ToNumber() + bakeCakeCfg.makeCakeTime - curTime
    if leftTimes < 0 then
      leftTimes = 0
      baking = false
    end
    GUIUtils.SetText(Label_Time, textRes.BakeCake[11]:format(leftTimes))
    if baking and self.m_UIGOs.bakingFXGO == nil then
      local fxId = bakeCakeCfg.barkingEffectId
      if fxId and fxId ~= 0 then
        local effectres = _G.GetEffectRes(fxId)
        if effectres then
          self.m_UIGOs.bakingFXGO = GUIFxMan.Instance():PlayAsChild(self.m_UIGOs.Group_Cake, effectres.path, -25, 100, -1, false)
        end
      end
    end
  end
  GUIUtils.SetActive(Group_CookTime, baking)
  GUIUtils.SetActive(self.m_UIGOs.bakingFXGO, baking)
end
def.method().UpdateMemberList = function(self)
  self.m_memberList = self:GetMemberList()
  local Group_PlayerList = self.m_UIGOs.Group_Open:FindDirect("Group_PlayerList")
  local List_GangMember = Group_PlayerList:FindDirect("List_GangMember")
  local Scrollview = List_GangMember:FindDirect("Scrollview")
  local List = Scrollview:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  local itemCount = #self.m_memberList
  uiList:set_itemCount(itemCount)
  uiList:Resize()
  local children = uiList:get_children()
  for i = 1, itemCount do
    local itemGO = children[i]
    local member = self.m_memberList[i]
    self:SetMemberInfo(itemGO, member)
  end
end
def.method("number").UpdateMemberInfo = function(self, index)
  local Group_PlayerList = self.m_UIGOs.Group_Open:FindDirect("Group_PlayerList")
  local List_GangMember = Group_PlayerList:FindDirect("List_GangMember")
  local Scrollview = List_GangMember:FindDirect("Scrollview")
  local List = Scrollview:FindDirect("List")
  local itemGO = List:FindDirect("item_" .. index)
  local member = self.m_memberList[index]
  if itemGO and member then
    self:SetMemberInfo(itemGO, member)
  end
end
def.method("userdata", "table").SetMemberInfo = function(self, itemGO, member)
  local Label_Name = itemGO:FindDirect("Label_Name")
  local Label_Num = itemGO:FindDirect("Label_Num")
  local Img_State = itemGO:FindDirect("Img_State")
  local Img_Bg = itemGO:FindDirect("Img_Bg")
  local Img_BgSelf = itemGO:FindDirect("Img_BgSelf")
  local Img_Select = itemGO:FindDirect("Img_Select")
  GUIUtils.SetText(Label_Name, member.name)
  local cakeInfo = self.m_bakeCakeMgr:GetRoleCakeInfo(self.m_activityId, member.roleId)
  if cakeInfo then
    local cakeLevel = member.cakeLevel or 0
    GUIUtils.SetText(Label_Num, cakeLevel)
    local cakeState = cakeInfo.state
    local baking = false
    if cakeState == CakeDetailInfo.STAGE_MAKE_ING then
      baking = true
    end
    GUIUtils.SetActive(Img_State, baking)
  else
    GUIUtils.SetText(Label_Num, "")
    GUIUtils.SetActive(Img_State, false)
  end
  local isDifference = false
  if member.roleId == self.m_myRoleId or member.cakeLevelMax then
    isDifference = true
  end
  GUIUtils.SetActive(Img_Bg, not isDifference)
  GUIUtils.SetActive(Img_BgSelf, isDifference)
  local isSelected = member.roleId == self.m_viewRoleId
  GUIUtils.SetActive(Img_Select, isSelected)
end
def.method("=>", "table").GetMemberList = function(self)
  local FriendModule = require("Main.friend.FriendModule")
  local function getCloseness(roleId)
    local closeness = 0
    local friendInfo = FriendModule.Instance():GetFriendInfo(roleId)
    if friendInfo then
      closeness = friendInfo.relationValue
    end
    return closeness
  end
  local gangCakeInfos = self.m_bakeCakeMgr:GetGangMembersCakeInfos(self.m_activityId) or {}
  local closenessMap = {}
  local memberList = {}
  for roleIdStr, cakeInfo in pairs(gangCakeInfos) do
    local roleId = Int64.ParseString(roleIdStr)
    local member = {}
    member.roleId = roleId
    member.name = self.m_bakeCakeMgr:GetRoleNameInActivity(self.m_activityId, roleId)
    member.closeness = getCloseness(roleId)
    member.hasCake = cakeInfo.cakeId ~= 0
    if member.hasCake then
      member.cakeLevel = BakeCakeUtils.GetCakeCfg(cakeInfo.cakeId).range
      member.cakeLevelMax = member.cakeLevel == CAKE_MAX_LEVEL
    end
    table.insert(memberList, member)
  end
  local myRoleId = _G.GetMyRoleID()
  table.sort(memberList, function(lhs, rhs)
    local lclossness = lhs.closeness
    local rclossness = rhs.closeness
    if lhs.roleId == myRoleId then
      return true
    elseif rhs.roleId == myRoleId then
      return false
    elseif lhs.hasCake and not rhs.hasCake then
      return true
    elseif not lhs.hasCake and rhs.hasCake then
      return false
    elseif not lhs.cakeLevelMax and rhs.cakeLevelMax then
      return true
    elseif lhs.cakeLevelMax and not rhs.cakeLevelMax then
      return false
    elseif lclossness ~= rclossness then
      return lclossness > rclossness
    else
      return lhs.roleId < rhs.roleId
    end
  end)
  return memberList
end
def.method().UpdateHistoryList = function(self)
  local Group_Log = self.m_UIGOs.Group_Open:FindDirect("Group_Log")
  local Log = Group_Log:FindDirect("Log")
  local Scrollview = Log:FindDirect("Scrollview")
  local List = Scrollview:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  local logList = self:GetLogList()
  local itemCount = #logList > 0 and 1 or 0
  uiList:set_itemCount(itemCount)
  uiList:Resize()
  if itemCount > 0 then
    local children = uiList:get_children()
    local contentTable = {}
    for i, logInfo in ipairs(logList) do
      table.insert(contentTable, logInfo.content)
    end
    local logInfo = {}
    logInfo.content = table.concat(contentTable, [[


]])
    local itemGO = children[1]
    self:SetLogInfo(itemGO, logInfo)
  end
end
def.method("userdata", "table").SetLogInfo = function(self, itemGO, logInfo)
  local Label_Content = itemGO:FindDirect("Label_Content")
  GUIUtils.SetText(Label_Content, logInfo.content)
end
def.method("=>", "table").GetLogList = function(self)
  local historyList = self.m_bakeCakeMgr:GetGangMemberCakeHistoryList(self.m_activityId, self.m_viewRoleId) or {}
  local logList = {}
  for index, history in ipairs(historyList) do
    local logInfo = {}
    logInfo.content = self.m_bakeCakeMgr:ConvertHistoryToLogText(history)
    table.insert(logList, logInfo)
  end
  return logList
end
def.method("number").OnClickMember = function(self, index)
  local lastIndex
  for i, member in ipairs(self.m_memberList) do
    if member.roleId == self.m_viewRoleId then
      lastIndex = i
      break
    end
  end
  local member = self.m_memberList[index]
  self:SetViewRole(member.roleId)
  self:UpdateViewInfos()
  self:UpdateMemberInfo(index)
  if lastIndex then
    self:UpdateMemberInfo(lastIndex)
  end
end
def.method("userdata").SetViewRole = function(self, roleId)
  self.m_viewRoleId = roleId
  self:LoadViewRoleHistroyList()
end
def.method().LoadViewRoleHistroyList = function(self)
  self.m_bakeCakeMgr:LoadGangMemberCakeHistoryList(self.m_activityId, self.m_viewRoleId, function(activityId, retRoleId)
    if not self:IsLoaded() then
      return
    end
    if self.m_UIGOs == nil then
      return
    end
    if activityId ~= self.m_activityId or retRoleId ~= self.m_viewRoleId then
      return
    end
    self:UpdateHistoryList()
  end)
end
def.method().OnClickPrimaryCookBtn = function(self)
  if self:CheckBakeCakeConditions() == false then
    return
  end
  local bakeCakeCfg = BakeCakeUtils.GetBakeCakeActivityCfg(self.m_activityId)
  local itemId = bakeCakeCfg.giftMaterialItemId
  local primaryNum = ItemModule.Instance():GetItemCountById(itemId)
  if primaryNum == 0 then
    local itemBase = ItemUtils.GetItemBase(itemId)
    Toast(textRes.BakeCake[12]:format(itemBase.name))
    return
  end
  self.m_bakeCakeMgr:ReqAddFavoring(self.m_activityId, self.m_viewRoleId, itemId)
end
def.method().OnClickSeniorCookBtn = function(self)
  if self:CheckBakeCakeConditions() == false then
    return
  end
  local bakeCakeCfg = BakeCakeUtils.GetBakeCakeActivityCfg(self.m_activityId)
  local itemId = bakeCakeCfg.collectMaterialItemId
  local primaryNum = ItemModule.Instance():GetItemCountById(itemId)
  if primaryNum == 0 then
    local itemBase = ItemUtils.GetItemBase(itemId)
    Toast(textRes.BakeCake[12]:format(itemBase.name))
    return
  end
  self.m_bakeCakeMgr:ReqAddFavoring(self.m_activityId, self.m_viewRoleId, itemId)
end
def.method("=>", "boolean").CheckBakeCakeConditions = function(self)
  local stage = self.m_bakeCakeMgr:GetActiveActivityStage()
  if stage == BakeCakeMgr.Stage.End then
    Toast(textRes.BakeCake[24])
    return false
  end
  local stage = self.m_bakeCakeMgr:GetActiveActivityStage()
  if stage == BakeCakeMgr.Stage.BreakTime then
    Toast(textRes.BakeCake[23])
    return false
  end
  local cakeInfo = self.m_bakeCakeMgr:GetRoleCakeInfo(self.m_activityId, self.m_viewRoleId)
  local cakeId = cakeInfo and cakeInfo.cakeId or 0
  if cakeId == 0 then
    if self:IsMyCake() then
      Toast(textRes.BakeCake[27])
    else
      Toast(textRes.BakeCake[25])
    end
    return false
  end
  local cakeCfg = BakeCakeUtils.GetCakeCfg(cakeId)
  if cakeCfg == nil then
    return false
  end
  if cakeCfg.range >= CAKE_MAX_LEVEL then
    Toast(textRes.BakeCake[15])
    return false
  end
  if self:IsMyCake() then
    local leftTimes = self.m_bakeCakeMgr:GetBakeSelfsCakeLeftTimes(self.m_activityId)
    if leftTimes <= 0 then
      Toast(textRes.BakeCake[13])
      return false
    end
  else
    local leftTimes = self.m_bakeCakeMgr:GetBakeOthersCakeLeftTimes(self.m_activityId)
    if leftTimes <= 0 then
      Toast(textRes.BakeCake[14])
      return false
    end
  end
  if cakeInfo.state == CakeDetailInfo.STAGE_MAKE_ING then
    local bakeCakeCfg = BakeCakeUtils.GetBakeCakeActivityCfg(self.m_activityId)
    local curTime = _G.GetServerTime()
    local leftTimes = cakeInfo.cookStartTime:ToNumber() + bakeCakeCfg.makeCakeTime - curTime
    if leftTimes > 0 then
      Toast(textRes.BakeCake[34])
      return false
    end
  end
  return true
end
def.method().OnClickAddCakeBtn = function(self)
  if not self:IsMyCake() then
    Toast(textRes.BakeCake[25])
    return
  end
  local stage = self.m_bakeCakeMgr:GetActiveActivityStage()
  if stage == BakeCakeMgr.Stage.End then
    Toast(textRes.BakeCake[24])
    return
  end
  local stage = self.m_bakeCakeMgr:GetActiveActivityStage()
  if stage == BakeCakeMgr.Stage.BreakTime then
    Toast(textRes.BakeCake[23])
    return
  end
  self.m_bakeCakeMgr:ReqAddCake(self.m_activityId)
end
def.method().OnClickHelpBtn = function(self)
  local bakeCakeCfg = BakeCakeUtils.GetBakeCakeActivityCfg(self.m_activityId)
  local tipsId = bakeCakeCfg.activityTipId
  local TipsHelper = require("Main.Common.TipsHelper")
  TipsHelper.ShowHoverTip(tipsId, 0, 0)
end
def.method("=>", "boolean").IsMyCake = function(self)
  return self.m_viewRoleId == self.m_myRoleId
end
def.method().PlayAddCakeFX = function(self)
  local bakeCakeCfg = BakeCakeUtils.GetBakeCakeActivityCfg(self.m_activityId)
  if bakeCakeCfg == nil then
    return
  end
  self:PlayFxAsChild(bakeCakeCfg.addCakeEffectId, self.m_UIGOs.Group_Cake)
end
def.method().PlayCakeUpgradeFx = function(self)
  local bakeCakeCfg = BakeCakeUtils.GetBakeCakeActivityCfg(self.m_activityId)
  if bakeCakeCfg == nil then
    return
  end
  self:PlayFxAsChild(bakeCakeCfg.cakeRiseEffectId, self.m_UIGOs.Group_Cake)
end
def.method().PlayCakeDowngradeFx = function(self)
  local bakeCakeCfg = BakeCakeUtils.GetBakeCakeActivityCfg(self.m_activityId)
  if bakeCakeCfg == nil then
    return
  end
  self:PlayFxAsChild(bakeCakeCfg.cakeDropEffectId, self.m_UIGOs.Group_Cake)
end
def.method("number", "userdata").PlayFxAsChild = function(self, fxId, root)
  if fxId and fxId ~= 0 then
    local effectres = _G.GetEffectRes(fxId)
    if effectres then
      GUIFxMan.Instance():PlayAsChild(root, effectres.path, 0, 0, -1, false)
    end
  end
end
def.method().ResetHistoryList = function(self)
  local Group_Log = self.m_UIGOs.Group_Open:FindDirect("Group_Log")
  local Log = Group_Log:FindDirect("Log")
  local Scrollview = Log:FindDirect("Scrollview")
  local uiScrollView = Scrollview:GetComponent("UIScrollView")
  uiScrollView:ResetPosition()
  self:UpdateHistoryList()
end
def.method().ResetMemberList = function(self)
  local Group_PlayerList = self.m_UIGOs.Group_Open:FindDirect("Group_PlayerList")
  local List_GangMember = Group_PlayerList:FindDirect("List_GangMember")
  local Scrollview = List_GangMember:FindDirect("Scrollview")
  local uiScrollView = Scrollview:GetComponent("UIScrollView")
  uiScrollView:ResetPosition()
  self:UpdateMemberList()
end
def.method().ResetViewInfos = function(self)
  self.m_viewRoleId = self.m_myRoleId
  self:UpdateViewInfos()
end
def.static("table", "table").OnBagInfoSyncronized = function(params, context)
  instance:UpdateFlavoringNums()
end
def.static("table", "table").OnCakeInfoChange = function(params, context)
  if params.activityId ~= instance.m_activityId then
    return
  end
  instance:UpdateMemberList()
  if params.cakeOwnerId == instance.m_viewRoleId then
    instance:UpdateViewInfos()
    instance:UpdateHistoryList()
    if params.isAdd then
      instance:PlayAddCakeFX()
    elseif params.orgRank < params.newRank then
      instance:PlayCakeUpgradeFx()
    elseif params.orgRank > params.newRank then
      instance:PlayCakeDowngradeFx()
    end
  end
  if params.lastOperatorId == _G.GetMyRoleID() then
    instance:UpdateBakeCakeTimes()
  end
end
def.static("table", "table").OnRoundReset = function(params, context)
  instance:UpdateBakeCakeTimes()
  instance:ResetHistoryList()
  instance:ResetMemberList()
  instance:ResetViewInfos()
end
def.static("table", "table").OnCakeListChange = function(params, context)
  instance:UpdateMemberList()
end
return BakeCakeMainPanel.Commit()
