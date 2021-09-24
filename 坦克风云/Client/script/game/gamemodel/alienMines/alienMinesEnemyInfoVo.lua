alienMinesEnemyInfoVo={}

-- 存储oid(占领者id) 军团名字 战力 等级 图片
function alienMinesEnemyInfoVo:new(oid,alienceName,power,level,pic)
	local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.oid=oid
    nc.alienceName=alienceName
    nc.power=power
    nc.level=level
    nc.pic=pic
    nc.expireTime=base.serverTime+60

    return nc
end