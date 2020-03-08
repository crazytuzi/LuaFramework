local Lplus = require("Lplus")
local PanelBase = require("GUI.ECPanelBase")
local UIPlantTree = Lplus.Extend(PanelBase, "UIPlantTree")
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local ActivityInterface = require("Main.activity.ActivityInterface")
local MoneyType = require("consts.mzm.gsp.planttree.confbean.PlantTreeMoneyType")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local def = UIPlantTree.define
local instance
def.field("boolean")._bFeatureOpen = false
def.field("table")._uiObjs = nil
def.field("table")._arrFriendList = nil
def.field("table")._plantTreeInfos = nil
def.field("table")._roleInfo = nil
def.field("number")._selectRoleIdx = 1
def.field("number")._activityId = -1
def.field("number")._numSections = 5
def.field("boolean")._bPanelShow = false
def.field("table")._activityCfg = nil
def.field("table")._sectionCfg = nil
def.field("table")._specialStateCfg = nil
def.field("number")._dstTotalPts = 1
def.field("table")._plantStageInfo = nil
def.field("table")._curAddPtInfo = nil
def.field("table")._plantLoginInfo = nil
def.field("table")._timeLogin = nil
def.const("number").KILL_BUG = 2
def.const("number").WATER = 1
def.static("=>", UIPlantTree).Instance = function()
  if instance == nil then
    instance = UIPlantTree()
  end
  return instance
end
def.method().InitSelfInfo = function(self)
  local myselfInfo = require("Main.Hero.HeroModule").Instance():GetHeroProp()
  self._roleInfo = {
    name = myselfInfo.name,
    Id = myselfInfo.id
  }
  self._plantTreeInfos = {}
  local plantInfo = {}
  plantInfo.addPtCount = 0
  self._plantTreeInfos[self._roleInfo.Id:tostring()] = plantInfo
end
def.method().InitFriendListInfo = function(self)
  local objFriendData = require("Main.friend.FriendData").Instance()
  local friendList = objFriendData:GetFriendList()
  self._arrFriendList = {}
  table.insert(self._arrFriendList, self._roleInfo)
  if friendList == nil then
    return
  end
  for i = 1, #friendList do
    local friendInfo = friendList[i]
    table.insert(self._arrFriendList, {
      name = friendInfo.roleName,
      Id = friendInfo.roleId
    })
    local roleId = friendInfo.roleId:tostring()
    self._plantTreeInfos[roleId] = {}
  end
end
def.method().InitGameCfg = function(self)
  self._sectionCfg = self._activityCfg.section_infos
  local secInfos = self._sectionCfg
  local actDstPt = 0
  for i = 1, #secInfos do
    actDstPt = actDstPt + secInfos[i].section_total_point
  end
  self._dstTotalPts = actDstPt
  self._specialStateCfg = self._activityCfg.special_state_infos
  self:InitPlantStageInfo()
end
def.method().InitPlantStageInfo = function(self)
  if self._plantStageInfo ~= nil then
    return
  end
  self._plantStageInfo = {}
  if #self._sectionCfg < 1 then
    warn("section_infos is nil")
    return
  end
  local iStage = 1
  self._plantStageInfo[1] = iStage
  for i = 2, #self._sectionCfg do
    if self._sectionCfg[i] == self._sectionCfg[i - 1] then
      self._plantStageInfo[i] = iStage
    else
      iStage = iStage + 1
      self._plantStageInfo[i] = iStage
    end
  end
  self._plantStageInfo[#self._sectionCfg + 1] = iStage + 1
end
def.static("table").OnSGetRelatedRolePlantTreeSpecialStateSuccess = function(p)
  local self = UIPlantTree.Instance()
  self:InitFriendsSpecStatInfo(p)
end
def.static("table").OnSGetRelatedRolePlantTreeSpecialStateFail = function(p)
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>DB_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  end
end
def.method("table").InitFriendsSpecStatInfo = function(self, p)
  local tblSpecInfo = p.special_states
  for roleId, specIdx in pairs(tblSpecInfo) do
    local plantInfo = self._plantTreeInfos[roleId:tostring()]
    if plantInfo.special_state_indexes == nil then
      plantInfo.special_state_indexes = {}
    end
    warn("roleId " .. roleId:tostring() .. " spec idx" .. type(specIdx))
    plantInfo.special_state_indexes[specIdx] = specIdx
  end
  self:UpdateUIFriendList()
end
def.method().ShowPanel = function(self)
  if not self:IsFeatureOpen() then
    Toast(textRes.PlantTree[20])
    return
  end
  if self._bPanelShow then
    return
  end
  self._activityCfg = UIPlantTree.GetActivityCfgById(self._activityId)
  self:InitGameCfg()
  self:InitSelfInfo()
  self:InitFriendListInfo()
  self:CreatePanel(RESPATH.PREFAB_PLANT_TREE, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:Init()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, UIPlantTree.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, UIPlantTree.OnActivityStart)
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:SendReqForGetPlantTreeDetailInfo(self._roleInfo.Id)
    self:SendReqForRelatedRoleSpecialStateInfo()
    self:OnSynLoginPlantInfo()
  end
end
def.method().SendReqForRelatedRoleSpecialStateInfo = function(self)
  local p = require("netio.protocol.mzm.gsp.planttree.CGetRelatedRolePlantTreeSpecialStateReq").new(self._activityId)
  gmodule.network.sendProtocol(p)
end
def.method().Init = function(self)
  local imgBg = self.m_panel:FindDirect("Img_Bg0")
  local uiFrindListGO = imgBg:FindDirect("FriendList_Group/Scrollview_Group/Scrollview_FriendsList/List_FriendList")
  local labelCurIntegralVal = imgBg:FindDirect("Group_Grow/Label_GrowNum")
  local slider = imgBg:FindDirect("Group_Grow/Group_Slider")
  local secPtGroupRoot = slider:FindDirect("Group_Items")
  local lablLog = imgBg:FindDirect("Group_Note/Scrollview_Note/Drag_Tips")
  local texTreeModel = imgBg:FindDirect("Texture_Tree")
  local btnReward = imgBg:FindDirect("Group_Btn/Btn_Reward")
  local btnFertilize = imgBg:FindDirect("Group_Btn/Btn_Feed")
  local btn_Water = imgBg:FindDirect("Group_Btn/Btn_Water")
  local btn_KillWorm = imgBg:FindDirect("Group_Btn/Btn_KillWorm")
  self._uiObjs = {}
  self._uiObjs.uifriendList = uiFrindListGO
  self._uiObjs.texTreeModel = texTreeModel
  self._uiObjs.secPtGroupRoot = secPtGroupRoot
  self._uiObjs.secPtGroup = nil
  self._uiObjs.labelCurIntegralVal = labelCurIntegralVal
  self._uiObjs.lablLog = lablLog
  self._uiObjs.btnReward = btnReward
  self._uiObjs.btnFertilize = btnFertilize
  self._uiObjs.slider = slider
  self._uiObjs.btn_Water = btn_Water
  self._uiObjs.btn_KillWorm = btn_KillWorm
  local secPtGroup = GUIUtils.InitUIList(self._uiObjs.secPtGroupRoot, self._activityCfg.section_num)
  self._uiObjs.secPtGroup = secPtGroup
  self:InitUIFriendLits()
  self:UpdateUI()
  self._bPanelShow = true
end
def.override().OnDestroy = function(self)
  self:ReleaseMem()
  self._bPanelShow = false
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, UIPlantTree.OnActivityStart)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, UIPlantTree.OnActivityStart)
end
def.method().ReleaseMem = function(self)
  self._roleInfo = nil
  self._curAddPtInfo = nil
  self._arrFriendList = nil
  self._plantTreeInfos = nil
  self._uiObjs = nil
  self._specialStateCfg = nil
  self._sectionCfg = nil
  self._plantStageInfo = nil
  self._selectRoleIdx = 1
  if self._activityCfg ~= nil then
    self._activityCfg = nil
  end
end
def.method().HidePanel = function(self)
  if self._bPanelShow then
    self:DestroyPanel()
  end
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  return require("Main.PlantTree.PlantTreeModule").PlantTreeFeatureOpen()
end
def.static("=>", "boolean").IsInDate = function()
  local self = UIPlantTree.Instance()
  local activityCfg = ActivityInterface.GetActivityCfgById(self._activityId)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local timeLimitCfg = TimeCfgUtils.GetTimeLimitCommonCfg(activityCfg.activityLimitTimeid)
  local bIsInDate = false
  local nowSec = _G.GetServerTime()
  if timeLimitCfg ~= nil then
    local beginTimeSec = TimeCfgUtils.GetTimeSec(timeLimitCfg.startYear, timeLimitCfg.startMonth, timeLimitCfg.startDay, timeLimitCfg.startHour, timeLimitCfg.startMinute, 0)
    local endTimeSec = TimeCfgUtils.GetTimeSec(timeLimitCfg.endYear, timeLimitCfg.endMonth, timeLimitCfg.endDay, timeLimitCfg.endHour, timeLimitCfg.endMinute, 0)
    bIsInDate = nowSec >= beginTimeSec and nowSec <= endTimeSec
  end
  return bIsInDate
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn(id)
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Img_FriendBg" then
    local itemObj, idx = ScrollList_getItem(clickObj)
    if idx > #self._arrFriendList then
      warn(">>>>Click friend index out of range friendlist size<<<<")
      return
    end
    if idx == 1 then
      self:OnSelectedMySelf()
    else
      self:OnSelectedFriend(idx)
    end
  elseif id == "Btn_Help" then
    local tipsId = self._activityCfg.tipsId
    local content = require("Main.Common.TipsHelper").GetHoverTip(tipsId)
    require("GUI.CommonUITipsDlg").ShowCommonTip(content, {x = 0, y = 0})
  elseif id == "Btn_Water" then
    self:OnBtnWateringClick()
  elseif id == "Btn_KillWorm" then
    self:OnBtnDisinsectionClick()
  elseif id == "Btn_Feed" then
    self:OnBtnFertilizationClick()
  elseif id == "Btn_Reward" then
    self:OnBtnAcceptAwardClick()
  elseif string.find(id, "Img_Reward_", 1) ~= nil then
    local idx = tonumber(string.sub(id, string.find(id, "%d")))
    if idx > self._activityCfg.section_num then
      warn(">>>>Click get award out of range section_num<<<<")
      return
    end
    self:OnBtnGetSectionAwardClick(idx)
  end
end
def.method("table").FriendListChange = function(self, newFriends)
  local newFrnd = newFriends.friendInfo
  table.insert(self._arrFriendList, {
    Id = newFrnd.roleId,
    name = newFrnd.roleName
  })
  self._plantTreeInfos[newFrnd.roleId:tostring()] = {}
  ScrollList_setCount(self._uiObjs.uiScrollList, #self._arrFriendList)
  self._selectRoleIdx = 1
  local scrollList = self._uiObjs.uiScrollList
  ScrollList_scrollToBegin(scrollList)
  self:OnSelectedFriend(self._selectRoleIdx)
  self:SendReqForGetPlantTreeDetailInfo(newFrnd.roleId)
end
def.method().UpdateUI = function(self)
  if not self._bPanelShow then
    return
  end
  self:UpdateUIFriendList()
  self:UpdateAllProgressUI()
  self:UpdateTreeModel()
  self:UpdateLogUI()
  self:UpdateBtns()
end
def.method().InitUIFriendLits = function(self)
  local friendsCount = #self._arrFriendList
  local listObj = self._uiObjs.uifriendList
  local uiScrollList = listObj:GetComponent("UIScrollList")
  if uiScrollList then
    self._uiObjs.uiScrollList = uiScrollList
    local GUIScrollList = listObj:GetComponent("GUIScrollList")
    if not GUIScrollList then
      listObj:AddComponent("GUIScrollList")
    end
    ScrollList_setUpdateFunc(uiScrollList, function(item, i)
      local roleInfo = self._arrFriendList[i]
      self:SetFriendItemUI(item, roleInfo, i)
    end)
    ScrollList_setCount(uiScrollList, friendsCount)
    self.m_msgHandler:Touch(listObj)
    return
  end
end
def.method().UpdateUIFriendList = function(self)
  ScrollList_forceUpdate(self._uiObjs.uiScrollList)
end
def.method("userdata", "table", "number").SetFriendItemUI = function(self, itemGO, roleInfo, idx)
  if roleInfo == nil then
    return
  end
  local labelName = itemGO:FindDirect("Label_FriendName")
  local iconWater = itemGO:FindDirect("Icon_FriendWater")
  local iconKillBug = itemGO:FindDirect("Icon_FriendKill")
  GUIUtils.SetActive(iconWater, false)
  GUIUtils.SetActive(iconKillBug, false)
  local roleId = roleInfo.Id:tostring()
  local rolePlantInfo = self._plantTreeInfos[roleId]
  local tblSpecStatIdxs = rolePlantInfo.special_state_indexes
  if tblSpecStatIdxs == nil then
    GUIUtils.SetActive(iconWater, false)
    GUIUtils.SetActive(iconKillBug, false)
  else
    for k, v in pairs(tblSpecStatIdxs) do
      if k == UIPlantTree.WATER then
        GUIUtils.SetActive(iconWater, true)
      elseif k == UIPlantTree.KILL_BUG then
        GUIUtils.SetActive(iconKillBug, true)
      end
    end
  end
  GUIUtils.SetText(labelName, roleInfo.name)
end
def.method().UpdateAllProgressUI = function(self)
  local roleInfo = self._arrFriendList[self._selectRoleIdx]
  local roleId = roleInfo.Id:tostring()
  local plantInfo = self._plantTreeInfos[roleId]
  if plantInfo.current_section_id == nil then
    self:UpdateProgressUI(0, self._dstTotalPts, self._activityCfg.section_num)
  else
    self:UpdateProgressUI(plantInfo.total_points, self._dstTotalPts, self._activityCfg.section_num)
  end
  local tblSpecStatIdxs = plantInfo.special_state_indexes
  local panelBasePath = "panel_planttree/Img_Bg0/Group_Btn/"
  if tblSpecStatIdxs ~= nil then
    for _, v in pairs(tblSpecStatIdxs) do
      if v == UIPlantTree.WATER then
        GUIUtils.SetLightEffect(self._uiObjs.btn_Water, 2)
        GUIUtils.SetLightEffect(self._uiObjs.btn_KillWorm, 0)
      elseif v == UIPlantTree.KILL_BUG then
        GUIUtils.SetLightEffect(self._uiObjs.btn_KillWorm, 2)
        GUIUtils.SetLightEffect(self._uiObjs.btn_Water, 0)
      end
    end
  else
    GUIUtils.SetLightEffect(self._uiObjs.btn_Water, 0)
    GUIUtils.SetLightEffect(self._uiObjs.btn_KillWorm, 0)
  end
  if self._selectRoleIdx == 1 then
    self:UpdateSectionPointBtns()
  end
end
def.method().UpdateTreeModel = function(self)
  local roleInfo = self._arrFriendList[self._selectRoleIdx]
  local plantInfo = self._plantTreeInfos[roleInfo.Id:tostring()]
  local texId = -1
  local texTreeModel = self._uiObjs.texTreeModel
  if plantInfo.current_section_id == nil then
    texId = self._activityCfg.activity_complete_modle_id
    GUIUtils.SetTexture(texTreeModel, 0)
    return
  end
  local bIsTreeMature = plantInfo.total_points >= self._dstTotalPts
  local secIdx = plantInfo.current_section_id
  if bIsTreeMature then
    secIdx = #self._plantStageInfo
  end
  if plantInfo.special_state_indexes ~= nil then
    for k, _ in pairs(plantInfo.special_state_indexes) do
      if k ~= 0 then
        local img_ids = self._specialStateCfg[k].img_ids
        texId = img_ids[secIdx]
      end
    end
  end
  if texId == -1 then
    if bIsTreeMature then
      texId = self._activityCfg.activity_complete_modle_id
    else
      local sectInfo = self._sectionCfg[secIdx]
      texId = sectInfo.section_modle_id
    end
  end
  warn(">>>>texId = " .. texId)
  GUIUtils.FillIcon(texTreeModel:GetComponent("UITexture"), texId)
end
def.method().UpdateLogUI = function(self)
  local roleInfo = self._arrFriendList[self._selectRoleIdx]
  local plantInfo = self._plantTreeInfos[roleInfo.Id:tostring()]
  local lablLog = self._uiObjs.lablLog
  local logs = plantInfo.log
  local strLog = ""
  if logs == nil or #logs == 0 then
    GUIUtils.SetText(lablLog, strLog)
    return
  end
  local logsCount = #logs
  for i = logsCount, 1, -1 do
    strLog = strLog .. logs[i] .. "\n"
  end
  GUIUtils.SetText(lablLog, strLog)
end
def.method().UpdateBtns = function(self)
  if self._selectRoleIdx ~= 1 then
    return
  end
  local plantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  if plantInfo.total_points == nil then
    warn("Not Get self plant tree info data ..")
    return
  end
  local bIsTreeMature = plantInfo.total_points >= self._dstTotalPts
  if plantInfo.bHasGetActAward == nil then
    plantInfo.bHasGetActAward = true
  end
  local bCanToGetAward = bIsTreeMature and not plantInfo.bHasGetActAward
  warn("bIsTreeMature = " .. tostring(bIsTreeMature) .. " bHasGetActAward =" .. tostring(plantInfo.bHasGetActAward))
  if bCanToGetAward then
    GUIUtils.SetLightEffect(self._uiObjs.btnReward, 2)
  else
    GUIUtils.SetLightEffect(self._uiObjs.btnReward, 0)
  end
end
def.method().UpdateSectionPointBtns = function(self)
  local secPtGroup = self._uiObjs.secPtGroup
  if self._selectRoleIdx ~= 1 then
    return
  end
  local myRoleId = self._roleInfo.Id:tostring()
  local plantInfo = self._plantTreeInfos[myRoleId]
  local curSecPtNum = 0
  for i = 1, #secPtGroup do
    local uiSecItem = secPtGroup[i]
    local imgFinish = uiSecItem:FindDirect(("Img_Finished_%d"):format(i))
    local imgReward = uiSecItem:FindDirect(("Img_Reward_%d"):format(i))
    local labeNum = uiSecItem:FindDirect(("item_Num_%d"):format(i))
    curSecPtNum = curSecPtNum + self._sectionCfg[i].section_total_point
    GUIUtils.SetText(labeNum, curSecPtNum)
    if plantInfo.bArrGotSecAward == nil then
      self:OnSynLoginPlantInfo()
    end
    local bArrGotSecAward = plantInfo.bArrGotSecAward
    if bArrGotSecAward == nil then
      GUIUtils.SetLightEffect(imgReward, 0)
      imgReward:SetActive(true)
      imgFinish:SetActive(false)
    elseif bArrGotSecAward ~= nil and bArrGotSecAward[i] then
      imgFinish:SetActive(true)
      imgReward:SetActive(false)
      GUIUtils.SetLightEffect(imgReward, 0)
    else
      imgReward:SetActive(true)
      imgFinish:SetActive(false)
      if plantInfo.total_points ~= nil and curSecPtNum <= plantInfo.total_points then
        GUIUtils.SetLightEffect(imgReward, 2)
      end
    end
  end
  if plantInfo.total_points == nil then
    self:SendReqForGetPlantTreeDetailInfo(self._roleInfo.Id)
  end
end
def.method("=>", "boolean").selectedRoleIsMySelf = function(self)
  local ret = self._selectRoleIdx == 1
  local secPtGroupRoot = self._uiObjs.secPtGroupRoot
  local btnReward = self._uiObjs.btnReward
  local btnFertilize = self._uiObjs.btnFertilize
  GUIUtils.SetActive(secPtGroupRoot, ret)
  GUIUtils.SetActive(btnReward, ret)
  GUIUtils.SetActive(btnFertilize, ret)
  return ret
end
def.method("number", "number", "number").UpdateProgressUI = function(self, curPt, totalPt, numSegment)
  local slider = self._uiObjs.slider:GetComponent("UISlider")
  local progressVal = 0
  if totalPt ~= 0 then
    progressVal = curPt / totalPt
  end
  slider:set_sliderValue(progressVal)
  GUIUtils.SetText(self._uiObjs.labelCurIntegralVal, curPt)
end
def.method("table", "table", "userdata", "boolean").ParseLog = function(self, plantInfo, rcvLogs, roleId, bEmptyLog)
  if bEmptyLog then
    plantInfo.log = {}
    local recordCount = #rcvLogs
    if recordCount > constant.CPlantTreeConsts.MAX_LOG_NUM then
      recordCount = constant.CPlantTreeConsts.MAX_LOG_NUM
    end
    for i = 1, recordCount do
      local str = self:_parseLog(rcvLogs[i], roleId)
      if str ~= nil and str ~= "" then
        table.insert(plantInfo.log, str)
      end
    end
    return
  end
  plantInfo.log = plantInfo.log or {}
  if #plantInfo.log >= constant.CPlantTreeConsts.MAX_LOG_NUM then
    for i = 1, #rcvLogs do
      table.remove(plantInfo.log, 1)
      local str = self:_parseLog(rcvLogs[i], roleId)
      table.insert(plantInfo.log, str)
    end
  else
    for i = 1, #rcvLogs do
      local str = self:_parseLog(rcvLogs[i], roleId)
      table.insert(plantInfo.log, str)
    end
  end
end
def.method("table", "userdata", "=>", "string")._parseLog = function(self, record, roleId)
  local PlantTreelog = require("netio.protocol.mzm.gsp.planttree.PlantTreelog")
  local log_type = record.log_type
  local secTime = record.timestamp
  local arrLogRecord = record.extradatas
  if arrLogRecord == nil or #arrLogRecord == 0 then
    warn("No log data ...")
    return ""
  end
  local retStr = ""
  local secId = tonumber(arrLogRecord[1])
  local section_infos = self._sectionCfg
  local addPtOperaCfg = self._activityCfg.add_point_operations
  local specStatCfg = self._specialStateCfg
  local secName = ""
  local nxtSecName = ""
  if secId > self._activityCfg.section_num then
    nxtSecName = self._activityCfg.activity_complete_name
    secName = nxtSecName
  else
    secName = section_infos[secId].section_name
    if secId == self._activityCfg.section_num then
      nxtSecName = self._activityCfg.activity_complete_name
    else
      nxtSecName = section_infos[secId + 1].section_name
    end
  end
  if log_type == PlantTreelog.TYPE_ONLINR_REWARD_POINT then
    local pt = tonumber(arrLogRecord[2])
    retStr = string.format(textRes.PlantTree[25], secName, pt)
  elseif log_type == PlantTreelog.TYPE_ADD_POINT_OPERATION then
    local operaId = tonumber(arrLogRecord[2])
    local operaName = addPtOperaCfg[1].desc
    local pt = arrLogRecord[3]
    retStr = string.format(textRes.PlantTree[27], operaName, pt)
  elseif log_type == PlantTreelog.TYPE_REMOVE_SPECIAL_STATE then
    local roleInLog = Int64.new(arrLogRecord[2])
    local roleName = arrLogRecord[3]
    local specIdx = tonumber(arrLogRecord[4])
    local specIdxName = textRes.PlantTree[12]
    if specIdx == 2 then
      specIdxName = textRes.PlantTree[13]
    end
    if self._roleInfo.Id == roleInLog then
      roleName = textRes.PlantTree[28]
    end
    retStr = string.format(textRes.PlantTree[23], roleName, secName, specIdxName)
  elseif log_type == PlantTreelog.TYPE_SECTION_COMPLETE then
    if nxtSecName == secName then
      retStr = string.format(textRes.PlantTree[32], secName)
    else
      retStr = string.format(textRes.PlantTree[26], secName, nxtSecName)
    end
  elseif log_type == PlantTreelog.TYPE_ADD_SPECIAL_STATE then
    local specIdx = tonumber(arrLogRecord[2])
    if specIdx == 1 then
      retStr = string.format(textRes.PlantTree[29], secName)
    elseif specIdx == 2 then
      retStr = string.format(textRes.PlantTree[24], secName)
    end
  end
  retStr = self:_parseTime(secTime) .. retStr
  return retStr
end
def.method("number", "=>", "string")._parseTime = function(self, sec)
  local date = AbsoluteTimer.GetServerTimeTable(sec)
  return string.format(textRes.PlantTree[33], date.hour, date.min)
end
def.method().OnSelectedMySelf = function(self)
  if self._selectRoleIdx == 1 then
    return
  end
  self._selectRoleIdx = 1
  self:selectedRoleIsMySelf()
  local roleInfo = self._arrFriendList[1]
  local plantInfo = self._plantTreeInfos[roleInfo.Id:tostring()]
  if plantInfo.log == nil or plantInfo.current_section_id == nil then
    self:SendReqForGetPlantTreeDetailInfo(roleInfo.Id)
  end
  self:UpdateUI()
end
def.method("number").OnSelectedFriend = function(self, idx)
  if self._selectRoleIdx == idx then
    return
  end
  self._selectRoleIdx = idx
  self:selectedRoleIsMySelf()
  self:UpdateUI()
  local roleInfo = self._arrFriendList[idx]
  local plantInfo = self._plantTreeInfos[roleInfo.Id:tostring()]
  if plantInfo.current_section_id == nil then
    self:SendReqForGetPlantTreeDetailInfo(roleInfo.Id)
    return
  end
end
def.method("userdata").SendReqForGetPlantTreeDetailInfo = function(self, roleId)
  warn("Send  GetPlantTreeDetailInfo req roleId=" .. Int64.ToNumber(roleId))
  local p = require("netio.protocol.mzm.gsp.planttree.CGetPlantTreeDetailInfoReq").new(roleId, self._activityId)
  gmodule.network.sendProtocol(p)
end
def.method().OnBtnWateringClick = function(self)
  local curRoleInfo = self._arrFriendList[self._selectRoleIdx]
  local plantInfo = self._plantTreeInfos[curRoleInfo.Id:tostring()]
  if plantInfo.current_section_point == nil then
    Toast(textRes.PlantTree[21])
    self:SendReqForGetPlantTreeDetailInfo(curRoleInfo.Id)
    return
  end
  local sepcStatIdxs = plantInfo.special_state_indexes
  if sepcStatIdxs == nil or sepcStatIdxs[1] == nil then
    if self._selectRoleIdx == 1 then
      Toast(string.format(textRes.PlantTree[11], textRes.PlantTree[12]))
    else
      Toast(string.format(textRes.PlantTree[35], curRoleInfo.name))
    end
    return
  end
  local myPlantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  if myPlantInfo.rmvSpecialStatCount >= self._activityCfg.remove_special_state_award_max_times then
    Toast(string.format(textRes.PlantTree[39], textRes.PlantTree[12]))
  end
  local special_state_idx = self._specialStateCfg[UIPlantTree.WATER].special_state_index
  self:SendRmvSpecialStateReq(curRoleInfo.Id, self._activityId, special_state_idx)
end
def.method().OnBtnDisinsectionClick = function(self)
  local curRoleInfo = self._arrFriendList[self._selectRoleIdx]
  local plantInfo = self._plantTreeInfos[curRoleInfo.Id:tostring()]
  if plantInfo.current_section_point == nil then
    Toast(textRes.PlantTree[21])
    self:SendReqForGetPlantTreeDetailInfo(curRoleInfo.Id)
    return
  end
  local sepcStatIdxs = plantInfo.special_state_indexes
  if sepcStatIdxs == nil or sepcStatIdxs[2] == nil then
    if self._selectRoleIdx == 1 then
      Toast(string.format(textRes.PlantTree[11], textRes.PlantTree[13]))
    else
      Toast(string.format(textRes.PlantTree[36], curRoleInfo.name))
    end
    return
  end
  local myPlantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  if myPlantInfo.rmvSpecialStatCount >= self._activityCfg.remove_special_state_award_max_times then
    Toast(string.format(textRes.PlantTree[39], textRes.PlantTree[13]))
  end
  local special_state_idx = self._specialStateCfg[UIPlantTree.KILL_BUG].special_state_index
  self:SendRmvSpecialStateReq(curRoleInfo.Id, self._activityId, special_state_idx)
end
def.method("userdata", "number", "number").SendRmvSpecialStateReq = function(self, roleId, actId, specStatId)
  local p = require("netio.protocol.mzm.gsp.planttree.CRemoveSpecialStateReq").new(roleId, actId, specStatId)
  gmodule.network.sendProtocol(p)
end
def.method().OnBtnFertilizationClick = function(self)
  local roledInfo = self._arrFriendList[1]
  local plantInfo = self._plantTreeInfos[roledInfo.Id:tostring()]
  if plantInfo.addPtCount == nil and self._plantLoginInfo == nil then
    Toast(textRes.PlantTree[21])
    return
  end
  if plantInfo.addPtCount >= self._activityCfg.add_point_max_times then
    Toast(textRes.PlantTree[7])
    return
  elseif plantInfo.total_points >= self._dstTotalPts then
    Toast(textRes.PlantTree[38])
    return
  end
  local addPtCfgInfos = self._activityCfg.add_point_operations
  local addPtCfgInfoCount = #addPtCfgInfos
  if addPtCfgInfoCount == 1 then
    local actId = self._activityId
    local addPtId = addPtCfgInfos[1].add_point_operation_cfg_id
    local money_type = addPtCfgInfos[1].money_type
    local money_num = addPtCfgInfos[1].money_num
    local desc = addPtCfgInfos[1].desc
    local confirm_txt = ""
    self._curAddPtInfo = addPtCfgInfos[1]
    if money_type == MoneyType.SILVER then
      confirm_txt = string.format(textRes.PlantTree[4], desc, money_num, textRes.PlantTree[1])
      CommonConfirmDlg.ShowConfirm("", confirm_txt, UIPlantTree.OnConfirmSilverAddPtCallback, nil)
    elseif money_type == MoneyType.GOLD then
      confirm_txt = string.format(textRes.PlantTree[4], desc, money_num, textRes.PlantTree[2])
      CommonConfirmDlg.ShowConfirm("", confirm_txt, UIPlantTree.OnConfirmGoldAddPtCallback, nil)
    elseif money_type == MoneyType.YUANBAO then
      confirm_txt = string.format(textRes.PlantTree[4], desc, money_num, textRes.PlantTree[3])
      CommonConfirmDlg.ShowConfirm("", confirm_txt, UIPlantTree.OnConfirmYBAddPtCallback, nil)
    end
  else
    warn(">>>>To Select which addPt type<<<<")
  end
end
def.static("number", "table").OnConfirmSilverAddPtCallback = function(yesOrNo, tag)
  if yesOrNo == 0 then
    return
  end
  local roleSilverNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  local self = UIPlantTree.Instance()
  local data = self._curAddPtInfo
  if Int64.lt(roleSilverNum, data.money_num) then
    CommonConfirmDlg.ShowConfirm("", textRes.PlantTree[5], function(yesOrNo, tag)
      if yesOrNo == 0 then
        return
      end
      _G.GoToBuySilver(false)
    end, nil)
    return
  end
  self:SendAddPtReq(self._activityId, data.add_point_operation_cfg_id, data.money_type, data.money_num)
end
def.static("number", "table").OnConfirmGoldAddPtCallback = function(yesOrNo, tag)
  if yesOrNo == 0 then
    return
  end
  local roleGoldNum = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD) or Int64.new(0)
  local self = UIPlantTree.Instance()
  local data = self._curAddPtInfo
  if Int64.lt(roleGoldNum, data.money_num) then
    CommonConfirmDlg.ShowConfirm("", textRes.PlantTree[6], function(yesOrNo, tag)
      if yesOrNo == 0 then
        return
      end
      _G.GoToBuyGold(false)
    end, nil)
    return
  end
  self:SendAddPtReq(self._activityId, data.add_point_operation_cfg_id, data.money_type, data.money_num)
end
def.static("number", "table").OnConfirmYBAddPtCallback = function(yesOrNo, tag)
  if yesOrNo == 0 then
    return
  end
  local roleYuanbaoNum = ItemModule.Instance():GetAllYuanBao() or Int64.new(0)
  local self = UIPlantTree.Instance()
  local data = self._curAddPtInfo
  if Int64.lt(roleYuanbaoNum, data.money_num) then
    _G.GotoBuyYuanbao()
    return
  end
  self:SendAddPtReq(self._activityId, data.add_point_operation_cfg_id, data.money_type, data.money_num)
end
def.method("number", "number", "number", "number").SendAddPtReq = function(self, actId, addPtId, moneyType, moneyNum)
  warn(">>>>Send AddPoint Req...<<<<")
  local p = require("netio.protocol.mzm.gsp.planttree.CAddPointReq").new(actId, addPtId, moneyType, moneyNum)
  gmodule.network.sendProtocol(p)
end
def.method().OnSynLoginPlantInfo = function(self)
  if self._plantLoginInfo == nil then
    return
  end
  local timeNow = AbsoluteTimer.GetServerTimeTable(_G.GetServerTime())
  if timeNow.day ~= self._timeLogin.day then
    self._timeLogin = timeNow
    self._plantLoginInfo.addPtCount = 0
    self._plantLoginInfo.rmvSpecialStatCount = 0
    self._plantLoginInfo.bHasGetActAward = false
  end
  local myPlantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  self:UpdateSecAwardInfo(self._plantLoginInfo.iArrGotSecAwards)
  myPlantInfo.bHasGetActAward = self._plantLoginInfo.bHasGetActAward
  myPlantInfo.addPtCount = self._plantLoginInfo.addPtCount
  myPlantInfo.rmvSpecialStatCount = self._plantLoginInfo.rmvSpecialStatCount
end
def.method().OnBtnAcceptAwardClick = function(self)
  local myPlantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  if myPlantInfo.bHasGetActAward == nil or myPlantInfo.total_points == nil then
    self:OnSynLoginPlantInfo()
    if self._plantLoginInfo == nil or myPlantInfo.total_points == nil then
      Toast(textRes.PlantTree[21])
      self:SendReqForGetPlantTreeDetailInfo(self._roleInfo.Id)
      return
    end
  end
  local bIsTreeMature = myPlantInfo.total_points >= self._dstTotalPts
  if not bIsTreeMature then
    Toast(textRes.PlantTree[16])
    return
  end
  if myPlantInfo.bHasGetActAward then
    Toast(textRes.PlantTree[17])
    return
  end
  warn(">>>>Send CGetActivityCompleteAwardReq <<<<")
  local p = require("netio.protocol.mzm.gsp.planttree.CGetActivityCompleteAwardReq").new(self._activityId)
  gmodule.network.sendProtocol(p)
end
def.method("number").OnBtnGetSectionAwardClick = function(self, idx)
  local myPlantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  local bArrGotSecAward = myPlantInfo.bArrGotSecAward
  if bArrGotSecAward == nil or myPlantInfo.current_section_id == nil then
    Toast(textRes.PlantTree[21])
    self:SendReqForGetPlantTreeDetailInfo(self._roleInfo.Id)
    return
  end
  if bArrGotSecAward[idx] then
    Toast(textRes.PlantTree[19])
    return
  end
  if idx > myPlantInfo.current_section_id then
    Toast(textRes.PlantTree[18])
    return
  end
  warn(">>>>Send CGetSectionCompleteAwardReq <<<<")
  local p = require("netio.protocol.mzm.gsp.planttree.CGetSectionCompleteAwardReq").new(self._activityId, self._sectionCfg[idx].section_id)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnAddPointFailed = function(p)
  local SAddPointFail = require("netio.protocol.mzm.gsp.planttree.SAddPointFail")
  local self = UIPlantTree.Instance()
  if not self._bPanelShow then
    return
  end
  if p.res == SAddPointFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == SAddPointFail.ROLE_STATUS_ERROR then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == SAddPointFail.PARAM_ERROR then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == SAddPointFail.CAN_NOT_JOIN_ACTIVITY then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == SAddPointFail.ADD_POINT_TO_LIMIT then
    Toast(textRes.PlantTree[7])
  elseif p.res == SAddPointFail.ACTIVITY_POINT_FULL then
    Toast(textRes.PlantTree[8])
    self._roleInfo.addPtCofunt = self._activityCfg.add_point_max_times
  elseif p.res == SAddPointFail.MONEY_NOT_MATCH then
    warn(">>>>MONEY_NOT_MATCH<<<<")
  elseif p.res == SAddPointFail.MONEY_NOT_ENOUGH then
    Toast(textRes.PlantTree[9])
  elseif p.res == SAddPointFail.COST_MONEY_FAIL then
    warn(">>>>COST_MONEY_FAIL<<<<")
  end
end
def.static("table").OnAddPointSuccess = function(p)
  local self = UIPlantTree.Instance()
  if not self._bPanelShow then
    return
  end
  Toast(string.format(textRes.PlantTree[10], self._curAddPtInfo.desc, self._curAddPtInfo.point))
  local plantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  plantInfo.addPtCount = plantInfo.addPtCount + 1
  self._plantLoginInfo = self._plantLoginInfo or {}
  self._plantLoginInfo.addPtCount = plantInfo.addPtCount
end
def.static("table").OnSGetActivityCompleteAwardFail = function(p)
  local self = UIPlantTree.Instance()
  if not self._bPanelShow then
    return
  end
  local myPlantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  local SGetActivityCompleteAwardFail = require("netio.protocol.mzm.gsp.planttree.SGetActivityCompleteAwardFail")
  if p.res == SGetActivityCompleteAwardFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == SGetActivityCompleteAwardFail.ROLE_STATUS_ERROR then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == SGetActivityCompleteAwardFail.PARAM_ERROR then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == SGetActivityCompleteAwardFail.CAN_NOT_JOIN_ACTIVITY then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == SGetActivityCompleteAwardFail.ALREADY_GET_AWARD then
    Toast(textRes.PlantTree[17])
    myPlantInfo.bHasGetActAward = true
  elseif p.res == SGetActivityCompleteAwardFail.ACTIVITY_NOT_COMPLETE then
    Toast(textRes.PlantTree[16])
  end
end
def.static("table").OnSGetActivityCompleteAwardSuccess = function(p)
  local self = UIPlantTree.Instance()
  if not self._bPanelShow then
    return
  end
  if self._activityId ~= p.activity_cfg_id then
    return
  end
  local myPlantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  myPlantInfo.bHasGetActAward = true
  self._plantLoginInfo = self._plantLoginInfo or {}
  self._plantLoginInfo.bHasGetActAward = true
  self:UpdateBtns()
end
def.static("table").OnSGetPlantTreeDetailInfoFail = function(p)
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>DB_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
    Toast(textRes.PlantTree[37])
  elseif p.res == 2 then
    warn(">>>>RELATIONSHIP_ERROR<<<<")
  end
  warn(">>>>OnSGetPlantTreeDetailInfoFail resid = " .. p.res)
end
def.static("table").OnSGetSectionCompleteAwardSuccess = function(p)
  warn("On Get OnSGetSectionCompleteAwardSuccess")
  local self = UIPlantTree.Instance()
  local mySelfId = self._roleInfo.Id:tostring()
  local myPlantInfo = self._plantTreeInfos[mySelfId]
  myPlantInfo.bArrGotSecAward[p.section_id] = true
  if self._plantLoginInfo ~= nil then
    self._plantLoginInfo.iArrGotSecAwards = self._plantLoginInfo.iArrGotSecAwards or {}
    table.insert(self._plantLoginInfo.iArrGotSecAwards, p.section_id)
  end
  self:UpdateUI()
end
def.static("table").OnSGetSectionCompleteAwardFail = function(p)
  local self = UIPlantTree.Instance()
  if not self._bPanelShow then
    return
  end
  local SGetSectionCompleteAwardFail = require("netio.protocol.mzm.gsp.planttree.SGetSectionCompleteAwardFail")
  if p.res == SGetSectionCompleteAwardFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == SGetSectionCompleteAwardFail.ROLE_STATUS_ERROR then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == SGetSectionCompleteAwardFail.PARAM_ERROR then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == SGetSectionCompleteAwardFail.CAN_NOT_JOIN_ACTIVITY then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == SGetSectionCompleteAwardFail.ALREADY_GET_AWARD then
    Toast(textRes.PlantTree[19])
  elseif p.res == SGetSectionCompleteAwardFail.SECTION_NOT_COMPLETE then
    Toast(textRes.PlantTree[18])
  end
  self:UpdateUI()
end
def.static("table").OnSRemoveSpecialStateFail = function(p)
  local SRemoveSpecialStateFail = require("netio.protocol.mzm.gsp.planttree.SRemoveSpecialStateFail")
  local self = UIPlantTree.Instance()
  if p.res == SRemoveSpecialStateFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == SRemoveSpecialStateFail.ROLE_STATUS_ERROR then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == SRemoveSpecialStateFail.PARAM_ERROR then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == SRemoveSpecialStateFail.CAN_NOT_JOIN_ACTIVITY then
    Toast(textRes.PlantTree[37])
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == SRemoveSpecialStateFail.RELATIONSHIP_ERROR then
    warn(">>>>RELATIONSHIP_ERROR<<<<")
  elseif p.res == SRemoveSpecialStateFail.SPECIAL_STATE_ERROR then
    warn(">>>>SPECIAL_STATE_ERROR<<<<")
  end
  self:UpdateUI()
end
def.static("table").OnRcvRolePlantTreeInfo = function(p)
  warn("\228\184\138\231\186\191\232\142\183\229\143\150\230\156\141\229\138\161\229\153\168\232\175\166\231\187\134\228\191\161\230\129\175")
  local self = UIPlantTree.Instance()
  self._plantLoginInfo = self._plantLoginInfo or {}
  local plantLoginInfo = self._plantLoginInfo
  plantLoginInfo.activityId = p.activity_cfg_id
  plantLoginInfo.iArrGotSecAwards = p.award_section_ids
  p.has_get_activity_complete_award = p.has_get_activity_complete_award or 0
  plantLoginInfo.bHasGetActAward = p.has_get_activity_complete_award == 1
  plantLoginInfo.addPtCount = p.add_point_times or 0
  plantLoginInfo.rmvSpecialStatCount = p.remove_special_state_award_times
  if self._timeLogin == nil then
    self._timeLogin = AbsoluteTimer.GetServerTimeTable(_G.GetServerTime())
  end
  if not self._bPanelShow then
    return
  end
  self:UpdateSecAwardInfo(p.award_section_ids)
  self:UpdateActCompleteAwardState(p.has_get_activity_complete_award == 1)
  local plantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  plantInfo.addPtCount = p.add_point_times
  plantInfo.rmvSpecialStatCount = plantLoginInfo.rmvSpecialStatCount
  self:UpdateUI()
end
def.method("table").UpdateSecAwardInfo = function(self, completedSecs)
  local roleId = self._roleInfo.Id:tostring()
  local plantInfo = self._plantTreeInfos[roleId]
  if plantInfo.bArrGotSecAward == nil then
    plantInfo.bArrGotSecAward = plantInfo.bArrGotSecAward or {}
    local section_num = self._activityCfg.section_num
    for i = 1, section_num do
      table.insert(plantInfo.bArrGotSecAward, false)
    end
  end
  completedSecs = completedSecs or {}
  for _, v in pairs(completedSecs) do
    plantInfo.bArrGotSecAward[v] = true
  end
end
def.method("boolean").UpdateActCompleteAwardState = function(self, bHasGetAward)
  local plantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  plantInfo.bHasGetActAward = bHasGetAward
end
def.static("table").OnUpdatePlantTreeState = function(p)
  UIPlantTree.ToSetActivityInterfaceRedPt(p)
  local self = UIPlantTree.Instance()
  if not self._bPanelShow then
    return
  end
  self:ToUpdateRealtimeActInfo(p, true)
end
def.static("table").ToSetActivityInterfaceRedPt = function(p)
  local PlantTreeModule = require("Main.PlantTree.PlantTreeModule")
  local self = UIPlantTree.Instance()
  local actId = self._activityId
  if actId == -1 then
    return
  end
  local roleInfo = require("Main.Hero.HeroModule").Instance():GetHeroProp()
  if roleInfo.id == p.owner_id then
    local spcIdx = p.special_state_index
    if spcIdx == nil or spcIdx == 0 then
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {activityId = actId, isShowRedPoint = false})
    else
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {activityId = actId, isShowRedPoint = true})
    end
  end
end
def.static("table").OnGetPlantTreeBasicInfo = function(p)
  local self = UIPlantTree.Instance()
  if not self._bPanelShow then
    return
  end
  self:SendReqForGetPlantTreeDetailInfo(p.owner_id)
  self:ToUpdateRealtimeActInfo(p, true)
end
def.static("table").OnGetPlantTreeDetailInfo = function(p)
  local self = UIPlantTree.Instance()
  if not self._bPanelShow then
    return
  end
  self:ToUpdateRealtimeActInfo(p, false)
end
def.method("table", "boolean").ToUpdateRealtimeActInfo = function(self, p, bIsMyself)
  local roleId = p.owner_id:tostring()
  local plantInfo = self._plantTreeInfos[roleId]
  plantInfo.special_state_indexes = plantInfo.special_state_indexes or {}
  local specStatIdxs = plantInfo.special_state_indexes
  warn(">>>>sepcial state idx = " .. p.special_state_index)
  plantInfo.special_state_indexes = nil
  if p.special_state_index ~= 0 then
    plantInfo.special_state_indexes = {}
    plantInfo.special_state_indexes[p.special_state_index] = p.special_state_index
  end
  plantInfo.current_section_id = p.current_section_id
  plantInfo.current_section_point = p.current_section_point
  self:UpdateRoleActTotalPt(plantInfo)
  if p.logs ~= nil then
    self:ParseLog(plantInfo, p.logs, p.owner_id, not bIsMyself)
  end
  self:UpdateUI()
end
def.static("table", "table").OnHeroLvUp = function(p1, context)
  local self = UIPlantTree.Instance()
  if self._timeLogin == nil then
    self._timeLogin = AbsoluteTimer.GetServerTimeTable(_G.GetServerTime())
  end
  if self._plantLoginInfo == nil then
    self._plantLoginInfo = {}
    self._plantLoginInfo.addPtCount = 0
    self._plantLoginInfo.rmvSpecialStatCount = 0
    self._plantLoginInfo.bHasGetActAward = false
  end
end
def.method("table").UpdateRoleActTotalPt = function(self, plantInfo)
  local curSecId = plantInfo.current_section_id or 1
  local curTotalPt = 0
  for i = 2, curSecId do
    curTotalPt = curTotalPt + self._sectionCfg[i - 1].section_total_point
  end
  curTotalPt = curTotalPt + (plantInfo.current_section_point or 0)
  plantInfo.total_points = curTotalPt
end
def.static("table").OnSyncFriendList = function(p)
  local self = UIPlantTree.Instance()
  if not self._bPanelShow then
    return
  end
  self:FriendListChange(p)
end
def.static("number", "=>", "userdata").GetRecord = function(actId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PLANT_TREE_CFG, actId)
  if record == nil then
    warn(">>>>Get PlantTreeCfg return data is empty, actId = " .. actId .. "<<<<")
    return nil
  end
  return record
end
def.static("number", "=>", "table").GetActivityCfgById = function(actId)
  local retData = {}
  local record = UIPlantTree.GetRecord(actId)
  if record == nil then
    return retData
  end
  retData.add_point_max_times = record:GetIntValue("add_point_max_times")
  retData.activity_type = record:GetIntValue("activity_type")
  retData.remove_special_state_award_max_times = record:GetIntValue("remove_special_state_award_max_times")
  retData.section_num = record:GetIntValue("section_num")
  retData.activity_complete_modle_id = record:GetIntValue("activity_complete_modle_id")
  retData.activity_complete_name = record:GetStringValue("activity_complete_name")
  retData.tipsId = record:GetIntValue("tips_content_id")
  retData.special_state_infos = {}
  retData.section_infos = {}
  retData.add_point_operations = {}
  UIPlantTree.LoadSpecialStateInfos(retData.special_state_infos, actId, record)
  UIPlantTree.LoadSectionInfos(retData.section_infos, actId, record)
  UIPlantTree.LoadAddPointOperation(retData.add_point_operations, actId, record)
  return retData
end
def.static("table", "table").OnActivityStart = function(p, context)
  local actId = p[1] and p[1] or 0
  local acts = require("Main.PlantTree.PlantTreeUtils").GetModuleActs()
  if acts == nil then
    return
  end
  local bHasAct = false
  for i = 1, #acts do
    if acts[i].actId == actId then
      bHasAct = true
      break
    end
  end
  if not bHasAct then
    return
  end
  local self = UIPlantTree.Instance()
  self._plantLoginInfo = self._plantLoginInfo or {}
  self._plantLoginInfo.addPtCount = 0
  self._plantLoginInfo.rmvSpecialStatCount = 0
  self._plantLoginInfo.bHasGetActAward = false
  local myPlantInfo = self._plantTreeInfos[self._roleInfo.Id:tostring()]
  self:OnSynLoginPlantInfo()
  self:UpdateUI()
end
def.static("table", "number", "userdata").LoadSpecialStateInfos = function(tblCont, actId, record)
  if record == nil then
    record = UIPlantTree.GetRecord(actId)
    if record == nil then
      return nil
    end
  end
  if #tblCont > 1 then
    tblCont = nil
  end
  local vecStructData = record:GetStructValue("special_state_infosStruct")
  local vecSize = vecStructData:GetVectorSize("special_state_infos")
  for i = 1, vecSize do
    local single_record = vecStructData:GetVectorValueByIdx("special_state_infos", i - 1)
    local specialStatIdx = single_record:GetIntValue("special_state_index")
    local stateName = single_record:GetStringValue("special_state_name")
    local vecImgStructData = single_record:GetStructValue("image_idsStruct")
    local vecImgSize = vecImgStructData:GetVectorSize("image_ids")
    local arrImgIds = {}
    for j = 1, vecImgSize do
      local sglImgRecrd = vecImgStructData:GetVectorValueByIdx("image_ids", j - 1)
      table.insert(arrImgIds, sglImgRecrd:GetIntValue("img_id"))
    end
    table.insert(tblCont, {
      special_state_index = specialStatIdx,
      special_state_name = stateName,
      img_ids = arrImgIds
    })
  end
end
def.static("table", "number", "userdata").LoadSectionInfos = function(tblCont, actId, record)
  if record == nil then
    record = UIPlantTree.GetRecord(actId)
    if record == nil then
      return nil
    end
  end
  if #tblCont > 1 then
    tblCont = nil
  end
  local vecStructData = record:GetStructValue("section_infosStruct")
  local vecSize = vecStructData:GetVectorSize("section_infos")
  for i = 1, vecSize do
    local single_record = vecStructData:GetVectorValueByIdx("section_infos", i - 1)
    local secId = single_record:GetIntValue("section_id")
    local sec_total_pt = single_record:GetIntValue("section_total_point")
    local modelId = single_record:GetIntValue("section_modle_id")
    local secName = single_record:GetStringValue("section_name")
    table.insert(tblCont, {
      section_id = secId,
      section_total_point = sec_total_pt,
      section_modle_id = modelId,
      section_name = secName
    })
  end
  table.sort(tblCont, function(a, b)
    return a.section_id < b.section_id
  end)
end
def.static("table", "number", "userdata").LoadAddPointOperation = function(tblCont, actId, record)
  if record == nil then
    record = UIPlantTree.GetRecord(actId)
    if record == nil then
      return nil
    end
  end
  if #tblCont > 1 then
    tblCont = nil
  end
  local vecStructData = record:GetStructValue("add_point_operationsStruct")
  local vecSize = vecStructData:GetVectorSize("add_point_operations")
  for i = 1, vecSize do
    local single_record = vecStructData:GetVectorValueByIdx("add_point_operations", i - 1)
    local cfgId = single_record:GetIntValue("add_point_operation_cfg_id")
    local moneyType = single_record:GetIntValue("money_type")
    local moneyNum = single_record:GetIntValue("money_num")
    local pt = single_record:GetIntValue("point")
    local desc = single_record:GetStringValue("desc")
    table.insert(tblCont, {
      add_point_operation_cfg_id = cfgId,
      money_type = moneyType,
      money_num = moneyNum,
      point = pt,
      desc = desc
    })
  end
end
UIPlantTree.Commit()
return UIPlantTree
