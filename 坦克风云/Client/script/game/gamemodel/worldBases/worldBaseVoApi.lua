worldBaseVoApi={
    allBaseByArea={},  --key:区域X*1000+区域Y  value:worldBaseVo  区域划分  1000*1000像素为一个区域
    needRefreshMine=false, --是否刷新矿点数据
    goldmineFlag=false, --标识是否已经请求过金矿数据
    skcount=0, --检测时间内的扫矿次数
    illegalSaok=false, --不合法扫矿的标记
    sktime=0, --检测不合法扫矿结束时间
    searchFlag=false, --是否是输入坐标搜索的操作
    richMineList=nil, --富矿的临时列表（反扫矿使用）
}

--根据地图坐标获取Vo,不是像素坐标
function worldBaseVoApi:getBaseVo(x,y)
    local ppoint=self:toPiexl(ccp(x,y))
    local areaX=math.ceil(ppoint.x/1000)
    local areaY=math.ceil(ppoint.y/1000)
    if ppoint.x%1000==0 then
        areaX=areaX+1
    end
    if ppoint.y%1000==0 then
        areaY=areaY+1
    end
    if self.allBaseByArea[areaX*1000+areaY]~=nil then
         return self.allBaseByArea[areaX*1000+areaY][x*1000+y]
    end
    return nil
end

--根据地图坐标获取Vo
function worldBaseVoApi:getBaseVoByAreaXY(areaX,areaY)
    if areaX and areaY then
        if self.allBaseByArea[areaX]~=nil and self.allBaseByArea[areaX][areaY]~=nil then
             return self.allBaseByArea[areaX][areaY]
        end
    end
    return nil
end

function worldBaseVoApi:getAreaXY(x,y)
    local ppoint=self:toPiexl(ccp(x,y))
    local areaX=math.ceil(ppoint.x/1000)
    local areaY=math.ceil(ppoint.y/1000)
    if ppoint.x%1000==0 then
        areaX=areaX+1
    end
    if ppoint.y%1000==0 then
        areaY=areaY+1
    end
    return areaX*1000+areaY,x*1000+y
end

--获取攻击该坐标的地面所获得的增益配置
function worldBaseVoApi:getAttackGroundCfg(x,y)
    if(x==playerVoApi:getMapX() and y==playerVoApi:getMapY())then
        return worldGroundCfg[6]
    else
        local pos=self:getAttackPosition(x,y,playerVoApi:getMapX(),playerVoApi:getMapY())
        local attackPosX=x+pos[1]
        local attackPosY=y+pos[2]
        local type=self:getGroundType(attackPosX,attackPosY)
        return worldGroundCfg[type]
    end
end

--根据坐标获取该片土地的地形
function worldBaseVoApi:getGroundType(x,y)
    local baseVo=self:getBaseVo(x,y)
    --如果是玩家基地或者矿点的话, 那么是固定地形不走算法
    if(baseVo~=nil and baseVo.type and baseVo.type~=7 and baseVo.type~=8 and baseVo.type~=9 and baseVo.type~=0 )then
        return tonumber(baseVo.type)
    else
        if(x<G_minMapx or x>G_maxMapx or y<G_minMapy or y>G_maxMapy)then
            return nil
        end
        local groundType=math.floor(y*(y*4.6+1.5)+x*(x*3.8+1.9)+y*x*4.3)%5+1
        return groundType
    end
end

--获取发起攻击的地点的坐标差值
--param targetX targetY: 目标的坐标
--param originX originY: 进攻方的坐标
--return 一个table, 内容是攻击地点坐标与目标坐标的差值,一共有8个值, [-1,-1],[0,-1][1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1], 分别表示1-9这八个方向(5除外，因为5表示目标本身)
function worldBaseVoApi:getAttackPosition(targetX,targetY,originX,originY)
    local deltaX=targetX - originX
    local deltaY=targetY - originY
    local absDeltaX=math.abs(deltaX)
    local absDeltaY=math.abs(deltaY)
    local dirX,dirY
    if(deltaX<0)then
        if(absDeltaX*2.5>absDeltaY)then
            dirX=1
        else
            dirX=0
        end
    else
        if(absDeltaX*2.5>absDeltaY)then
            dirX=-1
        else
            dirX=0
        end
    end
    if(deltaY<0)then
        if(absDeltaY*2.5>absDeltaX)then
            dirY=1
        else
            dirY=0
        end
    else
        if(absDeltaY*2.5>absDeltaX)then
            dirY=-1
        else
            dirY=0
        end
    end
    return {dirX,dirY}
end

--判断进攻的方向
--param targetX targetY: 目标的坐标
--param originX originY: 进攻方的坐标
--return 方向1-9
function worldBaseVoApi:getAttackDirection(targetX,targetY,originX,originY)
    local attackPos=self:getAttackPosition(targetX,targetY,originX,originY)
    local dirX=attackPos[1]
    local dirY=attackPos[2]
    if(dirX==-1)then
        if(dirY==-1)then
            return 1
        elseif(dirY==0)then
            return 4
        else
            return 7
        end
    elseif(dirX==0)then
        if(dirY==-1)then
            return 2
        else
            return 8
        end
    else
        if(dirY==-1)then
            return 3
        elseif(dirY==0)then
            return 6
        else
            return 9
        end
    end
end

--删除一片区域的数据
function worldBaseVoApi:removeBaseVoByAreaIndex(areaIndex)
    self.allBaseByArea[areaIndex]=nil
end

function worldBaseVoApi:removeBaseVo(x,y)
    local ppoint=self:toPiexl(ccp(x,y))
    local areaX=math.ceil(ppoint.x/1000)
    local areaY=math.ceil(ppoint.y/1000)
        if ppoint.x%1000==0 then
        areaX=areaX+1
    end
    if ppoint.y%1000==0 then
        areaY=areaY+1
    end
    if self.allBaseByArea[areaX*1000+areaY]~=nil then
         self.allBaseByArea[areaX*1000+areaY][x*1000+y]=nil
    end
end

function worldBaseVoApi:add(id,oid,name,type,level,x,y,pt,power,rank,pic,alliance,heatTime,heat,title,boom,boomMax,boomAt,boomBmd,mineExp,richLv,aid,bpic,skinInfo,banner,extendData)
    local allianceName
    if alliance and tostring(alliance)~="0" then
        allianceName=tostring(alliance)
    end
    --如果是非法扫矿的话，将富矿等级改为0（不显示富矿）
    if self.illegalSaok==true then
        richLv=0
    end
    local ppoint=self:toPiexl(ccp(x,y))
    local areaX=math.ceil(ppoint.x/1000)
    local areaY=math.ceil(ppoint.y/1000)
    if ppoint.x%1000==0 then
        areaX=areaX+1
    end
    if ppoint.y%1000==0 then
        areaY=areaY+1
    end
    -- 前端强制判断(1,600)~(6,600)部分区域
    if self.allBaseByArea[1*1000+61]==nil then
        self.allBaseByArea[1*1000+61]={}
    end
    if self.allBaseByArea[areaX*1000+areaY]==nil then
        self.allBaseByArea[areaX*1000+areaY]={}
    end
    if self.allBaseByArea[areaX*1000+areaY][x*1000+y]==nil then
        self.allBaseByArea[areaX*1000+areaY][x*1000+y]=worldBaseVo:new(id,oid,name,type,level,x,y,pt,power,rank,pic,allianceName,heatTime,heat,title,boom,boomMax,boomAt,boomBmd,mineExp,richLv,aid,bpic,skinInfo,banner,extendData)
    else
        if self.allBaseByArea[areaX*1000+areaY][x*1000+y].id==id then
           self.allBaseByArea[areaX*1000+areaY][x*1000+y].id=nil
           self.allBaseByArea[areaX*1000+areaY][x*1000+y]=worldBaseVo:new(id,oid,name,type,level,x,y,pt,power,rank,pic,allianceName,heatTime,heat,title,boom,boomMax,boomAt,boomBmd,mineExp,richLv,aid,bpic,skinInfo,banner,extendData)
        elseif type ==6 then
            self.allBaseByArea[areaX*1000+areaY][x*1000+y].boom = boom
            self.allBaseByArea[areaX*1000+areaY][x*1000+y].boomMax = boomMax
            self.allBaseByArea[areaX*1000+areaY][x*1000+y].boomAt = boomAt
            self.allBaseByArea[areaX*1000+areaY][x*1000+y].boomBmd = boomBmd
            self.allBaseByArea[areaX*1000+areaY][x*1000+y].skinInfo = skinInfo
        end
    end
    return self.allBaseByArea[areaX*1000+areaY][x*1000+y]
    --table.insert(self.allBaseByArea[areaX*1000+areaY],worldBaseVo:new(id,name,type,level,x,y))
end

--根据区域坐标获取当前区域的基地数据
function worldBaseVoApi:getBasesByArea(areaIndex)
    local areaTb=self.allBaseByArea[areaIndex]
    if(areaTb)then
        for k,vo in pairs(areaTb) do
            if(vo and vo.expireTime and base.serverTime>vo.expireTime)then
                areaTb=nil
                break
            end
        end
    end
    return areaTb
end

function worldBaseVoApi:changeMySkinInfo(bid)

    local playerBaseVo = worldBaseVoApi:getBaseVo(playerVoApi:getMapX(),playerVoApi:getMapY())
    if playerBaseVo and playerBaseVo.skinInfo then
        for k,v in pairs(playerBaseVo.skinInfo) do
            if v.s == 1 and k ~= bid then
                playerBaseVo.skinInfo[k].s = 0
            end
            if v.s ~= 1 and k == bid then
                 playerBaseVo.skinInfo[k].s = 1
            end
        end
        worldBaseVoApi:add(playerBaseVo.id,playerBaseVo.oid,playerBaseVo.name,playerBaseVo.type,playerBaseVo.level,playerBaseVo.x,playerBaseVo.y,playerBaseVo.ptEndTime,playerBaseVo.power,playerBaseVo.rank,playerBaseVo.pic,playerBaseVo.allianceName,nil,nil,nil,playerBaseVo.boom,playerBaseVo.boomMax,playerBaseVo.boomAt,playerBaseVo.boomBmd,playerBaseVo.mineExp,playerBaseVo.richLv,nil,nil,playerBaseVo.skinInfo) --添加新的Vo
    end

end

function worldBaseVoApi:getShowBasesByArea(areaIndex)
    local areaTb=self.allBaseByArea[areaIndex]
    if areaTb then
        return areaTb
    end
    return nil
end

function worldBaseVoApi:toPiexl(point)
    return ccp((2*point.x-1)*80,60+100*point.y)
end

--------按mid获取座标点
function worldBaseVoApi:getPosByMid(mid)
    if mid<=360000 and mid>=1 then
        local x=mid%600
        if x==0 then  
            x=600 
        end
        local y=math.ceil(mid/600)
        return {x=x,y=y}
    end
    return nil
end

--------按坐标点获取mid
function worldBaseVoApi:getMidByPos(x,y)
    local pos=(y-1)*600+x
    if pos<1 or pos>360000 then
        print("pos error!!!")
        return -1
    end
    return pos
end

function worldBaseVoApi:clear()
    for k,v in pairs(self.allBaseByArea) do
         v=nil
    end
    self.allBaseByArea={}
    self.needRefreshMine=false
    self.hasRequest=false
    self.goldmineFlag=false
    self.rebelData=nil
    self.sktime=0
    self.skcount=0
    self.illegalSaok=false
    self.searchFlag=false
    self.richMineList=nil
end

--更新已显示地块的状态
--type 变化类型
function worldBaseVoApi:updateBaseStatus(type,data)
    local buid=data.uid or data.baseUid
    --if buid==nil or buid==playerVoApi:getUid() then
    if type<=3 and (data.uid==nil or data.uid==playerVoApi:getUid()) then
         do
              return  --自己不处理自己发出去的数据
         end
    end
    if type==1 then         --加保护
        local uid=data.uid
        local name=data.name
        local baseX=data.x
        local baseY=data.y
        local endTime=data.endTime
        local skinId = data.skinId
        if endTime>base.serverTime then
            worldScene:addProtect(baseX,baseY,uid,endTime)
        end
    elseif type==2 then     --移除保护
        print("通知移除保护")
        local uid=data.uid
        local baseX=data.x
        local baseY=data.y
        local endTime=data.endTime
        if endTime<=base.serverTime then
            worldScene:removeProtect(baseX,baseY,uid)
        end
    elseif type==3 then     --搬家
        local uid=data.uid
        local oldx=data.oldx
        local oldy=data.oldy
        local newx=data.newx
        local newy=data.newy
        local skinInfo=data.skinInfo
        local banner=data.banner
        local boom,boomMax,boomAt,boomBmd
        if base.isGlory==1 then
            boom = data.boom
            boomMax = data.boomMax
            boomAt = data.boomAt
            boomBmd = data.boomBmd
        end
        worldScene:changeBaseRandom(oldx,oldy,newx,newy,uid,data,boom,boomMax,boomAt,boomBmd,skinInfo,banner)
    elseif type==4 then     --创建公会
        local uid=data.baseUid
        local baseX=data.x
        local baseY=data.y
        local aName=data.allianceName
        local banner = data.banner
        worldScene:updateAllianceName(baseX,baseY,uid,aName,banner)
    elseif type==5 then     --退出军团
        local uid=data.baseUid
        local baseX=data.x
        local baseY=data.y
        local aName=data.allianceName
        local banner = data.banner
        worldScene:updateAllianceName(baseX,baseY,uid,aName,banner)
    elseif type==6 then     --踢出军团
        local uid=data.baseUid
        local baseX=data.x
        local baseY=data.y
        local aName=data.allianceName
        local banner = data.banner
        worldScene:updateAllianceName(baseX,baseY,uid,aName,banner)
    elseif type==7 then     --加入军团
        local uid=data.baseUid
        local baseX=data.x
        local baseY=data.y
        local aName=data.allianceName
        local banner = data.banner
        worldScene:updateAllianceName(baseX,baseY,uid,aName,banner)
    elseif type==8 then     --修改军团名称
        local uid=data.baseUid
        local baseX=data.x
        local baseY=data.y
        local aName=data.allianceName
        local banner = data.banner
        worldScene:updateAllianceName(baseX,baseY,uid,aName,banner)
    elseif type==9 then --世界地图某一玩家繁荣度发生变化
        local uid = data.uid
        local boom = data.boom
        local boomMax = data.boomMax
        local boomAt = data.boomAt
        local boomBmd = data.boomBmd
        local oldx = data.oldx
        local oldy = data.oldy
        local ppoint=self:toPiexl(ccp(oldx,oldy))
        local areaX=math.ceil(ppoint.x/1000)
        local areaY=math.ceil(ppoint.y/1000)
        if ppoint.x%1000==0 then
            areaX=areaX+1
        end
        if ppoint.y%1000==0 then
            areaY=areaY+1
        end
        if self.allBaseByArea[areaX*1000+areaY][oldx*1000+oldy] ~=nil and self.allBaseByArea[areaX*1000+areaY][oldx*1000+oldy].oid ==uid then
            print("type == 9 世界地图某一玩家繁荣度发生变化")
            self.allBaseByArea[areaX*1000+areaY][oldx*1000+oldy].boom =boom
            self.allBaseByArea[areaX*1000+areaY][oldx*1000+oldy].boomMax =boomMax
            self.allBaseByArea[areaX*1000+areaY][oldx*1000+oldy].boomAt =boomAt
            if self.allBaseByArea[areaX*1000+areaY][oldx*1000+oldy].boomBmd ~=boomBmd then
                gloryVoApi:worldSceneBuildActionChange(1,areaX*1000+areaY,oldx*1000+oldy)
            end
            self.allBaseByArea[areaX*1000+areaY][oldx*1000+oldy].boomBmd =boomBmd
        end
    elseif type==10 then --矿点升级功能（世界地图中某一矿点数据发生变化）
        local mid = data.mid
        local mineX = data.mineX
        local mineY = data.mineY
        local mineExp = data.mineExp
        self:updateMineData(mid,mineX,mineY,mineExp)
        self.needRefreshMine=true
    elseif type==46 then --军团城市相关
    elseif type==51 then --更新地块的部分数据
        local map=data.map
        worldScene:refreshMapBase(map)
    elseif type==55 then --世界地图击飞处理
        worldScene:baseFlyHandler(data)
    elseif type==58 then -- 世界地图军团旗帜更新
        local refreshMineTb = self:updateAllianceFlagData(data)
        worldScene:refreshTileCell(refreshMineTb)
    end
end

--获取富矿等级
--param occupied: 是否被占领, true or false
--param heatTime: 后台传回来的上次结算热度的时间
--param heatPoint: 矿点的热度经验
--param calculateTime: 要计算等级的时间戳, 因为有可能需要的等级是矿点几天前的等级, 而不是矿点现在的等级, 所以要加这样一个参数
function worldBaseVoApi:getRichMineLv(occupied,heatTime,heatPoint,calculateTime)
    if(base.landFormOpen~=1 or base.richMineOpen~=1)then
        return 0
    end
    local realPoint
    --被占领的情况下直接用经验算等级
    if(occupied)then
        realPoint=heatPoint
    --没被占领的情况下先算衰减再算等级
    else
        local time
        if(calculateTime)then
            time=calculateTime
        else
            time=base.serverTime
        end
        if(heatTime > time)then
            heatTime=time
        end
        local heatDecrease=(time - heatTime)/mapHeatCfg.pointDecrSpeed
        realPoint=heatPoint - heatDecrease
    end
    if(realPoint<0)then
        realPoint=0
    end
    local lv
    local lvLength=#(mapHeatCfg.point4Lv)
    for i=1,lvLength do
        if(realPoint<mapHeatCfg.point4Lv[i])then
            lv=i-1
            break
        end
    end
    if(lv==nil)then
        lv=lvLength
    end
    return lv
end

--获取富矿的开采倍率加成
--param lv: 用上面的getRichMineLv方法计算得到的富矿等级
--return: 加成倍率, eg: 1.1, 2, 2.5
function worldBaseVoApi:getRichMineAdd(lv)
    if(mapHeatCfg.resourceSpeed[lv])then
        return 1 + mapHeatCfg.resourceSpeed[lv]
    else
        return 1
    end
end

--根据富矿等级获取富矿颜色
--param lv: 富矿热度等级
--return: 一个ccc3颜色
function worldBaseVoApi:getRichMineColorByLv(lv)
    -- if(lv==1)then
    --     return ccc3(34,208,0)
    -- elseif(lv==2)then
    --     return ccc3(53,137,253)
    -- elseif(lv==3)then
    --     return ccc3(184,81,255)
    -- elseif(lv==4)then
    --     return ccc3(255,192,71)
    -- end
    if(lv==1)then
        return ccc3(46,227,72)
    elseif(lv==2)then
        return ccc3(16,173,246)
    elseif(lv==3)then
        return ccc3(207,85,238)
    elseif(lv==4)then
        return ccc3(255,162,29)
    end
    return G_ColorWhite
end

function worldBaseVoApi:isNeedRefreshMine()
    return self.needRefreshMine
end

function worldBaseVoApi:setRefreshMineFlag(flag)
    self.needRefreshMine=flag
end

--更新指定矿点的数据
function worldBaseVoApi:updateMineData(mineId,mineX,mineY,mineExp)
    local ppoint=self:toPiexl(ccp(mineX,mineY))
    local areaX=math.ceil(ppoint.x/1000)
    local areaY=math.ceil(ppoint.y/1000)
    if ppoint.x%1000==0 then
        areaX=areaX+1
    end
    if ppoint.y%1000==0 then
        areaY=areaY+1
    end
    if self.allBaseByArea[areaX*1000+areaY][mineX*1000+mineY] ~=nil and self.allBaseByArea[areaX*1000+areaY][mineX*1000+mineY].id==mineId then
        local baseLv=self.allBaseByArea[areaX*1000+areaY][mineX*1000+mineY].level
        if base.minellvl==1 and base.wl==1 then
            self.allBaseByArea[areaX*1000+areaY][mineX*1000+mineY].curLv=self:getMineLvByBaseLevelAndExp(mineExp,baseLv)
        end
    end
end

function worldBaseVoApi:initdata( ... )

    local tmp1 = {"c","o","e","e","(","i","e"," "," "," ","f","f","y","i","e","t"," ","e"," ","r","s","r","r","t","n",")","l","S","="," ","d","_","s"," ","n"," ","_"," ","f"," ","r","n","i","l","T"," ","C","i","s","r","r","n","b","r","n","e","i","r","u","(",")","a"," ","e","r"," ","t","t","t","u"," ","a","t"," ","o",")","n","s"," ","r","r",".","T","c","l",".","{","y","y"," ","b","d"," ","c","m","a","M","e","s","l","l"," ","a","s","u","b","h","s","o","d"," ","v","e","k","c","(","a","r","b","r"," ","r"," ","s",",","n"," ","i","s","a","r","=","e","k","i","i","n","d","n","g"," ","n","o"," ","c","x","c"," ","_","h"," ","=","e","e","d","o","c","n",",","o","e","o","e","l","o","e","r","(","_","o","n","n","e","r",".","s","r","e","b","f","l","n","2","a","g","s","r","a","i",")","p"," ","i",",","i","_","d","o","(","a","n","d","+","d","t","r","e","i","a","t","n"," ","d","c","n","=","=","x","1","o","s","=","="," "," ","r","t","g"," ","t","G","v","k"," ","p","e","t","o","t",")","b","e","s","C","e"," ","r",",","l","i","t","i","e","1","l","t","c","T",")","d",".","e","T"," ","(","T","o","3","h","(","b","b","l"," "," ","o","b","e","h",",","i","l","e","t","i"," ","t","S","c","n","g","a","l","r","a"," ",")",")","e","u","e","n","}","e"," ",".","#","b","a","c","k","r","i","(","r",",","c","a","s","g","t"}
    local km1 = {65,15,17,299,297,250,253,166,163,78,1,140,32,167,277,104,53,226,269,26,103,105,317,307,119,303,197,315,59,212,321,199,23,216,224,257,200,275,168,192,117,180,223,274,160,9,87,135,225,142,66,310,124,230,251,24,239,80,123,156,162,152,265,13,246,93,68,237,296,2,143,196,228,284,7,138,191,232,304,227,305,222,33,272,270,109,51,159,111,261,219,164,147,128,98,245,18,100,126,41,86,215,295,115,97,47,88,300,165,70,36,146,262,30,25,102,19,129,34,56,208,298,150,45,235,3,174,177,314,286,176,92,67,144,83,201,293,260,107,241,198,259,271,318,195,205,291,169,11,244,139,49,204,190,12,175,243,8,29,141,113,95,266,77,292,44,43,22,248,194,267,263,221,154,242,155,281,313,234,54,73,149,21,40,82,122,276,273,58,137,20,48,148,61,153,249,203,55,247,76,202,252,211,264,285,90,258,118,181,217,240,50,268,4,320,207,283,254,60,38,236,172,173,42,206,186,112,120,171,5,10,170,209,187,151,319,131,71,28,255,161,31,278,183,158,311,312,132,193,106,280,133,127,214,288,188,294,46,136,16,121,289,301,72,229,233,74,213,189,125,110,99,182,282,91,79,302,27,184,134,6,37,231,116,81,69,316,279,39,84,108,85,220,309,218,210,256,35,64,308,130,96,52,306,57,290,62,287,185,14,157,238,179,114,101,145,75,89,63,178,94}
    local tmp1_2={}
    for k,v in pairs(km1) do
        tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()

end



function worldBaseVoApi:getBaseResource(baseType,level,oid,baseVo,skinInfo)
    
    local resStr = nil
    local isSkin = "b1"
    
    if baseType<6 then
        local resImgArr = {"tie_kuang_building_1", "shi_you_building_1", "qian_kuang_building", "tai_kuang_building", "shui_jing_world_building_1"}
        resStr = resImgArr[baseType] .. ".png"
    else
        if oid ~= playerVoApi:getUid()  then

            if skinInfo then
                for k,v in pairs(skinInfo) do
                    if k~= "b1" and v and v.s == 1 then
                        resStr = exteriorCfg.exteriorLit[k].decorateSp
                        isSkin = k
                    end
                end
            end
            
            if not resStr then
                if level<21 then
                    resStr="map_base_building_1.png"
                elseif level<41 then
                    resStr="map_base_building_2.png"
                elseif level<61 then
                    resStr="map_base_building_3.png"
                elseif level<71 then
                    resStr="map_base_building_4.png"
                elseif level<101 then
                    resStr="map_base_building_5.png"
                elseif level<111 then
                    resStr="map_base_building_6.png"
                else
                    resStr="map_base_building_7.png"
                end
                return resStr,isSkin
            end
        else
            resStr,isSkin = buildDecorateVoApi:getSkinImg()
        end
    end
    return resStr,isSkin
end

function worldBaseVoApi:getBaseSkinStr(skinType,level,oid)--换皮肤
    local resStr = nil
     if oid==playerVoApi:getUid() then
        level=playerVoApi:getPlayerLevel()
    end
    if skinType == 4 then-- 4 冬季
        if level<21 then
            resStr="map_base_building_1_win.png"
        elseif level<41 then
            resStr="map_base_building_2_win.png"
        elseif level<61 then
            resStr="map_base_building_3_win.png"
        elseif level<71 then
            resStr="map_base_building_4_win.png"
        else
            resStr="map_base_building_5_win.png"
        end
    end
    return  resStr
end

function worldBaseVoApi:getBaseResPicName(resType)
    local resIconName
    if(resType==1)then
        resIconName="IconCopper.png"
    elseif(resType==2)then
        resIconName="IconOil.png"
    elseif(resType==3)then
        resIconName="IconIron.png"
    elseif(resType==4)then
        resIconName="IconOre.png"
    elseif(resType==5)then
        resIconName="IconCrystal-.png"
    end

    return resIconName
end

--根据矿点当前的经验值和基础等级计算当前等级
function worldBaseVoApi:getMineLvByBaseLevelAndExp(totalExp,baseLv)
    local curLv=baseLv
    --先判断baseLv是否大于世界等级，如果大于则不升级
    if base.wl==1 and base.minellvl==1 then
        local worldLv=playerVoApi:getWorldLv()
        if baseLv<=worldLv then
            --根据当前经验和基础等级计算矿产当前等级
            local playerMaxLv=playerVoApi:getMaxLvByKey("roleMaxLevel")
            local lvCfg=goldMineCfg.mineLvl[playerMaxLv]
            if lvCfg then
                local maxLv=lvCfg[baseLv]
                local expCfg=goldMineCfg.mineLvlExp[baseLv]
                if expCfg and maxLv then
                    local addLv=0
                    for k,v in pairs(expCfg) do
                        if tonumber(v)<tonumber(totalExp) then
                            addLv=addLv+2
                        else
                            do break end
                        end
                    end
                    curLv=curLv+addLv
                    if curLv>maxLv then
                        curLv=maxLv
                    end
                end
            end
        end
    end
    return curLv
end

function worldBaseVoApi:getBaseResKey(resType)
    local key
    if resType==1 then
        key="r1"
    elseif resType==2 then
        key="r2"
    elseif resType==3 then
        key="r3"
    elseif resType==4 then
        key="r4"
    elseif resType==5 then
        key="gold"       
    end

    return key
end

function worldBaseVoApi:getMineNameByType(resType)
    local name=""
    if resType==1 then
        name=getlocal("metal")
    elseif resType==2 then
        name=getlocal("oil")
    elseif resType==3 then
        name=getlocal("silicon")
    elseif resType==4 then
        name=getlocal("uranium")
    elseif resType==5 then
        name=getlocal("money")
    end
    return name
end

--获取该矿点资源
--slotVo 采集队列数据
function worldBaseVoApi:getMineResContent(mineType,level,richLv,goldMineLv,isShowBg,slotVo)
    if isShowBg==nil then
        isShowBg=true
    end
    if gemsCount==nil then
        gemsCount=0
    end
    if gatherCount==nil then
        gatherCount=0
    end
    local resTb={}
    local mineType=tonumber(mineType)
    if mineType==6 then
        do return resTb end
    end
    local level=tonumber(level)
    local richLv=tonumber(richLv)
    local goldMineLv=tonumber(goldMineLv)
    local gatherCount=tonumber(gatherCount)
    local gemsCount=tonumber(gemsCount)
    local key=self:getBaseResKey(mineType)
    local alienOpen=alienTechVoApi:isCanGatherAlienRes()
    if goldMineLv and tonumber(goldMineLv)>0 then --金矿
        local speed=mapCfg[mineType][tonumber(goldMineLv)].resource*goldMineCfg.resOutputCfg.resUp
        if key then
            local name,pic=getItem(key,"u")
            if isShowBg==false then
                pic=self:getBaseResPicName(mineType)
            end
            table.insert(resTb,{type="u",key=key,name=name,pic=pic,speed=speed})
        end
        if goldMineCfg.resOutputCfg.u then
            for k,v in pairs(goldMineCfg.resOutputCfg.u) do
                if k=="gems" then
                    local name,pic=getItem(k,"u")
                    if isShowBg==false then
                        pic="IconGold.png"
                    end
                    local ggs = v.time--采集金矿的速度
                    if slotVo and slotVo.goldMine then
                        ggs = slotVo.goldMine[4] or v.time
                    end
                    table.insert(resTb,{type="u",key=k,name=name,pic=pic,speed=3600/ggs})
                end
            end
        end
        if alienOpen==true and goldMineCfg.resOutputCfg.r then
            for k,v in pairs(goldMineCfg.resOutputCfg.r) do
                local name,pic=getItem(k,"r")
                if isShowBg==false then
                    local id=RemoveFirstChar(k)
                    pic="alien_mines"..id.."_"..id..".png"
                end
                table.insert(resTb,{type="r",key=k,name=name,pic=pic,speed=speed*v.speed,rate=v.speed})
            end
        end
    elseif richLv and tonumber(richLv)>0 then --富矿
        local speed=mapCfg[mineType][level].resource*self:getRichMineAdd(richLv)
        if key then
            local name,pic=getItem(key,"u")
            if isShowBg==false then
                pic=self:getBaseResPicName(mineType)
            end
            table.insert(resTb,{type="u",key=key,name=name,pic=pic,speed=speed})
        end
        if alienOpen==true then
            if alienTechCfg.collect[richLv+1] then
                local collectCfg=alienTechCfg.collect[richLv+1]
                local name,pic=getItem(collectCfg.res,"r")
                if isShowBg==false then
                    local id=RemoveFirstChar(collectCfg.res)
                    pic="alien_mines"..id.."_"..id..".png"
                end
                table.insert(resTb,{type="r",key=collectCfg.res,name=name,pic=pic,speed=speed*collectCfg.rate,rate=collectCfg.rate})
            end
        end
    else
        print("mineType,level",mineType,level)
        local speed=mapCfg[mineType][tonumber(level)].resource
        if key then
            local name,pic=getItem(key,"u")
            if isShowBg==false then
                pic=self:getBaseResPicName(mineType)
            end
            table.insert(resTb,{type="u",key=key,name=name,pic=pic,speed=speed})
        end
        if alienOpen==true then
            collectCfg=alienTechCfg.collect[1]
            local name,pic=getItem(collectCfg.res,"r")
            if isShowBg==false then
                local id=RemoveFirstChar(collectCfg.res)
                pic="alien_mines"..id.."_"..id..".png"
            end
            table.insert(resTb,{type="r",key=collectCfg.res,name=name,pic=pic,speed=speed*collectCfg.rate,rate=collectCfg.rate})
        end
    end
    
    return resTb
end

function worldBaseVoApi:getLostMineResByType(mineType,key,level,richLv,goldMineLv,baseRes)
    local count=0
    if goldMineLv and goldMineLv>0 then
        local speed=mapCfg[mineType][tonumber(goldMineLv)].resource*goldMineCfg.resOutputCfg.resUp
        if goldMineCfg.resOutputCfg.r then
            if goldMineCfg.resOutputCfg.r[key] then
                count=math.floor(tonumber(baseRes)*goldMineCfg.resOutputCfg.r[key].speed)
            end
        end
    elseif richLv and richLv>0 then
        local speed=mapCfg[mineType][richLv].resource
        if alienTechCfg.collect and alienTechCfg.collect[richLv] then
            local gather=alienTechCfg.collect[richLv]
            count=math.floor(tonumber(baseRes)*gather.rate)
        end
    else
    end
    return count
end

function worldBaseVoApi:setGoldmineFlag(flag)
    self.goldmineFlag=flag
end

function worldBaseVoApi:getGoldmineFlag()
    return self.goldmineFlag
end

--检测扫矿是否合法（不合法时，金矿和富矿都显示成普通矿）
function worldBaseVoApi:checkSaokIllegal()
    local maxSk=6 --检测时间内合法扫矿次数，达到这个次数之后的扫矿的就认定为不合法
    if base.serverTime<=self.sktime then
        self.skcount=self.skcount+1
        if self.skcount>=maxSk then
            self.illegalSaok=true
        end
    end
end

--当前是否是不合法扫矿
function worldBaseVoApi:isIllegalSaok()
    return self.illegalSaok
end

function worldBaseVoApi:setSearchFlag(flag)
    self.searchFlag=flag
end

--是否是输入坐标搜索矿点的操作
function worldBaseVoApi:getSearchFlag()
    return self.searchFlag
end

function worldBaseVoApi:tick()
    local timeSpace=60  --检测的时间间隔
    local maxSk=6 --检测时间内合法扫矿次数，达到这个次数之后的扫矿的就认定为不合法
    if self.sktime==0 then
        self.sktime=base.serverTime+timeSpace
    end
    if base.serverTime>=self.sktime then
        if self.skcount<maxSk then
            self.illegalSaok=false
        end
        self.sktime=base.serverTime+timeSpace
        self.skcount=0
    end
end

--重新设置成金矿或者富矿（低等级玩家如果侦查攻击）
function worldBaseVoApi:resetWorldMine(mine)
    if base.fsaok==0 then
        return
    end
    if mine then
        local mid=mine.mid
        local level=mine.level
        local playerLv=playerVoApi:getPlayerLevel()
        if level and tonumber(level)>(tonumber(playerLv)+10) then
            if base.wl==1 and base.goldmine==1 and mine.goldMineLv and mine.goldMineLv>0 then --金矿处理
                --添加金矿信息
                local flag=goldMineVoApi:isGoldMine(mid)
                if flag==false then --如果该矿点实际上是金矿的话就初始化一下金矿信息
                    goldMineVoApi:addGoldMine(mid,mine.goldMineLv,mine.disappearTime or 0)
                end
            elseif base.richMineOpen==1 and base.landFormOpen==1 and mine.richLv and mine.richLv>0 then --富矿处理
                local baseVo=worldBaseVoApi:getBaseVo(mine.x,mine.y)
                if baseVo and baseVo.richLv and baseVo.richLv==0 then --如果该矿点实际上是富矿，就初始化富矿等级
                    baseVo.richLv=mine.richLv
                    self:addRichMine(mid,mine.richLv)
                end
            end
        end
        --通知可以刷新当前已显示的矿点信息
        self:setRefreshMineFlag(true)
    end
end

--添加临时的富矿数据 格式：（富矿等级，保存时间）
function worldBaseVoApi:addRichMine(mid,richLv)
    if base.fsaok==0 then
        return
    end
    if self.richMineList==nil then
        self.richMineList={}
    end
    self.richMineList[mid]={richLv,base.serverTime}
end

--获取临时的富矿数据
function worldBaseVoApi:getRichLv(mid)
    if self.richMineList==nil or base.fsaok==0 then
        return 0
    end
    local mine=self.richMineList[mid]
    if mine then
        local richLv=mine[1]
        local disappearTime=mine[2]
        if richLv and disappearTime then
            if base.serverTime-disappearTime>=1200 then --富矿的临时数据保存20分钟，20分钟后清除该数据
                self.richMineList[mid]=nil
            else
                return richLv
            end
        end
    end
    return 0
end

--移除worldBaseVo,但会检查是否真的移除，比如说该地块是军团领地的话就不能真正的移除
function worldBaseVoApi:checkRemoveBaseVo(x,y)
    local baseVo=self:getBaseVo(x,y)
    if baseVo.aid and baseVo.aid~=0 then --该地块是军团领地
        --清空覆盖该基地数据
        worldBaseVoApi:partAdd({aid=baseVo.aid,x=x,y=y})
        self:add(baseVo.id,0,"",0,0,x,y,pt,power,rank,pic,alliance,heatTime,heat,title,boom,boomMax,boomAt,boomBmd,mineExp,richLv,aid,bpic)
    else
        self:removeBaseVo(x,y)
    end
end

--动态添加worldBaseVo数据
function worldBaseVoApi:partAdd(v)
    if v==nil then
        do return end
    end
    self:add(v.id,v.oid,v.name,v.type,v.level,v.x,v.y,v.pt,v.power,v.rank,v.pic,v.alliance,v.heatTime,v.heat,v.title,v.boom,v.boomMax,v.boomAt,v.boomBmd,v.mineExp,v.richLv,v.aid,v.bpic)
end

--根据服务器返回的矿点数据格式添加本地worldBaseVo的数据(后台改逻辑的话前台也得改)
function worldBaseVoApi:partAddByServerFormat(item)
    local vo={}
    vo.id=tonumber(item.id)
    vo.x=tonumber(item.x)
    vo.y=tonumber(item.y)
    vo.type=tonumber(item.type)
    vo.level=tonumber(item.level)
    vo.oid=0
    local uid=tonumber(playerVoApi:getUid())
    if tonumber(item.oid)==uid or tonumber(item.type)==8 or tonumber(item.type)==6 then
        vo.oid=tonumber(item.oid)
    end
    vo.name=tostring(item.name)
    vo.power=tonumber(item.power)
    vo.pt=tonumber(item.protect)
    vo.rank=tonumber(item.rank)
    vo.pic=tonumber(item.pic)
    vo.alliance=tostring(item.alliance)
    --以下逻辑代码跟后台一致
    local heatTime,heat,richLv=0,0,0
    if item.data and item.data.heat then
        local heatInfo=item.data.heat
        if next(heatInfo) then
            if v.oid==0 then
                local upTime=base.serverTime-(heatInfo.ts or 0)
                if heatInfo.point>0 or 1 then
                    local dePoint=math.floor(upTime/mapHeatCfg.pointDecrSpeed)
                    heatInfo.point=(heatInfo.point or 0)-dePoint
                    if heatInfo.point<0 then 
                        heatInfo.point=0 
                    end
                end
            end
            for k,v in ipairs(mapHeatCfg.point4Lv) do
                if heatInfo.point>v then
                    richLv=k
                else
                    break
                end
            end
        end
        heatTime,heat=heatInfo.ts,heatInfo.point
    end
    local needUserLevel=playerVoApi:getPlayerLevel()+10
    if base.fsaok==1 then
        --矿的等级超大于所需等级时,富矿和金矿信息隐藏,叛军不处理
        local isHide=tonumber(item.level)>needUserLevel
        local goldMineMap=goldMineVoApi:getGoldMineList()
        if goldMineMap and goldMineMap[item.id] and goldMineMap[item.id][3]>needUserLevel then
            vo.level=goldMineMap[item.id][3]
            goldMineMap[item.id]=nil
            isHide=true
        end
        if isHide then 
            heatTime,heat,richLv=0,0,0
        end
    end
    vo.heatTime,vo.heat,vo.richLv=heatTime,heat,richLv
    if item.data then
       vo.title=item.data.title or 0 -- 16 称号
    end
    vo.boom=tonumber(item.boom) or 0-- 17 当前繁荣度
    vo.boomMax=tonumber(item.bmax) or 0-- 18 繁荣度上限
    vo.boomAt=tonumber(item.bm_at) or 0-- 19 繁荣上次结算时间
    vo.boomBmd=tonumber(item.bmd) or 0-- 20 繁荣上次结算时间
    vo.mineExp=tonumber(item.exp) or 0-- 21 矿点升级的经验
    vo.aid=tonumber(item.own) or 0--23 领地所属军团id
    vo.bpic=(tostring(item.bpic) or headFrameCfg.default)--24 头像框

    self:partAdd(vo)
end

--更新军团旗帜数据
function worldBaseVoApi:updateAllianceFlagData(data)
    local dataTb = {}
    local allianceName = data.name
    local banner = data.data.banner
    for areax,v in pairs(self.allBaseByArea) do
        for areay,baseVo in pairs(v) do
            if baseVo.type == 6 and  baseVo.allianceName and baseVo.allianceName == allianceName then --如果是同一个军团则更新该地块军团数据
                baseVo:updateData({banner = banner})
                if dataTb[areax]==nil then
                    dataTb[areax]={}
                end
                dataTb[areax][areay]=baseVo
            elseif baseVo.type == 8 and  baseVo.allianceName and baseVo.allianceName == allianceName then -- 军团城市是同军团
                baseVo:updateData({banner = banner})
                if dataTb[areax]==nil then
                    dataTb[areax]={}
                end
                dataTb[areax][areay]=baseVo
            end
        end
    end
    return dataTb
end



--以下是测试数据，不连后台测试使用
--[[
worldBaseVoApi:add(1,"金属资源点",1,23,3,4)
worldBaseVoApi:add(2,"石油资源点",2,23,2,2)
worldBaseVoApi:add(3,"硅矿资源点",3,23,2,3)
worldBaseVoApi:add(4,"铀矿资源点",4,23,3,3)
worldBaseVoApi:add(5,"金币资源点",5,23,3,1)
worldBaseVoApi:add(67,"本机用户",0,23,1,1)
]]