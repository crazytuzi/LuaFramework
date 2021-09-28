-- Filename：    PillData.lua
-- Author：      DJN
-- Date：        2015-5-27
-- Purpose：     丹药数据层
module("PillData", package.seeall)
require "db/DB_Pill"

require "script/model/DataCache"
require "db/DB_Normal_config"
--数据结构须知：
--后端的数据结构是 以PILL表中的id为key 返回这种丹药已经服用的个数 所以在addPillByPos函数中对于heroinfo和_curHeroPill缓存的修改方法不同
--前端整理成刷新UI比较方便直观的数据结构 以三种类型type为二维数组的第一层 以里面的每一页为二维数组的第二层
local _curHeroPill = {}   --当前武将的全部丹药信息
local TYPE_DEFENSE = 1 
local TYPE_LIFE    = 2
local TYPE_ATTACK  = 3 
local _curHeroInfo = {}
local _propsTab = {}
local _cacheAttr = {} --缓存的属性信息 加速战斗力计算
local silvercCost = DB_Normal_config.getDataById(1).Pill_coin
local _pillComposeInfo = nil


function transferPillInfo( p_info)
    -- print("transferPillInfo p_info")
    -- print_t(p_info.pill)
    _curHeroInfo = p_info
    for i=1,3 do
        _curHeroPill[i] = {}
    end
    if table.isEmpty(p_info) then
        return
    end 
    if table.isEmpty(p_info.pill) then
        return
    end
    -- print("transferPillInfo _curHeroInfo")
    -- print_t(_curHeroInfo)
  
    for k_page,v_pageInfo in pairs(p_info.pill)do
        for k_pillId , v_pillNum in pairs(v_pageInfo)do
            local pillType = getPillTypeById(k_pillId)
            local pillPage = getPillInDb(k_pillId)[1].Star - 1
            _curHeroPill[pillType][pillPage] = {}
            _curHeroPill[pillType][pillPage].templeId = tonumber(k_pillId)
            _curHeroPill[pillType][pillPage].num = tonumber(v_pillNum)
        end

    end
end
--获取_curHeroPill
function getHeroPill( ... )
   return _curHeroPill
end
--设置_curHeroPill
function setHeroPill(p_info)
   _curHeroPill = p_info
end
--更改_curHeroPill中某个type某个page的num值
--p_heroId做校验用
function changeHeroPill(p_heroId,p_type,p_page,p_pillId,p_num)

    if(tonumber(_curHeroInfo.hid) ~= tonumber(p_heroId))then
        --这是什么样的手速 能造成这种结果 。。
        return
    end
    local p_type = tonumber(p_type)
    local p_page = tonumber(p_page)
    local p_num = tonumber(p_num)
    local pillId = tostring(p_pillId)
    if table.isEmpty(_curHeroPill[p_type]) or table.isEmpty(_curHeroPill[p_type][p_page]) or _curHeroPill[p_type][p_page].num == nil then
        return
    end
    --改丹药缓存
    _curHeroPill[p_type][p_page].num = _curHeroPill[p_type][p_page].num + p_num
    local pillTmpId = tostring(_curHeroPill[p_type][p_page].templeId)
    --改武将缓存
    local allhero = HeroModel.getAllHeroes()
    -- print("addPillByPos _curHeroInfo")
    -- print_t(_curHeroInfo)
    -- print("allhero[.._curHeroInfo.hid]")
    -- print_t(allhero["".._curHeroInfo.hid])
    --local pillId = getInfoByTypeAndPage(p_page,p_type).id
    local heroPill = allhero[tostring(p_heroId)].pill
    if(table.isEmpty(heroPill) or table.isEmpty(heroPill[pillId]) )then
        return
    end
    -- print("heroPillheroPillheroPillheroPill before")
    -- print_t(allhero[tostring(p_heroId)].pill)
    heroPill[pillId][pillTmpId] = tonumber(heroPill[pillId][pillTmpId]) + p_num
    --  print("heroPillheroPillheroPillheroPill after")
    -- print_t(allhero[tostring(p_heroId)].pill)
    
end
--清除_curHeroPill中某个type下的全部值
--p_heroId做校验用
function clearHeroPill(p_heroId,p_type)

    if(tonumber(_curHeroInfo.hid) ~= tonumber(p_heroId))then
        --这是什么样的手速 能造成这种结果 。。
        return
    end
    local p_type = tonumber(p_type)
    -- local p_page = tonumber(p_page)
    -- local p_num = tonumber(p_num)
    -- local pillId = tostring(p_pillId)
    if table.isEmpty(_curHeroPill[p_type]) then
        return
    end
    --改丹药缓存
    _curHeroPill[p_type] = {}

    --改武将缓存
    local allhero = HeroModel.getAllHeroes()

    local heroPill = allhero[tostring(p_heroId)].pill
    if(table.isEmpty(heroPill) )then
        return
    end
    local dbInfo = DB_Pill.getArrDataByField("Pill_type",p_type)
    for i = 1,#dbInfo do
        local curDbInfo = dbInfo[i]
        local pillId = tostring(curDbInfo.id) 
        heroPill[pillId] = {}
    end
    
    --  print("heroPillheroPillheroPillheroPill after")
    -- print_t(allhero[tostring(p_heroId)].pill)
    
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
--通过丹药id获取丹药的类型（防御、生命、攻击）
function getPillTypeById( p_id)
    p_id = tostring(p_id)
    local tmpArray = DB_Pill.getArrDataByField("Pill_id",p_id)
   
    if(table.isEmpty(tmpArray) == false)then
        local typeTab = tonumber(tmpArray[1].Pill_type)   
        if(typeTab == 1)then    
            return TYPE_DEFENSE
        elseif(typeTab == 2)then
            return TYPE_LIFE
        elseif(typeTab == 3)then
            return TYPE_ATTACK
        end
    end
end
--通过丹药类型获得玩家已服用的这种丹药的数组
function getPageArryByType(p_type)
    local p_type = tonumber(p_type)
    local pillArray = _curHeroPill[p_type]
    --if(table.isEmpty(pillArray))then
        return _curHeroPill[p_type]
    --end
end
--通过丹药类型和页码 获得玩家已服用的这种丹药的个数
function getHaveNumByTypeAndPage(p_type,p_page)
    local p_page = tonumber(p_page)
    local pillArray = getPageArryByType(p_type)
    if(table.isEmpty(pillArray))then
        return 0
    end
    for k_page,v_info in pairs(pillArray) do
        if(tonumber(k_page) == p_page)then
            return tonumber(v_info.num)
        end
    end
    return 0
end
--通过丹药类型和丹药页数获取表中这个丹药的表中信息
function getInfoByTypeAndPage(p_page,p_type)
    local pageArray = DB_Pill.getArrDataByField("Star",tonumber(p_page)+1)
    if(table.isEmpty(pageArray))then
        return
    end
    for k,v in pairs (pageArray) do
        if(v.Pill_type == tonumber(p_type))then
            return v
        end
    end
    -- body
end
-- 初始化背包缓存 存在本地 
function initBagCache( ... )
    _propsTab = {}
    _propsTab = table.hcopy(DataCache.getBagInfo().props,{})
    -- print("--------------------initBagCache---------------------")
    -- print_t(_propsTab)
    -- print("initBagCache Count",table.count(_propsTab))
    -- print("--------------------initBagCache---------------------")
end
--更改背包缓存
function setPropsTab(p_id,p_delta)
    -- print("进来更改一次缓存")
    -- print("_propsTab before")
    -- print_t(_propsTab)
    local p_id = tonumber(p_id)
    if(table.isEmpty(_propsTab)) then return end 
    for k_index,v_info in pairs(_propsTab) do
        if(tonumber(v_info.item_template_id) == p_id)then
            v_info.item_num = v_info.item_num + tonumber(p_delta)
            -- print("_propsTab after")
            -- print_t(_propsTab)
            return
        end
    end
    local tmpTab = {}
    tmpTab.item_template_id = p_id
    tmpTab.item_num = p_delta
    table.insert(_propsTab,tmpTab)

    -- print("--------------------setPropsTab---------------------")
    -- print_t(_propsTab)
    -- print("setPropsTab Count",table.count(_propsTab))
    -- print("--------------------setPropsTab---------------------")
   
end
--获取这个人背包中拥有的某个丹药
function getPillInBag(p_tmpId)
    p_tmpId = tonumber(p_tmpId)
    local propsTab = _propsTab

    for k_index,v_info in pairs(propsTab) do
        if(tonumber(v_info.item_template_id) == p_tmpId)then
            return tonumber(v_info.item_id),tonumber(v_info.item_num)
        end
    end
end

--成功吃丹药后修改本地缓存
function addPillByPos(p_type,p_page,p_num)
    --改heroModel
    local p_type = tonumber(p_type)
    local p_pageNum = tonumber(p_page)
    local p_pageStr = tostring(p_page)
    local p_num = p_num or 1
    p_num = tonumber(p_num)
    local allhero = HeroModel.getAllHeroes()
    -- print("addPillByPos _curHeroInfo")
    -- print_t(_curHeroInfo)
    -- print("allhero[.._curHeroInfo.hid]")
    -- print_t(allhero["".._curHeroInfo.hid])
    if(table.isEmpty(allhero["".._curHeroInfo.hid].pill))then
        allhero["".._curHeroInfo.hid].pill = {}
    end
    local pillTab = allhero["".._curHeroInfo.hid].pill
    if( pillTab[p_pageStr] == nil )then
        --print("没有这个页的丹药")
        pillTab[p_pageStr] = {}
    end
    local pillDbInfo = DB_Pill.getDataById(p_pageNum)
    if(table.isEmpty(pillDbInfo))then return end
    local pillTemplateId = tostring(pillDbInfo.Pill_id)
    if(pillTab[p_pageStr][pillTemplateId] == nil)then
        pillTab[p_pageStr][pillTemplateId] = 0
    end
    --print("pillTab[p_pageStr][pillTemplateId]",pillTab[p_pageStr][pillTemplateId])
    pillTab[p_pageStr][pillTemplateId] = tostring(tonumber(pillTab[p_pageStr][pillTemplateId]) + p_num)
    -- print("pillTab[p_pageStr][pillTemplateId]",pillTab[p_pageStr][pillTemplateId])
    -- print("_curHeroPill before")
    -- print_t(_curHeroPill)
    --改丹药数据缓存
    local cachePage = pillDbInfo.Star - 1
    if(_curHeroPill[p_type][cachePage] == nil)then
        _curHeroPill[p_type][cachePage]  = {}
        _curHeroPill[p_type][cachePage].templeId = pillTemplateId
        _curHeroPill[p_type][cachePage].num = 0
    end
    _curHeroPill[p_type][cachePage].num = _curHeroPill[p_type][cachePage].num + p_num
    --     print("_curHeroPill after")
    -- print_t(_curHeroPill)
end
--通过丹药模板ID获取表中信息
function getPillInDb(p_id)
    return DB_Pill.getArrDataByField("Pill_id",tostring(p_id))
end
--计算某个人增加的属性
--p_isForce:是否重新计算属性信息
function getAffixByHid(p_hid,p_isForce)
    local p_hid = tonumber(p_hid)
    if(p_isForce ~= true and _cacheAttr[p_hid] ~= nil)then
        return _cacheAttr[p_hid] 
    end

    p_hid = tostring(p_hid)

    local allhero = HeroModel.getAllHeroes()
    local pillTab = allhero[""..p_hid].pill
    -- print("getAffixByHid pillTab")
    -- print_t(pillTab)
    if(table.isEmpty(pillTab))then
        return
    end
    local resultTab = {}
    for k_page,v_pillItem in pairs(pillTab) do
        for k_pillId , v_pillNum in pairs (v_pillItem)do
            --取出了单个丹药及数量
            local DbInfo = getPillInDb(k_pillId)[1]
            local pillType = DbInfo.Pill_type
            local pillPage = DbInfo.Star - 1
            for i = 1,tonumber(v_pillNum) do
                local tmpTab = getAffixByPos(pillType,pillPage,i)
                table.insert(resultTab,tmpTab)
            end
        end
    end

    resultTab = mergeTable(resultTab)
    -- print("resultTab")
    -- print_t(resultTab)
    _cacheAttr[tonumber(p_hid)] = resultTab
    return resultTab
end
--处理有重复key的table 专为getAffixByHid函数用
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
--通过类型，页码，位置 得到该位置的增加的属性
function getAffixByPos(p_type,p_page,p_pos)
    local pillDbInfo = getInfoByTypeAndPage(p_page,p_type)
    if(pillDbInfo == nil)then
        return
    end
    local resultTab = {}
    local affixInfo = analysisDbStr(pillDbInfo.Pill_attop)
   
    for k,v in pairs(affixInfo)do    
        local tmpTab = {}    
        tmpTab[1] = v[1]
        tmpTab[2] = v[2] - (tonumber(p_pos) -1 )*v[3]
        table.insert(resultTab,tmpTab)
    end
    return resultTab
end
--根据类型获得这种类型丹药总共能增加多少属性
function getTotalAffixByTypeInDB(p_type)
    local typeArray = DB_Pill.getArrDataByField("Pill_type",tonumber(p_type))
    if(table.isEmpty(typeArray))then return end
    local resultTab = {}
    for k,v in pairs(typeArray)do
        local page = v.Star - 1
        --for i = 1,v.Star do
        for i = 1,v.Pill_number do
            local tmpTab = getAffixByPos(p_type,page,i)
            table.insert(resultTab,tmpTab)
        end
    end

    resultTab = mergeTable(resultTab)
 
    return resultTab
end
--根据affix的map找affix的数值
function getAffixNumByMap(p_table,p_map)
    if(table.isEmpty(p_table))then
        return
    end

    local totalAffix = 0
    for k,v in pairs(p_table) do         
        if(tonumber(k) == tonumber(p_map))then
            return tonumber(v)
        end
    end
end
--根据类型获得这个类型有多少页
function getPageByType(p_type )
    local pillDbInfo = DB_Pill.getArrDataByField("Pill_type",tonumber(p_type))
    if(table.isEmpty(pillDbInfo))then
        return 0
    else
        return table.count(pillDbInfo)
    end
end
--获得三种类型所累加的属性的类型的table
function getAffixTypeTable( ... )
    local resultTab = {}
    for i=1,3 do
        local dbTmpInfp = DB_Pill.getArrDataByField("Pill_type",i)[1]
        if(dbTmpInfp ~= nil)then
            local tmpTab = {}
            local affixTypeStr = dbTmpInfp.Pill_attop
            affixTypeStr = analysisDbStr(affixTypeStr)
            for k,v in pairs(affixTypeStr)do
                table.insert(tmpTab,v[1])
            end
            resultTab[i] = tmpTab
        end
    end
    return resultTab
end
--获取当前阵上有几个武将
function getHeroNum( ... )
    return DataCache.getFormationHeroCount(  )
end
--获取当前位置是否有红点 红点要求 背包里面有 并且还没镶嵌满
function isTipByIndex(p_type,p_page)
    local pillInBag = _propsTab
    if table.isEmpty(pillInBag) then
        --背包里没有丹药
        return false
    end
    local pillDbInfo = PillData.getInfoByTypeAndPage(p_page,p_type)
    if pillDbInfo == nil then
        --查不到表信息
        return false
    end

    local totalNum = pillDbInfo.Pill_number
    local haveNum = getHaveNumByTypeAndPage(p_type,p_page)
    
    if(totalNum <= haveNum)then
        --镶嵌满了
        return false
    end
    
    local pillId = tonumber(pillDbInfo.Pill_id)
    for k,v in pairs(pillInBag)do
   
        if tonumber(v.item_template_id) == pillId and tonumber(v.item_num) > 0 then
            return true
        end 
    end
    return false


end
--获取丹药滑动的阵容界面  注意 这个阵容界面是经过筛选过的  外面的小伙伴不要用哦 
function getPillFormationInfo(p_hid )
    if(p_hid)then
        local heroInfo = HeroUtil.getHeroInfoByHid(p_hid)
        --传来了对应武将 就不去阵容里面找了 local heroInfo = HeroUtil.getHeroInfoByHid(v)
        local retTab = {}
        local tmpTab = {}
        if HeroModel.isHeroCanPill(p_hid) then
            tmpTab = table.hcopy(heroInfo,{})
            tmpTab.pillPosition = 1
            table.insert(retTab,tmpTab)
        end
        return retTab
    else

        local squad = DataCache.getSquad()
       --  print("getPillFormationInfo squad")
       -- print_t(squad)
        if(table.isEmpty(squad))then
            return {}
        end
        local onFormation = {}

        for i = 1,table.count(squad) do
            --print("squad[tostring(i-1)]",squad[tostring(i-1)])
            if(tonumber(squad[tostring(i-1)]) >0 )then
                onFormation[i] = squad[tostring(i-1)]
            end

        end


        local resultTab = {}
        for k,v in pairs(onFormation) do
            local tmpTab = {}
            local heroInfo = HeroUtil.getHeroInfoByHid(v)
            if HeroModel.isHeroCanPill(v) then
                tmpTab = table.hcopy(heroInfo,{})
                tmpTab.pillPosition = k
                
                table.insert(resultTab,tmpTab)
            end
        end 
        -- print("resultTab")
        -- print_t(resultTab)
        return resultTab
    end


end
function getPillHeroIndex(p_heroIndex,p_formationInfo)
    if(table.isEmpty(p_formationInfo))then
        return
    end
    local p_heroIndex = tonumber(p_heroIndex)
    for k,v in pairs(p_formationInfo)do
        if(v.pillPosition == p_heroIndex)then
            return k
        end
    end
end
--当按照类型将丹药全部卸下后 为了让界面及时出现加号 先将旧的丹药信息存入缓存 当点击加号按钮后 会重新向背包拉数据
function addOldPill( p_pillInfo)
    if(table.isEmpty(p_pillInfo))then
        return
    end

    for k,v in pairs(p_pillInfo) do
        setPropsTab(v.templeId,v.num)
    end
end
--根据要卸的丹药个数获得需要花费多少银币
function getCostSilverByNum( p_num )
    return silvercCost * tonumber(p_num)
end
--根据丹药类型获取玩家当前吃了多少这个类型的丹药
function getPillNumByType(p_type)
    local pageNum = getPageByType(p_type)
    local retCount = 0
    for i =1 ,pageNum do
         retCount = retCount + getHaveNumByTypeAndPage(p_type,i)
    end
    return retCount

end

--[[
    @desc   : 根据丹药类型获取背包里丹药数量
    @param  : pType 1 防御 2 生命 3 攻击
    @return : number 背包里丹药数量
--]]
function getPillTotalBagNumByType( pType )
    local typeArray = DB_Pill.getArrDataByField("Pill_type",tonumber(pType))
    local totalBagNum = 0
    if (not table.isEmpty(typeArray)) then
        for k,v in pairs(typeArray) do
            local itemId,havePillNum = getPillInBag(v.Pill_id)
            if (havePillNum and havePillNum > 0) then
                totalBagNum = totalBagNum + havePillNum
            end
        end
    end
    return totalBagNum
end

--[[
    @desc   : 根据丹药类型获取总共需要服用的丹药数量
    @param  : pType 1 防御 2 生命 3 攻击
    @return : number 需要服用的丹药数量
--]]
function getPillTotalPageNumByType( pType )
    local typeArray = DB_Pill.getArrDataByField("Pill_type",tonumber(pType))
    local totalPageNum = 0
    if (not table.isEmpty(typeArray)) then
        for k,v in pairs(typeArray) do
            totalPageNum = totalPageNum + tonumber(v.Pill_number)
        end
    end
    return totalPageNum
end

--[[
    @desc   : 更新所有的丹药信息包括 HeroModel 和 PillData
    @param  : pHid 武将ID pData 武将丹药信息
    @return : 
--]]
function updateAllPillData( pHid, pData )
    if (pData ~= nil) then
        -- 刷新HeroModel
        if (pHid and tonumber(pHid) > 0) then
            local allhero = HeroModel.getAllHeroes()
            local heroInfo = allhero[tostring(pHid)]
            heroInfo.pill = pData

            -- 刷新PillData
            transferPillInfo(heroInfo)
        end
    end
end

--[[
    @desc   : 更新丹药背包缓存
    @param  : pData 背包修改信息
    @return : 
--]]
function updateBagCache( pData )
    if (table.isEmpty(pData)) then
        return
    end
    initBagCache() -- 重置单个服用和卸下修改的数据
    for k,v in pairs(_propsTab) do
        local gid = tostring(v.gid)
        local modifyData = pData[gid]
        if (modifyData ~= nil) then
            if (table.isEmpty(modifyData)) then
                _propsTab[k] = nil
            else
                for key,val in pairs(modifyData) do
                    _propsTab[k].key = val
                end
            end
        end
    end
    -- print("--------------------updateBagCache---------------------")
    -- print_t(_propsTab)
    -- print("updateBagCache Count",table.count(_propsTab))
    -- print("--------------------updateBagCache---------------------")
end


-----------------------------------丹药合成 相关------------------------------------
--[[
    @desc   : 根据丹药类型获取索引
    @param  : pType 丹药类型
    @return : 
--]]
function getIndexByPillType( pType )
    local index = 1
    if (pType == TYPE_DEFENSE) then
        index = 1
    elseif (pType == TYPE_LIFE) then
        index = 2
    else
        index = 3
    end
    return index
end

--[[
    @desc   : 根据索引获取丹药类型
    @param  : pIndex 索引
    @return : 
--]]
function getPillTypeByIndex( pIndex )
    local pillType = TYPE_DEFENSE
    if (pIndex == 1) then
        pillType = TYPE_DEFENSE
    elseif (pIndex == 2) then
        pillType = TYPE_LIFE
    else
        pillType = TYPE_ATTACK
    end
    return pillType
end

--[[
    @desc   : 处理合成丹药信息
    @param  : 
    @return : 
--]]
function dealPillComposeInfo()
    -- 读取DB中配置数据
    local normalConfigDb = DB_Normal_config.getDataById(1)
    local pillPormulaTab = string.split(normalConfigDb.pillPormula,";")
    -- 需要的丹药
    local needPillTab = parseField(pillPormulaTab[1])
    -- 需要的物品
    local needItemTab = parseField(pillPormulaTab[2])
    -- 合成的丹药
    local pillResultTab = parseField(normalConfigDb.pillResult)

    -- print("------------needPillTab--------------")
    -- print_t(needPillTab)
    -- print("------------needItemTab--------------")
    -- print_t(needItemTab)
    -- print("------------pillResultTab--------------")
    -- print_t(pillResultTab)

    local retData = {}
    for k,v in pairs(pillResultTab) do
        local tab = {}

        -- 合成丹药
        local retTab = {}
        retTab.tid = v[1]
        retTab.num = v[2]
        tab.result = retTab

        -- 所需物品
        local itemTab = {}

        local needPill = {}
        needPill.tid = needPillTab[k][1]
        needPill.num = needPillTab[k][2]
        table.insert(itemTab,needPill)

        local needItem = {}
        needItem.tid = needItemTab[1]
        needItem.num = needItemTab[2]
        table.insert(itemTab,needItem)

        tab.needItem = itemTab
        local pillType = getPillTypeByIndex(tonumber(k))
        retData[pillType] = tab
    end
    _pillComposeInfo = retData
    -- print("------------pillComposeInfo--------------")
    -- print_t(_pillComposeInfo)
end

--[[
    @desc   : 根据丹药类型获取合成丹药信息
    @param  : pType 合成丹药类型
    @return : 合成丹药需要的信息
--]]
function getPillComposeInfoByType( pType )
    local retData = nil
    if (_pillComposeInfo) then
        retData = _pillComposeInfo[pType]
    else
        -- 处理数据
        dealPillComposeInfo()
        retData = _pillComposeInfo[pType]
    end
    -- print("------------getPillComposeInfoByType--------------")
    -- print("pillType",pType)
    -- print_t(retData)
    return retData
end

--[[
    @desc   : 根据丹药类型获取合成丹药最大数量
    @param  : pType 合成丹药类型
    @return : 合成丹药最大数量
--]]
function getMaxComposeNumByType( pType )
    local maxNum = -1
    local pillCompInfo = getPillComposeInfoByType(pType)
    local needItemTab = pillCompInfo.needItem
    for i = 1,#needItemTab do
        local needItemTid = needItemTab[i].tid
        local haveItemNum = ItemUtil.getCacheItemNumBy(needItemTid)
        local needItemNum = needItemTab[i].num
        local canNum = math.floor(haveItemNum/needItemNum)
        if (maxNum == -1 or canNum < maxNum) then
            maxNum = canNum
        end
    end

    return maxNum
end

--[[
    @desc   : 处理丹药合成后端返回的丹药信息为ReceiveReward支持的格式
    @param  : pRetData 后端返回的合成丹药信息
    @return : table 合成丹药信息
--]]
function dealPillComposeRetData( pRetData )
    local retInfo = {}
    -- 物品
    local itemTab = {}
    itemTab.type = "item"
    itemTab.tid  = tonumber(pRetData.itemTmpId)
    itemTab.num  = tonumber(pRetData.itemNum)
    -- 加入数组
    table.insert(retInfo,itemTab)
    return retInfo
end

-----------------------------------丹药合成 相关------------------------------------
