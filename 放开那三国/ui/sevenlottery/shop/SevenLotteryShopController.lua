-- FileName: SevenLotteryShopController.lua 
-- Author: fuqiongqiong
-- Date: 2016-8-4
-- Purpose: 七星台商店控制器

module("SevenLotteryShopController",package.seeall)
require "script/ui/sevenlottery/shop/SevenLotteryShopService"
function getShopInfo(callBack)
	local callBackFunc = function ( ... )
		if(callBack)then
			callBack()
		end
	end
	SevenLotteryShopService.getShopInfo(callBackFunc)
end

function buy(id,num,callBack)
	local callBackFunc = function ( ... )
		if(callBack)then
			callBack()
		end
		--扣梦魇积分币
		SevenLotteryShopLayer.refreshScoreNum()
		--刷新tableview
		SevenLotteryShopLayer.reloadDataFunc()
	end
	SevenLotteryShopService.buy(id,num,callBackFunc)
end