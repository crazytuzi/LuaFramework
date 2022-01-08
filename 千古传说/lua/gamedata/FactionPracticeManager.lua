--[[
******帮派修炼场管理类*******
	-- quanhuan
	-- 2016/1/8
]]


local FactionPracticeManager = class("FactionPracticeManager")

FactionPracticeManager.startPracticeSucess = 'FactionPracticeManager.startPracticeSucess'
FactionPracticeManager.endPracticeSucess = 'FactionPracticeManager.endPracticeSucess'
FactionPracticeManager.inheritanceSucess = 'FactionPracticeManager.inheritanceSucess'
FactionPracticeManager.studySucess = 'FactionPracticeManager.studySucess'
--FactionPracticeManager.practiceSucess = "FactionPracticeManager.practiceSucess"
function FactionPracticeManager:ctor()

    --修炼场信息
    TFDirector:addProto(s2c.GUILD_PRACTICE_INFOS, self, self.onGuildPracticeInfo)
    --修炼场研究成功
    TFDirector:addProto(s2c.STUDY_SUCESS , self, self.onStudySucess)
    --开始修炼
    TFDirector:addProto(s2c.START_PRACTICE_SUCESS, self, self.onStartPracticeSucess)
    --结束修炼
    TFDirector:addProto(s2c.END_PRACTICE_SUCESS, self, self.onEndPracticeSucess)
    --传承成功
    TFDirector:addProto(s2c.INHERITANCE_SUCESS, self, self.onInheritanceSucess)
	--所有角色修炼属性 服务器推送
    TFDirector:addProto(s2c.PLAYER_PRACTICE_INFOS, self, self.onPlayerPracticeInfo)

    self:restart()
end

function FactionPracticeManager:restart()
    self.guildPracticeInfo = {}
    self.practiceHouseCard = {}
    self.firstTimeInPractice = nil
end

function FactionPracticeManager:openPracticeInheritLayer()
	local layer  = require("lua.logic.factionPractice.PracticeInherit"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE) 
    layer:dataReady()   
    AlertManager:show()
end

function FactionPracticeManager:openFactionPracticeLayer()
	local layer  = require("lua.logic.factionPractice.FactionPractice"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE) 
    layer:dataReady()   
    AlertManager:show()
end

function FactionPracticeManager:getHouseInfoById( house_id )
--[[
    -state                  是否开启
    -openLimit              开启条件
    -gmId                   正在修炼的侠客
    -headImg                侠客图像
    -skillName              修炼的技能名称
    -complete               修炼剩余时间
    -completeTotal          修炼总时间
    -sycee                  完成需要消耗的元宝
]]    
    local serverData = self.practiceHouseCard[house_id] or {}

    local teamLevel = MainPlayer:getLevel() or 0
    local factionInfo = FactionManager:getFactionInfo() or {}
    local guildLevel = factionInfo.level or 0

    local HouseDetailData = {}
    HouseDetailData.state = GuildPracticePosData:isOpen(house_id, teamLevel, guildLevel)
    HouseDetailData.gmId = serverData.instanceId or 0
    HouseDetailData.openLimit = GuildPracticePosData:getOpenDescr( house_id )
    local cardRole = CardRoleManager:getRoleByGmid(HouseDetailData.gmId)
    if cardRole then
        HouseDetailData.headImg = cardRole:getHeadPath()
        local attributeLevel = cardRole:getFactionPracticeLevelByType( serverData.attributeType ) + 1
        local practiceInfo = GuildPracticeData:getPracticeInfoByTypeAndLevel(serverData.attributeType, attributeLevel,cardRole.outline) or {}
        local studyInfo = GuildPracticeStudyData:getPracticeInfoByTypeAndLevel(serverData.attributeType, attributeLevel) or {}
        print('studyInfo = ',studyInfo)
        HouseDetailData.skillName = practiceInfo.title or ""
        local nowTime = MainPlayer:getNowtime()
        HouseDetailData.completeTotal = studyInfo.time
        if serverData.practiceTime and serverData.practiceTime ~= 0 then
            HouseDetailData.complete = (math.floor(serverData.practiceTime/1000) + studyInfo.time) - nowTime
        else
            HouseDetailData.complete = 0
        end
        if HouseDetailData.complete < 0 then
            HouseDetailData.complete = 0
        end        
        HouseDetailData.outline = cardRole.outline 
        HouseDetailData.quality = cardRole.quality
        HouseDetailData.sycee = 0
    else
        HouseDetailData.gmId = 0
    end

    return HouseDetailData
end

--进入修炼场
function FactionPracticeManager:enterXiulianCLayer()
    local openLevel = self:getPracticeOpenLevel()
    if openLevel == 0 then
        -- toastMessage("即将开放，敬请期待！")
        toastMessage(localizable.common_function_will_open)
        return
    elseif FactionManager.factionInfo.level < openLevel then
        -- local str = TFLanguageManager:getString(ErrorCodeData.Field_Open_Level)
        -- str = string.format(str,openLevel)
        local str = stringUtils.format(localizable.Field_Open_Level, openLevel)

        toastMessage(str)
        return
    end    
    self:requestGuildPracticeInfo(true) 
end

function FactionPracticeManager:requestGuildPracticeInfo(isOpenLayer)
    --修炼场信息

    self.guildPracticeInfoOpenLayer = isOpenLayer
    TFDirector:send(c2s.GUILD_PRACTICE_INFO,{})
    showLoading();
end
function FactionPracticeManager:onGuildPracticeInfo( event )
    hideLoading();
    local data = event.data
    self.firstTimeInPractice = true
    local dataTbl = data.infos or {}
    self.guildPracticeInfo = {}
    for k,v in pairs(dataTbl) do
        self.guildPracticeInfo[v.attributeType] = v.level
    end

    if self.guildPracticeInfoOpenLayer then
        self:openFactionPracticeLayer()
    end
end

function FactionPracticeManager:requestStudy(attributeType)
    --研究
    self.requestStudyType = attributeType
    TFDirector:send(c2s.STUDY,{attributeType})
    showLoading();
end
function FactionPracticeManager:onStudySucess( event )
    hideLoading();

    self.guildPracticeInfo = self.guildPracticeInfo or {}
    self.guildPracticeInfo[self.requestStudyType] = self.guildPracticeInfo[self.requestStudyType] or 0
    self.guildPracticeInfo[self.requestStudyType] = self.guildPracticeInfo[self.requestStudyType] + 1

    TFDirector:dispatchGlobalEventWith(FactionPracticeManager.studySucess ,{})
    play_jibaichenggong()
end

function FactionPracticeManager:requestStartPractice(pos,instanceId,attributeType)
    --开始修炼
    self.startPracticePos = pos
    self.startPracticeInstanceId = instanceId
    self.startPracticeType = attributeType
    TFDirector:send(c2s.START_PRACTICE,{pos,instanceId,attributeType})
    showLoading();
end
function FactionPracticeManager:onStartPracticeSucess( event )
    hideLoading();
    self.practiceHouseCard[self.startPracticePos] = {}
    self.practiceHouseCard[self.startPracticePos].instanceId = self.startPracticeInstanceId
    self.practiceHouseCard[self.startPracticePos].attributeType = self.startPracticeType
    self.practiceHouseCard[self.startPracticePos].practiceTime = MainPlayer:getNowtime()*1000

    TFDirector:dispatchGlobalEventWith(FactionPracticeManager.startPracticeSucess ,{self.startPracticePos})
end

function FactionPracticeManager:requestEndPractice(pos,finish)
    --finish
    --true 已完成
    --false 立即完成
    self.endPracticePos = pos
    self.endPracticeFinish = finish
    TFDirector:send(c2s.END_PRACTICE,{pos,finish})
    showLoading();
end
function FactionPracticeManager:onEndPracticeSucess( event )
    hideLoading();
    local msg = {}
    msg.state = self.endPracticeFinish
    msg.pos = self.endPracticePos
    msg.instanceId = self.practiceHouseCard[self.endPracticePos].instanceId
    msg.attributeType = self.practiceHouseCard[self.endPracticePos].attributeType

    -- if self.endPracticeFinish then
    --     --点击了已完成按钮
    --     self.practiceHouseCard[self.endPracticePos] = {}
    -- else
    --     --点击了立即完成按钮
    --     self.practiceHouseCard[self.endPracticePos].practiceTime = 0
    --     --setcardrole
    -- end
    local cardRole = CardRoleManager:getRoleByGmid(msg.instanceId)
    if cardRole then  
        local value = cardRole:getFactionPracticeLevelByType(msg.attributeType) or 0
        print('value = ',value)
        cardRole:setFactionPracticeByType(msg.attributeType, value+1)
    end
    print('msg = ',msg)
    self.practiceHouseCard[self.endPracticePos] = {}
    TFDirector:dispatchGlobalEventWith(FactionPracticeManager.endPracticeSucess ,msg)
    play_jibaichenggong()
end

function FactionPracticeManager:requestInheritance(instanceId_A,attributeType,instanceId_B)
    --a 传承给 b
    self.inheritanceA = instanceId_A
    self.inheritanceB = instanceId_B
    self.inheritanceType = attributeType
    TFDirector:send(c2s.INHERITANCE,{instanceId_A,attributeType,instanceId_B})
    showLoading();
end
function FactionPracticeManager:onInheritanceSucess( event )
    hideLoading();
    local cardRoleA = CardRoleManager:getRoleByGmid(self.inheritanceA)
    local cardRoleB = CardRoleManager:getRoleByGmid(self.inheritanceB)
    local msg = {}
    msg.roleA = self.inheritanceA
    msg.roleB = self.inheritanceB
    msg.inheritanceType = self.inheritanceType

    if cardRoleA and cardRoleB then  
        local valueA = cardRoleA:getFactionPracticeLevelByType(self.inheritanceType)
        local valueB = cardRoleB:getFactionPracticeLevelByType(self.inheritanceType)
        msg.levelA = valueA
        msg.levelB = valueB
        cardRoleB:setFactionPracticeByType(self.inheritanceType, valueA)
        cardRoleA:setFactionPracticeByType(self.inheritanceType, 0)
    end

    TFDirector:dispatchGlobalEventWith(FactionPracticeManager.inheritanceSucess, msg)
    play_xiangqian()
end

function FactionPracticeManager:onPlayerPracticeInfo( event )
    local data = event.data
    local houseData = data.playerPracticeInfos or {}
    for k,v in pairs(houseData) do
        self.practiceHouseCard[v.pos] = {}
        self.practiceHouseCard[v.pos].instanceId = v.instanceId
        self.practiceHouseCard[v.pos].attributeType = v.attributeType
        self.practiceHouseCard[v.pos].practiceTime = v.practiceTime
    end
    -- print('houseData = ',houseData)
    -- print('self.practiceHouseCard = ',self.practiceHouseCard)

    local roleData = data.partnerPracticeInfos or {}
    local roleList = {}
    for k,v in pairs(roleData) do
        roleList[v.instanceId] = roleList[v.instanceId] or {}
        local index = #roleList[v.instanceId] + 1
        roleList[v.instanceId][index] = {type = v.attributeType, level = v.level}
    end
    for gmId,tbl in pairs(roleList) do
        local cardRole = CardRoleManager:getRoleByGmid(gmId)
        if cardRole then
            cardRole:setFactionPractice(tbl)
        else
            print('cardRole not find,gmId = ',gmId)
        end
    end
end

--获取修炼场上的侠客列表
function FactionPracticeManager:getHouseCardList()
    local filter_list = TFArray:new()
    for k,v in pairs(self.practiceHouseCard) do
        local cardRole = CardRoleManager:getRoleByGmid(v.instanceId)
        if cardRole then
            filter_list:pushBack(cardRole)
        end
    end
    return filter_list
end

--获取修炼场的等级信息
function FactionPracticeManager:getHouseDetailInfo()
    return self.guildPracticeInfo
end

function FactionPracticeManager:getPracticeOpenLevel()
    for v in FactionLevelUpData:iterator() do
        if v.science_level ~= 0 then
            return v.id
        end
    end
    return 0
end
--进入修炼选择界面
function FactionPracticeManager:showPracticeChooseLayer(posIndex)
    -- body
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.factionPractice.PracticeChooseLayer");
    layer:loadData(posIndex)
    AlertManager:show();
end

--进入研究界面
function FactionPracticeManager:showPracticeStudyLayer()
    -- body
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.factionPractice.PracticeStudyLayer");
    --layer:loadData(1)
    AlertManager:show();
end

function FactionPracticeManager:getXLCLevel()
    local currLevel = FactionManager:getFactionInfo().level or 0
    if currLevel == 0 then
        return 0
    end
    for v in FactionLevelUpData:iterator() do
        if v.id == currLevel then
            return v.science_level
        end
    end
    return 0
end

function FactionPracticeManager:canRedPointPractice()
    if self.firstTimeInPractice == nil then
        return false
    end
    for i=1,5 do
        local dataInfo = self:getHouseInfoById( i )
        if (dataInfo.gmId == 0 and dataInfo.state) or (dataInfo.gmId and dataInfo.complete==0) then
            return true
        end
    end
    return false
end

function FactionPracticeManager:checkRoleInHouseByGmId( gmID )
    local data = self.practiceHouseCard or {}
    for k,v in pairs(data) do
        if v.instanceId == gmID then
            return true
        end
    end 
    return false
end

function FactionPracticeManager:checkIsOpenSecondPage()
    local openLevel = 0
    for v in FactionLevelUpData:iterator() do
        if v.max_skill_level2 ~= 0 then
            openLevel = v.id
            break
        end
    end

    if openLevel == 0 then
        -- toastMessage("即将开放，敬请期待！")
        toastMessage(localizable.common_function_will_open)
        return false
    elseif FactionManager.factionInfo.level < openLevel then
        -- local str = TFLanguageManager:getString(ErrorCodeData.Field_Open_Level)
        -- str = string.format(str,openLevel)
        local str = stringUtils.format(localizable.Field_Open_XLC_Level, openLevel)

        toastMessage(str)
        return false
    end    
    return true
end
return FactionPracticeManager:new();
