local ChatUtil = require "Zeus.UI.Chat.ChatUtil"
local ChatModel = require "Zeus.Model.Chat"
local FriendModel = require "Zeus.Model.Friend"
local ChatSendVoice = require "Zeus.UI.Chat.ChatSendVoice"

local DaoyouModel = require 'Zeus.Model.Daoyou'
local Util = require "Zeus.Logic.Util"
local SoloHud = require "Zeus.UI.XmasterSolo.SoloHud"

local GDRQ = require "Zeus.Model.Guild"



local PetModel = require 'Zeus.Model.Pet'

local RecycleModel = require "Zeus.Model.Recycle"
local Relive = require "Zeus.Model.Relive"
local ReliveUI = require "Zeus.Model.Relive"

local CDLabelExt = require "Zeus.Logic.CDLabelExt"
local ItemModel = require 'Zeus.Model.Item'
local TeamModel = require 'Zeus.Model.Team'
local _5v5Hud = require 'Zeus.UI.Xmaster5V5.5V5Hud'
local BossFightModel  = require 'Zeus.Model.BossFight'
local FubenApi = require "Zeus.Model.Fuben"
local ArenaApi = require "Zeus.Model.Arena"
local PlayerModel = require "Zeus.Model.Player"
local ServerTime = require "Zeus.Logic.ServerTime"


local self = {
    root = nil,
    btn_gift = nil,
    btn_sign = nil,
    autobuy = { },
    teamtips = { },
}

local UIFlags = {
    "lb_bj_mall",
    
    "lb_bj_welfare",
    
    
    "lb_bj_activity",
    "lb_bj_target",
    "lb_bj_mail",
}

local oldMusicVolume = XmdsSoundManager.GetXmdsInstance():GetBGMVolume()
local oldSoundVolume = XmdsSoundManager.GetXmdsInstance():GetEffectVolume()

local string_format_time = Util.GetText(TextConfig.Type.FUBEN,'leaveCD')

local function OnClickBtnWelfare(displayNode)
    if true == self.welfare_canGet then
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIOnlineWelfare, 0, tostring(true));
    else
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIOnlineWelfare, 0, self.cvs_welfare:FindChildByEditName("lb_welfaretime", true).Text);
    end
end


local chat_channel_tab = {
	ChatModel.ChannelState.Channel_world,
	ChatModel.ChannelState.Channel_union,
	ChatModel.ChannelState.Channel_group,
	ChatModel.ChannelState.Channel_ally
}
local function GetChannelTextById(channel_id)
	local chat_setting = GlobalHooks.DB.Find('ChatSetting', {})
    for i = 1, #chat_setting do
		if chat_setting[i].ChannelID == channel_id then
			return chat_setting[i].ChannelShort
		end
    end
end

local function SetChannelEnabled(channel_id,btn_channel)
	if channel_id == ChatModel.ChannelState.Channel_world then
		btn_channel.Enable = true
	elseif channel_id == ChatModel.ChannelState.Channel_union then 
		GDRQ.getMyGuildInfoRequestWithoutWait(function (param)
			btn_channel.Enable = (table.getCount(param) > 1) 
        end)
	elseif channel_id == ChatModel.ChannelState.Channel_group then 
		btn_channel.Enable = DataMgr.Instance.TeamData.HasTeam	
	elseif channel_id == ChatModel.ChannelState.Channel_ally then
        if GlobalHooks.CheckFuncOpenByTag(GlobalHooks.UITAG.GameUISocialDaoqun) then
            DaoyouModel.ReqDaoqunInfo(function (data)
                if data and data.isHasDaoYou == 1 then
                    btn_channel.Enable = (data.s2c_list ~= nil)
                end
            end)
        else
            btn_channel.Enable = false
        end
	end
	
	if btn_channel.Enable == true then
		btn_channel.FontColor = GameUtil.RGBA2Color(0xddf2ffff)
	else 
		btn_channel.FontColor = GameUtil.RGBA2Color(0x9aa9b5ff)
	end
end

function OnClickCHatCHannelSwitch(channel_id)
	self.cvs_channel.Visible = false
	self.curIndex = channel_id
	self.tbt_channel.IsChecked = false
	InitChatChannelSwitchText()
end

function InitChatChannelSwitchText()
	local channel_pop_tab = {}
	for _,v in pairs(chat_channel_tab) do
		if v ~= self.curIndex then
			table.insert(channel_pop_tab,v)
			
		else
			self.tbt_channel.Text = GetChannelTextById(v)
		end
	end
	for i = 1,#(channel_pop_tab) do
		self["btn_channel"..i].Text = GetChannelTextById(channel_pop_tab[i])
		SetChannelEnabled(channel_pop_tab[i],self["btn_channel"..i])
		self["btn_channel"..i].TouchClick = function(sender)
			OnClickCHatCHannelSwitch(channel_pop_tab[i])
		end
	end
	
	self.btn_notice1.Visible = self.tbt_channel.Enable
	ChatSendVoice.InitChannel(self.curIndex, self)
end

local function ShowChatChannelSwitch()
	self.cvs_channel.Visible = not self.cvs_channel.Visible
	InitChatChannelSwitchText()
end

local function OnClickBtnBag(displayNode)
    
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBagMain, 0)
end

local function OnClickBtnAutofight(displayNode)
    if DataMgr.Instance.TeamData.TeamFollow == 1 then
        displayNode.IsChecked = false
        GameAlertManager.Instance:ShowNotify("跟随状态不能执行该操作")
    end
    local isAutoFight = displayNode.IsChecked
    EventManager.Fire("Event.Quest.CancelAuto", {});
    DataMgr.Instance.UserData.AutoTarget = "point:0"
    DataMgr.Instance.UserData.AutoFight = isAutoFight
    EventManager.Fire("Event.Delivery.Close", {});
    Util.clearAllEffect(displayNode)
end

local function OnAutoFightStatusChange(eventname, params)
    local tb_autofight = self.root:FindChildByEditName("tb_autofight", true)
    if tb_autofight ~= nil then
        local isAutoFight = tostring(params.status) == "True"
        tb_autofight.IsChecked = isAutoFight
       
        
       
    end
end

local function OnClickBtnMail(displayNode)
    DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.MailReceive)
    local MailRq = require "Zeus.Model.Mail"
    MailRq.MailGetAllRequest(
    function()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIMail, 0)
    end
    )
end

local function OnShowHudMenu(eventname, params)
   self.cvs_topright.Visible = false   
    
end

local function OnCloseMenu(eventname, params)
    
    self.cvs_topright.Visible = true 
end

local function OnShowCharacter(eventname, params)
    local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleAttribute, 0)
    
end

local function ShowReliveBtn(eventname, params)
    self.cvs_revive.Visible = true
end

local function ShowMainMenuBtn(eventname, params)
    MenuBaseU.SetVisibleUENode(self.root, "lb_bj_menu", params.show)
end

local function SetMailNum()
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_MAIL)
    
    MenuBaseU.SetVisibleUENode(self.root, "lb_bj_mail", num ~= 0)
    self.lb_bj_mail = num ~= 0
end

local fristActiveRedPoint = true 
local function SetActivityFlag()
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_CENTER)
    if num == 0 and fristActiveRedPoint == true then 
        MenuBaseU.SetVisibleUENode(self.root, "lb_bj_activity", GlobalHooks.CheckFuncIsOpenByName(GlobalHooks.UITAG.GameUIActivityHJBoss,false)) 
    else
        MenuBaseU.SetVisibleUENode(self.root, "lb_bj_activity", num ~= 0)
    end
    self.lb_bj_activity = num ~= 0
end
local function stopLimitGiftLabel()
    if self.CDLabelExtLmitGift ~= nil then
        self.CDLabelExtLmitGift:stop()
        self.CDLabelExtLmitGift = nil
    end
end
local function RemoveAllActivityFlagEvent()
    for i=1,6 do
        RemoveUpdateEvent("Event.Activity.FlagEvent"..i, true)
    end
    stopLimitGiftLabel()
end

local function UpdateActivityFlagTimeStr(label, timeSeq, index)
    
    local currTime = ServerTime.GetServerUnixTime()
    local nowTime = GameUtil.NormalizeTimpstamp(currTime)
    local nowCount = nowTime.Hour*3600+nowTime.Minute*60+nowTime.Second

    
    if self.flagTimeCount then
        local tmp = self.flagTimeCount - nowCount
        if tmp < 10 and tmp > 0 then
            return
        end
    end
    self.flagTimeCount = nowCount

    for i,v in ipairs(timeSeq) do
        local time = string.split(v, '-')
        local startHour = tonumber(string.split(time[1], ':')[1])
        local startMinute = tonumber(string.split(time[1], ':')[2])
        local startTimeCount = startHour*3600+startMinute*60
        local endHour = tonumber(string.split(time[2], ':')[1])
        local endMinute = tonumber(string.split(time[2], ':')[2])
        local endTimeCount = endHour*3600+endMinute*60
        if (nowCount >= startTimeCount and nowCount <= endTimeCount) then
            local cutDown = endTimeCount - nowCount
            local h = math.floor(cutDown/3600)
            local m = math.floor(cutDown/60)-h*60
            local s = cutDown-h*3600-m*60
            if h == 0 then
                h = ""
            elseif h < 10 then
                h = "0"..h..":"
            else
                h = h..":"
            end
            if m == 0 then
                m = "00"..":"
            elseif m < 10 then
                m = "0"..m..":"
            else
                m = m..":"
            end
            if s == 0 then
                s = "00"
            elseif s < 10 then
                s = "0"..s
            end
            label.Text = h..m..s
            return
        end
    end

    label.Text = ""
end
local function UpdateLimitTimeStr( timeSeq,label )
    local last = math.floor(timeSeq)
    local h = math.floor(last/3600)
    local m = math.floor(last/60)-h*60
    local s = last-m*60-h*3600
    if h == 0 then
        h = ""
    elseif h < 10 then
        h = "0"..h..":"
    else
        h = h..":"
    end
    if m == 0 then
        m = "00"..":"
    elseif m < 10 then
        m = "0"..m..":"
    else
        m = m..":"
    end
    if s == 0 then
        s = "00"
    elseif s < 10 then
        s = "0"..s
    end
    label.Text = h..m..s
    return  
end
local function OpenLimitGiftUI(eventname, params)
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUILimitGift, -1)
end
local function SetActivityOpenFlag()
    RemoveAllActivityFlagEvent()

    
    local kuanghuanCount = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_KUANGHUAN)
    local posX = {}
    if kuanghuanCount > 0 then
        posX = {418,339,258,177,96,15}
    else
        posX = {497,418,339,258,177,96}
    end
    local showCount = 1
    local cvs_yaozu = self.root:FindChildByEditName("cvs_yaozu", true)
    local num_yaozu = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_YAOZU)
    cvs_yaozu.Visible = num_yaozu ~= 0
    if cvs_yaozu.Visible then
        local data = GlobalHooks.DB.Find('Schedule',13)
        local btn_yaozu = cvs_yaozu:FindChildByEditName("btn_yaozu", true)
        
        local currTime = math.floor(ServerTime.GetServerUnixTime())
        local hour = tonumber(os.date("%H",currTime))
        local openTimeStr = string.split(data.OpenPeriod,";")[1]
        local openHourStr = string.split(openTimeStr,'-')
        local startHour = tonumber(string.split(openHourStr[1],":")[1])
        local endHour = tonumber(string.split(openHourStr[2],":")[1])
        local index = 0
        if hour >= startHour and hour <= endHour then
            index = 3
        else
            index = 4
        end
        btn_yaozu.TouchClick = function()
            EventManager.Fire('Event.Goto', {id = "Lingzhu"})
            EventManager.Fire('Event.GoToYaoZu',{tag = index})
        end

        local ib_yaozu_wait = cvs_yaozu:FindChildByEditName("ib_yaozu_wait", true)
        ib_yaozu_wait.Visible = num_yaozu == 1

        local lb_bj_yaozu = cvs_yaozu:FindChildByEditName("lb_bj_yaozu", true)
        lb_bj_yaozu.Visible = num_yaozu == 2
        
        local lb_yaozu_time = cvs_yaozu:FindChildByEditName("lb_yaozu_time", true)
        lb_yaozu_time.Visible = num_yaozu == 2
        if lb_yaozu_time.Visible then
            local timeSeq = string.split(data.PeriodInCalendar, ';')
            AddUpdateEvent("Event.Activity.FlagEvent1", function(deltatime)
                UpdateActivityFlagTimeStr(lb_yaozu_time, timeSeq, 1)
            end)
        end

        cvs_yaozu.X = posX[showCount]
        showCount = showCount + 1
    end

    local cvs_wuyue = self.root:FindChildByEditName("cvs_wuyue", true)
    local num_wuyue = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_WUYUE)
    cvs_wuyue.Visible = num_wuyue ~= 0
    if cvs_wuyue.Visible then
        local data = GlobalHooks.DB.Find('Schedule',7)
        local btn_wuyue = cvs_wuyue:FindChildByEditName("btn_wuyue", true)
        btn_wuyue.TouchClick = function()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIMultiPvpFrame, 0)
        end

        local ib_wuyue_wait = cvs_wuyue:FindChildByEditName("ib_wuyue_wait", true)
        ib_wuyue_wait.Visible = num_wuyue == 1

        local lb_bj_wuyue = cvs_wuyue:FindChildByEditName("lb_bj_wuyue", true)
        lb_bj_wuyue.Visible = num_wuyue == 2

        local lb_wuyue_time = cvs_wuyue:FindChildByEditName("lb_wuyue_time", true)
        lb_wuyue_time.Visible = num_wuyue == 2
        if lb_wuyue_time.Visible then
            local timeSeq = string.split(data.PeriodInCalendar, ';')
            AddUpdateEvent("Event.Activity.FlagEvent2", function(deltatime)
                UpdateActivityFlagTimeStr(lb_wuyue_time, timeSeq, 2)
            end)
        end

        cvs_wuyue.X = posX[showCount]
        showCount = showCount + 1
    end

    local cvs_wendao = self.root:FindChildByEditName("cvs_wendao", true)
    local num_wendao = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_WENDAO)
    cvs_wendao.Visible = num_wendao ~= 0
    if cvs_wendao.Visible then
        local data = GlobalHooks.DB.Find('Schedule',6)
        local btn_wendao = cvs_wendao:FindChildByEditName("btn_wendao", true)
        btn_wendao.TouchClick = function()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISolo)
        end

        local ib_wendao_wait = cvs_wendao:FindChildByEditName("ib_wendao_wait", true)
        ib_wendao_wait.Visible = num_wendao == 1

        local lb_bj_wendao = cvs_wendao:FindChildByEditName("lb_bj_wendao", true)
        lb_bj_wendao.Visible = num_wendao == 2

        local lb_wendao_time = cvs_wendao:FindChildByEditName("lb_wendao_time", true)
        lb_wendao_time.Visible = num_wendao == 2
        if lb_wendao_time.Visible then
            local timeSeq = string.split(data.PeriodInCalendar, ';')
            AddUpdateEvent("Event.Activity.FlagEvent3", function(deltatime)
                UpdateActivityFlagTimeStr(lb_wendao_time, timeSeq, 3)
            end)
        end

        cvs_wendao.X = posX[showCount]
        showCount = showCount + 1
    end

    local cvs_shilian = self.root:FindChildByEditName("cvs_shilian", true)
    local num_shilian = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_SHILIAN)
    cvs_shilian.Visible = num_shilian ~= 0
    if cvs_shilian.Visible then
        local data = GlobalHooks.DB.Find('Schedule',8)
        local btn_shilian = cvs_shilian:FindChildByEditName("btn_shilian", true)
        btn_shilian.TouchClick = function()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUI5V5Main)
        end

        local ib_shilian_wait = cvs_shilian:FindChildByEditName("ib_shilian_wait", true)
        ib_shilian_wait.Visible = num_shilian == 1

        local lb_bj_shilian = cvs_shilian:FindChildByEditName("lb_bj_shilian", true)
        lb_bj_shilian.Visible = num_shilian == 2

        local lb_shilian_time = cvs_shilian:FindChildByEditName("lb_shilian_time", true)
        lb_shilian_time.Visible = num_shilian == 2
        
        if lb_shilian_time.Visible then
            local timeSeq = string.split(data.PeriodInCalendar, ';')
            AddUpdateEvent("Event.Activity.FlagEvent4", function(deltatime)
                UpdateActivityFlagTimeStr(lb_shilian_time, timeSeq, 4)
            end)
        end

        cvs_shilian.X = posX[showCount]
        showCount = showCount + 1
    end

    
    local num_mijing = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACTIVITY_MIJING)
    self.cvs_mijing.Visible = num_mijing ~= 0
    if self.cvs_mijing.Visible then
        local data = GlobalHooks.DB.Find('Schedule',15)
        local btn_mijing = self.cvs_mijing:FindChildByEditName("btn_mijing", true)
        btn_mijing.TouchClick = function()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIMiJing)
        end

        local ib_mijing_wait = self.cvs_mijing:FindChildByEditName("ib_mijing_wait", true)
        ib_mijing_wait.Visible = num_mijing == 1

        local lb_bj_mijing = self.cvs_mijing:FindChildByEditName("lb_bj_mijing", true)
        lb_bj_mijing.Visible = num_mijing == 2

        local lb_mijing_time = self.cvs_mijing:FindChildByEditName("lb_mijing_time", true)
        lb_mijing_time.Visible = num_mijing == 2
        
        if lb_mijing_time.Visible then
            local timeSeq = string.split(data.PeriodInCalendar, ';')
            AddUpdateEvent("Event.Activity.FlagEvent5", function(deltatime)
                UpdateActivityFlagTimeStr(lb_mijing_time, timeSeq, 5)
            end)
        end

        self.cvs_mijing.X = posX[showCount]
        showCount = showCount + 1
    end

    
    local num_xiangmo = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_BOSS_FLAG)
    self.cvs_Gboss.Visible = num_xiangmo ~= 0
    if self.cvs_Gboss.Visible then
        local data = GlobalHooks.DB.Find('Schedule',16)
        local btn_xiangmo = self.cvs_Gboss:FindChildByEditName("btn_Gboss", true)
        btn_xiangmo.TouchClick = function()
            if DataMgr.Instance.UserData.Guild then
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildBoss,0)
            else
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILD, "noguildTips"))
            end
        end

        local ib_xiangmo_wait = self.cvs_Gboss:FindChildByEditName("ib_Gboss_wait", true)
        ib_xiangmo_wait.Visible = num_xiangmo == 1

        local lb_bj_xiangmo = self.cvs_Gboss:FindChildByEditName("lb_bj_Gboss", true)
        lb_bj_xiangmo.Visible = num_xiangmo == 2

        local lb_xiangmo_time = self.cvs_Gboss:FindChildByEditName("lb_Gboss_time", true)
        lb_xiangmo_time.Visible = num_xiangmo == 2
        
        if lb_xiangmo_time.Visible then
            local timeSeq = string.split(data.PeriodInCalendar, ';')
            AddUpdateEvent("Event.Activity.FlagEvent6", function(deltatime)
                UpdateActivityFlagTimeStr(lb_xiangmo_time, timeSeq, 6)
            end)
        end

        self.cvs_Gboss.X = posX[showCount]
        showCount = showCount + 1
    end

    
    local num_guildwar = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_WAR_ACCESS)
    self.cvs_GWar.Visible = num_guildwar > 0
    if self.cvs_GWar.Visible then
        local btn_Gwar = self.cvs_GWar:FindChildByEditName("btn_Gwar", true)
        btn_Gwar.TouchClick = function()
            if DataMgr.Instance.UserData.Guild then
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildBoss,0)
            else
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILD, "noguildTips"))
            end
        end

        local lb_bj_Gwar = self.cvs_GWar:FindChildByEditName("lb_bj_Gwar", true)
        lb_bj_Gwar.Visible = true

        self.cvs_GWar.X = posX[showCount]
        showCount = showCount + 1
    end

    
    local eventId = FlagPushData.FLAG_LIMITGIFT
    local timeCount = DataMgr.Instance.FlagPushData:GetFlagState(eventId)
    self.cvs_Qgift.Visible = timeCount > 0
    if self.cvs_Qgift.Visible then
        local btn_limitGift = self.cvs_Qgift:FindChildByEditName("btn_Qgift", true)
        btn_limitGift.TouchClick = function()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUILimitGift, -1)
        end
        local lb_bj_limitGift = self.cvs_Qgift:FindChildByEditName("lb_bj_Qgift", true)
        lb_bj_limitGift.Visible = timeCount > 0

        local lb_limitGift_time = self.cvs_Qgift:FindChildByEditName("lb_Qgift_time", true)
        lb_limitGift_time.Visible = timeCount > 0
        
        local function format(cd,label)
            if cd <= 0 then
                self.cvs_Qgift.Visible = false
            else
                UpdateLimitTimeStr(cd,label)
            end
        end
        self.CDLabelExtLmitGift = CDLabelExt.New(lb_limitGift_time,timeCount,format,nil,1) 
        self.CDLabelExtLmitGift:start()

        self.cvs_Qgift.X = posX[showCount]
        showCount = showCount + 1
   end
end

local function SetShopmallFlag()
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_SHOPMALL) + 
                DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_VIP)
    MenuBaseU.SetVisibleUENode(self.root, "lb_bj_mall", num ~= 0)
    
    self.lb_bj_mall = num ~= 0
end

local function SetFirstPayFlag()
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_FIRST_PAY)
    MenuBaseU.SetVisibleUENode(self.root, "lb_bj_fp", num ~= 0)
    MenuBaseU.SetVisibleUENode(self.root, "ib_fp", num ~= 0)
    self.lb_bj_fp = num ~= 0
end

local function SetKuanghuanFlag()
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_KUANGHUAN)
    
    if(num>0) then
        self.cvs_kuanghuan.Visible=true
    else
        self.cvs_kuanghuan.Visible=false
    end
end

local function SetWelFareFlag()
    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_WELFARE)
    MenuBaseU.SetVisibleUENode(self.root, "lb_bj_welfare", num ~= 0)
    self.lb_bj_welfare = num ~= 0
end

local function SetHotFlag()
    local num1 = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_HOT_CONTINUE)
    local num2 = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_HOT_RICH)
    local num3 = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_HOT_SEVENTARGET)

    self.cvs_hot.Visible = (num1 + num2 + num3) > 0
    self.lb_bj_hot.Visible = num1 > 1 or num2 > 1 or num3 > 1
end

local function addChatMsg(content, param)
    
    
    if self.chatAction then
        self.lastcontent = content
        return
    end
    self.chatAction = true

    local tb_chatlist = HZRichTextPan.New();
    tb_chatlist.RichTextLayer.UseBitmapFont = true
    tb_chatlist.RichTextLayer:SetEnableMultiline(true)

    tb_chatlist.Width = self.tb_chat.Width
    tb_chatlist.TextPan.Width = self.tb_chat.Width
    tb_chatlist.RichTextLayer:SetWidth(tb_chatlist.TextPan.Width)
    tb_chatlist.RichTextLayer:SetString(content)
    
    tb_chatlist.Size2D = Vector2.New(self.tb_chat.Width, tb_chatlist.RichTextLayer.ContentHeight)

    local display = ChatDisplayNode.New()
    display.IsInteractive = true
    display.Enable = true
    display.EnableChildren = true
    display.HasInitData = true
    display:AddChild(tb_chatlist)

    self.scroll_pan:AddChild(display)

    local fa = DelayAction.New()
    fa.Duration = 0.1
    fa.ActionFinishCallBack = function(sender)
        
        if self.scroll_pan.Container.Height > self.tb_chat.Height then
            local ma = MoveAction.New()
            ma.TargetX = 0
            ma.TargetY = -(self.scroll_pan.Container.Height - self.tb_chat.Height)
            ma.ActionEaseType = EaseType.linear
            ma.Duration = self.scroll_pan.Container.Height * 0.01
            ma.ActionFinishCallBack = function(...)
                
                self.chatAction = false
                if self.lastcontent ~= nil then
                    addChatMsg(self.lastcontent, nil)
                    self.lastcontent = nil
                end
            end
            self.scroll_pan.Container:AddAction(ma)
        else
            self.chatAction = false
            if self.lastcontent ~= nil then
                addChatMsg(self.lastcontent, nil)
                self.lastcontent = nil
            end
        end
    end
    self.scroll_pan.Container:AddAction(fa)
end

local function ChatPushCb(param)
    if param.s2c_sys == 1 then
        
        
        GameAlertManager.Instance:ShowGoRoundBottomTipsXml(param.s2c_content, nil) 
    elseif param.s2c_sys == 2 then
        
        if param.linkdata == nil then
            param.linkdata = ChatUtil.HandleChatClientDecode(param.s2c_content, 0xffffffff)
        end
        GameAlertManager.Instance:ShowHornTipAtt(UIChatDynamicScrollPan.HtmlTextToAttributedString("<font size= '20' color='" .. string.format("%08X", GameUtil.RGBA_To_ARGB(0xf7ffa3ff)) .. "'>" .. param.serverData.s2c_name .. "</font>"), param.linkdata)    
    end

    
    if ChatModel.mSettingItems[param.s2c_scope] ~= nil and ChatModel.mSettingItems[param.s2c_scope].IsHide == 1 then
      return
     end
    
    if param.s2c_scope == ChatModel.ChannelState.Channel_private then return end

    if param.s2c_scope ~= ChatModel.ChannelState.Channel_system then
        
        local msg = ChatUtil.HandleChatMsg(param)
        addChatMsg(msg, param)
    end
end
	
local function RefreshChat(index)
    
    local param = ChatModel.ChatData[index]
    if param ~= nil and #param > 0 then
        local msg = ChatUtil.HandleChatMsg(param[#param])
        addChatMsg(msg, param[#param])
    else
        ChatModel.getSaveChatMsgRequest(index, 0, DataMgr.Instance.UserData.UserId, function()
            
            local param = ChatModel.ChatData[index]
            if param ~= nil and #param > 0 then
                local msg = ChatUtil.HandleChatMsg(param[#param])
                addChatMsg(msg, param[#param])
            end
        end )
    end
end
	

local function LuaHudChatCallBack(index)
    
	InitChatChannelSwitchText()
	if self.tbt_channel.IsChecked == true then
		self.tbt_channel.IsChecked = false
	end	
	self.cvs_channel.Visible = false	
    ChatUtil.ChatMainSecond = nil
end
	
local function OpenChatUIByChannel(channel)
    
    local open = UnityEngine.PlayerPrefs.GetInt(DataMgr.Instance.UserData.RoleID .. "chatSizeModel", 0)
    local node, lua_obj
    if open == 0 then
        local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
        if sceneType == PublicConst.SceneType.Normal or sceneType == PublicConst.SceneType.CrossServer then
            node, lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatMainSecond, 0, channel)
        else
            
             node, lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatMainSecond, 0, channel)
        end
    elseif open == 1 then
        node, lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatMainSecond, 0, channel)
    elseif open == 2 then
        
        node, lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIChatMainSecond, 0, channel)
    end
    lua_obj.hudCallBack = LuaHudChatCallBack

    ChatUtil.ChatMainSecond = lua_obj
end
	
local function OnClickBtnChat(displayNode)
    OpenChatUIByChannel()
end
	
local function changeMountBtn()
    local mountRq = require "Zeus.Model.Mount"
    local flag = mountRq.GetmountRingFlag()
    if self.tb_ride then
        if flag == 1 then
            self.tb_ride.IsChecked = true
        else
            self.tb_ride.IsChecked = false
        end
    end
end
	
local function DoRidingMount(isButtonClick, params)
    if DataMgr.Instance.UserData.AutoFight then
        if self.tb_ride.IsChecked == true then
            local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PK, "canNotRide")
            GameAlertManager.Instance:ShowNotify(tips)
            self.tb_ride.IsChecked = false
            return
        end
    end

    if BattleClientBase.GetActor().mInfoBar.isInCombat and DataMgr.Instance.UserData.HasMount then
        if self.tb_ride.IsChecked == true then
            local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PK, "canNotRideByBattle")
            GameAlertManager.Instance:ShowNotify(tips)
            self.tb_ride.IsChecked = false
            return
        end
    end

    if GlobalHooks.CheckRindingIsOpenByName('Riding', isButtonClick) then
        
        local FuncOpen = require "Zeus.Model.FunctionOpen"
        FuncOpen.SetPlayedFunctionByName('Riding')

        local mountRq = require "Zeus.Model.Mount"
        local flag
        if params then
            flag = tonumber(params.status)
            if flag ~= mountRq.GetmountRingFlag() then
                mountRq.ridingMountRequest(flag, function() end)
            end
        else
            self.tb_ride.IsChecked = not self.tb_ride.IsChecked
            flag = mountRq.GetmountRingFlag() == 0 and 1 or 0
            mountRq.ridingMountRequest(flag, function() end)
        end
    else
        if isButtonClick then
            self.tb_ride.IsChecked = not self.tb_ride.IsChecked
        end
    end
end
			
local function OnRidingMount(eventname, params)
    DoRidingMount(false, params)
end
			
local function InitDynamicScrollPan(parent)
    self.scroll_pan = UIChatDynamicScrollPan.New()
    self.scroll_pan.Bounds2D = parent.Bounds2D
    self.scroll_pan.Gap = 0
    self.scroll_pan.Scroll.vertical = true
    self.scroll_pan.Scroll.horizontal = false
    self.scroll_pan.IsCountUnVisibleNode = false
    self.scroll_pan.CacheRecordNum = 3
    self.scroll_pan:SetDirection(UIChatDynamicScrollPan.UIDynamicScrollPan_Direction.eAddToBottom)
    
    
    self.scroll_pan.Name = "m_MFUIChatDynamicScrollTemplate"

    self.scroll_pan.Enable = false
    
    self.scroll_pan.event_PointerClick = OnClickBtnChat

    self.scroll_pan.IsAutoScroll = true
    self.m_Lock = true

    parent.Parent:AddChild(self.scroll_pan)

    parent.Visible = false
end
			
local function InitChatList(m_root)
    self.tb_chat = m_root:FindChildByEditName("tb_chat", true)
    self.tb_chat.Visible = false

    self.tb_chatlist = { }
    InitDynamicScrollPan(m_root:FindChildByEditName("sp_chatlist", true))

    self.curIndex = 1
	
	
    self.btn_notice1.TouchClick = function() 
        if (HudManagerU.Instance.PauseSceneTouch) then
            return
        end
        OnClickBtnChat()
    end
	InitChatChannelSwitchText()
end
			
local function EventPushCb(param)
    if #FriendModel.PushData == 0 then
        self.lb_acount1.Visible = false
    else
        self.lb_acount1.Visible = true
        self.lb_acount1.Text = "" .. #FriendModel.PushData
    end
end
			
local function hideMenuActionCb()
    GameObject.Destroy(self.landaction)
    self.actionfinish = true
end
			
local function hideMenuAction()
    
    if self.actionfinish == false then
        return
    end
    self.isHide = true
    self.actionfinish = false
    self.landaction = self.cvs_main1.UnityObject:AddComponent(typeof(uTools.uTweenPosition))
    self.landaction.from = Vector3.New(self.mainPosition2D.x, - self.mainPosition2D.y, 0)
    self.landaction.to = Vector3.New(self.mainPosition2D.x, self.cvs_main1.Size2D.y - self.mainPosition2D.y, 0)
    self.landaction.duration = 0.01
    local finish = UnityEngine.Events.UnityEvent.New()
    local action = LuaUIBinding.UnityAction(hideMenuActionCb)
    finish:AddListener(action)
    self.landaction.onFinished = finish
end
			
local function showMenuAction()
    if self.actionfinish == false then
        return
    end
    self.isHide = false
    self.actionfinish = false
    self.landaction = self.cvs_main1.UnityObject:AddComponent(typeof(uTools.uTweenPosition))
    self.landaction.from = Vector3.New(self.mainPosition2D.x, self.cvs_main1.Size2D.y - self.mainPosition2D.y, 0)
    self.landaction.to = Vector3.New(self.mainPosition2D.x, - self.mainPosition2D.y, 0)
    self.landaction.duration = 0.01
    local finish = UnityEngine.Events.UnityEvent.New()
    local action = LuaUIBinding.UnityAction( function()
        hideMenuActionCb()
    end )
    finish:AddListener(action)
    self.landaction.onFinished = finish
end
			
local function OnClickBtnShouhui(displayNode)
    self.shouhui_node = displayNode
    local isSelect = displayNode.IsChecked
    if isSelect == true then
        hideMenuAction()
    else
        showMenuAction()
    end
end
			
local function SetEXPUI()
    local expGauge = self.root:FindChildByEditName("gg_exp", true)
    if expGauge ~= nil then
        local curexp = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.EXP)
        local needexp = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.NEEDEXP)
        local percentage =(curexp / needexp > 1) and 1 or(curexp / needexp)
		percentage = (percentage < 0 ) and 0 or percentage 
        expGauge.Value = percentage * 100
        
    end
end

local function initCurrency()
    local cvs_rmby = self.currencyRoot:FindChildByEditName("cvs_rmby",true)
    local cvs_rmby_bind = self.currencyRoot:FindChildByEditName("cvs_rmby_bind",true)
    local cvs_silver = self.currencyRoot:FindChildByEditName("cvs_silver",true)
    local rmbyBtn = cvs_rmby:FindChildByEditName("addBtn",true)
    local rmby_bindBtn = cvs_rmby_bind:FindChildByEditName("addBtn",true)
    local silverBtn = cvs_silver:FindChildByEditName("addBtn",true)
    local lb_rmby_num = self.currencyRoot:FindChildByEditName("lb_rmby_num",true)
    local lb_bind_num = self.currencyRoot:FindChildByEditName("lb_bind_num",true)
    local lb_silver_num = self.currencyRoot:FindChildByEditName("lb_silver_num",true)
    rmbyBtn.event_PointerClick = function()
        

    end
    rmby_bindBtn.event_PointerClick = function()

    end
    silverBtn.event_PointerClick = function()

    end
end

local function SetCurrency()
    local lb_rmby_num = self.currencyRoot:FindChildByEditName("lb_rmby_num",true)
    local lb_bind_num = self.currencyRoot:FindChildByEditName("lb_bind_num",true)
    local lb_silver_num = self.currencyRoot:FindChildByEditName("lb_silver_num",true)
    if DataMgr.Instance.UserData then
        lb_rmby_num.Text = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.DIAMOND,0)
        lb_bind_num.Text = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.TICKET,0)
        lb_silver_num.Text = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.GOLD,0)
    end
end

local function RefreshMessageIconPos(iconRoot, iconList)
    local iconCount = #iconList
    local rootWidth = iconRoot.Width
    for i=1,iconCount do
        iconList[i].X = 65*(i-1)+iconList[i].Width/2
    end
    if self.isSpecialScene then
        local iconRoot = self.root:FindChildByEditName("cvs_hud_message", true)
        iconRoot.Visible = not self.isSpecialScene
    else
        iconRoot.Visible = iconCount > 0
    end
end
			
local function RefreshMsgIcon()
    local iconRoot = self.root:FindChildByEditName("cvs_hud_message", true)
    if iconRoot ~= nil then
        local iconName = {
            "cvs_hud_mail","cvs_hud_team","cvs_hud_friend","cvs_hud_guild_apply","cvs_hud_fuben_invite","cvs_hud_transaction","cvs_hud_daoyou",
            "cvs_hud_upgrade","cvs_team_chat","cvs_guild_chat","cvs_ally_chat","cvs_hongbao_chat"
        }
        local msgCount = {
            DataMgr.Instance.MessageData:GetMailMesCount(),
            DataMgr.Instance.MessageData:GetTeamMesCount(),
            DataMgr.Instance.MessageData:GetFriendMesCount(),
            DataMgr.Instance.MessageData:GetMessageCount(MessageData.MsgType.GuildApply),
            DataMgr.Instance.MessageData:GetMessageCount(MessageData.MsgType.FubenFriendInvite),
            DataMgr.Instance.MessageData:GetMessageCount(MessageData.MsgType.TradeInvite),
            DataMgr.Instance.MessageData:GetMessageCount(MessageData.MsgType.DaoyouInvite),
            DataMgr.Instance.MessageData:GetMessageCount(MessageData.MsgType.UpLevelUp),
            DataMgr.Instance.MessageData:GetMessageCount(MessageData.MsgType.TeamChatMsg),
            DataMgr.Instance.MessageData:GetMessageCount(MessageData.MsgType.LegionChatMsg),
            DataMgr.Instance.MessageData:GetMessageCount(MessageData.MsgType.AllyChatMsg),
            DataMgr.Instance.MessageData:GetMessageCount(MessageData.MsgType.RedPacket),
        }

        local showIconList = {}
        for i = 1, #iconName do
            local icon = iconRoot:FindChildByEditName(iconName[i], true)
            if icon ~= nil then
                if msgCount[i] and msgCount[i] > 0 then
                    icon.Visible = true
                    table.insert(showIconList, icon)
                else
                    icon.Visible = false
                end
            end
        end
        RefreshMessageIconPos(iconRoot, showIconList)
        if DataMgr.Instance.MessageData:GetMessageCount(MessageData.MsgType.TeamApply) > 0 then
            EventManager.Fire("Event.RefreshTeamApply",{applyNum = 1})
        else
            EventManager.Fire("Event.RefreshTeamApply",{applyNum = 0})
        end
    end
end
			
local function InitMessageIcon()
    local iconRoot = self.root:FindChildByEditName("cvs_hud_message", true)
    if iconRoot ~= nil then
        
        local mail = iconRoot:FindChildByEditName("cvs_hud_mail", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = mail,
            click = function()
                
                OnClickBtnMail()
                
                
            end
        } )

        
        local team = iconRoot:FindChildByEditName("cvs_hud_team", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = team,
            click = function()
                DataMgr.Instance.MessageData:ShowTeamAlert()
            end
        } )

        
        local friend = iconRoot:FindChildByEditName("cvs_hud_friend", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = friend,
            click = function()
                local node, lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialFriendApply, 0)
                
                DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.FriendInvite)
            end
        } )

        
        local guild = iconRoot:FindChildByEditName("cvs_hud_guild_apply", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = guild,
            click = function()
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildHall,0)
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildMain,0,2)
                
                DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.GuildApply)
            end
        } )

        
        local fubenInvite = iconRoot:FindChildByEditName("cvs_hud_fuben_invite", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = fubenInvite,
            click = function()
                DataMgr.Instance.MessageData:ShowSimpleAlert(MessageData.MsgType.FubenFriendInvite)
            end
        } )
        
        local transactionInvite = iconRoot:FindChildByEditName("cvs_hud_transaction", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = transactionInvite,
            click = function()
                DataMgr.Instance.MessageData:ShowSimpleAlert(MessageData.MsgType.TradeInvite)
            end
        } )

        
        local cvs_hud_daoyou = iconRoot:FindChildByEditName("cvs_hud_daoyou", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = cvs_hud_daoyou,
            click = function()
                DataMgr.Instance.MessageData:ShowSimpleAlert(MessageData.MsgType.DaoyouInvite)
            end
        } )

        
        local cvs_hud_upgrade = iconRoot:FindChildByEditName("cvs_hud_upgrade", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = cvs_hud_upgrade,
            click = function()
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIUpStairs, 0)
                

            end
        } )

        local cvs_team_chat = iconRoot:FindChildByEditName("cvs_team_chat", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = cvs_team_chat,
            click = function()
                OpenChatUIByChannel(ChatModel.ChannelState.Channel_group)
            end
        } )

        local cvs_guild_chat = iconRoot:FindChildByEditName("cvs_guild_chat", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = cvs_guild_chat,
            click = function()
                OpenChatUIByChannel(ChatModel.ChannelState.Channel_union)
            end
        } )

        local cvs_ally_chat = iconRoot:FindChildByEditName("cvs_ally_chat", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = cvs_ally_chat,
            click = function()
                OpenChatUIByChannel(ChatModel.ChannelState.Channel_ally)
            end
        } )
        
         local cvs_hongbao_chat = iconRoot:FindChildByEditName("cvs_hongbao_chat", true)
        LuaUIBinding.HZPointerEventHandler( {
            node = cvs_hongbao_chat,
            click = function()
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRedPacket,0)
               
                DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.RedPacket)
            end
        } )
        RefreshMsgIcon()
    end
end
													
local function OpenUIChangeFlag(eventname, params)    
    
    local oplv = GlobalHooks.DB.Find("OpenLv", params.name)
    if oplv.RedDot == '' then return end
    local flagNode = self.root:FindChildByEditName(oplv.RedDot, true)
    if oplv and flagNode then
        
        if params.waitToPlay then
            flagNode.Visible = true
        else
            if not self[oplv.RedDot] then
                flagNode.Visible = false
            end
        end
    end

    if params.name == "Strengthen" or params.name == "SetNew" or params.name == "Enchant" then
        local bl = GlobalHooks.CheckFuncWaitToPlay("Strengthen") or GlobalHooks.CheckFuncWaitToPlay("SetNew") or GlobalHooks.CheckFuncWaitToPlay("Enchant")

        MenuBaseU.SetVisibleUENode(self.root, "lb_bj_bag", false)
    end
    
    if params.name == "Solo" or params.name == "FB" or params.name == "Consignment" or params.name == "AllyBattle"
        or params.name == "JJC" or params.name == "Servers" then
        if params.waitToPlay then 
            
        else
            
        end
    end            
end
													
local function AutoBuyItem(eventname, params)
    if self.autobuy[params.Code] == nil or self.autobuy[params.Code] <= tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD)) then
        if params.Code ~= nil and self.buying == nil then
            self.buying = true
            local item = GlobalHooks.DB.Find("Items", params.Code)
            if string.empty(item.WaysID) then return end
            local ways = string.split(item.WaysID, ',')
            local idxs = { }
            for i, v in ipairs(ways) do
                local idx = GlobalHooks.DB.Find("Functions", v).SellIndex
                if not string.empty(idx) then
                    for ii, vv in ipairs(string.split(idx, ',')) do
                        table.insert(idxs, tonumber(vv))
                    end
                end
            end
            local num = GlobalHooks.DB.GetPetGlobalConfig("AutoBuy.ItemNum." .. item.Type)
            if num == nil then
                num = item.GroupCount
            end

            RecycleModel.autoBuyItemByCodeRequest(idxs, params.Code, num, function(...)
                self.buying = nil
            end , function(data)
                self.buying = nil
                if data.s2c_notEnoughGold == 1 then
                    self.autobuy[params.Code] = data.s2c_needGold
                end
            end )
        end
    end
end

local function showBattery()
    local str = "battery_power"
    local bateryValue = GameUtil.BatteryValue()
    for i = 1, 5 do
        self.root:FindChildByEditName(str .. i, true).Visible = ((i-1)*20 <= bateryValue)
    end
end			

local function showWifi()
    local str = "ib_ping"
    local wifi = "wifi_ping"
    local rgba = { 0x00d600ff, 0xffba00ff, 0xf43a1cff }
    self.pingvalue = BattleClientBase.GetCurPingValue()
    local TitlePing = self.root:FindChildByEditName("lb_ping", true)
    if TitlePing == nil then
        return
    end 
    TitlePing.Text =(self.pingvalue >= 999 and 999 or self.pingvalue) .. ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PUBLICCFG, "hud_ms")
    local function isVisible(Value)
        if Value >= 0 and Value <= 100 then
            return 1
        elseif Value > 100 and Value <= 250 then
            return 2
        else
            return 3
        end
    end
    TitlePing.FontColor = GameUtil.RGBA2Color(rgba[isVisible(self.pingvalue)])
    local bUseWifi = GameUtil.IsUseWifi()
    for i = 1, 3 do
        self.root:FindChildByEditName(str .. i, true).Visible = (i == isVisible(self.pingvalue) and (not bUseWifi))
        self.root:FindChildByEditName(wifi .. i, true).Visible = (i == isVisible(self.pingvalue) and bUseWifi)
    end
end
														
local function ShowTimeWifiFPS()
    local TitleTime = self.root:FindChildByEditName("lb_time_fps", true)
    local TitleFPS = self.root:FindChildByEditName("lb_fps", true)
    local oldClockTime = os.time()
    local oldWifiTime = oldClockTime
    local function setClock(curtime)
        local tab = os.date("*t", curtime)
        TitleTime.Text = tab.hour .. ":" ..(tonumber(tab.min) > 9 and tab.min or "0" .. tab.min)
        oldClockTime = os.time()
    end
    local function setWifi()
        showWifi()
        oldWifiTime = os.time()
    end
    local function setFPS()
        TitleFPS.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PUBLICCFG, "hud_fps") .. " " .. tostring(math.floor(1 /(UnityEngine.Time.deltaTime)))
    end
    setWifi()
    setClock(os.time())
    showBattery()

    AddUpdateEvent(
    "Event.hudClock.Update",
    function(dt)
        local curtime = os.time()
        if curtime - oldWifiTime > 5 then
            setWifi()
            setFPS()
        end
        if curtime - oldClockTime > 10 then
            setClock(curtime)
            showBattery()
        end
    end
    )
end
														
local function JoinVoiceChannel(teamData)
    local PlayerModel = require "Zeus.Model.Player"
    PlayerModel.GetAgoraDynamicKeyRequest(teamData.TeamId, 0, function(param)
        if param.s2c_channelName == teamData.TeamId then
            XmdsSoundManager.GetXmdsInstance():SetBGMVolume(oldMusicVolume * 0.3)
            XmdsSoundManager.GetXmdsInstance():SetEffectVolume(oldSoundVolume * 0.3)
            SDKWrapper.Instance:JoinVoiceChannel(param.s2c_channelName, tostring(param.s2c_uid), param.s2c_key)
        end
    end )
end
														
local function OnTeamDataNotify(status, teamData)
    local hasTeam = teamData.HasTeam
    if status ~= TeamData.NotiFyStatus.TeamJoinOrLeave then return end

    local isAllMute = GameSetting.GetValue(GameSetting.ALL_MUTE) == 1
    
    

    if hasTeam then
        
    else
        XmdsSoundManager.GetXmdsInstance():SetBGMVolume(oldMusicVolume)
        XmdsSoundManager.GetXmdsInstance():SetEffectVolume(oldSoundVolume)
        
    end

    local text = hasTeam and "voiceJoinTeamTips" or "voiceLeaveTeamTips"
    text = Util.GetText(TextConfig.Type.PUBLICCFG, text)
    GameAlertManager.Instance:ShowNotify(text)
end
		

    
    

		

    

		

    




	




														
local function InitVoice()
    AddUpdateEvent("Event.UI.LuaHudMgr.ChatUtil.Update", function(deltatime)
        ChatUtil.AutoPlayVoice()
    end)

    local hasVoice = SDKWrapper.Instance:HasPluginVoice()
    self.btn_notice1 = self.root:FindChildByEditName("btn_notice1", true)
    
    
    

    if not hasVoice then
        self.btn_notice1.Visible = false
        
        
        return
    end

    
    

    
    

    
    

    OnTeamDataNotify(nil, DataMgr.Instance.TeamData)
end
														
local function HideOrShowCvsChat(eventname, params)
    
    self.cvs_chat.Visible = params.param
    self.cvs_bag.Visible = params.param
end

local function TimeToHideMenu()
    if not self.isHide then
        
        hideMenuAction()
        
    end
end
														
local function InitUI()
    
    local UIName = {
        "btn_bag",
        
        "tb_ride",
        "tb_autofight",
        "btn_activity",
        
        "btn_welfare",
        "btn_tuichu",
        "cvs_leavedugeon",
       
        "cvs_chat",
        "cvs_expbar",
        "cvs_ride",
        "cvs_main1",
        "cvs_main",
        "cvs_menu",
        "cvs_lift",
        "btn_mail",
        "btn_mall",
        "cvs_autofight",
        "lb_bj_bag",
        
        "tb_laba",
        "cvs_revive",
        "btn_revive",
        "cvs_bag",
        "cvs_sociality",
        "cvs_mail",
        "cvs_setting",
        "cvs_welfare",
        "cvs_activity",
        "cvs_mall",
        
        
        "cvs_target",
        "btn_target",
        "cvs_guoyuan",
        "btn_guoyuan",
        
        "cvs_firstpay",
        "btn_fp",
        
        "cvs_pay",
        "btn_pay",
        
        
        
        
        
        
        "btn_menu",
        "btn_sociality",
        "btn_setting",
        "btn_ranklist",
        "btn_trade_center",
        "cvs_topright", 
		"cvs_channel", 
		"tbt_channel",
		"btn_channel1",
		"btn_channel2",
		"btn_channel3",

        "lb_shouhu_num",
        "cvs_shouhu", 

        "cvs_huanjing", 
        "lb_money", 
        "lb_exp", 
        "lb_money_rate", 
        "lb_exp_rate", 

        "btn_linshi", 

        "cvs_touch_shield",

        "cvs_hot",    
        "btn_hot",       
        "lb_bj_hot",

        "cvs_kuanghuan",
        "btn_kh",
        "lb_bj_kh",
        "cvs_mijing",
        "cvs_mijing2",
        "lb_mjboxnum",
        "lb_daojishi",
        "cvs_Gboss",
        "cvs_guild_boss",
        "cvs_guildboss_rank",
        "cvs_guildboss_inspire",
        "cvs_Qgift",
        "cvs_GWar",
        "cvs_guild_judian",
        "cvs_dungeon_tongji",
        "cvs_tower",       
            }

    for i = 1, #UIName do
        self[UIName[i]] = self.root:FindChildByEditName(UIName[i], true)
    end

    local flags = { }
    for i = 1, #UIFlags do
        flags[UIFlags[i]] = self.root:FindChildByEditName(UIFlags[i], true)
    end
    self.flags = flags
end
														
local function OnShowUI(eventname, params)
    print("-----------------------Event.Menu.LuaHudMgr---------------------")

    local m_root = HudManagerU.Instance.CreateHudUIFromFile("xmds_ui/hud/mainhud.gui.xml")
    local currencyRoot = LuaMenuU.Create('xmds_ui/common/currency.gui.xml', GlobalHooks.UITAG.GameUICurrencyTip)    
    currencyRoot.Enable = false           
    self.root = m_root
    self.currencyRoot = currencyRoot
    local cvs_rmby = self.currencyRoot:FindChildByEditName("cvs_rmby",true)
        local btn_rmby = cvs_rmby:FindChildByEditName("addBtn",true)
        btn_rmby.TouchClick = function()
            local menu = MenuMgrU.Instance:FindMenuByTag(GlobalHooks.UITAG.GameUIShop)
            if menu then
                MenuMgrU.Instance:CloseMenuByTag(GlobalHooks.UITAG.GameUIShop)
            end
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop,-1,"pay")
        end
        local cvs_rmby_bind = self.currencyRoot:FindChildByEditName("cvs_rmby_bind",true)
        local btn_rmby_bind = cvs_rmby_bind:FindChildByEditName("addBtn",true)
        btn_rmby_bind.TouchClick = function()
            local menu = MenuMgrU.Instance:FindMenuByTag(GlobalHooks.UITAG.GameUIShop)
            if menu then
                MenuMgrU.Instance:CloseMenuByTag(GlobalHooks.UITAG.GameUIShop)
            end
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop,-1,"card")
        end
        local cvs_silver = self.currencyRoot:FindChildByEditName("cvs_silver",true)
        local btn_silver = cvs_silver:FindChildByEditName("addBtn",true)
        btn_silver.TouchClick = function()
            local menu = MenuMgrU.Instance:FindMenuByTag(GlobalHooks.UITAG.GameUIShop)
            if menu then
                MenuMgrU.Instance:CloseMenuByTag(GlobalHooks.UITAG.GameUIShop)
            end
            local o, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIItemGetDetail)
            if obj then
                GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIItemGetDetail)
            end
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, "gold10w")
        end
    local bt_scoreshop = self.currencyRoot:FindChildByEditName("bt_scoreshop",true)
    local ib_ricon = self.currencyRoot:FindChildByEditName("ib_ricon",true)
    if DataMgr.Instance.FlagPushData:GetFlagState(3700)>0 then
        ib_ricon.Visible = true
    else
        ib_ricon.Visible = false
    end
    bt_scoreshop.TouchClick = function(sender)
        if ib_ricon.Visible then
            ib_ricon.Visible = false
        end
        local node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIShopScore)
        if lua_obj == nil then
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShopScore)
        
        end
    end
    initCurrency()
    XmdsUISystem.Instance:UILayerAddChild(currencyRoot);


    m_root.Enable = false
    m_root:FindChildByEditName("cvs_mainhud", true).Enable = false
    
    
    HudManagerU.Instance:AddHudUI(m_root, "MainHud")

    InitVoice()
    InitUI()
    Pomelo.PlayerHandler.clientReadyRequest(function()
    end)
    self.btn_bag:SetSound("buttonClick")
    self.btn_bag.TouchClick = OnClickBtnBag



    
    
        
    
    

    self.cvs_revive.Visible = false
    HudManagerU.Instance:InitAnchorWithNode(m_root:FindChildByEditName("cvs_rightcenter", true), bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_TOP))
    HudManagerU.Instance:InitAnchorWithNode(m_root:FindChildByEditName("cvs_guildboss_rank", true), bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_TOP))
    HudManagerU.Instance:InitAnchorWithNode(m_root:FindChildByEditName("cvs_guildboss_inspire", true), bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_TOP))
    HudManagerU.Instance:InitAnchorWithNode(m_root:FindChildByEditName("cvs_guild_judian", true), bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_TOP))
    
    local lb_itempoint = m_root:FindChildByEditName("lb_itempoint", true)
    if lb_itempoint ~= nil then
        HudManagerU.Instance:InitAnchorWithNode(lb_itempoint, bit.bor(HudManagerU.HUD_BOTTOM))
        FlyToBag.bag = lb_itempoint.Transform
    end

    local cvs_autoAtk = m_root:FindChildByEditName("cvs_topright", true)
    HudManagerU.Instance:InitAnchorWithNode(cvs_autoAtk, bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_TOP))
    self.tb_autofight.TouchClick = OnClickBtnAutofight

    HudManagerU.Instance:InitAnchorWithNode(self.cvs_ride, bit.bor(HudManagerU.HUD_LEFT, HudManagerU.HUD_BOTTOM))
    
    self.tb_ride.TouchClick = function(sender)
        DoRidingMount(true)
    end
    changeMountBtn()

    local ridebj = m_root:FindChildByEditName("lb_bj_ride", true)
    
    self.btn_activity:SetSound("buttonClick")
    self.btn_activity.TouchClick = function(sender)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIActivityHJBoss, 0) 
        fristActiveRedPoint = false
        SetActivityFlag()
    end

     self.btn_linshi.TouchClick = function(sender)
        if GlobalHooks.CheckUICanOpen(GlobalHooks.UITAG.GameUIActivityHJBoss) then
            
        end
    end

    self.btn_welfare:SetSound("buttonClick")
    self.btn_welfare.TouchClick = function(sender) 
        local SignRq = require "Zeus.Model.Sign"
        if SignRq.GetAllSignMsg()==nil then
            SignRq.GetAttendanceInfoRequest(function ( ... )
              GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISignXMDS, 1)
            end)
        else
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISignXMDS, 1)
        end
     end

    HudManagerU.Instance:InitAnchorWithNode(self.cvs_chat, bit.bor(HudManagerU.HUD_BOTTOM))
    self.cvs_chat.event_PointerClick = function()
        if (HudManagerU.Instance.PauseSceneTouch) then
            return
        end
        OnClickBtnChat()
    end
    HudManagerU.Instance:InitAnchorWithNode(self.cvs_expbar, bit.bor(HudManagerU.HUD_BOTTOM))
    HudManagerU.Instance:InitAnchorWithNode(self.cvs_menu, bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_BOTTOM))

    
    local cvs_disablebutton = m_root:FindChildByEditName("cvs_disablebutton", true)
    self.actionfinish = true
    self.mainPosition2D = self.cvs_main1.Position2D

    HudManagerU.Instance:InitAnchorWithNode(m_root:FindChildByEditName("cvs_right", true), bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_TOP))
    HudManagerU.Instance:InitAnchorWithNode(m_root:FindChildByEditName("cvs_shouhu", true), HudManagerU.HUD_TOP)
    HudManagerU.Instance:InitAnchorWithNode(cvs_disablebutton, bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_TOP))
    HudManagerU.Instance:InitAnchorWithNode(m_root:FindChildByEditName("cvs_lift", true), bit.bor(HudManagerU.HUD_LEFT, HudManagerU.HUD_TOP))
    HudManagerU.Instance:InitAnchorWithNode(m_root:FindChildByEditName("cvs_dungeon_tongji", true), bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_TOP))
    HudManagerU.Instance:InitAnchorWithNode(self.currencyRoot, bit.bor(HudManagerU.HUD_LEFT, HudManagerU.HUD_TOP))
    self.currencyRoot.Visible = false

    self.btn_mail.TouchClick = OnClickBtnMail

    self.btn_mall:SetSound("buttonClick")
    self.btn_mall.TouchClick = function()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop, 0)
    end
    
    self.btn_target:SetSound("buttonClick")
    self.btn_target.TouchClick = function()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIStrongerMain, 0)
    end

    self.btn_guoyuan:SetSound("buttonClick")
    self.btn_guoyuan.TouchClick = function()
        
    end

    self.btn_fp.TouchClick = function()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFirstPay, -1)
    end

    self.btn_pay:SetSound("buttonClick")
    self.btn_pay.TouchClick = function()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop, 0, "pay")
    end

    self.btn_menu.TouchClick = function()
        EventManager.Fire("Event.Menu.OnMenuClickFromLua", { })
    end

    self.btn_sociality:SetSound("buttonClick")
    self.btn_sociality.TouchClick = function()
        
        local node, lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialMain, 0)
    end
    self.btn_setting:SetSound("buttonClick")
    self.btn_setting.TouchClick = function()
        
        MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUISetMain, 0)
    end
    self.btn_ranklist:SetSound("buttonClick")
    self.btn_ranklist.TouchClick = function()
        
        MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUILeaderboard, 0)
    end
    self.btn_trade_center:SetSound("buttonClick")
    self.btn_trade_center.TouchClick = function()
        
        local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIConsignmentMain, 0)
        if obj then
            obj:Start(0)
        end
    end
	
	self.tbt_channel.TouchClick = function() 
        if (HudManagerU.Instance.PauseSceneTouch) then
            return
        end
        OnClickBtnChat()
        return
        
        
    end

    self.btn_kh.TouchClick = function()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUICarnival, -1)
    end
    
    
    

    self.btn_hot.TouchClick = function()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIHotMainUI, 0)
    end

    SetEXPUI()
    
    InitChatList(m_root)

    ChatModel.AddChatPushListener("LuaHudChatPush", ChatPushCb)
    FriendModel.AddEventPushListener("LuaHudEventPush", EventPushCb)

    
    SetMailNum()

    
    InitMessageIcon()

    
    local wifitime = self.root:FindChildByEditName("cvs_enviro", true)
    HudManagerU.Instance:InitAnchorWithNode(wifitime, bit.bor(HudManagerU.HUD_LEFT, HudManagerU.HUD_TOP))
    ShowTimeWifiFPS()

    ChatModel.getChatServerIdRequest( function(param)
        
        if param == nil or param.s2c_serverId == nil or param.s2c_serverId == "" then
            
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, "chatservererror"))
        else
            FileSave.serverId = param.s2c_serverId
            FileSave.test_voice_path = param.s2c_clientHttp
        end
    end )

    local count = GlobalHooks.DB.Find("Parameters", { ParamName = "HUD.TopMenu.Close" })[1].ParamValue
    GameGlobal.Instance.getStaticIdleTime = count
    
    SetKuanghuanFlag()
end
	
local function UpdateIllusionPush(eventname,params)
    local exp = params.s2c_today_exp
    local gold = params.s2c_today_gold
    local lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)

    self.lb_exp.Text = exp
    self.lb_exp.FontColorRGBA = 0xffffffff  
    
    self.lb_money.Text = gold
    self.lb_money.FontColorRGBA = 0xffffffff  

    if not self.expRets then
        self.expRets = GlobalHooks.DB.GetFullTable("ExpReduce")
    end

    local function ratefunc(rete)
        return string.format("%s%d%s",Util.GetText(TextConfig.Type.MAP,"shuaijian"),rete,"%")
    end

    for i,v in ipairs(self.expRets) do
        if lv >= v.MinLv and lv <= v.MaxLv then
            if exp <= v.Rate1 then
                self.lb_exp_rate.Text = ratefunc(0)
            elseif exp <= v.Rate2 then
                self.lb_exp_rate.Text = ratefunc(20)
            elseif exp <= v.Rate3 then
                self.lb_exp_rate.Text = ratefunc(40)
            elseif exp <= v.Rate4 then
                self.lb_exp_rate.Text = ratefunc(60)
            else
                self.lb_exp_rate.Text = ratefunc(80)
            end
            break
        end
    end

    if not self.glodRets then
        self.glodRets = GlobalHooks.DB.GetFullTable("GoldReduce")
    end

    for i,v in ipairs(self.glodRets) do
        if lv >= v.MinLv and lv <= v.MaxLv then
            if gold <= v.Rate1 then
                self.lb_money_rate.Text = ratefunc(0)
            elseif gold <= v.Rate2 then
                self.lb_money_rate.Text = ratefunc(20)
            elseif gold <= v.Rate3 then
                self.lb_money_rate.Text = ratefunc(40)
            elseif gold <= v.Rate4 then
                self.lb_money_rate.Text = ratefunc(60)
            else
                self.lb_money_rate.Text = ratefunc(80)
            end
            break
        end
    end
end


local function UpdateIllusionPushBoxNum(eventname,params)
    local smallBox = params.s2c_today_lv1
    local middleBox = params.s2c_today_lv2
    local largeBox = params.s2c_today_lv3
    local todayBoxNum = smallBox + middleBox + largeBox
    self.lb_mjboxnum.Text = Util.GetText(TextConfig.Type.MAP, "box") .. string.format("%d/%d",todayBoxNum,params.s2c_max_num)

    if todayBoxNum >= params.s2c_max_num then 
        self.lb_mjboxnum.FontColorRGBA = 0xff0000ff   
    else
        self.lb_mjboxnum.FontColorRGBA = 0x00ff00ff  
    end
end

function self.Notify(status, subject)
    if subject == DataMgr.Instance.UserData then
        if subject:ContainsKey(status, UserData.NotiFyStatus.DIAMOND) then
            if self.cvs_firstpay.Visible then
                self.cvs_firstpay.Visible = not (PlayerModel.GetBindPlayerData().payGiftData == 2)
                self.cvs_pay.Visible = not self.cvs_firstpay.Visible
            end
        end

        if self.root ~= nil then
            SetEXPUI()
            SetCurrency()
        end
    elseif subject == DataMgr.Instance.FlagPushData then
        if self.root ~= nil then
            if status == FlagPushData.FLAG_MAIL then
                SetMailNum()
            end
            if status == FlagPushData.FLAG_ACTIVITY_CENTER then
                SetActivityFlag()
            end
            if status == FlagPushData.FLAG_SHOPMALL then
                SetShopmallFlag()
            end
            if status == FlagPushData.FLAG_VIP then
                SetShopmallFlag()
            end
            if status == FlagPushData.FLAG_FIRST_PAY then
                SetFirstPayFlag()
            end
            if status == FlagPushData.FLAG_WELFARE then 
                SetWelFareFlag()
            end
            if status == FlagPushData.FLAG_ACTIVITY_YAOZU or status == FlagPushData.FLAG_ACTIVITY_WUYUE or
               status == FlagPushData.FLAG_ACTIVITY_WENDAO or status == FlagPushData.FLAG_ACTIVITY_SHILIAN
               or status ==  FlagPushData.FLAG_ACTIVITY_MIJING or status ==  FlagPushData.FLAG_GUILD_BOSS_FLAG 
               or status == FlagPushData.FLAG_LIMITGIFT or status == FlagPushData.FLAG_GUILD_WAR_ACCESS then 
                SetActivityOpenFlag()
            end
            if status == FlagPushData.FLAG_KUANGHUAN then 
                SetKuanghuanFlag()
            end
            if status == FlagPushData.FLAG_HOT_CONTINUE or status == FlagPushData.FLAG_HOT_RICH or 
               status == FlagPushData.FLAG_HOT_SEVENTARGET then 
                SetHotFlag()
            end
        end
    elseif subject == DataMgr.Instance.MessageData then
        RefreshMsgIcon()
    end
end
														
local function fin(relogin)
    if relogin then
        RemoveUpdateEvent("Event.OnlineWelfare.UpdaFirstInitFinishte", true)
        RemoveUpdateEvent("Event.hudSendVoice.Update", true)
        RemoveUpdateEvent("Event.hudClock.Update", true)
        
        XmdsSoundManager.GetXmdsInstance():SetBGMVolume(oldMusicVolume)
        XmdsSoundManager.GetXmdsInstance():SetEffectVolume(oldSoundVolume)
        
    end
    
    DataMgr.Instance.FlagPushData:DetachLuaObserver(9999)
    DataMgr.Instance.UserData:DetachLuaObserver(9999)
    DataMgr.Instance.MessageData:DetachLuaObserver(9999)
    DataMgr.Instance.TeamData:DetachLuaObserver(9999)

    RemoveAllActivityFlagEvent()
end
														
local function DoAutoFight()
    if not DramaHelper.IsAllowAutoGuard() then return end

    local staticVo = GlobalHooks.DB.Find("Map", DataMgr.Instance.UserData.SceneId)
    if staticVo and staticVo.AutoFight == 3 then
        
        if DataMgr.Instance.TeamData.TeamFollow == 0 then
            DataMgr.Instance.UserData.AutoTarget = "point:0"
            DataMgr.Instance.UserData.AutoFight = true
            if DataMgr.Instance.UserData.PlayDrama then
                GameSceneMgr.Instance.BattleRun.BattleClient:PauseSeek()
            end
        end
    end
end
														
local function ChangeAutoBattleMode()
    if not GameUtil.IsWildScene() then
        DataMgr.Instance.AutoSettingData.isAutoFightMapModeInOther = true
    end
    GameUtil.ChangeAutoBattleMode()
end

local function OnSetHudMaskTouchEnable(eventname,params)
    self.cvs_touch_shield.Visible = params.value
    if params.value == true then
        self.cvs_touch_shield.TouchClick = function(sender)
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, "bianshenquest"))
        end
    end
end

local function OnSetHudMaskTouchEnable(eventname,params)
    self.cvs_touch_shield.Visible = params.value
    if params.value == true then
        self.cvs_touch_shield.TouchClick = function(sender)
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, "bianshenquest"))
        end
    end
end

local function OnUpdateGuildWarUI(eventname,params)
    local ownGuild = params.ownGuild
    local enemyGuild = params.enemyGuild or {}

    local function func(node, num1, num2)
        node:FindChildByEditName("lb_1",true).Text = num1
        node:FindChildByEditName("lb_2",true).Text = num2
        local gag_percent = node:FindChildByEditName("gag_percent",true)
        if num2 > 0 then
            gag_percent.Value = num1 / (num1 + num2)
        elseif num1 <= 0 then
            gag_percent.Value = 0.5
        else
            gag_percent.Value = 1
        end
    end

    local cvs_member = self.cvs_guild_judian:FindChildByEditName("cvs_member",true)
    func(cvs_member, ownGuild.mumber, enemyGuild.mumber or 0)

    local cvs_defadd = self.cvs_guild_judian:FindChildByEditName("cvs_defadd",true)
    func(cvs_defadd, ownGuild.defenseSoul, enemyGuild.defenseSoul or 0)

    local cvs_atkadd = self.cvs_guild_judian:FindChildByEditName("cvs_atkadd",true)
    func(cvs_atkadd, ownGuild.attackSoul, enemyGuild.attackSoul or 0)

    local cvs_score = self.cvs_guild_judian:FindChildByEditName("cvs_score",true)
    func(cvs_score, ownGuild.kill, enemyGuild.kill or 0)

    self.cvs_guild_judian:FindChildByEditName("lb_11",true).Text = ownGuild.attack or 0
    self.cvs_guild_judian:FindChildByEditName("lb_12",true).Text = ownGuild.defense or 0
    self.cvs_guild_judian:FindChildByEditName("lb_21",true).Text = enemyGuild.attack or 0
    self.cvs_guild_judian:FindChildByEditName("lb_22",true).Text = enemyGuild.defense or 0

    local totalFlag = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "GuildFort.TotalFlag"})[1].ParamValue)
    for i=1,6 do
        local ownFlag = self.cvs_guild_judian:FindChildByEditName("ib_red_"..i,true)
        ownFlag.Visible = i <= (totalFlag- (ownGuild.armyFlag or 0))
        local enemyFlag = self.cvs_guild_judian:FindChildByEditName("ib_blue_"..i,true)
        enemyFlag.Visible = i <= (totalFlag - (enemyGuild.armyFlag or 0))
    end
end

local function InitGuildWarUI()
    local GuildWarAPI = require "Zeus.Model.GuildWar"
    local lb_name_guild1 = self.cvs_guild_judian:FindChildByEditName("lb_name_guild1",true)
    local lb_name_guild2 = self.cvs_guild_judian:FindChildByEditName("lb_name_guild2",true)
    local bt_guildWar_arrow = self.cvs_guild_judian:FindChildByEditName("bt_guildWar_arrow",true)
    local cvs_guildwar_moreInfo = self.cvs_guild_judian:FindChildByEditName("cvs_guildwar_moreInfo",true)

    GuildWarAPI.ApplyFortGuildInfoRequest(function(data)
        self.cvs_guild_judian.Visible = true
        if data.ownGuild and data.ownGuild.guildId and data.ownGuild.guildId ~= "" then
            lb_name_guild1.Text = data.ownGuild.guildName .. Util.GetText(TextConfig.Type.GUILDWAR, "score", data.ownGuild.score)
        else
            lb_name_guild1.Text = Util.GetText(TextConfig.Type.GUILDWAR, "shouweijun")
        end

        if data.enemyGuild and data.enemyGuild.guildId and data.enemyGuild.guildId ~= "" then
            lb_name_guild2.Text = data.enemyGuild.guildName .. Util.GetText(TextConfig.Type.GUILDWAR, "score", data.enemyGuild.score)
        else
            lb_name_guild2.Text = Util.GetText(TextConfig.Type.GUILDWAR, "shouweijun")
        end

        local param = {ownGuild = data.ownGuild, enemyGuild = data.enemyGuild or nil}
        EventManager.Fire("Event.GuildWar.UpdateGuildWarUI", param)
    end)

    bt_guildWar_arrow.IsChecked = true
    cvs_guildwar_moreInfo.Visible = true
    bt_guildWar_arrow.TouchClick = function(sender)
        cvs_guildwar_moreInfo.Visible = bt_guildWar_arrow.IsChecked
    end
end

local function OnUpdateDungeonTongJiUI(eventname,params)
    if not self.cvs_dungeon_tongji.Visible then
        return
    end
    
    local sp_tongji = self.cvs_dungeon_tongji:FindChildByEditName("sp_tongji",true)
    local cvs_tongji_player = self.cvs_dungeon_tongji:FindChildByEditName("cvs_tongji_player",true)
    cvs_tongji_player.Visible = false
    sp_tongji.Visible = true
    sp_tongji:Initialize(cvs_tongji_player.Width,cvs_tongji_player.Height+5,#params.players,1,cvs_tongji_player,
        function (gx,gy,node)
            local data = params.players[gy + 1]
            node.Visible = true
            local lb_tongji_name = node:FindChildByEditName("lb_tongji_name", false)
            local lb_tongji_damage = node:FindChildByEditName("lb_tongji_damage", false)
            local lb_tongji_cure = node:FindChildByEditName("lb_tongji_cure", false)
            lb_tongji_name.Text = data.playerName
            lb_tongji_damage.Text = Util.NumberToShow(data.hurt or 0)
            lb_tongji_cure.Text = Util.NumberToShow(data.cure or 0)
            if data.playerName == DataMgr.Instance.UserData.Name then
                lb_tongji_name.FontColor = Util.FontColorGreen
                lb_tongji_damage.FontColor = Util.FontColorGreen
                lb_tongji_cure.FontColor = Util.FontColorGreen
            else
                lb_tongji_name.FontColor = Util.FontColorWhite
                lb_tongji_damage.FontColor = Util.FontColorWhite
                lb_tongji_cure.FontColor = Util.FontColorWhite
            end
    end,function () end)
end

local function InitDungeonTongJiUI()
    local cvs_dungeon_tongji1 = self.cvs_dungeon_tongji:FindChildByEditName("cvs_dungeon_tongji1",true)
    local cvs_tongji_title = self.cvs_dungeon_tongji:FindChildByEditName("cvs_tongji_title",true)
    local bt_tongji_arrow = self.cvs_dungeon_tongji:FindChildByEditName("bt_tongji_arrow",true)
    
    cvs_dungeon_tongji1.Visible = false
    cvs_tongji_title.Y = 0
    bt_tongji_arrow.IsChecked = true
    bt_tongji_arrow.TouchClick = function(sender)
        cvs_dungeon_tongji1.Visible = sender.IsChecked == false
        cvs_tongji_title.Y = (cvs_dungeon_tongji1.Visible and cvs_dungeon_tongji1.Height) or 0
    end
    local sp_tongji = self.cvs_dungeon_tongji:FindChildByEditName("sp_tongji",true)
    sp_tongji.Visible = false
end

local function ShowGuildBossHud(show)
    local tbt_geren = self.cvs_guild_boss:FindChildByEditName("tbt_geren",true)
    local tbt_xianmeng = self.cvs_guild_boss:FindChildByEditName("tbt_xianmeng",true)
    local sp_rank = self.cvs_guild_boss:FindChildByEditName("sp_rank",true)
    local sp_rank_guild = self.cvs_guild_boss:FindChildByEditName("sp_rank_guild",true)
    local cvs_self = self.cvs_guild_boss:FindChildByEditName("cvs_self",true)
    local cvs_self_guild = self.cvs_guild_boss:FindChildByEditName("cvs_self_guild",true)
    sp_rank.Visible = false
    sp_rank_guild.Visible = false
    Util.InitMultiToggleButton(function (sender)
        sp_rank.Visible = tbt_geren.IsChecked
        cvs_self.Visible = tbt_geren.IsChecked
        sp_rank_guild.Visible = tbt_xianmeng.IsChecked
        cvs_self_guild.Visible = tbt_xianmeng.IsChecked
    end,tbt_geren,{tbt_geren,tbt_xianmeng})

    local tbn_back = self.cvs_guild_boss:FindChildByEditName("tbn_back",true)
    local cvs_left1 = self.cvs_guild_boss:FindChildByEditName("cvs_left1",true)
    local cvs_rank_item = self.cvs_guild_boss:FindChildByEditName("cvs_rank_item",true)
    local lb_canyurenshu = self.cvs_guild_boss:FindChildByEditName("lb_canyurenshu",true)
    tbn_back.IsChecked = false
    tbn_back.TouchClick = function(sender)
        cvs_left1.Visible = not sender.IsChecked
    end

    cvs_rank_item.Visible = false
    lb_canyurenshu.Text = 0

    self.personalTimes = 0
    self.totalTimes = 0
    self.totalDefenseTimes = 0

    local function ReqInspire(index,cb)
        local personalMax = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "GuildBoss.InspireMaxNum1"})[1].ParamValue)
        local totalMax = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "GuildBoss.InspireMaxNum2"})[1].ParamValue)
        local totalDefenseMax = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "GuildBoss.InspireMaxNum3"})[1].ParamValue)
        if index == 1 and self.personalTimes >= personalMax then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, "personlimit"))
            return
        elseif index == 2 and self.totalTimes >= totalMax then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, "xianmenglimit"))
            return
        elseif index == 3 and self.totalDefenseTimes >= totalDefenseMax then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP, "xianmenglimit"))
            return
        end

        local costData
        local CostDiamond
        local tips
        if index == 1 then
            costData = GlobalHooks.DB.Find("InspireLevel", {InspireType = index, InspireNum = self.personalTimes+1})[1]
            CostDiamond = Util.GetText(TextConfig.Type.FUBEN,'resGuildBossInspire1')
            tips = string.format(CostDiamond,costData.InspireCost,costData.InspirePlus,"%")
        elseif index == 2 then
            costData = GlobalHooks.DB.Find("InspireLevel", {InspireType = index, InspireNum = self.totalTimes+1})[1]
            CostDiamond = Util.GetText(TextConfig.Type.FUBEN,'resGuildBossInspire1')
            tips = string.format(CostDiamond,costData.InspireCost,costData.InspirePlus,"%")
        elseif index == 3 then
            costData = GlobalHooks.DB.Find("InspireLevel", {InspireType = index, InspireNum = self.totalDefenseTimes+1})[1]
            CostDiamond = Util.GetText(TextConfig.Type.FUBEN,'resGuildBossInspire2')
            tips = string.format(CostDiamond,costData.InspireCost,costData.InspirePlus)
        end
        
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            tips,
            Util.GetText(TextConfig.Type.FUBEN, "ok"),
            Util.GetText(TextConfig.Type.FUBEN, "cancle"),
            nil,
            function()
                if costData.InspireCost > DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.TICKET,0) then
                local content = Util.GetText(TextConfig.Type.SHOP, "notenouchbangyuan")
                local ok = Util.GetText(TextConfig.Type.SHOP, "OK")
                local cancel = Util.GetText(TextConfig.Type.SHOP, "Cancel")
                local title = Util.GetText(TextConfig.Type.SHOP, "bangyuanbuzu")
                GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, ok, cancel, title, nil, 
                    function()
                        GDRQ.GuildBossInspireRequest(index)
                    end, 
                    nil)
                else
                    GDRQ.GuildBossInspireRequest(index)
                end
            end,
            nil
        )
    end

    local cvs_geren = self.cvs_guild_boss:FindChildByEditName("cvs_geren",true)
    local cvs_xianmeng = self.cvs_guild_boss:FindChildByEditName("cvs_xianmeng",true)
    local cvs_xianmeng2 = self.cvs_guild_boss:FindChildByEditName("cvs_xianmeng2",true)

    cvs_geren.TouchClick = function(sender)
        ReqInspire(1)
    end
    cvs_xianmeng.TouchClick = function(sender)
        ReqInspire(2)
    end
    cvs_xianmeng2.TouchClick = function(sender)
        ReqInspire(3)
    end
end

local function OnGuildBossHurtPush(eventname,params)
    local function updateRankItem(node,data)
        if node and data then
            node.Visible = true
            node:FindChildByEditName("lb_rank",true).Text = data.rank
            node:FindChildByEditName("lb_name",true).Text = data.name
            node:FindChildByEditName("lb_number",true).Text = Util.NumberToShow(data.hurt or 0)
        else
            node.Visible = false
        end
    end

    local cvs_rank_item = self.cvs_guild_boss:FindChildByEditName("cvs_rank_item",true)
    local sp_rank = self.cvs_guild_boss:FindChildByEditName("sp_rank",true)
    local sp_rank_guild = self.cvs_guild_boss:FindChildByEditName("sp_rank_guild",true)
    local cvs_self = self.cvs_guild_boss:FindChildByEditName("cvs_self",true)
    local cvs_self_guild = self.cvs_guild_boss:FindChildByEditName("cvs_self_guild",true)
    local lb_canyurenshu = self.cvs_guild_boss:FindChildByEditName("lb_canyurenshu",true)
    
    local datalist = params.data.otherInfo or {}
    sp_rank:Initialize(cvs_rank_item.Width, cvs_rank_item.Height+5, #datalist, 1, cvs_rank_item,
      function(x, y, cell)
          updateRankItem(cell,datalist[y + 1])
      end,
      function()
      end
    )

    local datalist1 = params.data.otherGuildInfo or {}
    sp_rank_guild:Initialize(cvs_rank_item.Width, cvs_rank_item.Height+5, #datalist1, 1, cvs_rank_item,
      function(x, y, cell)
          updateRankItem(cell,datalist1[y + 1])
      end,
      function()
      end
    )

    updateRankItem(cvs_self,params.data.myInfo or nil)
    updateRankItem(cvs_self_guild,params.data.myGuildInfo or nil)
    cvs_self.Visible = sp_rank.Visible
    cvs_self_guild.Visible = sp_rank_guild.Visible
    
    lb_canyurenshu.Text = params.data.join_count
end

local function OnGuildBossInspireChange(eventname,params)
    local cvs_geren = self.cvs_guild_boss:FindChildByEditName("cvs_geren",true)
    local cvs_xianmeng = self.cvs_guild_boss:FindChildByEditName("cvs_xianmeng",true)
    local cvs_xianmeng2 = self.cvs_guild_boss:FindChildByEditName("cvs_xianmeng2",true)

    local inspireNode
    if params.data.index == 1 then
        inspireNode = cvs_geren
        self.personalTimes = params.data.totalTimes
    elseif params.data.index == 2 then
        inspireNode = cvs_xianmeng
        self.totalTimes = params.data.totalTimes
    elseif params.data.index == 3 then
        inspireNode = cvs_xianmeng2
        self.totalDefenseTimes = params.data.totalTimes
    end

    if inspireNode then
        local lb_inspire = inspireNode:FindChildByEditName("lb_inspire",true)
        if params.data.index == 1 or params.data.index == 2 then
            lb_inspire.Text = (params.data.totalValue or 0) .. "%"
        else
            lb_inspire.Text = "+ " .. (params.data.totalValue or 0)
        end
    end
end

local function stopCdLabel()
    if self.CDLabelExt ~= nil then
        self.CDLabelExt:stop()
        self.CDLabelExt = nil
    end
end

local function stopDemonTowerCdLabel()
    if self.CDLabelDemonTower ~= nil then
        self.CDLabelDemonTower:stop()
        self.CDLabelDemonTower = nil
    end
end


local function stopJXCdLabel()
    if self.CDLabelExtJXDungeons ~= nil then
        self.CDLabelExtJXDungeons:stop()
        self.CDLabelExtJXDungeons = nil
    end
end

local function UpdateTowerCD()
    local lb_towercdnum = self.cvs_tower:FindChildByEditName("lb_towercdnum",true)
    local cdCount = GlobalHooks.DB.Find("Parameters", {ParamName = "DemonTower.LimitTime"})[1].ParamValue
    local function format(cd,label)
        if cd <= 0 then
            cd = 0
            stopDemonTowerCdLabel()
        else
            UpdateLimitTimeStr(cd,label)
        end
    end
    self.CDLabelDemonTower = CDLabelExt.New(lb_towercdnum,cdCount,format,nil,1)
    self.CDLabelDemonTower:start()

end

local function OnQuitGuildBoss(eventname,params)
    self.cvs_leavedugeon.Visible = true
    
    local textlb = self.cvs_leavedugeon:FindChildByEditName("lb_leavedg",true)
    textlb.Text = Util.GetText(TextConfig.Type.FUBEN,'willLeaveFuben')
    local function callback()
        stopCdLabel()
        stopJXCdLabel()
        Util.clearUIEffect(self.btn_tuichu,41)
    end

    local addEffect = false
    local function format(cd,label)
        if addEffect == false and self.btn_tuichu.Visible then
            Util.showUIEffect(self.btn_tuichu,41)
            addEffect = true
        end
        return ServerTime.GetTimeStr(cd)
    end

    local lb = self.cvs_leavedugeon:FindChildByEditName("lb_leave_time",true)
    lb.Visible = true
    stopCdLabel()
    stopJXCdLabel()
    self.CDLabelExt = CDLabelExt.New(lb,params.cd,format,callback)
    self.CDLabelExt:start()
end


local function AutoOpenFunction()
    if Relive.AutoOpenFeatureId then
        if Relive.AutoOpenFeatureId.param == nil then
            GlobalHooks.OpenUI(Relive.AutoOpenFeatureId.id, 0)
        else
            GlobalHooks.OpenUI(Relive.AutoOpenFeatureId.id, 0, Relive.AutoOpenFeatureId.param)
        end
        Relive.AutoOpenFeatureId = nil
    end
end

local function InitCustomerService()
    local isIphone = UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
    if isIphone then
        local mask =  DataMgr.Instance.UserData:GetClientConfig('customer_closed')
        if not mask then
            SDKWrapper.Instance:ShowCustomerService(true)
        else
            SDKWrapper.Instance:ShowCustomerService(false)
        end
    end
end

local function stopPvpWaitLabel()
    if self.cvs_5v5_fellin_timer ~= nil then
        self.cvs_5v5_fellin_timer:Stop()
        self.cvs_5v5_fellin_timer = nil
    end
    if self.cvs_1v1_fellin_timer ~= nil then
        self.cvs_1v1_fellin_timer:Stop()
        self.cvs_1v1_fellin_timer = nil
    end
end

local function RemoveMJFlgEvent()
    RemoveUpdateEvent("Event.UpdateMJTime", true)
end

local function UpdateMijingActivity()
    local data = GlobalHooks.DB.Find('Schedule',15)
    local timeSeq = string.split(data.PeriodInCalendar, ';')
    AddUpdateEvent("Event.UpdateMJTime", function(deltatime)
        UpdateActivityFlagTimeStr(self.lb_daojishi, timeSeq, 7)
    end)
end

local function initSceneType()
    
    GameAlertManager.Instance:HideCDTips()
    ChangeAutoBattleMode()
    stopCdLabel()
    stopJXCdLabel()
    stopPvpWaitLabel()
    OnSetHudMaskTouchEnable("",{value = false})
    
    local mapId = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.MAPID)
    local mapData = GlobalHooks.DB.Find("Map", { MapID = mapId })[1]
    local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
    local hudMgr = HudManagerU.Instance
    local isSolo = PublicConst.SceneType.SOLO == sceneType
    local isArena = PublicConst.SceneType.ARENA == sceneType
    local isDungeon = PublicConst.SceneType.Dungeon == sceneType
    local isResourceDungeon = PublicConst.SceneType.ResourceDungeon == sceneType
    local isDemonTower = PublicConst.SceneType.DemonTower == sceneType
    local isGuildDungeon = PublicConst.SceneType.GuildDungeon == sceneType
    local isGuildBoss = PublicConst.SceneType.GuildBoss == sceneType
    local isAllyWar = PublicConst.SceneType.AllyWar == sceneType
    local isNormal = PublicConst.SceneType.Normal == sceneType
    local isCrossServer = PublicConst.SceneType.CrossServer == sceneType
    local isWorldBoss = PublicConst.SceneType.WorldBoss == sceneType
    local is5v5 = PublicConst.SceneType.FiveVSFive == sceneType
    local isHJBoss = PublicConst.SceneType.HJBoss == sceneType
    local isMJBoss = PublicConst.SceneType.MJBoss == sceneType
    local isHaoyuejing = PublicConst.SceneType.Haoyuejing == sceneType
    local isLimitDungeon = PublicConst.SceneType.LimitDungeon == sceneType
    local isGuildWarGather = PublicConst.SceneType.GuildWarGather == sceneType
    local isGuildWarFight = PublicConst.SceneType.GuildWarFight == sceneType
    

    SetHotFlag()

    self.cvs_shouhu.Visible = false
    self.cvs_mijing2.Visible = isMJBoss
    self.cvs_tower.Visible = isDemonTower
    if isDemonTower then 
        UpdateTowerCD()
    else
        stopDemonTowerCdLabel()
    end
    if isMJBoss then
        UpdateMijingActivity()
    else
        RemoveMJFlgEvent()
    end 
    self.cvs_huanjing.Visible = isHJBoss
    self.cvs_huanjing.TouchClick = function(sender)
        EventManager.Fire('Event.Goto', {id = "Dreamland"})
    end

    
    if isResourceDungeon and mapId == 51001 or mapId == 51002 or mapId == 51003 then 
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFightLimitReward)
    end

    
    self.cvs_guild_judian.Visible = false
    if isGuildWarGather or isGuildWarFight then
        InitGuildWarUI()
    end

    
    self.cvs_dungeon_tongji.Visible = isDungeon or isLimitDungeon
    if isDungeon or isLimitDungeon then
        InitDungeonTongJiUI()
    end

    if isSolo then
        local soloHud, node = SoloHud.getOrCreate()
        if soloHud then
            soloHud:reset()
        end
    else
        SoloHud.destroy()
    end

    if is5v5 then
        _5v5Hud.Close()
        _5v5Hud.Create()
        HudManagerU.Instance:foreSetHeroPkModel(4)
    else
        _5v5Hud.Close()
    end

    if isArena then
        EventManager.Fire('Event.Arena.ShowHud',{})
    else
        EventManager.Fire('Event.Arena.CloseShowHud',{})
    end

    local isSpecialScene = isSolo or isArena or isAllyWar or is5v5
    if isSpecialScene then
        ReliveUI.setHideReliveUI(true)
        EventManager.Fire("Event.Quest.CancelAuto", {})
    else
        HudManagerU.Instance:closeAutoAnimi(8) 
        ReliveUI.setHideReliveUI(false)
    end

    if isSolo or isArena or isAllyWar or isDungeon or isLimitDungeon or isResourceDungeon or isDemonTower 
        or isGuildDungeon or is5v5 or isGuildBoss or isGuildWarGather or isGuildWarFight then
        hideMenuAction()
    elseif isNormal or isCrossServer or isWorldBoss or isHJBoss or isHaoyuejing or isMJBoss then
        showMenuAction()
    end

    if isDungeon or isLimitDungeon or isResourceDungeon or isDemonTower or isHaoyuejing or isGuildBoss then
        DoAutoFight()
    end

    self.isSpecialScene = isSpecialScene
    local iconRoot = self.root:FindChildByEditName("cvs_hud_message", true)
    iconRoot.Visible = false
    hudMgr.TeamQuest.Visible = not isSpecialScene
    self.cvs_ride.Visible = not isArena

    self.cvs_guild_boss.Visible = isGuildBoss
    if isGuildBoss then
        ShowGuildBossHud()
    end

    self.cvs_welfare.Visible = not isSpecialScene
    SetWelFareFlag()

    self.cvs_mall.Visible = not isSpecialScene
    SetShopmallFlag()

    SetActivityFlag()
    SetActivityOpenFlag()

    self.cvs_activity.Visible = not isSpecialScene
    self.cvs_target.Visible = not isSpecialScene
    self.cvs_guoyuan.Visible = false
    self.cvs_mail.Visible = not isSpecialScene
    self.cvs_setting.Visible = not isSpecialScene
    self.tb_autofight.Enable = not isAllyWar
    self.tb_autofight.EnableChildren = self.tb_autofight.Enable
    self.cvs_bag.Visible = not isSpecialScene
    self.cvs_sociality.Visible = not isSpecialScene
    self.btn_bag.Enable = not isSolo and not isAllyWar and not is5v5
    self.btn_bag.EnableChildren = self.btn_bag.Enable
    self.cvs_leavedugeon.Visible = false
    self.cvs_revive.Visible = false

    Util.clearAllEffect(self.btn_tuichu)
    self.btn_tuichu.Visible = isDungeon or isResourceDungeon or isDemonTower or isGuildDungeon or isAllyWar or isHaoyuejing or isGuildBoss or isMJBoss or isLimitDungeon or isGuildWarGather

    local function OnCloseArenaHud()
        local left = HudManagerU.Instance:GetHudUI('Arena.Hud.Left')
        local top_right = HudManagerU.Instance:GetHudUI('Arena.Hud.TopRight')
        if left then
            left.Visible = false
        end
        if top_right then
            top_right.Visible = false
        end
    end

    if not isArena then
        OnCloseArenaHud()
    end

    local payGiftSign = not (PlayerModel.GetBindPlayerData().payGiftData == 2)
    self.cvs_firstpay.Visible = payGiftSign  and not isSpecialScene
    self.cvs_pay.Visible = not payGiftSign and not isSpecialScene

    local exitmijing = Util.GetText(TextConfig.Type.MAP, "exitmijing")
    local btnOK = Util.GetText(TextConfig.Type.MAP, "btnOK")
    local btnCancel = Util.GetText(TextConfig.Type.MAP, "btnCancel")
    local exitScene = Util.GetText(TextConfig.Type.MAP, "exitScene")

    self.btn_tuichu.TouchClick = function(sender)
        local fightingEnd = self.cvs_leavedugeon.Visible == true
        if isArena then
            
        elseif isMJBoss then
            
            GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL,
                exitmijing,btnOK,btnCancel,nil,
                function()
                    FubenApi.requestLeaveFuben()
                end ,
                nil
            )
        elseif isDungeon or isResourceDungeon or isLimitDungeon then
            local function callback()
                stopCdLabel()
                GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL,
                exitScene,btnOK,btnCancel,nil,
                function()
                    FubenApi.requestLeaveFuben()
                end ,
                nil
                )
                if not fightingEnd then
                    if DataMgr.Instance.TeamData.HasTeam and DataMgr.Instance.TeamData:IsLeader() then
                             
                        if DataMgr.Instance.QuestManager.autoControl.IsAuto then
                            EventManager.Fire("Event.Quest.CancelAuto", {quit = 1});
                        end
                    end
                end
            end
            callback()
        elseif isDemonTower then
            GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL,
                exitScene,btnOK,btnCancel,nil,
                function()
                    FubenApi.requestLeaveFuben()
                end ,
                nil
            )
        elseif isGuildDungeon then
            local GuildDungeonApi = require "Zeus.Model.GuildDungeon"
            if not fightingEnd then
                local txt = Util.GetText(TextConfig.Type.FUBEN, 'quitGuildDungeon')
                GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL,
                txt,'','',nil,
                function()
                    GuildDungeonApi.requestLeaveDungeon()
                end,
                emptyFunc
                )
            else
                GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL,
                exitScene,btnOK,btnCancel,nil,
                function()
                    FubenApi.requestLeaveFuben()
                end ,
                nil
                )
            end
        elseif isAllyWar then
            GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL,
                exitScene,btnOK,btnCancel,nil,
                function()
                    FubenApi.requestLeaveFuben()
                end,
                nil
            )
        elseif isHaoyuejing then
            if not fightingEnd then
                
                GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL,
                exitScene,btnOK,btnCancel,nil,
                function()
                    if not fightingEnd then
                    if DataMgr.Instance.TeamData.HasTeam and DataMgr.Instance.TeamData:IsLeader() then
                             
                        if DataMgr.Instance.QuestManager.autoControl.IsAuto then
                            EventManager.Fire("Event.Quest.CancelAuto", {quit = 1});
                        end
                    end
                end

                FubenApi.requestLeaveFuben()
                end ,
                nil
                )
            else
                GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL,
                exitScene,btnOK,btnCancel,nil,
                function()
                    FubenApi.requestLeaveFuben()
                end ,
                nil
                )
            end
        elseif isGuildBoss or isGuildWarGather then
            GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL,
                exitScene,btnOK,btnCancel,nil,
                function()
                    FubenApi.requestLeaveFuben()
                end ,
                nil
            )
        end
    end

    self.btn_revive.TouchClick = function(sender)
        local reliveMenu = MenuMgrU.Instance:CreateUIByTag(GlobalHooks.UITAG.GameUIDeadCommon, 0)
        MenuMgrU.Instance:AddMsgBox(reliveMenu)
        self.cvs_revive.Visible = false
    end

    if isResourceDungeon then
        
        if mapId == 51001 or mapId == 51002 or mapId == 51003 then
            stopJXCdLabel()
            FubenApi.SetResFubenTime(0)
            FubenApi.resourceCountDownRequest(function(time)
                self.cvs_leavedugeon.Visible = true
                local textlb = self.cvs_leavedugeon:FindChildByEditName("lb_leavedg",true)
                textlb.Text = Util.GetText(TextConfig.Type.FUBEN,'fubenTimeLeft')
                local lb = self.cvs_leavedugeon:FindChildByEditName("lb_leave_time",true)
                lb.Visible = true
                local function format(cd,label)
                    if cd <= 0 then
                        cd = 0 
                        stopJXCdLabel()
                    end
                    FubenApi.SetResFubenTime(time - cd)
                    return string.format(string_format_time,cd)
                end
                self.CDLabelExtJXDungeons = CDLabelExt.New(lb,time,format)
                self.CDLabelExtJXDungeons:start()
            end)
        
        elseif mapId == 51004 or mapId == 51005 or mapId == 51006 then
            self.lb_shouhu_num.Text = 0
            self.cvs_shouhu.Visible = true
        end
    elseif isDungeon then
        FubenApi.reqRemainTipsRequest()
    end
    
    local rolebag = DataMgr.Instance.UserData.RoleBag 
    local iter = rolebag.AllData:GetEnumerator()
    local isred = false
    while iter:MoveNext() do
        local data = iter.Current.Value
        local it = GlobalHooks.DB.Find("Items", data.TemplateId)
        if data.Type == ItemData.TYPE_CHEST or (it.RedPoint and it.RedPoint == 1) then
           isred = true
           break
        end         
    end 

    RefreshMsgIcon()
    AutoOpenFunction()
    InitCustomerService()

    GlobalHooks.Drama.StartCacheGuide()

    EventManager.Fire("Event.Hud.red", {value=isred})

    Pomelo.PlayerHandler.clientReadyRequest(function()
    end)
end

local function OnFubenWillClose(evtName, params)
    self.cvs_leavedugeon.Visible = true
    
    local textlb = self.cvs_leavedugeon:FindChildByEditName("lb_leavedg",true)
    textlb.Text = Util.GetText(TextConfig.Type.FUBEN,'willLeaveFuben')

    local function callback()
        stopCdLabel()
        stopJXCdLabel()
        Util.clearUIEffect(self.btn_tuichu,41)
        FubenApi.requestLeaveFuben()
    end
    
    local addEffect = false
    local function format(cd,label)
        if params.cd - cd >= 10 and addEffect == false and self.btn_tuichu.Visible then
            Util.showUIEffect(self.btn_tuichu,41)
            addEffect = true
        end
        return string.format(string_format_time,cd)
    end

    local lb = self.cvs_leavedugeon:FindChildByEditName("lb_leave_time",true)
    lb.Visible = true
    stopCdLabel()
    self.CDLabelExt = CDLabelExt.New(lb,params.cd,format,callback)
    self.CDLabelExt:start()

    
    
    
    
    
    
end

local function showPvpWait(ename, params)
    local cvs_5v5_fellin = self.root:FindChildByEditName("cvs_5v5_fellin", true)
    
    local cvs_icon = cvs_5v5_fellin:FindChildByEditName("cvs_icon", true)
    local lb_wait = cvs_5v5_fellin:FindChildByEditName("lb_wait", true)
    local lb_waitNum = cvs_5v5_fellin:FindChildByEditName("lb_waitNum", true)
    local lb_queue = cvs_5v5_fellin:FindChildByEditName("lb_queue", true)
    local lb_toenter = cvs_5v5_fellin:FindChildByEditName("lb_toenter", true)
    if not cvs_5v5_fellin.Visible or not lb_waitNum.Visible then
        cvs_5v5_fellin.Visible = true
        lb_wait.Visible = true
        lb_waitNum.Visible = true
        lb_toenter.Visible = false
        lb_queue.Visible = true
        cvs_5v5_fellin.TouchClick = function (sender)
            print("cvs_5v5_fellin")
            local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5WaitEnter)
            if obj then
              menu.Visible = true
            else
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUI5V5Main)
            end
        end
    end

    if params.waitNum then
        lb_waitNum.Text = params.waitNum
    end

    if params.startTime ~= nil then
        local refreshTime = function()
            
            local nowTime = ServerTime.GetServerUnixTime()
            local time = nowTime - params.startTime
            if time < 0 then
                time = 0
            end
            lb_wait.Text = ServerTime.FormatCD(time)
        end

        refreshTime()
        if self.cvs_5v5_fellin_timer ~= nil then
            self.cvs_5v5_fellin_timer:Stop()
        end
        self.cvs_5v5_fellin_timer = Timer.New(refreshTime, 1, -1)
        self.cvs_5v5_fellin_timer:Start()
    end
end

local function stopPvpWait(ename, params)
    if self.cvs_5v5_fellin_timer ~= nil then
        self.cvs_5v5_fellin_timer:Stop()
        self.cvs_5v5_fellin_timer = nil
    end
    local cvs_5v5_fellin = self.root:FindChildByEditName("cvs_5v5_fellin", true)
    cvs_5v5_fellin.Visible = true
    local lb_queue = cvs_5v5_fellin:FindChildByEditName("lb_queue", true)
    local lb_waitNum = cvs_5v5_fellin:FindChildByEditName("lb_waitNum", true)
    local lb_toenter = cvs_5v5_fellin:FindChildByEditName("lb_toenter", true)
    lb_queue.Visible = false
    lb_waitNum.Visible = false
    lb_toenter.Visible = true

end

local function hidePvpWait(ename, params)
    local cvs_5v5_fellin = self.root:FindChildByEditName("cvs_5v5_fellin", true)
    cvs_5v5_fellin.Visible = false
    if self.cvs_5v5_fellin_timer ~= nil then
        self.cvs_5v5_fellin_timer:Stop()
        self.cvs_5v5_fellin_timer = nil
    end
end

local function show1v1Wait(ename, params)
    local cvs_1v1_fellin = self.root:FindChildByEditName("cvs_1v1_fellin", true)
    local cvs_icon = cvs_1v1_fellin:FindChildByEditName("cvs_icon", true)
    local lb_wait = cvs_1v1_fellin:FindChildByEditName("lb_wait", true)
    local lb_queue = cvs_1v1_fellin:FindChildByEditName("lb_queue", true)
    local lb_toenter = cvs_1v1_fellin:FindChildByEditName("lb_toenter", true)
    if not cvs_1v1_fellin.Visible then
        cvs_1v1_fellin.Visible = true
        lb_wait.Visible = true
        lb_toenter.Visible = false
        lb_queue.Visible = true
        cvs_1v1_fellin.TouchClick = function (sender)
            print("cvs_1v1_fellin")
            local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUISolo)
            if obj then
              menu.Visible = true
            else
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISolo)
            end
        end
    end

    
    lb_wait.Text = ServerTime.FormatCD(0)
    local startTime = ServerTime.GetServerUnixTime()
    local refreshTime = function()
        local nowTime = ServerTime.GetServerUnixTime()
        local time = nowTime - startTime
        if time < 0 then
            time = 0
        end
        lb_wait.Text = ServerTime.FormatCD(time)
    end
    if self.cvs_1v1_fellin_timer ~= nil then
        self.cvs_1v1_fellin_timer:Stop()
    end
    self.cvs_1v1_fellin_timer = Timer.New(refreshTime, 0.1, -1)
    self.cvs_1v1_fellin_timer:Start()
end

local function hide1v1Wait(ename, params)
    local cvs_1v1_fellin = self.root:FindChildByEditName("cvs_1v1_fellin", true)
    cvs_1v1_fellin.Visible = false
    if self.cvs_1v1_fellin_timer ~= nil then
        self.cvs_1v1_fellin_timer:Stop()
        self.cvs_1v1_fellin_timer = nil
    end
end


local function OnShowCurrencyUI(evtName, params)
    if self.showCurrencyTag == nil then
        self.showCurrencyTag = {}
    end
    local menu = XmdsUISystem.Instance:UILayerFindChildByName("MenuBase - 11003",true)
    if menu == nil then
        self.showCurrencyTag = {}
        local currencyRoot = LuaMenuU.Create('xmds_ui/common/currency.gui.xml', GlobalHooks.UITAG.GameUICurrencyTip) 
        currencyRoot.Enable = false             
        self.currencyRoot = currencyRoot
        local cvs_rmby = self.currencyRoot:FindChildByEditName("cvs_rmby",true)
        local btn_rmby = cvs_rmby:FindChildByEditName("addBtn",true)
        btn_rmby.TouchClick = function()
            if MenuMgrU.Instance:FindMenuByTag(GlobalHooks.UITAG.GameUIShop) == nil then
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop,-1,"pay")
            end
        end
        local cvs_rmby_bind = self.currencyRoot:FindChildByEditName("cvs_rmby_bind",true)
        local btn_rmby_bind = cvs_rmby_bind:FindChildByEditName("addBtn",true)
        btn_rmby_bind.TouchClick = function()
            if MenuMgrU.Instance:FindMenuByTag(GlobalHooks.UITAG.GameUIShop) == nil then
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop,-1,"card")
            end
        end
        local cvs_silver = self.currencyRoot:FindChildByEditName("cvs_silver",true)
        local btn_silver = cvs_silver:FindChildByEditName("addBtn",true)
        btn_silver.TouchClick = function()
            local menu = MenuMgrU.Instance:FindMenuByTag(GlobalHooks.UITAG.GameUIShop)
            if menu then
                MenuMgrU.Instance:CloseMenuByTag(GlobalHooks.UITAG.GameUIShop)
            end
            local o, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIItemGetDetail)
            if obj then
                GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIItemGetDetail)
            end
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, "gold10w")
        end
        initCurrency()
        XmdsUISystem.Instance:UILayerAddChild(currencyRoot);
       
        HudManagerU.Instance:InitAnchorWithNode(self.currencyRoot, bit.bor(HudManagerU.HUD_LEFT, HudManagerU.HUD_TOP))
        local bt_scoreshop = self.currencyRoot:FindChildByEditName("bt_scoreshop",true)
        local ib_ricon = self.currencyRoot:FindChildByEditName("ib_ricon",true)
        if DataMgr.Instance.FlagPushData:GetFlagState(3700)>0 then
            ib_ricon.Visible = true
        else
            ib_ricon.Visible = false
        end
        bt_scoreshop.TouchClick = function(sender)
            if ib_ricon.Visible then
                ib_ricon.Visible = false
            end
            if MenuMgrU.Instance:FindMenuByTag(GlobalHooks.UITAG.GameUIShopScore) == nil then
                GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShopScore)
            end
        end
    end
    self.showCurrencyTag[params.tag] = 1
    self.currencyRoot.Visible = true
    if DataMgr.Instance.UserData then
         local lb_rmby_num = self.currencyRoot:FindChildByEditName("lb_rmby_num",true)
         local lb_bind_num = self.currencyRoot:FindChildByEditName("lb_bind_num",true)
         local lb_silver_num = self.currencyRoot:FindChildByEditName("lb_silver_num",true)
        lb_rmby_num.Text = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.DIAMOND,0)
        lb_bind_num.Text = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.TICKET,0)
        lb_silver_num.Text = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.GOLD,0)
    end
end
	
local function OnCloseCurrencyUI(evtName, params)
    self.showCurrencyTag[params.tag] = nil
    for k,v in pairs(self.showCurrencyTag) do
        if v then
            return
        end
    end
    self.currencyRoot.Visible = false
end
    													
local function ShowPetReviveBtn(ename, params)
    
    if DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.PETID) ~= "" then
        if self.cvs_revive ~= nil then
            self.cvs_revive.Visible = params.Show
        end
    else
        self.cvs_revive.Visible = false
    end
end

local function SetMenuChecked(ename, params)
    local btn = self.cvs_menu:FindChildByEditName("btn_menu", true)
    btn.IsChecked = false
end

local function OnShowItemDetail(evtName,param)
    if param then
        local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISimpleDetail,0)
        if param.itemData then
            
            obj:SetItem(param.itemData,param.itemData.IsEquip)
        elseif param.data then
            
            obj:SetItemDetail(param.data)
        elseif param.templateId then
            
            local detail = ItemModel.GetItemDetailByCode(param.templateId)
            obj:SetItemDetail(detail)
        elseif param.id then
            
            local item = params.item or ItemModel.GetItemById(params.id)
            obj:SetItem(item,item.IsEquip)
        end
        if param.pos then
            
            obj:setXmlPos(param.pos)
        else
            obj:setXmlPos(Vector2.New(456,69))
        end
        if param.buttons then
            
            obj:setButtons(param.buttons,param.closeCallback)
        elseif param.closeCallback then
            
            obj:setCloseCallback(param.closeCallback)
        end
    end
end

local function OnTeamSetFollowLeader(evtName,param)
    local value = tonumber(param.follow)
    local function callback(param)
        EventManager.Fire("Event.TeamSetFollowLeaderOK",{follow = param})
    end
    TeamModel.RequestTeamSetFollowLeader(value,callback)
end

local function OnTeamInviteFollow(evtName,param)
    
    TeamModel.RequestSummonAllMembers()
end

local function OnTeamChangeTarget(evtName,param)


end

local function OnAddCurrencyChat(evtName,param)
    local key = param.key
    local value = tonumber(param.value)
    local content = nil
    if key == "exp" then
        if(param.value1) then
            content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.CHAT, "gain_exp_text1")
            local value1 = tonumber(param.value1)
            content = string.format(content,value,value1)
        else
            content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.CHAT, "gain_exp_text")
            content = string.format(content,value)
        end
    elseif key == "gold" then
        content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.CHAT, "gain_gold_text")
        content = string.format(content,value)
    elseif key == "classExp" then
        content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.CHAT, "gain_upexp_text")
        content = string.format(content,value)
    elseif key == "diamond" then
        content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.CHAT, "gain_diamond_text")
        content = string.format(content,value)
    elseif key == "ticket" then
        content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.CHAT, "gain_ticket_text")
        content = string.format(content,value)
    end
    if content == nil then
        return
    end
    local param = {}
    param.s2c_playerId = DataMgr.Instance.UserData.RoleID
    param.s2c_uid = DataMgr.Instance.UserData.UserId
    param.s2c_content = content
    param.s2c_scope = 7
    param.s2c_time = ""
    param.s2c_sys = 0
    param.s2c_serverData = "{\"acceptRoleId\":\"\",\"s2c_level\":%d,\"s2c_name\":\"%s\",\"s2c_pro\":%d,\"s2c_vip\":0,\"s2c_zoneId\":%d}"
    param.s2c_serverData = string.format(param.s2c_serverData,DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0),
        DataMgr.Instance.UserData.Name,DataMgr.Instance.UserData.Pro,DataMgr.Instance.UserData.SceneId)
    ChatModel.dealSysChatMsg(param)
end

local function onEnvironmentChange(eventname,params)
    
    local isResourceDungeon = PublicConst.SceneType.ResourceDungeon == PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
    if params.key == "round" then
        if isResourceDungeon and params.value > 0 then
            HudManagerU.Instance:showAutoAnimi(100, params.value)
            self.lb_shouhu_num.Text = params.value
            self.cvs_shouhu.Visible = true
            FubenApi.SetResFubenWave(params.value)
        end
    elseif params.key == "Be_at_death" then
        if isResourceDungeon and params.value > 0 then
            HudManagerU.Instance:showAutoAnimi(101, params.value)
        end
    end
end

local function onStopHudTimeCount(eventname,params)
    stopCdLabel()
    stopJXCdLabel()
    if params.param then
        local lb = self.cvs_leavedugeon:FindChildByEditName("lb_leave_time",true)
        lb.Text = params.param
    end
end

local function OnChangePKToTeamMode(eventname,params)
    local curPKMode = DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.PKMODEL,1)
    if curPKMode == 6 and DataMgr.Instance.TeamData.HasTeam then
        GameAlertManager.Instance:ShowFloatingTips(Util.GetText(TextConfig.Type.PK,'onlyTeam'))
        EventManager.Unsubscribe("Event.joinTeam", OnChangePKToTeamMode)
        PlayerModel.ChangePkModelRequest(4, function(params)
            
            
            local msg = Util.GetText(TextConfig.Type.PK,'changeNotice')
            local sdata = {}
            sdata[1] = Util.GetText(TextConfig.Type.PK,'pkModel5')
            GameAlertManager.Instance:ShowFloatingTips(ChatUtil.HandleString(msg, sdata))
            EventManager.Subscribe("Event.joinTeam", OnChangePKToTeamMode)
        end)
        
    end
end

local function initial()
    
    ChatModel.InitBaseSetData()
    EventManager.Subscribe("Event.PetDeadMsg", ShowPetReviveBtn)
    EventManager.Subscribe("Event.UI.Hud.HideOrShowCvschat", HideOrShowCvsChat)
    EventManager.Subscribe("Event.UI.Hud.LuaHudInit", OnShowUI)
    EventManager.Subscribe("Event.Scene.ChangeFinish", initSceneType)
    EventManager.Subscribe("Event.Menu.OpenFuncEntryMenu", OnShowHudMenu)
    EventManager.Subscribe("Event.Menu.CloseFuncEntryMenuCb", OnCloseMenu)
    EventManager.Subscribe("Event.Menu.CloseFuncEntryMenu", SetMenuChecked)
    EventManager.Subscribe("Event.Menu.MountRing", changeMountBtn)
    EventManager.Subscribe("Event.UI.OnRidingMount", OnRidingMount)
    EventManager.Subscribe("Event.Hud.AutoFight", OnAutoFightStatusChange)
    EventManager.Subscribe("Event.FunctionOpen.WaitToPlay", OpenUIChangeFlag)
    EventManager.Subscribe("Event.AutoBuyItem", AutoBuyItem)
    EventManager.Subscribe("Event.Fuben.WillClose", OnFubenWillClose) 
    EventManager.Subscribe("Event.Hud.ShowCurrency", OnShowCurrencyUI)
    EventManager.Subscribe("Event.Hud.CloseCurrency", OnCloseCurrencyUI)
    EventManager.Subscribe("Event.ShowItemDetail",OnShowItemDetail)
    EventManager.Subscribe("Event.TeamSetFollowLeader",OnTeamSetFollowLeader)
    EventManager.Subscribe("Event.LeaderTeamInviteFollow",OnTeamInviteFollow)
    EventManager.Subscribe("Event.TeamTarget.Set",OnTeamChangeTarget)
    EventManager.Subscribe("Event.AddChat.Currency",OnAddCurrencyChat)
    EventManager.Subscribe("Event.Hud.red",function(evtName,param)
         
         MenuBaseU.SetVisibleUENode(self.root, "lb_bj_bag", param.value)                       
    end)
    DataMgr.Instance.FlagPushData:AttachLuaObserver(9999, self)
    DataMgr.Instance.UserData:AttachLuaObserver(9999, self)
    DataMgr.Instance.MessageData:AttachLuaObserver(9999, self)
    if SDKWrapper.Instance:HasPluginVoice() then
        DataMgr.Instance.TeamData:AttachLuaObserver(9999, { Notify = OnTeamDataNotify })
        
    end
    EventManager.Subscribe("Event.fightLevelHandler.illusionPush", UpdateIllusionPush)
    EventManager.Subscribe("Event.fightLevelHandler.illusion2Push", UpdateIllusionPushBoxNum)
    EventManager.Subscribe("Event.ActivityFavorHandler.LimitTimeGiftInfoPush", OpenLimitGiftUI)
    EventManager.Subscribe("Event.Menu.OpenCharacter", OnShowCharacter)
    
    EventManager.Subscribe("Event.relive.ShowReliveBtn", ShowReliveBtn)
    EventManager.Subscribe("Event.MainMenu.MenuTtnShow", ShowMainMenuBtn)
    EventManager.Subscribe("Event.Hud.showPvpWait",showPvpWait)
    EventManager.Subscribe("Event.Hud.stopPvpWait",stopPvpWait)
    EventManager.Subscribe("Event.Hud.hidePvpWait",hidePvpWait)
    EventManager.Subscribe("Event.Hud.show1v1Wait",show1v1Wait)
    EventManager.Subscribe("Event.Hud.hide1v1Wait",hide1v1Wait)
    EventManager.Subscribe("Event.EnvironmentVarChange", onEnvironmentChange)
    EventManager.Subscribe("Event.Hud.StopHudTimeCount", onStopHudTimeCount)
    EventManager.Subscribe("Event.joinTeam", OnChangePKToTeamMode)
    EventManager.Subscribe("Event.SetHudMaskTouchEnable", OnSetHudMaskTouchEnable)
    
    EventManager.Subscribe("Event.GuildBoss.HurtPush", OnGuildBossHurtPush)
    EventManager.Subscribe("Event.GuildBoss.InspireChange", OnGuildBossInspireChange)
    EventManager.Subscribe("Event.GuildBoss.QuitGuildBoss", OnQuitGuildBoss)
    
    EventManager.Subscribe("Event.GuildWar.UpdateGuildWarUI", OnUpdateGuildWarUI)
    
    EventManager.Subscribe("Event.GuildWar.UpdateDungeonTongJiUI", OnUpdateDungeonTongJiUI)
end
                                                        
return { initial = initial, fin = fin, dont_destroy = true }
