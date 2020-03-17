--[[
	人物时装
	liyuan
--]]
_G.classlist['PlayerFashions'] = 'PlayerFashions'
_G.PlayerFashions = {}
PlayerFashions.objName = 'PlayerFashions'
PlayerFashions.fashionDic = {}
PlayerFashions.fashionWuqiId = nil
PlayerFashions.prof = nil
function PlayerFashions:New()
	local obj = {}
	obj.fashions = {};
	setmetatable(obj, {__index = PlayerFashions})
	return obj
end

-- 时装赋值
function PlayerFashions:InitFashions(headId, bodyId, wuqiId, prof)
	self.fashionDic = {}
	self.fashionWuqiId = 0
	if prof and prof ~= 0 then
		self.prof = prof
	end
	--头
	if headId and headId ~= 0 then
		self:SetFashModel(headId,self.fashionDic)
	end
	--身体
	if bodyId and bodyId ~= 0 then
		self:SetFashModel(bodyId,self.fashionDic)
	end
	--武器
	if wuqiId and wuqiId ~= 0 then
		self.fashionWuqiId = wuqiId
	end
end

-- 得到时装武器
function PlayerFashions:GetFashionWeapon()
	if self.fashionWuqiId and self.fashionWuqiId ~= 0 then
		local vo = t_fashions[self.fashionWuqiId];
		local idx = 'vmesh'.. self.prof;
		local modelFile = vo[idx];
		return modelFile
	end
	
	return nil
end

function PlayerFashions:GetFashionArmPfx()
	if self.fashionWuqiId and self.fashionWuqiId ~= 0 then
		local vo = t_fashions[self.fashionWuqiId]
		if vo then
			return vo['pfxname' .. self.prof], vo['bone' .. self.prof]
		end
	end
end

function PlayerFashions:GetFashionDressPfx(dressId)
	if dressId and dressId ~= 0 then
		local vo = t_fashions[dressId]
		if vo then
			return vo['pfxname' .. self.prof], vo['bone' .. self.prof]
		end
	end
end

-- 把时装加到换装中
function PlayerFashions:GetDressWithFashions(dressTable)
	-- FTrace(self.fashionDic,'把时装加到换装中')
	for k, v in pairs(self.fashionDic) do
		dressTable[k] = v
	end
end

-- 把上一次的时装加到换装中
function PlayerFashions:GetOldDressWithFashion(headId, bodyId, dressTable)
	self.oldFashionDic = {}
	--头
	if headId and headId ~= 0 then
		self:SetFashModel(headId,self.oldFashionDic)
	end
	--身体
	if bodyId and bodyId ~= 0 then
		self:SetFashModel(bodyId,self.oldFashionDic)
	end
	
	for k, v in pairs(self.oldFashionDic) do
		dressTable[k] = v
	end
end

-- 内部方法
-- 得到时装 除武器外的
function PlayerFashions:GetFashionByPart(part)
	if self.fashionDic[part] then
		return self.fashionDic[part]
	end
	
	return nil
end

-- 把时装加入字典
function PlayerFashions:SetFashModel(fashionId, fashionDic)
	local vo = t_fashions[fashionId]
	if vo then
	    local idx = 'vmesh'.. self.prof
	    local modelFile = vo[idx]
		if modelFile and modelFile ~= "" then 
			local dressTable = GetPoundTable(modelFile)
			if dressTable and #dressTable > 1 then
				for index, dressConfig in pairs(dressTable) do
					local dressFile = GetColonTable(dressConfig)
					fashionDic[dressFile[1]] = dressFile[2]
				end
			else 
				local dressFile = GetColonTable(modelFile)
				fashionDic[dressFile[1]] = dressFile[2]
			end
		end
	end
end

function PlayerFashions:GetFashionsDress()
	if self.fashionDic and next(self.fashionDic) then
		return self.fashionDic
	end
end

function PlayerFashions:SetFashions(headId, bodyId, wuqiId, prof)
	for i,item in pairs(self.fashions) do
		item.append = false;
	end
	
	local append = function(fashionId,prof)
		local id = self:GetFashModelId(fashionId,prof);
		if id ~= 0 then
			local fashion = self.fashions[id];
			if not fashion then
				fashion = {id=id,append=true};
				self.fashions[id] = fashion;
			end
			fashion.append = true;
		end
	end
	append(headId,prof);
	append(bodyId,prof);
	append(wuqiId,prof);
end

function PlayerFashions:GetFashions()
	return self.fashions;
end

function PlayerFashions:RemoveFashion(fashionId)
	self.fashions[fashionId] = nil;
end

function PlayerFashions:GetFashModelId(fashionId,prof)
	local result = 0;
	local cfg = t_fashions[fashionId];
	if cfg then
		result = cfg['vmesh'.. prof]=='' and 0 or toint(cfg['vmesh'.. prof]);
	end
	return result;
end
