-- @Author: liaoxianbo
-- @Date:   2020-07-10 10:53:30
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-25 14:46:26

local QBaseShopProxy = import(".QBaseShopProxy")
local QBaseSilverShopProxy = class("QBaseSilverShopProxy", QBaseShopProxy)
local QVIPUtil = import("...utils.QVIPUtil")

function QBaseSilverShopProxy:ctor(shopId)
	QBaseSilverShopProxy.super.ctor(self, shopId)
end

function QBaseSilverShopProxy:getShopData()
	QBaseSilverShopProxy.super:getShopData()

	print("[QBaseSilverShopProxy self.shopId] ", self.shopId)
	local newShopInfos = {}
	local shops = remote.exchangeShop:getShopInfoById(self.shopId)
	local userLevel = remote.user.level or 0
	local vipLevel = QVIPUtil:VIPLevel() or 0
	for i = 1, #shops do
		if userLevel >= shops[i].team_minlevel and userLevel <= shops[i].team_maxlevel and vipLevel >= shops[i].vip_id then
			-- newShopInfos[i] = shops[i]
			table.insert(newShopInfos , shops[i])
		end
	end

	table.sort(newShopInfos, function(a, b)
		if a.show_grid_id and b.show_grid_id then
			return a.show_grid_id < b.show_grid_id
		else
			return a.grid_id < b.grid_id
		end
	end)

	local data = {}
	for index, v in pairs(newShopInfos) do
		if index % self._rowMaxCount == 1 then
			v.isPartition = true
		end	
		v.index = index

		if not db:checkItemShields(v.item_id) then
			table.insert(data, v)
		end
	end

	return data
end

return QBaseSilverShopProxy