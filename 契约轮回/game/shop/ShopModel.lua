-- @Author: lwj
-- @Date:   2018-11-12 16:53:05
-- @Last Modified time: 2018-11-12 17:17:02

ShopModel = ShopModel or class("ShopModel", BaseBagModel)
local ShopModel = ShopModel

function ShopModel:ctor()
    ShopModel.Instance = self
    self:Reset()
end

function ShopModel:Reset()
    self.isOpenFlashSale = true
    self.flashSaleList = {}
    self.goodsBoughtList = {}
    self.goodsSingelBought = {}
    self.curMallType = nil
    self.curId = nil
    self.isRecivingSingle = false
    self.curLimit = nil
    self.isOpenMainIcon = false
    self.isCloseOther = false
    self.shop_goods_num = 0
    self.flash_sale_side_data = {}
    self.min_order = 1
    self.beast_list = {}
    self.gundam_list = {}
    self.petEquip_list = {}

    self.is_check = false                   --抢购本次登录不提示标志
    self.cur_flash_sale_list = {}           --当前限时抢购列表
    self.is_allBuy = false                 -- 打包带走  是否可以一键购买
    self.curallPrice = 0
    self.packmallId = 0
end

function ShopModel:GetInstance()
    if ShopModel.Instance == nil then
        ShopModel()
    end
    return ShopModel.Instance
end

function ShopModel:SetFlashSaleList(list)
    --过滤非限时抢购
    local list2 = {}
    local beast_list = {}
    local gundam_list = {}
    local petEquip_list = {}
    self.magic_list = {}
    self.totem_list = {}
    for i = 1, #list do
        local item = list[i]
        local mallcfg = Config.db_mall[item.id]
        if not mallcfg then
            logError("ShopModel 48:mall配置中没有id为：", item.id, " 的配置")
        else
            local mall_type = String2Table(mallcfg.mall_type)[1]
            if mall_type == 1 then
                list2[#list2 + 1] = item
            elseif mall_type == 80 then
                beast_list[#beast_list + 1] = item
            elseif mall_type == 81 then
                gundam_list[#gundam_list + 1] = item
            elseif mall_type  == 82 then
                petEquip_list[#petEquip_list + 1] = item
            elseif mall_type  == 83 then
                self.magic_list[#self.magic_list+1] = item
            elseif mall_type  == 84 then
                self.totem_list[#self.totem_list+1] = item
            end
        end
    end
    self.beast_list = beast_list
    self.gundam_list = gundam_list
    self.flashSaleList = list2
    self.petEquip_list = petEquip_list

    --限购处理
    if OpenTipModel.GetInstance():IsOpenSystem(1420, 2) then
        local beast_list = self:GetGundamList()
        local flag = true
        if table.isempty(beast_list) then
            flag = false
        else
            local end_time = beast_list[1].end_time
            if end_time <= os.time() then
                flag = false
            end
        end
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "gundam_limit", flag)
    end

    if OpenTipModel.GetInstance():IsOpenSystem(1420, 3) then
        local beast_list = self:GetPetEquipList()
        local flag = true
        if table.isempty(beast_list) then
            flag = false
        else
            local end_time = beast_list[1].end_time
            if end_time <= os.time() then
                flag = false
            end
        end
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "pet_limit", flag)
    end

    if OpenTipModel.GetInstance():IsOpenSystem(1420, 4) then
        local magic_list = self:GetMagicList()
        local flag = true
        if table.isempty(magic_list) then
            flag = false
        else
            local end_time = magic_list[1].end_time
            if end_time <= os.time() then
                flag = false
            end
        end
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "magic_limit", flag)
    end

    --开启图腾限购
    if OpenTipModel.GetInstance():IsOpenSystem(1420, 5) then
        local magic_list = self:GetTotemList()
        local flag = true
        if table.isempty(magic_list) then
            flag = false
        else
            local end_time = magic_list[1].end_time
            if end_time <= os.time() then
                flag = false
            end
        end
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "totem_limit", flag)
    end
end

function ShopModel:GetFlashSaleList()
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local preview_list = {}
    local list = Config.db_mall
    local interator = table.pairsByKey(list)
    for i, v in interator do
        local mall_type = String2Table(v.mall_type)[1]
        if v.limit_type == 3 and mall_type == 1 then
            local data_lv = v.limit_level
            --数据等级要求大于当前等级
            if data_lv > lv then
                --缓存表没有数据
                if not preview_list[1] then
                    preview_list[1] = v
                else
                    --有数据  比较缓存表的等级与当前数据等级的大小
                    local vData = preview_list[1].limit_level
                    if data_lv == vData then
                        --等于  在后面加
                        preview_list[#preview_list + 1] = v
                    elseif data_lv < vData then
                        preview_list = {}
                        preview_list[1] = v
                    end
                end
            end
        end
    end
    local ser_list = {}
    for i = 1, #self.flashSaleList do
        ser_list[#ser_list + 1] = self.flashSaleList[i]
    end
    for i = 1, #preview_list do
        ser_list[#ser_list + 1] = preview_list[i]
    end
    self.cur_flash_sale_list = ser_list
    return ser_list
end

function ShopModel:GetFlashLongestLimit()
    local result = nil
    local tbl = self.flashSaleList
    if table.isempty(tbl) then
        return result
    end
    for i = 1, #tbl do
        if not result then
            result = tbl[i].end_time
        else
            if tbl[i].end_time > result then
                result = tbl[i].end_time
            end
        end
    end
    return result
end

function ShopModel:GetFlashSaleListNums()
    return table.nums(self.flashSaleList)
end

function ShopModel:CheckFlashSaleListIsEmpty()
    return table.isempty(self.flashSaleList)
end

function ShopModel:GetFlashSaleItemDataById(targetId)
    local data = nil
    for i, v in pairs(self.flashSaleList) do
        if v.id == targetId then
            data = v
            break
        end
    end
    return data
end

function ShopModel:RemoveFlashSaleById(id)
    local list = self.flashSaleList
    for i = 1, #list do
        if list[i].id == id then
            table.remove(self.flashSaleList, i)
            break
        end
    end
end

function ShopModel:GetTypeNameById(targetId)
    local result = Constant.GoldIDMap[targetId]
    return result
end

function ShopModel:SetGoodsBoughtList(list)
    self.goodsBoughtList = list
end

function ShopModel:GetGoodsBoRecordById(id)
    local temp = nil
    for i, v in pairs(self.goodsBoughtList) do
        if i == id then
            temp = v
            break
        end
    end
    return temp
end

function ShopModel:GetCurSinglePrice()
    return String2Table(Config.db_mall[self.curId].price)[2]
end

function ShopModel:GetCurPanymentType()
    local cf = Config.db_mall[self.curId]
    local price = cf.price
    local tbl = String2Table(price)
    local result = tbl[1]
    return tonumber(result)
end

function ShopModel:GetMallIdByItemId(item_id)
    local tbl = Config.db_mall
    local mall_ids = {}
    for i, v in pairs(tbl) do
        local cf_ite_id = String2Table(v.item)[1]
        if cf_ite_id == item_id then
            mall_ids[#mall_ids + 1] = v.id
        end
    end
    if #mall_ids == 0 then
        logError("商城配置中并没有 " .. item_id .. " 这个物品")
    end
    return mall_ids
end

--获取异兽限购
function ShopModel:GetBeastList()
    return self.beast_list
end

--机甲限购
function ShopModel:GetGundamList()
    return self.gundam_list
end

--宠装限购
function ShopModel:GetPetEquipList()
    return self.petEquip_list
end

--神器限购
function ShopModel:GetMagicList()
    return self.magic_list
end

--图腾限购
function ShopModel:GetTotemList()
    return self.totem_list
end

-- 获取 打包带走
function ShopModel:GetConfigById(id)
    local config = Config.db_mall[id]
    return config
end

--当前是否有抢购物品
function ShopModel:IsHavaFlashSaleItem()
    return not table.isempty(self.cur_flash_sale_list)
end
