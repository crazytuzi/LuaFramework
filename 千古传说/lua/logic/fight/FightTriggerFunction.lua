--[[
/*code is far away from bug with the animal protecting
    *  ┏┓　　　┏┓
    *┏┛┻━━━┛┻┓
    *┃　　　　　　　┃ 　
    *┃　　　━　　　┃
    *┃　┳┛　┗┳　┃
    *┃　　　　　　　┃
    *┃　　　┻　　　┃
    *┃　　　　　　　┃
    *┗━┓　　　┏━┛
    *　　┃　　　┃神兽保佑
    *　　┃　　　┃代码无BUG！
    *　　┃　　　┗━━━┓
    *　　┃　　　　　　　┣┓
    *　　┃　　　　　　　┏┛
    *　　┗┓┓┏━┳┓┏┛
    *　　　┃┫┫　┃┫┫
    *　　　┗┻┛　┗┻┛
    *　　　
    */
]]
local FightTriggerFunction = {}

local fightRoleMgr = require("lua.logic.fight.FightRoleManager")
-- 回合数
function FightTriggerFunction:getRoundComplete( conditions )
	if conditions.value and conditions.value >= FightManager.nCurrRoundNum then
		return true
	end
	return false
end
-- 存活数
function FightTriggerFunction:getLiveNum( conditions )
	local liveList= fightRoleMgr:GetAllLiveRole(false, false, false)
	if conditions.value and conditions.value <= liveList:length() then
		return true
	end
	return false
end
-- 血上限
function FightTriggerFunction:getHpPercent( conditions )
    if conditions.value then
        return fightRoleMgr:isAllHpPercent(false,conditions.value)
    end
    return false
end

-- 技能个数
function FightTriggerFunction:getUseSKillNum( conditions )
	if conditions.value then
		return FightManager.manualActionNum < conditions.value
	end
	return false
end


return FightTriggerFunction