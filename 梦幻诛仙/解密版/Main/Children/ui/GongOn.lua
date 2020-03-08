local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GUIUtils = require("GUI.GUIUtils")
local GongOn = Lplus.Extend(ECPanelBase, "GongOn")
local MoneyType = require("consts.mzm.gsp.shanggong.confbean.ShangGongMoneyType")
local instance
local def = GongOn.define
def.field("boolean")._bIsCreated = false
def.field("boolean")._bNeedSendReq = true
def.field("boolean")._bHasGotBaby = false
def.field("userdata")._uiGroup_SilverGP = nil
def.field("userdata")._uiGroup_GoldGP = nil
def.field("userdata")._uiGroup_YuanbaoGP = nil
def.field("userdata")._uiRoot = nil
def.field("number")._sessionId = 0
def.field("number")._GongOnId = 0
def.field("number")._timerEffect = -1
def.field("number")._iCurrentGongOnType = 0
def.field("number")._iGongOnNum = 0
def.field("number")._iMaxGongOnNum = 1
def.field("number")._iHasGongOnType = -1
def.field("table")._cfgData = nil
def.const("table").LIGHT_TYPE = {
  NONE = 1,
  SQUARE = 2,
  ROUND = 3
}
def.static("=>", GongOn).Instance = function()
  if instance == nil then
    instance = GongOn()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._bIsCreated = true
  local activityID = constant.GuanYinConsts.QIUQIAN_ACTIVITY_CFG_ID
  local signCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(activityID)
  self._iMaxGongOnNum = signCfg.limitCount
  self:InitUI()
end
def.method().RegisterProtocols = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shanggong.SShangGongFail", GongOn.OnGongOnFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.shanggong.SShangGongSuccess", GongOn.OnGongOnSuccess)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GongOnGetBaby, GongOn.OnGetBaby)
end
def.override().OnDestroy = function(self)
  self._bIsCreated = false
  self._bHasGotBaby = false
  self._bNeedSendReq = true
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GongOnGetBaby, GongOn.OnGetBaby)
end
def.override("boolean").OnShow = function(self, bIsShow)
end
def.method().ToShow = function(self)
  if not self._bIsCreated then
    self:ResendGongOnReq()
  end
end
def.method().ShowPanel = function(self)
  if not self._bIsCreated then
    self:CreatePanel(RESPATH.PREFAB_SHANGGONG_UI, 1)
    self:SetModal(true)
    self:Show(true)
  end
end
def.method().HidePanel = function(self)
  if not self._bIsCreated then
    return
  end
  self:DestroyPanel()
end
def.method().InitUI = function(self)
  local GongUIRoot = self.m_panel:FindDirect("Img_Bg/Img_Bg01/Scroll View_Item/Grid_Bg")
  self._uiRoot = GongUIRoot
  self._uiGroup_SilverGP = GongUIRoot:FindDirect("Group_GongPin_1")
  self._uiGroup_GoldGP = GongUIRoot:FindDirect("Group_GongPin_2")
  self._uiGroup_YuanbaoGP = GongUIRoot:FindDirect("Group_GongPin_3")
  self:LoadCfgData()
  local cfgDataSize = #self._cfgData
  if cfgDataSize == 0 then
    warn("Load ShangGong Cfg data error")
    return
  end
  for i = 1, cfgDataSize do
    local money_type = self._cfgData[i].money_type
    if money_type == MoneyType.SILVER then
      self:UpdateGongPinUI(self._uiGroup_SilverGP, self._cfgData[i].gong_name, self._cfgData[i].iconID, self._cfgData[i].integral, self._cfgData[i].money_num, "Icon_Sliver")
    elseif money_type == MoneyType.GOLD then
      self:UpdateGongPinUI(self._uiGroup_GoldGP, self._cfgData[i].gong_name, self._cfgData[i].iconID, self._cfgData[i].integral, self._cfgData[i].money_num, "Icon_Gold")
    elseif money_type == MoneyType.YUANBAO then
      self:UpdateGongPinUI(self._uiGroup_YuanbaoGP, self._cfgData[i].gong_name, self._cfgData[i].iconID, self._cfgData[i].integral, self._cfgData[i].money_num, "Img_Money")
    end
  end
  if self._iGongOnNum >= self._iMaxGongOnNum then
    self:ActiveGongOnBtns(false)
  else
    self:ActiveGongOnBtns(true)
  end
end
def.method().LoadCfgData = function(self)
  local activity_id = constant.GuanYinConsts.SHANGGONG_ID
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SONGZIGUANYIN_GongOnCfg, activity_id)
  if record == nil then
    warn(">>>>>>>>>>>>>>>Get GongCfg return nil ID = " .. tostring(activity_id))
    return
  end
  self._cfgData = self._cfgData or {}
  local vecStructData = record:GetStructValue("gongpin_infosStruct")
  local vecSize = vecStructData:GetVectorSize("gongpin_infos")
  for i = 1, vecSize do
    local ui_record = vecStructData:GetVectorValueByIdx("gongpin_infos", i - 1)
    self._cfgData[i] = {}
    self._cfgData[i].gong_name = ui_record:GetStringValue("gongpin_name")
    self._cfgData[i].iconID = ui_record:GetIntValue("icon_id")
    self._cfgData[i].integral = ui_record:GetIntValue("point")
    self._cfgData[i].money_num = ui_record:GetIntValue("money_num")
    self._cfgData[i].money_type = ui_record:GetIntValue("money_type")
    self._cfgData[i].sort_id = ui_record:GetIntValue("sort_id")
  end
end
def.method("userdata", "string", "number", "number", "number", "string").UpdateGongPinUI = function(self, ctrl_obj, gongName, iconid, integral, money, iconBuy)
  if ctrl_obj == nil then
    warn("Error, got a nil control object")
    return
  end
  local label_GP_name = ctrl_obj:FindDirect("Label_GP_Name")
  local label_GP_JiFen = ctrl_obj:FindDirect("Label_GP_JiFen")
  local icon_GP = ctrl_obj:FindDirect("Texture_GP")
  local label_buy = ctrl_obj:FindDirect("Btn_Buy/Label_Num")
  local icon_bug = ctrl_obj:FindDirect("Btn_Buy/Img_Icon")
  GUIUtils.SetText(label_GP_name, gongName)
  GUIUtils.SetText(label_GP_JiFen, string.format(textRes.Children.SongZiGuanYin[4], integral))
  GUIUtils.SetText(label_buy, money)
  GUIUtils.SetSprite(icon_bug, iconBuy)
  GUIUtils.SetTexture(icon_GP, iconid)
end
def.method("boolean").ActiveGongOnBtns = function(self, bIsEnable)
  local GongUIRoot = self._uiRoot
  if GongUIRoot == nil then
    warn("Can't find GongOn Button Group Root!")
    return nil
  end
  local btns = {}
  for i = 1, 3 do
    btns[i] = GongUIRoot:FindDirect("Group_GongPin_" .. i .. "/Btn_Buy")
  end
  for i = 1, 3 do
    if btns[i] == nil then
      warn("Gong On Panel Can't not find buttons ...")
      return
    else
      GUIUtils.EnableButton(btns[i], bIsEnable)
    end
  end
end
def.method("userdata").onClickObj = function(self, ctrl_obj)
  if ctrl_obj.name == "Btn_Close" then
    self:HidePanel()
    return
  elseif ctrl_obj.name ~= "Btn_Buy" then
    return
  end
  local str_parentName = ctrl_obj.parent.name
  local ctrl_id = string.sub(str_parentName, string.find(str_parentName, "%d", 1))
  if ctrl_id == "1" then
    self:OnBtnSilverCoinClick()
  elseif ctrl_id == "2" then
    self:OnBtnGoldCoinClick()
  elseif ctrl_id == "3" then
    self:OnBtnYuanbaoClick()
  end
end
def.method("number", "=>", "table").getCfgValueByMoneyType = function(self, money_type)
  local vecSize = #self._cfgData
  if vecSize == 0 then
    return nil
  end
  for i = 1, vecSize do
    if self._cfgData[i].money_type == money_type then
      return self._cfgData[i]
    end
  end
  return nil
end
def.method("=>", "boolean").IsCanGongOn = function(self)
  local activityID = constant.GuanYinConsts.SHANGGONG_ACTIVITY_CFG_ID
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local activityInfo = activityInterface:GetActivityInfo(activityID)
  if activityInfo ~= nil and activityInfo.count >= self._iMaxGongOnNum then
    Toast(string.format(textRes.Children.SongZiGuanYin[5], activityInfo.count, self._iMaxGongOnNum))
    return false
  end
  return true
end
def.method().ResendGongOnReq = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CAttendGuanYinShangGongReq").new())
end
def.method().OnBtnSilverCoinClick = function(self)
  self._iCurrentGongOnType = MoneyType.SILVER
  if self:IsCanGongOn() == false then
    return
  end
  local silverGongCfg = self:getCfgValueByMoneyType(MoneyType.SILVER)
  if silverGongCfg == nil then
    warn("No silver config data ...")
    return
  end
  local confirm_txt = string.format(textRes.Children.SongZiGuanYin[10], silverGongCfg.money_num, textRes.Children.SongZiGuanYin[6], silverGongCfg.gong_name)
  local title = ""
  CommonConfirmDlg.ShowConfirm("", confirm_txt, GongOn.ComfirmGongOnCallback, {self})
end
def.method().OnBtnGoldCoinClick = function(self)
  self._iCurrentGongOnType = MoneyType.GOLD
  if self:IsCanGongOn() == false then
    return
  end
  local goldGongCfg = self:getCfgValueByMoneyType(MoneyType.GOLD)
  if goldGongCfg == nil then
    warn("No gold config data ...")
    return
  end
  local confirm_txt = string.format(textRes.Children.SongZiGuanYin[10], goldGongCfg.money_num, textRes.Children.SongZiGuanYin[7], goldGongCfg.gong_name)
  CommonConfirmDlg.ShowConfirm("", confirm_txt, GongOn.ComfirmGongOnCallback, {self})
end
def.method().OnBtnYuanbaoClick = function(self)
  self._iCurrentGongOnType = MoneyType.YUANBAO
  if self:IsCanGongOn() == false then
    return
  end
  local YBGongCfg = self:getCfgValueByMoneyType(MoneyType.YUANBAO)
  if YBGongCfg == nil then
    warn("No Yuanbao config data ...")
    return
  end
  local confirm_txt = string.format(textRes.Children.SongZiGuanYin[10], YBGongCfg.money_num, textRes.Children.SongZiGuanYin[8], YBGongCfg.gong_name)
  CommonConfirmDlg.ShowConfirm("", confirm_txt, GongOn.ComfirmGongOnCallback, {self})
end
def.static("number", "table").ComfirmGongOnCallback = function(id, tag)
  if id == 0 then
    return
  end
  local self = tag[1]
  local hero_coin_num = 0
  local title = ""
  local confirm_txt = ""
  local ItemModule = require("Main.Item.ItemModule")
  local cfgData
  if self._iCurrentGongOnType == MoneyType.SILVER then
    hero_coin_num = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
    cfgData = self:getCfgValueByMoneyType(MoneyType.SILVER)
    if cfgData == nil then
      warn("load silver cfg data error.")
      return nil
    end
    if Int64.lt(hero_coin_num, Int64.new(cfgData.money_num)) then
      confirm_txt = string.format(textRes.Children.SongZiGuanYin[9], textRes.Children.SongZiGuanYin[6])
      CommonConfirmDlg.ShowConfirm(title, confirm_txt, GongOn.OnComfirmBuySilverCallback, nil)
      return
    end
  elseif self._iCurrentGongOnType == MoneyType.GOLD then
    hero_coin_num = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD) or Int64.new(0)
    cfgData = self:getCfgValueByMoneyType(MoneyType.GOLD)
    if cfgData == nil then
      warn("load gold cfg data error.")
      return nil
    end
    if Int64.lt(hero_coin_num, Int64.new(cfgData.money_num)) then
      confirm_txt = string.format(textRes.Children.SongZiGuanYin[9], textRes.Children.SongZiGuanYin[7])
      CommonConfirmDlg.ShowConfirm(title, confirm_txt, GongOn.OnComfirmBuyGoldCallback, nil)
      return
    end
  elseif self._iCurrentGongOnType == MoneyType.YUANBAO then
    hero_coin_num = ItemModule.Instance():GetAllYuanBao() or Int64.new(0)
    cfgData = self:getCfgValueByMoneyType(MoneyType.YUANBAO)
    if cfgData == nil then
      warn("load YUANBAO cfg data error.")
      return nil
    end
    if Int64.lt(hero_coin_num, Int64.new(cfgData.money_num)) then
      _G.GotoBuyYuanbao()
      return
    end
  end
  if self._bNeedSendReq then
    self._bNeedSendReq = false
    self:ResendGongOnReq()
    return
  end
  self._bNeedSendReq = true
  local p = require("netio.protocol.mzm.gsp.shanggong.CShangGongReq").new(self._GongOnId, Int64.new(self._sessionId), cfgData.sort_id, cfgData.money_type, Int64.ToNumber(hero_coin_num))
  gmodule.network.sendProtocol(p)
end
def.static("number", "table").OnComfirmBuySilverCallback = function(yes_or_no, tag)
  if yes_or_no == 0 then
    return
  end
  _G.GoToBuySilver(false)
end
def.static("number", "table").OnComfirmBuyGoldCallback = function(yes_or_no, tag)
  if yes_or_no == 0 then
    return
  end
  _G.GoToBuyGold(false)
end
def.static("number", "table").OnComfirmBuyYuanbaoCallback = function(yes_or_no, tag)
  if yes_or_no == 0 then
    return
  end
  _G.GotoBuyYuanbao()
end
def.static("table").OnGongOnFail = function(p)
  if p.shanggong_id == nil or p.res == nil then
    warn("Unknow error when ShangOn..")
  end
  local SShangGongFail = require("netio.protocol.mzm.gsp.shanggong.SShangGongFail")
  if SShangGongFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN == p.res then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif SShangGongFail.ROLE_STATUS_ERROR == p.res then
    warn(">>>>Role ROLE_STATUS_ERROR<<<<")
  elseif SShangGongFail.PARAM_ERROR == p.res then
    warn(">>>>PARAM_ERROR<<<<")
  elseif SShangGongFail.OVERTIME == p.res then
    warn(">>>>OVERTIME<<<<")
  elseif SShangGongFail.CONTEXT_NOT_MATCH == p.res then
    warn(">>>>CONTEXT_NOT_MATCH<<<<")
  elseif SShangGongFail.MONEY_NOT_MATCH == p.res then
    warn(">>>>MONEY_NOT_MATCH<<<<")
  elseif SShangGongFail.MONEY_NOT_ENOUGH == p.res then
    Toast(textRes.Children.SongZiGuanYin[24])
  elseif SShangGongFail.COST_MONEY_FAIL == p.res then
    warn(">>>>COST_MONEY_FAIL<<<<")
  end
  local self = GongOn.Instance()
end
def.static("table").OnGongOnSuccess = function(p)
  if p.shanggong_id == nil or p.sort_id == nil then
    return nil
  end
  local self = GongOn.Instance()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SONGZIGUANYIN_GongOnCfg, p.shanggong_id)
  local duration = DynamicRecord.GetIntValue(record, "anim_duration")
  local cfgDataStruct = record:GetStructValue("gongpin_infosStruct")
  local cfgData = cfgDataStruct:GetVectorValueByIdx("gongpin_infos", p.sort_id - 1)
  local integralValue = cfgData:GetIntValue("point")
  duration = duration or 3
  if self._timerEffect == -1 then
    self:DisplayGongOnBtnEffect(self._iCurrentGongOnType, duration)
  end
  Toast(string.format(textRes.Children.SongZiGuanYin[19], integralValue))
end
def.method("number", "number").DisplayGongOnBtnEffect = function(self, coinType, seconds)
  if self._uiGroup_SilverGP == nil or self._uiGroup_GoldGP == nil or self._uiGroup_YuanbaoGP == nil then
    warn("GongOn buttons can't be find in display button effect")
    return
  end
  local icon_GP
  if coinType == MoneyType.SILVER then
    icon_GP = self._uiGroup_SilverGP:FindDirect("Texture_GP")
  elseif coinType == MoneyType.GOLD then
    icon_GP = self._uiGroup_GoldGP:FindDirect("Texture_GP")
  elseif coinType == MoneyType.YUANBAO then
    icon_GP = self._uiGroup_YuanbaoGP:FindDirect("Texture_GP")
  end
  if icon_GP == nil then
    warn("Can't find GongOn buttons effect")
    return
  else
    self:SetLightEffect(icon_GP, GongOn.LIGHT_TYPE.SQUARE)
    self._timerEffect = GameUtil.AddGlobalTimer(seconds, true, function()
      self._timerEffect = -1
      if not self._bIsCreated then
        return
      end
      self:SetLightEffect(icon_GP, GongOn.LIGHT_TYPE.NONE)
    end)
  end
end
def.method("userdata", "number").SetLightEffect = function(self, go, lightType)
  if go == nil or go.isnil then
    return
  end
  local lightName = "lighteffect"
  local GUIFxMan = require("Fx.GUIFxMan")
  local Vector = require("Types.Vector")
  if lightType == GongOn.LIGHT_TYPE.SQUARE then
    local lighteffect = go:FindDirect(lightName)
    if lighteffect then
      return
    end
    local widget = go:GetComponent("UIWidget")
    local w = widget:get_width()
    local h = widget:get_height()
    local xScale = w / 64
    local yScale = h / 64
    GUIFxMan.Instance():PlayAsChildLayer(go, RESPATH.PREFAB_GONG_SUCCESS_EFFECT, lightName, 0, 0, xScale, yScale, -1, false)
  elseif lightType == GongOn.LIGHT_TYPE.SQUARE then
    local lighteffect = go:FindDirect(lightName)
    if lighteffect then
      return
    end
    local widget = go:GetComponent("UIWidget")
    local w = widget:get_width()
    local h = widget:get_height()
    local radius = math.min(w, h)
    local scale = radius / 64
    local fx = GUIFxMan.Instance():PlayAsChildLayer(go, RESPATH.BTN_LIGHT_ROUND, lightName, 0, 0, scale, scale, -1, false)
  else
    local lighteffect = go:FindDirect(lightName)
    if lighteffect then
      Object.Destroy(lighteffect)
    end
  end
end
def.static("table").OnStartAttenGongOn = function(p)
  local self = GongOn.Instance()
  self._GongOnId = p.shanggong_id
  self._sessionId = Int64.ToNumber(p.sessionid)
  self:ShowPanel()
  if not self._bNeedSendReq then
    GongOn.ComfirmGongOnCallback(1, {self})
  end
end
def.static("table", "table").OnGetBaby = function(p, context)
  local self = GongOn.Instance()
  self._bHasGotBaby = true
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if p.feature == Feature.TYPE_SHANG_GONG then
    if p.open then
      activityInterface:removeCustomCloseActivity(constant.GuanYinConsts.SHANGGONG_ACTIVITY_CFG_ID)
    else
      activityInterface:addCustomCloseActivity(constant.GuanYinConsts.SHANGGONG_ACTIVITY_CFG_ID)
    end
  end
end
return GongOn.Commit()
