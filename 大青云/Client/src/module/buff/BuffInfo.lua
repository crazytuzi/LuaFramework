_G.classlist['BuffInfo'] = 'BuffInfo' 
_G.BuffInfo = {}
BuffInfo.objName = 'BuffInfo'

local metaBuffInfo = {__index = BuffInfo}
function BuffInfo:new()
	local buffInfo = {}
	setmetatable(buffInfo, metaBuffInfo)
	buffInfo.buffList = {};
	return buffInfo
end

function BuffInfo:GetBuffList()
	return self.buffList;
end

function BuffInfo:GetBuff(id)
	return self.buffList[id]
end

function BuffInfo:AddBuff(buff)
	self.buffList[buff.id] = buff
end

function BuffInfo:DeleteBuff(id)
	local buff = self.buffList[id];
	self.buffList[id] = nil
end

--@param interval 单位 ms
function BuffInfo:Update(interval)
	for id, buff in pairs(self.buffList) do
		buff:Update(interval);
	end
end
