LuckeyChestManager = LuckeyChestManager or BaseClass(BaseManager)

function LuckeyChestManager:__init()
    if LuckeyChestManager.Instance then
        Log.Error("MarketManager 不能重复实例化")
        return
    end

    LuckeyChestManager.Instance = self
    self.model = LuckeyChestModel.New()

    self.backpackItemChange = function() self:BackpackItemChange() end

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.backpackItemChange)
end

function LuckeyChestManager:__delete()
end

function LuckeyChestManager:AddListener()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.backpackItemChange)
end

function LuckeyChestManager:RemoveListener()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackItemChange)
end

function LuckeyChestManager:BackpackItemChange()
    NewYearManager.Instance:CheckLuckeyChestRedPoint()
end

function LuckeyChestManager:OpenWindow(args)
    self.model:OpenWindow(args)
end