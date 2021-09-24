allianceMemberVoApi={
	allianceMemberList={},
}
function allianceMemberVoApi:clear()
    for k,v in pairs(self.allianceMemberList) do
        v=nil
    end
    self.allianceMemberList=nil
    self.allianceMemberList={}

end

function allianceMemberVoApi:addMember(data)

    local isHave=false
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(data.uid)==tonumber(v.uid) then
            isHave=true
            if data.level~=nil then
                v.level=data.level
            end
            if data.role~=nil then
                v.role=data.role
                --判断如果是自己 role更新
                if tonumber(data.uid)==tonumber(playerVoApi:getUid()) and allianceVoApi:getSelfAlliance()~=nil then
                    allianceVoApi:getSelfAlliance().role=data.role
                end
                v.rank1=0
                if tonumber(v.role)==2 then
                    v.rank1=9999999999998
                end
                if tonumber(v.role)==1 then
                    v.rank1=9999999999997
                end
                if tonumber(v.role)==0 then
                    v.rank1=v.fight
                end
                if tonumber(v.uid)==tonumber(playerVoApi:getUid()) then
                    v.rank1=9999999999999
                end
            end
            if data.fight~=nil then
                v.fight=data.fight
            end
            if data.signature~=nil then
                v.signature=data.signature
            end
            if data.logined_at~=nil then
                v.logined_at=data.logined_at
            end
            if data.weekraising~=nil then
                v.weekDonate=tonumber(data.weekraising)
            end
            if data.raising~=nil then
                v.donate=tonumber(data.raising)
            end
            if data.raising_at~=nil then
                v.donateTime=tonumber(data.raising_at)
            end
            if data.use_rais~=nil then
                v.useDonate=tonumber(data.use_rais) or 0
            end
            if data.apoint ~=nil then
                v.apoint=tonumber(data.apoint)
            end
            if data.apoint_at ~=nil then
                v.apoint_at=tonumber(data.apoint_at)
            end
            
            if data.ar ~=nil then
                v.ar=tonumber(data.ar)
            end
            if data.ar_at ~=nil then
                v.ar_at=tonumber(data.ar_at)
            end
            if data.name then
                v.name=data.name
            end
        end
    end
    if isHave==false and data~=nil then
        local vo=allianceMemberVo:new()

        vo:initWithData(data.uid,data.name,data.level,data.role,data.fight,data.signature,nil,tonumber(data.weekraising),tonumber(data.raising),tonumber(data.raising_at),tonumber(data.use_rais) or 0,tonumber(data.join_at),tonumber(data.apoint),tonumber(data.apoint_at),data.ar,tonumber(data.ar_at))
        if data.logined_at~=nil then
            vo.logined_at=data.logined_at
        end

        vo.rank1=0
        if tonumber(vo.role)==2 then
            vo.rank1=9999999999998
        end
        if tonumber(vo.role)==1 then
            vo.rank1=9999999999997
        end
        if tonumber(vo.role)==0 then
            vo.rank1=data.fight
        end
        if tonumber(vo.uid)==tonumber(playerVoApi:getUid()) then
            vo.rank1=9999999999999
        end

        table.insert(self.allianceMemberList,vo)

    end


end

function allianceMemberVoApi:changeMemberSignByUid(uid,sign)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            v.signature=sign
        end
    end
end

function allianceMemberVoApi:getMemberTab()
    local tb={}
    for k,v in pairs(self.allianceMemberList) do
        tb[k]=v
    end
    local rank1Tb={}
    table.sort(tb,function(a,b) return tonumber(a.fight)>tonumber(b.fight) end)

    for k,v in pairs(tb) do
        v.rank2=k
    end
    table.sort(tb,function(a,b) return tonumber(a.rank2)<tonumber(b.rank2) end)
    local role1MemberTb={}
    for k,v in pairs(tb) do
        if tonumber(playerVoApi:getUid())==tonumber(v.uid) then
            rank1Tb[1]=v
        elseif tonumber(v.role)==2 and tonumber(playerVoApi:getUid())~=tonumber(v.uid) then
            rank1Tb[2]=v
        elseif tonumber(v.role)==1 and tonumber(playerVoApi:getUid())~=tonumber(v.uid) then
            table.insert(role1MemberTb,v)
        end
    end
    
    for k,v in pairs(role1MemberTb) do
        table.insert(rank1Tb,v)
    end

    table.sort(tb,function(a,b) return tonumber(a.rank2)<tonumber(b.rank2) end)
    for k,v in pairs(tb) do
        if tonumber(playerVoApi:getUid())~=tonumber(v.uid) and tonumber(v.role)~=2 and tonumber(v.role)~=1 then
            table.insert(rank1Tb,v)
        end
    end

	return rank1Tb

end
function allianceMemberVoApi:getMemberTabByDonate()
    local rank4Tb={}
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(playerVoApi:getUid())==tonumber(v.uid) then
            v.rank4=999999
        else
            -- v.rank4=v.donate
            v.rank4=v.weekDonate
        end
    end
    -- table.sort(self.allianceMemberList,function(a,b) return tonumber(a.donate)>tonumber(b.donate) end)
    -- table.sort(self.allianceMemberList,function(a,b) return tonumber(a.weekDonate)>tonumber(b.weekDonate) end)

      local function sortFunc(a,b)
        if (a.weekDonate)>tonumber(b.weekDonate) then
            return true
        elseif a and b and tonumber(a.weekDonate) > 0 and tonumber(a.weekDonate) == tonumber(b.weekDonate) then
            if tonumber(a.donateTime) < tonumber(b.donateTime) then
                return true
            end
        end
    end
    table.sort(self.allianceMemberList,sortFunc)

    for k,v in pairs(self.allianceMemberList) do
        v.rank3=k
    end
    
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(playerVoApi:getUid())==tonumber(v.uid) then
            rank4Tb[1]=v
        end
    end

    table.sort(self.allianceMemberList,function(a,b) return tonumber(a.rank3)<tonumber(b.rank3) end)

    for k,v in pairs(self.allianceMemberList) do
        if tonumber(playerVoApi:getUid())~=tonumber(v.uid) then
            table.insert(rank4Tb,v)
        end
    end

	return rank4Tb
end

function allianceMemberVoApi:getMemberTabByActive()
    local rank5Tb={}
    
    table.sort(self.allianceMemberList,function(a,b) return tonumber(a.apoint)>tonumber(b.apoint) end)

    for k,v in pairs(self.allianceMemberList) do
        v.rank5=k
    end
    
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(playerVoApi:getUid())==tonumber(v.uid) then
            rank5Tb[1]=v
        end
    end

    table.sort(self.allianceMemberList,function(a,b) return tonumber(a.rank5)<tonumber(b.rank5) end)

    for k,v in pairs(self.allianceMemberList) do
        if tonumber(playerVoApi:getUid())~=tonumber(v.uid) then
            table.insert(rank5Tb,v)
        end
    end

	return rank5Tb
end

function allianceMemberVoApi:appointmentMemberByUid(uid,role)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            v.role=role
            break;
        end
    end
end

function allianceMemberVoApi:deleteMemberByUid(uid)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            self.allianceMemberList[k]=nil
            break;
        end
    end
    
    local newTab ={}
    for k,v in pairs(self.allianceMemberList) do
        table.insert(newTab,v);
    end
    self.allianceMemberList={}
    self.allianceMemberList=newTab

end

function allianceMemberVoApi:getLeaderNum()
    local num=0
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(v.role)==1 then
            num=num+1;
        end
    end
    return num;
end

function allianceMemberVoApi:getCanUseDonate(uid)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            if v.donate and v.useDonate then
                local canUseDonate=tonumber(v.donate)-tonumber(v.useDonate)
                if canUseDonate>0 then
                    return canUseDonate
                end
            end
        end
    end
    return 0
end
function allianceMemberVoApi:getUseDonate(uid)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            return (v.useDonate or 0)
        end
    end
end
function allianceMemberVoApi:setUseDonate(uid,useDonate)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            v.useDonate=useDonate
        end
    end
end
function allianceMemberVoApi:getDonate(uid)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            return v.donate
        end
    end
end
function allianceMemberVoApi:setDonate(uid,donate)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            v.donate=donate
        end
    end
end
function allianceMemberVoApi:getDonateTime(uid)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            return v.donateTime
        end
    end
end
function allianceMemberVoApi:getWeekDonate(uid)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            local isSameWeek=G_getWeekDay(v.donateTime,base.serverTime)
            if isSameWeek then
                return v.weekDonate
            else
                return 0
            end
        end
    end
end
function allianceMemberVoApi:setWeekDonate(uid,donateTime,donate)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            -- if donateTime>=v.donateTime then
                v.donateTime=donateTime
                v.weekDonate=donate
            -- end
        end
    end
end
function allianceMemberVoApi:addDonate(uid,donate)
    for k,v in pairs(self.allianceMemberList) do
        if uid and donate and tonumber(uid)==tonumber(v.uid) then
            v.donate=v.donate+donate
            v.weekDonate=v.weekDonate+donate
        end
    end
end

function allianceMemberVoApi:setApoint(uid,apoint,apointTime)
    for k,v in pairs(self.allianceMemberList) do
        if uid and apoint and tonumber(uid)==tonumber(v.uid) then
            v.apoint=apoint
            v.apoint_at=apointTime
        end
    end
end

function allianceMemberVoApi:getApoint(uid)
    for k,v in pairs(self.allianceMemberList) do
        if uid and tonumber(uid)==tonumber(v.uid) then
            local isToday=G_isToday(v.apoint_at)
            if isToday then
                return v.apoint
            else
                return 0
            end
        end
    end
end

function allianceMemberVoApi:setUserHadRewardResource(uid,hadReward,rewardTime)
    for k,v in pairs(self.allianceMemberList) do
        if uid and hadReward and tonumber(uid)==tonumber(v.uid) then
            v.ar=hadReward
            v.ar_at=rewardTime
        end
    end
end

function allianceMemberVoApi:getUserHadRewardResource(uid)
    for k,v in pairs(self.allianceMemberList) do
        if uid and tonumber(uid)==tonumber(v.uid) then
            local isToday=G_isToday(v.ar_at)
            if isToday then
                return v.ar
            else
                return {}
            end
        end
    end
end


function allianceMemberVoApi:getMemberByUid(uid)
    for k,v in pairs(self.allianceMemberList) do
        if tonumber(uid)==tonumber(v.uid) then
            return v
        end
    end
    return {}
end

function allianceMemberVoApi:getMemberByName(name)
    for k,v in pairs(self.allianceMemberList) do
        if name and tostring(name)==tostring(v.name) then
            return v
        end
    end
    return nil
end
