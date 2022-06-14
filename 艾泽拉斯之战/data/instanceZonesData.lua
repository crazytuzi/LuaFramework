local instanceZones = class("instanceZonesData")

-- 姣忎竴涓壇鏈?鏅€?or 绮捐嫳
local Stage	 = class("adventureStage")
local attCollectionClass  = include("attCollection")

 
local INSTANCE_ATT_BATTLE_NUM = "INSTANCE_ATT_BATTLE_NUM"
local INSTANCE_ATT_MAXBATTLE_NUM = "INSTANCE_ATT_MAXBATTLE_NUM"
local INSTANCE_ATT_STAR_NUM = "INSTANCE_ATT_STAR_NUM"
local INSTANCE_ATT_RESET_NUM = "INSTANCE_ATT_RESET_NUM"
local INSTANCE_ATT_WIN = "INSTANCE_ATT_WIN"
local INSTANCE_ATT_PASS_FIRST = "INSTANCE_ATT_PASS_FIRST"

function Stage:ctor(adventureID,_type,chapter)
	
	self.att = attCollectionClass.new()		
	self.adventureID = adventureID	
	self.chapter = chapter
	self.id = nil
	self._type = 	_type	
	self.sweepRandomReward = {}
	self.sweepCount = 0
	-- 为了结束时的对话，需要备份开战前的star
	self.beforeBattleStar = 0;
	self:init()
 
	
end

function Stage:getconfig()
	return instanceZones.getStageConfig(self.id )     ---instanceZones.getAdventureConfig(self.id )
end 

function Stage:getAdventureID()
	return  self.adventureID 
end 

function Stage:getId()
	return  self.id 
end 
function Stage:getChapter()
	return  self.chapter 
end 
 
function Stage:init()
	local congfig = instanceZones.getAdventureConfig(self.adventureID )	
	self.id	= congfig.limit[self._type].stageID
	countLimit = congfig.limit[self._type].count	
	self:setMaxCanBattleNum(countLimit)
	self:setBattleNum(0)
	self:setStarNum(0)
	self:setWin(false)
	self:setResetNum(0)
	self.RandomRewardType = {}
	self.RandomRewardId = {}
	self.RandomRewardCount = {}
end	

function Stage:getName()
	return self:getconfig().name	
end

function Stage:getDesc()
	return self:getconfig().desc
end

function Stage:getScene()
	return self:getconfig().sceneID
end	

function Stage:getKingName()
	return self:getconfig().kingName
end	

function Stage:getPoint( )
	return instanceZones.getAdventureConfig(self.adventureID).point
end 	

function Stage:playerPower()
	local config = self:getconfig()
	local power = 0	
	for i,v in ipairs(config.units)do
		local star = dataConfig.configs.unitConfig[v].starLevel
		local quality = dataConfig.configs.unitConfig[v].quality
		local count = dataConfig.configs.unitConfig[v].food * config.unitCount[i]				
		
		power = power +  global.getOneShipPower( star,quality, count ,config['shipAttrBase'][1].attack,config['shipAttrBase'][1].defence,config['shipAttrBase'][1].critical,config['shipAttrBase'][1].resilience)
	end
	local magicStars = {}
	for i,v in ipairs(config.magics)do
		if(v > 0 )then
			table.insert(magicStars,config.magicLevels[i])
		end
	end		
	power = power + global.getAllMagicPower(magicStars,config.intelligence)	
	return  math.ceil(power)
end

function Stage:getKingIcon()
	if(self:getconfig().kingIcon)then
		return tonumber(self:getconfig().kingIcon)
	end
	return 1
end	

function Stage:getHeroLevel()
	return self:getconfig().heroLevel
end	
function Stage:getType()
		return self._type 
end		
function Stage:getTypeDesc()
	if(self._type == enum.Adventure_TYPE.ELITE) then
		return  "精英"
	elseif(self._type == enum.Adventure_TYPE.NORMAL) then	
		return 	"普通"
	end	 
	return "error"
end	
function Stage:getServerType()
	if(self._type == enum.Adventure_TYPE.ELITE) then
		return enum.ADVENTURE.ADVENTURE_ELITE
	elseif(self._type == enum.Adventure_TYPE.NORMAL) then	
		return enum.ADVENTURE.ADVENTURE_NORMAL
	end	
end
--- 灰化？
function Stage:isEnable()
	if(	self._type == enum.Adventure_TYPE.ELITE)then	
		local normal = dataManager.playerData:getAdventureNormalProcess();
		if(normal < dataConfig.configs.ConfigConfig[0].eliteAdventureLimit )then
			return false
		end			
		local res =  self.adventureID <=  dataManager.playerData:getAdventureEliteProcess() + 1
		local zones = dataManager.instanceZonesData	
		local stage = zones:getStageWithAdventureID(self.adventureID, enum.Adventure_TYPE.NORMAL)	
		return res and stage:isEnable() and ( not stage:isWillFirstPass())
	elseif(	self._type == enum.Adventure_TYPE.NORMAL)then			
		return self.adventureID <=  dataManager.playerData:getAdventureNormalProcess() + 1
	end				
end	

function Stage:isMain()
	return instanceZones.getAdventureConfig(self.adventureID).isMain
end	



function Stage:getAdventureShowIndex()
	
	local aid = self:getAdventureID() 
	
	local start =  self:getChapter():getAdventureIDStart() 
	local index = 0
	for i = start, aid  do
		if(instanceZones.getAdventureConfig(i).isMain) then
			index = index + 1
		end
	end
	return index
end 

function Stage:isMissed()
	if(self:isMain())then
		return false
	end
	if(	self._type == enum.Adventure_TYPE.ELITE)then	
		return self.adventureID <=  dataManager.playerData:getAdventureEliteProcess()
	elseif(	self._type == enum.Adventure_TYPE.NORMAL)then			
		return self.adventureID <=  dataManager.playerData:getAdventureNormalProcess()
	end				 
end	
	
function Stage:isWillFirstPass()
	if(	self._type == enum.Adventure_TYPE.ELITE)then	
		return self.adventureID ==  dataManager.playerData:getAdventureEliteProcess() + 1
	elseif(	self._type == enum.Adventure_TYPE.NORMAL)then	
		return self.adventureID ==  dataManager.playerData:getAdventureNormalProcess() + 1
	end				
end	

---体力消耗
function Stage:getVigourCost()
	return  global.adventureConfig[self._type].cost,global.adventureConfig[self._type].failCost		
end	
--鍙兘鑾峰緱鐨勭粡楠?
function Stage:getExp()
	 return  global.adventureConfig[self._type].exp,global.adventureConfig[self._type].failExp			
end	

---  鎸戞垬娆℃暟
function Stage:getBattleNum()
	return self.att:getAttr(INSTANCE_ATT_BATTLE_NUM)		
end  
--鏈€澶ф寫鎴樻鏁?
function Stage:getMaxCanBattleNum()
	return self.att:getAttr(INSTANCE_ATT_MAXBATTLE_NUM)		
end  
--绾у埆瑕佹眰
function Stage:getlevelLimit()
	local congfig = instanceZones.getAdventureConfig(self.adventureID )	
	return congfig.limit[self._type].level
end  

function Stage:setBattleNum(n)
	self.att:setAttr(INSTANCE_ATT_BATTLE_NUM,n)		
end 	

function Stage:setMaxCanBattleNum(n)
	self.att:setAttr(INSTANCE_ATT_MAXBATTLE_NUM,n)		
end 
 
function Stage:setStarNum(n)
	self.att:setAttr(INSTANCE_ATT_STAR_NUM,n)		
end 	

function Stage:setResetNum(n)
	self.att:setAttr(INSTANCE_ATT_RESET_NUM,n)		
end 

function Stage:getStarNum()
	return self.att:getAttr(INSTANCE_ATT_STAR_NUM)		
end 	

function Stage:getVisStarNum()
	local num =   self:getStarNum()
	if(num <= 0) then
		return 0 
	end		
	return num + 1
end 	

function Stage:isFullStar()
	return self:getVisStarNum() >= 3;
end

function Stage:backupStar()
	self.beforeBattleStar = self:getVisStarNum();
end

function Stage:isShowDialogue()
	return self:getVisStarNum() == 0 and self:getType() == enum.Adventure_TYPE.NORMAL;
end

function Stage:isShowAfterBattleDialogue()
	return self.beforeBattleStar == 0 and self:getVisStarNum() > 0;
end

-- 战斗结束后，飞入几颗星的表现
function Stage:getFlyStarCount()

	if self:isMain() then
		return self:getVisStarNum() - self.beforeBattleStar; 
	else
		return 0; 
	end
end

function Stage:getPrepareDialogueID()
	local congfig = instanceZones.getAdventureConfig(self.adventureID );
	if congfig then
		return congfig.textPrepare;
	else
		return -1;
	end
end

function Stage:getBeforeDialogueID()
	local congfig = instanceZones.getAdventureConfig(self.adventureID );
	if congfig then
		return congfig.textBefore;
	else
		return -1;
	end
end

function Stage:getAfterDialogueID()
	local congfig = instanceZones.getAdventureConfig(self.adventureID );
	if congfig then
		return congfig.testAfter;
	else
		return -1;
	end
end

function Stage:getResetNum(n)
	return self.att:getAttr(INSTANCE_ATT_RESET_NUM)		
end 

function Stage:setWin(n)
	self.att:setAttr(INSTANCE_ATT_WIN,n)	
end	

function Stage:isWin()
	return self.att:getAttr(INSTANCE_ATT_WIN)== true	
end 

function Stage:setFirstPass(n)
	self.att:setAttr(INSTANCE_ATT_PASS_FIRST,n)	
end	

function Stage:getFirstPass()
	return self.att:getAttr(INSTANCE_ATT_PASS_FIRST)
end 

--
function Stage:getScore()
	local star = self:getVisStarNum()
	if(star == 3)then
		return  3,star
	end		
	if(star < 2 )then
		return  0,star
	end
	return  2,star
end	
function Stage:canSweep()
	return  self:getVisStarNum() >= 3
end	

function Stage:isExitReward(index,_type,id)
	local config = self:getconfig()
	
	--首通不要
	local c1 = 	{}  --config.firstRewardType	
	local c2 = 	{}  --config.firstRewardID		
	local c3 = {}	--config.firstRewardCount	
	
	if(index == 1)then
		  c1 = 	config.rewardType	
		  c2 = 	config.rewardID		
		  c3 = 	config.rewardCount	
	elseif(index == 2)then
		  c1 = config.randomReward1Type	
		  c2 = 	config.randomReward1ID		
		  c3 = 	config.randomReward1Count	
	elseif(index ==3)then
		  c1 = self.RandomRewardType
		  c2 = self.RandomRewardId
		  c3 = self.RandomRewardCount	
	end		
	
	
	for i,v in ipairs  (c1)	 do	
		if( v == _type and c2[i] == id )then
			return true
		end
	end
	return false
end	
--0==首通  1 = normal    2== 随即1      3==真实的随即
function Stage:getStageReward(index)
	local config = self:getconfig()
	
	local c1 = 	config.firstRewardType	
	local c2 = 	config.firstRewardID		
	local c3 = 	config.firstRewardCount	
	local isRandom = false
	if(index == 1)then
		  c1 = 	config.rewardType	
		  c2 = 	config.rewardID		
		  c3 = 	config.rewardCount	
	elseif(index == 2)then
		  c1 = config.randomReward1Type	
		  c2 = 	config.randomReward1ID		
		  c3 = 	config.randomReward1Count
		  isRandom = true	
	elseif(index ==3)then
		  c1 = self.RandomRewardType
		  c2 = self.RandomRewardId
		  c3 = self.RandomRewardCount	
	elseif(index ==4)then
		  c1 = config.randomReward2Type	
		  c2 = 	config.randomReward2ID		
		  c3 = 	config.randomReward2Count	
		  isRandom = true		
	end		
	return self:__getStageReward(c1,c2,c3,isRandom)		
end		
--[[
enum.MONEY_TYPE
	MONEY_TYPE_GOLD = 0,	--閲戠熆
	MONEY_TYPE_LUMBER = 1,	--鏈ㄦ潗
	MONEY_TYPE_DIAMOND = 2,	--閽荤煶
	MONEY_TYPE_VIGOR = 3,	--娲诲姏
	MONEY_TYPE_FOOD = 4,	--鍏电伯
--]]
function Stage:getStageRewardMoney(moneyType,firstWind)
	local nums = 0
	 	
	function __calcReward(_reward)
		local n = 0
		for i ,v in ipairs (_reward) do
				if(v._type == enum.REWARD_TYPE.REWARD_TYPE_MONEY)then
				  if(v._id == moneyType)then
					n = n + v._num	
				  end	
				end				
			end
		return n	
	end	
	
	if(firstWind)then
		nums = nums + __calcReward(self:getStageReward(0))	
	end
 
	nums = nums + __calcReward(self:getStageReward(1))	
	nums = nums + __calcReward(self:getStageReward(3))
	return nums	
end	


function Stage:getStageRandomReward()
	
	local config = self:getconfig()
	local c1 = 	clone(config.randomReward1Type)	
	local c2 = 	clone(config.randomReward1ID)		
	local c3 = 	clone(config.randomReward1Count)	
	
	for i,v in ipairs  (config.randomReward2Type)	 do
		local k = table.keyOfItem(c1, v)
		if(k and  c2[k] == self.randomReward2ID[i])then
			c3[k] = c3[k] + self.randomReward2Count[i]
		else			
			table.insert(c1,v)
			table.insert(c2, self.randomReward2ID[i]  )
			table.insert(c3, self.randomReward2Count[i] )
		end			
	end		
	return self:__getStageReward(c1,c2,c3,true)		
end		

--[[
function Stage:getStageNormalMergerRandomReward()
	
	local config = self:getconfig()
	local c1 = 	clone(config.rewardType)	
	local c2 = 	clone(config.rewardID)		
	local c3 = 	clone(config.rewardCount)	
	
	for i,v in ipairs  (self.RandomRewardType)	 do
		local k = table.keyOfItem(c1, v)
		if(k and  c2[k] == self.RandomRewardId[i])then
			c3[k] = c3[k] + self.RandomRewardCount[i]
		else			
			table.insert(c1,v)
			table.insert(c2, self.RandomRewardId[i]  )
			table.insert(c3, self.RandomRewardCount[i] )
		end			
	end		
	return self:__getStageReward(c1,c2,c3)		
end		
]]--
--[[
function Stage:getStageFirstMergerNormalRandonReward()
	
	local config = self:getconfig()
	local c1 = 	clone(config.firstRewardType)	
	local c2 = 	clone(config.firstRewardID)		
	local c3 = 	clone(config.firstRewardCount)	
	
	for i,v in ipairs  (config.rewardType)	 do
		local k = table.keyOfItem(c1, v)
		if(k and  c2[k] == config.rewardID[i])then
			c3[k] = c3[k] + config.rewardCount[i]
		else			
			table.insert(c1,v)
			table.insert(c2, config.rewardID[i]  )
			table.insert(c3, config.rewardCount[i] )
		end			
	end
	
	for i,v in ipairs  (self.RandomRewardType)	 do
		local k = table.keyOfItem(c1, v)
		if(k and  c2[k] == self.RandomRewardId[i])then
			c3[k] = c3[k] + self.RandomRewardCount[i]
		else			
			table.insert(c1,v)
			table.insert(c2, self.RandomRewardId[i]  )
			table.insert(c3, self.RandomRewardCount[i] )
		end			
	end		
	return self:__getStageReward(c1,c2,c3)	
 
end	

--]]
function Stage:getStageFirstMergerNormalReward()
	
	local config = self:getconfig()
	local c1 = 	clone(config.firstRewardType)	
	local c2 = 	clone(config.firstRewardID)		
	local c3 = 	clone(config.firstRewardCount)	
	
	for i,v in ipairs  (config.rewardType)	 do
		local k = table.keyOfItem(c1, v)
		if(k and  c2[k] == config.rewardID[i])then
			c3[k] = c3[k] + config.rewardCount[i]
		else			
			table.insert(c1,v)
			table.insert(c2, config.rewardID[i]  )
			table.insert(c3, config.rewardCount[i] )
		end

	end
	return self:__getStageReward(c1,c2,c3,false)	
 
end	

function Stage:__getStageReward(c1,c2,c3,isRandom)
	local config = self:getconfig()
	local t = {}
	local num = #c1
	for i = 1,num do	
		local rType = c1[i]
		local id = c2[i]	
		local count = c3[i]	
		if(rType ~= -1) then
			t[i] = {}			
			t[i]._type = rType	
			t[i]._id = id	
			t[i]._rate = isRandom
			
			local rewardInfo = dataManager.playerData:getRewardInfo(rType, id, count);
			t[i]._icon = rewardInfo.icon;
			t[i]._star = rewardInfo.star;
			t[i]._showstar = rewardInfo.showstar;
			t[i]._maskicon = rewardInfo.maskicon;
			t[i]._isDebris = rewardInfo.isDebris;
			t[i]._backImage = rewardInfo.backImage;
			t[i]._qualityImage = rewardInfo.qualityImage;
			t[i]._selectImage = rewardInfo.selectImage;
			t[i]._userdata = rewardInfo.userdata;
			t[i]._num = rewardInfo.count;
			
			if global.needAdjustReward(config.needAdjust, rType, id) then
				local rewardRatio =  dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel()).rewardRatio
				t[i]._num =  math.floor(t[i]._num*rewardRatio)
			end
			
		end
	end		
	return t
end		
function Stage:setRandomReward(t)
	
	local randomNum = #t  --- randomNum == 2
	local config = self:getconfig()
	self.RandomRewardType = {}
	self.RandomRewardId = {}	
	self.RandomRewardCount = {}	
	
	local configType = {}
	local configId = 	{}
	local configCount = {}	
	
	configType[1] = 	config.randomReward1Type
	configId[1] = 	config.randomReward1ID
	configCount[1] = 	config.randomReward1Count	
	
	configType[2] = 	config.randomReward2Type
	configId[2] = 	config.randomReward2ID
	configCount[2] = 	config.randomReward2Count	
	for i =1,randomNum do	
		local idTable = t[i]				
		for k = 1,#idTable do		
			table.insert(self.RandomRewardType,configType[i][idTable[k]  + 1 ])
			table.insert(self.RandomRewardId,configId[i][idTable[k]  + 1 ])
			table.insert(self.RandomRewardCount,configCount[i][idTable[k]  + 1])						
		end
	end		
end

--id 就是 1 ，2 index 就是第几轮
function Stage:getStageSweepRandomRewardRandom(index)
	local reward =   self.sweepRandomReward[index]	
	local c1 = reward.RandomRewardType
	local c2 = reward.RandomRewardId
	local c3 = reward.RandomRewardCount
	return self:__getStageReward(c1,c2,c3)	
end	

function Stage:getSweepCount()
	return self.sweepCount
end	

function Stage:getSweepData()
	return self.sweepRandomReward
end	
function Stage:ClearSweepRandomReward(count)
	self.sweepRandomReward = {}
	self.sweepCount = count
end	
function Stage:AddSweepRandomReward(index,t)
	local randomNum = #t  --- randomNum == 2
	local config = self:getconfig()

	local tt = {}		
	tt.RandomRewardType = {}
	tt.RandomRewardId = {}	
	tt.RandomRewardCount = {}
	
	local configType = {}
	local configId = 	{}
	local configCount = {}	
	
	configType[1] = 	config.randomReward1Type
	configId[1] = 	config.randomReward1ID
	configCount[1] = 	config.randomReward1Count	
	
	configType[2] = 	config.randomReward2Type
	configId[2] = 	config.randomReward2ID
	configCount[2] = 	config.randomReward2Count	
	for i =1,randomNum do	
		local idTable = t[i]				
		for k = 1,#idTable do		
			table.insert(tt.RandomRewardType, idTable[k].type )
			table.insert(tt.RandomRewardId, idTable[k].id )
			table.insert(tt.RandomRewardCount, idTable[k].count)						
		end
	end					
	 self.sweepRandomReward[index] = tt		
end

function Stage:getSweepRewardMoney(moneyType,index)
	local nums = 0	
	function __calcReward(_reward)
		local n = 0
		for i ,v in ipairs (_reward) do
				if(v._type == enum.REWARD_TYPE.REWARD_TYPE_MONEY)then
				  if(v._id == moneyType)then
					n = n + v._num	
				  end	
				end				
			end
		return n	
	end	
	if(self.sweepRandomReward[index])then
		nums = nums + __calcReward(self:getStageSweepRandomRewardRandom(index))	
	end		
	nums = nums + __calcReward(self:getStageReward(1))		
	return nums	
end	

function Stage:getStageSweepNormalMergerRandomReward(index)
	local config = self:getconfig()
	local c1 = 	clone(config.rewardType)	
	local c2 = 	clone(config.rewardID)		
	local c3 = 	clone(config.rewardCount)		
	if(self.sweepRandomReward[index])then	
			local tt = self.sweepRandomReward[index] 
			for i,v in ipairs  (tt.RandomRewardType)	 do
				local k = table.keyOfItem(c1, v)
				if(k and  c2[k] == tt.RandomRewardId[i])then
					c3[k] = c3[k] + tt.RandomRewardCount[i]
				else			
					table.insert(c1,v)
					table.insert(c2, tt.RandomRewardId[i]  )
					table.insert(c3, tt.RandomRewardCount[i] )
				end			
			end						
	end			
	return self:__getStageReward(c1,c2,c3)		
end		

local  Chapter	 = class("AdventureChapter")

function Chapter:ctor(id)
	 self.Adventure = nil	
	 self.id = id	
	 self.pos_index = nil
	 self:init()
end

function Chapter:getconfig( )
	return instanceZones.getChapterConfig(self.id)
end 	


function Chapter:getId( )
	return  self.id 
end 
function Chapter:getAdventureIDStart( )
	local config = instanceZones.getChapterConfig(self.id - 1)
	if(config)then
			return config.adventureID  + 1
	end
	return 1			 
end 	



function Chapter:hasAdventure( AdventureId)
	local config = self:getconfig()
	local start = self:getAdventureIDStart()
	local endl = config.adventureID		
	if type(AdventureId) ~= "table" then
		
		return AdventureId >= start and AdventureId<=  endl , AdventureId
		
	else
		for i,v in pairs(AdventureId)do
			
			if(v >= start and v<=  endl )then
				return true,v
			end
			
		end
		
	end
	
	return false
	
end

function Chapter:init()
		self.Adventure = {}
		local config = self:getconfig()		
		local start = self:getAdventureIDStart()
		local endl = config.adventureID		
	
		-- 	AdventureConfig 鑲畾鏄繛缁殑	
		for  adventureID = start, endl do				
			local  stageN = Stage.new(adventureID,enum.Adventure_TYPE.NORMAL,self)
			local  stageE = Stage.new(adventureID,enum.Adventure_TYPE.ELITE,self)							
			table.insert(self.Adventure,adventureID)
			dataManager.instanceZonesData:addStageWithAdventureID(adventureID,stageN,enum.Adventure_TYPE.NORMAL)	
			dataManager.instanceZonesData:addStageWithAdventureID(adventureID,stageE,enum.Adventure_TYPE.ELITE)			
		end				
end

--绔犺妭鍚嶅瓧 
function Chapter:getName()
	return self:getconfig().name
end	

--绔犺妭  
function Chapter:getAdventure()
	return self.Adventure
end	


function Chapter:getLastCanBattleAdventure(mode)
	local index = #self.Adventure
	 for i,v in ipairs (self.Adventure) do
		 local stage =  dataManager.instanceZonesData:getStageWithAdventureID(v,mode)	
		 if( stage:isMissed() == false )	then
			index = i
			if(stage:isWillFirstPass() == true )	then
				 return i
			end
		 end
	end
	return index
end	

function Chapter:getFirstMainAdventure(mode)
	 for i,v in ipairs (self.Adventure) do
		 local stage =  dataManager.instanceZonesData:getStageWithAdventureID(v,mode)	
		if(stage:isMain() == false )	then
				if(stage:isMissed() == false)then
					return i
				end
		else  
			 return i;
		end
	end
	return -1;
end	

-- 获取第一个没有满星的主要关卡
function Chapter:getFirstNotFullStarStage(mode)

	 for i,v in ipairs (self.Adventure) do
			local stage =  dataManager.instanceZonesData:getStageWithAdventureID(v,mode);
			if stage:isMain() and (not stage:isFullStar()) then
				return stage;
			end
	end
	
	return nil;
end
	
function instanceZones.getStageConfig(id)
	return dataConfig.configs.stageConfig[id]	
end	

function instanceZones.getAdventureConfig(id)
	return dataConfig.configs.AdventureConfig[id]	
end	

function instanceZones.getChapterConfig(id)
	return dataConfig.configs.ChapterConfig[id]	
end	

--杩涘害鏉″綋鍓嶅€硷細銆愭湰绔犳櫘閫氳瘎浠峰叧鍗℃暟銆?2+銆愭湰绔犲畬缇庤瘎浠峰叧鍗℃暟銆?3
--杩涘害鏉℃渶澶у€硷細銆愭湰绔犲叧鍗℃€绘暟銆?3

	
function Chapter:getPerfectProcess(mode)
	
	local num = 0
	local allnum =   0 -- 3 * #self.Adventure
	for _,v in ipairs (self.Adventure) do
		 local stage =  dataManager.instanceZonesData:getStageWithAdventureID(v,mode)	
		 if(stage:isMain())then
			num = num + stage:getScore()
			allnum = allnum + 3
		 end
	end
	return  num,allnum
end	

function Chapter:getChapterReward(_type)
	local c1,c2,c3
	local config = self:getconfig()
	local t = nil
	if(_type ==  enum.Adventure_TYPE.NORMAL)then
		t = config.chapterRewardList[1]
	elseif(_type ==  enum.Adventure_TYPE.ELITE)then
		t = config.chapterRewardList[2]
	end
	
	return self:__getChapterReward(t['type'],t['id'],t['count'])
end	

function Chapter:__getChapterReward(c1,c2,c3)
	local config = self:getconfig()
	local t = {}
	local num = #c1
	for i = 1,num do	
		local rType = c1[i]
		local id = c2[i]	
		local count = c3[i]	
		t[i] = {}		
		t[i]._num = count		
		t[i]._type = rType	
		t[i]._id = id	
		t[i]._star = 0
		
		local rewardInfo = dataManager.playerData:getRewardInfo(rType, id, count);
		t[i]._icon = rewardInfo.icon;
		t[i]._star = rewardInfo.star;
		t[i]._showstar = rewardInfo.showstar;
		t[i]._maskicon = rewardInfo.maskicon;
		t[i]._isDebris = rewardInfo.isDebris;
		t[i]._backImage = rewardInfo.backImage;
		t[i]._qualityImage = rewardInfo.qualityImage;
		t[i]._selectImage = rewardInfo.selectImage;
		t[i]._userdata = rewardInfo.userdata;
		t[i]._num = rewardInfo.count;
		
	end		
	return t
end			



function Chapter:getChapterRewardConfig(_type)
	 
	local config = self:getconfig()
	local t = {}
	if(_type ==  enum.Adventure_TYPE.NORMAL)then
		t = config.chapterRewardList[1]
	elseif(_type ==  enum.Adventure_TYPE.ELITE)then
		t = config.chapterRewardList[2]
	end
	return t 
end	



function Chapter:getRewardMoney(moneyType,_type)
	local nums = 0
	 	
	function __calcReward(_reward)
		local n = 0
		for i ,v in ipairs (_reward) do
				if(v._type == enum.REWARD_TYPE.REWARD_TYPE_MONEY)then
				  if(v._id == moneyType)then
					n = n + v._num	
				  end	
				end				
			end
		return n	
	end			
	nums = nums + __calcReward(self:getChapterReward(_type))		
	return nums	
end	

--宸茬粡棰嗗
function Chapter:haveAward(_type)
	if(	 _type == enum.Adventure_TYPE.ELITE)then	
		return dataManager.playerData:getChapterEliteAwardProcess(self.id) == 1;
	elseif( _type == enum.Adventure_TYPE.NORMAL)then	
		return dataManager.playerData:getChapterNormalAwardProcess(self.id) == 1;
	end				
end		


--鍓湰绠＄悊
function instanceZones:ctor()
	self.Chapter = {}
	self.stage  = nil	
end 		

function instanceZones:getCurNormalProgressChapter()
	 for k,v in ipairs  (self.Chapter) do		
		for _k,_v in ipairs  (v.Adventure) do
			if(_v == dataManager.playerData:getAdventureNormalProcess())then
				return v.id
			end
		end
	end	
	return 1
end 	
function instanceZones:getCurEliteProgressChapter()
	 for k,v in ipairs  (self.Chapter) do		
		for _k,_v in ipairs  (v.Adventure) do
			if(_v == dataManager.playerData:getAdventureEliteProcess())then
				return v.id
			end
		end
	end	
	return 1
end 


function instanceZones:getAllChapter()
	return self.Chapter
end 		


function instanceZones:init()
	local t = dataConfig.configs.ChapterConfig	
	for k,v in pairsByKeys  (t) do	
		local  chapter =  Chapter.new(k)		
		table.insert(self.Chapter,chapter)	
		chapter.pos_index = # self.Chapter
	end				
end
 
function instanceZones:addStageWithAdventureID(adventureID,stage,_type)
	if(self.stage == nil)then
		self.stage ={}
	end
	if(self.stage[_type] == nil)then
		self.stage[_type] ={}
	end
	self.stage[_type][adventureID] = stage
end	

function instanceZones:getStageWithAdventureID(adventureID,_type)
	return self.stage[_type][adventureID]
end	


function instanceZones:setStatgeTimes(param,isElite)
		local _type = enum.Adventure_TYPE.NORMAL
		if(isElite)then
			_type = enum.Adventure_TYPE.ELITE
		end
		local nums = table.nums(param)
		for i = 1, nums	do		
			if(self.stage[_type][i])then
				self.stage[_type][i]:setBattleNum( param[i])	
			end			
		end			
end 

function instanceZones:setStatgeResetTimes(param,isElite)
	 
	 	local _type = enum.Adventure_TYPE.NORMAL
		if(isElite)then
			_type = enum.Adventure_TYPE.ELITE
		end
		local nums = table.nums(param)
		for i = 1, nums	do		
			if(self.stage[_type][i])then
				self.stage[_type][i ]:setResetNum( param[i])		
			end		
		end		
end 

function instanceZones:setStatgeStar(param,isElite)
 
	 	local _type = enum.Adventure_TYPE.NORMAL
		if(isElite)then
			_type = enum.Adventure_TYPE.ELITE
		end
		local nums = table.nums(param)
		
		for i = 1, nums	do		
			if(self.stage[_type][i])then
				self.stage[_type][i]:setStarNum( param[i])
			end				
		end		
	
end 

function instanceZones:getNewInstance(_type)
	
	local adventureID = nil
	if(	_type == enum.Adventure_TYPE.ELITE)then	
		adventureID =  dataManager.playerData:getAdventureEliteProcess()+1 
		local stage = self:getStageWithAdventureID(adventureID,_type)
		if( (stage) and (not stage:isEnable()) )then
			adventureID = adventureID - 1
		end
	elseif(	_type == enum.Adventure_TYPE.NORMAL)then	
		adventureID =  dataManager.playerData:getAdventureNormalProcess()+1
	end			
	local size = #dataConfig.configs.AdventureConfig
	if(adventureID > size  )then
		adventureID = size
	end
	if(adventureID <= 0  )then
		adventureID = 1
	end
	return self:getStageWithAdventureID(adventureID,_type)
end
 

function instanceZones:getNewChapter(_type)
	return self:getNewInstance(_type):getChapter()
end


function instanceZones:serchAdventureIdWithPoint(point)
	for i ,v in ipairs (dataConfig.configs.AdventureConfig) do
			if(v.point == point)then
				return v.id
			end
	end
	
end


function instanceZones:haveAward(_type)
	local stage = self:getNewInstance(_type)
	local newMaxChapter = stage:getChapter():getId()	
	for i,v in ipairs (self.Chapter) do
		if(i <= newMaxChapter )then
			 local has = v:haveAward(_type)
			 if(has == false)then
				 local num ,all = v:getPerfectProcess(_type)
				 if( num >= all)then
					return true
				 end
			 end
		end
	end
	return false
end



return instanceZones