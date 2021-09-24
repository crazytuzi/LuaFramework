allianceHelpVoApi={
	allHelpList={},
	myHelpList={},
	eventList={},
	initFlag=-1,
	flagTb={-1,-1,-1},
	hasMore=false,
	helpData=nil,
	expiredTime=0,
}

function allianceHelpVoApi:clear()
	self:clearList(1)
	self:clearList(2)
	self:clearList(3)
	self.initFlag=-1
	self.flagTb={-1,-1,-1}
	self.hasMore=false
	self.helpData=nil
	self.expiredTime=0
end

function allianceHelpVoApi:clearList(type)
	if type==1 then
		if self.allHelpList then
			for k,v in pairs(self.allHelpList) do
				self.allHelpList[k]=nil
			end
		end
		self.allHelpList={}
	elseif type==2 then
		if self.myHelpList then
			for k,v in pairs(self.myHelpList) do
				self.myHelpList[k]=nil
			end
		end
		self.myHelpList={}
	elseif type==3 then
		if self.eventList then
			for k,v in pairs(self.eventList) do
				self.eventList[k]=nil
			end
		end
		self.eventList={}
	end
end

function allianceHelpVoApi:formatData(type,callback,isPage)
 -- 	data.list={
 -- 		{uid=5000014,mc=50,type="techs",updated_at=1450005916,info={n="name1",tid="t1",bType="1",sid=1,lvl=1,pic=1}},
 -- 		{uid=5000014,mc=50,type="techs",updated_at=1450005926,info={n="name2",tid="t1",bType="1",sid=2,lvl=2,pic=1}},
 -- 		{uid=5000014,mc=50,type="techs",updated_at=1450005936,info={n="name3",tid="t1",bType="1",sid=3,lvl=3,pic=1}},
 -- 		{uid=5000014,mc=50,type="techs",updated_at=1450005946,info={n="name4",tid="t1",bType="1",sid=4,lvl=4,pic=1}},
 -- 		{uid=5000014,mc=50,type="techs",updated_at=1450005956,info={n="name5",tid="t1",bType="1",sid=5,lvl=5,pic=1}},
 -- 		{uid=5000014,mc=50,type="techs",updated_at=1450005966,info={n="name6",tid="t1",bType="1",sid=6,lvl=6,pic=1}},
	-- }
	if type==1 then
		local function helplistCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if isPage==true then
				else
					self:clearList(type)
				end
				if sData.data and sData.data.helplist then
					local list=sData.data.helplist
					for k,v in pairs(list) do
						local id=tonumber(v.id)
						local uid=tonumber(v.uid) or 0
						local num=tonumber(v.cc) or 0
						local maxNum=tonumber(v.mc) or 0
						local hType=v.type
						local time=tonumber(v.updated_at) or 0
						local info=v.info
						if info and maxNum>0 and num<maxNum then
							local sid=info.sid
							local tid=info.tid
							local bType=info.tid
							local name=info.n or ""
							local level=tonumber(info.lvl) or 0
							local pic=info.pic or 1
							local vo = allianceHelpVo:new()
					        vo:initWithData(id,uid,name,tid,bType,level,pic,num,maxNum,hType,time)
					        table.insert(self.allHelpList,vo)
						end
			        end
			        local function sortAsc(a, b)
			        	return a.id>b.id
			        end
			        table.sort(self.allHelpList,sortAsc)
			        if sData.data and sData.data.next==1 then
						self:setHasMore(true)
					else
						self:setHasMore(false)
					end
				end
				if isPage==true then
				else
					self:setFlag(type,1)
				end
				if callback then
					callback()
				end
			end
		end
	    local maxid,minid=0,0
	    if isPage==true then
	    	maxid,minid=self:getMinAndMaxId()
	    end
	    socketHelper:allianceHelplist(maxid,minid,helplistCallback)
		-- self:clearList(type)
		-- local list={}
		-- for i=1,300 do
		-- 	local vo = allianceHelpVo:new()
	 --        vo:initWithData(i,0,"name"..i,1,1,10,1,0,5,"techs",0)
	 --        table.insert(self.allHelpList,vo)
		-- end
		-- if callback then
		-- 	callback()
		-- end
	elseif type==2 then
		local function MyHelpCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				self:clearList(type)
				if sData.data and sData.data.mylist then
					local list=sData.data.mylist
					for k,v in pairs(list) do
						local id=tonumber(v.id)
						local uid=tonumber(v.uid) or 0
						local num=tonumber(v.cc) or 0
						local maxNum=tonumber(v.mc) or 0
						local hType=v.type
						local time=tonumber(v.updated_at) or 0
						local info=v.info
						if info then
							local sid=info.sid
							local tid=info.tid
							local bType=info.tid
							local name=info.n or ""
							local level=tonumber(info.lvl) or 0
							local pic=info.pic or 1
							local vo = allianceHelpVo:new()
					        vo:initWithData(id,uid,name,tid,bType,level,pic,num,maxNum,hType,time)
					        table.insert(self.myHelpList,vo)
						end
			        end
				end
				self:setFlag(type,1)
				if callback then
					callback()
				end
			end
		end
		local listType=1
		socketHelper:allianceMyhelp(listType,MyHelpCallback)
	elseif type==3 then
		-- local list={
		-- 	{id=1,n="name1",tid=1,type="techs",lvl=31,updated_at=1433832216},
		-- 	{id=2,n="name2",tid=1,type="techs",lvl=32,updated_at=1433832226},
		-- 	{id=3,n="name3",tid=1,type="techs",lvl=33,updated_at=1433832236},
		-- 	{id=4,n="name4",tid=1,type="techs",lvl=34,updated_at=1433832246},
		-- 	{id=5,n="name5",tid=1,type="techs",lvl=35,updated_at=1433832256},
		-- 	{id=6,n="name6",tid=1,type="techs",lvl=36,updated_at=1433832266},
		-- 	{id=7,n="name7",tid=1,type="techs",lvl=37,updated_at=1433832276},
		-- }
		local function eventCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				self:clearList(type)
				if sData.data and sData.data.myhelplog then
					local list=sData.data.myhelplog
					for k,v in pairs(list) do
						if v then
							local id=tonumber(v.id)
							local uid=tonumber(v.uid)
							local time=tonumber(v.updated_at) or 0
							local info=v.info
							if info then
								local name=info.n or ""
								local level=tonumber(info.lvl) or 0
								local tid=info.tid
								local hType=info.type
								local targetName=""
								if hType=="techs" then
									if tid then
										tid=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
										if techCfg[tid] and techCfg[tid].name then
											targetName=getlocal(techCfg[tid].name)
										end
									end
								else
									local bType=tid
									if bType then
										bType=(tonumber(bType) or tonumber(RemoveFirstChar(bType)))
										if buildingCfg[bType] and buildingCfg[bType].buildName then
											targetName=getlocal(buildingCfg[bType].buildName)
										end
									end
								end
								local message=getlocal("alliance_help_record",{name,targetName,level})
								local color=G_ColorWhite
								local vo = allianceHelpEventVo:new()
								vo:initWithData(type,time,message,color)
						        table.insert(self.eventList,vo)
						    end
					    end
			        end
			    end
		        local function sortAsc(a, b)
		        	return a.time>b.time
		        end
		        table.sort(self.eventList,sortAsc)
		        self:setFlag(type,1)
		        if callback then
					callback()
				end
		    end
		end
	    local listType=2
		socketHelper:allianceMyhelp(listType,eventCallback)
	end
end

function allianceHelpVoApi:getList(type)
	if type==1 then
		return self.allHelpList
	elseif type==2 then
		return self.myHelpList
	elseif type==3 then
		return self.eventList
	end
	return {}
end

function allianceHelpVoApi:removeHelpData(type,id)
	if type==1 then
		if self.allHelpList then
			for k,v in pairs(self.allHelpList) do
				if v and v.id==id then
					table.remove(self.allHelpList,k)
				end
			end
		end
	elseif type==2 then
		if self.myHelpList then
			for k,v in pairs(self.myHelpList) do
				if v and v.id==id then
					table.remove(self.myHelpList,k)
				end
			end
		end
	elseif type==3 then
		if self.eventList then
			for k,v in pairs(self.eventList) do
				if v and v.id==id then
					table.remove(self.eventList,k)
				end
			end
		end
	end
end

function allianceHelpVoApi:addAllHelpData(newhelp)
	if newhelp and SizeOfTable(newhelp)>0 then
		local id=tonumber(newhelp.id)
		local uid=tonumber(newhelp.uid) or 0
		local num=tonumber(newhelp.cc) or 0
		local maxNum=tonumber(newhelp.mc) or 0
		local hType=newhelp.type
		local time=tonumber(newhelp.updated_at) or 0
		local info=newhelp.info
		if info and maxNum>0 and num<maxNum then
			local sid=info.sid
			local tid=info.tid
			local bType=info.tid
			local name=info.n or ""
			local level=tonumber(info.lvl) or 0
			local pic=info.pic or 1
			local vo = allianceHelpVo:new()
	        vo:initWithData(id,uid,name,tid,bType,level,pic,num,maxNum,hType,time)
	        table.insert(self.allHelpList,vo)
		end
		local function sortAsc(a, b)
	    	return a.id>b.id
	    end
	    table.sort(self.allHelpList,sortAsc)
	end
end

function allianceHelpVoApi:addHelpNum(id)
	if self.allHelpList then
		for k,v in pairs(self.allHelpList) do
			if id and v.id==id then
				self.allHelpList[k].num=self.allHelpList[k].num+1
			end
		end
		for k,v in pairs(self.allHelpList) do
			if v and v.num>=v.maxNum then
				table.remove(self.allHelpList,k)
			end
		end
	end
end

function allianceHelpVoApi:getMinAndMaxId()
	local maxid,minid=0,0
	local list=self:getList(1)
	if list and SizeOfTable(list)>0 then
		local num=SizeOfTable(list)
		maxid,minid=list[1].id,list[num].id
	end
	return maxid,minid
end

function allianceHelpVoApi:getInitFlag()
	return self.initFlag
end
function allianceHelpVoApi:setInitFlag(initFlag)
	self.initFlag=initFlag
end

function allianceHelpVoApi:getFlag(type)
	return self.flagTb[type]
end
function allianceHelpVoApi:setFlag(type,flag)
	if type and flag then
		self.flagTb[type]=flag
	end
end

function allianceHelpVoApi:getHasMore()
	return self.hasMore
end
function allianceHelpVoApi:setHasMore(hasMore)
	self.hasMore=hasMore
end

function allianceHelpVoApi:getHelpData()
	return self.helpData
end
function allianceHelpVoApi:addHelpData(helpData)
	if self.helpData==nil then
		self.helpData={}
	end
	table.insert(self.helpData,helpData)
end
function allianceHelpVoApi:tick()
	if self.helpData and (#self.helpData)>0 then
		self.expiredTime=self.expiredTime+1
		if self.expiredTime>5 then
			self.expiredTime=0
			local helpData=self.helpData
			local helpName=""
			local nameTab={}
			local delTab={}
			local newBuildsData={}
			local newtechs={}
			local hasBuildData=false
			for index,hData in pairs(helpData) do
				if hData.help and hData.help.n then
					local hName=hData.help.n
					local isHas=false
					for _,name in pairs(nameTab) do
						if name==hName then
							isHas=true
						end
					end
					if isHas==false then
		            	if helpName=="" then
		            		helpName=hName
		            	else
		            		helpName=helpName..","..hName
		            	end
		            	table.insert(nameTab,hName)
		            end
				end
				if hData.helpdel and hData.helpdel.del then
					local id=tonumber(hData.helpdel.del)
					local isHas=false
					for _,delid in pairs(delTab) do
						if delid==id then
							isHas=true
						end
					end
					if isHas==false then
		            	table.insert(delTab,id)
		            end
				end
				--更新建筑
				if hData.newbuildings then
	                for k,v in pairs(hData.newbuildings) do
	                    if k~="queue" and k~="auto" and k~="auto_expire" then
			            	local bid=tonumber(RemoveFirstChar(k))
			            	local oldLevel
			            	local build=buildingVoApi:getBuildiingVoByBId(bid)
			            	if build and build.level then
			            		oldLevel=build.level
			            	end
	                        local btype=v[1]
	                        local blevel=v[2]
	                        buildingVoApi:updateBuild(bid,btype,blevel)
	                        hasBuildData=true
	                        --判断是否协助升级，完成每日任务
	                        if oldLevel and blevel and oldLevel<blevel then
	                        	taskVoApi:setValueBySid(1002)
	                        end
	                    end
	                end
				end
				if hData.newtechs then
					--更新科技
	                local newtechs=hData.newtechs
	                if newtechs then
	                    local tmpTb={}
	                    for k,v in pairs(newtechs) do
	                        if k~="queue" then
	                            tmpTb[tonumber(RemoveFirstChar(k))]=tonumber(v)
	                        end
	                    end
	                    if SizeOfTable(tmpTb)>0 then
	                    	local allTech=G_clone(technologyVoApi:getAllTech())
	                    	if allTech and SizeOfTable(allTech)>0 then
		                    	for k,v in pairs(allTech) do
							        if v.level and tmpTb[v.id]~=nil and v.level<tmpTb[v.id] then
							            taskVoApi:setValueBySid(1003)
							        end
							    end
							end
	                        technologyVoApi:update(tmpTb)
	                    end
	                end
				end
			end
			if helpName~="" then
				local str=getlocal("alliance_help_helped_success",{helpName})
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30,nil,true)
				allianceHelpVoApi:setFlag(2,-1)
                allianceHelpVoApi:setFlag(3,-1)
			end
			if delTab and #delTab>0 then
				for _,id in pairs(delTab) do
                    allianceHelpVoApi:removeHelpData(1,id)
                    allianceHelpVoApi:removeHelpData(2,id)
				end
				allianceHelpVoApi:setFlag(1,0)
                allianceHelpVoApi:setFlag(2,0)
                local selfAlliance=allianceVoApi:getSelfAlliance()
                if selfAlliance and selfAlliance.aid then
                    local aid=selfAlliance.aid
                    local params={uid=playerVoApi:getUid(),idTab=delTab}
                    chatVoApi:sendUpdateMessage(30,params,aid+1)
                end
			end
			local newData=helpData[#helpData]
            --更新建筑队列
            if newData and newData.newbuildings~=nil then
                local newBuildsData=newData.newbuildings
                if newBuildsData.queue~=nil then 
                    local bSlot=newBuildsData.queue
                    buildingSlotVoApi:judgeAndShowSlot(bSlot)
                    buildingSlotVoApi:clear()
                    for k,v in pairs(bSlot) do
                        buildingSlotVoApi:add(tonumber(RemoveFirstChar(v.id)),v.st,v.et,v.hid,false)
                    end
                end 
            end
            if hasBuildData==true then
                buildingVoApi:unlockBuildingByCommanderCenterLevel()
            end
            --更新科技队列
            if newData and newData.newtechs~=nil then
                local newtechs=newData.newtechs
                if newtechs.queue~=nil then
                    local oldNum=0
                    local allSlots=technologySlotVoApi:getAllSlots()
                    if allSlots then
                        oldNum=SizeOfTable(allSlots)
                    end
                    technologySlotVoApi:clear()
                    local tSlot=newtechs.queue
                    for k,v in pairs(tSlot) do
                        technologySlotVoApi:add(tonumber(RemoveFirstChar(v.id)),v.st,v.et,v.timeConsume,v.slotid,v.hid)
                    end
                    technologyVoApi:resetStatus()
                    local newNum=0
                    local allSlots1=technologySlotVoApi:getAllSlots()
                    if allSlots1 then
                        newNum=SizeOfTable(allSlots1)
                    end
                    print("oldNum,newNum",oldNum,newNum)
                    if oldNum~=newNum then
                        technologySlotVoApi:setFlag(0)
                    end
                end
            end
            self.helpData=nil
        end
	end
end

function allianceHelpVoApi:getAllianceHelpRequest(isPage,callback)
	local function helplistCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if isPage==true then
			else
				self:clearList(type)
			end
			if sData.data and sData.data.helplist then
				local list=sData.data.helplist
				for k,v in pairs(list) do
					local id=tonumber(v.id)
					local uid=tonumber(v.uid) or 0
					local num=tonumber(v.cc) or 0
					local maxNum=tonumber(v.mc) or 0
					local hType=v.type
					local time=tonumber(v.updated_at) or 0
					local info=v.info
					if info and maxNum>0 and num<maxNum then
						local sid=info.sid
						local tid=info.tid
						local bType=info.tid
						local name=info.n or ""
						local level=tonumber(info.lvl) or 0
						local pic=info.pic or 1
						local vo = allianceHelpVo:new()
				        vo:initWithData(id,uid,name,tid,bType,level,pic,num,maxNum,hType,time)
				        table.insert(self.allHelpList,vo)
					end
		        end
		        local function sortAsc(a, b)
		        	return a.id>b.id
		        end
		        table.sort(self.allHelpList,sortAsc)
		        if sData.data and sData.data.next==1 then
					self:setHasMore(true)
				else
					self:setHasMore(false)
				end
			end
			if isPage==true then
			else
				self:setFlag(type,1)
			end
			if callback then
				callback()
			end
		end
	end
	local maxid,minid=0,0
	if isPage==true then
		maxid,minid=self:getMinAndMaxId()
	end
	local cmd="alliance.helplist"
	local params={maxid=maxid,minid=minid}
	local callback=helplistCallback

	return cmd,params,callback
end

function allianceHelpVoApi:helpAllOhterHandler(callback)
  	local list=self:getList(1)
    if list and SizeOfTable(list)>0 then
        local selfAlliance=allianceVoApi:getSelfAlliance()
        if selfAlliance and selfAlliance.aid then
            local aid=selfAlliance.aid
            local httpUrl="http://"..base.serverIp.."/tank-server/public/index.php/api/alliancehelp/help"
            local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid().."&aid="..aid
            G_sendAsynHttpRequestNoResponse(httpUrl.."?"..reqStr)

            self:clearList(1)
            self:setHasMore(false)
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_help_help_all_success"),30)
            local params={uid=playerVoApi:getUid()}
            chatVoApi:sendUpdateMessage(31,params,aid+1)
            if callback then
            	callback()
            end
        end
    end
end

--初始化军团帮助列表
function allianceHelpVoApi:formatAllHelpList(sData)
	self:clearList(1)
	local list=sData.data.helplist
	for k,v in pairs(list) do
		local id=tonumber(v.id)
		local uid=tonumber(v.uid) or 0
		local num=tonumber(v.cc) or 0
		local maxNum=tonumber(v.mc) or 0
		local hType=v.type
		local time=tonumber(v.updated_at) or 0
		local info=v.info
		if info and maxNum>0 and num<maxNum then
			local sid=info.sid
			local tid=info.tid
			local bType=info.tid
			local name=info.n or ""
			local level=tonumber(info.lvl) or 0
			local pic=info.pic or 1
			local vo = allianceHelpVo:new()
	        vo:initWithData(id,uid,name,tid,bType,level,pic,num,maxNum,hType,time)
	        table.insert(self.allHelpList,vo)
		end
    end
    local function sortAsc(a, b)
    	return a.id>b.id
    end
    table.sort(self.allHelpList,sortAsc)
end