playerVo={aid=0,isATag=0} --isATag 0就是无变化 1公会从无到有 2公会从有到无
function playerVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function playerVo:initWithData(data)
    if data.alliance==nil then
        data.alliance=0
    end
    if tonumber(data.alliance)>0 and tonumber(self.aid)==0 then
        self.isATag=1
    elseif tonumber(data.alliance)==0 and tonumber(self.aid)>0 then
        self.isATag=2
    else
        self.isATag=0
    end
    self.baseChange=false
    self.oldmapx=0
    self.oldmapy=0
    if self.mapx~=nil then
        if  tonumber(data.mapx)~=tonumber(self.mapx) or tonumber(data.mapy)~=tonumber(self.mapy) then
             self.baseChange=true
             self.oldmapx=self.mapx
             self.oldmapy=self.mapy
        end
    end
    self.uid=data.uid
    self.name=data.nickname
    self.regdate=data.regdate
    self.isLevelUpgrade=false
    if self.level~=nil and self.level~=0 then
         if tonumber(data.level)>tonumber(self.level) then
            self.isLevelUpgrade=true
         end
    end
    self.level=data.level
    self.exp=data.exp
    self.energy=data.energy
    self.energycd=data.energycd
    if self.honors then
        local beforeLv = playerVoApi:getHonorInfo()
        local nowLv = playerVoApi:getHonorInfo(data.honors)
        if nowLv>beforeLv and beforeLv>0 and nowLv%10==0 then
            -- 1:玩家名称  2:活动名称 3:等级 4:奖励 5:技能名称
            local params = {key="honorUpgradeMessage",param={{playerVoApi:getPlayerName(),1},{nowLv,3}}}
            chatVoApi:sendUpdateMessage(41,params)
        end
    end
    self.honors=data.honors --声望
    
    self.credit=data.reputation --荣誉
    self.troops=data.troops
    self.rank=data.rank
    self.vip=data.vip
    self.buygems=data.buygems
    self.gems=data.gems
    --VIP成长点数
    if(data.vippoint)then
        self.vipPoint=tonumber(data.vippoint)
    else
        self.vipPoint=0
    end
    self.gold=data.gold
    self.r1=data.r1
    self.r2=data.r2
    self.r3=data.r3
    self.r4=data.r4
    self.mapx=(data.mapx==0 and 1 or data.mapx)
    self.mapy=(data.mapy==0 and 1 or data.mapy)
    self.buildingSlotNum=data.buildingslots
    self.protect=(data.protect==nil and 0 or data.protect)
    self.tutorial=data.tutorial
    -- self.pic=(data.pic==0 and 1 or data.pic)
    if data.pic==nil or data.pic==0 then
        self.pic=headCfg.default
    else
        self.pic=data.pic
    end
    self.title=data.title
    self.isGuest=(data.guest==1 and "0" or "1")
    self.cost=data.cost
    self.buyn=data.buyn
    self.buyts=data.buyts
    G_cancelPush("e"..G_EnergyFullTag,G_EnergyFullTag)
    if self.energycd~=0 then
        G_pushMessage(getlocal("energy_notice"),self.energycd,"e"..G_EnergyFullTag,G_EnergyFullTag)
    end
	self.power=data.fc or 0
    self.aid=data.alliance
    self.platformInfo=nil   --用户的平台信息（如FB名字、ID等）

    self.grow=data.grow
    self.growrd=data.growrd

    self.logindate=data.logindate or 0    --上一次登陆时间戳

    if self.flags==nil then
        self.flags={}
    end
    local onlineData = 0
    if data.flags.ol ~= nil then
        local ol = data.flags.ol
        if type(ol)=="table" then
            onlineData = tonumber(data.flags.ol[1])
        else
            onlineData = -1
        end
    end

    if data.flags.qq==nil then
        self.qq=0
    else
        self.qq = 1
    end

    --头像框ID
    if data.flags and data.flags.hb then
        self.hfid=data.flags.hb
    end
    self.hfid=self.hfid or headFrameCfg.default

    --聊天框ID
    if data.flags and data.flags.bb then
        self.cfid=data.flags.bb
    end
    self.cfid=self.cfid or chatFrameCfg.default


    if onlineData ~= nil then
        self.onlinePackage = onlineData -- 在线礼包已领取奖励次数（-1代表已经完全领取完，0代表一次未领取） 后台数据{领取次数，领取时间}，最后一次领取完成后，后台数据变成-1，一次未领取时后台没有对应数据
    else
        self.onlinePackage = 0
    end
    if(data.flags.fb)then
        friendVoApi:initFBData(data.flags.fb)
    end
    self.onlineTime = -1
    if(data.mc)then
        vipVoApi:initWithData(data.mc)
    end
    if(data.flags.vf)then
        vipVoApi:setVf(data.flags.vf)
    end
    if(data.flags.luck)then
        self.luck=data.flags.luck
    end
    if data.flags and data.flags.func then
        self.func=data.flags.func
    end
    --ba={}, 每日被其他玩家无视保护罩戏谑攻击次数(飞机主动技能s20){n=0,t=0}{次数,时间}
    if data.flags and data.flags.ba then 
        self.flags.ba=data.flags.ba
    end
    if data.flags and data.flags.mt then --叛军天眼buff生效结束时间
        self.flags.mt=data.flags.mt
    end
    if(self.baseChange)then
        eventDispatcher:dispatchEvent("user.basemove")
    end
    self.rankPoint=data.rp or 0             --用户总战功
    self.dailyRankPoint=data.drp or 0       --用户今日获得的战功
    self.getRankPointTime=data.rpt or 0     --上次获得战功的时间
    self.updateRankTime=data.urt or 0       --更新军衔的时间

    if self.serverWarRank==nil then
        self.serverWarRank=0
    end
    if self.serverWarRankStartTime==nil then
        self.serverWarRankStartTime=0
    end
    if data.crossranking and data.crossranking[1] and data.crossranking[2] then
        self.serverWarRank=data.crossranking[1] or 0   --跨服战排名
        self.serverWarRankStartTime=data.crossranking[2] or 0   --跨服战排名称号开始时间
    end
    if data.bid then
        self.bid=data.bid
    end
    if data.usegems then
        self.usegems=tonumber(data.usegems) or 0
    end 
    self.rpCoin=tonumber(data.rpb) or 0
    self.tempSlots=tonumber(data.tempslots) or 0            --临时建造位到期时间戳

    -- 玩家在世界地图的坐标
    self.startPosition = nil
    -- 总基金
    self.daily_fund =  tonumber(data.flags.daily_fund) or 0
    -- 每日基金
    self.daily_dfund =  data.flags.daily_dfund or {}

    -- 基地皮肤
    self.skin = data.flags.exter or {}
    -- 礼包推送
    self.xsjx = data.flags.xsjx
    
    self.nameChangedCD=data.flags.cdtime --玩家修改昵称时的时间戳

    self.energy_at = data.energy_at or base.serverTime --能量点上一次恢复的时间戳

    if data.flags and data.flags.mpay then --玩家月累计充值（货币非金币） mpay={月末时间戳,累计充值数}
        self.mpay=data.flags.mpay
    end
    self.daily_online_time = data.olts or 0 --玩家每日累计在线时长
end

function playerVo:afterGetOnlinePackageAward(flag)
    self.onlinePackage = self.onlinePackage + 1

    if self.onlinePackage >= SizeOfTable(playerCfg.onlinePackage) then
        self.onlinePackage = -1 -- 所有奖励都已经领取
    end
    self.onlineTime = 0
end

function playerVo:updateOnlineTime(data)
    self.onlineTime = data
end

function playerVo:setLastAddTime(t)
    self.lastAddTime = t
end


function playerVo:getLastAddTime()
    if self.lastAddTime ~= nil then
        return self.lastAddTime
    end
    return -1
end

