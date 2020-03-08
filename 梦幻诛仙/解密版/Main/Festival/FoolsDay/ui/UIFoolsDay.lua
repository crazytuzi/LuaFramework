local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIFoolsDay = Lplus.Extend(ECPanelBase, "UIFoolsDay")
local GUIUtils = require("GUI.GUIUtils")
local def = UIFoolsDay.define
local instance
def.field("boolean")._bShowPanel = false
def.field("boolean")._bHasGotTitle = false
def.field("number")._iCountRefresh = 0
def.field("number")._iSelectBuffIdx = 0
def.field("number")._iActIntegral = 0
def.field("number")._iCountMadeChest = 0
def.field("table")._tblBuffinfoList = nil
def.field("table")._arrBuffCtrlModel = nil
def.field("table")._arrAwardUIInfos = nil
def.field("boolean")._bFeatureOpen = false
def.field("table")._uiObjs = nil
def.field("table")._ecUIModel = nil
def.const("number").COUNT_AWARDS = 3
def.static("=>", UIFoolsDay).Instance = function()
  if instance == nil then
    instance = UIFoolsDay()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, UIFoolsDay.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, UIFoolsDay.OnActivityStart)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, UIFoolsDay.OnActivityStart)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, UIFoolsDay.OnActivityStart)
  self:SetPanelShow(false)
  self._bHasGotTitle = false
  self._iCountMadeChest = 0
  self._iCountRefresh = 0
  self._iActIntegral = 0
  self._iSelectBuffIdx = 0
  self._tblBuffinfoList = nil
  self._arrBuffCtrlModel = nil
  self._arrAwardUIInfos = nil
  local uiModelCO = self._uiObjs.model_YuRen:GetComponent("UIModel")
  if self._ecUIModel ~= nil then
    self._ecUIModel:Destroy()
    uiModelCO.modelGameObject = nil
    self._ecUIModel = nil
  end
  self._uiObjs = nil
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:UpdateUI()
  end
end
def.method().ToShow = function(self)
  if not self:IsFeatureOpen() then
    Toast(textRes.Festival.FoolsDay[7])
    return
  end
  local p = require("netio.protocol.mzm.gsp.foolsday.CGetFoolsDayInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Toggle_Select" then
    id = obj.parent.name
  end
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_BuffTips" then
    self:ShowTips(constant.CFoolsDayConsts.BUFF_TIPS_CONTENT_ID)
  elseif id == "Btn_ChestTips" then
    self:ShowTips(constant.CFoolsDayConsts.ACTIVITY_TIPS_CONTENT_ID)
  elseif id == "Btn_Refresh" then
    self:OnRefreshBuffList()
  elseif id == "Btn_Make" then
    self:OnBtnMakeTreasureTank()
  elseif id == "Img_ChengWei" then
    self:OnBtnGetTitle()
  elseif string.find(id, "Head_") ~= nil then
    local fidx = string.sub(id, string.find(id, "%d%d%d"))
    self:OnSelectBuff(tonumber(fidx))
  end
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_UI_FOOLSDAY, 1)
  self:SetModal(true)
end
def.method("boolean").SetPanelShow = function(self, bShow)
  self._bShowPanel = bShow
end
def.method().InitUI = function(self)
  local rootPanel = self.m_panel:FindDirect("Img_Bg0")
  local groupYuRen = rootPanel:FindDirect("Group_YuRen")
  local buffListRoot = groupYuRen:FindDirect("Group_Head")
  local labelBuffDesc = groupYuRen:FindDirect("Label_Tips3")
  local labelRefresh = groupYuRen:FindDirect("Label_Tips2")
  local labelHint = groupYuRen:FindDirect("Label_Tips1")
  local btnRefresh = groupYuRen:FindDirect("Btn_Refresh")
  local model_YuRen = groupYuRen:FindDirect("Img_YuRen/Model")
  self._uiObjs = {}
  self._uiObjs.buffListRoot = buffListRoot
  self._uiObjs.labelBuffDesc = labelBuffDesc
  self._uiObjs.labelRefresh = labelRefresh
  self._uiObjs.labelHint = labelHint
  self._uiObjs.btnRefresh = btnRefresh
  self._uiObjs.model_YuRen = model_YuRen
  local groupAward = rootPanel:FindDirect("Group_Award")
  local awardListRoot = groupAward:FindDirect("Grid_Award")
  local imgTitle = groupAward:FindDirect("Img_ChengWei")
  local labelCountIntegral = groupAward:FindDirect("Slider/Label_Num")
  local labelCountMakeChest = groupYuRen:FindDirect("Label_Make")
  self._uiObjs.awardListRoot = awardListRoot
  self._uiObjs.imgTitle = imgTitle
  self._uiObjs.labelCountIntegral = labelCountIntegral
  self._uiObjs.labelCountMakeChest = labelCountMakeChest
end
def.method().OnRefreshBuffList = function(self)
  local countRefresh = self:GetRefreshTimes()
  local maxRefresh = self:GetRefreshMaxNum()
  if countRefresh >= maxRefresh then
    Toast(string.format(textRes.Festival.FoolsDay[10], countRefresh, maxRefresh))
    return
  end
  local p = require("netio.protocol.mzm.gsp.foolsday.CRefreshAlternativeBuffCfgidsReq").new()
  gmodule.network.sendProtocol(p)
end
def.method("number").OnSelectBuff = function(self, idx)
  idx = idx or 1
  self:SetSelectBuffIdx(idx)
  local buffInfo = self:GetSelectBuffInfo()
  local strDesc = ""
  if buffInfo == nil then
  else
    strDesc = buffInfo.desc
    local buffCfgInfo = require("Main.Buff.BuffUtility").GetBuffCfg(buffInfo.buff_id)
    local modeid = _G.GetModelChangeCfg(buffCfgInfo.effects[1].value).modelId
    self:UpdateModel(modeid)
  end
  self:UpdateUILabelBuffDesc(strDesc)
end
def.method().OnBtnMakeTreasureTank = function(self)
  local buffInfo = self:GetSelectBuffInfo()
  if buffInfo == nil then
    Toast(textRes.Festival.FoolsDay[9])
    return
  end
  if buffInfo.cost_vigor > self:GetHeroVigor() then
    Toast(textRes.Festival.FoolsDay[1])
    return
  end
  if self:GetMadeChestNum() >= self:GetMakeChestMaxNum() then
    Toast(string.format(textRes.Festival.FoolsDay[8], self:GetMadeChestNum(), self:GetMakeChestMaxNum()))
    return
  end
  local p = require("netio.protocol.mzm.gsp.foolsday.CMakeChestReq").new(buffInfo.buffCfgId)
  gmodule.network.sendProtocol(p)
end
def.method("number").ShowTips = function(self, tipsId)
  local content = require("Main.Common.TipsHelper").GetHoverTip(tipsId)
  require("GUI.CommonUITipsDlg").ShowCommonTip(content, {x = 0, y = 0})
end
def.method().OnBtnGetTitle = function(self)
  if self:GetActIntegral() < self:GetTitleAwardNeedPt() then
    Toast(textRes.Festival.FoolsDay[5])
    return
  end
  if self:HasGotActivityTitle() then
    Toast(textRes.Festival.FoolsDay[6])
    return
  end
  local p = require("netio.protocol.mzm.gsp.foolsday.CGetTitleReq").new()
  gmodule.network.sendProtocol(p)
end
def.method().UpdateUI = function(self)
  self:UpdateUIActivityIntegral(self:GetActIntegral(), self:GetTitleAwardNeedPt())
  self:UpdateUIAwardList()
  self:UpdateUILabelCountMakeTreasureTank(self:GetMadeChestNum(), self:GetMakeChestMaxNum())
  self:UpdateUILabelBuffDesc("")
  self:UpdateUILabelRefreshTimes()
  self:UpdateUIBuffList()
end
def.method("number", "number").UpdateUILabelCountMakeTreasureTank = function(self, countMade, total)
  local label = self._uiObjs.labelCountMakeChest
  local txt = textRes.Festival.FoolsDay[11] .. string.format(textRes.Festival.FoolsDay[12], countMade, total)
  GUIUtils.SetText(label, txt)
end
def.method().UpdateUILabelRefreshTimes = function(self)
  local label = self._uiObjs.labelRefresh
  local countRefresh = self:GetRefreshMaxNum() - self:GetRefreshTimes()
  GUIUtils.SetText(label, string.format(textRes.Festival.FoolsDay[14], countRefresh))
end
def.method("number", "number").UpdateUIActivityIntegral = function(self, curIntegral, total)
  local texTitle = self._uiObjs.imgTitle:FindDirect("Img_IconCW")
  if total <= curIntegral and not self:HasGotActivityTitle() then
    GUIUtils.SetLightEffect(texTitle, 1)
  else
    GUIUtils.SetLightEffect(texTitle, 0)
  end
  local label = self._uiObjs.labelCountIntegral
  GUIUtils.SetTexture(texTitle, constant.CFoolsDayConsts.TITLE_AWARD_ICON_ID)
  GUIUtils.SetText(label, string.format(textRes.Festival.FoolsDay[12], curIntegral, total))
end
def.method("string").UpdateUILabelBuffDesc = function(self, desc)
  desc = desc or ""
  GUIUtils.SetText(self._uiObjs.labelBuffDesc, desc)
end
def.method("table").AddAwardUIInfo = function(self, awardInfo)
  if awardInfo == nil then
    return
  end
  self._arrAwardUIInfos = self._arrAwardUIInfos or {}
  if #self._arrAwardUIInfos < UIFoolsDay.COUNT_AWARDS then
    table.insert(self._arrAwardUIInfos, {
      name = awardInfo.name,
      img_id = awardInfo.icon
    })
  end
end
def.method("=>", "table").GetAwardUIInfos = function(self)
  return self._arrAwardUIInfos
end
def.method().UpdateUIAwardList = function(self)
  for i = 1, UIFoolsDay.COUNT_AWARDS do
    local ctrlItem = self._uiObjs.awardListRoot:FindDirect(string.format("Item_%02d", i))
    local tex = ctrlItem:FindDirect("Img_Icon")
    local label = ctrlItem:FindDirect("Label_Name")
    local awardId = constant.CFoolsDayConsts[string.format("MIN_AWARD_ID_%d", i)]
    local awardInfo = self:GetAwardCfgInfoByAwardId(awardId)
    if awardInfo ~= nil then
      GUIUtils.SetTexture(tex, awardInfo.icon)
      GUIUtils.SetText(label, awardInfo.name)
      self:AddAwardUIInfo(awardInfo)
    end
  end
end
def.method("number", "=>", "table").GetAwardCfgInfoByAwardId = function(self, awardId)
  local ItemUtils = require("Main.Item.ItemUtils")
  local Occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local Gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local key = string.format("%d_%d_%d", awardId, Occupation.ALL, Gender.ALL)
  local awardCfg = ItemUtils.GetGiftAwardCfg(key)
  local awardCfgInfo
  if awardCfg and #awardCfg.itemList > 0 then
    awardCfgInfo = awardCfg.itemList[1]
  end
  if awardCfgInfo ~= nil then
    local awardInfo = ItemUtils.GetItemBase(awardCfgInfo.itemId)
    return awardInfo
  end
  return nil
end
def.method().UpdateUIBuffList = function(self)
  local countBuffList = #self._arrBuffCtrlModel
  for i = 1, countBuffList do
    local ctrlBuff = self._uiObjs.buffListRoot:FindDirect(string.format("Head_%03d", i))
    local tex = ctrlBuff:FindDirect("Img_Head")
    local label = ctrlBuff:FindDirect("Label_Title")
    local labelName = ctrlBuff:FindDirect("Label_Name")
    local buffCfgId = self._arrBuffCtrlModel[i].buffCfgId
    local buffInfo = self:GetBuffInfoByCfgId(buffCfgId)
    local buffCfgData = require("Main.Buff.BuffUtility").GetBuffCfg(buffInfo.buff_id)
    GUIUtils.SetTexture(tex, buffInfo.image_id)
    GUIUtils.SetText(label, string.format(textRes.Festival.FoolsDay[13], buffInfo.cost_vigor))
    GUIUtils.SetText(labelName, buffCfgData.name)
  end
  self:OnSelectBuff(self._iSelectBuffIdx)
end
local ECUIModel = require("Model.ECUIModel")
def.method("number").UpdateModel = function(self, modelId)
  local uiModel = self._uiObjs.model_YuRen:GetComponent("UIModel")
  local modelPath, modelColor = GetModelPath(modelId)
  if modelPath == nil or modelPath == "" then
    return false
  end
  if self._ecUIModel then
    self._ecUIModel:Destroy()
  end
  local function afterLoadFunc()
    uiModel.modelGameObject = self._ecUIModel.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end
  self._ecUIModel = ECUIModel.new(modelId)
  self._ecUIModel.m_bUncache = true
  self._ecUIModel:LoadUIModel(modelPath, function(ret)
    if not self._ecUIModel or not self._ecUIModel.m_model or self._ecUIModel.m_model.isnil then
      return
    end
    afterLoadFunc()
  end)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if id:find("Model") == 1 and self._ecUIModel ~= nil then
    self._ecUIModel:SetDir(self._ecUIModel.m_ang - dx / 2)
  end
end
def.method("=>", "boolean").HasGotActivityTitle = function(self)
  return self._bHasGotTitle
end
def.method("=>", "number").GetHeroVigor = function(self)
  local myVigorNum = require("Main.Hero.Interface").GetHeroProp().energy
  return myVigorNum
end
def.method("number").SetSelectBuffIdx = function(self, idx)
  self._iSelectBuffIdx = idx
end
def.method("=>", "number").GetSelectBuffIdx = function(self)
  return self._iSelectBuffIdx
end
def.method("=>", "table").GetSelectBuffInfo = function(self)
  local buffIdx = self:GetSelectBuffIdx()
  if buffIdx == 0 then
    return nil
  end
  local buffBasicInfo = self._arrBuffCtrlModel[buffIdx]
  return self:GetBuffInfoByCfgId(buffBasicInfo.buffCfgId)
end
def.method("=>", "number").GetTitleAwardNeedPt = function(self)
  return constant.CFoolsDayConsts.TITLE_AWARD_NEED_POINT
end
def.method("=>", "number").GetMakeChestMaxNum = function(self)
  return constant.CFoolsDayConsts.MAKE_CHEST_MAX_NUM
end
def.method("=>", "number").GetRefreshMaxNum = function(self)
  return constant.CFoolsDayConsts.REFRESH_MAX_TIME
end
def.method("number").SetMadeChestNum = function(self, iCountMade)
  self._iCountMadeChest = iCountMade
end
def.method("=>", "number").GetMadeChestNum = function(self)
  return self._iCountMadeChest
end
def.method("table").SetBuffinfoList = function(self, buffCfgIds)
  self._tblBuffinfoList = self._tblBuffinfoList or {}
  self._arrBuffCtrlModel = self._arrBuffCtrlModel or {}
  local count = 1
  for _, v in pairs(buffCfgIds) do
    self._tblBuffinfoList[v] = {buffCfgId = v}
    self._arrBuffCtrlModel[count] = self._tblBuffinfoList[v]
    count = count + 1
  end
end
def.method("number", "=>", "table").GetBuffInfoByCfgId = function(self, buffCfgId)
  local buffInfo = self._tblBuffinfoList[buffCfgId]
  if buffInfo ~= nil and buffInfo.buff_id == nil then
    self:LoadBuffInfoByCfgId(buffInfo)
  end
  return buffInfo
end
def.method("table").LoadBuffInfoByCfgId = function(self, buffInfo)
  if buffInfo == nil then
    return
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FOOLS_DAY_BUFFINFO, buffInfo.buffCfgId)
  buffInfo.buff_id = record:GetIntValue("buff_id")
  buffInfo.cost_vigor = record:GetIntValue("cost_vigor")
  buffInfo.image_id = record:GetIntValue("image_id")
  buffInfo.desc = record:GetStringValue("desc")
end
def.method("boolean").SetGotActivityTitle = function(self, bGotTitle)
  self._bHasGotTitle = bGotTitle
end
def.method("number").SetActIntegral = function(self, integral)
  self._iActIntegral = integral or 0
end
def.method("=>", "number").GetActIntegral = function(self)
  return self._iActIntegral
end
def.method("=>", "boolean").HasSyncActivityInfo = function(self)
  return self._tblBuffinfoList ~= nil
end
def.method("number").SetRefreshTimes = function(self, times)
  self._iCountRefresh = times
end
def.method("=>", "number").GetRefreshTimes = function(self)
  return self._iCountRefresh or 0
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  return require("Main.Festival.FoolsDay.FoolsDayMgr").Instance():GetFeatureOpen()
end
def.method().ResetCrossDayInfos = function(self)
  self._iCountRefresh = 0
  self._iCountMadeChest = 0
end
def.static("table", "table").OnActivityStart = function(p)
  local self = UIFoolsDay.Instance()
  self:ResetCrossDayInfos()
  self:UpdateUI()
end
def.static("table").OnSGetFoolsDayInfoFail = function(p)
  warn(">>>>OnSGetFoolsDayInfoFail<<<<")
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
def.static("table").OnSSynFoolsDayInfo = function(p)
  local self = UIFoolsDay.Instance()
  self:SetBuffinfoList(p.alternative_buff_cfg_ids)
  self:SetRefreshTimes(p.refresh_time)
  self:SetMadeChestNum(p.make_chest_num or 0)
  self:SetGotActivityTitle(p.has_get_title_award == 1)
  self:SetActIntegral(p.point)
  if not self:IsShow() then
    self:ShowPanel()
  else
    self:UpdateUI()
  end
end
def.static("table").OnSGetTitleSuccess = function(p)
  local self = UIFoolsDay.Instance()
  if not self:IsShow() then
    return
  end
  self:SetGotActivityTitle(true)
  self:UpdateUIActivityIntegral(self:GetActIntegral(), self:GetTitleAwardNeedPt())
end
def.static("table").OnSGetTitleFail = function(p)
  warn(">>>>SGetTitleFail<<<<")
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
  elseif p.res == 2 then
    warn(">>>>ALREADY_GET_TITLE<<<<")
  elseif p.res == 3 then
    warn(">>>>POINT_NOT_ENOUGH<<<<")
  end
end
def.static("table").OnSMakeChestFail = function(p)
  warn(">>>>SMakeChestFail<<<<")
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
  elseif p.res == 2 then
    warn(">>>>MAKE_CHEST_TIME_TO_LIMIT<<<<")
  elseif p.res == 3 then
    warn(">>>>BUFF_CFG_ID_ERROR<<<<")
  elseif p.res == 4 then
    Toast(textRes.Festival.FoolsDay[1])
  elseif p.res == 5 then
    Toast(textRes.Festival.FoolsDay[2])
  end
end
def.static("table").OnSMakeChestSuccess = function(p)
  Toast(textRes.Festival.FoolsDay[4])
  local self = UIFoolsDay.Instance()
  if not self:IsShow() then
    return
  end
  local objMakeChestEffect = require("Main.Festival.FoolsDay.ui.UIMakeChestEffect").Instance()
  objMakeChestEffect:ShowPanel(self:GetSelectBuffInfo(), self:GetAwardUIInfos())
  local count = self:GetMadeChestNum()
  self:SetMadeChestNum(count + 1)
  self:UpdateUI()
end
def.static("table").OnSRefreshAlternativeBuffCfgidsFail = function(p)
  warn(">>>SRefreshAlternativeBuffCfgidsFail<<<")
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
  elseif p.res == 2 then
    local refreshMaxTimes = constant.CFoolsDayConsts.REFRESH_MAX_TIME
    Toast(string.format(textRes.Festival.FoolsDay[3], refreshMaxTimes, refreshMaxTimes))
  end
end
return UIFoolsDay.Commit()
