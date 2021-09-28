-- Filename：    RivalPillData.lua
-- Author：      DJN
-- Date：        2015-5-27
-- Purpose：     对方阵容丹药数据层
module("RivalPillData", package.seeall)
require "db/DB_Pill"

require "script/model/DataCache"
--数据结构须知：
--后端的数据结构是 以PILL表中的id为key 返回这种丹药已经服用的个数 所以在addPillByPos函数中对于heroinfo和_curHeroPill缓存的修改方法不同
--前端整理成刷新UI比较方便直观的数据结构 以三种类型type为二维数组的第一层 以里面的每一页为二维数组的第二层
local _curHeroPill = {}   --当前武将的全部丹药信息
local TYPE_DEFENSE = 1 
local TYPE_LIFE    = 2
local TYPE_ATTACK  = 3 
local _curHeroInfo = {}
local _propsTab = {}
--设置_curHeroPill p_info是后端获取的数据
function transferPillInfo( p_info)
    -- print("transferPillInfo p_info")
    -- print_t(p_info)
    _curHeroInfo = p_info
    for i=1,3 do
        _curHeroPill[i] = {}
    end
    if table.isEmpty(p_info) then
        return
    end 
    if table.isEmpty(p_info.pillInfo) then
        return
    end
    -- print("transferPillInfo _curHeroInfo")
    -- print_t(_curHeroInfo)
    
   
  
    for k_page,v_pageInfo in pairs(p_info.pillInfo)do
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
-- -- 初始化背包缓存 存在本地
-- function initBagCache( ... )
--     _propsTab = DataCache.getBagInfo().props
-- end
--更改背包缓存
function setPropsTab(p_id,p_delta)
    local p_id = tonumber(p_id)
    if(table.isEmpty(_propsTab))then return end 
    for k_index,v_info in pairs(_propsTab) do
        if(tonumber(v_info.item_template_id) == p_id)then
            v_info.item_num = v_info.item_num + tonumber(p_delta)
            return
        end
    end
end
-- --获取这个人背包中拥有的某个丹药
-- function getPillInBag(p_tmpId)
--     p_tmpId = tonumber(p_tmpId)
--     local propsTab = _propsTab

--     for k_index,v_info in pairs(propsTab) do
--         if(tonumber(v_info.item_template_id) == p_tmpId)then
--             return tonumber(v_info.item_id),tonumber(v_info.item_num)
--         end
--     end
-- end

-- --成功吃丹药后修改本地缓存
-- function addPillByPos(p_type,p_page,p_num)
--     --改heroModel
--     local p_type = tonumber(p_type)
--     local p_pageNum = tonumber(p_page)
--     local p_pageStr = tostring(p_page)
--     local p_num = p_num or 1
--     p_num = tonumber(p_num)
--     local allhero = HeroModel.getAllHeroes()
--     -- print("addPillByPos _curHeroInfo")
--     -- print_t(_curHeroInfo)
--     print("allhero[.._curHeroInfo.hid]")
--     print_t(allhero["".._curHeroInfo.hid])
--     if(table.isEmpty(allhero["".._curHeroInfo.hid].pill))then
--         allhero["".._curHeroInfo.hid].pill = {}
--     end
--     local pillTab = allhero["".._curHeroInfo.hid].pill
--     if( pillTab[p_pageStr] == nil )then
--         print("没有这个页的丹药")
--         pillTab[p_pageStr] = {}
--     end
--     local pillDbInfo = DB_Pill.getDataById(p_pageNum)
--     if(table.isEmpty(pillDbInfo))then return end
--     local pillTemplateId = tostring(pillDbInfo.Pill_id)
--     if(pillTab[p_pageStr][pillTemplateId] == nil)then
--         pillTab[p_pageStr][pillTemplateId] = 0
--     end
--     print("pillTab[p_pageStr][pillTemplateId]",pillTab[p_pageStr][pillTemplateId])
--     pillTab[p_pageStr][pillTemplateId] = tostring(tonumber(pillTab[p_pageStr][pillTemplateId]) + p_num)
--     print("pillTab[p_pageStr][pillTemplateId]",pillTab[p_pageStr][pillTemplateId])
--     print("_curHeroPill before")
--     print_t(_curHeroPill)
--     --改丹药数据缓存
--     local cachePage = pillDbInfo.Star - 1
--     if(_curHeroPill[p_type][cachePage] == nil)then
--         _curHeroPill[p_type][cachePage]  = {}
--         _curHeroPill[p_type][cachePage].templeId = pillTemplateId
--         _curHeroPill[p_type][cachePage].num = 0
--     end
--     _curHeroPill[p_type][cachePage].num = _curHeroPill[p_type][cachePage].num + p_num
--         print("_curHeroPill after")
--     print_t(_curHeroPill)
-- end
--通过丹药模板ID获取表中信息
function getPillInDb(p_id)
    return DB_Pill.getArrDataByField("Pill_id",tostring(p_id))
end
--计算某个人增加的属性
function getAffixByHero(p_hero)
    if(table.isEmpty(p_hero))then
        return
    end
    local pillTab = p_hero.pillInfo 
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
    return resultTab
end
--处理有重复key的table 专为getAffixByHero函数用
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
--获取丹药滑动的阵容界面  注意 这个阵容界面是经过筛选过的  外面的小伙伴不要用哦 
function getPillFormationInfo( ... )
    local formationInfo = RivalInfoData.getFormationHeroInfo()


    if(table.isEmpty(formationInfo))then
        return {}
    end
 
    local resultTab = {}
    for k,v in pairs(formationInfo) do
           -- print("getPillFormationInfo kkkk",k)
        if(table.isEmpty(v.localInfo))then
            v.localInfo = HeroUtil.getHeroLocalInfoByHtid(v.htid)
        end

        if  tonumber(v.localInfo.potential) >= 5 and 
            (tonumber(v.evolve_level) >= 1 or v.localInfo.star_lv >= 6 )then
            tmpTab = table.hcopy(v,{})
            --tmpTab.pillPosition = #resultTab +1
            tmpTab.pillPosition = k
            table.insert(resultTab,tmpTab)
        end
    end 
    return resultTab

end
function getPillHeroIndex(p_heroIndex,p_formationInfo)
    --print("getPillHeroIndex p_formationInfo",p_heroIndex)
    --print_t(p_formationInfo)
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