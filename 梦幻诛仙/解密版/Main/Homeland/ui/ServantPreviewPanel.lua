local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ServantPreviewPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local HouseMgr = require("Main.Homeland.HouseMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local ServantRoomMgr = require("Main.Homeland.Rooms.ServantRoomMgr")
local ECUIModel = require("Model.ECUIModel")
local NPCInterface = require("Main.npc.NPCInterface")
local def = ServantPreviewPanel.define
def.const("number").NUM_PER_PAGE = 3
def.field("table").m_UIGOs = nil
def.field("number").m_curPage = 1
def.field("table").m_previewList = nil
def.field("table").m_models = nil
def.field("number").m_curModelIndex = 1
def.field("table").m_currency = nil
local instance
def.static("=>", ServantPreviewPanel).Instance = function()
  if instance == nil then
    instance = ServantPreviewPanel()
    instance:Init()
  end
  return instance
end
def.static().ShowPanel = function()
  local self = ServantPreviewPanel.Instance()
  if self.m_panel then
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SERVANT_PREVIEW_PANEL, 1)
end
def.method().Init = function(self)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Hire_Servant_Success, ServantPreviewPanel.OnUpdateServantInfos)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Change_Servant_Success, ServantPreviewPanel.OnUpdateServantInfos)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, ServantPreviewPanel.OnLeaveHomeland)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, ServantPreviewPanel.OnLoseHomelandControl)
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  if self.m_models then
    for i, v in ipairs(self.m_models) do
      v:Destroy()
    end
    self.m_models = nil
  end
  if self.m_currency then
    self.m_currency:UnregisterCurrencyChangedEvent(ServantPreviewPanel.OnCurrencyChanged)
    self.m_currency = nil
  end
  self.m_curModelIndex = 1
  self.m_curPage = 1
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Hire_Servant_Success, ServantPreviewPanel.OnUpdateServantInfos)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Change_Servant_Success, ServantPreviewPanel.OnUpdateServantInfos)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, ServantPreviewPanel.OnLeaveHomeland)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, ServantPreviewPanel.OnLoseHomelandControl)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateServantInfos()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Left" then
    self:PrevPage()
  elseif id == "Btn_Right" then
    self:NextPage()
  elseif string.find(id, "Model_Yongren_") then
    local index = tonumber(string.sub(id, #"Model_Yongren_" + 1, -1))
    if index then
      self:SelectModel(index)
    end
  elseif string.find(id, "Btn_Buy_") then
    local index = tonumber(string.sub(id, #"Btn_Buy_" + 1, -1))
    if index then
      self:SelectModel(index)
      self:OnHireBtnClick()
    end
  elseif string.find(id, "Btn_Change_") then
    local index = tonumber(string.sub(id, #"Btn_Change_" + 1, -1))
    if index then
      self:SelectModel(index)
      self:OnChangeBtnClick()
    end
  elseif id == "Btn_Hire" then
    self:OnHireBtnClick()
  elseif id == "Btn_Tips" then
    self:OnTipsBtnClick()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Group_List = self.m_UIGOs.Img_Bg0:FindDirect("Group_List")
  self.m_UIGOs.Group_HaveMoney = self.m_UIGOs.Img_Bg0:FindDirect("Group_HaveMoney")
  self.m_UIGOs.ScrollView = self.m_UIGOs.Group_List:FindDirect("Scroll View")
  self.m_UIGOs.Btn_Right = self.m_UIGOs.Group_List:FindDirect("Btn_Right")
  self.m_UIGOs.Btn_Left = self.m_UIGOs.Group_List:FindDirect("Btn_Left")
  self.m_UIGOs.List = self.m_UIGOs.ScrollView:FindDirect("List")
  local uiList = self.m_UIGOs.List:GetComponent("UIList")
  uiList.itemCount = ServantPreviewPanel.NUM_PER_PAGE
  uiList:Resize()
  uiList:Reposition()
  self.m_msgHandler:Touch(self.m_UIGOs.List)
  self.m_previewList = ServantRoomMgr.Instance():GetPreviewServantList()
  self:SelectModel(self.m_curModelIndex)
end
def.method().UpdateUI = function(self)
  self:UpdateServantInfos()
end
def.method().UpdateServantInfos = function(self)
  local curPage = self.m_curPage
  for i = 1, ServantPreviewPanel.NUM_PER_PAGE do
    local previewIndex = (curPage - 1) * ServantPreviewPanel.NUM_PER_PAGE + i
    local servantInfo = self.m_previewList[previewIndex]
    local itemObj = self.m_UIGOs.List:FindDirect("House_" .. i)
    self:SetServantInfo(i, itemObj, servantInfo)
  end
  self:UpdatePageInfo()
  self:UpdateCurIndexInfo()
end
def.method("number", "userdata", "table").SetServantInfo = function(self, index, itemObj, servantInfo)
  local Label_Name = itemObj:FindDirect("Label_Name_" .. index)
  local Label_Level = itemObj:FindDirect("Label_Level_" .. index)
  local Model_Yongren = itemObj:FindDirect("Model_Yongren_" .. index)
  local Btn_Buy = itemObj:FindDirect("Btn_Buy_" .. index)
  local Btn_Change = itemObj:FindDirect("Btn_Change_" .. index)
  local Label_Using = itemObj:FindDirect("Label_" .. index)
  local canShow = servantInfo ~= nil
  GUIUtils.SetActive(Label_Name, canShow)
  GUIUtils.SetActive(Label_Level, canShow)
  GUIUtils.SetActive(Model_Yongren, canShow)
  GUIUtils.SetActive(Btn_Buy, canShow)
  GUIUtils.SetActive(Btn_Change, canShow)
  GUIUtils.SetActive(Label_Using, canShow)
  if servantInfo == nil then
    return
  end
  local uiModel = Model_Yongren:GetComponent("UIModel")
  local servantCfg = HomelandUtils.GetServantCfg(servantInfo.servantID)
  local npcCfg = NPCInterface.GetNPCCfg(servantCfg.npcId)
  local modelId = 0
  local servantName = "nil"
  if npcCfg then
    modelId = npcCfg.monsterModelTableId
    if servantInfo.servantName == nil then
      servantName = npcCfg.npcName
    else
      servantName = servantInfo.servantName
    end
  end
  GUIUtils.SetText(Label_Name, servantName)
  local roomLevelName = string.format(textRes.Homeland[17], servantInfo.roomLevel)
  GUIUtils.SetText(Label_Level, roomLevelName)
  if ServantRoomMgr.Instance():IsServantWorking(servantInfo.servantID) then
    GUIUtils.SetActive(Btn_Buy, false)
    GUIUtils.SetActive(Btn_Change, false)
  elseif ServantRoomMgr.Instance():HasServantHired(servantInfo.servantID) then
    GUIUtils.SetActive(Btn_Buy, false)
    GUIUtils.SetActive(Label_Using, false)
  else
    GUIUtils.SetActive(Btn_Change, false)
    GUIUtils.SetActive(Label_Using, false)
    local Label_Number = Btn_Buy:FindDirect("Label_Number_" .. index)
    local Sprite = Btn_Buy:FindDirect("Sprite_" .. index)
    local costMoneyType = servantCfg.costMoneyType
    local costMoneyNum = servantCfg.costMoneyNum
    local currency = CurrencyFactory.Create(costMoneyType)
    local spriteName = currency:GetSpriteName()
    GUIUtils.SetText(Label_Number, costMoneyNum)
    GUIUtils.SetSprite(Sprite, spriteName)
  end
  self.m_models = self.m_models or {}
  local lastModelId
  if self.m_models[index] then
    lastModelId = self.m_models[index].mModelId
    if lastModelId == modelId then
      self.m_models[index]:Play(_G.ActionName.Stand)
      return
    else
      self.m_models[index]:Destroy()
    end
  end
  local path = _G.GetModelPath(modelId)
  local model = ECUIModel.new(modelId)
  model:LoadUIModel(path, function(ret)
    if ret == nil then
      return
    end
    if uiModel.isnil then
      return
    end
    local m = model.m_model
    uiModel.modelGameObject = m
    uiModel.mCanOverflow = true
  end)
  self.m_models[index] = model
end
def.method().UpdatePageInfo = function(self)
  local canLeftBtnShow = not self:IsTheFirstPage()
  local canRightBtnShow = not self:IsTheLastPage()
  GUIUtils.SetActive(self.m_UIGOs.Btn_Left, canLeftBtnShow)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Right, canRightBtnShow)
end
def.method().UpdateCurIndexInfo = function(self)
  local index = self:GetCurPreviewIndex()
  local servantInfo = self.m_previewList[index]
  if servantInfo == nil then
    return
  end
  local servantCfg = HomelandUtils.GetServantCfg(servantInfo.servantID)
  local costMoneyType = servantCfg.costMoneyType
  local costMoneyNum = servantCfg.costMoneyNum
  if self.m_currency then
    self.m_currency:UnregisterCurrencyChangedEvent(ServantPreviewPanel.OnCurrencyChanged)
  end
  local currency = CurrencyFactory.Create(costMoneyType)
  self.m_currency = currency
  self.m_currency:RegisterCurrencyChangedEvent(ServantPreviewPanel.OnCurrencyChanged)
  self:UpdateCurrencyInfo()
end
def.method().UpdateCurrencyInfo = function(self)
  local currency = self.m_currency
  if currency == nil then
    return
  end
  local Label_HaveMoneyNum = self.m_UIGOs.Group_HaveMoney:FindDirect("Label_HaveMoneyNum")
  local Img_HaveMoneyIcon = self.m_UIGOs.Group_HaveMoney:FindDirect("Img_HaveMoneyIcon")
  local haveNum = currency:GetHaveNum()
  local spriteName = currency:GetSpriteName()
  GUIUtils.SetText(Label_HaveMoneyNum, tostring(haveNum))
  GUIUtils.SetSprite(Img_HaveMoneyIcon, spriteName)
end
def.method("=>", "number").GetCurPreviewIndex = function(self)
  local curPage = self.m_curPage
  local i = self.m_curModelIndex
  return (curPage - 1) * ServantPreviewPanel.NUM_PER_PAGE + i
end
def.method().PrevPage = function(self)
  if self:IsTheFirstPage() then
    Toast("This the first page!")
    return
  end
  self.m_curPage = self.m_curPage - 1
  self:SelectModel(ServantPreviewPanel.NUM_PER_PAGE)
  self:UpdateServantInfos()
end
def.method().NextPage = function(self)
  if self:IsTheLastPage() then
    Toast("This is the last page")
    return
  end
  self.m_curPage = self.m_curPage + 1
  self:SelectModel(1)
  self:UpdateServantInfos()
end
def.method("=>", "boolean").IsTheFirstPage = function(self)
  if self.m_curPage == 1 then
    return true
  end
  return false
end
def.method("=>", "boolean").IsTheLastPage = function(self)
  local totalPage = self:GetTotalPage()
  if self.m_curPage == totalPage then
    return true
  end
  return false
end
def.method("=>", "number").GetTotalPage = function(self)
  local totalPage = math.ceil(#self.m_previewList / ServantPreviewPanel.NUM_PER_PAGE)
  return totalPage
end
def.method("string").onDragStart = function(self, id)
end
def.method("string").onDragEnd = function(self, id)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if string.find(id, "Model_Yongren_") then
    local index = tonumber(string.sub(id, #"Model_Yongren_" + 1, -1))
    local model
    if self.m_models and index then
      model = self.m_models[index]
    end
    if model then
      model:SetDir(model.m_ang - dx / 2)
    end
  end
end
def.method("number").SelectModel = function(self, index)
  self.m_curModelIndex = index
  self:UpdateCurIndexInfo()
  for i = 1, ServantPreviewPanel.NUM_PER_PAGE do
    local HouseGO = self.m_UIGOs.List:FindDirect("House_" .. i)
    local Img_Selected = HouseGO:FindDirect("Img_Selected_" .. i)
    GUIUtils.SetActive(Img_Selected, i == index)
  end
end
def.method().OnHireBtnClick = function(self)
  local index = self:GetCurPreviewIndex()
  local servantInfo = self.m_previewList[index]
  if servantInfo == nil then
    return
  end
  local servantID = servantInfo.servantID
  if ServantRoomMgr.Instance():HasServantHired(servantID) then
    Toast(textRes.Homeland[18])
    return
  end
  local servantCfg = HomelandUtils.GetServantCfg(servantInfo.servantID)
  local costMoneyType = servantCfg.costMoneyType
  local costMoneyNum = Int64.new(servantCfg.costMoneyNum)
  local currency = CurrencyFactory.Create(costMoneyType)
  local haveNum = currency:GetHaveNum()
  local currencyName = currency:GetName()
  if costMoneyNum > haveNum then
    currency:AcquireWithQuery()
    return
  end
  local npcCfg = NPCInterface.GetNPCCfg(servantCfg.npcId)
  local servantName = "nil"
  if npcCfg then
    servantName = npcCfg.npcName
  end
  local title = textRes.Homeland[19]
  local desc = string.format(textRes.Homeland[20], tostring(costMoneyNum), currencyName, servantName)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(title, desc, function(s)
    if s == 1 then
      ServantRoomMgr.Instance():HireServant(servantID)
    end
  end, nil)
end
def.method().OnChangeBtnClick = function(self)
  local index = self:GetCurPreviewIndex()
  local servantInfo = self.m_previewList[index]
  if servantInfo == nil then
    return
  end
  local servantID = servantInfo.servantID
  ServantRoomMgr.Instance():ChangeServant(servantID)
end
def.method().OnTipsBtnClick = function(self)
  local tipId = 701605016
  require("Main.Common.TipsHelper").ShowHoverTip(tipId, 0, 0)
end
def.static("table", "table").OnCurrencyChanged = function()
  instance:UpdateCurrencyInfo()
end
def.static("table", "table").OnUpdateServantInfos = function()
  instance:UpdateServantInfos()
end
def.static("table", "table").OnLeaveHomeland = function()
  instance:DestroyPanel()
end
def.static("table", "table").OnLoseHomelandControl = function()
  instance:DestroyPanel()
end
return ServantPreviewPanel.Commit()
