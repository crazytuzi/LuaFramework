-- ---------------------------------
-- 道具管理
-- ---------------------------------
BackpackManager = BackpackManager or BaseClass(BaseManager)

function BackpackManager:__init()
    if BackpackManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    BackpackManager.Instance = self
    self:InitHandler()

    self.mainModel = BackpackModel.New()

    self.storeModel = StoreModel.New() --道具仓库

    self.selectItemModel = SelectItemModel.New() --选择道具


    --以道具背包ID做key
    self.itemDic = {}
    self.equipDic = {}
    self.storeDic = {} --仓库物品
    self.homeStoreDic = {} --仓库物品

    self.volumeOfItem = 0 -- 背包容量
    self.volumeOfStorage = 0 --仓库容量
    self.volumeOfHomeStorage = 0 --家园仓库容量

    -- 背包已扩充次数
    self.openedCount = 0

    self.posDic = {}

    self:TempLoad()

    self.slotMom = nil

    -- 需要快速使用但等级不够的先放在
    self.autoList = {}

    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:OnLevelChange() end)
    EventMgr.Instance:AddListener(event_name.self_loaded, function() self:OnSelfLoad() end)

    self.refreshCount = 0
    self.refreshId = 0

    self.autoUseCallback = function(item)
        if item ~= nil and self.itemDic[item.id] ~= nil then
            self:Use(item.id, item.quantity, item.base_id)
        end
    end

    -- 需要重新刷新背包道具标志
    self.needReloadGirdItem = false
    -- 需要重新刷新仓库道具标志
    self.needReloadStoreItem = false
    -- 需要重新刷新家园仓库道具标志
    self.needReloadHomeStoreItem = false

    self.ItemSlotPool = {}

    self.specialItemList = {
      [1] = "40级极品装备",
      [2] = "50级极品装备",
      [3] = "60级极品装备",
      [4] = "70级极品装备",
    }

    self.isFirstInit = false

    -- self.checkSpecialItem = function(data) self:CheckBestItem(data) end
    -- EventMgr.Instance:AddListener(event_name.backpack_item_change,self.checkSpecialItem)
end

function BackpackManager:__delete()
    if self.mainModel ~= nil then
        self.mainModel:DeleteMe()
        self.mainModel = nil
    end
end

function BackpackManager:InitHandler()
    self:AddNetHandler(10300, self.On10300)
    self:AddNetHandler(10301, self.On10301)
    self:AddNetHandler(10302, self.On10302)
    self:AddNetHandler(10303, self.On10303)
    self:AddNetHandler(10310, self.On10310)
    self:AddNetHandler(10311, self.On10311)
    self:AddNetHandler(10312, self.On10312)
    self:AddNetHandler(10315, self.On10315)
    self:AddNetHandler(10316, self.On10316)
    self:AddNetHandler(10317, self.On10317)
    self:AddNetHandler(10318, self.On10318)
    self:AddNetHandler(10319, self.On10319)
    self:AddNetHandler(10320, self.On10320)
    self:AddNetHandler(10321, self.On10321)
    self:AddNetHandler(10322, self.On10322)
    self:AddNetHandler(10323, self.On10323)
    self:AddNetHandler(10324, self.On10324)
    self:AddNetHandler(10329, self.On10329)
    self:AddNetHandler(10330, self.On10330)
    self:AddNetHandler(10331, self.On10331)
    self:AddNetHandler(10332, self.On10332)
    self:AddNetHandler(10334, self.On10334)
    self:AddNetHandler(10335, self.On10335)
    self:AddNetHandler(10336, self.On10336)
    self:AddNetHandler(10338, self.On10338)
    self:AddNetHandler(10339, self.On10339)
    self:AddNetHandler(10340, self.On10340)
end

-- ---------------------
-- 发送协议
-- ---------------------
function BackpackManager:Send10300(data)
    self:Send(10300, data)
end

function BackpackManager:Send10301(data)
    self:Send(10301, data)
end

function BackpackManager:Send10302(data)
    self:Send(10302, data)
end

function BackpackManager:Send10310(data)
    self:Send(10310, data)
end

function BackpackManager:Send10311(data)
    self:Send(10311, data)
end

function BackpackManager:Send10312(data)
    self:Send(10312, data)
end

function BackpackManager:Send10315(_id, _quantity)
    print("发送协议" .. _id .. ":" .. _quantity)
    if self.itemDic[_id] ~= nil and self.autoDataTab[self.itemDic[_id].base_id] ~= nil then
        self.autoDataTab[self.itemDic[_id].base_id]:DeleteMe()
        self.autoDataTab[self.itemDic[_id].base_id] = nil
    end
    self:Send(10315, {id = _id, quantity = _quantity, args = {}})
end

function BackpackManager:Send10316(data)
    self:Send(10316, data)
end

function BackpackManager:Send10317(data)
    self:Send(10317, data)
end

function BackpackManager:Send10318(data)
    self:Send(10318, data)
end

function BackpackManager:Send10319(data)
    self:Send(10319, data)
end

function BackpackManager:Send10320(data)
    self:Send(10320, data)
end
--整理背包
function BackpackManager:Send10321(data)
    if self.refreshCount > 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s秒后才能再次整理"), self.refreshCount))
        return
    end
    self:Send(10321, data)
end
--整理仓库
function BackpackManager:Send10322(data)
    self:Send(10322, data)
end

function BackpackManager:Send10323(data)
    self:Send(10323, data)
end

function BackpackManager:Send10324(data)
    self:Send(10324, data)
end

function BackpackManager:Send10329(data)
    -- BaseUtils.dump(data,"Send10329")
    self:Send(10329, data)
end

function BackpackManager:Send10330(data)
    -- BaseUtils.dump(data,"Send10330")
    self:Send(10330, data)
end

-- 开通背包格子次数
function BackpackManager:Send10331()
    self:Send(10331, {})
end

-- ---------------------
-- 协议接收
-- ---------------------
function BackpackManager:AddItem(proto, IsEquip)
    local item = ItemData.New()
    item:SetProto(proto, IsEquip)
    local base = self:GetItemBase(proto.base_id)
    item:SetBase(base)
    return item
end

--获取背包物品
function BackpackManager:On10300(data)
    --BaseUtils.dump(data,"xxxxxxxxxxxxxxxxxxxxxxxxxx")
    local items = {}
    self.volumeOfItem = data.volume
    for _,proto in ipairs(data.item_list) do
        self.itemDic[proto.id] = self:AddItem(proto)
        self.posDic[proto.pos] = proto.id
        table.insert(items, {id = proto.id, pos = proto.pos})
    end

    EventMgr.Instance:Fire(event_name.backpack_item_change, items)
    self.needReloadGirdItem = false

    items = nil
end
--获取仓库物品
function BackpackManager:On10301(data)
    local stores = {}

    self.volumeOfStorage = data.volume
    for _,proto in ipairs(data.item_list) do
        self.storeDic[proto.id] = self:AddItem(proto)
        table.insert(stores, {id = proto.id, pos = proto.pos})
    end

    EventMgr.Instance:Fire(event_name.store_item_change, stores)
    self.needReloadStoreItem = false

    stores = nil
end

--获取装备
function BackpackManager:On10302(data)
    -- BaseUtils.dump(data, "On10302")
    local equips = {}

    for _,proto in ipairs(data.item_list) do
        self.equipDic[proto.id] = self:AddItem(proto, true)
        table.insert(equips, {id = proto.id, pos = proto.pos})
    end

    EventMgr.Instance:Fire(event_name.equip_item_change, equips)

    equips = nil
end

--增加物品通知
function BackpackManager:On10310(data)
    -- BaseUtils.dump(data, "增加物品通知")
    local items = {}
    local equips = {}
    local stores = {}
    local homeStores = {}
    self.autoDataTab = self.autoDataTab or {}
    for _,proto in ipairs(data.item_list) do
        if proto.storage == BackpackEumn.StorageType.Backpack then --背包
            self.mainModel.newItemTab[proto.id] = 1
            table.insert(items, {id = proto.id, pos = proto.pos})
            local newItem = self:AddItem(proto)
            if newItem.base_id == 23807 then -- 子女商店那边买了天地灵种要关闭那个商店只能这里检查了
                MidAutumnFestivalManager.Instance.model:CloseExchange()
            elseif (newItem.base_id == 23801 or newItem.base_id == 23802 or newItem.base_id == 23803) and (QuestManager.Instance:GetQuest(83026) ~= nil or QuestManager.Instance:GetQuest(83020) ~= nil) then
                MidAutumnFestivalManager.Instance.model:CloseExchange()
            end
            self.itemDic[proto.id] = newItem
            self.posDic[proto.pos] = proto.id
            if DataItem.data_notice[newItem.base_id] ~= nil then
                if RoleManager.Instance.RoleData.lev >= newItem.lev  then
                    if (newItem.base_id == 23801 or newItem.base_id == 23802 or newItem.base_id == 23803) and not (QuestManager.Instance:GetQuest(83026) ~= nil or QuestManager.Instance:GetQuest(83020) ~= nil) then
                        if self.autoDataTab[newItem.base_id] ~= nil then
                            self.autoDataTab[newItem.base_id]:DeleteMe()
                            self.autoDataTab[newItem.base_id] = nil
                        end
                        table.insert(self.autoList, newItem)
                    else
                        local autoData = self.autoDataTab[newItem.base_id]
                        if autoData == nil or autoData.inChain ~= true then
                            autoData = AutoUseData.New()
                            self.autoDataTab[newItem.base_id] = autoData
                        end
                        autoData.callback = function() self.autoUseCallback(newItem) end
                        autoData.itemData = newItem
                        NoticeManager.Instance:AutoUse(autoData)
                    end
                else
                    if self.autoDataTab[newItem.base_id] ~= nil then
                        self.autoDataTab[newItem.base_id]:DeleteMe()
                        self.autoDataTab[newItem.base_id] = nil
                    end
                    table.insert(self.autoList, newItem)
                end
            end
        elseif proto.storage == BackpackEumn.StorageType.Equipment then --装备
            table.insert(equips, {id = proto.id, pos = proto.pos})
            self.equipDic[proto.id] = self:AddItem(proto, true)
        elseif proto.storage == BackpackEumn.StorageType.Store then --仓库
            table.insert(stores, {id = proto.id, pos = proto.pos})
            self.storeDic[proto.id] = self:AddItem(proto)
        elseif proto.storage == BackpackEumn.StorageType.HomeStore then --仓库
            table.insert(homeStores, {id = proto.id, pos = proto.pos})
            self.homeStoreDic[proto.id] = self:AddItem(proto)
        end
    end
    if #items > 0 then
        EventMgr.Instance:Fire(event_name.backpack_item_change, items)
    end
    if #equips > 0 then
        equips.type = 1 --增加物品触发
        EventMgr.Instance:Fire(event_name.equip_item_change, equips)
    end
    if #stores > 0 then
        EventMgr.Instance:Fire(event_name.store_item_change, stores)
    end
    if #homeStores > 0 then
        EventMgr.Instance:Fire(event_name.home_store_item_change, homeStores)
    end
    items = nil
    equips = nil
    stores = nil
    homeStores = nil
end

--删除物品通知
function BackpackManager:On10311(data)
    -- BaseUtils.dump(data, "删除物品通知")
    local items = {}
    local equips = {}
    local stores = {}
    local homeStores = {}
    for _,proto in ipairs(data.item_list) do
        if proto.storage == BackpackEumn.StorageType.Backpack then
            table.insert(items, {id = proto.id, pos = proto.pos})
            self.itemDic[proto.id] = nil
            self.posDic[proto.pos] = nil
        elseif proto.storage == BackpackEumn.StorageType.Equipment then
            table.insert(equips, {id = proto.id, pos = proto.pos})
            self.equipDic[proto.id] = nil
        elseif proto.storage == BackpackEumn.StorageType.Store then --仓库
            table.insert(stores, {id = proto.id, pos = proto.pos})
            self.storeDic[proto.id] = nil
        elseif proto.storage == BackpackEumn.StorageType.HomeStore then --家园仓库
            table.insert(homeStores, {id = proto.id, pos = proto.pos})
            self.homeStoreDic[proto.id] = nil
        end
    end
    if #items > 0 then
        EventMgr.Instance:Fire(event_name.backpack_item_change, items)
    end
    if #equips > 0 then
        equips.type = 0 --删除物品触发
        EventMgr.Instance:Fire(event_name.equip_item_change, equips)
    end
    if #stores > 0 then
        EventMgr.Instance:Fire(event_name.store_item_change, stores)
    end
    if #homeStores > 0 then
        EventMgr.Instance:Fire(event_name.home_store_item_change, homeStores)
    end
    items = nil
    equips = nil
    stores = nil
    homeStores = nil
end

--刷新物品通知
function BackpackManager:On10312(data)
    -- print("-------------------------------------收到10312")
    -- BaseUtils.dump(data, "刷新物品通知")
    local items = {}
    local equips = {}
    local stores = {}
    local homeStores = {}
    for _,proto in ipairs(data.item_list) do
        if proto.storage == BackpackEumn.StorageType.Backpack then
            table.insert(items, {id = proto.id, pos = proto.pos})
            local item = self.itemDic[proto.id]
            if item ~= nil then
                item:SetProto(proto)
            end
        elseif proto.storage == BackpackEumn.StorageType.Equipment then
            table.insert(equips, {id = proto.id, pos = proto.pos})
            local item = self.equipDic[proto.id]
            if item ~= nil then
                item:SetProto(proto, true)
            end
        elseif proto.storage == BackpackEumn.StorageType.Store then --仓库
            table.insert(stores, {id = proto.id, pos = proto.pos})
            local item = self.storeDic[proto.id]
            if item ~= nil then
                item:SetProto(proto)
            end
        elseif proto.storage == BackpackEumn.StorageType.HomeStore then --仓库
            table.insert(homeStores, {id = proto.id, pos = proto.pos})
            local item = self.homeStoreDic[proto.id]
            if item ~= nil then
                item:SetProto(proto)
            end
        end
    end
    if #items > 0 then
        self.posDic = {}
        for id,item in pairs(self.itemDic) do
            self.posDic[item.pos] = id
        end
        EventMgr.Instance:Fire(event_name.backpack_item_change, items)
    end
    if #equips > 0 then
        -- print('--------------------------------------发出更新装备')
        EventMgr.Instance:Fire(event_name.equip_item_change, equips)
    end
    if #stores > 0 then
        EventMgr.Instance:Fire(event_name.store_item_change, stores)
    end
    if #homeStores > 0 then
        -- print('--------------------------------------发出更新家园仓库')
        EventMgr.Instance:Fire(event_name.home_store_item_change, homeStores)
    end
    items = nil
    equips = nil
    stores = nil
    homeStores = nil
end

function BackpackManager:On10315(data)
    print("接收到协议10315")
    --BaseUtils.dump(data,"data")
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end

    if MarryManager.Instance.cpTreasureModel.itemdata ~= nil and data.base_id == MarryManager.Instance.cpTreasureModel.itemdata.base_id then
        MarryManager.Instance.cpTreasureModel:CheckMoveToNext()
    end
    --[[
    if data.flag == 1 then
        local base = DataItem.data_get[data.base_id]
        if base ~= nil then
            local effectss = base.effect_client
            for i,effect in ipairs(effectss) do
                if effect.effect_type_client == BackpackEumn.ItemUseClient.gift_show then
                    self.mainModel:OpenGiftShow(data.base_id)
                end
            end
        end
    end
    --]]

    -- self:CheckBestItem(data)
end

function BackpackManager:On10316(data)
end

function BackpackManager:On10317(data)
end

function BackpackManager:On10318(data)
end

function BackpackManager:On10319(data)
end
--删除物品
function BackpackManager:On10320(data)
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

function BackpackManager:On10321(data)
    if data.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
    if data.flag == 1 then
        self.refreshCount = 4
        self.refreshId = LuaTimer.Add(0, 1000, function() self:RefreshTick() end)
    end
end

function BackpackManager:RefreshTick()
    self.refreshCount = self.refreshCount - 1
    if self.refreshCount == 0 then
        if self.refreshId ~= nil then
            LuaTimer.Delete(self.refreshId)
            self.refreshId = nil
        end
    end
end

function BackpackManager:On10322(data)
end

function BackpackManager:On10323(data)
    self.openedCount = data.times
    if data.flag == 1 then
        data.newOpenGridCnt = data.new_volume - self.volumeOfItem --新增的格子数
        self.volumeOfItem = data.new_volume
        if self.mainModel.itemModel ~= nil then
            self.mainModel.itemModel:UnLocakGrid(data.newOpenGridCnt)
        end
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end
--开通仓库格子
function BackpackManager:On10324(data)
    -- BaseUtils.dump(data,"On10324")
    if data.flag == 1 then
        data.newOpenGridCnt = data.new_volume - self.volumeOfStorage --新增的格子数
        self.volumeOfStorage = data.new_volume
        if self.storeModel~= nil and self.storeModel.gaWin ~= nil and self.storeModel.gaWin.panelList[1]~= nil and self.storeModel.gaWin.panelList[1].gridPanel ~= nil then
            self.storeModel.gaWin.panelList[1].gridPanel:RefreshGrid(data)
        end
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

function BackpackManager:On10329(data)
    if data.flag == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

--获取家园仓库物品
function BackpackManager:On10330(data)
    local homeStores = {}

    self.volumeOfHomeStorage = data.volume
    for _,proto in ipairs(data.item_list) do
        self.homeStoreDic[proto.id] = self:AddItem(proto)
        table.insert(homeStores, {id = proto.id, pos = proto.pos})
    end

    EventMgr.Instance:Fire(event_name.home_store_item_change, homeStores)
    self.needReloadHomeStoreItem = false

    homeStores = nil
end

-- 开通背包格子次数
function BackpackManager:On10331(dat)
    self.openedCount = dat.num
end

--改变家园仓库格子
function BackpackManager:On10332(data)
    data.newOpenGridCnt = data.new_volume - self.volumeOfHomeStorage --新增的格子数
    self.volumeOfHomeStorage = data.new_volume
    if self.storeModel~= nil and self.storeModel.gaWin ~= nil and self.storeModel.gaWin.panelList[3]~= nil and self.storeModel.gaWin.panelList[3].gridPanel ~= nil then
        if data.newOpenGridCnt > 0 then
            self.storeModel.gaWin.panelList[3].gridPanel:RefreshGrid(data)
        else
            self.storeModel.gaWin.panelList[3].gridPanel:RefreshGrid_Del(data)
        end
    end
end

function BackpackManager:Send10334(base_id)
    self:Send(10334, {base_id = base_id})
end

function BackpackManager:On10334(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function BackpackManager:On10335(data)
    -- BaseUtils.dump(data, "On10335")
    if data.flag == BackpackEumn.ActivityItemFlag.ShowTips then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    else
        local args = StringHelper.Split(data.open, ",")
        local panelId = tonumber(args[1])
        local panelargs = {}
        for i=2,#args do
            table.insert(panelargs, tonumber(args[i]))
        end
        WindowManager.Instance:OpenWindowById(panelId, panelargs)
    end
end

function BackpackManager:Send10336(id)
    self:Send(10336, {id = id})
end

function BackpackManager:On10336(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function BackpackManager:On10339(data)
    local base = DataItem.data_get[data.id]
    if base ~= nil then
        local effectss = base.effect_client
        for i,effect in ipairs(effectss) do
            if effect.effect_type_client == BackpackEumn.ItemUseClient.gift_show then
                self.mainModel:OpenGiftShow(data)
            end
        end
    end

end

function BackpackManager:Send10340(id)
    self:Send(10340, {id = id})
end

function BackpackManager:On10340(data)
    --BaseUtils.dump(data,"On10340")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- -------------------------
-- 业务处理外部调用接口
-- -------------------------
function BackpackManager:OnTick()
end

function BackpackManager:NeedReload()
    self.needReloadGirdItem = true
    self.needReloadStoreItem = true
    self.needReloadHomeStoreItem = true
end

function BackpackManager:RequestInitData()
    self.itemDic = {}
    self.posDic = {}
    self.equipDic = {}
    self.storeDic = {}
    self.homeStoreDic = {}
    self.openedCount = 0

    self:Send10300()
    self:Send10301()
    self:Send10302()
    self:Send10330()
    self:Send10331()
end

-- 重新登录游戏，加载需要快速使用的道具到列表记录
function BackpackManager:ReLoadAutoList()
    self.autoList = {}
    self.autoDataTab = self.autoDataTab or {}
    for id,item in pairs(self.itemDic) do
        if DataItem.data_notice[item.base_id] ~= nil then
            if RoleManager.Instance.RoleData.lev >= item.lev  then
                if (item.base_id == 23801 or item.base_id == 23802 or item.base_id == 23803) and not (QuestManager.Instance:GetQuest(83026) ~= nil or QuestManager.Instance:GetQuest(83020) ~= nil) then
                    if self.autoDataTab[item.base_id] ~= nil then
                        self.autoDataTab[item.base_id]:DeleteMe()
                        self.autoDataTab[item.base_id] = nil
                    end
                    table.insert(self.autoList, item)
                else
                    local autoData = self.autoDataTab[item.base_id]
                    if autoData == nil or autoData.inChain ~= true then
                        autoData = AutoUseData.New()
                        self.autoDataTab[item.base_id] = autoData
                    end
                    autoData.callback = function() self.autoUseCallback(item) end
                    autoData.itemData = item
                    NoticeManager.Instance:AutoUse(autoData)
                end
            else
                if self.autoDataTab[item.base_id] ~= nil then
                    self.autoDataTab[item.base_id]:DeleteMe()
                    self.autoDataTab[item.base_id] = nil
                end
                table.insert(self.autoList, item)
            end
        end
    end
end

function BackpackManager:Open(args)
    self.mainModel:OpenMain(args)
end

-- 获取剩余格子数
function BackpackManager:GetCurrentGirdNum()
    local num = 0
    for k,v in pairs(self.itemDic) do
        num = num + 1
    end
    return self.volumeOfItem - num
end

--获取道具配置数据
function BackpackManager:GetItemBase(baseid)
    return BaseUtils.copytab(DataItem.data_get[baseid])
end

-- 根据道具唯一id在背包获取道具
function BackpackManager:GetItemById(id)
    return self.itemDic[id]
end

function BackpackManager:GetItemByIdAndStorageType(id,storageType)
    if storageType == BackpackEumn.StorageType.Backpack then --背包
        return self:GetItemById(id)
    elseif storageType == BackpackEumn.StorageType.Store then --仓库
        return self.storeDic[id]
    elseif storageType == BackpackEumn.StorageType.Equipment then --装备

    elseif storageType == BackpackEumn.StorageType.HomeStore then --仓库
        return self.homeStoreDic[id]
    end
end

function BackpackManager:GetDataByStorageType(storageType)
    if storageType == BackpackEumn.StorageType.Backpack then --背包
        return self.itemDic
    elseif storageType == BackpackEumn.StorageType.Store then --仓库
        return self.storeDic
    elseif storageType == BackpackEumn.StorageType.Equipment then --装备

    elseif storageType == BackpackEumn.StorageType.HomeStore then --仓库
        return self.homeStoreDic
    end
end

--根据道具配置id在背包获取道具列表
function BackpackManager:GetItemByBaseid(baseid)
    local list = {}
    for id,item in pairs(self.itemDic) do
        if item.base_id == baseid then
            table.insert(list, BaseUtils.copytab(item))
        end
    end
    return list
end

--根据道具配置id在背包获取道具列表(非绑定)
function BackpackManager:GetUnbindItemByBaseid(baseid, num)
    local list = {}
    for id,item in pairs(self.itemDic) do
        if item.base_id == baseid and item.bind == BackpackEumn.BindType.unbind then
            table.insert(list, BaseUtils.copytab(item))
        end
    end
    return list
end

--根据道具配置类型type在背包获取道具列表
function BackpackManager:GetItemByType(_type)
    local list = {}
    for id,item in pairs(self.itemDic) do
        if item.type == _type then
            table.insert(list, BaseUtils.copytab(item))
        end
    end
    return list
end

--获取指定道具配置id的道具数量
function BackpackManager:GetItemCount(baseid)
    local count = 0
    for id,item in pairs(self.itemDic) do
        if item.base_id == baseid then
            count = count + item.quantity
        end
    end
    return count
end

--获取指定道具配置id的未过期(不包括穿戴)道具数量
function BackpackManager:GetNotExpireItemCount(baseid)
    local count = 0
    for id,item in pairs(self.itemDic) do
        local Expired = false  --没过期
        if (item.expire_type == 1 or item.expire_type == 2) and item.expire_time ~= 0 and item.expire_time < BaseUtils.BASE_TIME then
            Expired = true
        end
        if item.base_id == baseid and not Expired then
            count = count + item.quantity
        end
    end
    return count

end

--获取指定道具配置id的非绑定道具数量
function BackpackManager:GetUnbindItemCount(baseid)
    local count = 0
    for id,item in pairs(self.itemDic) do
        if item.base_id == baseid and item.bind == BackpackEumn.BindType.unbind then
            count = count + item.quantity
        end
    end
    return count
end

-- 随便获取一个空格子
function BackpackManager:GetNilPos()
    for i = 1, self.volumeOfItem do
        if self.posDic[i] == nil then
            return i
        end
    end
    return 0
end

-- 检查是否是装备
function BackpackManager:IsEquip(_type)
    if (_type >= 1 and _type <= 20) or (_type >= 101 and _type <= 102) or _type == BackpackEumn.ItemType.warblade or _type == BackpackEumn.ItemType.pikeshield then
        return true
    end
    return false --不是装备
end

function BackpackManager:GetQuantity(id)
    local item = self:GetItemById(id)
    if item == nil then
        return 0
    else
        return item.quantity
    end
end

function BackpackManager:Change(id)
    local noticeData = NoticeConfirmData.New()
    noticeData.content = string.format(TI18N("<color='#ffff00'>%s</color>（%s）与本职业不符，是否<color='#ffff00'>转换？</color>"), self:GetItemById(id).name, KvData.classes_name[self:GetItemById(id).classes])
    noticeData.sureCallback = function() BackpackManager.Instance:Send10338(id) end
    NoticeManager.Instance:ConfirmTips(noticeData)
end

--使用道具处理
function BackpackManager:Use(_id, _quantity, base_id)
    if DataItem.data_item_sound ~= nil and DataItem.data_item_sound[base_id] ~= nil then
        SoundManager.Instance:Play(DataItem.data_item_sound[base_id].soundId)
    end

    local itemData = DataItem.data_get[base_id]
    local itemType = itemData.type

    if base_id == 29052 then
        if BuffPanelManager.Instance:HasBuff(12250) then
            local bd = DataBuff.data_list[12250]
            if bd ~= nil then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format(TI18N("当前身上还有<color='#ffff00'>[%s]</color>效果，使用后将被重置"), bd.name)
                data.sureLabel = TI18N("确 定")
                data.cancelLabel = TI18N("取 消")
                data.sureCallback = function() self:Send10315(_id, _quantity) end
                NoticeManager.Instance:ConfirmTips(data)
                return true
            end
        end
    elseif base_id == 24019 then -- 白色情人节，许愿
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.love_wish)
        return true
    elseif base_id == 24020 then -- 白色情人节，许愿
        ValentineManager.Instance:send17830(_id)
        return true
    elseif base_id == 25026 then -- 未来机甲礼包
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mesh_fashion_special, {base_id = base_id,id = _id, num = _quantity})
        return true
    elseif DataItem.data_change_item[base_id] ~= nil and self:GetItemById(_id) ~= nil and self:GetItemById(_id).classes ~= RoleManager.Instance.RoleData.classes then
        self:Change(_id)
        return true
    elseif base_id == 70150 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("恭喜您获得决斗胜利，围观群众意犹未尽，快在<color='#ffff00'>跨服擂台场景</color>洒下<color='#ffff00'>红包雨</color>分享喜悦吧")
        data.sureLabel = TI18N("确 定")
        data.cancelLabel = TI18N("取 消")
        data.sureCallback = function() self:Send10315(_id, _quantity) end
        NoticeManager.Instance:ConfirmTips(data)
        return true
    end
    if  itemType == 152 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.specialitem_window,{base_id,_id,_quantity})
        return true
    end

    if base_id == 23807 then  -- 子女单人任务的种子
        if MarryManager.Instance.loverData ~= nil and MarryManager.Instance.loverData.status == 3 then
            self:Send10315(_id, _quantity)
            return true
        end

        if SceneManager.Instance.sceneElementsModel.self_view == nil then
            return
        end
        
        local OnMovEnd = function()
            local first = function(effectview)
                effectview.gameObject.transform.localPosition = SceneManager.Instance.sceneElementsModel.self_view.gameObject.transform.localPosition
                effectview.gameObject:SetActive(false)
                local func = function()
                    self:Send10315(_id, _quantity)
                    local extra = {}
                    extra.base = BaseUtils.copytab(DataUnit.data_unit[64340])
                    MainUIManager.Instance.dialogModel:Open(DataUnit.data_unit[64340], extra, true)
                    LuaTimer.Add(800, function()
                        GameObject.Destroy(effectview.gameObject)
                    end)
                end
                LuaTimer.Add(800, function()
                    effectview.gameObject:SetActive(true)
                end)
                SceneManager.Instance.sceneElementsModel.collection.callback = func
                SceneManager.Instance.sceneElementsModel.collection:Show({msg = TI18N("栽培中..."), time = 1000})
            end
            BaseEffectView.New({effectId = 30019, time = nil, callback = first})
        end
        local ToTargetPoint = function()
            SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = OnMovEnd
            local p = {x = 0, y = 0}
            if SceneManager.Instance:CurrentMapId() == 30012 then
                    p.x = 1529
                    p.y = 1089
                else
                    p.x = 2324
                    p.y = 1445
                end
            local posi = SceneManager.Instance.sceneModel:transport_small_pos(p.x, p.y)
            SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(posi.x, posi.y)
        end

        if HomeManager.Instance.model:CanEditHome() and HomeManager.Instance:IsAtHome() then
            ToTargetPoint()
        else
            EventMgr.Instance:AddListener(event_name.scene_load, ToTargetPoint)
            HomeManager.Instance:EnterHome()
            LuaTimer.Add(2000, function()
                EventMgr.Instance:RemoveListener(event_name.scene_load, ToTargetPoint)
            end)
        end
        return true
    end

    if base_id == 23801 or base_id == 23802 or base_id == 23803 then
        local finished = function()
            self:Send10315(_id, _quantity)
        end
        SceneManager.Instance.sceneElementsModel.collection.callback = finished
        SceneManager.Instance.sceneElementsModel.collection:Show({msg = TI18N("服药中..."), time = 2000})
        return true
    end
    if base_id == 23804 or base_id == 23805 then
        if QuestManager.Instance:GetQuest(83110) ~= nil then
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack)
            QuestManager.Instance:DoQuest(QuestManager.Instance:GetQuest(83110))
        else
            self:Send10315(_id, _quantity)
        end
        return true
    end
    if base_id == 23219 then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack)
        self:Send10315(_id, _quantity)
        return true
    end
    if base_id == 29014 then
        -- 特殊处理，万年玄冰
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("使用后使自己装备鞋子增加的<color='#ffff00'>攻速变为0</color>（适用于龟速流派打法，慎用），确定要使用吗？")
        data.sureLabel = TI18N("确 定")
        data.cancelLabel = TI18N("取 消")
        data.sureCallback = function() self:Send10315(_id, _quantity) end
        NoticeManager.Instance:ConfirmTips(data)
        return true
    end
    --泽斌 特殊写死跨服状态下使用星光碎片弹出提示  jia
    if base_id == 23700 and RoleManager.Instance.RoleData.cross_type == 1 then
       NoticeManager.Instance:FloatTipsByString(TI18N("跨服状态下无法使用该道具"))
        return true
    end
    --悬赏任务奖励队长勋章
    if base_id == 23238 then
        FriendManager.Instance.model:OpenAwardPanel({_id})
        return true
    end

    if base_id == 23733 or base_id == 23734 then
        TalismanManager.Instance:send19606({}, {{id2 = _id}})
        return true
    end
    if base_id == 20019 then
        -- 肥寰要的特殊处理，就这个道具 =。=
        local all = self:GetQuantity(_id)
        if all > 0 then
            self:Send10315(_id, all)
        end
        return true
    elseif base_id == 29059 then
        if TeamManager.Instance:HasTeam() and not TeamManager.Instance:IsSelfCaptin() then
            NoticeManager.Instance:FloatTipsByString(TI18N("队长才可以使用南瓜之心，挑战邪灵之主哟~"))
            return
        end
    end

    if base_id == 22453 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.face_get_effect)
        self:Send10315(_id, _quantity)
        return true
    end

    --王者之心
    if base_id == 22785 then
        --historical_high best_rank_lev
        --print(WorldChampionManager.Instance.rankData.historical_high.."最高段位")
        -- if WorldChampionManager.Instance.rankData.historical_high < 8 then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("武道会达到<color='#ffff00'>已臻大成</color>段位开启{face_1,18}"))
        --     return true
        -- else
            WorldChampionManager.Instance.model:OpenBadgeWindow({1})
            return true
        -- end
    end

    -- 圣诞活动的特殊处理，直接跑寻路
    if base_id == 29020
        or base_id == 29021
        or base_id == 29022
        or base_id == 29023
        then
        if CombatManager.Instance.isFighting == true or CombatManager.Instance.isWatching == true then
            NoticeManager.Instance:FloatTipsByString(TI18N("请在战斗结束后使用"))
        else
            DoubleElevenManager.Instance:FindNpc(10001, "1_46")
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backpack)
        end
        return true
    end



    -- 冲顶答题入场券
    if base_id == 26013 then
        if TeamManager.Instance:HasTeam() == true then
            NoticeManager.Instance:FloatTipsByString(TI18N("单人活动，请离队后参加{face_1,9}"))
        elseif RushTopManager.Instance.model.status == RushTopEnum.State.Idle then
            NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，请留意活动公告{face_1,7}"))
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rushtop_signup_window, {RushTopManager.Instance.model.nexttime})
        end
        return true
    elseif base_id == 70218 or base_id == 70219 or base_id == 70220 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.CrossVoiceWindow, {})
        return true
    end


    local is_close = false
    local item = self:GetItemBase(base_id)

    local checkClose = function()
        if self:GetQuantity(_id) > 1 then
            return false
        else
            return true
        end
    end

        -- 元素晶石特殊处理
    if base_id == DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].learn_cost[1][1] then
        if SkillManager.Instance.sq_point == 100 then
            NoticeManager.Instance:FloatTipsByString(TI18N("灵气值已满，不可使用"))
            return
        elseif SkillManager.Instance.sq_point > 80 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("灵气值最大值<color='#ffff00'>100</color>点，超出的部分将会消失，是否继续补充灵气？")
            data.sureLabel = TI18N("确 定")
            data.cancelLabel = TI18N("取 消")
            data.sureCallback = function() self:Send10315(_id, _quantity) end
            NoticeManager.Instance:ConfirmTips(data)
        else
            self:Send10315(_id, _quantity)
        end
        return checkClose()
    end


    if item ~= nil then
        if RoleManager.Instance.RoleData.lev >= item.lev then
            if item.use_type == BackpackEumn.UseType.unuse then
                if base_id == 20095 then --珍兽兑换
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godanimal_window, {2})
                    return true
                elseif base_id == 20038 then --神兽兑换
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godanimal_window, {1})
                    return true
                elseif base_id == 22248 then -- 鸿福宝箱
                    NotNamedTreasureManager.Instance.model:UseKey(base_id)
                    return true
                elseif base_id == 22249 then -- 秘银宝箱
                    NotNamedTreasureManager.Instance.model:UseKey(base_id)
                    return true
                elseif item.type == BackpackEumn.ItemType.petStoneMark then
                    local stoneMarkData = PetManager.Instance.model.curPetStoneMarkData
                    if stoneMarkData ~= nil then

                        local temp_data = self:GetItemByBaseid(item.id)
                        if #temp_data == 0 then
                            NoticeManager.Instance:FloatTipsByString(TI18N("该符石已经消耗完"))
                            return
                        end

                        for i=1,#stoneMarkData.stoneData.attr do
                            local attr_data = stoneMarkData.stoneData.attr[i]
                            if attr_data.name == 100 then
                                if item.effect_client[1].val_client[1] == attr_data.val then
                                    --相同特效
                                    local confirmData = NoticeConfirmData.New()
                                    confirmData.type = ConfirmData.Style.Normal
                                    confirmData.sureLabel = TI18N("刻印")
                                    confirmData.cancelLabel = TI18N("取消")
                                    confirmData.sureCallback = function()
                                        PetManager.Instance:Send10544(stoneMarkData.petData.id, stoneMarkData.stoneData.id, temp_data[1].id)
                                    end
                                    confirmData.content = TI18N("当前符石拥有<color='#ffff00'>相同特效</color>，刻印只能改变<color='#00ff00'>附加属性值</color>，是否要进行刻印？")
                                    NoticeManager.Instance:ConfirmTips(confirmData)
                                    return
                                end
                            end
                        end
                        PetManager.Instance:Send10544(stoneMarkData.petData.id, stoneMarkData.stoneData.id, temp_data[1].id)
                        TipsManager.Instance.model:Closetips()
                    else
                        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有可以刻印的符石，无法使用"))
                    end
                -- elseif item.type == BackpackEumn.ItemType.probationRide then
                --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rideChooseWindow,{})
                --     return true
                elseif item.type == BackpackEumn.ItemType.pet_feed
                    or item.type == BackpackEumn.ItemType.pet_max_apt
                    or item.type == BackpackEumn.ItemType.pet_growth
                    or item.type == BackpackEumn.ItemType.pet_expbook
                    or item.type == BackpackEumn.ItemType.petglutinousriceballs  then
                    if PetManager.Instance:Get_CurPet() == nil then
                        return true
                    else
                        if base_id == 20004 and _quantity > 1 then
                            PetManager.Instance:Send10556(PetManager.Instance:Get_CurPet().id, _quantity)
                        else
                            PetManager.Instance:Send10508(PetManager.Instance:Get_CurPet().id, _id)
                        end
                        return checkClose()
                    end
                elseif item.type == BackpackEumn.ItemType.childTelent
                    or item.type == BackpackEumn.ItemType.childGrowth
                    or item.type == BackpackEumn.ItemType.childFood
                    or item.type == BackpackEumn.ItemType.childPoint then
                    if PetManager.Instance.model.currChild == nil then
                        return true
                    else
                        local child = PetManager.Instance.model.currChild
                        ChildrenManager.Instance:Require18619(child.child_id, child.platform, child.zone_id, _id)
                        return checkClose()
                    end
                elseif item.type == BackpackEumn.ItemType.petskillgem or item.type == BackpackEumn.ItemType.petattrgem then
                    PetManager.Instance.model:OpenPetWindow({1})
                    return true
                elseif item.type == BackpackEumn.ItemType.childattreqm or item.type == BackpackEumn.ItemType.childskilleqm then
                    PetManager.Instance.model:OpenPetWindow({4})
                    return true
                elseif item.type == BackpackEumn.ItemType.pet_gemwash then
                    PetManager.Instance.model:OpenPetGemWashWindow()
                    return true
                elseif item.type == BackpackEumn.ItemType.ride_food then
                    RideManager.Instance.model:UseFood(_id)
                    return true
                else
                    --处理不能直接使用的情况
                    local effectss = item.effect_client
                    BaseUtils.dump(item,"打开的道具数据")
                    for i,effect in ipairs(effectss) do
                        if effect.effect_type_client == BackpackEumn.ItemUseClient.open_window then
                            local args = effect.val_client
                            local arg1 = args[1]
                            local arg2 = args[2]
                            local arg3 = args[3]
                            local arg4 = args[4]
                            local arg5 = args[5]

                            arg1 = (arg1 == nil and nil or tonumber(arg1))
                            arg2 = (arg2 == nil and nil or tonumber(arg2))
                            arg3 = (arg3 == nil and nil or tonumber(arg3))
                            arg4 = (arg4 == nil and nil or tonumber(arg4))
                            arg5 = (arg5 == nil and nil or tonumber(arg5))
                            local args = {arg2, arg3, arg4, arg5}

                            if arg1 ~= 0 then
                                if arg1 == WindowConfig.WinID.child_study_win then
                                    if ChildrenManager.Instance:GetChildhood() ~= nil then
                                        WindowManager.Instance:OpenWindowById(arg1, args)
                                    else
                                        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有<color='#ffff00'>幼年期</color>的孩子可学习此课程"))
                                    end
                                else
                                    WindowManager.Instance:OpenWindowById(arg1, args)
                                end
                                return true
                            end
                        elseif effect.effect_type_client == BackpackEumn.ItemUseClient.find_npc then
                            local args = effect.val_client
                            local key = string.format("%s_%s", args[2], args[1])
                            print(string.format("开始寻路到npc=%s", key))
                            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                            SceneManager.Instance.sceneElementsModel:Self_PathToTarget(key)
                            return
                        end
                    end
                    self:Send10315(_id, _quantity)

                    return checkClose()
                end
            else
                if item.type == BackpackEumn.ItemType.gift then
                   local effectss = item.effect_client
                    if DataAgenda.data_lev_gift[string.format("%s_%s", base_id, RoleManager.Instance.RoleData.classes)] ~= nil then
                        --需要在面板上操作的礼包道具，打开面板
                        for i,effect in ipairs(effectss) do
                            if effect.effect_type_client == BackpackEumn.ItemUseClient.gift_show then
                                self:Send10315(_id, _quantity)
                                return true
                            end
                        end
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1,3})
                        return checkClose()
                    else
                        for i,effect in ipairs(effectss) do
                            if effect.effect_type_client == BackpackEumn.ItemUseClient.gift_show then
                                self:Send10315(_id, _quantity)
                                return checkClose()
                            end
                        end
                        self:Send10315(_id, _quantity)
                        return checkClose()
                    end
                elseif item.type == BackpackEumn.ItemType.treasuremap then
                    if RoleManager.Instance:CheckCross() then
                        return
                    end

                    local itemData = self:GetItemById(_id)
                    if itemData == nil then
                        return true
                    else
                        TreasuremapManager.Instance.model:use_treasuremap(itemData)
                        return false
                    end
                elseif item.type == BackpackEumn.ItemType.cp_treasuremap or item.type == BackpackEumn.ItemType.treasureoftruelove then --伴侣宝藏
                    if RoleManager.Instance:CheckCross() then
                        return
                    end

                    local itemData = self:GetItemById(_id)
                    if itemData == nil then
                        return true
                    else
                        MarryManager.Instance.cpTreasureModel:use_treasuremap(itemData)
                        return false
                    end
                elseif item.type == BackpackEumn.ItemType.role_wash then
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = TI18N("是否进行洗点？")
                    data.sureLabel = TI18N("确 定")
                    data.cancelLabel = TI18N("取 消")
                    data.sureCallback = function() self:Send10315(_id, _quantity) end
                    NoticeManager.Instance:ConfirmTips(data)
                    return true
                elseif item.type == BackpackEumn.ItemType.fruit or item.type == BackpackEumn.ItemType.limit_fruit then
                    local itemData = self:GetItemById(_id)
                    local level_need = 0
                    local skill_level = 0
                    for i,v in ipairs(itemData.effect) do
                        if v.effect_type == 20 or v.effect_type == 52 then
                            level_need = tonumber(v.val[1][2])
                        end
                    end
                    for _,value in ipairs(SkillManager.Instance.model.life_skills) do
                        if value.id == 10009 then
                            skill_level = value.lev
                        end
                    end
                    if skill_level < level_need then
                        local data = NoticeConfirmData.New()
                        data.type = ConfirmData.Style.Normal
                        data.content = string.format(TI18N("使用该幻化果需要<color='#ffff00'>%s级幻化之术</color>，是否前往提升？"), level_need)
                        data.sureLabel = TI18N("提升等级")
                        data.cancelLabel = TI18N("取消")
                        data.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill, {4, 10009}) end
                        NoticeManager.Instance:ConfirmTips(data)
                    else
                        self:Send10315(_id, _quantity)
                    end
                    return true
                elseif item.type == BackpackEumn.ItemType.selectgift then
                    self.mainModel:OpenSelectGiftPanel(base_id)
                    return true
                --使用按钮才会打开
                -- elseif item.type == BackpackEumn.ItemType.wingselectgift then
                --     self.mainModel:OpenSelectSuitPanel(base_id)
                --     return true
                end
                --其他情况由服务端处理
                self:Send10315(_id, _quantity)

                return checkClose()
            end
        else
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s级</color>才能使用<color='#ffff00'>%s</color>"), item.lev, item.name))
            return true
        end
    else

        self:Send10315(_id, _quantity)
        return checkClose()
    end
    return is_close
end

function BackpackManager:TempLoad()
    local func = function()
    end
    self.assestWrapper = AssetBatchWrapper.New()
    local list = {
        {file = AssetConfig.slot_item, type = AssetType.Main},
        {file = AssetConfig.talisman_set, type = AssetType.Dep},    -- 策划搞事情
    }
    self.assestWrapper:LoadAssetBundle(list, func)
end

-- 获取prefab
function BackpackManager:GetPrefab(file)
    if self.assestWrapper ~= nil then
        return self.assestWrapper:GetMainAsset(file)
    else
        return nil
    end
end

function BackpackManager:OnLevelChange()
    self.mainModel:OnLevelChange()
    self:ReLoadAutoList()
end

function BackpackManager:OnSelfLoad()
    self:ReLoadAutoList()
end

function BackpackManager:CreateManySlot()
    self.ItemSlotPool = {}
    local parent = ctx.CanvasContainer.transform:Find("BaseCanvas").transform
    for i = 1, 200 do
        local gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.slot_item))
        gameObject.transform:SetParent(parent)
        gameObject.transform.localScale = Vector3.one
        gameObject.transform.localPosition = Vector3.zero
        gameObject.name = "ItemSlot" .. i
        gameObject:SetActive(false)
        table.insert(self.ItemSlotPool, gameObject)
    end
end

function BackpackManager:GetSlotObject()
    if #self.ItemSlotPool > 0 then
        return table.remove(self.ItemSlotPool, 1)
    end
    return GameObject.Instantiate(self:GetPrefab(AssetConfig.slot_item))
end

function BackpackManager:PutSlotBack(gameObject)
    local parent = ctx.CanvasContainer.transform:Find("BaseCanvas").transform
    gameObject.transform:SetParent(parent)
    gameObject:SetActive(false)
    table.insert(self.ItemSlotPool, gameObject)
end

function BackpackManager:OpenInfoWindow(args)
    self.mainModel:OpenInfoWindow(args)
end

function BackpackManager:OpenInfoHonorWindow(args)
    self.mainModel:OpenInfoHonorWindow(args)
end

function BackpackManager:EquipCanUpgrade(equip)
    local roleLev = RoleManager.Instance.RoleData.lev
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes
    local lev_break_times = RoleManager.Instance.RoleData.lev_break_times

    local lev = equip.lev
    local key = string.format("%s_%s_%s", equip.base_id, sex, classes)
    local currData = DataBacksmith.data_forge[key]
    if currData == nil then
        return false
    end

    local needLev = currData.need_lev

    if lev_break_times < currData.need_break_times then
        return false
    elseif lev_break_times > currData.need_break_times then
        return true
    else
        if roleLev >= needLev and roleLev - lev >= 10 then
            return true
        else
            return false
        end
    end
end

-- function BackpackManager:CheckBestItem(data)

--     if self.isFirstInit == true then
--         BaseUtils.dump(data,"获得数据")
--         local isSpecial = false
--         local itemData = self:GetItemById(data[1].id)
--         BaseUtils.dump(itemData,"获得物品数据")
--         local str = DataItem.data_get[itemData.base_id].func
--         for i,v in ipairs(self.specialItemList) do
--             if v == str then
--                isSpecial = true
--                break
--             end
--         end

--         if isSpecial == true then
--             OpenServerManager.Instance:OpenRewardPanel({{id = itemData.base_id, num = 1}, TI18N("确定"), 5})
--        end
--     end


--     if self.isFirstInit == false then
--         self.isFirstInit = true
--     end
-- end

--20 装备特殊使用，不检查条件 jia
function BackpackManager:SpecialUseEuip(_id, _quantity, base_id)
    self:Send10315(_id, _quantity)
end
-- 选择礼包兑换
function BackpackManager:SendSelectGift(id, tab_id, num)
    self:Send(10315, {id = id, quantity = num, args = {{name = 1, value = tab_id, str = ""}}})
end

-- 职业转换
function BackpackManager:Send10338(id)
    self:Send(10338, {id = id})
end

function BackpackManager:On10338(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--判断是否为贵重物品
function BackpackManager:GetPreciousItem(id)
    return DataItem.data_pricious_item[id] ~= nil
end

--得到某类幻化果剩余使用次数大于某个值的列表
function BackpackManager:GetFruitTimes(baseid, times)
    local list = {}
    --BaseUtils.dump(self.itemDic,"self.itemDic")
    for id,item in pairs(self.itemDic) do
        local lev = 0
        local mintimes = 0
        if item.base_id == baseid and next(item.extra) ~= nil then
            for i,v in pairs(item.extra) do
                if v.name == BackpackEumn.ExtraName.fruit_time then  --果实次数
                    mintimes = v.value
                elseif v.name == BackpackEumn.ExtraName.fruit_lev then
                    lev = v.value
                end
            end
            if lev >= 0 and lev <= 2 and mintimes >= times then
                table.insert(list, BaseUtils.copytab(item))
            end
        end
    end
    return list
end

--得到该幻化果的等级
function BackpackManager:GetFruitLev(id)
    local lev = 0
    if id == nil then return lev end
    local itemData = self.itemDic[id]
    for i,v in pairs(itemData.extra) do
        if v.name == 32 then  --果实等级
            lev = v.value
        end
    end
    return lev
end

--得到当前幻化果的数据
function BackpackManager:GetCurrFruitData(id)
    local tab = {}
    local tab = {}
    local lev = 0
    local levtype1 = 0
    local levtype2 = 0
    local levtype3 = 0
    local data = self.itemDic[id]
    if data ~= nil and next(data) ~= nil then
        for i, v in pairs(data.extra) do
            if v.name == BackpackEumn.ExtraName.fruit_lev then
                  lev = v.value
            elseif v.name == BackpackEumn.ExtraName.fruit_lev1_type then
                  levtype1 = v.value
            elseif v.name == BackpackEumn.ExtraName.fruit_lev2_type then
                  levtype2 = v.value
            elseif v.name == BackpackEumn.ExtraName.fruit_lev3_type then
                  levtype3 = v.value
            end
        end
    end
    
    tab["lev"] = lev
    tab["fruit_lev1"] = levtype1
    tab["fruit_lev2"] = levtype2
    tab["fruit_lev3"] = levtype3
    return tab
end

function BackpackManager:MergeSameAttr(fruitdata, targetid)
    local mapp = {}
    self.handbook_data = DataHandbook.data_base[targetid]
    local type_num = nil
    local type = nil
    for c = 1, fruitdata.lev do
        type_num = self.handbook_data["lev_num"..c]
        local type = fruitdata["fruit_lev"..c]
        if mapp[type] ~= nil then
            mapp[type] = mapp[type] + type_num
        else
            mapp[type] = type_num
        end
    end
    return mapp
end