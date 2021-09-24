allianceWarUserVo={}
function allianceWarUserVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceWarUserVo:initWithData(allianceWarUserTb)
    if allianceWarUserTb~=nil and SizeOfTable(allianceWarUserTb)>0 then
        if allianceWarUserTb.uid~=nil and allianceWarUserTb.uid==playerVoApi:getUid() then
            self.battle_at=allianceWarUserTb.battle_at
            self.b1=allianceWarUserTb.b1
            self.b2=allianceWarUserTb.b2
            self.b3=allianceWarUserTb.b3
            self.b4=allianceWarUserTb.b4
            self.cdtime_at=allianceWarUserTb.cdtime_at
            self.buff_at=allianceWarUserTb.buff_at
        end

    end
end