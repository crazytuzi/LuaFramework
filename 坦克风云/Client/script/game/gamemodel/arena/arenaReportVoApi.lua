arenaReportVoApi={
	reportList={},
	flag=-1,
	totalNum=0,
	unreadNum=0,
	maxNum=50,
}

function arenaReportVoApi:clear()
	self:deleteAll()
	self.flag=-1
	self.totalNum=0
	self.unreadNum=0
	self.maxNum=50
end

function arenaReportVoApi:getMaxNum()
	return self.maxNum
end

function arenaReportVoApi:getFlag()
	return self.flag
end
function arenaReportVoApi:setFlag(flag)
	self.flag=flag
end

function arenaReportVoApi:getTotalNum()
	return self.totalNum
end
function arenaReportVoApi:setTotalNum(totalNum)
	self.totalNum=totalNum
end
function arenaReportVoApi:getUnreadNum()
	return self.unreadNum
end
function arenaReportVoApi:setUnreadNum(unreadNum)
	self.unreadNum=unreadNum
end

function arenaReportVoApi:getReportList()
	if self.reportList==nil then
		self.reportList={}
	end
	return self.reportList
end

function arenaReportVoApi:getNum()
	local num=0
	local list=self:getReportList()
	if list then
		num=SizeOfTable(list)
	end
	return num
end

function arenaReportVoApi:getReport(rid)
	local list=self:getReportList()
	if list then
		for k,v in pairs(list) do
			if v.rid==rid then
				return v
			end
		end
	end
	return nil
end

function arenaReportVoApi:addReport(data,isAddReport)
	if data then
		for k,v in pairs(data) do
			if k=="maxrows" then
				if v and tonumber(v) then
					self:setTotalNum(tonumber(v) or 0)
				end
	        elseif k=="unread" then
	        	if v and tonumber(v) then
	        		self:setUnreadNum(tonumber(v) or 0)
	        	end
	        elseif isAddReport~=false then
				local rid=tonumber(v.eid)
				local uid=playerVoApi:getUid()
				local name=playerVoApi:getPlayerName()
				local enemyId=tonumber(v.receiver) or 0
				local enemyName=arenaVoApi:getNpcNameById(enemyId,v.dfname or "")
				local time=tonumber(v.ts) or 0
				local isVictory=tonumber(v.isvictory) or 0
				local rankChange=tonumber(v.rank) or 0
				local isRead=tonumber(v.isRead) or 0

	   --          local lostShip={
				-- 	attackerLost={},
				-- 	defenderLost={},
				-- 	attackerTotal={},
				-- 	defenderTotal={}
				-- }
				-- local report={}
				-- local accessory={}
				-- local hero={{{},0},{{},0}}
	   --          if v.content then
	   --          	if v.content.lostShip then
		  --           	local lostShipTab=v.content.lostShip
				-- 		--战斗损失
						
				-- 		if lostShipTab then
				-- 			local attackerLost=lostShipTab.attacker
				-- 			local defenderLost=lostShipTab.defenser
				-- 			if attackerLost then
				-- 				lostShip.attackerLost=FormatItem({o=attackerLost},false)
				-- 			end
				-- 			if defenderLost then
				-- 				lostShip.defenderLost=FormatItem({o=defenderLost},false)
				-- 			end
				-- 		end
				-- 	end
				-- 	if v.content.tank then
				-- 		local tankTotal =v.content.tank
				-- 		    if tankTotal then
				-- 		        local attackerTotal = tankTotal.a
				-- 		        local defenderTotal = tankTotal.d
				-- 		        if attackerTotal then
				-- 		        	lostShip.attackerTotal =FormatItem({o=attackerTotal},false)
				-- 		        end
				-- 		        if defenderTotal then
				-- 		        	lostShip.defenderTotal =FormatItem({o=defenderTotal},false)
				-- 		        end
				-- 		    end
				-- 	end
				-- 	if v.content.report then
				-- 		report=v.content.report
				-- 	end
				-- 	if v.content.aey then
				-- 		accessory=v.content.aey
				-- 	end
				-- 	if v.content.hh then
				-- 		hero=v.content.hh
				-- 	end
				-- end

				local vo = arenaReportVo:new()
		        vo:initWithData(rid,tonumber(v.type),uid,name,enemyId,enemyName,time,isRead,isVictory,report,rankChange,lostShip,accessory,false,hero)
		        table.insert(self.reportList,vo)
		    end
		end

		if self.reportList and SizeOfTable(self.reportList)>0 then
	        local function sortAsc(a, b)
				if a and b and a.rid and b.rid then
					return a.rid > b.rid
				end
			end
			table.sort(self.reportList,sortAsc)
		end
	
		local maxNum=self:getMaxNum()
		local totalNum=self:getTotalNum()
		if totalNum>maxNum then
			self:setTotalNum(maxNum)
		end
		local unreadNum=self:getUnreadNum()
		if unreadNum>maxNum then
			self:setUnreadNum(unreadNum)
		end
		while self:getNum()>maxNum do
			table.remove(self.reportList,self:getNum())
		end
		return vo
	end
	return nil
end

-- 优化过之后，单独请求report
function arenaReportVoApi:addReportHeroAccesoryAndLostship(rid,content)
	local lostShip={
		attackerLost={},
		defenderLost={},
		attackerTotal={},
		defenderTotal={}
	}
	local attInfo=nil
	local defInfo=nil
	local report={}
	local accessory={}
	local hero={{{},0},{{},0}}
	local emblemID=nil
	local plane=nil
	local weapon=nil --超级武器{进攻方，防守方}
    local armor=nil --装甲矩阵{进攻方，防守方}
    local troops=nil --敌我双方部队信息
    local aitroops = nil --敌我双方AI部队信息
    local extraReportInfo = nil --敌我双方新增功能数据
    local airShipInfo = nil
    if content then
    	if content.lostShip then
        	local lostShipTab=content.lostShip
			--战斗损失
			
			if lostShipTab then
				local attackerLost=lostShipTab.attacker
				local defenderLost=lostShipTab.defenser
				if attackerLost then
					lostShip.attackerLost=FormatItem({o=attackerLost},false)
				end
				if defenderLost then
					lostShip.defenderLost=FormatItem({o=defenderLost},false)
				end
			end
		end
		if content.tank then
			local tankTotal =content.tank
			    if tankTotal then
			        local attackerTotal = tankTotal.a
			        local defenderTotal = tankTotal.d
			        if attackerTotal then
			        	lostShip.attackerTotal =FormatItem({o=attackerTotal},false)
			        end
			        if defenderTotal then
			        	lostShip.defenderTotal =FormatItem({o=defenderTotal},false)
			        end
			    end
		end
		if content.attInfo then
			attInfo=content.attInfo
		end
		if content.defInfo then
			defInfo=content.defInfo
		end
		if content.report then
			report=content.report
		end
		if content.aey then
			accessory=content.aey
		end
		if content.hh then
			hero=content.hh
		end
		if content.se then
			emblemID=content.se
		end
		if content.plane then
			plane=content.plane
		end
		if content.weapon then
			weapon=content.weapon
		end
		if content.armor then
			armor=content.armor
		end
		if content.troops then
			troops=content.troops
		end
		if content.ait then
			aitroops=content.ait
		end
		if content.ri then
			extraReportInfo=content.ri
		end
		if content.ap then
			airShipInfo = content.ap
		end
	end

	-- 给的report等赋值
	local list=self:getReportList()
	if list then
		for k,v in pairs(list) do
			if v.rid==rid then
				v.report=report or {}
				v.accessory=accessory or {}
				v.hero=hero or {{{},0},{{},0}}
				v.lostShip=lostShip or {}
				v.initReport=true
				v.emblemID=emblemID
				v.plane=plane
				v.attInfo=attInfo
				v.defInfo=defInfo
				v.weapon=weapon --超级武器{进攻方，防守方}
    			v.armor=armor --装甲矩阵{进攻方，防守方}
    			v.troops=troops --敌我双方部队信息
    			v.aitroops=aitroops
    			--tskinList：敌我双方坦克皮肤数据
    			v.tskinList=G_formatExtraReportInfo(extraReportInfo)
    			v.airship=airShipInfo
			end
		end
	end


end

-- function arenaReportVoApi:addBattleReport(rid,battleReport)
-- 	if self.reportList then
-- 		for k,v in pairs(self.reportList) do
-- 			if v.rid==rid then
-- 				v.report=battleReport
-- 				v.initReport=true
-- 			end
-- 		end
-- 	end
-- end

function arenaReportVoApi:deleteReport(rid)
	if self.reportList then
		for k,v in pairs(self.reportList) do
			if v.rid==rid then
				table.remove(self.reportList,k)
				local totalNum=self:getTotalNum()
				totalNum=totalNum-1
				if totalNum<0 then
					totalNum=0
				end
				self:setTotalNum(totalNum)
			end
		end
	end
end

--删除已读邮件
function arenaReportVoApi:deleteAllReadReport()
	if self.reportList then
		local list = {}
		local rc = 0
		for k,v in pairs(self.reportList) do
			if v.isRead~=1 then
				table.insert(list,v)
			else
				rc = rc + 1
			end
		end
		local totalNum = self:getTotalNum()
		totalNum=totalNum-rc
		if totalNum<0 then
			totalNum=0
		end
		self:setTotalNum(totalNum)
		self.reportList=list
	end
end

function arenaReportVoApi:deleteAll()
	if self.reportList~=nil then
		for k,v in pairs(self.reportList) do
			v=nil
		end
		self.reportList=nil
	end
	self.reportList={}
end

function arenaReportVoApi:hasMore()
	if self.totalNum>0 then
		if self.totalNum>self:getNum() then
			return true
		end
	end
	return false
end

function arenaReportVoApi:setIsRead(rid)
	if self.reportList then
		for k,v in pairs(self.reportList) do
		    if tostring(rid)==tostring(v.rid) then
				if v.isRead==0 then
					v.isRead=1

					local unreadNum=self:getUnreadNum()
					unreadNum=unreadNum-1
					if unreadNum<0 then
						unreadNum=0
					end
					self:setUnreadNum(unreadNum)
				end
				do break end
			end
		end
	end
end

function arenaReportVoApi:setIsAllRead()
	if self.reportList then
		for k,v in pairs(self.reportList) do
		    if v.isRead==0 then
				v.isRead=1
			end
		end
		self:setUnreadNum(0)		
	end
end

function arenaReportVoApi:isShowAccessory()
	if base.ifAccessoryOpen==1 then
		return true
	end
	return false
end

function arenaReportVoApi:isShowHero()
	if base.heroSwitch==1 then
		return true
	end
	return false
end

--是否在邮件面板显示军徽信息
function arenaReportVoApi:isShowEmblem(report)
	if base.emblemSwitch==1 and report.emblemID ~= nil and SizeOfTable(report.emblemID) == 2 and (report.emblemID[1] ~= 0 or report.emblemID[2] ~= 0) then
		return true
	end
	return false
end

function arenaReportVoApi:getMinAndMaxRid()
	local minrid,maxrid=0,0
	local num=self:getNum()
	local list=self:getReportList()
	if list and self:getNum()>0 then
		minrid,maxrid=list[num].rid,list[1].rid
	end
	return minrid,maxrid
end
