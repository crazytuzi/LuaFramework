local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECUniSDK = require("ProxySDK.ECUniSDK")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local EfunRelationShipChainPanel = Lplus.Extend(ECPanelBase, "EfunRelationShipChainPanel")
local def = EfunRelationShipChainPanel.define
def.field("table").m_Data = nil
def.field("table").m_UIGO = nil
def.field("table").m_TextureData = function()
  return {}
end
local instance
def.static("=>", EfunRelationShipChainPanel).Instance = function()
  if not instance then
    instance = EfunRelationShipChainPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_EFUN_RELATIONSHIP_CHAIN_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.static("table", "table").OnFetchFBFriends = function(params)
  if instance.m_panel and not instance.m_panel.isnil then
    instance.m_Data = params.info
    instance:Update()
  end
end
def.override().OnCreate = function(self)
  ECUniSDK.Instance():FetchPlayingFriends({})
  ECUniSDK.Instance():GetinviteFriends({})
  self:InitUI()
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.FetchFBFriends, EfunRelationShipChainPanel.OnFetchFBFriends)
end
def.override().OnDestroy = function(self)
  self.m_Data = nil
  self.m_UIGO = nil
  for k, v in pairs(self.m_TextureData) do
    if v then
      v:Destroy()
    end
    self.m_TextureData[k] = nil
  end
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.FetchFBFriends, EfunRelationShipChainPanel.OnFetchFBFriends)
end
def.override("boolean").OnShow = function(self, flag)
  if flag then
    self:Update()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Invite" then
    ECUniSDK.Instance():InviteFriends({})
  elseif id == "Btn_Share" then
    ECUniSDK.Instance():Share({
      name = textRes.RelationShipChain[64],
      caption = textRes.RelationShipChain[65],
      shareDesc = textRes.RelationShipChain[66],
      type = ECUniSDK.SHARETYPE.FB
    })
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Invite" then
    ECUniSDK.Instance():InviteFriends({})
  elseif id == "Btn_Share" then
    ECUniSDK.Instance():Share({
      name = textRes.RelationShipChain[64],
      caption = textRes.RelationShipChain[65],
      shareDesc = textRes.RelationShipChain[66]
    })
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
end
def.method("string", "boolean").onPress = function(self, id, state)
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.ScrollView = self.m_panel:FindDirect("Img_Bg0/Group_Power/Img_BgList/Scroll View_List")
  self.m_UIGO.FriendList = self.m_UIGO.ScrollView:FindDirect("List_Friend")
  GUIUtils.SetActive(self.m_UIGO.FriendList, false)
end
def.method().Update = function(self)
  if not self.m_Data then
    return
  end
  local memberList = self.m_Data
  local scrollViewObj = self.m_UIGO.ScrollView
  local scrollListObj = self.m_UIGO.FriendList
  GUIUtils.SetActive(self.m_UIGO.FriendList, true)
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillMemberInfo(item, i, memberList[i])
  end)
  ScrollList_setCount(uiScrollList, #memberList)
  self.m_msgHandler:Touch(scrollListObj)
  scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "table").FillMemberInfo = function(self, item, index, friendData)
  local nameGO = item:FindDirect("Label_FriendName")
  local genderGO = item:FindDirect("Label_Gender")
  local idGO = item:FindDirect("Label_CharactorInfo")
  local headImgGO = item:FindDirect("Img_BgIconGroup/Texture_IconGroup")
  local iconUri = friendData.thumbnail
  if platform == 2 then
    iconUri = UniSDK.action("getProfilePicturUri", {
      userId = friendData.id,
      width = "300",
      height = "300"
    })
  end
  GUIUtils.FillTextureFromURL(headImgGO, iconUri, function(tex2d)
    self.m_TextureData[index] = tex2d
  end)
  GUIUtils.SetText(nameGO, friendData.name)
  GUIUtils.SetText(genderGO, friendData.gender)
  GUIUtils.SetText(idGO, friendData.id)
end
return EfunRelationShipChainPanel.Commit()
