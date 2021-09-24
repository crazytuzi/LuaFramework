acEquipSearchIIVoApi = {
	flag={-1,-1},
	isToday=true,
	lastListTime=0,
	formatContentCfg=nil,
}

function acEquipSearchIIVoApi:clearAll()
	self.flag={-1,-1}
	self.isToday=true
	self.lastListTime=0
	self.formatContentCfg=nil
end

function acEquipSearchIIVoApi:getAcVo()
	return activityVoApi:getActivityVo("equipSearchII")
end

function acEquipSearchIIVoApi:clearRankList()
	local data={rankList={}}
	local vo=self:getAcVo()
	vo:updateSpecialData(data)
end

function acEquipSearchIIVoApi:getFlag(idx)
	return self.flag[idx]
end
function acEquipSearchIIVoApi:setFlag(idx,value)
	if idx then
		if value then
			self.flag[idx]=value
		else
			self.flag[idx]=1
		end
	else
		if value then
			self.flag={value,value}
		else
			self.flag={1,1}
		end

	end
end

function acEquipSearchIIVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	self.flag={0,0}
	activityVoApi:updateShowState(vo)
end
function acEquipSearchIIVoApi:setLastTime(time)
	local vo=self:getAcVo()
	vo.lastTime=time
	self.flag={0,0}
	activityVoApi:updateShowState(vo)
end
function acEquipSearchIIVoApi:setListRewardNum()
	local vo=self:getAcVo()
	if vo and vo.listRewardNum then
		vo.listRewardNum=1
		activityVoApi:updateShowState(vo)
	end
end

function acEquipSearchIIVoApi:isSearchToday()
	local vo=self:getAcVo()
	if self:checkCanSearch() and G_isToday(vo.lastTime)==false then
		return false
	end
	return true
end

function acEquipSearchIIVoApi:getEquipSearchCfg()
	local version = self:getCfgVersion()
	if version and (version==2 or version ==4) then
		return activityCfg.equipSearchIII
	elseif version and (version ==1 or version==3) then
		return activityCfg.equipSearchII
	elseif version ==5 then
		return activityCfg.equipSearchIV
	elseif version ==6 then
		return activityCfg.equipSearchVI
	elseif version ==7 then
		return activityCfg.equipSearchVII
	elseif version ==8 then
		return activityCfg.equipSearchVIII
	end
end

function acEquipSearchIIVoApi:checkCanSearch()
	local vo=self:getAcVo()
	if self:acIsStop()==false and activityVoApi:isStart(vo) then
		return true
	end
	return false
end

function acEquipSearchIIVoApi:getRankList()
	local vo=self:getAcVo()
	if vo and vo.rankList and SizeOfTable(vo.rankList)>0 then
		return vo.rankList
	else
		return {}
	end
end

function acEquipSearchIIVoApi:getSelfRank()
	local vo=self:getAcVo()
	if vo and vo.rankList and SizeOfTable(vo.rankList)>0 then
		for k,v in pairs(vo.rankList) do
			if v and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
				return k
			end
		end
	end
	return "10+"
end

function acEquipSearchIIVoApi:canReward()
	local vo=self:getAcVo()
	if self:acIsStop()==false and activityVoApi:isStart(vo)==true and self:isSearchToday()==false then
		return true
	end
	return false
end

function acEquipSearchIIVoApi:rankCanReward()
	local cfg=self:getEquipSearchCfg()
	local vo=self:getAcVo()
	if vo and vo.listRewardNum==0 and self:acIsStop()==true and activityVoApi:isStart(vo) then
		if vo.point and vo.point>=cfg.rankPoint then
			if vo.rankList and SizeOfTable(vo.rankList)>0 then
				for k,v in pairs(vo.rankList) do
					if v and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
						return tonumber(k) or 0
					end
				end
			end
		end
	end
	return 0
end

function acEquipSearchIIVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acEquipSearchIIVoApi:getTimeStr()
	local vo=self:getAcVo()
	-- local acSt=os.date("*t",vo.st)
	-- local acEt = os.date("*t",vo.acEt)
	-- local stStr = getlocal("activity_equipSearch_data",{acSt.month,acSt.day})
	-- local etStr = getlocal("activity_equipSearch_data",{acEt.month,acEt.day})
	-- local timeStr = getlocal("activity_equipSearch_time",{stStr,etStr})
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	local str=getlocal("activity_timeLabel")..":"..timeStr
	return str
end

function acEquipSearchIIVoApi:getRewardTimeStr( )
	local vo = self:getAcVo()
	local rewardTimeStr = activityVoApi:getActivityRewardTimeStr(vo.acEt,60,86400)
	local str = getlocal("recRewardTime")..":"..rewardTimeStr
	return str
end


function acEquipSearchIIVoApi:formatContent(index)
	if self.formatContentCfg==nil then
		self.formatContentCfg={}

		local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
		for p,q in pairs(cfg.pool) do
			local reward=q.content
		    local content={}
		    for k,v in pairs(reward) do
		        local rewardType=k
		        for m,n in pairs(v) do
		            local key
		            local point=0
		            local num=0
		            local index=0
		            local name,pic,desc,id,nouse,eType,equipId
		            for i,j in pairs(n) do
		                if j then
		                    if i=="wz" then
		                        if type(j)=="table" and j[1] and j[2] then
		                            point=j[1].."~"..j[2]
		                        else
		                            point=tonumber(j)
		                        end
		                    elseif i=="index" then
		                        index=tonumber(j)
		                    else
		                        key=i
		                        num=tonumber(j)
		                        name,pic,desc,id,nouse,eType,equipId=getItem(i,rewardType)
		                    end
		                end
		            end
		            local award={name=name,num=num,pic=pic,desc=desc,id=id,type=rewardType,index=index,key=key,eType=eType,equipId=equipId}
		            local function sortAsc(a, b)
		                if a and b and a.index and b.index and tonumber(a.index) and tonumber(b.index) then
		                    return a.index < b.index
		                end
		            end
		            table.sort(award,sortAsc)
		            table.insert(content,{award=award,point=point})
		        end
		    end
		    table.insert(self.formatContentCfg,p,content)
		end
    end
    return self.formatContentCfg[index]
end

function acEquipSearchIIVoApi:getIndexByNameAndNum(name,num)
	local cfg=self:getEquipSearchCfg()
	for k,v in pairs(cfg.pool) do
		local content=self:formatContent(k)
		for m,n in pairs(content) do
			local award=n.award
			if name and num and award and tostring(name)==tostring(award.key) and tostring(num)==tostring(award.num) then
				return v.index
			end
		end
		
	end
	return 0
end


function acEquipSearchIIVoApi:getCfgVersion()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.version then
		return acVo.version
	end
	return 1
end

-- 以下是新版需添加
-- mustMode 判断新版本还是旧版本
function acEquipSearchIIVoApi:getMustMode()
	local vo = self:getAcVo()
	if vo.mustMode and tonumber(vo.mustMode)==1 then
		return true
	end
	return false
end

function acEquipSearchIIVoApi:getMustReward(tag)
	local vo = self:getAcVo()
	if tag==nil then
		tag=1
	end
	return vo["mustReward" .. tag]
end

function acEquipSearchIIVoApi:getFlickerTipTb(idx)
	local cfg=self:getEquipSearchCfg()
	local flickerTb = cfg.flick
	if flickerTb and flickerTb[idx] and SizeOfTable(flickerTb[idx]) > 0 then
		return flickerTb[idx]
	end
	return nil
end

