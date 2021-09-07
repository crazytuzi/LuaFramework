-- ----------------------------------------------------------
-- 逻辑模块 - 宠物
-- ----------------------------------------------------------
AchievementManager = AchievementManager or BaseClass(BaseManager)

function AchievementManager:__init()
    if AchievementManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	AchievementManager.Instance = self

    self.newAchievementMark = false

    self.model = AchievementModel.New()

    self:InitHandler()

    self.OnUpdateList = EventLib.New()

    -----------------------------------------------------
    self.assetIdToKey = {}
    for k,v in pairs(KvData.assets) do
        self.assetIdToKey[v] = k
    end

    self.redPoint = {}

    self.onUpdateRedPoint = EventLib.New()
    self.onUpdateCurrency = EventLib.New()
    self.onUpdateBuyPanel = EventLib.New()
    self.onUpdateUnfreeze = EventLib.New()
    self.onUpdateRT = EventLib.New()

    self.onUpdateCompleteNumber = EventLib.New() -- 成就完成人数返回
end

function AchievementManager:__delete()
    self.OnUpdateList:DeleteMe()
    self.OnUpdateList = nil
end

function AchievementManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(10219, self.On10219)
    self:AddNetHandler(10220, self.On10220)
    self:AddNetHandler(10221, self.On10221)
    self:AddNetHandler(10222, self.On10222)
    self:AddNetHandler(10226, self.On10226)
    self:AddNetHandler(10227, self.On10227)
    self:AddNetHandler(10229, self.On10229)
    self:AddNetHandler(10230, self.On10230)
    self:AddNetHandler(10231, self.On10231)
    self:AddNetHandler(10232, self.On10232)
    self:AddNetHandler(10233, self.On10233)
    self:AddNetHandler(10234, self.On10234)

    self:AddNetHandler(10422, self.On10422)
    self:AddNetHandler(10423, self.On10423)
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------


function AchievementManager:Send10219()
    Connection.Instance:send(10219, { })
end

function AchievementManager:On10219(data)
    self.model:On10219(data)
end

function AchievementManager:On10220(data)
    self.model:On10220(data)
end

function AchievementManager:Send10221(id)
    Connection.Instance:send(10221, { id_list = {{ id = id }} })
end

function AchievementManager:On10221(data)
    -- self.model:On10221(data)
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end

function AchievementManager:Send10222()
    Connection.Instance:send(10222, { })
end

function AchievementManager:On10222(data)
    RoleManager.Instance.RoleData.achieve_score = data.assets_num
    self.onUpdateCurrency:Fire()
end

function AchievementManager:Send10226(shop_type)
    Connection.Instance:send(10226, { shop_type = shop_type })
end

function AchievementManager:On10226(data)
	self.model:On10226(data)
end

function AchievementManager:Send10227(id)
    Connection.Instance:send(10227, { id = id })
end

function AchievementManager:On10227(data)
    -- self.model:On10227(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function AchievementManager:Send10229(id)
    -- print("Send10229")
    Connection.Instance:send(10229, { id = id })
end

function AchievementManager:On10229(data)
    -- print("On10229")
    self.model.achievementCompleteNumber[data.id] = data
    self.model.achievementCompleteTotalNumber = data.total
    self.onUpdateCompleteNumber:Fire()
end

function AchievementManager:Send10230()
    -- print("Send10230")
    Connection.Instance:send(10230, {})
end

function AchievementManager:On10230(data)
    -- print("On10230")
    for _,value in ipairs(data.achievement_log) do
        self.model.achievementCompleteNumber[value.id] = value
    end
    self.model.achievementCompleteTotalNumber = data.total
    self.onUpdateCompleteNumber:Fire()
end

function AchievementManager:Send10231(id)
    -- print("Send10231")
    Connection.Instance:send(10231, { id = id })
end

function AchievementManager:On10231(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function AchievementManager:Send10232()
    Connection.Instance:send(10232, { })
end

function AchievementManager:On10232(data)
    -- BaseUtils.dump(data, "On10232")
    self.model.attentionList = {}
    self.model.attentionNum = 0
    for _,value in pairs(data.list) do
        self.model.attentionList[value.id] = true
        self.model.attentionNum = self.model.attentionNum + 1
    end
    self.OnUpdateList:Fire()
end

function AchievementManager:Send10233(id, platform, zone_id)
    Connection.Instance:send(10233, { id = id, platform = platform, zone_id = zone_id })
end

function AchievementManager:On10233(data)
    self.model:OpenAchievementBadgeTips({data})
end

function AchievementManager:Send10234(id)
    -- print("Send10234")
    Connection.Instance:send(10234, { id = id })
end

function AchievementManager:On10234(data)
    -- print("On10234")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function AchievementManager:Send10422(id)
    -- print("Send10422")
    Connection.Instance:send(10422, { id = id })
end

function AchievementManager:On10422(data)
    -- print("On10422")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function AchievementManager:Send10423(type)
    -- print("Send10423")
    Connection.Instance:send(10423, { type = type })
end

function AchievementManager:On10423(data)
    --BaseUtils.dump(data,"on10423")
    if data.type == 6 then
        ChatManager.Instance.model.prefix_id = data.id
        AchievementManager.Instance.onUpdateBuyPanel:Fire()
    elseif data.type == 8 then
        RoleManager.Instance.foot_mark_id = data.id
        AchievementManager.Instance.onUpdateBuyPanel:Fire()
    else
        
    end
end
-------------------------------------------
-------------------------------------------
------------- 逻辑处理 -----------------
-------------------------------------------
-------------------------------------------

function AchievementManager:RequestInitData()
    self:Send10219()
    self:Send10222()
    self:Send10230()
    self:Send10232()

    self:Send10423(6)

    for i=1, 8 do
        self:Send10226(i)
    end
    ChatManager.Instance:Send10416()

    self.newAchievementMark = false
    self.newAchievementTime = 0
end

function AchievementManager:OnTick()
    if self.newAchievementMark then
        if BaseUtils.BASE_TIME - self.newAchievementTime > 1 then
            self.newAchievementMark = false

            self.model:countStar()
            self.model:getRedPoint()
            self.model:makeAllAchievement()
            self.model:makeProgress()
            self.OnUpdateList:Fire()
        end
    end
end