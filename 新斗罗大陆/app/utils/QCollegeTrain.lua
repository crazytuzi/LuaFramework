-- @Author: liaoxianbo
-- @Date:   2019-11-13 12:24:01
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-27 12:10:40

local QBaseModel = import("..models.QBaseModel")
local QCollegeTrain = class("QCollegeTrain",QBaseModel)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIViewController = import("..ui.QUIViewController")
local QUIHeroModel = import("..models.QUIHeroModel")
local QNavigationController = import("..controllers.QNavigationController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QActorProp = import("..models.QActorProp")

QCollegeTrain.TEAM_INDEX_MAIN = 1 --主力战队
QCollegeTrain.TEAM_INDEX_HELP = 2 --援助战队1
QCollegeTrain.TEAM_INDEX_HELP2 = 3 --援助战队2 
QCollegeTrain.TEAM_INDEX_HELP3 = 4 --援助战队3 
QCollegeTrain.TEAM_INDEX_SKILL = 2 --援助战队1 
QCollegeTrain.TEAM_INDEX_SKILL2 = 3 --援助战队2
QCollegeTrain.TEAM_INDEX_SKILL3 = 4 --援助战队3 

function QCollegeTrain:ctor(options)
	QCollegeTrain.super.ctor(self)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
   	self._chapterInfo = {}
    self._chapterHeroInfo = {}
end

--创建时初始化事件
function QCollegeTrain:didappear()

end

function QCollegeTrain:disappear()
    self._chapterInfo = {}
    self._chapterHeroInfo = {}
end

function QCollegeTrain:getIsOpenCollegetTrain(showTips)
    return app.unlock:checkLock("UNLOCK_COLLEGE_TRAIN", showTips)
end

function QCollegeTrain:loginEnd()
    if self:getIsOpenCollegetTrain(false) then
        self:initChapterInfo()
        self:getMyCollegeTrainInfoRequest()
    end
end
function QCollegeTrain:openMainDialog()
    if not self:getIsOpenCollegetTrain(true) then
        return
    end

    -- if app.unlock:checkLock("UNLOCK_MOCK_BATTLE", false) then
    --     remote.mockbattle:mockBattleGetMainInfoRequest()
    -- end
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCollegeTrainMain"})
end
function QCollegeTrain:openCollegeTrainDialog( )
    if not self:getIsOpenCollegetTrain(true) then
        return
    end
    
    self:getCollegeTrainMainInfo(function()
        if next(self._chapterInfo) == nil then
            self:initChapterInfo()
        end
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCollegeTrainChapterLevel"})
    end)
    
end

function QCollegeTrain:openMockBattleEntranceDialog(callback)
    if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE", true) then
        return
    end
    app.sound:playSound("common_small")
    remote.mockbattle:mockBattleGetMainInfoRequest(function()
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMockBattleEntrance"})
        if callback then
            callback()
        end
    end)
end


function QCollegeTrain:initChapterInfo( )
    local collegeInfo = db:getCollegeTrainConfig() or {}
    local cloneCollegeInfo = clone(collegeInfo)
    self._chapterInfo = {}
    for _,v in pairs(cloneCollegeInfo) do
        if v.type == 1 then
            if self._chapterInfo[1] == nil then
                self._chapterInfo[1] = {}
            end
            table.insert(self._chapterInfo[1],v)
        elseif v.type == 2 then
            if self._chapterInfo[2] == nil then
                self._chapterInfo[2] = {}
            end
            table.insert(self._chapterInfo[2],v)            
        elseif v.type == 3 then
            if self._chapterInfo[3] == nil then
                self._chapterInfo[3] = {}
            end
            table.insert(self._chapterInfo[3],v)            
        end
    end
end

function QCollegeTrain:checkCollegeTrainRedTips()
    if not self:getIsOpenCollegetTrain(false) then
        return false
    end
    
    for i=1,3 do
        local checkIsAllFinsh = function( chapterTypeInfo )
            for _,chapter in pairs(chapterTypeInfo) do
                if chapter.finsh == nil or chapter.finsh == false then
                    return app:getUserOperateRecord():checkNewWeekCompareWithRecordeTime("college_train_tips",0)
                end
            end
        end
        if i==2 and app.unlock:checkLock("UNLOCK_COLLEGE_TRAIN_2") then
            checkIsAllFinsh(self._chapterInfo[2] or {})
        elseif i == 3 and app.unlock:checkLock("UNLOCK_COLLEGE_TRAIN_3") then
             checkIsAllFinsh(self._chapterInfo[3] or {})
        elseif i == 1 then
            checkIsAllFinsh(self._chapterInfo[1] or {})
        end

    end

    return false
end

function QCollegeTrain:checkChapterIdUnlock(id)
    local mapconfig = db:getCollegeTrainConfigById(id)
    local unlockIds = {}
    if mapconfig.unlock_dungeon_id == nil then
        return true
    end
    if mapconfig then
        unlockIds = string.split(mapconfig.unlock_dungeon_id, ";") or {}
    end

    for _,v in pairs(unlockIds) do
        if v ~= "" and v ~= nil then
            if not self:colleTrainIsPassed(v) then
                return false
            end
        end
    end

    return true
end

function QCollegeTrain:getChapterNameById(id)
    local chapterInfo = db:getCollegeTrainConfigById(id)
    if chapterInfo then
        local unlockInfo = db:getCollegeTrainConfigById(chapterInfo.unlock_dungeon_id)
        if unlockInfo then
            local dungeonConfig = db:getDungeonConfigByIntID(unlockInfo.dungeon_config)
            if dungeonConfig then
                return dungeonConfig.name or "上一关"
            end
        end
    end

    return "上一关"
end

function QCollegeTrain:colleTrainIsPassed(id )
    if id == nil or id == "" then 
        return false 
    end
    local getAwardsIds = {}
    if self._collegeMyInfo then
        getAwardsIds = self._collegeMyInfo.gotAwardId or {}
    end

    for _, award in pairs(getAwardsIds) do
        if tonumber(id) == tonumber(award) then
            return true
        end
    end
    return false
end

function QCollegeTrain:getChapterInfoByType( chapterType )
    local chapterinfo = self._chapterInfo[chapterType] or {}

    table.sort( chapterinfo, function(a,b)
        return tonumber(a.id) < tonumber(b.id)
    end)

    return chapterinfo
end

function QCollegeTrain:setSelectBtnIndex( index)
    self._selectBtnIndex = index
end

function QCollegeTrain:getMinChooseChapterBtnIndex(chapterType)

    if self._selectBtnIndex ~= nil then
        return self._selectBtnIndex
    end

    local chapterinfo = self:getChapterInfoByType(chapterType) or {}

    for index,v in pairs(chapterinfo) do
        if v.finsh == nil or v.finsh == false then
            return index
        end
    end

    return 1
end

function QCollegeTrain:initChapterHeroInfo(chapterid)
    self._chapterHeroInfo = {}
    local collegeInfo = db:getCollegeTrainConfigById(chapterid)
    local heroList = string.split(collegeInfo.hero_id, ",")
    for _,v in pairs(heroList) do
        if v then
            local heroInfo = {}
            local character = db:getCharacterByID(v)
            if character and character.aptitude == APTITUDE.SS then
               heroInfo.godSkillGrade = collegeInfo.god_skill or 0
            end
            heroInfo.actorId = tonumber(v)
            heroInfo.level = collegeInfo.hero1_level or 1
            heroInfo.breakthrough = collegeInfo.hero1_breakthrough
            heroInfo.grade = collegeInfo.hero1_grade
            heroInfo.equipments = self:initEquipment(v,collegeInfo)
            heroInfo.slots = self:initSkill(v,collegeInfo)
            local uiModel = QActorProp.new()
            uiModel:setHeroInfo(heroInfo, {})
            heroInfo.uiModel = uiModel 
            heroInfo.force = uiModel:getBattleForce(true)  
            table.insert(self._chapterHeroInfo,heroInfo)
        end
    end
end

function QCollegeTrain:getHeroInfoById(chapterid,actorId)
	if next(self._chapterHeroInfo)  == nil then
        self:initChapterHeroInfo(chapterid)
    end

    for _,v in pairs(self._chapterHeroInfo) do
        if tonumber(v.actorId) == tonumber(actorId) then
            return v
        end
    end
	return nil
end

function QCollegeTrain:getHeroModelById(chapterid,actorId)
    if next(self._chapterHeroInfo)  == nil then
        self:initChapterHeroInfo(chapterid)
    end

    for _,v in pairs(self._chapterHeroInfo) do
        if tonumber(v.actorId) == tonumber(actorId) then
            return v.uiModel
        end
    end
    return nil
end

function QCollegeTrain:getHeroListInfoById(chapterid)
	local collegeInfo = db:getCollegeTrainConfigById(chapterid)
	local heroList = string.split(collegeInfo.hero_id, ",")
	return heroList
end

function QCollegeTrain:getSpritListById( chapterid )
    local collegeInfo = db:getCollegeTrainConfigById(chapterid)
    local spritList = string.split(collegeInfo.soul_sprite_id, ",")
    local allSpritList = {}
    for _,v in pairs(spritList) do
        if v then
            local spritInfo = {}
            spritInfo.id = collegeInfo.soul_sprite_id
            spritInfo.exp = 0
            spritInfo.level = collegeInfo.soul_sprite_level
            spritInfo.grade = collegeInfo.soul_sprite_grade
            spritInfo.force = remote.soulSpirit:countForceBySpiritIds({collegeInfo.soul_sprite_id})
            table.insert(allSpritList,spritInfo)
        end
    end
    return allSpritList
end

-- level: 1
-- grade: 2
-- id: 2001
-- exp: 0
-- heroId: 1025
-- force: 91440
function QCollegeTrain:getSpritInfoById( chapterid,spritid)
    local collegeInfo = db:getCollegeTrainConfigById(chapterid)
    local spritList = string.split(collegeInfo.soul_sprite_id, ",")
    local spritInfo = {}
    for _,v in pairs(spritList) do
        if v and tonumber(v) ~= nil and tonumber(v) == tonumber(spritid) then
            spritInfo.id = collegeInfo.soul_sprite_id
            spritInfo.exp = 0
            spritInfo.level = collegeInfo.soul_sprite_level
            spritInfo.grade = collegeInfo.soul_sprite_grade - 1
            spritInfo.force = remote.soulSpirit:countForceBySpiritIds({collegeInfo.soul_sprite_id})
        end
    end
    return spritInfo
end

function QCollegeTrain:initEquipment(heroId,collegeInfo)
	local characterInfo = db:getCharacterByID(heroId)
	local breakConfig = db:getBreakthroughByTalentLevel(characterInfo.talent,collegeInfo.hero1_breakthrough) --突破配置表
	local equipments = {}
	table.insert(equipments,{level=collegeInfo.hero1_equip_enhance or 0,itemId=breakConfig.weapon,enhance_exp = 0,enchants=collegeInfo.hero1_equip_enchant or 0})
	table.insert(equipments,{level=collegeInfo.hero1_equip_enhance or 0,itemId=breakConfig.clothes,enhance_exp = 0,enchants=collegeInfo.hero1_equip_enchant or 0})
	table.insert(equipments,{level=collegeInfo.hero1_equip_enhance or 0,itemId=breakConfig.bracelet,enhance_exp = 0,enchants=collegeInfo.hero1_equip_enchant or 0})
	table.insert(equipments,{level=collegeInfo.hero1_equip_enhance or 0,itemId=breakConfig.shoes,enhance_exp = 0,enchants=collegeInfo.hero1_equip_enchant or 0})
	table.insert(equipments,{level=collegeInfo.hero1_jewelry_enhance or 0,itemId=breakConfig.jewelry1,enhance_exp = 0,enchants=collegeInfo.hero1_jewelry_enchant or 0})
	table.insert(equipments,{level=collegeInfo.hero1_jewelry_enhance or 0,itemId=breakConfig.jewelry2,enhance_exp = 0 ,enchants=collegeInfo.hero1_jewelry_enchant or 0})

	return equipments
end

function QCollegeTrain:initSkill(heroId,collegeInfo)
    local breakHeroConfig = db:getBreakthroughHeroByActorId(heroId) --突破数值表
    local skills = {}
    local index = 1
    if breakHeroConfig ~= nil then
        for _,value in pairs(breakHeroConfig) do
        	if tonumber(value.breakthrough_level) <= tonumber(collegeInfo.hero1_breakthrough) then
                for i=1,3 do
                    local slotId = value["skill_id_"..i]
                    if slotId ~= nil then
                        local slotInfo = db:getSkillByActorAndSlot(heroId,slotId)
                        if slotInfo then
                            skills[index] = {}
                            skills[index].slotId = slotId
                            skills[index].slotLevel = collegeInfo.hero1_level
                            index = index + 1
                        end
                    end                
                end

	        	local slotId = value.skill_id_4
	            if slotId ~= nil then
                    local slotInfo = db:getSkillByActorAndSlot(heroId,slotId)
                    if slotInfo then
    	            	skills[index] = {}
    	            	skills[index].slotId = slotId
    	            	skills[index].slotLevel = collegeInfo.hero1_level
                        index = index + 1
                    end
	            end
	        end
        end
    end

    return skills
end

function QCollegeTrain:getChooseChapterId()
    return self._chooseChapterId
end

function QCollegeTrain:setChooseChapterId(id)
    self._chooseChapterId = id
end

function QCollegeTrain:updateMyCollegeInfo( myinfo)
    self._collegeMyInfo = myinfo

    local getAwardsIds = {}
    local collegeTrainDungeonInfo = {}
    if self._collegeMyInfo then
        getAwardsIds = self._collegeMyInfo.gotAwardId or {}
        collegeTrainDungeonInfo = self._collegeMyInfo.collegeTrainDungeonInfo or {}
    end

    for _, award in pairs(getAwardsIds) do
            self:setChapterFinshByid(award)
    end


    for _, chapterInfo in pairs(collegeTrainDungeonInfo) do
            self:setChapterPassInfoByid(chapterInfo)
    end
end

-- message CollegeTrainDungeonInfo{
--     optional int32 dungeonId = 1; //评论对应的关卡
--     optional string firstUserNickname = 2; //最快玩家通关昵称
--     optional int32 firstUserPassTime = 3; //最快玩家通关时间
--     optional int32 myPassTime=4;//我的通关时间
-- }
function QCollegeTrain:setChapterFinshByid(finshId )

    for i=1,3 do
        if self._chapterInfo[i] then
            for _,v in pairs(self._chapterInfo[i]) do
                if tonumber(v.id) == tonumber(finshId) then
                    v.finsh = true
                end
            end
        end
    end
end

function QCollegeTrain:setChapterPassInfoByid( chapterInfo )
    for i=1,3 do
        if self._chapterInfo[i] then
            for _,v in pairs(self._chapterInfo[i]) do
                if tonumber(v.id) ~= nil and tonumber(v.id) == tonumber(chapterInfo.dungeonId) then
                    v.firstUserNickname = chapterInfo.firstUserNickname
                    v.firstUserPassTime = chapterInfo.firstUserPassTime
                    v.myPassTime = chapterInfo.myPassTime
                    v.isAllEnv = chapterInfo.isAllEnv
                end
            end
        end
    end
end
function QCollegeTrain:getCollegeMyInfo( )
    return self._collegeMyInfo 
end

-- 协议相关
-- 请求我的信息
function QCollegeTrain:getMyCollegeTrainInfoRequest(success, fail)
    local request = {api = "COLLEGE_TRAIN_GET_MY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:collegeTrainInfoResponse(response, success, nil, true)
    end, function (response)
        self:collegeTrainInfoResponse(response, nil, fail)
    end)
end

function QCollegeTrain:collegeTrainInfoResponse(data, success, fail, succeeded)
    if data.collegeTrainInfoResponse ~= nil then
        self:updateMyCollegeInfo(data.collegeTrainInfoResponse.myInfo)
    end
    self:responseHandler(data, success, fail, succeeded)
end

function QCollegeTrain:getCollegeTrainMainInfo(success, fail )
    local request = {api = "COLLEGE_TRAIN_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:collegeTrainInfoResponse(response, success, nil, true)
    end, function (response)
        self:collegeTrainInfoResponse(response, nil, fail)
    end)
end
-- 获取评论集合
function QCollegeTrain:getCollegeTrainCommentInfo(dungeonId,index,success, fail )
    local request = {api = "COLLEGE_TRAIN_GET_COMMENT_INFO",collegeTrainGetCommentRequest = {dungeonId=dungeonId,index = index}}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
-- message CollegeTrainAdmireRequest {
--     optional string admireId = 1; //点赞对应的id
--     optional int32 index = 2; //点赞对应的index
--     optional int32 dungeonId = 3; //评论对应的关卡
-- }

-- 点赞
function QCollegeTrain:collegeTrainAdmire(admireId,index,dungeonId,success, fail )
    print("admireId,index,dungeonId",admireId,index,dungeonId)
    local request = {api = "COLLEGE_TRAIN_ADMIRE",collegeTrainAdmireRequest = {admireId = admireId,dungeonId = dungeonId,index = index}}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 评论
function QCollegeTrain:collegeTrainComment(dungeonId,content,success, fail )
    local request = {api = "COLLEGE_TRAIN_COMMENT",collegeTrainDoCommentRequest = {dungeonId = dungeonId,content = content}}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--战斗开始
function QCollegeTrain:startCollegeTrainFightBattle(dungeonId,battleFormation,success, fail )
    local collegeTrainFightStartRequest = {dungeonId = dungeonId}
    local gfStartRequest = {battleType = BattleTypeEnum.COLLEGE_TRAIN, battleFormation = battleFormation,collegeTrainFightStartRequest = collegeTrainFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
-- 战斗结束
function QCollegeTrain:collegeTrainFightEndRequestServer(isWin,passTime,dungeonId,battleVerify,fightReportData,success, fail) --fightReportData,fightResult,battleVerify,success, fail)   
    local collegeTrainFightEndRequest = {passTime = passTime,dungeonId = dungeonId,isWin = isWin}
    local battleVerify = q.battleVerifyHandler(battleVerify)
    -- fightReportData = fightReportData,
    -- ,dungeonId = dungeonId, isWin = isWin,fightResult = fightResult, battleVerify=battleVerify
    local gfEndRequest = {battleType = BattleTypeEnum.COLLEGE_TRAIN, battleVerify = battleVerify, fightReportData=fightReportData,collegeTrainFightEndRequest = collegeTrainFightEndRequest}                                 
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
       self:collegeTrainFightEndResponse(response, success, nil, true)
    end, function (response)
        self:collegeTrainFightEndResponse(response, nil, fail)
    end)
end

-- 请求当前关通关前10名
function QCollegeTrain:getCollegeTrainTop10(dungeonId,success,fail)
    local request = {api = "COLLEGE_TRAIN_GET_DUNGEON_TOP_10",collegeTrainGetTopTenRequest = {dungeonId=dungeonId}}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:collegeTrainInfoResponse(response, success, nil, true)
    end, function (response)
        self:collegeTrainInfoResponse(response, nil, fail)
    end)
end
function QCollegeTrain:collegeTrainFightEndResponse(data, success, fail, succeeded)
    if data.collegeTrainInfoResponse ~= nil then 
        self:updateMyCollegeInfo(data.collegeTrainInfoResponse.myInfo)
    end
    self:responseHandler(data,success,fail, succeeded)
end

function QCollegeTrain:responseHandler(data, success, fail, succeeded)
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

return QCollegeTrain