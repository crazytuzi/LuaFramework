swReportVoApi={}

function swReportVoApi:isShowAccessory()
	if base.ifAccessoryOpen==1 then
		return true
	end
	return false
end

function swReportVoApi:isShowHero(report)
	if base.heroSwitch==1 then
		return true
	end
	return false
end

--是否在邮件面板显示军徽信息
function swReportVoApi:isShowEmblem(report)
	if base.emblemSwitch==1 and report.emblemID and SizeOfTable(report.emblemID)==2 and (report.emblemID[1]~=0 or report.emblemID[2]~=0) then
		return true
	end
	return false
end

-- 优化过之后，单独请求report，部队，军徽，配件等数据
function swReportVoApi:addReportDetail(rid,content)
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
    local extraReportInfo = nil --敌我双方新增功能数据
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
		if content.tankinfo then
			local tankTotal =content.tankinfo
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
		if content.ri then
			extraReportInfo=content.ri
		end
	end

	-- 给的report等赋值
	local list=superWeaponVoApi:getReportList()
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
    			--v.tskinList：敌我双方坦克皮肤数据
    			v.tskinList=G_formatExtraReportInfo(extraReportInfo)
				do break end
			end
		end
	end
end

function swReportVoApi:getReportContent(report)
	local content={}
	if report and SizeOfTable(report)>0 then
		local time=report.time or 0
		local enemyName=report.enemyName
		local isVictory=report.isVictory
		local robResult=report.robSuccess
		local isAttacker
		if report.type==1 then
			isAttacker=true
		else
			isAttacker=false
		end

		local msgStr1=""
		local msgStr2=""
		local msgStr3=""
		local msgStr4=""
		
		if isAttacker==true then
			msgStr1=getlocal("swreport_attackstr",{enemyName})
		else
			msgStr1=getlocal("swreport_defendstr",{enemyName})
		end
		msgStr2=getlocal("arena_report_desc5",{},{G_getDataTimeStr(time)})
		if isVictory==1 then
			if isAttacker==true then
				msgStr3=getlocal("fight_content_result")..getlocal("fight_win")
			else
				msgStr3=getlocal("fight_content_result")..getlocal("serverwarteam_report_defend_win")
			end
			msgStr3={msgStr3,G_ColorGreen}
		else
			if isAttacker==true then
				msgStr3=getlocal("fight_content_result")..getlocal("fight_defeated")
			else
				msgStr3=getlocal("fight_content_result")..getlocal("serverwarteam_report_defend_fail")
			end
			msgStr3={msgStr3,G_ColorRed}
		end
		if robResult==1 then
			msgStr4={getlocal("snatch_result")..getlocal("snatch_success"),G_ColorGreen}
		else
			msgStr4={getlocal("snatch_result")..getlocal("snatch_fail"),G_ColorRed}
		end
		content={msgStr1,msgStr2,msgStr3,msgStr4}
	end
	return content
end

function swReportVoApi:deleteReport(rid)
	local reportList=superWeaponVoApi:getReportList()
	if reportList then
		for k,v in pairs(reportList) do
			if v.rid==rid then
				table.remove(reportList,k)
				local totalNum=superWeaponVoApi:getTotalNum()
				totalNum=totalNum-1
				if totalNum<0 then
					totalNum=0
				end
				superWeaponVoApi:setTotalNum(totalNum)
				do break end
			end
		end
	end
end

function swReportVoApi:deleteAllReport()
    local function callback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
			superWeaponVoApi:clearReportList()
			superWeaponVoApi:setTotalNum(0)
			superWeaponVoApi:setUnreadNum(0)
			superWeaponVoApi:setFlag(0)
        end
    end
    socketHelper:weaponDelete(nil,callback)
end

function swReportVoApi:readAllReport()
    local function callback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
        	local reportList=superWeaponVoApi:getReportList()
        	if reportList then
        		for k,v in pairs(reportList) do
        			v.isRead=1
        		end
        	end
			superWeaponVoApi:setUnreadNum(0)
			superWeaponVoApi:setFlag(0)
        end
    end
    socketHelper:weaponRead(nil,callback,1)
end