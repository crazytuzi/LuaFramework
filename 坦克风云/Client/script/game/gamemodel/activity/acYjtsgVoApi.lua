acYjtsgVoApi={
	rewardList=nil,
	name=nil,
}

function acYjtsgVoApi:setActiveName(name)
	self.name=name
end

function acYjtsgVoApi:getActiveName()
	return self.name or "yjtsg"
end

function acYjtsgVoApi:clearAll()
	self.rewardList=nil
end


function acYjtsgVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acYjtsgVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end
function acYjtsgVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acYjtsgVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acYjtsgVoApi:getShowCityID()
	local vo=self:getAcVo()
	if vo and vo.l then
		return vo.l
	end
	return 1
end
function acYjtsgVoApi:updateShowCityID(id)
	local vo=self:getAcVo()
	if vo  then
		vo.l = id
	end
	return 0
end

function acYjtsgVoApi:getLotteryOnceCost( ... )
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.cost
	end
	return 0
end

function acYjtsgVoApi:getLotteryTenCost( ... )
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.cost*vo.activeCfg.mul*(vo.activeCfg.mulc/vo.activeCfg.mul)
	end
	return 0
end

function acYjtsgVoApi:getRefitTankNeedCfg( ... )
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.consume
	end
	return {}
end

function acYjtsgVoApi:getTankID()
	local vo=self:getAcVo()
	local aidTb={}
	local tankIDTb={}
	if vo and vo.activeCfg then
		for k,v in pairs(vo.activeCfg.consume) do
			aidTb[v.index]=k
		end
	end
	if aidTb then
		for k,v in pairs(aidTb) do
			local arr = Split(v,"a")
			tankIDTb[k] =tonumber(arr[2])
		end
	end
	return aidTb,tankIDTb
end
function acYjtsgVoApi:getRefitNeedTankIDAndNum(aid,tankID)
	local consume = self:getRefitTankNeedCfg()
	local needAidTb={}
	local needTankIDTb={}
	local needNumTb={}
	local upgradeShipConsume = {}
	if aid and consume and consume[aid] and consume[aid]["upgradeShipConsume"] then
		upgradeShipConsume=consume[aid]["upgradeShipConsume"]
		-- needAidTb = upgradeShipConsume[1]
		-- needNum = upgradeShipConsume[2]
		for i=1,#upgradeShipConsume do
			needAidTb[i]=upgradeShipConsume[i][1]
			needNumTb[i]=upgradeShipConsume[i][2]
		end
	end
	if needAidTb then
		for k,v in pairs(needAidTb) do
			local arr = Split(v,"a")
			needTankIDTb[k] =tonumber(arr[2])
		end
		
	end
	return needTankIDTb,needNumTb
end

function acYjtsgVoApi:getUpgradedTankResources(aid,tankID)
	local consume = self:getRefitTankNeedCfg()
	local r1,r2,r3,r4,reUpgradedMoney=0,0,0,0,0
	if consume and aid then
		r1=tonumber(consume[aid]["upgradeMetalConsume"])
		r2=tonumber(consume[aid]["upgradeOilConsume"])
		r3=tonumber(consume[aid]["upgradeSiliconConsume"])
		r4=tonumber(consume[aid]["upgradeUraniumConsume"])
		reUpgradedMoney=tonumber(tankCfg[tankID]["upgradeTimeConsume"])
	end
    
    return r1,r2,r3,r4,reUpgradedMoney
end

function acYjtsgVoApi:getUpgradePropConsume(aid,tankID)
	local consume = self:getRefitTankNeedCfg()
	local upgradePropConsume
	if consume and aid and consume[aid] and consume[aid]["upgradePropConsume"] then
		upgradePropConsume=consume[aid]["upgradePropConsume"]
	end
	return upgradePropConsume
end


function acYjtsgVoApi:getVipCfg()

	 -- vipCost={
  --                   --{vip等级， 消耗的金币， 取第四个奖池, 每日次数限制}
  --                   {{1,2}, 1000, 4, 5},
  --                   {{3,4}, 800, 4, 6},
  --                   {{4,5}, 600, 4, 7},
  --                   {{6,7}, 500, 4, 8},
  --                   {{8,9}, 400, 4, 9},
  --               },

	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.vipCost
	end
	return {}
end
function acYjtsgVoApi:getVipCost()
	local vipLv = playerVoApi:getVipLevel()
	local cfg = self:getVipCfg()
	if cfg then
		for k,v in pairs(cfg) do
			if v and v[1] and type(v[1])=="table" and v[1][1] and v[1][2] then
				if vipLv>=v[1][1] and vipLv<=v[1][2] and v[2] then
					return v[2]
				end
			end
		end
	end
	return 0
end

function acYjtsgVoApi:getVipTansuoTotal()
	local vipLv = playerVoApi:getVipLevel()
	local cfg = self:getVipCfg()
	if cfg then
		for k,v in pairs(cfg) do
			if v and v[1] and type(v[1])=="table" and v[1][1] and v[1][2] then
				if vipLv>=v[1][1] and vipLv<=v[1][2] and v[4] then
					return v[4]
				end
			end
		end
	end
	return 0
end

function acYjtsgVoApi:getVipHadTansuoNum()
	local vo=self:getAcVo()
	if vo and vo.vipHadNum then
		if self:isToday() == false then
			vo.vipHadNum = 0
		end
		return vo.vipHadNum
	end
	return 0
end
function acYjtsgVoApi:addVipHadTansuoNum(num)
	local vo=self:getAcVo()
	if vo then
		if vo.vipHadNum == nil then
			vo.vipHadNum =0 
		end
		vo.vipHadNum = vo.vipHadNum+num
	end
end
function acYjtsgVoApi:updateVipHadTansuoNum()
	local vo=self:getAcVo()
	if vo then
		if self:isToday() == false then
			vo.vipHadNum = 0
		end
	end
end

function acYjtsgVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = base.serverTime
	end
end

function acYjtsgVoApi:getRewardList()
	return self.rewardList
end
function acYjtsgVoApi:setRewardList(list)
	self.rewardList=list
end

function acYjtsgVoApi:getRewardsCfg()
	local vo = self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.rewardlist
	end
	return {}
end
function acYjtsgVoApi:getRewardByID(id)
	local cfg = self:getRewardsCfg()
	if cfg then
		for k,v in pairs(cfg) do
			if k and v and k==id then
				-- return v
				--格式化奖励
								local formatData={}	
								local num=0
								local name=""
								local pic=""
								local desc=""
							    local id=0
								local index=0
							    local eType=""
							    local noUseIdx=0 --无用的index 只是占位
							    local equipId
								if v then
									for x,y in pairs(v) do
										if y then
											for m,n in pairs(y) do
												if m~=nil and n~=nil then
													local key,type1,num=m,x,n
													local isSpecial
													if type(n)=="table" then
														for i,j in pairs(n) do
															if i=="index" then
																index=j
															elseif i=="isSpecial" then
																isSpecial=j
															else
																key=i
																num=j
															end
														end
													end
													name,pic,desc,id,noUseIdx,eType,equipId=getItem(key,type1)
													if name and name~="" then
														table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId,isSpecial=isSpecial})
													end
												end
											end
										end
									end
								end
								if formatData and SizeOfTable(formatData)>0 then
									local function sortAsc(a, b)
										if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
											return a.index < b.index
										end
								    end
									table.sort(formatData,sortAsc)
								end
								return formatData
			end
		end
	end
	return {}
end
function acYjtsgVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acYjtsgVoApi:returnTankData()
	local vo = self:getAcVo()
	local aid,tankID = self:getTankIdAndAid()
	require "luascript/script/game/scene/tank/tankShowData"
	if  tankShowData == nil or tankShowData[aid]==nil then
		return nil
	end
	
	return tankShowData[aid]
end
function acYjtsgVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
    
end

function acYjtsgVoApi:getTankIdAndAid()
    -- local version = self:getVersion( )
    local vo = self:getAcVo()
    if vo and vo.activeCfg then
    	local aid=vo.activeCfg.tankId
    	local tankID=tonumber(RemoveFirstChar(aid))
    	return aid,tankID
    end
end

-- 以下是新版需添加
-- mustMode 判断新版本还是旧版本
function acYjtsgVoApi:getMustMode()
	local vo = self:getAcVo()
	if vo.activeCfg.mustMode and tonumber(vo.activeCfg.mustMode)==1 then
		return true
	end
	return false
end

function acYjtsgVoApi:getMustReward1()
	local vo = self:getAcVo()
	if vo.activeCfg.mustReward1 then
		return vo.activeCfg.mustReward1
	end
	return {}
end

function acYjtsgVoApi:getMustReward2()
	local vo = self:getAcVo()
	if vo.activeCfg.mustReward2 then
		return vo.activeCfg.mustReward2
	end
	return {}
end

function acYjtsgVoApi:getMustReward3()
	local vo = self:getAcVo()
	if vo.activeCfg.mustReward3 then
		return vo.activeCfg.mustReward3
	end
	return {}
end

function acYjtsgVoApi:getAwardCfgByIdx(whiIdx)
		local vo = self:getAcVo()
		local cfg = self:getRewardsCfg()
		local formatCfg = {}
		if whiIdx ==2 then
			formatCfg =self:getRewardByID(#cfg)
		elseif whiIdx ==1 then

			for k,v in pairs(cfg) do
				local curFormatCfg = self:getRewardByID(k)
				for m,n in pairs(curFormatCfg) do
					if SizeOfTable(formatCfg) >0 then
						local isReapet = false
						for kk,vv in pairs(formatCfg) do
							if vv.name ==n.name and vv.num ==n.num then
								isReapet =true
								do break end
							end
						end
						if isReapet ==true then
							isReapet =false
						else
							table.insert(formatCfg,n)
						end
					else
						table.insert(formatCfg,n)
					end
				end
			end
		end

		return formatCfg
end

function acYjtsgVoApi:getCurMustAward(idx)
	local mustReward = {}
	if idx ==1 then
		mustReward =self:getMustReward1()
	elseif idx ==2 then
		mustReward = self:getMustReward3()
	else
	end
	local rewardItem = FormatItem(mustReward.reward)

	return rewardItem
end

function acYjtsgVoApi:getActivityIcon(activeName)
	local acVo=self:getAcVo(activeName)
	local aid=acVo.activeCfg.tankId
	local tankID=tonumber(RemoveFirstChar(aid))
	return tankCfg[tankID].icon
end


