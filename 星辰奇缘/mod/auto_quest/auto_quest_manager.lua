-- 目前主要是用来实现自动跑历练环和自动做职业任务
-- @郑嘉俊
AutoQuestManager = AutoQuestManager or BaseClass(BaseManager)

function AutoQuestManager:__init()
    if AutoQuestManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    AutoQuestManager.Instance = self

    self.autoQuest = EventLib.New()
    self.disabledAutoQuest = EventLib.New()

    self.updateAutoTagOfChain = EventLib.New()
    self.updateAutoTagOfCycle = EventLib.New()

    -- inserted by 嘉俊 497163788@qq.com
    self.hasTreasureOfChain = 0
    self.indexOfChosenBox = 0 -- 玩家所选择的历练环宝箱
    -- end by 嘉俊

    self.model = AutoQuestModel.New()

end

function AutoQuestManager:__delete()
    if self.autoQuest ~= nil then
        self.autoQuest:DeleteMe()
        self.autoQuest = nil
    end
    if self.disabledAutoQuest ~= nil then
        self.disabledQuest:DeleteMe()
        self.disabledQuest = nil
    end
    if updateAutoTagOfChain ~= nil then
        self.updateAutoTagOfChain:DeleteMe()
        self.updateAutoTagOfChain = nil
    end
    if updateAutoTagOfCycle ~= nil then
        self.updateAutoTagOfCycle:DeleteMe()
        self.updateAutoTagOfCycle = nil
    end
end











