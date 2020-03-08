local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local PartnerMain = Lplus.ForwardDeclare("PartnerMain")
local PartnerMain_Info = Lplus.Class("PartnerMain_Info")
local def = PartnerMain_Info.define
local inst
local ECModel = require("Model.ECModel")
local UIModelWrap = require("Model.UIModelWrap")
local LV1Property = require("consts.mzm.gsp.partner.confbean.LV1Property")
local LV2Property = require("consts.mzm.gsp.partner.confbean.LV2Property")
local PartnerFaction = require("consts.mzm.gsp.partner.confbean.PartnerFaction")
local PartnerSex = require("consts.mzm.gsp.partner.confbean.PartnerSex")
local PartnerType = require("consts.mzm.gsp.partner.confbean.PartnerType")
local UnlockItem = require("consts.mzm.gsp.partner.confbean.UnlockItem")
local ItemUtils = require("Main.Item.ItemUtils")
local PubroleInterface = require("Main.Pubrole.PubroleInterface")
local PartnerInterface = require("Main.partner.PartnerInterface")
local partnerInterface = PartnerInterface.Instance()
local PersonalHelper = require("Main.Chat.PersonalHelper")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
def.field(PartnerMain)._partnerMain = nil
def.field("boolean")._isShow = false
def.field("boolean")._isDraging = false
def.field(UIModelWrap)._UIModelWrap = nil
def.field("table")._partnerProterty = nil
def.field("number").tipsItemId = 0
def.field("boolean")._isTipShowSource = true
def.static(PartnerMain, "=>", PartnerMain_Info).New = function(panel)
  if inst == nil then
    inst = PartnerMain_Info()
    inst._partnerMain = panel
    inst:Init()
  end
  return inst
end
def.static("=>", PartnerMain_Info).Instance = function()
  return inst
end
def.method().Init = function(self)
end
def.method().OnCreate = function(self)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Group_Info = panel:FindDirect("Group_Right/Group_Info")
  local Group_Basic = Group_Info:FindDirect("Group_Basic")
  local Grid_Attribute = Group_Basic:FindDirect("Grid_Attribute")
  local Grid_Skill = Group_Basic:FindDirect("Grid_Skill")
  for idx = 1, 8 do
    local Skill_ = Grid_Skill:FindDirect(string.format("Skill_%d", idx))
    local Img_BgIcon = Skill_:FindDirect("Img_BgIcon")
    Img_BgIcon:set_name(string.format("Img_BgIcon_Skill_%d", idx))
  end
end
def.method().OnDestroy = function(self)
  self:DestroyInfoModel()
  self._UIModelWrap = nil
  self._isShow = false
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, PartnerMain_Info.OnMoneyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, PartnerMain_Info.OnMoneyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, PartnerMain_Info.OnMoneyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, PartnerMain_Info.OnMoneyChanged)
  Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LovesDataChanged, PartnerMain_Info.OnPartnerLovesDataChanged)
  Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_PropertyChanged, PartnerMain_Info.OnPartnerPropertyChanged)
end
def.method("=>", "boolean").IsShow = function(self)
  if self._partnerMain == nil or self._partnerMain.m_panel == nil or self._partnerMain.m_panel.isnil or self._partnerMain:IsShow() == false then
    return false
  end
  local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
  local ret = Group_Info:get_activeInHierarchy() == true
  return ret
end
def.method().DestroyInfoModel = function(self)
  if self._UIModelWrap ~= nil then
    self._UIModelWrap:Destroy()
  end
end
def.method("boolean").OnShow = function(self, s)
  if self._isShow == s then
    return
  end
  self._isShow = s
  if s == true then
    local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
    local Model = Group_Info:FindDirect("Img_BgModel/Model")
    local uiModel = Model:GetComponent("UIModel")
    uiModel.mCanOverflow = true
    self:DestroyInfoModel()
    self._UIModelWrap = UIModelWrap.new(uiModel)
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, PartnerMain_Info.OnMoneyChanged)
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, PartnerMain_Info.OnMoneyChanged)
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, PartnerMain_Info.OnMoneyChanged)
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, PartnerMain_Info.OnMoneyChanged)
    Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LovesDataChanged, PartnerMain_Info.OnPartnerLovesDataChanged)
    Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_PropertyChanged, PartnerMain_Info.OnPartnerPropertyChanged)
    if self._UIModelWrap ~= nil and self._UIModelWrap._model ~= nil then
      self._UIModelWrap._model:Play("Stand_c")
    end
  else
    self:DestroyInfoModel()
    self._isDraging = false
    Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, PartnerMain_Info.OnMoneyChanged)
    Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, PartnerMain_Info.OnMoneyChanged)
    Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, PartnerMain_Info.OnMoneyChanged)
    Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, PartnerMain_Info.OnMoneyChanged)
    Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LovesDataChanged, PartnerMain_Info.OnPartnerLovesDataChanged)
    Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_PropertyChanged, PartnerMain_Info.OnPartnerPropertyChanged)
  end
end
def.static("table", "table").OnMoneyChanged = function(p1, p2)
  local self = inst
  local index = self._partnerMain._selectedIndex
  local cfg = self._partnerMain._partnerList[index]
  local invited = partnerInterface:HasThePartner(cfg.id)
  if invited == true then
    self:_FillSelectedLoveProp(cfg)
  else
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local lock = heroProp.level < cfg.unlockLevel
    self:_FillInvite(cfg, lock)
  end
end
def.static("table", "table").OnPartnerLovesDataChanged = function(p1, p2)
  local self = inst
  local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  local invited = partnerInterface:HasThePartner(cfg.id)
  self:_FillSelectedLoveProp(cfg)
end
def.static("table", "table").OnPartnerPropertyChanged = function(p1, p2)
  local self = inst
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Group_Info = panel:FindDirect("Group_Right/Group_Info")
  local activeSelf = Group_Info:get_activeSelf()
  if activeSelf == true then
    local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
    local invited = partnerInterface:HasThePartner(cfg.id)
    self:_FillSelectedProp(self._partnerMain._selectedIndex, cfg)
    self:_FillSelectedAttrib(cfg, invited)
    self:_FillSelectedSkill(cfg, invited)
  end
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:HideDlg()
    return
  end
  local fnTable = {}
  fnTable.Btn_Invite = PartnerMain_Info.OnBtnInvite
  fnTable.Btn_Special = PartnerMain_Info.OnBtnSpecial
  fnTable.Img_BgHead1 = PartnerMain_Info.OnBtn_Yuan1
  fnTable.Img_BgHead2 = PartnerMain_Info.OnBtn_Yuan2
  fnTable.Img_Item = PartnerMain_Info.OnImgItem
  fnTable.Btn_XL = PartnerMain_Info.OnBtn_XL
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
    return true
  end
  local strs = string.split(id, "_")
  if strs[1] == "Img" and strs[2] == "BgIcon" and strs[3] == "Skill" then
    local index = tonumber(strs[4])
    if index ~= nil then
      self:_ShowSkillTip(index)
      return true
    end
  end
  return false
end
def.method().OnBtnInvite = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local index = self._partnerMain._selectedIndex
  local cfg = self._partnerMain._partnerList[index]
  local ItemModule = require("Main.Item.ItemModule")
  local itemModule = gmodule.moduleMgr:GetModule(ModuleId.ITEM)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local MallPanel = require("Main.Mall.ui.MallPanel")
  local fnTable = {}
  fnTable[UnlockItem.UL_YUANBAO] = function()
    local yuanBaoAmount = itemModule:GetAllYuanBao()
    local ret = tonumber(tostring(yuanBaoAmount)) >= cfg.unlockItemNum
    if ret == false then
      local personAward = {}
      table.insert(personAward, {
        PersonalHelper.Type.Text,
        textRes.Partner[13]
      })
      table.insert(personAward, {
        PersonalHelper.Type.Yuanbao,
        cfg.unlockItemNum
      })
      PersonalHelper.CommonTableMsg(personAward)
      MallPanel.Instance():ShowPanel(MallPanel.StateConst.Pay, 0, 0)
    end
    return ret, string.format(textRes.Partner[16], cfg.unlockItemNum)
  end
  fnTable[UnlockItem.UL_GOLD] = function()
    local gold = itemModule:GetMoney(ItemModule.MONEY_TYPE_GOLD)
    local ret = tonumber(tostring(gold)) >= cfg.unlockItemNum
    if ret == false then
      local personAward = {}
      table.insert(personAward, {
        PersonalHelper.Type.Text,
        textRes.Partner[13]
      })
      table.insert(personAward, {
        PersonalHelper.Type.Gold,
        cfg.unlockItemNum
      })
      PersonalHelper.CommonTableMsg(personAward)
      GoToBuyGold(false)
    end
    return ret, string.format(textRes.Partner[17], cfg.unlockItemNum)
  end
  fnTable[UnlockItem.UL_SILVER] = function()
    local silver = itemModule:GetMoney(ItemModule.MONEY_TYPE_SILVER)
    local ret = tonumber(tostring(silver)) >= cfg.unlockItemNum
    if ret == false then
      local personAward = {}
      table.insert(personAward, {
        PersonalHelper.Type.Text,
        textRes.Partner[13]
      })
      table.insert(personAward, {
        PersonalHelper.Type.Silver,
        cfg.unlockItemNum
      })
      PersonalHelper.CommonTableMsg(personAward)
      GoToBuySilver(false)
    end
    return ret, string.format(textRes.Partner[18], cfg.unlockItemNum)
  end
  fnTable[UnlockItem.UL_ITEM] = function()
    local itemData = require("Main.Item.ItemData").Instance()
    local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
    local num = itemData:GetNumByItemType(BagInfo.BAG, constant.PartnerConstants.Partner_ITEM_TYPE_ID)
    local ret = num >= cfg.unlockItemNum
    if ret == false then
      local personAward = {}
      table.insert(personAward, {
        PersonalHelper.Type.Text,
        textRes.Partner[13]
      })
      local itemmap = {}
      itemmap[cfg.unlockItemId] = cfg.unlockItemNum
      table.insert(personAward, {
        PersonalHelper.Type.ItemMap,
        itemmap
      })
      PersonalHelper.CommonTableMsg(personAward)
      local needItemId = cfg.unlockItemId
      if needItemId then
        local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
        local targetObj = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info/Group_Invite/Btn_Invite")
        if targetObj then
          local Sprite = targetObj:GetComponent("UISprite")
          local worldposition = targetObj.position
          local position = WorldPosToScreen(worldposition.x, worldposition.y)
          local width = Sprite:get_width()
          local height = Sprite:get_height()
          ItemTipsMgr.Instance():ShowBasicTips(needItemId, position.x, position.y, width, height, 0, true)
        end
      end
    end
    local itemBase = ItemUtils.GetItemBase(cfg.unlockItemId)
    return ret, string.format(textRes.Partner[15], cfg.unlockItemNum, itemBase.name)
  end
  local fn = fnTable[cfg.unlockItem]
  local ret = false
  local txt = ""
  local needItemId = cfg.unlockItemId
  if fn ~= nil then
    print("***** PartnerMain_Info.OnBtnInvite fn ~= nil")
    ret, txt = fn()
  end
  if ret == false then
    print("***** PartnerMain_Info.OnBtnInvite ret == false")
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Partner[5], txt, PartnerMain_Info.OnInvitePartnerConfirm, {cfg = cfg})
end
def.method().OnBtn_Yuan1 = function(self)
  local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  local invited = partnerInterface:HasThePartner(cfg.id)
  if invited == false then
    require("Main.partner.ui.PartnerTips").Instance():ShowDlg(cfg.id)
    return
  end
  local LoveInfos = partnerInterface:GetPartnerLoveInfos(cfg.id) or {}
  local loveID = LoveInfos[1]
  if loveID ~= nil then
    local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
    local Group_Yuan = Group_Info:FindDirect("Group_Yuan")
    local Img_BgHead1 = Group_Yuan:FindDirect("Img_BgHead1")
    local position = Img_BgHead1:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = Img_BgHead1:GetComponent("UISprite")
    if constant.PartnerConstants.NULL_LOVE_ID ~= loveID then
      require("Main.partner.ui.PartnerTips2").Instance():ShowDlg(loveID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
    end
  end
end
def.method().OnBtn_Yuan2 = function(self)
  local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  local invited = partnerInterface:HasThePartner(cfg.id)
  if invited == false then
    require("Main.partner.ui.PartnerTips").Instance():ShowDlg(cfg.id)
    return
  end
  local LoveInfos = partnerInterface:GetPartnerLoveInfos(cfg.id) or {}
  local loveID = LoveInfos[2]
  if loveID ~= nil then
    local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
    local Group_Yuan = Group_Info:FindDirect("Group_Yuan")
    local Img_BgHead2 = Group_Yuan:FindDirect("Img_BgHead2")
    local position = Img_BgHead2:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = Img_BgHead2:GetComponent("UISprite")
    if constant.PartnerConstants.NULL_LOVE_ID ~= loveID then
      require("Main.partner.ui.PartnerTips2").Instance():ShowDlg(loveID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
    end
  end
end
def.method().OnBtn_XL = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  require("Main.partner.ui.PartnerRelation").Instance():ShowDlg(cfg.id)
end
def.method().OnBtnSpecial = function(self)
  local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  local specialGetPartnerCfg = PartnerInterface.GetSpecialPartnerCfg(cfg.id)
  if specialGetPartnerCfg ~= nil then
    local uiPath = specialGetPartnerCfg.uiPath
    if uiPath == "panel_commonexchange" then
      gmodule.moduleMgr:GetModule(ModuleId.EXCHANGE):ShowExchangePanel()
    else
      local AwardPanel = require("Main.Award.ui.AwardPanel")
      local nodeId = AwardPanel.Instance():GetNodeIdByTabName(uiPath)
      if nodeId ~= 0 then
        AwardPanel.Instance():ShowPanelEx(nodeId)
      end
    end
  end
end
def.method().OnImgItem = function(self)
  local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
  local Group_Invite = Group_Info:FindDirect("Group_Invite")
  local Img_Item = Group_Invite:FindDirect("Img_Item")
  local position = Img_Item:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = Img_Item:GetComponent("UISprite")
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  if self.tipsItemId ~= 0 then
    ItemTipsMgr.Instance():ShowBasicTips(self.tipsItemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, self._isTipShowSource)
  end
end
def.static("number", "table").OnInvitePartnerConfirm = function(id, tag)
  if id == 1 then
    local partnerId = tag.cfg.id
    local CActivePartnerReq = require("netio.protocol.mzm.gsp.partner.CActivePartnerReq").new(partnerId)
    gmodule.network.sendProtocol(CActivePartnerReq)
  end
end
def.method("number", "table")._FillSelectedLV1Prop = function(self, index, cfg)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  self:_FillSelectedProp(index, cfg)
  local invited = partnerInterface:HasThePartner(cfg.id)
  self:_FillSelectedModel(cfg)
  self:_FillSelectedAttrib(cfg, invited)
  self:_FillSelectedSkill(cfg, invited)
  if invited == true then
    self:_FillSelectedLoveProp(cfg)
  else
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local lock = heroProp.level < cfg.unlockLevel
    self:_FillInvite(cfg, lock)
  end
end
def.method("number", "table")._FillSelectedProp = function(self, index, cfg)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Group_Info = panel:FindDirect("Group_Right/Group_Info")
  local partnerProperty = partnerInterface:GetPartnerProperty(cfg.id)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local PartnerProterty = require("Main.partner.PartnerProterty")
  self._partnerProterty = PartnerProterty.New(cfg, heroProp.level)
  local Group_Red = Group_Info:FindDirect("Group_Slider/Group_Red")
  local Slider_SX_BgBlood = Group_Red:FindDirect("Slider_SX_BgBlood")
  local Label_SX_SliderBlood = Slider_SX_BgBlood:FindDirect("Label_SX_SliderBlood")
  if partnerProperty ~= nil then
    Label_SX_SliderBlood:GetComponent("UILabel"):set_text(string.format("%d/%d", partnerProperty.hp, partnerProperty.maxHp))
    Slider_SX_BgBlood:GetComponent("UIProgressBar").value = math.min(1, partnerProperty.hp / partnerProperty.maxHp)
  else
    local hp = PartnerProterty.get_MAX_HP(self._partnerProterty)
    hp = math.floor(hp + 0.5)
    Label_SX_SliderBlood:GetComponent("UILabel"):set_text(string.format("%d/%d", hp, hp))
    Slider_SX_BgBlood:GetComponent("UIProgressBar").value = 1
  end
  local Group_Blue = Group_Info:FindDirect("Group_Slider/Group_Blue")
  local Slider_SX_BgBlue = Group_Blue:FindDirect("Slider_SX_BgBlue")
  local Label_SX_SliderBlue = Slider_SX_BgBlue:FindDirect("Label_SX_SliderBlue")
  if partnerProperty ~= nil then
    Label_SX_SliderBlue:GetComponent("UILabel"):set_text(string.format("%d/%d", partnerProperty.mp, partnerProperty.maxMp))
    Slider_SX_BgBlue:GetComponent("UIProgressBar").value = math.min(1, partnerProperty.mp / partnerProperty.maxMp)
  else
    local mp = PartnerProterty.get_MAX_MP(self._partnerProterty)
    mp = math.floor(mp + 0.5)
    Label_SX_SliderBlue:GetComponent("UILabel"):set_text(string.format("%d/%d", mp, mp))
    Slider_SX_BgBlue:GetComponent("UIProgressBar").value = 1
  end
  local Group_Power = Group_Info:FindDirect("Group_Power")
  if partnerProperty ~= nil then
    Group_Power:SetActive(true)
    local Label_Power = Group_Power:FindDirect("Label_Power")
    Label_Power:GetComponent("UILabel"):set_text(tostring(partnerProperty.fightValue))
  else
    Group_Power:SetActive(false)
  end
  local pinjieLabel = Group_Info:FindDirect("Group_PingJie/Label"):GetComponent("UILabel")
  local rankInfoId = partnerInterface:getPartnerInfoCfgId(cfg.id)
  if rankInfoId > 0 then
    local rankInfoCfg = PartnerInterface.GetRankInfoCfg(rankInfoId)
    local rankEnum = rankInfoCfg.rankEnum
    local rankLvStr = partnerInterface:getRankLevelStr(rankEnum)
    if rankLvStr then
      pinjieLabel:set_text(rankLvStr)
    else
      pinjieLabel:set_text(cfg.rank)
    end
  else
    Label_FightLevel:GetComponent("UILabel"):set_text(cfg.rank)
  end
  local Label_PartnerName = Group_Info:FindDirect("Label_PartnerName")
  Label_PartnerName:GetComponent("UILabel"):set_text(cfg.name)
  local Img_Tpye = Group_Info:FindDirect("Group_PingJie/Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(cfg.classType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
end
def.method("table")._FillSelectedLoveProp = function(self, cfg)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Group_Info = panel:FindDirect("Group_Right/Group_Info")
  local Group_Yuan = Group_Info:FindDirect("Group_Yuan")
  Group_Yuan:SetActive(true)
  local Group_Invite = Group_Info:FindDirect("Group_Invite")
  Group_Invite:SetActive(false)
  local Label_Yuan1 = Group_Yuan:FindDirect("Btn_Yuan1/Label_Yuan")
  local Label_Yuan2 = Group_Yuan:FindDirect("Btn_Yuan2/Label_Yuan")
  local Img_BgHead1 = Group_Yuan:FindDirect("Img_BgHead1/Text_Head")
  local Img_BgHead2 = Group_Yuan:FindDirect("Img_BgHead2/Text_Head")
  local Img_Yuan = Group_Yuan:FindDirect("Img_Yuan")
  local table_yuan = {Img_BgHead1, Img_BgHead2}
  local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
  local defaultLineUp = partnerInterface:GetLineup(defaultLineUpNum)
  local memberHasLoves = {}
  for k, partnerID in pairs(defaultLineUp.positions) do
    if partnerInterface:IsPartnerJoinedBattle(partnerID) == true then
      local LoveInfos = partnerInterface:GetPartnerLoveInfos(partnerID)
      if LoveInfos ~= nil then
        for k, loveID in pairs(LoveInfos) do
          local LoveDataCfg = PartnerInterface.GetPartnerLoveDataCfg(loveID)
          local result = false
          if LoveDataCfg.toPartner1 ~= partnerID and partnerInterface:IsPartnerJoinedBattle(LoveDataCfg.toPartner1) == true then
            result = true
            memberHasLoves[partnerID] = true
            memberHasLoves[LoveDataCfg.toPartner1] = true
          end
          if LoveDataCfg.toPartner2 ~= partnerID and partnerInterface:IsPartnerJoinedBattle(LoveDataCfg.toPartner2) == true then
            result = true
            memberHasLoves[partnerID] = true
            memberHasLoves[LoveDataCfg.toPartner2] = true
          end
          if LoveDataCfg.toPartner3 ~= partnerID and partnerInterface:IsPartnerJoinedBattle(LoveDataCfg.toPartner3) == true then
            result = true
            memberHasLoves[partnerID] = true
            memberHasLoves[LoveDataCfg.toPartner3] = true
          end
        end
      end
    end
  end
  Img_Yuan:SetActive(memberHasLoves[partnerID] == true)
  local i = 0
  local LoveInfos = partnerInterface:GetPartnerLoveInfos(cfg.id) or {}
  for i = 1, 2 do
    local loveID = LoveInfos[i]
    local LoveDataCfg
    if loveID ~= nil then
      LoveDataCfg = PartnerInterface.GetPartnerLoveDataCfg(loveID)
    end
    if LoveDataCfg ~= nil then
      table_yuan[i]:SetActive(true)
      local uiTexture = table_yuan[i]:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, LoveDataCfg.loveIconId)
    else
      table_yuan[i]:SetActive(false)
    end
  end
end
def.method("table")._FillSelectedModel = function(self, cfg)
  local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
  local Model = Group_Info:FindDirect("Img_BgModel/Model")
  local uiModel = Model:GetComponent("UIModel")
  local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, cfg.modelId)
  local resourcePath = DynamicRecord.GetStringValue(modelinfo, "modelResPath")
  if resourcePath == "" or resourcePath == nil then
    warn(" resourcePath == \"\" modelId = " .. cfg.modelId)
  else
    self._UIModelWrap:Load(resourcePath .. ".u3dext")
  end
end
def.method("table", "boolean")._FillSelectedAttrib = function(self, cfg, invited)
  local partnerProperty = partnerInterface:GetPartnerProperty(cfg.id)
  local PartnerProterty = require("Main.partner.PartnerProterty")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local lpCfg = PartnerInterface.GetLevelToPropertyCfg(cfg.level2propertyId, heroProp.level)
  local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
  local Group_Basic = Group_Info:FindDirect("Group_Basic")
  local Grid_Attribute = Group_Basic:FindDirect("Grid_Attribute")
  local Group_Attribute1 = Grid_Attribute:FindDirect("Group_Attribute1")
  local Label_Num = Group_Attribute1:FindDirect("Label_Num")
  if partnerProperty == nil then
    local PhyAtk = PartnerProterty.get_PHYATK(self._partnerProterty)
    Label_Num:GetComponent("UILabel"):set_text(math.floor(PhyAtk + 0.5))
  else
    Label_Num:GetComponent("UILabel"):set_text(partnerProperty.phyAtk)
  end
  local Group_Attribute2 = Grid_Attribute:FindDirect("Group_Attribute2")
  local Label_Num = Group_Attribute2:FindDirect("Label_Num")
  if partnerProperty == nil then
    local PhyDef = PartnerProterty.get_PHYDEF(self._partnerProterty)
    Label_Num:GetComponent("UILabel"):set_text(math.floor(PhyDef + 0.5))
  else
    Label_Num:GetComponent("UILabel"):set_text(partnerProperty.phyDef)
  end
  local Group_Attribute3 = Grid_Attribute:FindDirect("Group_Attribute3")
  local Label_Num = Group_Attribute3:FindDirect("Label_Num")
  if partnerProperty == nil then
    local MagAtk = PartnerProterty.get_MAGATK(self._partnerProterty)
    Label_Num:GetComponent("UILabel"):set_text(math.floor(MagAtk + 0.5))
  else
    Label_Num:GetComponent("UILabel"):set_text(partnerProperty.magAtk)
  end
  local Group_Attribute4 = Grid_Attribute:FindDirect("Group_Attribute4")
  local Label_Num = Group_Attribute4:FindDirect("Label_Num")
  if partnerProperty == nil then
    local MagDef = PartnerProterty.get_MAGDEF(self._partnerProterty)
    Label_Num:GetComponent("UILabel"):set_text(math.floor(MagDef + 0.5))
  else
    Label_Num:GetComponent("UILabel"):set_text(partnerProperty.magDef)
  end
  local Group_Attribute5 = Grid_Attribute:FindDirect("Group_Attribute5")
  local Label_Num = Group_Attribute5:FindDirect("Label_Num")
  if partnerProperty == nil then
    local Speed = PartnerProterty.get_SPEED(self._partnerProterty)
    Label_Num:GetComponent("UILabel"):set_text(math.floor(Speed + 0.5))
  else
    Label_Num:GetComponent("UILabel"):set_text(partnerProperty.speed)
  end
  local Group_Attribute6 = Grid_Attribute:FindDirect("Group_Attribute6")
  local Label_Num = Group_Attribute6:FindDirect("Label_Num")
  if partnerProperty == nil then
    local phyCritlevel = PartnerProterty.get_PHY_CRIT_LEVEL(self._partnerProterty)
    Label_Num:GetComponent("UILabel"):set_text(math.floor(phyCritlevel + 0.5))
  else
    Label_Num:GetComponent("UILabel"):set_text(partnerProperty.phyCrt)
  end
  local Group_Attribute7 = Grid_Attribute:FindDirect("Group_Attribute7")
  local Label_Num = Group_Attribute7:FindDirect("Label_Num")
  if partnerProperty == nil then
    local magCritlevel = PartnerProterty.get_MAG_CRT_LEVEL(self._partnerProterty)
    Label_Num:GetComponent("UILabel"):set_text(math.floor(magCritlevel + 0.5))
  else
    Label_Num:GetComponent("UILabel"):set_text(partnerProperty.magCrt)
  end
  local Group_Attribute8 = Grid_Attribute:FindDirect("Group_Attribute8")
  local Label_Num = Group_Attribute8:FindDirect("Label_Num")
  if partnerProperty == nil then
    local fengkang = PartnerProterty.get_SEAL_RESIST(self._partnerProterty)
    Label_Num:GetComponent("UILabel"):set_text(math.floor(fengkang + 0.5))
  else
    Label_Num:GetComponent("UILabel"):set_text(partnerProperty.sealRes)
  end
end
def.method("table", "boolean")._FillSelectedSkill = function(self, cfg, invited)
  for i = 1, 8 do
    local skillId = cfg.skillIds[i]
    if skillId ~= nil then
      local skillCfg = PartnerInterface.GetPartnerSkillCfg(skillId)
      self:_FillASkill(i, cfg, skillCfg)
    else
      self:_ClearASkill(i)
    end
  end
end
def.method("number", "table", "table")._FillASkill = function(self, index, partnerCfg, partnerSkillCfg)
  local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
  local Group_Basic = Group_Info:FindDirect("Group_Basic")
  local Grid_Skill = Group_Basic:FindDirect("Grid_Skill")
  local grid = Grid_Skill:GetComponent("UIGrid")
  local Skill = Grid_Skill:FindDirect(string.format("Skill_%d", index))
  local Label_Name = Skill:FindDirect("Label_Name")
  Label_Name:GetComponent("UILabel"):set_text(partnerSkillCfg.skillCfg.name)
  local Img_BgIcon_Skill = Skill:FindDirect(string.format("Img_BgIcon_Skill_%d", index))
  if Img_BgIcon_Skill == nil then
    local Img_BgIcon = Skill:FindDirect(string.format("Img_BgIcon", index))
    Img_BgIcon:set_name(string.format("Img_BgIcon_Skill_%d", index))
    Img_BgIcon_Skill = Img_BgIcon
  end
  local Tex_Icon = Img_BgIcon_Skill:FindDirect("Tex_Icon")
  Tex_Icon:SetActive(true)
  local uiTexture = Tex_Icon:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, partnerSkillCfg.skillCfg.iconId)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local level = math.max(heroProp.level, partnerCfg.unlockLevel)
  local property = partnerInterface:GetPartnerProperty(partnerCfg.id)
  local isUnlock = true
  if property ~= nil then
    local skillId = partnerCfg.skillIds[index]
    isUnlock = property.skillInfos[skillId] ~= nil
  end
  if isUnlock then
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
  else
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
  end
end
def.method("number")._ClearASkill = function(self, index)
  local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
  local Group_Basic = Group_Info:FindDirect("Group_Basic")
  local Grid_Skill = Group_Basic:FindDirect("Grid_Skill")
  local grid = Grid_Skill:GetComponent("UIGrid")
  local Skill = Grid_Skill:FindDirect(string.format("Skill_%d", index))
  local Label_Name = Skill:FindDirect("Label_Name")
  Label_Name:SetActive(false)
  local Img_BgIcon_Skill = Skill:FindDirect(string.format("Img_BgIcon_Skill_%d", index))
  if Img_BgIcon_Skill == nil then
    local Img_BgIcon = Skill:FindDirect(string.format("Img_BgIcon", index))
    Img_BgIcon:set_name(string.format("Img_BgIcon_Skill_%d", index))
    Img_BgIcon_Skill = Img_BgIcon
  end
  local Tex_Icon = Img_BgIcon_Skill:FindDirect("Tex_Icon")
  Tex_Icon:SetActive(false)
end
def.method()._FillZhenFa = function(self)
  local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
  local defaultLineUp = partnerInterface:GetLineup(defaultLineUpNum)
  local zhenfaName = textRes.Partner[8]
  if defaultLineUp.zhenFaId > 0 then
    local FormationUtils = require("Main.Formation.FormationUtils")
    local zhenfaCfg = FormationUtils.GetFormationCfg(defaultLineUp.zhenFaId)
    zhenfaName = zhenfaCfg.name
  end
end
def.method("table", "boolean")._FillInvite = function(self, cfg, lock)
  local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
  local Group_Yuan = Group_Info:FindDirect("Group_Yuan")
  Group_Yuan:SetActive(false)
  local Group_Invite = Group_Info:FindDirect("Group_Invite")
  Group_Invite:SetActive(true)
  local Label_Invite = Group_Invite:FindDirect("Label_Invite")
  Label_Invite:SetActive(lock == true)
  if lock == true then
    Label_Invite:GetComponent("UILabel"):set_text(string.format(textRes.Partner[1], cfg.unlockLevel))
  end
  local Btn_Invite = Group_Invite:FindDirect("Btn_Invite")
  Btn_Invite:SetActive(lock == false)
  local Btn_Special = Group_Invite:FindDirect("Btn_Special")
  Btn_Special:SetActive(false)
  local ItemModule = require("Main.Item.ItemModule")
  local itemModule = gmodule.moduleMgr:GetModule(ModuleId.ITEM)
  local Label_Num = Group_Invite:FindDirect("Img_BgHave/Label_Num")
  local fnTable = {}
  fnTable[UnlockItem.UL_YUANBAO] = function(sprite1, sprite2)
    sprite1:set_spriteName("Img_Money")
    sprite2:set_spriteName("Img_Money")
    local yuanBaoAmount = itemModule:GetAllYuanBao()
    return tonumber(tostring(yuanBaoAmount)) or 0
  end
  fnTable[UnlockItem.UL_GOLD] = function(sprite1, sprite2)
    sprite1:set_spriteName("Icon_Gold")
    sprite2:set_spriteName("Icon_Gold")
    local gold = itemModule:GetMoney(ItemModule.MONEY_TYPE_GOLD)
    return tonumber(tostring(gold)) or 0
  end
  fnTable[UnlockItem.UL_SILVER] = function(sprite1, sprite2)
    sprite1:set_spriteName("Icon_Sliver")
    sprite2:set_spriteName("Icon_Sliver")
    local silver = itemModule:GetMoney(ItemModule.MONEY_TYPE_SILVER)
    return tonumber(tostring(silver)) or 0
  end
  local Img_Item = Group_Invite:FindDirect("Img_Item")
  local Img_BgHave = Group_Invite:FindDirect("Img_BgHave")
  local Img_BgUse = Group_Invite:FindDirect("Img_BgUse")
  local fn = fnTable[cfg.unlockItem]
  if fn ~= nil then
    local Img_Icon1 = Img_BgHave:FindDirect("Img_Icon")
    local Img_Icon2 = Img_BgUse:FindDirect("Img_Icon")
    local num = fn(Img_Icon1:GetComponent("UISprite"), Img_Icon2:GetComponent("UISprite"))
    if num >= cfg.unlockItemNum then
      Label_Num:GetComponent("UILabel"):set_text(num)
    else
      Label_Num:GetComponent("UILabel"):set_text(string.format(textRes.Partner[3], num))
    end
    local Label_Num = Group_Invite:FindDirect("Img_BgUse/Label_Num")
    Label_Num:GetComponent("UILabel"):set_text(tostring(cfg.unlockItemNum))
    Img_BgHave:SetActive(true)
    Img_BgUse:SetActive(true)
    Img_Item:SetActive(false)
  elseif cfg.unlockItem == UnlockItem.UL_ITEM then
    Img_BgHave:SetActive(false)
    Img_BgUse:SetActive(false)
    Img_Item:SetActive(true)
    local Icon_Item = Img_Item:FindDirect("Icon_Item")
    local Label_Num = Img_Item:FindDirect("Label_Num")
    local Label_Name = Img_Item:FindDirect("Label_Name")
    self._isTipShowSource = true
    local itemBase = ItemUtils.GetItemBase(cfg.unlockItemId)
    if itemBase ~= nil then
      local uiTexture = Icon_Item:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
      Label_Name:GetComponent("UILabel"):set_text(itemBase.name)
      local itemData = require("Main.Item.ItemData").Instance()
      local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
      local num = itemData:GetNumberByItemId(BagInfo.BAG, cfg.unlockItemId)
      local specialGetPartnerCfg = PartnerInterface.GetSpecialPartnerCfg(cfg.id)
      if specialGetPartnerCfg ~= nil then
        self._isTipShowSource = false
      end
      if num >= cfg.unlockItemNum then
        Label_Num:GetComponent("UILabel"):set_text(string.format("%d / %d", cfg.unlockItemNum, num))
      else
        Label_Num:GetComponent("UILabel"):set_text(string.format("[ff0000]%d / %d[-]", cfg.unlockItemNum, num))
        if specialGetPartnerCfg ~= nil and not lock then
          Btn_Invite:SetActive(false)
          Btn_Special:SetActive(true)
          Btn_Special:FindDirect("Label"):GetComponent("UILabel"):set_text(specialGetPartnerCfg.btnName)
        end
      end
      self.tipsItemId = cfg.unlockItemId
    end
  end
end
def.method("number")._ShowSkillTip = function(self, index)
  local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  local skillId = cfg.skillIds[index]
  if skillId ~= nil then
    local skillCfg = PartnerInterface.GetPartnerSkillCfg(skillId)
    local Group_Info = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Info")
    local Group_Basic = Group_Info:FindDirect("Group_Basic")
    local Grid_Skill = Group_Basic:FindDirect("Grid_Skill")
    local Skill = Grid_Skill:FindDirect(string.format("Skill_%d", index))
    local position = Skill:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = Skill:GetComponent("UIWidget")
    local property = partnerInterface:GetPartnerProperty(cfg.id)
    local isUnlock = true
    if property ~= nil then
      isUnlock = property.skillInfos[skillCfg.id] ~= nil
    end
    require("Main.Skill.SkillTipMgr").Instance():ShowPartnerSkillTip(skillCfg, isUnlock, screenPos.x, screenPos.y, widget.width, widget.height, 0)
  end
end
def.method("string").onDragStart = function(self, id)
  print("onDragStart", id)
  if id == "Model" then
    self._isDraging = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self._isDraging = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self._isDraging == true and self._UIModelWrap._model then
    self._UIModelWrap._model:SetDir(self._UIModelWrap._model.m_ang - dx / 2)
  end
end
PartnerMain_Info.Commit()
return PartnerMain_Info
