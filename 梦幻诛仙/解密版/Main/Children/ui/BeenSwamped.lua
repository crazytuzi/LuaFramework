local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BeenSwamped = Lplus.Extend(ECPanelBase, "BeenSwamped")
local def = BeenSwamped.define
local instance
def.field("number")._toSignId = 0
def.field("number")._sessionId = 0
def.field("number")._gotSortId = 0
def.field("number")._duration = 3
def.field("boolean")._bIsCreated = false
def.field("boolean")._bCanClosePanel = false
def.field("boolean")._bHasGetBaby = false
def.field("table")._cachedCfgData = nil
def.field("userdata")._labelTitle = nil
def.field("userdata")._labelContent1 = nil
def.field("userdata")._labelContent2 = nil
def.field("userdata")._labelContent3 = nil
def.field("userdata")._labelContent4 = nil
def.static("=>", BeenSwamped).Instance = function()
  if instance == nil then
    instance = BeenSwamped()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._bIsCreated = true
  self:Init()
end
def.method().RegisterProtocols = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qiuqian.SQiuQianFail", BeenSwamped.OnSignFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qiuqian.SQiuQianSuccess", BeenSwamped.OnSignSuccess)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.ToSignGetBaby, BeenSwamped.OnGetBaby)
end
def.override("boolean").OnShow = function(self, s)
end
def.method().Init = function(self)
  local BeenSwampedAnim = self.m_panel:FindDirect("Tween_Qian")
  local tweener = BeenSwampedAnim:FindDirect("UI_ChouQian"):GetComponent("FxDuration")
  self._labelTitle = self.m_panel:FindDirect("Img_Bg/Img_Title/Label")
  self._labelContent1 = self.m_panel:FindDirect("Img_Bg/Label_Content1")
  self._labelContent2 = self.m_panel:FindDirect("Img_Bg/Label_Content2")
  self._labelContent3 = self.m_panel:FindDirect("Img_Bg/Label_Content3")
  self._labelContent4 = self.m_panel:FindDirect("Img_Bg/Label_Content4")
  local duration = self._duration or 3
  tweener.duration = duration
  GameUtil.AddGlobalTimer(duration, true, function()
    if not self._bIsCreated then
      return
    end
    if BeenSwampedAnim ~= nil then
      BeenSwampedAnim:SetActive(false)
      BeenSwampedAnim = nil
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.qiuqian.CQiuQianReq").new(self._toSignId, Int64.new(self._sessionId)))
  end)
end
def.method().ShowSign = function(self)
  if self.m_panel == nil then
    warn("BeenSwamped panel has been closed.")
    return
  end
  local ctrl_sign = self.m_panel:FindDirect("Img_Bg")
  local cfgData = BeenSwamped.GetSignCfgDataBySortId(self._gotSortId)
  local signType = cfgData.qianwen_title
  local integral = cfgData.point
  Toast(string.format(textRes.Children.SongZiGuanYin[11], signType, integral))
  self:UpdateSignUI(cfgData)
  ctrl_sign:SetActive(true)
end
def.method("table").UpdateSignUI = function(self, cfgData)
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.SetText(self._labelTitle, cfgData.qianwen_title)
  GUIUtils.SetText(self._labelContent1, cfgData.qianwen_content_1)
  GUIUtils.SetText(self._labelContent2, cfgData.qianwen_content_2)
  GUIUtils.SetText(self._labelContent3, cfgData.qianwen_content_3)
  GUIUtils.SetText(self._labelContent4, cfgData.qianwen_content_4)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.ToSignGetBaby, BeenSwamped.OnGetBaby)
  self._bIsCreated = false
  self._bHasGetBaby = false
end
def.method().ShowModal = function(self)
  if self._bHasGetBaby then
    return
  end
  if self._bIsCreated then
    self:Show(true)
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TOSIGN_UI, GUIDEPTH.TOP)
  self:SetModal(true)
  self:Show(true)
end
def.method().ToShow = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CAttendGuanYinQiuQianReq").new())
end
def.method().HidePanel = function(self)
  if self._bIsCreated then
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, ctrl_id)
  if self._bCanClosePanel then
    self:HidePanel()
    self._bCanClosePanel = false
  end
end
def.static("number", "=>", "table").GetSignCfgDataBySortId = function(sort_id)
  local self = BeenSwamped.Instance()
  self._cachedCfgData = self._cachedCfgData or {}
  local sid = self._cachedCfgData.sort_id
  if sid ~= nil and sid == sort_id then
    return self._cachedCfgData
  end
  local activity_id = constant.GuanYinConsts.QIUQIAN_ACTIVITY_CFG_ID
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SONGZIGUANYIN_Sign, self._toSignId)
  if record == nil then
    warn(">>>>>>>>>>>>>>>Get QiuQian Cfg return nil ID = " .. tostring(activity_id))
    return nil
  end
  self._duration = DynamicRecord.GetIntValue(record, "anim_duration")
  local vecStructData = record:GetStructValue("qianwen_infosStruct")
  local vecSize = vecStructData:GetVectorSize("qianwen_infos")
  local cfgData = vecStructData:GetVectorValueByIdx("qianwen_infos", sort_id - 1)
  if cfgData == nil then
    warn("Can't load qiuqian cfg data ")
    return nil
  end
  local cfgRecord = BeenSwamped._loadCfgData(cfgData)
  return cfgRecord
end
def.static("userdata", "=>", "table")._loadCfgData = function(entry)
  if entry == nil then
    return nil
  end
  local cfgRecord = {}
  cfgRecord.qianwen_title = entry:GetStringValue("qianwen_title")
  cfgRecord.sort_id = entry:GetIntValue("sort_id")
  cfgRecord.point = entry:GetIntValue("point")
  cfgRecord.qianwen_content_1 = entry:GetStringValue("qianwen_content_1")
  cfgRecord.qianwen_content_2 = entry:GetStringValue("qianwen_content_2")
  cfgRecord.qianwen_content_3 = entry:GetStringValue("qianwen_content_3")
  cfgRecord.qianwen_content_4 = entry:GetStringValue("qianwen_content_4")
  return cfgRecord
end
def.static("table").OnStartToSign = function(p)
  local self = BeenSwamped.Instance()
  self._toSignId = p.qiuqian_id
  self._sessionId = Int64.ToNumber(p.sessionid)
  if self._toSignId == nil or self._sessionId == nil then
    warn("Parse Start to Qiuqian callback param failed..")
    return nil
  end
  self:ShowModal()
end
def.static("table").OnSignFailed = function(p)
  if p.res == nil then
    warn("Pasre qiuqian OnSignFailed error :p.res is nil ")
    return nil
  end
  local SQiuQianFail = require("netio.protocol.mzm.gsp.qiuqian.SQiuQianFail")
  if p.res == SQiuQianFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    warn(">>>>Qiuqian Module has been closed or curren role has been forbidden<<<<")
  elseif p.res == SQiuQianFail.ROLE_STATUS_ERROR then
    warn(">>>>Qiuqian : role status error <<<<")
  elseif p.res == SQiuQianFail.PARAM_ERROR then
    warn(">>>>Qiuqian : param error <<<<")
  elseif p.res == SQiuQianFail.OVERTIME then
    warn(">>>>Qiuqian : operation timeout <<<<")
  elseif p.res == SQiuQianFail.CONTEXT_NOT_MATCH then
    warn(">>>>Qiuqian : Context not match <<<<")
  end
  Toast(textRes.SongZiGuanYin[15])
  local self = BeenSwamped.Instance()
  self._bCanClosePanel = true
  self:HidePanel()
end
def.static("table").OnSignSuccess = function(p)
  if p.sort_id == nil or p.qiuqian_id == nil then
    warn("Pasre qiuqian OnSignSuccess error:p.res is nil ")
  end
  local self = BeenSwamped.Instance()
  self._bCanClosePanel = true
  self._toSignId = p.qiuqian_id
  self._gotSortId = p.sort_id
  self:ShowSign()
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if p.feature == Feature.TYPE_GUAN_YIN_QIU_QIAN then
    if p.open then
      activityInterface:removeCustomCloseActivity(constant.GuanYinConsts.QIUQIAN_ACTIVITY_CFG_ID)
    else
      activityInterface:addCustomCloseActivity(constant.GuanYinConsts.QIUQIAN_ACTIVITY_CFG_ID)
    end
  end
end
def.static("table", "table").OnGetBaby = function(p, context)
  local self = BeenSwamped.Instance()
  self._bHasGetBaby = true
end
return BeenSwamped.Commit()
