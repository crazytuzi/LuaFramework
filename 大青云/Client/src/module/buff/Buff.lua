_G.classlist['Buff'] = 'Buff'
_G.Buff = {}
Buff.objName = 'Buff'
local buffMeta = { __index = Buff }
function Buff:new()
	return setmetatable({}, buffMeta)
end

function Buff:Init(id, buffId, time, caster)
	self.id     = id --实例ID
	self.buffId = buffId --配置表ID
	self.time   = time
	self.caster = caster
end

function Buff:Clear()
	self.id     = nil;
	self.buffId = nil;
	self.time   = nil;
	self.caster = nil;
end

function Buff:Update(interval)
	self.time = self.time - interval;
end

