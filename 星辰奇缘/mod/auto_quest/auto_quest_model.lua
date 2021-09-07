-- 目前主要是用来实现自动跑历练环和自动做职业任务
-- @郑嘉俊
AutoQuestModel = AutoQuestModel or BaseClass(BaseModel)

function AutoQuestModel:__init()

    self.mgr = AutoQuestManager.Instance
    self.isOpen = false
    self.currentTaskType = nil
    self.timer = nil -- 用来定时执行找NPC
    self.timerForNpcShopWindow = nil -- 当打开NPC商店的时候也会有个延时的定时器
    self.str = {"历练环","职业任务"}

    self.autoTag = nil -- 主要用来处理自动戳的显示和隐藏

    -- inserted by 嘉俊 497163788@qq.com
    self.hasTreasureOfChain = 0
    self.indexOfChosenBox = 1 -- 玩家所选择的历练环宝箱
    self.lockAuto = false

    self.lockSecondBuy = false -- 防止自动时多次购买

    -- end by 嘉俊

    self.autoQuestListener = function () self:AutoQuest() end
    self.disabledAutoQuestListener = function () self:DisabledAutoQuest() end
    self.mgr.autoQuest:AddListener(self.autoQuestListener)
    self.mgr.disabledAutoQuest:AddListener(self.disabledAutoQuestListener)

    EventMgr.Instance:AddListener(event_name.team_update, function() self:OnTeamUpdate() end)
end

function AutoQuestModel:__delete()
    self.isOpen = nil
    self.currentTaskType = nil
    self.timer = nil
    self.str = nil

end

function AutoQuestModel:AutoQuestSetting(taskType)
    self.currentTaskType = taskType
end

function AutoQuestModel:AutoQuest()
    --NoticeManager.Instance:FloatTipsByString(TI18N(self.str[self.currentTaskType].."自动功能开启"))
    self.isOpen = true
    if self.timer == nil then
        self.timer = LuaTimer.Add(0, 3000, function()
        if not self.isOpen then
            return false
        end
        --print("*************************Now is in auto mode***********************")
        MainUIManager.Instance.dialogModel:Hide()
        if (TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None) and (CombatManager.Instance.isFighting or SceneManager.Instance.sceneElementsModel.autopath_data ~= nil) then
            if (self.currentTaskType == 1) then
                self.mgr.updateAutoTagOfChain:Fire()
            elseif (self.currentTaskType == 2) then
                self.mgr.updateAutoTagOfCycle:Fire()
            end
        else
            if (self.currentTaskType == 1) then
                self.mgr.updateAutoTagOfChain:Fire()
                QuestManager.Instance.model:DoChain()
            elseif (self.currentTaskType == 2) then
                self.mgr.updateAutoTagOfCycle:Fire()
                QuestManager.Instance.model:DoCycle()
            end
        end
        end)
    end
end

function AutoQuestModel:DisabledAutoQuest()
    --NoticeManager.Instance:FloatTipsByString(TI18N(self.str[self.currentTaskType].."自动功能关闭"))
    self.isOpen = false

    MainUIManager.Instance.dialogModel:Hide()

    self.lockSecondBuy = false -- 解开多次购买的锁

    if self.currentTaskType == 1 then
        self.mgr.updateAutoTagOfChain:Fire()
    else
        self.mgr.updateAutoTagOfCycle:Fire()
    end

    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
end

function AutoQuestModel:OnTeamUpdate()
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
        AutoQuestManager.Instance.disabledAutoQuest:Fire()
    end
end

function AutoQuestModel:OpenChainTreasureWindow()
    if self.chainTreasureWindow == nil then
        self.chainTreasureWindow = ChainTreasureWindow.New(self)
    end
    self.chainTreasureWindow:Open()
end

function AutoQuestModel:CloseChainTreasureWindow()
    if self.chainTreasureWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.chainTreasureWindow)
    end
end

function AutoQuestModel:OpenAutoModeSelectWindow() -- 嘉俊 2017/8/28 17:02
    if self.autoModeSelectWindow == nil then
        self.autoModeSelectWindow = AutoModeSelectWindow.New(self)
    end
    self.autoModeSelectWindow:Open()
end

function AutoQuestModel:CloseAutoModeSelectWindow() -- by 嘉俊 2017/8/28 17:02
    if self.autoModeSelectWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.autoModeSelectWindow)
    end
end


