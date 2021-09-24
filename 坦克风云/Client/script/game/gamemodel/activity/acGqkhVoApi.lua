acGqkhVoApi = {
	name="",
	report={},
	acShowType={TYPE_1=1,TYPE_2=2}
}

function acGqkhVoApi:setActiveName(name)
	self.name=name
end

function acGqkhVoApi:getActiveName()
	return self.name
end

function acGqkhVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acGqkhVoApi:canReward(activeName)
	local isfree=true
	local vo = self:getAcVo(activeName)
	if vo and vo.f and vo.f==1 then --是否是第一次免费
		isfree=false
	end				
	-- if self:isToday()==true then
	-- 	isfree=false
	-- end
	return isfree
end

function acGqkhVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acGqkhVoApi:getAcShowType(activeName)
	local version = self:getVersion(activeName)
	if version == 2 then
		return self.acShowType.TYPE_2
	end
	return self.acShowType.TYPE_1
end

function acGqkhVoApi:getCostByType(type,isdouble)
	local acVo = self:getAcVo()
	if acVo then
		if isdouble then
			return acVo["cost" .. type]*acVo.double
		else
			return acVo["cost" .. type]
		end
	end
	return 0
end

function acGqkhVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acGqkhVoApi:getLimit()
	local vo = self:getAcVo()
	local limit=vo.limit or 20
	return limit
end

function acGqkhVoApi:getPoint()
	local vo = self:getAcVo()
	local point=vo.point
	return point
end

function acGqkhVoApi:getVersion(activeName)
	local vo = self:getAcVo(activeName)
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acGqkhVoApi:getVersionCfg()
	local version=self:getVersion()
	return gqkhCfg[version]
end


function acGqkhVoApi:setF(flag)
	local acVo = self:getAcVo()
	if acVo then
		acVo.f=flag
	end
end

function acGqkhVoApi:setC(flag)
	local acVo = self:getAcVo()
	if acVo then
		acVo.c=flag
	end
end

-- 获得代币数
function acGqkhVoApi:getV()
	local acVo = self:getAcVo()
	if acVo and acVo.v then
		return acVo.v
	end
	return 0
end

-- 获得今天玩了多少次了
function acGqkhVoApi:getC()
	local acVo = self:getAcVo()
	if acVo and acVo.c then
		return acVo.c
	end
	return 0
end

-- 获得 当前到第几个格子
function acGqkhVoApi:getS()
	local acVo = self:getAcVo()
	if acVo and acVo.s then
		return acVo.s
	end
	return 1
end

-- 获得 商店购买记录
function acGqkhVoApi:getB()
	local acVo = self:getAcVo()
	if acVo and acVo.b then
		return acVo.b
	end
	return {}
end

function acGqkhVoApi:getLeftNumBySid(sid)
	local cfg = self:getVersionCfg()
	local totalNum=cfg.shop[sid].buynum
	local shopBuy=self:getB()
	local aleadyNum=shopBuy[sid] or 0
	return totalNum-aleadyNum
end

function acGqkhVoApi:buyShop(sid,name,refreshFunc)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[name] then
				self:updateSpecialData(sData.data[name])
			end
			if sData and sData.data and sData.data.accessory then
    			accessoryVoApi:onRefreshData(sData.data.accessory)
    		end
			local cfg = acGqkhVoApi:getVersionCfg()
			if cfg.shop[sid].reward then
				local rewardItem=FormatItem(cfg.shop[sid].reward)
				for k,v in pairs(rewardItem) do
					if v.type~="gq" then
						G_addPlayerAward(v.type,v.key,v.id,v.num,true)
					end
				end
			end

			if refreshFunc then
				refreshFunc()
			end
		end
	end
	local action="buy"
	socketHelper:activityGqkh(action,sid,nil,nil,nil,callback)
end

function acGqkhVoApi:throwDice(point,free,rate,name,refreshFunc,needCost)
	local oldRound=self:getR()
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			-- 扣除金币
			playerVoApi:setGems(playerVoApi:getGems()-needCost)
			-- 更新数据
			if sData and sData.data and sData.data[name] then
				self:updateSpecialData(sData.data[name])
			end
			if sData and sData.data and sData.data.reprot then
				if self.report[name] and self.report[name]==1 then
					for k,v in pairs(sData.data.reprot) do
						self:setLog(v)
					end
				end
				local flag=false
				for k,v in pairs(sData.data.reprot[1][1]) do
					if k=="gq_m1" then
						flag=true
					end
				end
				if flag==false then
					local rewardItem=FormatItem(sData.data.reprot[1][1])
					G_addPlayerAward(rewardItem[1].type,rewardItem[1].key,rewardItem[1].id,rewardItem[1].num,nil,true)
				end
			end
			local newRound=self:getR()
			if newRound>oldRound then
				local cfg = self:getVersionCfg()
				if cfg.roundReward[newRound] then
					local rewardItem=FormatItem(cfg.roundReward[newRound].reward)
					for k,v in pairs(rewardItem) do
						if v.type~="gq" then
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
					end
				end
			end

			if refreshFunc then
				refreshFunc(sData.data.reprot[1])
			end
			eventDispatcher:dispatchEvent("activity.tipVisibleChange",{})
		end
	end
	local action="cast"
	socketHelper:activityGqkh(action,nil,point,free,rate,callback)
end

function acGqkhVoApi:getLog(name,refreshFunc)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.log then
				self:updateSpecialData(sData.data)
			end
			self.report[name]=1
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	if self.report[name]==nil then
		local action="log"
		socketHelper:activityGqkh(action,nil,nil,nil,nil,callback)
	else
		if refreshFunc then
			refreshFunc()
		end
	end
end

function acGqkhVoApi:setLog(report)
	local acVo = self:getAcVo()
	if acVo.log==nil then
		acVo.log={}
	end
	table.insert(acVo.log,report)
	if SizeOfTable(acVo.log)>10 then
		table.remove(acVo.log,1)
	end
	if SizeOfTable(acVo.log)>10 then
		table.remove(acVo.log,1)
	end
end

function acGqkhVoApi:showLogRecord(layerNum)
	local acVo = self:getAcVo()
	if acVo.log==nil or SizeOfTable(acVo.log)==0 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
        do return end
	end

	local record={}
	for k,v in pairs(acVo.log) do
		local reward={}
		for kk,vv in pairs(v[1]) do
			if kk=="gq_m1" then
				local name,pic,desc,id,index,eType,equipId,bgname=getItem("gq_m1","gq")
				local type="gq"
				local num=vv
				table.insert(reward,{name=name,pic=pic,type=type,bgname=bgname,desc=desc,num=num,key="gq_m1"})
			else
				for kkk,vvv in pairs(vv) do
					local name,pic,desc,id,index,eType,equipId,bgname=getItem(kkk,kk)
					local type=kk
					local key=kkk
					local num=vvv
					table.insert(reward,{name=name,pic=pic,desc=desc,id=id,index=index,eType=eType,equipId=equipId,bgname=bgname,num=num,key=key,type=type})
				end
			end
		end
		local color
		local desc
		if v[4] and v[4]==1 then
			desc=getlocal("activity_gqkh_logDes2",{v[2]})
			color=G_ColorYellowPro
		elseif v[4] and v[4]==2 then
			desc=getlocal("activity_gqkh_logDes3",{v[2]})
			color=G_ColorGreen
		else
			desc=getlocal("activity_gqkh_logDes1",{v[2]})
			color=G_ColorWhite
		end

		table.insert(record,{award=reward,time=v[3],desc=desc,colorTb={color}})
	end

	local function sortFunc(a,b)
        if a and b and a.time and b.time then
            return tonumber(a.time)>tonumber(b.time)
        end
    end
    table.sort(record,sortFunc)
    -- local recordCount=SizeOfTable(record)
    -- if recordCount==0 then
    --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
    --     do return end
    -- end
    local function confirmHandler()
    end
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
    acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),getlocal("activity_customLottery_RewardRecode"),record,false,layerNum+1,confirmHandler,nil,10)
end

function acGqkhVoApi:getPercentage()
	local alreadyCost = self:getR()
	local cost = self:getlvUp()
	local numDuan = SizeOfTable(cost)
	local per = 0
	if numDuan==0 then
		numDuan=5
	end
	local everyPer = 100/numDuan

	local per = 0

	local diDuan=0 
	for i=1,numDuan do
		if alreadyCost<=cost[i] then
			diDuan=i
			break
		end
	end

	if alreadyCost>=cost[numDuan] then
		per=100
	elseif diDuan==1 then
		per=alreadyCost/cost[1]/numDuan*100
	else
		per = (diDuan-1)*everyPer+(alreadyCost-cost[diDuan-1])/(cost[diDuan]-cost[diDuan-1])/numDuan*100
	end
	return per
end

function acGqkhVoApi:getlvUp()
	local acVo = self:getAcVo()
	if acVo and acVo.lvUp then
		return acVo.lvUp
	end
end

function acGqkhVoApi:getR()
	local acVo = self:getAcVo()
	if acVo and acVo.r then
		return acVo.r
	end
	return 0
end

function acGqkhVoApi:tipSpVisible()
	local cfg=acGqkhVoApi:getVersionCfg()
	local flag=false
	for k,v in pairs(cfg.shop) do
		local leftNum=self:getLeftNumBySid(k)
		if leftNum>0 then
			local haveNum=self:getV()
			if haveNum>=v.price then
				return true
			end
		end
	end
	return flag
end

function acGqkhVoApi:getRoundReward()
	local cfg=self:getVersionCfg()
    local roundNum=self:getR()
    local rewardNum=self:gerRewardNum(roundNum)

    local rewardTb={}
    for k,v in pairs(cfg.map) do
    	local reward=v.reward
    	local item
    	if rewardNum==0 then
    		item=v.reward[SizeOfTable(v.reward)]
    	else
    		item=v.reward[rewardNum]
    	end
    	local rewrdItem=FormatItem(item)
    	table.insert(rewardTb,rewrdItem[1])
    end

    return rewardTb,roundNum,cfg,rewardNum
end

function acGqkhVoApi:gerRewardNum(roundNum)
	local lvUp=self:getlvUp()
    local rewardNum=0
    for k,v in pairs(lvUp) do
        if roundNum<v then
            rewardNum=k
            return rewardNum
        end
    end
    return rewardNum
end


function acGqkhVoApi:clearAll()
	self.name=""
	self.report={}
end