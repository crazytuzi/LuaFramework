-- @Author: liaoxianbo
-- @Date:   2020-07-29 11:21:25
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-29 11:22:07

local QBaseArenaShopProxy = import(".QBaseArenaShopProxy")
local QGroceriesShopProxy = class("QGroceriesShopProxy", QBaseArenaShopProxy)
local QVIPUtil = import("...utils.QVIPUtil")


function QGroceriesShopProxy:ctor(shopId)
	QGroceriesShopProxy.super.ctor(self, shopId)
end

function QGroceriesShopProxy:getRefreshCount()
	local vip = db:getVipContnentByVipLevel(QVIPUtil:VIPLevel())
	return vip.ptshop_limit
end

return QGroceriesShopProxy