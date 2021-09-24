acRecyclingVoApi ={
	rewardList=nil
}

function acRecyclingVoApi:getAcVo( )
	return activityVoApi:getActivityVo("huiluzaizao")
end
function acRecyclingVoApi:getVersion(  )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end
function acRecyclingVoApi:canReward()

	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
    
end
function acRecyclingVoApi:returnTankData(idx)
	require "luascript/script/game/scene/tank/tankShowData"
	if idx ==nil then
		idx= 1
	end
	local vo = self:getAcVo()
	local aid,tankID,aidChoose = self:getTankID(idx)
	if  tankShowData and tankShowData[aid] then
		return tankShowData[aid]
	end
	-- if vo and vo.tankActionData then
	-- 	-- if idx ==1 then
	-- 		return vo.tankActionData[aid]
	-- 	-- elseif idx==2 then
	-- 	-- 	return vo.tankActionData["a20114"]
	-- 	-- end
	-- end
end
function acRecyclingVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acRecyclingVoApi:getRefitTankNeedCfg( ... )
	local vo=self:getAcVo()
	if vo and vo.consume then
		return vo.consume
	end
	return {}
end

function acRecyclingVoApi:getTankID(idx )
	local vo=self:getAcVo()
	local aid
	local tankID
	local con={}
	local ship = {}
	local whiIdx = 1
	if idx then
		whiIdx =idx
	end
	-- if vo and vo.consume then
	-- 	for k,v in pairs(vo.consume) do
	-- 		aid=k
	-- 	end
	-- end
	-- if aid then
	-- 	local arr = Split(aid,"a")
	-- 	tankID =arr[2]
	-- end

	if vo and vo.consume then
		con= vo.consume
		for k,v in pairs(con) do
			if k ==whiIdx then
				ship =v
			end
		end
		for k,v in pairs(ship.TransShipConsume) do
			if k ==1 then
				aid =v
			end
		end
		--print("aid....",aid)
	end
	if aid then
		local arr = Split(aid,"a")
		tankID =arr[2]
	end	
	return aid,tonumber(tankID),whiIdx
end

function acRecyclingVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end
function acRecyclingVoApi:updateShowCityID(id)
	local vo=self:getAcVo()
	if vo  then
		vo.l = id
	end
	return 0
end
function acRecyclingVoApi:getRewardsCfg()
	local vo = self:getAcVo()
	if vo and vo.rewardCfg then
		return vo.rewardCfg
	end
	return {}
end

function acRecyclingVoApi:addVipHadTansuoNum(num)
	local vo=self:getAcVo()
	if vo then
		if vo.vipHadNum == nil then
			vo.vipHadNum =0 
		end
		vo.vipHadNum = vo.vipHadNum+num
	end
end
function acRecyclingVoApi:updateVipHadTansuoNum()
	local vo=self:getAcVo()
	if vo then
		if self:isToday() == false then
			vo.vipHadNum = 0
		end
	end
end

function acRecyclingVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = base.serverTime
	end
end

function acRecyclingVoApi:getRewardList()
	return self.rewardList
end
function acRecyclingVoApi:setRewardList(list)
	self.rewardList=list
end

function acRecyclingVoApi:getRewardByID(id)
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

function acRecyclingVoApi:getShowCityID()
	local vo=self:getAcVo()
	if vo and vo.l then
		return vo.l
	end
	return 1
end
function acRecyclingVoApi:getLotteryOnceCost( ... )
	local vo=self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return 0
end
function acRecyclingVoApi:getLotteryTenCost( ... )
	local vo=self:getAcVo()
	if vo and vo.cost and vo.mul and vo.mulc then
		return vo.cost*vo.mul*(vo.mulc/vo.mul)
	end
	return 0
end

function acRecyclingVoApi:getRefitNeedTankIDAndNum( idx )
	local aid,tankID,idx = acRecyclingVoApi:getTankID(idx)
	local consume = self:getRefitTankNeedCfg()
	local needAid
	local needTankID
	local upgradeShipConsume = {}
	if aid and consume and consume[idx] and consume[idx]["upgradeShipConsume"] then
		upgradeShipConsume=consume[idx]["upgradeShipConsume"]
		needAid = upgradeShipConsume[1]
		needNum = upgradeShipConsume[2]
	end
	if needAid then
		local arr = Split(needAid,"a")
		needTankID =arr[2]
	end
	return tonumber(needTankID),tonumber(needNum)
end

function acRecyclingVoApi:getRefitNeedGoldNum( idx )
	local aid,tankID,idx = acRecyclingVoApi:getTankID(idx)
	local consume = self:getRefitTankNeedCfg()
	local needNum--,needIcon
	if consume and idx and  consume[idx] and consume[idx]["upgradeGemsConsume"] then
		needNum=consume[idx]["upgradeGemsConsume"]
		--needIcon ="GoldImage.png"
	end
	return tonumber(needNum)
end

function acRecyclingVoApi:getUpgradedTankResources(idx)
	local aid,tankID,idx = self:getTankID(idx)
	local consume = self:getRefitTankNeedCfg()
	local r1,r2,r3,r4,reUpgradedMoney=0,0,0,0,0
	if consume and aid then
		r1=tonumber(consume[idx]["upgradeMetalConsume"])
		r2=tonumber(consume[idx]["upgradeOilConsume"])
		r3=tonumber(consume[idx]["upgradeSiliconConsume"])
		r4=tonumber(consume[idx]["upgradeUraniumConsume"])
		reUpgradedMoney=tonumber(tankCfg[tankID]["upgradeTimeConsume"])
	end
    
    return r1,r2,r3,r4,reUpgradedMoney
end

function acRecyclingVoApi:getUpgradePropConsume(idx)
	local aid,tankID,idx = acRecyclingVoApi:getTankID(idx)
	local consume = self:getRefitTankNeedCfg()
	local upgradePropConsume
	if consume and aid and consume[idx] and consume[idx]["upgradePropConsume"] then
		upgradePropConsume=consume[idx]["upgradePropConsume"]
	end
	return upgradePropConsume

end

function acRecyclingVoApi:getVipCfg()

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
function acRecyclingVoApi:getVipCost()
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

function acRecyclingVoApi:getVipTansuoTotal()
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
function acRecyclingVoApi:getVipHadTansuoNum()
	local vo=self:getAcVo()
	if vo and vo.vipHadNum then
		if self:isToday() == false then
			vo.vipHadNum = 0
		end
		return vo.vipHadNum
	end
	return 0
end
function acRecyclingVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end