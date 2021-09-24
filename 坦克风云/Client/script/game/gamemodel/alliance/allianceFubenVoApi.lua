allianceFubenVoApi={
	flag={},
	fuben=nil,
    maxFubenNum=0,
    baseChapterNum=nil,--除副本boss外基础副本章节个数
    baseFubenNum=nil,--除副本boss外基础副本个数
    refreshBoss=false, --刷新boss
    requestCount=0, --请求boss信息次数
    requestTime=base.serverTime, --请求boss信息的时间
}


function allianceFubenVoApi:clear()
	self.flag={}
	self.fuben=nil
    self.maxFubenNum=0
    self.baseChapterNum=nil
    self.baseFubenNum=nil
    self.refreshBoss=false
    self.requestCount=0
    self.requestTime=base.serverTime
end

-- 开启的最大关卡(后台传)
function allianceFubenVoApi:getMaxNum()
    local maxNum=playerVoApi:getMaxLvByKey("unlockAllianceFuben")
    local cfgMaxNum=self:getBaseChapterNum()
    if maxNum and tonumber(maxNum) then
        maxNum=tonumber(maxNum)
        if maxNum>cfgMaxNum then
            maxNum=cfgMaxNum
        end
        if maxNum==cfgMaxNum and alliancebossCfg and alliancebossCfg.chapterCfg then --添加的副本boss的关卡
            maxNum=maxNum+1
        end
        return maxNum
    end
    return nil
end

function allianceFubenVoApi:initData()
	if self.fuben==nil then
        self.fuben=allianceFubenVo:new()
    end
    if SizeOfTable(self.fuben)<=0 then
    	self.fuben.unlockId=1
		self.fuben.attackCount=0
		self.fuben.rewardCount={}
		self.fuben.killCount={}
		self.fuben.refreshTime=0

		-- self:initTank()
        self.fuben.tank={}
        self.fuben.bcount=0 --boss副本已经领取的军需箱的个数
    end
    if self.fuben.boss==nil then
        self.fuben.boss={bossLv=alliancebossCfg.startLevel,oldHp=0,maxHp=0,attackedHp=0,lastKillTime=0,killCount=0}
    end
end

--partFlag是否只是拉取部分数据，（比如说建筑图标显示所拉取的数据）
function allianceFubenVoApi:formatData(data,partFlag)
	self:initData()

    if data.maxbid~=nil then
        self.fuben.unlockId=(tonumber(data.maxbid) or tonumber(RemoveFirstChar(data.maxbid))) or 1
    	-- self.fuben.unlockId=self.fuben.unlockId+1
    end
    if data.akcount~=nil then
        self.fuben.attackCount=tonumber(data.akcount) or 0
    end
    if data.rwcount~=nil then
        self.fuben.rewardCount=data.rwcount or {}
    end
    if data.krcount~=nil then
        self.fuben.killCount=data.krcount or {}
    end
    if data.refresh_at~=nil then
        self.fuben.refreshTime=tonumber(data.refresh_at) or 0
    end
    if data.tank~=nil then
    	for k,v in pairs(data.tank) do
    		local fid=tonumber(k) or tonumber(RemoveFirstChar(k))
   --  		local tankNumTab={}
			-- for m,n in pairs(v) do
			-- 	if n and SizeOfTable(n)>0 then
			-- 		tankNumTab[m]=tonumber(n[2]) or 0
			-- 	else
			-- 		tankNumTab[m]=0
			-- 	end
			-- end
			-- self.fuben.tank[fid]=tankNumTab
            self.fuben.tank[fid]=v

            local isKill=true
            for m,n in pairs(v) do
                if n[2] and tonumber(n[2])>0 then
                    isKill=false
                end
            end

            for k,v in pairs(self.fuben.killCount) do
                if tonumber(v)==tonumber(fid) then
                    -- if isKill==false then
                        table.remove(self.fuben.killCount,k)
                    -- end
                end
            end
            if isKill==true then
                table.insert(self.fuben.killCount,tonumber(fid))
                if self.fuben.unlockId<(tonumber(fid)+1) then
                    self.fuben.unlockId=tonumber(fid)+1
                    local maxNum=allianceFubenVoApi:getMaxFubenNum()+1
                    if self.fuben.unlockId>maxNum then
                        self.fuben.unlockId=maxNum
                    end
                end
            end

    	end
    end
    if data.bcount then
        self.fuben.bcount=data.bcount
    end
    -- 解锁的副本最大关卡
    -- local unlockMaxNum=self:getMaxNum()
    -- local chapterCfg=self:getChapterCfg()
    -- local maxNum=SizeOfTable(chapterCfg)
    -- local unlockNum=0
    -- if unlockMaxNum then
    --     for i=1,unlockMaxNum do
    --         unlockNum=unlockNum+chapterCfg[i].maxNum
    --     end
    --     if unlockNum>0 and self.fuben.unlockId>unlockNum then
    --         self.fuben.unlockId=unlockNum
    --     end
    -- end
    if partFlag==nil or partFlag==false then
        self:setAllFlag()
    end
end

function allianceFubenVoApi:formatBossData(data)
    self:initData()
    if data then
        if data.allianceboss then
            self.fuben.boss.bossLv=data.allianceboss[1] or alliancebossCfg.startLevel
            self.fuben.boss.maxHp=data.allianceboss[2] or 0
            self.fuben.boss.attackedHp=data.allianceboss[3] or 0
            self.fuben.boss.lastKillTime=data.allianceboss[4] or 0
            self.fuben.boss.oldHp=data.allianceboss[5] or data.allianceboss[2] or 0
        end
        if data.killcount then
            self.fuben.boss.killCount=tonumber(data.killcount) or 0
        end
    end
end

function allianceFubenVoApi:updateTank(data)
    if data and SizeOfTable(data)>0 then
        local tank=data
        local fid
        local isKill=false
        if SizeOfTable(tank)>0 then
            for k,v in pairs(tank) do
                if k=="w" then
                    if tonumber(v)==1 then
                        isKill=true
                    end
                else
                    fid=tonumber(k) or tonumber(RemoveFirstChar(k))
                    for m,n in pairs(v) do
                        if n and SizeOfTable(n)>0 then
                            if self.fuben.tank and self.fuben.tank[fid] and self.fuben.tank[fid][m] and SizeOfTable(self.fuben.tank[fid][m])>0 then
                                self.fuben.tank[fid][m][2]=self.fuben.tank[fid][m][2]-tonumber(n[2])
                                if self.fuben.tank[fid][m][2]<0 then
                                    self.fuben.tank[fid][m][2]=0
                                end
                            end
                        end
                    end
                end
            end
        end

        -- local isKill=false
        -- if fid and fid>0 then
        --     if self.fuben.tank and self.fuben.tank[fid] and SizeOfTable(self.fuben.tank[fid])>0 then
        --         isKill=true
        --         for k,v in pairs(self.fuben.tank[fid]) do
        --             if v and tonumber(v[2]) and tonumber(v[2])>0 then
        --                 isKill=false
        --             end
        --         end               
        --     end
        --     if isKill==true then
        --         allianceFubenVoApi:setKillCount(fid)
        --         if self.fuben.unlockId<(fid+1) then
        --             self.fuben.unlockId=fid+1
        --         end
        --     end
        -- end

        if fid and fid>0 then
            if isKill==true then
                allianceFubenVoApi:setKillCount(fid)
                if self.fuben.unlockId<(fid+1) then
                    self.fuben.unlockId=fid+1
                    local maxNum=allianceFubenVoApi:getMaxFubenNum()+1
                    if self.fuben.unlockId>maxNum then
                        self.fuben.unlockId=maxNum
                    end
                end
            end
        end


        self:setAllFlag()
    end
end

function allianceFubenVoApi:getChapterCfg()
    -- return allianceFubenCfg.chapterCfg

    -- 开启得副本最大关卡
    local openMaxNum=self:getMaxNum()
    local chapterCfg={}
    if openMaxNum then
        for i=1,openMaxNum do
            table.insert(chapterCfg,allianceFubenCfg.chapterCfg[i])
        end
    else
        chapterCfg=allianceFubenCfg.chapterCfg
    end
    return chapterCfg
end
function allianceFubenVoApi:getSectionCfg()
    return allianceFubenCfg.sectionCfg
end
function allianceFubenVoApi:getDailyAttackNum()
    local attackNumTab=playerCfg.vipAllianceFuben
    local attackMaxNum=attackNumTab[playerVoApi:getVipLevel()+1]
    return attackMaxNum
end

function allianceFubenVoApi:getMaxFubenNum()
    if self.maxFubenNum==nil or self.maxFubenNum==0 then
        local chapterCfg=allianceFubenVoApi:getChapterCfg()
        for k,v in pairs(chapterCfg) do
            self.maxFubenNum=self.maxFubenNum+v.maxNum
        end
    end
    return self.maxFubenNum
end

function allianceFubenVoApi:getFlag(idx)
	if SizeOfTable(self.flag)==0 then
        -- self:setAllFlag()
		return -1
	elseif idx and self.flag[idx] then
		return self.flag[idx]
	else
		return -1
	end
end
function allianceFubenVoApi:setFlag(idx,flag)
	self.flag[idx]=flag
end
function allianceFubenVoApi:setAllFlag()
    for i=1,3 do
        self.flag[i]=0
    end
end

function allianceFubenVoApi:getFuben()
	self:initData()
    return self.fuben
end


function allianceFubenVoApi:resetTankData()
    local sectionCfg=self:getSectionCfg()
    if self.fuben.tank and SizeOfTable(self.fuben.tank)>0 then
        for k,v in pairs(self.fuben.tank) do
            local fid=tonumber(k) or tonumber(RemoveFirstChar(k))

            if v and SizeOfTable(v)>0 then
                self.fuben.tank[fid]=nil
            end
            local tankTab={}

            local tankCfg=sectionCfg[fid].tank.o
            local tankTab={}
            for m,n in pairs(tankCfg) do
                for i,j in pairs(n) do
                    table.insert(tankTab,{i,j})
                end
            end
            
            -- local tankCfg=FormatItem(sectionCfg[fid].tank) or {}
            -- for m,n in pairs(tankCfg) do
            --     table.insert(tankTab,{n.key,n.num})
            -- end

            self.fuben.tank[fid]=tankTab

        end
    end
end
function allianceFubenVoApi:isRefreshData()
	self:initData()
    -- if self.testTs==nil then
    --     self.testTs=1394799342
    -- end
    -- if base.serverTime>self.testTs then

    if self.fuben.refreshTime~=0 and base.serverTime>(G_getWeeTs(self.fuben.refreshTime)+24*60*60) then
    	self.fuben.attackCount=0
		if self.fuben.rewardCount and SizeOfTable(self.fuben.rewardCount)>0 then
			for k,v in pairs(self.fuben.rewardCount) do
				table.remove(self.fuben.rewardCount,k)
			end
			self.fuben.rewardCount=nil
		end
	    self.fuben.rewardCount={}

	    if self.fuben.killCount and SizeOfTable(self.fuben.killCount)>0 then
			for k,v in pairs(self.fuben.killCount) do
				table.remove(self.fuben.killCount,k)
			end
			self.fuben.killCount=nil
		end
	    self.fuben.killCount={}

        self:resetTankData()

		self.fuben.refreshTime=self.fuben.refreshTime+24*60*60
        -- self.testTs=self.testTs+60*0.5--24*60*60
        self.fuben.boss={bossLv=alliancebossCfg.startLevel,oldHp=0,maxHp=0,attackedHp=0,lastKillTime=0,killCount=0}
        self.fuben.bcount=0

        self.requestCount=0
        self.requestTime=base.serverTime

        self:setAllFlag()
        
		return true
	end
	return false
end

function allianceFubenVoApi:setAttackCount()
	if self.fuben.attackCount then
		self.fuben.attackCount=self.fuben.attackCount+1
	else
		self.fuben.attackCount=1
	end
	self:setAllFlag()
end
function allianceFubenVoApi:setKillCount(fid)
	local isInsert=true
    for k,v in pairs(self.fuben.killCount) do
        if tonumber(v)==tonumber(fid) then
            isInsert=false
        end
    end
    if isInsert==true then
        table.insert(self.fuben.killCount,tonumber(fid))
    end
    if self.fuben.unlockId and self.fuben.unlockId==tonumber(fid) then
        self.fuben.unlockId=self.fuben.unlockId+1
        local maxNum=allianceFubenVoApi:getMaxFubenNum()+1
        if self.fuben.unlockId>maxNum then
            self.fuben.unlockId=maxNum
        end
    end
    self:setAllFlag()
end
function allianceFubenVoApi:setRewardCount(fid)
	local isInsert=true
    for k,v in pairs(self.fuben.rewardCount) do
        if tonumber(v)==tonumber(fid) then
            isInsert=false
        end
    end
    if isInsert==true then
        table.insert(self.fuben.rewardCount,tonumber(fid))
    end
    self:setAllFlag()
end

function allianceFubenVoApi:getBossFubenRewards()
    return alliancebossCfg.reward,alliancebossCfg.addexp
end

function allianceFubenVoApi:getBaseChapterNum()
    if self.baseChapterNum==nil then
        self.baseChapterNum=SizeOfTable(allianceFubenCfg.chapterCfg)
    end
    return self.baseChapterNum
end

function allianceFubenVoApi:getBaseFubenNum()
    if self.baseFubenNum==nil then
        self.baseFubenNum=SizeOfTable(allianceFubenCfg.sectionCfg)
    end
    return self.baseFubenNum
end

function allianceFubenVoApi:getBaseFubenLimitLv(chapterId)
    local limitLv=0
    if chapterId and tonumber(chapterId)>1 then
        limitLv=tonumber(allianceFubenCfg.levelLimit)
    end
    return limitLv
end

function allianceFubenVoApi:getAllianceBossKillCount()
    local count=0
    if self.fuben.boss then
        if self.fuben.boss.killCount then
            count=tonumber(self.fuben.boss.killCount)
        end
    end
    return count
end

function allianceFubenVoApi:setAllianceBossKilCount()
    if self.fuben and self.fuben.boss and self.fuben.boss.killCount then
        self.fuben.boss.killCount=self.fuben.boss.killCount+1
    end
end
--获取已经拥有的副本boss的军需箱个数
function allianceFubenVoApi:getAllianceBossRewardCount()
    local count=0
    if self.fuben.boss then
        local killCount=self:getAllianceBossKillCount()
        if self.fuben.bcount then
            count=tonumber(killCount)-tonumber(self.fuben.bcount)
            if count<0 then
                count=0
            end
        end
    end
    return count
end

--获取已经领取过的boss奖励次数
function allianceFubenVoApi:getbcount()
    local count=0
    if self.fuben.bcount then
        count=tonumber(self.fuben.bcount)
    end
    return count
end

function allianceFubenVoApi:setBossRewardCount(count)
    if self.fuben.bcount then
        self.fuben.bcount=self.fuben.bcount+tonumber(count)
    end
end

function allianceFubenVoApi:isFubenKilled(fubenId)
    local isKill=false
    if fubenId then
        local tankNum=0
        local tankNumTab=self.fuben.tank or {} --副本的部队信息
        local tankFubenTab=tankNumTab[fubenId] or {}
        if tankFubenTab and SizeOfTable(tankFubenTab)>0 then
            for k,v in pairs(tankFubenTab) do
                if v and tonumber(v[2]) then
                    tankNum=tankNum+tonumber(v[2])
                end
            end
            if tankNum<=0 then
                isKill=true
            end
        end
     
        for k,fid in pairs(self.fuben.killCount) do
            if tonumber(fid)==fubenId then
                isKill=true
                do break end
            end
        end
    end
    return isKill
end

function allianceFubenVoApi:isFubenOpen(fubenId)
    local isOpen=false
    if fubenId then
        local playerLv=playerVoApi:getPlayerLevel()
        if tonumber(fubenId)>5 then
            if playerLv>=tonumber(allianceFubenCfg.levelLimit) then
                isOpen=true
            end
        else
            isOpen=true
        end
    end
    return isOpen
end
--获取军团副本得到的军需箱
function allianceFubenVoApi:getFunbenRewards(flag)
    local rewardCount=0 --当前总的军需箱的个数
    local availableCount=0 --当前可以直接领取的军需箱的个数
    local costDonate=0 --本次一键领取奖励消耗的个人贡献值
    local fubenIdTb={} --普通副本奖励副本id
    local allbcount=0 --所有的boss军需箱
    local bossCount=0
    local bcount=0 --可以领取的boss军需箱个数
    local remainbcount=0

    local freeBoxFubenIdTb={} --免费宝箱副本id(不需要花费军团贡献值)
    local costBoxFubenIdTb={} --需要消耗贡献值的副本id
    local needCostDonate=0

    local canUseDonate=allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid()) --可以使用的个人贡献值
    local playerLv=playerVoApi:getPlayerLevel()
    if self.fuben then
        for k,v in pairs(allianceFubenCfg.sectionCfg) do
            local fubenId=tonumber(v.id)
            local isOpen=self:isFubenOpen(fubenId)
            local isUnlock=false
            if fubenId<=self.fuben.unlockId then
                isUnlock=true
            end
            if isOpen==true and isUnlock==true then
                local isKill=self:isFubenKilled(fubenId)
                local isReward=false
                for k,id in pairs(self.fuben.rewardCount) do
                    if tonumber(id)==fubenId then
                        isReward=true
                        do break end
                    end
                end           
                if isKill==true and isReward==false then
                    rewardCount=rewardCount+1
                    local cost=tonumber(v.raisingConsume)
                    if cost>0 then
                        allbcount=allbcount+1
                    end
                    if cost<=tonumber(canUseDonate) then
                        availableCount=availableCount+1
                        canUseDonate=canUseDonate-cost
                        costDonate=costDonate+cost
                        table.insert(fubenIdTb,fubenId)
                        if cost>0 then
                            bossCount=bossCount+1
                        end
                    end

                    if flag then
                        if cost > 0 then
                            table.insert(costBoxFubenIdTb, fubenId)
                            needCostDonate = needCostDonate + cost
                        else
                            table.insert(freeBoxFubenIdTb, fubenId)
                        end
                    end

                end
            end
        end
        if playerLv>=tonumber(alliancebossCfg.levelLimite) then
            local count=self:getAllianceBossRewardCount()
            rewardCount=rewardCount+count
            allbcount=allbcount+count
            if tonumber(alliancebossCfg.raisingConsume)>0 then
                local acount=math.floor(canUseDonate/tonumber(alliancebossCfg.raisingConsume))
                if acount<count then
                    bcount=acount
                    bossCount=bossCount+acount
                else
                    bcount=count
                    bossCount=bossCount+count
                end
            end
            availableCount=availableCount+bcount
            costDonate=costDonate+bcount*tonumber(alliancebossCfg.raisingConsume)

            if flag then
                needCostDonate = needCostDonate + count*tonumber(alliancebossCfg.raisingConsume)
            end

        end
    end
    remainbcount=allbcount-bossCount
    return rewardCount,availableCount,costDonate,fubenIdTb,bcount,bossCount,remainbcount,freeBoxFubenIdTb,costBoxFubenIdTb,needCostDonate
end

function allianceFubenVoApi:isBossFuben(chapterId)
    local isBoss=false
    local baseChapterNum=self:getBaseChapterNum()
    if chapterId and chapterId>baseChapterNum then
        isBoss=true
    end
    return isBoss
end

function allianceFubenVoApi:isBossFubenUnlock()
    local unlock=false
    if self.fuben and self.fuben.unlockId then
        local baseCount=self:getBaseFubenNum()
        local isKill=self:isFubenKilled(baseCount)
        if self.fuben.unlockId>=tonumber(baseCount+1) or isKill==true then
            unlock=true
        end
    end
    return unlock
end

function allianceFubenVoApi:getBossChapterCfg()
    return alliancebossCfg.chapterCfg
end

function allianceFubenVoApi:getBossFubenLimitLv()
    local lv=0
    if alliancebossCfg.levelLimite then
        lv=tonumber(alliancebossCfg.levelLimite)
    end
    return lv
end

function allianceFubenVoApi:getAllianceBossLv()
    return self.fuben.boss.bossLv
end

function allianceFubenVoApi:getAllianceBossHp()
    local curHp=0
    if self.fuben and self.fuben.boss then
        if self.fuben.boss.maxHp and self.fuben.boss.attackedHp then
            curHp=tonumber(self.fuben.boss.maxHp)-tonumber(self.fuben.boss.attackedHp)
            if curHp<0 then
                curHp=0
            end
        end
    end
    return curHp
end

function allianceFubenVoApi:setBossOldHp(hp)
    if self.fuben and self.fuben.boss and self.fuben.boss.oldHp then
        self.fuben.boss.oldHp=self.fuben.boss.oldHp-hp
    end
end

function allianceFubenVoApi:getBossOldHp()
    return self.fuben.boss.oldHp
end

function allianceFubenVoApi:getBossMaxHp()
    return self.fuben.boss.maxHp
end

function allianceFubenVoApi:setBossAttackedHp(damage)
    if self.fuben and self.fuben.boss and self.fuben.boss.attackedHp then
        self.fuben.boss.attackedHp=damage
    end
end

function allianceFubenVoApi:getBossAttackedHp()
    local attackedHp=0
    if self.fuben and self.fuben.boss and self.fuben.boss.attackedHp then
        attackedHp=self.fuben.boss.attackedHp
    end
    return attackedHp
end

function allianceFubenVoApi:getFubenBossState()
    local state=0
    local lefttime=0
    if base.fbboss==1 and self.fuben and self.fuben.boss then
        local curHp=self:getAllianceBossHp()
        if tonumber(curHp)<=0 then
            state=2
            local reviveTime=self.fuben.boss.lastKillTime+alliancebossCfg.exprie
            lefttime=tonumber(reviveTime)-tonumber(base.serverTime)
            if lefttime<=0 then
                lefttime=0
            end
        else
            state=1
        end
    end
    return state,lefttime
end

function allianceFubenVoApi:updateAllianceBoss(params)
    if params then
        if params.lastKillTime then
            if self.fuben and self.fuben.boss and self.fuben.boss.lastKillTime then
                if tonumber(self.fuben.boss.lastKillTime)<tonumber(params.lastKillTime) then
                    self.fuben.boss.lastKillTime=tonumber(params.lastKillTime)
                end
            end
        end
        if params.damage and tonumber(params.damage)>0 then
            local attackedHp=self:getBossAttackedHp()
            if tonumber(params.damage)>tonumber(attackedHp) then
                self:setBossAttackedHp(params.damage)
                eventDispatcher:dispatchEvent("allianceBossFuben.damageChanged",nil)
            end
        end
        if params.uid and params.isKill and params.isKill==1 then
            local uid=playerVoApi:getUid()
            if tostring(params.uid)~=tostring(uid) then
                self:setAllianceBossKilCount()
                for i=1,3 do
                    if self:getFlag(i)~=-1 then
                        self:setFlag(i,0)
                    end
                end
            end
        end
    end
end

function allianceFubenVoApi:getTankPaotouCfg()
    return alliancebossCfg.paotou
end

function allianceFubenVoApi:getBossPaotou()
    local tankTb = {}
    local oldHp=self.fuben.boss.oldHp
    local maxHp=self.fuben.boss.maxHp
    local paotouCfg=self:getTankPaotouCfg()
    if oldHp<=0 then
        return tankTb
    end
    for i=1,6 do
        if oldHp>maxHp/6*(i-1) then
            tankTb[paotouCfg[6-i+1]]=1
        end
    end
    return tankTb
end

function allianceFubenVoApi:getNoSubLifeBossPaotou(btdata,mm)--预先判断损失的炮口
  local oldHp=self.fuben.boss.oldHp
  local paotouCfg=self:getTankPaotouCfg()
  local subHp = 0
  for i=1,mm do
        local curDate = btdata[i]
        local dataTb=Split(curDate,"-")
        subHp = subHp + tonumber(dataTb[1])
  end

  local newHp = oldHp-subHp
  local maxHp = self.fuben.boss.maxHp
  local tankTb = {}
  if newHp <=0 then
    return tankTb
  end
  for i=1,6 do
    if newHp>maxHp/6*(i-1) then
      tankTb[paotouCfg[6-i+1]]=1
    end
  end

   return tankTb
end

function allianceFubenVoApi:getDestoryPaotouByHP(bossHP,oldHP)
    local maxHp=self:getBossMaxHp()
    local oldTankHP=oldHP
    local bossHp=bossHP
    local paotouCfg=self:getTankPaotouCfg()
    
    local oldPaotou={}
    if oldTankHP<=0 then
        oldPaotou={}
    end
    for i=1,6 do
        if oldTankHP>maxHp/6*(i-1) then
            oldPaotou[paotouCfg[6-i+1]]=1
        end
    end

    local destoryPaotou={}
    local tankTb={}
    for i=1,6 do
        if bossHp>maxHp/6*(i-1) then
            tankTb[paotouCfg[6-i+1]]=1
        end
    end

    for k,v in pairs(oldPaotou) do
        if v and tankTb[k]==nil then
            table.insert(destoryPaotou,k)
        end
    end
    return destoryPaotou
end

function allianceFubenVoApi:isSameToGunNum(btdata,curIdx,beAttkPos)
    local GunNums = SizeOfTable(self:getBossPaotou())
    local addHurt = 0
    local isDie = 1
    local maxHp = self:getBossMaxHp()
    local bossHp = self:getBossOldHp()
    local tankTb = {}
    local isSame = true
    local nextAttPos = 0
    local curGunNum = 0
    local paotouCfg = self:getTankPaotouCfg()
    for i=1,curIdx do
        if btdata==nil or  btdata[i]==nil then
            return isSame,0
        end
        local willHurtTb = Split(btdata[i],"-")
        addHurt =addHurt+willHurtTb[1]
        if willHurtTb[2] ==0 then
            isDie =willHurtTb[2]
        end
    end
    for i=1,6 do
        if bossHp-addHurt>maxHp/6*(i-1) then
        tankTb[paotouCfg[6-i+1]]=1
        end
    end
    for k,v in pairs(paotouCfg) do
        if v ==beAttkPos then
            curGunNum =k
        end
    end
    if SizeOfTable(tankTb) ~=GunNums and tankTb[paotouCfg[curGunNum]] ==nil then
        isSame =false
        for i=1,6 do
            if beAttkPos ==paotouCfg[i]  then
                if i+1>6 then
                    nextAttPos =paotouCfg[i-1]
                else
                    nextAttPos =paotouCfg[i+1]
                end
            end
        end
    end
    return isSame ,isDie,nextAttPos
end

function allianceFubenVoApi:tick()
    if base.fbboss==1 then
        local state,lefttime=self:getFubenBossState()
        if state==2 and lefttime<=0 then
            local function allianceBossGetHandler(fn,bossdata)
                local killCount=allianceFubenVoApi:getAllianceBossKillCount()
                local cret,cData=base:checkServerData(bossdata)
                if cret==true then
                    local curKill=allianceFubenVoApi:getAllianceBossKillCount()
                    if tonumber(curKill)~=tonumber(killCount) then
                        self:setAllFlag()
                    end
                    local data={changeType=2}
                    eventDispatcher:dispatchEvent("allianceBossFuben.damageChanged",data)
                    self.requestCount=0
                    self.requestTime=base.serverTime
                end
            end
            local timeSpace=tonumber(base.serverTime)-tonumber(self.requestTime)
            if (self.requestCount<=5 and timeSpace>10) or (self.requestCount>5 and timeSpace>60) then
                socketHelper:allianceBossGet(allianceBossGetHandler)
                self.requestCount=self.requestCount+1
                self.requestTime=base.serverTime
            end
        end
    end
end

function allianceFubenVoApi:getFubenRequest(callback)
    local cmd="achallenge.get"
    local params={}

    local function achallengeGetHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if base.fbboss==1 then
                local function allianceBossGetHandler(fn,bossdata)
                    local cret,cData=base:checkServerData(bossdata)
                    if callback then
                        callback()
                    end
                end
                socketHelper:allianceBossGet(allianceBossGetHandler)
            else
                if callback then
                    callback()
                end
            end
        end
    end
    local callback=achallengeGetHandler

    return cmd,params,callback
end