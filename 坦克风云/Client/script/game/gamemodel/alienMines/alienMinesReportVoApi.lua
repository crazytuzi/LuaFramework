require "luascript/script/game/gamemodel/alienMines/alienMinesBattleReportVo"
require "luascript/script/game/gamemodel/alienMines/alienMinesScoutReportVo"
require "luascript/script/game/gamemodel/alienMines/alienMinesReturnReportVo"

alienMinesReportVoApi={
	battleReport=nil,
	scoutReport=nil,
	returnReport=nil,
}

function alienMinesReportVoApi:getReport(rid)
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
		-- end
	return nil
end

function alienMinesReportVoApi:addReport(type,data)
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

			-- if award then
			-- 	for k,v in pairs(award) do
			-- 		if v and v.id and v.name then
			-- 			if v.id==20 then
			-- 				local evo=alienMinesEmailVoApi:getEmailByEid(2,data.rid)
			-- 				if evo and evo.isRead==0 then
			-- 					-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage4",{playerVoApi:getPlayerName(),v.name}))
   --      						local pid="p"..v.id
   --      						local prop=propCfg[pid]
   --      						local nameData={key=prop.name,param={}}
			-- 					local message={key="chatSystemMessage4",param={playerVoApi:getPlayerName(),nameData}}
   --              				chatVoApi:sendSystemMessage(message)
			-- 				end
			-- 			end
			-- 		end
			-- 	end
			-- end

	        local vo = alienMinesBattleReportVo:new()
	        vo:initWithData(data.rid,data.type,data.islandType,data.attacker,data.defender,data.place,data.level,data.time,data.islandOwner,data.isVictory,award,resource,lostShip,credit,helpDefender,data.report,data.attackerPlace,data.accessory,data.aLandform,data.dLandform,data.acaward,data.rp,data.hero,data.emblemID,data.plane,data.weapon,data.armor,data.troops,data.aitroops,data.ri,data.ap)
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
	        local vo = alienMinesScoutReportVo:new()
	        vo:initWithData(data.rid,data.type,data.islandType,data.defender,data.place,data.level,data.time,data.islandOwner,resource,defendShip,helpDefender,data.allianceName,data.landform,data.richLevel,data.skin)
	        table.insert(self.scoutReport,vo)
			return vo
		elseif type==3 then
			if self.returnReport==nil then
				self.returnReport={}
			end
	        local vo = alienMinesReturnReportVo:new()
	        vo:initWithData(data.rid,data.type,data.returnType,data.islandType,data.place,data.level,data.alienPoint,data.aAlienPoint,resource,data.time)
	        table.insert(self.returnReport,vo)
			return vo
		end
	end
	return nil
end

function alienMinesReportVoApi:deleteReport(rid)
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

function alienMinesReportVoApi:deleteAll()
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

function alienMinesReportVoApi:formatReportData(report)
	local islandType=1
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
	local richLevel=0
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
		end
	end
	return islandType,attacker,defender,attackerAllianceName,defenderAllianceName,helpDefender,helpDefenderAllianceName,hasHelpDefender,aLandform,dLandform,landform,richLevel
end

function alienMinesReportVoApi:getReportContent(report,chatSender)
	local content={}
	local color={}
	local msgStr1=""
	local msgStr2=""
	local msgStr3=""
	local msgStr4=""
	local msgStr5=""
	local msgStr6=""
	local islandType,attacker,defender,attackerAllianceName,defenderAllianceName,helpDefender,helpDefenderAllianceName,hasHelpDefender,aLandform,dLandform,landform,richLevel=self:formatReportData(report)
	if report and SizeOfTable(report)>0 and report.type then
		local rtype=report.type
		if rtype==3 then
			msgStr1=getlocal("alienMines_return_report_site")..G_getAlienIslandName(islandType).."Lv."..report.level
			table.insert(content,{msgStr1,G_ColorWhite})
			msgStr2=getlocal("alienMines_return_report_pos")
			table.insert(content,{msgStr2,G_ColorWhite})
			--[[
			local returnType=report.returnType
			if returnType==1 then
				msgStr1=getlocal("alienMines_return_desc_1")
			else
				msgStr1=getlocal("alienMines_return_desc_2")
			end
			G_dayin(report)
			print("report.time=======>>>>",report.time)
			msgStr2=getlocal("alienMines_return_desc_3",{G_getAlienIslandName(islandType),report.level,report.place.x,report.place.y})
			msgStr3=getlocal("alienMines_return_desc_4",{alienMinesEmailVoApi:getTimeStr(report.time)})
			content={msgStr1,msgStr2,msgStr3}
			--]]
		elseif rtype==2 then
			msgStr1=getlocal("scout_content_site")..G_getAlienIslandName(islandType).."Lv."..report.level
			table.insert(content,{msgStr1,G_ColorWhite})
			msgStr2=getlocal("scout_position")
			table.insert(content,{msgStr2,G_ColorWhite})
			--是否有驻军
			if report.islandOwner and report.islandOwner>0 then
				msgStr5=getlocal("scout_content_defend_name",{defender})
			else
				msgStr5=getlocal("scout_content_defend_name",{getlocal("fight_content_null")})
			end
			table.insert(content,{msgStr5,G_ColorWhite})
			--[[
			local defenderStr
			local terrainStr
			local richMineStr
			-- if islandType==6 then
			-- 	if hasHelpDefender==true then
			-- 		defenderStr=getlocal("fight_content_fight_type_8_1",{helpDefender})
			-- 	else
			-- 		defenderStr=getlocal("fight_content_fight_type_8_2")
			-- 	end
			-- 	msgStr1=getlocal("scout_content_player",{defender,report.place.x,report.place.y})
			-- 	if landform and landform~="" then
			-- 		terrainStr=getlocal("scout_content_terrain",{landform})
			-- 	end
			-- elseif islandType<6 then
				if report.islandOwner>0 then
					defenderStr=getlocal("scout_content_defend_name",{defender})
				else
					defenderStr=getlocal("scout_content_defend_name",{getlocal("fight_content_null")})
				end
				msgStr1=getlocal("scout_content_island",{G_getAlienIslandName(islandType),report.level,report.place.x,report.place.y})
				-- if landform and landform~="" then
				-- 	terrainStr=getlocal("scout_content_terrain",{landform})
				-- end
			-- end
			local msgStr2=getlocal("scout_content_time",{alienMinesEmailVoApi:getTimeStr(report.time)})
			content={{msgStr1,G_ColorWhite}}
			-- if terrainStr then
			-- 	table.insert(content,{terrainStr,G_ColorWhite})
			-- 	content={msgStr1,terrainStr,msgStr2,defenderStr}
			-- else
			-- 	content={msgStr1,msgStr2,defenderStr}
			-- end
			table.insert(content,{msgStr2,G_ColorWhite})
			if base.landFormOpen==1 and base.richMineOpen==1 and richLevel and richLevel>0 then
				if mapHeatCfg.resourceSpeed[richLevel] then
					richMineStr=getlocal("scout_content_rich_mine",{richLevel,(tonumber(mapHeatCfg.resourceSpeed[richLevel])+1)*100})
					local strColor=worldBaseVoApi:getRichMineColorByLv(richLevel)
					table.insert(content,{richMineStr,strColor})
				end
			end
			table.insert(content,{defenderStr,G_ColorWhite})
			--]]
		elseif rtype==1 then
			local isAttacker=alienMinesEmailVoApi:isAttacker(report,chatSender)
			local target=""
			local terrainStr1
			local terrainStr2
			if isAttacker==true then
				-- if aLandform and aLandform~="" then
				-- 	terrainStr1=getlocal("fight_content_terrain_1",{aLandform})
				-- end
				-- if islandType==6 then
				-- 	target=defender
				-- 	if hasHelpDefender==true then
				-- 		msgStr1=getlocal("fight_content_fight_type_2",{helpDefender})
				-- 	else
				-- 		msgStr1=getlocal("fight_content_fight_type_2",{target})
				-- 	end
				-- 	-- if dLandform and dLandform~="" then
				-- 	-- 	terrainStr2=getlocal("fight_content_terrain_2",{dLandform})
				-- 	-- end
				-- elseif islandType<6 then
					if report.islandOwner>0 then
						target=defender
						msgStr1=getlocal("fight_content_fight_type_5",{target,G_getAlienIslandName(islandType)})
						msgStr5=getlocal("alienMines_battle_enemy_desc",{target..defenderAllianceName})
					else
						target=G_getAlienIslandName(islandType)
						msgStr1=getlocal("fight_content_fight_type_1",{target,report.level})
						msgStr5=getlocal("alienMines_battle_enemy_desc",{getlocal("buildNameAndLevel",{target,report.level})})
					end
					-- if dLandform and dLandform~="" then
					-- 	terrainStr2=getlocal("fight_content_terrain_2",{dLandform})
					-- end
				-- end
				if chatSender then
					msgStr2=getlocal("fight_content_place1",{target})
				else
					msgStr2=getlocal("fight_content_place",{target,report.place.x,report.place.y})
				end
				msgStr3=getlocal("fight_content_time",{alienMinesEmailVoApi:getTimeStr(report.time)})
				local resultStr=getlocal("fight_content_result")..getlocal("fight_content_attack_type")
				if report.isVictory==1 then
					msgStr4={resultStr..getlocal("fight_content_result_win"),G_ColorGreen}
				else
					msgStr4={resultStr..getlocal("fight_content_result_defeat"),G_ColorRed}
				end

				
				-- local credit=report.credit
				-- if credit==0 then
				-- 	msgStr5=getlocal("email_honor").."0"
				-- else
				-- 	if report.isVictory==1 then
				-- 		msgStr5=getlocal("email_honor").."+"..tostring(credit)
				-- 	else
				-- 		msgStr5=getlocal("email_honor").."-"..tostring(credit)
				-- 	end
				-- end
				-- local rankPoint=0
				-- if report.rp and report.rp[1] and tonumber(report.rp[1]) then
				-- 	rankPoint=tonumber(report.rp[1]) or 0
				-- end
				-- if rankPoint==0 then
				-- 	msgStr6=getlocal("email_rankPoint").."0"
				-- else
				-- 	if rankPoint>0 then
				-- 		msgStr6=getlocal("email_rankPoint").."+"..tostring(rankPoint)
				-- 	else
				-- 		msgStr6=getlocal("email_rankPoint").."-"..tostring(rankPoint)
				-- 	end
				-- end
				-- if terrainStr1 and terrainStr2 then
				-- 	content={msgStr1,msgStr2,terrainStr1,terrainStr2,msgStr3,msgStr4,msgStr5,msgStr6}
				-- elseif terrainStr1 then
				-- 	content={msgStr1,msgStr2,terrainStr1,msgStr3,msgStr4,msgStr5,msgStr6}
				-- elseif terrainStr2 then
				-- 	content={msgStr1,msgStr2,terrainStr2,msgStr3,msgStr4,msgStr5,msgStr6}
				-- else
					content={msgStr1,msgStr5,msgStr2,msgStr3,msgStr4}
				-- end
			else
				-- if aLandform and aLandform~="" then
				-- 	terrainStr1=getlocal("fight_content_terrain_3",{aLandform})
				-- end
				-- if islandType==6 then
				-- 	if hasHelpDefender==true then
				-- 		msgStr1=getlocal("fight_content_fight_type_9",{attacker})
				-- 	else
				-- 		msgStr1=getlocal("fight_content_fight_type_3",{attacker})
				-- 	end	
				-- 	-- if dLandform and dLandform~="" then
				-- 	-- 	terrainStr2=getlocal("fight_content_terrain_4",{dLandform})
				-- 	-- end
				-- elseif islandType<6 then
					msgStr1=getlocal("fight_content_fight_type_4",{G_getAlienIslandName(islandType),attacker})
					-- if dLandform and dLandform~="" then
					-- 	terrainStr2=getlocal("fight_content_terrain_4",{dLandform})
					-- end
				-- end
				msgStr5=getlocal("alienMines_battle_enemy_desc",{attacker})
				if chatSender then
					msgStr2=getlocal("fight_content_place1",{defender})
				else
					msgStr2=getlocal("fight_content_place",{defender,report.place.x,report.place.y})
				end
				msgStr3=getlocal("fight_content_time",{alienMinesEmailVoApi:getTimeStr(report.time)})
				local resultStr=getlocal("fight_content_result")..getlocal("fight_content_defende_type")
				if report.isVictory==1 then
					msgStr4={resultStr..getlocal("fight_content_result_defeat"),G_ColorRed}
				else
					msgStr4={resultStr..getlocal("fight_content_result_win"),G_ColorGreen}
				end
				-- local credit=report.credit
				-- if credit==0 then
				-- 	msgStr5=getlocal("email_honor").."0"
				-- else
				-- 	if report.isVictory==1 then
				-- 		msgStr5=getlocal("email_honor").."-"..tostring(credit)
				-- 	else
				-- 		msgStr5=getlocal("email_honor").."+"..tostring(credit)
				-- 	end
				-- end
				-- local rankPoint=0
				-- if report.rp and report.rp[2] and tonumber(report.rp[2]) then
				-- 	rankPoint=tonumber(report.rp[2]) or 0
				-- end
				-- if rankPoint==0 then
				-- 	msgStr6=getlocal("email_rankPoint").."0"
				-- else
				-- 	if rankPoint>0 then
				-- 		msgStr6=getlocal("email_rankPoint").."+"..tostring(rankPoint)
				-- 	else
				-- 		msgStr6=getlocal("email_rankPoint").."-"..tostring(rankPoint)
				-- 	end
				-- end
				-- if terrainStr1 and terrainStr2 then
				-- 	content={msgStr1,msgStr2,terrainStr1,terrainStr2,msgStr3,msgStr4,msgStr5,msgStr6}
				-- elseif terrainStr1 then
				-- 	content={msgStr1,msgStr2,terrainStr1,msgStr3,msgStr4,msgStr5,msgStr6}
				-- elseif terrainStr2 then
				-- 	content={msgStr1,msgStr2,terrainStr2,msgStr3,msgStr4,msgStr5,msgStr6}
				-- else
					content={msgStr1,msgStr5,msgStr2,msgStr3,msgStr4}
				-- end
			end
		end
	end
	return content,color
end
