local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local UIQingYunAsk = Lplus.Extend(ECPanelBase, "UIQingYunAsk")
local QingYunZhiData = require("Main.QingYunZhi.data.QingYunZhiData")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = UIQingYunAsk.define
local instance
def.field("table").uiTbl = nil
def.field("table").modelWrap = nil
def.field("number").state = 0
def.field("table").chapterNode = nil
def.field("number").QingYunZhiType = 0
def.static("=>", UIQingYunAsk).Instance = function()
  if instance == nil then
    instance = UIQingYunAsk()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:showChapterInfo()
  self:UpdateUI()
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg = self.m_panel:FindDirect("Img _Bg0")
  local Img_BgAnswer01 = Img_Bg:FindDirect("Img_BgAnswer01")
  uiTbl.Img_BgAnswer01 = Img_BgAnswer01
  local Btn_ConFirm = Img_Bg:FindDirect("Btn_ConFirm")
  uiTbl.Btn_ConFirm = Btn_ConFirm
  local chapterNode = self.chapterNode
  if chapterNode then
    local Label_Tips = Img_Bg:FindDirect("Label_Tips")
    local typeName = textRes.Soaring.QingYunAsk.QingYunName[self.QingYunZhiType] or ""
    local qingyunzhiName = textRes.Soaring.QingYunAsk[2]
    Label_Tips:GetComponent("UILabel"):set_text(string.format(textRes.Soaring.QingYunAsk[2], typeName, chapterNode.chapterNum, chapterNode.sectionNum))
  end
end
def.method().showChapterInfo = function(self)
  local chapterNode = self.chapterNode
  if chapterNode then
    local Img_BgAnswer01 = self.uiTbl.Img_BgAnswer01
    local GridModel = Img_BgAnswer01:FindDirect("Model01")
    local uiModelCO = GridModel:GetComponent("UIModel")
    uiModelCO:set_orthographic(true)
    if self.modelWrap ~= nil then
      self.modelWrap:Destroy()
      self.modelWrap = nil
      uiModelCO.modelGameObject = nil
    end
    self.modelWrap = self:fillModelHalfIcon(uiModelCO, chapterNode.sectionPicid)
  end
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
def.method().UpdateUI = function(self)
  local chapterNode = self.chapterNode
  local Img_BgAnswer01 = self.uiTbl.Img_BgAnswer01
  local Img_Lock = Img_BgAnswer01:FindDirect("Img_Lock")
  local Img_Pass = Img_BgAnswer01:FindDirect("Img_Pass")
  local Btn_ConFirm = self.uiTbl.Btn_ConFirm
  local Label_Go = Btn_ConFirm:FindDirect("Label_Go")
  local Label_Release = Btn_ConFirm:FindDirect("Label_Release")
  if chapterNode then
    local heroChapter = 0
    local heroSection = 0
    local nextChapter = 0
    local nextSection = 0
    local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
    heroChapter, heroSection = QingYunZhiData.Instance():getProgress(self.QingYunZhiType)
    nextChapter, nextSection = QingYunZhiData.Instance():getNextChapterSection(self.QingYunZhiType, heroChapter, heroSection)
    local pass = heroChapter > chapterNode.chapterNum or chapterNode.chapterNum == heroChapter and heroSection >= chapterNode.sectionNum
    local lock = nextChapter < chapterNode.chapterNum or nextChapter == chapterNode.chapterNum and nextSection < chapterNode.sectionNum or heroLevel < chapterNode.openLevel
    Img_Pass:SetActive(pass)
    Img_Lock:SetActive(nextChapter > 0 and lock)
    Label_Go:SetActive(not pass)
    Label_Release:SetActive(pass)
  else
    Img_Pass:SetActive(false)
    Img_Lock:SetActive(false)
    Label_Go:SetActive(false)
    Label_Release:SetActive(true)
  end
end
def.override().OnDestroy = function(self)
  local modelWrap = self.modelWrap
  if modelWrap ~= nil then
    local Img_BgAnswer01 = self.uiTbl.Img_BgAnswer01
    local GridModel = Img_BgAnswer01:FindDirect("Model01")
    local uiModelCO = GridModel:GetComponent("UIModel")
    modelWrap:Destroy()
    uiModelCO.modelGameObject = nil
    self.modelWrap = nil
  end
end
def.method("number", "number", "number").ShowPanel = function(self, qingyunzhiType, chapterNum, sectionNum)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.QingYunZhiType = qingyunzhiType
  self.chapterNode = QingYunZhiData.Instance():getSectionInfo(self.QingYunZhiType, chapterNum, sectionNum)
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_UI_QINGYUNWENDAO, GUILEVEL.MUTEX)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_ConFirm" then
    self:onBtnConFirmClick()
  end
end
def.method().onBtnConFirmClick = function(self)
  local chapterNode = self.chapterNode
  if not chapterNode then
    return
  end
  local heroChapter = 0
  local heroSection = 0
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  heroChapter, heroSection = QingYunZhiData.Instance():getProgress(self.QingYunZhiType)
  if heroChapter > chapterNode.chapterNum or chapterNode.chapterNum == heroChapter and heroSection >= chapterNode.sectionNum then
    local activityId = require("Main.Soaring.proxy.TaskQingYunAsked").ACTIVITY_ID
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.feisheng.CAttendQingYunZhiActivityReq").new(activityId))
  else
    if heroLevel < chapterNode.openLevel then
      CommonConfirmDlg.ShowConfirmCoundDown(textRes.QingYunZhi[1], string.format(textRes.QingYunZhi[5], chapterNode.openLevel), "", "", 0, 0, function(selection, tag)
      end, nil)
      return
    end
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.CQingYunZhiConsts.QING_NPC_ID
    })
  end
  self:DestroyPanel()
end
return UIQingYunAsk.Commit()
