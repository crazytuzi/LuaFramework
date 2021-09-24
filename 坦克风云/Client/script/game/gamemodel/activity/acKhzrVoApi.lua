acKhzrVoApi={
	name=nil,
}

function acKhzrVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acKhzrVoApi:setActiveName(name)
	self.name=name
end

function acKhzrVoApi:getActiveName()
	return self.name or "khzr"
end
function acKhzrVoApi:clearAll()
	self.name=nil
end
function acKhzrVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end
function acKhzrVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	return G_formatActiveDate(vo.et - base.serverTime)
end

function acKhzrVoApi:getLeftNum()
	local vo=self:getAcVo()
	local c=vo.c or 0
	local shop=vo.activeCfg.shop
	return SizeOfTable(shop)-c
end


function acKhzrVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acKhzrVoApi:setCanBuyTimesTb(newTimes)
	local vo = self:getAcVo()
	if vo and newTimes then
		vo.bn = newTimes
	end
end
function acKhzrVoApi:getCanBuyTimesTb( )
	local vo = self:getAcVo()
	if vo and vo.bn then
	  return vo.bn
	end
	return {}
end

function acKhzrVoApi:getSelfSpendGold( )--累计充值金币
	local vo = self:getAcVo()
	if vo and vo.spendGold then
		return vo.spendGold
	end
end

function acKhzrVoApi:getNgAndStalls()
	local vo=self:getAcVo()
	if vo.spendGold and vo.activeCfg.ng then
		local ng = vo.activeCfg.ng
		local stalls = 0--花费金币档位
		for i=1,#ng do
			if vo.spendGold >= ng[i] then
				stalls = stalls + 1 
			end
		end
		return vo.activeCfg.ng,stalls
	end
	return nil,nil
end

function acKhzrVoApi:getShop()
	local vo=self:getAcVo()
	return vo.activeCfg.shop
end

function acKhzrVoApi:getPoolList()
	local vo=self:getAcVo()
	local poollist=vo.activeCfg.poollist

	local poolReward=FormatItem(poollist,nil,true)
	return poolReward,(vo.activeCfg.poolflicker or {})
end


function acKhzrVoApi:isToday(activeName)
	local isToday=false
	local vo = self:getAcVo(activeName)
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	-- print("return isToday======>>>>>>",isToday,vo.lastTime)
	return isToday
end

function acKhzrVoApi:getBigRewardsCfg()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.reward
	end
	return {}
end

function acKhzrVoApi:clearData()
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.bn = {}
	vo.spendGold = 0
end

function acKhzrVoApi:socketBuy(action,sid,refreshFunc)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	socketHelper:acKhzrBuyGift(callBack,"i"..sid)
end

function acKhzrVoApi:getBuyId()
	local vo=self:getAcVo()
	local buyId=vo.c or 0
	return buyId
end

function acKhzrVoApi:showGiftBuyDialog(layerNum,istouch,isuseami,callBack,giftId,shopInfo,parent)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acKhzrSmallDialog"
	return acKhzrSmallDialog:showGiftBuy(layerNum,istouch,isuseami,callBack,giftId,shopInfo,parent)
end



function acKhzrVoApi:canReward(activeName)
	local isfree=true							--是否是第一次免费
	if self:isToday(activeName)==true then
		isfree=false
	end
	return isfree
    
end

function acKhzrVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acKhzrVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end
