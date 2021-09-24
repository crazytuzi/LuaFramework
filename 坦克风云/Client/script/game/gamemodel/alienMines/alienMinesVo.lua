alienMinesVo={}

--type 1-3:3种资源
function alienMinesVo:new(id,oid,name,type,level,x,y,ptEndTime,power,rank,pic,allianceName,heatTime,heatPoint)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.id=id
    nc.oid=oid
    nc.name=name
    nc.x=x
    nc.y=y
    nc.type=type
    nc.level=level
    nc.ptEndTime=ptEndTime --保护结束时间（玩家）
    nc.power=power
    nc.rank=rank
    nc.pic=(pic==0 and 1 or pic)
    nc.allianceName=allianceName
    --增加了富矿系统之后, 资源点的信息要加一个过期时间
    nc.expireTime=base.serverTime + 300
    --富矿系统的热度和上次刷新时间
    nc.heatTime=heatTime or 0
    nc.heatPoint=heatPoint or 0
    return nc
end


