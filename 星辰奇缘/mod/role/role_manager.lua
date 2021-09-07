-- ----------------------------------------------------------
-- 逻辑模块 - 角色信息
-- ----------------------------------------------------------
RoleManager = RoleManager or BaseClass(BaseManager)

function RoleManager:__init()
    if RoleManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
	RoleManager.Instance = self

    -- 角色数据
    self.RoleData = RoleInfo.New()

	self.world_lev = 0 --世界等级
	self.exp_ratio = 0 --世界等级经验加成
	self.coin_ratio = 0--世界等级金钱加成
	self.world_next_time = 0--世界等级下次刷时间
	self.exp_ratio_real = 0--配置取出来的未计算过的数值
    self.connect_type = 0 -- 是否能连上中央服


    self.jump_over_find = nil -- 跳到跨服后寻路目标
    self.jump_over_call = nil -- 跳到跨服后调用
    self.jump_match_type = nil -- 跳到跨服后匹配类型
    self.returnTime = nil
    self.returnListener = function() self:ShowReturnTips() end
    self.beginFcallback = function() self:SwitchCrossIcon(false) end
    self.endFcallback = function() self:SwitchCrossIcon(true) end
    self.showNameUsedGo = nil

    self.effectPath = "prefabs/effect/30000.unity3d"
    self.effect = nil
    self.effectTimeId = 0

    -- 本次登陆是否引导过突破
    self.isGuideBreakFirst = false
    self.isGuideBreakThird = false

    -- 经验模型
    self.expModeTab = {}
    self.foot_mark_id = 0   --足迹id

    self:InitHandler()

    self.listener = function() self:send10013() self:send10003() end
    EventMgr.Instance:AddListener(event_name.self_loaded, self.listener)
    self.sceneLoadListener = function() self:OnSceneLoad() end

    self.recharchUpdate = EventLib.New()

    self.updateRedPoint = EventLib.New()

    self.updateAddPointPlan3 = EventLib.New()
end

--[[
    协议处理
]]--
function RoleManager:InitHandler()
    self:AddNetHandler(10000, self.on10000)
    self:AddNetHandler(10001, self.on10001)
    self:AddNetHandler(10002, self.on10002)
    self:AddNetHandler(10003, self.on10003)
    self:AddNetHandler(10004, self.on10004)
    self:AddNetHandler(10005, self.on10005)
    self:AddNetHandler(10006, self.on10006)
    self:AddNetHandler(10007, self.on10007)
    self:AddNetHandler(10009, self.on10009)
    self:AddNetHandler(10011, self.on10011)
    self:AddNetHandler(10013, self.on10013)
    self:AddNetHandler(10014, self.on10014)
    self:AddNetHandler(10015, self.on10015)
    self:AddNetHandler(10016, self.on10016)
    self:AddNetHandler(10017, self.on10017)
    self:AddNetHandler(10019, self.on10019)
    self:AddNetHandler(10020, self.on10020)
    self:AddNetHandler(9904,  self.on9904)

    self:AddNetHandler(10024, self.on10024)
    self:AddNetHandler(10023, self.on10023)

    self:AddNetHandler(10025, self.on10025)
    self:AddNetHandler(10026, self.On10026)
    self:AddNetHandler(10030, self.On10030)
    self:AddNetHandler(10031, self.On10031)
    self:AddNetHandler(10035, self.on10035)
    self:AddNetHandler(10036, self.on10036)

    self:AddNetHandler(10037, self.on10037)
    self:AddNetHandler(10038, self.on10038)
end

--登录完成后回调
function RoleManager:Logined()
    if self.returnTime ~= nil then
        LuaTimer.Delete(self.returnTime)
        self.returnTime = nil
    end

    if self.RoleData ~= nil then
        self.RoleData.cross_type = nil
    end

    self:send10000()
    self:send10001()
    self:send10002()
    self:send10003()
    self:send10004()
    self:send10014()
    self:Send10020()
    self:send9904()
    self:Send10030()

    LevelBreakManager.Instance:send17400()
    NationalDayManager.Instance:Send14086()
    BuffPanelManager.Instance:send12803()

    self.isGuideBreakFirst = false
    self.isGuideBreakThird = false
end

function RoleManager:OnReConnet()
    LuaTimer.Add(5000, self.listener)
end

--获取世界等级
function RoleManager:on9904(dat)
    self.world_lev = dat.world_lev
    self.world_next_time = dat.next_time
    self.exp_ratio = 0
    self.coin_ratio = 0

    self:WorldlevRatio()

    EventMgr.Instance:Fire(event_name.world_lev_change)
end

--获取角色信息
function RoleManager:on10000(dat)
    -- BaseUtils.dump(dat, "角色信息")
    self.RoleData:Update(dat)
    EventMgr.Instance:Fire(event_name.logined)

    --设备激活
    BaseUtils.ActiveDevice(dat)

    self:send10007()

    LoginManager.Instance:send10022(SdkManager.Instance:GetDeviceIdIMEI())

    local roleData = RoleManager.Instance.RoleData -- 往下七行：从用户内存中读取上次的自动模式 by 嘉俊 2017/8/29 13：46
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "chain_automode")
    local autoMode = PlayerPrefs.GetInt(key) or 1
    if autoMode == 0 then
        autoMode = 2
    end
    AutoQuestManager.Instance.model.autoMode = autoMode
    self.updateRedPoint:Fire()
end

function RoleManager:on10001(dat)
    -- print("--------------------------收到10001")
    -- BaseUtils.dump(dat)
    self.RoleData:Update(dat, true)
    EventMgr.Instance:Fire(event_name.role_attr_change)
end

--获取角色资产
function RoleManager:on10002(dat)
    self.RoleData:Update(dat)
    EventMgr.Instance:Fire(event_name.role_asset_change)
end

--获取角色其他资产
function RoleManager:on10003(dat)
    self.RoleData:Update(dat)
    self.recharchUpdate:Fire()
    EventMgr.Instance:Fire(event_name.role_asset_change)
end

--获取角色等级经验
function RoleManager:on10004(dat)
    local level_change_mark = false
    local exp_change_mark = false
    if self.RoleData.lev ~= dat.lev then level_change_mark = true end
    if self.RoleData.exp ~= dat.exp then exp_change_mark = true end
    if self.RoleData.reserve_exp ~= dat.reserve_exp then exp_change_mark = true end

    self.RoleData:Update(dat)
    if level_change_mark then
        EventMgr.Instance:Fire(event_name.role_level_change)
        LuaTimer.Add(500, function() self:PlayLevup() end)
        -- self:PlayLevup()
        if SdkManager.Instance:RunSdk() then
            SdkManager.Instance:SendExtendDataRoleLevelUpdate()
        end
        -- KKKSdkWrapper:StatisticsInfo("RoleLevel")
    end
    if exp_change_mark then
        EventMgr.Instance:Fire(event_name.role_exp_change)
    end
end

--加点
function RoleManager:on10005(dat)
    -- print("------------------------------收到10005")
    -- BaseUtils.dump(dat)
    -- self.RoleData:Update(dat)
    -- EventMgr.Instance:Fire(event_name.role_attr_change)
    if dat.result == 1 then --成功
        SoundManager.Instance:Play(244)
    elseif dat.result == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

--设置加点方案
function RoleManager:on10006(dat)
    -- print("------------------------------收到10006")
    -- BaseUtils.dump(dat)
    -- self.RoleData:Update(dat)
    -- EventMgr.Instance:Fire(event_name.role_attr_change)
    if dat.result == 1 then --成功

    elseif dat.result == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

--请求加点设置
function RoleManager:on10007(dat)
    -- print("------------------------------收到10007")
    -- BaseUtils.dump(dat)
    self.RoleData:Update(dat)
    local crrentPlan = dat.plan_data[dat.valid_plan]
    if crrentPlan ~= nil then
        self.RoleData.pre_agi = crrentPlan.pre_agi
        self.RoleData.pre_str = crrentPlan.pre_str
        self.RoleData.pre_end = crrentPlan.pre_end
        self.RoleData.pre_magic = crrentPlan.pre_magic
        self.RoleData.pre_con = crrentPlan.pre_con
    else
        self.RoleData.pre_agi = 0
        self.RoleData.pre_str = 0
        self.RoleData.pre_end = 0
        self.RoleData.pre_magic = 0
        self.RoleData.pre_con = 0
    end
    table.sort(self.RoleData.plan_data, function(a,b) return a.index < b.index end)
    EventMgr.Instance:Fire(event_name.role_attr_change)
end

function RoleManager:on10009(dat)
    -- print("------------------------------收到10009")
    -- BaseUtils.dump(dat)
    -- self.RoleData:Update(dat)
    -- if dat.msg ~= "" then
    --     NoticeManager.Instance:FloatTipsByString(dat.msg)
    -- end
    -- EventMgr.Instance:Fire(event_name.role_attr_change)

    if dat.result == 0 then --失败

    elseif dat.result == 1 then --成功

    end
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 更新气血/魔法
function RoleManager:on10011(dat)
    self.RoleData:Update(dat)
    EventMgr.Instance:Fire(event_name.role_attr_change)
end

-- 领取离线经验
function RoleManager:on10013(dat)
    if dat.msg ~= nil and dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
end

-- 更新改名信息
function RoleManager:on10014(dat)
    -- BaseUtils.dump(dat)
    self.RoleData:Update({rename_free = dat.num, rename_unfree = dat.pay_num})
    EventMgr.Instance:Fire(event_name.role_name_change)
end

-- 改名请求返回
function RoleManager:on10015(dat)
    if dat.flag == 1 then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
        self.RoleData.name = dat.name
        self.RoleData.rename_free = dat.num
        self.RoleData.rename_unfree = dat.pay_num

        if self.renameCallback ~= nil then
            self.renameCallback()
            self.renameCallback = nil
        end
        EventMgr.Instance:Fire(event_name.role_name_change)
    else
        NoticeManager.Instance:FloatTipsByString(dat.msg)
        self.renameCallback = nil
    end
end

-- 请求他人信息返回
function RoleManager:on10016(dat)
    BaseUtils.dump(dat,"10016")
    if dat.zone_id == 0 then
        TipsManager.Instance.model:SetPlayerTipsInfo(nil)
    else
        LuaTimer.Add(100, function()
            TipsManager.Instance.model:SetPlayerTipsInfo(dat)
        end)
        TipsManager.Instance.model:SetPlayerTipsInfo(dat)
        -- EventMgr.Instance:Fire(event_name.update_charactor_info, dat)
    end
end

-- 曾用名列表返回
function RoleManager:on10017(dat)
    if not BaseUtils.isnull(self.showNameUsedGo) then
        local list = dat.role_name_used
        table.sort( list, function(a, b) return a.time>b.time end )
        local namedata = {}
        if #list == 0 then
            table.insert(namedata, TI18N("<color=#ffff00>无曾用名</color>"))
        else
            table.insert(namedata, TI18N("<color=#ffff00>曾用名:　　　</color>"))
        end
        for i,v in ipairs(list) do
            if i<6 then
                table.insert(namedata, v.name)
            end
        end
        TipsManager.Instance:ShowText({gameObject = self.showNameUsedGo, itemData = namedata, special = true})
        self.showNameUsedGo = nil
    end
end

function RoleManager:on10020(dat)
    if dat.type == 1 then
        if self.returnTime ~= nil then
            LuaTimer.Delete(self.returnTime)
            self.returnTime = nil
        end
    end

    if self.connect_type > 0 and dat.type == 0 and self.RoleData.cross_type == 1 then
        self.returnTime = LuaTimer.Add(60000, self.returnListener)
    end
    self.connect_type = dat.type
end

function RoleManager:ShowReturnTips()
    if self.returnTime ~= nil then
        LuaTimer.Delete(self.returnTime)
        self.returnTime = nil
    end

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Sure
    data.content = TI18N("与跨服练级区断开连接，已自动回到原服务器")
    data.sureLabel = TI18N("确认")
    data.sureCallback = function() self:QuitCenter() end
    NoticeManager.Instance:ConfirmTips(data)
end

--获取跨服信息
function RoleManager:on10019(dat)
    local mark = true
    if self.RoleData.cross_type == dat.cross_type then
        mark = false
    end
    self.RoleData.cross_type = dat.cross_type

    -- if PlayerPrefs.HasKey("RetrunToLocalEffect") == false then
    --     SettingManager.Instance:SetResult("RetrunToLocalEffect", 0)
    -- end
    if mark then
        if self.RoleData.cross_type == 0 then
            MainUIManager.Instance:DelAtiveIcon3(303)
        else
            MainUIManager.Instance:DelAtiveIcon3(303)

            local cfg_data = DataSystem.data_daily_icon[303]
            local data = AtiveIconData.New()
            data.id = cfg_data.id
            data.iconPath = cfg_data.res_name
            data.sort = cfg_data.sort
            data.lev = cfg_data.lev
            data.clickCallBack = function()
                if CombatManager.Instance.isFighting then
                    NoticeManager.Instance:FloatTipsByString(TI18N("战斗中无法返回原服"))
                    return
                end
                self:CheckQuitCenter()
                if self.returnicon_effectView ~= nil then
                    self.returnicon_effectView:DeleteMe()
                    self.returnicon_effectView = nil
                    -- SettingManager.Instance:SetResult("RetrunToLocalEffect", 1)
                end
            end
            data.createCallBack = function(gameObject)
                -- if self.returnicon_effectView == nil and SettingManager.Instance:GetResult("RetrunToLocalEffect") == false then
                if self.returnicon_effectView == nil or BaseUtils.is_null(self.returnicon_effectView.gameObject) then
                    local fun = function(effectView)
                        if BaseUtils.is_null(gameObject) then
                            effectView:DeleteMe()
                            return
                        end
                        self.returnicon_effectView = effectView
                        local effectObject = effectView.gameObject

                        effectObject.transform:SetParent(gameObject.transform)
                        effectObject.transform.localScale = Vector3(0.9, 0.9, 0.9)
                        effectObject.transform.localPosition = Vector3(-1.6, 30, -400)
                        effectObject.transform.localRotation = Quaternion.identity

                        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                    end
                    BaseEffectView.New({effectId = 20121, time = nil, callback = fun})
                end
            end
            MainUIManager.Instance:AddAtiveIcon3(data)
        end
        EventMgr.Instance:Fire(event_name.cross_type_change)
    end

    if self.jump_over_find ~= nil then
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneLoadListener)
    elseif self.jump_over_call ~= nil then
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneLoadListener)
    elseif self.jump_match_type ~= nil then
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneLoadListener)
    end

    if MainUIManager.Instance.MainUICanvasView ~= nil then
        MainUIManager.Instance.MainUICanvasView:ShowServer()
    end
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFcallback)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFcallback)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.endFcallback)
    EventMgr.Instance:AddListener(event_name.end_fight, self.endFcallback)
end

function RoleManager:OnSceneLoad()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneLoadListener)
    if self.jump_over_find ~= nil then
        QuestManager.Instance.model:FindNpc(self.jump_over_find)
        self.jump_over_find = nil
    end

    if self.jump_over_call ~= nil then
        self.jump_over_call()
        self.jump_over_call = nil
    end

    if self.jump_match_type ~= nil then
        local status = self.jump_match_type.status
        local first = self.jump_match_type.first
        local second = self.jump_match_type.second
        local desc = (first == 5) and TI18N("悬赏任务具有一定难度，请<color='#ffff00'>3人以上组队</color>再进行！") or TI18N("多人副本难度较大，还是<color='#ffff00'>3人以上组队</color>再挑战吧！")
        local descTemp = TI18N("1.<color='#ffff00'>队长</color>可额外获得<color='#ffff00'>20%</color>经验加成。\n2.<color='#ffff00'>队长</color>每10环可获得<color='#ffff00'>额外奖励</color>")
        desc = desc .. "\n" .. descTemp
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[first] = second

        if status == RoleEumn.TeamStatus.Leader then
            TeamManager.Instance:Send11701()
            self:CrossTeamUp(desc, "", TI18N("招募队员"), "", nil, nil,
                function()
                    LuaTimer.Add(500, function() TeamManager.Instance:AutoFind() end)
                end)
        else
            self:CrossTeamUp(desc, TI18N("当队长<color='#ffff00'>(荐)</color>"), "", TI18N("当队员"),
                function()
                    TeamManager.Instance:Send11701()
                    LuaTimer.Add(500, function() TeamManager.Instance:AutoFind() end)
                end,
                function()
                    TeamManager.Instance:AutoFind()
                end, nil)
        end
        self.jump_match_type = nil
    end
end

--切换加点方案
function RoleManager:on10024(data)
    if data.flag == 1 then --成功
        EventMgr.Instance:Fire(event_name.role_attr_option_change)
    elseif data.flag == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--切换加点方案
function RoleManager:on10023(dat)
    -- {uint32, left_point, "剩余分配点数"}
    -- print("----------------------------收到10023")
    -- BaseUtils.dump(dat)
    self.RoleData.point = dat.left_point
    EventMgr.Instance:Fire(event_name.role_attr_change)
end

--切换加点方案预览
function RoleManager:on10025(dat)
    -- print("-----------------------------收到10025")
    EventMgr.Instance:Fire(event_name.role_point_preview_back, dat)
end

--获取角色信息
function RoleManager:send10000()
    Connection.Instance:send(10000,{})
end

--获取角色属性
function RoleManager:send10001()
    Connection.Instance:send(10001,{})
end

--获取角色资产
function RoleManager:send10002()
    Connection.Instance:send(10002,{})
end

--获取角色其他资产
function RoleManager:send10003()
    Connection.Instance:send(10003,{})
end

--获取角色等级经验
function RoleManager:send10004()
    Connection.Instance:send(10004,{})
end

--加点
function RoleManager:send10005(info)
    Connection.Instance:send(10005,{strength = info[2], constitution = info[1], magic = info[3], agility = info[4], endurance = info[5]})
end

--设置加点方案
function RoleManager:send10006(info)
    Connection.Instance:send(10006,{strength = info[2], constitution = info[1], magic = info[3], agility = info[4], endurance = info[5]})
end

--请求加点方案
function RoleManager:send10007()
    Connection.Instance:send(10007,{})
end

--登录角色数据加载完成 通知服务器端
function RoleManager:send10008()
    Connection.Instance:send(10008,{from = ""})
end

---请求洗点
function RoleManager:send10009()
    Connection.Instance:send(10009,{})
end

-- 领取离线经验
function RoleManager:send10013()
    -- print("请求离线经验")
    EventMgr.Instance:RemoveListener(event_name.mainui_loaded, self.listener)
    EventMgr.Instance:RemoveListener(event_name.self_loaded, self.listener)
    Connection.Instance:send(10013,{})
end

-- 请求改名次数
function RoleManager:send10014()
    Connection.Instance:send(10014,{})
end

-- 请求改名
function RoleManager:send10015(name, callback)
    self.renameCallback = callback
    Connection.Instance:send(10015, {name = name})
end

-- 请求他人相信信息
function RoleManager:send10016(id, platform, zone_id)
    Connection.Instance:send(10016, {id = id, platform = platform, zone_id = zone_id})
end

function RoleManager:Send10017(id, platform, zone_id, showNameUsedGo)
    self.showNameUsedGo = showNameUsedGo
    Connection.Instance:send(10017, {id = id, platform = platform, zone_id = zone_id})
end

function RoleManager:Send10019()
    Connection.Instance:send(10019, {})
end

-- 请求本服是否连接上中央服
function RoleManager:Send10020()
    Connection.Instance:send(10020, {})
end


-- 切换加点方案
function RoleManager:Send10024(_valid_plan)
    Connection.Instance:send(10024, {valid_plan = _valid_plan})
end


-- 请求剩余分配点数
function RoleManager:Send10023()
    Connection.Instance:send(10023, {})
end

-- 请求加点方案预览
function RoleManager:Send10025(_valid_plan)
    print('------------------------------发送10025')
    Connection.Instance:send(10025, {valid_plan = _valid_plan})
end

-- 获取人物装备加成点数
function RoleManager:On10026( data )
    if AddPointManager.Instance.model ~= nil then
       if AddPointManager.Instance.model.addPointView ~= nil then

       AddPointManager.Instance.model.addPointView.slider.equipAdditonalPoints[1] = data.constitution
       AddPointManager.Instance.model.addPointView.slider.equipAdditonalPoints[2] = data.strength
       AddPointManager.Instance.model.addPointView.slider.equipAdditonalPoints[3] = data.magic
       AddPointManager.Instance.model.addPointView.slider.equipAdditonalPoints[4] = data.agility
       AddPointManager.Instance.model.addPointView.slider.equipAdditonalPoints[5] = data.endurance

       AddPointManager.Instance.model.addPointView.slider:UpdateEquipAddPoints()

       end
    end
end

--玩家实名认证信息返回
function RoleManager:On10030(data)
    print("------------------收到10030")
    BaseUtils.dump(data)
    self.RoleData:Update(data)

    BibleManager.Instance.redPointDic[1][20] = (data.is_auth == 0)
    BibleManager.Instance.onUpdateRedPoint:Fire()

    EventMgr.Instance:Fire(event_name.indulge_change)
    if data.is_auth == 0 and ((self.indulgeData[self.RoleData.platform] or {})[ctx.PlatformChanleId] or {}).is_need_check == 1 then
        BibleManager.Instance:AutoPopWin(20)
    end
end

--进行实名认证
function RoleManager:On10031(data)
    print("------------------收到10031")
    if data.flag == 1 then
        --成功
        -- BibleManager.Instance.model:CloseWindow()
    else
        --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 玩家实名认证信息
function RoleManager:Send10030()
    print("------------------发送10030")
    Connection.Instance:send(10030,{})
end

-- 进行实名认证
function RoleManager:Send10031(name, sfz_id)
    print("------------------发送10031")
    Connection.Instance:send(10031,{name = name, sfz_id = sfz_id})
end

---解锁等级
function RoleManager:send10034()
    Connection.Instance:send(10034,{})
end

function RoleManager:On10034(data)
    if data.result == 1 then
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

---请求世界等级
function RoleManager:send9904()
    Connection.Instance:send(9904,{})
end

-- 世界等级加成计算
function RoleManager:WorldlevRatio()
    for i,v in ipairs(DataWorldLev.data_exp) do
        local min = self.world_lev + v.lev_min
        local max = self.world_lev + v.lev_max
        local lev = self.RoleData.lev
        if self.world_lev >= 100 and RoleManager.Instance.RoleData.lev_break_times == 0  and self.RoleData.lev > 95 then
            lev = 95
        end
        if lev >= min and lev <= max then
            self.exp_ratio_real = v.exp_ratio
            self.exp_ratio = ((v.exp_ratio - 1000 < 0 and 0 or v.exp_ratio - 1000)) / 10
            self.coin_ratio = v.coin_ratio / 10
            break
        end
    end
end

-- 世界等级查看信息
function RoleManager:WorldlevTips()
    local timeStr = "--"
    if self.world_next_time ~= 0 then
        timeStr = string.format("%s-%s", os.date("%Y-%m-%d", self.world_next_time), os.date("%H:%M:00", self.world_next_time))
    end
    local exp_ratio = 0
    if self.world_lev >= 100 and RoleManager.Instance.RoleData.lev_break_times == 0  and self.RoleData.lev > 95 then
        exp_ratio = self.exp_ratio
    elseif self.world_lev > 40 and self.RoleData.lev > 20 then
        exp_ratio = self.exp_ratio
    else
        exp_ratio = 0
    end

    local content = {
        string.format(TI18N("当前世界等级：<color='#00ff00'>%s级</color>"), self.world_lev),
        string.format(TI18N("你当前的等级：<color='#00ff00'>%s级</color>"), self.RoleData.lev),
        string.format(TI18N("当前经验加成：100%%+<color='#00ff00'>%s%%</color>"), exp_ratio),
        string.format(TI18N("下次服务器开放等级时间：<color='#00ff00'>%s</color>"), timeStr)
    }
    local cfg_data = DataWorldLev.data_desc[self.world_lev]
    if cfg_data ~= nil then
        local str_tbl = StringHelper.Split(cfg_data.desc, ";")
        table.insert(content, " ")
        for i=1,#str_tbl do
            table.insert(content, str_tbl[i])
        end
    end
    return content
end

function RoleManager:PlayLevup()
    if BaseUtils.is_null(self.effect) then
        self:LoadEffect()
    else
        SoundManager.Instance:Play(217)
        self.effect:SetActive(false)
        self.effect:SetActive(true)
        self:EffectTime()
    end
end

function RoleManager:LoadEffect()
    --创建加载wrapper
    self.assetWrapper = AssetBatchWrapper.New()

    local func = function()
        SoundManager.Instance:Play(217)
        if self.assetWrapper == nil then
            return
        end
        if SceneManager.Instance.sceneElementsModel.self_view == nil then
            return
        end
        self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
        self.effect.name = "LevelEffect"
        local transform = self.effect.transform
        transform:SetParent(SceneManager.Instance.sceneElementsModel.self_view.gameObject.transform)
        transform.localScale = Vector3.one
        transform.localPosition = Vector3.zero
        transform:Rotate(Vector3(25, 0, 0))
        self.effect:SetActive(true)

        self.effectHideFunc = function() self:HideEffect() end

        self:EffectTime()

        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
    self.assetWrapper:LoadAssetBundle({{file = self.effectPath, type = AssetType.Main}}, func)
end

function RoleManager:EffectTime()
    if self.effectTimeId ~= 0 then
        LuaTimer.Delete(self.effectTimeId)
        self.effectTimeId = 0
    end
    self.effectTimeId = LuaTimer.Add(3000, self.effectHideFunc)
end

function RoleManager:HideEffect()
    self.effectTimeId = 0
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

-- 统一判断是否能连上中央服
function RoleManager:CanConnectCenter()
    if self.connect_type > 0 and self.world_lev >= 55 then
        return true
    end
    return false
end

function RoleManager:QuitCenter()
    if TeamManager.Instance:HasTeam() then
        TeamManager.Instance:Send11708()
        SceneManager.Instance:Send10171()
    else
        SceneManager.Instance:Send10171()
    end
end

-- 退出中央服检查
function RoleManager:CheckQuitCenter()
    if TeamManager.Instance:HasTeam() then
        self:CheckQuitCenterHasTeam()
    else
        self:CheckQuitCenterNoTeam()
    end
end

function RoleManager:CheckQuitCenterHasTeam()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("组队状态无法<color='#ffff00'>退出跨服</color>，是否<color='#ffff00'>退出队伍</color>后<color='#ffff00'>返回原服</color>？")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        TeamManager.Instance:Send11708()
        SceneManager.Instance:Send10171()
    end
    NoticeManager.Instance:ConfirmTips(data)
end

function RoleManager:CheckQuitCenterNoTeam()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("你确定要退出跨服，返回原服吗？\n<color='#ffff00'>(跨服状态悬赏、副本更容易组队)</color>")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() SceneManager.Instance:Send10171() end
    NoticeManager.Instance:ConfirmTips(data)
end

-- 进入中央服检查
function RoleManager:CheckEnterCenter()
    if TeamManager.Instance:HasTeam() then
        self:CheckEnterCenterHasTeam()
    else
        self:CheckEnterCenterNoTeam()
    end
end

function RoleManager:CheckEnterCenterHasTeam()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("组队状态无法<color='#ffff00'>进入跨服</color>，是否<color='#ffff00'>退出队伍</color>后进入？")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        TeamManager.Instance:Send11708()
        if MainUIManager.Instance.dialogModel ~= nil and MainUIManager.Instance.dialogModel.currentNpcData ~= nil then
            self.jump_over_find = string.format("%s_%s", MainUIManager.Instance.dialogModel.currentNpcData.id, MainUIManager.Instance.dialogModel.currentNpcData.battleid)
        end
        SceneManager.Instance:Send10170()
    end
    NoticeManager.Instance:ConfirmTips(data)
end

function RoleManager:CheckEnterCenterNoTeam()
    if MainUIManager.Instance.dialogModel ~= nil and MainUIManager.Instance.dialogModel.currentNpcData ~= nil then
        self.jump_over_find = string.format("%s_%s", MainUIManager.Instance.dialogModel.currentNpcData.id, MainUIManager.Instance.dialogModel.currentNpcData.battleid)
    end
    SceneManager.Instance:Send10170()
end

function RoleManager:CheckCross()
    if self.RoleData.cross_type == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("跨服区暂未开放此功能"))
        return true
    end
    return false
end

function RoleManager:CrossTeamUp(desc, lt, mt, rt, leader, member, mid)
    local info = {
        Desc = desc,
        Ltxt = lt,
        Mtxt = mt,
        Rtxt = rt,
        LGreen = true,
        MGreen = false,
        RGreen = false,
        LCallback = leader,
        MCallback = mid,
        RCallback = member,
    }
    LuaTimer.Add(800, function() TipsManager.Instance:ShowTeamUp(info) end)
end

function RoleManager:SwitchCrossIcon(bool)
    if bool and self.RoleData.cross_type == 1 then
        MainUIManager.Instance:DelAtiveIcon3(303)
        local cfg_data = DataSystem.data_daily_icon[303]
        local data = AtiveIconData.New()
        data.id = cfg_data.id
        data.iconPath = cfg_data.res_name
        data.sort = cfg_data.sort
        data.lev = cfg_data.lev
        data.clickCallBack = function()
            if CombatManager.Instance.isFighting then
                NoticeManager.Instance:FloatTipsByString(TI18N("战斗中无法返回原服"))
                return
            end
            self:CheckQuitCenter()
            if self.returnicon_effectView ~= nil then
                self.returnicon_effectView:DeleteMe()
                self.returnicon_effectView = nil
                -- SettingManager.Instance:SetResult("RetrunToLocalEffect", 1)
            end
        end
        data.createCallBack = function(gameObject)
        end
        MainUIManager.Instance:AddAtiveIcon3(data)
    else
        MainUIManager.Instance:DelAtiveIcon3(303)
    end
end

-- 检查突破后属性点兑换引导
-- 突破成功，且拥有经验值大于300万，指引任务未完成
function RoleManager:CheckBreakGuide()
    if self.RoleData.lev_break_times ~= 0 then --and self.RoleData.exp >= 3000000 then
        local quest = QuestManager.Instance:GetQuest(41720)
        if quest ~= nil and quest.finish ~= QuestEumn.TaskStatus.Finish then
            return true
        end
    end
    return false
end

-- =============================== 防沉迷 ======================================

function RoleManager:send10035()
    Connection.Instance:send(10035, {})
end

function RoleManager:on10035(data)
    self.indulgeData = self.indulgeData or {}
    for _,dat in ipairs(data.auth_sfz_cfg) do
        self.indulgeData[dat.platform] = self.indulgeData[dat.platform] or {}
        self.indulgeData[dat.platform][dat.channel_reg] = self.indulgeData[dat.platform][dat.channel_reg] or {}
        for k,v in pairs(dat) do
            self.indulgeData[dat.platform][dat.channel_reg][k] = v
        end
    end
    EventMgr.Instance:Fire(event_name.indulge_change)

    if self:ShowRealName() then
        BibleManager.Instance:AutoPopWin(20)
    end
end

function RoleManager:CanIRecharge(money)
    local platformId = ctx.PlatformChanleId
    self.indulgeData = self.indulgeData or {}
    self.indulgeData[RoleManager.Instance.RoleData.platform] = self.indulgeData[RoleManager.Instance.RoleData.platform] or {}

    if self.indulgeData[RoleManager.Instance.RoleData.platform][ctx.PlatformChanleId] == nil then
        return true
    else
        local data = self.indulgeData[self.RoleData.platform][ctx.PlatformChanleId]
        if data.is_lev_60 ~= 1 or self.RoleData.lev < 60 then
            if data.can_charge == 0 and self.RoleData.is_auth == 0 then
                -- NoticeManager.Instance:FloatTipsByString(TI18N("未认证身份信息禁止充值"))
                self:RechargeGoToIdentify()
                return false
            elseif data.is_nonage == 1 and self.RoleData.is_adult == 0 then
                if (PrivilegeManager.Instance.authsfz_charge or 0) + money >= data.charge_limit then
                    NoticeManager.Instance:FloatTipsByString(string.format(TI18N("未成年人累计充值不能超过<color='#00ff00'>%s</color>元"), data.charge_limit))
                    return false
                else
                    return true
                end
            else
                return true
            end
        else
            return true
        end
    end
end

-- 充值前 前往认证
function RoleManager:RechargeGoToIdentify()
    self.identifyConfirmData = self.identifyConfirmData or NoticeConfirmData.New()
    self.identifyConfirmData.type = ConfirmData.Style.Normal
    self.identifyConfirmData.content = TI18N("亲爱的玩家您好，进行<color='#ffff00'>实名制认证</color>后才能充值哦，是否前往认证？")
    self.identifyConfirmData.sureLabel = TI18N("前往认证")
    self.identifyConfirmData.sureCallback = function()
        if not BaseUtils.IsIosVest() and ctx.PlatformChanleId ~= 33 and SdkManager.Instance:IsOpenRealName() and BibleManager.Instance.isRealName == 0 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, 24})
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, 20})
        end
    end
    NoticeManager.Instance:ConfirmTips(self.identifyConfirmData)
end

function RoleManager:JuvenilesConfirm()
    self.identifyConfirmData = self.identifyConfirmData or NoticeConfirmData.New()
    self.identifyConfirmData.type = ConfirmData.Style.Sure
    self.identifyConfirmData.content = TI18N("亲爱的玩家您好，根据未成年人限制，您今日的充值额度已达到上限，明天再来吧^_^")
    self.identifyConfirmData.sureLabel = TI18N("前往认证")
    self.identifyConfirmData.sureCallback = function()
        if not BaseUtils.IsIosVest() and ctx.PlatformChanleId ~= 33 and SdkManager.Instance:IsOpenRealName() and BibleManager.Instance.isRealName == 0 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, 24})
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1, 20})
        end
    end
    NoticeManager.Instance:ConfirmTips(self.identifyConfirmData)
end

function RoleManager:ShowRealName()
    return self.RoleData.is_auth == 0 and ((self.indulgeData[self.RoleData.platform] or {})[ctx.PlatformChanleId] or {}).is_need_check == 1
end


function RoleManager:send10036(mod)
    Connection.Instance:send(10036, {mod = mod})
end

function RoleManager:on10036(data)
    self.expModeTab = self.expModeTab or {}
    self.expModeTab[data.mod] = data
    EventMgr.Instance:Fire(event_name.exp_mode_change, data.mod)
end


function RoleManager:send10037()
    Connection.Instance:send(10037, {})
end

function RoleManager:on10037(data)
    -- BaseUtils.dump("收到10037")
    local confirmdata = NoticeConfirmData.New()
    confirmdata.type = ConfirmData.Style.Normal
    confirmdata.content = data.msg
    confirmdata.sureLabel = "提前开启"
    confirmdata.sureCallback = function() self:send10038(1) end
    confirmdata.cancelCallback = function() self:send10038(0) end
    NoticeManager.Instance:ConfirmTips(confirmdata)
end

function RoleManager:send10038(decision)
    Connection.Instance:send(10038, {decision = decision})
end

function RoleManager:on10038(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.updateAddPointPlan3:Fire()
    end
end
