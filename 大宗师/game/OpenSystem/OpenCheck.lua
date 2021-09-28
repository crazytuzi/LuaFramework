--[[
 --
 -- add by vicky
 -- 2014.09.15
 --
 --]]

 
 

 local OpenCheck = {} 


 -- 根据Id，返回，此功能是否已开放，及提示语 
 function OpenCheck.getOpenLevelById(id, curLevel, curVipLevel)
 	local needLevel = -1 
 	local needVipLevel = -1  
 	local bNeedAll = true  
 	local bHasOpen = false 
 	local prompt = "" 
 	local data_open_open = require("data.data_open_open") 
 	for i, v in ipairs(data_open_open) do 
 		if v.system == id then 
 			if v.level ~= nil and #v.level > 0 then 
 				needLevel = v.level[1] 
 			end 
 			if v.vip ~= nil then 
 				needVipLevel = v.vip 
 			end 

 			if v.need_all == 1 then 
 				bNeedAll = true 
 			elseif v.need_all == 2 then 
 				bNeedAll = false  
 			end 

 			prompt = v.prompt1 or "" 
 			break 
 		end 
 	end 

 	if bNeedAll then 
 		if curLevel >= needLevel and curVipLevel >= needVipLevel then 
 			bHasOpen = true 
 		end  
 	else
 		if curLevel >= needLevel or curVipLevel >= needVipLevel then 
 			bHasOpen = true 
 		end 
 	end 

 	if(GAME_DEBUG == true) then 
		-- bHasOpen = true  
	end

 	return bHasOpen, prompt 
 end 

--
 -- 根据等级判断是否有新的功能开启 
 function OpenCheck.checkIsOpenNewFuncByLevel(beforeLevel, curLevel )  -- 升级前的等级、升级后的等级
 	local open = false 
 	local openSystems = {}
 	if beforeLevel < curLevel then 
 		local disLv = curLevel - beforeLevel 
 		local data_open_open = require("data.data_open_open") 
 		for k = 1, disLv do 
 			local level = beforeLevel + k 
		 	for i, v in ipairs(data_open_open) do 
		 		if v.prama_num ~= nil and v.prama_num > 0 and v.arr_needLevel ~= nil and #v.arr_needLevel > 0 then
			 		for j, vl in ipairs(v.arr_needLevel) do 
			 			if level == vl then 
			 				open = true 
			 				table.insert(openSystems, v.system)
				 			break
				 		end
			 		end
			 	end
		 	end
		end 
	end

 	return open, openSystems
 end


 return OpenCheck 
