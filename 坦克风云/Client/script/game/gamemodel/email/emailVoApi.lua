require "luascript/script/game/gamemodel/email/emailVo"
require "luascript/script/game/gamemodel/report/reportVoApi"

emailVoApi={
	receive={},
	report={},
	send={},
	--unreadNum=0,
	unreadData={},
	--refreshFlag={},
	maxNum=100,
	needRefreshData=false,
}

function emailVoApi:clear(type)
	if type==1 then
	    for k,v in pairs(self.receive) do
	        self.receive[k]=nil
	    end
		self.receive={}
	elseif type==2 then
	    for k,v in pairs(self.report) do
	        self.report[k]=nil
	    end
		self.report={}
	elseif type==3 then
	    for k,v in pairs(self.send) do
	        self.send[k]=nil
	    end
		self.send={}
	end
end
function emailVoApi:clearUnreadData()
	if self.unreadData~=nil then
		for k,v in pairs(self.unreadData) do
			self.unreadData[k]=nil
		end
		self.unreadData=nil
	end
	self.unreadData={}
end
function emailVoApi:clearEmails()
	self:clear(1)
	self:clear(2)
	self:clear(3)
	self:clearUnreadData()
	--self.unreadNum=0
    --self.refreshFlag={}
end

function emailVoApi:formatData(data)
	for k,v in pairs(data) do
		local key=nil
		local etype=1
		if k=="inbox" then
			key="receive"
			etype=1
		elseif k=="report" then
			key="report"
			etype=2
		elseif k=="sent" then
			key="send"
			etype=3
		end
		if key then
			if self[key]==nil then
				self[key]={}
			end
			if self[key].flag==nil or self[key].flag==-1 then
				self:clear(etype)
				if etype==2 then
					reportVoApi:deleteAll()
				end
				self:setFlag(etype,1)
			elseif self[key].flag~=0 then
				self:setFlag(etype,0)
			end

			if v and v.flag then
				-- 设置一键领取的状态标记
				local readedAllFlag = v.flag or 0
				self:setReadedAllFlag(1, tonumber(readedAllFlag))
			end

			if v and v.mc then
				self[key].mc=tonumber(v.mc)
			end
			if self[key].mc==nil then
				self[key].mc=0
			end

			if v and v.maxrows then
				self[key].mailNum=tonumber(v.maxrows)
			end
			if self[key].mailNum==nil then
				self[key].mailNum=0
			end
			if self[key].mails==nil then
				self[key].mails={}
			end
			local mails
			if v and v.mails then
				mails=v.mails
			end
			if mails then
				for i,j in pairs(mails) do
					local eid=tonumber(j.eid)
					local email=self:getEmailByEid(etype,eid)
					if email==nil or SizeOfTable(email)==0 then
				        local vo = emailVo:new()
						local sender=tonumber(j.sender) or 1
						local from=j.from or getlocal("scout_content_system_email")
						local title=j.title or ""
						if sender==0 then
							from=getlocal("scout_content_system_email")
						elseif from=="" or sender==1 then
							if (tostring(title)=="31" or tostring(title)=="50") and from and from~="" then
							else
								from=getlocal("scout_content_system_email")
							end
							title=self:getAllianceEmailTitle(title)
						end
						local content=j.content or ""
						local isRead=tonumber(j.isRead) or 0
						local time=tonumber(j.ts)
						local to=tostring(j.to)
						local headlinesData
						local reportType
						if key=="report" then
							local titleData=j.title
							local tempLv = 0
							if j.content and j.content.info and j.content.info.islandLevel then
								tempLv = j.content.info.islandLevel
							end
							title,reportType=self:getAttackTitle(titleData,to,tempLv)
							from=getlocal("scout_content_system_email")
							if type(content)=="table" then
								if content.type==2 then
									isRead=1
								end
								self:addReport(content,eid,time)
							end
						else
							if key=="send" then
								isRead=1
								if to=="2" then
									to=getlocal("alliance_scene_all_member")
								end
							end

							if type(content)=="table" then
								if content.headlinesData then
									headlinesData=content.headlinesData
								end
								if content.content then
									content=content.content
								else
									content=""
								end
							end
						end
						local gift=tonumber(j.gift)
						local reward={}
						local flick={}
						local worldWarPoint=0
						if gift==3 then
							if j.item and tonumber(j.item) then
								worldWarPoint=tonumber(j.item)
							end
							title=getlocal("world_war_rank_reward_point_title")
						elseif tonumber(Split(j.title, "=")[1]) == 63 then --限时惊喜活动礼包
							title = getlocal("alliance_email_title63")
							if j.item and j.item.q then
								for rk, rv in pairs(j.item.q) do
									for rkk, rvv in pairs(rv) do
										if reward[rkk] == nil then
											reward[rkk] = {}
										end
										table.insert(reward[rkk], rvv)
									end
								end
								flick=j.item.f or {}
								gift = 4
							end
						else
							if j.item and j.item.q then
								reward=j.item.q
								flick=j.item.f or {}
							end
						end
						local isReward=tonumber(j.isreward)
				        vo:initWithData(eid,sender,from,to,title,content,time,isRead,j.attackData,gift,reward,isReward,flick,worldWarPoint,headlinesData,reportType)
				        table.insert(self[key].mails,vo)
					end
				end
				local function sortAsc(a, b)
					if a and b and a.time and b.time then
						return a.time > b.time
					end
				end
				table.sort(self[key].mails,sortAsc)
			end
			local totalNum=self:getTotalNumByType(etype)
			local mailNum=self:getNumByType(etype)
			self[key].isHas=true
			if mailNum>=totalNum then
				self[key].isHas=false
			end
			if SizeOfTable(self[key].mails)>100 or self[key].mailNum>100 then
				self[key].mailNum=100
				if SizeOfTable(self[key].mails)>100 then
					self[key].isHas=false
				end
			end
			while SizeOfTable(self[key].mails)>100 do
				table.remove(self[key].mails,101)
			end
		end
		--[[
		if self:getRefreshFlag(etype)~=0 then
			self:setRefreshFlag(etype,0)
		end
		]]
	end
end

-- 格式化一键删除和领取按钮状态
function emailVoApi:formatAutoDeleteAndReceive(data)
	if data~=nil then
        local tempType = data.type
        local tempFlag = data.flag or 0
        local tempMc = data.mc or 0

		self:setReadedAllFlag(tempType, tempFlag)
		self:setCanDeleteStateByType(tempType, tempMc)
	end
end

-- 获取是否可以一键领取状态
function emailVoApi:getReadedAllFlag(type)
	local flag = 0
	if type == 1 then
		flag = self.receive.readedAllFlag
	end
	return flag
end
function emailVoApi:setReadedAllFlag(type,flag)
	if type == 1 then
		self.receive.readedAllFlag = flag
	end
end

function emailVoApi:getFlag(type)
	local flag=-1
	if type==1 then
		flag=self.receive.flag
	elseif type==2 then
		flag=self.report.flag
	elseif type==3 then
		flag=self.send.flag
	end
	return flag
end
function emailVoApi:setFlag(type,flag)
	if type==1 then
		self.receive.flag=flag
	elseif type==2 then
		self.report.flag=flag
	elseif type==3 then
		self.send.flag=flag
	end
end
--[[
function emailVoApi:setRefreshFlag(type,flag)
	if self.refreshFlag==nil then
		self.refreshFlag={}
	end
	self.refreshFlag["t"..type]=flag
end
function emailVoApi:getRefreshFlag(type)
	if self.refreshFlag==nil then
		self.refreshFlag={}
	end
	return self.refreshFlag["t"..type]
end
function emailVoApi:setPage(type,page)
	local emailData={self.receive,self.report,self.send}
	emailData[type].page=page
end
function emailVoApi:getPage(type)
	local emails=self:getDataByType(type)
	return emails.page
end
]]
function emailVoApi:getDataByType(type)
	if type==1 then
		return self.receive
	elseif type==2 then
		return self.report
	elseif type==3 then
		return self.send
	end
end
function emailVoApi:getEmailsByType(type)
	if type==1 then
		if self.receive.mails==nil then
			self.receive.mails={}
		end
		return self.receive.mails
	elseif type==2 then
		if self.report.mails==nil then
			self.report.mails={}
		end
		return self.report.mails
	elseif type==3 then
		if self.send.mails==nil then
			self.send.mails={}
		end
		return self.send.mails
	end
end
function emailVoApi:getEmailByEid(type,eid)
	local emails=self:getEmailsByType(type)
	for k,v in pairs(emails) do
        if tostring(eid)==tostring(v.eid) then
			return v
		end
	end
	return {}
end
function emailVoApi:getMinAndMaxEid(type)
	local mineid,maxeid=0,0
	local emails=self:getEmailsByType(type)
	local num=emailVoApi:getNumByType(type)
	if emails~=nil and SizeOfTable(emails)~=0 then
		mineid,maxeid=emails[num].eid,emails[1].eid
	end
	return mineid,maxeid
end

function emailVoApi:getTotalNumByType(type)
	local data=self:getDataByType(type)
	local num=0
	if data then
		num=tonumber(data.mailNum or 0 )
	end
	return num
end
function emailVoApi:getNumByType(type)
	local emails=self:getEmailsByType(type)
	local num=0
	if emails then
		num=SizeOfTable(emails)
	end
	return num
end
-- 获得邮件和报告可删除状态
function emailVoApi:getCanDeleteStateByType(type)
	local mc = 0
	local emails=self:getDataByType(type)

	if emails.mc then
		mc = emails.mc
	end

	return mc
end
-- 设置邮件和报告可删除状态
function emailVoApi:setCanDeleteStateByType(type, state)
	local emails=self:getDataByType(type)
	if(emails and emails.mc)then
		emails.mc = state
	end
end

function emailVoApi:getNotReadNumByType(type)
	local num=0
	local emails=self:getEmailsByType(type)
	for k,v in pairs(emails) do
        if v.isRead==0 then
			num=num+1
		end
	end
	return num
end


function emailVoApi:formatUnread(data)
	if data~=nil then
		--[[
		if type(data)=="string" or type(data)=="num" then
			self.unreadNum=tonumber(data)
		else
		]]
			self:clearUnreadData()
			for i=1,3 do
				local num=data[tostring(i)]
				if num~=nil then
					self.unreadData[i]=tonumber(num) or 0
				else
					self.unreadData[i]=0
				end
			end
			--end
	end
end
function emailVoApi:getHasUnread(type)
	local num=0
	if self.unreadData then
		if type~=nil then
			if self.unreadData[type] then
				num=self.unreadData[type]
			end
		else
			for k,v in pairs(self.unreadData) do
				num=num+v
			end
		end
	end
	--num=self.unreadNum
	--[[
	if num>0 then
		return true
	else
		return false
	end
	]]
	return num
end
function emailVoApi:setHasUnread(type,num)
	if self.unreadData then
		if self.unreadData[type] then
			if num then
				self.unreadData[type]=num
			else
				self.unreadData[type]=self.unreadData[type]-1
				if self.unreadData[type]<0 then
					self.unreadData[type]=0
				end
			end
		end
	end
	--[[
	if self.unreadNum>0 then
		self.unreadNum=self.unreadNum-1
	end
	]]
end

function emailVoApi:getTimeStr(time)
	--[[tab=os.date("*t",time)
	--获得time时间table，有year,month,day,hour,min,sec等元素。
	local function format(num)
		if num<10 then
			return "0" .. num
		else
			return num
		end
	end
	local date=getlocal("email_time",{format(tab.month),format(tab.day),format(tab.hour),format(tab.min)})--]]
    
    local date = G_getDataTimeStr(time)
	return date
end

--title 1.成功申请军团 2.申请被拒绝 3.加入军团 4.被踢出军团 5.团长已转让 6.军团职务变更 7.军团职务变更
function emailVoApi:getAllianceEmailTitle(title)
	local titleStr=title
	if title and title~="" then
        local tData=Split(title,"=")
        if tData then
            local titleType=tData[1]
            local parms={}
            for k,v in pairs(tData) do
                if k>=2 then
                    table.insert(parms,v)
                end
            end
            if titleType==44 and acNewYearsEveVoApi and acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
            	titleStr=getlocal("alliance_email_title"..titleType.."_1",parms)
            else
            	titleStr=getlocal("alliance_email_title"..titleType,parms)
            end
        elseif tonumber(title) then
            local titleType=tonumber(title)
            --if titleType>=1 and titleType<=4 then
            if titleType==44 and acNewYearsEveVoApi and acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
                titleStr=getlocal("alliance_email_title"..title.."_1")
            else
                titleStr=getlocal("alliance_email_title"..title)
            end
            --end
        end
	end
	return titleStr
end
-- content={type=1,aName="aName",cName="cName",role=0,1,2}
-- type 1.成功申请军团 2.申请被拒绝 3.加入军团 4.被踢出军团 5.团长已转让 6.军团职务变更 7.军团职务变更 9.军团战报名成功 10.军团战大获全胜 11.军团战不幸战败
-- aName:公会名称 
-- cName:团长名字
function emailVoApi:formatAllianceContent(content)
	local contentStr=content
	if content and type(content)=="table" then
		local cType=tonumber(content.type)
		if cType then
			local paramData={}
			local contentKey=""
			if cType==1 or cType==2 or cType==3 then
				paramData={content.aName}
			elseif cType==4 then
                local roleStr=getlocal("alliance_role"..(content.role or 2))
                paramData={roleStr,content.cName,content.aName}
            elseif cType==5 then
				paramData={content.cName,content.aName}
			elseif cType==6 or cType==7 then
				local roleStr=getlocal("alliance_role"..(content.role or 0))
				paramData={content.cName,roleStr}
            elseif cType==8 then--7天不登陆弹劾
                local roleStr=getlocal("alliance_role"..(content.role or 0))
				paramData={content.bName,content.cName,content.aName,roleStr}
			elseif cType==9 then
				local pos=content.pos or ""
				local redname=content.redname or ""
				local bluename=content.bluename or ""
				local opents=content.opents or {}
				local startTs=opents.st or 0
				local endTs=opents.et or 0
				local position=content.position or 1
				-- local posStr=getlocal("allianceWar_cityName_"..position)
				local posStr=""
				local alliancewarnew=content.alliancewarnew
				if alliancewarnew and alliancewarnew==1 and allianceWar2Cfg and allianceWar2Cfg.city and allianceWar2Cfg.city[position] and allianceWar2Cfg.city[position].name then
					posStr=getlocal(allianceWar2Cfg.city[position].name)
				else
					posStr=getlocal("allianceWar_cityName_"..position)
				end
				local timeStr=G_chatTime(startTs)
				local allianceName=""
				if pos and pos=="red" then
					allianceName=bluename
				else
					allianceName=redname
				end
				if allianceName==nil or allianceName=="" then
					paramData={timeStr,posStr}
					contentKey="alliance_email_content9_1"
				else
					paramData={timeStr,allianceName,posStr}
				end
			elseif cType==10 then
				local endTs=content.et or 0
				local time=G_getWeeTs(endTs)
				--local timeTab = os.date("*t",time)
				--local timeStr = getlocal("activity_equipSearch_data",{timeTab.month,timeTab.day})
                local timeStr = G_getDataTimeStr(time,false,true)
				local posId=content.posId or 1
				-- local posStr=getlocal("allianceWar_cityName_"..posId)
				local posStr=""
				local alliancewarnew=content.alliancewarnew
				if alliancewarnew and alliancewarnew==1 and allianceWar2Cfg and allianceWar2Cfg.city and allianceWar2Cfg.city[posId] and allianceWar2Cfg.city[posId].name then
					posStr=getlocal(allianceWar2Cfg.city[posId].name)
				else
					posStr=getlocal("allianceWar_cityName_"..posId)
				end
				if content.eName and content.eName~="" then
					paramData={content.aName,timeStr,content.eName,posStr}
				else
					paramData={content.aName,timeStr,posStr}
					contentKey="alliance_email_content10_1"
				end
			elseif cType==11 then
				local endTs=content.et or 0
				local time=G_getWeeTs(endTs)
				--local timeTab = os.date("*t",time)
				--local timeStr = getlocal("activity_equipSearch_data",{timeTab.month,timeTab.day})
                local timeStr = G_getDataTimeStr(time,false,true)
				local posId=content.posId or 1
				-- local posStr=getlocal("allianceWar_cityName_"..posId)
				local posStr=""
				local alliancewarnew=content.alliancewarnew
				if alliancewarnew and alliancewarnew==1 and allianceWar2Cfg and allianceWar2Cfg.city and allianceWar2Cfg.city[posId] and allianceWar2Cfg.city[posId].name then
					posStr=getlocal(allianceWar2Cfg.city[posId].name)
				else
					posStr=getlocal("allianceWar_cityName_"..posId)
				end
				paramData={content.aName,timeStr,content.eName,posStr}
			elseif cType==12 then
				local reward=content.reward or {}
				local rewardTab=FormatItem(reward,nil,true)
				paramData={rewardTab[1].name}
			elseif cType==13 then
				local buildLevel=content.blevel or 0
				local playerLevel=content.plevel or 0
				local reward=content.reward or {}
				local rewardTab=FormatItem(reward,nil,true)
				paramData={buildLevel,playerLevel,rewardTab[1].name,rewardTab[2].name}
            elseif cType==14 then
				local name=content.nickname or ""
				local posX=content.x or 0
				local posY=content.y or 0
				paramData={name,posX,posY}
			elseif cType==15 then
				local time=content.ts or 0
				local timeStr=G_getDataTimeStr(time,true,true)
				paramData={timeStr}
			elseif cType==16 or cType==17 or cType==18 or cType==22 or cType==23 or cType==24  then
				local name=content.name or ""
				paramData={name}
			elseif cType==19 or cType==21 then
				local name=playerVoApi:getPlayerName()
				local aName=content.aName or ""
				paramData={name,aName}
			elseif cType==20 then
				local name=playerVoApi:getPlayerName()
				local aName=content.aName or ""
				local hName=content.hName or ""
				paramData={name,aName,hName}
			elseif cType==25 then
				local rank=content.rank or 0
				paramData={rank}
			elseif cType==27 then
				local startWeekDay=localWarCfg.prepareTime
				local weekDay=startWeekDay+localWarCfg.battleTime
				local weekDayStr=G_weekDayStr(weekDay)
				local battleSt=localWarCfg.startWarTime[1]..":"..localWarCfg.startWarTime[2]
				paramData={weekDayStr,battleSt}
			elseif cType==28 or cType==29 then
				local name=content.name or ""
				local aname=content.aname or ""
				local jobid=content.job or 0
				if jobid and jobid>0 and localWarCfg.jobs and localWarCfg.jobs[jobid] then
					if jobid==10 then
						paramData={aname}
						local buffCfg=localWarCfg.jobs[jobid].buff
						for k,v in pairs(buffCfg) do
							if v and localWarCfg.buff[v] then
								local buffValue=0
								if v==10 then
									buffValue=localWarCfg.buff[v].value
								else
									buffValue=localWarCfg.buff[v].value*100
								end
								table.insert(paramData,buffValue)
							end
						end
					else
						local jobStr=""
						if jobid and jobid>0 and localWarCfg.jobs[jobid] then
							local title=localWarCfg.jobs[jobid].title
							jobStr=getlocal(title)
						end
						paramData={name,jobStr}
					end
				end
			elseif cType==31 then
				local name=content.name or 0
				paramData={name}
			elseif cType==32 then
				local rank=content.rank
				paramData={rank}
			elseif cType==33 then
				local dayNum=0
				if localWarCfg and localWarCfg.buffTime then
					dayNum=localWarCfg.buffTime
				end
				paramData={dayNum}
			elseif cType==42 then
				local bstartTime=content.st or 0
				local astartTime=content.ats or (bstartTime-3600)
				local timeStr1=self:getTimeStr(astartTime)
				local timeStr2=self:getTimeStr(bstartTime)
				paramData={timeStr1,timeStr2}
			elseif cType ==49 then
				local pName = content.aname
				local resourceSub = math.abs(content.resFix*100)
				local glorySub = math.abs(content.atkFix*100)
				local goldRenew =  math.abs(content.gemFix*100)
				local removeNeedExp = gloryCfg.destoryGlory.removeNeedExp
				paramData ={pName,resourceSub,goldRenew,glorySub,removeNeedExp}
			elseif cType ==51 then
				local retGems = content.retGems or 0
				paramData ={retGems}
			elseif cType ==52 then
				local forbidType=tonumber(content.mtype) or 0
				if forbidType==0 then
					return ""
				end
				local forbidReason=tonumber(content.ctype) or 0
				local beginTime=content.ts or 0
				local endTime=content.et or 0
				local addDesc=content.desc or ""
				local fbReasonStr=""
				local fbStr=""
				if tonumber(forbidReason)>1 then
					fbReasonStr=getlocal("reason_str").."【"..getlocal("forbid_chat_reason"..forbidReason).."】"
				end
				if forbidType==1 then
					fbStr=getlocal("chatinfo")..getlocal("and_text")..getlocal("mainMail")
				elseif forbidType==2 then
					fbStr=getlocal("chatinfo")
				elseif forbidType==3 then
					fbStr=getlocal("mainMail")
				end
				paramData={fbReasonStr,math.floor((endTime-beginTime)/3600),G_getDataTimeStr(endTime),fbStr,addDesc}
			elseif cType==60 or cType==61 then
				local _name
				local _str1=""
				local ltype=tonumber(content.ltype)
				if ltype==1 then
					_str1=getlocal("player_icon")
					_name=headCfg.list[tostring(content.id)].name
				elseif ltype==2 then
					_str1=getlocal("head_frame")
					_name=headFrameCfg.list[tostring(content.id)].name
				elseif ltype==3 then
					_str1=getlocal("chat_buble")
					_name=chatFrameCfg.list[tostring(content.id)].name
				end
				_name=_name or ""
				paramData={getlocal(_name),G_getDataTimeStr(content.time),_str1}
			elseif cType == 62 then
				paramData = {getlocal("acMemoryServer_newSoldiers")}
				if acMemoryServerVoApi then
					local taskList = acMemoryServerVoApi:getTaskList(content.rewardtype)
					if taskList then
						for tk, tv in pairs(taskList) do
							if tv.tsk == content.tid then
								local needNum = tv.num[content.sid]
								paramData = {acMemoryServerVoApi:getTaskDesc(tv.key, needNum, needNum, tv.quality)}
								break
							end
						end
						
					end
				end
			end
			if contentKey and contentKey~="" then
				contentStr=getlocal(contentKey,paramData)
			else
				if cType==44 and acNewYearsEveVoApi and acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
					contentStr=getlocal("alliance_email_content"..cType.."_1",paramData)
				else
					contentStr=getlocal("alliance_email_content"..cType,paramData)
				end
			end
		end
	end
	return contentStr
end
--titleData 1-2-attackerName-defenderName attackerName判断自己是否是攻击者
--mailReceiver 邮件的接收方昵称
--selectLv 侦查等级
function emailVoApi:getAttackTitle(titleData,mailReceiver,selectLv)
	local titleStr=""
	local _reportType
	if titleData~=nil then
		local tData=Split(titleData,"-")
		local reportType,islandType=tonumber(tData[1]),tonumber(tData[2])
		_reportType=reportType
		if islandType==7 and reportType<3 then
			local rebelLv,rebelID,rpic=1,1,0 --rpic是标识叛军头像的（中秋赏月活动添加）
			if tData[4] then
				local rebelData=Split(tData[4],",")
				if rebelData then
					rebelLv,rebelID,rpic=tonumber(rebelData[1]) or 1,tonumber(rebelData[2]) or 1,tonumber(rebelData[3]) or 0
				end
			end
			local target=G_getIslandName(islandType,nil,rebelLv,rebelID,nil,rpic)
			if reportType==1 then
				titleStr=getlocal("fight_content_fight_title")..getlocal("email_figth_title1",{target})
			elseif reportType==2 then
				titleStr=getlocal("scout_content_scout_title")..getlocal("email_scout_title",{target})
			end
			do return titleStr,_reportType end
		end
		local attackerName=""
		if tData[3] and tostring(tData[3]) then
			attackerName=tostring(tData[3])
			string.gsub(attackerName,"-","—")
		end
		local defenderName=""
		if tData[4] and tostring(tData[4]) then
			defenderName=tostring(tData[4])
			string.gsub(defenderName,"-","—")
		end
		local isAttacker=false
		local selfName=""
		if mailReceiver and type(mailReceiver)=="string" then
			selfName=mailReceiver
		else
			selfName=playerVoApi:getPlayerName()
		end
		selfName=string.gsub(selfName,"-","—")

		local lenNum=string.len(titleData)
		--特殊符号需转义
		local formatName=string.gsub(selfName,"[^%w]",function(s) return "%"..tostring(s) end)
		local startIdx,endIdx=string.find(titleData,formatName)
		-- print("selfName",selfName)
		-- print("attackerName",attackerName)
		-- print("defenderName",defenderName)
		-- print("startIdx",startIdx)
		-- print("endIdx",endIdx)
		if startIdx~=nil and endIdx~=nil and (selfName==attackerName or selfName==defenderName) then
			if startIdx==5 and selfName~=defenderName then
				isAttacker=true
				attackerName=selfName
				if lenNum>=endIdx+2 then
					if string.sub(titleData,endIdx+2)~=nil and string.sub(titleData,endIdx+2)~="" then
						defenderName=string.sub(titleData,endIdx+2)
					end
				end
			else
				defenderName=selfName
				if string.sub(titleData,5,startIdx-2)~=nil and string.sub(titleData,5,startIdx-2)~="" then
					attackerName=string.sub(titleData,5,startIdx-2)
				end
			end
		-- else
		-- 	isAttacker=false
		-- 	attackerName=tostring(tData[3]) or ""
		-- 	defenderName=tostring(tData[4]) or ""
		end
		local target=""
		if reportType==1 then
			if isAttacker==true then
                target=G_getIslandName(islandType,defenderName)
				titleStr=getlocal("fight_content_fight_title")..getlocal("email_figth_title1",{target})
			else
				target=attackerName
				if islandType==8 then
					titleStr=getlocal("fight_content_fight_title")..getlocal("email_figth_title4",{target})
				else
					titleStr=getlocal("fight_content_fight_title")..getlocal("email_figth_title2",{target})
				end
			end
		elseif reportType==2 then
            target=G_getIslandName(islandType,defenderName)
            if selectLv and selectLv > 0 then
            	target = target .. " " .. getlocal("fightLevel", {selectLv})
            end
			titleStr=getlocal("scout_content_scout_title")..getlocal("email_scout_title",{target})
		elseif reportType==3 then
			titleStr=getlocal("fight_content_return_title")
		elseif reportType==4 then
			titleStr=getlocal("gather_report_title")
		elseif reportType==5 then
			target=attackerName
			titleStr=getlocal("search_base_report_title",{target})
		elseif reportType==6 then
			target=attackerName
			titleStr=getlocal("search_fleet_report_title",{target})
		elseif reportType==7 then
			titleStr=getlocal("attack_city_report_title")
		elseif reportType==8 then
			titleStr=getlocal("def_city_report_title")
		elseif reportType==9 then
			titleStr=getlocal("hitfly_email_title1")
		elseif reportType==10 then
			titleStr=getlocal("hitfly_email_title2")
		end
	end
	return titleStr,_reportType
end

function emailVoApi:setIsRead(type,eid)
	local emailData={self.receive.mails,self.report.mails,self.send.mails}
	for k,v in pairs(emailData[type]) do
	    if tostring(eid)==tostring(v.eid) then
			if v.isRead==0 then
				v.isRead=1
				self:setHasUnread(type)
			end
		end
	end
end
function emailVoApi:setAllReaded(type)
	local emailData={self.receive.mails,self.report.mails,self.send.mails}
	for k,v in pairs(emailData[type]) do
		-- if v.isRead==0 then
			v.isRead=1
		-- end
	end
	self:setHasUnread(type, 0)
end
function emailVoApi:deleteByType(type)
	if type==1 then
        for k,v in pairs(self.receive.mails) do
			--[[
			if v.isRead==0 then
				self:setHasUnread(type)
			end
			]]
            self.receive.mails[k]=nil
        end
        self.receive.mails=nil
        self.receive.mails={}
		self.receive.mailNum=0
		self.receive.isHas=false
		-- self:setHasUnread(1,0)
		self.receive.mc=0
	elseif type==2 then
        for k,v in pairs(self.report.mails) do
			--[[
			if v.isRead==0 then
				self:setHasUnread(type)
			end
			]]
            self.report.mails[k]=nil
        end
        self.report.mails=nil
		self.report.mails={}
		self.report.mailNum=0
		self.report.isHas=false
        reportVoApi:deleteAll()
		-- self:setHasUnread(2,0)
		self.report.mc=0
	elseif type==3 then
        for k,v in pairs(self.send.mails) do
			--[[
			if v.isRead==0 then
				self:setHasUnread(type)
			end
			]]
            self.send.mails[k]=nil
        end
        self.send.mails=nil
		self.send.mails={}
		self.send.mailNum=0
		self.send.isHas=false
		self:setHasUnread(3,0)
		self.send.mc=0
	end
end

function emailVoApi:deleteByEid(type,eid)
	local emailData={self.receive,self.report,self.send}
	for k,v in pairs(emailData[type].mails) do
	    if tostring(eid)==tostring(v.eid) then
			--emailData[type][k]=nil
			table.remove(emailData[type].mails,k)
			emailData[type].mailNum=emailData[type].mailNum-1
		end
		--[[
		local function sortAsc(a, b)
			if a.time and b.time then
				return a.time > b.time
			end
		end
		table.sort(emailData[type].mails,sortAsc)
		]]
		--self:setRefreshFlag(type,0)
		self:setFlag(type,0)
	end
	if type==2 then
	    reportVoApi:deleteReport(eid)
	end
end

function emailVoApi:addEmail(mailType,data)
	if data==nil then
		do return end
	end
    if SizeOfTable(data)==0 then
        do return end
    end
	local emailData={self.receive,self.report,self.send}
	for k,v in pairs(data) do
		if v then
		    local vo = emailVo:new()
		    local eid=tonumber(v.eid)
			local sender=tonumber(v.sender) or 1
			local from=v.from or getlocal("scout_content_system_email")
			local title=v.title or ""
			if sender==0 then
				from=getlocal("scout_content_system_email")
			elseif from=="" or sender==1 then
				if tostring(title)=="31" and from and from~="" then
				else
					from=getlocal("scout_content_system_email")
				end
				title=self:getAllianceEmailTitle(title)
			end
			local content=v.content or ""
			local isRead=tonumber(v.isRead) or 0
			local time=tonumber(v.ts)
			local to=tostring(v.to)
			local headlinesData
			local reportType
			if mailType==2 then
				local titleData=v.title
				local tempLv = 0
				if v.content and v.content.info and v.content.info.islandLevel then
					tempLv = v.content.info.islandLevel
				end
				title,reportType=self:getAttackTitle(titleData,to,tempLv)
				from=getlocal("scout_content_system_email")
				if type(content)=="table" then
					if content.type==2 then
						isRead=1
					end
					self:addReport(content,eid,time)
				end
			else
				if mailType==3 then
					isRead=1
					if to=="2" then
						to=getlocal("alliance_scene_all_member")
					end
				end
				if type(content)=="table" then
					if content.headlinesData then
						headlinesData=content.headlinesData
					end
					if content.content then
						content=content.content
					else
						content=""
					end
				end
			end
			local gift=tonumber(v.gift)
			local reward={}
			local flick={}
			local worldWarPoint=0
			if gift==3 then
				if v.item and tonumber(v.item) then
					worldWarPoint=tonumber(v.item)
				end
				title=getlocal("world_war_rank_reward_point_title")
			else
				if v.item and type(v.item)=="table" and v.item.q then
					reward=v.item.q
					flick=v.item.f or {}
				end
			end
			local isReward=tonumber(v.isreward)
		    vo:initWithData(eid,sender,from,to,title,content,time,isRead,nil,gift,reward,isReward,flick,worldWarPoint,headlinesData,reportType)
			if emailData[mailType].mails==nil then
				emailData[mailType].mails={}
			end
		    table.insert(emailData[mailType].mails,vo)
			local function sortAsc(a, b)
				if a.time and b.time then
					return a.time > b.time
				end
			end
			table.sort(emailData[mailType].mails,sortAsc)
			if emailData[mailType].mailNum==nil then
				emailData[mailType].mailNum=0
			end
			emailData[mailType].mailNum=emailData[mailType].mailNum+1
		end
	end
	if (emailData[mailType].mails and SizeOfTable(emailData[mailType].mails)>100) or (emailData[mailType].mailNum and emailData[mailType].mailNum>100) then
		emailData[mailType].mailNum=100
		if (emailData[mailType].mails and SizeOfTable(emailData[mailType].mails)>100) then
			emailData[mailType].isHas=false
		end
	end
	while (emailData[mailType].mails and SizeOfTable(emailData[mailType].mails)>100) do
		table.remove(emailData[mailType].mails,101)
	end
    if mailType==3 and (self:getFlag(mailType)==-1 or self:getFlag(mailType)==nil) then
    else
        --self:setRefreshFlag(mailType,0)
        self:setFlag(mailType,0)
    end
end

function emailVoApi:addReport(data,eid,time)
	--data={info={attacker,attackerName,attackerLevel,defenser,defenserName,defenserLevel,islandType,islandOwner,islandLevel,place={1,1},ts,credit,isVictory},...} 战斗数据
	local reportData
	--类型 1.战斗 2.侦查 3.返航 4.采集部队返回报告 5.查找目标基地 6.查找目标部队 7.攻击世界叛军
	local reportType=tonumber(data.type)
	local battleData=data.info
	local rebelData=data.rebel --叛军数据
	--战斗信息
	local time=time
	local attacker={id=0,name="",level=0,allianceName=""}
	local defender={id=0,name="",level=0,allianceName=""}
	local islandOwner=0
	local islandType=0
	local place={x=0,y=0}
	local attackerPlace={x=0,y=0}
	local level=0
	local isVictory=0
	local returnType=1
	local name=""
	local credit=0
	local helpStr=""
	local attackerAllianceName=""
	local defenderAllianceName=""
	local accessory=data.aey or {}
	local aLandform=0 --攻击方地形类型
	local dLandform=0 --防守方地形类型
	local landform=0  --侦查地形类型
	local rp=data.rp or {0,0} --军功
	local hero=data.hh or {{{},0},{{},0}} --英雄信息
	local richLevel=0
	local battleRichLevel=0
	local boom = nil
	local boomMax = nil
	local boomTs = nil
	local boomBmd = nil
	local helpDefender=data.helpDefender
	local goldMineLv=0
	local fleetload=0
	local disappearTime=0
	local targetName=""
	local allianceName=""
	local power=0
	local glory={0,0}
	local searchtype=1
	local leftTime=0
	local curRes=0
	local isHasFleet=false
	--叛军部分数据
	local pic=1 --头像
	local multiNum=0 --攻击倍数
	local rebelLv=1 --叛军等级
	local rebelID=1 --叛军编号
	local rebelTotalLife=0 --叛军总血量
	local rebelLeftLife=0 --叛军剩余血量
	local reduceLife=0 --本次攻击打掉叛军血量
	local attNum=0 	--连续几次攻击
	local expireTs=0 --过期时间(逃跑)
	local acData={} --活动数据
	local rpic=1 --叛军头像
	local privateMine = nil -- 判断是否为保护矿
	local aistatus --侦查报告中玩家AI部队生产状态

	if helpDefender then
		if type(helpDefender)=="table" then
			helpStr=""
		elseif tostring(helpDefender) then
			helpStr=tostring(helpDefender)
		end
	end

	if battleData~=nil then
        attackerAllianceName=tostring(battleData.AAName) or ""
        defenderAllianceName=tostring(battleData.DAName) or ""

		if battleData.aLandform then
			aLandform=tonumber(battleData.aLandform) or 0
		end

		if battleData.dLandform then
			dLandform=tonumber(battleData.dLandform) or 0
		end

		if battleData.landform then
			landform=tonumber(battleData.landform) or 0
		end

		if battleData.ts~=nil then
			time=battleData.ts
		elseif battleData.time then
			time=battleData.time
		end
	
		if battleData.attacker then
			local fight,vip,rank,pic,fhid
			local attInfo=battleData.attInfo
			if attInfo then
				fight,vip,rank,pic,fhid=attInfo[1],attInfo[2],attInfo[3],attInfo[4],attInfo[5]
			end
			attacker={id=battleData.attacker,name=tostring(battleData.attackerName),level=battleData.attackerLevel,allianceName=attackerAllianceName,fight=fight,vip=vip,rank=rank,pic=pic,fhid=fhid}
		end
		if battleData.defenser then
			local fight,vip,rank,pic,fhid
			local defInfo=battleData.defInfo
			if defInfo then
				fight,vip,rank,pic,fhid=defInfo[1],defInfo[2],defInfo[3],defInfo[4],defInfo[5]
			end
			defender={id=battleData.defenser,name=tostring(battleData.defenserName),level=battleData.defenserLevel,allianceName=defenderAllianceName,fight=fight,vip=vip,rank=rank,pic=pic,fhid=fhid}
		end
	
		if battleData.islandOwner then
			islandOwner=tonumber(battleData.islandOwner)
		end

		if battleData.islandType then
			islandType=tonumber(battleData.islandType)
		end
		if battleData.place then
			place={x=tonumber(battleData.place[1] or 0),y=tonumber(battleData.place[2] or 0)}
		end
		if battleData.attackerPlace then
			attackerPlace={x=tonumber(battleData.attackerPlace[1] or 0),y=tonumber(battleData.attackerPlace[2] or 0)}
		elseif battleData.AttackerPlace then
			attackerPlace={x=tonumber(battleData.AttackerPlace[1] or 0),y=tonumber(battleData.AttackerPlace[2] or 0)}
		end
		if battleData.islandLevel then 
			level=tonumber(battleData.islandLevel)
			rebelLv=tonumber(battleData.islandLevel)
		elseif battleData.level then
			level=tonumber(battleData.level)
		end

		if battleData.rettype then
			returnType=tonumber(battleData.rettype)
		end
	
		if battleData.name then
			name=tostring(battleData.name)
		end
		
		if battleData.isVictory~=nil then
			isVictory=battleData.isVictory
		end
	
		credit=tonumber(battleData.reputation)
		if credit==nil then
			credit=0
		end
		if data.bm then
			boom = data.bm.boom
			boomMax = data.bm.boom_max
			boomTs = data.bm.boom_ts
			boomBmd = data.bm.bmd
		end
		-- local helpDefender=battleData.helpDefender
		-- if helpDefender then
		-- 	if type(helpDefender)=="table" then
		-- 		for k,v in pairs(helpDefender) do
		-- 			helpStr=helpStr..v.."\t\t\t"
		-- 		end
		-- 	else
		-- 		helpStr=helpDefender
		-- 	end
		-- end
		if battleData.mapHeat then
			if battleData.mapHeat.point and battleData.mapHeat.ts then
				local richminePoint=tonumber(battleData.mapHeat.point) or 0
				local richmineTs=tonumber(battleData.mapHeat.ts) or 0
				local hasDefender=false
				if battleData.defenser and islandType~=6 then
					hasDefender=true
				end
				richLevel=worldBaseVoApi:getRichMineLv(hasDefender,richmineTs,richminePoint,time)
			end
		end
		if battleData.boom then
			boom=battleData.boom
		end

		--搜索雷达和间谍卫星部分
		if battleData.target then
			targetName=battleData.target
		end
		if battleData.aName then
			allianceName=battleData.aName
		end
		if battleData.power then
			power=battleData.power
		end
		if battleData.glory then
			glory=battleData.glory
		end
		if battleData.searchtype then
			searchtype=battleData.searchtype
		end
		if battleData.leftTime then
			leftTime=battleData.leftTime
		end
		if battleData.curRes then
			curRes=battleData.curRes
		end
		if battleData.isHasFleet then
			isHasFleet=battleData.isHasFleet
		end
		if battleData.aistatus then
			aistatus=battleData.aistatus
		end
	end

	if rebelData then
		if rebelData.reduceLife then
			reduceLife=tonumber(rebelData.reduceLife) or 0
		end
		if rebelData.rebelTotalLife then
			rebelTotalLife=tonumber(rebelData.rebelTotalLife) or 0
		end
		if rebelData.rebelLeftLife then
			rebelLeftLife=tonumber(rebelData.rebelLeftLife) or 0
			if rebelLeftLife<0 then
				--得出本次攻击前叛军血量，去除冗余血量
				reduceLife=reduceLife+rebelLeftLife 
				rebelLeftLife=0
			end
		end
		if reduceLife>rebelTotalLife then
			reduceLife=rebelTotalLife
		end

		if rebelData.multiNum then
			multiNum=tonumber(rebelData.multiNum) or 0
		end
		if rebelData.pic then
			pic=rebelData.pic or 1
		end
		if rebelData.rpic then
			rpic=rebelData.rpic or 1
		end
		if rebelData.rebelID then
			rebelID=tonumber(rebelData.rebelID) or 1
		end
		if rebelData.rebelLv then
			rebelLv=tonumber(rebelData.rebelLv) or 1
		end
		if rebelData.energy then
			energy=tonumber(rebelData.energy) or nil
		end
		if rebelData.attNum then
			attNum=tonumber(rebelData.attNum) or 0
		end
		if rebelData.rebelExpireTs then
			expireTs=tonumber(rebelData.rebelExpireTs) or 0
		end

		if reportType==3 and returnType==2 then
			returnType=9
			islandType=7
		end

		--中秋赏月活动，攻打叛军获得道具(桂花酒)时添加一句话
		if rebelData.midautumn then
			acData.midautumn=rebelData.midautumn
		end
	end


	if data.rLv then
		battleRichLevel=tonumber(data.rLv)
	end
	
	if data.goldMineLv then
		goldMineLv=tonumber(data.goldMineLv)
	end
	
	if data.pMine then
		privateMine = tonumber(data.pMine)
	end
	if battleData.fleetload then
		fleetload=tonumber(battleData.fleetload)
	elseif battleData.maxRes then
		fleetload=tonumber(battleData.maxRes)
	end
	if data.goldLeftTime then
		disappearTime=tonumber(data.goldLeftTime)
	end
	--战斗奖励
	local awardTab={}
	if data.rewards then
		awardTab=FormatItem(data.rewards)
	end
	--战斗损失
	local lostShip={
		attackerLost={},
		defenderLost={},
		attackerTotal={},
		defenderTotal={}
	}
	if data.destroy then
		local attackerLost=data.destroy.attacker
		local defenderLost=data.destroy.defenser
		if attackerLost then
			lostShip.attackerLost=FormatItem({o=attackerLost},false)
		end
		if defenderLost then
			lostShip.defenderLost=FormatItem({o=defenderLost},false)
		end
	end
    if data.tank then
        local attackerTotal = data.tank.a
        local defenderTotal = data.tank.d
        if attackerTotal then
        	lostShip.attackerTotal =FormatItem({o=attackerTotal},false)
        end
        if defenderTotal then
        	lostShip.defenderTotal =FormatItem({o=defenderTotal},false)
        end

    end
	--防守兵力
	local shipTab={}
	local defendShip=data.defendShip
	if defendShip~=nil and type(defendShip)=="table" then
		for k,v in pairs(defendShip) do
			if v and v[1] and v[2] and v[2]>0 then
				local key=v[1]
				local num=v[2]
				local name,pic,desc=getItem(key,"o")
				table.insert(shipTab,k,{name=name,pic=pic,num=num,key=key})
			else
				table.insert(shipTab,k,{})
			end
		end
	end
	--资源
	local resource=data.resource
	local resourceName={u={r1=0,r2=0,r3=0,r4=0,gold=0},r={r1=0,r2=0,r3=0}}
	local resourceTab=FormatItem(resourceName)
	if resource then
		if reportType==1  then
			--战斗掠夺或被掠夺资源
			local realResTab={u={},r={}}
			local battleRes=resource.battle
			local baseRes=0
			if battleRes~=nil then
				for k,v in pairs(resourceName.u) do
					if battleRes[k]~=nil then
						realResTab.u[k]=battleRes[k]
						baseRes=battleRes[k]
					end
				end
			end
			--金矿系统会掠夺金币
			if resource.robGems and resource.leftGems and goldMineLv and goldMineLv>0 then
				local isAttacker=false
				if tonumber(playerVoApi:getUid())==tonumber(battleData.attacker) then
					isAttacker=true
				end
				local gemsCount=0
				if isAttacker==true then
					gemsCount=resource.robGems
				else
					gemsCount=resource.leftGems
				end
				if gemsCount>0 then
					realResTab.u.gems=tonumber(gemsCount)
				end
			end
			if resource.alienRes then
				for k,v in pairs(resource.alienRes) do
					if v>0 then
						realResTab.r[k]=v
					end
				end
			end
			resourceTab=FormatItem(realResTab)
		elseif reportType==2 then
			--收集资源
			if islandType<6 and islandOwner>0 then
				local collect={}
				local collectRes=resource.collect
				if collectRes~=nil then
					for k,v in pairs(collectRes) do
						local name,pic=getItem(k,"u")
						pic=G_getResourceIcon(k)	
						if name and pic then
							table.insert(collect,{type="u",name=name,num=v,pic=pic})
						end
					end
					if resource.gems and resource.gems>0 then
						local name,pic=getItem("gems","u")
						pic=G_getResourceIcon("gems")
						table.insert(collect,{type="u",name=name,num=resource.gems,pic=pic})
					end
					if resource.alienRes then
						for k,v in pairs(resource.alienRes) do
							local name,pic=getItem(k,"r")
			              	local id=RemoveFirstChar(k)
		                    pic="alien_mines"..id.."_"..id..".png"
	                    	if name and pic then
								table.insert(collect,{type="r",name=name,num=v,pic=pic})
							end
						end
					end
				end
				resourceTab=collect
			elseif islandType==6 then
				local realResTab={u={},r={}}
				local collectRes=resource.battle
				if collectRes~=nil then
					for k,v in pairs(resourceName.u) do
						if collectRes[k]~=nil then
							realResTab.u[k]=collectRes[k]
						end
					end
					resourceTab=FormatItem(realResTab)
					for k,v in pairs(resourceTab) do
						if v.type=="u" then
							local pic=G_getResourceIcon(v.key)
							if pic then
								resourceTab[k].pic=pic
							end
						elseif v.type=="r" then
							local id=RemoveFirstChar(v.key)
		                    local pic="alien_mines"..id.."_"..id..".png"
		                    if pic then
								resourceTab[k].pic=pic
							end
						end
					end
				end
			end
		elseif reportType==4 or reportType==6 then
			local collect={}
			local collectRes=resource.collect
			if collectRes~=nil then
				for k,v in pairs(collectRes) do
					local name,pic=getItem(k,"u")
					if reportType==6 then
						pic=G_getResourceIcon(k)
					end
					table.insert(collect,{type="u",key=k,name=name,num=tonumber(v),pic=pic})
				end
			end
			if resource.gems and resource.gems>0 then
				local name,pic=getItem("gems","u")
				if reportType==6 then
					pic=G_getResourceIcon("gems")
				end
				table.insert(collect,{type="u",key="gems",name=name,num=resource.gems,pic=pic})
			end
			if resource.alienRes then
				for k,v in pairs(resource.alienRes) do
					local name,pic=getItem(k,"r")
					if reportType==6 then
						local id=RemoveFirstChar(k)
		                pic="alien_mines"..id.."_"..id..".png"
					end
                	if name and pic then
						table.insert(collect,{type="r",key=k,name=name,num=v,pic=pic})
					end
				end
			end
			-- local retb={u={r1=10000000,r2=100000000,},r={r1=200000000,r2=100000000,r3=50000000}}
			-- collect=FormatItem(retb)
			resourceTab=collect

			if reportType==6 and searchtype==1 then
				for k,v in pairs(collect) do
					if v and v.num then
						curRes=v.num
					end
				end
				local maxRes=resource.maxRes
				if maxRes then
					for k,v in pairs(maxRes) do
						if v then
							fleetload=v
						end
					end
				end
			end
		end
	end
	local rebel={multiNum=multiNum,rebelLv=rebelLv,rebelID=rebelID,energy=energy,rebelTotalLife=rebelTotalLife,rebelLeftLife=rebelLeftLife,reduceLife=reduceLife,attNum=attNum,expireTs=expireTs,pic=pic,rpic=rpic}

	local emblemID=data.equip
	local plane=data.plane
	local airShip=data.ap

	--local allianceName=data.aName
	if reportType==1 then
		reportData={rid=eid,type=reportType,islandType=islandType,attacker=attacker,defender=defender,place=place,level=level,time=time,islandOwner=islandOwner,isVictory=isVictory,award=awardTab,resource=resourceTab,lostShip=lostShip,credit=credit,helpDefender=helpStr,report=data.report,attackerPlace=attackerPlace,accessory=accessory,aLandform=aLandform,dLandform=dLandform,acaward=data.acaward,rp=rp,hero=hero,battleRichLevel=battleRichLevel,goldMineLv=data.goldMineLv,disappearTime=disappearTime,pic=pic,rebel=rebel,acData=acData,emblemID=emblemID,plane=plane,weapon=data.weapon,armor=data.armor,troops=data.troops,xixue=data.xixue,aitroops=data.ait,effect=data.effect,extraReportInfo=data.ri,privateMine=privateMine,ap=airShip,shipboss=data.shipboss}
	elseif reportType==2 then
		reportData={rid=eid,type=reportType,islandType=islandType,defender=defender,place=place,level=level,time=time,islandOwner=islandOwner,resource=resourceTab,defendShip=shipTab,helpDefender=helpStr,allianceName=defenderAllianceName,landform=landform,richLevel=richLevel,boom=boom,boomMax=boomMax,boomTs=boomTs,boomBmd=boomBmd,goldMineLv=data.goldMineLv,disappearTime=disappearTime,rebel=rebel,emblemID=emblemID,plane=plane,aistatus=aistatus,skin=data.skin,privateMine=privateMine,ap=airShip,shipboss=data.shipboss}
	elseif reportType==3 then
		reportData={rid=eid,type=reportType,returnType=returnType,islandType=islandType,name=name,place=place,level=level,allianceName=defenderAllianceName,richLevel=battleRichLevel,goldMineLv=goldMineLv,time=time,fleetload=fleetload,resource=resourceTab,boom=boom,rebel=rebel,emblemID=emblemID,plane=plane,ap=airShip,shipboss=data.shipboss}
	elseif reportType==4 then
		reportData={rid=eid,type=reportType,returnType=returnType,islandType=islandType,name=name,place=place,level=level,allianceName=defenderAllianceName,richLevel=battleRichLevel,goldMineLv=goldMineLv,time=time,fleetload=fleetload,resource=resourceTab,boom=boom,rebel=rebel,emblemID=emblemID,plane=plane,privateMine=privateMine,ap=airShip,shipboss=data.shipboss}
	elseif reportType==5 or reportType==6 then
		reportData={rid=eid,type=reportType,returnType=returnType,islandType=islandType,name=targetName,place=place,level=level,allianceName=allianceName,richLevel=battleRichLevel,goldMineLv=goldMineLv,time=time,fleetload=fleetload,resource=resourceTab,power=power,glory=glory,searchtype=searchtype,leftTime=leftTime,curRes=curRes,isHasFleet=isHasFleet,defendShip=shipTab,rebel=rebel,emblemID=emblemID,plane=plane,ap=airShip,shipboss=data.shipboss}
	elseif reportType==7 or reportType==8 or reportType==9 or reportType==10 then
		reportData={rid=eid,type=reportType,returnType=returnType,islandType=islandType,name=name,place=place,level=level,allianceName=defenderAllianceName,richLevel=battleRichLevel,goldMineLv=goldMineLv,time=time,fleetload=fleetload,resource=resourceTab,boom=boom,rebel=rebel,emblemID=emblemID,plane=plane,award=awardTab,ap=airShip,shipboss=data.shipboss}
	end
	reportVoApi:addReport(reportType,reportData)
end

function emailVoApi:addContent(data)
	local eid=tonumber(data.eid)
	local etype=tonumber(data.type)
	local email=self:getEmailByEid(etype,eid)
	local sender = data.sender
	if email~=nil and etype and etype<=3 then
		local content=email.content
		local contentData=data.content
		if etype==2 then
			local report=reportVoApi:getReport(eid)
			if report==nil then
				local time=tonumber(data.ts)
				self:addReport(contentData,eid,time)
			end
		else
			if content==nil or content=="" then
				local emailData={self.receive.mails,self.report.mails,self.send.mails}
				local emails=emailData[etype]
				for k,v in pairs(emails) do
			        if tostring(eid)==tostring(v.eid) then
			        	if (etype==1 or etype==3) and type(contentData)=="table" and contentData.headlinesData then
			        		if contentData.headlinesData then
			        			emailData[etype][k].headlinesData=contentData.headlinesData
			        		end
			        		if contentData.content then
			        			emailData[etype][k].content=contentData.content
			        		end
			        	elseif etype==1 and tostring(sender)=="1" and type(contentData)=="table" then
			        		emailData[etype][k].content=self:formatAllianceContent(contentData)
			        	elseif etype==1 and tonumber(sender) and tonumber(sender) > 1 and type(contentData)=="table" and contentData.type == 63 then --限时惊喜好友赠送礼包
			        		emailData[etype][k].content=getlocal("acFlashSale_email_friendGiveText")
			        	else
			        		if email.gift and email.gift==3 then
								if content and type(contentData)~="table" then
									emailData[etype][k].content=getlocal("world_war_rank_reward_point_content",{contentData})
								else
									emailData[etype][k].content=contentData
								end
			        		else
			        			emailData[etype][k].content=contentData
			        		end
						end
					end
				end
			end
		end
	end
end

function emailVoApi:getReport(rid)
	local report=reportVoApi:getReport(rid)
	if report then
		return report
	end
	return {}
end

function emailVoApi:hasMore(type)
	local emailData={self.receive,self.report,self.send}
	local isHas=emailData[type].isHas
	return isHas
end

function emailVoApi:isAttacker(report,playerId)
	local isAttacker=false
	if report~=nil then
		if report.type==1 then
			if report.attacker~=nil then
				local uid = playerId or playerVoApi:getUid()
				if uid~=nil then
					if tonumber(uid)==tonumber(report.attacker.id) then
						isAttacker=true
					end
				end
			end
		end
	end
	return isAttacker
end

function emailVoApi:isShowAccessory(report)
	if base.ifAccessoryOpen==1 and report and report.islandType and (report.islandType==6 or (report.islandType~=6 and report.islandOwner and report.islandOwner>0)) then
		return true
	end
	return false
end

function emailVoApi:isShowHero(report)
	if base.heroSwitch==1 then
		return true
	end
	return false
end

function emailVoApi:isShowArmorMatrix(report)
	if armorMatrixVoApi:isOpenArmorMatrix()==true and report and report.armor then
		return true
	end
	return false
end

function emailVoApi:isShowSuperWeapon(report)
	if report and report.weapon then
		return true
	end
	return false
end

--是否在邮件面板显示军徽信息
function emailVoApi:isShowEmblem(report)
	if base.emblemSwitch==1 and report.emblemID and SizeOfTable(report.emblemID) == 2 and (report.emblemID[1] ~= 0 or report.emblemID[2] ~= 0) then
		return true
	end
	return false
end

function emailVoApi:setIsReward(type,eid)
	if type and eid then
		local emailData={self.receive.mails,self.report.mails,self.send.mails}
		for k,v in pairs(emailData[type]) do
		    if tostring(eid)==tostring(v.eid) then
				v.isReward=1
			end
		end
	end
end

-- 设置所有邮件已领取
function emailVoApi:setIsRewardAll(type)
	local emailData={self.receive.mails,self.report.mails,self.send.mails}
	for k,v in pairs(emailData[type]) do
		if v.gift >= 1 and v.isReward ~= 1 then
			v.isReward = 1
			v.isRead = 1
			self:setHasUnread(type)
		end
	end
end

function emailVoApi:canSendEmail(layerNum)
	-- 检测玩家是否被禁言 true没有 false被禁言,
	if (G_forbidType==1 or G_forbidType==3) and G_isNotice==1 then
		if G_forbidEndTime and G_forbidEndTime>0 then
			local forbidStr=getlocal("forbid_chat_pro",{getlocal("mainMail")})
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),forbidStr,30)
			-- if layerNum then
			-- 	-- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),leftTimeStr,nil,layerNum+1)
			-- 	local tabStr={" ",leftTimeStr," "}
			-- 	local tabColor={nil,G_ColorWhite,nil}
			-- 	local td=smallDialog:new()
			-- 	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,tabStr,25,tabColor)
			-- 	sceneGame:addChild(dialog,layerNum+1)
			-- end
			return false
		end
	end
	return true
end

--titleStr：邮件标题，receiver：收件人，theme：邮件主题，isCheck：是否是查看邮件，headlinesData：头条数据
function emailVoApi:showWriteEmailDialog(layerNum,titleStr,receiver,theme,isAllianceEmail,isCheck,headlinesData,receiverUid)
    if isCheck==nil then
        isCheck=false
    end
    if isAllianceEmail==nil then
        isAllianceEmail=false
    end
    if isCheck==false and self:canSendEmail(layerNum)==false then
        do return end
    end
    require "luascript/script/game/scene/gamedialog/emailDetailDialog"
    local td=emailDetailDialog:new(layerNum,nil,nil,receiver,theme,nil,nil,isAllianceEmail,headlinesData,receiverUid)
    local nc={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,titleStr,false,layerNum)
    sceneGame:addChild(dialog,layerNum)
end