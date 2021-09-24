

alienMinesEmailVoApi={
	report={},
	unreadNum=0,
	flag=-1,
	mailNum=0,
	isHas=false,
	maxNum=100,
	-- unreadData={},
	--refreshFlag={},
}

function alienMinesEmailVoApi:clear()
	-- if type==1 then
	--     for k,v in pairs(self.receive) do
	--         self.receive[k]=nil
	--     end
	-- 	self.receive={}
	-- elseif type==2 then
	    for k,v in pairs(self.report) do
	        self.report[k]=nil
	    end
		self.report={}
		self.flag=-1
		self.mailNum=0
		self.isHas=false
	-- elseif type==3 then
	--     for k,v in pairs(self.send) do
	--         self.send[k]=nil
	--     end
	-- 	self.send={}
	-- end
end

function alienMinesEmailVoApi:clearUnreadData()
-- 	if self.unreadData~=nil then
-- 		for k,v in pairs(self.unreadData) do
-- 			self.unreadData[k]=nil
-- 		end
-- 		self.unreadData=nil
-- 	end
-- 	self.unreadData={}
	self.unreadNum=0
end
function alienMinesEmailVoApi:clearEmails()
	self:clear()
	self:clearUnreadData()
end

function alienMinesEmailVoApi:formatData(data)
	for k,v in pairs(data) do
		if k=="alienreport" then
			local key="alienreport"
			local etype=4
			if self.flag==nil or self.flag==-1 then
				self:clear()
				-- if etype==2 then
				-- 	alienMinesReportVoApi:deleteAll()
				-- end
				self:setFlag(1)
			elseif self.flag~=0 then
				self:setFlag(0)
			end
			if v and v.maxrows then
				self.mailNum=tonumber(v.maxrows)
			end
			if self.mailNum==nil then
				self.mailNum=0
			end
			-- if self[key].mails==nil then
			-- 	self[key].mails={}
			-- end
			local mails
			if v and v.mails then
				mails=v.mails
			end
			if mails then
				for i,j in pairs(mails) do
					local eid=tonumber(j.eid)
					local email=self:getEmailByEid(eid)
					if email==nil or SizeOfTable(email)==0 then
				        local vo = alienMinesEmailVo:new()
						local sender=tonumber(j.sender) or 1
						local from=getlocal("scout_content_system_email")
						local title=j.title or ""
						-- if sender==0 then
						-- 	from=getlocal("scout_content_system_email")
						-- elseif from=="" or sender==1 then
						-- 	from=getlocal("scout_content_system_email")
						-- 	title=self:getAllianceEmailTitle(title)
						-- end
						local content=j.content or ""
						local isRead=tonumber(j.isRead) or 0
						local time=tonumber(j.ts)
						local to=tostring(j.to)
						local reportType=1
						-- if key=="report" then
							local titleData=j.title
							title,reportType=self:getAttackTitle(titleData,to)
							from=getlocal("scout_content_system_email")
							if type(content)=="table" then
								if content.type==2 then
									isRead=1
								end
								self:addReport(content,eid,time)
							end
						-- elseif key=="send" then
						-- 	isRead=1
						-- 	if to=="2" then
						-- 		to=getlocal("alliance_scene_all_member")
						-- 	end
						-- end
						-- local gift=tonumber(j.gift)
						-- local reward={}
						-- local flick={}
						-- if j.item and j.item.q then
						-- 	reward=j.item.q
						-- 	flick=j.item.f or {}
						-- end
						-- local isReward=tonumber(j.isreward)
				        vo:initWithData(eid,sender,from,to,title,content,time,isRead,reportType,j.attackData)
				        table.insert(self.report,vo)
					end
				end
				local function sortAsc(a, b)
					if a and b and a.time and b.time then
						if a.time==b.time then
							if a.reportType and b.reportType then
								return a.reportType > b.reportType
							end
						else
							return a.time > b.time
						end
					end
				end
				table.sort(self.report,sortAsc)
			end
			local totalNum=self:getTotalNum()
			local mailNum=self:getNum()
			self.isHas=true
			if mailNum>=totalNum then
				self.isHas=false
			end
			if SizeOfTable(self.report)>=100 or self.mailNum>100 then
				self.mailNum=100
				if SizeOfTable(self.report)>=100 then
					self.isHas=false
				end
			end
			while SizeOfTable(self.report)>100 do
				table.remove(self.report,101)
			end
		end
	end
end

function alienMinesEmailVoApi:getFlag()
	if self.flag then
		return self.flag
	else
		return -1
	end
end
function alienMinesEmailVoApi:setFlag(flag)
	self.flag=flag
end

function alienMinesEmailVoApi:getEmailsList()
	if self.report==nil then
		self.report={}
	end
	return self.report
end
function alienMinesEmailVoApi:getEmailByEid(eid)
	local emails=self:getEmailsList()
	for k,v in pairs(emails) do
        if tostring(eid)==tostring(v.eid) then
			return v
		end
	end
	return {}
end
function alienMinesEmailVoApi:getMinAndMaxEid()
	local mineid,maxeid=0,0
	local emails=self:getEmailsList()
	local num=self:getNum()
	if emails~=nil and SizeOfTable(emails)~=0 then
		mineid,maxeid=emails[num].eid,emails[1].eid
	end
	return mineid,maxeid
end

function alienMinesEmailVoApi:getTotalNum()
	local num=0
	if self.mailNum then
		num=tonumber(self.mailNum or 0)
	end
	return num
end
function alienMinesEmailVoApi:getNum()
	local emails=self:getEmailsList()
	local num=0
	if emails then
		num=SizeOfTable(emails)
	end
	return num
end

function alienMinesEmailVoApi:getNotReadNum()
	local num=0
	local emails=self:getEmailsList()
	for k,v in pairs(emails) do
        if v.isRead==0 then
			num=num+1
		end
	end
	return num
end


function alienMinesEmailVoApi:formatUnread(data)
	if data and data[tostring(4)] then
		local num=tonumber(data[tostring(4)])
		self:setHasUnread(num)
	end	
end
function alienMinesEmailVoApi:getHasUnread()
	return self.unreadNum
end
function alienMinesEmailVoApi:setHasUnread(num)
	if self.unreadNum then
		if num then
			self.unreadNum=num
		else
			self.unreadNum=self.unreadNum-1
			if self.unreadNum<0 then
				self.unreadNum=0
			end
		end
	end
end

function alienMinesEmailVoApi:getTimeStr(time)
    local date = G_getDataTimeStr(time)
	return date
end

-- --title 1.成功申请军团 2.申请被拒绝 3.加入军团 4.被踢出军团 5.团长已转让 6.军团职务变更 7.军团职务变更
-- function alienMinesEmailVoApi:getAllianceEmailTitle(title)
-- 	local titleStr=title
-- 	if title and title~="" then
--         local tData=Split(title,"=")
--         if tData then
--             local titleType=tData[1]
--             local parms={}
--             for k,v in pairs(tData) do
--                 if k>=2 then
--                     table.insert(parms,v)
--                 end
--             end
--             titleStr=getlocal("alliance_email_title"..titleType,parms)
--         elseif tonumber(title) then
--             local titleType=tonumber(title)
--             --if titleType>=1 and titleType<=4 then
--                 titleStr=getlocal("alliance_email_title"..title)
--             --end
--         end
-- 	end
-- 	return titleStr
-- end

-- content={type=1,aName="aName",cName="cName",role=0,1,2}
-- type 1.成功申请军团 2.申请被拒绝 3.加入军团 4.被踢出军团 5.团长已转让 6.军团职务变更 7.军团职务变更 9.军团战报名成功 10.军团战大获全胜 11.军团战不幸战败
-- aName:公会名称 
-- cName:团长名字
-- function alienMinesEmailVoApi:formatAllianceContent(content)
-- 	local contentStr=content
-- 	if content and type(content)=="table" then
-- 		local cType=tonumber(content.type)
-- 		if cType then
-- 			local paramData={}
-- 			if cType==1 or cType==2 or cType==3 then
-- 				paramData={content.aName}
-- 			elseif cType==4 then
--                 local roleStr=getlocal("alliance_role"..(content.role or 2))
--                 paramData={roleStr,content.cName,content.aName}
--             elseif cType==5 then
-- 				paramData={content.cName,content.aName}
-- 			elseif cType==6 or cType==7 then
-- 				local roleStr=getlocal("alliance_role"..(content.role or 0))
-- 				paramData={content.cName,roleStr}
--             elseif cType==8 then--7天不登陆弹劾
--                 local roleStr=getlocal("alliance_role"..(content.role or 0))
-- 				paramData={content.bName,content.cName,content.aName,roleStr}
-- 			elseif cType==9 then
-- 				local pos=content.pos or ""
-- 				local redname=content.redname or ""
-- 				local bluename=content.bluename or ""
-- 				local opents=content.opents or {}
-- 				local startTs=opents.st or 0
-- 				local endTs=opents.et or 0
-- 				local position=content.position or 1
-- 				local posStr=getlocal("allianceWar_cityName_"..position)

-- 				local timeStr=G_chatTime(startTs)
-- 				local allianceName=""
-- 				if pos and pos=="red" then
-- 					allianceName=bluename
-- 				else
-- 					allianceName=redname
-- 				end
-- 				paramData={timeStr,allianceName,posStr}
-- 			elseif cType==10 then
-- 				local endTs=content.et or 0
-- 				local time=G_getWeeTs(endTs)
-- 				--local timeTab = os.date("*t",time)
-- 				--local timeStr = getlocal("activity_equipSearch_data",{timeTab.month,timeTab.day})
--                 local timeStr = G_getDataTimeStr(time,false,true)
-- 				local posId=content.posId or 1
-- 				local posStr=getlocal("allianceWar_cityName_"..posId)
-- 				paramData={content.aName,timeStr,content.eName,posStr}
-- 			elseif cType==11 then
-- 				local endTs=content.et or 0
-- 				local time=G_getWeeTs(endTs)
-- 				--local timeTab = os.date("*t",time)
-- 				--local timeStr = getlocal("activity_equipSearch_data",{timeTab.month,timeTab.day})
--                 local timeStr = G_getDataTimeStr(time,false,true)
-- 				local posId=content.posId or 1
-- 				local posStr=getlocal("allianceWar_cityName_"..posId)
-- 				paramData={content.aName,timeStr,content.eName,posStr}
-- 			elseif cType==12 then
-- 				local reward=content.reward or {}
-- 				local rewardTab=FormatItem(reward,nil,true)
-- 				paramData={rewardTab[1].name}
-- 			elseif cType==13 then
-- 				local buildLevel=content.blevel or 0
-- 				local playerLevel=content.plevel or 0
-- 				local reward=content.reward or {}
-- 				local rewardTab=FormatItem(reward,nil,true)
-- 				paramData={buildLevel,playerLevel,rewardTab[1].name,rewardTab[2].name}
--             elseif cType==14 then
-- 				local name=content.nickname or ""
-- 				local posX=content.x or 0
-- 				local posY=content.y or 0
-- 				paramData={name,posX,posY}
-- 			elseif cType==15 then
-- 				local time=content.ts or 0
-- 				local timeStr=G_getDataTimeStr(time,true,true)
-- 				paramData={timeStr}
-- 			elseif cType==16 or cType==17 or cType==18 or cType==22 or cType==23 or cType==24  then
-- 				local name=content.name or ""
-- 				paramData={name}
-- 			elseif cType==19 or cType==21 then
-- 				local name=playerVoApi:getPlayerName()
-- 				local aName=content.aName or ""
-- 				paramData={name,aName}
-- 			elseif cType==20 then
-- 				local name=playerVoApi:getPlayerName()
-- 				local aName=content.aName or ""
-- 				local hName=content.hName or ""
-- 				paramData={name,aName,hName}
-- 			end
-- 			contentStr=getlocal("alliance_email_content"..cType,paramData)
-- 		end
-- 	end
-- 	return contentStr
-- end

--titleData 1-2-attackerName-defenderName attackerName判断自己是否是攻击者
function alienMinesEmailVoApi:getAttackTitle(titleData,mailReceiver)
	local titleStr=""
	local reportType,islandType
	if titleData~=nil then
		local tData=Split(titleData,"-")
		reportType,islandType=tonumber(tData[1]),tonumber(tData[2])
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
                -- target=G_getIslandName(islandType,defenderName)
                target=G_getAlienIslandName(islandType)
				titleStr=getlocal("fight_content_fight_title")..getlocal("email_figth_title1",{target})
			else
				target=attackerName
				titleStr=getlocal("fight_content_fight_title")..getlocal("email_figth_title2",{target})
			end
		elseif reportType==2 then
            -- target=G_getIslandName(islandType,defenderName)
            target=G_getAlienIslandName(islandType)
			titleStr=getlocal("scout_content_scout_title")..getlocal("email_scout_title",{target})
		elseif reportType==3 then
			target=G_getAlienIslandName(islandType)
			titleStr=getlocal("fight_content_return_title")..getlocal("alienMines_return_title",{target})
		end
	end
	return titleStr,reportType
end

function alienMinesEmailVoApi:setIsRead(eid)
	local emailsList=self:getEmailsList()
	for k,v in pairs(emailsList) do
	    if tostring(eid)==tostring(v.eid) then
			if v.isRead==0 then
				v.isRead=1
				self:setHasUnread()
			end
		end
	end
end
-- function alienMinesEmailVoApi:deleteByType(type)
-- 	if type==1 then
--         for k,v in pairs(self.receive.mails) do
-- 			--[[
-- 			if v.isRead==0 then
-- 				self:setHasUnread(type)
-- 			end
-- 			]]
--             self.receive.mails[k]=nil
--         end
--         self.receive.mails=nil
--         self.receive.mails={}
-- 		self.receive.mailNum=0
-- 		self.receive.isHas=false
-- 		self:setHasUnread(1,0)
-- 	elseif type==2 then
--         for k,v in pairs(self.report.mails) do
-- 			--[[
-- 			if v.isRead==0 then
-- 				self:setHasUnread(type)
-- 			end
-- 			]]
--             self.report.mails[k]=nil
--         end
--         self.report.mails=nil
-- 		self.report.mails={}
-- 		self.report.mailNum=0
-- 		self.report.isHas=false
--         alienMinesReportVoApi:deleteAll()
-- 		self:setHasUnread(2,0)
-- 	elseif type==3 then
--         for k,v in pairs(self.send.mails) do
-- 			--[[
-- 			if v.isRead==0 then
-- 				self:setHasUnread(type)
-- 			end
-- 			]]
--             self.send.mails[k]=nil
--         end
--         self.send.mails=nil
-- 		self.send.mails={}
-- 		self.send.mailNum=0
-- 		self.send.isHas=false
-- 		self:setHasUnread(3,0)
-- 	end
-- end

-- function alienMinesEmailVoApi:deleteByEid(type,eid)
-- 	local emailData={self.receive,self.report,self.send}
-- 	for k,v in pairs(emailData[type].mails) do
-- 	    if tostring(eid)==tostring(v.eid) then
-- 			--emailData[type][k]=nil
-- 			table.remove(emailData[type].mails,k)
-- 			emailData[type].mailNum=emailData[type].mailNum-1
-- 		end
-- 		--[[
-- 		local function sortAsc(a, b)
-- 			if a.time and b.time then
-- 				return a.time > b.time
-- 			end
-- 		end
-- 		table.sort(emailData[type].mails,sortAsc)
-- 		]]
-- 		--self:setRefreshFlag(type,0)
-- 		self:setFlag(0)
-- 	end
-- 	if type==2 then
-- 	    alienMinesReportVoApi:deleteReport(eid)
-- 	end
-- end

function alienMinesEmailVoApi:addEmail(data)
	if data==nil then
		do return end
	end
    if SizeOfTable(data)==0 then
        do return end
    end
	-- local emailData={self.receive,self.report,self.send}
	for k,v in pairs(data) do
		if v then
		    local vo = alienMinesEmailVo:new()
			local sender=tonumber(v.sender) or 1
			local from=v.from or getlocal("scout_content_system_email")
			local title=v.title or ""
			-- if sender==0 then
			-- 	from=getlocal("scout_content_system_email")
			-- elseif from=="" or sender==1 then
			-- 	from=getlocal("scout_content_system_email")
			-- 	title=self:getAllianceEmailTitle(title)
			-- end
			local content=v.content or ""
			local isRead=tonumber(v.isRead) or 0
			local eid=tonumber(v.eid)
			local time=tonumber(v.ts)
			local to=tostring(v.to)
			local reportType=1
			-- if mailType==2 then
				local titleData=v.title
				title,reportType=self:getAttackTitle(titleData,to)
				from=getlocal("scout_content_system_email")
				if type(content)=="table" then
					if content.type==2 then
						isRead=1
					end
					self:addReport(content,eid,time)
				end
			-- elseif mailType==3 then
			-- 	isRead=1
			-- 	if to=="2" then
			-- 		to=getlocal("alliance_scene_all_member")
			-- 	end
			-- end
			-- local gift=tonumber(v.gift)
			-- local reward={}
			-- local flick={}
			-- if v.item and v.item.q then
			-- 	reward=v.item.q
			-- 	flick=v.item.f or {}
			-- end
			-- local isReward=tonumber(v.isreward)
		    vo:initWithData(eid,sender,from,to,title,content,time,isRead,reportType,nil)
			if self.report==nil then
				self.report={}
			end
		    table.insert(self.report,vo)
			local function sortAsc(a, b)
				if a and b and a.time and b.time then
					if a.time==b.time then
						if a.reportType and b.reportType then
							return a.reportType > b.reportType
						end
					else
						return a.time > b.time
					end
				end
			end
			table.sort(self.report,sortAsc)
			if self.mailNum==nil then
				self.mailNum=0
			end
			self.mailNum=self.mailNum+1
		end
	end
	if (self.report and SizeOfTable(self.report)>100) or (self.mailNum and self.mailNum>100) then
		self.mailNum=100
		if (self.report and SizeOfTable(self.report)>100) then
			self.isHas=false
		end
	end
	while (self.report and SizeOfTable(self.report)>100) do
		table.remove(self.report,101)
	end
    if mailType==3 and (self:getFlag()==-1 or self:getFlag()==nil) then
    else
        self:setFlag(0)
    end
end

function alienMinesEmailVoApi:addReport(data,eid,time)
	--data={info={attacker,attackerName,attackerLevel,defenser,defenserName,defenserLevel,islandType,islandOwner,islandLevel,place={1,1},ts,credit,isVictory},...} 战斗数据
	local reportData
	--类型 1战斗 2侦查 3返航
	local reportType=tonumber(data.type)
	local battleData=data.info
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
	local alienPoint=0   --个人异星积分
	local aAlienPoint=-1  --军团异星积分

	local helpDefender=data.helpDefender
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

		if battleData.alienPoint then
			alienPoint=battleData.alienPoint
		end

		if battleData.aAlienPoint then
			aAlienPoint=battleData.aAlienPoint
		end
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
	local alienResType=""
	local rate=0
	if islandType then
		alienResType="r"..islandType
	end
	if alienMineCfg and alienMineCfg.collect and alienMineCfg.collect[islandType] and alienMineCfg.collect[islandType].rate then
		rate=alienMineCfg.collect[islandType].rate
	end
	--返回报告的采集钛矿和异星资源
	-- islandType
	local alienCollectRes={u={r4=0},r={}}  --采集的资源
	if alienResType and alienResType~="" then
		alienCollectRes.r[alienResType]=0
	end
	local resource=data.resource
	local resourceName={u={r4=0},r={r1=0,r2=0,r3=0}}
	local resourceTab=FormatItem(resourceName)
	if reportType==3 then
		resourceTab=FormatItem(alienCollectRes)
	end
	if resource then
		if reportType==1 then
			--战斗掠夺或被掠夺资源
			local resNum=0
			local battleRes=resource.battle
			if battleRes~=nil then
				for k,v in pairs(resourceName.u) do
					if battleRes[k]~=nil then
						resourceName.u[k]=battleRes[k]
						resNum=battleRes[k]
					end
				end
				resourceTab=FormatItem(resourceName)
				for k,v in pairs(resourceTab) do
					if v.type=="r" and alienResType==v.key then
						resourceTab[k].num=math.floor(resNum*rate)
					end
				end
			end
		elseif reportType==2 then
			--收集资源
			local resNum=0
			if islandOwner>0 then
				local collect={}
				local cRes=resource.collect
				if cRes~=nil then
					-- for k,v in pairs(cRes) do
					-- 	local name,pic=getItem(k,"u")
					-- 	table.insert(collect,{name=name,num=v,pic=pic})
					-- end
					for k,v in pairs(resourceName.u) do
						if cRes[k]~=nil then
							resourceName.u[k]=cRes[k]
							resNum=cRes[k]
						end
					end
				end
				-- resourceTab=collect
				resourceTab=FormatItem(resourceName)
				for k,v in pairs(resourceTab) do
					if v.type=="r" and alienResType==v.key then
						resourceTab[k].num=math.floor(resNum*rate)
					end
				end
			-- elseif islandType==6 then
			-- 	local cRes=resource.battle
			-- 	if cRes~=nil then
			-- 		for k,v in pairs(resourceName.u) do
			-- 			if cRes[k]~=nil then
			-- 				resourceName.u[k]=cRes[k]
			-- 			end
			-- 		end
			-- 		resourceTab=FormatItem(resourceName)
			-- 	end
			end
		elseif reportType==3 then
			local resNum=0
			local alienRes
			if resource.alienRes and resource.alienRes.u and resource.alienRes.u[1] then
				alienRes=resource.alienRes.u[1]
			end
			if alienRes~=nil then
				for k,v in pairs(alienCollectRes.u) do
					if alienRes[k]~=nil then
						alienCollectRes.u[k]=alienRes[k]
						resNum=alienRes[k]
					end
				end
			end
			resourceTab=FormatItem(alienCollectRes)
			for k,v in pairs(resourceTab) do
				if v.type=="r" and alienResType==v.key then
					resourceTab[k].num=math.floor(resNum*rate)
				end
			end
		end
	end

	local emblemID=data.equip
	local plane=data.plane

	if reportType==1 then
		reportData={rid=eid,type=reportType,islandType=islandType,attacker=attacker,defender=defender,place=place,level=level,time=time,islandOwner=islandOwner,isVictory=isVictory,award=awardTab,resource=resourceTab,lostShip=lostShip,credit=credit,helpDefender=helpStr,report=data.report,attackerPlace=attackerPlace,accessory=accessory,aLandform=aLandform,dLandform=dLandform,acaward=data.acaward,rp=rp,hero=hero,emblemID=emblemID,plane=plane,weapon=data.weapon,armor=data.armor,troops=data.troops,aitroops=data.ait,ri=data.ri,ap=data.ap}
	elseif reportType==2 then
		reportData={rid=eid,type=reportType,islandType=islandType,defender=defender,place=place,level=level,time=time,islandOwner=islandOwner,resource=resourceTab,defendShip=shipTab,helpDefender=helpStr,allianceName=defenderAllianceName,landform=landform,richLevel=richLevel,emblemID=emblemID,plane=plane,skin=data.skin}
	elseif reportType==3 then
		reportData={rid=eid,type=reportType,returnType=returnType,islandType=islandType,place=place,level=level,alienPoint=alienPoint,aAlienPoint=aAlienPoint,resource=resourceTab,time=time}
	end
	alienMinesReportVoApi:addReport(reportType,reportData,false)
end

function alienMinesEmailVoApi:addContent(data)
	local eid=tonumber(data.eid)
	local etype=tonumber(data.type)
	local email=self:getEmailByEid(eid)
	local sender = data.sender
	if email~=nil then
		local content=email.content
		local contentData=data.content
		if etype==4 then
			local report=alienMinesReportVoApi:getReport(eid)
			if report==nil then
				local time=tonumber(data.ts)
				self:addReport(contentData,eid,time)
			end
		-- else
		-- 	if content==nil or content=="" then
		-- 		local emailData={self.receive.mails,self.report.mails,self.send.mails}
		-- 		local emails=emailData[etype]
		-- 		for k,v in pairs(emails) do
		-- 	        if tostring(eid)==tostring(v.eid) then
		-- 	        	if etype==1 and tostring(sender)=="1" and type(contentData)=="table" then
		-- 	        		emailData[etype][k].content=self:formatAllianceContent(contentData)
		-- 	        	else
		-- 	        		emailData[etype][k].content=contentData
		-- 				end
		-- 			end
		-- 		end
		-- 	end
		end
	end
end

function alienMinesEmailVoApi:getReport(rid)
	local report=alienMinesReportVoApi:getReport(rid)
	if report then
		return report
	end
	return {}
end

function alienMinesEmailVoApi:hasMore()
	return self.isHas
end

function alienMinesEmailVoApi:isAttacker(report,playerId)
	local isAttacker=false
	if report~=nil and report.type==1 then
		if report.attacker~=nil then
			local uid = playerId or playerVoApi:getUid()
			if uid~=nil then
				if tonumber(uid)==tonumber(report.attacker.id) then
					isAttacker=true
				end
			end
		end
	end
	return isAttacker
end

function alienMinesEmailVoApi:isShowAccessory(report)
	if base.ifAccessoryOpen==1 and report and report.islandType and report.islandOwner and report.islandOwner>0 then
		return true
	end
	return false
end

function alienMinesEmailVoApi:isShowHero(report)
	if base.heroSwitch==1 then
		return true
	end
	return false
end

--是否在邮件面板显示军徽信息
function alienMinesEmailVoApi:isShowEmblem(report)
	if base.emblemSwitch==1 and report.emblemID and SizeOfTable(report.emblemID) == 2 and (report.emblemID[1] ~= 0 or report.emblemID[2] ~= 0) then
		return true
	end
	return false
end

function alienMinesEmailVoApi:setIsReward(eid)
	if eid then
		local emailsList=self:getEmailsList()
		for k,v in pairs(emailsList) do
		    if tostring(eid)==tostring(v.eid) then
				v.isReward=1
			end
		end
	end
end
