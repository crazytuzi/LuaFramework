allianceWar2RecordVoApi=
{
	redPoint=0,
	bluePoint=0,
	redDestroy=0,
	blueDestroy=0,
	rewardContribution=0,
	redVip="",
	blueVip="",
	personDestroyTab={},
	allianceDestroyTab={},
	personRecordTab={},
	allianceRecordTab={},
	personMaxNum=0,
	allianceMaxNum=0,
	rFlag=-1,
	dFlag=-1,
	hasNew=false,
	aFlag=-1, -- 军团战报的标志（与rFlag对应）
	allianceHasNew=false,
}

function allianceWar2RecordVoApi:clearRecord()
	if self.personRecordTab then
		for k,v in pairs(self.personRecordTab) do
			self.personRecordTab[k]=nil
		end
		self.personRecordTab=nil
	end
	self.personRecordTab={}

	if self.allianceRecordTab then
		for k,v in pairs(self.allianceRecordTab) do
			self.allianceRecordTab[k]=nil
		end
		self.allianceRecordTab=nil
	end
	self.allianceRecordTab={}
	-- if self.allianceDestroyTab then
	-- 	for k,v in pairs(self.allianceDestroyTab) do
	-- 		self.allianceDestroyTab[k]=nil
	-- 	end
	-- 	self.allianceDestroyTab=nil
	-- end
	-- self.allianceDestroyTab={}
end

function allianceWar2RecordVoApi:clear()
	self.redPoint=0
	self.bluePoint=0
	self.redDestroy=0
	self.blueDestroy=0
	self.rewardContribution=0
	self.redVip=""
	self.blueVip=""
	self.personDestroyTab={}
	self.allianceDestroyTab={}
	self:clearRecord()
	self.personMaxNum=0
	self.allianceMaxNum=0
	self.rFlag=-1
	self.dFlag=-1
	self.aFlag=-1
	self.hasNew=false
	self.allianceHasNew=false
end

function allianceWar2RecordVoApi:getHasNew()
	return self.hasNew
end
function allianceWar2RecordVoApi:setHasNew(hasNew)
	self.hasNew=hasNew
end
-- 剧团战报
function allianceWar2RecordVoApi:getAllianceHasNew()
	return self.allianceHasNew
end
function allianceWar2RecordVoApi:setAllianceHasNew(hasNew)
	self.allianceHasNew=hasNew
end
function allianceWar2RecordVoApi:getRFlag()
	return self.rFlag
end
function allianceWar2RecordVoApi:setRFlag(rFlag)
	self.rFlag=rFlag
end
function allianceWar2RecordVoApi:getDFlag()
	-- return self.dFlag[index]
	return self.dFlag
end
function allianceWar2RecordVoApi:setDFlag(dFlag)
	-- if index then
	-- 	self.dFlag[index]=dFlag
	-- else
	-- 	self.dFlag={dFlag,dFlag}
	-- end
	self.dFlag=dFlag
end
-- 先添加，军团标志
function allianceWar2RecordVoApi:getAFlag()
	return self.aFlag
end
function allianceWar2RecordVoApi:setAFlag(aFlag)
	self.aFlag=aFlag
end

function allianceWar2RecordVoApi:formatResultData(data)
	--红方积分
	if self.redPoint==nil then
    	self.redPoint=0
    end
    --蓝方积分
   	if self.bluePoint==nil then
    	self.bluePoint=0
    end
    --红方军团总击毁数
    if self.redDestroy==nil then
    	self.redDestroy=0
    end
    --红方军团总击毁数
    if self.blueDestroy==nil then
    	self.blueDestroy=0
    end
    --个人获得总贡献
    if self.rewardContribution==nil then
    	self.rewardContribution=0
    end
    --红方vip
    if self.redVip==nil then
    	self.redVip=""
    end
	--蓝方vip
	if self.blueVip==nil then
    	self.blueVip=""
    end
	if data and SizeOfTable(data)>0 then
		local battleId,warid,attId,defId,attName,defName,redPoint,bluePoint,redRaising,blueRaising,redDestroyTab,blueDestroyTab,redVip,blueVip,time,rewardContribution=tonumber(data[1]),tonumber(data[2]),tonumber(data[3]),tonumber(data[4]),data[5],data[6],tonumber(data[7]),tonumber(data[8]),tonumber(data[9]),tonumber(data[10]),data[11],data[12],data[13],data[14],tonumber(data[15]),tonumber(data[16])
	    if redPoint then
	    	self.redPoint=redPoint or 0
	    end
	    if bluePoint then
	    	self.bluePoint=bluePoint or 0
	    end
	    local tempTab={self.redPoint,self.bluePoint}
	    local pointTab=allianceWar2VoApi:getMaxPointTb(tempTab)
	    self.redPoint=pointTab[1] or 0
	    self.bluePoint=pointTab[2] or 0

	    if redDestroyTab and type(redDestroyTab)=="table" and SizeOfTable(redDestroyTab)>0 then
	    	local num=0
	    	for k,v in pairs(redDestroyTab) do
	    		num=num+tonumber(v)
	    	end
	    	self.blueDestroy=num
	    end
	    if blueDestroyTab and type(blueDestroyTab)=="table" and SizeOfTable(blueDestroyTab)>0 then
	    	local num=0
	    	for k,v in pairs(blueDestroyTab) do
	    		num=num+tonumber(v)
	    	end
	    	self.redDestroy=num
	    end
	    if rewardContribution then
	    	self.rewardContribution=rewardContribution or 0
	    end
	    if redVip then
	    	self.redVip=redVip or ""
	    end
	    if blueVip then
	    	self.blueVip=blueVip or ""
	    end
	end
end

function allianceWar2RecordVoApi:formatStatsData(data)
	if data then
	    local mykill=data.mykill
	    local mydie=data.mydie

	    local rednum=data.rednum
	    local bluenum=data.bluenum

	    local myrais=data.myrais

	    -- 判断红蓝方
		local selfAlliance1=allianceVoApi:getSelfAlliance()
		local isRed=false
		-- print("+++++++data.redAId",data.redAId)
		if selfAlliance1 and selfAlliance1.aid and tonumber(selfAlliance1.aid) == tonumber(data.redAId) then
			isRed=true
		end

		local function sortAsc(a, b)
			if a and b and a[4] and b[4] then
				return tonumber(a[4]) > tonumber(b[4])
			end
		end

		for k,v in pairs(tankCfg) do
			if v then
				if self.personDestroyTab==nil then
					self.personDestroyTab={}
				end
				local mykillNum=0
				local mydieNum=0
				local myRaisNum=0 -- 贡献点
				if mykill and mykill["a"..v.sid] then
					mykillNum=tonumber(mykill["a"..v.sid])
				end
				if mydie and mydie["a"..v.sid] then
					mydieNum=tonumber(mydie["a"..v.sid])
				end
				if myrais and myrais["a"..v.sid] then
					myRaisNum=tonumber(myrais["a"..v.sid])
				end
				local pHasKey=false
				for m,n in pairs(self.personDestroyTab) do
					if tonumber(n[1])==tonumber(v.sid) then
						self.personDestroyTab[m][2]=mykillNum
						self.personDestroyTab[m][3]=mydieNum
						self.personDestroyTab[m][5]=myRaisNum
						pHasKey=true
					end
				end
				if pHasKey==false and (mykillNum>0 or mydieNum>0) then
					local destroyTab={tonumber(v.sid),mykillNum,mydieNum,tonumber(v.sortId),myRaisNum}
					table.insert(self.personDestroyTab,destroyTab)
				end
				

				if self.allianceDestroyTab==nil then
					self.allianceDestroyTab={}
				end
				local redDestroyNum=0
				local blueDestroyNum=0

				if rednum and rednum["a"..v.sid] then
					if isRed then
						blueDestroyNum=tonumber(rednum["a"..v.sid])
					else
						redDestroyNum=tonumber(rednum["a"..v.sid])
					end
					
				end
				if bluenum and bluenum["a"..v.sid] then
					if isRed then
						redDestroyNum=tonumber(bluenum["a"..v.sid])
					else
						blueDestroyNum=tonumber(bluenum["a"..v.sid])
					end
				end
				local aHasKey=false
				for m,n in pairs(self.allianceDestroyTab) do
					if tonumber(n[1])==tonumber(v.sid) then
						self.allianceDestroyTab[m][2]=redDestroyNum
						self.allianceDestroyTab[m][3]=blueDestroyNum
						aHasKey=true
					end
				end
				if aHasKey==false and (redDestroyNum>0 or blueDestroyNum>0) then
					local destroyTab={tonumber(v.sid),redDestroyNum,blueDestroyNum,tonumber(v.sortId)}
					table.insert(self.allianceDestroyTab,destroyTab)
				end

			end
		end

		table.sort(self.personDestroyTab,sortAsc)
		table.sort(self.allianceDestroyTab,sortAsc)
	end
end

function allianceWar2RecordVoApi:formatRecordData(data)
 --    [battleId] => 10
 --    [warId] => 516212
 --    [attacker] => 1000324
 --    [defender] => 1000354
 --    [attackerAllianceId] => 178
 --    [defenderAllianceId] => 279
 --    [attAllianceName] => ceshide
 --    [defAllianceName] => aaaaaaaa
 --    [attBuff] => []
 --    [defBuff] => []
 --    [attPoint] => 0
 --    [defPoint] => 1174
 --    [victor] => 1000354
 --    [report] => {"p":[["鍜箞",60,1],["澶╁ぉ澶╁ぉ澶 ",1,0]],"w":-1,"t":[[{"id":"a10012","armor":0,"double_hit":0,"crit":0.14,"buff_value":0,"dmg":148.8,"hp":1554,"buff":[null,"a10012"],"maxhp":203.4,"accuracy":0.11,"type":2,"anticrit":0.04,"buffType":2,"num":8,"dmg_reduce":1,"arp":0,"evade":0.25,"salvo":1},{},{},{},{},{}],[{"id":"a10012","armor":0,"double_hit":0,"crit":0,"buff_value":0,"dmg":120,"hp":0,"buff":[null,"a10012"],"maxhp":180,"accuracy":0,"type":2,"anticrit":0,"buffType":2,"num":0,"dmg_reduce":1,"arp":0,"evade":0.2,"salvo":1},{},{},{},{},{}]],"d":[["1488-2"],["240-9"],[0],["240-8"],["1191-0"]],"warPoint":{"defPoint":1174,"attPoint":0},"lostShip":{"attacker":{"a10012":10},"defender":{"a10012":2}}}
 --    [attRaising] => 0
 --    [defRaising] => 0
 --    [areaIndex] => 1  --大地区
 --    [placeIndex] => 2 --小地区
 --    [updated_at] => 0

	-- data={
	-- 	{1,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013824,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,1,base.serverTime},
	-- 	{2,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013824,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,2,base.serverTime},
	-- 	{3,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013824,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,3,base.serverTime},
	-- 	{4,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013824,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,4,base.serverTime},
	-- 	{5,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013824,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,5,base.serverTime},
	-- 	{6,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013824,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,6,base.serverTime},
	-- 	{7,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013824,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,7,base.serverTime},
	-- 	{8,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013824,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,8,base.serverTime},

	-- 	{11,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013766,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,1,base.serverTime},
	-- 	{12,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013766,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,2,base.serverTime},
	-- 	{13,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013766,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,3,base.serverTime},
	-- 	{14,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013766,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,4,base.serverTime},
	-- 	{15,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013766,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,5,base.serverTime},
	-- 	{16,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013766,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,6,base.serverTime},
	-- 	{17,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013766,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,7,base.serverTime},
	-- 	{18,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",{},{},0,0,1013766,{lostShip={attacker={a10012=10},defender={a10012=12}}},0,0,1,8,base.serverTime},

	-- 	{19,1,1013766,0,"attName","",1,0,"attAName","",{},{},0,0,1013766,{lostShip={}},0,0,1,9,base.serverTime},
	-- 	{20,1,1013824,0,"attName","",1,0,"attAName","",{},{},0,0,1013824,{},0,0,1,9,base.serverTime},
	-- }
	

	if data then
		if self.personRecordTab==nil then
			self.personRecordTab={}
		end
		local function sortAsc(a, b)
			return tonumber(a.time) > tonumber(b.time)
		end
		for k,v in pairs(data) do
			local battleId,warid,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,victor,report,attRaising,defRaising,areaIndex,placeIndex,time=tonumber(v[1]),tonumber(v[2]),tonumber(v[3]),tonumber(v[4]),v[5],v[6],tonumber(v[7]),tonumber(v[8]),v[9],v[10],v[11],v[12],tonumber(v[13]),tonumber(v[14]),tonumber(v[15]),v[16],tonumber(v[17]),tonumber(v[18]),tonumber(v[19]),v[20],tonumber(v[21])
			-- local battleId,warid,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,victor,report,attRaising,defRaising,areaIndex,placeIndex,time=tonumber(v["1"]),tonumber(v["2"]),tonumber(v["3"]),tonumber(v["4"]),v["5"],v["6"],tonumber(v["7"]),tonumber(v["8"]),v["9"],v["10"],v["11"],v["12"],tonumber(v["13"]),tonumber(v["14"]),tonumber(v["15"]),v["16"],tonumber(v["17"]),tonumber(v["18"]),tonumber(v["19"]),tonumber(v["20"]),tonumber(v["21"])

			if type(report)~="table" then
				report={}
			end
			if type(attBuff)~="table" then
				attBuff={}
			end
			if type(defBuff)~="table" then
				defBuff={}
			end

			local isWin=false
			if tonumber(victor)==playerVoApi:getUid() then
				isWin=true
			end
			
			local isAttacker
			if playerVoApi:getUid()==attId then
				isAttacker=true
			else
				isAttacker=false
			end
			local isBattle=true
			if defId==nil or defId==0 or defName==nil or defName=="" then
				isBattle=false
			end
			local destroyNum=0
			local lostNum=0
			if report and report.lostShip then
				if isAttacker then
					if report.lostShip.defender then
						for k,v in pairs(report.lostShip.defender) do
							destroyNum=destroyNum+tonumber(v)
						end
					end
					if report.lostShip.attacker then
						for k,v in pairs(report.lostShip.attacker) do
							lostNum=lostNum+tonumber(v)
						end
					end
				else
					if report.lostShip.attacker then
						for k,v in pairs(report.lostShip.attacker) do
							destroyNum=destroyNum+tonumber(v)
						end
					end
					if report.lostShip.defender then
						for k,v in pairs(report.lostShip.defender) do
							lostNum=lostNum+tonumber(v)
						end
					end
				end
			end
			-- attId==1 
			if attId==1 and defId==playerVoApi:getUid() then
				isWin=false
				isBattle=false
				isAttacker=false
				local vo = allianceWar2RecordVo:new()
		    	vo:initWithData(battleId,warid,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,isWin,report,attRaising,defRaising,time,placeIndex,destroyNum,lostNum,isAttacker,isBattle)
				table.insert(self.personRecordTab,vo)
			elseif attId==nil or attId==0 or attName==nil or attName=="" then
			else
				local vo = allianceWar2RecordVo:new()
		    	vo:initWithData(battleId,warid,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,isWin,report,attRaising,defRaising,time,placeIndex,destroyNum,lostNum,isAttacker,isBattle)
				table.insert(self.personRecordTab,vo)
			end			
		end
		table.sort(self.personRecordTab,sortAsc)
		if SizeOfTable(self.personRecordTab)==0 then
			self.rFlag=-1
		else
			self.rFlag=0
		end
	end

end

function allianceWar2RecordVoApi:formatAllianceRecordData(data)
	if data then
		if self.allianceRecordTab==nil then
			self.allianceRecordTab={}
		end
		local function sortAsc(a, b)
			return tonumber(a.time) > tonumber(b.time)
		end
		for k,v in pairs(data) do
			-- local battleId,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,victor,report,attRaising,defRaising,areaIndex,placeIndex,time=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13],v[14],v[15],v[16],v[17],v[18],v[19],v[20]
			-- local battleId,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,victor,report,attRaising,defRaising,areaIndex,placeIndex,time=v["1"],v["2"],v["3"],v["4"],v["5"],v["6"],v["7"],v["8"],v["9"],v["10"],v["11"],v["12"],v["13"],v["14"],v["15"],v["16"],v["17"],v["18"],v["19"],v["20"]
			local battleId,warid,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,victor,report,attRaising,defRaising,areaIndex,placeIndex,time=tonumber(v[1]),tonumber(v[2]),tonumber(v[3]),tonumber(v[4]),v[5],v[6],tonumber(v[7]),tonumber(v[8]),v[9],v[10],v[11],v[12],tonumber(v[13]),tonumber(v[14]),tonumber(v[15]),v[16],tonumber(v[17]),tonumber(v[18]),tonumber(v[19]),v[20],tonumber(v[21])
			-- local isWin=false
			-- if tonumber(victor)==playerVoApi:getUid() then
			-- 	isWin=true
			-- end
			local vo1 = allianceWar2RecordVo:new()
			local selfAlliance1=allianceVoApi:getSelfAlliance()
			local isAttacker
			if selfAlliance1 and selfAlliance1.aid==attAid then
				isAttacker=true
			else
				isAttacker=false
			end
			local isWin=false
			if isAttacker then
				if tonumber(victor)==attId then
					isWin=true
				end
			else
				if tonumber(victor)==defId then
					isWin=true
				end
			end

			local isBattle=true
			if defId==nil or defId==0 or defName==nil or defName=="" then
				isBattle=false
			end

			if attId==1 then
				isBattle=false
			end
			local destroyNum=0
			local lostNum=0

			if report and report.lostShip then
				if isAttacker then
					if report.lostShip.defender then
						for k,v in pairs(report.lostShip.defender) do
							destroyNum=destroyNum+tonumber(v)
						end
					end
					if report.lostShip.attacker then
						for k,v in pairs(report.lostShip.attacker) do
							lostNum=lostNum+tonumber(v)
						end
					end
				else
					if report.lostShip.attacker then
						for k,v in pairs(report.lostShip.attacker) do
							destroyNum=destroyNum+tonumber(v)
						end
					end
					if report.lostShip.defender then
						for k,v in pairs(report.lostShip.defender) do
							lostNum=lostNum+tonumber(v)
						end
					end
				end
			end
	    	-- vo1:initWithData(battleId,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,isWin,report,attRaising,defRaising,time,placeIndex,destroyNum,lostNum,isAttacker)
	    	vo1:initWithData(battleId,warid,attId,defId,attName,defName,attAid,defAid,attAName,defAName,attBuff,defBuff,attPoint,defPoint,isWin,report,attRaising,defRaising,time,placeIndex,destroyNum,lostNum,isAttacker,isBattle)
			table.insert(self.allianceRecordTab,vo1)
		end
		table.sort(self.allianceRecordTab,sortAsc)
		if SizeOfTable(self.allianceRecordTab)==0 then
			self.aFlag=-1
		else
			self.aFlag=0
		end
	end
end

function allianceWar2RecordVoApi:hasMore()
	local pMaxNum=allianceWar2RecordVoApi:getPersonMaxNum()
	local pNum=0
	if self.personRecordTab and SizeOfTable(self.personRecordTab)>0 then
		pNum=SizeOfTable(self.personRecordTab)
	end
	if pMaxNum and pNum and pMaxNum>pNum then
		return true
	end
	return false
end

function allianceWar2RecordVoApi:allianceHasMore()
	local pMaxNum=allianceWar2RecordVoApi:getAllianceMaxNum()
	local pNum=0
	if self.allianceRecordTab and SizeOfTable(self.allianceRecordTab)>0 then
		pNum=SizeOfTable(self.allianceRecordTab)
	end
	if pMaxNum and pNum and pMaxNum>pNum then
		return true
	end
	return false
end

function allianceWar2RecordVoApi:getPersonMaxNum()
	return self.personMaxNum
end
function allianceWar2RecordVoApi:setPersonMaxNum(num)
	self.personMaxNum=num
end
-- 军团，新打开的
function allianceWar2RecordVoApi:getAllianceMaxNum()
	return self.allianceMaxNum
end
function allianceWar2RecordVoApi:setAllianceMaxNum(num)
	self.allianceMaxNum=num
end

function allianceWar2RecordVoApi:getMinAndMaxTime(type)
	local minTs,maxTs=0,0
	if type==1 then
		local personRecordTab=allianceWar2RecordVoApi:getPersonRecordTab()
		if personRecordTab and SizeOfTable(personRecordTab)>0 then
			maxTs=personRecordTab[1].time or 0
			minTs=personRecordTab[SizeOfTable(personRecordTab)].time or 0
		end
	elseif type==4 then
		local allianceRecordTab=allianceWar2RecordVoApi:getAllianceRecordTab()
		if allianceRecordTab and SizeOfTable(allianceRecordTab)>0 then
			maxTs=allianceRecordTab[1].time or 0
			minTs=allianceRecordTab[SizeOfTable(allianceRecordTab)].time or 0
		end
	end
	return minTs,maxTs
end

function allianceWar2RecordVoApi:getPersonRecordTab()
	if self.personRecordTab==nil then
		self.personRecordTab={}
	end
	return self.personRecordTab
end
function allianceWar2RecordVoApi:getAllianceRecordTab()
	if self.allianceRecordTab==nil then
		self.allianceRecordTab={}
	end
	return self.allianceRecordTab
end
function allianceWar2RecordVoApi:getPersonDestroyTab()
	if self.personDestroyTab==nil then
		self.personDestroyTab={}
	end
	return self.personDestroyTab
end
function allianceWar2RecordVoApi:getAllianceDestroyTab()
	if self.allianceDestroyTab==nil then
		self.allianceDestroyTab={}
	end
	return self.allianceDestroyTab
end

function allianceWar2RecordVoApi:getPersonNum()
	local destroyNum=0
	local lostNum=0
	for k,v in pairs(self.personDestroyTab) do
		destroyNum=destroyNum+(v[2] or 0)
		lostNum=lostNum+(v[3] or 0)
	end
	return destroyNum,lostNum
end

function allianceWar2RecordVoApi:getAreaNameByIndex(idx)
	return getlocal("hold_name"..idx)
end

function allianceWar2RecordVoApi:isRed()
	if allianceWar2VoApi.targetState==1 then
		return true
	end
	return false
end

function allianceWar2RecordVoApi:isVictory()
	--if allianceWar2VoApi:checkInWarOrOver()==true then
		if self:isRed()==true then
			if self.redPoint and self.bluePoint and self.redPoint>=self.bluePoint then
				return true
			end
        else
            if self.redPoint and self.bluePoint and self.redPoint<self.bluePoint then
                return true
            end
		end
	--end
	return false
end

