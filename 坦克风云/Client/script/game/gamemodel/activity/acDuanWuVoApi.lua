acDuanWuVoApi={
	name=nil,
}
function acDuanWuVoApi:clearAll()
	self.name = nil
end
function acDuanWuVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acDuanWuVoApi:setActiveName(name)
	self.name=name
end

function acDuanWuVoApi:getActiveName()
	return self.name or "duanwu"
end

function acDuanWuVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end

function acDuanWuVoApi:canReward( )
	if self:TabOneIsCanAward() then
		return true
	end
	return false
end

function acDuanWuVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acDuanWuVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end
function acDuanWuVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acDuanWuVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end
function acDuanWuVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end

function acDuanWuVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acDuanWuVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

-------------------- t a b 1 --------------------

function acDuanWuVoApi:showInfoTipTb(layerNum)
	local tabStr = {}
	for i=1,3 do
        table.insert(tabStr,getlocal("activity_duanwu_Tip"..i))
    end
    local titleStr=getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,tabStr,nil,25)
end

function acDuanWuVoApi:getAllRechargeNums()--当前累计充值数
	local vo = self:getAcVo()
	if vo and vo.allReNums then
		return vo.allReNums
	end
	print "error ~~~~~~~~~ vo.allReNums is nil"
	return 0 
end

function acDuanWuVoApi:getAllRechargeStalls()--配置给的充值档位表
	local vo = self:getAcVo()
	if vo and vo.rechargeStallsTb then
		local canReward = 0
		local leftGoldNums = nil
		local curReNums = self:getAllRechargeNums()
		for k,v in pairs(vo.rechargeStallsTb) do
			if curReNums >= v then
				canReward = canReward + 1
			else
				leftGoldNums = v - curReNums
				do break end
			end
		end
		return vo.rechargeStallsTb,canReward,leftGoldNums,SizeOfTable(vo.rechargeStallsTb)
	end
	print "error ~~~~~~~~~ vo.rechargeStallsTb is nil"
	return {}
end

function acDuanWuVoApi:getHadAwardTb()--已领的 充值奖励对应表
	local vo = self:getAcVo()
	if vo and vo.hadAwardTb then
		return vo.hadAwardTb
	end
	return {}
end

function acDuanWuVoApi:TabOneIsCanAward( )
	local vo = self:getAcVo()
	if vo.rechargeStallsTb then
		local curReNums = self:getAllRechargeNums()
		local canReward = 0
		for k,v in pairs(vo.rechargeStallsTb) do
			if curReNums >= v then
				canReward = canReward + 1
			end
		end
		-- print("curReNums---canReward---->>>",curReNums,canReward,SizeOfTable(vo.hadAwardTb))
		if (vo.hadAwardTb and canReward > SizeOfTable(vo.hadAwardTb)) or (canReward > 0 and vo.hadAwardTb == nil) then
			return true
		end
	end
	return false
end

function acDuanWuVoApi:getAllRechargeAwardsTb( )--配置 充值档位对应的奖励表
	local vo = self:getAcVo()
	if vo and vo.rechargeAwardsTb then
		return vo.rechargeAwardsTb
	end
	print "error ~~~~~~~~~ vo.rechargeAwardsTb is nil"
	return {}
end

function acDuanWuVoApi:getRechargeAeward(idx,callBack)--领取充值档位对应奖励
	local function socketCall(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret == true then
			local rechargeAwardsTb = self:getAllRechargeAwardsTb()[idx]
			local reward = FormatItem(rechargeAwardsTb)
			for k,v in pairs(reward) do
                G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),false,true)
            end
            G_showRewardTip(reward,true)

            if sData and sData.data then----------------
	        	if sData.data.duanwu then
	        		self:updateSpecialData(sData.data.duanwu)
	        	end
	        end
	        if callBack then
	        	callBack()
	        end
		end
	end
	socketHelper:activeDuanWu(socketCall,"task",idx)-------------------
end
-------------------- t a b 2 --------------------

function acDuanWuVoApi:formatShop()--格式化商店信息：到达限购条件的放后面
	local vo = self:getAcVo()
	if vo and vo.shopListTb then
		if not vo.buyTb then
			print "~~~~~~~~~ vo.shopListTb is nil"
			for k,v in pairs(vo.shopListTb) do
				v.oldIdx = k
			end
			return SizeOfTable(vo.shopListTb),vo.shopListTb,{}
		end
		local formatTb,limitedTb = {},{}
		for k,v in pairs(vo.shopListTb) do
			v.oldIdx = k
			if not vo.buyTb["i"..k] or v.maxLimit > vo.buyTb["i"..k] then
				table.insert(formatTb,v)
			elseif vo.buyTb["i"..k] and v.maxLimit <= vo.buyTb["i"..k] then
				v.isOver =true
				table.insert(limitedTb,v)
			end
		end

		for k,v in pairs(limitedTb) do
			table.insert(formatTb,v)
		end

		return SizeOfTable(formatTb),formatTb,vo.buyTb
	end
	print "error ~~~~~~~~~ vo.shopListTb is nil"
	return {}
end

function acDuanWuVoApi:socketBuy(sureCall,buyId,needGems,sParent,rewardData,layerNum)

	local gems=playerVoApi:getGems() or 0
	local strSize3 = G_isAsia() and 25 or 22
    if needGems>gems then
        local function onSure()
            -- self:close()
            if sParent.close then
	    		sParent:close()
	    	end
            activityAndNoteDialog:closeAllDialog()
        end
        GemsNotEnoughDialog(nil,nil,needGems-gems,layerNum+1,needGems,onSure)
        return
    end
    if sParent then
    	if sParent.sureItem then
    		sParent.sureItem:setEnabled(false)
    	end
    	if sParent.close then
    		sParent:close()
    	end
    end

    local function sureClick()
        local function socketCall(fn,data)
			local ret,sData = base:checkServerData(data)
			if ret == true then
                G_addPlayerAward(rewardData.type,rewardData.key,rewardData.id,tonumber(rewardData.num),false,true)
	            G_showRewardTip({rewardData},true)
	            playerVoApi:setGems(playerVoApi:getGems() - needGems)
	            if sData and sData.data then----------------
		        	if sData.data.duanwu then
		        		self:updateSpecialData(sData.data.duanwu)
		        	end
		        end
		        if sureCall then
		        	sureCall()
		        end
			end
		end
		print("buyId---->>>>",buyId)
		socketHelper:activeDuanWu(socketCall,"buyshop",buyId)--
    end
    local function secondTipFunc(sbFlag)
        local keyName=self:getActiveName()
        local sValue=base.serverTime .. "_" .. sbFlag
        G_changePopFlag(keyName,sValue)
    end
    

    if needGems and needGems>0 then
        local keyName=self:getActiveName()

        if G_isPopBoard(keyName) then--
            self.secondDialog=G_showSecondConfirm(layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("packsBuyTip",{needGems,rewardData.name}),true,sureClick,secondTipFunc,nil,{strSize3})
        else
            sureClick()
        end
    end
end



