BossBattleVo=dailyActivityVo:new()
function BossBattleVo:new(type)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.type=type
    return nc
end

function BossBattleVo:canReward()
	if BossBattleVoApi:hadRankReward() == false and (BossBattleVoApi:getBossState()~=3 and BossBattleVoApi:canRankReward() == true) then
		return true
	else
		return false
	end
end


function BossBattleVo:dispose()
	BossBattleVoApi:clear()
end
-- info={}, --buff等信息
  --       point =0, --积分=血量
  --       auto=0, -- 是否自动攻击
  --       binfo={}, --设置部队镜像和英雄
  --       attack_at=0, --上一次攻击时间
  --       buy_at   =0, --上一次购买buff时间
  --       reward_at   =0, --上一次领奖时间
  --       updated_at=0,   -- 最近一次更新时间 

  -- "worldboss": {
  --           "auto": 0,
  --           "binfo": {},
  --           "buy_at": 0,
  --           "point": 0,
  --           "boss": [
  --               20,
  --               968,
  --               0
  --           ],
  --           "attack_at": 0,
  --           "info": {}
  --       }
function BossBattleVo:updateData(data)
    if data.st then
      self.st = data.st
    end
    if data.et then
        self.et = data.et
    end

	if data.info then
		self.buffInfo ={}
		if data.info.b then --buff
			self.buffInfo = data.info.b
		end
		self.attackedTb ={}
		if data.info.k then --击杀炮头信息
			self.attackedTb=data.info.k
		end
	end
	
	if data.attack_at then
	 	self.attack_at = data.attack_at
	end

	if data.auto then
		self.attackSelf = data.auto
	end

	if data.point then
		self.point = data.point
	end
	if data.binfo then
		self.binfo = data.binfo
	end
	if data.binfo then
		if data.binfo.t then
			self.bossTroops = data.binfo.t
			tankVoApi:clearTanksTbByType(12)
		    for k,v in pairs(data.binfo.t) do
		        if v[1]~=nil and v[2]~=nil then
		            local tid=RemoveFirstChar(v[1])
		            tankVoApi:setTanksByType(12,k,tonumber(tid),v[2])
		        end
		    end
		end

		if data.binfo.h then
			self.bossHero = data.binfo.h
			heroVoApi:setBossHeroList(data.binfo.h)
		end
		if data.binfo.aitroops then --AI部队
			AITroopsFleetVoApi:setBossAITroopsList(data.binfo.aitroops)
		end
		if data.binfo.se then
			emblemVoApi:setBattleEquip(12,data.binfo.se)
		end
		if data.binfo.plane then
			planeVoApi:setBattleEquip(12,data.binfo.plane)
		end
		if data.binfo.airship then --飞艇
			airShipVoApi:setBattleEquip(12, data.binfo.airship)
		end
	end

	
	if data.buy_at then
		self.buyBuffTime = data.buy_at
	end

	if data.reward_at then
		self.rewardTime = data.reward_at
	end

	if data.updated_at then
		self.updatedTime = data.updated_at
	end

	if data.boss and type(data.boss)=="table" then
		if data.boss[1] then
			self.bossLv = data.boss[1]
		end
		if data.boss[2] then
			self.bossMaxHp = data.boss[2]
		end
		if data.boss[3] then
			self.bossDamage= data.boss[3]
		end
		if data.boss[4] then
			self.bossGround = data.boss[4]
		end
		if data.boss[5] then
			self.bossOldHp = data.boss[5]
		end
	end


end

function BossBattleVo:checkActive()
	if base.dailyAcYouhuaSwitch==1 then
		local st = bossCfg.opentime[1][1]*60*60+bossCfg.opentime[1][2]*60
	    local et = bossCfg.opentime[2][1]*60*60+bossCfg.opentime[2][2]*60
	    local dayTime=base.serverTime-G_getWeeTs(base.serverTime)
	    if dayTime and dayTime>st and dayTime<et then
	        return true
	    end
	end
    return false
end