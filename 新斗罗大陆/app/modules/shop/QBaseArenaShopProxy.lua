-- @Author: liaoxianbo
-- @Date:   2020-07-10 10:31:52
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-10 11:29:30
local QBaseShopProxy = import(".QBaseShopProxy")
local QBaseArenaShopProxy = class("QBaseArenaShopProxy", QBaseShopProxy)
local QVIPUtil = import("...utils.QVIPUtil")

function QBaseArenaShopProxy:ctor(shopId)
	QBaseArenaShopProxy.super.ctor(self, shopId)
end


function QBaseArenaShopProxy:getShopData()
	QBaseArenaShopProxy.super:getShopData()

	print("[QBaseArenaShopProxy self.shopId] ", self.shopId)
	local storesInfo = remote.stores:getStoresById(self.shopId)
	if storesInfo == nil or next(storesInfo) == nil then 
		return 
	end
	local data = {}
	for index, value in ipairs(storesInfo) do
		if index % self._rowMaxCount == 1 then
			value.isPartition = true
		end
		value.index = index
		table.insert(data, value)
	end

	return data

end

return QBaseArenaShopProxy