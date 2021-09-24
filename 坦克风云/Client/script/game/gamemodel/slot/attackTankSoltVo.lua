attackTankSoltVo={
}

function attackTankSoltVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end
   
-- slotId:队列ID troops:坦克部队  isGather:队列状态  st:开始进攻时间 dist:航行结束时间
--param heatLv: 富矿热度等级
--goldMine: 金矿相关数据
--pMine:保护矿数据
--isGather:队列状态
    -- 0 不采集，==> 掠夺玩家，如果矿场没有玩家不能掠夺
    -- 1采集，==> 采集，分矿场有人和无人，有人打人，无人直接打岛
    -- 2采集中，
    -- 3已采满，
    -- 4待命中，
    -- 5驻防中，（isDef>0是驻防军团城市，否则是协防玩家城市）
    -- 6军团城市进攻后部队返回状态，（后台为了避免重复抓取同一个玩家攻打）
function attackTankSoltVo:initData(slotId,data)
     self.slotId    =slotId
     self.targetid  =data.targetid
     self.troops    =data.troops
     self.oldtroops =data.old --最原始的部队信息
     self.isGather  =tonumber(data.isGather) --是否采集资源（打玩家为false）
     self.level     =data.level
     self.type      =data.type
     self.st        =data.st
     self.dist      =data.dist
     self.maxRes    =data.maxRes
     self.res       =data.res
     self.gts       =data.gts
     self.ges       =data.ges
     self.bs        =data.bs
     self.tName     =data.tName
     self.signState =0 --标记显示用
     self.isHelp    =data.isHelp
     self.vate      = data.vate
     self.heatLv    =tonumber(data.heatLv) or 0
     self.goldMine  =data.goldMine
     self.gts1      =data.gts1
     if data.gems==nil then
        self.gems=0
     else
        self.gems=tonumber(data.gems) or 0
     end
     self.AcRate      =data.AcRate
     self.rebelIndex  =data.rebelForce
     self.rebelRpic   =data.rpic
     self.isDef       =tonumber(data.isDef) or 0 --默认不是驻防（如果有驻防则为军团id）
     self.mid         = data.mid
     self.privateMine = data.pMine
end

function attackTankSoltVo:setEndPoint(point)
    self.endPosition = point
end

function attackTankSoltVo:getEndPoint()
    return self.endPosition
end

function attackTankSoltVo:setStartPoint(point)
    self.startPosition = point
end

function attackTankSoltVo:getStartPoint()
    return self.startPosition
end