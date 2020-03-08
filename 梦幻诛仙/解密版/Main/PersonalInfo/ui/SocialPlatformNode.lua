local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local SocialPlatformNode = Lplus.Extend(TabNode, "SocialPlatformNode")
local Vector = require("Types.Vector")
local PersonalInfoModule = require("Main.PersonalInfo.PersonalInfoModule")
local SocialPlatformMgr = require("Main.PersonalInfo.mgr.SocialPlatformMgr")
local PersonalInfoInterface = require("Main.PersonalInfo.PersonalInfoInterface")
local PersonalInfoPanel = Lplus.ForwardDeclare("PersonalInfoPanel")
local def = SocialPlatformNode.define
def.const("string").TabPrefix = "Tab_"
def.const("string").SubTabPrefix = "SubTab_"
def.const("string").SNSPrefix = "SubInfo_"
def.field("table").uiObjs = nil
def.field("number").currentSelectTabIdx = 0
def.field("number").currentSelectSubTabIdx = 0
def.field("table").snsTypeCfgList = nil
def.field("number").curPageNum = 1
def.field("number").totalPageNum = 1
def.field("boolean").haveInit = false
def.field("number").timerId = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  if self:IsNeedOnShow() then
    self:InitUI()
    self:SetSocialTabList()
    self:SetSearchResult()
    self:SetSearchFilterText()
    self:OpenDefaultTab()
    self:CheckRefreshTimer()
    Event.RegisterEventWithContext(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SEARCH_FILTER_CHANGE, SocialPlatformNode.OnSearchFilterChange, self)
    Event.RegisterEventWithContext(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.RECEIVE_WORLD_SNS, SocialPlatformNode.OnReceiveSearchResult, self)
    Event.RegisterEventWithContext(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SEARCH_FILTER_AJUST, SocialPlatformNode.OnSearchFilterAjust, self)
  end
end
def.override().OnHide = function(self)
  if self:IsNeedOnHide() then
    self:Clear()
  end
end
def.method("=>", "boolean").IsNeedOnShow = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return false
  end
  local personalInfoPanel = PersonalInfoPanel.Instance()
  return not self.haveInit and personalInfoPanel.curNode == PersonalInfoPanel.NodeId.SOCIAL_PLATFORM
end
def.method("=>", "boolean").IsNeedOnHide = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return false
  end
  local personalInfoPanel = PersonalInfoPanel.Instance()
  return personalInfoPanel.curNode ~= PersonalInfoPanel.NodeId.SOCIAL_PLATFORM
end
def.method().OnDestroy = function(self)
  if self.haveInit then
    self:Clear()
  end
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.currentSelectTabIdx = 0
  self.currentSelectSubTabIdx = 0
  self.snsTypeCfgList = nil
  self.curPageNum = 1
  self.totalPageNum = 1
  self.haveInit = false
  self:StopRefreshTimer()
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SEARCH_FILTER_CHANGE, SocialPlatformNode.OnSearchFilterChange)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.RECEIVE_WORLD_SNS, SocialPlatformNode.OnReceiveSearchResult)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SEARCH_FILTER_AJUST, SocialPlatformNode.OnSearchFilterAjust)
end
def.method().InitUI = function(self)
  self.haveInit = true
  self.uiObjs = {}
  self.uiObjs.Img_BgLeft = self.m_node:FindDirect("Img_BgLeft")
  self.uiObjs.TabScrollView = self.uiObjs.Img_BgLeft:FindDirect("Scroll View")
  self.uiObjs.TabTableList = self.uiObjs.TabScrollView:FindDirect("Table_List")
  self.uiObjs.TabTemplate = self.uiObjs.TabTableList:FindDirect(SocialPlatformNode.TabPrefix .. "0")
  if self.uiObjs.TabTemplate == nil then
    self.uiObjs.TabTemplate = self.uiObjs.TabTableList:FindDirect("Tab_1")
    self.uiObjs.TabTemplate.name = SocialPlatformNode.TabPrefix .. "0"
  end
  local tween = self.uiObjs.TabTemplate:FindDirect("tween")
  self.uiObjs.SubTabTemplate = tween:FindDirect(SocialPlatformNode.SubTabPrefix .. "0")
  if self.uiObjs.SubTabTemplate == nil then
    self.uiObjs.SubTabTemplate = tween:FindDirect("Btn_Content")
    self.uiObjs.SubTabTemplate.name = SocialPlatformNode.SubTabPrefix .. "0"
  end
  self.uiObjs.TabTemplate:SetActive(false)
  self.uiObjs.SubTabTemplate:SetActive(false)
  self.uiObjs.Img_BgRight = self.m_node:FindDirect("Img_BgRight")
  self.uiObjs.SNSScrollView = self.uiObjs.Img_BgRight:FindDirect("Scroll View")
  self.uiObjs.SNSList = self.uiObjs.SNSScrollView:FindDirect("Table_List")
  self.uiObjs.Label_Condition = self.uiObjs.Img_BgRight:FindDirect("Group_Top/Label_Condition")
  self.uiObjs.Group_Bottom = self.uiObjs.Img_BgRight:FindDirect("Group_Bottom")
  self.uiObjs.Label_Number = self.uiObjs.Group_Bottom:FindDirect("Label_Number")
  self.uiObjs.Label_Page = self.uiObjs.Group_Bottom:FindDirect("Img_BgPage/Label_Page")
  self.uiObjs.Group_Top = self.uiObjs.Img_BgRight:FindDirect("Group_Top")
  self.uiObjs.Btn_Refresh = self.uiObjs.Group_Top:FindDirect("Btn_Refresh")
  self.uiObjs.Label_Refresh = self.uiObjs.Btn_Refresh:FindDirect("Label")
  local uiList = self.uiObjs.SNSList:GetComponent("UIList")
  uiList.itemCount = 0
  uiList:Resize()
end
def.method().SetSocialTabList = function(self)
  self.snsTypeCfgList = SocialPlatformMgr.Instance():GetSNSTypeCfg()
  local tabCount = 0
  if self.snsTypeCfgList ~= nil then
    tabCount = #self.snsTypeCfgList
  end
  SocialPlatformNode.ResizeTableSize(self.uiObjs.TabTableList, self.uiObjs.TabTemplate, SocialPlatformNode.TabPrefix, tabCount)
  for i = 1, tabCount do
    local subCount = 0
    if self.snsTypeCfgList[i].subTypeList ~= nil then
      subCount = #self.snsTypeCfgList[i].subTypeList
    end
    local tab = self.uiObjs.TabTableList:FindDirect(SocialPlatformNode.TabPrefix .. i)
    tab:SetActive(true)
    tab:FindDirect("Btn_Class"):GetComponent("UIToggle").value = false
    local subTabList = tab:FindDirect("tween")
    SocialPlatformNode.ResizeTableSize(subTabList, self.uiObjs.SubTabTemplate, SocialPlatformNode.SubTabPrefix, subCount)
    subTabList:SetActive(false)
    self:FillTabContent(tab, self.snsTypeCfgList[i])
    if not SocialPlatformMgr.IsSocialTypeFunctionOpen(self.snsTypeCfgList[i].id) then
      tab:SetActive(false)
    end
  end
end
def.static("userdata", "userdata", "string", "number").ResizeTableSize = function(uiTableObj, template, prefix, count)
  local tableItemCount = uiTableObj.transform.childCount - 1
  if tableItemCount < 0 then
    return
  end
  if count > tableItemCount then
    for i = tableItemCount + 1, count do
      local tabItem = GameObject.Instantiate(template)
      tabItem.name = prefix .. i
      tabItem.transform.parent = uiTableObj.transform
      tabItem.transform.localScale = Vector.Vector3.one
      tabItem:SetActive(true)
    end
  elseif count < tableItemCount then
    for i = tableItemCount, count + 1, -1 do
      local tabItem = uiTableObj:FindDirect(prefix .. i)
      tabItem.transform.parent = nil
      GameObject.Destroy(tabItem)
    end
  end
  local uiTable = uiTableObj:GetComponent("UITable")
  uiTable:Reposition()
end
def.method("userdata", "table").FillTabContent = function(self, tab, cfg)
  if tab == nil then
    return
  end
  local tabName = tab:FindDirect("Btn_Class/Label")
  GUIUtils.SetText(tabName, cfg.mainTypeName)
  local subCount = 0
  if cfg.subTypeList ~= nil then
    subCount = #cfg.subTypeList
  end
  for i = 1, subCount do
    local subTab = tab:FindDirect("tween/" .. SocialPlatformNode.SubTabPrefix .. i)
    subTab:GetComponent("UIToggle").value = false
    local subTabName = subTab:FindDirect("Label")
    GUIUtils.SetText(subTabName, cfg.subTypeList[i].subTypeName)
    if cfg.subTypeList[i].id == constant.SNSConsts.ALL_SUB_TYPE_ID then
      subTab:SetActive(false)
    end
  end
end
def.method().OpenDefaultTab = function(self)
  local openType = SocialPlatformMgr.Instance():GetOpenAdvertType()
  if self.snsTypeCfgList == nil then
    return
  end
  local tabIdx, subTabIdx = self:GetTabIndexByAdverType(openType)
  self:SelectTab(tabIdx)
  self:SelectSubTab(subTabIdx)
end
def.method("number", "=>", "number", "number").GetTabIndexByAdverType = function(self, advertType)
  local tabIdx = 1
  local subTabIdx = 1
  for idx, cfg in ipairs(self.snsTypeCfgList) do
    if cfg.subTypeList ~= nil then
      for subIdx, subCfg in ipairs(cfg.subTypeList) do
        if subCfg.id == advertType then
          tabIdx = idx
          subTabIdx = subIdx
          return tabIdx, subTabIdx
        end
      end
    end
  end
  return tabIdx, subTabIdx
end
def.method("number").ChooseTab = function(self, tabIdx)
  local preTabIndex = self.currentSelectTabIdx
  self:SelectTab(tabIdx)
  if self.currentSelectTabIdx ~= preTabIndex then
    self:SelectSubTab(1)
  end
end
def.method("number").ChooseSubTab = function(self, subTabIdx)
  self:SelectSubTab(subTabIdx)
end
def.method("number").SelectTab = function(self, tabIdx)
  if self.currentSelectTabIdx ~= tabIdx then
    self:CheckTab(tabIdx)
    self:CloseTab(self.currentSelectTabIdx)
    self:OpenTab(tabIdx)
    self:RepositionTabs()
    self.currentSelectTabIdx = tabIdx
  else
    self:CheckTab(tabIdx)
    self:ToggleTab(self.currentSelectTabIdx)
    self:RepositionTabs()
  end
end
def.method("number").CheckTab = function(self, tabIdx)
  local tab = self.uiObjs.TabTableList:FindDirect(SocialPlatformNode.TabPrefix .. tabIdx .. "/Btn_Class")
  tab:GetComponent("UIToggle").value = true
end
def.method("number").SelectSubTab = function(self, subTabIdx)
  self.currentSelectSubTabIdx = subTabIdx
  self:CheckSubTabStatus(subTabIdx)
  self:SetSearchFilterText()
  self:ShowSNSInfo()
end
def.method("number").ToggleTab = function(self, tabIdx)
  local tab = self.uiObjs.TabTableList:FindDirect(SocialPlatformNode.TabPrefix .. tabIdx)
  if tab ~= nil then
    if tab:FindDirect("tween"):get_activeSelf() then
      tab:FindDirect("tween"):SetActive(false)
    else
      tab:FindDirect("tween"):SetActive(true)
    end
  end
end
def.method("number").OpenTab = function(self, tabIdx)
  local tab = self.uiObjs.TabTableList:FindDirect(SocialPlatformNode.TabPrefix .. tabIdx)
  if tab ~= nil then
    tab:FindDirect("tween"):SetActive(true)
  end
end
def.method("number").CloseTab = function(self, tabIdx)
  local tab = self.uiObjs.TabTableList:FindDirect(SocialPlatformNode.TabPrefix .. tabIdx)
  if tab ~= nil then
    tab:FindDirect("tween"):SetActive(false)
  end
end
def.method().RepositionTabs = function(self)
  self.uiObjs.TabTableList:GetComponent("UITable"):Reposition()
end
def.method("number").CheckSubTabStatus = function(self, subTabIdx)
  local tab = self.uiObjs.TabTableList:FindDirect(SocialPlatformNode.TabPrefix .. self.currentSelectTabIdx)
  if tab ~= nil then
    local subTab = tab:FindDirect("tween/" .. SocialPlatformNode.SubTabPrefix .. subTabIdx)
    if subTab ~= nil then
      subTab:GetComponent("UIToggle").value = true
    end
  end
end
def.method().ShowSNSInfo = function(self)
  local subTypeId = self:GetCurrentSelectSubTypeId()
  SocialPlatformMgr.Instance():SetOpenAdvertType(subTypeId)
  if SocialPlatformMgr.Instance():HasSearchResultOfType(subTypeId) then
    self:SetSearchResult()
  else
    local lastSearchPage = SocialPlatformMgr.Instance():GetLastSearchPageOfType(subTypeId)
    SocialPlatformMgr.SearchWorldSNSInfo(subTypeId, lastSearchPage)
  end
end
def.method("number").SetPageOffset = function(self, offset)
  local subTypeId = self:GetCurrentSelectSubTypeId()
  local lastSearchPage = SocialPlatformMgr.Instance():GetLastSearchPageOfType(subTypeId)
  local newPage = lastSearchPage + offset
  if newPage < 1 then
    Toast(textRes.Personal[219])
  elseif newPage > self.totalPageNum then
    Toast(textRes.Personal[220])
  else
    SocialPlatformMgr.SearchWorldSNSInfo(subTypeId, lastSearchPage + offset)
  end
end
def.method().RefreshWorldSNSInfo = function(self)
  local cdTime = SocialPlatformMgr.GetLeftTimeBeforeRefresh()
  if cdTime <= 0 then
    local subTypeId = self:GetCurrentSelectSubTypeId()
    local lastSearchPage = SocialPlatformMgr.Instance():GetLastSearchPageOfType(subTypeId)
    SocialPlatformMgr.RefreshWorldSNSInfo(subTypeId, 1)
    self:CheckRefreshTimer()
  else
    Toast(string.format(textRes.Personal[232], cdTime))
  end
end
def.method().CheckRefreshTimer = function(self)
  local cdTime = SocialPlatformMgr.GetLeftTimeBeforeRefresh()
  if cdTime > 0 then
    self:StartRefreshTimer(cdTime)
  else
    self:SetRefreshBtnLabel(0)
  end
end
def.method("number").StartRefreshTimer = function(self, t)
  if self.timerId > 0 then
    return
  end
  self:SetRefreshBtnLabel(t)
  self.timerId = GameUtil.AddGlobalTimer(1, false, function()
    t = t - 1
    self:SetRefreshBtnLabel(t)
    if t <= 0 then
      self:StopRefreshTimer()
    end
  end)
end
def.method("number").SetRefreshBtnLabel = function(self, t)
  if t > 0 then
    self.uiObjs.Btn_Refresh:GetComponent("BoxCollider"):set_enabled(false)
    GUIUtils.SetText(self.uiObjs.Label_Refresh, string.format(textRes.Personal[237], t))
  else
    self.uiObjs.Btn_Refresh:GetComponent("BoxCollider"):set_enabled(true)
    GUIUtils.SetText(self.uiObjs.Label_Refresh, textRes.Personal[238])
  end
end
def.method().StopRefreshTimer = function(self)
  if self.timerId > 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method("=>", "number").GetCurrentSelectSubTypeId = function(self)
  if self.snsTypeCfgList ~= nil and self.snsTypeCfgList[self.currentSelectTabIdx] ~= nil and self.snsTypeCfgList[self.currentSelectTabIdx].subTypeList ~= nil and self.snsTypeCfgList[self.currentSelectTabIdx].subTypeList[self.currentSelectSubTabIdx] ~= nil then
    return self.snsTypeCfgList[self.currentSelectTabIdx].subTypeList[self.currentSelectSubTabIdx].id
  end
  return -1
end
def.method().SetSearchFilterText = function(self)
  local filter = SocialPlatformMgr.Instance():GetSearchFilter(self:GetCurrentSelectSubTypeId())
  local filterTable = {}
  if filter == nil then
    table.insert(filterTable, textRes.Personal.SearchFilter.Gender[-1])
    table.insert(filterTable, textRes.Personal.SearchFilter.Level[-1])
    table.insert(filterTable, textRes.Personal.SearchFilter.Province[-1])
  else
    if filter.gender == SocialPlatformMgr.SocialGender.MALE then
      table.insert(filterTable, textRes.Personal.SearchFilter.Gender[0])
    elseif filter.gender == SocialPlatformMgr.SocialGender.FEMALE then
      table.insert(filterTable, textRes.Personal.SearchFilter.Gender[1])
    else
      table.insert(filterTable, textRes.Personal.SearchFilter.Gender[-1])
    end
    table.insert(filterTable, string.format(textRes.Personal[215], filter.minLevel, filter.maxLevel))
    local province = PersonalInfoInterface.GetPersonalOptionCfg(filter.province)
    if province ~= nil then
      table.insert(filterTable, province.content)
    else
      table.insert(filterTable, textRes.Personal.SearchFilter.Province[-1])
    end
  end
  local str = table.concat(filterTable, ",")
  GUIUtils.SetText(self.uiObjs.Label_Condition, str)
end
def.method().SetSearchResult = function(self)
  local result = SocialPlatformMgr.Instance():GetCurrentSearchResult(self:GetCurrentSelectSubTypeId())
  local snsList = {}
  local totalSize = 0
  local curPage = 0
  local pageNum = 0
  if result ~= nil then
    snsList = result.SNSInfoList
    totalSize = result.totalSize
    pageNum = math.ceil(totalSize / constant.SNSConsts.PAGE_SIZE)
    curPage = math.min(result.page, pageNum)
  end
  self.totalPageNum = pageNum
  self.curPageNum = curPage
  local itemCount = #snsList
  local uiList = self.uiObjs.SNSList:GetComponent("UIList")
  uiList.itemCount = itemCount
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, itemCount do
    self:FillSNSItem(uiItems[i], snsList[i], i)
  end
  GUIUtils.SetText(self.uiObjs.Label_Number, string.format(textRes.Personal[212], totalSize))
  GUIUtils.SetText(self.uiObjs.Label_Page, string.format(textRes.Personal[213], curPage, pageNum))
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self ~= nil and self.uiObjs ~= nil and self.uiObjs.SNSScrollView ~= nil then
      self.uiObjs.SNSScrollView:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method("userdata", "table", "number").FillSNSItem = function(self, item, SNSInfo, idx)
  local Img_Bg = item:FindDirect("Img_Bg")
  local Label_Name = Img_Bg:FindDirect("Label_Name")
  local Img_HeadIcon = Img_Bg:FindDirect("Img_HeadIcon")
  local Img_Icon = Img_HeadIcon:FindDirect("Img_Icon")
  local Img_School = Img_Bg:FindDirect("Img_School")
  local LabeL_Level = Img_Bg:FindDirect("LabeL_Level")
  local Img_Type = Img_Bg:FindDirect("Img_Type")
  local LabeL_Content = Img_Bg:FindDirect("LabeL_Content")
  local Img_Boy = Img_Bg:FindDirect("Img_Boy")
  local Img_Girl = Img_Bg:FindDirect("Img_Girl")
  local Img_NoSex = Img_Bg:FindDirect("Img_NoSex")
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarCfg = AvatarInterface.GetAvatarCfgById(SNSInfo.headImage)
  if avatarCfg ~= nil then
    _G.SetAvatarIcon(Img_Icon, SNSInfo.headImage)
  else
    _G.SetAvatarIcon(Img_Icon, AvatarInterface.Instance():getDefaultAvatarId(SNSInfo.occupationId, SNSInfo.gender))
  end
  local AvatarFrameMgr = require("Main.Avatar.AvatarFrameMgr")
  local avatarFrameCfg = AvatarFrameMgr.GetAvatarFrameCfg(SNSInfo.avatar_frameid)
  if avatarFrameCfg ~= nil then
    _G.SetAvatarFrameIcon(Img_HeadIcon, SNSInfo.avatar_frameid)
  else
    _G.SetAvatarFrameIcon(Img_HeadIcon, AvatarFrameMgr.Instance():getDefaultAvatarFrameId())
  end
  GUIUtils.SetActive(Img_Boy, false)
  GUIUtils.SetActive(Img_Girl, false)
  GUIUtils.SetActive(Img_NoSex, false)
  if SNSInfo.realGender == SocialPlatformMgr.SocialGender.MALE then
    GUIUtils.SetActive(Img_Boy, true)
  elseif SNSInfo.realGender == SocialPlatformMgr.SocialGender.FEMALE then
    GUIUtils.SetActive(Img_Girl, true)
  else
    GUIUtils.SetActive(Img_NoSex, true)
  end
  GUIUtils.SetSprite(Img_School, GUIUtils.GetOccupationSmallIcon(SNSInfo.occupationId))
  GUIUtils.SetText(Label_Name, _G.GetStringFromOcts(SNSInfo.name))
  GUIUtils.SetText(LabeL_Level, string.format(textRes.Personal[210], SNSInfo.level))
  GUIUtils.SetText(LabeL_Content, _G.GetStringFromOcts(SNSInfo.content))
  local typeCfg = PersonalInfoInterface.GetSNSSubTypeCfgById(SNSInfo.advertType)
  GUIUtils.SetSprite(Img_Type, typeCfg.icon)
  item.name = SocialPlatformNode.SNSPrefix .. Int64.ToNumber(SNSInfo.advertId)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local objName = clickobj.name
  if objName == "Btn_Class" then
    local parentName = clickobj.transform.parent.name
    local tabIdx = tonumber(string.sub(parentName, string.len(SocialPlatformNode.TabPrefix) + 1))
    self:ChooseTab(tabIdx)
  elseif string.find(objName, SocialPlatformNode.SubTabPrefix) then
    local subTabIdx = tonumber(string.sub(objName, string.len(SocialPlatformNode.SubTabPrefix) + 1))
    self:ChooseSubTab(subTabIdx)
  elseif objName == "Btn_Connect" then
    local snsItem = clickobj.transform.parent.parent.parent.gameObject
    if snsItem ~= nil and string.find(snsItem.name, SocialPlatformNode.SNSPrefix) then
      local advertId = tonumber(string.sub(snsItem.name, string.len(SocialPlatformNode.SNSPrefix) + 1))
      self:SendPersonalMessage(advertId)
    end
  elseif objName == "Btn_Detail" then
    local snsItem = clickobj.transform.parent.parent.parent.gameObject
    if snsItem ~= nil and string.find(snsItem.name, SocialPlatformNode.SNSPrefix) then
      local advertId = tonumber(string.sub(snsItem.name, string.len(SocialPlatformNode.SNSPrefix) + 1))
      self:ViewPlayerDetail(advertId)
    end
  else
    self:onClick(objName)
  end
end
def.method("number").SendPersonalMessage = function(self, advertId)
  local sns = SocialPlatformMgr.Instance():GetSNSInfoByAdvertId(self:GetCurrentSelectSubTypeId(), advertId)
  if sns ~= nil then
    do
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      if heroProp == nil or heroProp.id == sns.roleId then
        Toast(textRes.Personal[228])
        return
      end
      local ChatModule = require("Main.Chat.ChatModule")
      local message = self:PackAdverMessage(sns.advertType)
      ChatModule.Instance():SendPrivateMsg(sns.roleId, message, false)
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm(textRes.Personal[221], textRes.Personal[223], function(result)
        if result == 1 then
          Event.DispatchEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.CLOSE_PERSONAL_PANEL, nil)
          gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(sns.roleId, function(roleInfo)
            local SocialDlg = require("Main.friend.ui.SocialDlg")
            SocialDlg.ShowSocialDlg(SocialDlg.NodeId.Recent)
            ChatModule.Instance():StartPrivateChat3(sns.roleId, roleInfo.name, roleInfo.level, roleInfo.occupationId, roleInfo.gender, roleInfo.avatarId, roleInfo.avatarFrameId)
          end)
        end
      end, nil)
    end
  end
end
def.method("number", "=>", "string").PackAdverMessage = function(self, advertType)
  local typeCfg = PersonalInfoInterface.GetSNSSubTypeCfgById(advertType)
  return require("Main.Chat.HtmlHelper").ConvertNPCLink(string.format(textRes.Personal[225], typeCfg.subTypeName, typeCfg.npcId))
end
def.method("number").ViewPlayerDetail = function(self, advertId)
  local sns = SocialPlatformMgr.Instance():GetSNSInfoByAdvertId(self:GetCurrentSelectSubTypeId(), advertId)
  if sns ~= nil then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    if heroProp == nil or heroProp.id == sns.roleId then
      Toast(textRes.Personal[229])
      return
    end
    PersonalInfoInterface.Instance():CheckPersonalInfo(sns.roleId, "")
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_PublishInfo" then
    PersonalInfoModule.OpenPublishSNSInfoPanel(self:GetCurrentSelectSubTypeId())
  elseif "Btn_ManageInfo" == id then
    PersonalInfoModule.OpenSNSInfoManagePanel()
  elseif id == "Btn_Screen" then
    PersonalInfoModule.OpenSNSFilterPanel(self:GetCurrentSelectSubTypeId())
  elseif id == "Btn_Next" then
    self:SetPageOffset(1)
  elseif id == "Btn_Last" then
    self:SetPageOffset(-1)
  elseif id == "Btn_Refresh" then
    self:RefreshWorldSNSInfo()
  end
end
def.static("table", "table").OnSearchFilterChange = function(context, params)
  local self = context
  self:SetSearchFilterText()
  local subTypeId = self:GetCurrentSelectSubTypeId()
  SocialPlatformMgr.SearchWorldSNSInfo(subTypeId, 1)
end
def.static("table", "table").OnSearchFilterAjust = function(context, params)
  local self = context
  self:SetSearchFilterText()
end
def.static("table", "table").OnReceiveSearchResult = function(context, params)
  local self = context
  self:SetSearchResult()
end
SocialPlatformNode.Commit()
return SocialPlatformNode
