--改变actor怒气相关的某个系数
local QSBAction = import(".QSBAction")
local QSBChangeRageCofficient = class("QSBChangeRageCofficient", QSBAction)

-- 必填参数有:
---- change_cofficient_name:怒气系数名
---- change_cofficient_value:怒气系数乘积因子

function QSBChangeRageCofficient:_execute(dt)
	if not self._options.change_cofficient_name or not self._options.change_cofficient_value then
		return
	end
	local targets = self._options.selectTargets or {}	--通过QSBArgsFindTargets获取
	if self._options.support_tianShiShengJian then
		targets = {app.battle:getFromMap("TIANSHISHENGJIAN_LAST_MAX_RAGE_ENEMY_ID")}
	end
	for k,v in ipairs(targets) do
		self:_changeRageCofficient(v)
	end	
	self:finished()
end

function QSBChangeRageCofficient:_changeRageCofficient(target)
	local name = self._options.change_cofficient_name
	local value = self._options.change_cofficient_value
	if self._options.not_rage_info then
		if target:getPropertyValue(name, "TIANSHISHENGJIAN_LAST_MAX_RAGE_ENEMY_ID") == nil then
            target:insertPropertyValue(name, "TIANSHISHENGJIAN_LAST_MAX_RAGE_ENEMY_ID", "+", value)
        else
            target:modifyPropertyValue(name, "TIANSHISHENGJIAN_LAST_MAX_RAGE_ENEMY_ID", "+", value)
        end
	else
		local actorRageInfo = target:getRageInfo()
		if actorRageInfo and actorRageInfo[name] then
			actorRageInfo[name] = actorRageInfo[name] * value
		end
	end
end

return QSBChangeRageCofficient