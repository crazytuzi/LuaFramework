acYdczVoApi={}

function acYdczVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("ydcz")
	end
	return self.vo
end

function acYdczVoApi:canReward()
	return self:isCanUpgrade()
end

function acYdczVoApi:updateData(data)
	local vo=self:getAcVo()
	if vo then
		vo:updateData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acYdczVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acYdczVoApi:initYdczData( ... )

	local tmp1= {"p","t","D","c","t","d","h","e","t","t","=","o","n","a","n"," ","m","n",")","t","e","o","i","T","e","a","l","r","c","a","h","G"," ","a","e","E","o","a","e","s","d","(","i","l"," ","c","n","e","u"," ","e","n"," ","c","E","l","f","e","e",".","t","p",".","s","E","a","e","a","G","m","o","m","h","e"," ","f","i"," ","n","i","l","_","T","c"," ","d","i","="," ","i","t","a"," ","i","(","i","l","s","k","p","b","o","l","=",".","t","=","s","="," ",":","r","a"," ","f","r","t","e","l",")","k","D","a"," ","o","c","f","o","E","e","n","r","g","d","t","n","o","a","d","a","a","b","f","=","n","b",")"," ","v"," ",".","s","f","a",",","f","f","1","e","t","a","f","d","s"," ","G","n","n"," ","c",".","i","a","a","d","d"," ","r","T"," ","e"," ","=","n","c","t","d","e","n","e","i","s","f","p","t","a","e","n","i","t","a","i","v","H","b","t","u","l",":","y","c","a","e","a","p","(","i","b"," ","c","c","f","o","e","k","k","e","("," ","p","s","r"," ","a",")","m","l","(","r","e","e","s","t","a","e","n","r","c","l","c","d","a","m","a"," ","G","e"," ","e","n","d","l","o","m","d","m","a","l","e","l","d","d","n","t","e","c","T","l","T","t"," ","i","t",")","p","e","c","e","E","t","d","m","e","T","o","s","u","h",":","u","c"," ","c","e","e","o","f","e","a","m","t","n"," ","a","G",",","S","n"}
    local km1={78,184,199,40,127,225,59,18,131,52,100,120,253,228,14,267,134,118,229,236,142,189,68,53,246,87,86,194,209,250,210,128,160,183,84,38,156,125,211,47,42,297,91,45,307,15,313,294,162,138,43,273,62,212,79,188,28,107,56,85,201,116,143,126,252,226,312,171,66,152,16,76,110,135,99,64,63,102,3,6,105,67,150,176,265,72,32,137,57,95,58,115,136,129,30,133,155,141,213,285,139,71,159,203,123,93,101,144,238,233,19,216,299,34,51,149,165,257,301,98,177,220,36,193,292,119,33,7,117,215,309,240,262,270,222,39,277,46,256,175,221,296,103,237,80,204,186,108,147,263,258,88,179,191,181,259,161,266,111,281,202,1,314,198,169,49,290,168,154,4,44,50,185,205,318,22,113,219,70,9,235,275,264,180,157,244,274,25,8,280,54,106,130,12,227,140,286,112,27,239,158,231,217,282,174,89,2,300,288,74,278,223,60,11,21,178,151,302,271,170,81,232,82,242,305,279,272,224,65,37,206,146,248,77,31,55,172,75,287,122,207,276,5,261,218,247,234,254,173,190,121,104,96,73,230,90,195,187,316,163,17,284,41,114,293,249,303,124,153,260,182,83,61,29,283,298,94,192,132,196,243,166,48,306,251,97,164,145,13,109,310,10,289,295,167,69,20,245,208,241,291,315,304,268,308,255,92,148,23,35,24,269,311,200,26,197,214,317}
    local tmp1_2={}
    for k,v in pairs(km1) do
        tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()

end

--获取当前升级到的奖励档位
function acYdczVoApi:getRewardLv()
	local vo=self:getAcVo()
	if vo and vo.rewardLv then
		return vo.rewardLv
	end
	return 1
end

--获取本月充值金额
function acYdczVoApi:getRecharge()
	local vo=self:getAcVo()
	local need=0
	if vo then
		need=vo.activeCfg.recharge
		if vo.recharge then
			return vo.recharge,need
		end
	end
	return 0,need
end

--充值添加金币
function acYdczVoApi:addRecharge(add)
	-- local flag=self:isCurrentMonth()
	-- if flag==false then
	-- 	self:reset()
	-- end
	-- local vo=self:getAcVo()
	-- if vo and vo.activeCfg then
	-- 	local lastRecharge=vo.recharge or 0
	-- 	vo.recharge=(vo.recharge or 0)+add
	-- 	vo.EOM=G_getEOM()
	-- 	if vo.recharge>=vo.activeCfg.recharge then --充值金额已达到，则主动更新发放奖励的档位
	-- 		if lastRecharge<vo.activeCfg.recharge or vo.rid==0 then
	-- 			vo.rid=(vo.rewardLv or 1)
	-- 		end
	-- 		self:setRebelBuffActive() --叛军天眼生效	
	-- 	end
	-- end
end

--判断是不是本月
function acYdczVoApi:isCurrentMonth()
	local vo=self:getAcVo()
	if vo then
		if vo.EOM==nil then --如果没有月末时间戳说明玩家没有充值，也就没有活动数据，不需要重置活动数据
			return true
		else
        	local lastZone=vo.lastZone or base.curTimeZone
			local diffZone=lastZone-base.curTimeZone
			if base.serverTime<=(vo.EOM+diffZone*3600) then --当前时间超过了月末，则跨月
				return true
			end
		end
	end
	return false
end

--获取充值奖励列表
function acYdczVoApi:getRewardList()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.reward then
		return vo.activeCfg.reward
	end
	return {}
end

--奖励升级解锁的配置
function acYdczVoApi:getRewardUnlockCfg()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.unlock then
		return vo.activeCfg.unlock
	end
	return {}
end

--获取指定等级的奖励的状态
--params：rid：奖励id
--return：1：已过期（已升级至高档位的奖励则该奖励过期），2：当前奖励生效，3：成就完成可以升级至该奖励，4：未解锁（成就未完成没有升级到该奖励），5：默认奖励已过期，6：默认奖励生效
function acYdczVoApi:getRewardState(rid)
	local vo=self:getAcVo()
	if vo then
		local unlockTb=self:getRewardUnlockCfg()
        local avtId,subId
        if unlockTb[rid] then
        	avtId,subId=unlockTb[rid][1],unlockTb[rid][2]
        end
        if avtId==nil or subId==nil then
        	if (vo.rewardLv or 0)>rid then
        		return 5
        	else
        		return 6
        	end
        else
        	local state=achievementVoApi:getAvtState(1,avtId,subId)
        	if state~=2 then --成就未激活
        		return 4
        	else
        		local rewardLv=vo.rewardLv or 0
        		if rewardLv>rid then
        			return 1
        		elseif rewardLv==rid then
        			return 2
        		else
        			return 3
        		end
        	end
        end
	end
	return 1
end

--判断奖励是否已经发放
function acYdczVoApi:isRewardReceived(rid)
	local vo=self:getAcVo()
	if vo and vo.rid and vo.rid==rid then
		return true
	end
	return false
end

--判断当前奖励是否可以升级
function acYdczVoApi:isCanUpgrade()
	local rewardlist=self:getRewardList()
	local num=SizeOfTable(rewardlist)
	local state
	local vo=self:getAcVo()
	if vo then
		local maxRid=(vo.rewardLv or 1)+1
		maxRid=(maxRid>num) and num or maxRid
		for rid=(vo.rewardLv or 1),maxRid do
			state=acYdczVoApi:getRewardState(rid)
			if state==3 then
				return true
			end
		end
	end
	return false
end

--升级奖励
function acYdczVoApi:ydczRewardUpgrade(callback)
	local function handler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.ydcz then
				self:updateData(sData.data.ydcz)
			end
			if callback then
				callback()
			end
		end
	end
	socketHelper:ydczRewardUpgrade(handler)
end

function acYdczVoApi:reset()
	local vo=self:getAcVo()
	if vo then
		vo:reset()
	end
end

--叛军buff生效
function acYdczVoApi:setRebelBuffActive()
	local vo=self:getAcVo()
	if vo and vo.recharge and vo.activeCfg and vo.activeCfg.recharge then
		local flag=self:isCurrentMonth()
		if flag==false then
			self:reset()
		end
		if vo.recharge>=vo.activeCfg.recharge then --充值达到额度后叛军buff生效
			playerVoApi:setRebelBuffEndTs(vo.EOM)	
		end
	end
end

--是不是奖励解锁的成就条件
function acYdczVoApi:isUnlockAvt(avtId,idx)
	local unlockTb=self:getRewardUnlockCfg()
	for k,v in pairs(unlockTb) do
		if v[1] and v[2] and v[1]==avtId and v[2]==idx then
			return true
		end
	end
	return false
end

function acYdczVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acYdczVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acYdczVoApi:getTimeStr()
	local bomt,eomt=G_getBOM(),G_getEOM()-1
	local vo=self:getAcVo()
	if vo and vo.st and vo.et then
		if bomt<vo.st then
			bomt=vo.st
		end
		if eomt>vo.et then
			eomt=vo.et
		end
	end
	return getlocal("activity_time",{G_getDataTimeStr(bomt),G_getDataTimeStr(eomt)})
end

function acYdczVoApi:clearAll()
	self.vo=nil
end