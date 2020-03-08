local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local GUIUtils = require("GUI.GUIUtils")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local RelationShipChainPanelNodeBase = require("Main.RelationShipChain.ui.RelationShipChainPanelNodeBase")
local GetGiftNode = Lplus.Extend(RelationShipChainPanelNodeBase, "GetGiftNode")
local def = GetGiftNode.define
def.const("number").PAGESIZE = 8
def.field("boolean").m_ForceSwith = false
def.field("boolean").m_Continue = false
def.field("number").m_CurrentPageIndex = 1
def.field("string").m_Desc = ""
def.field("table").m_Data = nil
def.field("table").m_TextureData = function()
  return {}
end
local instance
def.static("=>", GetGiftNode).Instance = function()
  if not instance then
    instance = GetGiftNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  RelationShipChainPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitData()
  self:Update()
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ReciveGift, GetGiftNode.OnReciveGiftCallBack)
end
def.override().OnHide = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ReciveGift, GetGiftNode.OnReciveGiftCallBack)
end
def.override().Clear = function(self)
  for k, v in pairs(self.m_TextureData) do
    if v then
      v:Destroy()
    end
    self.m_TextureData[k] = nil
  end
  self.m_CurrentPageIndex = 1
  self.m_Data = nil
  RelationShipChainPanelNodeBase.Clear(self)
end
def.override("=>", "boolean").IsUnlock = function(self)
  return true
end
def.static("table", "table").OnReciveGiftCallBack = function(params)
  if instance.m_panel and not instance.m_panel.isnil then
    if params then
      instance.m_CurrentPageIndex = params[1]
    end
    instance:InitData()
    instance:Update()
    instance:UpdateRedot()
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_GetOnce" then
    self:GetAllGift()
  elseif id:find("Btn_Get") == 1 then
    local item, idx = ScrollList_getItem(clickobj)
    self:ReciveGift(idx)
  end
end
def.method().GetAllGift = function()
  RelationShipChainMgr.GetAllGift({})
end
def.method("number").ReciveGift = function(self, index)
  local giftData = self.m_Data[index]
  if not giftData then
    return
  end
  RelationShipChainMgr.ReceiveGift({
    gift_type = giftData.gift_type,
    serialid = giftData.serialid
  })
end
def.method().InitData = function(self)
  local giftData = RelationShipChainMgr.GetReciveGiftData()
  local temp = {}
  for k, v in pairs(giftData) do
    table.insert(temp, v)
  end
  table.sort(temp, function(l, r)
    return l.timestamp > r.timestamp
  end)
  self.m_Data = temp
  local gifttype = RelationShipChainMgr.GetGrcGiftCfg().gift_type
  self.m_Desc = textRes.RelationShipChain[gifttype + 28] or ""
end
def.override().InitUI = function(self)
  RelationShipChainPanelNodeBase.InitUI(self)
  self.m_UIGO = {}
  self.m_UIGO.ScrollView = self.m_panel:FindDirect("Img_Bg0/Group_Get/Img_BgList/Scroll View_List")
  self.m_UIGO.GiftList = self.m_panel:FindDirect("Img_Bg0/Group_Get/Img_BgList/Scroll View_List/List_Gift")
end
def.method().UpdateRedot = function(self)
  local imgRedGO = self.m_panel:FindDirect("Img_Bg0/Tab_Get/Img_Red")
  GUIUtils.SetActive(imgRedGO, RelationShipChainMgr.CanReciveGift())
end
def.method().FillGiftList = function(self)
  local memberList = self.m_Data
  local scrollViewObj = self.m_UIGO.ScrollView
  local scrollListObj = self.m_UIGO.GiftList
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillGiftInfo(item, i, memberList[i])
  end)
  ScrollList_setCount(uiScrollList, #memberList)
  self.m_base.m_msgHandler:Touch(scrollListObj)
  scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "table").FillGiftInfo = function(self, item, index, giftData)
  local headImgGO = item:FindDirect("Img_BgIconGroup/Texture_IconGroup")
  local friendNameGO = item:FindDirect("Label_FriendName")
  local timeGO = item:FindDirect("Label_Time")
  local tipsGO = item:FindDirect("Label_Tip")
  local nickname = GetStringFromOcts(giftData.from_nickname) or textRes.RelationShipChain[73]
  local url = RelationShipChainMgr.ProcessHeadImgURL(giftData.from_figure_url)
  GUIUtils.FillTextureFromURL(headImgGO, url, function(tex2d)
    self.m_TextureData[index] = tex2d
  end)
  GUIUtils.SetText(timeGO, GUIUtils.PassTimeDesc(giftData.timestamp))
  GUIUtils.SetText(tipsGO, textRes.RelationShipChain[24]:format(self.m_Desc))
  GUIUtils.SetText(friendNameGO, nickname)
end
def.method().Update = function(self)
  self:FillGiftList()
end
return GetGiftNode.Commit()
