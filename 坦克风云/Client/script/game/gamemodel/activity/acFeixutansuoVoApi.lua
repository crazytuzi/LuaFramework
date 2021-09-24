acFeixutansuoVoApi={
	rewardList=nil
}

function acFeixutansuoVoApi:getAcVo()
	return activityVoApi:getActivityVo("feixutansuo")
end

function acFeixutansuoVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end
function acFeixutansuoVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acFeixutansuoVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acFeixutansuoVoApi:getShowCityID()
	local vo=self:getAcVo()
	if vo and vo.l then
		return vo.l
	end
	return 1
end
function acFeixutansuoVoApi:updateShowCityID(id)
	local vo=self:getAcVo()
	if vo  then
		vo.l = id
	end
	return 0
end

function acFeixutansuoVoApi:getLotteryOnceCost( ... )
	local vo=self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return 0
end

function acFeixutansuoVoApi:getLotteryTenCost( ... )
	local vo=self:getAcVo()
	if vo and vo.cost and vo.mul and vo.mulc then
		return vo.cost*vo.mul*(vo.mulc/vo.mul)
	end
	return 0
end

function acFeixutansuoVoApi:getRefitTankNeedCfg( ... )
	local vo=self:getAcVo()
	if vo and vo.consume then
		return vo.consume
	end
	return {}
end

function acFeixutansuoVoApi:getTankID( ... )
	local vo=self:getAcVo()
	local aid
	local tankID
	if vo and vo.consume then
		for k,v in pairs(vo.consume) do
			aid=k
		end
	end
	if aid then
		local arr = Split(aid,"a")
		tankID =arr[2]
	end
	return aid,tonumber(tankID)
end
function acFeixutansuoVoApi:getRefitNeedTankIDAndNum( ... )
	local aid,tankID = acFeixutansuoVoApi:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local needAid
	local needTankID
	local upgradeShipConsume = {}
	if aid and consume and consume[aid] and consume[aid]["upgradeShipConsume"] then
		upgradeShipConsume=consume[aid]["upgradeShipConsume"]
		needAid = upgradeShipConsume[1]
		needNum = upgradeShipConsume[2]
	end
	if needAid then
		local arr = Split(needAid,"a")
		needTankID =arr[2]
	end
	return tonumber(needTankID),tonumber(needNum)
end

function acFeixutansuoVoApi:getUpgradedTankResources()
	local aid,tankID = acFeixutansuoVoApi:getTankID()
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

function acFeixutansuoVoApi:getUpgradePropConsume( )
	local aid,tankID = acFeixutansuoVoApi:getTankID()
	local consume = self:getRefitTankNeedCfg()
	local upgradePropConsume
	if consume and aid and consume[aid] and consume[aid]["upgradePropConsume"] then
		upgradePropConsume=consume[aid]["upgradePropConsume"]
	end
	return upgradePropConsume

end


function acFeixutansuoVoApi:getVipCfg()

	 -- vipCost={
  --                   --{vip等级， 消耗的金币， 取第四个奖池, 每日次数限制}
  --                   {{1,2}, 1000, 4, 5},
  --                   {{3,4}, 800, 4, 6},
  --                   {{4,5}, 600, 4, 7},
  --                   {{6,7}, 500, 4, 8},
  --                   {{8,9}, 400, 4, 9},
  --               },

	local vo=self:getAcVo()
	if vo and vo.vipCfg then
		return vo.vipCfg
	end
	return {}
end
function acFeixutansuoVoApi:getVipCost()
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

function acFeixutansuoVoApi:getVipTansuoTotal()
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

function acFeixutansuoVoApi:getVipHadTansuoNum()
	local vo=self:getAcVo()
	if vo and vo.vipHadNum then
		if self:isToday() == false then
			vo.vipHadNum = 0
		end
		return vo.vipHadNum
	end
	return 0
end
function acFeixutansuoVoApi:addVipHadTansuoNum(num)
	local vo=self:getAcVo()
	if vo then
		if vo.vipHadNum == nil then
			vo.vipHadNum =0 
		end
		vo.vipHadNum = vo.vipHadNum+num
	end
end
function acFeixutansuoVoApi:updateVipHadTansuoNum()
	local vo=self:getAcVo()
	if vo then
		if self:isToday() == false then
			vo.vipHadNum = 0
		end
	end
end

function acFeixutansuoVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = base.serverTime
	end
end

function acFeixutansuoVoApi:getRewardList()
	return self.rewardList
end
function acFeixutansuoVoApi:setRewardList(list)
	self.rewardList=list
end

function acFeixutansuoVoApi:getRewardsCfg()
	local vo = self:getAcVo()
	if vo and vo.rewardCfg then
		return vo.rewardCfg
	end
	return {}
end
function acFeixutansuoVoApi:getRewardByID(id)
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
							    local equipId
							    local noUseIdx=0 --无用的index 只是占位
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
function acFeixutansuoVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acFeixutansuoVoApi:canReward()

	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
    
end

-- 以下是新版需添加
-- mustMode 判断新版本还是旧版本
function acFeixutansuoVoApi:getMustMode()
	local vo = self:getAcVo()
	if vo.mustMode and tonumber(vo.mustMode)==1 then
		return true
	end
	return false
end
