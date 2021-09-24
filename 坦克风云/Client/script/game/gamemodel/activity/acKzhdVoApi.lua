acKzhdVoApi={
	name=nil,
}

function acKzhdVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acKzhdVoApi:setActiveName(name)
	self.name=name
end

function acKzhdVoApi:getActiveName()
	return self.name or "kzhd"
end
function acKzhdVoApi:clearAll()
	self.name=nil
end

function acKzhdVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	return G_formatActiveDate(vo.et - base.serverTime)
end

function acKzhdVoApi:getLeftNum()
	local vo=self:getAcVo()
	local c=vo.c or 0
	local shop=vo.activeCfg.shop
	return SizeOfTable(shop)-c
end


function acKzhdVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acKzhdVoApi:getShop()
	local vo=self:getAcVo()
	return vo.activeCfg.shop
end

function acKzhdVoApi:getTask()
	local vo=self:getAcVo()
	local actionlist=vo.activeCfg.actionlist

	local rewardList=vo.rd or {}
	local taskList={}
	for k,v in pairs(actionlist) do

		local sType=k
		local needNum=v.rewardtimes
		local haveNum=rewardList[sType] or 0
		local index=v.index
		if needNum>haveNum then
			index=v.index
		else
			haveNum=needNum
			index=v.index+10000
		end
		if sType=="mr" then
			if ltzdzVoApi and ltzdzVoApi:isOpen() then
				table.insert(taskList,{sType=sType,needNum=needNum,haveNum=haveNum,index=index})
			end
		elseif sType=="eb" then
			if base.expeditionSwitch==1 then
				table.insert(taskList,{sType=sType,needNum=needNum,haveNum=haveNum,index=index})
			end
		elseif sType=="mb" then
			if base.ifMilitaryOpen==1 then
				table.insert(taskList,{sType=sType,needNum=needNum,haveNum=haveNum,index=index})
			end
		elseif sType=="wp" then
			if base.ifSuperWeaponOpen==1 then
				table.insert(taskList,{sType=sType,needNum=needNum,haveNum=haveNum,index=index})
			end
		elseif sType=="fa" then
			if base.isRebelOpen==1 then
				table.insert(taskList,{sType=sType,needNum=needNum,haveNum=haveNum,index=index})
			end
		elseif sType=="ht" then
			if base.he==1 then
				table.insert(taskList,{sType=sType,needNum=needNum,haveNum=haveNum,index=index})
			end
			
		else
			table.insert(taskList,{sType=sType,needNum=needNum,haveNum=haveNum,index=index})
		end
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(taskList,sortFunc)
	return taskList
end

function acKzhdVoApi:getPoolList()
	local vo=self:getAcVo()
	local poollist=vo.activeCfg.poollist

	local poolReward=FormatItem(poollist,nil,true)
	return poolReward,(vo.activeCfg.poolflicker or {})
end


function acKzhdVoApi:isToday(activeName)
	local isToday=false
	local vo = self:getAcVo(activeName)
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acKzhdVoApi:getBigRewardsCfg()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.reward
	end
	return {}
end

function acKzhdVoApi:clearData(flag)
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.c=0
	vo.rd={}

	if flag then
		eventDispatcher:dispatchEvent("active.kzhd",{})
	end

end

function acKzhdVoApi:socketBuy(action,sid,refreshFunc)
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
	socketHelper:acKzhdBuyGift(callBack,action,sid)
end

function acKzhdVoApi:getBuyId()
	local vo=self:getAcVo()
	local buyId=vo.c or 0
	return buyId
end

function acKzhdVoApi:showGiftBuyDialog(layerNum,istouch,isuseami,callBack,giftId,shopInfo,parent)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acKzhdSmallDialog"
	return acKzhdSmallDialog:showGiftBuy(layerNum,istouch,isuseami,callBack,giftId,shopInfo,parent)
end



function acKzhdVoApi:canReward(activeName)
	local isfree=true							--是否是第一次免费
	if self:isToday(activeName)==true then
		isfree=false
	end
	return isfree
    
end

function acKzhdVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acKzhdVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end
