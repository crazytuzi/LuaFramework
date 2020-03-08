local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local CatModule = require("Main.Cat.CatModule")
local ECUIModel = require("Model.ECUIModel")
local ItemModule = require("Main.Item.ItemModule")
local Octets = require("netio.Octets")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local CatModuleInst = CatModule.Instance()
local MODULE_NAME = (...)
local instance
local CatPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local def = CatPanel.define
def.field("table").uiObjs = nil
def.field("table").ecUIModel = nil
def.field("number").m_timerID = 0
def.field("number").m_exploreAniTimerID = 0
def.static("=>", CatPanel).Instance = function()
  if instance == nil then
    instance = CatPanel()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Clear = function(self)
  Event.UnregisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.CHANGE_NAME, CatPanel.OnChangeName)
  Event.UnregisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.FEED, CatPanel.OnFeed)
  Event.UnregisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.CHANGE_PARTNER, CatPanel.OnChangePartner)
  Event.UnregisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.EXPLORE, CatPanel.OnExplore)
  Event.UnregisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.CHANGE_STATE, CatPanel.OnChangeState)
  Event.UnregisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.GET_AWARD, CatPanel.OnGetAward)
  Event.UnregisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.RECOVERY, CatPanel.OnRecovery)
  Event.UnregisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.FEED_RECORD, CatPanel.OnFeedrecord)
  self.uiObjs = nil
  if self.ecUIModel then
    self.ecUIModel:Destroy()
    self.ecUIModel = nil
  end
  self:StopTimer()
  self:StopExploreTimer()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Init()
end
def.override().OnDestroy = function(self)
  self:Clear()
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:Update()
  else
  end
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.CHANGE_NAME, CatPanel.OnChangeName)
  Event.RegisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.FEED, CatPanel.OnFeed)
  Event.RegisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.CHANGE_PARTNER, CatPanel.OnChangePartner)
  Event.RegisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.EXPLORE, CatPanel.OnExplore)
  Event.RegisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.CHANGE_STATE, CatPanel.OnChangeState)
  Event.RegisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.GET_AWARD, CatPanel.OnGetAward)
  Event.RegisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.RECOVERY, CatPanel.OnRecovery)
  Event.RegisterEvent(ModuleId.CAT, gmodule.notifyId.Cat.FEED_RECORD, CatPanel.OnFeedrecord)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.btnTips = self.m_panel:FindDirect("Sprite")
  GUIUtils.AddBoxCollider(self.uiObjs.btnTips)
  local Group_Cat = self.m_panel:FindDirect("Img_Bg/Group_Cat")
  self.uiObjs.labName = Group_Cat:FindDirect("Label_Name")
  self.uiObjs.uiModel = Group_Cat:FindDirect("Model_Cat")
  self.uiObjs.sliderVitality = Group_Cat:FindDirect("Slider_Huoli")
  self.uiObjs.labVitality = self.uiObjs.sliderVitality:FindDirect("Label_Number")
  self.uiObjs.Btn_ChangeName = Group_Cat:FindDirect("Btn_ChangeName")
  local Group_Partner = self.m_panel:FindDirect("Img_Bg/Group_Partner")
  self.uiObjs.labPartnerName = Group_Partner:FindDirect("Label_Name")
  self.uiObjs.labDesc = Group_Partner:FindDirect("Label_Info")
  self.uiObjs.labLevel = Group_Partner:FindDirect("Label_LevelNumber")
  self.uiObjs.sliderTimes = Group_Partner:FindDirect("Slider_Times")
  self.uiObjs.labTimes = self.uiObjs.sliderTimes:FindDirect("Label_Number")
  self.uiObjs.Btn_Change = Group_Partner:FindDirect("Btn_Change")
  local Gruop_Btn = self.m_panel:FindDirect("Img_Bg/Gruop_Btn")
  self.uiObjs.Btn_Feed = Gruop_Btn:FindDirect("Btn_Feed")
  self.uiObjs.Btn_Back = Gruop_Btn:FindDirect("Btn_Back")
  self.uiObjs.Btn_Explore = Gruop_Btn:FindDirect("Btn_Explore")
  self.uiObjs.Btn_GetPrize = Gruop_Btn:FindDirect("Btn_GetPrize")
  self.uiObjs.Img_Red = self.uiObjs.Btn_GetPrize:FindDirect("Img_Red")
  self.uiObjs.Label_Exploring = self.m_panel:FindDirect("Img_Bg/Label_Exploring")
  self.uiObjs.Label_Time = self.m_panel:FindDirect("Img_Bg/Label_Time")
  self.uiObjs.Group_FeedRecord = self.m_panel:FindDirect("Group_FeedRecord")
  self.uiObjs.Group_FeedRecord:SetActive(false)
  local listObj = self.uiObjs.Group_FeedRecord:FindDirect("Bg_Content/Scroll View/List")
  self.uiObjs.uiScrollList = listObj:GetComponent("UIScrollList")
  if self.uiObjs.uiScrollList then
    local GUIScrollList = listObj:GetComponent("GUIScrollList")
    if not GUIScrollList then
      listObj:AddComponent("GUIScrollList")
    end
    ScrollList_setUpdateFunc(self.uiObjs.uiScrollList, function(item, i)
      local feedRecord = CatModuleInst:GetFeedRecord()
      if not feedRecord then
        return
      end
      local data = feedRecord[i]
      if not data then
        return
      end
      local octets = Octets.new(data.role_name)
      local Label_Content = item:FindDirect("Label_Content")
      local str = ""
      if CatModuleInst:GetTargetRoleId() == GetMyRoleID() then
        str = string.format(textRes.Cat[9], octets:toString())
      else
        str = string.format(textRes.Cat[10], octets:toString())
      end
      Label_Content:GetComponent("UILabel"):set_text(str)
      local time = os.date("%Y/%m/%d %H:%M:%S", data.feed_timestamp)
      local Label_Date = item:FindDirect("Label_Date")
      Label_Date:GetComponent("UILabel"):set_text(time)
      local Btn_Visit = item:FindDirect("Btn_Visit")
      Btn_Visit:SetActive(data.roleid ~= GetMyRoleID())
    end)
  end
end
def.method("string").SetName = function(self, name)
  self.uiObjs.labName:GetComponent("UILabel"):set_text(name)
end
def.method("number").SetModel = function(self, modelid)
  local uiModel = self.uiObjs.uiModel:GetComponent("UIModel")
  local modelpath, modelcolor = GetModelPath(modelid)
  if modelpath == nil or modelpath == "" then
    return false
  end
  if self.ecUIModel then
    self.ecUIModel:Destroy()
    self.ecUIModel = nil
  end
  local function AfterModelLoad()
    uiModel.modelGameObject = self.ecUIModel.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end
  if not self.ecUIModel then
    self.ecUIModel = ECUIModel.new(modelid)
    self.ecUIModel.m_bUncache = true
    self.ecUIModel:LoadUIModel(modelpath, function(ret)
      if not self.ecUIModel or not self.ecUIModel.m_model or self.ecUIModel.m_model.isnil then
        return
      end
      AfterModelLoad()
    end)
  end
end
def.method("number", "number").SetVitality = function(self, curr, max)
  local slider = self.uiObjs.sliderVitality:GetComponent("UIProgressBar")
  slider.value = curr / max
  self.uiObjs.labVitality:GetComponent("UILabel"):set_text(curr .. "/" .. max)
end
def.method("string").SetPartnerName = function(self, name)
  self.uiObjs.labPartnerName:GetComponent("UILabel"):set_text(name)
end
def.method("string").SetDesc = function(self, desc)
  self.uiObjs.labDesc:GetComponent("UILabel"):set_text(desc)
end
def.method("number").SetLevel = function(self, level)
  self.uiObjs.labLevel:GetComponent("UILabel"):set_text(tostring(level))
end
def.method("number", "number").SetTimes = function(self, curr, max)
  local slider = self.uiObjs.sliderTimes:GetComponent("UIProgressBar")
  slider.value = curr / max
  self.uiObjs.labTimes:GetComponent("UILabel"):set_text(curr .. "/" .. max)
end
def.method().UpdateButton = function(self)
  local bMyself = GetMyRoleID() == CatModuleInst:GetTargetRoleId()
  self.uiObjs.Btn_ChangeName:SetActive(bMyself)
  self.uiObjs.Btn_Change:SetActive(bMyself)
  local CatInfo = require("netio.protocol.mzm.gsp.cat.CatInfo")
  local state = CatModuleInst:GetState()
  local bNormal = state == CatInfo.STATE_NORMAL
  local bExplore = state == CatInfo.STATE_EXPLORE
  local bCooldown = state == CatInfo.STATE_RESET
  local bAward = CatModuleInst:IsCanGetaward()
  local bCanExplore = CatModuleInst:IsCanExplore()
  self.uiObjs.Btn_Feed:SetActive(not bExplore)
  self.uiObjs.Btn_Back:SetActive(bMyself and not bExplore)
  local Btn_Explore = self.uiObjs.Btn_Explore
  Btn_Explore:SetActive(bMyself and bNormal and not bAward)
  Btn_Explore:FindDirect("Img_Red"):SetActive(bMyself and bCanExplore)
  self.uiObjs.Btn_GetPrize:SetActive(bMyself and not bExplore and bAward)
  self.uiObjs.Img_Red:SetActive(bMyself and bAward)
  self.uiObjs.Label_Exploring:SetActive(bExplore)
  local timeStr = bAward and "" or CatModuleInst:GetCooldownTime()
  self.uiObjs.Label_Time:GetComponent("UILabel"):set_text(timeStr)
end
def.method().SetTimer = function(self)
  local CatInfo = require("netio.protocol.mzm.gsp.cat.CatInfo")
  local state = CatModuleInst:GetState()
  local bExplore = state == CatInfo.STATE_EXPLORE
  local bCooldown = state == CatInfo.STATE_RESET
  if bCooldown or bExplore then
    if self.m_timerID == 0 then
      self.m_timerID = GameUtil.AddGlobalTimer(1, false, function()
        self:Tick()
      end)
    end
  else
    self:StopTimer()
  end
end
def.method().StopTimer = function(self)
  if self.m_timerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_timerID)
    self.m_timerID = 0
  end
end
def.method().Tick = function(self)
  CatModuleInst:_CalcState()
  self:UpdateButton()
end
def.method().StopExploreTimer = function(self)
  if self.m_exploreAniTimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_exploreAniTimerID)
    self.m_exploreAniTimerID = 0
  end
end
def.method().PlayExploreAni = function(self)
  self:StopExploreTimer()
  if self.ecUIModel then
    self.ecUIModel:CrossFade(CatModuleInst:RandomExploreAni(), 0.1)
    self.ecUIModel:CrossFadeQueued(ActionName.Stand, 0.1)
    do
      local time = 0
      local interval = 0.2
      if self.m_exploreAniTimerID == 0 then
        self.m_exploreAniTimerID = GameUtil.AddGlobalTimer(interval, false, function()
          time = time + interval
          if time > 4 then
            self:StopExploreTimer()
            Toast(textRes.Cat[5])
            self:Hide()
          end
        end)
      end
    end
  end
end
def.method().Update = function(self)
  self:SetName(CatModuleInst:GetName())
  self:SetModel(CatModuleInst:GetModelId())
  self:SetVitality(CatModuleInst:GetVitality(), CatModuleInst:GetVitalityMax())
  self:SetPartnerName(CatModuleInst:GetPartnerName())
  self:SetDesc(CatModuleInst:GetDesc())
  self:SetLevel(CatModuleInst:GetLevel())
  self:SetTimes(CatModuleInst:GetTimes(), CatModuleInst:GetTimesMax())
  self:UpdateButton()
  self:SetTimer()
end
def.method().ShowFeedRecord = function(self)
  self.uiObjs.Group_FeedRecord:SetActive(true)
  ScrollList_setCount(self.uiObjs.uiScrollList, #CatModuleInst:GetFeedRecord())
end
def.static("table", "table").OnChangeName = function(p1, p2)
  if not instance then
    return
  end
  instance:SetName(CatModuleInst:GetName())
end
def.static("table", "table").OnFeed = function(p1, p2)
  if not instance then
    return
  end
  instance:SetVitality(CatModuleInst:GetVitality(), CatModuleInst:GetVitalityMax())
  instance:UpdateButton()
end
def.static("table", "table").OnChangePartner = function(p1, p2)
  if not instance then
    return
  end
  instance:SetPartnerName(CatModuleInst:GetPartnerName())
end
def.static("table", "table").OnExplore = function(p1, p2)
  if not instance then
    return
  end
  instance:SetLevel(CatModuleInst:GetLevel())
  instance:SetTimes(CatModuleInst:GetTimes(), CatModuleInst:GetTimesMax())
  instance:UpdateButton()
  instance:PlayExploreAni()
end
def.static("table", "table").OnChangeState = function(p1, p2)
  if not instance then
    return
  end
  instance:UpdateButton()
  instance:SetTimer()
end
def.static("table", "table").OnGetAward = function(p1, p2)
  if not instance then
    return
  end
  instance:UpdateButton()
end
def.static("table", "table").OnRecovery = function(p1, p2)
  local CatPanel = require("Main.Cat.ui.CatPanel")
  CatPanel.Instance():Hide()
end
def.static("table", "table").OnFeedrecord = function(p1, p2)
  if not instance then
    return
  end
  instance:ShowFeedRecord()
end
def.method().OnBtnTipsClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(CatModuleInst:GetTipId())
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method().OnModelClick = function(self)
  if self.ecUIModel then
    self.ecUIModel:CrossFade(CatModuleInst:RandomIdleAni(), 0.1)
    self.ecUIModel:CrossFadeQueued(ActionName.Stand, 0.1)
  end
end
def.method().OnBtnFeedClick = function(self)
  CatModuleInst:DoFeed()
end
def.method().OnBtnTakeBackClick = function(self)
  CatModuleInst:DoTakeBack()
end
def.method().OnBtnExploreClick = function(self)
  local content = string.format(textRes.Cat[12], CatModuleInst:GetPartnerName())
  CommonConfirmDlg.ShowConfirm("", content, function(select, tag)
    if 1 == select then
      CatModuleInst:DoExplore()
    end
  end, nil)
end
def.method().OnBtnChangeNameClick = function(self)
  CatModuleInst:DoChangeName()
end
def.method().OnBtnChangePartnerClick = function(self)
  local need = CatModuleInst:GetChangePartnerCost()
  local BuyGoldCallback = function(ret, tag)
    if ret == 1 then
      GoToBuyGold(false)
    end
  end
  local function OnConfirm(ret)
    if ret == 1 then
      local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
      if Int64.lt(gold, need) then
        CommonConfirmDlg.ShowConfirm("", textRes.Commerce.ErrorCode[3], BuyGoldCallback, {
          unique = "commercebuy"
        })
      else
        CatModuleInst:DoChangePartner()
      end
    end
  end
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Cat[4], need), OnConfirm, {})
end
def.method().OnBtnGetPrizeClick = function(self)
  CatModuleInst:DoGetAward()
end
def.method().OnFeedRecordClick = function(self)
  if self.uiObjs.Group_FeedRecord.activeSelf then
    self.uiObjs.Group_FeedRecord:SetActive(false)
  else
    CatModuleInst:DoGetFeedRecord()
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Sprite" then
    self:OnBtnTipsClick()
  elseif id == "Img_Bg" then
    self:OnModelClick()
  elseif id == "Btn_Feed" then
    self:OnBtnFeedClick()
  elseif id == "Btn_Back" then
    self:OnBtnTakeBackClick()
  elseif id == "Btn_Explore" then
    self:OnBtnExploreClick()
  elseif id == "Btn_ChangeName" then
    self:OnBtnChangeNameClick()
  elseif id == "Btn_Change" then
    self:OnBtnChangePartnerClick()
  elseif id == "Btn_GetPrize" then
    self:OnBtnGetPrizeClick()
  elseif id == "Btn_Visit" then
    local item, idx = ScrollList_getItem(clickObj.parent)
    local feedRecord = CatModuleInst:GetFeedRecord()
    if not feedRecord then
      return
    end
    local data = feedRecord[idx]
    if data and data.roleid then
      self:Hide()
      gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):VisitHome(data.roleid)
    end
  elseif id == "Label" then
    self:OnFeedRecordClick()
    return
  end
  if self.uiObjs and self.uiObjs.Group_FeedRecord then
    self.uiObjs.Group_FeedRecord:SetActive(false)
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if id:find("Img_Bg") == 1 then
    self.ecUIModel:SetDir(self.ecUIModel.m_ang - dx / 2)
  end
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:Update()
  else
    self:CreatePanel(RESPATH.PREFAB_CAT_PANEL, 1)
    self:SetModal(true)
  end
end
return CatPanel.Commit()
