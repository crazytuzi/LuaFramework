privateMineVoApi={
    privateMineTb={},
    refreshNewMine=false,
    searchLastTime=0,
}
function privateMineVoApi:clear()
    self.privateMineTb={}
    self.refreshNewMine=false
    self.searchLastTime=0
end

function privateMineVoApi:isCanSearchPrivateMine( )
	if self.searchLastTime + 7 < base.serverTime then
		return true
	end
	return false,getlocal("second_num",{self.searchLastTime + 7 - base.serverTime}) 
end
function privateMineVoApi:setSearchLastTime(newSearchLastTime)
	self.searchLastTime = newSearchLastTime
end

--添加一个保护矿 v.mid,v.stamp,v.flag,v.level,v.type
function privateMineVoApi:addprivateMine(mid,endTime,newflag,newlevel,newType,x,y)
	-- if self.privateMineTb[mid] and self.privateMineTb[mid].endTime == endTime then
	-- 	if newflag and newflag ~= self.privateMineTb[mid].flag then
	-- 		self.privateMineTb[mid].flag  = newflag
	-- 	end
	-- 	do return end
	-- end
    self.privateMineTb[mid]=nil
    self.privateMineTb[mid]=privateMineVo:new(mid,endTime)
    -- if newflag and newlevel then
	self.privateMineTb[mid].flag  = newflag or self.privateMineTb[mid].flag
	self.privateMineTb[mid].level = newlevel or self.privateMineTb[mid].level
	self.privateMineTb[mid].type  = newType or self.privateMineTb[mid].type
    -- end
    if x and y then
		self.privateMineTb[mid].x     = x
		self.privateMineTb[mid].y     = y
    end
    
end
--当保护矿矿点消失后要删除该矿点
function privateMineVoApi:removePrivateMine(mid)
    if self.privateMineTb[mid] then
        self.privateMineTb[mid]=nil
    end
end

--获取当前保护矿列表
function privateMineVoApi:getPrivateMineList()
	local newpMineTb = {}
	for k,v in pairs(self.privateMineTb) do
		if v.endTime - base.serverTime >= 0 then
			if v.mid and not v.x then
				local changePos = worldBaseVoApi:getPosByMid(tonumber(v.mid))
				v.x = changePos.x
				v.y = changePos.y
			end
			newpMineTb[k] = G_clone(v)
		end
	end
	self.privateMineTb = newpMineTb
    return self.privateMineTb
end

--判断该矿点是不是保护矿矿点
function privateMineVoApi:isPrivateMine(mid)
    local flag=false
    if base.privatemine==1 then
        
        if self.privateMineTb[mid] then
            local lefttime=self:getPrivateMineLeftTime(mid)
            if lefttime==0 then
                self:removePrivateMine(mid)
            else
                flag=true
            end
        end
    end
    return flag
end

function privateMineVoApi:getPrivateMineLeftTime(mid)
    local leftTime=0
    if self.privateMineTb[mid] then
        local endTime=self.privateMineTb[mid].endTime
        leftTime=(tonumber(endTime)-tonumber(base.serverTime))
        if leftTime<0 then
            leftTime=0
        end
        if tonumber(leftTime)==0 then
            self:removePrivateMine(mid)
        end
    end
    return leftTime
end

function privateMineVoApi:setRefreshNewMineFlag(flag)
    self.refreshNewMine=flag
end

function privateMineVoApi:needRefreshNewMine()
    return self.refreshNewMine
end
