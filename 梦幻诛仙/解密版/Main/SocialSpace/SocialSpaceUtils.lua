local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SocialSpaceUtils = Lplus.Class(MODULE_NAME)
local def = SocialSpaceUtils.define
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ECSocialSpaceMan = Lplus.ForwardDeclare("ECSocialSpaceMan")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local LuaUserDataIO = require("Main.Common.LuaUserDataIO")
def.const("number").MAX_REPLY_PREVIEW_NUM = 3
def.const("string").TEXT_DEFAULT_COLOR = "4f3018"
def.const("string").TEXT_REPLY_COLOR = "b57143"
def.static("number", "=>", "string").TimestampToDisplayText = function(timestamp)
  local curTime = _G.GetServerTime()
  local t = AbsoluteTimer.GetServerTimeTable(timestamp)
  local diffSeconds = curTime - timestamp
  local text
  if diffSeconds <= 0 then
    text = textRes.SocialSpace[1]
  elseif diffSeconds < 60 then
    text = textRes.SocialSpace[2]:format(diffSeconds)
  elseif diffSeconds < 3600 then
    text = textRes.SocialSpace[3]:format(math.floor(diffSeconds / 60))
  elseif diffSeconds < 86400 then
    text = textRes.SocialSpace[4]:format(math.floor(diffSeconds / 3600))
  elseif diffSeconds < 259200 then
    text = textRes.SocialSpace[5]:format(math.floor(diffSeconds / 86400))
  else
    text = AbsoluteTimer.GetFormatedServerDate(textRes.Common.Date[2], timestamp)
  end
  return text
end
def.static("table", "number", "=>", "string").BuildFavorListContent = function(favorList, voteSize)
  local maxFavorCount = 3
  local favorNameTable = {}
  for i = 1, maxFavorCount do
    local favorInfo = favorList[i]
    if favorInfo then
      local roleLink = SocialSpaceUtils.BuildRoleNameText(favorInfo.id, favorInfo.name, {})
      table.insert(favorNameTable, roleLink)
    end
  end
  local favorNames = table.concat(favorNameTable, textRes.Common.Dunhao)
  if voteSize > maxFavorCount then
    favorNames = textRes.SocialSpace[6]:format(favorNames, voteSize)
  end
  local richFavorList = favorNames
  if voteSize > 0 then
    richFavorList = SocialSpaceUtils.BuildSpaceRichContent(richFavorList, "")
  end
  return richFavorList
end
def.static("table", "number", "=>", "table").BuildReplyListContent = function(replyList, displaySize)
  local richReplyList = {}
  for i = 1, displaySize do
    local replyInfo = replyList[i]
    if replyInfo then
      local replyStr
      if replyInfo.replyRoleId == Zero_Int64 then
        local roleLink = SocialSpaceUtils.BuildRoleNameText(replyInfo.roleId, replyInfo.playerName, {})
        replyStr = textRes.SocialSpace[7]:format(roleLink, replyInfo.strPlainMsg)
      else
        local roleLink = SocialSpaceUtils.BuildRoleNameText(replyInfo.roleId, replyInfo.playerName, {})
        local targetRoleLink = SocialSpaceUtils.BuildRoleNameText(replyInfo.replyRoleId, replyInfo.replyRoleName, {})
        replyStr = textRes.SocialSpace[8]:format(roleLink, targetRoleLink, replyInfo.strPlainMsg)
      end
      replyStr = SocialSpaceUtils.BuildSpaceRichContent(replyStr, "", SocialSpaceUtils.TEXT_REPLY_COLOR)
      table.insert(richReplyList, replyStr)
    end
  end
  return richReplyList
end
def.static("table", "=>", "string").BuildMsgBoardContent = function(msg)
  local content
  if msg.replyRoleId ~= msg.targetId and msg.replyRoleId ~= Zero_Int64 then
    local roleLink = SocialSpaceUtils.BuildRoleNameText(msg.replyRoleId, msg.replyRoleName, {})
    content = textRes.SocialSpace[18]:format(roleLink, msg.strPlainMsg)
    content = SocialSpaceUtils.BuildSpaceRichContent(content, "")
  else
    content = msg.strRichMsg
  end
  return content
end
def.static("string", "string", "varlist", "=>", "string").BuildSpaceRichContent = function(plainStr, strData, textColor)
  local strRichMsg = HtmlHelper.ConvertInfoPack(plainStr)
  textColor = textColor or SocialSpaceUtils.TEXT_DEFAULT_COLOR
  return ("<p align=\"left\" valign=\"middle\" linespacing=\"6\"><font size=19 color=#%s>%s</font></p>"):format(textColor, strRichMsg)
end
def.static("userdata", "string", "table", "=>", "string").BuildRoleNameText = function(roleId, name, params)
  return SocialSpaceUtils.BuildLinkText("sspace_role_" .. tostring(roleId), name, params)
end
def.static("string", "string", "table", "=>", "string").BuildLinkText = function(id, name, params)
  local text = ("<a href=\"%s\" id='%s'><font color=#%s>[%s]</font></a>"):format(id, id, HtmlHelper.NameColor[2], name)
  return text
end
def.static("userdata", "table").ShowShareOptionsPanel = function(baseGO, context)
  if SocialSpaceUtils.IsShareOptionPanelv2Available() then
    SocialSpaceUtils.ShowShareOptionsPanelv2(baseGO, context)
    return
  end
  local Vector = require("Types.Vector")
  local position = baseGO.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = baseGO:GetComponent("UIWidget")
  local pos = {
    auto = true,
    prefer = 0,
    preferY = 1
  }
  pos.sourceX = screenPos.x
  pos.sourceY = screenPos.y - widget.height / 2
  pos.sourceW = widget.width
  pos.sourceH = widget.height
  local operations = {
    require("Main.Item.Operations.OperationSpaceShareWorld")(),
    require("Main.Item.Operations.OperationSpaceShareTeam")(),
    require("Main.Item.Operations.OperationSpaceShareGang")()
  }
  local btns = {}
  for i, v in ipairs(operations) do
    local btn = {
      name = v:GetOperationName()
    }
    btns[#btns + 1] = btn
  end
  require("GUI.ButtonGroupPanel").ShowPanel(btns, pos, function(index)
    local operation = operations[index]
    return operation:Operate(0, 0, nil, context)
  end)
end
def.static("=>", "boolean").IsShareOptionPanelv2Available = function()
  local ChannelChatPanel = require("Main.Chat.ui.ChannelChatPanel")
  return Lplus.tryget(ChannelChatPanel, "ShowChannelChatPanelWithCallback") ~= nil
end
def.static("userdata", "table").ShowShareOptionsPanelv2 = function(baseGO, context)
  local name, cipher = SocialSpaceUtils.MakeInfoPack(context)
  SocialSpaceUtils.WriteToChannel(0, name, cipher)
end
def.static("number", "string", "string").WriteToChannel = function(channel, name, cipher)
  local channelChatPanel = require("Main.Chat.ui.ChannelChatPanel").Instance()
  local lastMsgType = channelChatPanel.channelType
  local lastSubType = channelChatPanel.channelSubType
  if lastMsgType ~= ChatMsgData.MsgType.CHANNEL or lastSubType == ChatMsgData.Channel.TRUMPET then
    channel = ChatMsgData.Channel.WORLD
  end
  require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanelWithCallback(ChatMsgData.MsgType.CHANNEL, channel, function(panel)
    if panel and panel.inputViewCtrl then
      panel.inputViewCtrl:AddInfoPack(name, cipher)
    end
  end)
end
def.static("table", "=>", "string", "string").MakeInfoPack = function(context)
  local infoStr = string.format("[%s]", textRes.SocialSpace[37]:format(context.ownerName))
  local infoPack = string.format("{ssmoment:%s,%s,%s}", context.ownerName, context.ownerId:tostring(), context.msgId:tostring())
  return infoStr, infoPack
end
def.static().ShowFeatureNotOpenPrompt = function()
  Toast(textRes.SocialSpace[45])
end
def.static("=>", "table").GetAllDecorationTypeDisplayCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleOrnamentTypeShowCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = SocialSpaceUtils._GetDecorationTypeDisplayCfg(record)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(l, r)
    return l.displayIndex < r.displayIndex
  end)
  return cfgs
end
def.static("number", "=>", "table").GetDecorationTypeDisplayCfg = function(decoType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleOrnamentTypeShowCfg, decoType)
  if decoType == nil then
    Debug.LogError(string.format("GetDecorationTypeDisplayCfg(%d) return nil", decoType))
    return nil
  end
  return SocialSpaceUtils._GetDecorationTypeDisplayCfg(record)
end
def.static("userdata", "=>", "table")._GetDecorationTypeDisplayCfg = function(record)
  local cfg = {}
  cfg.decoType = record:GetIntValue("ornament_type")
  cfg.displayIndex = record:GetIntValue("show_index")
  cfg.defaultItemId = record:GetIntValue("default_item_cfg_id")
  cfg.name = record:GetStringValue("show_name")
  return cfg
end
def.static("number", "=>", "table").GetDecorationTypeCfg = function(decoType)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleOrnamentTypeCfg, decoType)
  if decoType == nil then
    Debug.LogError(string.format("GetDecorationTypeCfg(%d) return nil", decoType))
    return nil
  end
  local cfg = {}
  cfg.decoType = decoType
  cfg.itemIds = {}
  local itemIdsStruct = record:GetStructValue("itemIdsStruct")
  local size = itemIdsStruct:GetVectorSize("itemIds")
  for i = 0, size - 1 do
    local vectorRow = itemIdsStruct:GetVectorValueByIdx("itemIds", i)
    local itemId = vectorRow:GetIntValue("itemId")
    table.insert(cfg.itemIds, itemId)
  end
  return cfg
end
def.static("number", "=>", "table").GetDecorationItemCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleDressUpItemCfg, itemId)
  if record == nil then
    Debug.LogError(string.format("GetDecorationItemCfg(%d) return nil", itemId))
    return nil
  end
  return SocialSpaceUtils._GetDecorationItemCfg(record)
end
def.static("=>", "table").GetAllNewDecorationItems = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleDressUpItemCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = SocialSpaceUtils._GetDecorationItemCfg(record)
    if cfg.isNew then
      table.insert(cfgs, cfg)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfgs
end
def.static("userdata", "=>", "table")._GetDecorationItemCfg = function(record)
  local cfg = {}
  cfg.itemId = record:GetIntValue("id")
  cfg.resId = record:GetIntValue("dress_up_resource_id")
  cfg.decoType = record:GetIntValue("ornament_type")
  cfg.displayIndex = record:GetIntValue("show_index")
  cfg.isNew = record:GetCharValue("is_new_product") == 1
  return cfg
end
def.static("number", "=>", "table").GetPresentBrodcastCfg = function(itemId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleGivePresentCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local item_cfg_id = record:GetIntValue("item_cfg_id")
    if item_cfg_id == itemId then
      local grade = record:GetIntValue("grade")
      local gradeInfo = {grade = grade}
      gradeInfo.isBroadcast = record:GetCharValue("is_broadcast") == 1
      if gradeInfo.isBroadcast then
        cfg = cfg or {}
        local grades = cfg.grades or {}
        gradeInfo.fxId = record:GetIntValue("special_effect_cfg_id")
        table.insert(grades, gradeInfo)
        cfg.grades = grades
      end
    end
  end
  if cfg then
    table.sort(cfg.grades, function(l, r)
      return l.grade < r.grade
    end)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("number", "number", "=>", "table").GetGivePresentCfg = function(itemId, giftGrade)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleGivePresentCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfg
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local item_cfg_id = record:GetIntValue("item_cfg_id")
    local grade = record:GetIntValue("grade")
    if item_cfg_id == itemId and grade == giftGrade then
      cfg = {}
      cfg.isBroadcast = record:GetCharValue("is_broadcast") == 1
      cfg.isBroadcastFx = record:GetCharValue("is_broadcast_effect") == 1
      cfg.isSingleFx = record:GetCharValue("is_signal_effect") == 1
      cfg.fxId = record:GetIntValue("special_effect_cfg_id")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return cfg
end
def.static("number", "=>", "table").GetPresentGradeCfg = function(grade)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleGivePresentGradeCfg, grade)
  if record == nil then
    Debug.LogError(string.format("GetPresentGradeCfg(%d) return nil", grade))
    return nil
  end
  return SocialSpaceUtils._GetPresentGradeCfg(record)
end
def.static("=>", "table").GetAllPresentGradCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleGivePresentGradeCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = SocialSpaceUtils._GetPresentGradeCfg(record)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(l, r)
    return l.presentNum < r.presentNum
  end)
  return cfgs
end
def.static("userdata", "=>", "table")._GetPresentGradeCfg = function(record)
  local cfg = {}
  cfg.grade = record:GetIntValue("grade")
  cfg.presentNum = record:GetIntValue("present_num")
  return cfg
end
def.static("number", "=>", "table").GetPresentPopularCfg = function(itemId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleGivePresentPopularityCfg, itemId)
  if record == nil then
    Debug.LogError(string.format("GetPresentPopularCfg(%d) return nil", itemId))
    return nil
  end
  return SocialSpaceUtils._GetPresentPopularCfg(record)
end
def.static("=>", "table").GetAllPresentPopularCfgs = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_SOCIAL_SPACE_CFriendsCircleGivePresentPopularityCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local cfgs = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = SocialSpaceUtils._GetPresentPopularCfg(record)
    table.insert(cfgs, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  table.sort(cfgs, function(l, r)
    return l.sortIndex < r.sortIndex
  end)
  return cfgs
end
def.static("userdata", "=>", "table")._GetPresentPopularCfg = function(record)
  local cfg = {}
  cfg.itemId = record:GetIntValue("item_cfg_id")
  cfg.addPopValue = record:GetIntValue("add_popularity_values")
  cfg.sortIndex = record:GetIntValue("show_index")
  return cfg
end
def.static("table").ShowPhotoOptions = function(params)
  local pos, sourceObj = params.pos, params.sourceObj
  local onGetImagePath = params.onGetImagePath
  local onDelete = params.onDelete
  local extras = params.extras
  if pos == nil and sourceObj then
    local position = sourceObj.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = sourceObj:GetComponent("UIWidget")
    pos = {
      auto = true,
      prefer = 1,
      preferY = 1
    }
    pos.sourceX = screenPos.x
    pos.sourceY = screenPos.y - widget.height / 2
    pos.sourceW = widget.width
    pos.sourceH = widget.height
  end
  if pos == nil then
    error("params.pos expected", 2)
  end
  local ECSocialSpaceCosMan = require("Main.SocialSpace.ECSocialSpaceCosMan")
  local btns = {}
  if onDelete then
    local btn = {
      name = textRes.SocialSpace[74],
      order = 1
    }
    table.insert(btns, btn)
  end
  if onGetImagePath then
    local btn = {
      name = textRes.SocialSpace[73],
      order = 2
    }
    table.insert(btns, btn)
    local btn = {
      name = textRes.SocialSpace[72],
      order = 3
    }
    table.insert(btns, btn)
  end
  require("GUI.ButtonGroupPanel").ShowPanel(btns, pos, function(index)
    local btn = btns[index]
    if btn.order == 1 then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm(textRes.Common[8], textRes.SocialSpace[79], function(s)
        if s == 1 then
          _G.SafeCallback(onDelete)
        end
      end, nil)
    elseif btn.order == 2 then
      ECSocialSpaceCosMan.Instance():DoGetImagePath(ECSocialSpaceCosMan.FROM_ALBUM, function(localPath, cropResult)
        _G.SafeCallback(onGetImagePath, localPath, ECSocialSpaceCosMan.FROM_ALBUM, cropResult)
      end, extras)
    elseif btn.order == 3 then
      ECSocialSpaceCosMan.Instance():DoGetImagePath(ECSocialSpaceCosMan.FROM_CAMERA, function(localPath, cropResult)
        _G.SafeCallback(onGetImagePath, localPath, ECSocialSpaceCosMan.FROM_CAMERA, cropResult)
      end, extras)
    end
    return true
  end)
end
def.static("table", "number").ShowPictureDisplayPanel = function(remotePaths, defaultIndex)
  local GUIUtils = require("GUI.GUIUtils")
  local ECSocialSpaceCosMan = require("Main.SocialSpace.ECSocialSpaceCosMan")
  local CommonPictureDisplayPanel = require("GUI.CommonPictureDisplayPanel")
  CommonPictureDisplayPanel.Instance():ShowPanel(remotePaths, defaultIndex, function(Texture, remotePath)
    local cos_cfg = ECSocialSpaceCosMan.Instance():GetCosCfg()
    local picUrl = ECSocialSpaceCosMan.PicProcessing(remotePath, cos_cfg.pic_processing_params_big)
    ECSocialSpaceCosMan.Instance():LoadFile(picUrl, function(filePath)
      if _G.IsNil(Texture) then
        return
      end
      GUIUtils.FillTextureFromLocalPath(Texture, filePath, function(...)
        local uiTexture = Texture:GetComponent("UITexture")
        uiTexture:MakePixelPerfect()
        if uiTexture.width > cos_cfg.show_image_w_limit then
          uiTexture.height = uiTexture.height / uiTexture.width * cos_cfg.show_image_w_limit
          uiTexture.width = cos_cfg.show_image_w_limit
        end
        if uiTexture.height > cos_cfg.show_image_h_limit then
          uiTexture.width = uiTexture.width / uiTexture.height * cos_cfg.show_image_h_limit
          uiTexture.height = cos_cfg.show_image_h_limit
        end
      end)
    end)
  end)
end
def.static("userdata").ShowGiftHistory = function(roleId)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_GIVE_PRESENT) then
    Toast(textRes.SocialSpace[45])
    return
  end
  require("Main.SocialSpace.ui.SpaceGiftHistoryPanel").Instance():ShowPanel(roleId)
end
def.static("userdata", "=>", "boolean").ShowGiveGiftPanel = function(roleId)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_GIVE_PRESENT) then
    Toast(textRes.SocialSpace[45])
    return false
  end
  local ECSocialSpaceConfig = require("Main.SocialSpace.ECSocialSpaceConfig")
  local levelLimit = ECSocialSpaceConfig.getSendGiftLevelLimit()
  local hp = _G.GetHeroProp()
  if hp and levelLimit > hp.level then
    Toast(textRes.SocialSpace[109]:format(levelLimit))
    return false
  end
  if ECSocialSpaceMan.Instance():CheckIsRoleInBlacklist(roleId) then
    return false
  end
  require("Main.SocialSpace.ui.SpaceGiveGiftPanel").Instance():ShowPanel(roleId)
  return true
end
def.static("number", "=>", "number").GetSavedDecorateResId = function(decoType)
  local savedDecoData = ECSocialSpaceMan.Instance():GetSavedDecorateData()
  local itemId = savedDecoData[decoType] or 0
  local decoItemCfg
  if itemId ~= 0 then
    decoItemCfg = SocialSpaceUtils.GetDecorationItemCfg(itemId)
  end
  local resId = decoItemCfg and decoItemCfg.resId or 0
  return resId
end
def.static("=>", "string").GetSavedPendantDecorateResPath = function()
  local DecoType = require("consts.mzm.gsp.item.confbean.FriendsCircleOrnamentItemType")
  local resId = SocialSpaceUtils.GetSavedDecorateResId(DecoType.TYPE_PENDANT_ORNAMENT)
  local resPath = _G.GetIconPath(resId)
  return resPath
end
return SocialSpaceUtils.Commit()
