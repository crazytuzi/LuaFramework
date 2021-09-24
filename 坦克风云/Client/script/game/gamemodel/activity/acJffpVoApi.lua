acJffpVoApi={}

function acJffpVoApi:getAcVo()
	return activityVoApi:getActivityVo("jffp")
end

-- 当前积分
function acJffpVoApi:getCurNum()
	local vo = acJffpVoApi:getAcVo()
	if vo and vo.c then
		return vo.c
	end
	return 0
end

-- 每次消耗多少积分
function acJffpVoApi:getCostNum( ... )
	local vo = acJffpVoApi:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return 0
end

-- 最多可以抽几次
function acJffpVoApi:getRewardNum()
	local num = math.floor(self:getCurNum()/self:getCostNum())
	local vo = acJffpVoApi:getAcVo()
	local maxnum =10 
	if vo and vo.count then
		maxnum=vo.count
	end

	if num>maxnum then
		num=maxnum
	end
	if num<=0 then
		num=1
	end
	return num
end

-- 获取任务列表
function acJffpVoApi:getTaskList()
	
	local vo = acJffpVoApi:getAcVo()
	local list = {}
	local totalScore = 0--总共可以获得的积分
	local curScore = 0--当前获得的积分
	if vo and vo.consume then
		for k,v in pairs(vo.consume.i) do
			if self:checkIsOpen(v)==true then
				local num = self:getCompleteNumByKey(v)
				local totalnum = tonumber(vo.consume.t[v])
				local isComplete = 0
				local score = vo.consume.s[v]
				local desc=getlocal("activity_jffp_task_"..v)..getlocal("activity_jffp_score",{score})
				
				if num>=totalnum then
					isComplete=1
				end
				table.insert(list,{sortid=tonumber(k),isComplete=isComplete,totalnum=totalnum,num=num,score=score,desc=desc})
				totalScore=totalScore+(totalnum*score)
				curScore=curScore+(num*score)
			end
		end
		local function funcA(a,b)
			if a and b and a.isComplete and b.isComplete then
				return a.isComplete<b.isComplete
			end
		end
		local function funcB(a,b)
			if a and b and a.sortid and b.sortid then
				return a.sortid<b.sortid
			end
		end
		table.sort(list,funcB)
		table.sort(list,funcA)
		
	end
	return list,totalScore,curScore
end
 -- l登录,ab攻打关卡,a攻打一次玩家，eb攻打一次补给线,su精炼一次配件
 -- qe 强化配件，ge 改造配件，bs 进攻海德拉,ar 军事演习，aw 军团战占领一次据点
 -- ex 远征 ，al 赠送一次异星资源 wp 抢一次碎片
function acJffpVoApi:checkIsOpen(k)
	if k=="l" or k=="ab" or k=="a" then
		return true
	elseif (k=="eb" or k=="qe" or k=="ge") and base.ifAccessoryOpen==1 then
		return true
	elseif k=="su" and base.ifAccessoryOpen==1 and base.alien==1 then
		return true	
	elseif k=="bs" and base.boss==1 then
		return true
	elseif k=="ar" and base.ifMilitaryOpen==1 then
		return true
	elseif k=="aw" and base.isAllianceWarSwitch==1 then
		return true
	elseif k=="ex" and base.expeditionSwitch==1 then
		return true
	elseif k=="al" and base.alien==1 then
		return true
	elseif k=="wp" and base.ifSuperWeaponOpen==1 then
		return true
	end
	return false
end

-- 获取已经完成的次数
function acJffpVoApi:getCompleteNumByKey(k)
	local vo = acJffpVoApi:getAcVo()
	if vo and vo.n and vo.n[k] then
		return vo.n[k]
	end
	return 0
end
function acJffpVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

-- 获取所有的物品
function acJffpVoApi:getAllReward(rewardArr,index)
	local vo = acJffpVoApi:getAcVo()
	local allReward={}
	if vo and vo.reward then
		local allRewardItem = FormatItem(vo.reward)
		local totalnum = #allRewardItem
		local hasGetArr = {}
		hasGetArr[rewardArr[1].id]=1
		local i = 1
		while #allReward<=9 do
			if i==index then
				table.insert(allReward,rewardArr[1])
				i=i+1
			else
				local r=math.ceil(math.random()*totalnum)
				-- if allRewardItem[r].id==rewardArr[1].id then
				if hasGetArr[allRewardItem[r].id]~=nil and hasGetArr[allRewardItem[r].id]==1 then	
				else
					hasGetArr[allRewardItem[r].id]=1
					table.insert(allReward,allRewardItem[r])
					i=i+1
				end
			end
		end
		return allReward
	end
	return nil
end

-- 跨天后，重置完成次数
function acJffpVoApi:resetCompleteData()
	local vo = acJffpVoApi:getAcVo()
	if vo and vo.n then
		vo.n=nil
		vo.v=base.serverTime
	end
end
-- 判断是否跨天
function acJffpVoApi:checkIsToday()
	local vo = acJffpVoApi:getAcVo()
	if vo and vo.v>0 then
		local istoday = G_isToday(vo.v)
		if istoday==false then
			self:resetCompleteData()
		end
		return istoday
	end
	return true
end

function acJffpVoApi:refreshData(data)
	local vo = acJffpVoApi:getAcVo()
	if vo then
		vo:updateData(data)
	end
end

function acJffpVoApi:canReward()
	return false
end