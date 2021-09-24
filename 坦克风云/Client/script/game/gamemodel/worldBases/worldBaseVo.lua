worldBaseVo={}

--type 1-5:5种资源  6:玩家 7: 叛军
function worldBaseVo:new(id,oid,name,type,level,x,y,ptEndTime,power,rank,pic,allianceName,heatTime,heatPoint,title,boom,boomMax,boomAt,boomBmd,mineExp,richLv,aid,bpic,skinInfo,banner,extendData)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.id=id
    nc.oid=oid --(如果是军团城市的话，该字段是军团id)
    nc.name=name
    nc.x=x
    nc.y=y
    nc.type=type
    nc.level=level
    nc.ptEndTime=ptEndTime --保护结束时间（玩家）
    nc.power=power
    nc.rank=rank
    nc.pic=(pic==0 and 1 or pic)
    nc.bpic=(bpic or headFrameCfg.default)
    nc.allianceName=allianceName
    --增加了富矿系统之后, 资源点的信息要加一个过期时间
    if(type~=6 and base.landFormOpen==1 and base.richMineOpen==1)then
        nc.expireTime=base.serverTime + 300
        if(type==7)then
            nc.expireTime=math.min(nc.expireTime,nc.ptEndTime)
        end
    end
    --富矿系统的热度和上次刷新时间
    -- nc.heatTime=heatTime or 0
    -- nc.heatPoint=heatPoint or 0
    --富矿等级
    nc.richLv=richLv or 0
    nc.title=title

    nc.boom=boom
    nc.boomMax=boomMax
    nc.boomAt=boomAt
    nc.boomBmd =boomBmd
    nc.mineExp=tonumber(mineExp)
    if base.minellvl==1 and base.wl==1 and mineExp then
        nc.curLv=worldBaseVoApi:getMineLvByBaseLevelAndExp(mineExp,level)
    else
        nc.curLv=level
    end
    --叛军的特殊处理
    if(nc.type==7)then
        nc.rebelIndex=tonumber(nc.name) or 1
        nc.hp=nc.rank
        nc.maxHp=nc.power
        local reflectId=nc.boom --叛军的映射id
        --添加映射关系
        rebelVoApi:addReflectRebel(reflectId,nc.x,nc.y)
        
        local cfgIndex
        for k,v in pairs(rebelCfg.troops.tanklv) do
            if(nc.level<v)then
                cfgIndex=k - 1
                break
            end
        end
        if(cfgIndex==nil)then
            cfgIndex=#rebelCfg.troops.tanklv
        end
        nc.lvIndex=cfgIndex
        if nc.pic and nc.pic>=100 then
            nc.name=rebelVoApi:getRebelName(nil,nil,false,nc.pic)
        else
            local tankID=tonumber(RemoveFirstChar(rebelCfg.troops.tankIcon[cfgIndex][nc.rebelIndex]))
            local tankName=getlocal(tankCfg[tankID].name)
            nc.name=getlocal("worldRebel_name",{tankName})
        end
        nc.expireTime=nc.ptEndTime
    end
    nc.aid=aid or 0 --地块所属军团id
    if skinInfo and #skinInfo > 0 then
    end
    nc.skinInfo = skinInfo or {}
    if allianceVoApi:checkAllianceFlagIslegal(banner)==false then --如果没有军团旗帜的话给个默认值
        banner=""
    end
    nc.banner=banner
    nc.extendData=extendData
    return nc
end

--部分更新地块的数据
function worldBaseVo:updateData(data)
    -- if data.id==nil then
    --     do return end
    -- end
    -- print("data.id,data.aid--->",data.id,data.aid)
    if data.id then
        self.id=data.id
    end
    if data.oid then
        self.oid=data.oid
    end
    if data.name then
        self.name=data.name
    end
    if data.x then
        self.x=data.x
    end
    if data.y then
        self.y=data.y
    end
    if data.type then
        self.type=data.type
    end
    if data.level then
        self.level=data.level
        self.curLv=self.level
    end
    if data.ptEndTime then
        self.ptEndTime=data.ptEndTime
    end
    if data.power then
        self.power=data.power
    end
    if data.rank then
        self.rank=data.rank
    end
    if data.pic then
        self.pic=data.pic
    end
    if data.bpic then
        self.bpic=bpic
    end
    if data.allianceName then
        self.allianceName=data.allianceName
    end
    if data.richLv then
        self.richLv=data.richLv
    end
    if data.title then
        self.title=data.title
    end
    if data.boom then
        self.boom=data.boom
    end
    if data.boomMax then
        self.boomMax=data.boomMax
    end
    if data.boomAt then
        self.boomAt=data.boomAt
    end
    if data.boomBmd then
        self.boomBmd=data.boomBmd
    end
    if data.mineExp then
        self.mineExp=tonumber(data.mineExp)
        if base.minellvl==1 and base.wl==1 and self.mineExp and self.level then
            self.curLv=worldBaseVoApi:getMineLvByBaseLevelAndExp(self.mineExp,self.level)
        else
            self.curLv=self.level
        end
    end
    if data.aid then
        self.aid=data.aid
    end
    if data.skinInfo then
        self.skinInfo = data.skinInfo
    end
    if data.banner then
        self.banner = data.banner
        if allianceVoApi:checkAllianceFlagIslegal(self.banner)==false then --如果没有军团旗帜的话给个默认值
            self.banner=""
        end
    end
    if data.extendData then
        self.extendData = data.extendData
    end
end