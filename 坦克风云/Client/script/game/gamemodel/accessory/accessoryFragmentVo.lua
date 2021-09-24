accessoryFragmentVo={}
function accessoryFragmentVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function accessoryFragmentVo:initWithData(param)
	self.id=param.id 		--碎片的ID，因为碎片是必然堆叠，不会有重复ID，所以ID就是配置文件中的ID
	self.num=param.num 		--碎片的数目
end

--获取存在配置文件中的属性值
--param key: 要获取的是哪个属性
function accessoryFragmentVo:getConfigData(key)
	return accessoryCfg.fragmentCfg[self.id][key]
end