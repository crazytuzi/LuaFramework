allianceApplicantVoApi={
	allianceApplicantList={},
}
function allianceApplicantVoApi:clear()
    self.allianceApplicantList=nil
    self.allianceApplicantList={}
end


function allianceApplicantVoApi:addApplicant(data)
    
    local isHave=false
    for k,v in pairs(self.allianceApplicantList) do
        if tonumber(data.uid)==tonumber(v.uid) then
            isHave=true
            if data.level~=nil then
                v.level=data.level
            end
            if data.nickname~=nil then
                v.nickname=data.nickname
            end
            if data.fight~=nil then
                v.fight=data.fight
            end

        end
    end
    if isHave==false and data~=nil then
        local vo=allianceApplicantVo:new()
        vo:initWithData(data.uid,data.nickname,tonumber(data.level),tonumber(data.fight))
        table.insert(self.allianceApplicantList,vo)
    end

end


function allianceApplicantVoApi:getApplicantTab()

	return self.allianceApplicantList

end

function allianceApplicantVoApi:deleteApplicantByUid(uid)
    
    for k,v in pairs(self.allianceApplicantList) do
        if tonumber(uid)==tonumber(v.uid) then
            self.allianceApplicantList[k]=nil
        end
    end
    local newTab ={}
    for k,v in pairs(self.allianceApplicantList) do
        table.insert(newTab,v);
    end
    self.allianceApplicantList={}
    self.allianceApplicantList=newTab
    print("数量=",SizeOfTable(self.allianceApplicantList))

end

