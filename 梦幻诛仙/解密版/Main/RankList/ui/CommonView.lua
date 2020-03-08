local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RankListViewBase = import(".RankListViewBase")
local CommonView = Lplus.Extend(RankListViewBase, CUR_CLASS_NAME)
local RankListPanel = require("Main.RankList.ui.RankListPanel")
local SelfRankMgr = require("Main.RankList.SelfRankMgr")
local def = RankListViewBase.define
def.override().UpdateView = function(self)
  self:ShowDetailInfo()
  local uiScrollView = self.uiObjs.ListRight.transform.parent.gameObject:GetComponent("UIScrollView")
  uiScrollView:ResetPosition()
  local itemAmount = #self.m_rankListData.list
  local uiList = self.uiObjs.ListRight:GetComponent("UIList")
  uiList.itemCount = itemAmount
  uiList:Resize()
  uiList:Reposition()
  local displayInfoList = self.m_rankListData:GetViewData()
  self:SetListItemTitleInfo(displayInfoList.title)
  for i = 1, itemAmount do
    local displayInfo = displayInfoList[i]
    self:SetListItemInfo(i, displayInfo)
  end
  local rank = SelfRankMgr.Instance():GetSelfRank(self.m_rankListData)
  self:SetSelfRank(rank)
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number", "table").SetListItemInfo = function(self, index, displayInfo)
  local rank, p2, p3, p4, stepInfo = unpack(displayInfo)
  local listItem = self.uiObjs.ListRight:FindDirect("item_" .. index)
  listItem:FindDirect("Label_1"):GetComponent("UILabel").text = rank
  listItem:FindDirect("Label_2"):GetComponent("UILabel").text = p2
  listItem:FindDirect("Label_3"):GetComponent("UILabel").text = p3
  listItem:FindDirect("Label_4"):GetComponent("UILabel").text = p4
  local Img_MingCiChange = listItem:FindDirect("Img_MingCiChange")
  local LabelObj = Img_MingCiChange:FindDirect("Label")
  LabelObj:GetComponent("UILabel").text = ""
  local uiSprite = Img_MingCiChange:GetComponent("UISprite")
  uiSprite.spriteName = "nil"
  local Img_MingCi = listItem:FindDirect("Img_MingCi")
  if rank <= 3 then
    local uiSprite = Img_MingCi:GetComponent("UISprite")
    uiSprite.spriteName = RankListPanel.Top3IconName[rank]
    listItem:FindDirect("Label_1"):SetActive(false)
  else
    local uiSprite = Img_MingCi:GetComponent("UISprite")
    uiSprite.spriteName = "nil"
    if stepInfo.isNew then
      local uiSprite = Img_MingCiChange:GetComponent("UISprite")
      uiSprite.spriteName = RankListPanel.NEW_ICON_NAME
    else
      local step = stepInfo.step
      local spriteName = "nil"
      local stepText = ""
      if step > 0 then
        spriteName = RankListPanel.UP_ARROW_NAME
        stepText = step
      elseif step < 0 then
        spriteName = RankListPanel.DOWN_ARROW_NAME
        stepText = math.abs(step)
      end
      local uiSprite = Img_MingCiChange:GetComponent("UISprite")
      uiSprite.spriteName = spriteName
      LabelObj:GetComponent("UILabel").text = stepText
    end
  end
end
def.method("table").SetListItemTitleInfo = function(self, titleInfo)
  local Group = self.uiObjs.Group_Detail:FindDirect("Group_Title/Img_BgTitle/Group")
  for i = 1, 4 do
    Group:FindDirect("Label" .. i):GetComponent("UILabel").text = titleInfo[i]
  end
end
def.method("number").OnSubTabButtonClicked = function(self, index)
  self:SelectRankList(index)
end
def.method("number").SelectRankList = function(self, index)
  self.selectedRankListIndex = index
  self.displayInfo = RankListPanel.DisplayInfoEnum.Detail
  self:UpdateSelectedRankList()
end
def.method().ShowNoDataInfo = function(self)
  self.uiObjs.Group_Detail:SetActive(false)
  self.uiObjs.Group_Three:SetActive(false)
  self.uiObjs.Group_NoData:SetActive(true)
  self:SetSelfRank(SelfRankMgr.OUT_OF_RANK_LIST)
end
def.method().ShowDetailInfo = function(self)
  self.uiObjs.Group_Detail:SetActive(true)
  self.uiObjs.Group_Three:SetActive(false)
  self.uiObjs.Group_NoData:SetActive(false)
  self:SetSelfRank(SelfRankMgr.OUT_OF_RANK_LIST)
end
def.method("number").SetSelfRank = function(self, rank)
  local text = tostring(rank)
  if rank == SelfRankMgr.OUT_OF_RANK_LIST then
    text = textRes.RankList[1]
  end
  local label = self.uiObjs.Img_BgBottom:FindDirect("Group_Message/Label_Content2"):GetComponent("UILabel")
  label.text = text
end
def.method().OnSwitchDisplayInfoButtonClicked = function(self)
  if self.rankListData == nil or #self.rankListData.list == 0 then
    return
  end
  if self.displayInfo == RankListPanel.DisplayInfoEnum.Detail then
    self.displayInfo = RankListPanel.DisplayInfoEnum.Top3
    self:ShowTop3Info()
  else
    self.displayInfo = RankListPanel.DisplayInfoEnum.Detail
    self:ShowDetailInfo()
  end
  self:UpdateSwitchButtonText()
end
def.method().ShowTop3Info = function(self)
  self.uiObjs.Group_Detail:SetActive(false)
  self.uiObjs.Group_Three:SetActive(true)
  self.uiObjs.Group_NoData:SetActive(false)
  local displayData = Top3Mgr.Instance():GetTop3DisplayData(self.rankListData)
  local modelCount = 3
  for i = modelCount, 1, -1 do
    self:SetModel(i, displayData[i])
  end
end
def.method().HideTop3Info = function(self)
  self.uiObjs.Group_Three:SetActive(false)
end
def.method().UpdateSwitchButtonText = function(self)
  if self.displayInfo == RankListPanel.DisplayInfoEnum.Top3 then
    self:SetSwitchButtonText(textRes.RankList[4])
  else
    self:SetSwitchButtonText(textRes.RankList[3])
  end
end
def.method("string").SetSwitchButtonText = function(self, text)
  local label = self.uiObjs.Img_BgBottom:FindDirect("Btn_Change/Label"):GetComponent("UILabel")
  label.text = text
end
def.method("number", "table").SetModel = function(self, i, top3Data)
  if top3Data == nil then
    self:ShowEmptyModel(i)
    return
  end
  local modelObj = self.uiObjs.Group_Three:FindDirect("Model" .. i)
  local uiModel = modelObj:GetComponent("UIModel")
  local modelId = top3Data.modelId
  local modelPath = _G.GetModelPath(modelId)
  if self.models[i] ~= nil then
    self.models[i]:Destroy()
    self.models[i] = nil
  end
  self.models[i] = ECUIModel.new(modelId)
  self.models[i]:LoadUIModel(modelPath, function(ret)
    if ret == nil then
      return
    end
    local m = self.models[i].m_model
    uiModel.modelGameObject = m
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
      camera.depth = camera.depth
    end
    self.models[i]:SetDir(180)
    if top3Data.weaponId then
      local qiLingLevel = top3Data.weaponQiLingLevel or 0
      self.models[i]:SetWeapon(top3Data.weaponId, qiLingLevel)
    end
    local colorId = top3Data.colorId
    if colorId then
      if colorId > 0 then
        local colorcfg = GetModelColorCfg(colorId)
        self.models[i]:SetColoration(colorcfg)
      else
        self.models[i]:SetColoration(nil)
      end
    end
  end)
  local titleName = textRes.RankList.Title[top3Data.type][4]
  local valueText = string.format(textRes.RankList[2], titleName) .. top3Data.value
  modelObj:FindDirect("Label1"):GetComponent("UILabel").text = valueText
  modelObj:FindDirect("Label2"):GetComponent("UILabel").text = top3Data.name
end
def.method("number").ShowEmptyModel = function(self, i)
  if self.models[i] ~= nil then
    self.models[i]:Destroy()
    self.models[i] = nil
  end
  local modelObj = self.uiObjs.Group_Three:FindDirect("Model" .. i)
  modelObj:FindDirect("Label1"):GetComponent("UILabel").text = textRes.RankList[5]
  modelObj:FindDirect("Label2"):GetComponent("UILabel").text = textRes.RankList[5]
end
def.method().ResumeModels = function(self)
  if self.models == nil then
    return
  end
  for i, model in ipairs(self.models) do
    model:Play(ActionName.Stand)
  end
end
def.method("string").onDragStart = function(self, id)
  self.dragObjId = id
end
def.method("string").onDragEnd = function(self, id)
  self.dragObjId = ""
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if string.sub(id, 1, #"Model") ~= "Model" then
    return
  end
  local index = tonumber(string.sub(id, #"Model" + 1, -1))
  if self.models[index] then
    self.models[index]:SetDir(self.models[index].m_ang - dx / 2)
  end
end
def.method("number").OnRankItemClicked = function(self, index)
  local rankData = self.rankListData.list[index]
  RankUnitInfoMgr.Instance():ShowUnitInfo(self.rankListData.type, rankData)
end
def.method().OnTipsButtonClicked = function(self)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local rankList = self.rankListClasses[self.rankClassIndex][self.selectedRankListIndex]
  warn("TIP", rankList.timeCfgId)
  local timeCfgId = rankList.timeCfgId or 0
  local timeCfg = TimeCfgUtils.GetTimeCommonCfg(timeCfgId)
  local text = textRes.RankList.Tips[rankList.type]
  local timeStr = self:GetFormatTimeStr(timeCfg)
  text = string.format(string.format(text, timeStr))
  local tmpPosition = {x = 0, y = 0}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  CommonDescDlg.ShowCommonTip(text, tmpPosition)
end
def.method("table", "=>", "string").GetFormatTimeStr = function(self, timeCfg)
  if timeCfg == nil then
    return "[no value]"
  end
  local str = ""
  if timeCfg.activeWeekDay == 0 then
    str = str .. textRes.activity[21]
  else
    str = str .. textRes.activity[29] .. textRes.activity[29 - timeCfg.activeWeekDay]
  end
  str = str.format("%s%02d:%02d", str, timeCfg.activeHour, timeCfg.activeMinute)
  return str
end
def.method("number").OnModelClicked = function(self, index)
  local rankData = self.rankListData.list[index]
  if rankData == nil then
    return
  end
  RankUnitInfoMgr.Instance():ShowUnitInfo(self.rankListData.type, rankData)
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.lastRankClassIndex = 0
  self.displayInfo = RankListPanel.DisplayInfoEnum.Detail
  if self.models then
    for i, model in ipairs(self.models) do
      model:Destroy()
    end
  end
  self.models = {}
end
return CommonView.Commit()
