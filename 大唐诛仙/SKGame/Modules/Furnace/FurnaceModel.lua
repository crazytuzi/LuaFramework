FurnaceModel = BaseClass(LuaModel)
function FurnaceModel:__init()
	self.openType = 0

	self.listMap = {}
	self.furnaceList = {} -- {FurnaceVo}

	local ids = FurnaceConst.cfgIds
	for i=1,#ids do
		local id = ids[i]
		local cfg = GetCfgData("furnace")
		for _,v in ipairs(cfg) do
			if type(v) ~= "function" and v.furnaceId == id then
				if self.listMap[id]== nil then
					self.listMap[id] = {}
				end
				table.insert(self.listMap[id], v)
			end
		end
	end
end
function FurnaceModel:UpdateItem(data)
	if not data then return end
	local id = data.furnaceId
	if self.furnaceList[id] then
		self.furnaceList[id]:Update(data)
	else
		self.furnaceList[id]=FurnaceVo.New(data)
	end
end
function FurnaceModel:GetActivedData()
	return self.furnaceList
end
function FurnaceModel:GetActivedVo( id )
	return self.furnaceList[id]
end
function FurnaceModel:GetListMap()
	return self.listMap
end

-- 读表
function FurnaceModel:GetCfg(key)
	return GetCfgData("furnace"):Get( key )
end
function FurnaceModel:GetCfgByFurnaceId(id)
	-- if id and self.listMap[id] then
	return self.listMap[id]
	-- end
	-- local cfg = GetCfgData("furnace")
	-- for _,v in ipairs(cfg) do
	-- 	if type(v) ~= "function" and v.furnaceId == id then
	-- 		if self.listMap[id]== nil then
	-- 			self.listMap[id] = {}
	-- 		end
	-- 		table.insert(self.listMap[id], v)
	-- 	end
	-- end
	-- return self.listMap[id]
end

function FurnaceModel:GetCfgItem(stage,star,id)
	local list = self:GetCfgByFurnaceId(id)
	for i, v in ipairs(list) do
		if v.stage == stage and v.star == star then
			return v
		end
	end
	return nil
end


function FurnaceModel:GetInstance()
	if FurnaceModel.inst == nil then
		FurnaceModel.inst = FurnaceModel.New()
	end
	return FurnaceModel.inst
end

function FurnaceModel:__delete()
	
	FurnaceModel.inst = nil
end