


local Team 				= require "Zeus.Model.Team"
local Util 				= require "Zeus.Logic.Util"
local ChatModel 		= require 'Zeus.Model.Chat'
local ChatUtil  		= require "Zeus.UI.Chat.ChatUtil"
local ExchangeUtil      = require "Zeus.UI.ExchangeUtil"
local _M = {
    tag = nil
}
_M.__index = _M

local fubenHardColors = {
    0x21b2efff, 0xcc00ffff, 0xf43a1cff
}

local function DealLink(msgData, content)
	
	local datastr = "<f link = '|1|'>|2|</f>"
    local data = {}
    data[1] = ChatUtil.MsgConvertToStr(msgData, ChatUtil.LinkType.LinkTypeRecruit)
    data[2] = content
    datastr = ChatUtil.HandleString(datastr, data)
    return datastr
end

local ui_names = {
    {name = "cvs_zs"},
    {name = "cvs_ck"},
    {name = "cvs_fs"},
    {name = "cvs_lr"},
    {name = "cvs_ms"},
    {name = "lb_message"},
    {name = "btn_left",click = function(self)
        self:DealButton(self.selindex - 1)
    end},
    {name = "btn_right",click = function(self)
        self:DealButton(self.selindex + 1)
    end},
    {name = "tb_sendmessage"},
    {name = "btn_send",click = function(self)
        if self.tag == 1 then
            Team.RequestApplyTeamByTeamId(self.data.teamId, function ( ... )
    	        
    	        self.menu:Close()
            end)
        else
            self.data.sendPlayerId = DataMgr.Instance.UserData.RoleID
            self.data.slogans = self.slogans[self.selindex]
            self.data.selectProfessional = self.selectProfessional
            local str = "<f color='ffab82ff'>" ..  self.sendMsg .. Util.GetText(TextConfig.Type.TEAM, "sendmessageend")  .. "</f>"
            ChatModel.chatMessageRequest(ChatModel.ChannelState.Channel_world, DealLink(self.data, str), "", function (param)
    	        self.menu:Close()
    	        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM,'sendmessage'))
            end, nil, nil, 3)
        end
    end},
    {name = "btn_send_guild",click = function(self)
        self.data.sendPlayerId = DataMgr.Instance.UserData.RoleID
        self.data.slogans = self.slogans[self.selindex]
        self.data.selectProfessional = self.selectProfessional
        local str = "<f color='ffab82ff'>" ..  self.sendMsg .. Util.GetText(TextConfig.Type.TEAM, "sendmessageend")  .. "</f>"
        ChatModel.chatMessageRequest(ChatModel.ChannelState.Channel_union, DealLink(self.data, str), "", function (param)
            self.menu:Close()
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM,'sendmessage'))
        end, nil, nil, 3)

    end},
    {name = "btn_cancel",click = function(self)
        self.menu:Close()
    end},
}

local function RefreshSendmessage(self)
	
	self.sendMsg = Util.GetText(TextConfig.Type.TEAM, "teaminvite")
	local data = {}
    data[1] = self.data.targetName
    data[2] = ExchangeUtil.GetItemNameColor(Util.GetText(TextConfig.Type.FUBEN, "hardName" .. self.data.diffcult), GameUtil.RGBA_To_ARGB(fubenHardColors[self.data.diffcult]))
    data[3] = self.slogans[self.selindex]
    if self.data.needuplv ~= nil and self.data.needuplv > 0 then
	    local text, rgba = Util.GetUpLvTextAndColorRGBA(self.data.needuplv)
	    data[4] = ExchangeUtil.GetItemNameColor(text, GameUtil.RGBA_To_ARGB(rgba))
	else
		if self.data.needlv > 0 then
			data[4] = string.gsub(Util.GetText(TextConfig.Type.TEAM, "teaminviteLv"), "|1|", self.data.needlv)
		else
			data[4] = Util.GetText(TextConfig.Type.TEAM, "inviteNOLv")
		end
	end
    






	self.sendMsg = ChatUtil.HandleString(self.sendMsg, data)
	local find = 0
	local content = ""
	for i = 1, #self.selectProfessional do
		if self.selectProfessional[i] then
			if content == "" then
				content = content .. Util.GetText(TextConfig.Type.ITEM, "proLimit" .. i)
			else
				content = content .. Util.GetText(TextConfig.Type.FUBEN, "comma") .. Util.GetText(TextConfig.Type.ITEM, "proLimit" .. i)
			end
			find = find + 1
		end
	end
	if find == 0 or find == 5 then
		content = Util.GetText(TextConfig.Type.ITEM, "proLimit0")
	end
	self.sendMsg = self.sendMsg .. content 
	self.tb_sendmessage.XmlText = "<f color='ffab82ff'>" ..  self.sendMsg .. "</f>"
end

function _M:DealButton(index)
	
	self.selindex = index
	if self.selindex <= 1 or #self.slogans <= 1 then
		self.selindex = 1
		self.btn_left.Visible = false
	else
		self.btn_left.Visible = true
	end
	
	if self.selindex >= #self.slogans then
		self.selindex = #self.slogans
		self.btn_right.Visible = false
	else
		self.btn_right.Visible = true
	end
	self.lb_message.Text = self.slogans[self.selindex]
	RefreshSendmessage(self)
end

function _M:SetInfo(data)
    self.data = data
    if data.sendPlayerId == DataMgr.Instance.UserData.RoleID and self.params == 1 then
		self.btn_send.Visible = false
        self.btn_send_guild.Visible = false
		
		self.btn_cancel.Visible = false
	end
    self.slogans = {}
	if data.slogans == nil then
		self.slogans = split(Util.GetText(TextConfig.Type.FUBEN, "slogans"), '|')
    	self:DealButton(DataMgr.Instance.UserData.Pro)
        
        self.tag = 0
    else
    	self.slogans[1] = data.slogans
    	self:DealButton(DataMgr.Instance.UserData.Pro)
        self.btn_send.Text = Util.GetText(TextConfig.Type.TEAM, "shenqing2")
        self.tag = 1
    end
end

local function OnClickSelProfessional(self,node,index)
    self.selectProfessional[index] = node.IsChecked
	RefreshSendmessage(self)
end

local function InitComponent(self)
    self.menu = LuaMenuU.Create("xmds_ui/team/shout.gui.xml", GlobalHooks.UITAG.GameUITeamRecruit)
    self.menu.Enable = true
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.menu.IsInteractive = true
    self.menu.event_PointerClick = function()
        self.menu:Close()
    end
    self.cvsBtns = {self.cvs_zs,self.cvs_ck,self.cvs_fs,self.cvs_lr,self.cvs_ms}
    self.selectProfessional = {
    	false,
        false,
        false,
        false,
        false,
	}

    for i = 1,#self.cvsBtns,1 do
        local button = self.cvsBtns[i]:FindChildByEditName("tbt_icon", true)
		button.IsChecked = false
		button.TouchClick = function(displayNode)
			
			OnClickSelProfessional(self,displayNode, i)
		end
    end
end

function _M.Create()
    local self = {}
    setmetatable(self,_M)
    InitComponent(self)
    return self
end

return _M

