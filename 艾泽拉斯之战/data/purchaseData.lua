local purchaseData = class("purchaseData")

purchaseData.ITEM = 3 --  礼包，送审用
purchaseData.MONTH  = 2			--月卡
purchaseData.ONETIME  = 1			-- 购买1次
purchaseData.NORMAL  = 0		-- 无限次

function purchaseData:ctor()
	self.monthTypeInfo = {}
	self.onTimeTypeInfo = {}
	self.items = {}
	self.itemsNeedBuild = true 
	
end
	
function purchaseData:buildMONTH(id)
	
		local premiseitem = self.items[dataConfig.configs.rechargeConfig[id].premise]	
		if(premiseitem)then
			return
		end
		if(self.monthTypeInfo [id] )then
		
			self.items[id] = {id = id,time = self.monthTypeInfo [id].time }
			
		else
			self.items[id] = {id = id }	
		end
end	

function purchaseData:buildOnetime(id)
	
		local premiseitem = self.items[dataConfig.configs.rechargeConfig[id].premise]	
		if(premiseitem)then
			return
		end	
		
		if(self.onTimeTypeInfo [id])then
			return 
		end	
		self.items[id] = {id = id}
end	

function purchaseData:buildNormal(id)
		local premiseitem = self.items[dataConfig.configs.rechargeConfig[id].premise]	
		if(premiseitem)then
			return
		end	
		self.items[id] = {id = id}
end	

-- 得到一件商品是否已经
function purchaseData:isItemAlreadyBuyed(id)
	
	return dataManager.playerData:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_LIMIT_RECHARGE, id) > 0;
	
end

function purchaseData:getItems()
	
	local showItems = {};
	for k,v in ipairs(dataConfig.configs.rechargeConfig) do
		
		local itemID = {id = v.id};
		local showflag = false;
		
		if purchaseData.MONTH == v.type then
		
			-- 月卡
			-- 送审不显示
			showflag = not GLOBAL_CONFIG_BLOCK_VIP;
			
		elseif purchaseData.ONETIME == v.type then
			
			showflag = not self:isItemAlreadyBuyed(v.id);
			
		elseif purchaseData.NORMAL == v.type then
			
			if v.premise > 0 then
				showflag = self:isItemAlreadyBuyed(v.premise);
			else
				showflag = true;
			end
			
		elseif purchaseData.ITEM == v.type then
			
			-- 送审显示的礼包
			showflag = GLOBAL_CONFIG_BLOCK_VIP;
			
		end
		
		if showflag then
			table.insert(showItems, itemID);
		end
	end

	function sortpurchaseItems(a, b)	
		return dataConfig.configs.rechargeConfig[a.id].drawOrder < dataConfig.configs.rechargeConfig[b.id].drawOrder
	end
			
	table.sort(showItems, sortpurchaseItems)
		
	-- 根据服务器数据填充显示的物品
	return showItems;
	
end 	

function purchaseData:getItemConfig(id)
	return dataConfig.configs.rechargeConfig[id];
end



return purchaseData