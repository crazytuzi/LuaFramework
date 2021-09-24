acBtzxVoApi = {
	name="",
}

function acBtzxVoApi:setActiveName(name)
	self.name=name
end

function acBtzxVoApi:getActiveName()
	return self.name
end

function acBtzxVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acBtzxVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acBtzxVoApi:canReward(activeName)
	return false
end

function acBtzxVoApi:getCfg()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg
	end
	return {}
end



function acBtzxVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end


function acBtzxVoApi:showRewardDialog(rewardlist,layerNum,fqNum)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
	local titleStr=getlocal("activity_wheelFortune4_reward")
	local content={}
	for k,v in pairs(rewardlist) do
		table.insert(content,{award=v})                        
	end
	local rewardPromptStr=nil
	-- if fqNum and fqNum~=0 then
	-- 	rewardPromptStr=getlocal("activity_openyear_fetFQNum_des",{fqNum})
	-- end
	acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardPromptStr,nil,content,false,layerNum+1,nil,getlocal("confirm"),nil,nil,nil,nil,true,false)
end

function acBtzxVoApi:refreshClear()
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.c=0
	vo.v=0
	vo.dt={}
	vo.df={}
	vo.rf={}
end

function acBtzxVoApi:socketRankList(cmd,rank,refreshFunc,flag)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				self:updateSpecialData(sData)
			end
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end

			if refreshFunc then
				refreshFunc()
			end
		end
	end
	local vo=self:getAcVo()
	if flag then
		vo.lastTs=0
	end

	if vo and vo.lastTs then
		local startT=self:getRewardTime()
		-- 结束是否调过排行榜(30秒延时)
		if vo.lastTs-startT>30+10 then -- 是
			if refreshFunc then
				refreshFunc()
			end
			return
		elseif base.serverTime>startT+10 then
			socketHelper:activityBtzx(cmd,rank,callBack)
			return
		end
		if base.serverTime>vo.lastTs then
			socketHelper:activityBtzx(cmd,rank,callBack)
			return
		else
			if refreshFunc then
				refreshFunc()
			end
		end
		return 
	end
	socketHelper:activityBtzx(cmd,rank,callBack)
end

function acBtzxVoApi:socketReward(cmd,rank,refreshFunc)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end
			local rewardlist={}
			if sData and sData.data and sData.data.reward then
				rewardlist=FormatItem(sData.data.reward)
				for k,v in pairs(rewardlist) do
					G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
				end
			end

			if refreshFunc then
				refreshFunc(rewardlist)
			end
		end
	end
	socketHelper:activityBtzx(cmd,rank,callBack)
end

function acBtzxVoApi:getRankList()
	local vo=self:getAcVo()
	if vo and vo.ranklist then
		return vo.ranklist
	end
	return {}
end

function acBtzxVoApi:getMyRank()
	local vo=self:getAcVo()
	if vo and vo.myrank then
		return vo.myrank
	end
	return 0
end

function acBtzxVoApi:getMyRb()
	local vo=self:getAcVo()
	if vo and vo.myrb then
		return vo.myrb
	end
	return 0
end

function acBtzxVoApi:getRewardTime()
	local vo=self:getAcVo()
	if vo and vo.et then
		return vo.et-24*3600,vo.et
	end
end

function acBtzxVoApi:isActiveTime(activeName)
	local vo=self:getAcVo(activeName)
	if vo and tonumber(vo.st) <= tonumber(base.serverTime) and tonumber(base.serverTime) < tonumber(vo.et-24*3600) then
    	return true
    end
	return false
end

function acBtzxVoApi:matchAdd(activeName)
	local vo=self:getAcVo(activeName)
	if vo then
    	return vo.activeCfg.buff[1]
    end
	return 0
end
function acBtzxVoApi:buildAdd(activeName)
	local vo=self:getAcVo(activeName)
	if vo then
    	return vo.activeCfg.buff[3]
    end
	return 1
end

function acBtzxVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

-- 0 未领取  1 领取
function acBtzxVoApi:getRewardState(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo and acVo.c then
		return acVo.c
	end
	return 0
end

function acBtzxVoApi:showRewardDialog(rewardlist,layerNum)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
	local titleStr=getlocal("activity_wheelFortune4_reward")
	local content={}
	for k,v in pairs(rewardlist) do
		table.insert(content,{award=v})                        
	end
	acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,nil,nil,content,false,layerNum+1,nil,getlocal("confirm"),nil,nil,nil,nil,true,false)
end


function acBtzxVoApi:clearAll()
	self.name=""
end


