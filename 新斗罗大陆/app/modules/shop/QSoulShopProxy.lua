-- @Author: liaoxianbo
-- @Date:   2020-07-13 12:04:36
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-29 11:12:34

local QBaseArenaShopProxy = import(".QBaseArenaShopProxy")
local QSoulShopProxy = class("QSoulShopProxy", QBaseArenaShopProxy)
local QVIPUtil = import("...utils.QVIPUtil")


function QSoulShopProxy:ctor(shopId)
	QSoulShopProxy.super.ctor(self, shopId)
end


function QSoulShopProxy:getResourcesItemId( )
	return 22 --魂师刷新令
end

function QSoulShopProxy:checkSpeckTips()
	local showTips = remote.stores:checkNewShopGoodsView(self.shopId)
	if showTips then
		self.chooseItem = {}
		app:getUserOperateRecord():setShopQuickBuyConfiguration(self.shopId,{})
		app.tip:floatTip("魂师大人，您已可以购买更高级物品，快去重新设置吧~")
	end
end

function QSoulShopProxy:getRefreshCount()
	local vip = db:getVipContnentByVipLevel(QVIPUtil:VIPLevel())
	return vip.ylshop_limit
end

return QSoulShopProxy