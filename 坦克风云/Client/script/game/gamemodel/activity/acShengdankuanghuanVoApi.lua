acShengdankuanghuanVoApi={
	treePoint=0,
	lastSt=0,
}

function acShengdankuanghuanVoApi:getAcVo(  )
	return activityVoApi:getActivityVo("shengdankuanghuan")
end

function acShengdankuanghuanVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return nil
end

function acShengdankuanghuanVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acShengdankuanghuanVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acShengdankuanghuanVoApi:updateAddGold(addMoney)
    local  tmpStoreCfg=G_getPlatStoreCfg()
    for k,v in pairs(tmpStoreCfg["gold"]) do
    	if v and tonumber(v)<=addMoney then
    		self:addCanReawrdByID(SizeOfTable(tmpStoreCfg["gold"])-k+1)
    		return
    	end
    end
end

function acShengdankuanghuanVoApi:getCanGoldReward()
	local vo = self:getAcVo()
	if vo and vo.rechargeReward then
		return vo.rechargeReward 
	end
	return {}
end

function acShengdankuanghuanVoApi:getCanRewardNumByID(id)
	local goldReward = self:getCanGoldReward()
	if goldReward then
		for k,v in pairs(goldReward) do
			if k==id and v then
				return tonumber(v)
			end

		end
	end
	return 0
end
function acShengdankuanghuanVoApi:addCanReawrdByID(id)
	local vo = self.getAcVo()
	if vo and vo.rechargeReward then
		if vo.rechargeReward[id]==nil then
			vo.rechargeReward[id]=0 
		end
		vo.rechargeReward[id]=vo.rechargeReward[id]+1
	end
end
function acShengdankuanghuanVoApi:updateCanRewardByID(id)
	local vo = self.getAcVo()
	if vo and vo.rechargeReward then
		for k,v in pairs(vo.rechargeReward) do
			if k and k==id and v and v>=1 then
				vo.rechargeReward[id]=v-1
			end
		end
	end
end

function acShengdankuanghuanVoApi:checkIsCanGoldReward()
	local goldReward = self:getCanGoldReward()
	if goldReward then
		for k,v in pairs(goldReward) do
			if v and v>=1 then
				return true
			end
		end
	end
	return false
end
function acShengdankuanghuanVoApi:getSmallPoint()
	local vo  = self:getAcVo()
	if vo and vo.smallPoint then
		return tonumber(vo.smallPoint*100)
	end
	return 0
end

function acShengdankuanghuanVoApi:getBigPoint()
	local vo  = self:getAcVo()
	if vo and vo.bigPoint then
		return tonumber(vo.bigPoint*100)
	end
	return 0
end

function acShengdankuanghuanVoApi:getGoldVate()
	local vo  = self:getAcVo()
	if vo and vo.goldVate then
		return vo.goldVate
	end
	return 0
end
function acShengdankuanghuanVoApi:getResourceVate()
	local vo  = self:getAcVo()
	if vo and vo.resourceVate then
		return vo.resourceVate
	end
	return 0
end


function acShengdankuanghuanVoApi:getRewardCfg()
	-- local reward={
	-- {8000,{o={{a10006=2,index=1}}}},
	-- {5000,{o={{a10006=1,index=1},{a10016=1,index=1}}}}, 
	-- {1000,{o={{a10006=1,index=1},{a10016=1,index=1},{a10026=1,index=1}}}}, 
 --    {500,{o={{a10006=1,index=1},{a10016=1,index=1},{a10026=1,index=1},{a10036=1,index=1}}}}, 
            
            
            
 --        }
    local vo  = self:getAcVo()
	if vo and vo.treeReward then
		return vo.treeReward
	end
	return {}
end


function acShengdankuanghuanVoApi:getNeedPointById(id)
	local cfg = self:getRewardCfg()
	if cfg then
		for k,v in pairs(cfg) do
			if k and k==id and  v and v[1] then
				return tonumber(v[1])
			end
		end
	end

	return  0
end
function acShengdankuanghuanVoApi:getRewardById(id)
	local cfg = self:getRewardCfg()
	if cfg then
		for k,v in pairs(cfg) do
			if k and k==id and  v and v[2] then
				return v[2]
			end
		end
	end

	return  {}
end

function acShengdankuanghuanVoApi:checkIfCanRewardById(id)
	local nowPoint = self:getNowPoint()
	local needPoint = self:getNeedPointById(id)
	if nowPoint >= needPoint then
		return true
	end
	return false


end

function acShengdankuanghuanVoApi:getHadTreeRewrd()
	local vo  = self:getAcVo()
	if vo and vo.hadTreeReward then
		return vo.hadTreeReward
	end
	return {}
end
function acShengdankuanghuanVoApi:addHadTreeRewardByID(id)
	local vo = self:getAcVo()
	if vo then
		if vo.hadTreeReward == nil then
			vo.hadTreeReward = {}
		end
		table.insert(vo.hadTreeReward,id)
	end
end

function acShengdankuanghuanVoApi:checkIfHadRewardById(id)
	local hadReward = self:getHadTreeRewrd()
	if hadReward then
		for k,v in pairs(hadReward) do
			if v and v == id then
				return true
			end
		end
	end

	return false
end


function acShengdankuanghuanVoApi:getChatVate()
	local vo  = self:getAcVo()
	if vo and vo.goods then
		return vo.goods
	end
	return 0
end

function acShengdankuanghuanVoApi:setNowPoint(point)
	self.treePoint = point
end
function acShengdankuanghuanVoApi:getNowPoint()
	if self.treePoint == nil then
		self.treePoint = 0
	end
	return self.treePoint
end

function acShengdankuanghuanVoApi:clearAll( ... )
	self.lastSt=0
	self.treePoint=0
end

function acShengdankuanghuanVoApi:checkIsCanTreeReward()
	local treeReward = self:getRewardCfg()
	if treeReward then
		for k,v in pairs(treeReward) do
			if self:checkIfCanRewardById(k)==true and self:checkIfHadRewardById(k)==false then
				return true
			end
		end
	end
	return false
end

function acShengdankuanghuanVoApi:canReward()
	if self:checkIsCanGoldReward()==true or self:checkIsCanTreeReward()==true then
		return true
	end
	return false
end

function acShengdankuanghuanVoApi:setLastSt()
	self.lastSt =  base.serverTime
end

function acShengdankuanghuanVoApi:getV3Pic( )
	self.sixGifts={}
	if self:getVersion() ==3 then
		for i=1,6 do
			if i <3 then
				self.sixGifts[i]={"CommonBox.png","CommonBoxOpen.png"}
			elseif i>2 and i<5 then
				self.sixGifts[i]={"silverBox.png","silverBoxOpen.png"}
			elseif i>4 then
				self.sixGifts[i]={"SpecialBox.png","SpecialBoxOpen.png"}
			end			
		end
	end
	return self.sixGifts
end

function acShengdankuanghuanVoApi:getV3ArPic()
	self.arPics={}
	if self:getVersion() ==3 then
		for i=1,4 do
			self.arPics[i]={"acArsenalBg_"..i..".png"}
		end
	end
	return self.arPics
end