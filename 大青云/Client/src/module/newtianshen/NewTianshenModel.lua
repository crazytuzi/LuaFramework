--[[
	新天神
]]

_G.NewTianshenModel = Module:new()
NewTianshenModel.tianshenList = {}
NewTianshenModel.isTransfor=false;
NewTianshenModel.newList = {}
NewTianshenModel.isFirst = true

--天神数据初始化
function NewTianshenModel:InitData(data)
	local fightChanged = false;
	local ready = nil;
	for k, v in pairs(data) do
		local tianshen = self.tianshenList[v.id]
		if tianshen then
			tianshen:UpdataInfo(v)
		else
			if not self.isFirst then
				self.newList[v.id] = true
			end
			tianshen = NewTianshen:CreateTianshen(v)
			self.tianshenList[tianshen:GetId()] = tianshen
		end
		
		if tianshen:GetPos() == 0 then
			ready = tianshen;
		end
		
	end
	
	fightChanged = NewTianshen:Equal(self.changeBefore,ready);
	if fightChanged then
		self.changeBefore = NewTianshen:Clone(ready);
		TianShenController:UpdateState(true);
	end
	
	NewTianshenController:sendNotification(NotifyConsts.newtianShenUpUpdata,{fightChanged=fightChanged})
	self.isFirst = false
end

function NewTianshenModel:DisTianshen(id)
	self.tianshenList[id] = nil
end

-- 获取天神列表
function NewTianshenModel:GetTianshenList()
	return self.tianshenList
end

-- 获取天神出战列表
function NewTianshenModel:GetFightList()
	local fightList = {}
	for k, v in pairs(self.tianshenList) do
		if v:GetPos() ~= -1 then
			fightList[v:GetPos()] = v
		end
	end
	return fightList
end

-- 获取天神数量
function NewTianshenModel:GetAllCount()
	local count = 0
	for k, v in pairs(self.tianshenList) do
		count = count + 1
	end
	return count
end

---获取天神
function NewTianshenModel:GetTianshen(id)
	return self.tianshenList[id]
end

--- 判断天神是否出战 出战的不给分解
function NewTianshenModel:IsFight(tianshen)
	return false
end

--获取第几个出站的天神
function NewTianshenModel:GetTianshenByFightSize(size)
	for k, v in pairs(self.tianshenList) do
		if v:GetPos() == size then
			return v
		end
	end
end

--判断是否有出站的天神
function NewTianshenModel:IsHaveTianshenFight()
	for k, v in pairs(self.tianshenList) do
		if v:GetPos() ~= -1 then
			return true
		end
	end
	return false
end

--- 顺序获取空天神位
function NewTianshenModel:GetNoTianshenPos()
	for i = 0, 5 do
		local tianshen = self:GetTianshenByFightSize(i)
		if not tianshen then
			if NewTianshenUtil:GetTianshenFightOpenLv(i) <= MainPlayerModel.humanDetailInfo.eaLevel then
				return i
			end
		end
	end
end

-- 天神是否出阵
function NewTianshenModel:HaveFightByTianshenID(ID)
	for k, v in pairs(self:GetFightList()) do
		if v:GetTianshenID() == ID then
			return true
		end
	end
	return false
end

-- 点击上阵左侧有可以替换的天神
function NewTianshenModel:GetCanChangeTianshen(tianshen)
	for k, v in pairs(self:GetFightList()) do
		if v:GetTianshenID() == tianshen:GetTianshenID() then
			return v
		end
	end
	for k, v in pairs(self:GetFightList()) do
		if v:GetZizhi() < tianshen:GetZizhi() then
			return v
		end
	end
	return nil
end

-- 当前天神是否比上阵的天神战斗力高
function NewTianshenModel:IsMoreFight(tianshen)
	local fightList = self:GetFightList()
	for k, v in pairs(fightList) do
		if v:GetTianshenID() == tianshen:GetTianshenID() then
			return v:GetZizhi() < tianshen:GetZizhi() and true or false
		end
	end
	for i = 0, 5 do
		if not fightList[i] then
			if MainPlayerModel.humanDetailInfo.eaLevel >= NewTianshenUtil:GetTianshenFightOpenLv(i) then
				return true
			end
		else
			if fightList[i]:GetZizhi() < tianshen:GetZizhi() then
				return true
			end
		end
	end
	return false
end