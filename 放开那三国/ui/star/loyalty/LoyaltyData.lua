-- Filename:LoyaltyData.lua
-- Author: djn
-- Date: 2015-06-25
-- Purpose: 聚义厅数据层
module ("LoyaltyData", package.seeall)
require "db/DB_Hall_friendship"
require "db/DB_Hall_loyalty"
require "db/DB_Hall_attr"
require "db/DB_Normal_config"
require "db/DB_Union_profit"
require "db/DB_Heroes"
require "db/DB_Item_treasure"
require "db/DB_Item_godarm"
require "script/model/hero/HeroModel"
require "script/model/utils/HeroUtil"
require "script/model/DataCache"
require "script/ui/hero/HeroSort"
-- require "script/ui/star/loyalty/LoyaltyLayer"
require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
local _friendShipTab = {}
local _loyalTab = {}
local _attrTab = {}
local FRIEND_TYPE = 1001
local LOYAL_TYPE = 1002
local ATTR_TYPE = 1003
local _friendDBTab = {}
local _loyalDBTab = {}
local _attrDBTab = {}
local _addUnion = {} --激活的羁绊的总和
local _addAttr = {}  --增加的属性的总和(不包含演武厅中的)
local _addFun = {}   --增加的特异功能
local _funAddAttr = {}  --演武堂功能增加的属性
local _heroFit = {}  --符合镶嵌要求的英雄
local _treasFit = {} --符合镶嵌要求的宝物
local _godFit = {}   --符合镶嵌要求的神兵
local _bagCache = {}
local _haveEnter = false --記錄本次登陸是否進入過這個界面
local HEROTYPE = 1
local TREATYPE = 2
local GODTYPE = 3
------------对外提供的获取特殊功能、羁绊、属性的方法 都在下方 搜“对外使用”` 能搜到

--初始化一些数据
function initData( ... )
    setDBShow()
    refreshFitCache()
    _bagCache = {}
end


--设置是否进入过界面
function setHaveEnter(p_param )
     _haveEnter = p_param
end
--设置是否有红点
-- function setIfRedIcon( p_param )
--     getIfRedIcon
-- end
--通过type获取这种类型这个user总共有多少个羁绊或功能要显示
function getDBNumByType(p_type )
    local pType = tonumber(p_type)
    if(pType == FRIEND_TYPE)then
        return #_friendDBTab
    elseif(pType == LOYAL_TYPE)then
        return #_loyalDBTab
     elseif(pType == ATTR_TYPE)then
        return #_attrDBTab
    end
    -- body
end
--通过type获取这种类型数据需要几页
function getPageNumByType(p_type)
    local DBNum = getDBNumByType(p_type )
    local cellNum = getCellNumByType(p_type)
    if(cellNum == 0 )then
        --防止除数为0，不然会被编译器嘲笑的啊喂！！
        cellNum = 1
    end
    return math.ceil(DBNum/cellNum)
    -- body
end
--刷新适合的镶嵌材料的表
function refreshFitCache( ... )
    _heroFit = getFitHeroes()
    _treasFit = getFitTreas()
    _godFit = getFitGod()
end
--登陆时拉取增加的属性，增加的羁绊，增加的特异功能！
function setLoginInfo(p_data)
   -- print("setLoginInfo")
    _addUnion = {}
    _addAttr = {}
    _addFun = {}
    if(table.isEmpty(p_data) ) then
        return
    end
    _addUnion = p_data.union or {}
    _addAttr = p_data.attr or {}
    _addFun = p_data.func or {}

end
--解析表中的 ， | 形式 变成二维数组
function analysisDbStr(p_info)
    if(p_info == nil)then
        return
    end
    local resultTab = {}
    local tabData = string.split(p_info,",")
  
    for k , v in pairs(tabData)do
        local tmpTab = string.split(v,"|")
        table.insert(resultTab,tmpTab)

    end
    return resultTab
    
end
--处理有重复key的table
function mergeTable(p_table)
    if(table.isEmpty(p_table))then
        return
    end
    local resultTab = {}
    for k,v in pairs(p_table) do
        for i,j in pairs(v)do
            local affixId = j[1]
            if(resultTab[affixId] == nil)then
                resultTab[affixId] = 0
            end
            resultTab[affixId] = resultTab[affixId] + j[2]
        end
    end
    return resultTab
end
--接收网络传来数据
function setNetData(p_data)
    -- print("setNetData")
    -- print_t(p_data)
    if(table.isEmpty(p_data.va_fate) == false)then
        _friendShipTab = p_data.va_fate.lists or {}
    else
        _friendShipTab = {}
    end

    if(table.isEmpty(p_data.va_loyal) == false)then
        _loyalTab = p_data.va_loyal.lists or {}
    else
        _loyalTab = {}
    end

      if(table.isEmpty(p_data.va_martial) == false)then
        _attrTab = p_data.va_martial.lists or {}
    else
        _attrTab = {}
    end
 
end
--筛选DB 设置总共展示的羁绊在表中的id数组
--新加需求 把已经镶嵌的放后面展示  
function setDBShow()
    _friendDBTab  = {}
    _loyalDBTab = {}
    _attrDBTab = {}
    _friendDBTab = getUnionsCanOpen()
    _loyalDBTab = getFuncCanOpen()
    _attrDBTab = getAttrCanOpen()

end
function orderSort ( goods_1, goods_2 )

    if(tonumber(goods_1.order) < tonumber(goods_2.order))then
        return true
    elseif(tonumber(goods_1.order) == tonumber(goods_2.order) or tonumber(goods_1.order) > tonumber(goods_2.order))then
        return false
    end
end
--通过类型获取每页的cell数据 是配置表中的 目前缘分堂和忠义堂是相同的 预留以后不同的扩展
function getCellNumByType(p_type)
    return  ( not table.isEmpty(DB_Normal_config.getDataById(1)) )
    and DB_Normal_config.getDataById(1).page_num or 8
end
--通过索引，确定当前页有几个cell，因为涉及到最后一页可能少于总cell数目
function getCellNumByIndex(p_type,p_page)
    local cellNumInDB = getCellNumByType(p_type)
    local totalPageNum = getPageNumByType(p_type)
    local pPage = tonumber(p_page)
    local pType = tonumber(p_type)
    if(totalPageNum > pPage)then
        return cellNumInDB
    elseif(totalPageNum == pPage)then
        if(pType == FRIEND_TYPE)then
            return #_friendDBTab - cellNumInDB *(pPage - 1)
        elseif(pType == LOYAL_TYPE)then
            return #_loyalDBTab - cellNumInDB *(pPage - 1)
        elseif(pType == ATTR_TYPE)then
            return #_attrDBTab - cellNumInDB *(pPage - 1)
        end
    else
        return 0
    end

end
--通过类型，页码，行数 获取DB表信息
--传p_page,p_line 参数就是为了定位给p_id 如果传了p_id 就不用这两个参数了
function getDBInfoByIndex( p_type,p_page,p_line,p_id)
    local pType = tonumber(p_type)
    local DBId = nil
    if(p_id ~= nil)then
        DBId = tonumber(p_id)
    else
        DBId =  getIdByIndex(p_type,p_page,p_line)
    end
    --print("getDBInfoByIndex DBId",DBId)
    if(pType == FRIEND_TYPE)then
        return DB_Hall_friendship.getDataById(DBId)
    elseif(pType == LOYAL_TYPE)then
        return DB_Hall_loyalty.getDataById(DBId)
    elseif(pType == ATTR_TYPE)then
        return DB_Hall_attr.getDataById(DBId)
    end
end
--通过类型，页码，行数，位置 获取需要展示的卡牌信息
function getCardInfoByIndex( p_type,p_page,p_line,p_pos,p_id)
    local DBInfo = getDBInfoByIndex( p_type,p_page,p_line,p_id)
    local resultTab = {}
    if(table.isEmpty(DBInfo))then
        return resultTab
    end
    local tmpNeed = DBInfo.set_item
    tmpNeed = analysisDbStr(tmpNeed)
    if(not table.isEmpty(tmpNeed))then
        return tmpNeed[tonumber(p_pos)]
    end
    --返回的是一个数组 【1】是镶嵌的类型 【2】是tid
end
--通过类型，页码，行数，位置 获取是否已经镶嵌这个卡牌
function getIfFillByIndex( p_type,p_page,p_line,p_pos,p_id)
   -- print("getIfFillByIndex")
    local DBInfo = getCardInfoByIndex( p_type,p_page,p_line,p_pos,p_id)
    -- print("getCardInfoByIndex")
    -- print_t(DBInfo)
    if(table.isEmpty(DBInfo))then
        return false
    end
    local haveTab = getPutHeroByIndex(p_type,p_page,p_line,p_id)
    -- print("haveTab")
    -- print_t(haveTab)
    if(table.isEmpty(haveTab))then
        return false
    end
    for k,v in pairs(haveTab)do
        if(tonumber(v) == tonumber(DBInfo[2]) )then
            return true
        end
    end
    return false

end
--通过类型，页码，行数 获取DB表ID
function getIdByIndex(p_type,p_page,p_line)
    local pType = tonumber(p_type)
    local cellNum = getCellNumByType(pType)
    local tabIndex = (tonumber(p_page) -1 ) *cellNum + tonumber(p_line) 
    --print("getIdByIndex tabIndex",tabIndex)
    if(pType == FRIEND_TYPE)then
        return _friendDBTab[tabIndex].id  
    elseif(pType == LOYAL_TYPE)then
        return _loyalDBTab[tabIndex].id
    elseif(pType == ATTR_TYPE)then
        return _attrDBTab[tabIndex].id
    end

end
--通过类型，页码，行数 获取已经镶嵌的
function getPutHeroByIndex(p_type,p_page,p_line,p_id)
    local DBId = nil
    if(p_id)then
        DBId = tostring(p_id)
    else
        DBId = tostring(getIdByIndex(p_type,p_page,p_line))
    end
    local targetTab = {}
    local pType = tonumber(p_type)
    if(pType == FRIEND_TYPE)then
        targetTab = _friendShipTab
    elseif(pType == LOYAL_TYPE)then
        targetTab = _loyalTab
    elseif(pType == ATTR_TYPE)then
        targetTab = _attrTab
    end
    --print("getPutHeroByIndex targetTab",DBId)
    --print_t(targetTab)
    return  (not table.isEmpty(targetTab) ) and targetTab[DBId] or {}
end
--通过类型，页码，行数,英雄模板id修改本地缓存 
--------注意这里还要修改登录时拉取的属性 ！！！！！
function changeCacheByIndex(p_type,p_page,p_line,p_htid,p_itemType)
    local DBId = tostring(getIdByIndex(p_type,p_page,p_line))
    local DBInfo = getDBInfoByIndex(p_type,p_page,p_line) or {}
    local targetTab = {}
    local pType = tonumber(p_type)
    if(pType == FRIEND_TYPE)then
        targetTab = _friendShipTab or {}
    elseif(pType == LOYAL_TYPE)then
        targetTab = _loyalTab  or {}
    elseif(pType == ATTR_TYPE)then
        targetTab = _attrTab  or {}
    end
    -- print("changeCacheByIndex targetTab before")
    -- print_t(targetTab)
    --先修改 已镶嵌武将信息
    if(table.isEmpty(targetTab[DBId]))then
        targetTab[DBId] = {}
    end
    table.insert(targetTab[DBId],p_htid)
    -- print("changeCacheByIndex targetTab after")
    -- print_t(targetTab)
    --根据武将 修改增加的属性
    local addAffix = nil
    --print("changeCacheByIndex p_htid",p_htid)
    if(p_itemType == HEROTYPE)then
        local heroDbInfo = DB_Heroes.getDataById(p_htid)
        -- print("changeCacheByIndex heroDbInfo ")
        -- print_t(heroDbInfo)
        if(not table.isEmpty(heroDbInfo))then
            if(pType == FRIEND_TYPE)then
                addAffix = heroDbInfo.hero_affix1
            elseif(pType == LOYAL_TYPE)then
                addAffix = heroDbInfo.hero_affix2
            elseif(pType == ATTR_TYPE)then
                addAffix = heroDbInfo.hero_affix1
            end
        end
    elseif(p_itemType == TREATYPE)then
        local treaDbInfo = DB_Item_treasure.getDataById(p_htid)
        addAffix = treaDbInfo.affix_union
    elseif(p_itemType == GODTYPE)then
        local treaDbInfo = DB_Item_godarm.getDataById(p_htid)
        addAffix = treaDbInfo.affix_union
    end
    --print("addAffix before",addAffix)
    if(addAffix)then
        addAffix = analysisDbStr(addAffix)
    end
    -- print("本次镶嵌增加的属性")
    -- print_t(addAffix)
    -- print("目前缓存中增加的属性")
    -- print_t(_addAttr)
    for k,v in pairs(addAffix) do 
        --v[1] 属性id v[2]属性值
        local attrId = tostring(v[1])
        local attrNum = v[2]
        -- print("_addAttr[attrId]")
        -- print_t(_addAttr[attrId])
        if(_addAttr[attrId] == nil)then
            _addAttr[attrId] = 0
        end
        _addAttr[attrId] = _addAttr[attrId] + v[2]
    end
    -- print("改完本地缓存后的_addAttr")
    -- print_t(_addAttr)
    local tmpNeed = DBInfo.set_item
    tmpNeed = analysisDbStr(tmpNeed)
    -- print("tmpNeed")
    -- print_t(tmpNeed)
    local needTab = {}
    if(not table.isEmpty(tmpNeed))then
        for k,v in pairs(tmpNeed)do
            table.insert(needTab,v[2])
        end
    end
    -- print("needTab")
    -- print_t(needTab)

    --判断镶嵌的武将满没满
    if(judgeHeroIsEnough(needTab,targetTab[DBId]))then
        --print("判断认为镶嵌满了")
        if(pType == FRIEND_TYPE)then
            --加羁绊    
            local unionId  = DBInfo.union_id
            unionId = string.split(unionId,",")
            for k,v in pairs(unionId) do
                table.insert(_addUnion,tonumber(v))
            end          
            LoyaltyControler.flyStr(DBInfo.name)
        elseif(pType == LOYAL_TYPE)then
            --加特殊功能
            if(table.isEmpty(_addFun[tostring(DBInfo.type)]))then
                _addFun[tostring(DBInfo.type)] = {}
            end
            local funTab = _addFun[tostring(DBInfo.type)] 
          
            table.insert(funTab,DBInfo.id)
            LoyaltyControler.flyStr(DBInfo.name)
        elseif(pType == ATTR_TYPE)then
             --加开启属性 
            local attr  = DBInfo.attr
            attr = analysisDbStr(attr)
         
           for k,v in pairs(attr) do 
                --v[1] 属性id v[2]属性值
             
                local attrId = tostring(v[1])
                local attrNum = tonumber(v[2])
                if(_funAddAttr[attrId] == nil)then
                    _funAddAttr[attrId] = 0
                end
    
                _funAddAttr[attrId] = _funAddAttr[attrId] + attrNum
            end

            LoyaltyControler.flyStr(DBInfo.name)
 
        end
    end
end
--判断是否镶嵌满了
function judgeHeroIsEnough(p_need,p_have )
    if(table.isEmpty(p_have) or table.isEmpty(p_need))then
        --啥都没有还判断个啥 不许调戏函数
        return false
    end
    local tmpTab = {}
    for k,v in pairs(p_need)do
        v = tonumber(v)
        if(tmpTab[v] == nil)then
            tmpTab[v] = 0
        end
        tmpTab[v] = tmpTab[v] + 1
    end

    for k,v in pairs(p_have)do
        v = tonumber(v)
        if(tmpTab[v] ~= nil)then
            tmpTab[v] = tmpTab[v] -1
            if(tmpTab[v] == 0)then
                tmpTab[v] = nil
            end
        else
            --这里是拥有的比需要的多的情况 一般不会出现这个异常 如果出现 暂不做处理 只要拥有的足够需要的就可以了
            --tmpTab[v] = 1
        end
    end
    -- print("tmpTab 222")
    -- print_t(tmpTab)
    if(table.isEmpty(tmpTab))then
        return true
    else
        return false
    end
end
--获取镶嵌需要的消耗
function getItemCostByIndex( p_type,p_page,p_line,p_quality)
    local DBInfo = getDBInfoByIndex( p_type,p_page,p_line)
    if(table.isEmpty(DBInfo))then
        return
    end
    local p_quality = tonumber(p_quality)
    local costNumTab = DBInfo.card_cost
    local costNum = 0
    costNumTab = analysisDbStr(costNumTab)
    -- print("costNumTab",p_quality)
    -- print_t(costNumTab)
    for k,v in pairs(costNumTab)do
        if(tonumber(v[1]) >= p_quality)then
            costNum = tonumber(v[2])
            break
        end
    end
    local resultTab = {}
    resultTab.itemId = DBInfo.item_id
    resultTab.costNum = costNum
    resultTab.goldNum = DBInfo.gold 
    return resultTab

end
--得到所有符合镶嵌条件的英雄
function getFitHeroes()
    --满足条件的英雄
    local fitTable = {}
    --所有的英雄
    local allHeroes = HeroModel.getAllHeroes()

    -- print("getFitHeroes allHeroes")
    -- print_t(allHeroes)
    if(table.isEmpty(allHeroes))then
        return
    end
    --因为牵扯到排序，所以只能增加一些key
    local sortTable = {}
    table.hcopy(allHeroes,sortTable)
    -- print("getFitHeroes")
    -- print("sortTable")
    -- print_t(sortTable)
    --对于所有的英雄
    for k,v in pairs(sortTable) do
        local heroDBInfo = HeroUtil.getHeroLocalInfoByHtid(v.htid)
        --不是主角
        if not HeroModel.isNecessaryHero(v.htid) and

            --不在阵容里
            not HeroPublicLua.isBusyWithHid(v.hid) and
            --等级是1
            tonumber(v.level) == 1 and
            --不是小伙伴
            not LittleFriendData.isInLittleFriend(v.hid) and
            --不是第二套小伙伴
            not SecondFriendData.isInSecondFriendByHid(v.hid) and
            --没有进阶过的
            tonumber(v.evolve_level) <= 0 and
            --没有加锁的
            (v.lock == nil or tonumber(v.lock) ~= 1) and
            --没有觉醒
            (v.talent == nil or  (  table.isEmpty(v.talent.confirmed ) and table.isEmpty(v.talent.sealed ) ))and
            --不在神兵副本里
            not GodWeaponCopyData.isOnCopyFormationBy(v.hid) then

            v.star_lv = heroDBInfo.star_lv
            v.heroQuality = heroDBInfo.heroQuality
            v.country_icon = HeroModel.getCiconByCidAndlevel(heroDBInfo.country,heroDBInfo.star_lv)
            v.head_icon_id = heroDBInfo.head_icon_id
            v.name = heroDBInfo.name

            --说明这个是满足条件的武将
            table.insert(fitTable,v)
        end
    end
    -- print("fitTable")
    -- print_t(fitTable)
    local srotedTable = HeroSort.sortForHeroList(fitTable)
    -- print("srotedTable")
    -- print_t(srotedTable)
    return srotedTable
end
--[[
    @des    :得到满足炼化条件的宝物
    @return :满足炼化条件的宝物
--]]
function getFitTreas()
    local fitTable = {}
    local bagInfo = DataCache.getBagInfo()
    local sortTable = {}
    if(table.isEmpty(bagInfo))then
        return
    end
    if(table.isEmpty(bagInfo.treas))then
        return
    end
    table.hcopy(bagInfo.treas,sortTable)
    for k,v in pairs(sortTable) do
        if 
            --不是经验宝物
            v.itemDesc.isExpTreasure == nil and
            (
                --没有扩展字段
                table.isEmpty(v.va_item_text) or
                (
                    (v.va_item_text.treasureLevel == nil or  tonumber(v.va_item_text.treasureLevel) == 0 ) and
                    --没强化过
                    (v.va_item_text.treasureEvolve == nil or  tonumber(v.va_item_text.treasureEvolve) == 0 ) and
                    --没洗练过                   
                    (v.va_item_text.treasureDevelop == nil or  tonumber(v.va_item_text.treasureDevelop) == -1 ) and                      
                    --没进阶过
                    table.isEmpty(v.va_item_text.treasureInlay) and
                    --没有镶嵌          
                    (v.va_item_text.lock == nil or tonumber(v.va_item_text.lock) ~= 1 )
                    --没加锁
                )
            )
            then               
            table.insert(fitTable,v)
        end
    end

    return fitTable
end
--[[
    @des    :得到满足炼化条件的神兵
    @return :满足炼化条件的神兵
--]]
function getFitGod()
    require "script/ui/item/GodWeaponItemUtil"
    local fitTable = {}
    local bagInfo = DataCache.getBagInfo()
    local sortTable = {}
    if(table.isEmpty(bagInfo))then
        return
    end
    if(table.isEmpty(bagInfo.godWp))then
        return
    end
    table.hcopy(bagInfo.godWp,sortTable)

    for k,v in pairs(sortTable) do
        local quality,_,_  = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(v.item_template_id, v.item_id)        
        if 
            quality >= 6 and
            (
            --没有扩展字段
            table.isEmpty(v.va_item_text) or
            (
            (v.va_item_text.treasureEvolve == nil or  tonumber(v.va_item_text.treasureEvolve) == 0 ) and
            --没洗练过                           
            (v.va_item_text.lock == nil or tonumber(v.va_item_text.lock) ~= 1 )
            --没加锁
            )
            )then
                             
            table.insert(fitTable,v)
        end
    end
    return fitTable
end
--判断是否有合适镶嵌的材料
function getFitHeroByTid(p_type,p_tid)
    local resultTab = {}
    if(p_tid == nil )then
        return resultTab
    end
    -- print("getFitHeroByTid")
    -- print("p_type",p_type)
    -- print("p_tid",p_tid)
    local pTid = tonumber(p_tid)
    local pType = tonumber(p_type)
    local targetTab = {}
    if(pType == HEROTYPE)then
        targetTab = _heroFit
    elseif(pType == TREATYPE)then
        targetTab = _treasFit
    elseif(pType == GODTYPE)then
        targetTab = _godFit
    end
    -- print("targetTab")
    -- print_t(targetTab)
    if(table.isEmpty(targetTab))then
        return
    end
    if(pType == HEROTYPE)then
        for k,v in pairs(targetTab)do
            if(tonumber(v.htid) == pTid )then
                table.insert(resultTab,v)
            end
        end
    end
    if(pType == TREATYPE)then
        for k,v in pairs(targetTab)do
            if(tonumber(v.item_template_id) == pTid )then
                table.insert(resultTab,v)
            end
        end
    end
    -- print("resultTab")
    -- print_t(resultTab)
    return resultTab
    -- body
end
--获取当前背包中有多少个镶嵌消耗的物品材料
function getCostItemNumInBag(p_type,p_page,p_line,p_quality)
    local itemTab = getItemCostByIndex( p_type,p_page,p_line,p_quality)
    local itemId = 0
    if(not table.isEmpty(itemTab))then
        itemId = tonumber(itemTab.itemId)
    else
        return 0
    end
    -- print("getCostItemNumInBag itemId",itemId)
    -- print("getCostItemNumInBag _bagCache before")
    -- print_t(_bagCache)
    if(table.isEmpty(_bagCache[itemId]))then
        _bagCache[itemId] = 0
        local props = DataCache.getBagInfo().props
        -- print("getCostItemNum,props",props)
        -- print_t(props)
        if(table.isEmpty(props))then
            _bagCache[itemId] = 0
            return
        end
        for f,v in pairs(props)do
            if(tonumber(v.item_template_id) == itemId )then
                _bagCache[itemId] =  tonumber(v.item_num)
            end
        end
    else

    end
    return _bagCache[itemId]
    -- body
end
--更改缓存中背包里面这个物品的数量 缓存仅限这个data层 不涉及改变背包数据
function addItemInCache( p_id,p_num)
    local itemId = tonumber(p_id)
    if(table.isEmpty(_bagCache[itemId]))then
        return
    end
    _bagCache[itemId] = _bagCache[itemId] + tonumber(p_num)
    if(_bagCache[itemId] < 0 )then
        _bagCache[itemId] = 0
    end

end
--通过品质获取镶嵌需要多少个消耗基数
function getCostNumByQualty(p_type,p_DBId,p_quality)
    if(p_quality == nil )then
        return 
    end
    local indexDb = {}
    if(p_type == FRIEND_TYPE)then
        indexDb = DB_Hall_friendship.getDataById(p_DBId)
    elseif(p_type == LOYAL_TYPE)then
        indexDb = DB_Hall_loyalty.getDataById(p_DBId) 
    elseif(p_type == ATTR_TYPE)then
        indexDb = DB_Hall_attr.getDataById(p_DBId)
    end 
    if(table.isEmpty(indexDb))then
        return 
    end
    local numStr = indexDb.card_cost
 
    numStr = analysisDbStr(numStr)
    if(table.isEmpty(numStr))then
        return
    end
    local pQuality = tonumber(p_quality)
    for k ,v in pairs(numStr) do
        if(tonumber(v[1] >= pQuality ))then
            return tonumber(v[2])
        end
    end
    -- body
end
--删除一个fit
function removeOneFitByType( p_type,p_hid)
    
    local targetTab = {}
    if(p_type == HEROTYPE)then
        targetTab = _heroFit
    elseif(p_type == TREATYPE)then
        targetTab = _treasFit
    elseif(p_type == GODTYPE)then
        targetTab = _godFit
    end
    local p_hid = tonumber(p_hid)
    -- print("删除一个fit targetTab before")
    -- print_t(targetTab)
    if(not table.isEmpty(targetTab))then
        -- table.remove(targetTab,1)
        for k,v in pairs(targetTab)do
            if(p_type == HEROTYPE)then
                if(tonumber(v.hid) == p_hid)then
                    table.remove(targetTab,k)
                    break
                end
            elseif(p_type == TREATYPE or p_type == GODTYPE)then
                if(tonumber(v.item_id) == p_hid)then
                    table.remove(targetTab,k)
                    break
                end
            end
           
        end
    end
    -- print("删除一个fit targetTab after")
    -- print_t(targetTab)
    -- body
end
--通过羁绊ID获取这个羁绊是否在聚义厅功能中是否被激活，对外使用
function getIfUnionOpen( p_unionId)
    local p_unionId = tonumber(p_unionId)
    if(table.isEmpty(_addUnion))then
        return false
    end
    for k ,v in pairs(_addUnion)do
        if(tonumber(v)  == p_unionId)then
            return true
        end
    end
end
--获取聚义厅功能中增加的所有属性，属性对所有上阵武将有效(对助战军无效)。对外使用
-- ] Table
-- Cocos2d: [LUA-print] {
-- Cocos2d: [LUA-print]     "51" => "10000"
-- Cocos2d: [LUA-print]     "53" => 10000
-- Cocos2d: [LUA-print] }
function getSumAttr( )
    --TODO addFuncAttr
    local retTab = {};
    for k,v in pairs(_addAttr) do
        retTab[k] = v;
    end
    for i,j in pairs(_funAddAttr)do
        if(retTab[i] == nil) then
            retTab[i] = 0
        end
        retTab[i] = retTab[i] + j
    end

   return retTab
end
--获取增加的特异功能  对外使用
function getAddFun( ... )
    return _addFun
end
--根据传进的id判断这个特异功能有没有被开启 对外使用
function isFunOpen( p_type,p_id)
    local p_type = tostring(p_type)
    -- print("isFunOpen _addFun")
    -- print_t(_addFun)
    if(table.isEmpty(_addFun))then
        return false
    end
    -- print("_addFun[p_type]")
    -- print_t(_addFun[p_type])
    if(table.isEmpty(_addFun[p_type]))then
        return false
    end
    if(p_id == nil)then
        if(table.isEmpty(_addFun[p_type]))then
            return false
        else
            return true
        end
    end
    
    local pId = tonumber(p_id)

    for k,v in pairs(_addFun[p_type])do
        if(tonumber(v) == pId)then
            --print("当前type当前id的特异功能已经开启",p_type,pId)
            return true
        end
    end
    return false
end
--根据索引获取当前是否有可镶嵌但是未镶嵌的材料 有的话 有提示
--传前p_page,p_line 参数就是为了定位p_id 如果给了p_id 就不用了
function ifHaveRescourceByIndex(p_type,p_page,p_line,p_id)
   
    local DBInfo = getDBInfoByIndex( p_type,p_page,p_line,p_id)

    if(table.isEmpty(DBInfo))then
        return
    end
    if tonumber(DBInfo.level) > UserModel.getHeroLevel() then
        return 
    end
    local setItem = DBInfo.set_item
    setItem = analysisDbStr(setItem)
    if(table.isEmpty(setItem))then
        return
    end
    for k,v in pairs(setItem)do
        if(not getIfFillByIndex( p_type,p_page,p_line,k,p_id))then
            --没被镶嵌
            if(not table.isEmpty(getFitHeroByTid(v[1],v[2]) ))then
                return true
            end
        end
    end   
end

--获取当前是否有可镶嵌的材料但是未镶嵌的材料 供红点提示用
function ifHaveRedIcon( ... )
    --initData函数是初始化一些数据 以后如果废弃红点提示 切记把这个函数在页面入口的时候调用一次
    initData()
    if(table.isEmpty(_heroFit) and table.isEmpty(_treasFit) and table.isEmpty(_godFit))then
        --都没适合的材料
        return false
    end
    --再来判断适合的材料在不在镶嵌要求里
    --先判断缘分堂的
    local PageNum = getPageNumByType(FRIEND_TYPE)
    for i = 1,PageNum do
        local cellNum  = getCellNumByIndex(FRIEND_TYPE,i)
        for j = 1,cellNum do
            if ifHaveRescourceByIndex(FRIEND_TYPE,i,j) then
                return true
            end
        end
    end

    --再判断忠义堂的
    local PageNum = getPageNumByType(LOYAL_TYPE)
    for i = 1,PageNum do
        local cellNum  = getCellNumByIndex(LOYAL_TYPE,i)
        for j = 1,cellNum do
            if ifHaveRescourceByIndex(LOYAL_TYPE,i,j) then
                return true
            end
        end
    end

    --再判断演武堂的
    local PageNum = getPageNumByType(ATTR_TYPE)
    for i = 1,PageNum do
        local cellNum  = getCellNumByIndex(ATTR_TYPE,i)
        for j = 1,cellNum do
            if ifHaveRescourceByIndex(ATTR_TYPE,i,j) then
                return true
            end
        end
    end
    return false

end

--获取是否有红点
function getIfRedIcon( ... )
    return not _haveEnter and ifHaveRedIcon()
end
------------------一个工具方法
function analysList( p_list )
    if p_list == nil then
        return
    end
    return string.split(p_list,",")
end
--根据羁绊ID找出拥有这个羁绊的卡牌（将橙卡过滤掉）
function getHeroByUnion(p_unionId)
    local herotmp = DB_Heroes.Heroes
    if table.isEmpty(herotmp) then
        return
    end
    local p_unionId = tonumber(p_unionId)
    local resultTab = {}
    --先遍历一边 确认需要
    for k,v in pairs(herotmp) do 
        local unionList = v.link_group1
        if(unionList)then
            unionList = analysList(unionList)
            if(not table.isEmpty(unionList))then
                for i,j in pairs(unionList)do
                    if(tonumber(j) == p_unionId and tonumber(v.potential) <= 5)then
                       -- print("找到一个吴毅将")
                        local resTab = {}
                        resTab.id = v.id
                        resTab.name = v.name
                        resTab.potential = v.potential
                        table.insert(resultTab,resTab)
                    end
                end
            end
        end
    end
    return resultTab
end
--获取可在聚义厅中激活的羁绊
function getUnionsCanOpen( ... )
    local userLv = UserModel.getHeroLevel()
    local tmpFriend = {}
    local retTab = {}
    if(not table.isEmpty(DB_Hall_friendship.Hall_friendship))then
        local tabLength = table.count(DB_Hall_friendship.Hall_friendship)
        for i =1 ,tabLength do
            if(DB_Hall_friendship.getDataById(i) and DB_Hall_friendship.getDataById(i).show_level <= userLv)then
                table.insert(tmpFriend,DB_Hall_friendship.getDataById(i))
            end
        end
        if(not table.isEmpty(tmpFriend) )then
            local frontTab = {} --有卡可以镶嵌的
            local backTab = {} --已经镶嵌满了
            local midTab = {}  --没镶嵌满也没有卡的
           -- if(not table.isEmpty(_friendShipTab))then
            for k,v in pairs(tmpFriend) do
                v.id = tostring(v.id)
                local targetTab = {}
         
                local tmpNeed = v.set_item
                tmpNeed = analysisDbStr(tmpNeed)
        
                local needTab = {}
                if(not table.isEmpty(tmpNeed))then
                    for _,s in pairs(tmpNeed)do
                        table.insert(needTab,s[2])
                    end
                end
                if ifHaveRescourceByIndex(FRIEND_TYPE,nil,nil,v.id) then
                     table.insert(frontTab,v)
                elseif not table.isEmpty(_friendShipTab) and not table.isEmpty(_friendShipTab[v.id]) then
                    if( judgeHeroIsEnough(needTab,_friendShipTab[v.id]))then
                        table.insert(backTab,v)
                    else
                        table.insert(midTab,v)
                    end
                else
                    table.insert(midTab,v)
                end
            end

            table.sort(frontTab,orderSort)
    
            table.sort(backTab,orderSort)
    
            table.sort(midTab,orderSort)

            if(not table.isEmpty(frontTab))then
                for k,v in pairs(frontTab) do
                    table.insert(retTab,v)
                end
            end
            if(not table.isEmpty(midTab))then
                for k,v in pairs(midTab) do
                    table.insert(retTab,v)
                end
            end
            if(not table.isEmpty(backTab))then
                for k,v in pairs(backTab) do
                    table.insert(retTab,v)
                end
            end
      
        end
        -- _friendDBTab = tmpFriend
    end
    return retTab

end
--获取可在聚义厅中激活的特殊功能
function getFuncCanOpen( ... )
    local userLv = UserModel.getHeroLevel()
    local tmpLoyal = {}
    local retTab = {}
    if(not table.isEmpty(DB_Hall_loyalty.Hall_loyalty))then
        local tabLength = table.count(DB_Hall_loyalty.Hall_loyalty)
        for i =1 ,tabLength do
            if(DB_Hall_loyalty.getDataById(i) and DB_Hall_loyalty.getDataById(i).show_level <= userLv)then
                table.insert(tmpLoyal,DB_Hall_loyalty.getDataById(i))
            end
        end
        if(not table.isEmpty(tmpLoyal) )then
            local frontTab = {}
            local backTab = {}
            local midTab = {}
            --if(not table.isEmpty(_loyalTab))then
            for k,v in pairs(tmpLoyal) do
                v.id = tostring(v.id)
                local targetTab = {}
         
                local tmpNeed = v.set_item
                tmpNeed = analysisDbStr(tmpNeed)
        
                local needTab = {}
                if(not table.isEmpty(tmpNeed))then
                    for _,s in pairs(tmpNeed)do
                        table.insert(needTab,s[2])
                    end
                end
           
                if ifHaveRescourceByIndex(LOYAL_TYPE,nil,nil,v.id) then
                       table.insert(frontTab,v)
                elseif not table.isEmpty(_loyalTab) and not table.isEmpty(_loyalTab[v.id])then
                    if( judgeHeroIsEnough(needTab,_loyalTab[v.id]))then
                        table.insert(backTab,v)
                    else
                        table.insert(midTab,v)
                    end
                else
                    table.insert(midTab,v)
                end
            end

            table.sort(frontTab,orderSort)
            table.sort(backTab,orderSort)
            table.sort(midTab,orderSort)
         
            if(not table.isEmpty(frontTab))then
                for k,v in pairs(frontTab) do
                    table.insert(retTab,v)
                end
            end
              if(not table.isEmpty(midTab))then
                for k,v in pairs(midTab) do
                    table.insert(retTab,v)
                end
            end
            if(not table.isEmpty(backTab))then
                for k,v in pairs(backTab) do
                    table.insert(retTab,v)
                end
            end
       
        end
        
    end
    return retTab
end
--获取可在卿武堂中激活的属性
function getAttrCanOpen( ... )
    local userLv = UserModel.getHeroLevel()
    local tmpLoyal = {}
    local retTab = {}
    if(not table.isEmpty(DB_Hall_attr.Hall_attr))then
        local tabLength = table.count(DB_Hall_attr.Hall_attr)
        for i =1 ,tabLength do
            if(DB_Hall_attr.getDataById(i) and DB_Hall_attr.getDataById(i).show_level <= userLv)then
                table.insert(tmpLoyal,DB_Hall_attr.getDataById(i))
            end
        end
        if(not table.isEmpty(tmpLoyal) )then
            local frontTab = {}
            local backTab = {}
            local midTab = {}
    
            for k,v in pairs(tmpLoyal) do
                v.id = tostring(v.id)
                local targetTab = {}
         
                local tmpNeed = v.set_item
                tmpNeed = analysisDbStr(tmpNeed)
        
                local needTab = {}
                if(not table.isEmpty(tmpNeed))then
                    for _,s in pairs(tmpNeed)do
                        table.insert(needTab,s[2])
                    end
                end
           
                if ifHaveRescourceByIndex(ATTR_TYPE,nil,nil,v.id) then
                       table.insert(frontTab,v)
                elseif not table.isEmpty(_attrTab) and not table.isEmpty(_attrTab[v.id])then
                    if( judgeHeroIsEnough(needTab,_attrTab[v.id]))then
                        table.insert(backTab,v)
                    else
                        table.insert(midTab,v)
                    end
                else
                    table.insert(midTab,v)
                end
            end

            table.sort(frontTab,orderSort)
            table.sort(backTab,orderSort)
            table.sort(midTab,orderSort)
         
            if(not table.isEmpty(frontTab))then
                for k,v in pairs(frontTab) do
                    table.insert(retTab,v)
                end
            end
              if(not table.isEmpty(midTab))then
                for k,v in pairs(midTab) do
                    table.insert(retTab,v)
                end
            end
            if(not table.isEmpty(backTab))then
                for k,v in pairs(backTab) do
                    table.insert(retTab,v)
                end
            end
       
        end
        
    end
    return retTab
end
--获取这种羁绊是否可在聚义厅开启
function isUnionCanOpen(p_unionId )
    local p_unionId = tonumber(p_unionId)
    local friendDbTab = getUnionsCanOpen()
    if table.isEmpty(friendDbTab) then
        return false
    end
    for k,v in pairs(friendDbTab) do
        local unionList = string.split(v.union_id,",")
        for i,j in pairs(unionList) do
            if tonumber(j) == p_unionId then
                return true
            end
        end
    end
end
--获取这个功能是否通过了开放等级的限制
function isLvLimitByType( p_type)
    local userLv = UserModel.getHeroLevel()
    local needLv = getOpenLvByType(p_type)
    if(userLv >= needLv)then
        return true
    end
    return false
end
function getOpenLvByType(p_type)
     local needLv = string.split(DB_Normal_config.getDataById(1).hall_open,"|")
    if(p_type == FRIEND_TYPE)then
        return tonumber(needLv[1])
    elseif (p_type == LOYAL_TYPE)then
        return tonumber(needLv[2])
    elseif (p_type == ATTR_TYPE)then
        return tonumber(needLv[3])
    end
end
