-- ---------------------
-- 快速使用数据
-- hosr
-- ---------------------
AutoUseData = AutoUseData or BaseClass()

function AutoUseData:__init()
    self.title = TI18N("获得物品")
    self.label = TI18N("使用")
    self.callback = nil
    self.closeCallback = nil
    self.itemData = nil

    self.preData = nil
    self.afterData = nil

    self.inChain = false
end

function AutoUseData:__delete()
    self:ChainBreakage()
end

function AutoUseData:ChainBreakage()
    if self.preData ~= nil then
        self.preData.afterData = self.afterData
    end
    if self.afterData ~= nil then
        self.afterData.preData = self.preData
    end
    self.preData = nil
    self.afterData = nil
    self.inChain = false
end

