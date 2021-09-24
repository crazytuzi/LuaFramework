--叛军相关的vo
rebelVo={}
function rebelVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--fleeTime：逃跑时间，level：等级，num：编号，maxLife：最大血量，curLife：当前剩余血量，place：坐标{x,y}，killTime：击杀时间，killName：击杀玩家名字
function rebelVo:initWithData(id,fleeTime,level,num,maxLife,curLife,place,killTime,killName)
	self.id=id or 0
	self.fleeTime=fleeTime or 0
	self.level=level or 1
	self.num=num or 1
    self.maxLife=maxLife or 0
    self.curLife=curLife or 0
    self.place=place or {1,1}
    self.killTime=killTime or 0
    self.killName=killName or ""
end
