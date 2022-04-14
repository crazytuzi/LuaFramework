

MarketModel = MarketModel or class("MarketModel", BaseBagModel)
local MarketModel = MarketModel

function MarketModel:ctor()
    MarketModel.Instance = self
    self:Reset()

    self.sellItem = {}
    self.isOpenUpShelfMarket = false--是否打开了上架界面
    self.isOpenUpShelfMarketTwo = false --上架的二级界面
    self.isOpenMarket = false
    self.selectItem = nil  --上架界面选中的Item
    self.selectGoodItem = nil
    self.saleList = {}--自己上架的商品
    self.UpShelfItemList = {} --已经上架的商品
    self.SellItems = {}  --当前对应的商品列表
    self.leftDealInfos = {} --指定交易左侧数据信息
    self.rightDealInfos = {} -- 指定交易右侧数据信息

    self.seletAppointInfo = nil

    self.selectRole = nil
    self.redPoints = {}

end

function MarketModel:Reset()

end

function MarketModel:GetInstance()
    if MarketModel.Instance == nil then
        MarketModel()
    end
    return MarketModel.Instance
end


function MarketModel:dctor()

end

function MarketModel:Open()
    WindowPanel.Open(self)
end

--获取交易市场左边的大类
function MarketModel:GetBuyMarketRightItem()
    local tab = Config.db_market_type or {}
    table.sort(tab,function(a,b)
        return a.rank < b.rank
    end)
    return tab
end

--交易市场大类ID获取小类列表
function MarketModel:GetBuyMarketRightItemByID(typeID)
    local tab = {}
    local cfg = Config.db_market_stype
    for i, v in pairs(cfg) do
        if v.type == typeID then
            table.insert(tab,v)
        end
    end
    table.sort(tab,function(a,b)
        return a.stype < b.stype
    end)
    
    return tab
end

--获取背包中可以上架的物品
function MarketModel:GetCanUpShelfItemInBag(type)
    local itemList = {}
    local bagItems = {}
    local bagId
    if type == enum.ITEM_STYPE.ITEM_STYPE_PET then  --宠物特殊处理
        bagItems = PetModel:GetInstance():GetMarketPet()
        bagId = BagModel.Pet
    else
        bagItems = BagModel.GetInstance().bagItems
        bagId = BagModel.bagId
    end
    for i, v in pairs(bagItems) do
        if v ~= nil and v ~= 0 then
            if self:GetCanUpShelfItemByItemID(v.id) ~= nil and v.bind == false then
                local itemCfg = Config.db_item[v.id]
                local itemType = itemCfg.type
                local itemSType = itemCfg.stype
                if type == itemType or type == itemSType then
                    table.insert(itemList,v)
                end

            end
        end
    end
    return itemList,bagId
end

function MarketModel:GetGetCanUpShelfItemNumInBag(type,Id)
   local itemList = self:GetCanUpShelfItemInBag(type)
    local index = 0
    for i, v in pairs(itemList) do
        if v.id == Id then
            index = index + 1
        end
    end
    return index
end
--获取物品最大价格
function MarketModel:GetCanUpShelfItemMaxPrice(Id)
    local ItemList = Config.db_market_item
    local min_price = 0
    local max_price = 0
    for i, v in pairs(ItemList) do
        if v.item_id == Id then
            min_price = v.min_price
            max_price = v.max_price
            break
        end
    end
    return min_price,max_price
end
--通过ItemID获取可以上架的装备
function MarketModel:GetCanUpShelfItemByItemID(Id)
    local ItemList = Config.db_market_item
    return ItemList[Id]
    --local item = nil
    --for i, v in pairs(ItemList) do
    --    if v.item_id == Id then
    --        item = v
    --        break
    --    end
    --end
    --return item
end

---通过类型判断是否为装备
function MarketModel:CheckIsEquip(type)
    local tab  = Config.db_market_type
    local isEquip = true
    for i, v in pairs(tab) do
        if type == v.type then
            if v.is_equip == 1 then
                isEquip = true
            else
                isEquip = false
            end
        end
    end
    return isEquip
end

function MarketModel:CheckIsShowOrder(type)
    local tab  = Config.db_market_type
    for i, v in pairs(tab) do
        if type == v.type then
            return v.is_show
        end
    end
    return 0
end

function MarketModel:SortUPrice(type,tab)
    if type == 1 then
        table.sort(tab,function(a,b)
            return a.price < b.price
        end)
    else
        table.sort(tab,function(a,b)
            return a.price > b.price
        end)
    end

end
function MarketModel:SortUPrice(type,tab)
    if type == 1 then
        table.sort(tab,function(a,b)
            return a.price * a.num < b.price * b.num
        end)
    else
        table.sort(tab,function(a,b)
            return a.price*a.num > b.price*b.num
        end)
    end
end
--上架数量
function MarketModel:GetVipTimes()
 --   local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
    local vipLv = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
    local times = 0
    local cfg = Config.db_vip_rights[28]   --
    for i, v in pairs(cfg) do
        if i ==  "vip"..vipLv then
            times = v
            break
        end
    end
    return times
end
--交易税
function MarketModel:GetVipTax()
    local vipLv = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
    local times = 0
    local cfg = Config.db_vip_rights[2]   --
    for i, v in pairs(cfg) do
        if i ==  "vip"..vipLv then
            times = v
            break
        end
    end
    return tonumber(times)/100
end
--vip交易次数
function MarketModel:GetVipBuyTimes()
    local vipLv = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
    local times = 0
    local cfg = Config.db_vip_rights[26]   --
    for i, v in pairs(cfg) do
        if i ==  "vip"..vipLv then
            times = v
            break
        end
    end
    return times
end

function MarketModel:DeathAppointBuyInfo(uid)
    --self.rightDealInfos
    self.rightDealInfos = self.rightDealInfos or {}
    for i, v in pairs(self.rightDealInfos) do
        if v.item.uid ==uid then
            table.remove(self.rightDealInfos,i)
        end
    end
end

function MarketModel:AddAppointBuyInfo(item)
    self.rightDealInfos = self.rightDealInfos or {}
    table.insert(self.rightDealInfos,item)
    --self.rightDealInfos
    --for i, v in pairs(self.rightDealInfos) do
    --    if v.item.uid ==uid then
    --        table.remove(v,1)
    --    end
    --end
end

function MarketModel:CheckRedPoint()
    self.redPoints[1] = false --指定交易
    if table.nums(self.rightDealInfos) > 0 then --有红点
        self.redPoints[1] = true
        GlobalEvent:Brocast(MainEvent.ChangeRedDot,"market",true )
    else
        GlobalEvent:Brocast(MainEvent.ChangeRedDot,"market",false )
    end
    self:Brocast(MarketEvent.UpdateRedPoint)
end

function MarketModel:GetAllNums(tab)
    local nums = 0
    for i, v in pairs(tab) do
        nums = nums + v
    end
    return nums
end

