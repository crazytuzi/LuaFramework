-- ----------------------------
-- 任务
-- hosr
-- ----------------------------
QuestManager = QuestManager or BaseClass(BaseManager)

function QuestManager:__init()
    if QuestManager.Instance then
        return
    end
    QuestManager.Instance = self

    self.model = QuestModel.New()
    self.questWindow = nil

    self.questTab = {}

    self:InitHandler()

    -- 历练任务篇章节
    self.part = 0
    self.chapter = 0
    self.section = 0

    --悬赏任务作为队长做任务的次数，显示在预览处,最大100次
    self.captim_time_max = 100
    self.captin_time = 1
    self.offer_over = false
   --悬赏任务环数，显示在预览处
    self.ring_offer = 1
    --悬赏任务轮次，显示在预览处
    self.round_offer = 1
    --职业任务轮次，显示在预览处
    self.round_cycle = 1
    --职业任务环数，一天总共2环，用作判断处理
    self.time_cycle_max = 1
    self.time_cycle = 0
    --宝图任务轮次
    self.round_treasure = 1
    --公会任务轮次
    self.time_guild = 1
    --公会任务环数
    self.round_guild = 1
    --光速修炼环数
    self.round_fine = 1
    -- 任务链轮次
    self.time_chain = 1
    -- 任务链环数
    self.round_chain_max = 200
    self.round_chain = 1
    self.chainBattleId = 0
    self.chainUnitId = 0
    self.chainBaseId = 0
    self.chainFightNpcId = 0
    self.chainLucky = 0

    --伴侣任务轮次
    self.round_couple_max = 10
    self.round_couple = 1
    self.time_couple = 1

    -- 种植任务轮次
    self.round_plant_max = 6
    self.round_plant = 1
    self.time_plant = 1

    -- 师徒任务轮次
    self.round_teacher_max = 5
    self.round_teacher = 1
    self.time_teacher = 1
    self.teacher_question = 0
    self.teacher_question_zoneId = 0
    self.teacher_question_platform = ""

    -- 守卫蛋糕轮次
    self.round_defensecake = 1

    -- 结缘任务
    self.round_hello_max = 4
    self.round_hello = 1

    -- 进度
    self.target_progress = 1
    -- 目标名称
    self.target_name = ""

    -- 自动跑主线标志
    self.autoRun = false

    -- 出了自动提交接取的自动跑标志
    self.autoRunExceptAuto = true

    -- 任务杀怪指引点按钮
    self.guideKillId = 0

    -- 是否可以提交游侠任务
    self.questStatsCanCommit = 1

    self.listener = function() self.model:SceneLoad() end
    self.maintracelistener = function() self:OnMainTraceLoaded() end
    EventMgr.Instance:AddListener(event_name.scene_load, self.listener)
    EventMgr.Instance:AddListener(event_name.map_click, function() self:ClickMap() end)
    EventMgr.Instance:AddListener(event_name.trace_quest_loaded, self.maintracelistener)

    -- 市场扩展参数
    self.taskArgs = nil

    -- 种植数据
    self.plantData = nil

    -- 子女任务植物更新
    self.childPlantUpdate = EventLib.New()

    self.childPregnancyUpdate = EventLib.New()


    self.getQuestStatus = EventLib.New()

    self.offerCome20 = false
    self.InitCount = 0

end

function QuestManager:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

function QuestManager:InitHandler()
    self:AddNetHandler(10200, self.On10200)
    self:AddNetHandler(10201, self.On10201)
    self:AddNetHandler(10202, self.On10202)
    self:AddNetHandler(10203, self.On10203)
    self:AddNetHandler(10204, self.On10204)
    self:AddNetHandler(10205, self.On10205)
    self:AddNetHandler(10206, self.On10206)
    self:AddNetHandler(10207, self.On10207)
    self:AddNetHandler(10208, self.On10208)
    self:AddNetHandler(10209, self.On10209)
    self:AddNetHandler(10210, self.On10210)
    self:AddNetHandler(10211, self.On10211)
    self:AddNetHandler(10212, self.On10212)
    self:AddNetHandler(10213, self.On10213)
    self:AddNetHandler(10214, self.On10214)
    self:AddNetHandler(10215, self.On10215)
    self:AddNetHandler(10223, self.On10223)
    self:AddNetHandler(10224, self.On10224)
    self:AddNetHandler(10225, self.On10225)
    self:AddNetHandler(10243, self.On10243)
    self:AddNetHandler(10244, self.On10244)
    self:AddNetHandler(10245, self.On10245)
    self:AddNetHandler(10247, self.On10247)
    self:AddNetHandler(10250, self.On10250)
    self:AddNetHandler(10255, self.On10255) -- inserted by 嘉俊
    self:AddNetHandler(10256, self.On10256) -- inserted by 嘉俊
end

function QuestManager:RequestInitData()
    self.captin_time = 1
    self.offer_over = false
    --悬赏任务环数，显示在预览处
    self.ring_offer = 1
    --悬赏任务轮次，显示在预览处
    self.round_offer = 1
    --职业任务轮次，显示在预览处
    self.round_cycle = 1
    self.time_cycle = 0
    --宝图任务轮次
    self.round_treasure = 1
    --公会任务轮次
    self.time_guild = 1
    --公会任务环数
    self.round_guild = 1
    --光速修炼环数
    self.round_fine = 1
    -- 任务杀怪指引点按钮
    self.guideKillId = 0
    self.part = 0
    self.chapter = 0
    self.section = 0

    -- 任务链轮次
    self.time_chain = 1
    -- 任务链环数
    self.round_chain = 1
    self.chainBattleId = 0
    self.chainUnitId = 0
    self.chainBaseId = 0
    self.chainFightNpcId = 0
    self.chainLucky = 0

    --伴侣任务轮次
    self.round_couple = 1
    self.time_couple = 1

    -- 种植任务轮次
    self.round_plant = 1
    self.time_plant = 1

    -- 守卫蛋糕轮次
    self.round_defensecake = 1

    --单身狗轮次
    self.round_singledog = 1

    self.target_progress = 1
    self.target_name = ""

    self.questTab = {}

    self:RemoveMainNotice()
    self:RemovePlantTips()

    -- 自动跑主线标志
    self.autoRun = false

    -- 是否可以提交游侠任务
    self.questStatsCanCommit = 1

    -- 种植数据
    self.plantData = nil

    self:Send10200()
    self:Send10201()
    self:Send10213()
    self:Send10224()
    self:Send10243()
    self:Send10247()
end

-- 点击地图取消自动跑的标志
function QuestManager:ClickMap()
    local lev = RoleManager.Instance.RoleData.lev
    if lev <= 26 then
        if MainUIManager.Instance.mainuitracepanel ~= nil and MainUIManager.Instance.mainuitracepanel.traceQuest ~= nil then
            MainUIManager.Instance.mainuitracepanel.traceQuest:PlayEffect(true)
        end
    end
end

function QuestManager:OnTick()
    if self.autoRun and SceneManager.Instance.sceneModel.map_loaded then
        self.autoRun = false
        self.model:NpcState()
        self.model:Auto()
        self:CheckMainNotice()
        self:CheckAddPlantTips()
    end
end

function QuestManager:Notice(msg)
    if msg ~= nil and msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(msg)
    end
end

function QuestManager:CheckNeedAuto(sec_type, action)
    if self.offerCome20 then
        self.autoRun = false
        return
    end
    if (sec_type == QuestEumn.TaskType.practice or sec_type == QuestEumn.TaskType.practice_pro) and action == "accept" then
        self.model.lastType = sec_type
        self.autoRun = true
    elseif sec_type == QuestEumn.TaskType.guide then
        self.autoRun = true
    elseif sec_type == QuestEumn.TaskType.seekChild then
        self.model.lastType = sec_type
        self.autoRun = true
    elseif sec_type == QuestEumn.TaskType.child or sec_type == QuestEumn.TaskType.childbreed then
        self.model.lastType = sec_type
        self.autoRun = true
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow and (sec_type == QuestEumn.TaskType.couple or sec_type == QuestEumn.TaskType.ambiguous or sec_type == QuestEumn.TaskType.teacher) then
        self.autoRun = true
    elseif sec_type == self.model.lastType and sec_type ~= QuestEumn.TaskType.offer then
        self.autoRun = true
    elseif sec_type == QuestEumn.TaskType.acquaintance then
        self.autoRun = true
    end
end

-- 检查是否没有主线任务了，没有就插入一条提示追踪，点击打开剧情任务面板
function QuestManager:CheckMainNotice()
    if MainUIManager.Instance.mainuitracepanel == nil or MainUIManager.Instance.mainuitracepanel.traceQuest == nil or not MainUIManager.Instance.mainuitracepanel.traceQuest.isInit then
        return
    end

    if RoleManager.Instance.RoleData.lev < 20 then
        self:RemoveMainNotice()
        return
    end

    local questData = self:GetQuestMain()
    if questData == nil then
        self:AddMainNotice()
    else
        self:RemoveMainNotice()
    end
end

function QuestManager:AddMainNotice()
    if self.mainNoticeItem == nil then
        self.mainNoticeItem = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()
        self.mainNoticeItem.type = CustomTraceEunm.Type.MainQuest
        self.mainNoticeItem.title = string.format(TI18N("<color='%s'>[剧情]新剧情任务</color>"), QuestEumn.ColorName(QuestEumn.TaskType.main))
        self.mainNoticeItem.Desc = TI18N("有新的剧情任务可接，点击前往<color='#ffff00'>剧情面板</color>接取")
        self.mainNoticeItem.callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.taskdrama) end
        MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.mainNoticeItem)
        self:ClickMap()
    end
end

function QuestManager:RemoveMainNotice()
    if self.mainNoticeItem ~= nil then
        MainUIManager.Instance.mainuitracepanel.traceQuest:HideEffectBefore()
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.mainNoticeItem.customId)
        self.mainNoticeItem = nil
    end
end

function QuestManager:GetNoticeItemId()
    if self.mainNoticeItem ~= nil then
        return self.mainNoticeItem.customId
    end
    return nil
end

function QuestManager:OnMainTraceLoaded()
    EventMgr.Instance:RemoveListener(event_name.trace_quest_loaded, self.maintracelistener)
    self:CheckMainNotice()
    self:CheckAddPlantTips()
end
-- ------------------
-- 已接任务列表
-- ------------------
function QuestManager:Send10200()
    self:Send(10200, {})
end

function QuestManager:On10200(dat)
    -- BaseUtils.dump(dat, "<color=#00FF00>----------------已接任务----------------</color>")
    self.getQuestStatus:Fire(dat)
    local list = {}
    for _,quest in ipairs(dat.quest_list) do
        local questData = QuestData.New()
        questData:SetProto(quest)
        local base = DataQuest.data_get[quest.id]
        if base == nil then
            Log.Error(string.format("不存在ID=%s的任务配置", quest.id))
        else
            questData:SetBase(base)
            self.questTab[quest.id] = questData
            table.insert(list, quest.id)
        end
    end


    self:CheckDefaultFollow(list)

    self.InitCount = self.InitCount + 1
    if self.InitCount == 2 then
        MainUIManager.Instance:InitPanels()
    elseif self.InitCount > 2 then
        EventMgr.Instance:Fire(event_name.quest_update, list)
        self:CheckMainNotice()
        self:CheckAddPlantTips()
    end
end

-- ------------------
-- 可接任务列表
-- ------------------
function QuestManager:Send10201()
    self:Send(10201, {})
end

function QuestManager:On10201(dat)
    -- BaseUtils.dump(dat, "可接任务")
    local list = {}
    for _,quest in ipairs(dat.can_accept_quest_list) do
        local questData = QuestData.New()
        questData:SetProto(quest)
        local base = DataQuest.data_get[quest.id]
        if base == nil then
            Log.Error(string.format("不存在ID=%s的任务配置", quest.id))
        else
            questData:SetBase(base)
            self.questTab[quest.id] = questData
            table.insert(list, quest.id)
        end
    end
    self:CheckDefaultFollow(list)
    self.InitCount = self.InitCount + 1
    if self.InitCount == 2 then
        MainUIManager.Instance:InitPanels()
    elseif self.InitCount > 2 then
        EventMgr.Instance:Fire(event_name.quest_update, list)
        self:CheckMainNotice()
        self:CheckAddPlantTips()
    end

end

-- ------------------
-- 尝试接受任务
-- ------------------
function QuestManager:Send10202(id)
    self:Send(10202, {id = id})
    print("发送10202")
end

function QuestManager:On10202(dat)
    self:Notice(dat.msg)
    -- BaseUtils.dump(dat,0000000)
end

-- ------------------
-- 增加已接任务
-- ------------------
function QuestManager:On10203(dat)
    -- print("-------------收到10203")
    --BaseUtils.dump(dat, "增加已接任务")
    local list = {}
    local checkNotice = false
    for _,quest in ipairs(dat.quest_list) do
        local questData = QuestData.New()
        questData:SetProto(quest)
        local base = DataQuest.data_get[quest.id]
        if base == nil then
            Log.Error(string.format("不存在ID=%s的任务配置", quest.id))
        else
            table.insert(list, quest.id)
            questData:SetBase(base)
            self.questTab[quest.id] = questData

            self.model:AcceptOne(quest.id)

            --根据类型播剧本
            if base.sec_type == QuestEumn.TaskType.fineType then
                DramaManager.Instance.model:JustPlayPlot(base.id, function()
                    QuestManager.Instance:DoQuest(questData)
                end)
            end
        end
        self:CheckNeedAuto(questData.sec_type, "accept")
        if questData.type == QuestEumn.TaskTypeSer.main or questData.sec_type == QuestEumn.TaskType.plant then
            checkNotice = true
        end
    end
    self:CheckDefaultFollow(list)
    if #list > 0 then
        EventMgr.Instance:Fire(event_name.quest_update, list)
    end
    list = nil

    if checkNotice then
        self:CheckMainNotice()
        self:CheckAddPlantTips()
    end
end

-- ------------------
-- 删除可接任务
-- ------------------
function QuestManager:On10204(dat)
    -- BaseUtils.dump(dat, "删除可接任务")
    local list = {}
    for _,quest in ipairs(dat.can_accept_quest_list) do
        local questData = self.questTab[quest.id]
        if questData ~= nil then
            table.insert(list, quest.id)
            self:CheckNeedAuto(questData.sec_type)
        end
        self.questTab[quest.id] = nil
    end
    if #list > 0 then
        EventMgr.Instance:Fire(event_name.quest_update, list)
    end
    list = nil
end

-- ------------------
-- 尝试放弃任务
-- ------------------
function QuestManager:Send10205(id)
    self:Send(10205, {id = id})
end

function QuestManager:On10205(dat)
    self:Notice(dat.msg)
end

-- ------------------
-- 尝试提交任务
-- ------------------
function QuestManager:Send10206(id)
    self:Send(10206, {id = id})
end

function QuestManager:On10206(dat)

    self:Notice(dat.msg)
    if dat.flag == 1 then
        if AutoQuestManager.Instance.model.isOpen then -- inserted by 嘉俊 自动历练交任务时才解除购买多个物品的锁，若不处于自动购买，则使用原来的froznButton来防止多次购买
            if AutoQuestManager.Instance.model.lockSecondBuy == true then
                AutoQuestManager.Instance.model.lockSecondBuy = false -- 自动历练，自动职业任务中，自动购买解锁
            end
        end -- end by 嘉俊
        self.model:CommitOne(dat.id)
    end

end

-- ------------------
-- 增加可接任务
-- ------------------
function QuestManager:On10207(dat)
    -- BaseUtils.dump(dat, "增加可接任务")
    local list = {}
    for _,quest in ipairs(dat.can_accept_quest_list) do
        local questData = QuestData.New()
        questData:SetProto(quest)
        local base = DataQuest.data_get[quest.id]
        if base == nil then
            Log.Error(string.format("不存在ID=%s的任务配置", quest.id))
        else
            table.insert(list, quest.id)
            questData:SetBase(base)
            self.questTab[quest.id] = questData
        end
        self:CheckNeedAuto(questData.sec_type)
    end
    list = self:CheckDefaultFollow(list)
    if #list > 0 then
        EventMgr.Instance:Fire(event_name.quest_update, list)
    end
    list = nil
end

-- ------------------
-- 删除已接任务
-- ------------------
function QuestManager:On10208(dat)
    -- BaseUtils.dump(dat, "删除已接任务")
    local list = {}
    for _,quest in ipairs(dat.quest_list) do
        table.insert(list, quest.id)
        local questData = self.questTab[quest.id]
        if questData ~= nil then
            self:CheckNeedAuto(questData.sec_type)
        end

        self.model:RemoveOne(questData)

        self.questTab[quest.id] = nil
    end
    if #list > 0 then
        EventMgr.Instance:Fire(event_name.quest_update, list)
    end
    list = nil
end

-- ------------------
-- 更新已接任务进度
-- ------------------
function QuestManager:On10209(dat)
    BaseUtils.dump(dat, "更新已接任务进度")
    local list = {}
    for _,quest in ipairs(dat.quest_list) do
        local questData = self.questTab[quest.id]
        if questData == nil then
            self.questTab[quest.id] = nil
        else
            table.insert(list, quest.id)
            questData:SetProto(quest)
            if questData.finish == QuestEumn.TaskStatus.Finish then
                self.model:FinishOne(questData)
            end
            self:CheckNeedAuto(questData.sec_type)
        end
    end
    if #list > 0 then
        EventMgr.Instance:Fire(event_name.quest_update, list)
    end
    list = nil
    CampaignInquiryManager.Instance:RefreshQuest(dat)
end

-- ------------------
-- 动态任务奖励列表
-- ------------------
function QuestManager:On10210(dat)
    -- BaseUtils.dump(dat, "动态任务奖励列表")
end

-- ------------------
-- 根据类型接受相应任务
-- ------------------
function QuestManager:Send10211(type, args)
    args = args or 1
    Log.Debug("接取类型任务..."..type)
    self:Send(10211, {sec_type = type, args = args})
end


-- ------------------
-- 请求任务状态
-- ------------------
function QuestManager:Send10212(id)
    self:Send(10212, {id = id})
    --print("-----------发送10212"..id)
end

function QuestManager:On10212(data)

    --BaseUtils.dump(data,"-----------收到10212")
    --光棍节活动
    --if data.id == 83670 or data.id == 83660 or data.id == 83650 then
        self.getQuestStatus:Fire(data)
        if DoubleElevenManager.Instance.singleDogIsOpen == false then
            DoubleElevenManager.Instance.singleDogOpened = false
            DoubleElevenManager.Instance.closeSingleDog:Fire()
        end
        if data.state ~= 0 then
            DoubleElevenManager.Instance.questGet = true
        else
            DoubleElevenManager.Instance.questGet = false
        end
    --end
end

-- ------------------
-- 请求历练任务数据
-- ------------------
function QuestManager:Send10213()
    self:Send(10213, {})
end

function QuestManager:On10213(dat)
    -- BaseUtils.dump(dat, "请求历练任务数据")
    self.part = dat.part
    self.chapter = dat.chapter
    self.section = dat.section

    if DataQuestPrac.data_piece[dat.part] == nil then
        -- 超出了
        self.part = dat.part - 1
        local prac_data = DataQuestPrac.data_piece[self.part]
        if prac_data ~= nil then
            self.chapter = prac_data.chapters
        else
            self.chapter = 1
        end

        local chapter_data = DataQuestPrac.data_chapter[string.format("%s_%s", self.part, self.chapter)]
        if chapter_data ~= nil then
            self.section = chapter_data.sections
        else
            self.section = 1
        end
    end
end

-- 统计数据
function QuestManager:On10214(dat)
    -- print("-------------------------收到10214")
    for i,v in ipairs(dat.quest_stats) do
        if v.sec_type == QuestEumn.TaskType.offer then
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.LeaderTimes then--作为队长做任务的次数
                    self.captin_time = stat.value
                elseif stat.key == QuestEumn.StatisticsType.Round then--显示的任务轮次
                    self.round_offer = stat.value
                elseif stat.key == QuestEumn.StatisticsType.Ring then--显示的任务环数
                    self.ring_offer = stat.value
                end
            end
        elseif v.sec_type == QuestEumn.TaskType.cycle then
            self.target_progress = 1
            self.target_name = ""
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.Round then--轮次
                    self.round_cycle = stat.value
                elseif stat.key == QuestEumn.StatisticsType.Ring then--环数
                    self.time_cycle = stat.value
                end
            end

            -- 字符串
            for i,d in ipairs(v.desc) do
                self.target_progress = d.prog_id
                for i,ds in ipairs(d.desc_array) do
                    if ds.key == QuestEumn.StringType.TargetName then
                        self.target_name = ds.string
                    end
                end
            end
        elseif v.sec_type == QuestEumn.TaskType.treasuremap then
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.Round then--轮次
                    self.round_treasure = stat.value
                end
            end
        elseif v.sec_type == QuestEumn.TaskType.guild then
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.Round then--轮次
                    self.round_guild = stat.value
                elseif stat.key == QuestEumn.StatisticsType.Ring then--环数
                    self.time_guild = stat.value
                end
            end
        elseif v.sec_type == QuestEumn.TaskType.fineType then
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.Round then--环数
                    self.round_fine = stat.value
                elseif stat.key == QuestEumn.StatisticsType.QuestStatsCanCommit then -- 是否可提交
                    self.questStatsCanCommit = stat.value
                end
            end
        elseif v.sec_type == QuestEumn.TaskType.chain then
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.Round then--轮次
                    self.round_chain = stat.value
                    -- -- inserted by 嘉俊 497163788@qq.com 历练环达到整百次数时出现宝箱界面
                    if self.round_chain  == 101 then
                        -- print("*************************************AAAAAAAAAAAAAAA"..self.round_chain)
                        AutoQuestManager.Instance.model.lockAuto = true
                    end
                    -- if self.time_chain == 101 and self.model.hasTreasureOfChain100 == 0 then
                    --     self.model.hasTreasureOfChain100 = 1 -- 0代表未领取，1代表待领取，2代表已领取
                    -- elseif self.time_chain == 1 then -- 当接取历练环时将100环和200环的宝箱标记重置
                    --     self.model.hasTreasureOfChain100 = 0
                    --     self.model.hasTreasureOfChain200 = 0
                    -- elseif self.time_chain == 1 and self.model.hasTreasureOfChain200 == 0 then
                    --     self.model.hasTreasureOfChain200 = 1
                    -- end
                    -- -- end by 嘉俊
                elseif stat.key == QuestEumn.StatisticsType.Ring then--环数
                    self.time_chain = stat.value
                elseif stat.key == QuestEumn.StatisticsType.CommitBattleId then
                    self.chainBattleId = stat.value
                elseif stat.key == QuestEumn.StatisticsType.CommitId then
                    self.chainUnitId = stat.value
                elseif stat.key == QuestEumn.StatisticsType.CommitBaseId then
                    self.chainBaseId = stat.value
                elseif stat.key == QuestEumn.StatisticsType.ChainLuckyVal then
                    self.chainLucky = stat.value
                end
            end
        elseif v.sec_type == QuestEumn.TaskType.couple or v.sec_type == QuestEumn.TaskType.ambiguous then
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.Round then--轮次
                    self.round_couple = stat.value
                elseif stat.key == QuestEumn.StatisticsType.Ring then--环数
                    self.time_couple = stat.value
                end
            end
        elseif v.sec_type == QuestEumn.TaskType.plant then
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.Round then--轮次
                    self.round_plant = stat.value
                elseif stat.key == QuestEumn.StatisticsType.Ring then--环数
                    self.time_plant = stat.value
                end
            end
        elseif v.sec_type == QuestEumn.TaskType.acquaintance then
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.Round then--轮次
                    self.round_hello = stat.value
                elseif stat.key == QuestEumn.StatisticsType.Ring then--环数
                    -- self.time_plant = stat.value
                end
            end
        elseif v.sec_type == QuestEumn.TaskType.singledog then
        for i,stat in ipairs(v.stats) do
            if stat.key == QuestEumn.StatisticsType.Round then--轮次
                self.round_singledog = stat.value
            end
        end
        elseif v.sec_type == QuestEumn.TaskType.defensecake then
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.Round then--轮次
                    self.round_defensecake = stat.value
                end
            end
            EventMgr.Instance:Fire(event_name.nationalday_defense_update)
        elseif v.sec_type == QuestEumn.TaskType.teacher then
            for i,stat in ipairs(v.stats) do
                if stat.key == QuestEumn.StatisticsType.Round then--轮次
                    self.round_teacher = stat.value
                elseif stat.key == QuestEumn.StatisticsType.Ring then--环数
                    self.time_teacher = stat.value
                elseif stat.key == QuestEumn.StatisticsType.QuestionId then--题目
                    self.teacher_question = stat.value
                elseif stat.key == QuestEumn.StatisticsType.QuestionZoneId then--题目区号
                    self.teacher_question_zoneId = stat.value
                end
            end

            -- 字符串
            for i,d in ipairs(v.desc) do
                for i,ds in ipairs(d.desc_array) do
                    if ds.key == QuestEumn.StringType.QuestionFlatform then
                        self.teacher_question_platform = ds.string
                    end
                end
            end
        end
    end
end

-- 获取每日完成任务
function QuestManager:Send10215(type)
    self:Send(10215, {sec_type = type})
end

function QuestManager:On10215(dat)
    -- BaseUtils.dump(dat, "获取每日完成任务")
end

-- 跳过任务链的战斗任务
function QuestManager:Send10216(assets_enum)
    self:Send(10216, {assets_enum = assets_enum})
end

-- 发起任务链战斗
function QuestManager:Send10217(battleid, npcid)
    self:Send(10217, {battle_id = battleid, id = npcid})
end

-- 任务链战斗任务求助
function QuestManager:Send10218(quest_id)
    self:Send(10218, {quest_id = quest_id})
end

-- 队伍同步播放任务对话
function QuestManager:Send10223(quest_id, talk_type)
    self:Send(10223, {quest_id = quest_id, talk_type = talk_type})
end

function QuestManager:On10223(dat)
    -- BaseUtils.dump(dat, "On10223")
    if dat.op_code == 1 then
        -- 队伍成员都收到这个，成功了才播放对话
        self:PlayTalk(dat.quest_id, dat.talk_type)
    end
end

--请求种植任务数据
function QuestManager:Send10224()
    self:Send(10224, {})
end

function QuestManager:On10224(dat)
    self.plantData = dat
end

-- 种植
function QuestManager:Send10225()
    self:Send(10225, {})
end

function QuestManager:On10225(dat)
    if dat.msg ~= nil and dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
end

function QuestManager:PlayTalk(quest_id, talk_type)
    local questData = self.questTab[quest_id]
    if questData ~= nil then
        -- 都显示丘比特的预览
        local baseId = 20047
        if questData.sec_type == QuestEumn.TaskType.teacher then
            baseId = 20063
        elseif questData.sec_type == QuestEumn.TaskType.couple or questData.sec_type == QuestEumn.TaskType.ambiguous then
            baseId = 20047
        end

        local content = questData.talk_commit
        if talk_type == 1 then
            -- 接取对话
            -- baseId = questData.npc_accept
            content = questData.talk_accpet
        elseif talk_type == 3 then
            -- 提交对话
            baseId = questData.npc_commit
            content = questData.talk_commit
        end

        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            if talk_type == 3 then
                -- 完成的任务点击提交
                MainUIManager.Instance.dialogModel:SetAnywayCallback(function() QuestManager.Instance:Send10206(quest_id) end)
            else
                -- 其他的点击关掉做任务去
                if questData.sec_type == QuestEumn.TaskType.couple then
                    MainUIManager.Instance.dialogModel:SetAnywayCallback(function() self.model:DoCouple() end)
                elseif questData.sec_type == QuestEumn.TaskType.ambiguous then
                    MainUIManager.Instance.dialogModel:SetAnywayCallback(function() self.model:DoAmbiguous() end)
                elseif questData.sec_type == QuestEumn.TaskType.teacher then
                    MainUIManager.Instance.dialogModel:SetAnywayCallback(function() self.model:DoTeacher() end)
                end
            end
        else
            MainUIManager.Instance.dialogModel:SetTimeoutClose(5000)
        end

        local npcBase = BaseUtils.copytab(DataUnit.data_unit[baseId])
        npcBase.buttons = {}
        npcBase.plot_talk = content
        local npcData = {}
        npcData.baseid = baseId
        npcData.id = 0
        npcData.battle_id = 1
        npcData.classes = npcBase.classes
        npcData.sex = npcBase.sex
        npcData.looks = npcBase.looks
        MainUIManager.Instance:OpenDialog(npcData, {base = npcBase}, true)
    end
end

-- 子女任务单位
function QuestManager:Send10243()
    self:Send(10243, {})
end

function QuestManager:On10243(data)
    -- BaseUtils.dump(data, "子女任务单位")
    self.childPlantData = data
    self.childPlantUpdate:Fire()
end

-- 啪啪啪
function QuestManager:Send10244()
    self:Send(10244, {})
end

function QuestManager:On10244(data)
    if data.flag == 1 then
        local data = {}
        data.id = 20257
        data.time = 12
        data.type = 0
        data.map = 0
        data.x = 3662
        data.y = 2321
        EffectBrocastManager.Instance:On9907(data)
        -- local data = {icon = "target3", title = TI18N("浓情蜜意"), msg = TI18N("今日已完成浓情蜜意任务，具体结果将于1-2小时内公布，保持这份恩爱，期待爱情结晶吧{face_1,3}"), btntext = TI18N("确定")}
        -- LuaTimer.Add(2000, function()
        --     ChildrenManager.Instance.model:OpenNoticeResultPanel(data)
        -- end)
    end
    NoticeManager.Instance:FloatTipsByString(TI18N(data.msg))
end
-- 子女任务活力
function QuestManager:Send10245()
    self:Send(10245, {})
end

function QuestManager:On10245(data)
    if data.flag == 1 then
        ChildrenManager.Instance.model:StartGetWater()
    end
    NoticeManager.Instance:FloatTipsByString(TI18N(data.msg))
end


-- 子女孕育期任务状态数据
function QuestManager:Send10247()
    self:Send(10247, {})
end

-- 子女孕育期任务状态数据
function QuestManager:On10247(data)
    -- BaseUtils.dump(data, "子女孕育单位")
    self.childPregnancyData = data
    self.childPregnancyUpdate:Fire()
end

function QuestManager:Send10250()
    self:Send(10250, {})
end

-- 悬赏任务第三十环,通知成员加队长好友
function QuestManager:On10250(data)
    local confirmData = NoticeConfirmData.New()
    confirmData.content = string.format(TI18N("队长<color='#ffff00'>%s</color>辛劳带队，加个好友吧"), data.name)
    confirmData.sureLabel = TI18N("^_^好的")
    confirmData.sureCallback = function() FriendManager.Instance:Require11804(data.id, data.platform, data.zone_id) end
    confirmData.cancelLabel = TI18N("取消")
    confirmData.cancelSecond = 30
    NoticeManager.Instance:ConfirmTips(confirmData)
end

-- 根据ID获取身上的任务
function QuestManager:GetQuest(id)
    return self.questTab[id]
end

function QuestManager:GetAll()
    return self.questTab
end

--根据任务内容标签类型获取当前进度的目标名称
function QuestManager:GetTargetByLabel(cli_label, target)
    local tar_name = ""
    if cli_label == QuestEumn.CliLabel.use or cli_label == QuestEumn.CliLabel.gain then
        local itemData = DataItem.data_get[target]
        if itemData ~= nil then
            tar_name = itemData.name
        end
    elseif cli_label == QuestEumn.CliLabel.fight or cli_label == QuestEumn.CliLabel.visit or cli_label == QuestEumn.CliLabel.collect then
        local unitData = DataUnit.data_unit[target]
        if unitData ~= nil then
            tar_name = unitData.name
        end
    elseif cli_label == QuestEumn.CliLabel.catchpet then
        local petData = DataPet.data_pet[target]
        if petData ~= nil then
            tar_name = petData.name
        end
    end
    return tar_name
end

-- 获取相应类型的任务列表
function QuestManager:GetQuestByType(sec_type)
    for id,questData in pairs(self.questTab) do
        if questData.sec_type == sec_type then
            return questData
        end
    end
    return nil
end

-- 注意，只取第一个进度内容,看情况用
function QuestManager:GetQuestCurrentLabel(questData)
    if questData.progress_ser == nil or #questData.progress_ser == 0 then
        return QuestEumn.CliLabel.visit
    end
    for i,sp in ipairs(questData.progress_ser) do
        local cp = questData.progress[i]
        if sp.finish ~= 1 then
            return cp.cli_label
        end
    end
    return nil
end

-- 获取npc相关任务列表
function QuestManager:GetNpcQuest(npcid, battleid, npcBaseid)
    local back = {}

    for i,task in pairs(self.questTab) do
        if task.finish == 0 then
            if task.sec_type == QuestEumn.TaskType.guild then
               if task.npc_accept == npcid then
                    table.insert(back, task)
               end
            else
                if task.npc_accept_id == npcid and task.npc_accept_battle == battleid then
                    table.insert(back, task)
                end
            end
        elseif task.finish == 2 then
            if task.sec_type == QuestEumn.TaskType.guild then
                if task.npc_commit_id == 0 then
                    if task.npc_commit == npcid then
                        table.insert(back, task)
                    end
                elseif task.npc_commit_id == npcid then
                    table.insert(back, task)
                end
            else
                if task.npc_commit_id == npcid and task.npc_commit_battle == battleid then
                    table.insert(back, task)
                elseif task.npc_commit_id == 0 and task.npc_commit_battle == 0 and task.npc_commit == npcBaseid then
                    table.insert(back, task)
                end
            end
        elseif task.finish == 1 and task.sec_type == QuestEumn.TaskType.chain
            and self:GetQuestCurrentLabel(task) == QuestEumn.CliLabel.fight then
            -- 进行中
            local id = self:GetTargetidSer(task)
            if id ~= nil and npcid == id then
                table.insert(back, task)
            end
        end
    end

    table.sort(back,
                function(a,b)
                    if a.finish == b.finish then
                        return a.id < b.id
                    else
                        return a.finish > b.finish
                    end
                end)
    return back
end

-- 获取主线任务, 包括一般主线，历练，历练精英 .....
function QuestManager:GetQuestMain()
    for id,questData in pairs(self.questTab) do
        if id ~= 44500 and id ~= 44510 and questData.type == QuestEumn.TaskTypeSer.main then -- 去掉职业奥秘任务
            return questData
        end
    end
end

-- 做主线
function QuestManager:DoMain()
    self.model:DoMain()
end

-- 做任务
function QuestManager:DoQuest(questData)
    AutoFarmManager.Instance:stopFarm() --停止挂机
    AutoQuestManager.Instance.disabledAutoQuest:Fire() -- 停止自动历练、自动职业任务 -- by 嘉俊
    self.model:DoIt(questData)
end

--根据任务id获取提交任务的npc
function QuestManager:CommitNpc(taskid)
    local task = DataQuest.data_get[taskid]
    if task ~= nil then
        return BaseUtils.get_unique_npcid(task.npc_commit_id, task.npc_commit_battle)
    else
        return nil
    end
end

--根据任务id获取接受任务的npc
function QuestManager:AcceptNpc(taskid)
    local task = DataQuest.data_get[taskid]
    if task ~= nil then
        return BaseUtils.get_unique_npcid(task.npc_accept_id, task.npc_accept_battle)
    else
        return nil
    end
end

--根据任务id获取任务目标的npc
function QuestManager:TargetNpc(taskid)
    local task = DataQuest.data_get[taskid]
    if task ~= nil then
        local key = {}
        for i,sp in ipairs(task.server_progress) do
            local cp = task.progress[i]
            if cp.cli_label ~= QuestEumn.CliLabell.patrol and cp.cli_label ~= QuestEumn.CliLabell.levelup then
                for arg1, arg2 in string.gmatch(cp.msg, "(%d+),(%d+)") do
                    arg1 = tonumber(arg1)
                    arg2 = tonumber(arg2)
                    if arg1 ~= 99 then
                        --场景元素
                        table.insert(key, BaseUtils.get_unique_npcid(arg2, arg1))
                    end
                end
            end
        end
        return key
    else
        return {}
    end
end

--获取任务的目标id 列表
function QuestManager:GetTargetid(taskid)
    local list = {}
    local task = DataQuest.data_get[taskid]
    if task ~= nil then
        for i,cp in ipairs(task.progress) do
            table.insert(list, cp.target)
        end
    end
    return list
end

-- 获取当前任务的当前目标-- 服务端数据
-- 注意，只取第一个进度内容,看情况用
function QuestManager:GetTargetidSer(questData)
    if questData.progress_ser == nil then
        return nil
    end
    for i,sp in ipairs(questData.progress_ser) do
        if sp.finish ~= 1 then
            return sp.target
        end
    end
    return nil
end

-- 获取当前任务的当前目标-- 服务端数据
-- 注意，只取第一个进度内容,看情况用
function QuestManager:GetTargetDataSer(questData)
    if questData.progress_ser == nil then
        return nil
    end
    for i,sp in ipairs(questData.progress_ser) do
        if sp.finish ~= 1 then
            return sp
        end
    end
    return nil
end

-- 获取当前进行中的目标名
-- 通用全部
function QuestManager:GetCurrentTargetId(questData)
    local cps = quest.progress
    local sps = quest.progress_ser
    local sec_type = questData.sec_type
    if cps == nil and sps == nil then
        return nil
    end
    if #cp == 0 then
        local npcData = DataUnit.data_unit[questData.npc_commit]
        if npcData ~= nil then
            return npcData.name
        end
        return ""
    end
    for i,cp in ipairs(cps) do
        sp = sps[i]
        if cp.cli_label == QuestEumn.CliLabel.gain then
            local itemData = DataItem.data_get[sp.target]
            if itemData ~= nil then
                return itemData.name
            end
            return ""
        elseif cp.cli_label == QuestEumn.CliLabel.catchpet then
            local petData = DataPet.data_pet[sp.target]
            if petData ~= nil then
                return petData.name
            end
            return ""
        elseif cp.cli_label == QuestEumn.CliLabel.fight then
            local npcData = DataUnit.data_unit[sp.target]
            if npcData ~= nil then
                return npcData.name
            end
            return ""
        end
    end
    return ""
end

function QuestManager:GetChainFightTarget(questData)
    for i,sp in ipairs(questData.progress_ser) do
        local cp = questData.progress[i]
        if cp.cli_label == QuestEumn.CliLabel.fight then
            for i,v in ipairs(sp.ext_data) do
                if v.key == QuestEumn.ExtType.TargetNpcId then
                    return v.value
                end
            end
        end
    end
    return nil
end

--获取任务需求物品的id列表
-- type = 1 道具
-- type = 2 宠物
function QuestManager:GetItemTarget()
    local item_target_list = {}
    for id,quest in pairs(self.questTab) do
        if quest.finish == QuestEumn.TaskStatus.Doing and quest.lev <= RoleManager.Instance.RoleData.lev then
            --只返回进行中的任务的所需物品
            local cps = quest.progress
            local sps = quest.progress_ser
            if cps == nil and sps == nil then
                return
            end
            for i,cp in ipairs(cps) do
                local sp = sps[i]
                if cp.cli_label == QuestEumn.CliLabel.gain then
                    table.insert(item_target_list, {type = 1, id = sp.target, num = sp.target_val})
                elseif cp.cli_label == QuestEumn.CliLabel.catchpet then
                    table.insert(item_target_list, {type = 2, id = sp.target, num = sp.target_val})
                end
            end
        end
    end
    return item_target_list
end

function QuestManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function QuestManager:OpenDramaWindow(args)
    self.model:OpenDramaWindow(args)
end

function QuestManager:GetQuestContent(questData)
    local content = ""
    local len = #questData.progress
    local isfight = false
    local isItem = false
    local ccount = 0
    if #questData.progress == 0 then
        local npc = ""
        if questData.trace_msg ~= "" then
            content = questData.trace_msg
        else
            if questData.finish == QuestEumn.TaskStatus.CanAccept then--可接
                if questData.npc_accept ~= 0 then
                    npc = DataUnit.data_unit[questData.npc_commit].name
                end
            elseif questData.finish == QuestEumn.TaskStatus.Doing then-- 进行中
                if questData.npc_commit ~= 0 then
                    npc = DataUnit.data_unit[questData.npc_commit].name
                end
            elseif questData.finish == QuestEumn.TaskStatus.Finish then -- 完成
                if questData.sec_type == QuestEumn.TaskType.chain then
                    local npcData = DataUnit.data_unit[self.chainBaseId]
                    if npcData ~= nil then
                        npc = npcData.name
                    end
                else
                    if questData.npc_commit ~= 0 then
                        npc = DataUnit.data_unit[questData.npc_commit].name
                    end
                end
            end
            content = string.format(TI18N("拜访<color='#00ff12'>%s</color>"), npc)
        end
    else
        for i,v in ipairs(questData.progress) do
            -- -- 标志某些任务内容为战斗内容
            if v.cli_label == QuestEumn.CliLabel.fight or v.cli_label == QuestEumn.CliLabel.patrol then
                isfight = true
            elseif v.cli_label == QuestEumn.CliLabel.gain then
                isItem = true
            end
            -- 有些任务进度隐藏不显示
            if v.is_hide == 0 then
                ccount = ccount + 1
                if ccount > 1 and ccount < len then
                    -- 处理文本换行，避免多换行导致高度错误
                    content = content .. "\n"
                end
                local preval = ""
                if v.target_val > 1 then
                    preval = string.format("<color='#00ff12'>(%d/%d)</color>", (questData.progress_ser ~= nil and questData.progress_ser[i] ~= nil) and questData.progress_ser[i].value or 0, v.target_val)
                end
                if v.desc == nil or v.desc == "[]" then
                    local target_id = v.target
                    if questData.progress_ser ~= nil and questData.progress_ser[i] ~= nil then
                        target_id = questData.progress_ser[i].target
                    end
                    local tar_name = QuestManager.Instance:GetTargetByLabel(v.cli_label, target_id)
                    if v.cli_label == QuestEumn.CliLabel.catchpet or v.cli_label == QuestEumn.CliLabel.gain then
                        local npcName = ""
                        if questData.sec_type == QuestEumn.TaskType.chain then
                            local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                            if npcData ~= nil then
                                npcName = npcData.name
                            end
                        else
                            if questData.npc_commit ~= 0 then
                                npcName = DataUnit.data_unit[questData.npc_commit].name
                            end
                        end
                        local ss = string.format(QuestEumn.RequireName[v.cli_label], npcName, tar_name)
                        content = content .. string.format("%s%s", ss, preval)
                    elseif v.cli_label == QuestEumn.CliLabel.protest then
                        local tar_name = QuestManager.Instance.target_name
                        if tar_name == "" then
                            tar_name = TI18N("坏蛋")
                        end
                        local ss = string.format(QuestEumn.RequireName[v.cli_label], tar_name)
                        content = content .. string.format("%s%s", ss, preval)
                    else
                        content = content .. string.format("%s<color='#00ff12'>%s</color>%s", QuestEumn.RequireName[v.cli_label], tar_name, preval)
                    end
                else
                    content = content .. string.format("%s%s", StringHelper.MatchBetweenSymbols(v.desc, "%[", "%]")[1], preval)
                end
            end
        end
    end
    if isItem and questData.sec_type == QuestEumn.TaskType.chain then
        local mapName = QuestManager.Instance:GetHangupMapName()
        if mapName ~= nil then
            content = content .."\n"..string.format(TI18N("购买或击败<color='#ffff00'>%s</color>内的怪物可获得"), mapName)
        end
    end
    return content
end

-- 根据当前人物等级获取相应的挂野场景
function QuestManager:GetHangupMapName()
    local lev = RoleManager.Instance.RoleData.lev
    for i = DataHangup.data_list_length, 1, -1 do
        local v = DataHangup.data_list[i]
        if lev >= v.min_lev and lev <= v.max_lev then
            return v.name
        end
    end
    return nil
end

function QuestManager:GiveUp(questData)
    if questData == nil then
        return
    end

    local sureGiveup = function()
        self:Send10205(questData.id)
    end

    if questData.sec_type == QuestEumn.TaskType.chain then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("每周只可领取一次历练环任务，是否放弃历练环任务<color='#ffff00'>（放弃上周未完成的历练任务不影响本周接取）</color>")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = sureGiveup
        NoticeManager.Instance:ConfirmTips(data)
    else
        sureGiveup()
    end
end

function QuestManager:OnLevelupCheckFollow()
    local lev = RoleManager.Instance.RoleData.lev
    local questList = QuestManager.Instance.questTab
    local questBase = DataQuest.data_get
    for _,quest in pairs(questList) do
        if questList[quest.id] ~= nil and lev == quest.follow_lev then
            questList[quest.id].follow = questBase[quest.id].follow
            MainUIManager.Instance:HideOrShowQuest(quest.id, questList[quest.id].follow == 1)
        end
    end
end

function QuestManager:CheckDefaultFollow(questIds)
    local list = nil
    if questIds == nil or #questIds == 0 then
        questIds = {}
        for k,_ in pairs(self.questTab) do
            table.insert(questIds, k)
        end
        list = {}
    else
        list = BaseUtils.copytab(questIds)
    end
    local pre_quest_id = nil
    local lev = RoleManager.Instance.RoleData.lev
    local break_time = RoleManager.Instance.RoleData.lev_break_times
    for _,id in pairs(questIds) do
        local quest = DataQuest.data_get[id]
        if self.questTab[id] ~= nil then
            pre_quest_id = DataQuest.data_get[quest.id].pre_quest_client
            if pre_quest_id == nil then
                pre_quest_id = 0
            end

            local origin_follow = self.questTab[id].follow

            if quest.follow == 1 and quest.follow_lev <= lev and quest.find_break_lev <= break_time and (DataQuest.data_get[pre_quest_id] == nil or self.questTab[pre_quest_id] == nil) then
                self.questTab[id].follow = 1
            else
                self.questTab[id].follow = 0
            end

            if id == 41012 and RoleManager.Instance.world_lev < 45 then
                self.questTab[id].follow = 0
            end

            if origin_follow ~= self.questTab[id].follow then
                table.insert(list, id)
            end
        end
    end
    return list
end

function QuestManager:CheckAddPlantTips()
    local questData = self:GetQuestByType(QuestEumn.TaskType.plant)
    if questData == nil and self.plantData ~= nil and self.plantData.phase ~= 0 then
        self:AddPlantTips()
    else
        self:RemovePlantTips()
    end
end

-- 添加植树提示追踪
function QuestManager:AddPlantTips()
    if self.plantNoticeItem == nil then
        self.plantNoticeItem = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()
        self.plantNoticeItem.type = CustomTraceEunm.Type.Activity
        self.plantNoticeItem.title = string.format(TI18N("<color='%s'>[植树]等待</color>"), QuestEumn.ColorName(QuestEumn.TaskType.plant))
        self.plantNoticeItem.Desc = TI18N("等待祈福之树快快成长")
        local key = BaseUtils.get_unique_npcid(QuestManager.Instance.plantData.unit_id, 0)
        self.plantNoticeItem.callback = function() self.model:FindNpc(key) end
        MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.plantNoticeItem)
    end
end

-- 删除植树提示
function QuestManager:RemovePlantTips()
    if self.plantNoticeItem ~= nil then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.plantNoticeItem.customId)
        self.plantNoticeItem = nil
    end
end

-- 自动历练和自动职业任务
-- 开宝箱时向服务器发送10255
function QuestManager:Send10255(order,times)
    -- print(string.format("10255, %s, %s", order,times))
    self:Send(10255,{order = order,times = times})
end

function QuestManager:On10255(dat)
    -- BaseUtils.dump(dat, "On10255")
    self:Notice(dat.msg)
end

-- 开宝箱的结果由10256携带回客户端
-- 一般客户端不会发送10256，只负责接收10256
function QuestManager:Send10256()
    self:Send(10256,{})
end

function QuestManager:On10256(dat)
    -- BaseUtils.dump(dat, "On10256")

    if dat.order == 0 then
        if AutoQuestManager.Instance.model.chainTreasureWindow == nil then
            AutoQuestManager.Instance.model:OpenChainTreasureWindow()
        else
            AutoQuestManager.Instance.model:OpenChainTreasureWindow()
            AutoQuestManager.Instance.model.chainTreasureWindow:Reset()
        end
        AutoQuestManager.Instance.model.lockAuto = false
    else
        if AutoQuestManager.Instance.model.chainTreasureWindow ~= nil then
            AutoQuestManager.Instance.model.chainTreasureWindow:ShowBox(dat.order,dat.gain_list[1])
        end
    end

    -- 停止自动历练 -- inserted by 嘉俊
    if AutoQuestManager.Instance.model.isOpen then
        print("开宝箱导致自动停止")
        AutoQuestManager.Instance.disabledAutoQuest:Fire()
    end
    -- end by嘉俊
end
