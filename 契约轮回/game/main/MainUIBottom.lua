-- 
-- @Author: LaoY
-- @Date:   2018-08-15 15:33:12
-- 
MainUIBottom = MainUIBottom or class("MainUIBottom", BaseItem)
local MainUIBottom = MainUIBottom

function MainUIBottom:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "MainUIBottom"
    self.layer = layer
    self.isNeedLoadEscInfo = true
    self.model = MainModel:GetInstance()
    self.model_event_list = {}
    self.candy_move_dis = 180
	self.is_showUnion = false
    MainUIBottom.super.Load(self)
end

function MainUIBottom:dctor()
    if self.update_deco_rd_event_id then
        GlobalEvent:RemoveListener(self.update_deco_rd_event_id)
        self.update_deco_rd_event_id = nil
    end
    if self.update_dec_show_event_id then
        GlobalEvent:RemoveListener(self.update_dec_show_event_id)
        self.update_dec_show_event_id = nil
    end
    if self.guild_rd then
        self.guild_rd:destroy()
        self.guild_rd = nil
    end
    if self.chat_red_dot then
        self.chat_red_dot:destroy()
        self.chat_red_dot = nil
    end
    if self.gift_red_dot then
        self.gift_red_dot:destroy()
        self.gift_red_dot = nil
    end

    self:StopAutoStateTime()
    self:RemoveAutoButtonEffect()

    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end

    if self.model_event_list then
        self.model:RemoveTabListener(self.model_event_list)
        self.model_event_list = {}
    end

    if self.role_event_list then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveTabListener(self.role_event_list)
    end

    if self.item_list then
        for k, item in pairs(self.item_list) do
            item:destroy()
        end
    end

    self.item_list = {}

    if self.escortTimeDown then
        GlobalSchedule:Stop(self.escortTimeDown)
        self.escortTimeDown = nil
    end
    if self.chatView then
        self.chatView:destroy()
    end
    if self.guild_chat_reddot then
        self.guild_chat_reddot:destroy()
    end
    if self.marrySchedule then
        GlobalSchedule:Stop(self.marrySchedule);
    end

    if self.auto_move_effect then
        self.auto_move_effect:destroy()
        self.auto_move_effect = nil
    end

    if self.auto_fight_effect then
        self.auto_fight_effect:destroy()
        self.auto_fight_effect = nil
    end
	
	self.is_showUnion = false
end

function MainUIBottom:LoadCallBack()
    self.nodes = {
        "btn_friend",
        "center/img_chat_bg_2",
        "btn_auto",
        "btn_team_apply",
        "btn_team_invited",
        "MainTipItem",
        "center/tip_con",
        "center",
        "btn_jump",
        "btn_escort/escortTime",
        "btn_escort",
        "candy_house/btn_candy_give",
        "candy_house/btn_candy_chat",
        "candy_house", "candy_house/btn_candy_give/gift_red_con", "candy_house/btn_candy_chat/chat_red_con",
        "center/icon_tip_parent/icon_tip_mail",
        "center/icon_tip_parent/icon_tip_setting",
        "center/icon_tip_parent/icon_tip_friend",
        "center/icon_tip_parent/icon_tip_chat",
        "btn_guild", "btn_guild/guild_rd_con",
        "expObj/expTex", "expObj",
        "con_state/img_fly_icon", "con_state",
        "center/icon_tip_parent/icon_tip_help",
		"center/icon_tip_parent/icon_tip_union",
    }
    self:GetChildren(self.nodes)

    SetLocalPositionX(self.img_fly_icon, 130)
    LayerManager:GetInstance():AddOrderIndexByCls(self, self.img_fly_icon, nil, true, nil, nil, 5)
    SetChildLayer(self.img_fly_icon, LayerManager.BuiltinLayer.UI)

    self.transform:SetAsFirstSibling()

    self.btn_auto_img = self.btn_auto:GetComponent('Image')
    self.candy_rect = GetRectTransform(self.candy_house)

    self.MainTipItem_gameObject = self.MainTipItem.gameObject
    SetVisible(self.MainTipItem, false)
    self.escortTime = GetText(self.escortTime)
    self.expTex = GetText(self.expTex)
    self:SetAutoRes()

    self:AddChatView()
    self:AddEvent()

    self:UpdateTipIcon()

    self:CheckCandyIconShow()
    self:SetAutoState()
    self:CheckShowFriend()
    if self.isNeedLoadEscInfo then
        self:ShowEscortIcon()
    end
    local guild = RoleInfoModel:GetInstance():GetRoleValue("guild")
    SetVisible(self.btn_guild, guild ~= "0")
    MailController.Instance:RequestMailInfo()
end

function MainUIBottom:AddChatView()
    self.chatView = ChatViewInMainUI(self.img_chat_bg_2, "UI")
end

function MainUIBottom:AddEvent()
    self.update_deco_rd_event_id = GlobalEvent:AddListener(FashionEvent.AddDecoRD, handler(self, self.SetGuildRD))
    --只是聊天这边用的事件
    self.update_dec_show_event_id = GlobalEvent:AddListener(FashionEvent.ChangeChatDecoRD, handler(self, self.SetGuildRD))

    local function call_back(target, x, y)
        GlobalEvent:Brocast(ChatEvent.OpenChatPanel, 1)
    end
    AddClickEvent(self.img_chat_bg_2.gameObject, call_back)

    local function call_back(target, x, y)
        GlobalEvent:Brocast(FightEvent.AutoFight)
    end
    AddClickEvent(self.btn_auto.gameObject, call_back)

    local function call_back(target, x, y)
        local level = RoleInfoModel:GetInstance():GetRoleValue("level")
        if level < 75 then
            return Notify.ShowText("Friends unlock at Lv.75")
        end
        OpenLink(580, 1)
    end
    AddClickEvent(self.btn_friend.gameObject, call_back)

    local function call_back(target, x, y)
        MailModel.Instance.crntIndex = 2
        lua_panelMgr:GetPanelOrCreate(MailPanel):Open(2)
    end
    AddClickEvent(self.icon_tip_mail.gameObject, call_back)

    local function call_back(target, x, y)
        self:StopFlashButton2(self.icon_tip_friend)
        lua_panelMgr:GetPanelOrCreate(FriendApplyPanel):Open()
    end
    AddClickEvent(self.icon_tip_friend.gameObject, call_back)

    local function call_back(target, x, y)
        self:StopFlashButton2(self.icon_tip_chat)
        local personal_role_id = FriendModel:GetInstance():GetUnReadMessagesRoleId()
        GlobalEvent:Brocast(MailEvent.OpenMailPanel, 1, personal_role_id)
    end
    AddClickEvent(self.icon_tip_chat.gameObject, call_back)

    local function call_back(target, x, y)
        local main_role = SceneManager:GetInstance():GetMainRole()
        if not main_role then
            return
        end
        if main_role.is_swing_block then
            Notify.ShowText("You can't actively jump in deep water area")
            return
        elseif main_role:GetEscortMountID() then
            Notify.ShowText("You can't actively jump when escort is in progress")
            return
        end
        local bo, buff_effect_type = main_role.object_info:IsCanMoveByBuff()
        if not bo then
            main_role:MoveDebuffTip(buff_effect_type, "Jump")
            return
        end
        if main_role then
            main_role:PlayJump()
        end
    end
    AddClickEvent(self.btn_jump.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(SettingPanel):Open()
    end
    AddClickEvent(self.icon_tip_setting.gameObject, call_back)

    local function call_back()
        FactionEscortModel:GetInstance():GoNpc()
        -- lua_panelMgr:GetPanelOrCreate(FactionEscortPanel):Open()
    end
    AddButtonEvent(self.btn_escort.gameObject, call_back)

    local function call_back(target, x, y)
        GlobalEvent:Brocast(ChatEvent.OpenChatPanel, enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD)
    end
    AddClickEvent(self.btn_guild.gameObject, call_back)

    local function call_back(target, x, y)
        OperationManager:GetInstance():FlyToAStarPos()
    end
    AddClickEvent(self.gameObject, call_back)

    self.global_event_list = self.global_event_list or {}
    self.role_event_list = self.role_event_list or {}
    local function call_back()
        self:SetAutoRes()
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FightEvent.StartAutoFight, call_back)
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FightEvent.StopAutoFight, call_back)
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FightEvent.TemAutoFight, call_back)

    local function call_back()
        --RemoveClickEvent(self.img_chat_bg_2.gameObject)
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(ChatEvent.AddMsgItem, call_back)

    local function call_back()
        self:UpdateAutoState()
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(SceneEvent.FIND_WAY_START, call_back)
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(SceneEvent.FIND_WAY_END, call_back)
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FightEvent.StartAutoFight, call_back)
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FightEvent.StopAutoFight, call_back)

    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(ChatEvent.ExpandMainChatView, handler(self, self.DealChatExpand))
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(ChatEvent.FoldMainChatView, handler(self, self.DealChatFold))

    local function call_back()
        self:UpdateTipIcon()
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.AddMidTipIcon, call_back)

    local function call_back()
        self:UpdateTipIcon()
    end
    self.model_event_list[#self.model_event_list + 1] = self.model:AddListener(MainEvent.RemoveMidTipIcon, call_back)

    local function call_back(mail)
        --邮件事件
        local mail = MailModel.Instance.mailInfo
        if mail.unread then
            self:FlashButton(self.icon_tip_mail)
        else
            self:StopFlashButton(self.icon_tip_mail)
        end

    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(MailEvent.MailInfo, call_back)

    local function call_back(show)
        if show then
            self:FlashButton(self.icon_tip_mail)
        else
            self:StopFlashButton(self.icon_tip_mail)
        end
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(MailEvent.ShowMailIcon, call_back)

    local function call_back()
        self:CheckShowFriend()
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FriendEvent.ApplyList, call_back)
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FriendEvent.HandleAccept, call_back)

    local function call_back()
        local function ok_func()
            self:CheckPersonalChat()
        end
        GlobalSchedule:StartOnce(ok_func, 0.5)
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FriendEvent.UpdateMessage, call_back)
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FriendEvent.UpdateMainChatButton, call_back)

    local function call_back(data)
        if not self.is_loaded then
            self.isNeedLoadEscInfo = true
            return
        end
        self.isNeedLoadEscInfo = false
        self:ShowEscortIcon()
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FactionEscortEvent.FactionEscortInfo, call_back)

    ----糖果屋
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.CheckCandyIconShow))
    local function callback(is_show)
        self:SetGiftRedDot(is_show)
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(CandyEvent.UpdateCandyGiveGiftRD, callback)

    local function callback()
        CandyModel.GetInstance().cur_rank_mode = 1
        GlobalEvent:Brocast(CandyEvent.RequestCandyRankInfo, 6)
    end
    AddButtonEvent(self.btn_candy_chat.gameObject, callback)

    local function callback()
        CandyModel.GetInstance().cur_rank_mode = 2
        GlobalEvent:Brocast(CandyEvent.RequestCandyRankInfo, 100)
    end
    AddButtonEvent(self.btn_candy_give.gameObject, callback)

    local function callback()
        SetAnchoredPosition(self.candy_rect, self.candy_rect.anchoredPosition.x, self.candy_rect.anchoredPosition.y + 140)
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(ChatEvent.ExpandMainChatView, callback)
    local function callback()
        SetAnchoredPosition(self.candy_rect, self.candy_rect.anchoredPosition.x, self.candy_rect.anchoredPosition.y - 140)
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(ChatEvent.FoldMainChatView, callback)

    --检查糖果屋收礼红点
    local function callback(is_show)
        local sceneId = SceneManager:GetInstance():GetSceneId()
        if sceneId == 30341 or sceneId == 30342 then
            self:CheckCandyNotReadRedDot(is_show)
        end
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(CandyEvent.UpdateCandyChatIconRD, callback)

    ----聊天
    local function call_back()
        SetVisible(self.center, true)
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(ChatEvent.CloseChatPanel, call_back)
    local function call_back()
        SetVisible(self.center, false)
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(ChatEvent.OpenChatPanel, call_back)

    local function call_back(data)
        if data.channel_id == enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD then
            self:CheckGuildChatRedDot()
        elseif data.channel_id == enum.CHAT_CHANNEL.CHAT_CHANNEL_SCENE then
            --糖果屋
            if data.scene == 30341 or data.scene == 30342 then
                self:CheckCandyNotReadRedDot()
            end
        end
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(ChatEvent.ReceiveMessage, call_back)

    local function call_back(channel)
        if channel == enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD then
            self:CheckGuildChatRedDot()
        elseif channel == enum.CHAT_CHANNEL.CHAT_CHANNEL_SCENE then
            local sceneId = SceneManager:GetInstance():GetSceneId()
            --糖果屋
            if sceneId == 30341 or sceneId == 30342 then
                self:CheckCandyNotReadRedDot()
            end
        end
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(ChatEvent.CheckHaveUnRead, call_back)

    local function call_back(isShow, exp)

        if isShow then
            self.expTex.text = string.format("<color=#3ab60e>Get EXP：</color>%s/min", GetShowNumber(exp))
        end
        SetVisible(self.expObj, isShow)

    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(MainEvent.ShowExpStatistics, call_back)

    local function call_back()
        local guild = RoleInfoModel:GetInstance():GetRoleValue("guild")
        SetVisible(self.btn_guild, guild ~= "0")
    end
    self.role_event_list[#self.role_event_list + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("guild", call_back)

    local function call_back(isShow)
        self:SetHelpIcon(isShow)
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(DungeonEvent.ShowSosIcon, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ReviveHelpPanel):Open()
    end
    AddClickEvent(self.icon_tip_help.gameObject,call_back)
	
	local function call_back()
		lua_panelMgr:GetPanelOrCreate(FactionPanel):Open() 
		local function call_back()
			lua_panelMgr:GetPanelOrCreate(FactionOperatePanel):Open() 
			GlobalSchedule.StopFun(self.timeid)
			self:StopFlashButton(self.icon_tip_union)
			self.is_showUnion = false
		end
		self.timeid = GlobalSchedule.StartFunOnce(call_back, 1)
		
	end
	AddClickEvent(self.icon_tip_union.gameObject,call_back)
	
	local function call_back()
		if  not self.is_showUnion then
			self:FlashButton(self.icon_tip_union)
			self.is_showUnion = true
		end
	end
	self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(FactionEvent.ShowMainIcon, call_back)

    local function call_back()
        if self.escortTimeDown then
            GlobalSchedule:Stop(self.escortTimeDown)
            self.escortTimeDown = nil
        end
    end
    self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.GameReset, call_back)
end
----帮派新消息红点
function MainUIBottom:CheckGuildChatRedDot()
    local function call_back2()
        local flag = ChatModel:GetInstance():IsChannelHaveNotReadMsg(enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD)
        if not self.guild_chat_reddot then
            self.guild_chat_reddot = RedDot(self.btn_guild)
            SetLocalPosition(self.guild_chat_reddot.transform, 10, 13, 0)
        end
        SetVisible(self.guild_chat_reddot, flag)
    end
    GlobalSchedule:StartOnce(call_back2, 0.5)
end

----糖果屋未读消息红点检查
function MainUIBottom:CheckCandyNotReadRedDot(is_show)
    local function step()
        local is_really_show = true
        --收礼红点显示
        local is_show_reco_rd = true
        if is_show == false then
            --没有收礼红点
            is_show_reco_rd = false
        elseif is_show == nil then
            is_show_reco_rd = CandyModel.GetInstance().is_showing_record_rd
        end

        --聊天红点显示
        local is_show_chat_rd = ChatModel:GetInstance():IsChannelHaveNotReadMsg(enum.CHAT_CHANNEL.CHAT_CHANNEL_SCENE)

        if is_show_reco_rd == false and is_show_chat_rd == false then
            is_really_show = false
        end
        self:SetChatRedDot(is_really_show)
    end
    GlobalSchedule:StartOnce(step, 0.5)
end

----etc
function MainUIBottom:StartEscortTimeDown()
    local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), self.escortEndTime)
    if timeTab then
        local minStr = string.format("%02d", timeTab.min or 0)
        local secStr = string.format("%02d", timeTab.sec or 0)
        if not timeTab.min then
            self.escortTime.text = string.format("<color=#e63232>%s:%s</color>", minStr, secStr)
        else
            self.escortTime.text = string.format("<color=#43f673>%s:%s</color>", minStr, secStr)
        end
    else
        if self.escortTimeDown then
            GlobalSchedule:Stop(self.escortTimeDown)
            self.escortTimeDown = nil
        end
        SetVisible(self.btn_escort, false)
    end
end
function MainUIBottom:ShowEscortIcon()
    local model = FactionEscortModel:GetInstance()
    SetVisible(self.btn_escort, model.escortEndTime ~= 0)
    if model.escortEndTime ~= 0 then
        self.escortEndTime = model.escortEndTime  --剩余时间
        local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), self.escortEndTime)
        if timeTab then
            local minStr = string.format("%02d", timeTab.min or 0)
            local secStr = string.format("%02d", timeTab.sec or 0)
            if not timeTab.min then
                self.escortTime.text = string.format("<color=#e63232>%s:%s</color>", minStr, secStr)
            else
                self.escortTime.text = string.format("<color=#43f673>%s:%s</color>", minStr, secStr)
            end
        end
        if self.escortTimeDown then
            GlobalSchedule:Stop(self.escortTimeDown)
            self.escortTimeDown = nil
        end
        self.escortTimeDown = GlobalSchedule:Start(handler(self, self.StartEscortTimeDown), 1.0)
    else
        --
        if self.escortTimeDown then
            GlobalSchedule:Stop(self.escortTimeDown)
            self.escortTimeDown = nil
        end
    end
end

function MainUIBottom:UpdateAutoState()
    self:StopAutoStateTime()
    local function step()
        self:SetAutoState()
        -- 这个是执行一次的定时器，调用后会自动删除引用，不需要额外停止
        self.time_auto_id = nil
    end
    self.time_auto_id = GlobalSchedule:StartOnce(step, 0)
end

function MainUIBottom:StopAutoStateTime()
    if self.time_auto_id then
        GlobalSchedule:Stop(self.time_auto_id)
        self.time_auto_id = nil
    end
end

function MainUIBottom:SetAutoState()
    local auto_fight = false
    local auto_move = false
    if AutoFightManager:GetInstance():GetAutoFightState() or AutoTaskManager:GetInstance():IsAutoFight() then
        auto_fight = true
    end

    if not auto_fight and OperationManager:GetInstance():IsAutoWay() then
        auto_move = true
    end
    if auto_fight then
        if not self.auto_fight_effect then
            local effect = UIEffect(self.con_state, 10111, false, self.layer)
            effect:SetConfig({ pos = { x = -77, y = -162, z = 0 } })
            self.auto_fight_effect = effect
        else
            self.auto_fight_effect:SetVisible(true)
        end
    else
        if self.auto_fight_effect then
            self.auto_fight_effect:SetVisible(false)
        end
    end

    if auto_move then
        if not self.auto_move_effect then
            local effect = UIEffect(self.con_state, 10110, false, self.layer)
            effect:SetConfig({ pos = { x = -77, y = -162, z = 0 } })
            self.auto_move_effect = effect
        else
            self.auto_move_effect:SetVisible(true)
        end
        if MainModel:GetInstance():GetSwitchType() == MainModel.SwitchType.City then
            SetVisible(self.img_fly_icon, true)
        else
            SetVisible(self.img_fly_icon, false)
        end
    else
        if self.auto_move_effect then
            self.auto_move_effect:SetVisible(false)
        end
        SetVisible(self.img_fly_icon, false)
    end

    if not auto_fight and not auto_move then
        SetVisible(self.con_state, false)
    else
        SetVisible(self.con_state, true)
    end
end

function MainUIBottom:FlashButton(button)
    SetVisible(button.gameObject, true)
    local action = cc.ScaleTo(0.4, 0.85)
    action = cc.Sequence(action, cc.ScaleTo(0.4, 1))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, button)
end

function MainUIBottom:StopFlashButton(button)
    self:SetScale(1.0)
    SetVisible(button.gameObject, false)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(button)
end

function MainUIBottom:StopFlashButton2(button)
    self:SetScale(1.0)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(button)
end

function MainUIBottom:SetAutoRes()
    if not self.is_loaded then
        return
    end
    if AutoFightManager:GetInstance().auto_state == AutoFightManager.AutoState.Auto then
        lua_resMgr:SetImageTexture(self, self.btn_auto_img, "main_image", "btn_auto", true)
        self:LoadAutoButtonEffect()
    else
        if AutoFightManager:GetInstance().auto_state == AutoFightManager.AutoState.Tem then
            lua_resMgr:SetImageTexture(self, self.btn_auto_img, "main_image", "btn_tem_auto", true)
        else
            lua_resMgr:SetImageTexture(self, self.btn_auto_img, "main_image", "btn_cancel_auto", true)
        end
        self:RemoveAutoButtonEffect()
    end
end

function MainUIBottom:LoadAutoButtonEffect()
    if not self.auto_btn_effect then
        self.auto_btn_effect = UIEffect(self.btn_auto, 10106, false)
        self.auto_btn_effect:SetOrderIndex(101)
    end
end

function MainUIBottom:RemoveAutoButtonEffect()
    if self.auto_btn_effect then
        self.auto_btn_effect:destroy()
        self.auto_btn_effect = nil
    end
end

function MainUIBottom:SetData()
end

function MainUIBottom:UpdateTipIcon()
    local tab = self.model:GetMidIconShowList()

    self.item_list = self.item_list or {}
    local len = #tab
    local width = 0
    for i = 1, len do
        local info = tab[i]
        local item = self.item_list[i]
        if not item then
            item = MainTipItem(self.MainTipItem_gameObject, self.tip_con)
            self.item_list[i] = item
            local x = width - 200
            local y = 0
            item:SetPosition(x, y)
            --item:SetCallBack(callback)
        else
            item:SetVisible(true)
        end
        item:SetData(i, tab[i])
        local cf = IconConfig.MidTipConfig[info.key_str]
        width = width + (cf.width or 65)
    end

    local item_count = #self.item_list
    for i = len + 1, item_count do
        local item = self.item_list[i]
        item:destroy()
        self.item_list[i] = nil
    end
end

function MainUIBottom:CheckCandyIconShow(sceneId)
    if sceneId then
        local config = Config.db_scene[sceneId]
        if not config then
            return
        end
    else
        sceneId = SceneManager:GetInstance():GetSceneId()
    end
    local flag = sceneId == 30341 or sceneId == 30342
    if flag then
        GlobalEvent:Brocast(CandyEvent.OpenLeftCenter)
    else
        GlobalEvent:Brocast(CandyEvent.CloseLeftCenter)
    end
    SetVisible(self.candy_house, flag)
end

function MainUIBottom:CheckShowFriend()
    if table.isempty(FriendModel:GetInstance():GetApplyList()) then
        self:StopFlashButton(self.icon_tip_friend)
    else
        if not cc.ActionManager:GetInstance():isTargetInAction(self.icon_tip_friend) then
            self:FlashButton(self.icon_tip_friend)
        end
    end
end

function MainUIBottom:CheckPersonalChat()
    local personal_role_id = FriendModel:GetInstance():GetUnReadMessagesRoleId()
    if personal_role_id ~= "" then
        if not cc.ActionManager:GetInstance():isTargetInAction(self.icon_tip_chat) then
            self:FlashButton(self.icon_tip_chat)
        end
    else
        self:StopFlashButton(self.icon_tip_chat)
    end
end

function MainUIBottom:SetHelpIcon(isShow)
    if isShow then
        if not cc.ActionManager:GetInstance():isTargetInAction(self.icon_tip_help) then
            self:FlashButton(self.icon_tip_help)
        end
    else
        self:StopFlashButton(self.icon_tip_help)
    end

end

function MainUIBottom:DealChatExpand()
    SetSizeDeltaY(self.img_chat_bg_2.transform, 315)
end

function MainUIBottom:DealChatFold()
    SetSizeDeltaY(self.img_chat_bg_2.transform, 135)
end

function MainUIBottom:SetChatRedDot(isShow)
    if not self.chat_red_dot then
        self.chat_red_dot = RedDot(self.chat_red_con, nil, RedDot.RedDotType.Nor)
    end
    self.chat_red_dot:SetPosition(0, 0)
    self.chat_red_dot:SetRedDotParam(isShow)
end

function MainUIBottom:SetGiftRedDot(isShow)
    if not self.gift_red_dot then
        self.gift_red_dot = RedDot(self.gift_red_con, nil, RedDot.RedDotType.Nor)
    end
    self.gift_red_dot:SetPosition(0, 0)
    self.gift_red_dot:SetRedDotParam(isShow)
end

function MainUIBottom:SetGuildRD(isShow)
    if not self.guild_rd then
        self.guild_rd = RedDot(self.guild_rd_con, nil, RedDot.RedDotType.Nor)
    end
    self.guild_rd:SetPosition(0, 0)
    self.guild_rd:SetRedDotParam(isShow)
end
