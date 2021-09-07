-- @author 111
-- @date 2018年3月13日,星期二

AprilTreasureManager = AprilTreasureManager or BaseClass(BaseManager)

function AprilTreasureManager:__init()
    if AprilTreasureManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    AprilTreasureManager.Instance = self

    self:InitHandler()

    self.model = AprilTreasureModel.New()

    self.OnAprilDataUpdate = EventLib.New()
    self.OnFirstDataUpdate = EventLib.New()

    self.OnEventIdUpdate = EventLib.New()
    self.OnLuckyNumUpdate = EventLib.New()

    self.checkQuestFunc = function(list)
        self:checkQuest(list)
    end

    self.OnRecordUpdate = EventLib.New()
    self.onMsgEvent = EventLib.New()


    EventMgr.Instance:AddListener(event_name.quest_update,self.checkQuestFunc)

end

function AprilTreasureManager:__delete()
    EventMgr.Instance:RemoveListener(event_name.quest_update,self.checkQuestFunc)
end

function AprilTreasureManager:InitHandler()
    self:AddNetHandler(20444,self.on20444)   --推送大富翁数据
    self:AddNetHandler(20445,self.on20445)   --投掷骰子
    self:AddNetHandler(20446,self.on20446)   --投掷幸运骰子
    self:AddNetHandler(20447,self.on20447)   --触发大富翁事件
    self:AddNetHandler(20448,self.on20448)   --领取轮回奖励
    self:AddNetHandler(20449,self.on20449)   --大富翁获奖记录
    self:AddNetHandler(20450,self.on20450)   --大富翁数据信息（初始请求基础信息）
end

function AprilTreasureManager:RequestInitData()
    self:send20450()    --用于红点检测
end

--推送大富翁数据
function AprilTreasureManager:send20444()
    --print("--------20444协议数据---------")
    Connection.Instance:send(20444, {})
end
function AprilTreasureManager:on20444(data)
    --print("收到20444协议数据")
    --BaseUtils.dump(data,"on20444")
    local Querdata = data
    --self.model.DaliyDrawTimes = Querdata.times  --设置今日已投掷次数
    self.model.FreeLuckyDice = Querdata.lucky_dice  --可使用的幸运骰子数 （先存起来 事件触发时再设置）
    --self.model.CurrEvent = Querdata.event_id
    self.model.TurnTimes = Querdata.ring_times    --设置轮回次数
    for i,v in pairs(Querdata.ring_rewards) do
        table.insert(self.model.ReceivedTurnTimes, v)
    end
    if Querdata.event_id ~= nil and Querdata.event_id ~= 0 then
        self.OnAprilDataUpdate:Fire(Querdata)
        self.model.CurrReward = { }
        --根据 当前事件id 取奖励
        local rewards = DataZillionaireData.data_get_event[Querdata.event_id].rewards
        if rewards ~= nil and next(rewards) ~= nil then
            for i,v in pairs(rewards) do
                local item = { }
                item.item_id = v[1]
                item.val = v[2]
                table.insert(self.model.CurrReward, item)
            end
        end
        BaseUtils.dump(self.model.CurrReward,"self.model.CurrReward")

        self.model:AppendlHistory(Querdata.event_id)
    end
end

--投掷骰子
function AprilTreasureManager:send20445()
    --print("--------20445协议数据---------")
    Connection.Instance:send(20445, {})

    self.rollpMark = true
end
function AprilTreasureManager:on20445(data)
    --print("收到20445协议数据")
    local Querdata = data
    --BaseUtils.dump(data,"on20445")
    NoticeManager.Instance:FloatTipsByString(Querdata.msg)

    -- if Querdata.flag == 1 then
    --     self.model.CurrEvent =data.event_id
    --     if next(data.items) ~= nil then
    --         self.model.CurrReward = { }
    --         for i,v in pairs(data.items) do
    --             table.insert(self.model.CurrReward, v)
    --         end
    --     end

    -- end
    if Querdata.flag == 2 then
        self:send20447(1)
    end
end

--投掷幸运骰子
function AprilTreasureManager:send20446(data)
    --print("--------20446协议数据---------")
    Connection.Instance:send(20446, {result = data})

    self.rollpMark = true
    self.luckyRollpMark = true
end
function AprilTreasureManager:on20446(data)
    --print("收到20446协议数据")
    --BaseUtils.dump(data,"on20446")
    local Querdata = data
    if data.flag == 1 then
        self.OnLuckyNumUpdate:Fire()
    end
end

--触发大富翁事件
function AprilTreasureManager:send20447(data)
    --print("--------20447协议数据---------")
    Connection.Instance:send(20447, {flag = data})
end
function AprilTreasureManager:on20447(data)
    --print("收到20447协议数据")
    --BaseUtils.dump(data,"on20447")
    local Querdata = data
    if Querdata.flag == 1 and Querdata.event_id ~= 0 then
        self.OnEventIdUpdate:Fire(Querdata.event_id)
        self.model.CurrEvent = Querdata.event_id
    end
end

--领取轮回奖励
function AprilTreasureManager:send20448(data)
    --print("--------20448协议数据---------")
    Connection.Instance:send(20448, {ring_times = data})
end
function AprilTreasureManager:on20448(data)
    --print("收到20448协议数据")
    --BaseUtils.dump(data,"on20448")
end

--大富翁获奖记录
function AprilTreasureManager:send20449()
    --print("--------20449协议数据---------")
    Connection.Instance:send(20449, {})
end
function AprilTreasureManager:on20449(data)
    --print("收到20449协议数据")
    --BaseUtils.dump(data,"on20449")
    local Querdata = data.camp_zillionaire_event
    self.model:GenerateNormalHistory(Querdata)
end

--大富翁数据信息（初始请求基础信息）
function AprilTreasureManager:send20450()
    --print("--------20450协议数据---------")
    Connection.Instance:send(20450, {})
end
function AprilTreasureManager:on20450(data)
    --print("收到20450协议数据")
    --BaseUtils.dump(data,"on20450")
    local Querdata = data
    if self.model.CurrPos == -1 then
        self.model.CurrPos = Querdata.grid_index   --设置当前所在格子数据
    end
    --self.model.DaliyDrawTimes = Querdata.times  --设置今日已投掷次数
    self.model.FreeLuckyDice = Querdata.lucky_dice  --可使用的幸运骰子数 （先存起来 事件触发时再设置）
    self.model.TurnTimes = Querdata.ring_times    --设置轮回次数
    self.model.ReceivedTurnTimes = { }        --设置已领取的轮回列表
    if Querdata.ring_rewards ~= nil then
        for i,v in pairs(Querdata.ring_rewards) do
            table.insert(self.model.ReceivedTurnTimes, v)
        end
    end
    self.OnFirstDataUpdate:Fire(Querdata)
end

--  {uint8, grid_index, "当前所在格子"}
-- ,{uint32, times, "今日已经投掷次数"}
-- ,{uint8, lucky_dice, "幸运骰子次数"}
-- ,{uint32, ring_times, "轮回次数"}
-- ,{array, single, ring_rewards, "已经领取的轮回次数", [
--     {uint32, times, "次数"}

function AprilTreasureManager:checkQuest(list)
    --BaseUtils.dump(list,"777777777777777777777777")
    --BaseUtils.dump(QuestManager.Instance.questTab)
    local hasGuild = false
    local questId = 0
    for k,v in pairs(list) do
        if DataQuest.data_get[v].sec_type == QuestEumn.TaskType.april_treasure then
            questId = DataQuest.data_get[v].id
            hasGuild = true
            break
        end
    end
    if hasGuild == true then
        local data = DataQuest.data_get[questId]
        local questData = QuestManager.Instance:GetQuest(data.id)
        if questData ~= nil and questData.finish == 2 then
            --领取任务 已完成
            print("完成任务la"..questId)
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Sure
            local desc = ""
            if #DataQuest.data_get[questId].progress > 0 then
                --desc = DataQuest.data_get[questId].progress[1].desc
                if questId == 83698 then
                    --会长的
                    desc = "谢谢你的赞美，<color='#ffff00'>会长</color>听到后十分开心，并赠送一份小礼物，请查收{face_1,10}"
                else
                    desc = "恭喜你达成<color='#ffff00'>欢乐寻宝</color>特殊事件，一份小礼物发放给你，请查收{face_1,10}"
                end
            end

            --data.content = string.format(TI18N(desc))
            data.content = TI18N(desc)
            data.sureLabel = TI18N("确认")
            data.sureCallback = function()
                QuestManager.Instance:DoQuest(QuestManager.Instance:GetQuest(questId))
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
                --QuestManager.Instance:Send10206(questId)
            end
            NoticeManager.Instance:ConfirmTips(data)
        end
    end
end

function AprilTreasureManager:HasQuest()
    for k,v in pairs(QuestManager.Instance.questTab) do
        if v.sec_type == 33 then
            return true
        end
    end
    return false
end
