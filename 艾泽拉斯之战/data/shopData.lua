local shopData = class("shopData")

 
function shopData:ctor()
	self.items = {}		
	for	i = enum.SHOP_TYPE.SHOP_TYPE_GOLD, enum.SHOP_TYPE.SHOP_TYPE_COUNT - 1 do
		self.items[i] = {}		
	end		
	self.shopReFreshNum = 0
	
	-- 上次点击时候刷新的key 九  零 一 起 玩 ww w .9 0  1 7 5. com
	self.notifyTimeClickFlag = -1;
	
end 	

function shopData:getShopReFreshNum()
	return self.shopReFreshNum
end	

function shopData:setShopReFreshNum(num)
	 self.shopReFreshNum = num
end		

function shopData:getShopReFreshTime()
	return self.shopReFreshTime
end	

function shopData:setShopReFreshTime(t)
	if(type(t) == "userdata")then
		 self.shopReFreshTime = t:GetUInt() 		
	else
		 self.shopReFreshTime  = t
	end	
end		




function shopData:getItemNums(s_type)
	if(s_type >= enum.SHOP_TYPE.SHOP_TYPE_COUNT or s_type < enum.SHOP_TYPE.SHOP_TYPE_GOLD )	then
		error("shopData:getItemNums s_type.."..s_type)
		return 0
	end
	return table.nums(self.items[s_type])
end

 ----pos 从0开始
function shopData:getItem(pos,s_type)	
	if(s_type >= enum.SHOP_TYPE.SHOP_TYPE_COUNT or s_type < enum.SHOP_TYPE.SHOP_TYPE_GOLD )	then
		error("shopData:getItem s_type.."..s_type)
		return 0
	end		
	local vec = self.items[s_type]	
	return vec[pos]
end 		

function shopData:getVec(s_type)
		return self.items[s_type]	
end	

function shopData:clearAllitem()
	
	--print("-----------------------------------shopData:clearAllitem()");
	
	for	i = enum.SHOP_TYPE.SHOP_TYPE_GOLD, enum.SHOP_TYPE.SHOP_TYPE_COUNT - 1 do
		
		local count = self:getItemNums(i);
		
		for pos=0, count-1 do
			
			self:delItem(pos, i);
			
		end
		
	end
	
end

function shopData:addItem(item,pos,s_type,delOld)
	
	if(s_type >= enum.SHOP_TYPE.SHOP_TYPE_COUNT or s_type < enum.SHOP_TYPE.SHOP_TYPE_GOLD )	then
		error("shopData:addItem s_type.."..s_type)
		return 0
	end	
	if(delOld)then
		self:delItem(pos,s_type)
	end
	local vec = self.items[s_type]
	vec[pos] = item	
	item:setPos(pos)
	item:setVec(s_type)	
end 


function shopData:newItem(rowIndex, arrayIndex,s_type,pos)
		
	local t = dataConfig.configs.shopConfig[rowIndex]	
	local tableIndex = 1+arrayIndex	
	if t then
		local _type,_id,_count,_price ,_money 
		if s_type == enum.SHOP_TYPE.SHOP_TYPE_GOLD then
			_type = t.goldGoodsType[tableIndex]	
			_id = t.goldGoodsID[tableIndex]	
			_count = t.goldGoodsCount[tableIndex]				
			_price = t.goldGoodsPrice[tableIndex]	
			_money = enum.MONEY_TYPE.MONEY_TYPE_GOLD
		elseif s_type == enum.SHOP_TYPE.SHOP_TYPE_DIAMOND then	
			_type = t.diamondGoodsType[tableIndex]	
			_id = t.diamondGoodsID[tableIndex]	
			_count = t.diamondGoodsCount[tableIndex]	
			_price = t.diamondGoodsPrice[tableIndex]	
			_money = enum.MONEY_TYPE.MONEY_TYPE_DIAMOND
			
		elseif s_type == enum.SHOP_TYPE.SHOP_TYPE_HONOR then	
			_type = t.honorGoodsType[tableIndex]	
			_id = t.honorGoodsID[tableIndex]	
			_count = t.honorGoodsCount[tableIndex]	
			_price = t.honorGoodsPrice[tableIndex]	
			_money = enum.MONEY_TYPE.MONEY_TYPE_HONOR
			
		elseif s_type == enum.SHOP_TYPE.SHOP_TYPE_CONQUEST then	
			_type = t.conquestGoodsType[tableIndex]	
			_id = t.conquestGoodsID[tableIndex]	
			_count = t.conquestGoodsCount[tableIndex]	
			_price = t.conquestGoodsPrice[tableIndex]	
			_money = enum.MONEY_TYPE.MONEY_TYPE_CONQUEST
		end			
		local	item = itemManager.createSpecial(_type,_id,_count)
		item:setSalePrice(_price)
		item:setSaleMoney(_money)		
		self:addItem(item,pos,s_type,true)
		return 	item
	end 
	return nil		
end



function shopData:delItem(pos,s_type)
	if(s_type >= enum.SHOP_TYPE.SHOP_TYPE_COUNT or s_type < enum.SHOP_TYPE.SHOP_TYPE_GOLD )	then
		error("shopData:delItem s_type.."..s_type)
		return 0
	end	
	local vec = self.items[s_type]
	local item = vec[pos]
	if(item)then		
		item:setPos(-1)
		item:setVec(-1)		
		itemManager.destroyItem(item:getIndex())
	end
	vec[pos] = 	nil
end 	

function shopData:hasNotifyState()

	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].shopLevelLimit)then
		return false;
	end

	-- 根据当前时间找到上一次刷新的时间的key
	local h, m, s = dataManager.getLocalTime();
	local nowTime = h*3600 + m*60 + s;

	local lastFreshKey = -1;
	
	local shopFresh = dataConfig.configs.ConfigConfig[0].shopRefleshTimes;
	for k,v in ipairs(shopFresh) do
		local hour, minute = stringToTime(v);
		local time = hour*3600 + minute*60;
		
		if nowTime < time then
		
			lastFreshKey = k-1;
			
			break;
		end
		
	end

	local serverTime = dataManager.getServerTime();
	local serverTimeZeroClock = 24 * 60 * 60 * math.floor(serverTime / (24 * 60 * 60)) + dataManager.timezone*3600;
	
	--local sererTimeTable = os.date("*t", sererTime);
	
	local lastFreshTime = 0;
		
	if lastFreshKey == 0 then
		-- 上次刷新是前一天的最后一个key
		local hour, minute = stringToTime(shopFresh[#shopFresh]);
		local time = hour*3600 + minute*60;
		
		--lastFreshTime = os.time({year = sererTimeTable.year, month = sererTimeTable.month, day = sererTimeTable.day-1, hour = 0, min = 0});
		lastFreshTime = serverTimeZeroClock - 24 * 60 * 60 + time;
		--lastFreshTime = lastFreshTime + time;
		
	elseif lastFreshKey == -1 then
		-- 上次刷新是当天的最后一个key
		local hour, minute = stringToTime(shopFresh[#shopFresh]);
		local time = hour*3600 + minute*60;
		
		--lastFreshTime = os.time({year = sererTimeTable.year, month = sererTimeTable.month, day = sererTimeTable.day, hour = 0, min = 0});
		--lastFreshTime = lastFreshTime + time;
		lastFreshTime = serverTimeZeroClock + time;
	else
		--
		local hour, minute = stringToTime(shopFresh[lastFreshKey]);
		local time = hour*3600 + minute*60;

		--lastFreshTime = os.time({year = sererTimeTable.year, month = sererTimeTable.month, day = sererTimeTable.day, hour = 0, min = 0});
		--lastFreshTime = lastFreshTime + time;
		
		lastFreshTime = serverTimeZeroClock + time;
	end
	
	return dataManager.playerData:getLastOpenShopTime() < lastFreshTime;
end

function shopData:clickNotify()

	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].shopLevelLimit)then
		return;
	end
		
	local h, m, s = dataManager.getLocalTime();
	local nowTime = h*3600 + m*60 + s;
	
	local shopFresh = dataConfig.configs.ConfigConfig[0].shopRefleshTimes;
	for k,v in ipairs(shopFresh) do
		local hour, minute = stringToTime(v);
		local time = hour*3600 + minute*60;
		
		if nowTime < time then
		
			nowTimeKey = k-1;
			
			break;
		end
		
	end
	
	self.notifyTimeClickFlag = nowTimeKey;
			
end

return shopData