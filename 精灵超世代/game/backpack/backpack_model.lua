-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: cloud 1206802428@qq.com(必填, 创建模块的人员)
-- @editor: 1206802428@qq.com(必填, 后续维护以及修改的人员)
-- @description:
--      背包的整体逻辑功能
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-02-05
-- --------------------------------------------------------------------
BackpackModel = BackpackModel or BaseClass()

local table_insert = table.insert
local table_sort = table.sort
local partner_config = Config.PartnerData.data_get_compound_info
function BackpackModel:__init(ctrl)
    self.ctrl = ctrl
    self.item_list = {}                 -- 物品列表,背包类型做key
    self.expansion_list = {}            -- 存储空间扩充相关数据

    self.is_new_list = {}

    --[[每个部位存一件最高评分的装备，每次装备背包数据更新而更新一次,符文(以为神器)也放在这里 用来给伙伴红点判断
    --self.equip_score_list[武器类型][id] = 数据
    --self.equip_score_list[鞋子类型][id] = 数据
    --self.equip_score_list[衣服类型][id] = 数据
    --self.equip_score_list[帽子类型][id] = 数据
    --self.equip_score_list[符文(神器)类型][id] = 数据
    --神装4个类型也加进来了
    ]]--
    self.equip_score_list = {}   
    self.cur_equip_volume = 0       -- 当前背包的容量
    self.hallows_comp_list = {}     --神器合成


    --英魂的列表..因为宝可梦计算红点消耗巨大..这里保存多一份.减少负担
    self.hero_hun_list = {}

end

--[[
    @desc:装备产出效率
    author:{author}
    time:2018-05-08 20:41:25
    --@value: 
    return
]]
function BackpackModel:setEquipsOutput(value)
    self.equip_output = value
end
function BackpackModel:getEquipsOutput()
    return self.equip_output
end

--经验产出效率
function BackpackModel:setExpOutput(value)
    self.exp_output = value
end
function BackpackModel:getExpOutput()
    return self.exp_output
end

--[[
    @desc:获取指定存储空间的扩充数据
    author:{author}
    time:2018-05-08 17:41:13
    --@type: 
    return 返回table对象，包含 volume当前最大数量 open_times当前购买次数
]]
function BackpackModel:getExpansionInfo(type)
    type = type or BackPackConst.Bag_Code.EQUIPS
    return self.expansion_list[type]
end

--[[
    @desc: 获得装备副本的当前最大存储容量
    author:{author}
    time:2018-05-08 18:03:46
    return
]]
function BackpackModel:getEquipSize()
    local info = self.expansion_list[BackPackConst.Bag_Code.EQUIPS]
    return info and info.volume or 0
end

--[[
    @desc: 更新存储空间信息
    author:{author}
    time:2018-05-08 17:41:13
    --@data: 
    return
]]
function BackpackModel:updateExpansionInfo(data)
    if data == nil or data.type == nil or data.volume == nil or data.open_times == nil then return end
    if self.expansion_list[data.type] == nil then
        self.expansion_list[data.type] = {}
    end
    self.expansion_list[data.type].volume = data.volume
    self.expansion_list[data.type].open_times = data.open_times
    GlobalEvent:getInstance():Fire(BackpackEvent.UpdateEquipSize, data.type)
    -- MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.backpack, (self.cur_equip_volume >= data.volume))
end


--更新判断红点用的装备列表(包括符文)
function BackpackModel:updateEquipScoreList(bag_code, temp_item)
    if temp_item and temp_item.config then
        local type = temp_item.config.type or 1
        --装备背包备份一个序号列表
        if bag_code == BackPackConst.Bag_Code.EQUIPS then 
            if not self.equip_score_list[type] then 
                self.equip_score_list[type] = {}
            end
            self.equip_score_list[type][temp_item.id] = temp_item
        elseif bag_code == BackPackConst.Bag_Code.BACKPACK then 
            --背包里面的符文(以前神器)
            if type == BackPackConst.item_type.ARTIFACTCHIPS then
                if not self.equip_score_list[type] then 
                    self.equip_score_list[type] = {}
                end
                self.equip_score_list[type][temp_item.id] = temp_item         
            elseif type == BackPackConst.item_type.HERO_HUN then
                self.hero_hun_list[temp_item.id] = temp_item
            end
        elseif bag_code == BackPackConst.Bag_Code.PETBACKPACK then 
            if type == BackPackConst.item_type.HOME_PET_TREASURE then
                HomepetController:getInstance():getModel():updateHaveTreasureInfoById(temp_item.base_id)
            end
        end
    end
end

--[[
    @desc:初始化指定背包内物品数据，只有登录的时候，以及断线重连的时候会触发，只做初始化使用
    author:{author}
    time:2018-05-08 10:29:06
    --@data: 
    return
]]
function BackpackModel:initItemList(data)
    local bag_code = data.bag_code
    self.item_list[bag_code] = {}
    self.expansion_list[bag_code] = {}
    self.expansion_list[bag_code].volume = data.volume
    self.expansion_list[bag_code].open_times = data.open_times
    local bag_list = self.item_list[bag_code]
    for __, item in ipairs(data.item_list) do
        local id = item["id"]
        local temp_item
        if bag_list[id] ~= nil then
            temp_item = bag_list[id]
        else
            temp_item = GoodsVo.New(item.base_id)
        end
        if temp_item["initAttrData"] then
            temp_item:initAttrData(item)
        end
        bag_list[id] = temp_item

        --装备背包备份多个最高评分列表的4件装备
        self:updateEquipScoreList(bag_code, temp_item)
    end
    -- 是装备背包
    if bag_code == BackPackConst.Bag_Code.EQUIPS then
        self.cur_equip_volume = #data.item_list 
        -- MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.backpack, (self.cur_equip_volume >= data.volume))
    else
        if not self.is_init_hero_chip_redpoint then
            self.is_init_hero_chip_redpoint = true
            self:getHeroChipRedPoint()
        end
    end
    self:setHallowsCompData()
    self:checkArtifactCount()
    
    GlobalEvent:getInstance():Fire(BackpackEvent.GET_ALL_DATA, bag_code)
end
--计算碎片红点
function BackpackModel:getHeroChipRedPoint()
    local hero_list = self:getAllBackPackArray(BackPackConst.item_tab_type.HERO) 
    local status = false
    for i,v in pairs(hero_list) do
        status = self:checkHeroChipRedPoint(v)
        if status then
            break
        end
    end
    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.backpack, status)
end

--检查宝可梦碎片是否能合成
function BackpackModel:checkHeroChipRedPoint(v)
    if v.quality ~= -1 and v.base_id then
        --碎片
        if partner_config[v.base_id] then
            if v.quantity >= partner_config[v.base_id].num then
                return true
            end
        end
        --符文
        if self.hallows_comp_list and self.hallows_comp_list[v.base_id] then
            if v.quantity >= self.hallows_comp_list[v.base_id].num then
               return true
            end
        end
    end
    return false
end
--[[
    @desc: 新增一个物品数据
    author:{author}
    time:2018-05-08 10:29:46
    --@data: 
    return
]]
function BackpackModel:addItemInBagCode(data)
    if data == nil or next(data.item_list) == nil then return end
    local temp_add = {}
    local bag_code, config
    for i,vo in ipairs(data.item_list) do
        config = Config.ItemData.data_get_data(vo.base_id)
        if config ~= nil then
            if self.item_list[vo.storage] == nil then
                self.item_list[vo.storage] = {}
            end
            if bag_code == nil then
                bag_code = vo.storage
            end
            local bag_list = self.item_list[vo.storage]
            if bag_list[vo.id] == nil then
                bag_list[vo.id] = GoodsVo.New(vo.base_id)
            end
            local temp_item = bag_list[vo.id]
            if temp_item.initAttrData then
                temp_item:initAttrData(vo)
            end
            temp_add[vo.id] = temp_item

            --装备背包备份多个最高评分列表的4件装备
            self:updateEquipScoreList(bag_code, temp_item)
            --背包宝可梦符文碎片红点逻辑 --by lwc
            if config.sub_type == BackPackConst.item_tab_type.HERO then
                if self:checkHeroChipRedPoint(temp_item) then
                    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.backpack, true)
                end
            end
        end
    end
    bag_code = bag_code or BackPackConst.Bag_Code.BACKPACK

    -- 是装备背包
    if bag_code == BackPackConst.Bag_Code.EQUIPS then
        local expansion = self.expansion_list[bag_code]
        if expansion then
            self.cur_equip_volume = self.cur_equip_volume  + (#data.item_list)
            -- MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.backpack,(self.cur_equip_volume >= expansion.volume))
        end
    end

    GlobalEvent:getInstance():Fire(BackpackEvent.ADD_GOODS, bag_code, temp_add)
end

--[[
    @desc:删除一个物品 
    author:{author}
    time:2018-05-08 10:51:35
    --@data_list: 
    return
]]
function BackpackModel:deleteBagItems(data)
    if data == nil or next(data.item_list) == nil then return end
    local temp_tab = {}
    local bag_code = nil
    for i,vo in ipairs(data.item_list) do
        if bag_code == nil then
            bag_code = vo.storage or BackPackConst.Bag_Code.BACKPACK
        end
        if not self.item_list[bag_code] then return end
        local temp_item = self.item_list[bag_code][vo.id]
        if bag_code == BackPackConst.Bag_Code.EQUIPS then 
            if temp_item and temp_item.config then
                local type = temp_item.config.type or 1
                if not self.equip_score_list[type] then 
                    self.equip_score_list[type] = {}
                end
                self.equip_score_list[type][temp_item.id] = nil
            end
        elseif bag_code == BackPackConst.Bag_Code.BACKPACK then
            --背包里面的符文(以前神器)
            if temp_item and temp_item.config then
                local type = temp_item.config.type or 1
                if type == BackPackConst.item_type.ARTIFACTCHIPS then
                    if not self.equip_score_list[type] then 
                        self.equip_score_list[type] = {}
                    end
                    self.equip_score_list[type][temp_item.id] = nil         
                elseif type == BackPackConst.item_type.HERO_HUN then
                    self.hero_hun_list[temp_item.id] = nil
                end
                
            end
        end

        if self.item_list[bag_code] ~= nil then
            local bag_list = self.item_list[bag_code]
            if bag_list[vo.id] ~= nil then
                temp_tab[vo.id] = bag_list[vo.id]
                
                bag_list[vo.id] = nil
            end
        end
    end
    bag_code = bag_code or BackPackConst.Bag_Code.BACKPACK
    -- 是装备背包
    if bag_code == BackPackConst.Bag_Code.EQUIPS then
        self.cur_equip_volume = self.cur_equip_volume - (#data.item_list)
        -- MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.backpack, false)
    end

    GlobalEvent:getInstance():Fire(BackpackEvent.DELETE_GOODS, bag_code, temp_tab)
end

--[[
    @desc:更新一个物品
    author:{author}
    time:2018-05-08 10:53:29
    --@data: 
    return
]]
function BackpackModel:updateBagItemsNum(data)
    if data == nil or next(data.item_list) == nil then return end
    local change_list, bag_code, config = {}
    for i,vo in ipairs(data.item_list) do
        if vo.base_id ~= nil then
            config = Config.ItemData.data_get_data(vo.base_id)
            if config ~= nil then
                if self.item_list[vo.storage] == nil then
                    self.item_list[vo.storage] = {}
                end
                if bag_code == nil then
                    bag_code = vo.storage
                end
                local bag_list = self.item_list[vo.storage]
                if bag_list[vo.id] == nil then
                    bag_list[vo.id] = GoodsVo.New(vo.base_id)
                end
                local temp_item = bag_list[vo.id]

                --背包宝可梦符文碎片红点逻辑 (先算是否有红点)--by lwc
                local status 
                if config.sub_type == BackPackConst.item_tab_type.HERO then
                    status = self:checkHeroChipRedPoint(temp_item)
                end
                if temp_item.initAttrData then
                    temp_item:initAttrData(vo)
                end
                change_list[vo.id] = temp_item

                 --装备背包备份多个最高评分列表的4件装备
                if bag_code == BackPackConst.Bag_Code.EQUIPS then 
                    if temp_item and temp_item.config then
                        local type = temp_item.config.type or 1
                        if not self.equip_score_list[type] then 
                            self.equip_score_list[type] = {}
                        end
                        self.equip_score_list[type][temp_item.id] = temp_item
                    end
                elseif bag_code == BackPackConst.Bag_Code.BACKPACK then
                    if temp_item and temp_item.config then
                        local type = temp_item.config.type or 1
                        if type == BackPackConst.item_type.HERO_HUN then
                            self.hero_hun_list[temp_item.id] = temp_item
                        end
                    end
                end

                --背包宝可梦符文碎片红点逻辑 (如果没有红点才判断)--by lwc
                if not status and config.sub_type == BackPackConst.item_tab_type.HERO then
                    if self:checkHeroChipRedPoint(temp_item) then
                        MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.backpack, true)
                    end
                end
            end
        end
    end
    
    bag_code = bag_code or BackPackConst.Bag_Code.BACKPACK
    GlobalEvent:getInstance():Fire(BackpackEvent.MODIFY_GOODS_NUM, bag_code, change_list)
end

function BackpackModel:getAllEquipListByType(type)
    return self.equip_score_list[type]
end

--获取宝可梦武魂
function BackpackModel:getHeroHunList()
    return self.hero_hun_list or {}
end
--[[
    @desc:获取对应背包类型的物品列表 
    author:{author}
    time:2018-05-08 12:00:16
    --@bag_code: 
    return
]]
function BackpackModel:getBagItemList(bag_code)
    if self.item_list ~= nil and self.item_list[bag_code] ~= nil then
        return self.item_list[bag_code]
    end
    return {}
end

function BackpackModel:getItemListForShare(bag_type)
    local bag_code = bag_type or BackPackConst.Bag_Code.BACKPACK
    local list = self.item_list[bag_code]
    local target_list = {}
    if list then
        for k,v in pairs(list) do
            if v.config and v.config.can_share == 1 then
                table_insert(target_list, v)
            end
        end
    end
    return target_list
end

--[[
    @desc:根据背包类型获取指定的道具列表
    author:{author}
    time:2018-05-08 12:03:11
	--@_type: 
    return
]]
function BackpackModel:getAllBackPackArray(_type, need_sort)
    local _type = _type or BackPackConst.item_tab_type.EQUIPS
    local bag_code

    -- 装备 神装都是属于装备
    if _type == BackPackConst.item_tab_type.EQUIPS  or 
        _type == BackPackConst.item_tab_type.HOLYEQUIPMENT then
        bag_code = BackPackConst.Bag_Code.EQUIPS
    else
        bag_code = BackPackConst.Bag_Code.BACKPACK
    end
    local bag_list = self:getBagItemList(bag_code)
    local temp_arr = {}
    if bag_list ~= nil then
        for key, item in pairs(bag_list) do
            if item and item.config and item.config.sub_type == _type then
                table_insert(temp_arr, item)
            end
        end
        -- if temp_arr and next(temp_arr) ~= nil and (not need_sort) then
        --     local sort_func = SortTools.tableLowerSorter({"quality", "sort", "base_id"})
        --     table_sort(temp_arr, sort_func)
        -- end
    end
    return temp_arr
end

--[[
    @desc:判断装备背包是否满
    author:{author}
    time:2018-05-21 10:55:58
    return
]]
function BackpackModel:checkEquipsIsFull()
    local max_size = self:getEquipSize()
    local list = self:getAllBackPackArray(BackPackConst.item_tab_type.EQUIPS)
    local count = tableLen(list)
    return (count >= max_size )
end

-- ---获取背包中所有橙装的数据
function BackpackModel:getBagGoldEquipList()
    local list = self:getAllBackPackArray(BackPackConst.item_tab_type.EQUIPS)--self:getBagItemList(BackPackConst.Bag_Code.EQUIPS)
    local temp_list  = {}
    if list and next(list or {}) ~= nil then
        for i, v in ipairs(list) do
            if v.quality >= BackPackConst.quality.orange then
                table.insert(temp_list,v)
            end
        end
    end
    return temp_list
end

--判断是否是新增物品
function BackpackModel:isNewGoods(id)
    local bool = self.is_new_list[id]
    self.is_new_list[id] = false
    return bool
end

--判断背包物品是否是资产产出类型
function BackpackModel:isAssetsGoods(type)
    local is_assets = false
    if type == 104 then
        is_assets = true
    end
    return is_assets
end
--判断背包物品是否是自选礼包或者礼包类型
function BackpackModel:isSelectGiftGoods(type)
    local is_select_gift = false
    if type == 101 or type==100 then
        is_select_gift = true
    end
    return is_select_gift
end

--清理点击过的id
function BackpackModel:clearNewStateById(id)
    self.is_new_list[id] = nil
end

--清空该列表
function BackpackModel:clearNewGoodsList()
    self.is_new_list = {}
end

--根据id获取背包的物品数据
function BackpackModel:getBackPackItemById(id)
    return self:getBagItemById(BackPackConst.Bag_Code.BACKPACK, id)
end

function BackpackModel:getHomePetItemById(id)
    return self:getBagItemById(BackPackConst.Bag_Code.PETBACKPACK, id)
end

-- 根据bag_code，id获得物品数据
function BackpackModel:getBagItemById(bag_code,id)
    local temp_list = self:getBagItemList(bag_code)
    if temp_list ~= nil and temp_list[id] ~= nil then
       return temp_list[id]
    end
end

--根据bid获得道具物品的数量(包括资产道具)
function BackpackModel:getItemNumByBid(bid, bag_type)
    local bag_type = bag_type or BackPackConst.Bag_Code.BACKPACK
    --是否资产类型道具
    if Config.ItemData.data_assets_id2label[bid] then
        local str = Config.ItemData.data_assets_id2label[bid]
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo[str]  then
            return role_vo[str]
        else
            return 0
        end
    else
        if bag_type == BackPackConst.Bag_Code.BACKPACK then
            return self:getBackPackItemNumByBid(bid)
        elseif bag_type == BackPackConst.Bag_Code.EQUIPS then
            return self:getEquipItemNumByBid(bid)
        elseif bag_type == BackPackConst.Bag_Code.HOME then
            return self:getFurnitureNumByBid(bid)
        end
    end
end

--根据bid获得背包物品的数量
function BackpackModel:getBackPackItemNumByBid(bid)
     return self:getPackItemNumByBid(BackPackConst.Bag_Code.BACKPACK, bid)
end

--根据bid获得背包装备的数量
function BackpackModel:getEquipItemNumByBid(bid)
     return self:getPackItemNumByBid(BackPackConst.Bag_Code.EQUIPS, bid)
end

--根据bid获得背包中家具的数量
function BackpackModel:getFurnitureNumByBid( bid )
    return self:getPackItemNumByBid(BackPackConst.Bag_Code.HOME, bid)
end

--根据bid获得bag_code物品的数量
function BackpackModel:getPackItemNumByBid(bag_code, bid)
    local len = 0
    local bag_list = self:getBagItemList(bag_code)
    for k,item in pairs(bag_list) do
        if item and item.config and item.config.id == bid then
            len = len + item.quantity
        end
    end
    return len
end

--根据类型获得背包中该类型物品的列表
function BackpackModel:getBackPackItemListByType(type)
    local list = {}
    local bag_list = self:getBagItemList(BackPackConst.Bag_Code.BACKPACK)
    for k,item in pairs(bag_list) do
        if item and item.config and item.config.type == type then
            table_insert( list,item )
        end
    end
    return list
end

-- 根据bid获取物品的id列表
function BackpackModel:getBackPackItemIdListByBid( bid )
    local id_list = {}
    local bag_list = self:getBagItemList(BackPackConst.Bag_Code.BACKPACK)
    for k,item in pairs(bag_list) do
        if item and item.config and item.config.id == bid then
            table_insert(id_list, item.id)
        end
    end
    return id_list
end

--根据bid物品的id
function BackpackModel:getBackPackItemIDByBid(bid)
    return self:getPackItemIDByBid(BackPackConst.Bag_Code.BACKPACK, bid)
end

--根据bid获得bag_code物品的id
function BackpackModel:getPackItemIDByBid(bag_code, bid)
    local bag_list = self:getBagItemList(bag_code)
    local id = 0
    for k,item in pairs(bag_list) do
        if item and item.config and item.config.id == bid then
            id = item.id
            break
        end
    end
    return id
end

--==============================--
--desc:根据bid获取指定单位数据
--time:2017-11-08 05:12:52
--@bid:
--@return 
--==============================--
function BackpackModel:getBackPackItemByBid(bid)
    local id = self:getBackPackItemIDByBid(bid)
    if id ~= nil then
        return self:getBackPackItemById(id)
    end
end

--==============================--
--desc:背包是否是空
--time:2017-07-04 04:43:26
--@return 
--==============================--
function BackpackModel:isEmpty()
    local is_empty = true
    local bag_list = self:getBagItemList(BackPackConst.Bag_Code.BACKPACK)
    if bag_list ~= nil and next(bag_list) ~= nil then
        is_empty = false
    end
    return is_empty
end

--==============================--
--desc:统计各个标签的物品类型
--time:2017-07-04 04:47:10
--@return 
--==============================--
function BackpackModel:getItemTypeIsEmpty()
    local item_type_list = {}
    local bag_list = self:getBagItemList(BackPackConst.Bag_Code.BACKPACK)
    if bag_list ~= nil then
        for key, item in pairs(bag_list) do
            if item and item.config and item.config.sub_type ~= nil then 
                if item.config.sub_type ~= BackPackConst.item_tab_type.OTHERS then
                    if item_type_list[item.config.sub_type] == nil then
                        item_type_list[item.config.sub_type] = {}
                    end
                    table_insert(item_type_list[item.config.sub_type], item)
                end
            end
        end
    end
    return item_type_list
end

local ITEM_SOURCE_KEY = "item_source_key"
--物品来源扫荡次数
function BackpackModel:setSwapTimes(times)
    RoleEnv:getInstance():set(RoleEnv.keys.item_source_key, times, true)
end
function BackpackModel:getSwapTimes()
    --local times = RoleEnv:getInstance():get(RoleEnv.keys.item_source_key, 0)
	--if times == 0 then
		--打开界面时，如果条件满足，默认选择只能扫荡
	    local level_limit = Config.DunChapterData.data_const_list["swap_lev_limit"].val
		local role_lv = RoleController:getInstance():getRoleVo().lev
		local vip_lv = RoleController:getInstance():getRoleVo().vip_lev
		local SWAP_VIP_LEVEL = 1	--vip1或者登记到25自动开启10次扫荡
		if role_lv >= level_limit or vip_lv >= SWAP_VIP_LEVEL then
		    times = 10
		else
			times = 1
		end
	--end
	return times
end

--神器合成
function BackpackModel:setHallowsCompData()
    if next(self.hallows_comp_list) ~= nil then return end
    local data_list = Config.ItemProductData.data_product_data
    for i,v in pairs(data_list) do
        self.hallows_comp_list[v.need_items[1][1]] = {bid = v.bid, num = v.need_items[1][2]}
    end
end
function BackpackModel:getHallowsCompData(id)
    if not self.hallows_comp_list and next(self.hallows_comp_list) == nil then return end
    return self.hallows_comp_list[id] or {}
end

--检查符文数量 是否需要tips 玩家合成符文
function BackpackModel:checkArtifactCount(is_new_day)
    if self.is_artifact_check and not is_new_day then return end
    self.is_artifact_check = true
    local artifact_count_tips = RoleEnv:getInstance():getStr(RoleEnv.keys.artifact_count_tips)
    local timeStr = os.date("%m_%d")
    if artifact_count_tips ~= "" and artifact_count_tips == timeStr then return end

    if self.backpack_tips_count == nil then
        local config = Config.PartnerArtifactData.data_artifact_const.backpack_tips_count
        if config then
            self.backpack_tips_count = config.val or 5
        else
            self.backpack_tips_count = 5
        end
    end
    local list = self.equip_score_list[BackPackConst.item_type.ARTIFACTCHIPS] or {}
    local count = 0
    for k,v in pairs(list) do
        count = count + 1
    end
    if count >= self.backpack_tips_count then
        PromptController:getInstance():getModel():addPromptData({type = PromptTypeConst.Artifact_Count_tips})
    end
end

function BackpackModel:__delete()
end
