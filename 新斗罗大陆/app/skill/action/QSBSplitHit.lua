local QSBAction = import(".QSBAction")
local QSBSplitHit = class("QSBSplitHit", QSBAction)

function QSBSplitHit:getTargets()
	if self._targets then
		return self._targets
	end
	local targets = {}
	table.mergeForArray(targets, self._options.selectTargets)
	self._targets = targets
	return targets
end

function QSBSplitHit:_execute(dt)
	local targets = self:getTargets()
	if targets == nil then self:finished() return end
	if self._options.on then
		local cfg = {percent = self._options.split_percent, targets = targets}
		for i,hero in ipairs(targets) do
			hero:insertSplitHitTargets(cfg, self._skill)
		end
	elseif self._options.off then
		for i,hero in ipairs(targets) do
			hero:removeSplitHitTargets(self._skill)
		end
	end
	self:finished()
end

function QSBSplitHit:_onCancel()
    self:_onRevert()
end

function QSBSplitHit:_onRevert()
	local targets = self:getTargets()
	if targets then
	    for i,hero in ipairs(targets) do
			hero:removeSplitHitTargets(self._skill)
		end
	end
end

return QSBSplitHit