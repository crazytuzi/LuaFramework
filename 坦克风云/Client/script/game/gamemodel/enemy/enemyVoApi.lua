require "luascript/script/game/gamemodel/enemy/enemyVo"

enemyVoApi={
	enemyAll={},
	flag=-1,
}

function enemyVoApi:clear()
    if self.enemyAll~=nil then
        for k,v in pairs(self.enemyAll) do
            self.enemyAll[k]=nil
        end
        self.enemyAll=nil
    end
    self.enemyAll={}
	self.flag=-1
end
function enemyVoApi:getFlag()
	return self.flag
end
function enemyVoApi:setFlag(flag)
	self.flag=flag
end
function enemyVoApi:formatData(data)
    if data~=nil then
		local beforeNum=self:getEnemyNum()
		self:clear()
        for k,v in pairs(data) do
			if v.ts>base.serverTime then
	            local evo = enemyVo:new()
	            evo:initWithData(k,tonumber(v.islandType),tonumber(v.level),v.place,v.ts,v.attackerName,v.tc,v.tarplace)
	            table.insert(self.enemyAll,evo)
			end
        end
        local acityVo=allianceCityVoApi:getAllianceCity() --将攻打己方军团城市的列表加入到敌军来袭列表中
        if acityVo and acityVo.attlist then
	        for k,v in pairs(acityVo.attlist) do
				if v.ts>base.serverTime then
		            local evo=enemyVo:new()
		            evo:initWithData(k,tonumber(v.islandType),tonumber(v.level),v.place,v.ts,v.attackerName,v.tc,v.tarplace)
		            table.insert(self.enemyAll,evo)
				end
	        end
        end
        local function sortAsc(a, b)
            return a.time < b.time
        end
        table.sort(self.enemyAll,sortAsc)
		local afterNum=self:getEnemyNum()
		if beforeNum~=afterNum then
			self.flag=0
		end
    end
end
function enemyVoApi:hasEnemy()
	local num=self:getEnemyNum()
	if num>0 then
		return true
	else
		return false
	end
end
function enemyVoApi:getEnemyNum()
	local enemyAll=self:getEnemyAll()
	local num=0
	if enemyAll~=nil then
		num=SizeOfTable(enemyAll)
	end
	return num
end
function enemyVoApi:getEnemyAll()
	if self.enemyAll==nil then
		self.enemyAll={}
	end
	return self.enemyAll
end

function enemyVoApi:enemyArrive()
	local isArrive=-1
	local attackerName=""
	local islandType = 6
	local enemyAll=self:getEnemyAll()
	if enemyAll~=nil and next(enemyAll) then
		for k,v in pairs(enemyAll) do
			if tonumber(v.islandType) ~= 8 or (tonumber(v.islandType)==8 and (allianceCityVoApi:getMyDef() ~= nil or enemyVoApi:isPop() == true)) then
				isArrive=v.time-base.serverTime
				attackerName=v.attackerName
				islandType=v.islandType
				if isArrive<0 then
					isArrive=0
				end
				do break end
			end
		end
	end
	return isArrive,attackerName,islandType
end

function enemyVoApi:deleteEnemy(x,y)
	local isHasRemove=false
	local enemyAll=self:getEnemyAll()
	for k,v in pairs(enemyAll) do
		if v.place[1]==x and v.place[2]==y then
			table.remove(self.enemyAll,k)
			self.flag=0
			isHasRemove=true
		end
	end
	if isHasRemove==true and worldScene and worldScene.checkEndTankSlot then
		worldScene:checkEndTankSlot(true)
	end
end

function enemyVoApi:getEnemyById(slotId)
	local enemyAll=self:getEnemyAll()
	for k,v in pairs(enemyAll) do
		if slotId and slotId==v.slotId then
			return v
		end
	end
end

--添加敌军来袭队列
function enemyVoApi:addEnemy(enemylist)
	local flag=false
	local enemyAll=self:getEnemyAll()
	for slotId,enemy in pairs(enemylist) do
		for k,v in pairs(enemyAll) do
			if v.slotId==slotId then
				do return end
			end
		end

		if enemy.ts>base.serverTime then
	        local evo=enemyVo:new()
	        evo:initWithData(slotId,tonumber(enemy.islandType),tonumber(enemy.level),enemy.place,enemy.ts,enemy.attackerName,enemy.tc,enemy.tarplace)
	        table.insert(self.enemyAll,evo)
	        flag=true
		end
	end
	if flag==true then
	    local function sortAsc(a, b)
	        return a.time<b.time
	    end
	    table.sort(self.enemyAll,sortAsc)
		self.flag=0
	end
end

function enemyVoApi:isPop( ... )
	local switch_dailyNewspaper = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSetting_legionCityEnemyAlert")
    if switch_dailyNewspaper == 1 then
        -- 开关没开
        return false
    else
        return true
    end
end