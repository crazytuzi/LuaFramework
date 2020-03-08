local Lplus = require("Lplus")
local GreetingCardMgr = Lplus.Class("GreetingCardMgr")
local def = GreetingCardMgr.define
local instance
def.static("=>", GreetingCardMgr).Instance = function()
  if instance == nil then
    instance = GreetingCardMgr()
  end
  return instance
end
def.const("number").MAXID = 128
def.field("table").wordsMap = nil
def.field("number").idGen = 1
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.greetingcard.SSendCardFail", GreetingCardMgr.OnSSendCardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.greetingcard.SSendCardBroadcast", GreetingCardMgr.OnSSendCardBroadcast)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CARD_CLICK, GreetingCardMgr.OnClickCardBtn)
end
def.method().Reset = function(self)
  self.wordsMap = {}
  self.idGen = 1
end
def.static("table").OnSSendCardFail = function(p)
  local tip = textRes.CardFail[p.retcode]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSSendCardBroadcast = function(p)
  local senderId = p.senderData.roleId
  local roleName = p.senderData.roleName
  local gender = p.senderData.gender
  local occupationId = p.senderData.occupationId
  local level = p.senderData.level
  local vipLevel = 0
  local avatarId = p.senderData.avatarId
  local avatarFrameId = p.senderData.avatarFrameId
  local modelId = p.senderData.modelId
  local badge = p.senderData.badge
  local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
  local word = GetStringFromOcts(p.data.content)
  local self = GreetingCardMgr.Instance()
  if self.wordsMap == nil then
    self.wordsMap = {}
  end
  local thisId = self.idGen
  self.wordsMap[thisId] = p.data
  local sendContent = string.format(textRes.Chat[81], word, thisId)
  self.idGen = self.idGen >= GreetingCardMgr.MAXID and 1 or self.idGen + 1
  local content = require("netio.Octets").rawFromString(sendContent)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  if p.channel == ChatMsgData.Channel.FACTION then
    GreetingCardMgr.SendFakeFactionProtocol(senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, avatarId, avatarFrameId, 7)
  elseif p.channel == ChatMsgData.Channel.WORLD then
    GreetingCardMgr.SendFakeWorldProtocol(senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, avatarId, avatarFrameId)
  end
  if GetMyRoleID() == senderId then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Chat[88], textRes.Chat[89], function(sel)
      if sel == 1 then
        local shareScreen = function(panel)
          local filePath = GenShareImagePath("GreetingCard" .. tostring(GetServerTime()) .. ".png")
          local bg = panel.m_panel:FindDirect("Img_Bg0")
          local GUIMan = require("GUI.ECGUIMan")
          local screenHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
          local height = bg:GetComponent("UISprite"):get_height() / screenHeight * Screen.height
          local width = bg:GetComponent("UISprite"):get_width() / screenHeight * Screen.height
          local y = (Screen.height - height) / 2
          local x = (Screen.width - width) / 2
          GameUtil.ScreenShot(x, y, width, height, 800, filePath, function(ret, filePath)
            if ret then
              local sdktype = ClientCfg.GetSDKType()
              if sdktype == ClientCfg.SDKTYPE.MSDK then
                local ECMSDK = require("ProxySDK.ECMSDK")
                ECMSDK.SendToFriendWithPhotoPath(1, filePath)
              elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
                local ECUniSDK = require("ProxySDK.ECUniSDK")
                if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
                  ECUniSDK.Instance():Share({localPic = filePath})
                elseif ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
                  ECUniSDK.Instance():Share({
                    imagePath = filePath,
                    title = textRes.RelationShipChain[101],
                    desc = textRes.RelationShipChain[104]
                  })
                end
              end
            end
          end)
        end
        local cardCfg = GreetingCardMgr.Instance():GetGreetingCardCfg(p.data.cardCfgId)
        if cardCfg and cardCfg.cards[p.data.resourceId] then
          local prefab = cardCfg.cards[p.data.resourceId]
          local word = GetStringFromOcts(p.data.content)
          require("Main.Chat.GreetingCard.ui.GreetingCardShow").ShowGreetingCardShow(word, prefab, shareScreen)
        end
      end
    end, nil)
  end
end
def.static("userdata", "string", "number", "number", "number", "number", "number", "table", "number", "userdata", "number", "number", "number").SendFakeFactionProtocol = function(roleId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, avatarId, avatarFrameId, position)
  local SChatInFaction = require("netio.protocol.mzm.gsp.chat.SChatInFaction")
  local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
  local time = _G.GetServerTime()
  local chatCnt = ChatContent.new(roleId, roleName, gender, occupationId, avatarId, avatarFrameId, level, vipLevel, modelId, badge, contentType, content, 0, Int64.new(time) * 1000)
  local chatFaction = SChatInFaction.new(chatCnt, position)
  require("Main.Chat.ChatModule").OnNewFactionChat(chatFaction)
end
def.static("userdata", "string", "number", "number", "number", "number", "number", "table", "number", "userdata", "number", "number").SendFakeWorldProtocol = function(roleId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, avatarId, avatarFrameId)
  local SChatInWorld = require("netio.protocol.mzm.gsp.chat.SChatInWorld")
  local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
  local time = _G.GetServerTime()
  local chatCnt = ChatContent.new(roleId, roleName, gender, occupationId, avatarId, avatarFrameId, level, vipLevel, modelId, badge, contentType, content, 0, Int64.new(time) * 1000)
  local chatWorld = SChatInWorld.new(chatCnt)
  require("Main.Chat.ChatModule").OnWorldChat(chatWorld)
end
def.static("table", "table").OnClickCardBtn = function(p1, p2)
  local id = tonumber(p1.id)
  if id then
    local data = GreetingCardMgr.Instance().wordsMap[id]
    if data then
      local cardCfg = GreetingCardMgr.Instance():GetGreetingCardCfg(data.cardCfgId)
      if cardCfg and cardCfg.cards[data.resourceId] then
        local prefab = cardCfg.cards[data.resourceId]
        local word = GetStringFromOcts(data.content)
        require("Main.Chat.GreetingCard.ui.GreetingCardShow").ShowGreetingCardShow(word, prefab, nil)
      end
    end
  end
end
def.method("number", "=>", "table").GetGreetingCardCfg = function(self, itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GREETING_CARD_CFG, itemId)
  if not record then
    warn("GetGreetingCardCfg nil", activityId)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.desc = record:GetStringValue("desc")
  cfg.words = {}
  local textStruct = record:GetStructValue("textStruct")
  local textCount = DynamicRecord.GetVectorSize(textStruct, "texts")
  for i = 0, textCount - 1 do
    local entry = textStruct:GetVectorValueByIdx("texts", i)
    local text = entry:GetStringValue("text")
    table.insert(cfg.words, text)
  end
  cfg.cards = {}
  local resourcePathStruct = record:GetStructValue("resourcePathStruct")
  local resCount = DynamicRecord.GetVectorSize(resourcePathStruct, "resourcePaths")
  for i = 0, resCount - 1 do
    local entry = resourcePathStruct:GetVectorValueByIdx("resourcePaths", i)
    local resPath = entry:GetStringValue("resourcePath")
    table.insert(cfg.cards, resPath)
  end
  cfg.names = {}
  local nameStruct = record:GetStructValue("nameStruct")
  local nameCount = DynamicRecord.GetVectorSize(nameStruct, "names")
  for i = 0, nameCount - 1 do
    local entry = nameStruct:GetVectorValueByIdx("names", i)
    local name = entry:GetStringValue("name")
    table.insert(cfg.names, name)
  end
  return cfg
end
def.method("number", "string", "number", "number", "number").SendGreetingCard = function(self, channel, word, ui, itemKey, itemId)
  local Octets = require("netio.Octets")
  local data = require("netio.protocol.mzm.gsp.greetingcard.GreetingCardData").new(itemId, Octets.rawFromString(word), ui)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.greetingcard.CSendCardReq").new(itemKey, channel, data))
end
def.method("number", "number").ShowSendGreetingCard = function(self, itemId, itemKey)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GREETING_CARD) then
    Toast(textRes.Chat[87])
    return
  end
  local cfg = self:GetGreetingCardCfg(itemId)
  if cfg then
    require("Main.Chat.GreetingCard.ui.GreetingCardEdit").ShowGreetingCardEdit(cfg, function(text, ui, channel)
      if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GREETING_CARD) then
        Toast(textRes.Chat[87])
        return
      end
      self:SendGreetingCard(channel, text, ui, itemKey, itemId)
    end)
  end
end
GreetingCardMgr.Commit()
return GreetingCardMgr
