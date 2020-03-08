local Lplus = require("Lplus")
local TaskModule = Lplus.ForwardDeclare("TaskModule")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local UIModelWrap = require("Model.UIModelWrap")
local QingyunHistory = Lplus.Extend(ECPanelBase, "QingyunHistory")
local def = QingyunHistory.define
local _inst
local TaskInterface = require("Main.task.TaskInterface")
local taskInterface = TaskInterface.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local ECModel = require("Model.ECModel")
local GUIUtils = require("GUI.GUIUtils")
def.static("=>", QingyunHistory).Instance = function()
  if _inst == nil then
    _inst = QingyunHistory()
    _inst:_Init()
  end
  return _inst
end
def.field("number")._page = 0
def.field("table")._tableCfgs = nil
def.field("table")._tableChapterCfgs = nil
def.field("number")._chapterCount = 0
def.field("table")._models = nil
def.field("number")._timerID = 0
def.field("boolean").isshowing = false
def.method()._Init = function(self)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_QinyunHistoryChanged, QingyunHistory.OnQinyunHistoryChanged)
  self.m_TrigGC = true
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_QINYUN_HISTORY, 0)
  end
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  local ScrollView = self.m_panel:FindDirect("Scroll View")
  local Group_Section1 = self.m_panel:FindDirect("Scroll View/Group_Content/Scroll View/Grid/Group_Section1")
  Group_Section1:set_name("Group_Section_1")
  local Img_BgPrize = Group_Section1:FindDirect("Img_BgPrize")
  Img_BgPrize:set_name("Img_BgPrize_1")
  self._models = {}
  local Tab_Section = ScrollView:FindDirect("Container/Tab_Section")
  Tab_Section:SetActive(false)
  Tab_Section:FindDirect("Img_Select"):SetActive(true)
  local Tab_Movie = ScrollView:FindDirect("Container/Tab_Movie")
  Tab_Movie:SetActive(false)
  Tab_Movie:FindDirect("Img_Select"):SetActive(false)
  local Grid = self.m_panel:FindDirect("Img_Bg0/Group_Content/Scroll View/Grid")
  self._timerID = GameUtil.AddGlobalTimer(1.4, true, QingyunHistory._OnTimer)
end
def.override().OnDestroy = function(self)
  self:DestroyModels()
  ECGUIMan.Instance():ShowAllUIExceptMe(true, self)
  self.isshowing = false
end
def.method().DestroyModels = function(self)
  for k, v in pairs(self._models) do
    v:Destroy()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:_LoadCfg()
    self:_FillPageSpot()
    self:_FillCurr()
    ECGUIMan.Instance():ShowAllUIExceptMe(false, self)
  else
    ECGUIMan.Instance():ShowAllUIExceptMe(true, self)
  end
end
def.method("string").onClick = function(self, id)
  local fnTable = {}
  fnTable.Btn_Close = QingyunHistory.OnBtn_Close
  fnTable.Btn_Left = QingyunHistory.OnBtn_Left
  fnTable.Btn_Right = QingyunHistory.OnBtn_Right
  fnTable.Tab_Section = QingyunHistory.OnTab_Section
  fnTable.Tab_Movie = QingyunHistory.OnTab_Movie
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
    return
  end
  local strs = string.split(id, "_")
  if strs[1] == "Group" and strs[2] == "Section" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:_OnItemClick(index)
    end
  elseif strs[1] == "Img" and strs[2] == "BgPrize" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:_OnAwardItemClick(index)
    end
  end
end
def.method().OnBtn_Close = function(self)
  self:HideDlg()
end
def.method().OnBtn_Left = function(self)
  self:_PageUp()
  self:_Fill()
end
def.method().OnBtn_Right = function(self)
  self:_PageDown()
  self:_Fill()
end
def.method().OnTab_Section = function(self)
  local ScrollView = self.m_panel:FindDirect("Scroll View")
  local Tab_Section = ScrollView:FindDirect("Container/Tab_Section")
  Tab_Section:FindDirect("Img_Select"):SetActive(true)
end
def.method().OnTab_Movie = function(self)
  Toast(textRes.Common[10])
end
def.method("number")._OnItemClick = function(self, index)
  local chapterCfgs = self._tableChapterCfgs[self._page]
  local sectionCfgs = chapterCfgs[index]
  local currChapterNum = 0
  local currNodeNum = 0
  currChapterNum, currNodeNum = taskInterface:GetQingyunHistoryInfo()
  if self._page == currChapterNum and index == currNodeNum then
    local infos = taskInterface:GetTaskInfos()
    for taskId, graphIdValue in pairs(infos) do
      for graphId, info in pairs(graphIdValue) do
        if graphId == sectionCfgs.graphId then
          Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskFindPath, {taskId, graphId})
          self:HideDlg()
          return
        end
      end
    end
  end
  if currChapterNum <= self._page and index > currNodeNum then
    Toast(string.format(textRes.activity[162], sectionCfgs.openLevel))
  end
end
def.method("number")._OnAwardItemClick = function(self, index)
  local Grid = self.m_panel:FindDirect("Scroll View/Group_Content/Scroll View/Grid")
  local Group_Section = Grid:FindDirect(string.format("Group_Section_%d", index))
  local Img_BgPrize = Group_Section:FindDirect(string.format("Img_BgPrize_%d", index))
  local position = Img_BgPrize:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = Img_BgPrize:GetComponent("UISprite")
  local chapterCfgs = self._tableChapterCfgs[self._page]
  local sectionCfgs = chapterCfgs[index]
  local currChapterNum = 0
  local currNodeNum = 0
  currChapterNum, currNodeNum = taskInterface:GetQingyunHistoryInfo()
  local isCurrent = currChapterNum == self._page and index == currNodeNum
  local enabled = currChapterNum > self._page or self._page == currChapterNum and index <= currNodeNum
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local ItemUtils = require("Main.Item.ItemUtils")
  local takeItemBase = ItemUtils.GetItemBase(sectionCfgs.awardItemId)
  if takeItemBase ~= nil then
    if enabled == true and isCurrent == false then
      ItemTipsMgr.Instance():ShowBasicTipsAddDesc(sectionCfgs.awardItemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false, textRes.activity[160])
    else
      ItemTipsMgr.Instance():ShowBasicTipsAddDesc(sectionCfgs.awardItemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false, textRes.activity[161])
    end
  else
    ItemTipsMgr.Instance():ShowItemFilterTips(sectionCfgs.awardItemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
  end
end
def.method()._LoadCfg = function(self)
  self._tableCfgs = {}
  self._tableChapterCfgs = {}
  self._chapterCount = 0
  local entries = DynamicData.GetTable(CFG_PATH.DATA_TASK_QINYUNHISTORY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = DynamicRecord.GetIntValue(entry, "id")
    cfg.awardItemId = DynamicRecord.GetIntValue(entry, "awardIconId")
    cfg.chapterNum = DynamicRecord.GetIntValue(entry, "chapterNum")
    cfg.graphId = DynamicRecord.GetIntValue(entry, "graphId")
    cfg.nodeIconId = DynamicRecord.GetIntValue(entry, "nodeIconId")
    cfg.nodeNum = DynamicRecord.GetIntValue(entry, "nodeNum")
    cfg.openLevel = DynamicRecord.GetIntValue(entry, "openLevel")
    cfg.chapterName = DynamicRecord.GetStringValue(entry, "chapterName")
    cfg.nodeName = DynamicRecord.GetStringValue(entry, "nodeName")
    local chapter = self._tableChapterCfgs[cfg.chapterNum]
    if chapter == nil then
      chapter = {}
      self._tableChapterCfgs[cfg.chapterNum] = chapter
      self._chapterCount = self._chapterCount + 1
    end
    chapter[cfg.nodeNum] = cfg
    self._tableCfgs[cfg.id] = cfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method()._PageUp = function(self)
  if self._page > 1 then
    self._page = self._page - 1
  end
end
def.method()._PageDown = function(self)
  if self._page < self._chapterCount then
    self._page = self._page + 1
  end
end
def.method()._FillCurr = function(self)
  local currChapterNum = 0
  local currNodeNum = 0
  currChapterNum, currNodeNum = taskInterface:GetQingyunHistoryInfo()
  self._page = currChapterNum
  self:_Fill()
end
def.method()._Fill = function(self)
  local currChapterNum = 0
  local currNodeNum = 0
  currChapterNum, currNodeNum = taskInterface:GetQingyunHistoryInfo()
  local Group_Btn = self.m_panel:FindDirect("Group_Btn")
  local Btn_Left = Group_Btn:FindDirect("Btn_Left")
  local Btn_Right = Group_Btn:FindDirect("Btn_Right")
  Btn_Left:GetComponent("UIButton"):set_isEnabled(self._page > 1)
  Btn_Right:GetComponent("UIButton"):set_isEnabled(self._page < self._chapterCount)
  self:_SetSelectedPageSpot(self._page)
  local chapterCfgs = self._tableChapterCfgs[self._page]
  local sectionCfgs = chapterCfgs[currNodeNum]
  local ScrollView = self.m_panel:FindDirect("Scroll View")
  local Img_BgSection = ScrollView:FindDirect("Img_BgSection")
  local Label_Section = Img_BgSection:FindDirect("Label_Section")
  local sprite = Label_Section:GetComponent("UISprite")
  sprite:set_spriteName(string.format("Chapter_%02d", self._page))
  local Grid = ScrollView:FindDirect("Group_Content/Scroll View/Grid")
  local count = Grid:get_childCount()
  count = math.max(count, #chapterCfgs)
  for i = 1, count do
    local v = chapterCfgs[i]
    if v ~= nil then
      local isCurrent = currChapterNum == self._page and v.nodeNum == currNodeNum
      local enabled = currChapterNum > self._page or self._page == currChapterNum and currNodeNum >= v.nodeNum
      self:_Additem(i, v, isCurrent, enabled)
    else
      self:_HideItem(i)
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number", "table", "boolean", "boolean")._Additem = function(self, index, sectionCfg, isCurr, enabled)
  local ScrollView = self.m_panel:FindDirect("Scroll View")
  local Grid = ScrollView:FindDirect("Group_Content/Scroll View/Grid")
  local grid = Grid:GetComponent("UIGrid")
  local Group_Section_1 = Grid:FindDirect("Group_Section_1")
  local parent = Group_Section_1.parent
  local Group_Section = Grid:FindDirect(string.format("Group_Section_%d", index))
  if Group_Section ~= nil then
    Group_Section:SetActive(true)
  else
    Group_Section = Object.Instantiate(Group_Section_1)
    Group_Section:set_name(string.format("Group_Section_%d", index))
    Group_Section.parent = parent
    Group_Section:set_localScale(Vector.Vector3.one)
    local Img_BgPrize = Group_Section:FindDirect("Img_BgPrize_1")
    Img_BgPrize:set_name(string.format("Img_BgPrize_%d", index))
    grid:Reposition()
  end
  local Img_BgSection = Group_Section:FindDirect("Img_BgSection")
  local Img_BgGray = Group_Section:FindDirect("Img_BgGray")
  Img_BgSection:SetActive(enabled == true)
  Img_BgGray:SetActive(enabled == false)
  local Label_Name = Group_Section:FindDirect("Img_BgName/Label_Name")
  Label_Name:GetComponent("UILabel"):set_text(sectionCfg.nodeName)
  local Img_BgNow = Group_Section:FindDirect("Img_BgNow")
  Img_BgNow:SetActive(isCurr)
  local Model = Group_Section:FindDirect("Model")
  local uiModel = Model:GetComponent("UIModel")
  local theModel = self._models[index]
  local modelPath = GetModelPath(sectionCfg.nodeIconId)
  if theModel == nil then
    theModel = UIModelWrap.new(uiModel)
    self._models[index] = theModel
  end
  theModel:SetColored(enabled == true)
  theModel:SetAutoAdjustScale(true)
  theModel:Load(modelPath)
  local Img_BgPrize = Group_Section:FindDirect(string.format("Img_BgPrize_%d", index))
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(sectionCfg.awardItemId)
  if itemBase ~= nil then
    Img_BgPrize:SetActive(true)
    local uiSprite = Img_BgPrize:GetComponent("UISprite")
    local Texture_Prize = Img_BgPrize:FindDirect("Texture_Prize")
    local uiTexture = Texture_Prize:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    if enabled == true then
      uiSprite:set_spriteName("Img_BgPrize")
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
    else
      uiSprite:set_spriteName("Img_BgPrize_2")
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
    end
  else
    Img_BgPrize:SetActive(false)
  end
end
def.method("number")._HideItem = function(self, index)
  local ScrollView = self.m_panel:FindDirect("Scroll View")
  local Grid = ScrollView:FindDirect("Group_Content/Scroll View/Grid")
  local Group_Section = Grid:FindDirect(string.format("Group_Section_%d", index))
  if Group_Section ~= nil then
    local theModel = self._models[index]
    if theModel ~= nil then
      theModel:Destroy()
    end
    Group_Section:SetActive(false)
  end
end
def.method()._FillPageSpot = function(self)
  local ScrollView = self.m_panel:FindDirect("Scroll View")
  local Grid_Pages = ScrollView:FindDirect("Grid_Pages")
  local grid = Grid_Pages:GetComponent("UIGrid")
  local Img_Pages1 = Grid_Pages:FindDirect("Img_Pages00")
  for i = 1, self._chapterCount do
    local Img_Pages = Grid_Pages:FindDirect(string.format("Img_Pages%02d", i - 1))
    if Img_Pages == nil then
      Img_Pages = Object.Instantiate(Img_Pages1)
      Img_Pages.parent = Img_Pages1.parent
      Img_Pages:set_name(string.format("Img_Pages%02d", i - 1))
      Img_Pages:set_localScale(Vector.Vector3.one)
    end
  end
  grid:Reposition()
end
def.method("number")._SetSelectedPageSpot = function(self, index)
  local ScrollView = self.m_panel:FindDirect("Scroll View")
  local Grid_Pages = ScrollView:FindDirect("Grid_Pages")
  local count = Grid_Pages:get_childCount()
  for i = 1, count do
    local Img_Pages = Grid_Pages:FindDirect(string.format("Img_Pages%02d", i - 1))
    local Img_SelectPages = Img_Pages:FindDirect("Img_SelectPages")
    Img_SelectPages:SetActive(index == i)
  end
end
def.static()._OnTimer = function()
  local self = _inst
  for k, theModel in pairs(self._models) do
    if theModel ~= nil and theModel._model ~= nil and theModel._model.m_model ~= nil then
      theModel._model:Play("Stand_c")
    end
  end
end
def.static("table", "table").OnQinyunHistoryChanged = function(p1, p2)
  local self = _inst
  local chapterNum = p1[1]
  local nodeNum = p1[2]
  if self:IsShow() == true and (chapterNum == self._page or nodeNum == 1 and chapterNum - 1 == self._page) then
    self:_Fill()
  end
end
QingyunHistory.Commit()
return QingyunHistory
