local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local MailInfoPanel = Lplus.Extend(ECPanelBase, "MailInfoPanel")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local FriendUtils = require("Main.friend.FriendUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local MailContent = require("netio.protocol.mzm.gsp.mail.MailContent")
local def = MailInfoPanel.define
local dlg
local ThingBean = require("netio.protocol.mzm.gsp.mail.ThingBean")
def.field("number").mailIndex = 0
def.field("string").title = ""
def.field("string").content = ""
def.field("number").createTime = 0
def.field("table").itemList = nil
def.field("table").notItemList = nil
def.field("number").type = 0
def.field("boolean").bThingTemplateFill = false
def.field("number").contentType = 0
def.static("=>", MailInfoPanel).Instance = function(self)
  if nil == dlg then
    dlg = MailInfoPanel()
  end
  return dlg
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailClose, MailInfoPanel.OnClose)
  Event.DispatchEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnGangClose, nil)
end
def.static("string", "string", "number", "table", "table", "number", "number", "number").ShowMailInfo = function(title, content, createTime, itemList, notItemList, type, mailIndex, contentType)
  MailInfoPanel.Instance().title = title
  MailInfoPanel.Instance().content = HtmlHelper.ConvertMailContent(content)
  MailInfoPanel.Instance().createTime = createTime
  MailInfoPanel.Instance().itemList = itemList
  MailInfoPanel.Instance().notItemList = notItemList
  MailInfoPanel.Instance().type = type
  MailInfoPanel.Instance().contentType = contentType
  MailInfoPanel.Instance().mailIndex = mailIndex
  if MailInfoPanel.Instance():IsCreated() then
    if MailInfoPanel.Instance():IsLoaded() then
      MailInfoPanel.Instance():UpdateInfo()
    end
  else
    MailInfoPanel.Instance():CreatePanel(RESPATH.PREFAB_MAIL_PANEL, 2)
  end
end
def.static().CloseMailInfo = function()
  MailInfoPanel.Instance():Hide()
end
def.method().UpdateInfo = function(self)
  self:UpdateTitle()
  self:UpdateContent()
  self:UpdateThings()
  self:UpdateDate()
  self:UpdateButton()
end
def.method().UpdateTitle = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_BgTitle = Img_Bg0:FindDirect("Img_BgTitle")
  local Label_Title = Img_BgTitle:FindDirect("Label_Title")
  Label_Title:GetComponent("UILabel"):set_text(self.title)
end
def.method().UpdateContent = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_Bg1 = Img_Bg0:FindDirect("Img_Bg1")
  local ScrollView_WithoutFJ = Img_Bg1:FindDirect("ScrollView_WithoutFJ")
  local Group_WithFJ = Img_Bg1:FindDirect("Group_WithFJ")
  if nil ~= self.itemList and #self.itemList > 0 or nil ~= self.notItemList and 0 < #self.notItemList then
    ScrollView_WithoutFJ:SetActive(false)
    Group_WithFJ:SetActive(true)
    local ScrollView_WithFJ = Group_WithFJ:FindDirect("ScrollView_WithFJ")
    ScrollView_WithFJ:FindDirect("Label_WithFJ"):GetComponent("NGUIHTML"):ForceHtmlText(self.content)
    ScrollView_WithFJ:GetComponent("UIScrollView"):ResetPosition()
  else
    ScrollView_WithoutFJ:SetActive(true)
    Group_WithFJ:SetActive(false)
    ScrollView_WithoutFJ:FindDirect("Label_WithoutFJ"):GetComponent("NGUIHTML"):ForceHtmlText(self.content)
    ScrollView_WithoutFJ:GetComponent("UIScrollView"):ResetPosition()
  end
  local Img_BgTitle = Img_Bg0:FindDirect("Img_BgTitle")
  local Label_Title = Img_BgTitle:FindDirect("Label_Title")
  Label_Title:GetComponent("UILabel"):set_text(self.title)
  local wxRightGO = Img_Bg1:FindDirect("Group_WithFJ/Img_BgFJ")
  local mail = require("Main.friend.FriendModule").Instance()._data:GetMail(self.mailIndex)
  local cfg = require("Main.RelationShipChain.data.RelationShipChainData").GetPrivilegeAwardCfg(2)
  local id = ""
  if mail then
    id = mail.mailContent.contentMap[MailContent.CONTENT_MAIL_CFG_ID]
  end
  GUIUtils.SetActive(wxRightGO, cfg and tonumber(id) == tonumber(cfg.daily_award_mail_cfg_id))
end
def.method().UpdateThings = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_Bg1 = Img_Bg0:FindDirect("Img_Bg1")
  local Group_WithFJ = Img_Bg1:FindDirect("Group_WithFJ")
  local Group_FJ = Group_WithFJ:FindDirect("Group_FJ")
  local ScrollView = Group_FJ:FindDirect("Scroll View")
  local gridTemplate = ScrollView:FindDirect("Grid_FJ")
  Group_FJ:SetActive(true)
  if nil ~= self.itemList and #self.itemList > 0 or nil ~= self.notItemList and 0 < #self.notItemList then
    gridTemplate:SetActive(true)
    local groupTemplate = gridTemplate:FindDirect("Img_BgIcon1")
    self:ShowThings(gridTemplate, groupTemplate)
    GameUtil.AddGlobalTimer(0.01, true, function()
      if self.m_panel and false == self.m_panel.isnil then
        ScrollView:GetComponent("UIScrollView"):ResetPosition()
      end
    end)
  else
    gridTemplate:SetActive(false)
  end
end
def.method("userdata", "userdata").ShowThings = function(self, gridTemplate, groupTemplate)
  while gridTemplate:get_childCount() > 1 do
    Object.DestroyImmediate(gridTemplate:GetChild(gridTemplate:get_childCount() - 1))
  end
  self.bThingTemplateFill = false
  local count = 1
  gridTemplate:GetChild(0):SetActive(true)
  self:FillThingsList(count, groupTemplate, gridTemplate, self.itemList)
  count = #self.itemList + 1
  self:FillThingsList(count, groupTemplate, gridTemplate, self.notItemList)
  local uiGrid = gridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number", "userdata", "userdata", "table").FillThingsList = function(self, count, groupTemplate, gridTemplate, list)
  local index = 1
  if false == self.bThingTemplateFill then
    index = 2
    if #list > 0 then
      self:FillThingInfo(1, groupTemplate, gridTemplate, list[1])
      count = count + 1
      self.bThingTemplateFill = true
    end
  else
    index = 1
  end
  for i = index, #list do
    local thingNew = Object.Instantiate(groupTemplate)
    self:FillThingInfo(count, thingNew, gridTemplate, list[i])
    count = count + 1
  end
end
def.method("number", "userdata", "userdata", "table").FillThingInfo = function(self, count, thingNew, gridTemplate, thingInfo)
  thingNew:set_name(string.format("Img_BgIcon%d", count))
  thingNew.parent = gridTemplate
  thingNew:set_localScale(Vector.Vector3.one)
  thingNew:SetActive(true)
  local iconTexture = thingNew:FindDirect("Icon_Item"):GetComponent("UITexture")
  local iconId = 0
  local count = 0
  if self:bItem(thingInfo) then
    local itemBase = ItemUtils.GetItemBase(thingInfo.id)
    iconId = itemBase.icon
    count = thingInfo.number
  else
    iconId = self:GetThingIconId(thingInfo)
    count = thingInfo.count
  end
  GUIUtils.FillIcon(iconTexture, iconId)
  thingNew:FindDirect("Label_ItemNum"):GetComponent("UILabel"):set_text(count)
end
def.method("table", "=>", "number").GetThingIconId = function(self, thing)
  local itemRecord
  local iconId = 0
  if thing.thingType == ThingBean.MAIL_ATTACHMENT_MONEY then
    itemRecord = DynamicData.GetRecord(CFG_PATH.DATA_MONEY_CFG, thing.id)
  elseif thing.thingType == ThingBean.MAIL_ATTACHMENT_TOKEN then
    itemRecord = DynamicData.GetRecord(CFG_PATH.DATA_TOKEN_TYPE, thing.id)
  elseif thing.thingType == ThingBean.MAIL_ATTACHMENT_EXP then
    itemRecord = DynamicData.GetRecord(CFG_PATH.DATA_EXP_CFG, thing.id)
  end
  if nil ~= itemRecord then
    iconId = itemRecord:GetIntValue("icon")
  elseif thing.thingType == ThingBean.MAIL_ATTACHMENT_VIGOR then
    iconId = require("Main.Hero.HeroUtility").Instance():GetRoleCommonConsts("VIGOR_PICID")
  elseif thing.thingType == ThingBean.MAIL_ATTACHMENT_STORE_EXP then
    iconId = require("Main.Award.AwardUtils").GetStorageExpConsts("STORAGE_PICID")
  end
  return iconId
end
def.method("table", "=>", "boolean").bItem = function(self, thing)
  for k, v in pairs(self.itemList) do
    if v.id == thing.id then
      return true
    end
  end
  return false
end
def.method().UpdateDate = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_BgInfo = Img_Bg0:FindDirect("Img_BgInfo")
  local last = os.date("*t", self.createTime)
  Img_BgInfo:FindDirect("Label_DateNum"):GetComponent("UILabel"):set_text(string.format(textRes.Friend[33], last.year, last.month, last.day))
  local data = require("Main.friend.FriendModule").Instance()._data
  local mailInfo = data:GetMail(self.mailIndex)
  local remainTime, unit = FriendUtils.ComputeMailRemainTime(mailInfo)
  Img_BgInfo:FindDirect("Label_PeriodNum"):GetComponent("UILabel"):set_text(remainTime .. unit)
end
def.method().UpdateButton = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Btn_Mail = Img_Bg0:FindDirect("Btn_Mail")
  if nil ~= self.itemList and #self.itemList > 0 or nil ~= self.notItemList and 0 < #self.notItemList then
    Btn_Mail:FindDirect("Label_Mail"):GetComponent("UILabel"):set_text(textRes.Mail[4])
  else
    Btn_Mail:FindDirect("Label_Mail"):GetComponent("UILabel"):set_text(textRes.Mail[5])
  end
end
def.method().OnButtonClick = function(self)
  local mail = require("Main.friend.FriendModule").Instance()._data:GetMail(self.mailIndex)
  if mail then
    local id = mail.mailContent.contentMap[MailContent.CONTENT_MAIL_CFG_ID]
    if id then
      local swornMgr = require("Main.Sworn.SwornMgr")
      swornMgr.DelSwornVoteMail(tonumber(id))
    end
    if nil ~= self.itemList and #self.itemList > 0 or nil ~= self.notItemList and 0 < #self.notItemList then
      self:CollectMailThings()
    else
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.mail.CDelMailReq").new(self.mailIndex))
    end
  end
end
def.method().CollectMailThings = function(self)
  local gridCount = 0
  local itemTbl = {}
  for k, v in pairs(self.itemList) do
    if itemTbl[v.id] == nil then
      itemTbl[v.id] = v.number
    else
      itemTbl[v.id] = itemTbl[v.id] + v.number
    end
  end
  local full = ItemModule.Instance():IsEnoughForItems(itemTbl)
  if full > 0 then
    Toast(string.format(textRes.Friend[31], textRes.Item[full] or textRes.Item[ItemModule.BAG]))
  else
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.mail.CGetThingReq").new(self.mailIndex))
  end
end
def.method("number").SucceedCollectMailThings = function(self, mailIndex)
  if mailIndex == self.mailIndex and self.m_panel then
    self.itemList = {}
    self.notItemList = {}
    self:UpdateButton()
    self:UpdateThings()
    Toast(textRes.Friend[32])
  end
end
def.method("table").SucceedAutoCollectMailThings = function(self, mailIndexs)
  for k, v in pairs(mailIndexs) do
    self:SucceedCollectMailThings(v)
  end
end
def.method("number").HideLastMailInfo = function(self, index)
  if self.mailIndex == index then
    self:Hide()
  end
end
def.method("string").onClick = function(self, id)
  if "Btn_Mail" == id then
    self:OnButtonClick()
  elseif "Btn_Close" == id then
    self:Hide()
  elseif string.find(id, "Img_BgIcon") then
    self:ShowMailAttachmentTips(id)
  elseif string.find(id, "npc_") then
    local npcId = tonumber(string.sub(id, 5))
    if npcId > 0 then
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
      self:DestroyPanel()
    end
  elseif string.find(id, "FirstCharge") then
    local AwardPanel = require("Main.Award.ui.AwardPanel")
    AwardPanel.Instance():ShowPanelEx(AwardPanel.NodeId.FirstRechargeAward)
    self:DestroyPanel()
  elseif string.find(id, "ReturnHome") then
    gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GoToMyExplorerCat()
    self:DestroyPanel()
  elseif id:find("SwornVote") then
    local mailID = tonumber(id:sub(10, -1))
    if mailID then
      local swornMgr = require("Main.Sworn.SwornMgr")
      swornMgr.GetSwornVoteMail(mailID, self.mailIndex)
    else
      warn("Wrong MailID :", id:sub(10, -1))
    end
  elseif string.sub(id, 1, 6) == "award_" then
    local AwardPanel = require("Main.Award.ui.AwardPanel")
    local nodeName = string.sub(id, 7)
    local nodeId = AwardPanel.NodeId[nodeName]
    if nodeId then
      if AwardPanel.Instance():CheckNodeAvaliable(nodeId) then
        AwardPanel.Instance():ShowPanelEx(nodeId)
        self:DestroyPanel()
      else
        local tip = textRes.Mail.AwardNameToNotOpen[nodeName] or textRes.Mail.AwardNameToNotOpen.Default
        Toast(tip)
      end
    end
  elseif string.sub(id, 1, 6) == "corps_" then
    local index = tonumber(string.sub(id, 7))
    if index then
      require("Main.Corps.CorpsInterface").CheckCorpsInfo(Int64.new(index))
    end
  elseif string.sub(id, 1, 8) == "auction_" then
    require("Main.Auction.AuctionMgr").OnAuctionLinkClicked(id)
  end
end
def.method("string").ShowMailAttachmentTips = function(self, imgName)
  local index = tonumber(string.sub(imgName, string.len("Img_BgIcon") + 1))
  if not self.m_panel then
    return
  end
  local obj = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Group_WithFJ/Group_FJ/Scroll View/Grid_FJ/" .. imgName)
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent("UISprite")
  local itemId = 0
  if index >= 1 and index <= #self.itemList then
    itemId = self.itemList[index].id
  elseif 1 <= index - #self.itemList and index - #self.itemList <= #self.notItemList then
    local indexNonItem = index - #self.itemList
    local nonItem = self.notItemList[indexNonItem]
    if nonItem.thingType == ThingBean.MAIL_ATTACHMENT_MONEY then
      local cfg = ItemUtils.GetMoneyCfg(nonItem.id)
      itemId = cfg.desitemid
    elseif nonItem.thingType == ThingBean.MAIL_ATTACHMENT_EXP then
      local cfg = ItemUtils.GetExpCfg(nonItem.id)
      itemId = cfg.desitemid
    elseif nonItem.thingType == ThingBean.MAIL_ATTACHMENT_TOKEN then
      local cfg = ItemUtils.GetTokenCfg(nonItem.id)
      itemId = cfg.showItemId
    elseif nonItem.thingType == ThingBean.MAIL_ATTACHMENT_VIGOR then
    elseif nonItem.thingType == ThingBean.MAIL_ATTACHMENT_STORE_EXP then
    end
  end
  if itemId ~= 0 then
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, false)
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailClose, MailInfoPanel.OnClose)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.static("table", "table").OnClose = function(p1, p2)
  MailInfoPanel.Instance():Hide()
end
MailInfoPanel.Commit()
return MailInfoPanel
