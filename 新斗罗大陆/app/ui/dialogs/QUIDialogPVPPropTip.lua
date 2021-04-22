-- @Author: xurui
-- @Date:   2019-04-08 10:36:07
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-08 15:43:03
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPVPPropTip = class("QUIDialogPVPPropTip", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QReplayUtil = import("...utils.QReplayUtil")
local QListView = import("...views.QListView")
local QUIWidgetPVPPropTip = import("..widgets.QUIWidgetPVPPropTip")
local QActorProp = import("...models.QActorProp")

function QUIDialogPVPPropTip:ctor(options)
	local ccbFile = "ccb/Dialog_pvp_info.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogPVPPropTip.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._fighter1 = options.fighter or {}
        self._fighter2 = options.fighter2 or {}
        self._fighter3 = options.fighter3 or {}
        self._extraProp = options.extraProp
    	self._isMultiTeam = options.isMultiTeam
        self._teamKey1 = options.teamKey
        self._teamKey2 = options.teamKey2
        self._teamKey3 = options.teamKey3
        self._callBack = options.callBack
        self._showTeam = options.showTeam
        self._isEquilibrium = options.isEquilibrium
    end

    self._heroList = {}         --主力英雄列表
    self._teamNum = {}
    self._propList = {}         --主力属性加成列表

    self:setPorpInfo()
end

function QUIDialogPVPPropTip:viewDidAppear()
	QUIDialogPVPPropTip.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogPVPPropTip:viewWillDisappear()
  	QUIDialogPVPPropTip.super.viewWillDisappear(self)
end

function QUIDialogPVPPropTip:setMyFighterInfo()
end

function QUIDialogPVPPropTip:setInfo()
    local heroList = {}
    local propList = {}
    if q.isEmpty(self._fighter1) == false or self._teamKey1 then
        self:calculateProp(self._fighter1, self._teamKey1, 1, heroList, propList)
    end

    if q.isEmpty(self._fighter2) == false or self._teamKey2 then
        self:calculateProp(self._fighter2, self._teamKey2, 2, heroList, propList)
    end
    if q.isEmpty(self._fighter3) == false or self._teamKey3 then
        self:calculateProp(self._fighter3, self._teamKey3, 3, heroList, propList)
    end

    local index = 1
    for _, value in pairs(heroList) do
        self._heroList[index] = value
        index = index + 1
    end


    -- index = 1
    -- for _, value in pairs(propList) do
    --     self._propList[index] = value
    --     index = index + 1
    -- end

    self:setPorpInfo()
end

function QUIDialogPVPPropTip:calculateProp(fighter, teamKey, teamNum, heroList, addPropList)
    local extraProp = nil
    if q.isEmpty(fighter) then
        if teamKey == nil then 
            return
        end
        fighter = remote.user:makeFighterByTeamKey(teamKey, teamNum)
    else
        extraProp = app.extraProp:getExtraPropByFighter(fighter)
    end
    local additionalInfos = QReplayUtil:getFighterAdditionalInfos(fighter)
    if self._extraProp then
        extraProp = self._extraProp
    end

    local calculateMainPropFunc = function(heros)
        local heroList = {}
        for index, value in ipairs( heros ) do
            local actor = app:createHeroWithoutCache(value, nil, additionalInfos, nil, nil, nil, nil, nil, extraProp)
            local actorProp = actor:getActorPropInfo()
            local prop = {}
            prop.pvp_physical_damage_percent_attack = actorProp:getPVPPhysicalAttackPercent()
            prop.pvp_physical_damage_percent_beattack_reduce = actorProp:getPVPPhysicalReducePercent()
            prop.pvp_magic_damage_percent_attack = actorProp:getPVPMagicAttackPercent()
            prop.pvp_magic_damage_percent_beattack_reduce = actorProp:getPVPMagicReducePercent()
            table.insert(heroList, {heroInfo = value, prop = prop})
        end
 
        return heroList
    end 

    local calculateTotalMainPropFunc = function(heros)
        local heroList = {}
        local prop = {}
        prop.pvp_physical_damage_percent_attack = 0
        prop.pvp_physical_damage_percent_beattack_reduce = 0
        prop.pvp_magic_damage_percent_attack = 0
        prop.pvp_magic_damage_percent_beattack_reduce = 0
        for index, value in ipairs( heros ) do
            local actor = app:createHeroWithoutCache(value, nil, additionalInfos, nil, nil, nil, nil, nil, extraProp)
            local actorProp = actor:getActorPropInfo()
            prop.pvp_physical_damage_percent_attack = prop.pvp_physical_damage_percent_attack  + actorProp:getPVPPhysicalAttackPercent()
            prop.pvp_physical_damage_percent_beattack_reduce = prop.pvp_physical_damage_percent_beattack_reduce + actorProp:getPVPPhysicalReducePercent()
            prop.pvp_magic_damage_percent_attack = prop.pvp_magic_damage_percent_attack + actorProp:getPVPMagicAttackPercent()
            prop.pvp_magic_damage_percent_beattack_reduce = prop.pvp_magic_damage_percent_beattack_reduce + actorProp:getPVPMagicReducePercent()

        end
        local junhengProp = {}
        for key, subProp in pairs(prop) do
            junhengProp[key] = subProp / 7
        end
        printTable(junhengProp)
        for index, value in ipairs( heros ) do
            table.insert(heroList, {heroInfo = value, prop = junhengProp})
        end

        return heroList
    end 

    local addHelpProp = function(mainPropList, helpHeros)
        local helpProp = {}
        for index, value in ipairs( helpHeros ) do
            local actor = app:createHeroWithoutCache(value, nil, additionalInfos, nil, nil, nil, nil, nil, extraProp)
            local actorProp = actor:getActorPropInfo()
            helpProp.pvp_physical_damage_percent_attack = (helpProp.pvp_physical_damage_percent_attack or 0) + (actorProp:getPVPPhysicalAttackPercent() - actorProp:getArchaeologyPVPPhysicalAttackPercent()) / 4
            helpProp.pvp_physical_damage_percent_beattack_reduce = (helpProp.pvp_physical_damage_percent_beattack_reduce or 0) + (actorProp:getPVPPhysicalReducePercent() - actorProp:getArchaeologyPVPPhysicalReducePercent()) / 4
            helpProp.pvp_magic_damage_percent_attack = (helpProp.pvp_magic_damage_percent_attack or 0) + (actorProp:getPVPMagicAttackPercent() - actorProp:getArchaeologyPVPMagicAttackPercent()) / 4
            helpProp.pvp_magic_damage_percent_beattack_reduce = (helpProp.pvp_magic_damage_percent_beattack_reduce or 0) + (actorProp:getPVPMagicReducePercent() - actorProp:getArchaeologyPVPMagicReducePercent()) / 4       
        end
        for index, value in ipairs( mainPropList ) do
            if value.prop then
                for key, prop in pairs(value.prop) do
                    if helpProp[key] then
                        if self._isEquilibrium then
                            value.prop[key] = value.prop[key] + helpProp[key]/7
                        else
                            value.prop[key] = value.prop[key] + helpProp[key]
                        end
                    end
                end
            end
        end
    end


    if teamNum == 1 then
        remote.herosUtil:addPeripheralSkills(fighter.heros or {})
        local propList = {}
        local heros = clone(fighter.heros)
        if fighter.alternateHeros then
            for _,v in pairs(fighter.alternateHeros) do
                table.insert(heros, v)
            end
        end
        if self._isEquilibrium then
            propList = calculateTotalMainPropFunc(heros, teamNum)
        else
            propList = calculateMainPropFunc(heros, teamNum)
        end

        -- local add_propList = calculateMainAdditionPropFunc(heros, teamNum)

        -- addHelpProp(propList, fighter.subheros or {})
        -- addHelpProp(propList, fighter.sub2heros or {})
        -- addHelpProp(propList, fighter.sub3heros or {})
        -- 魂师pvp属性计算的时候，由于lua存储数据的问题，先后顺序不一样会导致小数在二进制存储时有不同的区别。
        -- 所以计算的时候，不同阵容魂师一样，就按照统一顺序去计算属性。
        local sortSubheros = {}
        local mergeHeros = function(heros)
            for _,v in pairs(heros) do
                table.insert(sortSubheros,v)
            end
        end
        mergeHeros(fighter.subheros or {})
        mergeHeros(fighter.sub2heros or {})
        mergeHeros(fighter.sub3heros or {})

        table.sort( sortSubheros, function(a,b)
            if a.actorId and b.actorId then
                return a.actorId < b.actorId
            end
        end )
        addHelpProp(propList,sortSubheros)

        -- calculateHelpAddProp(add_propList, fighter.subheros or {})
        -- calculateHelpAddProp(add_propList, fighter.sub2heros or {})
        -- calculateHelpAddProp(add_propList, fighter.sub3heros or {})

        propList.teamNum = teamNum
        heroList[teamNum] = propList
        -- addPropList[teamNum] = add_propList

    elseif teamNum == 2 then
        remote.herosUtil:addPeripheralSkills(fighter.main1Heros or {})
        local propList = calculateMainPropFunc(fighter.main1Heros or {}, teamNum)      
        -- local add_propList = calculateMainAdditionPropFunc(heros, teamNum)
        addHelpProp(propList, fighter.sub1heros or {})
        -- calculateHelpAddProp(add_propList, fighter.sub1heros or {})

        propList.teamNum = teamNum
        heroList[teamNum] = propList
        -- addPropList[teamNum] = add_propList
-- 
    elseif teamNum == 3 then
        remote.herosUtil:addPeripheralSkills(fighter.mainHeros3 or {})
        local propList = calculateMainPropFunc(fighter.mainHeros3 or {}, teamNum)      
        -- local add_propList = calculateMainAdditionPropFunc(heros, teamNum)
        addHelpProp(propList, fighter.subheros3 or {})
        -- calculateHelpAddProp(add_propList, fighter.sub1heros or {})

        propList.teamNum = teamNum
        heroList[teamNum] = propList

    end
end

function QUIDialogPVPPropTip:setPorpInfo()
    if not self._propListView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                -- body
                local isCacheNode = true
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetPVPPropTip.new()
                    isCacheNode = false
                end
                -- item:setInfo(self._heroList[index], self._showTeam,self._propList[index])
                item:setInfo(self._heroList[index], self._showTeam)
                info.item = item
                info.size = item:getContentSize()
                return isCacheNode
            end,
            ignoreCanDrag = true,
            enableShadow = false,
            isVertical = true,
            totalNumber = #self._heroList,
            contentOffsetX = 40 ,
        }  
        self._propListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._propListView:reload({totalNumber = #self._heroList})
    end
end

function QUIDialogPVPPropTip:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPVPPropTip:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogPVPPropTip:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogPVPPropTip
