armorMatrixVo={}
function armorMatrixVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function armorMatrixVo:initWithData(param)
	self.id=param.id or 0 				--装甲矩阵唯一ID
	self.type=param[1]					--装甲矩阵配置ID，是哪种装甲矩阵
	self.lv=tonumber(param[2])			--装甲矩阵等级,number
end

