--ModuleUnlock.lua

require("app.cfg.function_level_info")
local funLevelConst = require("app.const.FunctionLevelConst")
local BattleLayer = require("app.scenes.battle.BattleLayer")
local storage = require("app.storage.storage")
local ModuleUnlock = class("ModuleUnlock")

function ModuleUnlock:ctor( ... )
	self:resetData()

	self:_init()
end

function ModuleUnlock:_init( ... )
	local newLevel = G_Me.userData.level or 0
	self._currentLevel = newLevel
	self._lastLevel = newLevel

	self._realLastLevel = newLevel

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_ROLE_INFO, self._onRoleInfoChange, self)
	uf_eventManager:addEventListener(BattleLayer.BATTLE_FINISH, self._onBattleFinish, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FINISH_PLAY_FIGHTEND, self._onPlayFightend, self)


	-- 记录玩家有没有查看过新功能
	self._moduleStateStorgePath = "moduleState.data"

end

function ModuleUnlock:unInit( ... )
	if uf_eventManager then 
		uf_eventManager:removeListenerWithTarget(self)
	end
end

function ModuleUnlock:resetData( ... )
	self._currentLevel = 0
	self._lastLevel = 0
	self._realLastLevel = 0

	self._upgradeLevelArr = {}
	self._upgradeFlag = false
end

function ModuleUnlock:_onRoleInfoChange(  )
	local newLevel = G_Me.userData.level

	if self._currentLevel < 1 then
		self._currentLevel = newLevel
		self._lastLevel = newLevel
		return 
	end

	if self._lastLevel < 1 then 
		self._lastLevel = newLevel
	else
		self._lastLevel = self._currentLevel
	end
	self._currentLevel = newLevel


	if self._lastLevel < self._currentLevel then 
		self:_onLevelUpgrade()
	elseif self._lastLevel > self._currentLevel then 
		__Log("level upgrade error:%d, %d", self._lastLevel, self._currentLevel)
		--require("upgrade.ErrMsgBox").showErrorMsgBox(text)
	end	
end

function ModuleUnlock:_onBattleFinish()
	self._upgradeFlag = false
end

function ModuleUnlock:_onPlayFightend( ... )
	if #self._upgradeLevelArr < 1 then 
		return 
	end

	self:_checkUnlockModule()
end

function ModuleUnlock:_onLevelUpgrade( ... )
	__Log("--------------------Level update---------------------")
	__Log("current level is:%d", self._currentLevel)
	__Log("-----------------------------------------------------")

	self._realLastLevel = self._lastLevel
	
	table.insert(self._upgradeLevelArr, #self._upgradeLevelArr + 1, {self._lastLevel, self._currentLevel})
	
	dump(self._upgradeLevelArr)
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_USER_LEVELUP, nil, true, self._lastLevel, self._currentLevel)
	self._upgradeFlag = true
end

function ModuleUnlock:getLevelUpgradeFlag(  )
	local flag = self._upgradeFlag
	self._upgradeFlag = false
	return flag
end

function ModuleUnlock:getRealLastLevel(  )
	--return self._lastLevel  --直接返回这个是不对的 因为_onRoleInfoChange会调用两次导致self._lastLevel=self._currentLevel
	return self._realLastLevel
end

function ModuleUnlock:setRealLastLevel( lastLevel )
	local _lastLevel = 0

	if lastLevel and type(lastLevel) == "number" then
		_lastLevel = lastLevel
	end
	
	self._realLastLevel = _lastLevel
end

function ModuleUnlock:_checkUnlockModule(  )
	-- temp codes for test guiding bug
	if self._lastLevel > 30 then
		return 
	end

	local hasUnlockModule = function ( level )
		if type(level) ~= "number" or level < 2 then 
			return false
		end
		for key, value in pairs(self._upgradeLevelArr) do 
			if type(value) == "table" and #value == 2 then 
				if value[1] < level and level <= value[2] then
					return true
				end
			end
		end

		return false
	end

	local nextStepId = 0
	local stepComment = "[new module unlock!]"
	for i = 1, function_level_info.getLength() do 
		local funLevelInfo = function_level_info.get(i)
		if funLevelInfo then 
			if funLevelInfo.step_id > 0 and hasUnlockModule(funLevelInfo.level) then 
				nextStepId = funLevelInfo.step_id
				stepComment = funLevelInfo.directions
			end
		end
	end

	self._upgradeLevelArr = {}
	
	if nextStepId < 1 then 
		return 
	end

	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GUIDE_MODULE_STEP_ID, nil, true, nextStepId, stepComment, true)
end

function ModuleUnlock:getModuleUnlockLevel( moduleId )
	if not moduleId then 
		return -1
	end

	local funLevelInfo = function_level_info.get(moduleId)
	if not funLevelInfo then 
		__LogError("error moduleId:%d", moduleId or 0)
		return -1
	end

	return funLevelInfo.level
end

function ModuleUnlock:getModuleUnlockVip( moduleId )
	if not moduleId then
		return 0
	end

	local funLevelInfo = function_level_info.get(moduleId)
	if not funLevelInfo then
		__LogError("error moduleId:%d", moduleId or 0)
		return 0
	end

	return funLevelInfo.vip_level
end

function ModuleUnlock:isModuleUnlock( moduleId, flag )
	local level = self:getModuleUnlockLevel(moduleId, flag)
	if level <= 0 then 
		return false
	end

	local isLevelReach = false
	if flag then 
		if self._upgradeFlag then
			isLevelReach = (self._currentLevel > level)
		else
			isLevelReach = (self._currentLevel >= level)
		end
	else
		isLevelReach = self._currentLevel >= level
	end

	local unlockVip = self:getModuleUnlockVip(moduleId)
	local isVipReach = false
	if unlockVip > 0 then
		isVipReach = G_Me.userData.vip >= unlockVip
	end

	return isLevelReach or isVipReach
end

function ModuleUnlock:canPreviewModule(moduleId)
	local unlockLevel 	= self:getModuleUnlockLevel(moduleId)
	local unlockVip 	= self:getModuleUnlockVip(moduleId)
	local previewLevel 	= unlockLevel - 5
	local previewVip	= unlockVip - 2

	local canPreviewByLevel = previewLevel > 0 and self._currentLevel >= previewLevel
	local canPreviewByVip   = previewVip > 0 and G_Me.userData.vip >= previewVip

	return canPreviewByLevel or canPreviewByVip
end

function ModuleUnlock:checkModuleUnlockStatus( moduleId, flag )
	local unlockFlag = self:isModuleUnlock(moduleId, flag)

	if not unlockFlag then 
		local funLevelInfo = function_level_info.get(moduleId)
		G_MovingTip:showMovingTip(funLevelInfo and funLevelInfo.comment or "Un-locked!")
		return false
	end

	return true
end

function ModuleUnlock:checkUnopenModuleGuide( curStep )
	curStep = curStep or 0
	local guideSteps = {}

	local curLevel = G_Me.userData.level
	for i = 1, function_level_info.getLength() do 
		local funLevelInfo = function_level_info.get(i)
		if funLevelInfo.level <= curLevel and curStep < funLevelInfo.step_id then 
			table.insert(guideSteps, #guideSteps + 1, {funLevelInfo.step_id, funLevelInfo.directions})
		else
			--__Log("level:%d, curLevel:%d, step:%d, curStep:%d", funLevelInfo.level, curLevel, funLevelInfo.step_id, curStep)
		end
	end

	local sortFun = function ( step1, step2 )
		if not step2 then 
			return false
		end

		if not step1 then 
			return step2 and true or false
		end

		return step1[1] < step2[1]
	end
	table.sort(guideSteps, sortFun)

	return guideSteps
end

function ModuleUnlock:_getModuleByGuideId( stepId )
	if type(stepId) ~= "number" or stepId < 1 then 
		return 0
	end

	for i = 1, function_level_info.getLength() do 
		local funLevelInfo = function_level_info.get(i)
		if funLevelInfo and funLevelInfo.step_id == stepId then 
			return funLevelInfo.id
		end
	end

	return 0
end

--是否为新模块
function ModuleUnlock:isNewModule( moduleId )
	if not moduleId or type(moduleId) ~= "number" then return false end

	if not self:isModuleUnlock(moduleId) then return false end

	--NOTICE:
	--默认小于这个值都是老功能了  每次发新版本有新功能模块时，需要修改这个值
	if moduleId < funLevelConst.NEW_FUNCTION_FLOOR then 
		return false
	end

	-- 读取本地数据
	local _szStorgePath = self._moduleStateStorgePath

    local tLocalData = storage.load(storage.rolePath(_szStorgePath))

    --dump(tLocalData)

    if tLocalData == nil then
        tLocalData = {}
        tLocalData[tostring(moduleId)] = 0
        storage.save(storage.rolePath(_szStorgePath), tLocalData)
        return true
    end

    if not tLocalData[tostring(moduleId)] then
    	tLocalData[tostring(moduleId)] = 0
        storage.save(storage.rolePath(_szStorgePath), tLocalData)
        return true
    else
    	return tLocalData[tostring(moduleId)] == 0
    end
end

--设置模块状态
function ModuleUnlock:setModuleEntered( moduleId )
	if not moduleId or type(moduleId) ~= "number" then return false end

	if not self:isModuleUnlock(moduleId) then return false end

	-- 读取本地数据
	local _szStorgePath = self._moduleStateStorgePath
    local tLocalData = storage.load(storage.rolePath(_szStorgePath))

    if tLocalData == nil then
        tLocalData = {}
    end

    --print("------------set module id="..tostring(moduleId))
    if not tLocalData[tostring(moduleId)] or tLocalData[tostring(moduleId)] == 0 then 
	    tLocalData[tostring(moduleId)] = moduleId
    	storage.save(storage.rolePath(_szStorgePath), tLocalData)
    	return true
    end

    return false
    
end


return ModuleUnlock
