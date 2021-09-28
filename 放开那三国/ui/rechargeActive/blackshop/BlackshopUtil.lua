-- FileName: BlackShopUtil.lua 
-- Author: yangrui 
-- Date: 15-09-10
-- Purpose: function description of module 

module ("BlackshopUtil", package.seeall)

--[[
	@des    : 判断是否可以兑换
	@param  : pid
	@return : 可以兑换 true  不可以兑换  false
--]]
function isCanConvert( pId, pGoodNum )
	local pid = tonumber(pId)
	local goodNum = tonumber(pGoodNum)
	local ret = false
	local reqItems = BlackshopData.getConvertNeedItem(pid)
	
	local isCan = true
	local canConvertNum = 0
	local haveSilverNum = 0
	local haveGodlNum = 0
	local havePrestigeNum = 0
	local haveHonorNum = 0
	local haveItemNum = 0
	for i=1,#reqItems do
		if ( reqItems[i].type == "silver" ) then
			haveSilverNum = UserModel.getSilverNumber()
		elseif (reqItems[i].type == "gold") then
			haveGodlNum = UserModel.getGoldNumber()
		elseif (reqItems[i].type == "prestige") then
			havePrestigeNum = UserModel.getPrestigeNum()
		elseif (reqItems[i].type == "honor") then
			haveHonorNum = UserModel.getHonorNum()
		elseif ( reqItems[i].type == "item" ) then
			haveItemNum = ItemUtil.getCacheItemNumByTidAndLv(tonumber(reqItems[i].tid))
		end
	end
	print("===|number|===",haveSilverNum,haveGodlNum,havePrestigeNum,haveHonorNum,haveItemNum)
	for i=1,goodNum do
		for i=1,#reqItems do
			if ( reqItems[i].type == "silver" ) then
				local needNum = reqItems[i].num
				if ( tonumber(haveSilverNum) < tonumber(needNum) ) then
					isCan = false
					break
				end
				haveSilverNum = haveSilverNum - needNum
			elseif (reqItems[i].type == "gold") then
				local needNum = reqItems[i].num
				if ( tonumber(haveGodlNum) < tonumber(needNum) ) then
					isCan = false
					break
				end
				haveGodlNum = haveGodlNum - needNum
			elseif (reqItems[i].type == "prestige") then
				local needNum = reqItems[i].num
				if ( tonumber(havePrestigeNum) < tonumber(needNum) ) then
					isCan = false
					break
				end
				havePrestigeNum = havePrestigeNum - needNum
			elseif (reqItems[i].type == "honor") then
				local needNum = reqItems[i].num
				if ( tonumber(haveHonorNum) < tonumber(needNum) ) then
					isCan = false
					break
				end
				haveHonorNum = haveHonorNum - needNum
			elseif ( reqItems[i].type == "item" ) then
				local needNum = reqItems[i].num
				if ( tonumber(haveItemNum) < tonumber(needNum) ) then
					isCan = false
					break
				end
				haveItemNum = haveItemNum - needNum
			end
		end
		if isCan == false then
			break
		end
		canConvertNum = canConvertNum + 1
		print("===|inner number|===",haveSilverNum,haveGodlNum,havePrestigeNum,haveHonorNum,haveItemNum)
	end

	if ( isCan ) then
		ret = true
	end

	return ret,canConvertNum
end
