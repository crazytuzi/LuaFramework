-- Filename：	AthenaData.lua
-- Author：		zhang zihang
-- Date：		2015-3-30
-- Purpose：		主角星魂数据层

module("AthenaData",package.seeall)

require "db/DB_Tree"
require "db/DB_Tree_skill"
require "db/DB_Normal_config"
require "db/DB_Vip"
require "db/skill"
require "db/DB_Awake_ability"
require "script/ui/item/ItemUtil"
require "script/model/hero/HeroModel"
 require "db/DB_Awake_ability"
kNormaoSkillType = 1    -- 普通技能
kAngrySkillType  = 2    -- 怒气技能
kAwakeSkillType  = 3    -- 觉醒技能

local _athenaInfo
local _curPage
local _starSoulNum
local _changeSkillInfo  = {}

local _remainItemInfo 				--剩余物品信息
local _cacheDataArr = {}            --缓存的属性信息 加速战斗力计算

-- 仅测试用
test_skillid = nil
test_mapid = nil
test_table = nil

--[[
	@des 	:设置星魂信息
	@param  :后端返回的星魂信息
--]]
function setAthenaInfo(p_athenaInfo)
    _athenaInfo = p_athenaInfo
end

--[[
	@des 	:开放的地图数量
	@return :开放的地图数量
--]]
function getOpenNum()
    return tonumber(_athenaInfo.tree_num)
end

--[[
	@des 	:得到最多可以预览到的页数
	@return :可以预览到的页数
--]]
function getPreviewNum()
    return (getOpenNum() + 2 > totalMapNum()) and totalMapNum() or (getOpenNum() + 2)
end

--[[
	@des 	:设置已开放的地图数量
	@param  :地图数量
--]]
function setOpenNum(p_num)
    _athenaInfo.tree_num = tonumber(p_num)
end

--[[
	@des 	:判断这个页面是否开启
	@param  :页面数
	@return :是否开启
--]]
function isThisPageOpen(p_pageNo)
    return tonumber(p_pageNo) <= getOpenNum()
end

--[[
	@des 	:得到总共的地图数量
	@return :总共的地图数量
--]]
function totalMapNum()
    return table.count(DB_Tree.Tree)
end

--[[
	@des 	:根据id得到相应的tree表数据
	@param  :id
	@return :数据
--]]
function getTreeDBInfo(p_id)
    return DB_Tree.getDataById(p_id)
end
--获取技能的类型 add by fuqiongqiong
function getSkillType( p_index )
    print("p_index",p_index)
    local itemInfo = getTreeDBInfo(p_index)
    return tonumber(itemInfo.type)
end
--[[
	@des 	:得到技能的等级
	@param  :地图id
	@param  :技能id
	@return :技能等级
--]]
function getSkillLv(p_mapId,p_skillId)
    print("p_mapId,p_skillId,==", p_mapId,p_skillId)
    test_skillid = p_skillId
    test_mapid = p_mapId
    local firstTable = _athenaInfo.detail[tostring(p_mapId)]
    print_t(firstTable)
    test_table = firstTable
    if table.isEmpty(firstTable) then
        print("=======firstTable is empty=========", p_mapId,p_skillId)
        return 0
    elseif firstTable[tostring(p_skillId)] == nil then
        return 0
    else
        return tonumber(firstTable[tostring(p_skillId)])
    end
end

--[[
	@des 	:得到技能信息
	@param  :技能string
	@return :得到这个图的技能table
--]]
function getSkillTable(p_skillString)
    return string.split(p_skillString,"|")
end

--[[
	@des 	:得到技能的db信息
	@param  :技能id
	@return :技能信息
--]]
function getSkillDBInfo(p_id)
    return DB_Tree_skill.getDataById(p_id)
end

--[[
	@des 	:得到当前所在页数
	@return :当前所在页数
--]]
function getCurPageNo()
    return _curPage
end

--[[
	@des 	:设置当前所在页数
	@param  :当前所在页数
--]]
function setCurPageNo(p_pageNum)
    _curPage = p_pageNum

    local keyString =  ServerList.getSelectServerInfo().group .. UserModel.getUserUid()
    CCUserDefault:sharedUserDefault():setIntegerForKey(keyString,_curPage)
end

--[[
	@des 	:技能是否开启
	@param  :技能id
	@return :true 或 false
--]]
function isSkillOpen(p_skillId,p_pageNo)
    local isOpen = false
    --如果界面没有开
    if not isThisPageOpen(p_pageNo) then
        return false
    end

    local skillConditionTable = getUnlockSkillInfo(p_skillId)

    if #skillConditionTable == 0 then
        return true
    end

    for i = 1,#skillConditionTable do
        local firstInfo = skillConditionTable[i]
        local skillLv = getSkillLv(p_pageNo,firstInfo.skill)
        if skillLv >= firstInfo.lv then
            return true
        end
    end

    return isOpen
end

--[[
	@des 	:开启该技能需要的解锁条件
	@param  :技能id
	@return :解锁条件
--]]
function getUnlockSkillInfo(p_skillId)
    local returnTable = {}
    local skillInfo = getSkillDBInfo(p_skillId)
    local skillConditionTable = string.split(skillInfo.ex_skill,",")
    for i = 1,#skillConditionTable do
        local firstInfo = skillConditionTable[i]
        local secTable = string.split(firstInfo,"|")
        local innerTable = {}
        innerTable.skill = tonumber(secTable[1])
        innerTable.lv = tonumber(secTable[2])
        table.insert(returnTable,innerTable)
    end

    return returnTable
end

--[[
	@des 	:得到星魂数量
	@return :星魂数
--]]
function getStarSoulNum()
    local itemTid = getFinalItemId()

    return getRemainItemNum(itemTid)
        --return ItemUtil.getCacheItemNumBy(itemTid)
end

--[[
	@des 	:添加星魂数量
	@param  :增加的星魂数
--]]
function addStarSoulNum(p_soulNum)
    local itemTid = getFinalItemId()
    addRemainItemNum(itemTid,p_soulNum)
end

--[[
	@des 	:添加物品
	@param  :物品id
	@param  :物品数量
--]]
function addRemainItemNum(p_itemTid,p_itemNum)
    local itemTid = tonumber(p_itemTid)
    _remainItemInfo[itemTid] = _remainItemInfo[itemTid] + tonumber(p_itemNum)
end

--[[
	@des 	:得到剩余物品信息
	@param  :物品模板id
	@return :剩余物品数量
--]]
function getRemainItemNum(p_itemTid)
    local itemTid = tonumber(p_itemTid)
    if _remainItemInfo[itemTid] == nil then
        _remainItemInfo[itemTid] = tonumber(ItemUtil.getCacheItemNumBy(itemTid))
    end

    return _remainItemInfo[itemTid]
end

--[[
	@des 	:得到剩余物品信息
	@param  :物品模板id
	@return :剩余物品数量
--]]
function costItem(p_itemTid,p_pageNo)
    local costTable = getCostItemInfo(p_itemTid,p_pageNo)
    --对于所有不是银币的物品而言
    for k,v in pairs(costTable) do
        if k ~= 0 then
            --删除物品数量
            addRemainItemNum(k,-v)
        end
    end
end

--[[
	@des 	:清除剩余物品信息
--]]
function initRemainItemInfo()
    _remainItemInfo = {}
end

--[[
	@des 	:判断升级所需物品是否足够
	@param  :技能id
	@return :true 或 false
--]]
function isGoodEnough(p_id,p_curPage)
    local costTable = getCostItemInfo(p_id,p_curPage)

    local isEnough = true

    --对于所有的消耗
    for k,v in pairs(costTable) do
        if k == 0 then
            if UserModel.getSilverNumber() < v then
                return false
            end
        else
            --if ItemUtil.getCacheItemNumBy(k) < v then
            if getRemainItemNum(k) < v then
                return false
            end
        end
    end

    return isEnough
end

--[[
	@des 	:得到升级消耗的物品信息
	@param  :技能id
	@return :信息
--]]
function getCostItemInfo(p_id,p_curPage)
    local skillLv = getSkillLv(p_curPage,p_id)
    local skillInfo = getSkillDBInfo(p_id)

    local nextLv = skillLv + 1

    local returnTable = {}

    local costTable = string.split(skillInfo["up_cost" .. nextLv],",")
    for i = 1,#costTable do
        local costInfo = costTable[i]
        local detailInfo = string.split(costInfo,"|")
        returnTable[tonumber(detailInfo[2])] = tonumber(detailInfo[3])
    end

    return returnTable
end

--[[
	@des 	:判断是否满级
	@param  :技能id
	@return :true 或 false
--]]
function isFullLv(p_id,p_curPage)
    local skillLv = getSkillLv(p_curPage,p_id)
    local skillInfo = getSkillDBInfo(p_id)
    return skillLv >= tonumber(skillInfo.maxLevel)
end

--[[
	@des 	:消耗银币
	@param  :技能id
--]]
function costSilver(p_id,p_curPage)
    local costInfo = getCostItemInfo(p_id,p_curPage)
    local costNum = costInfo[0] or 0
    UserModel.addSilverNumber(-costNum)
end

--[[
	@des 	:通过技能id和等级得到属性信息
	@param  :技能id
	@param  :技能等级
	@return :技能信息
--]]
function getAtrrInfo(p_id,p_lv)
    local itemInfo = getSkillDBInfo(p_id)
    local skillTable = string.split(itemInfo.affixGrow,",")
    local returnTable = {}
    for i = 1,#skillTable do
        local innerTable = {}
        local secTable = string.split(skillTable[i],"|")
        innerTable.id = tonumber(secTable[1])
        innerTable.realNum = tonumber(secTable[2])*tonumber(p_lv)
        local atrrInfo,showNum = ItemUtil.getAtrrNameAndNum(innerTable.id,innerTable.realNum)
        innerTable.showNum = showNum
        innerTable.name = atrrInfo.godarmName
        table.insert(returnTable,innerTable)
    end

    return returnTable
end

--[[
	@des 	:为战斗力提供的属性信息
	@param  : p_isForce 是否重新计算属性
	@return :属性信息
--]]
function getAtrrInfoForFightForce(p_isForce)
    local returnTable = {}

    local hid = tonumber(HeroModel.getNecessaryHero().hid)
    if(p_isForce ~=true and _cacheDataArr[hid] ~= nil)then
        return _cacheDataArr
    end
    local detailTable = {}
    returnTable[hid] = getAcquireSkillInfo()
    _cacheDataArr[hid] = returnTable[hid]
    return returnTable
end

--[[
	@des 	:得到已经获得的属性
	@return :属性信息
--]]
function getAcquireSkillInfo()
    local detailTable = {}
    if not (DataCache.getSwitchNodeState(ksSwitchStarSoul,false)) then
        return detailTable
    end
    --在进入游戏的时候没有拉取，可是升级后，功能节点开了
    --这时候还是没有数据的，所以判断下
    if _athenaInfo == nil then
        return detailTable
    end

    for k_1,v_1 in pairs(_athenaInfo.detail) do
        for k,v in pairs(v_1) do
            local itemInfo = getSkillDBInfo(k)
            local skillTable = string.split(itemInfo.affixGrow,",")
            for i = 1,#skillTable do
                local secTable = string.split(skillTable[i],"|")
                local id  = tonumber(secTable[1])
                local num = tonumber(secTable[2])*tonumber(v)
                if detailTable[id] == nil then
                    detailTable[id] = num
                else
                    detailTable[id] = detailTable[id] + num
                end
            end
        end
    end

    return detailTable
end

--[[
	@des 	:得到属性预览里面的属性
	@return :属性信息
--]]
function getSkillPreviewInfo()
    local atrrInfo = getAcquireSkillInfo()
    local returnTable = {}
    local affixTable = string.split(DB_Normal_config.getDataById(1).starAffix,",")
    for k,v in ipairs(affixTable) do
        local affix = {}
        local tempAffix = nil
        affix.name = DB_Affix.getDataById(v).godarmName
        if(atrrInfo[tonumber(v)] == nil) then
            affix.value = 0
        else
            tempAffix, affix.value = ItemUtil.getAtrrNameAndNum(v,tonumber(atrrInfo[tonumber(v)]))
            affix.value = affix.value or 0
        end
        table.insert(returnTable, affix)
    end

    return returnTable
end

--[[
	@des 	:设置技能级别
	@param  :技能id
	@param  :技能等级
--]]
function setSkillLv(p_id,p_lv)
    if _athenaInfo.detail[tostring(_curPage)] == nil then
        _athenaInfo.detail[tostring(_curPage)] = {}
    end

    _athenaInfo.detail[tostring(_curPage)][tostring(p_id)] = tonumber(p_lv)
end

--[[
	@des 	:得到特殊技能信息
	@param  :技能id
    @param  :pSkillType 技能类型
	@return :创建好的按钮
--]]
function getSSDBInfo(p_skillId,pSkillType)
    pSkillType = pSkillType or kNormaoSkillType
    local info = nil
    if (pSkillType == kNormaoSkillType or pSkillType == kAngrySkillType) then
        -- 普通技能 or 怒气技能
        info = skill.getDataById(p_skillId)
        if info == nil then
           info = DB_Awake_ability.getDataById(p_skillId) 
        end
    elseif(pSkillType == kAwakeSkillType) then
        -- 觉醒技能
        info = DB_Awake_ability.getDataById(p_skillId)
    end
    return info
end
--[[
	@des 	:得到觉醒信息
	@param  :技能id
	@return :
--]]
function getAwakeDBInfo(p_skillId)
    return DB_Awake_ability.getDataById(p_skillId)
end
--[[
	@des 	:该页特殊技能是否开启
	@param  :页数
	@return :true 或 false
--]]
function isSSOpen(p_pageNo)
    local isOpen = false
    local skillConditionTable = getUnlockSSInfo(p_pageNo)

    if #skillConditionTable == 0 then
        return true
    end

    for i = 1,#skillConditionTable do
        local firstInfo = skillConditionTable[i]
        local skillLv = getSkillLv(p_pageNo,firstInfo.skill)
        if skillLv >= firstInfo.lv then
            return true
        end
    end

    return isOpen
end

--[[
	@des 	:开启该技能需要的解锁条件
	@param  :技能id
	@return :解锁条件
--]]
function getUnlockSSInfo(p_pageNo)
    local returnTable = {}
    local skillInfo = getTreeDBInfo(p_pageNo)
    local skillConditionTable = string.split(skillInfo.open_need,",")
    for i = 1,#skillConditionTable do
        local firstInfo = skillConditionTable[i]
        local secTable = string.split(firstInfo,"|")
        local innerTable = {}
        innerTable.skill = tonumber(secTable[1])
        innerTable.lv = tonumber(secTable[2])
        table.insert(returnTable,innerTable)
    end

    return returnTable
end

--[[
	@des 	:设置可以更换的技能信息
	@param  :技能信息
--]]
function setAthenaSkillInfo(p_skillInfo)
    _changeSkillInfo = p_skillInfo
end

--[[
	@des 	:添加新学会的特殊技能到缓存
	@param  :页数
--]]
function addSSkill(p_pageNo)
    local curPageInfo = getTreeDBInfo(p_pageNo)
    local skillType = tonumber(curPageInfo.type)
    local skillIdTab = getSSkillId(curPageInfo)
    if (table.isEmpty(skillIdTab))then return end
    if skillType == 1 then
        if _changeSkillInfo.normal == nil then
            _changeSkillInfo.normal = {}
        end
        for i=1,#skillIdTab do
            table.insert(_changeSkillInfo.normal,skillIdTab[i])
        end

    else
        if _changeSkillInfo.rage == nil then
            _changeSkillInfo.rage = {}
        end
        for i=1,#skillIdTab do
            table.insert(_changeSkillInfo.rage,skillIdTab[i])
        end
    end
end

--[[
	@des 	:得到特殊技能id
	@param  :树信息
	@return :技能id
--]]
function getSSkillId(p_treeInfo)
    local firstTable = string.split(p_treeInfo.skill_id,",")
    local resultTab = {}
    if(p_treeInfo.skill_id ~= nil )then
        for i = 1,#firstTable do
        local secondTable = string.split(firstTable[i],"|")
            if tonumber(secondTable[1]) ~= tonumber(UserModel.getUserSex()) then
                for j=2,#secondTable do
                    table.insert(resultTab,tonumber(secondTable[j]) )
                end
            end
        end
    else
    resultTab[1] = p_treeInfo.awake_ability
    end 
    print("resultTab")
    print_t(resultTab)
    return resultTab
end

--[[
	@des 	:得到星魂普通技能
	@return :普通技能信息
--]]
function getAthenaNormalSkill()
    return _changeSkillInfo.normal or {}
end

--[[
	@des 	:得到星魂怒气技能
	@return :怒气技能信息
--]]
function getAthenaRangeSkill()
    return _changeSkillInfo.rage or {}
end

--[[
	@des 	:得到合成材料已购买次数
	@param  :物品id
	@return :购买次数
--]]
function getComposeItemNum(p_itemId)
    return tonumber(_athenaInfo.buy_num[tostring(p_itemId)]) or 0
end

--[[
	@des 	:得到合成材料已购买次数
	@return :合成材料购买信息
--]]
function getCanComposeInfo()
    local vipNum = UserModel.getVipLevel()
    local dbInfo = DB_Vip.getDataById(vipNum + 1)
    local itemInfo = dbInfo.AthenaBuyNum
    local buyTable = string.split(itemInfo,",")
    local returnTable = {}
    for i = 1,#buyTable do
        local innerTable = string.split(buyTable[i],"|")
        returnTable[tostring(innerTable[1])] = tonumber(innerTable[2])
    end

    return returnTable
end

--[[
	@des 	:增加合成材料购买次数
	@param  :物品模板id
	@param  :新增购买数量
--]]
function addCopmoseItemNum(p_itemId,p_num)
    local curItemNum = tonumber(_athenaInfo.buy_num[tostring(p_itemId)])
    if curItemNum == nil then
        _athenaInfo.buy_num[tostring(p_itemId)] = tonumber(p_num)
    else
        _athenaInfo.buy_num[tostring(p_itemId)] = curItemNum + tonumber(p_num)
    end
end

--[[
	@des 	:得到解析后的合成所需物品信息
	@return :合成所需物品信息
--]]
function getDeCodeComposeItemInfo()
    local configInfo = DB_Normal_config.getDataById(1)
    local itemString = configInfo.formula
    return analyseString(itemString)
end

--[[
	@des 	:解析string
	@param  :string
	@return :解析后的string
--]]
function analyseString(p_string)
    return ItemUtil.getItemsDataByStr(p_string)
end

--[[
	@des 	:处理并返回处理后的合成物品信息
	@param  :合成信息
	@return :处理后的信息
--]]
function dealAndGetComposeInfo(p_composeInfo)
    -- Carry  14:20:02
    -- 佳林，星魂合成的时候，你都会配什么类型，只有物品吗
    -- Carry  14:20:08
    -- 还是会有金银币啥的
    -- 蒯佳林  14:20:25
    -- 只有物品
    -- Carry  14:20:37
    -- 好哒
    -- Carry  14:20:48
    -- 说好了哦
    -- 蒯佳林  14:20:56
    -- 恩

    --可以合成的信息
    local canComposeInfo = getCanComposeInfo()

    local returnTable = {}
    for i = 1,#p_composeInfo do
        local innerTable = {}
        local composeInfo = p_composeInfo[i]
        innerTable.tid = tonumber(composeInfo.tid)
        innerTable.needNum = tonumber(composeInfo.num)
        local haveNum = ItemUtil.getCacheItemNumBy(innerTable.tid)
        innerTable.haveNum = tonumber(haveNum)
        innerTable.isEnough = (innerTable.haveNum >= innerTable.needNum)
        innerTable.canNum = canComposeInfo[tostring(composeInfo.tid)] - getComposeItemNum(innerTable.tid)
        table.insert(returnTable,innerTable)
    end

    return returnTable
end

--[[
	@des 	:得到最大合成次数
	@param  :合成信息
	@return :最大合成次数
--]]
function getMaxComposeNum(p_composeInfo)
    local maxNum = 9999999
    for i = 1,#p_composeInfo do
        local composeInfo = p_composeInfo[i]
        local haveNum = ItemUtil.getCacheItemNumBy(composeInfo.tid)
        local needNum = tonumber(composeInfo.num)
        local canNum = math.floor(haveNum/needNum)
        if canNum < maxNum then
            maxNum = canNum
        end
    end

    local returnNum = maxNum*getFinalItemNum()

    return returnNum
end

--[[
	@des 	:得到最终合成的物品id
	@return :物品id
--]]
function getFinalItemId()
    return tonumber(analyseFormularNum()[1])
end

--[[
	@des 	:得到最终合成的物品数量
	@return :物品数量
--]]
function getFinalItemNum()
    return tonumber(analyseFormularNum()[2])
end

--[[
	@des 	:解析合成物品
	@return :解析后的字段
--]]
function analyseFormularNum()
    local configInfo = DB_Normal_config.getDataById(1)
    return string.split(configInfo.formula_item,"|")
end

--[[
	@des 	:得到购买物品的单价
	@return :单价
--]]
function getComposePrice(p_tid)
    local configInfo = DB_Normal_config.getDataById(1)
    local priceTable = string.split(configInfo.formula_price,",")
    for i = 1,#priceTable do
        local secTable = string.split(priceTable[i],"|")
        if tonumber(secTable[1]) == tonumber(p_tid) then
            return tonumber(secTable[2])
        end
    end
end

--[[
	@des 	:得到下一棵树
	@param  :页数
	@return :下一棵树id
--]]
function getNextTree(p_index)
    return getTreeDBInfo(p_index).next_tree
end

--[[
	@des 	:得到升级信息
	@param  :页数
	@return :下一棵树id
--]]
function getLevelUpAddAtrr(p_id)
    local itemInfo = getSkillDBInfo(p_id)
    local skillTable = string.split(itemInfo.affixGrow,",")
    local returnTable = {}
    for i = 1,#skillTable do
        local innerTable = {}
        local secTable = string.split(skillTable[i],"|")
        local atrrInfo,showNum = ItemUtil.getAtrrNameAndNum(tonumber(secTable[1]),tonumber(secTable[2]))
        innerTable.num = tonumber(secTable[2])
        innerTable.showNum = showNum
        innerTable.txt = atrrInfo.godarmName
        table.insert(returnTable,innerTable)
    end

    return returnTable
end

--[[
	@des 	:得到当前userDefault里记录的当前页面
	@return :当前页面
--]]
function getCacheCurPageNo()
    local keyString =  ServerList.getSelectServerInfo().group .. UserModel.getUserUid()
    local returnNum
    if tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey(keyString)) == 0 then
        returnNum = 1
        CCUserDefault:sharedUserDefault():setIntegerForKey(keyString,returnNum)
    else
        returnNum = tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey(keyString))
    end

    --这种情况只会在线下测试清数据的情况下出现
    if returnNum > getOpenNum() then
        returnNum = getOpenNum()
        CCUserDefault:sharedUserDefault():setIntegerForKey(keyString,returnNum)
    end

    return returnNum
end

--[[
	@des 	:主角等级是否满足
	@param  :当前页数
	@return :是否
--]]
function isHeroLvEnough(p_pageNo)
    return UserModel.getHeroLevel() >= getTreeDBInfo(p_pageNo).level
end

--[[
	@des 	:得到普通技能列表（整理成需要的数据格式，用于创建更换技能界面）
	@return :
--]]
function getNormalSkillList()
    local skillList = {}
    local athenaSkill = AthenaData.getAthenaNormalSkill()
    local db_hero = DB_Heroes.getDataById(UserModel.getAvatarHtid())
    local personSkillId = tonumber(db_hero.normal_attack)

    if(table.isEmpty(athenaSkill) == false)then
        --athenaSkill = table.hcopy(athenaSkill,{})
        local count = table.count(skillList)
        for k,v in pairs(athenaSkill) do
            if(tonumber(v) ~= 0)then
                count = count + 1
                skillList[count] = {}
                skillList[count].feel_skill = tonumber(v)
                if(skillList[count].feel_skill == personSkillId)then
                    --星魂的开启的时候，会有赠送技能，赠送的技能里面包括自己本身的技能
                    skillList[count].from = 0
                else
                    skillList[count].from = 2
                end

            end
        end
    else
        --还没有开启星魂 但是自己本身会有一个表里的普通技能
        skillList[1] = {}
        skillList[1].feel_skill = personSkillId
        skillList[1].from = 0
    end


    local curSkill,fromType  = UserModel.getUserNormalSkill()
    curSkill = tonumber(curSkill)
    fromType = tonumber(fromType)

    local doubleTab = {}
    local userGender = UserModel.getUserSex()
    local skillMap = getSkillMap(userGender)
    local isOnTag = 0 --记录第几个位置存放了正在装备的技能
    local resTab = {} --最后的返回结果
    local defaultRankId = -1
    --开始将结果排序
    for i=1,#skillList do
        local tmpDoubleTab = {}

        if(not skillList[i].isSelected)then
            if(skillList[i].feel_skill == curSkill and skillList[i].from == fromType)then
                skillList[i].isOn = true
                isOnTag = #doubleTab + 1
            end


            --当前这个技能还没被接入doubleTab中
            tmpDoubleTab[1] = skillList[i]
            skillList[i].isSelected = true

            if not table.isEmpty( skillMap[tostring(skillList[i].feel_skill)] ) then
                local friendId = skillMap[tostring(skillList[i].feel_skill)].skill_id
                if(friendId ~= nil)then
                    --如果找到可配对技能
                    tmpDoubleTab.rankId = skillMap[tostring(skillList[i].feel_skill)].dbId
                    --先获取排序的权重
                    for k,v in pairs(skillList)do
                        if v.feel_skill == friendId then
                            if(v.feel_skill == curSkill and v.from == fromType)then
                                v.isOn = true
                                isOnTag = #doubleTab + 1
                            end
                            v.isSelected = true
                            tmpDoubleTab[2] = v
                        end
                    end
                end
            else
                --排序权重靠后赋值
                tmpDoubleTab.rankId = defaultRankId
                defaultRankId = defaultRankId -1
            end
            table.insert(doubleTab,tmpDoubleTab)
        end

    end

    if(isOnTag ~= 0)then
        local onTab = doubleTab[isOnTag]

        if onTab[1].feel_skill == curSkill then
            table.insert(resTab,onTab[1])
            if not table.isEmpty(onTab[2]) then
                table.insert(resTab,onTab[2])
            end
        elseif onTab[2].feel_skill == curSkill then
            table.insert(resTab,onTab[2])
            table.insert(resTab,onTab[1])
        end

        table.remove(doubleTab,isOnTag)
    end
    table.sort(doubleTab,doubleRankSort)
    for k,v in pairs(doubleTab) do
        table.insert(resTab,v[1])
        if not table.isEmpty(v[2])  then
            table.insert(resTab,v[2])
        end
    end
    return resTab
end
function doubleRankSort(goods_1,goods_2 )

    if(tonumber(goods_1.rankId) > tonumber(goods_2.rankId))then
        return true
    elseif(tonumber(goods_1.rankId) == tonumber(goods_2.rankId) or tonumber(goods_1.rankId) < tonumber(goods_2.rankId))then
        return false
    end
end
--得到DB_Tree的技能map
--参数是主角性别
function getSkillMap(p_gender )
    local p_gender = tonumber(p_gender)
    local resTab = {}
    for k_id,v_list in pairs(DB_Tree.Tree) do
        --遍历DB_Tree表

        local skillStr = v_list[4]

        --取出字段
        skillStr = string.split(skillStr,",")
        for k,v in pairs(skillStr) do
            --判断性别
            local skillList = string.split(v,"|")

            if(tonumber(skillList[1]) ~= p_gender)then
                --尼玛策划把表的性别配反了你敢信？！！！！！！！ 而且这个排序需求是中途加的 原始开发的时候前后端都是按照反的开发的。。。。。真是够了 所以这里也要反着用
                --互相map
                resTab[skillList[2]] = {}
                resTab[skillList[2]].skill_id = tonumber(skillList[3])
                resTab[skillList[2]].dbId = v_list[1]
                resTab[skillList[3]] = {}
                resTab[skillList[3]].skill_id = tonumber(skillList[2])
                resTab[skillList[3]].dbId = v_list[1]
                break
            end
        end

    end
    return resTab
end
--[[
    @des    :交换一个表中的两个位置的值
    @param  :
    @return :
--]]
function swap(table, indexA, indexB)
    local temp = table[indexA]
    table[indexA] = table[indexB]
    table[indexB] = temp
end

