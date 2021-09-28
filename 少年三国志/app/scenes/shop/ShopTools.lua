local ShopTools = class("ShopTools")

function ShopTools.sendGodlyKnightDrop()
	local CheckFunc = require("app.scenes.common.CheckFunc")
	local scenePack = G_GlobalFunc.sceneToPack("app.scenes.shop.ShopScene", {})
	if CheckFunc.checkKnightFull(scenePack) then
	    return
	end
	if not G_Me.shopData:isGodlyKnightDropEnabled() then
	    require("app.scenes.shop.GoldNotEnoughDialog").show()
	    return
	end
	local BagConst = require("app.const.BagConst")
	local tokenCount = G_Me.bagData:getGodlyKnightTokenCount()
	local leftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.jp_free_time)
	local isFree = leftTime < 0
	if isFree then
		G_HandlersManager.shopHandler:sendDropGodlyKnight(BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.FREE)
	elseif tokenCount > 0 then
		G_HandlersManager.shopHandler:sendDropGodlyKnight(BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.TOKEN)
	else
		G_HandlersManager.shopHandler:sendDropGodlyKnight(BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.MONEY)
	end
end

function ShopTools.sendGoodKnightDrop()
	local CheckFunc = require("app.scenes.common.CheckFunc")
	local scenePack = G_GlobalFunc.sceneToPack("app.scenes.shop.ShopScene", {})
	if CheckFunc.checkKnightFull(scenePack) then
	    return
	end
	local BagConst = require("app.const.BagConst")
	local tokenCount = G_Me.bagData:getGoodKnightTokenCount()
	local leftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.lp_free_time)
	local isFree = leftTime < 0 and G_Me.shopData.dropKnightInfo.lp_free_count < 3
	if tokenCount == 0 and (not isFree) then
	    G_MovingTip:showMovingTip(G_lang:get("LANG_ZHAN_JIANG_LING_NOT_ENOUGH"))
	    return
	end
	if isFree then
	    G_HandlersManager.shopHandler:sendDropGoodKnight(BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.FREE)
	else
	    G_HandlersManager.shopHandler:sendDropGoodKnight(BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.TOKEN)
	end 
end

--阵营抽将
function ShopTools.sendZhenYingKnightDrop()
	local FunctionLevelConst = require("app.const.FunctionLevelConst")
	if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.ZHEN_YING_ZHAO_MU) then 
        return 
    end
	--检查元宝
	local curTimes = G_Me.shopData.dropKnightInfo.zy_recruited_times
	if curTimes >= 15 then
		return
	end
	local info = camp_drop_info.get(curTimes+1)
	if not info then
		return
	end
	if G_Me.userData.gold < info.cost then
		require("app.scenes.shop.GoldNotEnoughDialog").show()
		return
	end
	local CheckFunc = require("app.scenes.common.CheckFunc")
	if CheckFunc.checkDiffByType(G_Goods.TYPE_KNIGHT) then 
	    return 
	end

	G_HandlersManager.shopHandler:sendZhenYingDropKnight()
end

--获取价格
function ShopTools.getPrice(id,num)
	local info = ShopTools.getPriceInfo(id,num)
	if not info then
		--表有问题
		return -1
	end
	return info.price
end

--获取价格
function ShopTools.getPriceInfo(id,num)
	require("app.cfg.shop_price_info")
	local len = shop_price_info.getLength()
	for i=1,len do
		local item01 = shop_price_info.indexOf(i)
		local item02 = shop_price_info.indexOf(i+1)
		--必须ID一致
		if item01.id == id then
			if item02 and table.nums(item02) > 0 then
				if item02.id == id then
					if item01.num <= num and item02.num > num then
						return item01
					end
				else
					return item01
				end
			else
				return item01
			end
		end

	end
	return nil
end

return ShopTools