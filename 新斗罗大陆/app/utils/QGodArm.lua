-- @Author: liaoxianbo
-- @Date:   2019-12-23 14:37:54
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-11 12:17:46


local QBaseModel = import("..models.QBaseModel")
local QGodArm = class("QGodArm",QBaseModel)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIViewController = import("..ui.QUIViewController")
local QUIHeroModel = import("..models.QUIHeroModel")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QActorProp = import("..models.QActorProp")

QGodArm.EXP_ITEMS = {18100000,18100001,18100002}

QGodArm.GODARM_EVENT_UPDATE = "GODARM_EVENT_UPDATE"

function QGodArm:ctor(options)
	QGodArm.super.ctor(self)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._allGodarmList = {}     -- 所有神器
    self._godarmMap = {}     -- 神器map
    self._haveGodarmIdList = {}
end

function QGodArm:checkGodArmUnlock()
	return app.unlock:getUnlockGodarm(false)
end

function QGodArm:checkGodArmbBackPackItemNum()
    --     GODARM_CONSUM = 21, -- 神器消耗品
    -- GODARM_PIECE  = 22, -- 神器碎片
    -- GODARM_BOX = 23, -- 神器箱子  
    local itemTypes = {
        ITEM_CONFIG_CATEGORY.GODARM_CONSUM,
        ITEM_CONFIG_CATEGORY.GODARM_PIECE,
        ITEM_CONFIG_CATEGORY.GODARM_BOX,
    }
    local unlockLevel = app.unlock:getConfigByKey("UNLOCK_GOD_ARM").team_level
    if remote.user.level < unlockLevel - 5 then --神器背包如果有道具提前5级解锁
        return false
    end
    for _,key in pairs(itemTypes) do
        local items = db:getItemsByCategory(key)
        for _, value in pairs(items) do
            if remote.items:getItemsNumByID(value.id) > 0 then
                return true
            end
        end
    end

    return false
end

--创建时初始化事件
function QGodArm:didappear()
	QGodArm.super.didappear(self)
    if app.unlock:getUnlockGodarm() then
        self:init()
    end
end

function QGodArm:disappear()
	QGodArm.super.disappear(self)
end

function QGodArm:loginEnd()
end

function QGodArm:checkRedTips()
    if not self:checkGodArmUnlock() then
        return false
    end

    local allGodarmList = self:getAllGodarmList()

    for _, id in ipairs(allGodarmList) do
        if self:isGradeRedTipsById(id) then
            return true
        end
    end
    
    return false
end

function QGodArm:isGradeRedTipsById(id)
    local godarmInfo = self:getGodarmById(id)
    local grade = 0
    if godarmInfo then
        grade = godarmInfo.grade+1
    end
    local gradeConfig = db:getGradeByHeroActorLevel(id, grade)
    if gradeConfig ~= nil then
        local godarmCount = remote.items:getItemsNumByID(gradeConfig.soul_gem)
        if godarmCount >= gradeConfig.soul_gem_count then
            return true
        end
    end   
    return false
end

--获取所有暗器id
function QGodArm:init()
    self._allGodarmList = {}
    local characterConfig = db:getCharacter() or {}
    for _,value in pairs(characterConfig) do
        if value.npc_type == NPC_TYPE.GODARM and not db:checkHeroShields(value.id) then
            local gradeInfo = db:getGradeByHeroActorLevel(value.id, 0)
            if gradeInfo then
                table.insert(self._allGodarmList, value.id)
            end
        end
    end
end
function QGodArm:getHaveGodarmIdList()
	if next(self._haveGodarmIdList) == nil then
		for _,v in pairs(self._godarmMap) do
			table.insert(self._haveGodarmIdList, v.id)
		end

        table.sort( self._haveGodarmIdList, function(a, b)
            return a > b
        end)           
	end

	return self._haveGodarmIdList
end

function QGodArm:getAllGodarmList()
    if next(self._allGodarmList) == nil then
        self:init()
    end
    return self._allGodarmList
end

function QGodArm:getHaveGodarmList( )
	return  self._godarmMap
end

function QGodArm:getHaveGodarmListForBattle( )
    local armListInfo = {}
    for _,v in pairs(self._godarmMap) do
        table.insert(armListInfo, v.id..";"..(v.grade or 0))
    end
    return armListInfo
end

function QGodArm:getHaveGodarmLists( )
    local godArmMap = clone(self._godarmMap)
    local armListInfo = {}
    for _,v in pairs(godArmMap) do
        v.aptitude = nil 
        table.insert(armListInfo, v)
    end
    return armListInfo
end

--根据ID获取神器信息
function QGodArm:getGodarmById(godarmId)
    return self._godarmMap[godarmId]
end

--根据神器ID跟星级获取上阵技能战斗力
function QGodArm:getGodarmbattleForce( godarmId,grade )
    local force = 0
    local gradeConfig = db:getGradeByHeroActorLevel(godarmId, grade)
    if gradeConfig and gradeConfig.god_arm_skill_sz then
        local skillIds = string.split(gradeConfig.god_arm_skill_sz, ":")
        local skillData = db:getSkillDataByIdAndLevel(tonumber(skillIds[1]),tonumber(skillIds[2]))
        if skillData then
            force = skillData.battle_force or 0
        end
    end
    return force
end
--获取颜色根据神器ID
function QGodArm:getColorByGodarmId(godarmId)
    local characher = db:getCharacterByID(godarmId)
    local sabcInfo = db:getSABCByQuality(characher.aptitude)
    return string.upper(sabcInfo.color)
end

function QGodArm:getGodarmJobPath(joblabel)
    local iconPath = nil
    if joblabel == "毁灭" then
        iconPath = QResPath("godarm_job")[4]
    elseif joblabel == "生命" then
        iconPath = QResPath("godarm_job")[2]
    elseif joblabel == "邪恶" then
        iconPath = QResPath("godarm_job")[1]
    elseif joblabel == "善良" then
        iconPath = QResPath("godarm_job")[3]
    end

    return iconPath
end

function QGodArm:getGodarmJobBgPath(joblabel)
    local iconPath = nil
    if joblabel == "毁灭" then
        iconPath = QResPath("godarm_job_bg")[4]
    elseif joblabel == "生命" then
        iconPath = QResPath("godarm_job_bg")[2]
    elseif joblabel == "邪恶" then
      --  iconPath = QResPath("godarm_job_bg")[1] --这个版本不要
    elseif joblabel == "善良" then
       -- iconPath = QResPath("godarm_job_bg")[3] --这个版本不要
    end
    return iconPath
end

function QGodArm:getUIPropInfo(props)
    if props == nil then return {} end
    local prop = {}
    local index = 1
    if props.team_attack_value then
        prop[index] = {}
        prop[index].value = props.team_attack_value
        prop[index].name = "全  队  攻  击："
        index = index + 1
    end
    if props.team_hp_value then
        prop[index] = {}
        prop[index].value = props.team_hp_value
        prop[index].name = "全  队  生  命："
        index = index + 1
    end    
    if props.team_armor_physical or props.team_armor_magic then
        prop[index] = {}
        prop[index].value = props.team_armor_physical or props.team_armor_magic
        prop[index].name = "全队物防、法防："
        index = index + 1
    end    
    if props.team_attack_percent or props.team_hp_percent then
        prop[index] = {}
        prop[index].value = ((props.team_attack_percent or props.team_hp_percent)*100).."%"
        prop[index].name = "全队生命、攻击："
        index = index + 1
    end
    if props.team_armor_physical_percent or props.team_armor_magic_percent then
        prop[index] = {}
        prop[index].value = ((props.team_armor_physical_percent or props.team_armor_magic_percent)*100).."%"
        prop[index].name = "全队物防、法防："
        index = index + 1
    end
    return prop
end

function QGodArm:getPropDicByConfig(config, propDic)
    local returnTbl = propDic or {}
    for key, value in pairs(config or {}) do
        if QActorProp._field[key] then
            if returnTbl[key] then
                returnTbl[key] = returnTbl[key] + value
            else
                returnTbl[key] = value
            end
        end
    end

    return returnTbl
end

function QGodArm:getDelPropDicByConfig(oldConfig, newConfig)
    local returnTbl = {}
    for key, value in pairs(newConfig or {}) do
        if QActorProp._field[key] then
            if returnTbl[key] then
                returnTbl[key] = returnTbl[key]
            else
                returnTbl[key] = value
            end
        end
    end

    for key, value in pairs(oldConfig or {}) do
        if QActorProp._field[key] then
            if returnTbl[key] then
                returnTbl[key] = returnTbl[key] - value
            else
                returnTbl[key] = value
            end
        end
    end
    return returnTbl
end

function QGodArm:countForceByGodarmIds( godamIds )
    local force = 0
    for i, godarmId in pairs(godamIds) do
        local godarmInfo = self:getGodarmById(godarmId)
        if godarmInfo then
            force = force + godarmInfo.main_force
        end
    end
    return force
end

function QGodArm:updateGodarmList( godarmInfoList)
    for _, godarm in ipairs(godarmInfoList or {}) do
        local godarmConfig = db:getCharacterByID(godarm.id)
        godarm.aptitude = godarmConfig.aptitude

        self._godarmMap[godarm.id] = godarm
    end

    self._haveGodarmIdList = {}

    self:refreshCombinationProp()
    self:dispatchEvent({name = QGodArm.GODARM_EVENT_UPDATE})	
end

function QGodArm:refreshCombinationProp( ... )
    remote.herosUtil:validate()
    remote.herosUtil:updateHeros(remote.herosUtil.heros)
    remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})

    remote.herosUtil:updataMountCombinationProp()
end
--[[ 
    升级到指定的强化等级
    statusCode: 1 到最大等级 2 物品不足
]]
-- /**
--  * 道具对象
--  */
-- message Item {
--     required int32 type = 1; // 物品编号
--     required int32 count = 2; // 数量
--     optional int64 expireTime = 3; // 过期时间
-- }
function QGodArm:strengthToLevel(godarmId, level)
    print("QGodArm:strengthToLevel--godarmId,level-",godarmId,level)
    local godarmInfo = self:getGodarmById(godarmId)
    QPrintTable(godarmInfo)
    local maxLevel = remote.user.level * 2
    local targetLevel = math.min(level + godarmInfo.level, maxLevel)
    print("targetLevel=",targetLevel)
    if targetLevel == godarmInfo.level then --已经到最大等级
        return {statusCode = 1}
    end
    local needExp = - godarmInfo.exp
    local godarmConfig = db:getCharacterByID(godarmInfo.id)
    local aptitude = godarmConfig.aptitude
    for i=godarmInfo.level+1,(targetLevel) do
        local strengthConfig = db:getGodarmLevelConfigBylevel(aptitude, i)
        if strengthConfig ~= nil then
            needExp = needExp + (strengthConfig.strengthen_zuoqi or 0)
        end
    end
    -- print("strengthToLevel---",targetLevel)
    -- local strengthConfig = db:getGodarmLevelConfigBylevel(aptitude, targetLevel)
    -- if strengthConfig ~= nil then
    --     needExp = needExp + (strengthConfig.strengthen_zuoqi or 0)
    -- end
    print("needExp---",needExp)
    if needExp <= 0 then
        return {statusCode = 1}
    end

    local eatItems = {}
    local dropItemId = nil
    local eatTotalExp = 0
    for _, id in pairs(QGodArm.EXP_ITEMS) do
        local itemId = tonumber(id)
        if itemId ~= nil then
            dropItemId = itemId
            local itemConfig = db:getItemByID(itemId)
            local haveCount = remote.items:getItemsNumByID(itemId)
            print("itemId,haveCount--",itemId,haveCount)
            local needEatCount = math.ceil((needExp - eatTotalExp)/itemConfig.exp)
            local eatCount = math.min(haveCount, needEatCount)
            print("needExp,itemConfig.exp,needEatCount,eatCount",needExp,itemConfig.exp,needEatCount,eatCount)
            if eatCount > 0 then
                table.insert(eatItems, {type = itemId, count = eatCount})
                local eatExp = eatCount * itemConfig.exp
                eatTotalExp = eatTotalExp + eatExp
            end
            print("eatTotalExp==",eatTotalExp)
            if needExp <= eatTotalExp then
                break
            end
        end
    end
    if q.isEmpty(eatItems) then
        return {statusCode = 2, dropItemId = dropItemId}
    end
    local addLevel = 0
    eatTotalExp = eatTotalExp + (godarmInfo.exp or 0)
    -- local strengthConfig = db:getGodarmLevelConfigBylevel(aptitude, targetLevel)
    -- if strengthConfig ~= nil then
    --     if eatTotalExp >= (strengthConfig.strengthen_zuoqi or 0) then
    --         addLevel = addLevel + 1
    --         eatTotalExp = eatTotalExp - (strengthConfig.strengthen_zuoqi or 0)
    --     end
    -- end     

    for i=godarmInfo.level+1,targetLevel do
        local strengthConfig = db:getGodarmLevelConfigBylevel(aptitude, i)
        if strengthConfig ~= nil then
            if eatTotalExp >= (strengthConfig.strengthen_zuoqi or 0) then
                addLevel = addLevel + 1
                eatTotalExp = eatTotalExp - (strengthConfig.strengthen_zuoqi or 0)
            else
                break
            end
        else
            break
        end
    end
    print("eatTotalExp=222=",eatTotalExp)
    if addLevel == 0 then
        return {statusCode = 2, dropItemId = dropItemId}
    end
    return {eatItems = eatItems, addLevel = addLevel}
end
-- 神器删除
function QGodArm:_removeGodarms( idList )
    local idList = idList or {}
    local removeIndexList = {}
    for _, id in pairs(idList) do
        for index, godarmInfo in pairs(self._godarmMap) do
            if tonumber(id) == tonumber(godarmInfo.id) and tonumber(id) ~= nil then
                self._godarmMap[id] = {}
                table.insert(removeIndexList, index)
            end
        end
    end
    table.sort(removeIndexList, function(a, b)
            return a > b
        end)

    for k, index in ipairs(removeIndexList) do
        self._godarmMap[index] = nil
        table.remove(self._godarmMap, k)
    end
    self._haveGodarmIdList = {}
    self:refreshCombinationProp()
    self:dispatchEvent({name = QGodArm.GODARM_EVENT_UPDATE})           
end

-- /**
--  * 神像
--  */
-- message GodArm {
--     optional int32 id = 1; // id
--     optional int32 grade = 2; // 星级
--     optional int32 level = 3; // 等级
--     optional int64 exp = 4; // 经验
--     optional int64 force = 6; // 战力
-- }
-------------------------------------------协议请求-----------------------------------------------
--神器合成和升星
function QGodArm:godarmGradeUpRequest(godArmId, success, fail)
    local godArmGradeUpdateRequest = {godArmId = godArmId}
    local request = {api = "GOD_ARM_GRADE_UPDATE", godArmGradeUpdateRequest = godArmGradeUpdateRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--神器升级
function QGodArm:godarmLevelUpRequest(godArmId,items, success, fail)
    local godArmLevelUpdateRequest = {godArmId = godArmId,items = items}
    local request = {api = "GOD_ARM_LEVEL_UPDATE", godArmLevelUpdateRequest = godArmLevelUpdateRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--神器重生
function QGodArm:godarmRebornRequest(godArmId, success, fail)
    local godArmRebornRequest = {godArmId = godArmId}
    local request = {api = "GOD_ARM_REBORN", godArmRebornRequest = godArmRebornRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        response._id = godArmId
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--神器回收
function QGodArm:godarmReclyRequest(godArmId, success, fail)
    local godArmRecoverRequest = {godArmId = godArmId}
    local request = {api = "GOD_ARM_RECOVER", godArmRecoverRequest = godArmRecoverRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        response._id = godArmId
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--神器碎片回收
function QGodArm:godarmPiceRequest(items, success, fail)
    local godArmPieceRecoverRequest = {items = items}
    local request = {api = "GOD_ARM_PIECE_RECOVER", godArmPieceRecoverRequest = godArmPieceRecoverRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QGodArm:responseHandler(response,success,fail,succeeded)
	--神器数据更新
    if response.godArmList then
        self:updateGodarmList(response.godArmList)
    end

    if (response.api == "GOD_ARM_REBORN" or response.api == "GOD_ARM_RECOVER") and response.error == "NO_ERROR" then
        if response._id then
            self:_removeGodarms({response._id})
        end
    end

    if succeeded == true then
        if success ~= nil then
            success(data)
        end
    else
        if fail ~= nil then
            fail(data)
        end
    end
end
return QGodArm