acFirstRechargeVoApi = {}

function acFirstRechargeVoApi:getAcVo()
	return activityVoApi:getActivityVo("firstRecharge")
end

function acFirstRechargeVoApi:updataData(data)
	local  vo = self:getAcVo()
	vo:updateSpecialData(data)
end

--返回值：
-- 1.是否能领取奖励物品，
-- 2.是否显示双倍金币
-- 3.首充双倍开关开启时充值，之后开关关闭，则不让领取，按钮置灰（后台也领取不了）
function acFirstRechargeVoApi:canReward()
	local isReward,isShowDouble,isCanReward=false,false,true
	if self:isOpen()==true then
		local vo = self:getAcVo()
	    -- print("ddddddddddd=",type(vo.c),vo.c,type(vo.v),vo.v,vo.r)
		if vo and vo.c ~= nil and vo.v ~= nil and ((vo.c >= vo.v and vo.r==nil) or (vo.r and vo.r==0)) then
			if vo.c >= vo.v and vo.r==nil then
				isShowDouble=true
			end
			isReward=true
			if base.newRechargeSwitch==0 then
				if self:isHadRewardGems()==true and vo.r==0 then
					isCanReward=false
				end
			end
		end
	else
		isReward,isShowDouble,isCanReward=false,false,false
	end
	-- print("isReward",isReward)
	return isReward,isShowDouble,isCanReward
end

--是否显示首充双倍,goldNum当前充充值档的金币数
function acFirstRechargeVoApi:isShowFirstDouble(goldNum)
	local isShow=false
    if self:isOpen()==true and base.newRechargeSwitch==1 then
    	isShow=true
    	local vo = self:getAcVo()
    	if vo and vo.p then
    		for k,v in pairs(vo.p) do
    			if v and tonumber(v)==tonumber(goldNum) then
    				isShow=false
    			end
    		end
		end
    end	
	return isShow
end

--是否已经领取首充奖励
function acFirstRechargeVoApi:isHadReward()
	local isReward=false
	local vo = self:getAcVo()
	if vo and ((vo.c<0 and vo.r==nil) or (vo.r and vo.r==1)) then
		isReward=true
	end	
	return isReward
end

--是否已经获取首充双倍的金币
function acFirstRechargeVoApi:isHadRewardGems()
	local vo = self:getAcVo()
	if vo and vo.c then
		if (vo.c==0 and (vo.p and SizeOfTable(vo.p)>0)) or vo.c<0 then
			return true
		end
	end	
	return false
end


--首充活动是否开启
function acFirstRechargeVoApi:isOpen()
	local vo = self:getAcVo()
	if vo and activityVoApi:isStart(vo)==true then
		return true
	end
	return false
end
