local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgPhaseInfo = Lplus.Extend(ECPanelBase, "DlgPhaseInfo")
local def = DlgPhaseInfo.define
local dlg
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
def.field("table")._uiObjs = nil
def.field("userdata").phaseListCmp = nil
def.field("userdata").seasonListCmp = nil
def.field("table").phaseAwardCfgs = nil
def.field("table").seasonAwardCfgs = nil
def.field("number").seasonType = ChartType.LADDER_LOCAL
def.field("number").selectedPhaseIdx = 0
def.field("number").myPhaseIdx = 0
def.static("=>", DlgPhaseInfo).Instance = function()
  if dlg == nil then
    dlg = DlgPhaseInfo()
  end
  return dlg
end
def.override().OnCreate = function(self)
  self._uiObjs = {}
  self._uiObjs.Group_DuanWei = self.m_panel:FindDirect("Img_Bg/Group_DuanWei")
  self._uiObjs.PanelLevelChoose = self._uiObjs.Group_DuanWei:FindDirect("Btn_LC/Group_Zone")
  self._uiObjs.Img_Up = self._uiObjs.Group_DuanWei:FindDirect("Btn_LC/Img_Up")
  self._uiObjs.Img_Down = self._uiObjs.Group_DuanWei:FindDirect("Btn_LC/Img_Down")
  self._uiObjs.Img_Up:SetActive(false)
  self._uiObjs.LevelList = self._uiObjs.PanelLevelChoose:FindDirect("Group_ChooseType/List")
  self._uiObjs.Group_Season = self.m_panel:FindDirect("Img_Bg/Group_Season")
  self._uiObjs.Panel_Local_LevelChoose = self._uiObjs.Group_Season:FindDirect("Tab_Own/Group_Zone")
  self._uiObjs.Panel_Remote_LevelChoose = self._uiObjs.Group_Season:FindDirect("Tab_Cross/Group_Zone")
  self._uiObjs.local_levels = self._uiObjs.Panel_Local_LevelChoose:FindDirect("Group_ChooseType/List")
  self._uiObjs.remote_levels = self._uiObjs.Panel_Remote_LevelChoose:FindDirect("Group_ChooseType/List")
  self._uiObjs.Img_Up_local = self._uiObjs.Group_Season:FindDirect("Tab_Own/Img_Up")
  self._uiObjs.Img_Down_local = self._uiObjs.Group_Season:FindDirect("Tab_Own/Img_Down")
  self._uiObjs.Img_Up_remote = self._uiObjs.Group_Season:FindDirect("Tab_Cross/Img_Up")
  self._uiObjs.Img_Down_remote = self._uiObjs.Group_Season:FindDirect("Tab_Cross/Img_Down")
  self._uiObjs.Img_Up_local:SetActive(false)
  self._uiObjs.Img_Up_remote:SetActive(false)
  Event.RegisterEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_MYRANK_INFO, DlgPhaseInfo.OnGetMyRank)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.ladder.STakeLadderStageAwardRes", DlgPhaseInfo.OnSTakeLadderStageAwardRes)
  self._uiObjs.listPanel_phase = self._uiObjs.Group_DuanWei:FindDirect("Scroll View_LeiDeng/List_LeiDeng")
  self.phaseListCmp = self._uiObjs.listPanel_phase:GetComponent("UIScrollList")
  local GUIScrollList = self._uiObjs.listPanel_phase:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    do
      local scroll = self._uiObjs.Group_DuanWei:FindDirect("Scroll View_LeiDeng"):GetComponent("UIScrollView")
      self._uiObjs.listPanel_phase:AddComponent("GUIScrollList")
      ScrollList_setUpdateFunc(self.phaseListCmp, function(item, i)
        self:SetPhaseAwardInfo(item, i)
        if scroll and not scroll.isnil then
          scroll:InvalidateBounds()
        end
      end)
    end
  end
  self.m_msgHandler:Touch(self._uiObjs.listPanel_phase)
  self._uiObjs.listPanel_season = self._uiObjs.Group_Season:FindDirect("Scroll View_Season/List_Season")
  self.seasonListCmp = self._uiObjs.listPanel_season:GetComponent("UIScrollList")
  local GUIScrollList2 = self._uiObjs.listPanel_season:GetComponent("GUIScrollList")
  if GUIScrollList2 == nil then
    do
      local scroll2 = self._uiObjs.Group_Season:FindDirect("Scroll View_Season"):GetComponent("UIScrollView")
      self._uiObjs.listPanel_season:AddComponent("GUIScrollList")
      ScrollList_setUpdateFunc(self.seasonListCmp, function(item, i)
        self:SetSeasonAwardInfo(item, i)
        if scroll2 and not scroll2.isnil then
          scroll2:InvalidateBounds()
        end
      end)
    end
  end
  self.m_msgHandler:Touch(self._uiObjs.listPanel_season)
  local drop_lists = {
    self._uiObjs.LevelList,
    self._uiObjs.local_levels,
    self._uiObjs.remote_levels
  }
  local phaseCfgs = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetPhaseCfgs()
  local valid_num = 0
  for _, v in pairs(phaseCfgs) do
    if not v.hide then
      valid_num = valid_num + 1
    end
  end
  for k = 1, #drop_lists do
    local uiList = drop_lists[k]:GetComponent("UIList")
    uiList.itemCount = valid_num
    uiList:Resize()
    local uiItems = uiList.children
    for i = 1, uiList.itemCount do
      local label_name = uiItems[i]:FindDirect("Label_Name_" .. i)
      label_name:GetComponent("UILabel"):set_text(phaseCfgs[i].levelRangeName)
    end
  end
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    return
  end
  self:CreatePanel(RESPATH.DLG_CROSS_SERVER_AWARDS, 1)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local phaseCfgs = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetPhaseCfgs()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  for k = 1, #phaseCfgs do
    if heroProp.level < phaseCfgs[k].level then
      self.selectedPhaseIdx = k - 1
      local phase = phaseCfgs[k - 1]
      if phase then
        self.seasonType = phase.localChartType
      end
      break
    else
      self.selectedPhaseIdx = k
      self.seasonType = phaseCfgs[k].localChartType
    end
  end
  self.myPhaseIdx = self.selectedPhaseIdx
  self:SetTabTitle(self.selectedPhaseIdx, true)
  self:SetTabTitle(0, false)
  GameUtil.AddGlobalTimer(0, true, function()
    self:ShowPhaseInfo()
  end)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderSelfRankReq").new(self.seasonType))
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self.phaseListCmp = nil
  self.seasonListCmp = nil
  self.phaseAwardCfgs = nil
  self.seasonAwardCfgs = nil
  gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER).myRankInfo = nil
  self._uiObjs = nil
  self.selectedPhaseIdx = 0
end
def.method().ShowPhaseInfo = function(self)
  if self.m_panel == nil then
    return
  end
  ScrollList_clear(self.phaseListCmp)
  local mgr = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER)
  local myLadderInfo = mgr.myLadderInfo
  self._uiObjs.Group_DuanWei:FindDirect("Label_MyCredit/Label_Num"):GetComponent("UILabel").text = myLadderInfo and myLadderInfo.matchScore or "0"
  if myLadderInfo and myLadderInfo.stage < 1 then
    myLadderInfo.stage = 1
  end
  local cur_stage = myLadderInfo and myLadderInfo.stage or 1
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local phaseInfo = mgr:GetPhaseInfo(heroProp.level, cur_stage)
  self._uiObjs.Group_DuanWei:FindDirect("Label_MyDuanWei/Label"):GetComponent("UILabel").text = phaseInfo and phaseInfo.name or textRes.Common[1]
  local count = 0
  if self.phaseAwardCfgs == nil or self.phaseAwardCfgs.phaseIdx ~= self.selectedPhaseIdx then
    self.phaseAwardCfgs = {}
    self.phaseAwardCfgs.phaseIdx = self.selectedPhaseIdx
    local phaseCfgs = mgr:GetPhaseCfgs()
    local phaseCfg = phaseCfgs[self.selectedPhaseIdx]
    if phaseCfg == nil then
      return
    end
    for i = 1, #phaseCfg.ranks do
      local cfg = phaseCfg.ranks[i]
      if 0 < cfg.awardId then
        table.insert(self.phaseAwardCfgs, cfg)
        count = count + 1
      end
    end
  else
    count = #self.phaseAwardCfgs
  end
  local btn_label = self._uiObjs.Group_DuanWei:FindDirect("Btn_LC/Label_Btn")
  local uiList = self._uiObjs.LevelList:GetComponent("UIList")
  local uiItems = uiList.children
  local item = uiItems[self.selectedPhaseIdx]
  if item then
    local sel_name = item:FindDirect("Label_Name_" .. self.selectedPhaseIdx)
    local name = sel_name:GetComponent("UILabel"):get_text()
    local mark_idx = string.find(name, "\239\188\136")
    local subname
    if mark_idx and mark_idx > 0 then
      subname = string.sub(name, 1, mark_idx - 1)
    else
      subname = name
    end
    btn_label:GetComponent("UILabel"):set_text(subname)
  end
  ScrollList_setCount(self.phaseListCmp, count)
end
def.method().ShowSeasonAwardInfo = function(self)
  if self.m_panel == nil then
    return
  end
  ScrollList_clear(self.seasonListCmp)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_SERVER_SEASON_AWARD_CFG)
  local size = DynamicDataTable.GetRecordsCount(entries)
  if self.seasonAwardCfgs == nil then
    self.seasonAwardCfgs = {}
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, size - 1 do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local cfg = {}
      cfg.rank = record:GetIntValue("rank")
      cfg.rankType = record:GetIntValue("rankType")
      cfg.itemid1 = record:GetIntValue("itemid1")
      cfg.itemid2 = record:GetIntValue("itemid2")
      cfg.itemid3 = record:GetIntValue("itemid3")
      cfg.itemCount1 = record:GetIntValue("itemCount1")
      cfg.itemCount2 = record:GetIntValue("itemCount2")
      cfg.itemCount3 = record:GetIntValue("itemCount3")
      if self.seasonAwardCfgs[cfg.rankType] == nil then
        self.seasonAwardCfgs[cfg.rankType] = {}
      end
      table.insert(self.seasonAwardCfgs[cfg.rankType], cfg)
    end
    DynamicDataTable.FastGetRecordEnd(entries)
  end
  local count = self.seasonAwardCfgs[self.seasonType] and #self.seasonAwardCfgs[self.seasonType] or 0
  ScrollList_setCount(self.seasonListCmp, count)
end
def.method("userdata", "number").SetPhaseAwardInfo = function(self, awardPanel, idx)
  if awardPanel == nil then
    return
  end
  local awardInfo = self.phaseAwardCfgs and self.phaseAwardCfgs[idx]
  if awardInfo == nil then
    return
  end
  local myLadderInfo = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER).myLadderInfo
  awardPanel:FindDirect("Img_DuanWei"):GetComponent("UISprite").spriteName = awardInfo.iconName
  awardPanel:FindDirect("Label_Credit"):GetComponent("UILabel").text = tostring(awardInfo.upMinScore)
  awardPanel:FindDirect("Label_Name"):GetComponent("UILabel").text = awardInfo.name
  local group_ling = awardPanel:FindDirect("Goup_Ling")
  if self.myPhaseIdx == self.selectedPhaseIdx then
    group_ling:SetActive(true)
    if myLadderInfo and awardInfo.idx <= myLadderInfo.stage then
      awardPanel:FindDirect("Goup_Ling/Group_LeftNum"):SetActive(false)
      if myLadderInfo.stageAwards and myLadderInfo.stageAwards[awardInfo.idx] then
        awardPanel:FindDirect("Goup_Ling/Btn_Get"):SetActive(false)
        awardPanel:FindDirect("Goup_Ling/Img_YiLing"):SetActive(true)
      else
        awardPanel:FindDirect("Goup_Ling/Btn_Get"):SetActive(true)
        awardPanel:FindDirect("Goup_Ling/Img_YiLing"):SetActive(false)
      end
    else
      awardPanel:FindDirect("Goup_Ling/Btn_Get"):SetActive(false)
      awardPanel:FindDirect("Goup_Ling/Group_LeftNum"):SetActive(true)
      awardPanel:FindDirect("Goup_Ling/Img_YiLing"):SetActive(false)
      local cur_score = myLadderInfo and myLadderInfo.matchScore or 0
      awardPanel:FindDirect("Goup_Ling/Group_LeftNum/Label_Num"):GetComponent("UILabel").text = tostring(awardInfo.upMinScore - cur_score)
    end
  else
    group_ling:SetActive(false)
  end
  local cfg = ItemUtils.GetGiftAwardCfgByAwardId(awardInfo.awardId)
  if cfg then
    awardInfo.itemList = cfg.itemList
    for j = 1, 3 do
      local item = cfg.itemList[j]
      if item then
        local item_panel = awardPanel:FindDirect("Group_Icon/Img_BgIcon" .. j)
        local itemBase = ItemUtils.GetItemBase(item.itemId)
        item_panel:FindDirect("Label_Num"):GetComponent("UILabel").text = tostring(item.num)
        local awardIcon = item_panel:FindDirect("Texture_Icon")
        GUIUtils.SetTexture(awardIcon, itemBase.icon)
      end
    end
  end
end
def.method("userdata", "number").SetSeasonAwardInfo = function(self, awardPanel, idx)
  if awardPanel == nil then
    return
  end
  local awardInfo = self.seasonAwardCfgs and self.seasonAwardCfgs[self.seasonType][idx]
  if awardInfo == nil then
    return
  end
  local pre_award = self.seasonAwardCfgs and self.seasonAwardCfgs[self.seasonType][idx - 1]
  local pre_rank = pre_award and pre_award.rank or 1
  if awardInfo.rank - pre_rank == 1 then
    local rank_label = awardPanel:FindDirect("Label_Dan")
    rank_label:SetActive(true)
    rank_label:GetComponent("UILabel").text = awardInfo.rank
    awardPanel:FindDirect("Group_Duan"):SetActive(false)
  else
    awardPanel:FindDirect("Label_Dan"):SetActive(false)
    awardPanel:FindDirect("Group_Duan"):SetActive(true)
    awardPanel:FindDirect("Group_Duan/Label_1"):GetComponent("UILabel").text = pre_award and pre_award.rank + 1 or pre_rank
    awardPanel:FindDirect("Group_Duan/Label_2"):GetComponent("UILabel").text = awardInfo.rank
  end
  for i = 1, 3 do
    local itemIcon = awardPanel:FindDirect("Group_Icon/Img_BgSeasonIcon" .. i)
    local itemid = awardInfo["itemid" .. i]
    itemIcon:SetActive(itemid > 0)
    if itemid > 0 then
      local uiTexture = itemIcon:FindDirect("Texture_Icon"):GetComponent("UITexture")
      local itemBase = ItemUtils.GetItemBase(itemid)
      if itemBase then
        GUIUtils.FillIcon(uiTexture, itemBase.icon)
      end
      itemIcon:FindDirect("Label_Num"):GetComponent("UILabel").text = awardInfo["itemCount" .. i]
    else
      local uiTexture = itemIcon:FindDirect("Texture_Icon"):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, 0)
      itemIcon:FindDirect("Label_Num"):GetComponent("UILabel").text = ""
    end
  end
  local str = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetSeasonDateString()
  self._uiObjs.Group_Season:FindDirect("Label_SessionTime/Label_Num"):GetComponent("UILabel").text = str
end
def.method("userdata").onClickObj = function(self, clickobj)
  local name = clickobj.name
  if string.find(name, "Img_BgIcon") == 1 then
    local itemidx = tonumber(string.sub(name, #"Img_BgIcon" + 1))
    local item, idx = ScrollList_getItem(clickobj)
    if item then
      local awardInfo = self.phaseAwardCfgs[idx]
      if awardInfo and awardInfo.itemList[itemidx] then
        require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(awardInfo.itemList[itemidx].itemId, clickobj, 0, false)
      end
    end
  elseif string.find(name, "Img_BgSeasonIcon") == 1 then
    local itemidx = tonumber(string.sub(name, #"Img_BgSeasonIcon" + 1))
    local item, idx = ScrollList_getItem(clickobj)
    if item then
      local awardInfo = self.seasonAwardCfgs[self.seasonType][idx]
      local itemid = awardInfo and awardInfo["itemid" .. itemidx]
      if itemid and itemid > 0 then
        require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(itemid, clickobj, 0, false)
      end
    end
  elseif string.find(name, "Btn_Get") == 1 then
    local item, idx = ScrollList_getItem(clickobj)
    local awardInfo = self.phaseAwardCfgs[idx]
    if awardInfo then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CTakeLadderStageAwardReq").new(awardInfo.idx))
    end
  elseif string.find(name, "Btn_Own_") == 1 then
    local idx = tonumber(string.sub(name, -1, -1))
    local phaseCfgs = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetPhaseCfgs()
    local phase = phaseCfgs[idx]
    if self.seasonType ~= phase.localChartType then
      self.seasonType = phase.localChartType
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderSelfRankReq").new(self.seasonType))
      self:ShowSeasonAwardInfo()
      self:SetTabTitle(idx, true)
      self:SetTabTitle(0, false)
    end
    self._uiObjs.Panel_Local_LevelChoose:SetActive(false)
  elseif string.find(name, "Btn_Cross_") == 1 then
    local idx = tonumber(string.sub(name, -1, -1))
    local phaseCfgs = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetPhaseCfgs()
    local phase = phaseCfgs[idx]
    if self.seasonType ~= phase.remoteChartType then
      self.seasonType = phase.remoteChartType
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderSelfRankReq").new(self.seasonType))
      self:ShowSeasonAwardInfo()
      self:SetTabTitle(idx, false)
      self:SetTabTitle(0, true)
    end
    self._uiObjs.Panel_Remote_LevelChoose:SetActive(false)
  elseif name == "Btn_Close" then
    self:Hide()
  elseif name == "Btn_LC" then
    local visible = not self._uiObjs.PanelLevelChoose.activeSelf
    self._uiObjs.Img_Down:SetActive(not visible)
    self._uiObjs.PanelLevelChoose:SetActive(visible)
    self._uiObjs.Img_Up:SetActive(visible)
  elseif string.find(name, "Btn_LevelChoose_") == 1 then
    local idx = tonumber(string.sub(name, -1, -1))
    if self.selectedPhaseIdx ~= idx then
      self.selectedPhaseIdx = idx
      self:ShowPhaseInfo()
    end
    self._uiObjs.PanelLevelChoose:SetActive(false)
  elseif name == "Tap_Season" then
    self:ShowSeasonAwardInfo()
  elseif name == "Tab_Own" then
    local visible = not self._uiObjs.Panel_Local_LevelChoose.activeSelf
    self._uiObjs.Panel_Remote_LevelChoose:SetActive(false)
    self._uiObjs.Panel_Local_LevelChoose:SetActive(visible)
    self._uiObjs.Img_Down_local:SetActive(not visible)
    self._uiObjs.Img_Up_local:SetActive(visible)
  elseif name == "Tab_Cross" then
    local visible = not self._uiObjs.Panel_Remote_LevelChoose.activeSelf
    self._uiObjs.Panel_Local_LevelChoose:SetActive(false)
    self._uiObjs.Panel_Remote_LevelChoose:SetActive(visible)
    self._uiObjs.Img_Down_remote:SetActive(not visible)
    self._uiObjs.Img_Up_remote:SetActive(visible)
  end
end
def.static("table").OnSTakeLadderStageAwardRes = function(p)
  if dlg == nil or dlg.m_panel == nil then
    return
  end
  local myLadderInfo = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER).myLadderInfo
  if myLadderInfo then
    myLadderInfo.stageAwards[p.stage] = p.stage
  end
  dlg:ShowPhaseInfo()
end
def.static("table", "table").OnGetMyRank = function(p1, p2)
  if dlg == nil or dlg.m_panel == nil then
    return
  end
  local myRankInfo = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER).myRankInfo
  local label_num = dlg._uiObjs.Group_Season:FindDirect("Label_MyMingCi/Label_Num")
  local label_notOnList = dlg._uiObjs.Group_Season:FindDirect("Label_MyMingCi/Label_NotOnList")
  if myRankInfo and myRankInfo.rank > 0 then
    label_num:GetComponent("UILabel").text = tostring(myRankInfo.rank)
    label_notOnList:SetActive(false)
    label_num:SetActive(true)
  else
    label_num:SetActive(false)
    label_notOnList:SetActive(true)
  end
end
def.method("number", "boolean").SetTabTitle = function(self, idx, isLocal)
  local tab, str, label, initStr
  if isLocal then
    tab = self._uiObjs.local_levels
    initStr = textRes.CrossServer[58]
    str = textRes.CrossServer[59]
    label = self._uiObjs.Group_Season:FindDirect("Tab_Own/Label")
  else
    tab = self._uiObjs.remote_levels
    initStr = textRes.CrossServer[60]
    str = textRes.CrossServer[61]
    label = self._uiObjs.Group_Season:FindDirect("Tab_Cross/Label")
  end
  if idx == 0 then
    label:GetComponent("UILabel"):set_text(initStr)
  else
    local uiList = tab:GetComponent("UIList")
    local uiItems = uiList.children
    local item = uiItems[idx]
    if item == nil then
      return
    end
    local sel_name = item:FindDirect("Label_Name_" .. idx)
    local name = sel_name:GetComponent("UILabel"):get_text()
    local mark_idx = string.find(name, "\239\188\136")
    local subname
    if mark_idx and mark_idx > 0 then
      subname = string.sub(name, 1, mark_idx - 1)
    else
      subname = name
    end
    label:GetComponent("UILabel"):set_text(str .. subname)
  end
end
return DlgPhaseInfo.Commit()
