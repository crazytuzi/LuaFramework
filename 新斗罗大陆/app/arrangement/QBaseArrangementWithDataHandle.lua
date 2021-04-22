local QBaseArrangement = import(".QBaseArrangement")
local QBaseArrangementWithDataHandle = class("QBaseArrangementWithDataHandle", QBaseArrangement)
local QMyAppUtils = import(".utils.QMyAppUtils")


QBaseArrangementWithDataHandle.HERO_FULL = "魂师已满"
QBaseArrangementWithDataHandle.SOUL_FULL = "魂灵已满"
QBaseArrangementWithDataHandle.GODARM_FULL = "神器已满"
QBaseArrangementWithDataHandle.GODARM_SAME_FULL = "同类型神器只能同时上两个"

QBaseArrangementWithDataHandle.ELEMENT_TYPE = 
{
	HERO_ELE_TYPE =1,
	SOUL_ELE_TYPE =2,
	GODARM_ELE_TYPE =3,

	EMPTY_ELE_TYPE = 100,
	EMPTY_HERO_ELE_TYPE = 101,
	EMPTY_SOUL_ELE_TYPE = 102,
	EMPTY_GODARM_ELE_TYPE = 103,

	LOCK_ELE_TYPE =200,
	LOCK_HERO_ELE_TYPE =201,
	LOCK_SOUL_ELE_TYPE =202,
	LOCK_GODARM_ELE_TYPE =203,

}

QBaseArrangementWithDataHandle.JOB_TYPE ={
	JOB_TYPE_ALL =1,
	JOB_TYPE_TANK =2,
	JOB_TYPE_HEAL =3,
	JOB_TYPE_ATTACK =4,
	JOB_TYPE_PATTACK =5,
	JOB_TYPE_MATTACK =6,
}


QBaseArrangementWithDataHandle.TRANSFORM_TYPE = 
{
	NOT_REFRESH_TRANSFORM_TYPE = 1 ,	--不需要操作
	BUTTON_TRANSFORM_TYPE = 2 ,			--更改按钮标志
	PAGE_FRONT_TRANSFORM_TYPE = 3 ,		--更改页签标志 向前
	PAGE_BACK_TRANSFORM_TYPE = 4 ,		--更改页签标志 向后
	TEAM_TRANSFORM_TYPE = 5 ,			--更改队伍标志 向前
}

QBaseArrangementWithDataHandle.NOTICE_TYPE = 
{
	NONE_MAIN = 1 ,--无主力魂师
	LACK_MAIN = 2 ,--缺少主力魂师
	LACK_SOUL = 3 ,--缺少主力魂灵
	LACK_HELP = 4 ,--缺少辅助魂师
	LACK_GODARM = 5 ,--缺少神器
}


QBaseArrangementWithDataHandle.JOB_CON_FUNC={}
QBaseArrangementWithDataHandle.JOB_CON_FUNC[QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_ALL] = {condition = function (x) return true end}
QBaseArrangementWithDataHandle.JOB_CON_FUNC[QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_TANK] = {condition = function (x) return  x == 't' end}
QBaseArrangementWithDataHandle.JOB_CON_FUNC[QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_HEAL] = {condition = function (x) return  x == 'h' end}
QBaseArrangementWithDataHandle.JOB_CON_FUNC[QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_ATTACK] = {condition = function (x) return  x == 'pd' or x == 'md' end}
QBaseArrangementWithDataHandle.JOB_CON_FUNC[QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_PATTACK] = {condition = function (x) return  x == 'pd' end}
QBaseArrangementWithDataHandle.JOB_CON_FUNC[QBaseArrangementWithDataHandle.JOB_TYPE.JOB_TYPE_MATTACK] = {condition = function (x) return  x == 'md' end}


QBaseArrangementWithDataHandle.MultiTeamDataStruct={}
QBaseArrangementWithDataHandle.MultiTeamDataStruct[1] = {heroes = "heros", supports = "subheros", godArmIdList = "godArm1List"
	, soulSpirits = "soulSpirit", supportSkillHeroIndex = "activeSubActorId", supportSkillHeroIndex2 = "active1SubActorId"}
QBaseArrangementWithDataHandle.MultiTeamDataStruct[2] = {heroes = "main1Heros", supports = "sub1heros", godArmIdList = "godArm2List"
	, soulSpirits = "soulSpirit2", supportSkillHeroIndex = "activeSub2ActorId", supportSkillHeroIndex2 = "active1Sub2ActorId"}
QBaseArrangementWithDataHandle.MultiTeamDataStruct[3] = {heroes = "mainHeros3", supports = "subheros3", godArmIdList = "godArmList3"
	, soulSpirits = "soulSpirit3", supportSkillHeroIndex = "activeSubActorId3", supportSkillHeroIndex2 = "active1SubActorId3"}


function QBaseArrangementWithDataHandle:ctor(options)
	QBaseArrangementWithDataHandle.super.ctor(self, remote.herosUtil:getHaveHero(), options.teamKey or remote.teamManager.METAL_ABYSS_TEAM)
	self._teamKeys = options.teamKeys
	self._info = options.info
	self._teamIndexIds = options.teamIndexIds

	self._enemyFighter = options.enemyFighter 

	self:initFormationElement()

	if self._enemyFighter ~= nil and not q.isEmpty(self._teamIndexIds) then
		self:initEnemyFighterInfo()
	end
end

function QBaseArrangementWithDataHandle:resetFormationElement()
	self._heroElementsList = {}
	self._soulSpiritElementsList = {}
	self._godArmElementsList = {}

	self._teamArrangeHeroIds = {}		
	self._teamArrangeSoulSpiritIds = {}
	self._teamArrangeGodArmIds = {}

	self._teamHelpSkillMaxNumList = {}

	self._enemyFighterTeamInfos = {}


	self._elementType = QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE
	self._trialNum = 1
	self._jobType = 1
	self._teamIndex = remote.teamManager.TEAM_INDEX_MAIN
end

function QBaseArrangementWithDataHandle:saveFormation()

end

--转换成QTeamManager:encodeBattleFormation 可以转化的参数类型
function QBaseArrangementWithDataHandle:getTeamInfoByTrialNum(trialNum)
	local teamInfo = {}

	for i,teamIndex in ipairs(self._teamIndexIds) do
		local teamArrangement = self:getShowTeamArrangement(trialNum , teamIndex)
		if teamInfo[teamIndex] == nil then
			teamInfo[teamIndex] = {}
			if teamIndex == remote.teamManager.TEAM_INDEX_MAIN then
				teamInfo[teamIndex].actorIds = {}
				teamInfo[teamIndex].alternateIds = {}
				teamInfo[teamIndex].spiritIds = {}
			elseif teamIndex == remote.teamManager.TEAM_INDEX_GODARM then
				teamInfo[teamIndex].godarmIds = {}
			elseif teamIndex == remote.teamManager.TEAM_INDEX_HELP then
				teamInfo[teamIndex].actorIds = {}
				teamInfo[teamIndex].skill = {}
				teamInfo[teamIndex].skill[1] = 0
				teamInfo[teamIndex].skill[2] = 0
			else
				teamInfo[teamIndex].actorIds = {}
				teamInfo[teamIndex].skill = {}
				teamInfo[teamIndex].skill[1] = 0
			end

		end
		local labelhuimie = {}
		for _,info in ipairs(teamArrangement) do
			if info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
				if teamInfo[teamIndex].actorIds then
					table.insert(teamInfo[teamIndex].actorIds, info.actorId)
				end
				local skillIdx = info.skillIdx
				if skillIdx > 0 and teamInfo[teamIndex].skill and teamInfo[teamIndex].skill[skillIdx] then
					teamInfo[teamIndex].skill[skillIdx] = info.actorId
				end

			elseif info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
				if teamInfo[teamIndex].spiritIds then
					table.insert(teamInfo[teamIndex].spiritIds, info.id)
				end
			elseif info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
				if labelhuimie[info.label] == nil then
					labelhuimie[info.label] = {}
  					labelhuimie[info.label].number = (labelhuimie[info.label].number or 0) + 1
				else
					labelhuimie[info.label].number = (labelhuimie[info.label].number or 0) + 1
				end
				if labelhuimie[info.label].number <= 2 then
					if teamInfo[teamIndex].godarmIds then
						table.insert(teamInfo[teamIndex].godarmIds, info.id)
					end
				end

			end
		end
	end

	return teamInfo

end

function QBaseArrangementWithDataHandle:getTeamInfoLackByTrialNum(trialNum)
	local lackIdx = 0
	local mainCount = 0

	local judgePair ={}
	judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.NONE_MAIN] = true
	judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_MAIN] = false
	judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_HELP] = false
	judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_SOUL] = false
	judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_GODARM] = false

	local labelhuimie = {}

	local haveHero = self:checkHaveHeroRemaining()
	local haveSoul = self:checkHaveSoulSpiritRemaining()

	for i,teamIndex in ipairs(self._teamIndexIds) do
		local teamArrangement = self:getShowTeamArrangement(trialNum , teamIndex)
		for _,info in ipairs(teamArrangement) do
			if info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE and teamIndex == remote.teamManager.TEAM_INDEX_MAIN then
				if teamIndex == remote.teamManager.TEAM_INDEX_MAIN then
					mainCount = mainCount + 1
					judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.NONE_MAIN] = false
				end
			end
			if info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE  then
				if labelhuimie[info.label] == nil then
					labelhuimie[info.label] = {}
  					labelhuimie[info.label].number = (labelhuimie[info.label].number or 0) + 1
				else
					labelhuimie[info.label].number = (labelhuimie[info.label].number or 0) + 1
				end
			end

			if info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_HERO_ELE_TYPE and haveHero then
				if teamIndex == remote.teamManager.TEAM_INDEX_MAIN and judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_MAIN] == false then
					judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_MAIN] = true
				elseif judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_HELP] == false then
					judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_HELP] = true 
				end
			elseif info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_SOUL_ELE_TYPE 
				and judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_SOUL] == false
				and haveSoul then
					judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_SOUL] = true
			elseif info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_GODARM_ELE_TYPE and judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_GODARM] == false then
					if q.isEmpty(labelhuimie) then
						judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_GODARM] = true
					else
						local total ={"毁灭","生命"}
						for i,label in ipairs(total) do
							if labelhuimie[info.label] == nil or labelhuimie[info.label].number < 2 then
								if self:checkHaveGodArmRemaining(label) then
									judgePair[QBaseArrangementWithDataHandle.NOTICE_TYPE.LACK_GODARM] = true
									break
								end
							end
						end
					end
			end
		end
	end

	local resultTbl = {}
	for i,v in pairs(judgePair) do
		if v then
			table.insert(resultTbl,i)
		end
	end

	return resultTbl
end

function QBaseArrangementWithDataHandle:checkHaveHeroRemaining()
	for k,info in pairs(self._heroElementsList) do
		if info.index == 0 then
			return true
		end
	end
	return false
end

function QBaseArrangementWithDataHandle:checkHaveSoulSpiritRemaining()
	for k,info in pairs(self._soulSpiritElementsList) do
		if info.index == 0 then
			return true
		end
	end
	return false
end


function QBaseArrangementWithDataHandle:checkHaveGodArmRemaining(label)
	for k,info in pairs(self._godArmElementsList) do
		local labelCheck = label == nil and true or (label == info.label)
		if info.index == 0 and labelCheck then
			return true
		end
	end
	return false
end



function QBaseArrangementWithDataHandle:getElementType()
	return self._elementType
end

function QBaseArrangementWithDataHandle:getTrialNum()
	return self._trialNum
end

function QBaseArrangementWithDataHandle:getJobType()
	return self._jobType
end

function QBaseArrangementWithDataHandle:getTeamIndex()
	return self._teamIndex
end

function QBaseArrangementWithDataHandle:getTeamKeys()
	return self._teamKeys
end


function QBaseArrangementWithDataHandle:initEnemyFighterInfo()
	self._enemyFighterTeamInfos = {}
	if #self._teamIndexIds > 0 then
		for i,v in ipairs(self._teamIndexIds) do
			self:handleMultiTeamEnemyFighterInfo(i)
		end
	end

	-- QPrintTable(self._enemyFighterTeamInfos)
end

function QBaseArrangementWithDataHandle:handleMultiTeamEnemyFighterInfo(idx)

    -- 援助技能
    local function tableIndexof(supports, actorId)
        for i, v in pairs(supports or {}) do
            if v.actorId == actorId then
                return i
            end
        end
    end

	local force = 0
	self._enemyFighterTeamInfos[idx]={}
	local emenyFuncType =QBaseArrangementWithDataHandle.MultiTeamDataStruct[idx]
	--主力
	self._enemyFighterTeamInfos[idx].heroes={}
	for i,info in ipairs(self._enemyFighter[emenyFuncType.heroes] or {}) do
		force = force + (info.force or 0)
		local dataInfo = QMyAppUtils:getBaseHeroInfo(info)
		table.insert(self._enemyFighterTeamInfos[idx].heroes,dataInfo)
	end
	remote.teamManager:sortTeam(self._enemyFighterTeamInfos[idx].heroes, true)
	--替补
	self._enemyFighterTeamInfos[idx].supports={}
	local supports = (self._enemyFighter[emenyFuncType.supports] or {})
	for i,info in ipairs(supports) do
		force = force + (info.force or 0)
		local dataInfo = QMyAppUtils:getBaseHeroInfo(info)
		table.insert(self._enemyFighterTeamInfos[idx].supports,dataInfo)
	end
	--神器
	self._enemyFighterTeamInfos[idx].godArmIdList={}
	for i,info in ipairs(self._enemyFighter[emenyFuncType.godArmIdList] or {}) do
		force = force + (info.main_force or 0)
		local dataInfo = QMyAppUtils:getBaseGodarmInfo(info)
		table.insert(self._enemyFighterTeamInfos[idx].godArmIdList,dataInfo)
	end	
	--魂灵
	self._enemyFighterTeamInfos[idx].soulSpirits={}
	for i,info in ipairs(self._enemyFighter[emenyFuncType.soulSpirits] or {}) do
		force = force + (info.force or 0)
		local dataInfo = QMyAppUtils:getBaseSoulSpiritInfo(info)
		table.insert(self._enemyFighterTeamInfos[idx].soulSpirits,dataInfo)
	end	

	local supportSkillHeroIndex = tableIndexof(supports, self._enemyFighter[emenyFuncType.supportSkillHeroIndex])
	local supportSkillHeroIndex2 = tableIndexof(supports, self._enemyFighter[emenyFuncType.supportSkillHeroIndex2])
    if not supportSkillHeroIndex and #supports >= 1 then
        supportSkillHeroIndex = 1
    end
    if not supportSkillHeroIndex2 and #supports >= 2 then
        supportSkillHeroIndex2 = 2
    end
    print("emeny team"..idx.."force"..force)
    self._enemyFighterTeamInfos[idx].force = force
    self._enemyFighterTeamInfos[idx].supportSkillHeroIndex = supportSkillHeroIndex
    self._enemyFighterTeamInfos[idx].supportSkillHeroIndex2 = supportSkillHeroIndex2
end

--多队传入战斗的阵容
--主力头插
function QBaseArrangementWithDataHandle:getMyMultiTeamFighterInfo(idx)
  
	local force = 0
	local resultTbl = {}
	--主力
	resultTbl.heroes= {}
	--魂灵
	resultTbl.soulSpirits= {}
	local teamArrangement = self:getShowTeamArrangement(idx , remote.teamManager.TEAM_INDEX_MAIN , true)
	for i,info in ipairs(teamArrangement) do
		if info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
			local heroInfo = remote.herosUtil:getHeroByID(info.actorId)
			force = force + (heroInfo.force or 0)
			local dataInfo = self:_getHeroInfo(heroInfo)
			table.insert(resultTbl.heroes,1,dataInfo)			
		elseif info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
			local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(info.id)

			force = force + (soulSpiritInfo.force or 0)
			local dataInfo = self:_getSoulSpiritInfo(soulSpiritInfo)
			table.insert(resultTbl.soulSpirits,dataInfo)					
		end
	end
	remote.teamManager:sortTeam(resultTbl.heroes, true)
	
	
	teamArrangement = self:getShowTeamArrangement(idx , remote.teamManager.TEAM_INDEX_HELP , true)
	--替补
	resultTbl.supports= {}
	for i,info in ipairs(teamArrangement) do
		if info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
			local heroInfo = remote.herosUtil:getHeroByID(info.actorId)
			force = force + (heroInfo.force or 0)
			local dataInfo = self:_getHeroInfo(heroInfo)
			table.insert(resultTbl.supports,dataInfo)
			if info.skillIdx == 1 then
				resultTbl.supportSkillHeroIndex = i
			elseif info.skillIdx == 2 then
				resultTbl.supportSkillHeroIndex2 = i
			end
		end
	end
	--神器
	local labelhuimie = {}
	resultTbl.godArmIdList ={}
	teamArrangement = self:getShowTeamArrangement(idx , remote.teamManager.TEAM_INDEX_GODARM , true)
	for i,info in ipairs(teamArrangement) do
		if info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
			local godArmInfo = remote.godarm:getGodarmById(info.id)
			if labelhuimie[info.label] == nil then
				labelhuimie[info.label] = {}
					labelhuimie[info.label].number = (labelhuimie[info.label].number or 0) + 1
			else
				labelhuimie[info.label].number = (labelhuimie[info.label].number or 0) + 1
			end
			if labelhuimie[info.label].number <= 2 then
				force = force + (info.force or 0)
				local dataInfo =self:_getGodarmInfo(godArmInfo)
				table.insert(resultTbl.godArmIdList,dataInfo)
			end
		end
	end
	resultTbl.force = force
	return resultTbl
end

--多队传入战斗的敌方阵容
--主力头插
function QBaseArrangementWithDataHandle:getEnemyMultiTeamFighterInfo(idx)
	local resultTbl ={}
	local force = 0
    -- 援助技能
    local function tableIndexof(supports, actorId)
        for i, v in pairs(supports or {}) do
            if v.actorId == actorId then
                return i
            end
        end
    end

	local emenyFuncType =QBaseArrangementWithDataHandle.MultiTeamDataStruct[idx]
	--主力
	resultTbl.heroes ={}
	for i,info in ipairs(self._enemyFighter[emenyFuncType.heroes] or {}) do
		force = force + (info.force or 0)
		local dataInfo =self:_getHeroInfo(info)
		table.insert(resultTbl.heroes,dataInfo)
	end
	remote.teamManager:sortTeam(resultTbl.heroes, true)
	--替补
	resultTbl.supports ={}
	local supports = (self._enemyFighter[emenyFuncType.supports] or {})
	for i,info in ipairs(supports) do
		force = force + (info.force or 0)
		local dataInfo = self:_getHeroInfo(info)
		table.insert(resultTbl.supports,dataInfo)
	end
	resultTbl.godArmIdList ={}
	--神器
	for i,info in ipairs(self._enemyFighter[emenyFuncType.godArmIdList] or {}) do
		force = force + (info.main_force or 0)
		local dataInfo = self:_getGodarmInfo(info)
		table.insert(resultTbl.godArmIdList,dataInfo)
	end	
	--魂灵
	resultTbl.soulSpirits ={}
	for i,info in ipairs(self._enemyFighter[emenyFuncType.soulSpirits] or {}) do
		force = force + (info.force or 0)
		local dataInfo = self:_getSoulSpiritInfo(info)
		table.insert(resultTbl.soulSpirits,dataInfo)
	end	

	local supportSkillHeroIndex = tableIndexof(supports, self._enemyFighter[emenyFuncType.supportSkillHeroIndex])
	local supportSkillHeroIndex2 = tableIndexof(supports, self._enemyFighter[emenyFuncType.supportSkillHeroIndex2])
    if not supportSkillHeroIndex and #supports >= 1 then
        supportSkillHeroIndex = 1
    end
    if not supportSkillHeroIndex2 and #supports >= 2 then
        supportSkillHeroIndex2 = 2
    end
   	resultTbl.force = force
    resultTbl.supportSkillHeroIndex = supportSkillHeroIndex
    resultTbl.supportSkillHeroIndex2 = supportSkillHeroIndex2

	return resultTbl
end

function QBaseArrangementWithDataHandle:getEnemyFighterInfoByIdx(idx)
	return self._enemyFighterTeamInfos[idx] or {}
end

function QBaseArrangementWithDataHandle:getEnemyFighterInfos()
	return self._enemyFighterTeamInfos
end

function QBaseArrangementWithDataHandle:getEnemyFighter()
	return self._enemyFighter or nil
end


function QBaseArrangementWithDataHandle:getTeamIndexIds()
	return self._teamIndexIds
end

function QBaseArrangementWithDataHandle:getCurHeroTeamActorIds( _index )
	return self:getHeroTeamActorIdsByData(self._trialNum,_index)
end

function QBaseArrangementWithDataHandle:getHeroTeamActorIdsByData( trialNum ,_index )
	local resultTbl = {}
	if self._teamArrangeHeroIds[trialNum] and self._teamArrangeHeroIds[trialNum][_index]  then
		for i,v in ipairs(self._teamArrangeHeroIds[trialNum][_index]) do
			table.insert(resultTbl,v)
		end
	end
	return resultTbl
end

function QBaseArrangementWithDataHandle:getCurSoulSpiritTeamIds( _index )

	return self:getSoulSpiritTeamIdsByData(self._trialNum,_index)
end

function QBaseArrangementWithDataHandle:getSoulSpiritTeamIdsByData( trialNum ,_index )
	local resultTbl = {}
	if self._teamArrangeSoulSpiritIds[trialNum] and self._teamArrangeSoulSpiritIds[trialNum][_index]  then
		for i,v in ipairs(self._teamArrangeSoulSpiritIds[trialNum][_index]) do
			table.insert(resultTbl,v)
		end
	end
	return resultTbl
end

function QBaseArrangementWithDataHandle:getCurGodArmTeamActorIds( _index )
	return self:getGodArmTeamActorIdsByData(self._trialNum,_index)
end

function QBaseArrangementWithDataHandle:getGodArmTeamActorIdsByData( trialNum ,_index )
	local resultTbl = {}
	if self._teamArrangeGodArmIds[trialNum] and self._teamArrangeGodArmIds[trialNum][_index]  then
		for i,v in ipairs(self._teamArrangeGodArmIds[trialNum][_index]) do
			table.insert(resultTbl,v)
		end
	end
	return resultTbl
end



function QBaseArrangementWithDataHandle:getTeamArrangeIdsByData(_trialNum , _index , _eletype)
	if _eletype == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
		if self._teamArrangeHeroIds[_trialNum] and self._teamArrangeHeroIds[_trialNum][_index]  then
			return self._teamArrangeHeroIds[_trialNum][_index]
		end
	elseif _eletype == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
		if self._teamArrangeSoulSpiritIds[_trialNum] and self._teamArrangeSoulSpiritIds[_trialNum][_index]  then
			return self._teamArrangeSoulSpiritIds[_trialNum][_index]
		end		
	elseif _eletype == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
		if self._teamArrangeGodArmIds[_trialNum] and self._teamArrangeGodArmIds[_trialNum][_index]  then
			return self._teamArrangeGodArmIds[_trialNum][_index]
		end		
	end
		 
	return	{}
end

function QBaseArrangementWithDataHandle:getTeamArrangeMaxNumByData(_trialNum , _index , _eletype)

	if _index == remote.teamManager.TEAM_INDEX_MAIN and _eletype == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
		local maxNum =remote.soulSpirit:getTeamSpiritsMaxCountByTeamNum(#self._teamIndexIds)
		return maxNum
	end

	local teamKey = self._teamKeys[_trialNum]
	local teamVO = remote.teamManager:getTeamByKey(teamKey, false)
	local maxNum = teamVO:getHerosMaxCountBytrialNumAndIndex(_trialNum,_index)
	return maxNum
end

function QBaseArrangementWithDataHandle:getLockStr(_trialNum , _index , _eletype , pos)

	if _index == remote.teamManager.TEAM_INDEX_HELP and _eletype == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
		local teamKey = self._teamKeys[_trialNum]
		local teamVO = remote.teamManager:getTeamByKey(teamKey, false)
		return teamVO:getHeroLockStrByData(_trialNum , _index , pos)
	end

	return "敬请期待"
end

function QBaseArrangementWithDataHandle:getLockTipsByInfo(info)
	local trialNum = info.trialNum
	local index = info.index
	local eletype = info.oType % 100
	local pos = info.pos

	self:getLockTips(trialNum,index,eletype,pos)
end

function QBaseArrangementWithDataHandle:getLockTips(_trialNum , _index , _eletype , pos)
	if _index == remote.teamManager.TEAM_INDEX_HELP and _eletype == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
		local teamKey = self._teamKeys[_trialNum]
		local teamVO = remote.teamManager:getTeamByKey(teamKey, false)
		teamVO:getHeroLockTipsByData(_trialNum , _index , pos)
		return 
	end
	return
end


function QBaseArrangementWithDataHandle:getTeamArrangeForceByTrialNum(_trialNum )
	local force = 0

	if self._teamArrangeHeroIds[_trialNum] and not q.isEmpty(self._teamArrangeHeroIds[_trialNum]) then
		for k,v in pairs(self._teamArrangeHeroIds[_trialNum]) do
			for _,id in pairs(v) do
				local info = self._heroElementsList[id]
				force = force + info.force or 0
			end
		end
	end
	if self._teamArrangeSoulSpiritIds[_trialNum] and not q.isEmpty(self._teamArrangeSoulSpiritIds[_trialNum]) then
		for k,v in pairs(self._teamArrangeSoulSpiritIds[_trialNum]) do
			for _,id in pairs(v) do
				local info = self._soulSpiritElementsList[id]
				force = force + info.force or 0
			end
		end
	end
	if self._teamArrangeGodArmIds[_trialNum] and not q.isEmpty(self._teamArrangeGodArmIds[_trialNum]) then
		for k,v in pairs(self._teamArrangeGodArmIds[_trialNum]) do
			for _,id in pairs(v) do
				local info = self._godArmElementsList[id]
				force = force + info.force or 0
			end
		end
	end	

	return force
end

--[[
	伪结构体数据
**	QMyAppUtils生成的模版数据
**	index		阵容索引 -- 魂师对应替补编号 神器对于位置
**	pos			位置
**	trialNum	出战队伍索引
**	type		魂师 的类型
**	hatred		魂师 的仇恨值
**	skillIdx 	援助技能索引	0为不是援助技能 1
	--hero
	--QMyAppUtils:getBaseHeroInfo
	-- {id = actorId, type = heroType, hatred = hatred, index = 0, force = force}

	--soulSpirit
	--QMyAppUtils:getBaseSoulSpiritInfo
	--QMyAppUtils:getSoulSpiritInfo
	-- { id = soulSpiritId, level = level , grade = grade ,index = 0, force = force}--setSoulSpiritByInfo

	--godarm
	--QMyAppUtils:getBaseGodarmInfo
	--{godarmId = godarmInfo.id, grade = godarmInfo.grade,level = godarmInfo.level,index = 0, pos = 5,force = godarmInfo.main_force}

--]]
function QBaseArrangementWithDataHandle:initFormationElement()
	self:resetFormationElement()

	local heros = self:getHeroes() or {}
	local soulSpirits = self:getSoulSpirits() or {}
	local godArms = remote.godarm:getHaveGodarmList() or {}
	--魂师
	for i, actorId in pairs(heros) do
		local heroInfo = remote.herosUtil:getHeroByID(actorId)
		local dataInfo = QMyAppUtils:getBaseHeroInfo(heroInfo)

		local characher = db:getCharacterByID(actorId)
		if characher then
			local heroType = 1
			if characher.func == 't' then
				heroType = 't'
			elseif characher.func == 'health' then
				heroType = 'h'
			elseif characher.func == 'dps' and characher.attack_type == 1 then
				heroType = 'pd'
			elseif characher.func == 'dps' and characher.attack_type == 2 then
				heroType = 'md'
			end
			local force = remote.herosUtil:createHeroPropById(actorId):getBattleForce(self:getIsLocal())
			dataInfo.type = heroType
			dataInfo.hatred = characher.hatred
			dataInfo.force = force
			dataInfo.pos = 0
			dataInfo.index = 0
			dataInfo.trialNum = 0
			dataInfo.skillIdx = 0
			dataInfo.oType = QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE

			self._heroElementsList[actorId] = dataInfo
		end
	end

	--魂灵
	for i, soulSpiritInfo in pairs(soulSpirits) do
		local dataInfo = QMyAppUtils:getBaseSoulSpiritInfo(soulSpiritInfo)
		-- local force = remote.soulSpirit:countForceBySpirit(soulSpiritInfo)
		-- dataInfo.force = force
		dataInfo.pos = 0
		dataInfo.index = 0
		dataInfo.trialNum = 0
		dataInfo.oType = QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE
		self._soulSpiritElementsList[dataInfo.id] = dataInfo
	end

	--神器
	for i, godarmInfo in pairs(godArms) do
		local dataInfo = QMyAppUtils:getBaseGodarmInfo(godarmInfo)
		local characher = db:getCharacterByID(godarmInfo.id)
		dataInfo.pos = 0
		dataInfo.index = 0
		dataInfo.trialNum = 0
		dataInfo.oType = QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE
		dataInfo.label = characher.label
		self._godArmElementsList[dataInfo.id] = dataInfo
	end

	--根据多队阵容初始化数据
	for trialNum,teamKey in ipairs(self._teamKeys) do
		self._teamArrangeHeroIds[trialNum] = {}
		self._teamArrangeSoulSpiritIds[trialNum] = {}
		self._teamArrangeGodArmIds[trialNum] = {}
		self._teamHelpSkillMaxNumList[trialNum] = {}

		-- local teamKey = self._teamKeys[trialNum]
		local teamVO = remote.teamManager:getTeamByKey(teamKey, true)
		local maxIndex = teamVO:getTeamMaxIndex()
		--处理魂师
		local pos = 1
		for index = 1,maxIndex do
			self._teamArrangeHeroIds[trialNum][index] = {}
			self._teamHelpSkillMaxNumList[trialNum][index] = 0
			local actorIds = teamVO:getTeamActorsByIndex(index)
			pos = 1
			if actorIds ~= nil then
				actorIds = self:sortTeamArrangementHeroTable(actorIds)
				local maxNum = self:getTeamArrangeMaxNumByData(trialNum , index , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)

				for _,v in ipairs(actorIds) do
					if pos > maxNum then
						break
					end

					if self._heroElementsList[v] then
						self._heroElementsList[v].index = index
						self._heroElementsList[v].trialNum = trialNum
						self._heroElementsList[v].pos = pos
						pos = pos + 1
						table.insert(self._teamArrangeHeroIds[trialNum][index],v)
					end
				end
			end
			if index > 1 then
				local maxHelpNum =  teamVO:getTeamHelpSkillMaxNumByIndex(index)
				print("help idx:"..index.."maxHelpNum	"..maxHelpNum)
				self._teamHelpSkillMaxNumList[trialNum][index] = maxHelpNum
				local actorIds = teamVO:getTeamSkillByIndex(index)
				for i,v in ipairs(actorIds) do
					if self._heroElementsList[v] then
						self._heroElementsList[v].skillIdx = i
					end
				end
			end
		end
		--处理魂灵
		pos = 1
		local soulSpiritIds = teamVO:getTeamSpiritsByIndex(remote.teamManager.TEAM_INDEX_MAIN)
		self._teamArrangeSoulSpiritIds[trialNum][remote.teamManager.TEAM_INDEX_MAIN] = {}
		local maxNum = self:getTeamArrangeMaxNumByData(trialNum , remote.teamManager.TEAM_INDEX_MAIN , QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE)
		for _, v in ipairs(soulSpiritIds or {}) do
			if pos > maxNum then
				break
			end			
			if self._soulSpiritElementsList[v] then
				self._soulSpiritElementsList[v].index = remote.teamManager.TEAM_INDEX_MAIN
				self._soulSpiritElementsList[v].trialNum = trialNum
				self._soulSpiritElementsList[v].pos = pos
				pos = pos + 1
				table.insert(self._teamArrangeSoulSpiritIds[trialNum][remote.teamManager.TEAM_INDEX_MAIN],v)
			end
		end
		--处理神器
		pos = 1
		local godarmIds = teamVO:getTeamGodarmByIndex(remote.teamManager.TEAM_INDEX_GODARM)

		maxNum = self:getTeamArrangeMaxNumByData(trialNum , remote.teamManager.TEAM_INDEX_GODARM , QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE)
		self._teamArrangeGodArmIds[trialNum][remote.teamManager.TEAM_INDEX_GODARM] = {}
		for _, v in ipairs(godarmIds or {}) do
			if pos > maxNum then
				break
			end		
			if self._godArmElementsList[v] then
				self._godArmElementsList[v].index = remote.teamManager.TEAM_INDEX_GODARM
				self._godArmElementsList[v].trialNum = trialNum
				self._godArmElementsList[v].pos = pos
				pos = pos + 1
				table.insert(self._teamArrangeGodArmIds[trialNum][remote.teamManager.TEAM_INDEX_GODARM],v)
			end
		end
	end
end


--当前显示的列表标志为
function QBaseArrangementWithDataHandle:getArrangeMarkTable()
	local tbl = {}
	tbl.elementType = self._elementType
	tbl.trialNum = self._trialNum
	tbl.jobType = self._jobType
	tbl.teamIndex = self._teamIndex

	return tbl
end

--上下阵操作
--[[
parameter
	_id 处理对象id
	_type 处理对象类型 1魂师 2魂灵 3神器
return
	第一个	返回是否需要刷新阵容
	（判断当前显示索引与队伍索引判断是否需要刷新当前显示的阵容）
	true 需要刷新
	false 不需要刷新

	第二个	返回是否上阵
	true 上阵
	false 下阵
--]]
function QBaseArrangementWithDataHandle:operateSingleFormation(_id , _type)
	if _type == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
		return self:operateSingleHero(_id)
	elseif _type == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
		return self:operateSingleSoulSpirit(_id)
	elseif _type == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
		return self:operateSingleGodArm(_id)
	end
	return false,false
end

function QBaseArrangementWithDataHandle:operateSingleFormationByInfo(info)
	local _type = info.oType
	local _id = 0
	if _type == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
		_id = info.actorId
	else
		_id = info.id
	end

	return self:operateSingleFormation(_id,_type)
end

function QBaseArrangementWithDataHandle:operateSingleHero(_id)
	local elementCell = self._heroElementsList[_id]
	if not elementCell then
		return false,false
	end
	-- QPrintTable(elementCell)

	if elementCell.index ~= 0 then --下阵
		local needRresh = false
		if elementCell.trialNum == self._trialNum and elementCell.index == self._teamIndex then
			needRresh = true
		end
		-- local helpSkillMaxNum = self._teamHelpSkillMaxNumList[elementCell.trialNum][elementCell.index] 
		local tbl = self._teamArrangeHeroIds[elementCell.trialNum][elementCell.index] or {}
		--修改援助技能
		local skillNum = 0
		if elementCell.skillIdx ~= 0 then
			local changeSkillIdx = elementCell.skillIdx
			local newSkillActorId = nil
			for i,v in ipairs(tbl) do
				local info = self._heroElementsList[v]
				if info.skillIdx == 0 and not newSkillActorId then
					newSkillActorId = info.actorId
				elseif info.skillIdx >  elementCell.skillIdx then
					info.skillIdx = info.skillIdx - 1
					changeSkillIdx = changeSkillIdx + 1
				end
			end
			if newSkillActorId then 
				self._heroElementsList[newSkillActorId].skillIdx = changeSkillIdx
			end
		end

		table.remove(tbl , elementCell.pos)
		elementCell.index = 0
		elementCell.trialNum = 0
		elementCell.pos = 0
		elementCell.skillIdx = 0

		tbl = self:sortTeamArrangementHeroTable(tbl)
		for i,v in ipairs(tbl) do
			local info = self._heroElementsList[v]
			info.pos = i
			-- QPrintTable(info)
		end
		return needRresh ,false
	else --上阵
		local teamKey = self._teamKeys[self._trialNum]
		local teamVO = remote.teamManager:getTeamByKey(teamKey, false)
		local maxNum = teamVO:getHerosMaxCountBytrialNumAndIndex(self._trialNum,self._teamIndex)
		local curTable = self._teamArrangeHeroIds[self._trialNum][self._teamIndex] or {}
		if #curTable >= maxNum then
			app.tip:floatTip(QBaseArrangementWithDataHandle.HERO_FULL) 
			return false,false
		end
		table.insert(curTable ,elementCell.actorId)
		local num = #curTable
		elementCell.index = self._teamIndex
		elementCell.trialNum = self._trialNum
		curTable = self:sortTeamArrangementHeroTable(curTable)

		for i,v in ipairs(curTable) do
			local info = self._heroElementsList[v]
			info.pos = i
		end
		local  helpNum = self._teamHelpSkillMaxNumList[self._trialNum][self._teamIndex]
		if num <= helpNum then
			elementCell.skillIdx = num
		end
	end
	QPrintTable(elementCell)

	return true,true
end

function QBaseArrangementWithDataHandle:operateSingleSoulSpirit(_id)
	local elementCell = self._soulSpiritElementsList[_id]
	if not elementCell then
		return false
	end
	if elementCell.index ~= 0 then --下阵
		local needRresh = false
		if elementCell.trialNum == self._trialNum and elementCell.index == self._teamIndex then
			needRresh = true
		end
		local tbl = self._teamArrangeSoulSpiritIds[elementCell.trialNum][elementCell.index] or {}
		table.remove(tbl, elementCell.pos)
		elementCell.index = 0
		elementCell.trialNum = 0
		elementCell.pos = 0
		for i,v in ipairs(tbl) do
			local info = self._soulSpiritElementsList[v]
			info.pos = i
		end

		return needRresh,false
	else --上阵
		local teamKey = self._teamKeys[self._trialNum]
		local teamVO = remote.teamManager:getTeamByKey(teamKey, false)
		local maxNum = remote.soulSpirit:getTeamSpiritsMaxCountByTeamNum(#self._teamIndexIds)
		local curTable = self._teamArrangeSoulSpiritIds[self._trialNum][self._teamIndex] or {}
		if #curTable >= maxNum then
			app.tip:floatTip(QBaseArrangementWithDataHandle.SOUL_FULL) 
			return false,false
		end
		table.insert(curTable ,elementCell.id)
		elementCell.index = self._teamIndex
		elementCell.trialNum = self._trialNum
		elementCell.pos = #curTable

		for i,v in ipairs(curTable) do
			local info = self._soulSpiritElementsList[v]
			info.pos = i
		end

	end
	return true , true
end

function QBaseArrangementWithDataHandle:operateSingleGodArm(_id)
	local elementCell = self._godArmElementsList[_id]
	if not elementCell then
		return false
	end
	QPrintTable(elementCell)
	if elementCell.index ~= 0 then --下阵
		local needRresh = false
		if elementCell.trialNum == self._trialNum and elementCell.index == self._teamIndex then
			needRresh = true
		end
		local tbl = self._teamArrangeGodArmIds[elementCell.trialNum][elementCell.index] or {}
		table.remove(tbl, elementCell.pos)
		elementCell.index = 0
		elementCell.trialNum = 0
		elementCell.pos = 0
		for i,v in ipairs(tbl) do
			local info = self._godArmElementsList[v]
			info.pos = i
		end
		return needRresh,false

	else --上阵
		local teamKey = self._teamKeys[self._trialNum]
		local teamVO = remote.teamManager:getTeamByKey(teamKey, false)
		local maxNum = teamVO:getHerosMaxCountBytrialNumAndIndex(self._trialNum,self._teamIndex)
		local curTable = self._teamArrangeGodArmIds[self._trialNum][self._teamIndex] or {}
		if #curTable >= maxNum then
			app.tip:floatTip(QBaseArrangementWithDataHandle.GODARM_FULL) 
			return false,false
		end


		local characherCOnfig  = db:getCharacterByID(_id)
		local samelabelNum = 0
		for k, v in pairs(curTable) do
			local curtentConfig  = db:getCharacterByID(v)
			if characherCOnfig.label ~= nil and characherCOnfig.label == curtentConfig.label then
				samelabelNum = samelabelNum + 1
			end	
		end
		if samelabelNum >= 2 then
			app.tip:floatTip(QBaseArrangementWithDataHandle.GODARM_SAME_FULL) 
			return false,false
		end

		table.insert(curTable ,elementCell.id)
		elementCell.index = self._teamIndex
		elementCell.trialNum = self._trialNum

		for i,v in ipairs(curTable) do
			local info = self._godArmElementsList[v]
			info.pos = i
		end
		QPrintTable(self._teamArrangeGodArmIds[self._trialNum][self._teamIndex])


	end
	QPrintTable(elementCell)
	return true , true
end

function QBaseArrangementWithDataHandle:setTrialNum(_trialNum)
	if self._trialNum == _trialNum then
		return false
	end

	self._trialNum = _trialNum
	self._elementType = QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE
	self._jobType = 1

	self._teamIndex = remote.teamManager.TEAM_INDEX_MAIN

	return true
end

function QBaseArrangementWithDataHandle:setElementType(_elementType)
	if self._elementType == _elementType then
		return false
	end
	self._elementType = _elementType
	self._jobType = 1
	if self._elementType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
		self._teamIndex = remote.teamManager.TEAM_INDEX_MAIN
	elseif self._elementType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
		self._teamIndex = remote.teamManager.TEAM_INDEX_GODARM
	end
	return true
end

function QBaseArrangementWithDataHandle:setJobType(_jobType)
	-- if self._jobType == _jobType then
	-- 	return false
	-- end
	self._jobType = _jobType
	self._elementType = QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE
	if self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._teamIndex = remote.teamManager.TEAM_INDEX_MAIN
	end

	return true
end

function QBaseArrangementWithDataHandle:setTeamIndex(_teamIndex)
	if self._teamIndex == _teamIndex then
		return false
	end

	self._teamIndex = _teamIndex

	if self._teamIndex == remote.teamManager.TEAM_INDEX_GODARM then
		self._elementType = QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE
	elseif self._teamIndex >= remote.teamManager.TEAM_INDEX_MAIN then
		self._elementType = QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE
	end

	return true
end

--当前显示的列表信息表
function QBaseArrangementWithDataHandle:getCurShowArrayList()
	local resultTbl = {}
	if self._elementType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
		for k,v in pairs(self._heroElementsList or {}) do
			local condition = QBaseArrangementWithDataHandle.JOB_CON_FUNC[self._jobType].condition
			-- QPrintTable(v)
			if condition and condition(v.type) then
				table.insert(resultTbl, v)
			end
		end
	elseif self._elementType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
		for k,v in pairs(self._soulSpiritElementsList or {}) do
			table.insert(resultTbl,v)
		end
	elseif self._elementType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
		for k,v in pairs(self._godArmElementsList or {}) do
			table.insert(resultTbl,v)
		end
	end

	table.sort(resultTbl, function (x, y)
		return x.force > y.force
	end )

	return resultTbl
end

--当前显示上阵信息表
function QBaseArrangementWithDataHandle:getCurShowTeamArrangement(notEmpty)
	notEmpty = notEmpty == nil and false or notEmpty
	return self:getShowTeamArrangement(self._trialNum , self._teamIndex,notEmpty)
end

--指定队伍与类型	显示上阵信息表
function QBaseArrangementWithDataHandle:getShowTeamArrangement(_trialNum , _teamIndex,notEmpty)
	local resultTbl = {}
	local totalMaxNum = 4

	if _teamIndex == remote.teamManager.TEAM_INDEX_GODARM then
		--神器
		local curTable = self._teamArrangeGodArmIds[_trialNum][_teamIndex] or {}
		for i,v in ipairs(curTable) do
			local elementCell = self._godArmElementsList[v]
			table.insert(resultTbl,elementCell)
		end
		if not notEmpty then
			local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , _teamIndex , QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE)
			local curNum = #curTable
			self:addEmptyOrLockCell(resultTbl,curNum ,maxNum,totalMaxNum, QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE ,_teamIndex,_trialNum   )
		end




	elseif _teamIndex == remote.teamManager.TEAM_INDEX_MAIN then
		--魂师
		local curTable = self._teamArrangeHeroIds[_trialNum][_teamIndex] or {}
		if not q.isEmpty(curTable) then
			
			for i,v in ipairs(curTable) do
				local elementCell = self._heroElementsList[v]
				table.insert(resultTbl,elementCell)
			end
		end
		if  not notEmpty  then
			local curNum = #curTable
			local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , _teamIndex , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			self:addEmptyOrLockCell(resultTbl,curNum ,maxNum,totalMaxNum, QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE ,_teamIndex,_trialNum  )
		end


		--魂灵
		curTable = self._teamArrangeSoulSpiritIds[_trialNum][_teamIndex] or {}
		-- QPrintTable(curTable)
		for i,v in ipairs(curTable) do
			local elementCell = self._soulSpiritElementsList[v]
			table.insert(resultTbl,elementCell)
		end
		if  not notEmpty  then
			local curNum = #curTable
			local totalMaxNum = 2
			local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , _teamIndex , QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE)
			self:addEmptyOrLockCell(resultTbl,curNum ,maxNum,totalMaxNum, QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE,_teamIndex,_trialNum  )
		end

	else
		--魂师
		local curTable = self._teamArrangeHeroIds[_trialNum][_teamIndex] or {}
		if not q.isEmpty(curTable) then
			-- QPrintTable(curTable)
			for i,v in ipairs(curTable) do
				local elementCell = self._heroElementsList[v]
				table.insert(resultTbl,elementCell)
			end
		end
		if  not notEmpty  then
		local curNum = #curTable
			local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , _teamIndex , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			self:addEmptyOrLockCell(resultTbl,curNum ,maxNum,totalMaxNum, QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE,_teamIndex,_trialNum )
		end

	end
	return resultTbl
end




function QBaseArrangementWithDataHandle:setShowTeamArrangementByInfo(infos)
	local newteamArrangeHeroIds = {}
	local newteamArrangeSoulSpiritIds = {}
	local newteamArrangeGodArmIds = {}

	--根据多队阵容初始化数据
	for trialNum,teamKey in ipairs(self._teamKeys) do
		newteamArrangeHeroIds[trialNum] = {}
		newteamArrangeSoulSpiritIds[trialNum] = {}
		newteamArrangeGodArmIds[trialNum] = {}
		local teamVO = remote.teamManager:getTeamByKey(teamKey, false)
		local maxIndex = teamVO:getTeamMaxIndex()
		--处理魂师
		local pos = 1
		for index = 1,maxIndex do
			newteamArrangeHeroIds[trialNum][index] = {}
		end
		--处理魂灵
		newteamArrangeSoulSpiritIds[trialNum][remote.teamManager.TEAM_INDEX_MAIN] = {}
		newteamArrangeGodArmIds[trialNum][remote.teamManager.TEAM_INDEX_GODARM] = {}
	end

	for _trialNum,infoTbl in ipairs(infos) do
		-- newteamArrangeHeroIds[_trialNum]= {}
		-- newteamArrangeSoulSpiritIds[_trialNum]= {}
		-- newteamArrangeGodArmIds[_trialNum]= {}
		local sortHeroIds = {}
		for i,v in ipairs(infoTbl) do

			if v.oType < QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_ELE_TYPE then --排除空与禁止的元素
				-- QPrintTable(v)
				
				if v.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then

					local elementCell = self._heroElementsList[v.actorId or v.id]
					elementCell.pos = v.pos
					elementCell.index = v.index
					elementCell.trialNum = v.trialNum
					if elementCell.skillIdx and v.skillIdx then
						elementCell.skillIdx = v.skillIdx
					end	
					if sortHeroIds[v.index] == nil then
						sortHeroIds[v.index] = {}
					end
					table.insert(sortHeroIds[v.index] , v.actorId)
				elseif v.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then

					local elementCell = self._soulSpiritElementsList[v.actorId or v.id]
					elementCell.index = v.index
					elementCell.trialNum = v.trialNum
					if newteamArrangeSoulSpiritIds[_trialNum][v.index] == nil then
						newteamArrangeSoulSpiritIds[_trialNum][v.index] = {}
					end
					local num = #newteamArrangeSoulSpiritIds[_trialNum][v.index] 
					num = num + 1
					elementCell.pos = num					
					table.insert(newteamArrangeSoulSpiritIds[_trialNum][v.index] , v.id)					
				elseif v.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
					local elementCell = self._godArmElementsList[v.actorId or v.id]
					elementCell.index = v.index
					elementCell.trialNum = v.trialNum

					if newteamArrangeGodArmIds[_trialNum][v.index] == nil then
						newteamArrangeGodArmIds[_trialNum][v.index] = {}
					end
					local num = #newteamArrangeGodArmIds[_trialNum][v.index] 
					num = num + 1
					elementCell.pos = num

					table.insert(newteamArrangeGodArmIds[_trialNum][v.index] , v.id)					
				end
			end
		end
		for k,actorIds in pairs(sortHeroIds) do
			actorIds = self:sortTeamArrangementHeroTable(actorIds)
			if newteamArrangeHeroIds[_trialNum][k] == nil then
				newteamArrangeHeroIds[_trialNum][k] = {}
			end
			newteamArrangeHeroIds[_trialNum][k] = actorIds
			if k > remote.teamManager.TEAM_INDEX_MAIN then
				local  skillIdx = 1
				for i,v in ipairs(actorIds) do
					local elementCell = self._heroElementsList[v]
					elementCell.pos = i
					elementCell.skillIdx = skillIdx
					skillIdx = skillIdx + 1
				end
			else
				for i,v in ipairs(actorIds) do
					local elementCell = self._heroElementsList[v]
					elementCell.pos = i
				end
			end
		end

	end
	-- QPrintTable(newteamArrangeGodArmIds)
	self._teamArrangeHeroIds = newteamArrangeHeroIds
	self._teamArrangeSoulSpiritIds = newteamArrangeSoulSpiritIds
	self._teamArrangeGodArmIds = newteamArrangeGodArmIds

end


	-- EMPTY_HERO_ELE_TYPE = 96,
	-- EMPTY_SOUL_ELE_TYPE = 97,
	-- EMPTY_GODARM_ELE_TYPE = 98,
function QBaseArrangementWithDataHandle:addEmptyOrLockCell(resultTbl,curNum,maxNum,showNum,emptyType,index,trialNum)

	if curNum < maxNum then
		for i=curNum + 1,maxNum do
			local elementCell = {}
			elementCell.pos = i
			elementCell.index = index
			elementCell.trialNum = trialNum
			elementCell.oType = emptyType + QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_ELE_TYPE
			table.insert(resultTbl,elementCell)
		end
	end

	if maxNum < showNum then
		for i=maxNum + 1,showNum do
			local elementCell = {}
			elementCell.pos = i
			elementCell.index = index
			elementCell.trialNum = trialNum
			if emptyType + QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_ELE_TYPE == QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_HERO_ELE_TYPE then
				elementCell.lockStr =self:getLockStr(trialNum,index,emptyType,i)
			end
			elementCell.oType = emptyType + QBaseArrangementWithDataHandle.ELEMENT_TYPE.LOCK_ELE_TYPE
			table.insert(resultTbl,elementCell)
		end
	end
end

--魂师排序上阵显示
function QBaseArrangementWithDataHandle:sortTeamArrangementHeroTable(sortTable)
	table.sort(sortTable, function (x, y)
		local infoX = self._heroElementsList[x]
		local infoY = self._heroElementsList[y]

		local hatredX = 0
		local forceX = 0
		if infoX then
			hatredX = infoX.hatred or 0
			forceX = infoX.force or 0
		else
			local config = db:getCharacterByID(x)
			hatredX = config.hatred or 0
			forceX = remote.herosUtil:createHeroPropById(x):getBattleForce(self:getIsLocal())
		end

		local hatredY = 0
		local forceY = 0
		if infoY then
			hatredY = infoY.hatred or 0
			forceY = infoY.force or 0
		else
			local config = db:getCharacterByID(y)
			hatredY = config.hatred or 0
			forceY = remote.herosUtil:createHeroPropById(y):getBattleForce(self:getIsLocal())
		end

		if hatredX == hatredY then
			return forceX > forceY
		end
		return hatredX > hatredY
	end )

	return sortTable
end

--判断上阵后是否切页跳转或更换队伍操作
function QBaseArrangementWithDataHandle:handleArrangeMark(info)
	local _teamIndex = info.index
	local _trialNum = info.trialNum
	local _elementType = info.oType

	--首先判断上阵对象的队列是否已经满员
	if info then
		local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , _teamIndex , _elementType)
		local curTable = self:getTeamArrangeIdsByData(_trialNum , _teamIndex , _elementType)
		local curNum = #curTable
		if curNum < maxNum then
			return QBaseArrangementWithDataHandle.TRANSFORM_TYPE.NOT_REFRESH_TRANSFORM_TYPE
		end
	end
	local haveHero = self:checkHaveHeroRemaining()
	local haveSoul = self:checkHaveSoulSpiritRemaining()
	local haveGodArm = self:checkHaveGodArmRemaining()


	print("有剩余魂师 ："..(haveHero and "有" or "没有"))
	print("有剩余魂灵 ："..(haveSoul and "有" or "没有"))
	print("有剩余神器 ："..(haveGodArm and "有" or "没有"))
	--判断当前队伍是否满员
	for i,v in ipairs(self._teamIndexIds or {}) do
		if v == remote.teamManager.TEAM_INDEX_GODARM then
			print("检查神器")
			local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE)
			local curTable = self:getTeamArrangeIdsByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE)
			local curNum = #curTable
			if curNum < maxNum and haveGodArm then
				self:setTeamIndex(v)
				if _teamIndex > v then
					return QBaseArrangementWithDataHandle.TRANSFORM_TYPE.PAGE_FRONT_TRANSFORM_TYPE
				else
					return QBaseArrangementWithDataHandle.TRANSFORM_TYPE.PAGE_BACK_TRANSFORM_TYPE
				end
			end
		elseif v == remote.teamManager.TEAM_INDEX_MAIN then
			print("检查主力")
			local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			local curTable = self:getTeamArrangeIdsByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			local curNum = #curTable
			if curNum < maxNum and haveHero then
				local isCurIndex = v == self._teamIndex
				self:setTeamIndex(v)
				self:setElementType(QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
				return isCurIndex and QBaseArrangementWithDataHandle.TRANSFORM_TYPE.BUTTON_TRANSFORM_TYPE or QBaseArrangementWithDataHandle.TRANSFORM_TYPE.PAGE_FRONT_TRANSFORM_TYPE
			end
			maxNum = self:getTeamArrangeMaxNumByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE)
			curTable = self:getTeamArrangeIdsByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE)
			curNum = #curTable
			if curNum < maxNum and haveSoul then
			print("缺少魂灵")
				local isCurIndex = v == self._teamIndex
				self:setTeamIndex(v)
				self:setElementType(QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE)
				return isCurIndex and QBaseArrangementWithDataHandle.TRANSFORM_TYPE.BUTTON_TRANSFORM_TYPE or QBaseArrangementWithDataHandle.TRANSFORM_TYPE.PAGE_FRONT_TRANSFORM_TYPE
			end
		else
			print("检查替补")
			local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			local curTable = self:getTeamArrangeIdsByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			local curNum = #curTable
			print("检查替补	curNum "..curNum.."	maxNum "..maxNum)
			if curNum < maxNum and haveHero then
				self:setTeamIndex(v)
				if _teamIndex > v then
					return QBaseArrangementWithDataHandle.TRANSFORM_TYPE.PAGE_FRONT_TRANSFORM_TYPE
				else
					return QBaseArrangementWithDataHandle.TRANSFORM_TYPE.PAGE_BACK_TRANSFORM_TYPE
				end
			end
		end
	end

	local teamNum = #self._teamKeys

	if teamNum > _trialNum then

		self:setTrialNum(_trialNum + 1)
		return QBaseArrangementWithDataHandle.TRANSFORM_TYPE.TEAM_TRANSFORM_TYPE
	end


	return QBaseArrangementWithDataHandle.TRANSFORM_TYPE.NOT_REFRESH_TRANSFORM_TYPE
end


function QBaseArrangementWithDataHandle:getArrangementRedTips(_trialNum)
	local haveHero = self:checkHaveHeroRemaining()
	local haveSoul = self:checkHaveSoulSpiritRemaining()
	local haveGodArm = self:checkHaveGodArmRemaining()
	local tableResult = {}
	
	--判断当前队伍是否满员
	for i,v in ipairs(self._teamIndexIds or {}) do
		if v == remote.teamManager.TEAM_INDEX_GODARM then
			print("检查神器")
			local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE)
			local curTable = self:getTeamArrangeIdsByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE)
			local curNum = #curTable
			if curNum < maxNum and haveGodArm then
				tableResult[v] = 1			
			end
		elseif v == remote.teamManager.TEAM_INDEX_MAIN then
			print("检查主力")
			local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			local curTable = self:getTeamArrangeIdsByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			local curNum = #curTable
			if curNum < maxNum and haveHero then
				tableResult[v] = 1			
			end
			maxNum = self:getTeamArrangeMaxNumByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE)
			curTable = self:getTeamArrangeIdsByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE)
			curNum = #curTable
			if curNum < maxNum and haveSoul then
			print("缺少魂灵")
				tableResult[v] = 1			
			end
		else
			print("检查替补")
			local maxNum = self:getTeamArrangeMaxNumByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			local curTable = self:getTeamArrangeIdsByData(_trialNum , v , QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE)
			local curNum = #curTable
			print("检查替补	curNum "..curNum.."	maxNum "..maxNum)
			if curNum < maxNum and haveHero then
				tableResult[v] = 1			
			end
		end
	end
	return tableResult
end




--先进先出
function QBaseArrangementWithDataHandle:operateHelpHeroSkill(info)
	local helpSkillMaxNum = self._teamHelpSkillMaxNumList[info.trialNum][info.index] 
	if helpSkillMaxNum <= 0 then
		return false
	end

	if info.skillIdx > 0 then
		return false
	end
	local tbl = self._teamArrangeHeroIds[info.trialNum][info.index]

	if helpSkillMaxNum == 1 then
		for i,v in ipairs(tbl) do
			local elementCell = self._heroElementsList[v]
			if elementCell.skillIdx > 0 then
				elementCell.skillIdx = 0 
			elseif elementCell.actorId == info.actorId then
				elementCell.skillIdx = 1 
			end
		end
	else
		local targetNum = 1
		for i,v in ipairs(tbl) do
			local elementCell = self._heroElementsList[v]
			if elementCell.skillIdx > 0 then
				targetNum = targetNum + 1
			end
		end
		if helpSkillMaxNum > targetNum then
			info.skillIdx = targetNum
			return false
		else
			self._heroElementsList[info.actorId].skillIdx = targetNum
		end
	end

	return true
end

--num : +-1 进行单步左右切换使用
-- 返回左右按钮的显示状态
function QBaseArrangementWithDataHandle:changeTeamIndexByOffside(num)
	-- self._teamIndexIds
	-- self._teamIndex
	local targetTeamIndex =  1
	local targetTeamNum =  1

	for i,v in ipairs(self._teamIndexIds) do
		if self._teamIndex == v then
			targetTeamNum = i + num
			targetTeamIndex = self._teamIndexIds[targetTeamNum] or 1
			break
		end
	end
	self:setTeamIndex(targetTeamIndex)
end


return QBaseArrangementWithDataHandle
