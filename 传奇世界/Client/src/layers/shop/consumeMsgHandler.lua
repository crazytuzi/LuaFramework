
local writeToFile = function(stringTemp)
	local consumeKeep = {}
	local temp = 0
	local temp1 = 0

	local setfile = getDownloadDir().."consume"..tostring(userInfo.currRoleStaticId)..".cfg"
	local file = io.open(setfile,"r")
	if file then
		local line = file:read()
		while line do
			local pos = string.find(line,",")
			if tonumber(string.sub(line,1,pos-1)) == 1 then
				temp = temp + 1
			elseif tonumber(string.sub(line,1,pos-1)) == 2 then
				temp1 = temp1 + 1
			end
			table.insert(consumeKeep,line)
			line = file:read()
			
		end
		file:close()
	end
	if temp and temp1 and (temp >= 30 or temp1 >= 30) then
		table.remove(consumeKeep,1)
		-- table.remove(consumeKeep)
	end
----------------------------------------------------------------	
	table.insert(consumeKeep,stringTemp)
	local sum = 0
	-- local str = nil
	-- local str1 = nil
	-- if #consumeKeep > 1 then
	-- 	for i=#consumeKeep-1,#consumeKeep do
	-- 		local pos = string.find(consumeKeep[i],",")
	-- 		str = string.sub(consumeKeep[i],1,pos-1)
	-- 		str1 = string.sub(consumeKeep[i],pos,-1)
	-- 		sum = sum + tonumber(str)
	-- 		consumeKeep[i] = tostring(sum)..str1
	-- 	end
	-- end
	local file1 = io.open(setfile,"w+")
	if file1 then
		for i=1,#consumeKeep do
			file1:write(consumeKeep[i])
			file1:write("\n")
		end
		file1:close()
	end
end

local consumeLog = function(Buff)
	local xx = 0
	local consumeList = {}
	local stringTemp = nil
	if Buff then
		consumeList = {
						Buff:popInt(),        --货币
						Buff:popInt(),		  --时间
						Buff:popInt(),		--操作
						Buff:popInt(),		--数值
						Buff:popInt(),		--剩余
					}
	end

	stringTemp = tostring(consumeList[1])..","..tostring(consumeList[2])..","..tostring(consumeList[3])..","..tostring(consumeList[4])..","..tostring(consumeList[5])
	writeToFile(stringTemp)

	
end

g_msgHandlerInst:registerMsgHandler(ACTIVITY_SC_RECORD_RET,consumeLog)

