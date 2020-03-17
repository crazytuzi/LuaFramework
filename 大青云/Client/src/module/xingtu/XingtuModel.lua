--[[
祈愿	
yujia
]]

_G.XingtuModel = Module:new();
XingtuModel.nMaxLev = 9

XingtuModel.tXingtuList = {};

function XingtuModel:Updatainfo(id, nLev, nSize)
	local vo = {};
	vo.id = id;
	vo.nLev = nLev ~= 0 and nLev or 1
	vo.nSize = nSize;
	self.tXingtuList[id] = vo
end

function XingtuModel:GetInfoById(id)
	return self.tXingtuList[id] or {id = id, nLev = 1, nSize = 0}
end

function XingtuModel:IsHaveCanLvUp(index)
	local startIndex, endIndex = 1, 28
	if index then
		startIndex = 7*(index - 1) + 1
		endIndex = 7*index
	end
	for i = startIndex, endIndex do
		if XingtuUtil:isCanLvUp(i) == 0 then
			local info = self:GetInfoById(i)
			return true, info.nLev == 1 and info.nSize == 0 and 1 or 2
		end
	end
	return false
end