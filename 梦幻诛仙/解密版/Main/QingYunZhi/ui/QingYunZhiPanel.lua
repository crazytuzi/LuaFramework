local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local QingYunZhiPanel = Lplus.Extend(ECPanelBase, "QingYunZhiPanel")
local QingYunZhiUtils = require("Main.QingYunZhi.QingYunZhiUtils")
local ECUIModel = require("Model.ECUIModel")
local QingYunZhiModule = Lplus.ForwardDeclare("QingYunZhiModule")
local QingYunZhiData = require("Main.QingYunZhi.data.QingYunZhiData")
local QingYunZhiProtocol = require("Main.QingYunZhi.QingYunZhiProtocol")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = QingYunZhiPanel.define
local instance
local QINGYUNZHI_TYPE = QingYunZhiData.QINGYUNZHI_TYPE
def.field("table").uiTbl = nil
def.field("table").dataCfg = nil
def.field("table").curChapter = nil
def.field("table").modelWrap = nil
def.field("number").curPage = 0
def.field("number").maxPage = 0
def.field("number").curSection = 0
def.field("number").curType = QINGYUNZHI_TYPE.NORMAL
def.field("table").uiStateInfo = nil
def.static("=>", QingYunZhiPanel).Instance = function()
  if not instance then
    instance = QingYunZhiPanel()
  end
  return instance
end
def.method().OnReset = function(self)
  self.uiStateInfo = nil
end
def.method("number").ShowPanel = function(self, showType)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.curType = showType
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_QINGYUNZHI_PANEL, GUILEVEL.MUTEX)
end
def.method().FightClosePanel = function(self)
  if self:IsShow() then
    self.uiStateInfo = {
      curType = self.curType,
      curChapter = self.curChapter,
      curSection = self.curSection
    }
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  self.dataCfg = QingYunZhiData.Instance()
  self:InitUI()
  self:showDefaultChapterPage()
  self.uiStateInfo = nil
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, QingYunZhiPanel.OnRoleLvUp)
end
def.override().OnDestroy = function(self)
  local Grid = self.uiTbl.Grid
  for i = 1, 5 do
    local Img_BgAnswer = Grid:FindDirect(("Img_BgAnswer%02d"):format(i))
    local uiModelCO = Img_BgAnswer:FindDirect("Model01"):GetComponent("UIModel")
    local modelWrap = self.modelWrap[i]
    if modelWrap ~= nil then
      modelWrap:Destroy()
      uiModelCO.modelGameObject = nil
      self.modelWrap[i] = nil
    end
  end
  self.curChapter = nil
  self.curPage = 0
  self.curSection = 0
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, QingYunZhiPanel.OnRoleLvUp)
end
def.override("boolean").OnShow = function(self, isShow)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self.uiStateInfo = nil
    self:DestroyPanel()
  elseif id == "Btn_Share" then
    self:onBtnShareClick()
  elseif id == "Tab_Common" then
    self:onBtnNormalClick()
  elseif id == "Tab_Elite" then
    self:onBtnEliteClick()
  elseif id == "Tab_Hero" then
    self:onBtnHeroClick()
  elseif id == "Btn_Fight" then
    self:onBtnFightClick()
  elseif id == "Btn_Right" then
    self:onBtnRightClick()
  elseif id == "Btn_Left" then
    self:onBtnLeftClick()
  elseif id == "Img_BgAnswer01" then
    self:onBtnSectionClick(1)
  elseif id == "Img_BgAnswer02" then
    self:onBtnSectionClick(2)
  elseif id == "Img_BgAnswer03" then
    self:onBtnSectionClick(3)
  elseif id == "Img_BgAnswer04" then
    self:onBtnSectionClick(4)
  elseif id == "Img_BgAnswer05" then
    self:onBtnSectionClick(5)
  elseif string.sub(id, 1, #"Img_Item") == "Img_Item" then
    self:OnItemClick(clickobj)
  else
    warn("qingyun panel btn:", id)
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  if not self.modelWrap then
    self.modelWrap = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Img_BgSection = Img_Bg:FindDirect("Img_BgSection")
  local Label_Level = Img_BgSection:FindDirect("Label_Level")
  local Tab_Elite = Img_Bg:FindDirect("Group_Btn/Tab_Elite")
  local Tab_Common = Img_Bg:FindDirect("Group_Btn/Tab_Common")
  local Tab_Hero = Img_Bg:FindDirect("Group_Btn/Tab_Hero")
  local Btn_Share = Img_Bg:FindDirect("Group_Btn/Btn_Share")
  local Btn_Left = Img_Bg:FindDirect("Group_Btn/Btn_Left")
  local Btn_Right = Img_Bg:FindDirect("Group_Btn/Btn_Right")
  local Label_Num = Label_Level:FindDirect("Label_Num")
  local Label_Section = Img_BgSection:FindDirect("Label_Section")
  uiTbl.Label_Level = Label_Num
  uiTbl.Label_Section = Label_Section
  uiTbl.Tab_Elite = Tab_Elite
  uiTbl.Btn_Left = Btn_Left
  uiTbl.Btn_Right = Btn_Right
  Tab_Elite:SetActive(true)
  Tab_Elite:GetComponent("UIToggle").value = self.curType == QINGYUNZHI_TYPE.ELITE
  Tab_Common:GetComponent("UIToggle").value = self.curType == QINGYUNZHI_TYPE.NORMAL
  Tab_Hero:GetComponent("UIToggle").value = self.curType == QINGYUNZHI_TYPE.HERO
  Btn_Share:SetActive(false)
  local Group_Content = Img_Bg:FindDirect("Group_Content")
  local Grid = Group_Content:FindDirect("Scroll View/Grid")
  local GridModel = {}
  local GridBgAnswer = {}
  for i = 1, 5 do
    local Img_BgAnswer = Grid:FindDirect(("Img_BgAnswer%02d"):format(i))
    local Model01 = Img_BgAnswer:FindDirect("Model01")
    GridModel[i] = Model01
    GridBgAnswer[i] = Img_BgAnswer
  end
  uiTbl.Grid = Grid
  uiTbl.GridModel = GridModel
  uiTbl.GridBgAnswer = GridBgAnswer
  local Group_Bottom = Img_Bg:FindDirect("Group_Bottom")
  local Label_JieName = Group_Bottom:FindDirect("Label_JieName")
  local Label_TeamType = Group_Bottom:FindDirect("Label_TeamType")
  local Label_Award = Group_Bottom:FindDirect("Label_Award")
  local Group_Items = Group_Bottom:FindDirect("Group_Items")
  Label_Num = Group_Bottom:FindDirect("Label_ZhanLi/Label_Num")
  uiTbl.Label_Fight = Label_Num
  uiTbl.Label_JieName = Label_JieName
  uiTbl.Label_TeamType = Label_TeamType
  uiTbl.Label_Award = Label_Award
  local Img_Item = {}
  for i = 1, 4 do
    local iTemGO = Group_Items:FindDirect(("Img_Item%d"):format(i))
    Img_Item[i] = iTemGO
  end
  uiTbl.Img_Item = Img_Item
end
def.method("number", "number").showNormalChapterInfo = function(self, pageIndex, sectionIndex)
  local chapterPage = self.dataCfg:getNoramlPage(pageIndex)
  self.curPage = pageIndex
  self.maxPage = self.dataCfg:getNormalPageCount()
  self:showChapterInfo(chapterPage, sectionIndex)
end
def.method("number", "number").showEliteChapterInfo = function(self, pageIndex, sectionIndex)
  local chapterPage = self.dataCfg:getElitePage(pageIndex)
  self.curPage = pageIndex
  self.maxPage = self.dataCfg:getElitePageCount()
  self:showChapterInfo(chapterPage, sectionIndex)
end
def.method("number", "number").showHeroChapterInfo = function(self, pageIndex, sectionIndex)
  local chapterPage = self.dataCfg:getHeroPage(pageIndex)
  self.curPage = pageIndex
  self.maxPage = self.dataCfg:getHeroPageCount()
  self:showChapterInfo(chapterPage, sectionIndex)
end
def.method("table", "number").showChapterInfo = function(self, chapterPage, sectionIndex)
  local uiTbl = self.uiTbl
  if chapterPage ~= self.curChapter then
    local GridModel = uiTbl.GridModel
    for i = 1, 5 do
      local chapterNode = chapterPage[i]
      local uiModelCO = GridModel[i]:GetComponent("UIModel")
      uiModelCO:set_orthographic(true)
      if self.modelWrap[i] ~= nil then
        self.modelWrap[i]:Destroy()
        self.modelWrap[i] = nil
        uiModelCO.modelGameObject = nil
      end
      if chapterNode ~= nil then
        self.modelWrap[i] = self:fillModelHalfIcon(uiModelCO, chapterNode.sectionPicid)
      end
    end
  end
  uiTbl.Btn_Left:SetActive(1 < self.curPage)
  uiTbl.Btn_Right:SetActive(self.curPage < self.maxPage)
  local sectionCount = #chapterPage
  if sectionIndex < 1 then
    sectionIndex = 1
  end
  if sectionCount < sectionIndex then
    sectionIndex = sectionCount
  end
  self.curSection = 0
  self.curChapter = chapterPage
  self:showSectionStatus()
  self:showChapterSection(sectionIndex)
end
local UIModelWrap = require("Model.UIModelWrap")
def.method("userdata", "number", "=>", UIModelWrap).fillModelHalfIcon = function(self, uiModelCO, modelId)
  local modelWrap
  local modelRecord = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  if modelRecord then
    local halfIconId = modelRecord:GetIntValue("halfBodyIconId")
    local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, halfIconId)
    if iconRecord and iconRecord:GetIntValue("iconType") == 1 then
      local resourcePath = iconRecord:GetStringValue("path")
      if resourcePath and resourcePath ~= "" then
        modelWrap = UIModelWrap.new(uiModelCO)
        modelWrap:Load(resourcePath .. ".u3dext")
      end
    end
  end
  return modelWrap
end
def.method().showSectionStatus = function(self)
  if self.curChapter == nil then
    return
  end
  local heroChapter = 0
  local heroSection = 0
  local nextPage = 1
  local nextIndex = 1
  local chapterPage = self.curChapter
  local GridBgAnswer = self.uiTbl.GridBgAnswer
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  if self.curType == QINGYUNZHI_TYPE.NORMAL then
    nextPage, nextIndex = self.dataCfg:getNormalNextSection()
  elseif self.curType == QINGYUNZHI_TYPE.ELITE then
    nextPage, nextIndex = self.dataCfg:getEliteNextSection()
  elseif self.curType == QINGYUNZHI_TYPE.HERO then
    nextPage, nextIndex = self.dataCfg:getHeroNextSection()
  else
    warn("[error]qingyunzhi showSectionStatus, unknown type!!")
    return
  end
  heroChapter, heroSection = self.dataCfg:getProgress(self.curType)
  for i = 1, 5 do
    local chapterNode = chapterPage[i]
    local Img_Lock = GridBgAnswer[i]:FindDirect("Img_Lock")
    local Img_Pass = GridBgAnswer[i]:FindDirect("Img_Pass")
    if chapterNode ~= nil then
      Img_Pass:SetActive(heroChapter > chapterNode.chapterNum or chapterNode.chapterNum == heroChapter and heroSection >= chapterNode.sectionNum)
      Img_Lock:SetActive(nextPage < self.curPage or nextPage == self.curPage and i > nextIndex or heroLevel < chapterNode.openLevel)
    else
      Img_Pass:SetActive(false)
      Img_Lock:SetActive(false)
    end
  end
end
def.method("number").showChapterSection = function(self, index)
  if self.curChapter == nil then
    return
  end
  local uiTbl = self.uiTbl
  local GridBgAnswer = uiTbl.GridBgAnswer
  local sectionInfo = self.curChapter[index]
  if sectionInfo ~= nil then
    self.curSection = index
    GUIUtils.SetSprite(uiTbl.Label_Section, ("Chapter_%02d"):format(sectionInfo.chapterPicid))
    uiTbl.Label_Level:GetComponent("UILabel"):set_text(("%d-%d"):format(sectionInfo.reLevellow, sectionInfo.reLevelHigh))
    uiTbl.Label_JieName:GetComponent("UILabel"):set_text(sectionInfo.sectionName)
    uiTbl.Label_Fight:GetComponent("UILabel"):set_text(sectionInfo.reFightValue)
    uiTbl.Label_TeamType:GetComponent("UILabel"):set_text(sectionInfo.roleNumDes)
    uiTbl.Label_Award:GetComponent("UILabel"):set_text(sectionInfo.sectionDes)
    local Item_Texs = uiTbl.Item_Texs
    local itemList = self:getAwardItemList(sectionInfo.fixAwardId)
    for i = 1, 4 do
      local Img_Item = uiTbl.Img_Item[i]
      local itemBase
      if itemList[i] then
        itemBase = ItemUtils.GetItemBase(itemList[i].itemId)
      end
      if itemBase then
        GUIUtils.SetActive(Img_Item, true)
        GUIUtils.SetTexture(Img_Item:FindDirect("Texture"), itemBase.icon)
        Img_Item:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(itemList[i].itemNum)
      else
        GUIUtils.SetActive(Img_Item, false)
      end
    end
  end
  GUIUtils.Toggle(GridBgAnswer[self.curSection], true)
end
def.method().showDefaultChapterPage = function(self)
  if self.curType == QINGYUNZHI_TYPE.NORMAL then
    local page, section = self.dataCfg:getNormalNextSection()
    self:showNormalChapterInfo(page, section)
  elseif self.curType == QINGYUNZHI_TYPE.ELITE then
    local page, section = self.dataCfg:getEliteNextSection()
    self:showEliteChapterInfo(page, section)
  elseif self.curType == QINGYUNZHI_TYPE.HERO then
    local page, section = self.dataCfg:getHeroNextSection()
    self:showHeroChapterInfo(page, section)
  end
end
def.method("number").syncProgress = function(self, outPostType)
  if self.m_panel and self.curType == outPostType then
    GameUtil.AddGlobalTimer(0.1, true, function()
      self:showDefaultChapterPage()
    end)
  end
end
def.static("table", "table").OnRoleLvUp = function(p1, p2)
  if instance and instance:IsShow() then
    instance:showSectionStatus()
  end
end
def.method().onBtnShareClick = function(self)
end
def.method().onBtnNormalClick = function(self)
  if self.curType ~= QINGYUNZHI_TYPE.NORMAL then
    self.curType = QINGYUNZHI_TYPE.NORMAL
    local page, section = self.dataCfg:getNormalNextSection()
    self:showNormalChapterInfo(page, section)
  end
end
def.method().onBtnEliteClick = function(self)
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  local needLevel = constant.CQingYunZhiConsts.ELITE_OPEN_LEVEL
  if heroLevel < needLevel then
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.QingYunZhi[1], string.format(textRes.QingYunZhi[6], needLevel), "", "", 0, 0, function(selection, tag)
    end, nil)
    return
  end
  if self.curType ~= QINGYUNZHI_TYPE.ELITE then
    self.curType = QINGYUNZHI_TYPE.ELITE
    local page, section = self.dataCfg:getEliteNextSection()
    self:showEliteChapterInfo(page, section)
  end
end
def.method().onBtnHeroClick = function(self)
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  local needLevel = constant.CQingYunZhiConsts.HERO_OPEN_LEVEL
  if heroLevel < needLevel then
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.QingYunZhi[1], string.format(textRes.QingYunZhi[7], needLevel), "", "", 0, 0, function(selection, tag)
    end, nil)
    return
  end
  if self.curType ~= QINGYUNZHI_TYPE.HERO then
    self.curType = QINGYUNZHI_TYPE.HERO
    local page, section = self.dataCfg:getHeroNextSection()
    self:showHeroChapterInfo(page, section)
  end
end
def.method().onBtnFightClick = function(self)
  if self.curChapter == nil then
    return
  end
  local sectionInfo = self.curChapter[self.curSection]
  if sectionInfo ~= nil then
    local heroChapter = 0
    local heroSection = 0
    local nextPage = 1
    local nextIndex = 1
    local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
    if self.curType == QINGYUNZHI_TYPE.NORMAL then
      nextPage, nextIndex = self.dataCfg:getNormalNextSection()
    elseif self.curType == QINGYUNZHI_TYPE.ELITE then
      nextPage, nextIndex = self.dataCfg:getEliteNextSection()
    elseif self.curType == QINGYUNZHI_TYPE.HERO then
      nextPage, nextIndex = self.dataCfg:getHeroNextSection()
    else
      return
    end
    heroChapter, heroSection = self.dataCfg:getProgress(self.curType)
    if nextPage < self.curPage or nextPage == self.curPage and nextIndex < self.curSection then
      CommonConfirmDlg.ShowConfirmCoundDown(textRes.QingYunZhi[1], textRes.QingYunZhi[2], "", "", 0, 0, function(selection, tag)
      end, nil)
      return
    end
    if heroLevel < sectionInfo.openLevel then
      CommonConfirmDlg.ShowConfirmCoundDown(textRes.QingYunZhi[1], string.format(textRes.QingYunZhi[5], sectionInfo.openLevel), "", "", 0, 0, function(selection, tag)
      end, nil)
      return
    end
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.QingYunZhi[1], textRes.QingYunZhi[3], "", "", 0, 0, function(selection, tag)
      if selection == 1 then
        QingYunZhiProtocol.sendChallengeQing(self.curType, sectionInfo.chapterNum, sectionInfo.sectionNum)
      end
    end, nil)
  end
end
def.method().onBtnRightClick = function(self)
  if self.curType == QINGYUNZHI_TYPE.NORMAL then
    if self.curPage < self.dataCfg:getNormalPageCount() then
      self:showNormalChapterInfo(self.curPage + 1, 1)
    end
  elseif self.curType == QINGYUNZHI_TYPE.ELITE then
    if self.curPage < self.dataCfg:getElitePageCount() then
      self:showEliteChapterInfo(self.curPage + 1, 1)
    end
  elseif self.curType == QINGYUNZHI_TYPE.HERO and self.curPage < self.dataCfg:getHeroPageCount() then
    self:showHeroChapterInfo(self.curPage + 1, 1)
  end
end
def.method().onBtnLeftClick = function(self)
  if self.curType == QINGYUNZHI_TYPE.NORMAL then
    if self.curPage > 1 then
      self:showNormalChapterInfo(self.curPage - 1, 1)
    end
  elseif self.curType == QINGYUNZHI_TYPE.ELITE then
    if self.curPage > 1 then
      self:showEliteChapterInfo(self.curPage - 1, 1)
    end
  elseif self.curType == QINGYUNZHI_TYPE.HERO and self.curPage > 1 then
    self:showHeroChapterInfo(self.curPage - 1, 1)
  end
end
def.method("userdata").OnItemClick = function(self, clickobj)
  local index = tonumber(string.sub(clickobj.name, #"Img_Item" + 1, -1))
  if self.curChapter and self.curSection then
    local sectionInfo = self.curChapter[self.curSection]
    if sectionInfo ~= nil then
      local itemId
      local itemList = self:getAwardItemList(sectionInfo.fixAwardId)
      if itemList[index] then
        itemId = itemList[index].itemId
      end
      if itemId and itemId > 0 then
        local position = clickobj:get_position()
        local screenPos = WorldPosToScreen(position.x, position.y)
        local sprite = clickobj:GetComponent("UISprite")
        ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
      end
    end
  end
end
def.method("number").onBtnSectionClick = function(self, index)
  self:showChapterSection(index)
end
local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
def.method("number", "=>", "table").getAwardItemList = function(self, awardId)
  local awardItemList = {}
  local key = string.format("%d_%d_%d", awardId, occupation.ALL, gender.ALL)
  local awardcfg = ItemUtils.GetGiftAwardCfg(key)
  if awardcfg then
    for ki, vi in ipairs(awardcfg.itemList) do
      table.insert(awardItemList, {
        itemId = vi.itemId,
        itemNum = vi.num
      })
    end
  end
  return awardItemList
end
return QingYunZhiPanel.Commit()
