-- ----------------------------------------------------------
-- 天启挑战
-- ----------------------------------------------------------
ApocalypseLordManager = ApocalypseLordManager or BaseClass(BaseManager)

function ApocalypseLordManager:__init()
    if ApocalypseLordManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	ApocalypseLordManager.Instance = self

    self.model = ApocalypseLordModel.New()
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

function ApocalypseLordManager:__delete()
    self.OnUpdateList:DeleteMe()
    self.OnUpdateList = nil
    self.OnUpdateBossWave:DeleteMe()
    self.OnUpdateBossWave = nil
end

function ApocalypseLordManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(20800, self.On20800)
    self:AddNetHandler(20801, self.On20801)
    self:AddNetHandler(20802, self.On20802)
    self:AddNetHandler(20803, self.On20803)
    self:AddNetHandler(20804, self.On20804)
    self:AddNetHandler(20805, self.On20805)
    self:AddNetHandler(20806, self.On20806)
    self:AddNetHandler(20807, self.On20807)
    self:AddNetHandler(20808, self.On20808)
    self:AddNetHandler(20809, self.On20809)

    EventMgr.Instance:AddListener(event_name.scene_load, self.listener) -- by 嘉俊 2017/8/29
end

function ApocalypseLordManager:RequestInitData()
	self.model:InitData()

	self:Send20800()
    self:Send20806()
    -- self:Send20807()
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------


function ApocalypseLordManager:Send20800()
    -- print("Send20800")
    Connection.Instance:send(20800, { })
end

function ApocalypseLordManager:On20800(data)
	-- BaseUtils.dump(data, "<color='#ffff00'>On20800</color>")

    self.model.is_offer = data.is_offer
    self.model.max_wave = data.max_wave

    self.model.helpGet = data.help_times -- by 嘉俊 2017/8/29

    self.model:MakeBuff()
    EventMgr.Instance:Fire(event_name.buff_update)

    if self.model.is_offer == 1 then
        self:Send20805()
    end
    self.OnUpdateHelpGet:Fire() -- by 嘉俊 2017/8/29
end

function ApocalypseLordManager:Send20801()
    Connection.Instance:send(20801, { })
end

function ApocalypseLordManager:On20801(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function ApocalypseLordManager:Send20802()
    Connection.Instance:send(20802, { })
end

function ApocalypseLordManager:On20802(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function ApocalypseLordManager:Send20803()
    -- print("Send20803")
    Connection.Instance:send(20803, { })
end

function ApocalypseLordManager:On20803(data)
    -- BaseUtils.dump(data, "On20803")
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

function ApocalypseLordManager:Send20804(index)
    -- print("Send20804")
    Connection.Instance:send(20804, { order = index })
end

function ApocalypseLordManager:On20804(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function ApocalypseLordManager:Send20805()
    Connection.Instance:send(20805, { })
end

function ApocalypseLordManager:On20805(data)
	--BaseUtils.dump(data, "<color='#ffff00'>On20805</color>")

	self.model:On20805(data)

	self.OnUpdateList:Fire()
end

function ApocalypseLordManager:Send20806()
    -- print("Send20806")
    Connection.Instance:send(20806, { })
end

function ApocalypseLordManager:On20806(data)
	-- BaseUtils.dump(data, "<color='#ffff00'>On20806</color>")

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
    self.model.status = data.status
    self.model.group = data.group
    self.OnUpdateList:Fire()

    TeamManager.Instance:MatchData()
    -- self:UpdateIcon()
end

function ApocalypseLordManager:Send20807()
    Connection.Instance:send(20807, { })
end

function ApocalypseLordManager:On20807(data)
    -- BaseUtils.dump(data, "<color='#ffff00'>On20807</color>")
    -- Log.Error("波数协议来了".. data.wave)

    self.model.wave = data.wave
    self.model.reward_info = data.reward_info

    self.OnUpdateBossWave:Fire()
end

function ApocalypseLordManager:Send20808()
    Connection.Instance:send(20808, { })
end

function ApocalypseLordManager:On20808(data)
end

function ApocalypseLordManager:Send20809()
    print("Send20809")
    Connection.Instance:send(20809, { })
end

function ApocalypseLordManager:On20809(data)
    BaseUtils.dump(data, "On20809")
    for i,v in ipairs(data.rank_list) do
        v.rank = i
    end
    local pos = RankManager.Instance.model.rankTypeToPageIndexList[RankManager.Instance.model.rank_type.ApocalypseLord]
    RankManager.Instance.model:SetData(pos.main, pos.sub, 1, data)

    self.model.rank_list = data.rank_list

    self.OnUpdateList:Fire()
end

function ApocalypseLordManager:UpdateEvent(event, old_event)
    if event == RoleEumn.Event.ApocalypseLord then
    	self:Send20805()

        self.model:OpenApocalypseLordIcon()

        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, true)
        end
    elseif old_event == RoleEumn.Event.ApocalypseLord then
        self.model:CloseApocalypseLordIcon()

        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, false)
        end
    end
end

function ApocalypseLordManager:UpdateIcon()
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

function ApocalypseLordManager:OnEndFight(type, result)
    if type == 70 then
        if self.model.fightPanel ~= nil then
            self.model.fightPanel:DeleteMe()
            self.model.fightPanel = nil
        end
        if self.model.fightRewardPanel ~= nil then
            self.model.fightRewardPanel:DeleteMe()
            self.model.fightRewardPanel = nil
        end

        if not (CombatManager.Instance.isWatching or CombatManager.Instance.isWatchRecorder) then
            self.model:OpenApocalypseLordSettlementWindow()
        end
    end
end

function ApocalypseLordManager:ShowFightPanel()
    self.model:ShowFightPanel()
end


function ApocalypseLordManager:ShowFightRewardPanel()
    self.model:ShowFightRewardPanel()
end

-- 获取日程说明
function ApocalypseLordManager:GetAgendaDescString(type)
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
        return TI18N("天启试练开启中")
    end
end

-- 获取日程是否显示按钮
function ApocalypseLordManager:GetAgendaShowButton(type)
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

function ApocalypseLordManager:OpenHelp(args) -- by 嘉俊 2017/8/29 17:00
    self.model:OpenHelp(args)
end

function ApocalypseLordManager:ShowHelpIcon() -- by 嘉俊 2017/8/29 18:05
    local mapid = SceneManager.Instance:CurrentMapId()
    if mapid == 53015 then
        return true
    end

    return false
end

function ApocalypseLordManager:SetHelpIcon() -- by 嘉俊 2017/8/29 17:09
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
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ApocalypseLord_help_window) end

    MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
end