--[[
******随机商店的随机商品*******

	-- by david.dai
	-- 2014/06/12
]]

local RandomCommodity = class("RandomCommodity")

function RandomCommodity:ctor(data)
	-- self.super.ctor(self)
	self:init(data)
end

function RandomCommodity:init(data)
	self:setData(data)
end

--设置数据
function RandomCommodity:setData(data)
	--print("RandomCommodity:setData : ",data)
	--唯一的商品ID
	self.id = data.commodityId
	--数据模板需要查表，目前欠缺此表格
	local shopEntry = RandomShopData:objectByID(self.id)

	if shopEntry == nil then
		print("ShopEntry not found.",self.id)
	end

	self.shopEntry = shopEntry
	self.template = ItemData:objectByID(shopEntry.goods_id)

	if self.template == nil then
		print("Goods template not found.",shopEntry.id,shopEntry.goods_id)
	end

	--数量是随机的
	self.num = data.num
	--print("data.num : ",data.num , data)
	--商品是否可以购买
	self.enabled = data.enabled
end

function RandomCommodity:dispose()
	self.super.dispose(self)
	self.num 			= nil
	self.template 		= nil
	self.id 			= nil
	self.enabled 		= nil
	TFDirector:unRequire('lua.gamedata.base.GameObject')
end

function RandomCommodity:getId()
	return self.id
end

function RandomCommodity:getTemplate()
	return self.template
end

function RandomCommodity:getNumber()
	return self.num
end

function RandomCommodity:setNumber(number)
	self.num = number
	if self.num < 1 then
		self.enabled = false
	end
end

function RandomCommodity:getShopEntry()
	return self.shopEntry
end

function RandomCommodity:isEnabled()
	return self.enabled and self.num > 0
end

function RandomCommodity:getPrice()
	return self.shopEntry.res_num
end

function RandomCommodity:getTotalPrice()
	return self.shopEntry.res_num * self.num
end

function RandomCommodity:getName()
	return self.template.name
end

return RandomCommodity