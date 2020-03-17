--[[FumoModel
chenyujia
2016-5-18
]]

_G.FumoModel = Module:new();

--- 数据表
FumoModel.fumoList = {}

--- 上线客户端初始化
function FumoModel:initData()
	for k, info in pairs(t_fumobasic) do
		local map = info.map
		if not self.fumoList[map] then
			self.fumoList[map] = {}
		end
		self.fumoList[map][info.id] = Fumo:new(info.id, info)
	end
end

function FumoModel:UpdataData(info)
	local Fumo = self:GetFumo(info.id)
	if not Fumo then return end

	Fumo:SetLv(info.lv)
	Fumo:SetCount(info.used_num)
end

function FumoModel:GetFumo(id)
	for k, v in pairs(self.fumoList) do
		for k1, v1 in pairs(v) do
			if k1 == id then
				return v1
			end
		end
	end
end

function FumoModel:GetFumoList(nPage)
	if nPage then
		local list = {}
		for k, v in pairs(self.fumoList) do
			for k1, v1 in pairs(v) do
				if v1:GetPage() == nPage then
					list[k] = v
				end
				break
			end
		end
		return list
	else
		return self.fumoList
	end
end

--根据图鉴类型获取数量
function FumoModel:GetCountByMap(map)
	local tMap = self.fumoList[map]
	if not tMap then return 0 end
	local nCount = 0
	for k, v in pairs(tMap) do
		nCount = nCount + 1
	end
	return nCount
end

--- 根据图鉴类型获取表
function FumoModel:GetListByMap(map)
	return self.fumoList[map] or {}
end