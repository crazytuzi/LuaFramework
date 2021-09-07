-- ----------------------------------------------------------
-- 星辰挑战 龙王挑战
-- ----------------------------------------------------------
StarChallengeManager = StarChallengeManager or BaseClass(BaseManager)

function StarChallengeManager:__init()
    if StarChallengeManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	StarChallengeManager.Instance = self

    self.model = StarChallengeModel.New()
    self.listener = function () -- by 嘉俊 2017/8/29
        self:SetHelpIcon()
    end

    self:InitHandler()

    self.OnUpdateList = EventLib.New()
    self.OnUpdateBossWave = EventLib.New()

    self.OnUpdateHelpGet = EventLib.New() -- by 嘉俊 2017/8/29 用来更新是否获取了帮助奖励

    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self:UpdateEvent(event, old_event) end)
    EventMgr.Instance:AddListener(event_name.end_fight, function(type, result) self:OnEndFight(type, result) end)
    -----------------------------------------------------
end

function StarChallengeManager:__delete()
    self.OnUpdateList:DeleteMe()
    self.OnUpdateList = nil
    self.OnUpdateBossWave:DeleteMe()
    self.OnUpdateBossWave = nil
end

function StarChallengeManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(20200, self.On20200)
    self:AddNetHandler(20201, self.On20201)
    self:AddNetHandler(20202, self.On20202)
    self:AddNetHandler(20203, self.On20203)
    self:AddNetHandler(20204, self.On20204)
    self:AddNetHandler(20205, self.On20205)
    self:AddNetHandler(20206, self.On20206)
    self:AddNetHandler(20207, self.On20207)
    self:AddNetHandler(20208, self.On20208)
    self:AddNetHandler(20209, self.On20209)

    EventMgr.Instance:AddListener(event_name.scene_load, self.listener) -- by 嘉俊 2017/8/29
end

function StarChallengeManager:RequestInitData()
	self.model:InitData()

	self:Send20200()
    self:Send20206()
    -- self:Send20207()
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------


function StarChallengeManager:Send20200()
    Connection.Instance:send(20200, { })
end

function StarChallengeManager:On20200(data)
	--BaseUtils.dump(data, "<color='#ffff00'>On20200</color>")

    self.model.is_offer = data.is_offer
    self.model.max_wave = data.max_wave

    self.model.helpGet = data.help_times -- by 嘉俊 2017/8/29

    self.model:MakeBuff()
    EventMgr.Instance:Fire(event_name.buff_update)

    if self.model.is_offer == 1 then
        self:Send20205()
    end
    self.OnUpdateHelpGet:Fire() -- by 嘉俊 2017/8/29
end

function StarChallengeManager:Send20201()
    Connection.Instance:send(20201, { })
end

function StarChallengeManager:On20201(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function StarChallengeManager:Send20202()
    Connection.Instance:send(20202, { })
end

function StarChallengeManager:On20202(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function StarChallengeManager:Send20203()
    -- print("Send20203")
    Connection.Instance:send(20203, { })
end

function StarChallengeManager:On20203(data)
    -- BaseUtils.dump(data, "On20203")
    if data.order == 0 then
        self.model:OpenTowerEnd({data.type})
    else
        self.model:OpenBox(data)
        if data.gain_list[1].item_id1 ~= nil then
            local baseData = DataItem.data_get[data.gain_list[1].item_id1]
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("恭喜获得%s"), ColorHelper.color_item_name(baseData.quality, baseData.name)))
        end
    end
end

function StarChallengeManager:Send20204(index)
    -- print("Send20204")
    Connection.Instance:send(20204, { order = index })
end

function StarChallengeManager:On20204(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function StarChallengeManager:Send20205()
    Connection.Instance:send(20205, { })
end

function StarChallengeManager:On20205(data)
	-- BaseUtils.dump(data, "<color='#ffff00'>On20205</color>")

	self.model:On20205(data)

	self.OnUpdateList:Fire()
end

function StarChallengeManager:Send20206()
    Connection.Instance:send(20206, { })
end

function StarChallengeManager:On20206(data)
	-- BaseUtils.dump(data, "<color='#ffff00'>On20206</color>")

    -- local roleData = RoleManager.Instance.RoleData
    -- if roleData.event == RoleEumn.Event.None and roleData.lev >= 65 then
    --     if self.model.status ~= data.status then
    --         if (data.status == 2 and self.model.is_offer == 0) or data.status == 3 then
    --             local hour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    --             if (hour >= 10 and hour < 12) or (hour >= 15 and hour < 20) then
    --                 local confirmdata = NoticeConfirmData.New()
    --                 confirmdata.type = ConfirmData.Style.Normal
    --                 confirmdata.content = TI18N("龙王试练正在进行中，是否参与{face_1,1}")
    --                 confirmdata.sureLabel = TI18N("确认")
    --                 confirmdata.cancelLabel = TI18N("取消")
    --                 confirmdata.sureCallback = function()
    --                     self.model:EnterScene()
    --                 end
    --                 NoticeManager.Instance:ActiveConfirmTips(confirmdata)
    --             end
    --         end
    --     end
    -- end
    self:Send20205()    --再请求20205，刷新队伍的信息 
    self.model.status = data.status
    self.model.group = data.group
    self.OnUpdateList:Fire()

    TeamManager.Instance:MatchData()
    -- self:UpdateIcon()
end

function StarChallengeManager:Send20207()
    Connection.Instance:send(20207, { })
end

function StarChallengeManager:On20207(data)
    -- BaseUtils.dump(data, "<color='#ffff00'>On20207</color>")
    -- Log.Error("波数协议来了".. data.wave)

    self.model.wave = data.wave
    self.model.reward_info = data.reward_info

    self.OnUpdateBossWave:Fire()
end

function StarChallengeManager:Send20208()
    Connection.Instance:send(20208, { })
end

function StarChallengeManager:On20208(data)
end

function StarChallengeManager:Send20209()
    print("Send20209")
    Connection.Instance:send(20209, { })
end

function StarChallengeManager:On20209(data)
    BaseUtils.dump(data, "On20209")
    for i,v in ipairs(data.rank_list) do
        v.rank = i
    end
    local pos = RankManager.Instance.model.rankTypeToPageIndexList[RankManager.Instance.model.rank_type.StarChallenge]
    RankManager.Instance.model:SetData(pos.main, pos.sub, 1, data)

    self.model.rank_list = data.rank_list

    self.OnUpdateList:Fire()
end

function StarChallengeManager:UpdateEvent(event, old_event)
    if event == RoleEumn.Event.StarChallenge then
    	self:Send20205()

        self.model:OpenStarChallengeIcon()

        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, true)
        end
    elseif old_event == RoleEumn.Event.StarChallenge then
        self.model:CloseStarChallengeIcon()

        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, false)
        end
    end
end

function StarChallengeManager:UpdateIcon()
    -- if self.model.status == 1 then
        -- MainUIManager.Instance:DelAtiveIcon(347)
    -- else
        -- local cfg_data = DataSystem.data_daily_icon[347]
        -- local iconData = AtiveIconData.New()
        -- iconData.id = cfg_data.id
        -- iconData.iconPath = cfg_data.res_name
        -- iconData.clickCallBack = function()
        --     -- print(self.model.status)
        --     if self.model.status == 2 then
        --          self.model:OpenWindow({0})
        --     elseif self.model.status == 3 then
        --          self.model:OpenWindow({-1, 1})
        --     else
        --         NoticeManager.Instance:FloatTipsByString(TI18N("活动暂未开启"))
        --     end
        --  end
        -- iconData.createCallBack = function(gameObject)
        --     local fun = function(effectView)
        --         if BaseUtils.isnull(gameObject) then
        --             if not BaseUtils.isnull(effectView.gameObject) then
        --                 GameObject.Destroy(effectView.gameObject)
        --             end
        --             return
        --         end

        --         local effectObject = effectView.gameObject
        --         effectObject.transform:SetParent(gameObject.transform)
        --         effectObject.transform.localScale = Vector3(0.9, 0.9, 0.9)
        --         effectObject.transform.localPosition = Vector3(-1.6, 30, -400)
        --         effectObject.transform.localRotation = Quaternion.identity

        --         Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        --     end
        --     BaseEffectView.New({effectId = 20121, time = nil, callback = fun})
        -- end
        -- iconData.sort = cfg_data.sort
        -- iconData.lev = cfg_data.lev
        -- -- iconData.text = cfg_data.name
        -- MainUIManager.Instance:AddAtiveIcon(iconData)
    -- end
end

function StarChallengeManager:OnEndFight(type, result)
    if type == 62 then
        if self.model.fightPanel ~= nil then
            self.model.fightPanel:DeleteMe()
            self.model.fightPanel = nil
        end
        if self.model.fightRewardPanel ~= nil then
            self.model.fightRewardPanel:DeleteMe()
            self.model.fightRewardPanel = nil
        end

        if not (CombatManager.Instance.isWatching or CombatManager.Instance.isWatchRecorder) then
            self.model:OpenStarChallengeSettlementWindow()
        end
    end
end

function StarChallengeManager:ShowFightPanel()
    self.model:ShowFightPanel()
end


function StarChallengeManager:ShowFightRewardPanel()
    self.model:ShowFightRewardPanel()
end

-- 获取日程说明
function StarChallengeManager:GetAgendaDescString(type)
    if self.model.status == 2 then
        if self.model.is_offer == 0 then
            return TI18N("未获得资格")
        else
            return TI18N("<color='#249015'>已获得资格</color>")
        end
    elseif self.model.status == 3 then
        if self.model.is_offer == 0 then
            return TI18N("未获得资格")
        else
            if self.model.max_wave == 0 then
                return TI18N("未有挑战记录")
            else
                return string.format(TI18N("<color='#249015'>已挑战第%s阶段</color>"), BaseUtils.NumToChn(self.model.max_wave))
            end
        end
    else
        return TI18N("龙王试练开启中")
    end
end

-- 获取日程是否显示按钮
function StarChallengeManager:GetAgendaShowButton(type)
    local hour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    if hour < 10 then
        return false, TI18N("<color='#aaff00'>10:00</color>开启")
    elseif hour < 12 then
        return true, ""
    elseif hour < 15 then
        return false, TI18N("<color='#aaff00'>15:00</color>开启")
    elseif hour < 20 then
        return true, ""
    else
        return false, TI18N("<color='#aaff00'>10:00</color>开启")
    end
end

function StarChallengeManager:OpenHelp(args) -- by 嘉俊 2017/8/29 17:00
    self.model:OpenHelp(args)
end

function StarChallengeManager:ShowHelpIcon() -- by 嘉俊 2017/8/29 18:05
    local mapid = SceneManager.Instance:CurrentMapId()
    if mapid == 53005 then
        return true
    end

    return false
end

function StarChallengeManager:SetHelpIcon() -- by 嘉俊 2017/8/29 17:09
    MainUIManager.Instance:DelAtiveIcon(310)

    if not self:ShowHelpIcon() then
        if self.activeIconData ~= nil then
            self.activeIconData:DeleteMe()
            self.activeIconData = nil
        end
        return
    end

    if self.activeIconData == nil then self.activeIconData = AtiveIconData.New() end
    local iconData = DataSystem.data_daily_icon[310]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.star_challenge_help_window) end

    MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
end