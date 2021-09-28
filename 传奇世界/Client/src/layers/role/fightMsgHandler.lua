
local fightLog = function(Buff)
	local writeToFile = function(stringTemp)
		local fightKeep = {}
		local temp = 0
		local setfile = getDownloadDir().."fight_"..tostring(userInfo.currRoleStaticId)..".cfg"
		local file = io.open(setfile,"r")
		if file then
			local line = file:read()
			while line do
				temp = temp + 1
				table.insert(fightKeep,line)
				line = file:read()
				
			end
			file:close()
		end
		if temp and temp >= 50 then
			table.remove(fightKeep,1)
			table.remove(fightKeep)
		end

	----------------------------------------------------------------	
		table.insert(fightKeep,stringTemp)
		local sum = 0
		local str = nil
		local str1 = nil
		if #fightKeep > 1 then
			for i=#fightKeep-1,#fightKeep do
				local pos = string.find(fightKeep[i],",")
				str = string.sub(fightKeep[i],1,pos-1)
				str1 = string.sub(fightKeep[i],pos,-1)
				sum = sum + tonumber(str)
				fightKeep[i] = tostring(sum)..str1
			end
		end
		local file1 = io.open(setfile,"w+")
		if file1 then
			for i=1,#fightKeep do
				file1:write(fightKeep[i])
				file1:write("\n")
			end
			file1:close()
		end
	end
	local xx = 0
	local theTime = os.time()
	local fightList = {}
	local stringTemp = nil
	if Buff then
		local t = g_msgHandlerInst:convertBufferToTable("FightNotifyProtocol", Buff)
		fightList = {
						theTime,
						t.notifyType,
						t.targetName,
						t.mapName,
					}
		if SOCIAL_DATA then SOCIAL_DATA:checkHandler( fightList ) end
		if fightList and fightList[2] == 1 and fightList[3] then
			TIPS( { type = 1 , totalNumSet = 1 , str = string.format(game.getStrByKey("social_tip_kill"),fightList[3]) } )
		end
	end

	if tonumber(fightList[2]) == 1 or tonumber(fightList[2]) == 4 then
		xx = 1
	end
	stringTemp = tostring(xx)..","..tostring(fightList[1])..","..tostring(fightList[2])..","..tostring(fightList[3])..","..tostring(fightList[4])
	writeToFile(stringTemp)

	
end

g_msgHandlerInst:registerMsgHandler(RELATION_SC_FIGHT_NOTIFY,fightLog)

