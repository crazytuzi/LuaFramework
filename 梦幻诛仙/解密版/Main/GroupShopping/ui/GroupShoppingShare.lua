local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GroupShoppingShare = Lplus.Extend(ECPanelBase, "GroupShoppingShare")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = GroupShoppingShare.define
def.field("string").m_title = ""
def.field("string").m_content = ""
def.field("userdata").m_groupId = nil
def.field("number").m_cfgId = 0
local instance
def.static("=>", GroupShoppingShare).Instance = function()
  if instance == nil then
    instance = GroupShoppingShare()
  end
  return instance
end
def.static("string", "string", "number", "userdata").ShowShareGroup = function(title, content, cfgId, groupId)
  local dlg = GroupShoppingShare.Instance()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg.m_title = title
  dlg.m_content = content
  dlg.m_groupId = groupId
  dlg.m_cfgId = cfgId
  dlg:CreatePanel(RESPATH.PREFAB_GROUP_SHOPPING_SHARE, 2)
  dlg:SetModal(true)
end
def.static("string", "string", "number").ShowShareItem = function(title, content, cfgId)
  local dlg = GroupShoppingShare.Instance()
  if dlg:IsShow() then
    dlg:DestroyPanel()
  end
  dlg.m_title = title
  dlg.m_content = content
  dlg.m_groupId = nil
  dlg.m_cfgId = cfgId
  dlg:CreatePanel(RESPATH.PREFAB_GROUP_SHOPPING_SHARE, 2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GroupShoppingShare.OnFeatureChange, self)
  local titleLbl = self.m_panel:FindDirect("Img_0/Label_Title")
  titleLbl:GetComponent("UILabel"):set_text(self.m_title)
  local cntLbl = self.m_panel:FindDirect("Img_0/Group_Content/Label_Info")
  cntLbl:GetComponent("UILabel"):set_text(self.m_content)
  self:ShowShareBtn(false)
end
def.method("table").OnFeatureChange = function(self, params)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GROUP_SHOPPING and params.open == false then
    self:DestroyPanel()
  end
end
def.method("boolean").ShowShareBtn = function(self, show)
  local zone = self.m_panel:FindDirect("Img_0/Btn_Zone")
  zone:GetComponent("UIToggleEx").value = show
  local btns = zone:FindDirect("Group_Zone")
  btns:SetActive(show)
end
def.method().ToggleShareBtn = function(self)
  local zone = self.m_panel:FindDirect("Img_0/Btn_Zone")
  local curState = zone:GetComponent("UIToggleEx").value
  self:ShowShareBtn(curState)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GroupShoppingShare.OnFeatureChange)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, GroupShoppingShare.OnGroupInited)
  self.m_title = ""
  self.m_content = ""
  self.m_groupId = nil
  self.m_cfgId = 0
end
def.method("=>", "string", "string").MakeShare = function(self)
  local cfg = GroupShoppingUtils.GetGroupCfg(self.m_cfgId)
  if cfg then
    local itemBase = ItemUtils.GetItemBase(cfg.itemId)
    if itemBase then
      local infoStr = string.format("[%s" .. textRes.GroupShopping[48] .. "]", itemBase.name)
      local infoPack = string.format("{shoppingGroup:%s%s,%s,%s}", itemBase.name, textRes.GroupShopping[48], self.m_cfgId, self.m_groupId and self.m_groupId:tostring() or "0")
      return infoStr, infoPack
    else
      return "", ""
    end
  else
    return "", ""
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Zone" then
    self:ToggleShareBtn()
  elseif id == "Btn_01" then
    do
      local btn = self.m_panel:FindDirect("Img_0/Btn_Zone/Group_Zone/Group_ChooseType/Table/Btn_01")
      local position = btn:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local sprite = btn:GetComponent("UIWidget")
      local pos = {
        auto = true,
        sourceX = screenPos.x,
        sourceY = screenPos.y,
        sourceW = sprite:get_width(),
        sourceH = sprite:get_height(),
        prefer = -1
      }
      local FriendData = require("Main.friend.FriendData")
      local friendList = FriendData.Instance():GetFriendList()
      local friendNameList = {}
      for k, v in ipairs(friendList) do
        table.insert(friendNameList, {
          name = v.roleName,
          tag = v.roleId
        })
      end
      if #friendNameList > 0 then
        require("GUI.ScrollButtonGroupPanel").ShowPanel(friendNameList, pos, function(index, tag)
          local info = FriendData.Instance():GetFriendInfo(tag)
          if info then
            do
              local SocialDlg = require("Main.friend.ui.SocialDlg")
              SocialDlg.ShowSocialDlgWithCallback(SocialDlg.NodeId.Friend, function(panel)
                if panel then
                  SocialDlg.ShowPrivateChat(info.roleId, info.roleName, true)
                  local name, cipher = self:MakeShare()
                  panel.inputViewCtrl:AddInfoPack(name, cipher)
                  self:DestroyPanel()
                end
              end)
            end
          end
        end)
      else
        Toast(textRes.GroupShopping[26])
      end
    end
  elseif id == "Btn_02" then
    local GroupModule = require("Main.Group.GroupModule")
    if GroupModule.Instance():IsInitedBasicAllGroup() then
      self:OnGroupInited(nil)
    else
      Event.RegisterEventWithContext(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, GroupShoppingShare.OnGroupInited, self)
      local protocolMgr = require("Main.Group.GroupProtocolMgr")
      protocolMgr.SetWaitForBasicInfo(true)
      protocolMgr.CGroupBasicInfoReq()
    end
  elseif id == "Btn_03" then
    local hasGang = require("Main.Gang.GangModule").Instance():HasGang()
    if hasGang then
      local ChatMsgData = require("Main.Chat.ChatMsgData")
      local name, cipher = self:MakeShare()
      self:WriteToChannel(ChatMsgData.Channel.FACTION, name, cipher)
      self:DestroyPanel()
    else
      Toast(textRes.GroupShopping[34])
    end
  end
end
def.method("number", "string", "string").WriteToChannel = function(self, channel, name, cipher)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanelWithCallback(ChatMsgData.MsgType.CHANNEL, channel, function(panel)
    if panel and panel.inputViewCtrl then
      panel.inputViewCtrl:AddInfoPack(name, cipher)
    end
  end)
end
def.method("table").OnGroupInited = function(self)
  Event.UnregisterEvent(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, GroupShoppingShare.OnGroupInited)
  if self.m_panel and not self.m_panel.isnil then
    do
      local btn = self.m_panel:FindDirect("Img_0/Btn_Zone/Group_Zone/Group_ChooseType/Table/Btn_02")
      local position = btn:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local sprite = btn:GetComponent("UIWidget")
      local pos = {
        auto = true,
        sourceX = screenPos.x,
        sourceY = screenPos.y,
        sourceW = sprite:get_width(),
        sourceH = sprite:get_height(),
        prefer = -1
      }
      local GroupModule = require("Main.Group.GroupModule")
      local groupList = GroupModule.Instance():GetBasicGroupList()
      local groupNameList = {}
      for k, v in ipairs(groupList) do
        table.insert(groupNameList, {
          name = v.groupName,
          tag = v.groupId
        })
      end
      if #groupNameList > 0 then
        require("GUI.ScrollButtonGroupPanel").ShowPanel(groupNameList, pos, function(index, tag)
          local info = GroupModule.Instance():GetGroupBasicInfo(tag)
          if info then
            local SocialDlg = require("Main.friend.ui.SocialDlg")
            SocialDlg.ShowGroupChatWithCallback(Int64.new(tag), function(panel)
              if panel then
                local name, cipher = self:MakeShare()
                panel.inputViewCtrl:AddInfoPack(name, cipher)
                self:DestroyPanel()
              end
            end)
          end
        end)
      else
        Toast(textRes.GroupShopping[27])
      end
    end
  end
end
GroupShoppingShare.Commit()
return GroupShoppingShare
