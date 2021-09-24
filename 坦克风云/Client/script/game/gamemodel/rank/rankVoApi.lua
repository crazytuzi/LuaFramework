require "luascript/script/game/gamemodel/rank/rankVo"

rankVoApi={
	fightingRank={},
	starRank={},
	creditRank={},
	rankUserInfoList={}
}

function rankVoApi:clear()
    self:clearFightingRank()
    self:clearStarRank()
    self:clearCreditRank()
    self:clearRankUserInfoList()
end
function rankVoApi:clearFightingRank()
    if self.fightingRank~=nil then
        for k,v in pairs(self.fightingRank) do
            self.fightingRank[k]=nil
        end
        self.fightingRank=nil
    end
    self.fightingRank={}
end
function rankVoApi:clearStarRank()
    if self.starRank~=nil then
        for k,v in pairs(self.starRank) do
            self.starRank[k]=nil
        end
        self.starRank=nil
    end
    self.starRank={}
end
function rankVoApi:clearCreditRank()
    if self.creditRank~=nil then
        for k,v in pairs(self.creditRank) do
            self.creditRank[k]=nil
        end
        self.creditRank=nil
    end
    self.creditRank={}
end

function rankVoApi:clearRankUserInfoList()
    if self.rankUserInfoList~=nil then
        for k,v in pairs(self.rankUserInfoList) do
            self.rankUserInfoList[k]=nil
        end
        self.rankUserInfoList=nil
    end
    self.rankUserInfoList={}
end

function rankVoApi:formatRank(type,data)
	local key=nil
	if type==1 then
		key="fightingRank"
	elseif type==2 then
		key="starRank"
	elseif type==3 then
		key="creditRank"
	end
	if key~=nil then
		self[key].isMore=false
		if self[key].selfRank==nil or SizeOfTable(self[key].selfRank)==0 then
			local value
		    if type==1 then
				value=playerVoApi:getPlayerPower()
			elseif type==2 then
				value=checkPointVoApi:getStarNum()
			elseif type==3 then
				value=playerVoApi:getCredit()
			end
		    local rvo = rankVo:new()
		    rvo:initWithData(playerVoApi:getUid(),playerVoApi:getPlayerName(),playerVoApi:getPlayerLevel(),"100+",value)
			self[key].selfRank=rvo
		end
		if data.myranking~=nil then
			self[key].selfRank=nil
			local selfRank=data.myranking
		    local rvo = rankVo:new()
		    local rank=selfRank[4] or 0
		    if rank<=0 then
		    	rank="100+"
		    end
		    rvo:initWithData(selfRank[1],selfRank[2],selfRank[3],rank,selfRank[5])
			self[key].selfRank=rvo
		end
		if data.ranking~=nil then
			local rankData=data.ranking
			if self[key].rankData==nil then
				self[key].rankData={}
			end
			local num=0
			for k,v in pairs(rankData) do
		        local vo = rankVo:new()
		        vo:initWithData(v[1],v[2],v[3],v[4],v[5])
		        table.insert(self[key].rankData,vo)
				num=num+1
			end
			local function sortAsc(a, b)
				return a.rank < b.rank
			end
			table.sort(self[key].rankData,sortAsc)
			
			if self[key].page==nil then
				self[key].page=1
			else
				self[key].page=self[key].page+1
			end
			if self[key].page<5 and num>=20 then
				self[key].isMore=true
			end
		end
	end
end
function rankVoApi:getFightingRank()
	if self.fightingRank==nil then
		self.fightingRank={}
	end
	return self.fightingRank
end
function rankVoApi:getStarRank()
	if self.starRank==nil then
		self.starRank={}
	end
	return self.starRank
end
function rankVoApi:getCreditRank()
	if self.creditRank==nil then
		self.creditRank={}
	end
	return self.creditRank
end

function rankVoApi:getRank(type)
	if type==0 then
		return self:getFightingRank()
	elseif type==1 then
		return self:getStarRank()
	elseif type==2 then
		return self:getCreditRank()
	end
	return {}
end

function rankVoApi:getRankNum(type)
	local rData=self:getRank(type).rankData
	local num=0
	if rData~=nil then
		num=SizeOfTable(rData)+1
	end
	return num
end

function rankVoApi:hasMore(type)
	local rData=self:getRank(type)
	local isMore=rData.isMore
	if isMore then
		return true
	end
	return false
end

function rankVoApi:getUserInfo(uid)
	if self.rankUserInfoList[uid]==nil then
		self.rankUserInfoList[uid]={}
	end
	return self.rankUserInfoList[uid]
end

function rankVoApi:socketUserInfo( uid,func )
	local function callback( fun,data )
		local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.info then
            	self.rankUserInfoList[uid]={}
            	if sData.data.info[1]~="" and sData.data.info[1]~=nil then
                	self.rankUserInfoList[uid].title=sData.data.info[1]
                else
                	self.rankUserInfoList[uid].title=""
                end
				self.rankUserInfoList[uid].playerIcon=sData.data.info[2]
				if sData.data.info[3]~="" and sData.data.info[3]~=nil then
					self.rankUserInfoList[uid].headFrame=sData.data.info[3]
				else
					self.rankUserInfoList[uid].headFrame="nil"
				end
				if sData.data.info[6]~=nil and sData.data.info[6]~="" then
					self.rankUserInfoList[uid].power=sData.data.info[6]
				else
					self.rankUserInfoList[uid].power=0
				end
				self.rankUserInfoList[uid].ts=sData.ts
				if sData.data.info[7]~="" and sData.data.info[7]~=nil then
					self.rankUserInfoList[uid].alliance=sData.data.info[7]
				else
					self.rankUserInfoList[uid].alliance=""
				end
				self.rankUserInfoList[uid].vipLevel=sData.data.info[8]
				self.rankUserInfoList[uid].militaryRank=sData.data.info[9]
            end
		end
		func()
	end
	if self.rankUserInfoList[uid]==nil or self.rankUserInfoList[uid].ts==nil or (base.serverTime - self.rankUserInfoList[uid].ts)>36000 then
		socketHelper:rankUserInfo(callback,uid)
	else
		func()
	end
end