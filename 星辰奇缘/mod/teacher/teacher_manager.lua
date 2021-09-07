-- 师徒
-- @author zgs
TeacherEnum = TeacherEnum or {}

TeacherEnum.Type = {
    Teacher = 3, --师傅
    Student = 1, --徒弟
    BeTeacher = 2, --出师
    None = 0, --没有状态
}

TeacherManager = TeacherManager or BaseClass(BaseManager)

function TeacherManager:__init()
    if TeacherManager.Instance then
        Debug.LogError("")
        return
    end
    TeacherManager.Instance = self
    self:initHandle()

    self.model = TeacherModel.New()

    self.dailyRedPointDic = {
        -- [rid_platform_zoneid] = {日常是否红点, 目标是否红点设}
    }

    self.dailyInitRed = {}
    self.pressKey = "press"
    self.logined = "logined"

    self.onUpdateInfo = EventLib.New()
    self.onUpdateDaily = EventLib.New()
    self.onUpdateTarget = EventLib.New()
    self.onUpdateDailyRed = EventLib.New()

    self.onUpdateDailyRed:AddListener(function()
        local bool = false
        for k,v in pairs(self.dailyInitRed) do
            if v ~= nil then
                bool = bool or (v == true)
            end
        end
        bool = bool or (self.isFirstLogin == true)
        bool = bool or SwornManager.Instance:CheckRedPointState()
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(302, bool)
        end
    end)

    EventMgr.Instance:AddListener(event_name.scene_load, function()
        self.onUpdateDailyRed:Fire()
    end)

    EventMgr.Instance:AddListener(event_name.role_level_change, function()
        if RoleManager.Instance.world_lev < 45 or RoleManager.Instance.RoleData.lev ~= 28 or self.model.myTeacherInfo.status > 0 then
            return
        end

        local dataCon = NoticeConfirmData.New()
        dataCon.type = ConfirmData.Style.Normal
        dataCon.content = TI18N("你已经可以拜师了，是否选择一名师傅带你装X带你飞呢？")
        dataCon.sureLabel = TI18N("找师傅")
        dataCon.cancelLabel = TI18N("取 消")
        dataCon.sureCallback = function() self.model:ShowApprenticeResearchPanel(true) end
        NoticeManager.Instance:ConfirmTips(dataCon)
    end)
end

function TeacherManager:initHandle()
    self:AddNetHandler(15800, self.on15800)
    self:AddNetHandler(15801, self.on15801)
    self:AddNetHandler(15802, self.on15802)

    self:AddNetHandler(15804, self.on15804)
    self:AddNetHandler(15805, self.on15805)
    self:AddNetHandler(15806, self.on15806)
    self:AddNetHandler(15807, self.on15807)
    self:AddNetHandler(15808, self.on15808)
    self:AddNetHandler(15809, self.on15809)
    self:AddNetHandler(15810, self.on15810)
    self:AddNetHandler(15811, self.on15811)
    self:AddNetHandler(15812, self.on15812)
    self:AddNetHandler(15813, self.on15813)
    self:AddNetHandler(15814, self.on15814)
    self:AddNetHandler(15815, self.on15815)
    self:AddNetHandler(15816, self.on15816)
    self:AddNetHandler(15817, self.on15817)
    self:AddNetHandler(15818, self.on15818)
    self:AddNetHandler(15819, self.on15819)
    self:AddNetHandler(15820, self.on15820)
    self:AddNetHandler(15821, self.on15821)
    self:AddNetHandler(15822, self.on15822)
    self:AddNetHandler(15823, self.on15823)
    self:AddNetHandler(15824, self.on15824)
    -- self:AddNetHandler(15501, self.on15501)
    -- self:AddNetHandler(15502, self.on15502)
    -- self:AddNetHandler(15503, self.on15503)
    -- self:AddNetHandler(15504, self.on15504)
    -- self:AddNetHandler(15505, self.on15505)
    -- self:AddNetHandler(15506, self.on15506)

    -- EventMgr.Instance:AddListener(event_name.mainui_btn_init, function ()
    --     Log.Error("TeacherManager:initHandle()------------------------------")
    --     print(GuildManager.Instance.model:has_guild())
    --     if GuildManager.Instance.model:has_guild() == true then
    --         self:send15500() --登陆后，请求活动状态 =>>收到公会信息协议11100后请求
    --         self:send15501()
    --     end
    --     -- self:send15506()
    -- end)

    -- EventMgr.Instance:AddListener(event_name.role_asset_change, function ()
    --     self:roleAssetChange()
    -- end)
end
function TeacherManager:RequestInitData()
    self.isFirstLogin = false
    self.isFirstRequest = true
    self.model.targetData = {}
    self.model.dailyData = {}
    self.model.masterRewardList = {}
    self.dailyRedPointDic = {}
    self.dailyInitRed = {}
    self:send15804() --我的师门状态
    self:send15815() --报名状态
end
--带徒拜师
function TeacherManager:on15800(data)
    -- BaseUtils.dump(data, "on15800===")
end
--带徒拜师,师傅发，id为徒弟id。徒弟收15801
function TeacherManager:send15800(id,platform,zone_id,str)
    Connection.Instance:send(15800, {id = id,platform = platform,zone_id = zone_id,str = str})
end
--收徒信息:
--徒弟收到，发15802，师傅收15801。
--师傅收到
function TeacherManager:on15801(data)
    -- BaseUtils.dump(data, "on15801===")
    if data.type == 1 then --有人向你收徒
        data.tsFlag = TeacherEnum.Type.Teacher --数据是老师的
        self.model:ShowApprenticePanel(true,data)
    elseif data.type == 2 then --别人同意收徒
        self.model:ShowBeBSPanel(true,data)
    elseif data.type == 3 then --别人拒绝
        NoticeManager.Instance:FloatTipsByString(TI18N("对方拒绝了您的收徒意愿"))
    elseif data.type == 4 then --成为别人徒弟
        self.model:ShowBeBSPanel(true,data)
    end
end
--收徒信息
function TeacherManager:send15801()
    Connection.Instance:send(15801, {})
end
--同意拒绝
function TeacherManager:on15802(data)
    -- BaseUtils.dump(data, "on15802===")
    if data.flag == 1 then
        --成功
        self.model:ShowBeBSPanel(true)
    else
        --失败
    end
end
--同意拒绝
function TeacherManager:send15802(id,platform,zone_id,flag)
    Connection.Instance:send(15802, {id = id,platform = platform,zone_id = zone_id,flag = flag})
end

--推荐师徒信息
function TeacherManager:on15804(data)
    -- BaseUtils.dump(data, "on15804===")
    self.model.myTeacherInfo = data
    local isFirstToday = false
    local roleData = RoleManager.Instance.RoleData
    local lastTime = PlayerPrefs.GetInt(BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, self.logined), 86400)
    if math.ceil((BaseUtils.BASE_TIME + 1) / 86400) ~= math.ceil((lastTime + 1) / 86400) then
        isFirstToday = true
    end
    PlayerPrefs.SetInt(BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, self.logined), BaseUtils.BASE_TIME)
    local roleData = RoleManager.Instance.RoleData
    if data.status > 0 then
        if data.status == 1 then
            self.isFirstLogin = isFirstToday
        end
        self.showIcon = true
        self:send15807()
    else
        self.showIcon = false
    end
    self:SetIcon()
    self.onUpdateDailyRed:Fire()
end

function TeacherManager:SetIcon()
    local cfg_data1 = DataSystem.data_daily_icon[302]
    local cfg_data2 = DataSystem.data_daily_icon[321]
    local roleData = RoleManager.Instance.RoleData
    MainUIManager.Instance:DelAtiveIcon3(cfg_data1.id)
    MainUIManager.Instance:DelAtiveIcon3(cfg_data2.id)

    local cfg_data = nil
    if self.showIcon == true then
        cfg_data = cfg_data2    -- 师徒
    end
    if SwornManager.Instance.showIcon == true then
        cfg_data = cfg_data1    -- 关系
    end
    if cfg_data ~= nil then
        if self.iconData == nil then
            self.iconData = AtiveIconData.New()
        end
        self.iconData.id = cfg_data.id
        self.iconData.iconPath = cfg_data.res_name
        self.iconData.clickCallBack = function()
            self.isFirstLogin = false
            if self.model.myTeacherInfo.status == TeacherEnum.Type.Student
                or self.model.myTeacherInfo.status == TeacherEnum.Type.BeTeacher
             then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.apprenticeship, {{rid = roleData.id, platform = roleData.platform, zone_id = roleData.zone_id, classes = roleData.classes, sex = roleData.sex}, 1})
            else
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.teacher_window, {1})
            end
            self.onUpdateDailyRed:Fire()
        end
        self.iconData.sort = cfg_data.sort
        self.iconData.lev = cfg_data.lev
        MainUIManager.Instance:AddAtiveIcon3(self.iconData)
    end
end


--推荐师徒信息
function TeacherManager:send15804()
    Connection.Instance:send(15804, {})
end
--师徒日常
function TeacherManager:on15805(data)
    -- BaseUtils.dump(data, "on15805===")
    local key = BaseUtils.Key(data.tar_rid, data.tar_platform, data.tar_zone_id)
    self.model.dailyData[key] = data

    local bool = true
    if #data.list > 0 then
        for k,v in pairs(data.list) do
            bool = bool and (v.finish == 1)
        end
    else
        bool = false
    end

    bool = bool and (data.daily_reward == 0)
    if self.dailyRedPointDic[key] == nil then self.dailyRedPointDic[key] = {} end
    self.dailyRedPointDic[key][1] = bool
    self.dailyInitRed[key] = self.dailyRedPointDic[key][2] or bool

    self.onUpdateInfo:Fire()
    self.onUpdateDaily:Fire()
    self.onUpdateDailyRed:Fire()
end
--师徒日常
function TeacherManager:send15805(id,platform,zone_id)
    -- print("发送15805")
    Connection.Instance:send(15805, {id = id,platform = platform,zone_id = zone_id})
end
--师徒目标
function TeacherManager:on15806(data)
    -- BaseUtils.dump(data, "on15806===")
    local model = self.model
    local key = BaseUtils.Key(data.tar_rid, data.tar_platform, data.tar_zone_id)
    model.targetData[key] = data

    for i,v in ipairs(data.target_reward) do
        if RoleManager.Instance.RoleData.lev >= DataTeacher.data_get_target[v.id].lev then 
            model.masterRewardList[v.id] = 0
        end
    end

    for i,v in ipairs(data.target_rewarded) do
        model.masterRewardList[v.id] = 1
    end

    local bool = false
    if model.myTeacherInfo.status == 3 then
        for k,v in pairs(model.masterRewardList) do
            bool = bool or (v == 0)
        end
    else
        for k,v in pairs(data.list) do
            bool = bool or (v.finish == 1)
        end
    end

    if self.dailyRedPointDic[key] == nil then self.dailyRedPointDic[key] = {} end
    self.dailyRedPointDic[key][2] = bool
    self.dailyInitRed[key] = self.dailyRedPointDic[key][1] or bool

    self.onUpdateInfo:Fire()
    self.onUpdateTarget:Fire()
    self.onUpdateDailyRed:Fire()
end
--师徒目标
function TeacherManager:send15806(id,platform,zone_id)
    -- print("发送15806")
    self.model.masterRewardList = {}
    Connection.Instance:send(15806, {id = id,platform = platform,zone_id = zone_id})
end
--师徒信息
function TeacherManager:on15807(data)
    -- BaseUtils.dump(data, "on15807===")
    self.model.teacherStudentList = data
    EventMgr.Instance:Fire(event_name.teahcer_student_info_change)
    -- self.model:UpdateWindow()
    if self.isFirstRequest then
        self:send15820()
        self.isFirstRequest = false
    end

    self.onUpdateDailyRed:Fire()
end
--师徒信息
function TeacherManager:send15807()
    -- print("TeacherManager:send15807()")
    Connection.Instance:send(15807, {})
end
--师徒鼓励 -------------------暂时不要了
function TeacherManager:on15808(data)
    -- BaseUtils.dump(data, "on15808===")
end
--师徒鼓励 -------------------暂时不要了
function TeacherManager:send15808(id,platform,zone_id)
    Connection.Instance:send(15808, {id = id,platform = platform,zone_id = zone_id})
end
--师徒奖励
function TeacherManager:on15809(data)
    -- BaseUtils.dump(data, "on15809===")
end
--师徒奖励
function TeacherManager:send15809(type,id)
    Connection.Instance:send(15809, {type = type,id = id})
end
--等级评价
function TeacherManager:on15810(data)
    -- BaseUtils.dump(data, "on15810===")
    if data.flag == 1 then
        --徒弟
        -- self.model:OnLevelChangeListener() --不缓存
    elseif data.flag == 2 then
        --师傅
        -- if data.lev == RoleManager.Instance.RoleData.lev then
            local dataCon = NoticeConfirmData.New()
            dataCon.type = ConfirmData.Style.Sure
            local v = 1
            if data.type == 2 then
                v = 3
            elseif data.type == 3 then
                v = 5
            end
            dataCon.content = string.format(TI18N("徒弟<color='#ffff00'>%s</color>升级到<color='#00ff00'>%d</color>级，他对您最近的教导做出了评价,您获得了<color='#00ff00'>%d</color>师道值"),data.name,data.lev,v)
            dataCon.sureLabel = TI18N("确定")
            NoticeManager.Instance:ConfirmTips(dataCon)
        -- end
    end
end
--等级评价
function TeacherManager:send15810(lev,value)
    Connection.Instance:send(15810, {lev = lev,type = value})
end

--师徒关系
function TeacherManager:on15811(data)
    -- BaseUtils.dump(data, "on15811===")
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
--师徒关系
function TeacherManager:send15811(id,platform,zone_id,type) -- type = 1:开除徒弟2:退出师门3:出师
    Connection.Instance:send(15811, {id = id,platform = platform,zone_id = zone_id,type = type})
end
--出师反馈
function TeacherManager:on15812(data)
    -- BaseUtils.dump(data, "on15812===")
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("你已经达到了%d级，师傅决定让你出师了~出师将获得大量奖励，是否决定出师？"),RoleManager.Instance.RoleData.lev)
    data.sureLabel = TI18N("确定")
    data.cancelLabel = TI18N("取消")
    data.cancelCallback = function()
        TeacherManager.Instance:send15812(0)
    end
    data.sureCallback = function ()
        TeacherManager.Instance:send15812(1)
    end
    NoticeManager.Instance:ConfirmTips(data)
end
--出师反馈
function TeacherManager:send15812(type)
    Connection.Instance:send(15812, {type = type})
end

--师门训诫
function TeacherManager:on15813(data)
    -- BaseUtils.dump(data, "on15813===")
    if data.flag == 0 then
        --失败
    elseif data.flag == 1 then
        --成功
    end
end
--师门训诫
function TeacherManager:send15813(msg)
    Connection.Instance:send(15813, {msg = msg})
end
--报名做师傅
function TeacherManager:on15814(data)
	-- BaseUtils.dump(data, "on15814===")
    if data.flag == 0 then
        --失败
    elseif data.flag == 1 then
        --成功
    end
end
--报名做师傅
function TeacherManager:send15814(msg)
    -- print("发15814")
    Connection.Instance:send(15814, { msg = msg })
end
--报名状态
function TeacherManager:on15815(data)
    -- BaseUtils.dump(data, "on15815===")
    self.model.beTeacherState = data.flag
    -- if data.flag == 0 then
    --     --没有报名
    -- elseif data.flag == 1 then
    --     --已经报名
    -- end
    self.onUpdateDailyRed:Fire()
end
--报名状态
function TeacherManager:send15815()
    Connection.Instance:send(15815, {})
end
--找师傅
function TeacherManager:on15816(data)
    -- BaseUtils.dump(data, "on15816===")
    if #data.list > 0 then
        self.model.selectteacherList = data.list
        self.model:ShowSelectTeacherPanel(true)
    else

    end
end
--找师傅
function TeacherManager:send15816(sex,clazz)
    Connection.Instance:send(15816, {sex = sex,classes = clazz})
end
--师傅验收
function TeacherManager:on15817(data)
    -- BaseUtils.dump(data, "on15817===")
    local key = BaseUtils.Key(data.id, data.platform, data.zone_id)
    if self.dailyRedPointDic[key] == nil then self.dailyRedPointDic[key] = {} end

    if data.flag == 1 then
        if data.type == 1 then          -- 师傅收到验收请求
            self.dailyRedPointDic[key][1] = true
            self.onUpdateDailyRed:Fire()

            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.content = string.format(TI18N("您的徒弟<color=#00FF00>%s</color>已经完成了今天的教学功课，请您前往进行验收"), data.name)
            confirmData.sureLabel = TI18N("验 收")
            confirmData.cancelLabel = TI18N("取 消")
            confirmData.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.apprenticeship, {{rid = data.id, platform = data.platform, zone_id = data.zone_id, status = 1}, 1}) end
            NoticeManager.Instance:ConfirmTips(confirmData)
        elseif data.type == 2 then      -- 徒弟收到验收成功通知
            self.dailyRedPointDic[key][1] = true
            self.onUpdateDailyRed:Fire()

            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.content = TI18N("你的师傅已经验收了你的功课，请前往邮件领取奖励")
            confirmData.sureLabel = TI18N("前往领取")
            confirmData.cancelLabel = TI18N("取 消")
            confirmData.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friend, {3}) end
            NoticeManager.Instance:ConfirmTips(confirmData)
        elseif data.type == 3 then
        end
    end

    self.onUpdateDaily:Fire()
end

--师傅验收
function TeacherManager:send15817(id,platform,zone_id, op_type)
    Connection.Instance:send(15817, {id = id,platform = platform,zone_id = zone_id, op_type = op_type})
end

function TeacherManager:on15818(data)
    -- BaseUtils.dump(data, "on15818===")
end

function TeacherManager:send15818(id, platform, zone_id, targetid)
    Connection.Instance:send(15818, {id = id,platform = platform,zone_id = zone_id, target_id = targetid})
end

function TeacherManager:on15819(data)
    -- BaseUtils.dump(data, "<color=#00FF00>==============15819============</color>")
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = string.format(TI18N("<color='%s'>%s</color>在导师德林处相中了你并想拜你为师，如果你愿意收TA为徒的话，赶快组队带TA去<color='#ffff00'>圣心城-导师德林</color>处举行拜师仪式吧！"),ColorHelper.color[1], data.name)
    -- confirmData.sureLabel = "发送私聊"
    confirmData.sureLabel = TI18N("收TA为徒")
    confirmData.cancelLabel = TI18N("邀请组队")
    confirmData.showClose = 1
    confirmData.sureCallback = function()
        local dat = BaseUtils.copytab(data)
        -- dat.id = data.rid
        -- FriendManager.Instance:TalkToUnknowMan(dat)
        data.tsFlag = TeacherEnum.Type.Student --数据是学生的
        self.model:ShowApprenticePanel(true,data)
    end
    confirmData.cancelCallback = function()
        TeamManager.Instance:Send11702(data.id, data.platform, data.zone_id)
    end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function TeacherManager:send15819(id, platform, zone_id)
    -- print("发送15819")
    Connection.Instance:send(15819, {id = id, platform = platform, zone_id = zone_id})
end

function TeacherManager:on15820(data)
    -- BaseUtils.dump(data, "<color=#00FF00>==============15820============</color>")
    for i,v in ipairs(data.list) do
        self.dailyInitRed[BaseUtils.Key(v.rid, v.platform, v.zone_id)] = (v.flag == 1)
    end
end

function TeacherManager:send15820()
    -- print("发送15820")
    Connection.Instance:send(15820, {})
end
--出师奖励
function TeacherManager:on15821(data)
    -- BaseUtils.dump(data, "on15821===")
    self.model:ShowBeTeacherFinishRewardPanel(true,data)
end
--出师奖励
function TeacherManager:send15821()
    Connection.Instance:send(15821, {})
end

--请求师傅列表
function TeacherManager:on15822(data)
    -- BaseUtils.dump(data, "on15822===")
    self.onUpdateInfo:Fire(data)
end

--请求师傅列表
function TeacherManager:send15822()
    -- print("send15822")
    Connection.Instance:send(15822, {})
end

--请求徒弟列表
function TeacherManager:on15823(data)
    BaseUtils.dump(data, "on15823===")
    self.onUpdateInfo:Fire(data)
end

--请求徒弟列表
function TeacherManager:send15823()
    print("send15823")
    Connection.Instance:send(15823, {})
end

--请求师傅本周礼包
function TeacherManager:on15824(data)
    BaseUtils.dump(data, "on15824===")
    self.model.teachergiftMax = data.max_num
    self.model.teachergiftReceived = data.num
    --self.onUpdateInfo:Fire(data)
end
function TeacherManager:send15824()
    print("send15824")
    Connection.Instance:send(15824, {})
end

function TeacherManager:Press(data)
    local key = BaseUtils.Key(data.id, data.platform, data.zone_id, self.pressKey)
    local lastTime = PlayerPrefs.GetInt(key)
    local lastDay = 0
    local thisDay = math.ceil((BaseUtils.BASE_TIME + 1) / 86400)
    if lastTime ~= nil then
        lastDay = math.ceil((lastTime + 1) / 86400)
    end

    if thisDay - lastDay > 0 then
        FriendManager.Instance:TalkToUnknowMan(data, 2)
        PlayerPrefs.SetInt(key, BaseUtils.BASE_TIME)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("你今天已经督促过ta了，给ta点时间去完成嘛"))
    end
end
