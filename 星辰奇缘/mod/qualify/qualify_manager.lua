QualifyManager = QualifyManager or BaseClass(BaseManager)

function QualifyManager:__init()
    if QualifyManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    QualifyManager.Instance = self;
    self:InitHandler()
    self.model = QualifyModel.New()
    -- self.mark_lev = RoleManager.Instance.RoleData.lev
    self.fight_btn = nil
end

function QualifyManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function QualifyManager:InitHandler()
    self:AddNetHandler(13500,self.on13500)
    self:AddNetHandler(13501,self.on13501)
    self:AddNetHandler(13502,self.on13502)
    self:AddNetHandler(13503,self.on13503)
    self:AddNetHandler(13504,self.on13504)
    self:AddNetHandler(13505,self.on13505)
    self:AddNetHandler(13506,self.on13506)
    self:AddNetHandler(13507,self.on13507)

    self:AddNetHandler(13508,self.on13508)
    self:AddNetHandler(13509,self.on13509)
    self:AddNetHandler(13510,self.on13510)

    self:AddNetHandler(13511,self.on13511)
    self:AddNetHandler(13512,self.on13512)
    self:AddNetHandler(13513,self.on13513)

    self:AddNetHandler(13514,self.on13514)


    -- EventMgr.Instance:AddListener(event_name.role_event_change, function() self:on_role_event_change() end)

    self.on_role_change = function(data)
        self:request13502()
    end
    EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_change)


    self.on_begin_fight = function()
        -- -- print("-----------------------------------------开始战斗")
        self.model.match_data = nil
    end
    EventMgr.Instance:AddListener(event_name.begin_fight, self.on_begin_fight)

    self.on_stop_fight = function()
        -- -- print("-----------------------------------------结束战斗")
        self.model.match_data = nil
    end
    EventMgr.Instance:AddListener(event_name.end_fight, self.on_stop_fight)


    self.mainui_loaded_func = function(data)
        self:on_mainui_loaded()
    end
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, self.mainui_loaded_func)
end

function QualifyManager:ReqOnConnect()
    self:request13504(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
end

--场景跳转完成
function QualifyManager:on_role_event_change(event)
    -- print("-0-----------------------------------人物角色信息改变")
    -- if RoleManager.Instance.RoleData.event == RoleEumn.Event.Match then
    --     --段位赛状态
    --     if self.fight_btn == nil then
    --         self.assetWrapper = AssetBatchWrapper.New()
    --         local callback = function()
    --             if self.assetWrapper ~= nil then
    --                 self.fight_btn =GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.qualifyBtn))
    --                 MainUIManager.Instance:AddQualifyBtn2CanvasView(self.fight_btn)
    --                 self.fight_btn.transform:GetComponent(Button)
    --                 self.fight_btn.transform:GetComponent(Button).onClick:AddListener( function()
    --                         self.model:OpenQualifyMainUI()
    --                 end)
    --                 self.assetWrapper:DeleteMe()
    --                 self.assetWrapper= nil
    --             end
    --         end
    --         local reslist = {{file  =  AssetConfig.qualifyBtn, type  =  AssetType.Main}}
    --         self.assetWrapper:LoadAssetBundle(reslist, callback)
    --     end
    -- else
    --     if self.fight_btn ~= nil then
    --         GameObject.DestroyImmediate(self.fight_btn)
    --     end
    -- end
end


function QualifyManager:on_mainui_loaded()
    QualifyManager.Instance:request13511()
    QualifyManager.Instance:request13502()

    -- local cfg_data = DataSystem.data_daily_icon[103]
    -- if cfg_data.lev > RoleManager.Instance.RoleData.lev then
    --     return
    -- end

    -- if self.model:check_has_reward() then
    --     if MainUIManager.Instance.MainUIIconView ~= nil then
    --         local iconData = AtiveIconData.New()
    --         iconData.id = cfg_data.id
    --         iconData.iconPath = cfg_data.res_name
    --         iconData.clickCallBack = self.click_callback
    --         iconData.sort = cfg_data.sort
    --         iconData.lev = cfg_data.lev
    --         -- iconData.timestamp = data.time
    --         iconData.timeoutCallBack = nil
    --         iconData.text = ""
    --         MainUIManager.Instance:AddAtiveIcon(iconData)

    --         MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(cfg_data.id, true)
    --     end
    -- end
end


--接收协议逻辑
--报名
function QualifyManager:on13500(data)
    if data.result==0 then --失败

    else--成功
        --关掉主界面，进入匹配界面
        -- -- print("----------------报名成功")
        self.model:stop_match_timer()
        self.model:OpenQualifyMatchUI()
    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--取消报名
function QualifyManager:on13501(data)
    if data.result==0 then --失败

    else--成功
        self.model:stop_match_timer()
        self.model:OpenQualifyMainUI()
    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--活动状态
function QualifyManager:on13502(data)
    -- -- print("=============================收到13502")
    -- BaseUtils.dump(data)


    self.model.activity_state = data.status

    local cfg_data = DataSystem.data_daily_icon[103]
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        return
    end

    self.click_callback = function()
        if self.model.activity_state == 0 then
            self.model:OpenQualifyMainUI()
            return
        end
        if RoleManager.Instance.RoleData.cross_type == 1 then
            -- 如果处在中央服，先回到本服在参加活动
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.sureSecond = -1
            confirmData.cancelSecond = 180
            confirmData.sureLabel = TI18N("确认")
            confirmData.cancelLabel = TI18N("取消")
            RoleManager.Instance.jump_over_call = function()
                if SceneManager.Instance:CurrentMapId() == 30003 then
                    self.model:OpenQualifyMainUI()
                else
                    self:request13512()
                end
            end
            confirmData.sureCallback = SceneManager.Instance.quitCenter
            confirmData.content = string.format("<color='#ffff00'>%s</color>%s", TI18N("段位赛"), TI18N("活动已开启，是否<color='#ffff00'>返回原服</color>参加？"))
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            if SceneManager.Instance:CurrentMapId() == 30003 then
                self.model:OpenQualifyMainUI()
            else
                self:request13512()
            end
        end
    end

    AgendaManager.Instance:SetCurrLimitID(2002, data.status == 1)
    if data.status == 0 then
        --关闭
        if self.model:check_has_reward() then
            if MainUIManager.Instance.MainUIIconView ~= nil then

                MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
                local iconData = AtiveIconData.New()
                iconData.id = cfg_data.id
                iconData.iconPath = cfg_data.res_name
                iconData.clickCallBack = self.click_callback
                iconData.sort = cfg_data.sort
                iconData.lev = cfg_data.lev
                iconData.timeoutCallBack = nil
                iconData.text = string.format("<color='#2fc823'>%s</color>", TI18N("可领取"))
                MainUIManager.Instance:AddAtiveIcon(iconData)


                MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(cfg_data.id, true)

            end
        else
            MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        end
    elseif data.status == 1 then
        --准备中
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = self.click_callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        -- iconData.timestamp = data.time
        iconData.timeoutCallBack = nil
        iconData.text = TI18N("准备中")
        MainUIManager.Instance:AddAtiveIcon(iconData)

        if self.model:check_has_reward() then
            if MainUIManager.Instance.MainUIIconView ~= nil then
                MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(cfg_data.id, true)
            end
        end

        if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.qualify) == false then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("<color='#ffff00'>段位赛</color>活动已经开启，是否参加")
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.cancelSecond = 180
            data.sureCallback = function()
                --寻路到npc
                self.click_callback()
            end

            if RoleManager.Instance.RoleData.cross_type == 1 then
                -- 如果处在中央服，先回到本服在参加活动
                RoleManager.Instance.jump_over_call = function()
                    if SceneManager.Instance:CurrentMapId() == 30003 then
                        self.model:OpenQualifyMainUI()
                    else
                        self:request13512()
                    end
                end
                data.sureCallback = SceneManager.Instance.quitCenter
                data.content = TI18N("<color='#ffff00'>段位赛</color>活动已经开始，是否<color='#ffff00'>返回原服</color>参加？")
            end

            NoticeManager.Instance:ActiveConfirmTips(data)
            ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.qualify)
        end
    elseif data.status == 2 then
        --进行中
        MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = self.click_callback
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        iconData.timestamp = data.time + Time.time
        iconData.timeoutCallBack = function()
            self:request13502()
        end
        MainUIManager.Instance:AddAtiveIcon(iconData)

    end
    self.model.season_time = data.season_time
    self.model.activity_time = data.time + Time.time
    -- print('-------------------------收到更新计时')
    EventMgr.Instance:Fire(event_name.qualify_time_update)
end

--匹配成功
function QualifyManager:on13503(data)
    self.model.match_data = data
    self.model:update_match_win_socket_back()

end

--请求段位信息
function QualifyManager:on13504(data)
    -- -- print("--------------------------13504回来了")
     -- BaseUtils.dump(data)
    self.model.mine_qualify_data = data
    self.model:update_main_win_info()
end

--收到段位变化通知
function QualifyManager:on13505(data)
    -- print('--------------------------------收到13505')
     -- BaseUtils.dump(data)

    self.model.open_lock_data = data
    self.model.do_open_lock_win = false

    if data.rank_lev%5 == 1 and data.rank_lev ~= 1 then
        --没跨级
        if data.rank_lev > self.model.mine_qualify_data.rank_lev then
            self.model.do_open_lock_win = true
        end
    else
        --跨级
        local has_tips = {}
        for i=1,#self.model.mine_qualify_data.up_ranklev_reward do
            local temp_data = self.model.mine_qualify_data.up_ranklev_reward[i]
            has_tips[temp_data.rank_lev] = temp_data
        end
        local is_in = false
        local check_lev = math.floor(data.rank_lev/5)*5+1
        for i=1,#data.up_ranklev_reward do
            local socket_data = data.up_ranklev_reward[i]
            if has_tips[socket_data.rank_lev] == nil and socket_data.rank_lev == check_lev then
                is_in = true
            end
        end


        -- print('--------------------------dsjisjdfojdo')
        -- BaseUtils.dump(has_tips)
        -- print(check_lev)
        -- print(is_in)
        self.model.do_open_lock_win = is_in
    end
end

--战斗结果
function QualifyManager:on13506(data)
    self.model.qualifying_result = data
    self.model:OpenQualifyFinishUI()
end

--请求可参与次数
function QualifyManager:on13507(data)
    self.model.count_list = data.count_list
end

--请求段位排行榜返回
function QualifyManager:on13508(data)
    -- -- print("--------------------------------13508回来了")
    if self.model.rank_max_indexs == nil then
        self.model.rank_max_indexs = {}
    end
    self.model.rank_max_indexs[data.type] = data.max_idx
    self.model.rank_data_list = data.qualifying_roles
    self.model:update_rank_items(data)
end

--请求当前活动动态返回
function QualifyManager:on13509(data)
    self.model.qualifying_activitys = data
    self.model:update_activitys()
end

--点赞结果返回
function QualifyManager:on13510(data)
    if data.result ==0 then --失败

    else--成功

    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--请求当前匹配状态返回
function QualifyManager:on13511(data)
    -- print("--------------------------------收到13511")
    -- print(data.sign_type)
    -- BaseUtils.dump(data)

    self.model.sign_type = data.sign_type
    self.model.match_state_data = data
    EventMgr.Instance:Fire(event_name.qualify_state_update)
    self.model:update_fine_and_first_reward(data)

    self.model:update_reward_btn_point()
    --判断下五胜和首胜奖励能否领取
    local state = false
    if (data.win_flag ~= 1 and data.win >= 1) or (data.win_five_flag ~= 1 and data.win > 4) then
        state = true
    end
    local cfg_data = DataSystem.data_daily_icon[103]
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        return
    end
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(cfg_data.id, state)
    end
end

--请求进入准备区返回
function QualifyManager:on13512(data)
    -- -- print("---------------------------------------13512返回了")
    if data.result ==0 then --失败
        local unitData = {baseid = 20055}
        local base = BaseUtils.copytab(DataUnit.data_unit[20055])
        base.buttons = {}
        base.plot_talk = data.msg
        local extra = {base = base}
        MainUIManager.Instance:OpenDialog(unitData, extra)
    else--成功

    end
end

--请求退出准备区返回
function QualifyManager:on13513(data)
    if data.result ==0 then --失败

    else--成功

    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--请求退出准备区返回
function QualifyManager:on13514(data)
    if data.result ==0 then --失败

    else--成功
        if self.model:check_has_reward() == false then
            --没有奖励可以领取同时活动已经结束
            if self.model.activity_state == 0 then
                local cfg_data = DataSystem.data_daily_icon[103]
                MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
            end
        end
    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--发送协议逻辑
--报名
function QualifyManager:request13500(_type)
    -- -- print("--------------------------------------发送13500")
    Connection.Instance:send(13500, {type=_type})
end

--取消报名
function QualifyManager:request13501()
    -- -- print("--------------------------------------发送13501")
    Connection.Instance:send(13501, {})
end

--活动状态
function QualifyManager:request13502()
    -- -- print("--------------------------------------发送13502")
    Connection.Instance:send(13502, {})
end

--请求段位信息
function QualifyManager:request13504(_rid, _platform, _zone_id)
    -- -- print("--------------------------------------发送13504")
    Connection.Instance:send(13504, {rid = _rid, platform = _platform, zone_id = _zone_id})
end

--收到段位变化通知
function QualifyManager:request13505()
    -- -- print("--------------------------------------发送13505")
    Connection.Instance:send(13505, {})
end

--请求段位排行榜
function QualifyManager:request13508(_type, _idx, _num)
    -- -- print("------------------------------发送13508")
    Connection.Instance:send(13508, {type = _type, idx = _idx, num = _num})
end


--请求当前活动动态
function QualifyManager:request13509()
    Connection.Instance:send(13509, {})
end


--请求点赞
function QualifyManager:request13510(_rid, _platform, _zone_id)
    Connection.Instance:send(13510, {rid = _rid, platform = _platform, zone_id = _zone_id})
end

--请求当前匹配状态
function QualifyManager:request13511()
    Connection.Instance:send(13511, {})
end

--请求进入准备区
function QualifyManager:request13512()
    Connection.Instance:send(13512, {})
end

--请求退出准备区
function QualifyManager:request13513()
    Connection.Instance:send(13513, {})
end

--请求领取胜利奖励 1:首胜 2:五胜
function QualifyManager:request13514(_flag)
    Connection.Instance:send(13514, {flag = _flag})
end