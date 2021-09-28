local _M = {}
_M.__index = _M


local ChatModel = require 'Zeus.Model.Chat'
local Util      = require "Zeus.Logic.Util"
local ChatUtil  = require "Zeus.UI.Chat.ChatUtil"
local ChatSendVoice     = require "Zeus.UI.Chat.ChatSendVoice"
local GDRQ              = require "Zeus.Model.Guild"
local DaoyouModel       = require "Zeus.Model.Daoyou"

local MaxLength = 50
























local function InitRichTextLabel(self)
    
    
    
    
    if(self.m_htmlText == nil) then
        local canvas = HZCanvas.New()
        canvas.Size2D = self.m_TxtinputPrivate.Size2D
        
        
        canvas.Layout = XmdsUISystem.CreateLayoutFromFile("static_n/shade.png", LayoutStyle.IMAGE_STYLE_ALL_9, 8)
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

local function AddStringInput(msg, self, copy)
    
	if self.chat_speaker ~= nil then
		self.chat_speaker.AddStr(msg,copy)
		return
	end	
	
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

local function AddFace(index, self)
    
    local msg = ChatUtil.AddFaceByIndex(index)
    if self.m_StrTmpOriginal == nil then
        self.m_StrTmpOriginal = ""
    end

    local num = ChatUtil.HandleOriginalToInput(self.m_StrTmpOriginal .. msg)
    if string.len(num) < MaxLength then
        AddStringInput(msg, self)
    else
        
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'input_limit'))
    end
end

local function AddItem(str, self)
    
    local msg = str
	
    local num = ChatUtil.HandleOriginalToInput(self.m_StrTmpOriginal .. msg)
    if string.len(num) < MaxLength then
        AddStringInput(msg, self)
    else
        
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'input_limit'))
    end
end

local function OnClickSendMessage(self, msg)
    
    if msg == nil or string.gsub(msg, " ", "") == "" then
        
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'input_null'))
        return
    end
    if self.m_curChannel == ChatModel.ChannelState.Channel_private and self.privateRoleData == nil then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'chat_object'))
        return
    end

    if self.cvs_hornVisible and self.m_curChannel == ChatModel.ChannelState.Channel_world then
        ChatModel.chatMessageRequest(ChatModel.ChannelState.Channel_horm, msg, self.m_acceptRoleId, function (param)
            self.canClearMsg = true
            self.m_selPersion = nil
			
			if self.chat_speaker ~= nil then
				self.chat_speaker.Close()
			end
			
        end)
    else
        
        
        
        
        
        
        
        
        
        
        
        

        
        
        
        
        

        
        
        
        
        
        
        

        
        
        
        
        
        
        

        
        
        
        
        
        
        

        

        
        
        
        
        
        
        
        
        
        
        
        ChatModel.chatMessageRequest(self.m_curChannel, msg, self.m_acceptRoleId, function (param)
            self.canClearMsg = true
            self.m_selPersion = nil
            if self.m_curChannel == ChatModel.ChannelState.Channel_union or self.m_curChannel == ChatModel.ChannelState.Channel_group then
                _M.SetAcceptRoleData(nil, self)
            end
        end, self.s2c_isAtAll, self.m_titleMsg, self.m_functype)
        self.m_functype = nil
    end 
    
end

local function ActionDataToPrivate(data, self)
    if self.m_curChannel == ChatModel.ChannelState.Channel_private and data ~= nil then
        local todata = {}
        todata.playerId = data.s2c_playerId
        todata.name = data.s2c_name 
        todata.lv = data.s2c_level 
        todata.pro = data.s2c_pro
        _M.SetAcceptRoleData(todata, self)
    end
end

local function AddChatAction(index, strdata, self)
    local msg = ""
    local data = {}
    ActionDataToPrivate(self.m_selPersion, self)
    data.s2c_playerId = DataMgr.Instance.UserData.RoleID
    data.s2c_name = DataMgr.Instance.UserData.Name
    data.s2c_level = DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0)
    data.s2c_pro = DataMgr.Instance.UserData.Pro
    local str1 = ChatUtil.AddPersonByData(data)
    local str2 = ChatUtil.AddPersonByData(self.m_selPersion)
    local actionstr = ""
    if self.m_selPersion == nil then
        actionstr = strdata[index].ContentNull
    else
        if self.m_selPersion.s2c_playerId == DataMgr.Instance.UserData.RoleID then
            actionstr = strdata[index].ContentSelf
        else
            actionstr = strdata[index].ContentOther
        end
    end
    msg = ChatUtil.HandleActionMsg(actionstr, str1, str2)
    self.m_functype = 4
    OnClickSendMessage(self, msg)
end

local function FaceCallBack(type1, data1, data2, self)
    
    if type1 == 0 then        
        AddFace(data1, self)
    elseif type1 == 1 then    
        AddItem(data1, self)
    elseif type1 == 3 then    
        self.m_selPersion = nil
        self.tbt_expression.IsChecked = false
    end
end

local function OnClickBiaoqing(self,displayNode,pos)
    
    
    if self.chat_tab_list ~= nil and self.chat_tab_list.ChatUIFaceMenu ~= nil then
        self.chat_tab_list.ChatUIFaceObj:AddToChatExtend(self.chat_tab_list)
    else
        local node,lua_obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIChatFace, 0)    
		self.chat_tab_list.ChatUIFaceObj = lua_obj
        self.chat_tab_list.ChatUIFaceMenu = node    
        
        lua_obj.faceCb = function(type1, data1, data2)
			FaceCallBack(type1, data1, data2, self)
		end
		lua_obj:AddToChatExtend(self.chat_tab_list)
    end    
end

local function OnClickChatItem(self,displayNode,pos)
    
    if self.chat_tab_list ~= nil and self.chat_tab_list.ChatUIShowItemMenu ~= nil then
        self.chat_tab_list.ChatUIShowItemObj:AddToChatExtend(self.chat_tab_list)
    else
        local node,lua_obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIChatShowItem, 0)    
		self.chat_tab_list.ChatUIShowItemObj = lua_obj
        self.chat_tab_list.ChatUIShowItemMenu = node    
        
        lua_obj.faceCb = function(type1, data1, data2)
			FaceCallBack(type1, data1, data2, self)
		end
		lua_obj:AddToChatExtend(self.chat_tab_list)
    end    
end

local function clearMsg(self)
    
    self.m_StrTmpOriginal = ""
    AddStringInput("", self)
    self.m_TxtinputPrivate.Text = ""
end

local function HandleTxtInputPrivate(displayNode, self)
    self.lb_click.Visible = false
    
    if self.m_TxtinputPrivate.Input.text == " " then
        self.m_StrInput = ChatUtil.HandleOriginalToInput(self.m_StrTmpOriginal)
        
        self.m_TxtinputPrivate.Input.text = self.m_StrInput

        if(self.m_htmlText ~= nil)then
            self.m_htmlText.Visible = false;
        end
    end
end

local function OnClickJianPan(displayNode, self)
    
    self.m_IsVioceOn = false
    self.cvs_input.Visible = true
    self.cvs_input2.Visible = false
end

local function OnClickYuyin(displayNode, self)
    
    if self.m_curChannel == ChatModel.ChannelState.Channel_private and self.privateRoleData == nil then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'chat_object'))
        return
    end
    self.m_IsVioceOn = true
    self.cvs_input.Visible = false
    self.cvs_input2.Visible = true
end

local function OnClickHorn(displayNode, self)
    
    if self.cvs_hornVisible then
        self.cvs_hornVisible = false
    else
        self.cvs_hornVisible = true
    end
end

local function DealSwitchBtnPic(channel, self)
    
    if channel == ChatModel.ChannelState.Channel_world then
        self.btn_switch.Visible = self.cvs_hornVisible
        local up = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|26", self.btn_switch.Layout.Style, self.btn_switch.Layout.ClipSize);
        local down = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|26", self.btn_switch.LayoutDown.Style, self.btn_switch.LayoutDown.ClipSize);
        self.btn_switch:SetLayout(up, down)  
    elseif channel == ChatModel.ChannelState.Channel_union or channel == ChatModel.ChannelState.Channel_group then
        local up = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|10", self.btn_switch.Layout.Style, self.btn_switch.Layout.ClipSize);
        local down = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|12", self.btn_switch.LayoutDown.Style, self.btn_switch.LayoutDown.ClipSize);
        self.btn_switch:SetLayout(up, down)
        self.btn_switch.Visible = true
    elseif channel == ChatModel.ChannelState.Channel_private then
        local up = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|11", self.btn_switch.Layout.Style, self.btn_switch.Layout.ClipSize);
        local down = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/chat/chat.xml|chat|9", self.btn_switch.LayoutDown.Style, self.btn_switch.LayoutDown.ClipSize);
        self.btn_switch:SetLayout(up, down)
        self.btn_switch.Visible = true
    else
        self.btn_switch.Visible = false
    end
end

local function HandleInputFinishCallBack(displayNode, self)
    
    local msg = ""
    msg = ChatUtil.HandleInputToOriginal(self.m_TxtinputPrivate.Input.text)
    self.m_StrTmpOriginal = ""
    
    AddStringInput(msg, self)
    self.m_TxtinputPrivate.Input.text = " "
end

local function OnClickCallback(data, self)
    
    local curdata = {}
    if data.serverData ~= nil then
        curdata.name=data.serverData.s2c_name
        curdata.lv=data.serverData.s2c_level
        curdata.playerId = data.s2c_playerId
        curdata.pro = data.serverData.s2c_pro
        _M.SetAcceptRoleData(curdata, self)
    else
        self.s2c_isAtAll = 1
        self.m_titleMsg = "@" .. data.s2c_name
        AddStringInput(ChatUtil.HandleInputToOriginal(self.m_TxtinputPrivate.Input.text), self)
    end
end

local function OnClickSwitch( displayNode, self)
    
    if self.m_curChannel == ChatModel.ChannelState.Channel_world then
        _M.ShowHornChannel(self)
    else
    	local pos = displayNode:LocalToGlobal()
        local node, luaobj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatPersonList, 0)
        local chatlist = ChatModel.GetCharacterList(self.m_curChannel)
        if self.m_curChannel == ChatModel.ChannelState.Channel_group then
            chatlist = ChatUtil.DealTeamData(chatlist)
        elseif self.m_curChannel == ChatModel.ChannelState.Channel_union then
            chatlist = ChatUtil.DealUnionData(chatlist)
        elseif self.m_curChannel == ChatModel.ChannelState.Channel_private then
            chatlist = ChatUtil.DealPrivateData(chatlist)
        end
        luaobj.SetData(chatlist, function(data)
            
            OnClickCallback(data, self)
        end, ChatModel.mSettingItems[self.m_curChannel].Lefttimes, pos)
    end
end

local function InitUI(self)
    
    local UIName = {
        "btn_switch",
        "btn_talk",
        "tbt_expression",
        "btn_enter",
        "btn_jianpan",
        "btn_yuyin",
        "cvs_input",
        "cvs_input2",
        "cvs_input1",
        "lb_click",
        "lb_tishi1",
        "ib_tishi",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end
end

local function InitCompnent(self)
    InitUI(self)
    self.btn_switch.TouchClick = function(displayNode)
        
        OnClickSwitch(displayNode, self)
    end

    ChatSendVoice.Init(self.m_Root, self, self.btn_talk)

    self.tbt_expression.TouchClick = function (displayNode, pos)
        OnClickBiaoqing(self,displayNode,pos)
    end

    self.btn_enter.TouchClick = function (displayNode, pos)
        OnClickSendMessage(self, self.m_StrTmpOriginal)
    end

    self.btn_jianpan.TouchClick = function (displayNode, pos)
        OnClickJianPan(displayNode, self)
    end

    self.btn_yuyin.TouchClick = function (displayNode, pos)
        OnClickYuyin(displayNode, self)
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

    self.cvs_hornVisible = false
    self.m_StrTmpOriginal = ""
    self.m_titleMsg = ""
    self.m_IsVioceOn = false
end

local function CountLength(str, self)
    
    if self.m_contentText == nil then
        self.m_contentText = HZRichTextPan.New();
        self.m_contentText.Size2D = self.m_TxtinputPrivate.Size2D
        self.m_contentText.RichTextLayer.UseBitmapFont = true
        self.m_contentText.RichTextLayer:SetEnableMultiline(false)
        self.m_contentText.TextPan.Width = self.m_TxtinputPrivate.Size2D.x
        self.m_TxtinputPrivate:AddChild(self.m_contentText)
        self.m_contentText.Visible = false;
        self.m_contentText.X = 10
        self.m_contentText.Y = 10
    end
    local linkdata = ChatUtil.HandleChatClientDecode(str, 0xffffffff)
    self.m_contentText.RichTextLayer:SetString(linkdata)
    if self.m_contentText.RichTextLayer.ContentWidth > 1200 then
        return false
    else
        return true
    end
end

local function DefalutInitChannel(channel, self)
    if self.m_IsVioceOn then
        self.cvs_input2.Visible = true
    else
        self.cvs_input.Visible = true
    end
    self.cvs_input1.Visible = false

    AddStringInput(ChatUtil.HandleInputToOriginal(self.m_TxtinputPrivate.Input.text), self)
    ChatSendVoice.InitChannel(channel, self)
end

function _M.SetDefaultPerson(self)
    
    local chatdata = ChatModel.GetLastSpeakPerson(self.m_curChannel)
    if chatdata ~= nil then
        OnClickCallback(chatdata, self)
    end
end

function _M.ShowHornChannel(self, force)
    if force == nil then
        if self.cvs_hornVisible then
            self.cvs_hornVisible = false
            self.btn_switch.Visible = false
        else
            self.cvs_hornVisible = true
            self.btn_switch.Visible = true
			_M.OpenSpeaker(self, nil) 
        end
    else
        self.cvs_hornVisible = force
        self.btn_switch.Visible = force
		if force == true then
			_M.OpenSpeaker(self, nil) 
		end
    end
end

function _M.SetCopyData(str, self)
    local limit =  CountLength(self.m_StrTmpOriginal .. str, self)
    if limit then
        AddStringInput(str, self, true)
    else
        
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'input_limit'))
    end
end

function _M.SetAcceptRoleData(data, self)
    
    if data ~= nil and data.playerId == DataMgr.Instance.UserData.RoleID then
        return
    end
    self.privateRoleData = data
    if data ~= nil then
        self.m_acceptRoleId = self.privateRoleData.playerId
        self.s2c_isAtAll = 2   
    else
        self.m_acceptRoleId = ""
        self.s2c_isAtAll = 0
    end

    
    if self.m_curChannel == ChatModel.ChannelState.Channel_private then
        self.m_titleMsg = ChatUtil.GetPrivateChatTitle(self.privateRoleData) 
    else
        self.m_titleMsg = ChatUtil.GetAtChatTitle(self.privateRoleData)
    end 
    AddStringInput(ChatUtil.HandleInputToOriginal(self.m_TxtinputPrivate.Input.text), self)
    
end

local function GetActionData(channel)
    
    local data = {} 
    local search_t = {}
    if channel == ChatModel.ChannelState.Channel_world then
        search_t = {WorldValid = 1}
    elseif channel == ChatModel.ChannelState.Channel_union then
        search_t = {GuildValid = 1}
    elseif channel == ChatModel.ChannelState.Channel_group then
        search_t = {TeamValid = 1}
    elseif channel == ChatModel.ChannelState.Channel_private then
        search_t = {PrivateValid = 1}
    elseif channel == ChatModel.ChannelState.Channel_crossServer then
        search_t = {InterServiceValid = 1}
    end
    data = GlobalHooks.DB.Find('Action',search_t)
    return data
end

function _M.MakeAction(self, selPersion)
    
    if not (selPersion ~= nil and selPersion.s2c_playerId ~= DataMgr.Instance.UserData.RoleID)
     and self.m_curChannel == ChatModel.ChannelState.Channel_private and self.privateRoleData ~= nil then
        local selplayer = {}
        selplayer.s2c_playerId = self.privateRoleData.playerId
        selplayer.s2c_name = self.privateRoleData.name
        selplayer.s2c_level = self.privateRoleData.lv
        selplayer.s2c_pro = self.privateRoleData.pro
        self.m_selPersion = selplayer
    else
        self.m_selPersion = selPersion
    end

    local data = GetActionData(self.m_curChannel) 
    if data ~= nil and #data > 0 then
		local lua_obj = nil
		
		if self.chat_tab_list ~= nil and self.chat_tab_list.ChatUIActionMenu ~= nil then
			lua_obj = self.chat_tab_list.ChatUIActionObj	
			self.chat_tab_list.ChatUIActionObj:AddToChatExtend(self.chat_tab_list,data)
		else
			local node,obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIChatAction, 0)  
			self.chat_tab_list.ChatUIActionObj = obj
			self.chat_tab_list.ChatUIActionMenu = node   
			lua_obj = obj
		end
		
		lua_obj.faceCb = function(type1, data1, data2)
				if type1 == 3 then    
					self.m_selPersion = nil
				else
					AddChatAction(data1, data, self)
				end
			end
		lua_obj:AddToChatExtend(self.chat_tab_list,data)
		
       
    end
end

function _M.OpenSpeaker(self,resave)
	local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatSpeaker, 0)
	self.chat_speaker = lua_obj	
	lua_obj.InitData(self)
	lua_obj.OnClickCb = function(msg)
		OnClickSendMessage(self, msg)
	end
	
	lua_obj.OnExtendCb = function(test)
		self.ClickExtend()
	end	
	
	lua_obj.OnCloseCb = function()
		self.chat_speaker = nil	
		self.ClickLaba()
	end		
end

function _M.InitChannel(channel, self)
    
    self.m_curChannel = channel
    self.m_titleMsg = ""
    self.privateRoleData = nil
    self.s2c_isAtAll = 0
    self.ib_tishi.Visible = true
    DealSwitchBtnPic(channel,self)
    
    if (self.m_curChannel == ChatModel.ChannelState.Channel_group and DataMgr.Instance.TeamData.HasTeam == false)
        or self.m_curChannel == ChatModel.ChannelState.Channel_system then
        self.cvs_input.Visible = false
        self.cvs_input2.Visible = false
        self.cvs_input1.Visible = true
        if self.m_curChannel == ChatModel.ChannelState.Channel_group then
            self.lb_tishi1.Text = Util.GetText(TextConfig.Type.CHAT, 'no_team')
        else
            self.lb_tishi1.Text = Util.GetText(TextConfig.Type.CHAT, 'message1')
            self.ib_tishi.Visible = false
        end

        AddStringInput(ChatUtil.HandleInputToOriginal(self.m_TxtinputPrivate.Input.text), self)
        ChatSendVoice.InitChannel(channel, self)
    elseif self.m_curChannel == ChatModel.ChannelState.Channel_union then
        GDRQ.getMyGuildInfoRequestWithoutWait(function (param)
            if table.getCount(param) > 1 then
                if self.m_IsVioceOn then
                    self.cvs_input2.Visible = true
                else
                    self.cvs_input.Visible = true
                end
                self.cvs_input1.Visible = false

                local uniondata = {}
                if param.baseInfo.presidentId == DataMgr.Instance.UserData.RoleID then
                    uniondata.s2c_name = Util.GetText(TextConfig.Type.CHAT, 'all') .. " "
                else
                    uniondata.serverData = {}
                    uniondata.serverData.s2c_name = param.baseInfo.presidentName
                    uniondata.serverData.s2c_pro = param.baseInfo.presidentPro
                    uniondata.serverData.s2c_level = param.baseInfo.presidentLevel 
                    uniondata.s2c_playerId = param.baseInfo.presidentId
                end
                ChatUtil.UnionData = uniondata
            else
                self.cvs_input.Visible = false
                self.cvs_input2.Visible = false
                self.cvs_input1.Visible = true
                self.lb_tishi1.Text = Util.GetText(TextConfig.Type.CHAT, 'canjoin_guild')
            end
            
            AddStringInput(ChatUtil.HandleInputToOriginal(self.m_TxtinputPrivate.Input.text), self)
            ChatSendVoice.InitChannel(channel, self)
        end)
    elseif self.m_curChannel == ChatModel.ChannelState.Channel_crossServer then
        local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
        if sceneType ~= PublicConst.SceneType.CrossServer then
            self.cvs_input.Visible = false
            self.cvs_input2.Visible = false
            self.cvs_input1.Visible = true
            self.lb_tishi1.Text = Util.GetText(TextConfig.Type.CHAT, 'only_connect')
        else
            DefalutInitChannel(channel, self)
        end
    elseif self.m_curChannel == ChatModel.ChannelState.Channel_ally then
        DaoyouModel.ReqDaoqunInfo(function (data)
            if data and data.isHasDaoYou == 1 then
                DefalutInitChannel(channel, self)
            else
                self.cvs_input.Visible = false
                self.cvs_input2.Visible = false
                self.cvs_input1.Visible = true
                self.lb_tishi1.Text = Util.GetText(TextConfig.Type.CHAT, 'no_ally')
            end

        end)
    else
        DefalutInitChannel(channel, self)
    end
    
end

function _M.VoiceChatUpate(self)
    if self.canClearMsg ~= nil and self.canClearMsg then
        self.canClearMsg = false
        clearMsg(self)
    end
    ChatSendVoice.VoiceChatUpate(self)
end

function _M.ClickExpression(self,displayNode,pos)
    OnClickBiaoqing(self,displayNode,pos)
end

function _M.OnClickShowItem(self,displayNode,pos)
    OnClickChatItem(self,displayNode,pos)
end

function _M.OnDestory(self)
    
    ChatSendVoice.OnDestory(self)
    if self.chat_tab_list then
        self.chat_tab_list.ChatUIFaceObj = nil
        self.chat_tab_list.ChatUIFaceMenu = nil   
    end
    EventManager.Unsubscribe("Event.ShowNpcTalk", _M.OnShowNpcTalk)
    clearMsg(self)
end

function _M.Init(m_Root, self)
    self.m_Root = m_Root
	InitCompnent(self)
end

function _M.OnShowNpcTalk(eventname, params)
    ChatSendVoice.AbortRecord(_M.self) 
end

function _M.OnEnter(self)
	ChatSendVoice.OnEnter(self)
    _M.self = self
    EventManager.Subscribe("Event.ShowNpcTalk", _M.OnShowNpcTalk)
end

function _M.OnExit(self)
    _M.self = nil
    ChatSendVoice.OnExit(self)
    EventManager.Unsubscribe("Event.ShowNpcTalk", _M.OnShowNpcTalk)
end

function _M.CommonChatMsg(self, msg, cb)
    
    self.m_StrTmpOriginal = ""
    _M.SetCopyData(msg, self)
    if cb ~= nil then
        cb()
    end
end

function _M.OnSendMessage(self, msg)
    
    OnClickSendMessage(self, msg)
end


function _M.OnSendFunMsg(self, msg, type)
    
    if self.m_curChannel == ChatModel.ChannelState.Channel_private and self.privateRoleData == nil then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'chat_object'))
        return
    end
    ChatModel.chatMessageRequest(self.m_curChannel, msg, self.m_acceptRoleId, function (param)
    end, nil, nil, type)
end

return _M
