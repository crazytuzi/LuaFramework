-- @Author: liaoxianbo
-- @Date:   2020-07-29 11:19:31
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-29 11:20:32

local QBaseArenaShopProxy = import(".QBaseArenaShopProxy")
local QBalckShopProxy = class("QBalckShopProxy", QBaseArenaShopProxy)
local QVIPUtil = import("...utils.QVIPUtil")


function QBalckShopProxy:ctor(shopId)
	QBalckShopProxy.super.ctor(self, shopId)
end

function QBalckShopProxy:getRefreshCount()
	local vip = db:getVipContnentByVipLevel(QVIPUtil:VIPLevel())
	return vip.hsshop_limit
end

return QBalckShopProxy