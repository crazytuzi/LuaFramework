allianceVoApi={
	allianceReqAndRankList={},	--无军团时，可加入军团
	allianceRankList={},		--有军团时，排行榜
	allianceGoodList={},		--无军团时，排行榜，包括已经申请饿军团
	allianceSearchList={},
	selfAlliance=nil,
	perPageNum=20,
	listMaxNum=100,
	reqAndRankListMaxNum=100,
	goodListMaxNum=50,
	page=1,
	searchPage=1,
	requestsList={},			--无军团时，申请列表
    lastGetListTime=0,
    sendEmailMaxNum=20,
    sendEmailNum=0,
    donateMaxNum=6,
    allianceMaxLevel=30,		--军团的最大等级，从后台传过来，如果后台没传的话默认是30，后面有get和set方法
    showListType=1,
    needFlag={0,0},
    
    lastActiveSt=0,
    unReadEventNum=0, --未读取的军团事件数量
    needRefreshFlag=false, --需要重新拉取军团数据的标识（暂用于玩家改名后）
    flagNewTips={{}, {}, {}} -- 军团旗帜红点记录 1-icon 2-底图 3-颜色
}
function allianceVoApi:clear()
	self:clearReqAndRankList()
	self:clearRankList()
	self:clearGoodList()
	self:clearSearchList()

	self:clearSelfAlliance()

	-- self.selfAlliance=nil
	self:clearRequestsList()
    self.lastGetListTime=0
    self.page=1
	self.searchPage=1
	self.sendEmailNum=0
	self.showListType=nil
	self.needFlag=nil
	allianceSkillVoApi:clear()
    allianceEventVoApi:clear()
    allianceFubenVoApi:clear()

    
    self.lastActiveSt=0
    self.unReadEventNum=0
    self.needRefreshFlag=false
    self.flagNewTips={{}, {}, {}}

    if allianceGiftVo and allianceGiftVo.clearGiftTb then
        allianceGiftVo:clearGiftTb()
    end
end
function allianceVoApi:clearReqAndRankList()
	for k,v in pairs(self.allianceReqAndRankList) do
		self.allianceReqAndRankList[k]=nil
	end
	self.allianceReqAndRankList={}
end
function allianceVoApi:clearRequestsList()
	for k,v in pairs(self.requestsList) do
		self.requestsList[k]=nil
	end
	self.requestsList={}
end
function allianceVoApi:clearSelfAlliance()
	if allianceGiftVo and allianceGiftVo.clearGiftTb then--清理军团礼包数据
		allianceGiftVo:clearGiftTb()
	end	
	if self.selfAlliance and allianceCityVoApi:hasCity()==true and base.allianceCitySwitch==1 then
		local dissolveFlag=false
		if tonumber(self.selfAlliance.role)==2 then --军团长的话就是解散军团
			dissolveFlag=true
		end
		local mapData=allianceCityVoApi:clearMyAllianceCity(dissolveFlag)
		self.selfAlliance=nil
		worldScene:refreshMapBase(mapData) --刷新军团城市地块数据
	end
    allianceCityVoApi:clear()
	self.selfAlliance=nil
end
function allianceVoApi:clearRankList()
	for k,v in pairs(self.allianceRankList) do
		self.allianceRankList[k]=nil
	end
	self.allianceRankList={}
end
function allianceVoApi:clearGoodList()
	for k,v in pairs(self.allianceGoodList) do
		self.allianceGoodList[k]=nil
	end
	self.allianceGoodList={}
end
function allianceVoApi:clearSearchList()
	for k,v in pairs(self.allianceSearchList) do
		self.allianceSearchList[k]=nil
	end
	self.allianceSearchList={}
	self.searchPage=1
end
--[[
function allianceVoApi:formatSelfAllianceData(data,dataUser)
    self.selfAlliance=nil;
    self.selfAlliance=allianceVo:new()
    self.selfAlliance:initWithData(tonumber(data.aid),data.name,tonumber(data.exp),tonumber(data.level),tonumber(data.num),tonumber(data.maxnum),tonumber(data.rank),tonumber(data.fight),data.desc,tonumber(data.type),data.commander,data.notice,tonumber(data.oid),data.oname,nil,tonumber(data.commander_id),tonumber(data.fight_limit),tonumber(data.level_limit),tonumber(dataUser.role),data.alliancewar)

    print("公会data.aid=",data.aid,"data.name=",data.name,"data.exp=",data.exp,"data.level=",data.level,"data.num=",data.num,"data.maxnum=",data.maxnum,"data.rank=",data.rank,"data.fight=",data.fight,"data.desc=",data.desc,"data.type=",data.type,"data.commander=",data.commander,"data.notice=",data.notice,"data.oid=",data.oid,"data.oname=",data.oname,"data.commander_id=",data.commander_id,"data.fight_limit=",data.fight_limit,"data.level_limit=",data.level_limit,"dataUser.role=",dataUser.role)

end
]]

function allianceVoApi:formatSelfAllianceData(data)
    if self.selfAlliance==nil then
        self.selfAlliance=allianceVo:new()
    end
    if data.aid~=nil then
        self.selfAlliance.aid=tonumber(tonumber(data.aid))
    end
    if data.name~=nil then
        self.selfAlliance.name=data.name
    end
    if data.level_point~=nil then
        self.selfAlliance.exp=tonumber(data.level_point)
    end
    if data.level~=nil then
        self.selfAlliance.level=tonumber(data.level)
    end
    if data.num~=nil then
        self.selfAlliance.num=tonumber(data.num)
    end
    if data.maxnum~=nil then
        self.selfAlliance.maxnum=tonumber(data.maxnum)
    end
    if data.rank~=nil then
        self.selfAlliance.rank=tonumber(data.rank)
    end
    if data.fight~=nil then
        self.selfAlliance.fight=tonumber(data.fight)
    end
    if data.desc~=nil then
        self.selfAlliance.desc=data.desc
    end
    if data.type~=nil then
        self.selfAlliance.type=tonumber(data.type)
    end
    if data.commander~=nil then
        self.selfAlliance.leaderName=data.commander
    end
    if data.notice~=nil then
        self.selfAlliance.notice=data.notice
    end
    if data.oid~=nil then
        self.selfAlliance.oid=tonumber(data.oid)
    end
    if data.oname~=nil then
        self.selfAlliance.oname=data.oname
    end
    if data.commander_id~=nil then
        self.selfAlliance.leaderId=data.commander_id
    end
    if data.fight_limit~=nil then
        self.selfAlliance.fight_limit=tonumber(data.fight_limit)
    end
    if data.level_limit~=nil then
        self.selfAlliance.level_limit=tonumber(data.level_limit)
    end
    if data.groupmsg_limit~=nil then
    	self.selfAlliance.groupmsg_limit=tonumber(data.groupmsg_limit)
    end
    if data.groupmsg_ts~=nil then
        self.selfAlliance.groupmsg_ts=tonumber(data.groupmsg_ts)
    end
    if data.point~=nil then
        self.selfAlliance.point=tonumber(data.point)
    end
    
    if data.ainfo ~= nil then
        self.selfAlliance.ainfo=data.ainfo
        if data.ainfo.a ~= nil then
            self.selfAlliance.ainfo.a=data.ainfo.a
        end
        if data.ainfo.r ~= nil then
            self.selfAlliance.ainfo.r=data.ainfo.r
        end
    end
    
    if data.apoint ~= nil then  --军团活跃度
        self.selfAlliance.apoint=tonumber(data.apoint)
    end
    
    if data.setname_at~=nil then
        self.selfAlliance.setname_at=tonumber(data.setname_at)
    end

    if data.apoint_at ~= nil then  --刷新军团活跃度的时间戳
        self.selfAlliance.apoint_at=tonumber(data.apoint_at)
    end
    if self.selfAlliance.apoint_at==nil then
        self.selfAlliance.apoint_at=0
    end
    if data.alevel ~= nil then  --军团活跃度
        self.selfAlliance.alevel=tonumber(data.alevel)
    end
    
    if data.apoint_at and G_isToday(data.apoint_at)==false and self.selfAlliance.ainfo then
       self.selfAlliance.ainfo={}
    end

    if data.banner ~= nil then  -- 军团旗帜
        self.selfAlliance.banner = data.banner
    end
    if data.banner_at ~= nil then  -- 军团旗帜设置上次时间
        self.selfAlliance.banner_at = data.banner_at
    end
    if data.unlockflag then --已获得的军团旗帜数据
    	self.selfAlliance.unlockflag = (type(data.unlockflag) ~= "userdata" and data.unlockflag ~= nil) and data.unlockflag or {}
    end
    if data.desc_at then --军团长修改军团宣言的时间
    	self.selfAlliance.desc_at = tonumber(data.desc_at or 0)
    end
end
function allianceVoApi:formatAllianceWrData(data)
    if self.selfAlliance~=nil and data~=nil then
        self.selfAlliance.alliancewar=data
    end
end
function allianceVoApi:setAllianceDonateMembers(data)
    if self.selfAlliance~=nil and data~=nil then
        self.selfAlliance.allianceDonateMembers=data
    end

end

function allianceVoApi:setAllianceAddDonateCount(data)
    if self.selfAlliance~=nil and data~=nil then
        self.selfAlliance.addDonateCount=data
    end
end




function allianceVoApi:setRole(dataUser)
    if self.selfAlliance==nil then
        self.selfAlliance=allianceVo:new()
    end
    if dataUser~=nil then
	    if dataUser.role~=nil then
	        self.selfAlliance.role=tonumber(dataUser.role)
	    end
	    if dataUser.todayraisingcount~=nil then
	    	local donateCount={}
	    	donateCount.gold=dataUser.todayraisingcount.gold or 0
	    	donateCount.r1=dataUser.todayraisingcount.r1 or 0
	    	donateCount.r2=dataUser.todayraisingcount.r2 or 0
	    	donateCount.r3=dataUser.todayraisingcount.r3 or 0
	    	donateCount.r4=dataUser.todayraisingcount.r4 or 0
	        self.selfAlliance.donateCount=donateCount
	    end
	    if dataUser.raising_at~=nil then
	        self.selfAlliance.lastDonateTime=tonumber(dataUser.raising_at) or 0
	    end
	    if dataUser.join_at~=nil then
	        self.selfAlliance.joinTime=tonumber(dataUser.join_at) or 0
	    end
        if dataUser.ar~=nil then
            self.selfAlliance.ar = dataUser.ar
        end
        if dataUser.ar_at~=nil then
            self.selfAlliance.ar_at = dataUser.ar_at
        end
	end
end

function allianceVoApi:getActiveReward()
    if self.selfAlliance then
        if self.selfAlliance.ar and self.selfAlliance.ar_at and G_isToday(self.selfAlliance.ar_at) and self.selfAlliance.ar.a then
            return self.selfAlliance.ar.a
        else
            return {}
        end
    end
end

function allianceVoApi:getActiveRewardTotal()
    if self.selfAlliance then
        if self.selfAlliance.ar and self.selfAlliance.ar_at and G_isToday(self.selfAlliance.ar_at) and self.selfAlliance.ar.r then
            return self.selfAlliance.ar.r
        else
            return {}
        end
    end
end
function allianceVoApi:refreshActiveReward(reward,rewardTime)
    if self.selfAlliance then
        self.selfAlliance.ar =reward
        self.selfAlliance.ar_at=rewardTime
    end
end
function allianceVoApi:formatData(data)
	if data then
		if self:isHasAlliance() then
			if data.ranklist and SizeOfTable(data.ranklist)>0 then
				self:clearRankList()
				local ranklistNum=0
				for k,v in pairs(data.ranklist) do
					local avo = allianceVo:new()
					local requests--=tonumber(v.rank)
					-- if v.requests and type(v.requests)=="table" then
					-- 	requests=v.requests
					-- end
					local fight_limit=0
					local level_limit=0
					if v.fight_limit then
						fight_limit=tonumber(v.fight_limit)
					end
					if v.level_limit then
						level_limit=tonumber(v.level_limit)
					end
					if ranklistNum<self:getListMaxNum() then
					    avo:initWithData(v,tonumber(v.aid),v.name,tonumber(v.exp),tonumber(v.level),tonumber(v.num),tonumber(v.maxnum),tonumber(v.rank),tonumber(v.fight),v.desc,tonumber(v.type),v.commander,v.notice,tonumber(v.oid),v.oname,requests,tonumber(v.commander_id),fight_limit,level_limit)
						table.insert(self.allianceRankList,avo)
						ranklistNum=ranklistNum+1
					end
				end
				local function sortRankAsc(a, b)
	            	return a.rank < b.rank
		        end
		        table.sort(self.allianceRankList,sortRankAsc)
		        self:setPage(1)
		        
		    end
		else
			-- if (data.ranklist and SizeOfTable(data.ranklist)>0) or (data.mylist and SizeOfTable(data.mylist)>0) then
			if (data.ranklist and SizeOfTable(data.ranklist)>0) then
				self:clearReqAndRankList()
	            self:clearRequestsList()
	            local listNum=0
				if data.mylist and SizeOfTable(data.mylist)>0 then
					local function sortRankAsc111(a, b)
						if a.rank and b.rank then
		            		return a.rank < b.rank
		            	end
			        end
		        	table.sort(data.mylist,sortRankAsc111)
					for k,v in pairs(data.mylist) do
						local avo3 = allianceVo:new()
						local requests--=tonumber(v.rank)
						-- if v.requests and type(v.requests)=="table" then
						-- 	requests=v.requests
						-- end
						local fight_limit=0
						local level_limit=0
						if v.fight_limit then
							fight_limit=tonumber(v.fight_limit)
						end
						if v.level_limit then
							level_limit=tonumber(v.level_limit)
						end
					    avo3:initWithData(v,tonumber(v.aid),v.name,tonumber(v.exp),tonumber(v.level),tonumber(v.num),tonumber(v.maxnum),tonumber(v.rank),tonumber(v.fight),v.desc,tonumber(v.type),v.commander,v.notice,tonumber(v.oid),v.oname,requests,tonumber(v.commander_id),fight_limit,level_limit)
						table.insert(self.allianceReqAndRankList,avo3)
	                    table.insert(self.requestsList,tonumber(v.aid))
	                    listNum=listNum+1
					end
					self.showListType=1
				end
				if data.ranklist and SizeOfTable(data.ranklist)>0 then
					local function sortRankAsc1(a, b)
						if a.rank and b.rank then
		            		return a.rank < b.rank
		            	end
			        end
		        	table.sort(data.ranklist,sortRankAsc1)
					for k,v in pairs(data.ranklist) do
						local avo1 = allianceVo:new()
						local requests--=tonumber(v.rank)
						-- if v.requests and type(v.requests)=="table" then
						-- 	requests=v.requests
						-- end
						local fight_limit=0
						local level_limit=0
						if v.fight_limit then
							fight_limit=tonumber(v.fight_limit)
						end
						if v.level_limit then
							level_limit=tonumber(v.level_limit)
						end
						local isExist=false
						if data.mylist and SizeOfTable(data.mylist)>0 then
							for m,n in pairs(data.mylist) do
								if tostring(v.aid)==tostring(n.aid) then
									isExist=true
								end
							end
						end
						if isExist==false and listNum<self:getReqAndRankListMaxNum() then
						    avo1:initWithData(v,tonumber(v.aid),v.name,tonumber(v.exp),tonumber(v.level),tonumber(v.num),tonumber(v.maxnum),tonumber(v.rank),tonumber(v.fight),v.desc,tonumber(v.type),v.commander,v.notice,tonumber(v.oid),v.oname,requests,tonumber(v.commander_id),fight_limit,level_limit)
							table.insert(self.allianceReqAndRankList,avo1)
							listNum=listNum+1
						end
					end
					self.showListType=1
				end
		        self:setPage(1)
		        
		    end
		end
	    -- if (data.list and SizeOfTable(data.list)>0) or (data.mylist and SizeOfTable(data.mylist)>0) then
	    if (data.list and SizeOfTable(data.list)>0) then
			self:clearGoodList()
            self:clearRequestsList()
            local listNum=0
			if data.mylist and SizeOfTable(data.mylist)>0 then
				local function sortRankAsc11(a, b)
					if a.rank and b.rank then
	            		return a.rank < b.rank
	            	end
		        end
	        	table.sort(data.mylist,sortRankAsc11)
				for k,v in pairs(data.mylist) do
					local avo3 = allianceVo:new()
					local requests=tonumber(v.rank)
					-- if v.requests and type(v.requests)=="table" then
					-- 	requests=v.requests
					-- end
					local fight_limit=0
					local level_limit=0
					if v.fight_limit then
						fight_limit=tonumber(v.fight_limit)
					end
					if v.level_limit then
						level_limit=tonumber(v.level_limit)
					end
				    avo3:initWithData(v,tonumber(v.aid),v.name,tonumber(v.exp),tonumber(v.level),tonumber(v.num),tonumber(v.maxnum),tonumber(v.rank),tonumber(v.fight),v.desc,tonumber(v.type),v.commander,v.notice,tonumber(v.oid),v.oname,requests,tonumber(v.commander_id),fight_limit,level_limit)
					table.insert(self.allianceGoodList,avo3)
                    table.insert(self.requestsList,tonumber(v.aid))
                    listNum=listNum+1
				end
				self.showListType=0
			end
			if data.list and SizeOfTable(data.list)>0 then
				local function sortRankAsc1(a, b)
					if a.rank and b.rank then
	            		return a.rank < b.rank
	            	end
		        end
	        	table.sort(data.list,sortRankAsc1)
				for k,v in pairs(data.list) do
					local avo1 = allianceVo:new()
					local requests--=tonumber(v.rank)
					-- if v.requests and type(v.requests)=="table" then
					-- 	requests=v.requests
					-- end
					local fight_limit=0
					local level_limit=0
					if v.fight_limit then
						fight_limit=tonumber(v.fight_limit)
					end
					if v.level_limit then
						level_limit=tonumber(v.level_limit)
					end
					local isExist=false
					if data.mylist and SizeOfTable(data.mylist)>0 then
						for m,n in pairs(data.mylist) do
							if tostring(v.aid)==tostring(n.aid) then
								isExist=true
							end
						end
					end
					if isExist==false and listNum<self:getGoodListMaxNum() then
					    avo1:initWithData(v,tonumber(v.aid),v.name,tonumber(v.exp),tonumber(v.level),tonumber(v.num),tonumber(v.maxnum),tonumber(v.rank),tonumber(v.fight),v.desc,tonumber(v.type),v.commander,v.notice,tonumber(v.oid),v.oname,requests,tonumber(v.commander_id),fight_limit,level_limit)
						table.insert(self.allianceGoodList,avo1)
						listNum=listNum+1
					end

				end
				self.showListType=0
			end
			-- local function sortRankAsc1(a, b)
			-- 	if a.requests and b.requests and a.requests==b.requests then
			-- 		return a.requests < b.requests
			-- 	else
   --          		return a.rank < b.rank
   --          	end
	  --       end
	  --       table.sort(self.allianceGoodList,sortRankAsc1)
	        self:setPage(1)
		end
		if data.searchlist and SizeOfTable(data.searchlist)>0 then
			self:clearSearchList()
			for k,v in pairs(data.searchlist) do
				local avo2 = allianceVo:new()
				local requests--=tonumber(v.rank)
				-- if v.requests and type(v.requests)=="table" then
				-- 	requests=v.requests
				-- end
				local fight_limit=0
				local level_limit=0
				if v.fight_limit then
					fight_limit=tonumber(v.fight_limit)
				end
				if v.level_limit then
					level_limit=tonumber(v.level_limit)
				end
			    avo2:initWithData(v,tonumber(v.aid),v.name,tonumber(v.exp),tonumber(v.level),tonumber(v.num),tonumber(v.maxnum),tonumber(v.rank),tonumber(v.fight),v.desc,tonumber(v.type),v.commander,v.notice,tonumber(v.oid),v.oname,requests,tonumber(v.commander_id),fight_limit,level_limit)
				table.insert(self.allianceSearchList,avo2)
			end
			local function sortRankAsc2(a, b)
            	return a.rank < b.rank
	        end
	        table.sort(self.allianceSearchList,sortRankAsc2)
	        self:setSearchPage(1)
		end
	end
end
--[[
function allianceVoApi:updateRequestsList(data)
	if data and type(data)=="table" then
		self.requestsList=data
	end
end
]]

function allianceVoApi:getNeedFlag(showType)
	if self.needFlag==nil or SizeOfTable(self.needFlag)==0 then
		self.needFlag={0,0}
	end
	if showType then
		return self.needFlag[showType+1]
	end
	return 0
end
function allianceVoApi:setNeedFlag(showType,needFlag)
	if self.needFlag==nil or SizeOfTable(self.needFlag)==0 then
		self.needFlag={0,0}
	end
	if showType then
		self.needFlag[showType+1]=needFlag
	else
		self.needFlag={needFlag,needFlag}
	end
end
function allianceVoApi:getNeedGetList(useCD)
    local needFlag=false
    local useCD = useCD or 60*10
    if base.serverTime-self.lastGetListTime > useCD then
        needFlag=true
    end
    return needFlag
end
function allianceVoApi:getLastListTime()
    return self.lastGetListTime
end
function allianceVoApi:setLastListTime(time)
    if time then
        self.lastGetListTime=time
    end
end

function allianceVoApi:getShowListType()
	return self.showListType
end
function allianceVoApi:setShowListType(showListType)
	self.showListType=showListType
end
function allianceVoApi:getPerPageNum()
	return self.perPageNum
end
function allianceVoApi:getListMaxNum()
	return self.listMaxNum
end
function allianceVoApi:getGoodListMaxNum()
	return self.goodListMaxNum
end
function allianceVoApi:getReqAndRankListMaxNum()
	return self.reqAndRankListMaxNum
end
function allianceVoApi:getPage()
	return self.page
end

function allianceVoApi:setSearchPage(page)
	if page then
		self.searchPage=page
	else
		self.searchPage=self.searchPage+1
	end
end
function allianceVoApi:setPage(page)
	if page then
		self.page=page
	else
		self.page=self.page+1
	end
end
function allianceVoApi:hasMore(showType)
	if showType==nil then
		showType=0
	end
	if showType==0 then		--排名和推荐列表
		local num=self:getRankOrGoodNum()
		--if num>(self.page*self.perPageNum) and num<self.listMaxNum then
		if num>(self.page*self.perPageNum) then
			return true
		end
		return false
	elseif showType==1 then	--搜索列表
		local num=self:getSearchNum()
		--if num>(self.searchPage*self.perPageNum) and num<self.listMaxNum then
		if num>(self.searchPage*self.perPageNum) then
			return true
		end
		return false
	end
end
function allianceVoApi:getShowList()
	local showList={}
	if self:hasMore(0) then
        local list=self:getRankOrGoodList()
		for k,v in pairs(list) do
			if k>(self.page*self.perPageNum) and k<=((self.page+1)*self.perPageNum) then
				table.insert(showList,{index=k,alliance=v})
			end
		end
		self:setPage()
	end
	return showList
end
function allianceVoApi:getShowSearchList()
	local showList={}
	if self:hasMore(1) then
		local list=allianceVoApi:getSearchList()
		for k,v in pairs(list) do
			if k>(self.searchPage*self.perPageNum) and k<=((self.searchPage+1)*self.perPageNum) then
				table.insert(showList,{index=k,alliance=v})
			end
		end
		self:setSearchPage()
	end
	return showList
end
function allianceVoApi:getShowNum()
	local listNum=self:getRankOrGoodNum()
	local showNum=listNum
	if listNum>(self.page*self.perPageNum) then
		showNum=(self.page*self.perPageNum)
	end
	return showNum
end
function allianceVoApi:getShowSearchNum()
	local searchlistNum=self:getSearchNum()
	local showNum=searchlistNum
	if searchlistNum>(self.searchPage*self.perPageNum) then
		showNum=(self.searchPage*self.perPageNum)
	end
	return showNum
end
--退出和加入军团时，清空排行和推荐列表，再打开面板重新拉数据
function allianceVoApi:clearRankAndGoodList()
	self:clearRankList()
	self:clearGoodList()
	self:clearReqAndRankList()
end
function allianceVoApi:getRankOrGoodNum()
	local list=self:getRankOrGoodList()
	if list then
		return SizeOfTable(list)
	end
	return 0
	--return SizeOfTable(self.allianceRankList)
end
--有军团返回排名，无军团返回推荐
function allianceVoApi:getRankOrGoodList()
	if self:isHasAlliance() then
		return self.allianceRankList
	else
		if self.showListType==0 then
			return self.allianceGoodList
		else
			return self.allianceReqAndRankList
		end
		
	end
end
function allianceVoApi:getReqAndRankNum()
	return SizeOfTable(self.allianceReqAndRankList)
end
function allianceVoApi:getReqAndRankList()
	return self.allianceReqAndRankList
end
function allianceVoApi:getRankNum()
	return SizeOfTable(self.allianceRankList)
end
function allianceVoApi:getRankList()
	return self.allianceRankList
end
function allianceVoApi:getGoodNum()
	return SizeOfTable(self.allianceGoodList)
end
function allianceVoApi:getGoodList()
	return self.allianceGoodList
end
function allianceVoApi:getSearchNum()
	return SizeOfTable(self.allianceSearchList)
end
function allianceVoApi:getSearchList()
	return self.allianceSearchList
end

function allianceVoApi:getRequestsNum()
	return SizeOfTable(self.requestsList)
end
function allianceVoApi:getRequestsList()
	return self.requestsList
end
--获取列表中自己军团信息
function allianceVoApi:getSelfAllianceByList()
	local selfAlliance=self:getSelfAlliance()
	if selfAlliance then
		local list=self:getRankList()
		if list then
			for k,v in pairs(list) do
				if tostring(v.aid)==tostring(selfAlliance.aid) then
					do return v end
				end
			end
		end
		return selfAlliance
	end
end
--自己军团信息
function allianceVoApi:getSelfAlliance()
	-- return self.selfAlliance
	local aid=playerVoApi:getPlayerAid()
	if self.selfAlliance~=nil then
		return self.selfAlliance
	else
		return nil
	end
end

function allianceVoApi:getAlianceByUid(uid)
	-- body
end

function allianceVoApi:getListMaxNum()
	return self.listMaxNum
end

--判断是否加入军团
function allianceVoApi:isHasAlliance()
	local aid=playerVoApi:getPlayerAid()
	local selfAlliance=self:getSelfAlliance()
    if selfAlliance~=nil then
	--if aid and tonumber(aid)>0 then
		return true
	else
		return false
	end
end
--判断是否在同一个军团
function allianceVoApi:isSameAlliance(allianceName)
	local selfAlliance=self:getSelfAlliance()
	if self:isHasAlliance() and allianceName and tostring(selfAlliance.name)==tostring(allianceName) then
		return true
	end
	return false
end
--[[
function allianceVoApi:getAllianceFromList(type,aid)
	if aid then
		local allianceList={}
		if type==1 then
			allianceList=allianceVoApi:getRankList()
		elseif type==2 then
			allianceList=allianceVoApi:getGoodList()
		elseif type==3 then
			allianceList=allianceVoApi:getSearchList()
		end

		for k,v in pairs(allianceList) do
			if v and tostring(v.aid)==tostring(aid) then
				return v
			end
		end
	end
	return nil
end
]]
--是否已经申请过的军团
function allianceVoApi:isHasApplyAlliance(alliance)
    if self:isHasAlliance() then
        do return false end
    end
	local requestsList=allianceVoApi:getRequestsList()
	if requestsList and SizeOfTable(requestsList)>0 then
        for k,v in pairs(requestsList) do
            if tostring(v)==tostring(alliance.aid) then
                return true
            end
        end
    end
	return false
end

--是否符合申请加入条件
function allianceVoApi:isCanApply(alliance)
	if alliance then
		if self:isCanApplyByFightLimit(alliance.fight_limit) and self:isCanApplyByLevelLimit(alliance.level_limit) then
			if alliance.num<alliance.maxnum then
				return true
			end
		end
	end
	return false
end
--是否符合申请加入的战力条件
function allianceVoApi:isCanApplyByFightLimit(fight_limit)
	if fight_limit and tonumber(fight_limit) then
		local selfPower=playerVoApi:getPlayerPower()
		if selfPower<tonumber(fight_limit) then
			return false
		end
	end
	return true
end
--是否符合申请加入的等级条件
function allianceVoApi:isCanApplyByLevelLimit(level_limit)
	if level_limit and tonumber(level_limit) then
		local selfLevel=playerVoApi:getPlayerLevel()
		if selfLevel<tonumber(level_limit) then
			return false
		end
	end
	return true
end


function allianceVoApi:requestsIsFull()
	if self.requestsList then
		if SizeOfTable(self.requestsList)>=5 then
			return true
		end
	end
	return false
end
--申请加入需要审批的军团，修改军团列表数据
function allianceVoApi:addApply(aid)
	--[[
	if self.allianceGoodList then
		for k,v in pairs(self.allianceGoodList) do
			if v and tostring(v.aid)==tostring(aid) then
				if self.allianceGoodList[k].requests==nil then
					self.allianceGoodList[k].requests={}
				end
				table.insert(self.allianceGoodList[k].requests,playerVoApi:getUid())
			end
		end
	end
	]]
	if aid then
		for k,v in pairs(self.requestsList) do
			if v and tostring(v)==tostring(aid) then
				do return end
			end
		end
		table.insert(self.requestsList,aid)
	end
end
--取消申请加入军团，修改军团列表数据
function allianceVoApi:removeApply(aid)
	--[[
	if self.allianceGoodList then
		for k,v in pairs(self.allianceGoodList) do
			if v and tostring(v.aid)==tostring(aid) and self.allianceGoodList[k].requests then
				for m,n in pairs(self.allianceGoodList[k].requests) do
					if tostring(n)==tostring(playerVoApi:getUid()) then
						self.allianceGoodList[k].requests[m]=nil
					end
				end
			end
		end
	end
	]]
	if aid then
		if self.requestsList and SizeOfTable(self.requestsList) then
			for k,v in pairs(self.requestsList) do
				if v and tostring(v)==tostring(aid) then
					self.requestsList[k]=nil
					do return end
				end
			end
		end
	else
		if self.requestsList==nil then
			self.requestsList={}
		end
	end
end
--修改自己的军团数据，和列表中自己的军团数据
function allianceVoApi:setSelfAlliance(valueTab)
	if self.selfAlliance and valueTab and self.selfAlliance.aid==valueTab.aid then
		for k,v in pairs(valueTab) do
			self.selfAlliance[k]=v
		end
	end
    if self.allianceRankList and SizeOfTable(self.allianceRankList)>0 then
    	for m,n in pairs(self.allianceRankList) do
    		if valueTab and valueTab.aid and n and tostring(n.aid)==tostring(valueTab.aid) then
    			for i,j in pairs(valueTab) do
					self.allianceRankList[m][i]=j
				end
    		end
		end
    end
end
--根据军团id修改军团列表数据
function allianceVoApi:setAllianceByAid(allianceInfo)
    if allianceInfo and SizeOfTable(allianceInfo)>0 then
    	for k,v in pairs(self.allianceRankList) do 
    		if tostring(v.aid)==tostring(allianceInfo.aid) then
    			for m,n in pairs(v) do
    				if allianceInfo[m] then
    					if self.allianceRankList[k] then
    						self.allianceRankList[k][m]=allianceInfo[m]
    					end
    				end
    			end
    		end
    	end
    	for k,v in pairs(self.allianceGoodList) do 
    		if v.aid==allianceInfo.aid then
    			for m,n in pairs(v) do
    				if allianceInfo[m] then
    					if self.allianceGoodList[k] then
    						self.allianceGoodList[k][m]=allianceInfo[m]
    					end
    				end
    			end
    		end
    	end
    	for k,v in pairs(self.allianceSearchList) do 
    		if v.aid==allianceInfo.aid then
    			for m,n in pairs(v) do
    				if allianceInfo[m] then
    					if self.allianceSearchList[k] then
    						self.allianceSearchList[k][m]=allianceInfo[m]
    					end
    				end
    			end
    		end
    	end
    	for k,v in pairs(self.allianceReqAndRankList) do
    		if tostring(v.aid)==tostring(allianceInfo.aid) then
    			for m,n in pairs(v) do
    				if allianceInfo[m] then
    					if self.allianceReqAndRankList[k] then
    						self.allianceReqAndRankList[k][m]=allianceInfo[m]
    					end
    				end
    			end
    		end
    	end
    end
end

function allianceVoApi:getSendEmailMaxNum()
	return self.sendEmailMaxNum
end
function allianceVoApi:getSendEmailNum()
	if self:isHasAlliance() then
		if G_isToday(self.selfAlliance.groupmsg_ts)==false then
			do return 0 end
		elseif self.selfAlliance.groupmsg_limit>self.sendEmailMaxNum then
			do return self.sendEmailMaxNum end
		end
		do return self.selfAlliance.groupmsg_limit end
	end
	do return 0 end
end
function allianceVoApi:setSendEmailNum(num)
	if self:isHasAlliance() then
		if G_isToday(self.selfAlliance.groupmsg_ts)==false then
            self.selfAlliance.groupmsg_limit=0
        end
		self.selfAlliance.groupmsg_ts=base.serverTime
        --print("num",num)
        --print("self.selfAlliance.groupmsg_limit",self.selfAlliance.groupmsg_limit)
		if num then
			self.selfAlliance.groupmsg_limit=num
		else--if self.selfAlliance.groupmsg_limit+1<=self.sendEmailMaxNum then
			self.selfAlliance.groupmsg_limit=self.selfAlliance.groupmsg_limit+1
		end
	end
end
function allianceVoApi:getLastSendEmailTime()
	if self.selfAlliance.groupmsg_ts then
		return self.selfAlliance.groupmsg_ts
	else
		return 0
	end
end
function allianceVoApi:setLastSendEmailTime(ts)
	if ts then
		self.selfAlliance.groupmsg_ts=ts
	end
end

--是否能发送军团邮件
function allianceVoApi:canSendAllianceEmail()
	if self:isHasAlliance() then
		local selfAlliance=self:getSelfAlliance()
        --print("G_isToday(selfAlliance.groupmsg_ts)",G_isToday(selfAlliance.groupmsg_ts))
		--print("selfAlliance.groupmsg_limit",selfAlliance.groupmsg_limit)
        --if selfAlliance and tostring(selfAlliance.role)=="2" and (G_isToday(selfAlliance.groupmsg_ts)==false or (G_isToday(selfAlliance.groupmsg_ts) and selfAlliance.groupmsg_limit<self.sendEmailMaxNum)) then
        if selfAlliance and (tostring(selfAlliance.role)=="2" or tostring(selfAlliance.role)=="1") and self:getSendEmailNum()<self.sendEmailMaxNum then
			return true
		end
	end
	return false
end

function allianceVoApi:getAllianceDonateRequire(sid)
    local donateRequireTb1={}
    local donateRequireTb2={}
    local donateRequireTb3={}
    local goldRes=self:getDonateCount("gold")
    local r1Res=self:getDonateCount("r1")
    local r2Res=self:getDonateCount("r2")
    local r3Res=self:getDonateCount("r3")
    local r4Res=self:getDonateCount("r4")
    local timesTb={goldRes,r1Res,r2Res,r3Res,r4Res}
    for k,v in pairs(timesTb) do
        --取出当前技能捐献第几次
        --取出下次捐献需要的资源
        local nextCount=v+1
        if nextCount>self:getDonateMaxNum() then
        	nextCount=self:getDonateMaxNum()
        end
        donateRequireTb1[k]=playerCfg["allianceDonateResources"][nextCount]
        donateRequireTb2[k]=playerCfg["allianceDonate"][nextCount][1]
        if sid==SizeOfTable(allianceSkillCfg) then
            donateRequireTb2[k]=0
        end
        donateRequireTb3[k]=playerCfg["allianceDonate"][nextCount][2]


    end

    return donateRequireTb1,donateRequireTb2,donateRequireTb3
    
end

function allianceVoApi:checkAllianceDonate(sid)
      local require,require2,require3=self:getAllianceDonateRequire(sid)
      local results={}
      local result=true
      local have={}
      if require[1]>playerVoApi:getGold() then
              results[1]=false
              result=false
              
      else
              results[1]=true
      end
      have[1]=playerVoApi:getGold()
      
      if tonumber(require[2])>playerVoApi:getR1() then
              results[2]=false
              result=false
      else
              results[2]=true
      end
      have[2]=playerVoApi:getR1()
      if tonumber(require[3])>playerVoApi:getR2() then
              results[3]=false
              result=false
      else
              results[3]=true
      end
      have[3]=playerVoApi:getR2()
      if tonumber(require[4])>playerVoApi:getR3() then
              results[4]=false
              result=false
      else
              results[4]=true
      end
      have[4]=playerVoApi:getR3()
      if tonumber(require[5])>playerVoApi:getR4() then
              results[5]=false
              result=false
      else
              results[5]=true
      end
      have[5]=playerVoApi:getR4()

      return result,results,have
end

function allianceVoApi:getLvAndExpAndPer()
    local lvCfg=playerCfg["allianceExp"]
    local percent=100;
    local allianceLv=0
    local curExp=0
    local curMaxExp=0
    if self.selfAlliance.level~=60 then
        allianceLv=self.selfAlliance.level
        curExp=self.selfAlliance.exp-tonumber(lvCfg[allianceLv])
        curMaxExp=tonumber(lvCfg[allianceLv+1])-tonumber(lvCfg[allianceLv])
        percent = math.floor(curExp*100/curMaxExp)
    end

    return allianceLv,curExp,curMaxExp,percent
end

function allianceVoApi:setAllianceExp(exp)
	if exp then
		self.selfAlliance.exp=exp
	end
end
function allianceVoApi:setAllianceLevel(level)
	if level then
		self.selfAlliance.level=level
        self.selfAlliance.maxnum=playerCfg.allianceMember[level]
	end
end

function allianceVoApi:getDonateCount(key)
	local donateCount=0
	if key and self.selfAlliance and self.selfAlliance.donateCount and self.selfAlliance.lastDonateTime then
		local lastTime=self.selfAlliance.lastDonateTime
		if lastTime==0 then
			donateCount=0
		else
			if G_isToday(lastTime)==false then
				donateCount=0
			else
				if key==1 then
					key="gold"
				elseif key==2 then
					key="r1"
				elseif key==3 then
					key="r2"
				elseif key==4 then
					key="r3"
				elseif key==5 then
					key="r4"
				end
				if self.selfAlliance.donateCount[key] then
					donateCount=tonumber(self.selfAlliance.donateCount[key]) or 0
				end
			end
		end
	end
    return donateCount
end
function allianceVoApi:setLastDonateTime(time)
    if time and self.selfAlliance then
        self.selfAlliance.lastDonateTime=time
    end
end
function allianceVoApi:setDonateCount(key)
    if key and self.selfAlliance and self.selfAlliance.donateCount then
    	if self.selfAlliance.donateCount[key]==nil or type(self.selfAlliance.donateCount[key])~="number" then
    		self.selfAlliance.donateCount[key]=0
    	end
    	for k,v in pairs(self.selfAlliance.donateCount) do
    		if tostring(k)==tostring(key) then
    			self.selfAlliance.donateCount[key]=tonumber(v)+1
    		end
    	end
    end
end
function allianceVoApi:donateRefreshData(time,key)
	local lastDonateTime=self.selfAlliance.lastDonateTime
	if G_isToday(lastDonateTime)==false then
		if key and self.selfAlliance and self.selfAlliance.donateCount then
			-- self.selfAlliance.donateCount[key]=0
			if self.selfAlliance.donateCount then
				for k,v in pairs(self.selfAlliance.donateCount) do
		    		self.selfAlliance.donateCount[k]=0
		    	end
		    end
		end
	end
	if time then
		self:setLastDonateTime(time)
	end
	self:setDonateCount(key)
end

function allianceVoApi:getDonateMaxNum()
	local maxNum=self.donateMaxNum
    -- 每日捐献次数上限+2
	local vipPrivilegeSwitch=base.vipPrivilegeSwitch
	if vipPrivilegeSwitch and vipPrivilegeSwitch.vdn==1 then
		local vipRelatedCfg=playerCfg.vipRelatedCfg
		if vipRelatedCfg and vipRelatedCfg.donateAddNum and vipRelatedCfg.donateAddNum[1] and vipRelatedCfg.donateAddNum[2] then
			local needVipLevel=vipRelatedCfg.donateAddNum[1]
			local addNum=vipRelatedCfg.donateAddNum[2]
			local vipLevel=playerVoApi:getVipLevel()
			if vipLevel>=needVipLevel then
				maxNum=maxNum+addNum
			end
		end
	end
    return maxNum
end

function allianceVoApi:apointRefreshData(key,data)
    if self.selfAlliance then
    
        if self.selfAlliance.ainfo and self.selfAlliance.ainfo.a and self.selfAlliance.ainfo.a[key] and self.selfAlliance.ainfo.a[key]>=allianceActiveCfg.allianceActive[key] then
                do return end
        end
        if self.selfAlliance.apoint ==nil then
            self.selfAlliance.apoint=0
        end
        if data then
        print(data.apoint,data.alevel,data.apoint_at,data.ainfo)
            if data.apoint then
                self.selfAlliance.apoint=tonumber(data.apoint)
            end
            if data.alevel then
                self.selfAlliance.alevel=tonumber(data.alevel)
            end
            if data.apoint_at then
                self.selfAlliance.apoint_at=tonumber(data.apoint_at)
            end
            if data.ainfo then
                self.selfAlliance.ainfo=data.ainfo
            end
        else

            self.selfAlliance.apoint=self.selfAlliance.apoint+allianceActiveCfg.allianceActivePoint[key]
            if self.selfAlliance.apoint>=allianceActiveCfg.ActiveMaxPoint then
                self.selfAlliance.apoint=allianceActiveCfg.ActiveMaxPoint
            end
            self.selfAlliance.apoint_at=base.serverTime
            
            if self.selfAlliance.ainfo == nil then
                self.selfAlliance.ainfo={}
            end
            if self.selfAlliance.ainfo.a == nil then
                self.selfAlliance.ainfo.a={}
            end
            if self.selfAlliance.ainfo.a[key] ==nil then
                self.selfAlliance.ainfo.a[key]=0
            end
            if self.selfAlliance.ainfo.a[key]< allianceActiveCfg.allianceActive[key] then
                self.selfAlliance.ainfo.a[key]=self.selfAlliance.ainfo.a[key]+1
            end
        end

        if self.selfAlliance.alevel<SizeOfTable(allianceActiveCfg.allianceALevelPoint) and self.selfAlliance.apoint>allianceActiveCfg.allianceALevelPoint[self.selfAlliance.alevel+1] then
            self.selfAlliance.alevel=self.selfAlliance.alevel+1
        end

        local uid=playerVoApi:getUid()
        
        local myApoint = allianceMemberVoApi:getApoint(uid)
        myApoint = myApoint+allianceActiveCfg.allianceActivePoint[key]
        allianceMemberVoApi:setApoint(uid,myApoint,base.serverTime)

        
        local params={}
        params[1]=uid
        params[2]=self.selfAlliance.apoint
        params[3]=self.selfAlliance.alevel
        params[4]=self.selfAlliance.apoint_at
        params[5]=self.selfAlliance.ainfo
        params[6]=myApoint
        
        chatVoApi:sendUpdateMessage(17,params,playerVoApi:getPlayerAid()+1)
    end
end

function allianceVoApi:setMaxLevel(lv)
	self.allianceMaxLevel=tonumber(lv)
end

function allianceVoApi:getMaxLevel()
    return self.allianceMaxLevel
end
function allianceVoApi:getMaxExp()
	local maxLevel=self:getMaxLevel()
	local maxExp=playerCfg.allianceExp[maxLevel+1]
    return maxExp
end

function allianceVoApi:isOverstep24Hours( )--所有玩家退团再进团24小时内无法进行任何捐献
	if self.selfAlliance and self.selfAlliance.oid and tonumber(self.selfAlliance.oid) == tonumber(playerVoApi:getUid()) then
		return true --玩家 是 团长的情况 直接返回true 表示可以捐献，无关24小时
	end

	local joinTime = self:getJoinTime()
	if joinTime + 86400 < base.serverTime then
		return true
	end
	return false
end

function allianceVoApi:getJoinTime()
	if self.selfAlliance then
		if self.selfAlliance.joinTime then
    		return tonumber(self.selfAlliance.joinTime) or 0
    	else
    		return 0
    	end
    end
    return 0
end
--[[
function allianceVoApi:setJoinTime(joinTime)
	if joinTime then
		if self.selfAlliance then
			self.selfAlliance.joinTime=tonumber(joinTime) or 0
	    else
	    	self.selfAlliance.joinTime=0
	    end
	end
end
]]
function allianceVoApi:isJoinFirstDay()
	do return false end
	local joinTime=self:getJoinTime()
	if G_isToday(joinTime)==true then
		return true
	else
		return false
	end
end
--是否在军团战获胜buff阶段
function allianceVoApi:isAllianceWarBuff()
    local result=false
    local num=0
    if self.selfAlliance~=nil and self.selfAlliance.alliancewar~=nil and self.selfAlliance.alliancewar.own_at~=nil then
        local wartime=tonumber(self.selfAlliance.alliancewar.own_at)
        if base.serverTime>wartime and base.serverTime<wartime+24*3600 then
           result=true
           num=self.selfAlliance.alliancewar.resaddition
        end
    end
    return result,num
end

--是否在军团战开战期间
function allianceVoApi:isInAllianceWar()
    local result=false
    if self.selfAlliance~=nil and self.selfAlliance.alliancewar~=nil and self.selfAlliance.alliancewar.opents~=nil and self.selfAlliance.alliancewar.opents.et~=nil then
        local stTime=tonumber(self.selfAlliance.alliancewar.opents.st)
        local etTime=tonumber(self.selfAlliance.alliancewar.opents.et)
        if base.serverTime>stTime-allianceWarCfg.prepareTime and base.serverTime<etTime then
            result=true
        end
    end
    return result
end
--是否可以捐献
function allianceVoApi:isCanDonate()
    local isCanDonate=false
    if self.selfAlliance.allianceDonateMembers~=nil then
        if SizeOfTable(self.selfAlliance.allianceDonateMembers)>=self.selfAlliance.maxnum+self.selfAlliance.addDonateCount then
            for k,v in pairs(self.selfAlliance.allianceDonateMembers) do
                if playerVoApi:getUid()== tonumber(v) then
                    isCanDonate=true
                    break
                end
            end
        else
            isCanDonate=true
        end
    end
    if self.selfAlliance.allianceDonateMembers==nil then
        isCanDonate=true
    end


    return isCanDonate
end
--是否可以参加军团战
function allianceVoApi:isCanAllianceWar()
    local isCan=true
    if tonumber(self.selfAlliance.joinTime)+60*60*24>base.serverTime then
        isCan=false
    end
    return isCan
end


function allianceVoApi:isRefreshActiveData()
    if self.selfAlliance.apoint_at and self.selfAlliance.apoint_at>0 and G_isToday(self.selfAlliance.apoint_at)==false then
        --[[self.selfAlliance.ainfo = {}
        self.selfAlliance.ar = {}
        
        self.selfAlliance.ar_at=G_getWeeTs(base.serverTime)
        local function callback(fn,data)
        
        end--]]
        G_getAlliance()
		return true
	end
	return false

end

function allianceVoApi:setLastActiveSt()
    self.lastActiveSt = base.serverTime
end

function allianceVoApi:getRecommendNum()
end
function allianceVoApi:getNewSearchList()
	local recommendSearchList={}
	local playerLevel=playerVoApi:getPlayerLevel()
	local playerPower=playerVoApi:getPlayerPower()
	if self.allianceSearchList then
		for k,v in pairs(self.allianceSearchList) do
			-- if tonumber(v.num)<tonumber(v.maxnum) and playerLevel>=tonumber(v.level_limit or 0) and playerPower>=tonumber(v.fight_limit or 0) then
				table.insert(recommendSearchList,v)
			-- end
		end
	end
	local function sortFunc(a,b)
		if a.maxnum>b.maxnum then
			return true
		else
			if a.fight>b.fight and a.maxnum==b.maxnum then
				return true
			end
			return false
		end
	end
	table.sort(recommendSearchList,sortFunc)
	
	return recommendSearchList
end

function allianceVoApi:getNewRankOrGoodList()
	local allianceReqAndRankList=self:getRankOrGoodList()
	local playerLevel=playerVoApi:getPlayerLevel()
	local playerPower=playerVoApi:getPlayerPower()
	local recommendRankList={}
	for k,v in pairs(allianceReqAndRankList) do
		-- print("+++++",v.name,v.num,v.maxnum,playerLevel,v.level_limit,playerPower,v.fight_limit)
		if tonumber(v.num or 0)<tonumber(v.maxnum or 0) and playerLevel>=tonumber(v.level_limit or 0) and playerPower>=tonumber(v.fight_limit or 0) then
			table.insert(recommendRankList,v)
		end
	end
	local function sortFunc(a,b)
		if a.maxnum>b.maxnum then
			return true
		else
			if a.fight>b.fight and a.maxnum==b.maxnum then
				return true
			end
			return false
		end
	end
	
	table.sort(recommendRankList,sortFunc)
	return recommendRankList
end

function allianceVoApi:getActiveRewardRequest()
    local function resourceCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData.data.ainfo then
                local updateData={ainfo=sData.data.ainfo}
                self:formatSelfAllianceData(updateData)
                self:setLastActiveSt()
                local alliance=self:getSelfAlliance()
                if G_isToday(alliance.apoint_at or 0)==false then
                    local updateData={ainfo={}}
                    self:formatSelfAllianceData(updateData)
                end
            end
        end
    end
    local cmd="alliance.getresource"
    local params={}
    local callback=resourceCallback
    return cmd,params,callback
end

function allianceVoApi:getUnReadEventNum()
	return self.unReadEventNum
end

function allianceVoApi:setUnReadEventNum(num)
	self.unReadEventNum=num
end

function allianceVoApi:showAllianceDialog(layerNum,nameKey,tabType)

    if allianceVoApi:isHasAlliance()==false then
    	local buildVo=buildingVoApi:getBuildiingVoByBId(7)
    	if buildVo==nil then
    		do return end
    	end
    	if buildVo.status==-1 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("port_scene_building_tip_6"),28)
        	do return end
    	end
        require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
        if not tabType then
        	tabType = 1
        end
        local td=allianceDialog:new(tabType,layerNum)
        G_AllianceDialogTb[1]=td
        local tbArr={getlocal("recommendList"),getlocal("alliance_list_scene_create")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,layerNum)
        sceneGame:addChild(dialog,layerNum)

    else
        allianceEventVoApi:clear()
        -- require "luascript/script/game/scene/gamedialog/allianceDialog/allianceExistDialog"
        -- local td=allianceExistDialog:new(1,3)
        -- G_AllianceDialogTb[1]=td
        -- local tbArr={getlocal("alliance_info_title"),getlocal("alliance_function"),getlocal("alliance_list_scene_list")}
        -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,layerNum)
        -- sceneGame:addChild(dialog,3)
	    local function realShow()
            require "luascript/script/game/scene/gamedialog/newAlliance/newAllianceDialog"
            local titleStr = getlocal("alliance_list_scene_name")
		    local sd = newAllianceDialog:new()
	        G_AllianceDialogTb[1]=sd
		    local dialog = sd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,titleStr,true,self.layerNum);
		    sceneGame:addChild(dialog,layerNum)
            allianceVoApi:setNeedRefreshFlag(false)
            if nameKey then
            	G_goAllianceFunctionDialog(nameKey,layerNum+1)
            end
        end
        if allianceVoApi:isNeedRefreshFlag()==true then
            base.allianceTime=nil
            G_getAlliance(realShow) --重新拉取一下军团数据
        else
            realShow()
        end
    end
end

function allianceVoApi:showAllianceMemeberDialog(layerNum,tabType,subTabType)
	-- 成员
	require "luascript/script/game/scene/gamedialog/newAlliance/newAllianceMemberDialog"
	require "luascript/script/game/scene/gamedialog/newAlliance/newAllianceMemberInfoDialog"
	require "luascript/script/game/scene/gamedialog/newAlliance/newAllianceMemberRankDialog"
	
	local function getListHandler(fn,data)
        if base:checkServerData(data)==true then
            allianceVoApi:setLastListTime(base.serverTime)
        end
    end
    if allianceVoApi:getNeedGetList() or allianceVoApi:getRankOrGoodNum()==0 then
        socketHelper:allianceList(getListHandler,1)
    end
	local titleStr = getlocal("newAllianceBtn4")
    local sd = newAllianceMemberDialog:new(tabType,subTabType)
	local tabTb = {getlocal("newAllianceInfo"), getlocal("alliance_list_scene_list")}
    local dialog = sd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,titleStr,true,layerNum+1);
    sceneGame:addChild(dialog,layerNum+1)
end

function allianceVoApi:getCanReward()
	local canReward={}
	local alliance=self:getSelfAlliance()
	local hadRewardTotal=self:getActiveRewardTotal()
	if alliance.alevel and allianceActiveCfg.allianceActiveReward[alliance.alevel]>0 then
		if alliance.ainfo.r then
			for k,v in pairs(alliance.ainfo.r) do
				if k and v then
					local hadRewardR=0
					if hadRewardTotal[k] then
						hadRewardR=hadRewardTotal[k]
					end
					if v>hadRewardR then
						canReward[k]=math.ceil((v-hadRewardR)*allianceActiveCfg.allianceActiveReward[alliance.alevel])
					end
				end
			end
		end
	end
	return canReward
end

function allianceVoApi:getAllActiveRewards(callback)
  	local alliance=allianceVoApi:getSelfAlliance()
	local function rewardCallback(fn,data)
    	local ret,sData=base:checkServerData(data)
      	if ret==true then
        	if sData.data.res and type(sData.data.res) and SizeOfTable(sData.data.res)>0 then
				local ar={}
				local hadRewardTotal=self:getActiveRewardTotal()
				local hadReward=self:getActiveReward()
				local tipStr=getlocal("daily_lotto_tip_10")
				local i=1
				for k,v in pairs(sData.data.res) do
					playerVoApi:setValue(k,playerVo[k]+tonumber(v))
					if hadReward[k] then
						hadReward[k]=hadReward[k]+v
					else
					hadReward[k]=v
				end
				hadRewardTotal[k]=alliance.ainfo.r[k]
				local name=getItem(tostring(k),"u")
				if i==SizeOfTable(sData.data.res) then
					tipStr=tipStr..name.." x"..v
				else
					tipStr=tipStr..name.." x"..v..","
				end
				i=i+1
			end
          	ar.a=hadReward
          	ar.r=hadRewardTotal
          	self:refreshActiveReward(ar,base.serverTime)
          	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,28)
          	if callback then
          		callback()
          	end
        end    
      end
    end
    if G_isToday(self:getJoinTime())==true then
     	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_activie_joinToday"),28)
    else
      	if alliance.ainfo and alliance.ainfo.r and SizeOfTable(alliance.ainfo.r)>0 then
        	socketHelper:allianceActiveReward(alliance.ainfo.r,rewardCallback)
      	end
    end
end

function allianceVoApi:checkCanQuitAlliance(uid,layerNum)
    if allianceVoApi:isInAllianceWar() then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("inAllianceWar"),28)
    	do return false end
    end

    if attackTankSoltVoApi:getAllAttackTankSlotsHelpNum()>0 then
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("haveTroopsInHelp"),nil,layerNum)
        do return false end
    end
    if helpDefendVoApi:isHasArrive() then
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage8034"),true,layerNum)
        do return false end
    end
    if allianceCityVoApi:ishasDefTroops(uid)==true then
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("canotQuitAllianceStr1"),true,layerNum)
    	do return false end
    end
    return true
end

function allianceVoApi:isNeedRefreshFlag()
    return self.needRefreshFlag
end

function allianceVoApi:setNeedRefreshFlag(flag)
    self.needRefreshFlag=flag
end

function allianceVoApi:getFlagNewTips()
	return self.flagNewTips
end
function allianceVoApi:setFlagNewTips(flagType, key, value)
    if value and value < 0 then
        self.flagNewTips[flagType] = {}
    else
        self.flagNewTips[flagType][key] = value
    end
end
-- 检测当前升级后等级是否解锁军团旗帜
function allianceVoApi:checkUnlockState(flagType, levelOld, level)
    if base.isAf == 1 then
        local isSendMsg = false
        local updateData = {{}, {}, {}}
        local showAllTab = {}
        local sortAllKey = {"icon", "frame", "color"}
        for i,v in ipairs(sortAllKey) do
            local showList = {}
            -- 去除不显示的
            for k,vv in pairs(allianceFlagCfg[v]) do
                if vv.isShow == 1 then
                    showList[k] = vv
                end
            end
            -- 排序key值
            showAllTab[i] = {}
            for k,vvv in pairs(showList) do
                table.insert(showAllTab[i], k)
            end
            local function sortFunc(a, b)
                local aData = showList[a]
                local bData = showList[b]
                return tonumber(aData.sortId) < tonumber(bData.sortId)
            end
            table.sort(showAllTab[i], sortFunc)
        end

        if flagType == 3 then
            -- 颜色
            local flagCfg = allianceFlagCfg.color
            for i,v in ipairs(showAllTab[flagType]) do
                local flagData = flagCfg[v]

                if flagData.type == 1 then
                    -- 需军团科技等级
                    local sidKey = ""
                    local sidLv = 0
                    for skillK,skillV in pairs(flagData.condition) do
                        sidKey = skillK
                        sidLv = skillV
                    end

                    if levelOld < sidLv and level >= sidLv then
                        -- 老等级不解锁，等级解锁的添加
                        allianceVoApi:setFlagNewTips(flagType, v, 1)
                        isSendMsg = true
                        updateData[flagType][v] = 1
                    end
                end
            end
        elseif flagType == 1 then
            -- ICON
            local flagCfg = allianceFlagCfg.icon
            for i,v in ipairs(showAllTab[flagType]) do
                local flagData = flagCfg[v]

                if flagData.type == 1 then
                    -- 需军团等级
                    if levelOld < flagData.condition and level >= flagData.condition then
                        -- 老等级不解锁，等级解锁的添加
                        allianceVoApi:setFlagNewTips(flagType, v, 1)
                        isSendMsg = true
                        updateData[flagType][v] = 1
                    end
                end
            end
        end

        if isSendMsg then
            -- 通知军团其他成员更新解锁旗帜数据
            local alliance = allianceVoApi:getSelfAlliance()
            local params = {}
            params.unlock = updateData
            params.aid = alliance.aid
            params.uid = playerVoApi:getUid()
            -- 发送聊天消息通知军团其他成员更新解锁旗帜数据
            chatVoApi:sendUpdateMessage(59, params, alliance.aid + 1)
        end
    end
end

-- 获取旗帜图片或颜色
function allianceVoApi:getFlagShowInfo(flagType, key)
    local info = ""

    if flagType == 3 then
        local flagColor = allianceFlagCfg.color[key].color
        info = ccc3(flagColor[1], flagColor[2], flagColor[3])
    elseif flagType == 2 then
        info = allianceFlagCfg.frame[key].pic .. ".png"
    else
        info = allianceFlagCfg.icon[key].pic .. ".png"
    end

    return info
end

-- 显示旗帜创建
function allianceVoApi:createShowFlag(iconKey, frameKey, colorKey, scale, layerNum, callBack)
    local flagLayer = CCSprite:create()
    local flagColor = allianceFlagCfg.color[colorKey].color

    -- 上旗杆
    local flagSp1 = LuaCCSprite:createWithSpriteFrameName("allianceFlagpole.png", function () end)
    flagSp1:setTag(101)
    flagLayer:addChild(flagSp1, 1)

    -- 旗帜底板
    local flagSp2 = LuaCCSprite:createWithSpriteFrameName(allianceFlagCfg.frame[frameKey].pic .. ".png",
        function () 
            if callBack then
                -- 点击回调
                callBack()
            end
        end)
    flagSp2:setColor(ccc3(flagColor[1], flagColor[2], flagColor[3]))
    flagSp2:setTag(102)
    flagLayer:addChild(flagSp2, 2)
    if callBack then
        flagSp2:setTouchPriority(layerNum)
    end

    -- 图标
    local flagSp3 = LuaCCSprite:createWithSpriteFrameName(allianceFlagCfg.icon[iconKey].pic .. ".png", function () end)
    flagSp3:setTag(103)
    flagLayer:addChild(flagSp3, 3)

    -- 调整位置
    flagSp1:setPosition(0, flagSp2:getContentSize().height / 2 - 4)
    flagSp3:setPosition(0, 25)

    if scale then
        flagLayer:setScale(scale)
    end

    return flagLayer
end

-- 显示旗帜更新
function allianceVoApi:setShowFlag(iconNode, iconKey, frameKey, colorKey)
    if iconNode then
        local flagIcon = tolua.cast(iconNode:getChildByTag(103),"CCSprite")
        local flagBg = tolua.cast(iconNode:getChildByTag(102),"CCSprite")

        flagIcon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(allianceVoApi:getFlagShowInfo(1, iconKey)))
        flagBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(allianceVoApi:getFlagShowInfo(2, frameKey)))
        flagBg:setColor(allianceVoApi:getFlagShowInfo(3, colorKey))
    end
end

-- 获取旗帜属性
--useRichFlag属性是否使用富文本
function allianceVoApi:getShowFlagAttr(flagType, flagKey, useRichFlag)
    local attr, limit, lock = "", "", true
    if flagType == 3 then
        -- 旗帜颜色
        local flagCfg = allianceFlagCfg.color[flagKey]

        if flagCfg.type == 1 then
            -- 需军团科技等级
            local sidKey = ""
            local sidLv = 0
            for k,v in pairs(flagCfg.condition) do
                sidKey = k
                sidLv = v
            end

            local idx = tonumber(string.sub(sidKey, 2))
            local skillCfg = allianceSkillCfg[idx]
            local skillLv = allianceSkillVoApi:getAllSkills()[idx].level
            local value = 0
            if sidLv <= skillLv then
                -- 解锁
                lock = false
            else
                -- 未解锁
                lock = true
            end

            if sidLv > 1 then
                value = skillCfg.value[sidLv] - skillCfg.value[sidLv - 1]
            else
                value = skillCfg.value[1]
            end
            
            if sidLv == 0 then
                attr = getlocal("alliance_scene_info_null")
                limit = getlocal("alliance_scene_info_null")
            else
            	local valueStr = value .. "%%"
            	if useRichFlag==true then
            		valueStr = "<rayimg>"..valueStr.."<rayimg>"
            	end
                attr = getlocal("allianceFlagAttr1", {getlocal(buffEffectCfg[tonumber(skillCfg.attributeType)].name), valueStr})	
                limit = getlocal("allianceFlagLimit2", {getlocal(skillCfg.name), sidLv})
            end
        end
    elseif flagType == 2 then
        -- 旗帜底框
        local flagCfg = allianceFlagCfg.frame[flagKey]
        -- 解锁
        lock = false
        if flagCfg.type == 1 then
            lock = false
        	limit = getlocal("alliance_info_content")
        elseif flagCfg.type == 2 then --活动中获得
        	lock = not self:isFlagUnlock(flagKey)
        	if flagCfg.condition == "jtxlh" then
	        	limit = getlocal("acquire_from_ac",{activityVoApi:getActivityName(flagCfg.condition)})
        	elseif flagCfg.condition == "exerwar" then
	        	limit = getlocal("acquire_from_exerwar")
	        else
	        	local needFlag = self:getNeedFlagInAllianceGift(flagKey)
	        	limit = getlocal("allianceGiftFlagNeed",{needFlag})
	        end
        else
        	limit = getlocal("alliance_info_content")
        end

        local attrKey = ""
        local attrValue = 0

        if flagCfg.buff then
            for k,v in pairs(flagCfg.buff) do
                attrKey = k
                attrValue = v
            end
        else
            for k,v in pairs(flagCfg.att) do
                attrKey = k
                attrValue = v
            end
        end
        local valueStr = attrValue .. "%%"
    	if useRichFlag==true then
    		valueStr = "<rayimg>"..valueStr.."<rayimg>"
    	end
        attr = getlocal("allianceFlagAttr1", {getlocal(buffEffectCfg[buffKeyMatchCodeCfg[attrKey]].name), valueStr})
    else
        -- 旗帜图标
        local flagCfg = allianceFlagCfg.icon[flagKey]
        if flagCfg.type == 1 then
        	-- 需军团等级
            local alliance = allianceVoApi:getSelfAlliance()

            if flagCfg.condition <= alliance.level then
                -- 解锁
                lock = false
            else
                -- 未解锁
                lock = true
            end
        	limit = getlocal("allianceFlagLimit1", {flagCfg.condition})
     	elseif flagCfg.type == 2 then --活动中获得
     		lock = not self:isFlagUnlock(flagKey)
     		if flagCfg.condition == "jtxlh" then
	        	limit = getlocal("acquire_from_ac",{activityVoApi:getActivityName(flagCfg.condition)})
        	elseif flagCfg.condition == "exerwar" then
	        	limit = getlocal("acquire_from_exerwar")
	        else
	        	local needFlag = self:getNeedFlagInAllianceGift(flagKey)--军团礼包
	        	limit = getlocal("allianceGiftFlagNeed",{needFlag})
	        end
        else
        	limit = getlocal("alliance_info_content")
        end
        local attrKey = ""
        local attrValue = 0
        if flagCfg.buff then
            for k,v in pairs(flagCfg.buff) do
                attrKey = k
                attrValue = v
            end
        else
            for k,v in pairs(flagCfg.att) do
                attrKey = k
                attrValue = v
            end
        end
        local valueStr = attrValue .. "%%"
    	if useRichFlag==true then
    		valueStr = "<rayimg>"..valueStr.."<rayimg>"
    	end
        attr = getlocal("allianceFlagAttr1", {getlocal(buffEffectCfg[buffKeyMatchCodeCfg[attrKey]].name), valueStr})
    end

    return attr, limit, lock
end

function allianceVoApi:getFlagUnLockAttr()
    local descKey = {}

    if allianceVoApi:isHasAlliance() == false then
        return descKey
    end

    -- 获取解锁属性
    local showAllTab = {}
    local sortAllKey = {"icon", "frame", "color"}
    for i,v in ipairs(sortAllKey) do
        local showList = {}
        -- 去除不显示的
        for k,vv in pairs(allianceFlagCfg[v]) do
            if vv.isShow == 1 then
                showList[k] = vv
            end
        end
        -- 排序key值
        showAllTab[i] = {}
        for k,vvv in pairs(showList) do
            table.insert(showAllTab[i], k)
        end
    end

    local flagData = showAllTab

    -- 旗帜图标
    for i,v in ipairs(flagData[1]) do
        local flagCfg = allianceFlagCfg.icon[v]

		-- 需军团等级
    	local alliance = allianceVoApi:getSelfAlliance()
		if (flagCfg.type == 1 and flagCfg.condition <= alliance.level) or (flagCfg.type==2 and self:isFlagUnlock(v)==true) then
		    -- 解锁
		    local attrKey = ""
		    local attrValue = 0
		    if flagCfg.buff then
		        for k,v in pairs(flagCfg.buff) do
		            attrKey = k
		            attrValue = v
		        end
		    else
		        for k,v in pairs(flagCfg.att) do
		            attrKey = k
		            attrValue = v
		        end
		    end

		    if not descKey["" .. buffKeyMatchCodeCfg[attrKey]] then
		        descKey["" .. buffKeyMatchCodeCfg[attrKey]] = 0
		    end

		    descKey["" .. buffKeyMatchCodeCfg[attrKey]] = descKey["" .. buffKeyMatchCodeCfg[attrKey]] + attrValue
		end
    end

    -- 旗帜底框
    for i,v in ipairs(flagData[2]) do
        local flagCfg = allianceFlagCfg.frame[v]

        if flagCfg.type == 1 or (flagCfg.type==2 and self:isFlagUnlock(v)==true) then
            -- 解锁
            local attrKey = ""
            local attrValue = 0

            if flagCfg.buff then
                for k,v in pairs(flagCfg.buff) do
                    attrKey = k
                    attrValue = v
                end
            else
                for k,v in pairs(flagCfg.att) do
                    attrKey = k
                    attrValue = v
                end
            end

            if not descKey["" .. buffKeyMatchCodeCfg[attrKey]] then
                descKey["" .. buffKeyMatchCodeCfg[attrKey]] = 0
            end

            descKey["" .. buffKeyMatchCodeCfg[attrKey]] = descKey["" .. buffKeyMatchCodeCfg[attrKey]] + attrValue
        end
    end
    -- 旗帜颜色
    local colorAttrTb = {} --旗帜颜色增加的属性
    for i,v in ipairs(flagData[3]) do
        local flagCfg = allianceFlagCfg.color[v]

        if flagCfg.type == 1 then
            -- 需军团科技等级
            local sidKey = ""
            local sidLv = 0
            for k,v in pairs(flagCfg.condition) do
                sidKey = k
                sidLv = v
            end

            local idx = tonumber(string.sub(sidKey, 2))
            local skillCfg = allianceSkillCfg[idx]
            local skillLv = 0
            local aslist = allianceSkillVoApi:getAllSkills()
            if aslist and aslist[idx] then
            	skillLv = aslist[idx].level or 0
            end
            local value = 0
            if sidLv <= skillLv and tonumber(skillLv)>0 then
                -- 解锁
                if sidLv >= 1 then
                    value = skillCfg.value[sidLv]
                end
                if not colorAttrTb["" .. skillCfg.attributeType] or colorAttrTb["" .. skillCfg.attributeType] < value then
                    colorAttrTb["" .. skillCfg.attributeType] = value
                end

            end
        end
    end
	for k,v in pairs(colorAttrTb) do
        descKey[k] = (descKey[k] or 0) + tonumber(v or 0)
	end
    return descKey
end

-- 获取军团旗帜tab
function allianceVoApi:getFlagIconTab(str)
    local defaultSelect = {"i1", "if1", "ic1"}

    if str and str ~= "" and str ~= "''" then
        defaultSelect = Split(str, "-")
    end

    return defaultSelect
end

--判断军团旗帜数据是否异常
function allianceVoApi:checkAllianceFlagIslegal(banner)
	if banner and type(banner)=="string" then
		local arr = Split(banner,"-")
		if arr and SizeOfTable(arr)>=3 then
			return true
		end
	end
	return false
end

--军团旗帜
function allianceVoApi:getAllianceFlag(flagId,callback)
	local function touch()
		if callback then
			callback()
		end
	end
	local pic = self:getFlagShowInfo(2,flagId)
	local iconBg = LuaCCScale9Sprite:createWithSpriteFrameName("fi_bubble_bg.png", CCRect(3, 3, 3, 3), touch)
    iconBg:setContentSize(CCSizeMake(130, 130))
	local icon = CCSprite:createWithSpriteFrameName(pic)
	icon:setPosition(getCenterPoint(iconBg))
	icon:setScale(120/icon:getContentSize().height)
	iconBg:addChild(icon)
	return iconBg
end

--军团旗帜图案
function allianceVoApi:getAllianceFlagPattern(patternId,callback)
	local function touch()
		if callback then
			callback()
		end
	end
	local pic = self:getFlagShowInfo(1,patternId)
	local iconBg = LuaCCScale9Sprite:createWithSpriteFrameName("fi_bubble_bg.png", CCRect(3, 3, 3, 3), touch)
    iconBg:setContentSize(CCSizeMake(130, 130))
	local icon = CCSprite:createWithSpriteFrameName(pic)
	icon:setPosition(getCenterPoint(iconBg))
	icon:setScale(120/icon:getContentSize().height)
	iconBg:addChild(icon)
	return iconBg
end

--判断旗帜是否已经拥有
--注意：该方法只适用用type~=1的
--flagId：可以是旗帜id，也可以是图案id
function allianceVoApi:isFlagUnlock(flagId)
	local myAlliance = self:getSelfAlliance()
	if myAlliance and myAlliance.unlockflag then
		for k,v in pairs(myAlliance.unlockflag) do
			if v==flagId then
				return true
			end
		end
	end
	return false
end

function allianceVoApi:setUnlockFlag(unlockflag)
	local myAlliance = self:getSelfAlliance()
	if myAlliance then
		myAlliance.unlockflag=unlockflag or {}
	end
end

function allianceVoApi:setUnlockFlagValue(unlockflagValue)
	local myAlliance = self:getSelfAlliance()
	if myAlliance and myAlliance.unlockflag then
		local isHas = false
		for k,v in pairs(myAlliance.unlockflag) do
			if v == unlockflagValue then
				isHas = true
				do break end
			end
		end
		if not isHas then
			if myAlliance.unlockflag == nil then
				myAlliance.unlockflag = {}
			end
			table.insert(myAlliance.unlockflag,unlockflagValue)
		end
	end
end

function allianceVoApi:getNeedFlagInAllianceGift(flagId)--用于军团礼包 查需所需等级
	if allianceGiftCfg and allianceGiftCfg.flagLimit then
		for k,v in pairs(allianceGiftCfg.flagLimit) do
			if v.flag then
				local grade = v.grade
				for k,v in pairs(v.flag) do
					for m,n in pairs(v) do
						if m == flagId then
							return grade
						end
					end
				end
			end
		end
	end
	print " ====== e r r o r  flagId is nil ======="
	return nil
end

--获取编辑军团宣言冷却时间
function allianceVoApi:getEditAllianceDescCoolingTime()
	local selfAlliance = self:getSelfAlliance()
	if selfAlliance and selfAlliance.desc_at and selfAlliance.desc_at > 0 then
        local et = selfAlliance.desc_at + 86400
        return et - base.serverTime
    end
    return 0
end