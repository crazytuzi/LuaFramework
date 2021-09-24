acAllianceDonateVo=activityVo:new()
function acAllianceDonateVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.hasReward=nil			--是否领取过奖励
	self.rankList={}			--排行榜
	self.selfDonate=0			--本军团在此期间的总贡献
	return nc
end

function acAllianceDonateVo:updateSpecialData(data)
    self.acEt=self.et-86400

	if(data and tonumber(data.c)==0)then
		self.hasReward=false
	elseif(data and tonumber(data.c)==-1)then
		self.hasReward=true
	end
end

function acAllianceDonateVo:updateRank(data)
	if(data.point)then
		self.selfDonate=tonumber(data.point)
	end
	local selfRank
	local selfAid
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if(selfAlliance~=nil)then
		selfAid=selfAlliance.aid
	else
		selfAid=0
	end
	if(data and data.ranklist)then
		self.rankList={}
		for k,v in pairs(data.ranklist) do
			local obj={}
			obj.aid=tonumber(v[1])
			obj.donate=tonumber(v[2])
			obj.name=v[4]
			obj.num=tonumber(v[5])
			obj.rank=tonumber(k)
			self.rankList[k]=obj
			if(obj.aid==selfAid)then
				selfRank=obj.rank
			end
		end
	end
	if(selfRank==nil)then
		selfRank="10+"
	end
	if(selfAlliance~=nil)then
		local obj={aid=selfAlliance.aid,name=selfAlliance.name,num=selfAlliance.num,donate=self.selfDonate,rank=selfRank}
		table.insert(self.rankList,1,obj)
	end
end
