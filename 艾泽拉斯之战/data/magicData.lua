local attCollectionClass  = include("attCollection")

-- magic实例类
local kingMagicDataClass = class("kingMagicDataClassClass")
-- magic管理类
local kingMagicClass  = class("kingMagicClass")
 
local ATT_CUR__SKILL_CD  = "CUR__SKILL_CD"
local ATT_MAGIC_EXP = "ATT_MAGIC_EXP";
local ATT_CUR__SKILL_NUM = "ATT_CUR__SKILL_NUM"

function kingMagicDataClass:ctor(magicId)
	self.att = attCollectionClass.new()
	self.magicId = magicId	
	self.star = 0;
	
	local config = self:getConfig()
	self:setCurCD(config.cooldownOnStart)
	self:setCurNum(config.castTimes)
	self:setExp(0);
	
	self.currentExp = 0;
	self.nextExp = 1;

end 	

function kingMagicDataClass:getNewGainedFlag()
	return dataManager.playerData:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_MAGIC_VIEW_STAMP, self.magicId);
end

function kingMagicDataClass:setNewGainedFlag()
	sendViewStamp(enum.VIEW_STAMP_TYPE.VIEW_STAMP_TYPE_MAGIC, self.magicId);
end

function kingMagicDataClass:getCurCD()
	return self.att:getAttr(ATT_CUR__SKILL_CD)		
end 

function kingMagicDataClass:setCurCD(cd)
	if(cd<0)then
		cd = 0
	end
	return self.att:setAttr(ATT_CUR__SKILL_CD,cd)		
end



function kingMagicDataClass:isNumOver()
	return self:getCurNum()	== 0
end 

function kingMagicDataClass:getCurNumStr()
	 local config = self:getConfig()
	if(config.castTimes == -1)then
		return "n"
	end
	return self:getCurNum()
end 

function kingMagicDataClass:getCurNum()
	return self.att:getAttr(ATT_CUR__SKILL_NUM)		
end 

function kingMagicDataClass:setCurNum(n)
	local config = self:getConfig()
	if(config.castTimes == -1)then
		if(n <= -1 )then
			n = -1 
		end
	else
		if(n <= 0 )then
			n = 0 
		end
	end
	self.att:setAttr(ATT_CUR__SKILL_NUM,n)		
end

 

function kingMagicDataClass:getExp()
	return self.att:getAttr(ATT_MAGIC_EXP)
end

-- UI上显示的当前经验
function kingMagicDataClass:getCurrentExp()
	return self.currentExp;
end

function kingMagicDataClass:getNextExp()
	return self.nextExp;
end

function kingMagicDataClass:getStar()
	return self.star;
end

-- 是否获得该魔法 星级大于1
function kingMagicDataClass:isActive()
	return self:getStar() >=1;
end

function kingMagicDataClass:isTopLevel()
	return self.star == #dataConfig.configs.ConfigConfig[0].magicLevelExp
end



function kingMagicDataClass:getMpCost(rate)
	rate = rate or 1 
	local cost = 0
	local config = self:getConfig()
	local costConfig = config.cost
	local level =  self:getStar()
	
	cost = costConfig[level] or costConfig[1] 
	cost = math.floor(cost * rate	+0.5)		
	return cost
end





function kingMagicDataClass:setExp(exp)
	self.att:setAttr(ATT_MAGIC_EXP, exp);
	
	-- 更新一下star
	local oldStar = self.star;
	self.star = dataManager.kingMagic:getStarByExp(exp);
	
	self.currentExp, self.nextExp = dataManager.kingMagic:getCurrentAndNextByExp(exp);
	
	-- 更新一下sort list
	dataManager.kingMagic:onMagicExpChange(self.magicId, exp);
	
end

function kingMagicDataClass:enterCD()
	local config = self:getConfig()
	self:setCurCD(config.cooldown)
end


function kingMagicDataClass:enterNum()
	self:setCurNum(self:getCurNum()- 1)	
end


 
function kingMagicDataClass:getConfig()
	return  dataConfig.configs.magicConfig[self.magicId]	
end 	

function kingMagicDataClass:release()
	self.att = nil
end			

function kingMagicClass:ctor()
	 self.magics = {}
	
	 -- 万能碎片经验
	 self.exp = 0;
	 
	 -- 融合标志位
	 self.magicTowerFlag = false;
	 
	 -- 需要一个星级的排序列表。。
	 -- 初始化时按照magic表的顺序初始化
	 -- 当某个magic的exp发生变化时，再更新列表
	self.sortMagicIDList = {};

	self.tipsMagicID = -1;
	
	-- 大力魔法 
	self.greatMagic = {};

end

function kingMagicClass:init()

	for i,v in ipairs (dataConfig.configs.magicConfig) do
		self:addMagic(i);
		self.sortMagicIDList[i] = {
			magicID = i,
			exp = 0,
		};
	end
		
	-- 写死魔法箭的经验
	local mofajian = self:getMagic(1);
	if mofajian then
		mofajian:setExp(dataConfig.configs.ConfigConfig[0].magicLevelExp[1]);
	end
	
end

function kingMagicClass:setGreatMagic(greatMagic)
	self.greatMagic = greatMagic;
end

function kingMagicClass:getGreatMagic()
	return self.greatMagic;
end

function kingMagicClass:isGreatMagic(magicID)
	
	--for k,v in pairs(self.greatMagic) do
	--	if v == magicID then
	--		return true;
	--	end
	--end
	local magicConfig = dataConfig.configs.magicConfig[magicID];
	
	return magicConfig and magicConfig.isGreatMagic;
	--return false;
end

function kingMagicClass:getSortMagicIDList()
	return self.sortMagicIDList;
end

function kingMagicClass:setTipsMagicID(magicID)
	self.tipsMagicID = magicID;
end

function kingMagicClass:getTipsMagicID()
	return self.tipsMagicID;
end

function kingMagicClass:setTipsMagicLevel(level)
	self.tipsMagicLevel = level;
end

function kingMagicClass:getTipsMagicLevel()
	return self.tipsMagicLevel;
end

function kingMagicClass:setTipsMagicIntelligence(intelligence)
	self.tipsMagicIntelligence = intelligence;
end

function kingMagicClass:getTipsMagicIntelligence()
	return self.tipsMagicIntelligence;
end

-- 合并等级和智力参数
function kingMagicClass:mergeLevelIntelligence(level, intelligence)
	return intelligence*100 + level;
end

-- 解析等级和智力参数
function kingMagicClass:parseLevelIntelligence(data)
	local magicLevel = math.fmod(data, 100);
	local intelligence = math.floor(data/100);
	
	return magicLevel, intelligence;
end

-- 合并id和等级参数
function kingMagicClass:mergeIDLevel(id, level)
	return id*100 + level;
end

-- 合并id和等级参数
function kingMagicClass:parseIDLevel(data)
	local level = math.fmod(data, 100);
	local id = math.floor(data/100);
	
	return id, level;
end

function kingMagicClass:onMagicExpChange(newMagicID, newExp)
	if not self.sortMagicIDList then
		return;
	end
	
	local sortIDList = self.sortMagicIDList;
	-- 先删掉，再放到合适的位置
	local oldPosition = -1;
	for k, v in ipairs(sortIDList) do
		if v.magicID == newMagicID then
			oldPosition = k;
			break;
		end
	end
	
	if oldPosition > 0 then
		table.remove(sortIDList, oldPosition);
	end
	
	-- 默认在末尾
	local newPosition = #sortIDList + 1;
	for k, v in ipairs(sortIDList) do
		if v.exp < newExp then
			newPosition = k;
			break;
		end
	end
	
	table.insert(sortIDList, newPosition, {magicID = newMagicID, exp = newExp });	
end

function kingMagicClass:getStarByExp(exp)
	-- 更新一下star
	local configInfo = dataConfig.configs.ConfigConfig[0].magicLevelExp;
	local star = #configInfo;
		
	for k, v in ipairs(configInfo) do
		if exp < v then
			star = k-1;
			break;
		end
	end
	
	return star;
end

function kingMagicClass:getCurrentAndNextByExp(exp)

	local star = self:getStarByExp(exp);
	
	local currentExp = 0;
	local nextExp = 1;
	
	local configInfo = dataConfig.configs.ConfigConfig[0].magicLevelExp;
	
	
	if star == 0 then
		
		currentExp = exp;
		
	elseif star > 0 and star < #configInfo then
		
		currentExp = exp - configInfo[star];
	
	elseif star == #configInfo then
		
		currentExp = configInfo[star] - configInfo[star-1];
		
	else
	
		currentExp = 0;
	
	end
	
	if star == 0 then
		
		nextExp = configInfo[star+1];
		
	elseif star > 0 and star < #configInfo then
	
		nextExp = configInfo[star+1] - configInfo[star];
	
	elseif star == #configInfo then
		
		nextExp = configInfo[star] - configInfo[star-1];
		
	else
		
		nextExp = 1;
		
	end
	
	return currentExp, nextExp;
end

function kingMagicClass:setExtraExp(exp)
	self.exp = exp;
end

function kingMagicClass:getExtraExp()
	return self.exp;
end

function kingMagicClass:setMagicTowerFlag(flag)
	self.magicTowerFlag = flag;
end

function kingMagicClass:getMagicTowerFlag()
	return self.magicTowerFlag;
end

function kingMagicClass:getMagic(magicId)
	return  self.magics[magicId]
end 	

function kingMagicClass:addMagic(magicId)
	if(self.magics[magicId] ~= nil )	then
		return 
	end		
	self.magics[magicId]  = kingMagicDataClass.new(magicId)
end 	

function kingMagicClass:delMagic(magicId)
	local magicInstance = self:getMagic(magicId);
	if magicInstance then
		magicInstance:setExp(-1);
	end
end

function kingMagicClass:getSkillConfig(magicId)
	return dataConfig.configs.magicConfig[magicId]		
end 	

function kingMagicClass:onBattleStart()
	for i,v in pairs (self.magics)	do	
			local config = v:getConfig()
			v:setCurCD(config.cooldownOnStart)		
			v:setCurNum(config.castTimes)	
	end			
end 

function kingMagicClass:onMagicCaster(magicId)
	
	for i,v in pairs (self.magics)	do	
			local config = v:getConfig()
			v:setCurCD(v:getCurCD() - 1)	
		
	end		
	if(self.magics[magicId] ~= nil )then
		self.magics[magicId]:enterCD()
		self.magics[magicId]:enterNum()
	end
	
	
	eventManager.dispatchEvent({name = global_event.BATTLE_UI_UPDATE_MAGICCD})				
end 


function kingMagicClass:getMagicCount()
	local sum = 0
	for i,v in pairs (self.magics)	do	
			local level =  v:getStar() 
			if(level >= 1 and not self:isGreatMagic(i))then
				sum = sum +1
			end	 
	end		
	return sum	
end 

function kingMagicClass:getNewGainedMagicCountByType(_type)
	
	local count = 0;
	for i,v in pairs (self.magics)	do
		if v:getConfig().magicLabel == _type and v:getNewGainedFlag() > 0 then
			count = count + 1;
		end
	end
	
	return count;
end

function kingMagicClass:setNewGainedMagicByType(_type)
	for i,v in pairs (self.magics)	do
		if v:getConfig().magicLabel == _type and v:getNewGainedFlag() > 0 then
			v:setNewGainedFlag();
		end
	end
end

return kingMagicClass

