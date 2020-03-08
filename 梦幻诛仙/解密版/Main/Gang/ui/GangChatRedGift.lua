local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangChatRedGift = Lplus.Extend(ECPanelBase, "GangChatRedGift")
local def = GangChatRedGift.define
local instance
def.field("table").historyRedGifts = nil
def.static("=>", GangChatRedGift).Instance = function()
  if not instance then
    instance = GangChatRedGift()
  end
  return instance
end
def.method("table").ShowPanel = function(self, _redGifts)
  if self:IsShow() then
    return
  end
  self.historyRedGifts = _redGifts
  self:CreatePanel(RESPATH.PREFAB_GANG_CHATREDGIFT, 2)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  Event.RegisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Refresh_GangChatRedGift, GangChatRedGift.OnUpdateUI)
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Refresh_GangChatRedGift, GangChatRedGift.OnUpdateUI)
  self.historyRedGifts = nil
end
def.static("table", "table").OnUpdateUI = function(params, tbl)
  if instance.historyRedGifts and instance:IsShow() then
    for i = 1, #instance.historyRedGifts do
      if instance.historyRedGifts[i].redGiftId:eq(params.redGiftId) then
        local scrollViewObj = instance.m_panel:FindDirect("Img_Bg/Img_BgList/Container/Scroll View")
        local scrollListObj = scrollViewObj:FindDirect("List_Member")
        local memberItem = scrollListObj:FindDirect(tostring(i - 1))
        instance.historyRedGifts[i].isCanGet = false
        if memberItem then
          local btn_get = memberItem:FindDirect("Img_List/Btn_Get")
          local btn_see = memberItem:FindDirect("Img_List/Btn_See")
          if btn_get and btn_see then
            btn_get:SetActive(false)
            btn_see:SetActive(true)
          end
        end
        break
      end
    end
  end
end
def.method().UpdateUI = function(self)
  if self:IsShow() then
    local img_BgListObj = self.m_panel:FindDirect("Img_Bg/Img_BgList")
    local group_NoRedBagObj = self.m_panel:FindDirect("Img_Bg/Group_NoRedBag")
    if not self.historyRedGifts or #self.historyRedGifts <= 0 then
      img_BgListObj:SetActive(false)
      group_NoRedBagObj:SetActive(true)
    else
      img_BgListObj:SetActive(true)
      group_NoRedBagObj:SetActive(false)
      local memberCount = #self.historyRedGifts
      local scrollViewObj = self.m_panel:FindDirect("Img_Bg/Img_BgList/Container/Scroll View")
      local scrollListObj = scrollViewObj:FindDirect("List_Member")
      local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
      if not GUIScrollList then
        scrollListObj:AddComponent("GUIScrollList")
      end
      local uiScrollList = scrollListObj:GetComponent("UIScrollList")
      ScrollList_setUpdateFunc(uiScrollList, function(item, i)
        self:FillInfo(item, i, self.historyRedGifts[i])
      end)
      ScrollList_setCount(uiScrollList, memberCount)
      self.m_msgHandler:Touch(scrollListObj)
      scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
    end
  end
end
def.method("userdata", "number", "table").FillInfo = function(self, memberUI, index, memberInfo)
  local label_name = memberUI:FindDirect("Label_Name"):GetComponent("UILabel")
  local label_content = memberUI:FindDirect("Label_Content"):GetComponent("UILabel")
  local btn_get = memberUI:FindDirect("Btn_Get")
  local btn_see = memberUI:FindDirect("Btn_See")
  label_name:set_text(memberInfo.name)
  label_content:set_text(memberInfo.content)
  local isCanSee = true
  if memberInfo.isCanGet then
    isCanSee = false
  end
  btn_get:SetActive(not isCanSee)
  btn_see:SetActive(isCanSee)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  warn("onClickObj" .. id)
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif id:find("Btn_Get") or id:find("Btn_See") then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local parentObj = clickobj.parent
    local itemObj, index = ScrollList_getItem(parentObj)
    Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Get_ChatRedGiftProtocol, {
      redGiftId = self.historyRedGifts[index].redGiftId,
      channelType = ChatMsgData.MsgType.CHANNEL,
      channelSubType = ChatMsgData.Channel.FACTION
    })
  end
end
GangChatRedGift.Commit()
return GangChatRedGift
