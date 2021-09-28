local _M = {}
_M.__index = _M


local ChatModel = require 'Zeus.Model.Chat'
local Util      = require "Zeus.Logic.Util"
local cjson     = require "cjson"
local ChatUtil  = require "Zeus.UI.Chat.ChatUtil"
local ChatSend  = require "Zeus.UI.Chat.ChatSend"
local FriendModel           = require 'Zeus.Model.Friend'
local ChatUIDealLink        = require "Zeus.UI.Chat.ChatUIDealLink"

local self = {
    m_Root = nil,
    curIndex = nil,
}

_M._channelName = {"tbt_world","tbt_guild","tbt_team","tbt_pm","tbt_cross","tbt_near", "tbt_system"}
local TalkWidth = 305
local TalkHight = 60
local EachPageNum = 20

local function ClearNode(node)
    
    node.event_PointerUp = nil
    node.TouchClick = nil
    node.event_PointerDown  = nil
    node:RemoveChildren(0, -1, true)
end

local function NormalMsgCell(tb_talk, node, data, ismyselfcontent, canvas)
    
    local offsetX = 0
    local offsetY = 0
    local text = nil
    local curWidth = 0
    text = HZRichTextPan.New();
    text.RichTextLayer.UseBitmapFont = true

    if data.s2c_sys == 2 then
        if ismyselfcontent == false then
            offsetX = 30
        else
            offsetX = 40
        end
        offsetY = 5
        text.Y = 15
        curWidth = TalkWidth - 80
    else
        text.Y = 5
        curWidth = TalkWidth - 40
    end
    
    if ismyselfcontent == false then
        text.X = 26 + offsetX
    else
        text.X = 20
    end
    text.Size2D     = Vector2.New(curWidth, 200)
    text.TextPan.Width = curWidth
    text.RichTextLayer:SetWidth(curWidth)
    text.RichTextLayer:SetEnableMultiline(true)
    
    tb_talk:AddChild(text);
    if data.linkdata == nil then
        if ismyselfcontent == false and self.m_curChannel == ChatModel.ChannelState.Channel_private then
            data.serverData.s2c_titleMsg = ChatUtil.GetNameXml(data.serverData.s2c_name, data.serverData.s2c_pro) .. Util.GetText(TextConfig.Type.CHAT, 'saytoyou')
        end
        if data.serverData.s2c_AnonymousState ~= nil then
            local color = GameUtil.CovertHexStringToRGBA(ChatModel.mSettingItems[self.m_curChannel].FontColor)
            
            data.linkdata = ChatUtil.HandleChatClientDecode(data.serverData.s2c_titleMsg .. data.s2c_content, color)
        else
            data.linkdata = ChatUtil.HandleChatClientDecode(data.serverData.s2c_titleMsg .. data.s2c_content, data.serverData.s2c_color)
        end
    end
    if data.linkdata ~= nil then
        text.RichTextLayer:SetString(data.linkdata)
    end
    
    tb_talk.IsInteractive = true
    tb_talk.Enable = true
    tb_talk.EnableChildren = true
    tb_talk.event_PointerDown = function (displayNode, pos)
        self.pressTime = System.DateTime.Now 
        self.pressData = data
        self.pressPos = pos
    end

    tb_talk.event_PointerUp = function (displayNode, pos)
        if self.pressTime ~= nil and math.floor((System.DateTime.Now - self.pressTime).TotalSeconds) > 0.8 
            and data.s2c_playerId ~= DataMgr.Instance.UserData.RoleID then
            
            









        else
            if not self.scroll_pan.Scroll.IsDragging then
                local point
                if data.serverData.s2c_funtype == 3 then
                    point = Vector2.New(30, 30)
                else
                    point = text:ScreenToLocalPoint2D(pos)
                end
                local info = UIChatDynamicScrollPan.Click(point.x, point.y, text.RichTextLayer)
                if info.mRegion  ~= nil and info.mRegion.Attribute ~= nil then
                    ChatUIDealLink.HandleOnLinkClick(info.mRegion.Attribute.link, info, text, displayNode, data.s2c_playerId, pos, self)
                end
            end
        end
        self.pressTime = nil
        self.pressData = nil
    end

    local height = text.RichTextLayer.ContentHeight
    if height < 30 then
        height = 30
    end

    if text.RichTextLayer.ContentWidth + 15 > curWidth then 
        tb_talk.Size2D = Vector2.New(TalkWidth, height + offsetY + 30)
        node.Height = self.nodeHight + height - TalkHight + offsetY
            
        if ismyselfcontent then   
            if data.s2c_sys == 2 then
                tb_talk.X = self.nodeWidth - TalkWidth - 15
                text.X = 20 + offsetX
            else
                tb_talk.X = self.nodeWidth - TalkWidth
                text.X = 15
            end
        end
    else                                            
        local length = text.RichTextLayer.ContentWidth + 30 + offsetX 
        
        if length < 100 then
            length = 100
        end

        tb_talk.Size2D = Vector2.New(length + 15, height + offsetY + 30)
        node.Height = self.nodeHight + height - TalkHight + offsetY
        
        if ismyselfcontent then
            if data.s2c_sys == 2 then
                tb_talk.X = self.nodeWidth - length - 30
                text.X = length - text.RichTextLayer.ContentWidth - 20 + 15
            else
                tb_talk.X = self.nodeWidth - length - 15
                text.X = length - text.RichTextLayer.ContentWidth - 20 + offsetX
            end
            
        end
    end
end

local function initFanyiInfo(lb_fanyi, cvs_fanyi, data, vioceData, ismyselfcontent)
    
    
    if vioceData.AsrResult ~= nil then
        lb_fanyi.Visible = false
        local fanyirich = HZRichTextPan.New();
        fanyirich.RichTextLayer.UseBitmapFont = true
        fanyirich.RichTextLayer:SetEnableMultiline(true)
        fanyirich.Width = cvs_fanyi.Width - 20
        fanyirich.TextPan.Width = cvs_fanyi.Width - 20
        fanyirich.RichTextLayer:SetWidth(fanyirich.TextPan.Width)
        cvs_fanyi:AddChild(fanyirich)
        data.showFanyi = true
        fanyirich.RichTextLayer:SetString(UIChatDynamicScrollPan.HtmlTextToAttributedString("<font size= '20'>" .. vioceData.AsrResult .. "</font>"))
        if ismyselfcontent then
            fanyirich.X = cvs_fanyi.Width - fanyirich.RichTextLayer.ContentWidth
        else
            fanyirich.X = 0
        end
        cvs_fanyi.Height = fanyirich.RichTextLayer.ContentHeight
    else
        data.showFanyi = true
        lb_fanyi.Visible = true
    end
end

local function ClearLastVoice()
    
    if self.m_Selib_basicsound ~= nil then
        self.m_Selib_basicsound.Visible = true
        self.m_Selib_basicsound = nil
        
    end
    if self.m_Selib_sound ~= nil then
        self.m_Selib_sound.Visible = false
        self.m_Selib_sound = nil
        
    end
    self.localUSpeakSender:stopAllSpeaks()
end

local function VoiceMsgCell(tb_talk, node, data, ismyselfcontent, isVoice)
    
    local voiceWidth = 290
    local text = nil
    text = HudManagerU.Instance.CreateHudUIFromFile("xmds_ui/chat/chat_sound.gui.xml")
    text.IsInteractive = true
    text.Enable = false
    text.EnableChildren = true
    text.Y = -5
    tb_talk:AddChild(text);
    tb_talk.Size2D = Vector2.New(voiceWidth, 60)
    local lb_soundtime
    local ib_red
    local ib_sound
    local cvs_sound
    local ib_basicsound
    cvs_sound = text:FindChildByEditName("cvs_sound", true)
    cvs_sound.X = -32
    cvs_sound.Visible = true
    lb_soundtime = cvs_sound:FindChildByEditName("lb_soundtime", true)
    ib_red = cvs_sound:FindChildByEditName("ib_red", true)
    ib_sound = cvs_sound:FindChildByEditName("ib_sound", true)
    ib_basicsound = cvs_sound:FindChildByEditName("ib_basicsound", true)
    cvs_sound.Enable = true
    local cvs_fanyi = text:FindChildByEditName("cvs_fanyi", true)
    local lb_fanyi = text:FindChildByEditName("lb_fanyi", true)
    local tbt_change = text:FindChildByEditName("tbt_change", true)
    
    if ismyselfcontent then
        tb_talk.X = self.nodeWidth - tb_talk.Width - 14
        lb_fanyi.X = cvs_fanyi.Width - lb_fanyi.Width
        cvs_fanyi.X = voiceWidth - cvs_fanyi.Width
    else
        tb_talk.X = 95
        lb_fanyi.X = 0
        cvs_fanyi.X = 0
    end

     if data.isRead == nil then
        ib_red.Visible = true
    else
        ib_red.Visible = false
    end
    

    lb_soundtime.Text = isVoice.Time .. "s"
    ib_basicsound.Visible = true
    ib_sound.Visible = false
        
    tb_talk.IsInteractive = true
    tb_talk.Enable = true
    tb_talk.EnableChildren = true

    if data.showFanyi ~= nil and data.showFanyi == true then
        initFanyiInfo(lb_fanyi, cvs_fanyi, data, isVoice, ismyselfcontent)
        tbt_change.IsChecked = true
        cvs_fanyi.Visible = true
        node.Height = self.nodeHight - 30 + cvs_fanyi.Height
    else
        tbt_change.IsChecked = false
        node.Height = self.nodeHight - 30
        cvs_fanyi.Visible = false
    end

    tbt_change.TouchClick = function(displayNode)
        if  tbt_change.IsChecked then
            data.showFanyi = true
        else
            data.showFanyi = false
        end
        if data.showFanyi ~= nil and data.showFanyi == true then
            initFanyiInfo(lb_fanyi, cvs_fanyi, data, isVoice, ismyselfcontent)
            cvs_fanyi.Visible = true
            node.Height = self.nodeHight - 30 + cvs_fanyi.Height
        else
            node.Height = self.nodeHight - 30
            cvs_fanyi.Visible = false
        end
    end

    cvs_sound.TouchClick = function (displayNode, pos)
        if self.pressTime ~= nil and math.floor((System.DateTime.Now - self.pressTime).TotalSeconds) > 0.8 then
            
            









        else
            ClearLastVoice()
            
            data.isRead = true
            ib_basicsound.Visible = false
            ib_sound.Visible = true
            ib_red.Visible = false
            self.m_Selib_basicsound = ib_basicsound
            self.m_Selib_sound = ib_sound
            self.m_SelVoiceTime = isVoice.Time
            if FileSave.isFileExist(FileSave.voiceLocalFilePath .. isVoice.filepath) then
                ChatSend.PlayTencentVioce(FileSave.voiceLocalFilePath .. isVoice.filepath, self)
            else
                
                
                
                FileSave.Voiceengine:SetMode(gcloud_voice.GCloudVoiceMode.Messages)
                self.voiceCallBackstatus = FileSave.Voiceengine:DownloadRecordedFile(isVoice.fileid, FileSave.voiceLocalFilePath .. isVoice.filepath, 60000)
                FileSave.Voiceengine.OnDownloadRecordFileComplete = function(code, filepath, fileid)
                    
                    self.voiceCallBackstatus = nil
                    if code == gcloud_voice.IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
                        ChatSend.PlayTencentVioce(filepath, self)
                    end
                end
            end
            
        end
    end
end

local function SystemMsgCell(node, data)
    
    local text = nil
    local tb_talk = node:FindChildByEditName("cvs_talk2", true)
    ClearNode(tb_talk)
    text = HZRichTextPan.New();
    text.RichTextLayer.UseBitmapFont = true
    text.Size2D     = Vector2.New(tb_talk.Width, 200)
    text.TextPan.Width = tb_talk.Width - 10
    text.RichTextLayer:SetWidth(text.TextPan.Width)

    text.RichTextLayer:SetEnableMultiline(true)
    
    tb_talk:AddChild(text);
    if data.linkdata == nil then
        
        data.linkdata = ChatUtil.HandleChatClientDecode(data.serverData.s2c_titleMsg .. data.s2c_content, ChatUtil.GetDefaultSysColor())
    end

    text.RichTextLayer:SetString(data.linkdata)
    
    
        node.Height = text.RichTextLayer.ContentHeight
    
    
    
    data.NodeHight = node.Height

    tb_talk.event_PointerDown = function (displayNode, pos)
        self.pressPos = pos
    end

    tb_talk.TouchClick = function (displayNode, pos)
        
        local point = text:ScreenToLocalPoint2D(self.pressPos)
        local info = UIChatDynamicScrollPan.Click(point.x, point.y, text.RichTextLayer)
        if info.mRegion  ~= nil and info.mRegion.Attribute ~= nil then
            ChatUIDealLink.HandleOnLinkClick(info.mRegion.Attribute.link, info, text, displayNode, data.s2c_playerId, self.pressPos, self)
        end
    end
end

local function initTalkCell(node, data)
    
    
    if data.s2c_scope == ChatModel.ChannelState.Channel_system or data.s2c_sys == 1 or (data.serverData ~= nil and data.serverData.s2c_funtype == 4) then  
        node:FindChildByEditName("cvs_talk1", true).Visible = false
        node:FindChildByEditName("cvs_talk2", true).Visible = true
        SystemMsgCell(node, data)
    else
        node:FindChildByEditName("cvs_talk1", true).Visible = true
        node:FindChildByEditName("cvs_talk2", true).Visible = false

        local tb_talk = nil
        local ismyselfcontent = false
        local canvas = nil
        
        if data.s2c_playerId == DataMgr.Instance.UserData.RoleID then
            tb_talk = node:FindChildByEditName("tb_talk1", true)
            ClearNode(tb_talk)
            if data.s2c_sys == 2 then  
                local layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/dynamic_new/chat_new/chat_new.xml|chat_new|38", LayoutStyle.IMAGE_STYLE_ALL_9, 40)
                tb_talk.Layout = layout
                canvas = HZCanvas.New()
                canvas.Size2D = Vector2.New(50, 50)
                canvas.X = 10
                canvas.Y = 10
                canvas.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/dynamic_new/chat_new/chat_new.xml|chat_new|39", LayoutStyle.IMAGE_STYLE_ALL_9, 0)

                tb_talk:AddChild(canvas)
            else
                local layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/dynamic_new/chat_new/chat_new.xml|chat_new|66", LayoutStyle.IMAGE_STYLE_ALL_9, 30)
                tb_talk.Layout = layout
            end
            node:FindChildByEditName("tb_talk", true).Visible = false
            ismyselfcontent = true
        else
            tb_talk = node:FindChildByEditName("tb_talk", true)
            ClearNode(tb_talk)
            if data.s2c_sys == 2 then
                local layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/dynamic_new/chat_new/chat_new.xml|chat_new|38", LayoutStyle.IMAGE_STYLE_ALL_9, 40)
                tb_talk.Layout = layout

                canvas = HZCanvas.New()
                canvas.Size2D = Vector2.New(50, 50)
                canvas.X = 10
                canvas.Y = 10
                canvas.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/dynamic_new/chat_new/chat_new.xml|chat_new|39", LayoutStyle.IMAGE_STYLE_ALL_9, 0)

                tb_talk:AddChild(canvas)
            else
                local layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/dynamic_new/chat_new/chat_new.xml|chat_new|67", LayoutStyle.IMAGE_STYLE_ALL_9, 30)
                tb_talk.Layout = layout
            end
            node:FindChildByEditName("tb_talk1", true).Visible = false
            ismyselfcontent = false
        end
        tb_talk.Visible = true

        if data.isVoice == nil then
            NormalMsgCell(tb_talk, node, data, ismyselfcontent, canvas)
        else
            VoiceMsgCell(tb_talk, node, data, ismyselfcontent, data.isVoice)
            local layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/dynamic_new/chat_new/chat_new.xml|chat_new|37", LayoutStyle.IMAGE_STYLE_ALL_9, 30)
            tb_talk.Layout = layout
        end

        local lb_level = node:FindChildByEditName("lb_level", true)
        if data.serverData.s2c_AnonymousState ~= nil then
            lb_level.Text = "100"
        else
            if data.serverData.s2c_level == nil or tonumber(data.serverData.s2c_level) == nil then
                lb_level.Text = "1"
            else
                lb_level.Text = data.serverData.s2c_level
            end
        end

        local lb_time = node:FindChildByEditName("lb_time", true)
        if data.s2c_time ~= nil and data.s2c_sys ~= 2 and data.isVoice == nil then
            lb_time.Text = string.sub(data.s2c_time, 11, 16)
        else
            lb_time.Text = ""
        end
        
        local tbh_character = node:FindChildByEditName("tbh_character", true)
        local namelink = ChatUtil.GetChatNameLink(data)
        if namelink ~= nil then
            tbh_character.TextComponent.RichTextLayer:SetString(namelink)
        end

        local cvs_head = node:FindChildByEditName("cvs_head", true)
        local ib_head = node:FindChildByEditName("ib_head", true)
        if data.serverData.s2c_AnonymousState ~= nil then
            Util.HZSetImage(ib_head, "static_n/hud/target/nitx.png", false)
        else
            Util.HZSetImage(ib_head, "static_n/hud/target/" .. data.serverData.s2c_pro .. ".png", false)
        end

        MenuBaseU.SetEnableUENode(node, "ib_head", true, true)
        local click_head = {node = ib_head, click = function (displayNode, pos)
            if data.serverData.s2c_AnonymousState == nil then
                ChatUIDealLink.HandleClicKPerson(displayNode, data, pos, self)
            end
        end} 
        LuaUIBinding.HZPointerEventHandler(click_head)

        if ismyselfcontent then
            cvs_head.X = self.nodeWidth
            tbh_character.X = self.nodeWidth - tbh_character.TextComponent.RichTextLayer.ContentWidth - 20    
            lb_time.X = tb_talk.X + tb_talk.Width - 95
        else
            cvs_head.X = 0
            tbh_character.X = 115
            lb_time.X = tb_talk.X + tb_talk.Width - 85
        end

        lb_time.Y = tb_talk.Height - 5
        data.NodeHight = node.Height
    end
end

local function refreshVoice()
    
    if self.pressTime ~= nil and math.floor((System.DateTime.Now - self.pressTime).TotalSeconds) > 0.8 then
        if self.pressData.s2c_playerId ~= DataMgr.Instance.UserData.RoleID then
            
            local point = self.m_Root:GetComponent("cvs_main"):ScreenToLocalPoint2D(self.pressPos)
            self.cvs_copybg.Visible = true
            self.cvs_xk.Y = point.y
            self.selectData = self.pressData
        end
    end
end

local function filldata(datalist)
    
    
    
    
    self.m_Count = 0
    local record = Util.List2Luatable(self.scroll_pan:GetRecordList())
    
    
    if datalist == nil or datalist[1] == nil or datalist[1].s2c_scope == nil then
        
        
        for i = 1, #record do
            record[i].node.Visible = false
        end
        return
    end
    
    
    
    local node = nil
    local display = nil
    
    for i = 1, #datalist do
        if i > #record then
            
            node = self.cvs_talk:Clone()
            display = ChatDisplayNode.New()
            display.IsInteractive = true
            display.Enable = true
            display.EnableChildren = true
            display:AddChild(node)
            self.scroll_pan:AddChild(display)
        else
            node = record[i].node
            display = record[i]
            display.OnInit = nil
            display.HasInitData = false 
        end

        node.Visible = true
        if datalist[i].NodeHight ~= nil then
            node.Height = datalist[i].NodeHight
        end

        display.OnInit = LuaUIBinding.InitEventHandler(function(displaynode)
        
            
            
            displaynode.HasInitData = true
            initTalkCell(displaynode.node, datalist[i])
        end)

    end
    
    
    for i = #datalist + 1, #record do
        record[i].node.Visible = false
        record[i].HasInitData = false
        record[i].OnInit = nil
    end
    self.scroll_pan:MoveContainerV()
end

local function FillOnedata(data)
    local node = nil
    local display = nil
    local record = Util.List2Luatable(self.scroll_pan:GetRecordList())
    for i = 1, #record do
        if record[i].node.Visible == false then
            display = record[i]
            display.HasInitData = false 
            display.OnInit = nil
            node = record[i].node
            break
        end
    end
    if display == nil then
    	if #record == ChatModel.RecordCount then  
    		
    		display = record[1]
    		node = record[1].node
    		self.scroll_pan:GetRecordList():RemoveAt(0)
    		display:RemoveFromParent(false)
    		self.scroll_pan:AddChild(display)
    	else
	        node = self.cvs_talk:Clone()
	        display = ChatDisplayNode.New()
	        display.IsInteractive = true
	        display.Enable = true
	        display.EnableChildren = true
	        display:AddChild(node)
	        self.scroll_pan:AddChild(display)
	    end
    end
    
        
        node.Visible = true
        display.HasInitData = true 
        initTalkCell(node, data)
    
    if self.m_Lock == true then
        
        self.scroll_pan:MoveContainerV()
    end
end

local function GetPageIndex(pageindex, datalist)
    
    
    local curdata = {}

    local curdata2 = {}
    for i = 1, EachPageNum do
        local curindex = pageindex + i
        if datalist ~= nil and (#datalist > curindex or #datalist == curindex) then
            curdata[i] = datalist[#datalist - curindex + 1]
            self.curPage = pageindex
        else
            break
        end
    end
    for i = 1, #curdata do
        curdata2[i] = curdata[#curdata - i + 1]
    end
    
    
    return curdata2
end

local function InitChannel(channel)
    
    self.m_curChannel = channel
    ChatModel.RemoveMessageData(self.m_curChannel)
    local datalist = ChatModel.ChatData[self.m_curChannel]

    
    if datalist == nil or #datalist == 0 or datalist[1].s2c_index == nil then
        ChatModel.getSaveChatMsgRequest(self.m_curChannel, 0, DataMgr.Instance.UserData.UserId, function()
            
            datalist = ChatModel.ChatData[self.m_curChannel]
            filldata(GetPageIndex(0, datalist))
        end)
    else
        if #datalist < EachPageNum and datalist[1].s2c_index ~= nil then
            ChatModel.getSaveChatMsgRequest(self.m_curChannel, datalist[1].s2c_index, DataMgr.Instance.UserData.UserId, function()
                
                datalist = ChatModel.ChatData[self.m_curChannel]
               
                filldata(GetPageIndex(0, datalist))
            end)
        else
            filldata(GetPageIndex(0, datalist))
        end
    end
    
    ChatSend.InitChannel(channel, self)
    if channel == ChatModel.ChannelState.Channel_private then
        ChatSend.SetDefaultPerson(self)
    end
end

local function OnSwitch(sender)
    for i = 1, #_M._channelName do
        if sender.EditName== _M._channelName[i] then
            self.curIndex = i
            self["ib_" .. i].Visible = false
            ChatModel.RedPoint[i].showPoint = false
            InitChannel(self.curIndex)
        end
    end
end

local function FillPreData(datalist)
    self.scroll_pan.Scroll:StopMovement()
    for i = 1, #datalist do
        local node = self.cvs_talk:Clone()
        local display = ChatDisplayNode.New()
        display.IsInteractive = true
        display.Enable = true
        display.EnableChildren = true
        display:AddChild(node)
        self.scroll_pan:AddChildAtTop(display)

        node.Visible = true
        if datalist[i].NodeHight ~= nil then
            node.Height = datalist[i].NodeHight
        end

        display.OnInit = LuaUIBinding.InitEventHandler(function(displaynode)
        
            
            
            displaynode.HasInitData = true
            initTalkCell(displaynode.node, datalist[#datalist - i + 1])
        end)

    end
end

local function OnScrollPanEnd()
    
    if self.scroll_pan.Container.Y > -1 and self.scroll_pan:GetRecordListCount() <  ChatModel.RecordCount then
        local datalist = ChatModel.ChatData[self.m_curChannel]
        
        if #datalist > self.scroll_pan:GetRecordListCount() + EachPageNum then
            FillPreData(GetPageIndex(self.scroll_pan:GetRecordListCount(), datalist))
        else
            if #datalist == 0 or datalist[1].s2c_index == nil then
                return
            end
            ChatModel.getSaveChatMsgRequest(self.m_curChannel, datalist[1].s2c_index, DataMgr.Instance.UserData.UserId, function()
                
                datalist = ChatModel.ChatData[self.m_curChannel]
                FillPreData(GetPageIndex(self.scroll_pan:GetRecordListCount(), datalist))
            end)
        end
    end

    local templength = self.scroll_pan.Container.Position2D.y - self.scroll_pan.ScrollRect2D.height + self.scroll_pan.Container.Size2D.y

    if templength < 20 or self.scroll_pan.Container.Size2D.y < self.scroll_pan.ScrollRect2D.height then
        self.m_Lock = true
    else
        self.m_Lock = false
    end
end

local function InitDynamicScrollPan(parent)
    self.scroll_pan = UIChatDynamicScrollPan.New()
    self.scroll_pan.Bounds2D = parent.Bounds2D
    self.scroll_pan.Gap            = 10            
    self.scroll_pan.Scroll.vertical  = true
    self.scroll_pan.Scroll.horizontal  = false
    self.scroll_pan.IsCountUnVisibleNode = false
    self.scroll_pan.CacheRecordNum = ChatModel.RecordCount
    self.scroll_pan:SetDirection(UIChatDynamicScrollPan.UIDynamicScrollPan_Direction.eAddToBottom)
    
    
    self.scroll_pan.Scroll.movementType = UnityEngine.UI.ScrollRect.MovementType.Elastic
    self.scroll_pan.Scroll.inertia = true
    self.scroll_pan.Name    = "m_MFUIChatDynamicScrollTemplate"
    self.scroll_pan.event_OnEndDrag = OnScrollPanEnd
    self.scroll_pan.IsAutoScroll = true
    self.m_Lock = true

    parent.Parent:AddChild(self.scroll_pan)

    parent.Visible = false;
end

local function chatPushCb(param)
    if(param.s2c_scope == self.m_curChannel or self.m_curChannel == 0) then
        FillOnedata(param)
        ChatModel.RedPoint[param.s2c_scope].showPoint = false
        ChatModel.RemoveMessageData(self.m_curChannel)
    else
        if self["ib_" .. param.s2c_scope] then
            self["ib_" .. param.s2c_scope].Visible = ChatModel.RedPoint[param.s2c_scope].showPoint
        end
    end
end

local function OnExit()
    EventManager.Fire("Event.UI.Hud.HideOrShowCvschat",{param = true})
    RemoveUpdateEvent("Event.UI.ChatSmall.Update")
    ChatModel.RemoveChatPushListener("chatMainSmallPush")
    ClearLastVoice()
    ChatModel.SaveBaseSetData()
    self.waitHornData = nil
end

local function OnEnter()
    EventManager.Fire("Event.UI.Hud.HideOrShowCvschat",{param = false})
    ChatModel.AddChatPushListener("chatMainSmallPush", chatPushCb)
    AddUpdateEvent("Event.UI.ChatSmall.Update", function(deltatime)
        ChatSend.VoiceChatUpate(self)
        refreshVoice()
    end)

    local index = tonumber(self.m_Root.ExtParam)
    if index then
        self.curIndex = index
    end
    
    MenuBaseU.InitMultiToggleButton(self.cvs_change, _M._channelName[self.curIndex], CommonUnity3D.UGUIEditor.UI.TouchClickHandle(OnSwitch))
    
    for i = ChatModel.ChannelState.Channel_world, ChatModel.ChannelState.Channel_ally do
        if i ~= self.curIndex and ChatModel.RedPoint[i].showPoint then
            self["ib_" .. i].Visible = true
        else
            self["ib_" .. i].Visible = false
        end
    end
    ChatSend.OnEnter(self)
end

local function OnClickClose(displayNode)
    
    if self.hudCallBack ~= nil then
        self.hudCallBack(self.curIndex)
    end
    self.m_Root:Close()
end

local function CloseCopyMenu( displayNode)
    
    self.cvs_copybg.Visible = false
    self.selectData = nil
end

local function OnClickCopy(displayNode)
    
    if self.selectData ~= nil then
        ChatSend.SetCopyData(ChatUtil.DeleteLinkData(self.selectData.s2c_content), self)
    end
    CloseCopyMenu(displayNode)
end

local function OnClickShield(displayNode)
    FriendModel.addBlackListRequest(self.selectData.s2c_playerId, function()
        
        if self.selectData ~= nil then
            ChatModel.AddNewBlackRole(self.selectData.s2c_playerId)
        end
        CloseCopyMenu(displayNode)
    end)
    
end

local function OnClickReport(displayNode)
    
    FriendModel.friendAddChouRenRequest(self.selectData.s2c_playerId, function()
        
        CloseCopyMenu(displayNode)
    end)
end

local function OnClickBig(displayNode)
    OnClickClose(displayNode)
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatMainSecond, 0, self.curIndex)
    UnityEngine.PlayerPrefs.SetInt(DataMgr.Instance.UserData.RoleID .. "chatSizeModel", 1)
end

local function InitUI()
    
    local UIName = {
        "btn_close",
        "cvs_talk",
        "sp_show",
        "role_bg",
        "sp_list",
        "cvs_xk",
        "cvs_copybg",
        "btn_copy",
        "btn_shield",
        "btn_report",
        "cvs_change",
        "ib_1",
        "ib_2",
        "ib_3",
        "ib_4",
        "ib_5",
        "ib_6",
        "ib_7",
        "btn_big",
        "cvs_main",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end
end

local function InitCompnent()
    InitUI()
    self.localUSpeakSender = LocalUSpeakSender.clone:GetComponent(typeof(LocalUSpeakSender))
    LuaUIBinding.HZPointerEventHandler({node = self.btn_close, click = OnClickClose})
    HudManagerU.Instance:InitAnchorWithNode(self.cvs_main, bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_BOTTOM))

    self.btn_big.TouchClick = OnClickBig

    self.cvs_talk.Visible = false
    self.nodeHight = self.cvs_talk.Height
    self.nodeWidth = self.cvs_talk.Width
    InitDynamicScrollPan(self.sp_show)

    
    self.cvs_copybg.TouchClick = CloseCopyMenu
    self.cvs_copybg.Visible = false
    self.btn_copy.TouchClick = OnClickCopy
    self.btn_shield.TouchClick = OnClickShield
    self.btn_report.TouchClick = OnClickReport

    self.m_Root:SubscribOnDestory(function()
        
        
        ChatSend.OnDestory(self)
        self = nil
    end)
    
    self.m_Root:SubscribOnExit(OnExit)
    self.m_Root:SubscribOnEnter(OnEnter)
end

local function Init(tag,params)
	
	
	self.m_Root = LuaMenuU.Create("xmds_ui/chat/chat_hud_chat.gui.xml", GlobalHooks.UITAG.GameUIChatMainSmall)
    self.menu = self.m_Root
    self.menu.ShowType = UIShowType.Cover
    ChatSend.Init(self.m_Root, self)
	InitCompnent()
	
	return self.m_Root
end

local function Create(tag,params)
	self = {}
	setmetatable(self, _M)
	local node = Init(tag, params)
	return self
end

local function initial()
    
    
end

function _M.setPlayer(data)
    
    
    
    ChatSend.SetAcceptRoleData(data, self)
    ChatUtil.AddNewPrivateRole(data)
end

function _M.SwitchChannel(channel)
    
    if self.m_curChannel ~= channel then
        MenuBaseU.InitMultiToggleButton(self.cvs_change, _M._channelName[channel], CommonUnity3D.UGUIEditor.UI.TouchClickHandle(OnSwitch))
    end
end

return {Create = Create, initial = initial}
