local _M = {}
_M.__index = _M


local cjson     = require "cjson"
local Util      = require "Zeus.Logic.Util"
local ChatModel = require 'Zeus.Model.Chat'

_M.m_StrTemp = nil               
_M.chatcolor = {
    tbt_channel1 = 0xf3ac50ff,
    tbt_channel2 = 0xf9d983ff,
    tbt_channel3 = 0xdf7bffff,
    tbt_channel4 = 0x7fc1feff,
    tbt_channel5 = 0x6ccb9cff,
    tbt_channel6 = 0xff7380ff,
    tbt_channel7 = 0xece0e0ff,
    tbt_channel8 = 0xe7ba58ff,

    tbt_stroke1 = 0x4e2e0eff,
    tbt_stroke2 = 0x2c1a10ff,
    tbt_stroke3 = 0x311e4bff,
    tbt_stroke4 = 0x181a23ff,
    tbt_stroke5 = 0x101a16ff,
    tbt_stroke6 = 0x452319ff,
    tbt_stroke7 = 0x2b2d35ff,
    tbt_stroke8 = 0x2b2d35ff,

    play_name   = 0x7fc1feff,
    play_stroke = 0x181a23ff,
    hudcontent  = 0xece0e0ff,
    hudcontentstroke = 0x2b2d35ff,
    chatcontentslef = 0x000000ff,
    chatcontentplay = 0x000000ff,
    chatcontentHorn = 0xC8AAA0ff,
    
    
}

_M.PorColor = {
    PorColor1 = 0xddf2ffff,
    PorColor2 = 0xddf2ffff,
    PorColor3 = 0xddf2ffff,
    PorColor4 = 0xddf2ffff,
    PorColor5 = 0xddf2ffff,
}

_M.LinkType = {
    LinkTypeItem = 1,          
    LinkTypeVoice = 2,         
    LinkTypePerson = 3,        
    LinkTypeSendPlace = 4,     
    LinkTypeTeamMsg = 5,       
    LinkTypeMapMsg = 6,        
    LinkTypeMonster = 7,       
    LinkTypePet = 8,           
    LinkTypeSkill = 9,         
    LinkTypeRecruit = 10,      
    LinkType5v5Battle = 11,    
}

_M.PrivateList = {}
_M.UnionData = {}
_M.VoiceAutoPlayList = {}
_M.isVoicePlaying = false
local defaultSysColor = nil

local BGMVolume = 1
local EffectVolume = 1

function _M.GetDefaultSysColor()  
    if defaultSysColor == nil then
        defaultSysColor = GameUtil.CovertHexStringToRGBA(_M.ParametersValue("Chat.Default.Color"))
    end
    return defaultSysColor
end

local function DealItemEncode(msg, type)
    return "|<" .. type .. " " .. msg .. "></" .. type .. ">|"
end

function _M.ParametersValue(key)
    
    local search_t = {ParamName = key}
    local ret = GlobalHooks.DB.Find('Parameters',search_t)
    if ret ~= nil and #ret > 0 then
        if ret[1].ParamType == "NUMBER" then
            return tonumber(ret[1].ParamValue)
        else
            return ret[1].ParamValue
        end
    end
    return 0
end

function _M.StartsWith(item, res)
    return ChatModel.StartsWith(item, res)
end

function _M.EndsWith(item, res)
    return ChatModel.EndsWith(item, res)
end

function _M.AddFaceByIndex(index)
    local input = {}
    input.index = index
    local msg = cjson.encode(input)
    return DealItemEncode(msg, "q")
end

function _M.AddItemByData(data, detail)
    
    
    local input = {}
    input.Id = detail.id
    input.TemplateId = detail.static.Code
    input.MsgType = _M.LinkType.LinkTypeItem                          
    input.Quality = detail.static.Qcolor
    if detail.equip ~= nil then
        input.needQuery = 1
    else
        input.needQuery = 0
    end
    input.Name = '['..detail.static.Name..']'
    local msg = cjson.encode(input)
    return DealItemEncode(msg, "a")
end

function _M.Add5v5Battle(battleid,linkstr)
    local input = {}
    input.BattleId = battleid
    input.MsgType = _M.LinkType.LinkType5v5Battle
    input.Str = linkstr
    local msg = cjson.encode(input)
    return DealItemEncode(msg, "battle")
end

function _M.AddVoiceByData(data)
    data.MsgType = _M.LinkType.LinkTypeVoice
    local msg = cjson.encode(data)
    return DealItemEncode(msg, "v")
end

function _M.AddPersonByData(data)
    
    if data == nil then
        return ""
    end

    local input = {}
    input.s2c_playerId = data.s2c_playerId
    input.MsgType = _M.LinkType.LinkTypePerson
    input.s2c_name = data.s2c_name
    input.s2c_level = data.s2c_level
    input.s2c_pro = data.s2c_pro
    local msg = cjson.encode(input)
    return DealItemEncode(msg, "a")
end

function _M.AddSendPlace(data)
    
    if data == nil then
        return ""
    end

    local input = {}
    input.MsgType = _M.LinkType.LinkTypeSendPlace
    input.id = data.id
    return cjson.encode(input)
end

function _M.MsgConvertToStr(data, type)
    
    if data == nil then
        return ""
    end

    local input = {}
    input.MsgType = type
    input.data = data
    return cjson.encode(input)
end

function _M.CommonMsgDeal(msgData, name, qColor, linkType)  
    
    return _M.CommonMsgDeal2nd(msgData, name, Util.GetQualityColorARGB(tonumber(qColor)), linkType)
end

function _M.CommonMsgDeal2nd(msgData, name, colorargb, linkType)
    
    local datastr = "<f color='|1|' style = '4' link = '|2|'>|3|</f>"
    local data = {}
    data[1] = string.format("%08X",  colorargb)
    data[2] = _M.MsgConvertToStr(msgData, linkType)
    data[3] = name
    datastr = _M.HandleString(datastr, data)
    return datastr
end

function _M.PersonMsgDeal(msgData, name, colorargb)
    
    local datastr = "<f color='|1|' style = '4' link = '|2|'>|3|</f>"
    local data = {}
    data[1] = string.format("%08X",  colorargb)
    data[2] = cjson.encode(msgData)
    data[3] = name
    datastr = _M.HandleString(datastr, data)
    return datastr
end

function _M.AddSendTeamMsg(data)
    
    return _M.MsgConvertToStr(data, _M.LinkType.LinkTypeTeamMsg)
end

function _M.GetNameXml(s2c_name, s2c_pro)
    return "<f color='" .. string.format("%08X",  GameUtil.RGBA_To_ARGB(_M.PorColor["PorColor" .. s2c_pro])) .. "'>" .. s2c_name .. "</f>"
end

function _M.GetPrivateChatTitle(data)
    
    if data ~= nil then
        local datastr = Util.GetText(TextConfig.Type.CHAT, 'say')
        local sdata = {}
        local msgData = {}
        msgData.s2c_playerId = data.playerId
        msgData.s2c_name = data.name
        msgData.s2c_level = data.lv
        msgData.MsgType = _M.LinkType.LinkTypePerson
        if data.pro == nil then
            msgData.s2c_pro = 1
        else
            msgData.s2c_pro = data.pro
        end
        sdata[1] = _M.PersonMsgDeal(msgData, msgData.s2c_name, GameUtil.RGBA_To_ARGB(_M.PorColor["PorColor" .. msgData.s2c_pro]))
        datastr = _M.HandleString(datastr, sdata)
        return datastr
    else
        return ""
    end
end

function _M.GetAtChatTitle(data)
    
    if data ~= nil then
        
        local datastr = Util.GetText(TextConfig.Type.CHAT, 'char')
        local sdata = {}
        local msgData = {}
        msgData.s2c_playerId = data.playerId
        msgData.s2c_name = data.name
        msgData.s2c_level = data.lv
        msgData.MsgType = _M.LinkType.LinkTypePerson
        if data.pro == nil then
            msgData.s2c_pro = 1
        else
            msgData.s2c_pro = data.pro
        end
        sdata[1] = _M.PersonMsgDeal(msgData, msgData.s2c_name, GameUtil.RGBA_To_ARGB(_M.PorColor["PorColor" .. msgData.s2c_pro]))
        datastr = _M.HandleString(datastr, sdata)
        return datastr
    else
        return ""
    end
end

function _M.AddMapMsg(data)
    
    return _M.MsgConvertToStr(data, _M.LinkType.LinkTypeMapMsg)
end

function _M.HandleChatClientDecode(msg, strColor, title, strokeColor, fontSize, isMyContent)
    
    if strColor == nil then
        strColor = 0x000000ff
    end
    if strokeColor == nil then
        strokeColor = 0x0e0e0eff
    end
    
    if fontSize == nil then
        fontSize = 20
    end
    local linkdata = AttributedString.New()
    if title ~= nil then
        for i = 1, #title do
            linkdata:Append(title[i])
        end
    end

    local retArray = split(msg, "|")
    
    
    for i, ement in ipairs(retArray) do
        local item = ement
        local temptext = ""
        local abs = AttributedString.New()
        if _M.StartsWith(item, "<q ") and _M.EndsWith(item, "></q>") then
            local itemData = UIChatDynamicScrollPan.createTextAttribute(strColor,fontSize)
            temptext = "a"
            local msg = cjson.decode(ChatModel.GetContent(item))
            if msg.index < 10 then
                itemData.resSprite = "/dynamic_n/ui_chat/emotion/output/emotion.xml,e0" .. msg.index
            else
                itemData.resSprite = "/dynamic_n/ui_chat/emotion/output/emotion.xml,e" .. msg.index
            end
            abs:Append(temptext, itemData);
        elseif _M.StartsWith(item, "<a ") and _M.EndsWith(item, "></a>") then
            local itemData = UIChatDynamicScrollPan.createTextAttribute(strColor,fontSize)
            local curcontent = ChatModel.GetContent(item)
            local msg = cjson.decode(curcontent)
            
            if msg.MsgType == 1 then               
                temptext = msg.Name
                itemData.fontColor = Util.GetQualityColorRGBA(msg.Quality)
                itemData.borderColor = strokeColor
                itemData.fontStyle = FontStyle.STYLE_UNDERLINED
                itemData.borderCount = TextBorderCount.Border
            elseif msg.MsgType == 3 then          
                
                temptext = msg.s2c_name
                itemData.fontColor = _M.PorColor["PorColor" .. msg.s2c_pro]
                
                itemData.borderColor = strokeColor
                itemData.borderCount = TextBorderCount.Border
                itemData.fontStyle = FontStyle.STYLE_UNDERLINED
                
            end
            
            itemData.link = curcontent
            abs:Append(temptext, itemData);
        elseif _M.StartsWith(item, "<v ") and _M.EndsWith(item, "></v>") then
            local itemData = UIChatDynamicScrollPan.createTextAttribute(strColor,fontSize)
            local curcontent = ChatModel.GetContent(item)
            local msg = cjson.decode(curcontent)
            local viocetext = "v"
            local vioceabs = AttributedString.New()
            local vioceItemData = UIChatDynamicScrollPan.createTextAttribute(strColor,fontSize)
            vioceItemData.resImage = "#dynamic_n/chat/chat.xml,chat,18"
            local iz = ImageZoom.New()
            vioceItemData.resImageZoom = iz.FromString("14,22")
            
            
            vioceItemData.link = curcontent
            vioceabs:Append(viocetext, vioceItemData)
            linkdata:Append(vioceabs)

            temptext = msg.AsrResult
            itemData.fontColor = strColor
            abs:Append(temptext, itemData);

            if not isMyContent then
                local isAuto = UnityEngine.PlayerPrefs.GetInt("UI.ChatMainSecond.AutoPlayVoice", 0)
                if isAuto ~= 0 then
                    table.insert(_M.VoiceAutoPlayList, {voicedata=msg})
                end
            end
            
        elseif _M.StartsWith(item, "<battle ") and _M.EndsWith(item, "></battle>") then
            local itemData = UIChatDynamicScrollPan.createTextAttribute(strColor,fontSize)
            local curcontent = ChatModel.GetContent(item,"battle")
            local msg = cjson.decode(curcontent)

            temptext = msg.Str
            itemData.fontColor = GameUtil.RGBA_To_ARGB(0xff00a0ff)
            itemData.borderColor = strokeColor
            itemData.fontStyle = FontStyle.STYLE_UNDERLINED
            itemData.borderCount = TextBorderCount.Border

            itemData.link = curcontent
            abs:Append(temptext, itemData);

            
            
            
            
            
        else
            local color = GameUtil.RGBA_To_ARGB(strColor)
            local curdata1 = UIChatDynamicScrollPan.HtmlTextToAttributedString("<font size= '" .. fontSize .. "' color='" .. string.format("%08X", color) .. "'>" .. item .. "</font>")
            if curdata1 == nil then
                curdata1 = UIChatDynamicScrollPan.HtmlTextToAttributedString("<font size= '" .. fontSize .. "' color='" .. string.format("%08X", color) .. "'>" .. "error" .. "</font>")
            end
            if curdata1 ~= nil then
                abs:Append(curdata1)
            end
            
        end
        
        linkdata:Append(abs)
    end
    return linkdata
end

function _M.DeleteLinkData(msg)
    
    
    local linkdata = ""
    local retArray = split(msg, "|")
    
    
    for i, ement in ipairs(retArray) do
        local item = ement
        local temptext = ""
        local abs = AttributedString.New()
        if _M.StartsWith(item, "<q ") and _M.EndsWith(item, "></q>") then
            linkdata = linkdata .. "|" .. item .. "|"
        elseif _M.StartsWith(item, "<a ") and _M.EndsWith(item, "></a>") then
            local curcontent = ChatModel.GetContent(item)
            local msg = cjson.decode(curcontent)
            
            if msg.MsgType == 1 then               
                linkdata = linkdata .. msg.Name
            elseif msg.MsgType == 3 then          
                linkdata = linkdata .. msg.s2c_name
            end
        elseif _M.StartsWith(item, "<v ") and _M.EndsWith(item, "></v>") then
            linkdata = linkdata ..  "|" .. item .. "|"
        else
            local curdata1 = UIChatDynamicScrollPan.HtmlTextToAttributedString("<font size= '20'>" .. item .. "</font>")
            if curdata1 == nil then
                curdata1 = UIChatDynamicScrollPan.HtmlTextToAttributedString("<font size= '20'>" .. "error" .. "</font>")
            end
            if curdata1 ~= nil then
                linkdata = linkdata .. curdata1:ToString()
            end
        end
    end
    
    return linkdata
end

function _M.HandleOriginalToInput(msg)
    
    local retArray = split(msg, "|")
    _M.m_StrTemp = {}
    local str = ""
    for i, ement in ipairs(retArray) do
        local item = ement
        if (_M.StartsWith(item, "<q ") and _M.EndsWith(item, "></q>")) 
            or (_M.StartsWith(item, "<a ") and _M.EndsWith(item, "></a>")) then
            str = str .. "|" .. i .. "|"
            _M.m_StrTemp[i] = item
            i = i + 1
        else
            local startpos = string.find(item, "<f")
            local endpos = string.find(item, "</f>")
            local endpos2 = string.find(item, "</font>")
            if startpos and (endpos or endpos2) then
                str = str .. "|" .. i .. "|"
                _M.m_StrTemp[i] = item
                i = i + 1
            else
                str = str .. item
            end
        end
    end
    return str
end

function _M.HandleInputToOriginal(msg)
    
    local retArray = split(msg, "|")
    
    
    
    local str = ""
    for i, ement in ipairs(retArray) do
        local item = tonumber(ement)
        
        if (_M.m_StrTemp ~= nil and _M.m_StrTemp[item] ~= nil) then
            str = str .. "|" .. _M.m_StrTemp[item] .. "|"
        else
            str = str .. ement
        end
    end
    
    return str
end

function _M.HandleActionMsg(msg, dest1, dest2)
    
    local retArray = split(msg, "|")
    _M.m_StrTemp = {}
    local str = ""
    for i, ement in ipairs(retArray) do
        local item = tonumber(ement)
        if item == 1 then
            if dest1 ~= nil then
                str = str .. dest1
            end
        elseif item == 2 then
            if dest2 ~= nil then
                str = str .. dest2
            end
        else
            str = str ..ement
        end
    end
    return str
end

function _M.HandleString(msg, dest)
    
    local retArray = split(msg, "|")
    _M.m_StrTemp = {}
    local str = ""
    for i, ement in ipairs(retArray) do
        local item = tonumber(ement)
        if item ~= nil then
            if dest[item] ~= nil then
                str = str .. dest[item]
            end
        else
            str = str ..ement
        end
    end
    return str
end

function  _M.DownloadAndPlayVoice( isVoice )
    if _M.isVoicePlaying then
        return
    end

    _M.isVoicePlaying = true
    _M.isVoiceData = isVoice

    if FileSave.isFileExist(FileSave.voiceLocalFilePath .. isVoice.filepath) then
        _M.PlayTencentVioce(FileSave.voiceLocalFilePath .. isVoice.filepath)
    else
        
        
        
        
        _M.voiceCallBackstatus = FileSave.Voiceengine:DownloadRecordedFile(isVoice.fileid, FileSave.voiceLocalFilePath .. isVoice.filepath, 60000)
  
        FileSave.Voiceengine.OnDownloadRecordFileComplete = function(code, filepath, fileid)
            
            _M.voiceCallBackstatus = nil
            if code == gcloud_voice.IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
                _M.PlayTencentVioce(filepath, fileid)
            else
                _M.isVoicePlaying = false
                _M.isVoiceData = nil
            end
        end
    end
end

function _M.StopVoice()
    FileSave.Voiceengine:StopPlayFile()
    _M.waitStopVoice = _M.isVoiceData
    _M.isVoicePlaying = false
end

function _M.StopVoice(newVoice)
    if _M.isVoiceData ~= newVoice then
        FileSave.Voiceengine:StopPlayFile()
        _M.waitStopVoice = _M.isVoiceData
        _M.isVoicePlaying = false
    end
end

function _M.PlayTencentVioce(filepath, fileid)

    _M.isVoicePlaying = true

    BGMVolume = XmdsSoundManager.GetXmdsInstance():GetBGMVolume()
    EffectVolume = XmdsSoundManager.GetXmdsInstance():GetEffectVolume()

    XmdsSoundManager.GetXmdsInstance():SetBGMVolume(BGMVolume*0.2)
    XmdsSoundManager.GetXmdsInstance():SetEffectVolume(EffectVolume*0.2)

    _M.voiceCallBackstatus = FileSave.Voiceengine:PlayRecordedFile(filepath)
    if _M.voiceCallBackstatus == 0 then
        FileSave.Voiceengine.OnPlayRecordFilComplete = function(code, filepath)
            

            if _M.waitStopVoice ~= nil then
                fileid = _M.waitStopVoice.fileid
                _M.waitStopVoice = nil

                if _M.isVoiceData == nil or _M.isVoiceData == _M.waitStopVoice then 
                    XmdsSoundManager.GetXmdsInstance():SetBGMVolume(BGMVolume)
                    XmdsSoundManager.GetXmdsInstance():SetEffectVolume(EffectVolume)
                    _M.isVoiceData = nil
                    _M.isVoicePlaying = false

                    if code == gcloud_voice.IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_PLAYFILE_DONE then
                        if _M.ChatMainSecond ~= nil then
                            _M.ChatMainSecond.OnVoicePlayEnd(fileid)
                        end
                    end

                end
            else
                if _M.isVoiceData ~= nil then
                    fileid = _M.isVoiceData.fileid
                end
                XmdsSoundManager.GetXmdsInstance():SetBGMVolume(BGMVolume)
                XmdsSoundManager.GetXmdsInstance():SetEffectVolume(EffectVolume)
                _M.isVoiceData = nil
                _M.isVoicePlaying = false

                if code == gcloud_voice.IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_PLAYFILE_DONE then
                    if _M.ChatMainSecond ~= nil then
                        _M.ChatMainSecond.OnVoicePlayEnd(fileid)
                    end
                end

            end

            _M.voiceCallBackstatus = nil

        end
    else
        _M.isVoicePlaying = false
        _M.isVoiceData = nil
        XmdsSoundManager.GetXmdsInstance():SetBGMVolume(BGMVolume)
        XmdsSoundManager.GetXmdsInstance():SetEffectVolume(EffectVolume)
    end
end

function  _M.AutoPlayVoice()
    if _M.isVoicePlaying then
        return
    end

    if #_M.VoiceAutoPlayList > 0 then
        _M.DownloadAndPlayVoice(_M.VoiceAutoPlayList[1].voicedata)

        if _M.ChatMainSecond ~= nil then
                _M.ChatMainSecond.OnVoiceAutoPlayBegin(_M.VoiceAutoPlayList[1].voicedata.fileid)
        end

        table.remove(_M.VoiceAutoPlayList, 1)
    end
end

function _M.HandleChatMsg(param, fontSize)

    
    if fontSize == nil then
        fontSize = 18
    end
    local title = Util.GetText(TextConfig.Type.CHAT, 'channel' .. param.s2c_scope)
    
    
    
    
    local datalist = {}
    local abs = AttributedString.New()
    local itemData = UIChatDynamicScrollPan.createTextAttribute(0,fontSize)
    
    itemData.fontColor = _M.chatcolor["tbt_channel" .. param.s2c_scope]
    itemData.borderColor = _M.chatcolor["tbt_stroke" .. param.s2c_scope]
    itemData.borderCount = TextBorderCount.Shadow_R_B
    abs:Append(title, itemData);
    local abs1 = AttributedString.New()
    local itemData1 = UIChatDynamicScrollPan.createTextAttribute(0,fontSize)
    if param.s2c_sys == 1 or param.serverData.s2c_funtype == 4 or param.serverData.s2c_name == nil or param.serverData.s2c_name == "" then
        title = ""
    else
        if param.serverData.s2c_AnonymousState ~= nil then 
            title = string.gsub(Util.GetText(TextConfig.Type.CHAT, 'anonymous'), "[<f>-</f>]", "") .. ":"
        else
            title = param.serverData.s2c_name .. ":"
        end
    end
    
    if param.serverData.s2c_pro ~= nil and param.serverData.s2c_pro > 0 and param.serverData.s2c_pro < 6 then
        if param.serverData.s2c_AnonymousState ~= nil then 
            itemData1.fontColor = 0xffffffff
        else
            itemData1.fontColor = _M.PorColor["PorColor" .. param.serverData.s2c_pro]
        end
    else
        itemData1.fontColor = _M.chatcolor["play_name"]
    end
    itemData1.borderColor = _M.chatcolor["play_stroke"]
    itemData1.borderCount = TextBorderCount.Shadow_R_B
    abs1:Append(title, itemData1);
    datalist[1] = abs
    datalist[2] = abs1

    local isMyContent = false
    if param.s2c_playerId == DataMgr.Instance.UserData.RoleID then
        isMyContent = true
    else
        local isAuto = UnityEngine.PlayerPrefs.GetInt("UI.ChatMainSecond.AutoPlayVoice", 0)
        if isAuto ~= 0 then 
            param.isRead = true
        end
    end

    local data 
    
    if param.s2c_sys == 1 then          
        data = _M.HandleChatClientDecode(param.serverData.s2c_titleMsg .. param.s2c_content, _M.GetDefaultSysColor(), datalist,  _M.GetDefaultSysColor(), fontSize, isMyContent)
    else
        if param.serverData ~= nil then
            if param.serverData.s2c_AnonymousState ~= nil then  
                data = _M.HandleChatClientDecode(param.serverData.s2c_titleMsg .. param.s2c_content, GameUtil.CovertHexStringToRGBA(ChatModel.mSettingItems[param.s2c_scope].FontColor), datalist, _M.chatcolor["hudcontentstroke"], fontSize, isMyContent)
            else
                data = _M.HandleChatClientDecode(param.serverData.s2c_titleMsg .. param.s2c_content, param.serverData.s2c_color, datalist, _M.chatcolor["hudcontentstroke"], fontSize, isMyContent)
            end
        else
            data = _M.HandleChatClientDecode(param.serverData.s2c_titleMsg .. param.s2c_content, _M.chatcolor["hudcontent"], datalist, _M.chatcolor["hudcontentstroke"], fontSize, isMyContent)
        end
        
    end
    return data
end

function _M.MadeNodeFullScreen(node)
    
    local root = XmdsUISystem.Instance.RootRect
    local scale = root.width > XmdsUISystem.SCREEN_WIDTH and root.width / XmdsUISystem.SCREEN_WIDTH or root.height / XmdsUISystem.SCREEN_HEIGHT
            
    local mMaskW = node.Width * scale;
    local mMaskH = node.Height * scale;

    local mMaskOffsetX = (XmdsUISystem.SCREEN_WIDTH - mMaskW) * 0.5
    local mMaskOffsetY = (XmdsUISystem.SCREEN_HEIGHT - mMaskH) * 0.5

    node.Position2D = Vector2.New(mMaskOffsetX, mMaskOffsetY);
    node.Size2D = Vector2.New(mMaskW, mMaskH)
end

function _M.GetOneLineXml(node, xmlstr)
	
	node:RemoveAllChildren(true)
	local textPan = HZTextBox.New();
    
    
  
    local canvas = HZCanvas.New()
    canvas.Size2D = node.Size2D
    canvas.X = 0
    canvas.Layout = XmdsUISystem.CreateLayoutFromFile("static_n/img_black.png", LayoutStyle.IMAGE_STYLE_ALL_9, 8)
    local mask = canvas.UnityObject:AddComponent(typeof(UnityEngine.UI.Mask))
    mask.showMaskGraphic = false

    textPan.Width = node.Width
    textPan.Height = 100
    
    textPan.XmlText = "<f size = '22'>" .. xmlstr .. "</f>"
    textPan.X = 0
    
    if textPan.TextComponent.RichTextLayer.ContentHeight > canvas.Height then
    	textPan.Width = node.Width - 30
    	local textPan2 = HZTextBox.New();
    	textPan2.Width = node.Width - 20
    	textPan2.Height = 100
    	textPan2.XmlText = "<f size = '22'>... </f>"
    	textPan2.X = textPan.TextComponent.RichTextLayer.ContentWidth
    	canvas:AddChild(textPan2)
    	
    	
    end
    canvas:AddChild(textPan)
    node:AddChild(canvas)
end

function _M.GetVipChatNameLink(data)
    local namelink
    if data.serverData.s2c_AnonymousState ~= nil then
        namelink = UIChatDynamicScrollPan.HtmlTextToAttributedString(Util.GetText(TextConfig.Type.CHAT, 'anonymous'))
    else
        local vipstr = ""
        if data.serverData.s2c_vip > 0 then
            vipstr = "<f>" .. Util.GetText(TextConfig.Type.CHAT, 'guibin') .. data.serverData.s2c_vip .. " </f>"
        end
        namelink = UIChatDynamicScrollPan.HtmlTextToAttributedString("<f>" .. vipstr .. "<f color='" .. string.format("%08X",  GameUtil.RGBA_To_ARGB(_M.PorColor["PorColor" .. data.serverData.s2c_pro])) .. "'>" .. data.serverData.s2c_name .. "</f></f>")
        if namelink == nil then
            namelink = UIChatDynamicScrollPan.HtmlTextToAttributedString("<f>" .. vipstr .. "<f color='" .. string.format("%08X",  GameUtil.RGBA_To_ARGB(_M.PorColor["PorColor" .. data.serverData.s2c_pro])) .. "'>" .. "error" .. "</f></f>")
        end
    end
    return namelink
end

function _M.GetChatNameLink(data)
    local namelink
    if data.serverData.s2c_AnonymousState ~= nil then
        namelink = UIChatDynamicScrollPan.HtmlTextToAttributedString(Util.GetText(TextConfig.Type.CHAT, 'anonymous'))
    else
        local vipstr = ""
        
        
        
        namelink = UIChatDynamicScrollPan.HtmlTextToAttributedString("<f>" .. vipstr .. "<f color='" .. string.format("%08X",  GameUtil.RGBA_To_ARGB(_M.PorColor["PorColor" .. data.serverData.s2c_pro])) .. "'>" .. data.serverData.s2c_name .. "</f></f>")
        if namelink == nil then
            namelink = UIChatDynamicScrollPan.HtmlTextToAttributedString("<f>" .. vipstr .. "<f color='" .. string.format("%08X",  GameUtil.RGBA_To_ARGB(_M.PorColor["PorColor" .. data.serverData.s2c_pro])) .. "'>" .. "error" .. "</f></f>")
        end
    end
    return namelink
end

local function GetTeamData()
    
    local findLead = {}
    local data = Util.List2Luatable(DataMgr.Instance.TeamData.TeamList)
    if DataMgr.Instance.TeamData:IsLeader() then
        findLead.s2c_name = Util.GetText(TextConfig.Type.CHAT, 'all') .. " "
        return findLead
    else
        for i = 1, #data do
            
            if data[i].isLeader == 1 then
                if data[i].id == DataMgr.Instance.UserData.RoleID then
                    findLead.s2c_name = Util.GetText(TextConfig.Type.CHAT, 'all') .. " "
                else
                    findLead.serverData = {}
                    findLead.serverData.s2c_name = data[i].name
                    findLead.serverData.s2c_pro = data[i].pro
                    findLead.serverData.s2c_level = data[i].level
                    findLead.s2c_playerId = data[i].id
                end
                return findLead
            end
        end
    end
    return nil
end

function _M.DealTeamData(datalist)
    local teamdata = GetTeamData()
    if teamdata ~= nil then
        local find = false
        if teamdata.serverData ~= nil then
            for i = 1, #datalist do
                if datalist[i].s2c_playerId == teamdata.s2c_playerId then
                    find = true
                end
                if find then
                    datalist[i] = datalist[i + 1]
                end
            end
        end
        datalist[#datalist + 1] = teamdata
    end
    return datalist
end

function _M.DealUnionData(datalist)
    
    local teamdata = _M.UnionData
    if teamdata ~= nil then
        local find = false
        if teamdata.serverData ~= nil then
            for i = 1, #datalist do
                if datalist[i].s2c_playerId == teamdata.s2c_playerId then
                    find = true
                end
                if find then
                    datalist[i] = datalist[i + 1]
                end
            end
        end
        datalist[#datalist + 1] = teamdata
    end
    return datalist
end

function _M.AddNewPrivateRole(data, typeindex)
    
    
    local newRoleid = true
    for i = 1, #_M.PrivateList do
        if typeindex ~= nil and typeindex == 1 then
            if _M.PrivateList[i].s2c_playerId == data.s2c_playerId then
                newRoleid = false
            end
        else
            if _M.PrivateList[i].s2c_playerId == data.playerId then
                newRoleid = false
            end
        end
    end
    if newRoleid then
        local todata = {}
        if typeindex ~= nil and typeindex == 1 then
            todata = data
        else
            todata.serverData = {}
            todata.serverData.s2c_name = data.name
            todata.serverData.s2c_pro = (data.pro == nil) and 1 or data.pro
            todata.serverData.s2c_level = (data.pro == nil) and 1 or data.pro
            todata.s2c_playerId = data.playerId
        end
        if #_M.PrivateList < 5 then
            _M.PrivateList[#_M.PrivateList + 1] = todata
        else
            for i = 1, 4 do
                _M.PrivateList[i] = _M.PrivateList[i + 1]
            end
            _M.PrivateList[5] = todata
        end
    end
    return newRoleid
end

function _M.DealPrivateData(datalist)
    
    
    
    
    for i = 1, #datalist do
        _M.AddNewPrivateRole(datalist[i], 1)
    end
    return _M.PrivateList
end

function _M.ShowPosInfo(index)
    
    local datastr = Util.GetText(TextConfig.Type.CHAT, 'i_here')
    local pos = DataMgr.Instance.UserData.Position
    local sdata = {}
    local msgData = {}
    msgData.areaId = DataMgr.Instance.UserData.SceneId
    msgData.mapId = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.MAPID)
    msgData.instanceId = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.INSTANCEID)
    msgData.targetX = math.floor(pos.x)
    msgData.targetY = math.floor(pos.y)

    sdata[1] = _M.AddMapMsg(msgData)
    sdata[2] = DataMgr.Instance.UserData.SceneName .. "(" .. msgData.targetX .. "," .. msgData.targetY .. ")"
    
    datastr = _M.HandleString(datastr, sdata)
    return datastr
end





















return _M
