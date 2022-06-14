vipGiftData = class("vipGiftData")

function vipGiftData:ctor()
		
end

function vipGiftData:destroy()
	
end

function vipGiftData:init()
	
	self.vipGifts = {};
	
	-- 初始化所有的礼包信息
	local count = table.nums(dataConfig.configs.vipConfig);
	
	for i=0, count-1 do
		local vipConfig = dataConfig.configs.vipConfig[i];
		
		local gift = {};
		
		gift.giftPrice = vipConfig.giftPrice;
		gift.giftPrimeCost = vipConfig.giftPrimeCost;
		gift.viplevel = i;
		gift.items = {};
		
		for k, v in ipairs(vipConfig.giftType) do
			
			local item = {
				giftType = v;
				giftID = vipConfig.giftID[k];
				giftCount = vipConfig.giftCount[k];
			};
			
			table.insert(gift.items, item);
			
		end
		
		table.insert(self.vipGifts, gift);
	end
	
end

-- 获得所有的礼包信息
function vipGiftData:getAllGift()

	return self.vipGifts;
	
end

function vipGiftData:getGiftByVipLevel(viplevel)
	
	for k,v in pairs(self.vipGifts) do
		
		if v.viplevel == viplevel then
			
			return v;
		end
		
	end
	
end

-- 点击对应的vip 礼包
function vipGiftData:onClickGift(vipLevel)
	
	-- handle
	local nowLevel = dataManager.playerData:getVipLevel();
	if nowLevel < vipLevel then
		eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "^FF0000您的VIP等级未达到礼包购买要求"})
		return;
	end
	
	local gift = self:getGiftByVipLevel(vipLevel);
	
	if gift.giftPrice > dataManager.playerData:getGem() then
		eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });
				
		return;			
	end
	
	sendAgiotage(enum.AGIOTAGE_TYPE.AGIOTAGE_TYPE_VIG_GIFT, vipLevel);
end

-- 是否买过了礼包
function vipGiftData:isGiftAlreadyBuyed(vipLevel)

	return dataManager.playerData:getCounterArrayData(enum.COUNTER_ARRAY_TYPE.COUNTER_ARRAY_TYPE_VIP_GIFT, vipLevel+1) > 0;
	
end
