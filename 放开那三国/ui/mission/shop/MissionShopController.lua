module("MissionShopController",package.seeall)

require "script/ui/mission/shop/MissionShopData"
require "script/ui/mission/shop/MissionShopService"

--[[
	@des 	: 请求商店的数据
	@param 	: callBack：初始化数据后回调的函数
	@return : 
--]]
function getInfo(callBack)
	-- body
	MissionShopService.getInfo(function (ret)
		MissionShopData.setInfo(ret)
		callBack()
	end)
end
--[[
	@des 	: 兑换时的判断处理
	@param 	: id:商品ID,num:兑换次数,callFunc:判断完成后的回调
	@return : 
--]]
function exchange(id,num,callFunc)
	local shopInfo = MissionShopData.getShopInfo()[id]
	if (ItemUtil.isBagFull()) then
		MissionShopLayer.closeButtonCallFunc()
		return
	end
	if (tonumber(shopInfo.receiveTimes) < num) then
		AnimationTip.showTip(GetLocalizeStringBy("syx_1009"))
		return
	end
	if ((shopInfo.price * num) > UserModel.getFameNum()) then
		AnimationTip.showTip(GetLocalizeStringBy("syx_1010"))
		return
	end
	callFunc(shopInfo)
end
--[[
	@des 	: 兑换
	@param 	: shopInfo：商品信息，num：兑换的次数
	@return : 
--]]
function buy(shopInfo,num)
	MissionShopService.buy(shopInfo.id,num,function (ret)
		local fameNum = tonumber(shopInfo.price) * num
		UserModel.reduceFameNum(fameNum)
		MissionShopLayer.refresh()
	   	local itemInfo = ItemUtil.getItemById(shopInfo.goodID)
		AnimationTip.showTip(GetLocalizeStringBy("syx_1011",num * shopInfo.goodNum,itemInfo.name))
	end)
end

