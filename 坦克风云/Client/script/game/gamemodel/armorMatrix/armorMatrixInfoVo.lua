armorMatrixInfoVo={}
function armorMatrixInfoVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function armorMatrixInfoVo:initWithData(armor)
	if armor.exp then
		self.exp=armor.exp  -- 经验值
	end
	if armor.free then
		self.free=armor.free  -- 招募免费信息
	end
	if armor.curNum then
		self.curNum=armor.curNum --当用仓库拥有矩阵数量
	end
	if armor.count then
		self.count=armor.count  -- 当前仓库容量
	end
	if armor.info then 	-- 所有的装甲矩阵，格式{id={type,lv}}
		self.info=armor.info
	end
	if armor.used then
		self.used=armor.used -- 已装备的装甲矩阵，格式{["m209322",0,0,0,0,0],{},{},{},{},{}}
	end
	if armor.props then
		self.props=armor.props  --
	end
	if armor.exinfo then
		self.exinfo=armor.exinfo
	end
	if armor.rtimes then --高级招募必出紫色的已招募次数
		self.rtimes = armor.rtimes
	end
end