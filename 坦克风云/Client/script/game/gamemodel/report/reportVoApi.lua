require "luascript/script/game/gamemodel/report/battleReportVo"
require "luascript/script/game/gamemodel/report/scoutReportVo"
require "luascript/script/game/gamemodel/report/returnReportVo"

reportVoApi={
	battleReport=nil,
	scoutReport=nil,
	returnReport=nil,
}

function reportVoApi:getReport(rid)
	--if type==1 then
		if self.battleReport then
			for k,v in pairs(self.battleReport) do
				if v.rid==rid then
					return v
				end
			end
		end
	--elseif type==2 then
		if self.scoutReport then
			for k,v in pairs(self.scoutReport) do
				if v.rid==rid then
					return v
				end
			end
		end
	--elseif type==3 then
		if self.returnReport then
			for k,v in pairs(self.returnReport) do
				if v.rid==rid then
					return v
				end
			end
		end
		--end
	return nil
end

function reportVoApi:addReport(type,data)
	if data then
		local resource={}
		local helpDefender=""
		if data.resource then
			resource=data.resource
		end
		if data.helpDefender then
			helpDefender=data.helpDefender
		end
		if type==1 then
			if self.battleReport==nil then
				self.battleReport={}
			end
			local award={}
			local lostShip={}
			local credit=0
			if data.award then
				award=data.award
			end
			if data.lostShip then
				lostShip=data.lostShip
			end
			if data.credit then
				credit=data.credit
			end
			
			if award and data.islandType and data.islandType~=7 then
				for k,v in pairs(award) do
					if v and v.id and v.name then
						if v.id==20 then
							local evo=emailVoApi:getEmailByEid(2,data.rid)
							if evo and evo.isRead==0 then
								-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage4",{playerVoApi:getPlayerName(),v.name}))
        						local pid="p"..v.id
        						local prop=propCfg[pid]
                                local paramTab={}
                                paramTab.functionStr="map"
                                paramTab.addStr="go_attack"
        						local nameData={key=prop.name,param={}}
								local message={key="chatSystemMessage4",param={playerVoApi:getPlayerName(),nameData}}
                				chatVoApi:sendSystemMessage(message,paramTab)
							end
						end
					end
				end
			end

	        local vo = battleReportVo:new()
	        vo:initWithData(data.rid,data.type,data.islandType,data.attacker,data.defender,data.place,data.level,data.time,data.islandOwner,data.isVictory,award,resource,lostShip,credit,helpDefender,data.report,data.attackerPlace,data.accessory,data.aLandform,data.dLandform,data.acaward,data.rp,data.hero,data.battleRichLevel,data.goldMineLv,data.disappearTime,data.pic,data.rebel,data.acData,data.emblemID,data.plane,data.weapon,data.armor,data.troops,data.xixue,data.aitroops,data.effect,data.extraReportInfo,data.privateMine,data.ap,data.shipboss)
	        table.insert(self.battleReport,vo)
			return vo
		elseif type==2 then
			if self.scoutReport==nil then
				self.scoutReport={}
			end
			local defendShip={}
			if data.defendShip then
				defendShip=data.defendShip
			end
	        local vo = scoutReportVo:new()
	        vo:initWithData(data.rid,data.type,data.islandType,data.defender,data.place,data.level,data.time,data.islandOwner,resource,defendShip,helpDefender,data.allianceName,data.landform,data.richLevel,data.boom,data.boomMax,data.boomTs,data.boomBmd,data.goldMineLv,data.disappearTime,data.rebel,data.aistatus,data.skin,data.privateMine)
	        table.insert(self.scoutReport,vo)
			return vo
		elseif type==3 then
			if self.returnReport==nil then
				self.returnReport={}
			end
	        local vo = returnReportVo:new()
	        vo:initWithData(data.rid,data.type,data.returnType,data.islandType,tostring(data.name),data.place,data.level,data.allianceName,data.richLevel,data.goldMineLv,data.time,data.fleetload,data.resource,data.boom,nil,nil,nil,nil,nil,nil,nil,data.rebel)
	        table.insert(self.returnReport,vo)
			return vo
		elseif type==4 then
			if self.returnReport==nil then
				self.returnReport={}
			end
	        local vo = returnReportVo:new()
	        vo:initWithData(data.rid,data.type,data.returnType,data.islandType,tostring(data.name),data.place,data.level,data.allianceName,data.richLevel,data.goldMineLv,data.time,data.fleetload,data.resource,data.boom,nil,nil,nil,nil,nil,nil,nil,data.rebel,nil,data.privateMine)
	        table.insert(self.returnReport,vo)
			return vo
		elseif type==5 or type==6 then
			local defendShip={}
			if data.defendShip then
				defendShip=data.defendShip
			end
			if self.returnReport==nil then
				self.returnReport={}
			end
	        local vo = returnReportVo:new()
	        vo:initWithData(data.rid,data.type,data.returnType,data.islandType,tostring(data.name),data.place,data.level,data.allianceName,data.richLevel,data.goldMineLv,data.time,data.fleetload,data.resource,nil,data.power,data.glory,data.searchtype,data.leftTime,data.curRes,data.isHasFleet,defendShip,data.rebel)
	        table.insert(self.returnReport,vo)
			return vo
		elseif type==7 or type==8 or type==9 or type==10 then
			if self.returnReport==nil then
				self.returnReport={}
			end
	        local vo = returnReportVo:new()
	        vo:initWithData(data.rid,data.type,data.returnType,data.islandType,tostring(data.name),data.place,data.level,data.allianceName,data.richLevel,data.goldMineLv,data.time,data.fleetload,data.resource,data.boom,nil,nil,nil,nil,nil,nil,nil,data.rebel,data.award)
	        table.insert(self.returnReport,vo)
	        return vo
		end
	end
	return nil
end

function reportVoApi:deleteReport(rid)
	--if type==1 then
		if self.battleReport then
			for k,v in pairs(self.battleReport) do
				if v.rid==rid then
					table.remove(self.battleReport,k)
				end
			end
		end
	--elseif type==2 then
		if self.scoutReport then
			for k,v in pairs(self.scoutReport) do
				if v.rid==rid then
					table.remove(self.scoutReport,k)
				end
			end
		end
	--elseif type==3 then
		if self.returnReport then
			for k,v in pairs(self.returnReport) do
				if v.rid==rid then
					table.remove(self.returnReport,k)
				end
			end
		end
		--end
end

function reportVoApi:deleteAll()
	if self.battleReport~=nil then
		for k,v in pairs(self.battleReport) do
			v=nil
		end
		self.battleReport=nil
	end
	self.battleReport={}
	if self.scoutReport~=nil then
		for k,v in pairs(self.scoutReport) do
			v=nil
		end
		self.scoutReport=nil
	end
	self.scoutReport={}
	if self.returnReport~=nil then
		for k,v in pairs(self.returnReport) do
			v=nil
		end
		self.returnReport=nil
	end
	self.returnReport={}
end

function reportVoApi:formatReportData(report)
	local islandType=6
	local attacker=""
	local defender=""
	local attackerAllianceName=""
	local defenderAllianceName=""
	local helpDefender=""
	local helpDefenderAllianceName=""
	local hasHelpDefender=false
	local aLandform=""
	local dLandform=""
	local landform=""
	local landformPic=nil
	local richLevel=0
	local boom = nil
	local boomMax =nil
	local boomTs = nil
	local boomBmd = nil
	if report and SizeOfTable(report)>0 and report.type then
		local rtype=report.type
		islandType=report.islandType
		if report.aLandform and report.aLandform>0 then
			aLandform=getlocal("world_ground_name_"..report.aLandform)
		end
		if report.dLandform and report.dLandform>0 then
			dLandform=getlocal("world_ground_name_"..report.dLandform)
		end
		if report.landform and report.landform>0 then
			landform=getlocal("world_ground_name_"..report.landform)
			landformPic="world_ground_"..report.landform..".png"
		end
		if rtype==1 then
			if report.attacker then
				attacker=report.attacker.name
				attackerAllianceName=report.attacker.allianceName
				if attackerAllianceName and attackerAllianceName~="" then
					attacker=attacker..getlocal("report_content_alliance",{attackerAllianceName})
				end
			end
			if report.defender then
				defender=report.defender.name
				defenderAllianceName=report.defender.allianceName
				if defenderAllianceName and defenderAllianceName~="" then
					defender=defender..getlocal("report_content_alliance",{defenderAllianceName})
				end
			end
			if report.helpDefender and report.helpDefender~="" then
				helpDefender=report.helpDefender
				helpDefenderAllianceName=report.defender.allianceName
				if helpDefenderAllianceName and helpDefenderAllianceName~="" then
					helpDefender=helpDefender..getlocal("report_content_alliance",{helpDefenderAllianceName})
				end
				hasHelpDefender=true
			end
		elseif rtype==2 then
			if report.defender then
				defender=report.defender.name
				defenderAllianceName=report.defender.allianceName
				if defenderAllianceName and defenderAllianceName~="" then
					defender=defender..getlocal("report_content_alliance",{defenderAllianceName})
				end
			end
			if report.helpDefender and report.helpDefender~="" then
				helpDefender=report.helpDefender
				helpDefenderAllianceName=report.defender.allianceName
				if helpDefenderAllianceName and helpDefenderAllianceName~="" then
					helpDefender=helpDefender..getlocal("report_content_alliance",{helpDefenderAllianceName})
				end
				hasHelpDefender=true
			end
			if report.richLevel and report.richLevel>0 then
				richLevel=report.richLevel
			end

			if report.boom then
				boom =report.boom
			end

			if report.boomMax then
				boomMax =report.boomMax
			end

			if report.boomTs then
				boomTs =report.boomTs
			end

			if report.boomBmd then
				boomBmd =report.boomBmd
			end
		elseif rtype==4 then
			if report.boom then
				boom=report.boom
			end

		end
	end
	return islandType,attacker,defender,attackerAllianceName,defenderAllianceName,helpDefender,helpDefenderAllianceName,hasHelpDefender,aLandform,dLandform,landform,richLevel,boom,boomMax,boomTs,boomBmd,landformPic
end

function reportVoApi:getReportContent(report,chatSender)
	local content={}
	local color={}
	local msgStr1=""
	local msgStr2=""
	local msgStr3=""
	local msgStr4=""
	local msgStr5=""
	local msgStr6=""
	local islandType,attacker,defender,attackerAllianceName,defenderAllianceName,helpDefender,helpDefenderAllianceName,hasHelpDefender,aLandform,dLandform,landform,richLevel,boom,boomMax,boomTs,boomBmd=self:formatReportData(report)
	if report and SizeOfTable(report)>0 and report.type then
		local rtype=report.type
		if rtype==2 then
			if islandType==7 then
				local rebelData=report.rebel or {}
				local rebelLv=rebelData.rebelLv or 0
				local rebelID=rebelData.rebelID or 0
				local expireTs=rebelData.expireTs or 0
				local leftTime=expireTs-report.time
				local target=G_getIslandName(islandType,nil,rebelLv,rebelID,nil,rebelData.rpic)
				local terrainStr
				msgStr1=getlocal("scout_content_player",{target,report.place.x,report.place.y})
				if landform and landform~="" then
					terrainStr=getlocal("scout_content_terrain",{landform})
				end
				msgStr2=getlocal("scout_content_time",{emailVoApi:getTimeStr(report.time)})
				msgStr3=getlocal("email_report_rebel_scout_flee",{GetTimeStr(leftTime)})
				content={{msgStr1,G_ColorWhite}}
				if terrainStr then
					table.insert(content,{terrainStr,G_ColorWhite})
				end
				table.insert(content,{msgStr2,G_ColorWhite})
				table.insert(content,{msgStr3,G_ColorYellowPro})
			else
				local defenderStr
				local terrainStr
				local boomStr = nil
				local boomMaxStr = nil
				local mineStateStr
				local stateColor=G_ColorWhite
				if islandType==6 then
					if hasHelpDefender==true then
						defenderStr=getlocal("fight_content_fight_type_8_1",{helpDefender})
					else
						defenderStr=getlocal("fight_content_fight_type_8_2")
					end
					msgStr1=getlocal("scout_content_player",{defender,report.place.x,report.place.y})
					if landform and landform~="" then
						terrainStr=getlocal("scout_content_terrain",{landform})
					end
				elseif islandType<6 then
					if report.islandOwner>0 then
						defenderStr=getlocal("scout_content_defend_name",{defender})
					else
						defenderStr=getlocal("scout_content_defend_name",{getlocal("fight_content_null")})
					end
					msgStr1=getlocal("scout_content_island",{G_getIslandName(islandType),report.level,report.place.x,report.place.y})
					if landform and landform~="" then
						terrainStr=getlocal("scout_content_terrain",{landform})
					end

					if base.wl==1 and base.goldmine==1 and report.goldMineLv and report.goldMineLv>0 then	
						local mineName=worldBaseVoApi:getMineNameByType(islandType)
						local nameStr=getlocal("bountiful")..mineName
						msgStr1=getlocal("scout_content_island",{nameStr,report.goldMineLv,report.place.x,report.place.y})
						local leftTime=tonumber(report.disappearTime-base.serverTime)
						if leftTime<=0 then
							mineStateStr=getlocal("mine_state")..":"..getlocal("goldmine").."，"..getlocal("disappeared")
						else
							mineStateStr=getlocal("mine_state")..":"..getlocal("goldmine").."，"..GetTimeStr(leftTime)..getlocal("time_disappear")
						end
						stateColor=G_ColorYellowPro
					elseif base.richMineOpen==1 and base.landFormOpen==1 and report.richLevel and report.richLevel>0 then
						mineStateStr=getlocal("mine_state")..":"..getlocal("richmine").."，"..getlocal("res_output_changeto")..tostring((mapHeatCfg.resourceSpeed[report.richLevel]+1)*100).."%"
						stateColor=worldBaseVoApi:getRichMineColorByLv(report.richLevel)
					elseif base.privatemine == 1 and report.privateMine == 1 then
						mineStateStr=getlocal("mine_state")..": "..getlocal("privateMineName")
					else
						mineStateStr=getlocal("mine_state")..":"..getlocal("merge_precent_name3")
					end
				end
				local msgStr2=getlocal("scout_content_time",{emailVoApi:getTimeStr(report.time)})
				content={{msgStr1,G_ColorWhite}}
				if mineStateStr then
					table.insert(content,{mineStateStr,stateColor})
				end
				if terrainStr then
					table.insert(content,{terrainStr,G_ColorWhite})
				-- 	content={msgStr1,terrainStr,msgStr2,defenderStr}
				-- else
				-- 	content={msgStr1,msgStr2,defenderStr}
				end
				table.insert(content,{msgStr2,G_ColorWhite})
				table.insert(content,{defenderStr,G_ColorWhite})
				if base.isGlory ==1 then
					print("boom---->",boom)
					if boom and boomMax then
						boomStr =getlocal("gloryDegreeStr")..":"..getlocal("scheduleChapter",{boom,boomMax})
						table.insert(content,{boomStr,G_ColorWhite})
					end
				end
			end
		elseif rtype==1 then
			if islandType==7 then
				local rebelData=report.rebel or {}
				local rebelLv=rebelData.rebelLv or 0
				local rebelID=rebelData.rebelID or 0
				-- print("islandType,rebelLv,rebelID",islandType,rebelLv,rebelID)
				local target=G_getIslandName(islandType,nil,rebelLv,rebelID,nil,rebelData.rpic)
				-- print("target",target)
				local terrainStr1
				local terrainStr2		
				msgStr1=getlocal("fight_content_fight_type_2",{target})
				if aLandform and aLandform~="" then
					terrainStr1=getlocal("fight_content_terrain_1",{aLandform})
				end
				if dLandform and dLandform~="" then
					terrainStr2=getlocal("fight_content_terrain_2",{dLandform})
				end
				local richColor=G_ColorWhite
				msgStr2={getlocal("fight_content_place",{target,report.place.x,report.place.y}),richColor}
				msgStr3=getlocal("fight_content_time",{emailVoApi:getTimeStr(report.time)})
				local resultStr=getlocal("fight_content_result")..getlocal("fight_content_attack_type")
				if report.isVictory==1 then
					msgStr4={resultStr..getlocal("fight_content_result_win"),G_ColorGreen}
				else
					msgStr4={resultStr..getlocal("fight_content_result_defeat"),G_ColorRed}
				end

				local rankPoint=0
				if report.rp and report.rp[1] and tonumber(report.rp[1]) then
					rankPoint=tonumber(report.rp[1]) or 0
				end
				if rankPoint>0 then
					msgStr6=getlocal("email_rankPoint").."<rayimg>+"..tostring(rankPoint).."<rayimg>"
				end
				if report.acData and report.acData.midautumn then
					local acReward=report.acData.midautumn
					local rewardTb=FormatItem(acReward) or {}
					if rewardTb and rewardTb[1] then
						local award=rewardTb[1]
						local ver = (acMidAutumnVoApi and acMidAutumnVoApi.getVersion) and acMidAutumnVoApi:getVersion() or 1
						msgStr5=ver ==3 and getlocal("activity_miaautumn_report_v2_desc",{award.name.."*"..award.num}) or getlocal("activity_miaautumn_report_desc",{award.name.."*"..award.num})
					end
				end
				if terrainStr1 and terrainStr2 then
					content={msgStr1,msgStr2,terrainStr1,terrainStr2,msgStr3,msgStr4,{msgStr6,{G_ColorWhite,G_ColorGreen,G_ColorWhite}}}
				elseif terrainStr1 then
					content={msgStr1,msgStr2,terrainStr1,msgStr3,msgStr4,{msgStr6,{G_ColorWhite,G_ColorGreen,G_ColorWhite}}}
				elseif terrainStr2 then
					content={msgStr1,msgStr2,terrainStr2,msgStr3,msgStr4,{msgStr6,{G_ColorWhite,G_ColorGreen,G_ColorWhite}}}
				else
					content={msgStr1,msgStr2,msgStr3,msgStr4,{msgStr6,{G_ColorWhite,G_ColorGreen,G_ColorWhite}}}
				end
				if msgStr5 and msgStr5~="" then
					table.insert(content,msgStr5)
				end
			else
				local isAttacker=emailVoApi:isAttacker(report,chatSender)
				local target=""
				local terrainStr1
				local terrainStr2
				local mineStateStr
				local stateColor=G_ColorWhite		
				if isAttacker==true then
					if aLandform and aLandform~="" then
						terrainStr1=getlocal("fight_content_terrain_1",{aLandform})
					end
					if islandType==6 then
						target=defender
						if hasHelpDefender==true then
							msgStr1=getlocal("fight_content_fight_type_2",{helpDefender})
						else
							msgStr1=getlocal("fight_content_fight_type_2",{target})
						end
						if dLandform and dLandform~="" then
							terrainStr2=getlocal("fight_content_terrain_2",{dLandform})
						end
					elseif islandType<6 then
						local nameStr=G_getIslandName(islandType)
						local curLv=report.level
						if base.wl==1 and base.goldmine==1 and report.goldMineLv and report.goldMineLv>0 then
							local mineName=worldBaseVoApi:getMineNameByType(islandType)
							nameStr=getlocal("bountiful")..mineName
							curLv=report.goldMineLv
						end
						if report.islandOwner>0 then
							target=defender
							msgStr1=getlocal("fight_content_fight_type_5",{target,nameStr})
						else
							target=nameStr
							msgStr1=getlocal("fight_content_fight_type_1",{target,curLv})
						end
						if dLandform and dLandform~="" then
							terrainStr2=getlocal("fight_content_terrain_2",{dLandform})
						end

						if base.wl==1 and base.goldmine==1 and report.goldMineLv and report.goldMineLv>0 then
							mineStateStr=getlocal("mine_state")..":"..getlocal("goldmine").."，"..G_getDataTimeStr(report.disappearTime,false,false)..getlocal("time_disappear")
							stateColor=G_ColorYellowPro
						elseif base.richMineOpen==1 and base.landFormOpen==1 and report.richLevel and report.richLevel>0 then
							mineStateStr=getlocal("mine_state")..":"..getlocal("richmine").."，"..getlocal("res_output_changeto")..tostring((mapHeatCfg.resourceSpeed[report.richLevel]+1)*100).."%"
							stateColor=worldBaseVoApi:getRichMineColorByLv(report.richLevel)
						else
							mineStateStr=getlocal("mine_state")..":"..getlocal("merge_precent_name3")
						end
					elseif islandType==8 then --军团城市
						msgStr1=getlocal("fight_content_fight_type_2",{defender})
						target=G_getIslandName(islandType,defenderAllianceName)
						if dLandform and dLandform~="" then
							terrainStr2=getlocal("fight_content_terrain_2",{dLandform})
						end
					end
					local richColor=G_ColorWhite
					-- if report.richLevel then
					-- 	richColor=worldBaseVoApi:getRichMineColorByLv(report.richLevel)
					-- end
					if chatSender then
						msgStr2={getlocal("fight_content_place1",{target}),richColor}
					else
						msgStr2={getlocal("fight_content_place",{target,report.place.x,report.place.y}),richColor}
					end
					msgStr3=getlocal("fight_content_time",{emailVoApi:getTimeStr(report.time)})
					local resultStr=getlocal("fight_content_result")..getlocal("fight_content_attack_type")
					if report.isVictory==1 then
						msgStr4={resultStr..getlocal("fight_content_result_win"),G_ColorGreen}
					else
						msgStr4={resultStr..getlocal("fight_content_result_defeat"),G_ColorRed}
					end

					local rankPoint=0
					if report.rp and report.rp[1] and tonumber(report.rp[1]) then
						rankPoint=tonumber(report.rp[1]) or 0
					end
					if rankPoint>0 then
						msgStr6=getlocal("email_rankPoint").."+"..tostring(rankPoint)
					end
					if terrainStr1 and terrainStr2 then
						content={msgStr1,msgStr2,{mineStateStr,stateColor},terrainStr1,terrainStr2,msgStr3,msgStr4,msgStr6}
					elseif terrainStr1 then
						content={msgStr1,msgStr2,{mineStateStr,stateColor},terrainStr1,msgStr3,msgStr4,msgStr6}
					elseif terrainStr2 then
						content={msgStr1,msgStr2,{mineStateStr,stateColor},terrainStr2,msgStr3,msgStr4,msgStr6}
					else
						content={msgStr1,msgStr2,{mineStateStr,stateColor},msgStr3,msgStr4,msgStr6}
					end
				else
					if aLandform and aLandform~="" then
						terrainStr1=getlocal("fight_content_terrain_3",{aLandform})
					end
					if islandType==6 then
						if hasHelpDefender==true then
							msgStr1=getlocal("fight_content_fight_type_9",{attacker})
						else
							msgStr1=getlocal("fight_content_fight_type_3",{attacker})
						end	
						if dLandform and dLandform~="" then
							terrainStr2=getlocal("fight_content_terrain_4",{dLandform})
						end
					elseif islandType<6 then
						local nameStr=G_getIslandName(islandType)
						if base.wl==1 and base.goldmine==1 and report.goldMineLv and report.goldMineLv>0 then
							local mineName=worldBaseVoApi:getMineNameByType(islandType)
							nameStr=getlocal("bountiful")..mineName
						end
						msgStr1=getlocal("fight_content_fight_type_4",{nameStr,attacker})
						if dLandform and dLandform~="" then
							terrainStr2=getlocal("fight_content_terrain_4",{dLandform})
						end

						if base.wl==1 and base.goldmine==1 and report.goldMineLv and report.goldMineLv>0 then
							mineStateStr=getlocal("mine_state")..":"..getlocal("goldmine").."，"..G_getDataTimeStr(report.disappearTime,false,false)..getlocal("time_disappear")
							stateColor=G_ColorYellowPro
						elseif base.richMineOpen==1 and base.landFormOpen==1 and report.richLevel and report.richLevel>0 then
							mineStateStr=getlocal("mine_state")..":"..getlocal("richmine").."，"..getlocal("res_output_changeto")..tostring((mapHeatCfg.resourceSpeed[report.richLevel]+1)*100).."%"
							stateColor=worldBaseVoApi:getRichMineColorByLv(report.richLevel)
						else
							mineStateStr=getlocal("mine_state")..":"..getlocal("merge_precent_name3")
						end
					elseif islandType==8 then
						msgStr1=getlocal("serverwarteam_report_fight_2",{attacker})
						if dLandform and dLandform~="" then
							terrainStr2=getlocal("fight_content_terrain_4",{dLandform})
						end
					end
					if chatSender then
						if islandType==8 then
							local target=G_getIslandName(islandType,defenderAllianceName)
							msgStr2=getlocal("fight_content_place1",{target})
						else
							msgStr2=getlocal("fight_content_place1",{defender})
						end
					else
						if islandType==8 then
							local target=G_getIslandName(islandType,defenderAllianceName)
							msgStr2=getlocal("fight_content_place",{target,report.place.x,report.place.y})
						else
							msgStr2=getlocal("fight_content_place",{defender,report.place.x,report.place.y})
						end
					end
					msgStr3=getlocal("fight_content_time",{emailVoApi:getTimeStr(report.time)})
					local resultStr=getlocal("fight_content_result")..getlocal("fight_content_defende_type")
					if report.isVictory==1 then
						msgStr4={resultStr..getlocal("fight_content_result_defeat"),G_ColorRed}
					else
						msgStr4={resultStr..getlocal("fight_content_result_win"),G_ColorGreen}
					end
					local rankPoint=0
					if report.rp and report.rp[2] and tonumber(report.rp[2]) then
						rankPoint=tonumber(report.rp[2]) or 0
					end
					if rankPoint>0 then
						msgStr6=getlocal("email_rankPoint").."+"..tostring(rankPoint)
					end
					if terrainStr1 and terrainStr2 then
						content={msgStr1,msgStr2,{mineStateStr,stateColor},terrainStr1,terrainStr2,msgStr3,msgStr4,msgStr6}
					elseif terrainStr1 then
						content={msgStr1,msgStr2,{mineStateStr,stateColor},terrainStr1,msgStr3,msgStr4,msgStr6}
					elseif terrainStr2 then
						content={msgStr1,msgStr2,{mineStateStr,stateColor},terrainStr2,msgStr3,msgStr4,msgStr6}
					else
						content={msgStr1,msgStr2,{mineStateStr,stateColor},msgStr3,msgStr4,msgStr6}
					end
				end
			end
		elseif rtype==4 then
			local boomStr
			local mineStateStr
			local timeStr=G_getDataTimeStr(report.time,false,false)
			local nameStr=G_getIslandName(islandType)
			local color=G_ColorWhite
			local curLv=report.level
			if base.wl==1 and base.goldmine==1 and report.goldMineLv and report.goldMineLv>0 then
				mineStateStr=getlocal("mine_state").."："..getlocal("goldmine")
				color=G_ColorYellowPro
				local mineName=worldBaseVoApi:getMineNameByType(islandType)
				nameStr=getlocal("bountiful")..mineName
				curLv=report.goldMineLv
			elseif base.richMineOpen==1 and base.landFormOpen==1 and report.richLevel and report.richLevel>0 then
				mineStateStr=getlocal("mine_state").."："..getlocal("richmine").."，"..getlocal("res_output_changeto")..tostring((mapHeatCfg.resourceSpeed[report.richLevel]+1)*100).."%"
				color=worldBaseVoApi:getRichMineColorByLv(report.richLevel)
			elseif base.privatemine == 1 and report.privateMine == 1 then
				mineStateStr=getlocal("mine_state")..": "..getlocal("privateMineName")
			else
				mineStateStr=getlocal("mine_state").."："..getlocal("merge_precent_name3")
			end
			-- msgStr1=getlocal("gather_position",{nameStr,curLv,report.place.x,report.place.y})
			msgStr1=getlocal("gather_site")..nameStr.."Lv."..curLv
			table.insert(content,{msgStr1,G_ColorWhite})
			table.insert(content,{getlocal("gather_position_new"),G_ColorWhite})

			if mineStateStr then
				table.insert(content,{mineStateStr,color})
			end
			-- msgStr2=getlocal("returnarrivade",{timeStr})
			-- table.insert(content,{msgStr2,G_ColorWhite})
			msgStr3=getlocal("limitLoad",{FormatNumber(tonumber(report.fleetload))})
			table.insert(content,{msgStr3,G_ColorWhite})
			if base.isGlory==1 then
				print("boom---->",boom)
				if boom then
					boomStr=getlocal("gloryGetStr",{boom})
					table.insert(content,{boomStr,G_ColorWhite})
				end
			end
		elseif rtype==5 then
			-- table.insert(content,{" ",G_ColorWhite})
			-- msgStr1=getlocal("search_base_report_desc_1",{report.name})
			msgStr1=getlocal("scout_content_site")..report.name
			table.insert(content,{msgStr1,G_ColorWhite})
			-- table.insert(content,{" ",G_ColorWhite})
			msgStr2=getlocal("search_base_report_desc_2",{getlocal("alliance_info_content")})
			if report.allianceName and report.allianceName~="" then
				msgStr2=getlocal("search_base_report_desc_2",{report.allianceName})
			end
			table.insert(content,{msgStr2,G_ColorWhite})
			-- table.insert(content,{" ",G_ColorWhite})
			table.insert(content,getlocal("scout_position"))
			msgStr3=getlocal("world_war_power",{FormatNumber(tonumber(report.power))})
			table.insert(content,{msgStr3,G_ColorWhite})
			-- table.insert(content,{" ",G_ColorWhite})
			if base.isGlory==1 then
				if report.glory and report.glory[1] and report.glory[2] then
					msgStr4=getlocal("search_base_report_desc_3",{report.glory[1],report.glory[2]})
					table.insert(content,{msgStr4,G_ColorWhite})
					-- table.insert(content,{" ",G_ColorWhite})
				end
			end
			-- if report and report.place and report.place[1] then
			-- 	msgStr5=getlocal("search_base_report_desc_4",{report.place[1],report.place[2]})
			-- 	table.insert(content,{msgStr5,G_ColorWhite})
			-- 	table.insert(content,{" ",G_ColorWhite})
			-- elseif report and report.place and report.place.x then
			-- 	msgStr5=getlocal("search_base_report_desc_4",{report.place.x,report.place.y})
			-- 	table.insert(content,{msgStr5,G_ColorWhite})
			-- 	table.insert(content,{" ",G_ColorWhite})
			-- end
			-- local timeStr=G_getDataTimeStr(report.time,false,false)
			-- msgStr6=getlocal("search_base_report_desc_5",{timeStr})
			-- table.insert(content,{msgStr6,G_ColorWhite})
			-- table.insert(content,{" ",G_ColorWhite})
		elseif rtype==6 then
			local searchtype=report.searchtype
			print("searchtype",searchtype)
			if searchtype==1 then
				-- table.insert(content,{" ",G_ColorWhite})
				-- local timeStr=G_getDataTimeStr(report.time,false,false)
				-- msgStr1=getlocal("search_fleet_report_desc_1",{timeStr})
				-- table.insert(content,{msgStr1,G_ColorWhite})
				-- table.insert(content,{" ",G_ColorWhite})
				local nameStr=G_getIslandName(islandType,report.name)
				msgStr1=getlocal("scout_content_site")..nameStr.."Lv."..report.level
				table.insert(content,{msgStr1,G_ColorWhite})
				-- if report and report.place and report.place[1] then
				-- 	msgStr2=getlocal("search_fleet_report_desc_2",{nameStr,report.place[1],report.place[2]})
				-- 	table.insert(content,{msgStr2,G_ColorWhite})
				-- 	table.insert(content,{" ",G_ColorWhite})
				-- elseif report and report.place and report.place.x then
				-- 	msgStr2=getlocal("search_fleet_report_desc_2",{nameStr,report.place.x,report.place.y})
				-- 	table.insert(content,{msgStr2,G_ColorWhite})
				-- 	table.insert(content,{" ",G_ColorWhite})
				-- end
				msgStr3=getlocal("search_fleet_report_desc_3",{report.name})
				table.insert(content,{msgStr3,G_ColorWhite})
				-- table.insert(content,{" ",G_ColorWhite})
				table.insert(content,getlocal("scout_position"))
				msgStr4=getlocal("search_fleet_report_desc_4",{FormatNumber(tonumber(report.power))})
				table.insert(content,{msgStr4,G_ColorWhite})
				-- table.insert(content,{" ",G_ColorWhite})
				-- msgStr5=getlocal("search_fleet_report_desc_5",{GetTimeForItemStr(report.leftTime)})
				-- table.insert(content,{msgStr5,G_ColorWhite})
				-- table.insert(content,{" ",G_ColorWhite})
				-- msgStr6=getlocal("search_fleet_report_desc_6")
				-- table.insert(content,{msgStr6,G_ColorWhite})
				-- table.insert(content,{" ",G_ColorWhite})
			elseif searchtype==2 then
				-- table.insert(content,{" ",G_ColorWhite})
				msgStr1=getlocal("search_fleet_desc6")
				table.insert(content,{msgStr1,G_ColorWhite})
				-- table.insert(content,{" ",G_ColorWhite})
			elseif searchtype==3 then
				-- table.insert(content,{" ",G_ColorWhite})
				msgStr1=getlocal("search_fleet_desc4")
				table.insert(content,{msgStr1,G_ColorWhite})
				table.insert(content,{" ",G_ColorWhite})
				msgStr2=getlocal("search_fleet_desc5")
				table.insert(content,{msgStr2,G_ColorWhite})
				table.insert(content,{" ",G_ColorWhite})
			end
		elseif rtype==7 or rtype==8 or rtype==9 then
			local timeStr=G_getDataTimeStr(report.time,false,false)
			local nameStr=""
			if rtype==7 then
				nameStr=allianceCityVoApi:getAllianceCityName(report.name,report.level)
			elseif rtype==8 or rtype==9 then
				nameStr=report.name.."("..getlocal("fightLevel",{report.level})..")"
			end
			local color=G_ColorWhite
			-- if rtype==7 then
			-- 	msgStr1=getlocal("fight_content_place",{nameStr,report.place.x,report.place.y})
			-- else
			-- 	msgStr1=getlocal("def_content_place",{nameStr,report.place.x,report.place.y})
			-- end
			if rtype==7 or rtype==9 then
				msgStr1=getlocal("fight_content_site")..nameStr
			else
				msgStr1=getlocal("def_content_site")..nameStr
			end
			table.insert(content,{msgStr1,G_ColorWhite})
			if rtype==7 or rtype==9 then
				table.insert(content,{getlocal("fight_content_position"),G_ColorWhite})
			else
				table.insert(content,{getlocal("def_content_position"),G_ColorWhite})
			end

			if mineStateStr then
				table.insert(content,{mineStateStr,color})
			end
			-- msgStr2=getlocal("returnarrivade",{timeStr})
			-- table.insert(content,{msgStr2,G_ColorWhite})
		end
	end
	return content,color
end
