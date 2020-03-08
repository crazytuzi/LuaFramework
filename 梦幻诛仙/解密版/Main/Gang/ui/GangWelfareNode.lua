local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local GangUtility = require("Main.Gang.GangUtility")
local GangHelpPanel = require("Main.Gang.ui.GangHelpPanel")
local BanggongExchangePanel = require("Main.Gang.ui.BanggongExchangePanel")
local GangDrugShopPanel = require("Main.Gang.ui.GangDrugShopPanel")
local GangGiftBoxPanel = require("Main.Gang.ui.GangGiftBoxPanel")
local GangSignStrEditPanel = require("Main.Gang.ui.GangSignStrEditPanel")
local GangModule = require("Main.Gang.GangModule")
local FuLiItemType = require("consts.mzm.gsp.gang.confbean.FuLiItemType")
local GangData = require("Main.Gang.data.GangData")
local GangWelfareNode = Lplus.Extend(TabNode, "GangWelfareNode")
local def = GangWelfareNode.define
def.field("table").welfareList = nil
local instance
def.static("=>", GangWelfareNode).Instance = function()
  if instance == nil then
    instance = GangWelfareNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitGangWelfare()
  self:FillGangWelfareList(true)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangSignChanged, GangWelfareNode.OnGangSignChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangSignStrChanged, GangWelfareNode.OnGangSignStrChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_LiheInfoChanged, GangWelfareNode.OnLiheInfoChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FuliChanged, GangWelfareNode.OnFuliChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpChaned, GangWelfareNode.OnHelpInfoChanged)
  Event.RegisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.GangHistoryRedGifts, GangWelfareNode.OnOpenGangChatRedGifePanel)
end
def.method().ResetNotice = function(self)
  GangData.Instance():SetHelpShow(false)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {3})
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangSignChanged, GangWelfareNode.OnGangSignChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangSignStrChanged, GangWelfareNode.OnGangSignStrChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_LiheInfoChanged, GangWelfareNode.OnLiheInfoChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FuliChanged, GangWelfareNode.OnFuliChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpChaned, GangWelfareNode.OnHelpInfoChanged)
  Event.UnregisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.GangHistoryRedGifts, GangWelfareNode.OnOpenGangChatRedGifePanel)
  self:ResetNotice()
end
def.method().InitGangWelfare = function(self)
  if self.welfareList then
    return
  end
  self.welfareList = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GANG_WELFARE_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local welfare = {}
    welfare.id = DynamicRecord.GetIntValue(entry, "id")
    welfare.itemName = DynamicRecord.GetStringValue(entry, "itemName")
    welfare.itemType = DynamicRecord.GetIntValue(entry, "itemType")
    welfare.iconId = DynamicRecord.GetIntValue(entry, "iconId")
    welfare.itemDesc = DynamicRecord.GetStringValue(entry, "itemDesc")
    welfare.tips = DynamicRecord.GetIntValue(entry, "tips")
    welfare.buttonName = DynamicRecord.GetStringValue(entry, "buttonName")
    welfare.isHaveChange = DynamicRecord.GetCharValue(entry, "isHaveChange")
    welfare.isCanShow = true
    table.insert(self.welfareList, welfare)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "number").GetNodeCount = function(self)
  if not self.welfareList then
    return 0
  end
  local listcount = 0
  for _, v in ipairs(self.welfareList) do
    if v.itemType == FuLiItemType.GangChatGift then
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      local ChatRedGiftData = require("Main.ChatRedGift.ChatRedGiftData")
      if ChatRedGiftData.Instance():IsCanShowRedGiftBtnByChannelType(ChatMsgData.Channel.FACTION) then
        listcount = listcount + 1
        v.isCanShow = true
      else
        v.isCanShow = false
      end
    else
      listcount = listcount + 1
    end
  end
  return listcount
end
def.method("boolean").FillGangWelfareList = function(self, bRepostion)
  local welfareAmount = self:GetNodeCount()
  local ScrollView = self.m_node:FindDirect("Scroll View")
  local List_FL = ScrollView:FindDirect("List_FL"):GetComponent("UIList")
  GangData.Instance():CheckFuLiTimeStamp()
  GangData.Instance():CheckGangInfoTimeStamp()
  List_FL:set_itemCount(welfareAmount)
  List_FL:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not List_FL.isnil then
      List_FL:Reposition()
    end
  end)
  local welfares = List_FL:get_children()
  local index = 1
  for _, v in ipairs(self.welfareList) do
    local welfareUI = welfares[index]
    if v.isCanShow then
      self:FillWelfareInfo(welfareUI, index, v)
      index = index + 1
    end
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
  if bRepostion then
    ScrollView:GetComponent("UIScrollView"):ResetPosition()
  end
  GangUtility.SaveWelfareTouchedToday()
end
def.method("userdata", "number", "table").FillWelfareInfo = function(self, welfareUI, index, welfareInfo)
  local Texture = welfareUI:FindDirect(string.format("Icon_Frame_%d", index)):FindDirect(string.format("Texture_%d", index)):GetComponent("UITexture")
  local Label1 = welfareUI:FindDirect(string.format("Label1_%d", index)):GetComponent("UILabel")
  local Label2 = welfareUI:FindDirect(string.format("Label2_%d", index)):GetComponent("UILabel")
  local LabelType = welfareUI:FindDirect(string.format("LabelType_%d", index))
  local Btn_Open = welfareUI:FindDirect(string.format("Btn_Open_%d", index))
  local Label = Btn_Open:FindDirect(string.format("Label_%d", index)):GetComponent("UILabel")
  local Label_Html = welfareUI:FindDirect(string.format("Label_Html_%d", index))
  local Img_Signed = welfareUI:FindDirect(string.format("Img_Signed_%d", index))
  local Img_ThreeDay = welfareUI:FindDirect(string.format("Img_ThreeDay_%d", index))
  local Img_JustChief = welfareUI:FindDirect(string.format("Img_JustChief_%d", index))
  local redLabel = Btn_Open:FindDirect(string.format("Img_BgRed_%d", index))
  if welfareInfo.itemType == FuLiItemType.gangsignin then
    redLabel:SetActive(GangUtility.NeedShowSignInNotice())
  elseif welfareInfo.itemType == FuLiItemType.ganghelp then
    redLabel:SetActive(GangUtility.NeedShowHelpNotice())
  else
    redLabel:SetActive(false)
  end
  Img_Signed:SetActive(false)
  Img_ThreeDay:SetActive(false)
  Img_JustChief:SetActive(false)
  Btn_Open:SetActive(true)
  if welfareInfo.itemType == FuLiItemType.gangsignin then
    local bSignToday = GangData.Instance():IsSignToday()
    if bSignToday then
      Img_Signed:SetActive(true)
      Btn_Open:SetActive(false)
    end
  elseif welfareInfo.itemType == FuLiItemType.Salary then
    local joinDays = GangData.Instance():GetHeroJoinTime()
    if joinDays < 3 then
      Img_ThreeDay:SetActive(true)
      Btn_Open:SetActive(false)
    end
  elseif welfareInfo.itemType == FuLiItemType.lihe and not GangUtility.HeroIsBangZhu() then
    Img_JustChief:SetActive(true)
    Btn_Open:SetActive(false)
  end
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.FillIcon(Texture, welfareInfo.iconId)
  Label1:set_text(welfareInfo.itemName)
  Label2:set_text(welfareInfo.itemDesc)
  Label:set_text(welfareInfo.buttonName)
  LabelType:GetComponent("UILabel"):set_text(welfareInfo.itemType)
  LabelType:SetActive(false)
  Label_Html:SetActive(false)
  if welfareInfo.isHaveChange then
    Label_Html:SetActive(true)
    local desc = self:GetDescByType(welfareInfo.itemType)
    Label_Html:GetComponent("NGUIHTML"):ForceHtmlText(desc)
  end
end
def.method("number", "=>", "string").GetDescByType = function(self, type)
  local desc = ""
  if FuLiItemType.Salary == type then
    desc = self:GetFuliDesc()
  elseif FuLiItemType.lihe == type then
    desc = self:GetLiheDesc()
  elseif FuLiItemType.gangsignin == type then
    desc = self:GetSignDesc()
  end
  return desc
end
def.method("=>", "string").GetFuliDesc = function(self)
  local strTable = {}
  table.insert(strTable, "<br/>")
  local remain = GangData.Instance():GetRemainFuli()
  local total = GangData.Instance():GetTotalFuli()
  table.insert(strTable, string.format("<font color=#4f3018 size=22>%s %d / %d</font>", textRes.Gang[125], remain, total))
  local cost = GangUtility.GetGangConsts("GET_FENGLU_NEED_BANGGONG")
  table.insert(strTable, string.format("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color=#4f3018 size=22>%s</font>", textRes.Gang[126]))
  table.insert(strTable, string.format("<img src='%s:%s' width=27 height=27>", RESPATH.COMMONATLAS, "Icon_Bang"))
  table.insert(strTable, string.format("<font color=#4f3018 size=22>%d</font>", cost))
  return table.concat(strTable)
end
def.method("=>", "string").GetLiheDesc = function(self)
  local strTable = {}
  table.insert(strTable, "<br/>")
  local gangInfo = GangData.Instance():GetGangBasicInfo()
  local warehouseTbl = GangUtility.GetWarehouseGangBasicCfg(gangInfo.warehouseLevel)
  local remain = GangData.Instance():GetRemainLihe()
  table.insert(strTable, string.format("<font color=#4f3018 size=22>%s %d / %d</font>", textRes.Gang[125], remain, warehouseTbl.gridSize))
  return table.concat(strTable)
end
def.method("=>", "string").GetSignDesc = function(self)
  local strTable = {}
  table.insert(strTable, "<br/>")
  local strSign = GangData.Instance():GetStrSign()
  if strSign == "" then
    strSign = textRes.Gang[137]
  end
  strSign = string.gsub(strSign, "<", "&lt;")
  strSign = string.gsub(strSign, ">", "&gt;")
  table.insert(strTable, string.format("<font color=#1874CD size=22>%s</font>", strSign))
  local button = string.format("&nbsp;&nbsp;&nbsp;&nbsp;<a href='btn_sign' id=btn_sign><font color=#55965f size=22><u>[%s]</u></font></a>", textRes.Gang[259])
  table.insert(strTable, button)
  return table.concat(strTable)
end
def.method().Clear = function(self)
end
def.method().OnGangHelpClick = function(self)
  if GangModule.Instance():HasGang() then
    GangHelpPanel.ShowGangHelpPanel(nil, nil)
  else
    Toast(textRes.Gang[100])
  end
end
def.method().OnBanggongExchangeClick = function(self)
  if GangModule.Instance():HasGang() then
    BanggongExchangePanel.ShowBanggongExchangePanel()
  else
    Toast(textRes.Gang[100])
  end
end
def.method().OnGangDrugShopClick = function(self)
  if GangModule.Instance():HasGang() then
    GangDrugShopPanel.ShowGangDrugPanel()
  else
    Toast(textRes.Gang[100])
  end
end
def.method().OnRequireFuliClick = function(self)
  if GangModule.Instance():HasGang() then
    local isGetFuli = GangData.Instance():IsGetFuli()
    if isGetFuli then
      Toast(textRes.Gang[140])
      return
    end
    local remain = GangData.Instance():GetRemainFuli()
    if remain < 1 then
      Toast(textRes.Gang[144])
      return
    end
    local cost = GangUtility.GetGangConsts("GET_FENGLU_NEED_BANGGONG")
    if cost > GangModule.Instance():GetHeroCurBanggong() then
      Toast(string.format(textRes.Gang[127], cost))
    else
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGetFuLiReq").new())
    end
  else
    Toast(textRes.Gang[100])
  end
end
def.method().OnRequireLiheClick = function(self)
  if GangModule.Instance():HasGang() then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local heroMember = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
    local bangzhuId = GangUtility.GetGangConsts("BANGZHU_ID")
    if heroMember.duty == bangzhuId then
      GangGiftBoxPanel.ShowGiftBoxPanel()
    else
      Toast(textRes.Gang[130])
    end
  else
    Toast(textRes.Gang[100])
  end
end
def.method().OnSignTodayClick = function(self)
  local bSignToday = GangData.Instance():IsSignToday()
  if bSignToday then
    Toast(textRes.Gang[138])
  else
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGangSignReq").new())
  end
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.GANGSIGNTODAY, {})
end
def.method().OnGangPayClick = function(self)
  local tipsId = 701602014
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method().OnGangChatRedGiftClick = function(self)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CGetChatGiftListReq").new(ChatMsgData.Channel.FACTION))
end
def.method("userdata").OnGangWelfareClick = function(self, clickobj)
  local id = clickobj.name
  local index = tonumber(string.sub(id, #"Btn_Open_" + 1, -1))
  local type = tonumber(clickobj.parent:FindDirect(string.format("LabelType_%d", index)):GetComponent("UILabel"):get_text())
  if FuLiItemType.ganghelp == type then
    self:OnGangHelpClick()
  elseif FuLiItemType.BangGongRedeem == type then
    self:OnBanggongExchangeClick()
  elseif FuLiItemType.YaoFang == type then
    self:OnGangDrugShopClick()
  elseif FuLiItemType.Salary == type then
    self:OnRequireFuliClick()
  elseif FuLiItemType.lihe == type then
    self:OnRequireLiheClick()
  elseif FuLiItemType.gangsignin == type then
    self:OnSignTodayClick()
  elseif FuLiItemType.Pay == type then
    self:OnGangPayClick()
  elseif FuLiItemType.GangChatGift == type then
    self:OnGangChatRedGiftClick()
  end
end
def.method("number").OnGangWelfareTipsClick = function(self, index)
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  local tipId = self.welfareList[index].tips
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  local tmpPosition = {x = 0, y = 0}
  CommonDescDlg.ShowCommonTip(tipContent, tmpPosition)
end
def.method().OnEditSignClick = function(self)
  GangSignStrEditPanel.ShowGangSignStrEditPanel()
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Btn_Open_") == "Btn_Open_" then
    self:OnGangWelfareClick(clickobj)
  elseif string.sub(id, 1, #"Btn_tips_") == "Btn_tips_" then
    local index = tonumber(string.sub(id, #"Btn_tips_" + 1, -1))
    self:OnGangWelfareTipsClick(index)
  elseif string.sub(id, 1, #"btn_sign") == "btn_sign" then
    self:OnEditSignClick()
  end
end
def.static("table", "table").OnGangSignChanged = function(params, tbl)
  instance:FillGangWelfareList(false)
end
def.static("table", "table").OnGangSignStrChanged = function(params, tbl)
  instance:FillGangWelfareList(false)
end
def.static("table", "table").OnLiheInfoChanged = function(params, tbl)
  instance:FillGangWelfareList(false)
end
def.static("table", "table").OnFuliChanged = function(params, tbl)
  instance:FillGangWelfareList(false)
end
def.static("table", "table").OnHelpInfoChanged = function(params, tbl)
  instance:FillGangWelfareList(false)
end
def.static("table", "table").OnOpenGangChatRedGifePanel = function(params, tbl)
  local GangChatRedGiftPanel = require("Main.Gang.ui.GangChatRedGift")
  GangChatRedGiftPanel.Instance():ShowPanel(params.redGiftInfo)
end
GangWelfareNode.Commit()
return GangWelfareNode
