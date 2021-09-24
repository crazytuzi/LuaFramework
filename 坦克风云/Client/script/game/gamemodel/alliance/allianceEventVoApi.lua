allianceEventVoApi={
	allEvent={},
	-- flag=-1,
	page=0,
	perPageNum=20,
	hasMore=false,
	maxPage=5,
}
function allianceEventVoApi:clear()
	if self.allEvent~=nil then
        for k,v in pairs(self.allEvent) do
            self.allEvent[k]=nil
        end
        self.allEvent=nil
    end
    self.allEvent={}
	-- self.flag=-1
	self.page=0
	self.hasMore=false
end

function allianceEventVoApi:getPerPageNum()
	return self.perPageNum
end
function allianceEventVoApi:getPage()
	return self.page
end
function allianceEventVoApi:setPage(page)
	self.page=page
end
function allianceEventVoApi:formatData(data)
	local msgHeight=0
	if data and type(data)=="table" and SizeOfTable(data)>0 then
		for k,v in pairs(data) do
			local id=tonumber(k)--v[1]
			local type=tonumber(v[1])
			local isFight=false
			if type==10 or type==11 then
				isFight=true
			end
			local message,time,width,height=self:formatMessage(v)
			local vo=allianceEventVo:new()
			vo:initWithData(id,type,time,message,width,height,isFight)
        	table.insert(self.allEvent,vo)
        	msgHeight=msgHeight+height
		end
		local function sortAsc(a, b)
			if a.time and b.time then
				return a.time > b.time
			end
		end
		table.sort(self.allEvent,sortAsc)
		self.page=self.page+1

		local msgNum=SizeOfTable(data)
		if msgNum>=self:getPerPageNum() and self.page<self.maxPage then
			self.hasMore=true
		else
			self.hasMore=false
		end
	end
	return msgHeight
end
function allianceEventVoApi:formatMessage(data)
	local type=tonumber(data[1])					--类型
	-- local name=tostring(data[2]) or ""				--名字
    local time=tonumber(data[2]) or 0				--时间
	-- local attackerName=tostring(data[4]) or ""		--攻击者名字
	-- local attackerAlliance=tostring(data[5]) or ""	--攻击者公会名字
	-- local resNum=tonumber(data[6]) or 0				--资源数量
	-- local leaderName=tostring(data[7]) or ""		--军团团长
	-- local donateNum=tonumber(data[8]) or 0			--贡献数量
	-- local skillId=tostring(data[9]) or 1			--科技id
	-- local skillLevel=tonumber(data[10]) or 0		--科技id等级
	-- local allianceLevel=tonumber(data[11]) or 0		--军团等级
    local isFight=isFight							--是否是战斗事件

 --    local skillName=""
	-- if skillId and allianceSkillCfg[skillId] then
 --    	skillName=getlocal(allianceSkillCfg[skillId].name) or ""
 --    end

	local params={}
	local message=""
	if type==9 then
    	local str=getlocal("alliance_event_"..type,{tonumber(data[3]) or 0})
    	if data[4] and tonumber(data[4]) and tonumber(data[4])>0 then
    		str=str..","..getlocal("alliance_event_"..type.."_1",{tonumber(data[4])})
    	end
    	if data[5] and data[5]~="" then
    		local sid=tonumber(data[5]) or tonumber(RemoveFirstChar(data[5]))
    		if sid and allianceSkillCfg[sid] then
    			local skillName=getlocal(allianceSkillCfg[sid].name) or ""
    			str=str..","..getlocal("alliance_event_"..type.."_2",{skillName})
    		end
    	end
    	message=str
    elseif type==10 then
    	local name=tostring(data[3]) or ""
    	local attackerName=tostring(data[4]) or ""
    	local resNum=tonumber(data[5]) or 0
    	local attackerAlliance=tostring(data[6]) or ""
    	if attackerAlliance and attackerAlliance~="" and attackerAlliance~="nil" then
    		attackerName=attackerName..getlocal("report_content_alliance",{attackerAlliance})
    	end
        if resNum<0 then
        	params={name,attackerName}
        	message=getlocal("alliance_event_"..type.."_1",params)
        else
        	resNum=FormatNumber(resNum)
        	params={name,attackerName,resNum}
    		message=getlocal("alliance_event_"..type,params)
        end
    else
	    if type==1 or type==2 or type==4 or type==6 then
	    	params={data[3]}
	    elseif type==3 or type==5 or type==7 or type==8 then
	    	if type==8 then
	    		local skillName=""
	    		local sid=tonumber(data[3]) or tonumber(RemoveFirstChar(data[3]))
	    		if sid and allianceSkillCfg[sid] then
	    			skillName=getlocal(allianceSkillCfg[sid].name) or ""
	    		end
	    		params={skillName,tonumber(data[4]) or 1}
	    	else
	    		params={data[3],data[4]}
	    	end
	    elseif type==11 then
	    	-- alliance_event_11="%s击杀了%s增加了军团经验%s，%s级军需箱可拾取",
	    	local name=tostring(data[3]) or ""
	    	local fubenId=tonumber(data[4]) or tonumber(RemoveFirstChar(data[4]))--副本id
	    	local sectionCfg=allianceFubenVoApi:getSectionCfg()
	    	local exp=tonumber(sectionCfg[fubenId].AllianceExp) or 0--军团经验
	    	local sectionCfg=allianceFubenVoApi:getSectionCfg()
	    	local fuben=sectionCfg[fubenId]
	    	local fubenName=getlocal(fuben.name)
	    	params={name,fubenName,exp,fubenId}
	    elseif type==12 or type==15 then --type==15 是击败军团boss副本的事件类型
	    	-- alliance_event_12="alliance_event_12="%s领取了活动奖励，军团经验+%s,
	    	local name=tostring(data[3]) or ""
	    	local exp=tonumber(data[4]) or 0--军团经验
	    	params={name,exp}
        elseif type==13 then
	    	-- alliance_event_13="%s弹劾%s成功，接任为%s。",
	    	local name=tostring(data[3]) or ""
	    	local bName=tostring(data[4]) or ""
	    	local roleStr=getlocal("alliance_role"..(tostring(data[5]) or "0"))
	    	params={name,bName,roleStr}
	    elseif type==14 then
			-- alliance_event_14="%s成功晋升成为%s。",
			local name=tostring(data[3]) or ""
			local roleStr=getlocal("alliance_role"..(tostring(data[4]) or "0"))
	    	params={name,roleStr}
        elseif type == 16 then
            -- 军团旗帜事件
            params = {data[3], getlocal("alliance_role" .. data[4])}
	    end
	    message=getlocal("alliance_event_"..type,params)
	end

	local width=400
	local messageLabel=GetTTFLabelWrap(message,22,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	local height=messageLabel:getContentSize().height+20

    return message,time,width,height
end

function allianceEventVoApi:getAllEvent()
	return self.allEvent
end
function allianceEventVoApi:getEventNum()
	if self.allEvent then
		return SizeOfTable(self.allEvent)
	end
	return 0
end

function allianceEventVoApi:getTimeStr(time)
	--[[--获得time时间table，有year,month,day,hour,min,sec等元素。
	-- tab=os.date("*t",(time))
	tab=os.date("*t",(time))
	local function format(num)
		if num<10 then
			return "0" .. num
		else
			return num
		end
	end
	local date=getlocal("email_time",{format(tab.month),format(tab.day),format(tab.hour),format(tab.min)})--]]
    
    local date=G_getDataTimeStr(time)
	return date
end

function allianceEventVoApi:isHasMore()
	return self.hasMore
end

function allianceEventVoApi:getMinTime()
	local allEvent=self:getAllEvent()
	local minTime=0
	if allEvent then
		local function sortAsc(a, b)
			if a.time and b.time then
				return a.time > b.time
			end
		end
		table.sort(allEvent,sortAsc)
		minTime=allEvent[SizeOfTable(allEvent)].time  or 0
	end
	return minTime
end

