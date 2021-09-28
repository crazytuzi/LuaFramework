local _M = {}
_M.__index = _M


local Util          = require "Zeus.Logic.Util"
local TreeView      = require "Zeus.Logic.TreeView"
local ChatModel     = require 'Zeus.Model.Chat'
local ChatUtil      = require "Zeus.UI.Chat.ChatUtil"
local ChatSendVoice = require "Zeus.UI.Chat.ChatSendVoice"
local FriendModel   = require 'Zeus.Model.Friend'
local SocialUtil    = require "Zeus.UI.XmasterSocial.SocialUtil"
local InteractiveMenu = require "Zeus.UI.InteractiveMenu"

local MaxLength = 50
local TalkWidth = 415
local TalkHight = 20
local EachPageNum = 20

local BGMVolume = 1
local EffectVolume = 1

local self = {
    m_Root = nil,
}

local function InitRichTextLabel()
    if(self.m_htmlText == nil) then
        local canvas = HZCanvas.New()
        canvas.Size2D = self.m_TxtinputPrivate.Size2D
        
        
        canvas.Layout = XmdsUISystem.CreateLayoutFromFile("static_n/login/img_black.png", LayoutStyle.IMAGE_STYLE_ALL_9, 8)
        local mask = canvas.UnityObject:AddComponent(typeof(UnityEngine.UI.Mask))
        mask.showMaskGraphic = false

        self.m_htmlText = HZRichTextPan.New();
        self.m_htmlText.Size2D = self.m_TxtinputPrivate.Size2D
        self.m_htmlText.RichTextLayer.UseBitmapFont = true
        self.m_htmlText.RichTextLayer:SetEnableMultiline(false)
        self.m_htmlText.TextPan.Width = self.m_TxtinputPrivate.Size2D.x
        canvas:AddChild(self.m_htmlText)
        self.m_TxtinputPrivate:AddChild(canvas)
        
        self.m_htmlText.Visible = false;
        self.m_htmlText.X = 10
        self.m_htmlText.Y = 10
    end
end

local function AddStringInput(msg, copy)
    InitRichTextLabel(self)
    if string.gsub(msg, " ", "") ~= "" or self.m_titleMsg ~= "" or string.gsub(self.m_StrTmpOriginal, " ", "") ~= "" then
        self.lb_click.Visible = false
        self.m_htmlText.Visible = true
        
    else
        self.lb_click.Visible = true
        self.m_htmlText.Visible = false
        
    end

    if string.gsub(msg, " ", "") == "" then
        msg = ""
    end
    if copy then
        if ChatUtil.StartsWith(msg, "|") then
            self.m_StrTmpOriginal = self.m_StrTmpOriginal .. msg
        else
            self.m_StrTmpOriginal = self.m_StrTmpOriginal .. "|" .. msg .. "|"
        end 
    else
        self.m_StrTmpOriginal = self.m_StrTmpOriginal .. msg
    end
    local linkdata = ChatUtil.HandleChatClientDecode(self.m_titleMsg .. self.m_StrTmpOriginal, 0xffffffff)
    self.m_htmlText.RichTextLayer:SetString(linkdata)
end

local function ClearInput()
    self.m_StrTmpOriginal = ""
    AddStringInput("")
    self.m_TxtinputPrivate.Text = ""

    self.curChatList = nil
end

local function OnClickJianPan(displayNode)
    
    self.m_IsVioceOn = false
    self.cvs_input.Visible = true
    self.cvs_input2.Visible = false
end

local function OnClickYuyin(displayNode)
    
    self.m_IsVioceOn = true
    self.cvs_input.Visible = false
    self.cvs_input2.Visible = true
end

local function OnClickSendMessage(msg)
    
    if msg == nil or string.gsub(msg, " ", "") == "" then
        
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'input_null'))
        return
    end

    FriendModel.sendMessageRequest(msg, self.m_SelData.id, function (param)
        self.m_selPersion = nil
        ClearInput()
    end)
end

local function AddFace(index)
    
    local msg = ChatUtil.AddFaceByIndex(index)
    local num = ChatUtil.HandleOriginalToInput(self.m_StrTmpOriginal .. msg)
    if string.len(num) < MaxLength then
        AddStringInput(msg)
    else
        
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'input_limit'))
    end
end

local function FaceCallBack(type1, data1, data2)
    
    if type1 == 0 then        
        AddFace(data1, self)
    elseif type1 == 1 then    
        AddItem(data1, data2, self)
    elseif type1 == 3 then    
        self.m_selPersion = nil
        self.tbt_expression.IsChecked = false
    end
end

local function OnClickBiaoqing(displayNode, pos)
    
    local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatFace, 0)
    lua_obj.faceCb = function(type1, data1, data2)
        FaceCallBack(type1, data1, data2, self)
    end
end

local function HandleTxtInputPrivate(displayNode)
    self.lb_click.Visible = false
    
    if self.m_TxtinputPrivate.Input.text == " " then
        self.m_StrInput = ChatUtil.HandleOriginalToInput(self.m_StrTmpOriginal)
        
        self.m_TxtinputPrivate.Input.text = self.m_StrInput

        if(self.m_htmlText ~= nil)then
            self.m_htmlText.Visible = false;
        end
    end
end

local function HandleInputFinishCallBack(displayNode)
    
    local msg = ""
    msg = ChatUtil.HandleInputToOriginal(self.m_TxtinputPrivate.Input.text)
    self.m_StrTmpOriginal = ""
    AddStringInput(msg)
    self.m_TxtinputPrivate.Input.text = " "
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

local  IsVoicePlaying = false
local function PlayTencentVioce(filepath)
    
    IsVoicePlaying = true
    local function PlayOk(self)
        
        if self.m_Selib_basicsound ~= nil then
            self.m_Selib_basicsound.Visible = true
            self.m_Selib_basicsound = nil
        end
        if self.m_Selib_sound ~= nil then
            self.m_Selib_sound.Visible = false
            self.m_Selib_sound = nil
        end
    end

    BGMVolume = XmdsSoundManager.GetXmdsInstance():GetBGMVolume()
    EffectVolume = XmdsSoundManager.GetXmdsInstance():GetEffectVolume()

    XmdsSoundManager.GetXmdsInstance():SetBGMVolume(BGMVolume*0.2)
    XmdsSoundManager.GetXmdsInstance():SetEffectVolume(EffectVolume*0.2)

    self.voiceCallBackstatus = FileSave.Voiceengine:PlayRecordedFile(filepath)
    if self.voiceCallBackstatus == 0 then
        FileSave.Voiceengine.OnPlayRecordFilComplete = function(code, filepath, fileid)
            

            XmdsSoundManager.GetXmdsInstance():SetBGMVolume(BGMVolume)
            XmdsSoundManager.GetXmdsInstance():SetEffectVolume(EffectVolume)
            self.voiceCallBackstatus = nil
            if code == gcloud_voice.IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_PLAYFILE_DONE then
                PlayOk(self)
            end

            IsVoicePlaying = false
        end
    else
        XmdsSoundManager.GetXmdsInstance():SetBGMVolume(BGMVolume)
        XmdsSoundManager.GetXmdsInstance():SetEffectVolume(EffectVolume)
        PlayOk(self)
        IsVoicePlaying = false
    end
end

local function NormalMsgCell(tb_talk, node, data, ismyselfcontent, canvas)
    
    local offsetX = 0
    local offsetY = 0
    local text = nil
    local curWidth = 0
    text = HZRichTextPan.New();
    text.RichTextLayer.UseBitmapFont = true

    
    
    
    
    
    
    
    
    
    
        text.Y = 5
        curWidth = TalkWidth - 40
    
    
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
        
            
        
        
            
            
            
        
            data.linkdata = ChatUtil.HandleChatClientDecode("" .. data.s2c_content, 0xddf2ffff)
        
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
                
                
                
                
                local point = text:ScreenToLocalPoint2D(pos)
                
                
                local info = UIChatDynamicScrollPan.Click(point.x, point.y, text.RichTextLayer)
                if info.mRegion  ~= nil and info.mRegion.Attribute ~= nil then
                    
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
        tb_talk.Size2D = Vector2.New(TalkWidth, height + offsetY + 10)
        node.Height = self.nodeHight + height - TalkHight + offsetY
            
        if ismyselfcontent then   
            
            
            
            
                tb_talk.X = self.nodeWidth - TalkWidth
                text.X = 15
            
        end
    else                                            
        local length = text.RichTextLayer.ContentWidth + 30 + offsetX 
        
        if length < 100 then
            length = 100
        end

        tb_talk.Size2D = Vector2.New(length + 15, height + offsetY + 10)
        node.Height = self.nodeHight + height - TalkHight + offsetY
        
        if ismyselfcontent then
            
            
            
            
                tb_talk.X = self.nodeWidth - length - 15
                text.X = length - text.RichTextLayer.ContentWidth - 20 + offsetX
            
            
        end
    end
end

local function VoiceMsgCell(tb_talk, node, data, ismyselfcontent, isVoice)
    
    local offsetY = 0
    local text = nil
    text = HudManagerU.Instance.CreateHudUIFromFile("xmds_ui/chat/chat_sound.gui.xml")
    text.IsInteractive = true
    text.Enable = false
    text.EnableChildren = true
    text.Y = -5
    tb_talk:AddChild(text);
    tb_talk.Size2D = Vector2.New(340, 60)
    local lb_soundtime
    local ib_red
    local ib_sound
    local cvs_sound
    local ib_basicsound
    cvs_sound = text:FindChildByEditName("cvs_sound", true)
    cvs_sound.Visible = true
    lb_soundtime = cvs_sound:FindChildByEditName("lb_soundtime", true)
    ib_red = cvs_sound:FindChildByEditName("ib_red", true)
    ib_sound = cvs_sound:FindChildByEditName("ib_sound", true)
    ib_basicsound = cvs_sound:FindChildByEditName("ib_basicsound", true)
    cvs_sound.Enable = true
    local cvs_fanyi = text:FindChildByEditName("cvs_fanyi", true)
    local lb_fanyi = text:FindChildByEditName("lb_fanyi", true)
    local tbt_change = text:FindChildByEditName("tbt_change", true)
    data.showFanyi = true
    tbt_change.Visible = false
    if ismyselfcontent then
        tb_talk.X = self.nodeWidth - tb_talk.Width - 14
        lb_fanyi.X = cvs_fanyi.Width - lb_fanyi.Width
        cvs_fanyi.X = 340 - cvs_fanyi.Width
    else
        tb_talk.X = 100
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
        node.Height = self.nodeHight + offsetY + cvs_fanyi.Height
    else
        tbt_change.IsChecked = false
        node.Height = self.nodeHight + offsetY
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
            node.Height = self.nodeHight + offsetY + cvs_fanyi.Height
        else
            node.Height = self.nodeHight + offsetY
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
                PlayTencentVioce(FileSave.voiceLocalFilePath .. isVoice.filepath)
            else
                
                
                
                
                self.voiceCallBackstatus = FileSave.Voiceengine:DownloadRecordedFile(isVoice.fileid, FileSave.voiceLocalFilePath .. isVoice.filepath, 60000)
                FileSave.Voiceengine.OnDownloadRecordFileComplete = function(code, filepath, fileid)
                    
                    self.voiceCallBackstatus = nil
                    if code == gcloud_voice.IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
                        PlayTencentVioce(filepath)
                    end
                end
            end
            
        end
    end
end

local function ClearNode(node)
    node.event_PointerUp = nil
    node.TouchClick = nil
    node.event_PointerDown  = nil
    node:RemoveChildren(0, -1, true)
end

local function initTalkCell(node, data)

    node:FindChildByEditName("cvs_talk1", true).Visible = true
    
    local tb_talk = nil
    local ismyselfcontent = false
    local canvas = nil
    
    local lb_level = node:FindChildByEditName("lb_level", true)
    if data.s2c_playerId == DataMgr.Instance.UserData.RoleID then
        lb_level.Text = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
        tb_talk = node:FindChildByEditName("tb_talk1", true)
        ClearNode(tb_talk)
        local layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/common2.xml|common2|137", LayoutStyle.IMAGE_STYLE_ALL_9, 21)
        tb_talk.Layout = layout
        node:FindChildByEditName("tb_talk", true).Visible = false
        ismyselfcontent = true
    else
        lb_level.Text = self.m_SelData.level
        tb_talk = node:FindChildByEditName("tb_talk", true)
        ClearNode(tb_talk)
        local layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/common2.xml|common2|87", LayoutStyle.IMAGE_STYLE_ALL_9, 21)
        tb_talk.Layout = layout
        node:FindChildByEditName("tb_talk1", true).Visible = false
        ismyselfcontent = false
    end
    tb_talk.Visible = true
    data.isVoice = FriendModel.IsVoiceMsg(data.s2c_content)
    if data.isVoice == nil then
        NormalMsgCell(tb_talk, node, data, ismyselfcontent, canvas)
    else
        VoiceMsgCell(tb_talk, node, data, ismyselfcontent, data.isVoice)
        local layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|21", LayoutStyle.IMAGE_STYLE_ALL_9, 30)
        tb_talk.Layout = layout
    end
    
    
    
    
        
        
        
            
        
    
    
    
    
    
    
    
    local tbh_character = node:FindChildByEditName("tbh_character", true)
    tbh_character.Visible = false
    
    
    
    
    local cvs_head = node:FindChildByEditName("cvs_head", true)
    local ib_head = node:FindChildByEditName("ib_head", true)
    
    
    
        
    
    MenuBaseU.SetEnableUENode(node, "ib_head", true, true)
    local click_head = {node = ib_head, click = function (displayNode, pos)
        
            
        
    end} 
    LuaUIBinding.HZPointerEventHandler(click_head)
    if ismyselfcontent then
        cvs_head.X = self.nodeWidth - 90
        
        
        Util.HZSetImage(ib_head, "static_n/hud/target/" .. DataMgr.Instance.UserData.Pro .. ".png", false)
        tb_talk.X =  tb_talk.X - 100 
    else
        Util.HZSetImage(ib_head, "static_n/hud/target/" .. self.m_SelData.pro .. ".png", false)
        cvs_head.X = 0
        
        
    end
    
    data.NodeHight = node.Height
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
    
        self.scroll_pan:MoveContainerV()
    
end

local function NewMessagePush(param)
    if self.curChannelBtn and self.m_SelData then
        if param.s2c_playerId == self.m_SelData.id or param.s2c_acceptRid == self.m_SelData.id then
            FillOnedata(param)
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
    
    
    

    
    
    
    
    
    
end

local function filldata(recordList)
    local datalist = nil
    if recordList and recordList.recordList then
        datalist = recordList.recordList
    end
    local record = Util.List2Luatable(self.scroll_pan:GetRecordList())
    if datalist == nil or datalist[1] == nil then
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

local function ClearChatRecord()
    
    FriendModel.clearChatRecordReqest(self.m_SelData.id, function(param)
        if self.tbn_recently.IsChecked == true then
            EventManager.Fire("Event.Social.NeedRefreshFriendList", {})
            self.m_SelData = nil
            self.cvs_chat.Visible = false
            self.cvs_chat_none.Visible = true
        else
            self.curChatList = nil
            filldata(self.curChatList)
        end
    end)
end

local function OpenChatWindows(data)
    ClearInput()

    self.cvs_chat.Visible = true
    self.cvs_chat_none.Visible = false
    self.m_SelData = data
    FriendModel.GetChatRecordList(self.m_SelData.id, function(param)
        self.curChatList = param
        filldata(self.curChatList)
    end)

    ChatSendVoice.SetAcceptRoleID(self, self.m_SelData.id)
end

local function InteractiveChatMenuCb(id, data)
    if self.m_OprateData == nil then 
        return 
    end

    if id == 13 then 
        self.m_OprateData = nil
        EventManager.Fire("Event.Social.NeedRefreshFriendList", {})
    elseif id == 14 then 
        FriendModel.friendDeleteChouRenRequest(self.m_OprateData.id, function(data)
            
            EventManager.Fire("Event.Social.NeedRefreshFriendList", {})
            self.m_OprateData = nil
        end)
    elseif id == 21 then 
        FriendModel.deleteBlackListRequest(self.m_OprateData.id, function(params)
            EventManager.Fire("Event.Social.NeedRefreshFriendList", {})
            self.m_OprateData = nil
        end)
    end
end

local function InitItemUI(node, data, fromType)
    local UIName = {
        "tbn_brief",
        "btn_icon",
        "ib_headicon",
        "lb_level",
        "lb_name",
        "lb_Glv",
        "lb_bj_news",
        "img_zhezhao",
    }

    local ui = {}
    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
    
    ui.lb_level.Text =  data.level
    ui.lb_name.Text =  data.name
    
    
    
    
    

    ui.lb_Glv.Text = data.guildName or ""

    Util.HZSetImage(ui.ib_headicon, "static_n/hud/target/" ..data.pro.. ".png", false)
    
    ui.img_zhezhao.Visible = data.isOnline == 0
    ui.btn_icon.TouchClick = function (sender)
        self.m_OprateData = data
        EventManager.Fire("Event.ShowInteractive", {
            type=fromType,
            player_info = {
            name = data.name, 
            lv = data.level,
            upLv = data.stageLevel,
            guildName = data.guildName,
            playerId = data.id,
            pro = data.pro,
            activeMenuCb = InteractiveChatMenuCb,
            },
        })
    end
    ui.tbn_brief.IsChecked = (self.m_SelData ~= nil) and (self.m_SelData.id == data.id)
    if ui.tbn_brief.IsChecked == true then
        self.CurSelectItem = ui.tbn_brief
        OpenChatWindows(self.m_SelData)
    end
    ui.tbn_brief.Enable = (not ui.tbn_brief.IsChecked)
    ui.tbn_brief.TouchClick = function (sender)
        if fromType == InteractiveMenu.SOCIAL_BLACKLIST then
            Util.GetText(TextConfig.Type.FRIEND,'blackListChatTips')
            sender.IsChecked = false
            return
        end
        if self.CurSelectItem ~= nil then
            self.CurSelectItem.IsChecked = false
            self.CurSelectItem.Enable = true
        end
        sender.IsChecked = true
        sender.Enable = false
        self.CurSelectItem = sender
        ui.lb_bj_news.Visible = false
        OpenChatWindows(data)
    end
    
    
end

local function CreatFriendTreeView()
    local DataList = {}
    table.insert(DataList,self.FriendList.friends or {})
    table.insert(DataList,self.FriendList.chouRens or {})
    table.insert(DataList,self.FriendList.blackList or {})

    if self.treeView ~= nil then
        self.friend_list:RemoveNormalChild(self.treeView.view, true)
    end
    self.treeView = TreeView.Create(3,0,self.friend_list.Size2D)

    local function rootCreateCallBack(index,node)
        local lb_title = node:FindChildByEditName("lb_title", true)
        lb_title.Text = Util.GetText(TextConfig.Type.FRIEND,'friendViewName_'..index)

        local lb_num = node:FindChildByEditName("lb_num", true)
        local online, total = SocialUtil.GetOnlineNumFromList(DataList[index])
        lb_num.Text = online.."/"..total
    end
    local function rootClickCallBack(node,visible)
        local ib_down = node:FindChildByEditName("ib_down",false)
        local ib_up = node:FindChildByEditName("ib_up",false)
        ib_down.Visible = not visible
        ib_up.Visible = visible
        if visible == true then
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zuobiaoqian')
        end
        if visible == true then
            self.selectRootIndex = node.UserTag
        end
    end
    local rootValue = TreeView.CreateRootValue(self.cvs_titles,3,rootCreateCallBack,rootClickCallBack)
    
    local function subClickCallback(rootIndex,subIndex,node)

    end
    local function subCreateCallback(rootIndex,subIndex,node)
        local friendType = InteractiveMenu.SOCIAL_FRIEND
        if rootIndex == 2 then
            friendType = InteractiveMenu.SOCIAL_ENEMY
        elseif rootIndex == 3 then
            friendType = InteractiveMenu.SOCIAL_BLACKLIST
        end
        InitItemUI(node, DataList[rootIndex][subIndex], friendType)
    end
    local subValues = {}
    local sub1 = TreeView.CreateSubValue(1 ,self.recently_information,#DataList[1],subClickCallback, subCreateCallback)
    local sub2 = TreeView.CreateSubValue(2 ,self.recently_information,#DataList[2],subClickCallback, subCreateCallback)
    local sub3 = TreeView.CreateSubValue(3 ,self.recently_information,#DataList[3],subClickCallback, subCreateCallback)
    table.insert(subValues,sub1)
    table.insert(subValues,sub2)
    table.insert(subValues,sub3)
    self.treeView:setValues(rootValue,subValues)
    self.friend_list:AddNormalChild(self.treeView.view)

    if self.selectRootIndex > 0 then
        self.treeView:selectNode(self.selectRootIndex,nil,false)
    end
end

local function SwitchToFriendList()
    
    FriendModel.GetAllSocialList(function()
        self.FriendList = FriendModel.GetFriendList()
        CreatFriendTreeView()
        self.friend_list.Visible = true
    end)
end





















local function RefreshRecentlyItem(x, y, node)
    node.UserTag = y + 1
    local data = self.RecentlyList[y + 1]
    node.Visible = true
    InitItemUI(node, data, InteractiveMenu.SOCIAL_RECENTYLY)
end

local function InitRecentlyItem(node)

end

local function SwitchToRecentlyList()
    FriendModel.GetAllRecentlyList(function()
        self.RecentlyList = FriendModel.GetRecentlyList()
        local rows = (self.RecentlyList and #self.RecentlyList) or 0
        if rows > 0 then
            local pos = -self.recently_list.Scrollable.Container.Y
            self.recently_list:Initialize(self.recently_information.Width, self.recently_information.Height + 5, rows, 1, self.recently_information, 
                LuaUIBinding.HZScrollPanUpdateHandler(RefreshRecentlyItem), 
                LuaUIBinding.HZTrusteeshipChildInit(InitRecentlyItem))

            self.recently_list.Scrollable:LookAt(Vector2.New(0, pos))
        end
        self.recently_list.Visible = rows > 0
    end)
end

local function SwitchList( sender )
    if sender == self.tbn_recently then
        self.curChannelBtn = sender
        self.friend_list.Visible = false
        SwitchToRecentlyList()
    elseif sender == self.tbt_friendlist then
        self.curChannelBtn = sender
        self.recently_list.Visible = false
        SwitchToFriendList()
    end
end

local function OnClickAddFriend(displayNode)
    local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialFriendAdd, 0)
end

local function RefreshFriendList()
    if self.curChannelBtn then
        self.curChannelBtn.IsChecked = true
    end
end

local function refreshVoice()
    
    if self.pressTime ~= nil and math.floor((System.DateTime.Now - self.pressTime).TotalSeconds) > 0.8 then
        if self.pressData.s2c_playerId ~= DataMgr.Instance.UserData.RoleID then
            
            local point = self.m_Root:GetComponent("cvs_chat"):ScreenToLocalPoint2D(self.pressPos)
            self.cvs_copybg.Visible = true
            self.cvs_xk.X = point.x
            if self.cvs_xk.X > 710 then
                self.cvs_xk.X = 710
            end
            self.cvs_xk.Y = point.y
            self.selectData = self.pressData
        end
    end
end

local function OnEnter()
    RefreshFriendList()

    AddUpdateEvent("Event.UI.ChatFriend.Update", function(deltatime)
            ChatSendVoice.VoiceChatUpate(self)
            refreshVoice()
        end)
    
    FriendModel.AddMessagePushListener("newMessagePush", NewMessagePush)
    EventManager.Subscribe("Event.Social.NeedRefreshFriendList", RefreshFriendList)

    GlobalHooks.Drama.Start('guide_friend', true)
end

local function InitDynamicScrollPan(parent)
    self.scroll_pan = UIChatDynamicScrollPan.New()
    self.scroll_pan.Bounds2D = parent.Bounds2D
    self.scroll_pan.Gap = 10
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
    parent.Visible = false
end

local function InitChatUI()
    self.cvs_talk.Visible = false
    self.nodeHight = self.cvs_talk.Height
    self.nodeWidth = self.cvs_talk.Width
    InitDynamicScrollPan(self.sp_show)

    self.btn_clear.TouchClick = function (sender)
        ClearChatRecord()
    end

    self.btn_delete.Visible = false

    self.tbt_expression.TouchClick = function (displayNode, pos)
        OnClickBiaoqing(displayNode, self, pos)
    end

    self.btn_enter.TouchClick = function (displayNode, pos)
        OnClickSendMessage(self.m_StrTmpOriginal)
    end

    self.btn_yuyin.TouchClick = function (displayNode, pos)
        OnClickYuyin(displayNode)
    end

    self.btn_jianpan.TouchClick = function (displayNode, pos)
        OnClickJianPan(displayNode)
    end

    self.m_TxtinputPrivate = self.m_Root:GetComponent("ti_content")
    self.m_TxtinputPrivate.Input.characterLimit = MaxLength
    self.m_TxtinputPrivate.Input.text = " "
    self.m_TxtinputPrivate.Input.lineType = UnityEngine.UI.InputField.LineType.MultiLineSubmit
    self.m_TxtinputPrivate.InputTouchClick = function(displayNode)
        HandleTxtInputPrivate(displayNode, self)
    end
    self.m_TxtinputPrivate.event_endEdit = LuaUIBinding.InputValueChangedHandler(function(displayNode)
        HandleInputFinishCallBack(displayNode, self)
    end)

    
    self.m_StrTmpOriginal = ""
    self.m_titleMsg = ""
    self.m_IsVioceOn = false
end

local function InitUI()
    
    local UIName = {
        "tbn_recently",
        "lb_bj_recently",
        "tbt_friendlist",
        "lb_bj_friendlist",
        
        "recently_list",
        "cvs_titles",
        "recently_information",

        "friend_list",

        "tbt_property",
        "tbt_title",
        "tbt_strg",

        "btn_makefriends",

        "cvs_chat",
        "cvs_chat_none",
        "btn_clear",
        "cvs_input",
        "ti_content",
        "lb_click",
        "tbt_expression",
        "btn_enter",
        "cvs_input2",
        "btn_yuyin",
        "btn_jianpan",

        "sp_show",
        "cvs_talk",
        "cvs_talk1",
        "lb_time",
        "btn_talk",

        "btn_delete",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end
    self.selectRootIndex = 0
end

local function OnExit()
    RemoveUpdateEvent("Event.UI.ChatFriend.Update")
    FriendModel.RemoveMessagePushListener("newMessagePush")
    EventManager.Unsubscribe("Event.Social.FriendAddUIClosed", RefreshFriendList)
    self.m_Root:RemoveAllSubMenu()
end

local function InitCompnent()
    InitUI()
    InitChatUI()
    self.localUSpeakSender = LocalUSpeakSender.clone:GetComponent(typeof(LocalUSpeakSender))

    self.recently_information.Visible = false
    self.cvs_titles.Visible = false

    self.CurSelectItem = nil

    self.lb_time.Visible = false

    self.cvs_chat.Visible = false
    self.cvs_chat_none.Visible = true

    Util.InitMultiToggleButton(function (sender)
      SwitchList(sender)
    end,nil,{self.tbn_recently,self.tbt_friendlist})
    self.curChannelBtn = self.tbn_recently

    Util.InitMultiToggleButton(function (sender)
      
    end,self.tbt_property,{self.tbt_property,self.tbt_title,self.tbt_strg})
    

    self.btn_makefriends.TouchClick = OnClickAddFriend

    self.cvs_talk.Visible = false
    self.nodeHight = self.cvs_talk.Height
    self.nodeWidth = self.cvs_talk.Width

    self.m_Root:SubscribOnEnter(OnEnter)
    self.m_Root:SubscribOnExit(OnExit)

    self.m_Root:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
    self.m_Root = LuaMenuU.Create("xmds_ui/social/friend.gui.xml", GlobalHooks.UITAG.GameUISocialFriend)
    self.menu = self.m_Root
    self.menu.Enable = false
    
    InitCompnent()

    ChatSendVoice.Init(self.m_Root, self, self.btn_talk)
    ChatSendVoice.InitChannel(ChatModel.ChannelState.Channel_private, self)

    return self.m_Root
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end


return {Create = Create}
