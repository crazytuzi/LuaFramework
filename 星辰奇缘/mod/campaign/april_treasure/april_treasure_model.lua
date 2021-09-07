-- @author 111
-- @date 2018年3月13日,星期二

AprilTreasureModel = AprilTreasureModel or BaseClass(BaseModel)

function AprilTreasureModel:__init()
    self.CurrPos = -1      --初始位置
    --self.DaliyDrawTimes = 0  --今日已投掷次数
    self.FreeLuckyDice = 0  --可使用的幸运骰子 数量
    self.TurnTimes = 0     --已轮回次数
    self.ReceivedTurnTimes = { }   --已领取的轮回次数列表

    self.history = { }     --获奖记录

    self.CurrEvent = 1   --(0.闲置 1.货币格 2.道具格 3.移动格 4 幸运骰子格 5 事件格)
    self.CurrReward = {{item_id = 90000, val = 1000},{item_id = 90005, val = 1} }  --每次推送的奖励列表

    self.questId = 0  --当前任务id


end

function AprilTreasureModel:__delete()
end

function AprilTreasureModel:OpenMainWindow(args)
    if self.mainWin == nil then
        self.mainWin = AprilTreasureWindow.New(self)
    end
    self.mainWin:Open(args)
end

function AprilTreasureModel:CloseMainWindow()
    WindowManager.Instance:CloseWindow(self.mainWin)
end

function AprilTreasureModel:OpenRewardWindow(args)
    if self.rewardWin == nil then
        self.rewardWin = AprilTurnRewardWindow.New(self)
    end
    self.rewardWin:Open(args)
end

function AprilTreasureModel:CloseRewardWindow()
    WindowManager.Instance:CloseWindow(self.rewardWin)
end

-- function AprilTreasureModel:OpenDicePanel(args)
--     if self.dicePanel ~= nil then
--         self.dicePanel:Close()
--     end
--     if self.dicePanel == nil then
--         self.dicePanel = AprilLuckyDicePanel.New(self)
--     end
--     self.dicePanel:Open(args)
-- end

-- function AprilTreasureModel:CloseDicePanel()
--     if self.dicePanel ~= nil then
--         self.dicePanel:DeleteMe()
--         self.dicePanel = nil
--     end
-- end

--奖励弹窗
function AprilTreasureModel:OpenGiftShow(args)
    if self.giftShow ~= nil then
        self.giftShow:Close()
    end
    if self.giftShow == nil then
        self.giftShow = BackpackGiftShow.New(self)
    end
    self.giftShow:Show(args)
end

function AprilTreasureModel:CloseGiftShow()
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
end

function AprilTreasureModel:GenerateNormalHistory(data)
    if data ~= nil then
        self.history = { }
        local eventId = 0
        for i, v in pairs(data) do
            local eventId = v.event_id
            local rewardString = ""
            for _, item in pairs(v.items) do
                rewardString = string.format("%s{item_2, %d, 0, %d}", rewardString, item.item_id, item.val)
            end
            if DataZillionaireData.data_get_event[eventId].event_type == "item" then
                --普通事件
                local str = string.format("{role_2, %s}一脚踩下去，发现脚下竟然是%s", v.name, rewardString)
                table.insert(self.history, {msg = str})
            else
                local str = string.format("{role_2, %s}在完成神秘事件时，竟获得%s", v.name, rewardString)
                table.insert(self.history, {msg = str})
            end
        end

        AprilTreasureManager.Instance.OnRecordUpdate:Fire()
    end
end

function AprilTreasureModel:AppendlHistory(event_id)
    local data_get_event = DataZillionaireData.data_get_event[event_id]
    if data_get_event ~= nil and data_get_event.is_hearsay == 1 then
        local rewards = data_get_event.rewards
        local rewardString = ""
        for i, v in pairs(rewards) do
            rewardString = string.format("%s{item_2, %d, 0, %d}", rewardString, v[1], v[2])
        end

        if DataZillionaireData.data_get_event[event_id].event_type == "item" then
            --普通事件
            local str = string.format("{role_2, %s}一脚踩下去，发现脚下竟然是%s", RoleManager.Instance.RoleData.name, rewardString)
            AprilTreasureManager.Instance.onMsgEvent:Fire(str)
        else
            local str = string.format("{role_2, %s}在完成神秘事件时，竟获得%s", RoleManager.Instance.RoleData.name, rewardString)
            AprilTreasureManager.Instance.onMsgEvent:Fire(str)
        end
    end
end
