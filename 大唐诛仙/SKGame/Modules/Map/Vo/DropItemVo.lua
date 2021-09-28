--物品掉落的数据对象
DropItemVo =BaseClass(PuppetVo)

function DropItemVo:__init()
	self.type = PuppetVo.Type.DropItem
	self.targetGuid = 0 --掉落者
	self.itemId = 0 -- 物品编号
	self.goodsType = GoodsVo.GoodType.none --物品编号
	self.dropPosition = nil
	self.num = 0
	self.isInited = true
end

function DropItemVo:InitVo(vo)
	if vo ~= nil then
		for k, v in pairs(vo) do
			self[k] = v
		end
	end
end


function DropItemVo:SetValue(key, oldValue, newValue)
	if key ~= nil and oldValue ~= nil and newValue ~= nil  and self.isInited == true then
		if self[key] and self[key] ~= nil then
			self[key] = newValue
		end
	end
end



function DropItemVo:__delete()
	self.isInited = false
end