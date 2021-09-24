acTankBattleVoApi = {
}

function acTankBattleVoApi:getAcVo()
	return activityVoApi:getActivityVo("tankbattle")
end

function acTankBattleVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acTankBattleVoApi:canReward()
	local isFree,_,_ = self:isCanBattle( )	
	if isFree then
		return true
	end
	
	return false
end


function acTankBattleVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end

function acTankBattleVoApi:getReward( )
	local vo = self:getAcVo()
	if vo and vo.reward then
		return vo.reward
	end
end

function acTankBattleVoApi:getRankReward(rank)
	local vo = self:getAcVo()
	local rankReward=vo.rankReward or {}
	for k,v in pairs(rankReward) do
		if rank>=v.range[1] and rank<=v.range[2] then
			return v.reward
		end
	end
	return nil
end

function acTankBattleVoApi:getAllRankReward()
	local vo = self:getAcVo()
	if vo and vo.rankReward then
		return vo.rankReward
	end
	return {}
end

function acTankBattleVoApi:getLimitLevel( )
	if(base.heroOpenLv)then
		limitLv=base.heroOpenLv
		return limitLv
	end
	local vo = self:getAcVo()
	if vo and vo.level then
		return vo.level
	end
	return 25
end

function acTankBattleVoApi:getTPoint( )
	local vo = self:getAcVo()
	if vo and vo.tpoint then
		return vo.tpoint
	end
	return {1,2}
end

function acTankBattleVoApi:isRetchLevel( )
	local vo = self:getAcVo()
	local limitLv
	if(base.heroOpenLv)then
		limitLv=base.heroOpenLv
	else
		limitLv=25
	end
	local playerLevel = playerVoApi:getPlayerLevel() or 1
	if playerLevel<limitLv then
		return false
	end
	return true
end

-- 1:是否还有免费的  2：是否能打
function acTankBattleVoApi:isCanBattle( )
	local vo = self:getAcVo()
	local free = vo.free or 0
	local attacNum = vo.c or 0
	local vipC = vo.vipC or {}
	local vipLevel = playerVoApi:getVipLevel() or 0
	local totalNum = 0

	-- if vipLevel==0 then
	-- 	totalNum=free
	-- else

		totalNum=free + (vipC[vipLevel+1] or vipC[#vipC] or 0)
	-- end
	if attacNum < free then
		return true,true,attacNum
	elseif attacNum < totalNum then
		return false,true,attacNum
	else
		return false,false,attacNum
	end
	return false,false,attacNum
end

function acTankBattleVoApi:showTankBattleDialog(layerNum,DialogCallback)

	if self:isRetchLevel()==false then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tankbattle_levelLimit",{acTankBattleVoApi:getLimitLevel( )}),30)
        return
    end


	local isFree,isCanbattle,attacNum = self:isCanBattle( )

	local numOfattck = attacNum+1

	if isCanbattle then
		local cost = self:getCost()
		local gems = playerVoApi:getGems()
		if cost>gems then
			-- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem"),30)
			GemsNotEnoughDialog(nil,nil,cost-gems,layerNum,cost)
			return
		end


		local function showDialog()
			base.pauseSync=true
			local dialog =  acTankBattleDialog:new()
			local vd = dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,acTitle,true,layerNum)
			sceneGame:addChild(vd,layerNum)
		end
		local function callback(fn,data)
			local ret,sData = base:checkServerData(data)
			if ret==true then
				if sData and sData.data and sData.data.tankbattle then
					self:updateSpecialData(sData.data.tankbattle)
				end
				if DialogCallback then
					DialogCallback()
				end

				if cost>0 then
					playerVoApi:setGems(gems-cost)
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tankbattle_consumeCost",{cost}),30)
				end

				showDialog()
			end
		end
		
		
		
		socketHelper:acTankBattleStart(numOfattck,callback)
	else
		local totalNum = self:getTotalNum()
		if numOfattck>totalNum then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tankbattle_attackLimit"),30)
			return
		else
			local vo = self:getAcVo()
			local vipC = vo.vipC or {} -- 从vip0开始的
			local vipLevel = playerVoApi:getVipLevel() or 0
			local costNum = vo.vipC[vipLevel+1]


			local upGrade=1
			local addNUm=0
			for i=vipLevel+1,#vipC do
				if vipC[i]>costNum then
					upGrade=i
					break
				end
			end
			addNUm=vipC[upGrade]-costNum
			local content=getlocal("activity_tankbattle_vipLimit",{vipLevel,costNum,upGrade-1,addNUm})
			GemsNotEnoughDialog(nil,content,nil,layerNum,nil)
			return
		end
	end
end




function acTankBattleVoApi:showTankBattleEndDialog(layerNum,parent,count,point)
	local dialog =  acTankBattleEndDialog:new(parent,count,point)
	local vd = dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,acTitle,true,layerNum)
	sceneGame:addChild(vd,layerNum)

end

function acTankBattleVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

-- 跨天清除v，c
function acTankBattleVoApi:clearVandC()
	local vo = self:getAcVo()
	if vo then
		vo.c=0
		vo.v=0
		vo.lastTime=base.serverTime
	end
end

function acTankBattleVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.acEt-24*3600) then
		return false
	end
	return true
end

function acTankBattleVoApi:getSid()
	local vo=self:getAcVo()
	if vo and vo.sid then
		return vo.sid
	end

	local herolist = heroVoApi:getHeroList()
	if SizeOfTable(herolist)==0 then
		return vo.reward
	end
	local hid = herolist[1].hid
	local id=tonumber(hid) or tonumber(RemoveFirstChar(hid))
    local sid = "s" .. id
	return sid

end

function acTankBattleVoApi:getRankPoint()
	local vo=self:getAcVo()
	if vo and vo.point then
		return vo.point
	end

	return 0
end

function acTankBattleVoApi:getCost()
	local vo=self:getAcVo()
	local costTb=vo.vcost
	local free = vo.free or 0
	local isFree,isCanbattle,attacNum = self:isCanBattle()
	if isFree then
		return 0
	end
	local numOfattck = attacNum+1
	local costNum = numOfattck-free
	local cost = costTb[costNum] or costTb[#costTb]
	return cost

end

function acTankBattleVoApi:getNumReward(point)
	local vo=self:getAcVo()
	local rpoint=vo.rpoint
	local limit=vo.limit
	local num=math.floor(math.pow((point/rpoint)+2.25,0.5)-0.5)
	-- local num = math.floor(point/rpoint)+1
	if num>tonumber(limit) then
		return limit
	end
	return num
end

function acTankBattleVoApi:getR()
	local vo=self:getAcVo()
	if vo and vo.r then
		return vo.r
	end
	return 0
end

function acTankBattleVoApi:getTotalNum()
	local vo = self:getAcVo()
	local free = vo.free or 0
	local vipC = vo.vipC or {}
	local totalNum = free + (vipC[#vipC] or 0)
	return totalNum
end

function acTankBattleVoApi:getFree()
	local vo = self:getAcVo()
	if vo and vo.free then
		return vo.free
	end
	return 0
end

function acTankBattleVoApi:getRewardTimeStr( )
	local vo  = self:getAcVo()
	local reTimeStr = activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
	return reTimeStr
end

function acTankBattleVoApi:setGetReward(sid,callBack)
	local function setReward(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.tankbattle then
                acTankBattleVoApi:updateSpecialData(sData.data.tankbattle)
            end 
            if callBack then
            	callBack()
            end
        end
    end
    if sid==acTankBattleVoApi:getSid() then
    	if callBack then
    		callBack()
    	end
    else
        socketHelper:acTankBattleSet(sid,setReward)
    end
end







function acTankBattleVoApi:clearAll()
end


