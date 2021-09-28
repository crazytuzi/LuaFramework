-- FileName: DevilTowerShopController.lua 
-- Author: fuqiongqiong
-- Date: 2016-7-29
-- Purpose:试练塔商店控制器

module("DevilTowerShopController",package.seeall)
require "script/ui/deviltower/shop/DevilTowerShopService"


-- /**
--  * 获取商店信息
--  * @return array
--  *         [
--  *             'point':int     剩余积分
--  *             'info' : array  购买信息
--  *                         [
--  *                             id => num
--  *                         ]
--  *         ]
--  */
function getShopInfo(callBack)
	local callBackFunc = function ( ... )
		if(callBack)then
			callBack()
		end
	end
	DevilTowerShopService.getShopInfo(callBackFunc)
end

-- /**
--  * 购买商品
--  * @param int $id  商品id
--  * @param int $num 数量
--  * @return 'ok'
--  */
function buy(id,num,callBack)
	local callBackFunc = function ( ... )
		if(callBack)then
			callBack()
		end
		--扣梦魇积分币
		DevilTowerShopLayer.updateWmLable()
		--刷新tableview
		DevilTowerShopLayer.updateCell()
	end
	DevilTowerShopService.buy(id,num,callBackFunc)
end