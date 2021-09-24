require "luascript/script/game/gamemodel/alienMines/alienMinesInfoVo"
alienMinesVoApi={
    allBaseByArea={},  --key:区域X*1000+区域Y  value:worldBaseVo  区域划分  1000*1000像素为一个区域
    refreshTime=300, -- 定时刷新排行榜时间
    refreshRankTime=0,
    refreshRankTime2=0,
    personalList={}, -- 个人排行
    alianList={}, -- 军团排行
    mcount=0, -- 自己的异星积分
    infoVo={},
    email_flag=false,
    refreshFlag=false,
    isSendChat=false,
}

--根据地图坐标获取Vo,不是像素坐标
function alienMinesVoApi:getBaseVo(x,y)
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

function alienMinesVoApi:setBaseVo(x,y)
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

function alienMinesVoApi:add(id,oid,name,type,level,x,y,pt,power,rank,pic,alliance,heatTime,heat)
    local allianceName
    if alliance and tostring(alliance)~="0" then
        allianceName=tostring(alliance)
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
    if self.allBaseByArea[areaX*1000+areaY]==nil then
        self.allBaseByArea[areaX*1000+areaY]={}
    end
    if self.allBaseByArea[areaX*1000+areaY][x*1000+y]==nil then
        self.allBaseByArea[areaX*1000+areaY][x*1000+y]=alienMinesVo:new(id,oid,name,type,level,x,y,pt,power,rank,pic,allianceName,heatTime,heat)
    else
        if self.allBaseByArea[areaX*1000+areaY][x*1000+y].id==id then
            self.allBaseByArea[areaX*1000+areaY][x*1000+y].id=nil
            self.allBaseByArea[areaX*1000+areaY][x*1000+y]=alienMinesVo:new(id,oid,name,type,level,x,y,pt,power,rank,pic,allianceName,heatTime,heat)
        end
    end
    --table.insert(self.allBaseByArea[areaX*1000+areaY],worldBaseVo:new(id,name,type,level,x,y))
end

function alienMinesVoApi:toPiexl(point)
    return ccp((2*point.x-1)*100,60+170*point.y)
end

--根据区域坐标获取当前区域的基地数据
function alienMinesVoApi:getBasesByArea(areaIndex)
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

-- 得到军团奖励
function alienMinesVoApi:getAllianceRankingReward()
    local reward = alienMineCfg.allianceRanking.reward[1].reward
    local rewL = FormatItem(reward)
    local rewardList = {}
    table.insert(rewardList,rewL[1])
    return rewardList
end

-- 得到个人奖励
function alienMinesVoApi:getUserRankingReward()
    local reward = alienMineCfg.userRanking.reward
    local rewardList = {}
    for i=1,SizeOfTable(reward) do
        local rew=FormatItem(reward[i].reward)
        table.insert(rewardList,rew[1])
    end
    return rewardList
end

-- 数据data个人
function alienMinesVoApi:setPersonalList(data)
    self.personalList=data
end

function alienMinesVoApi:getPersonalList()
    return self.personalList
end

function alienMinesVoApi:setMcount(mcount)
    self.mcount=mcount
end

function alienMinesVoApi:getSelfList()
    local list = self:getPersonalList()
    local id = playerVoApi:getUid()
    for k,v in pairs(list) do
        if v[1]==id then
            return v
        end
    end
    return {id,playerVoApi:getPlayerName(),playerVoApi:getPlayerLevel(),"100+",self.mcount}
end

-- 数据data军团
function alienMinesVoApi:setAlianList(data)
    self.alianList=data
end

function alienMinesVoApi:getAlianList()
    return self.alianList
end

-- 排行榜定时五分钟刷新
function alienMinesVoApi:getRefreshTime()
    return self.refreshTime
end

--开启后是否发送过公告
function alienMinesVoApi:getIsSendChat()
    return self.isSendChat
end
function alienMinesVoApi:setIsSendChat(isSendChat)
    self.isSendChat=isSendChat
end

function alienMinesVoApi:clear()
    self.allBaseByArea={}  --key:区域X*1000+区域Y  value:worldBaseVo  区域划分  1000*1000像素为一个区域
    self.refreshTime=300 -- 定时刷新排行榜时间
    self.refreshRankTime=0
    self.refreshRankTime2=0
    self.personalList={} -- 个人排行
    self.alianList={} -- 军团排行
    self.mcount=0 -- 自己异星资源的积分
    self.infoVo={}
    self.email_flag=false
    self.refreshFlag=false
    self.isSendChat=false
end

-- 等级限制
function alienMinesVoApi:checkOpen()
   local level
   if(base.alienTechOpenLv and base.alienTechOpenLv>alienMineCfg.needLevel)then
      level=base.alienTechOpenLv
   else
      level=alienMineCfg.needLevel
   end
   if playerVoApi:getPlayerLevel()>=level then
        return true
   end
   return false
end

-- 是否在时间范围内(天)
function alienMinesVoApi:checkIsActive()
    -- local date=os.date("*t",base.serverTime)
    local week=G_getFormatWeekDay(base.serverTime)
    local openTime=G_clone(self:getBeginAndEndData())
    if openTime[2]==0 then
      openTime[2]=7
    end
    if openTime[1]==0 then
      openTime[1]=7
    end
    if(week==openTime[1] or week==openTime[2]) then
        return true
    else
        return false    
    end
end

-- 判断是否是周一
function alienMinesVoApi:checkIsMonday()
    -- local date=os.date("*t",base.serverTime)
    local week=G_getFormatWeekDay(base.serverTime)
    local openTime=G_clone(self:getBeginAndEndData())
    if(week==openTime[2]+1)then
        return true
    else
        return false    
    end
end

-- 是否在时间范围内(小时)
function alienMinesVoApi:checkIsActive2()
  local startTime,endTime=self:getBeginAndEndtime()
   local ts = G_getWeeTs(base.serverTime)
   local difTs=base.serverTime-ts
   local beginTs = startTime[1]*3600+startTime[2]*60
   local endTs = endTime[1]*3600+endTime[2]*60
   if difTs>=beginTs and difTs<=endTs then
        return true
    end
    return false
end

-- 结束一分15秒拉部队
function alienMinesVoApi:checkIsActive6()
  local startTime,endTime=self:getBeginAndEndtime()
   local ts = G_getWeeTs(base.serverTime)
   local difTs=base.serverTime-ts
   local endTs = endTime[1]*3600+endTime[2]*60
   if difTs-endTs>=75 then
      return true
   end
    return false
end

-- 是否结束后五分钟调用发奖励邮件
function alienMinesVoApi:checkIsActive3()
    -- 开放日
   local flag = self:checkIsActive()
   if flag==true then

           local ts = G_getWeeTs(base.serverTime)
           local difTs=base.serverTime-ts
           local startTime,endTime=self:getBeginAndEndtime()
           local endTs = endTime[1]*3600+endTime[2]*60
           if difTs-endTs>=300 then
                local function callback(fn,data)
                    local result,sData=base:checkServerData(data)
                    if result==true then
                        self.email_flag=true
                    end
                end
                socketHelper:alienMinesGetRankReward(callback)
           end
   end
  
end



--进攻面板
function alienMinesVoApi:showAttackDialog(flag,data,layerNum,parent)
    -- --判断是否被占领
    -- if self.data.oid==playerVoApi:getUid() then
    --  smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("city_info_cant_attack_tip"),true,4)
    --  do return end
    -- end
    --判断被保护
    if data.ptEndTime>=base.serverTime then
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("playerhavenoFightBuffattack"),true,layerNum+1)
        do return end
    end
    -- --判断是否是盟友 同联盟
    -- if self.data.allianceName and allianceVoApi:isSameAlliance(self.data.allianceName) then
    --  smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("city_info_cant_attack_tip_1"),true,4)
    --  do return end
    -- end
    --判断是否有能量
    -- if playerVoApi:getEnergy()<=0 then
    --     local function buyEnergy()
    --         G_buyEnergy(5)
    --     end
    --     smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyEnergy,getlocal("dialog_title_prompt"),getlocal("energyis0"),nil,layerNum+1)
    --     do return end
    -- end
    -- flag 
     -- 0 不采集，==> 掠夺玩家，如果矿场没有玩家不能掠夺
     -- 1采集，==> 采集，分矿场有人和无人，有人打人，无人直接打岛
    require "luascript/script/game/scene/gamedialog/alienMines/alienMinesTankAttackDialog"
    local td=alienMinesTankAttackDialog:new(data.type,data,layerNum,true,flag,parent)
    local tbArr={getlocal("AEFFighting"),getlocal("repair")}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,7)
    sceneGame:addChild(dialog,layerNum)
end

-- alienMinesInfoVo 信息 （开始时间 次数等）
function alienMinesVoApi:setInfoVo(data)
    local dailyOccupyNum=data.alienmineGet.dailyOccupyNum or 0
    local updated_at=data.alienmineGet.updated_at
    local dailyRobNum=data.alienmineGet.dailyRobNum or 0
    local endTime=data.alienmineCfg.endTime
    local startTime=data.alienmineCfg.startTime
    local openTime=data.alienmineCfg.openTime
    local totoalRobNum=data.alienmineCfg.dailyRobNum or alienMineCfg.dailyRobNum
    local totoalOccupyNum=data.alienmineCfg.dailyOccupyNum or alienMineCfg.dailyOccupyNum
    self.infoVo=alienMinesInfoVo:new(dailyOccupyNum,updated_at,dailyRobNum,endTime,startTime,openTime,totoalRobNum,totoalOccupyNum)
end

-- 得到开始和结束时间
function alienMinesVoApi:getBeginAndEndtime(flag)
  if flag then
    return self.infoVo.startTime,self.infoVo.endTime
  end
  if self.infoVo.startTime and self.infoVo.endTime then
    return self.infoVo.startTime,self.infoVo.endTime
  else
    return alienMineCfg.startTime, alienMineCfg.endTime
  end
   
end

-- 得到开始和结束日期
function alienMinesVoApi:getBeginAndEndData()
  if self.infoVo.openTime then
    return self.infoVo.openTime
  else
    return alienMineCfg.openTime
  end
   
end

-- 得到掠夺次数
function alienMinesVoApi:getRobNum()
   return self.infoVo.dailyRobNum or 0
end

-- 得到占领次数
function alienMinesVoApi:getOccupyNum()
   return self.infoVo.dailyOccupyNum or 0
end

-- 得到配置占领次数
function alienMinesVoApi:getTotalOccupyNum()
   return self.infoVo.totoalOccupyNum or alienMineCfg.dailyOccupyNum
end

-- 得到配置掠夺次数
function alienMinesVoApi:getTotalRobNum()
   return self.infoVo.totoalRobNum or alienMineCfg.dailyRobNum
end

-- 设置掠夺次数
function alienMinesVoApi:setRobNum(flag)
   local num = self:getRobNum()
   self.infoVo.dailyRobNum=num+flag
end

-- 设置占领次数
function alienMinesVoApi:setOccupyNum(flag)
  local num = self:getOccupyNum()
   self.infoVo.dailyOccupyNum=num+flag
end

-- 个人和军团
--得到排行榜刷新时间
function alienMinesVoApi:getRefreshRankTime()
  return self.refreshRankTime
end

--设置排行榜刷新时间
function alienMinesVoApi:setRefreshRankTime(time)
  self.refreshRankTime=time
end

--得到排行榜刷新时间
function alienMinesVoApi:getRefreshRankTime2()
  return self.refreshRankTime2
end

--设置排行榜刷新时间
function alienMinesVoApi:setRefreshRankTime2(time)
  self.refreshRankTime2=time
end

-- 结束时间是否大于五分钟
function alienMinesVoApi:checkIsActive4()
  local startTime,endTime=self:getBeginAndEndtime()
   local ts = G_getWeeTs(base.serverTime)
   local difTs=base.serverTime-ts
   local endTs = endTime[1]*3600+endTime[2]*60
   if difTs-endTs>=300 then
       return true
   end
  return false
end

-- 结束后到结束后五分之前
function alienMinesVoApi:checkIsActive5()
    local startTime,endTime=self:getBeginAndEndtime()
   local ts = G_getWeeTs(base.serverTime)
   local difTs=base.serverTime-ts
   local endTs = endTime[1]*3600+endTime[2]*60
   if difTs-endTs>=0 and difTs-endTs<=300 then
       return true
   end
  return false
end

-- 领奖邮件触发标志
function alienMinesVoApi:getEmailFlag()
    return self.email_flag
end

function alienMinesVoApi:tick()
    if self.infoVo and self.infoVo.updated_at then
        if G_isToday(self.infoVo.updated_at)==true then
        else
            self.infoVo.updated_at=base.serverTime
            self.infoVo.dailyOccupyNum=0
            self.infoVo.dailyRobNum=0
        end
    end

    if base.amap and base.amap>0 then
        if self:getIsSendChat()==false and self:checkIsActive()==true and self:checkIsActive2()==true then
            local params={subType=4,contentType=3,message={key="alienMines_open_chat",param={}},ts=base.serverTime}
            chatVoApi:addChat(1,0,"",0,"",params,base.serverTime)
            self:setIsSendChat(true)
        end
    end
end

function alienMinesVoApi:setallBaseVoExpireTime()
  for k,v in pairs(self.allBaseByArea) do
    for kk,vv in pairs(v) do
      vv.expireTime=0
    end
  end
end

function alienMinesVoApi:setBaseVoByXY(x,y,vv)
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
         self.allBaseByArea[areaX*1000+areaY][x*1000+y]=vv
    end
end

-- 从后台到前台标志位
function alienMinesVoApi:setrefreshFlag(flag)
  self.refreshFlag=flag
end

function alienMinesVoApi:getrefreshFlag()
  return self.refreshFlag
end











