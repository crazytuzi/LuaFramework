helpDefendVoApi={
	helpDefendAll={},
	flag=-1,
	maxNum=5,
}

function helpDefendVoApi:clear()
    if self.helpDefendAll~=nil then
        for k,v in pairs(self.helpDefendAll) do
            self.helpDefendAll[k]=nil
        end
        self.helpDefendAll=nil
    end
    self.helpDefendAll={}
	self.flag=-1
end

function helpDefendVoApi:getFlag()
	return self.flag
end
function helpDefendVoApi:setFlag(flag)
	self.flag=flag
end
function helpDefendVoApi:getMaxNum()
	return self.maxNum
end
function helpDefendVoApi:formatData(data)
	-- self:clear()
	if data and data.list and SizeOfTable(data.list)>0 then
		local list=data.list
		-- local beforeNum=self:getHelpDefendNum()
		local function sortAsc(a, b)
        	if a and b and a.ts and b.ts and a.status and b.status and a.status==b.status then
            	return a.ts<b.ts
            elseif a and b and a.status and b.status then
            	return a.status>b.status
            end
        end
		table.sort(list,sortAsc)
        for k,v in pairs(list) do
	        local vo = helpDefendVo:new()
	        vo:initWithData(k,v.uid,v.aid,v.name,v.ts,v.status,0)
	        table.insert(self.helpDefendAll,vo)
        end
        local function sortAsc1(a, b)
        	if a.status==b.status then
            	return a.time<b.time
            else
            	return a.status>b.status
            end
        end
        table.sort(self.helpDefendAll,sortAsc1)
        while SizeOfTable(self.helpDefendAll)>5 do
        	table.remove(self.helpDefendAll,6)
    	end
		-- local afterNum=self:getHelpDefendNum()
		-- if beforeNum~=afterNum then
		-- 	self.flag=0
		-- end
    end
    self.flag=0
end

function helpDefendVoApi:formatTankInfo(id,data)
	if id and data and data.troops then
		local hdAll=self:getHelpDefendAll()
		for k,v in pairs(hdAll) do
			if tostring(id)==tostring(v.id) then
				self.helpDefendAll[k].tankInfoTab=data.troops
				helpDefendVoApi:setLastTime(tostring(id),base.serverTime)
			end
		end
    end
end

function helpDefendVoApi:setLastTime(id,time)
	if id and time then
		local hdAll=self:getHelpDefendAll()
		for k,v in pairs(hdAll) do
			if tostring(id)==tostring(v.id) then
				self.helpDefendAll[k].lastTime=time
			end
		end
	end
end

function helpDefendVoApi:getHelpDefend(id)
	if id then
		local hdAll=self:getHelpDefendAll()
		for k,v in pairs(hdAll) do
			if tostring(id)==tostring(v.id) then
				return v
			end
		end
	end
	return nil
end

function helpDefendVoApi:hasHelpDefend()
	local num=self:getHelpDefendNum()
	if num>0 then
		return true
	else
		return false
	end
end
function helpDefendVoApi:getHelpDefendNum()
	local helpDefendAll=self:getHelpDefendAll()
	local num=0
	if helpDefendAll~=nil then
		num=SizeOfTable(helpDefendAll)
	end
	return num
end
function helpDefendVoApi:getHelpDefendAll()
	if self.helpDefendAll==nil then
		self.helpDefendAll={}
	end
	return self.helpDefendAll
end
function helpDefendVoApi:getTimeLeast()
	local hDefendAll=self:getHelpDefendAll()
	if hDefendAll and SizeOfTable(hDefendAll)>0 then
		local helpDefendAll={}
		for k,v in pairs(hDefendAll) do
			if v.status==0 then
				if v.time-base.serverTime<=0 then
					local isDelete=false
					local myAid=playerVoApi:getPlayerAid()
					if myAid>0 then
						if tostring(v.aid)~=tostring(myAid) then
							isDelete=true
						end
					else
						isDelete=true
					end
					if isDelete==true then
						self:deleteOne(v.id)
					else
						self.helpDefendAll[k].status=1
					end
				else
					table.insert(helpDefendAll,v)
				end
			end
		end
		if SizeOfTable(helpDefendAll)>0 then
			local function sortAsc(a, b)
		    	if a.time and b.time then
		        	return a.time<b.time
		        end
		    end
		    table.sort(helpDefendAll,sortAsc)
		    do return helpDefendAll[1] end
		end
		do return hDefendAll[1] end
	end
	-- if helpDefendAll and SizeOfTable(helpDefendAll)>0 then
	-- 	local function sortAsc(a, b)
	--     	if a.status==b.status then
	--         	return a.time<b.time
	--         else
	--         	return a.status<b.status
	--         end
	--     end
	--     table.sort(helpDefendAll,sortAsc)
	--     return helpDefendAll[1]
	-- end
	return {}
end

function helpDefendVoApi:updateStatus(id,status)
	local hDefendAll=self:getHelpDefendAll()
	if hDefendAll and SizeOfTable(hDefendAll)>0 then
		for k,v in pairs(hDefendAll) do
			if tostring(v.id)==tostring(id) then
				self.helpDefendAll[k].status=status
			elseif v.status==2 then
				self.helpDefendAll[k].status=1
			end
		end
		local function sortAsc(a, b)
        	if a.status==b.status then
            	return a.time<b.time
            else
            	return a.status>b.status
            end
        end
        table.sort(self.helpDefendAll,sortAsc)
	end
	self.flag=0
end

function helpDefendVoApi:deleteOne(id)
	local hDefendAll=self:getHelpDefendAll()
	if hDefendAll and SizeOfTable(hDefendAll)>0 then
		for k,v in pairs(hDefendAll) do
			if tostring(v.id)==tostring(id) then
				-- self.helpDefendAll[k]=nil
				table.remove(self.helpDefendAll,k)
			end
		end
		if self.helpDefendAll and SizeOfTable(self.helpDefendAll)>0 then
			local function sortAsc(a, b)
	        	if a.status==b.status then
	            	return a.time<b.time
	            else
	            	return a.status>b.status
	            end
	        end
	        table.sort(self.helpDefendAll,sortAsc)
	    end
	end
	self.flag=0
end

function helpDefendVoApi:isHasArrive()
	local hDefendAll=self:getHelpDefendAll()
	if hDefendAll and SizeOfTable(hDefendAll)>0 then
		for k,v in pairs(hDefendAll) do
			if v.status==2 or v.status==1 or (v.status==0 and v.time-base.serverTime<0) then
				return true
			end
		end
	end
	return false
end



