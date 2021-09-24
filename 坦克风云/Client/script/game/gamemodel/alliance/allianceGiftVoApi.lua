allianceGiftVoApi={
	formatGiftTb = {},
	isCanRefresh = false,
}
function allianceGiftVoApi:clear()
	self.formatGiftTb = nil
	self.isCanRefresh = nil
end

function allianceGiftVoApi:setRefreshType(newType)
	self.isCanRefresh = newType
end

function allianceGiftVoApi:getRefreshType( )
	return self.isCanRefresh
end

function allianceGiftVoApi:getGiftVo( )
	return allianceGiftVo
end

function allianceGiftVoApi:updateSpecialData(data)
	local vo = self:getGiftVo()
	if vo then
		vo:initWithData(data)
	end
end

function allianceGiftVoApi:getLevel( )
	return tonumber(allianceGiftVo.level) or 1
end

function allianceGiftVoApi:getExp( )
	return tonumber(allianceGiftVo.exp) or 0
end

function allianceGiftVoApi:getRechargeSmallLimit( )
	if allianceGiftCfg and allianceGiftCfg.stage and allianceGiftCfg.stage[1] and allianceGiftCfg.stage[1].diamond then
		return allianceGiftCfg.stage[1].diamond
	end
	return 100
end

function allianceGiftVoApi:showInfoTipTb(layerNum)
	local tabStr = {}
	for i=1,7 do
		if i == 7 then
			table.insert(tabStr,getlocal("allianceGift_tip"..i,{self:getRechargeSmallLimit()}))
		else
	        table.insert(tabStr,getlocal("allianceGift_tip"..i))
	    end

    end
    local titleStr=getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,tabStr,nil,25)
end

--- nNum 源数字
--- n 小数位数
function allianceGiftVoApi:getNum(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0;
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal);
    local nRet = nTemp / nDecimal;
    return nRet;
end

function allianceGiftVoApi:getExpData()-- 当前等级，下一等级，经验值比例
	
	local curLvl = self:getLevel()
	local curExp = self:getExp()
	local gradeExpTb = allianceGiftCfg.gradeExp
	local per,perNum,nextLvl = nil,nil,nil
	
	if gradeExpTb[curLvl] then
		-- print("curExp----gradeExpTb[curLvl].exp-------->>>>",(curExp / gradeExpTb[curLvl].exp)%0.0001)
		local num1 = curExp / gradeExpTb[curLvl].exp
		-- per = ((curExp / gradeExpTb[curLvl].exp) - (curExp / gradeExpTb[curLvl].exp)%0.0001)* 100
		-- per = string.format("%0.4f", curExp / gradeExpTb[curLvl].exp) * 100
		per = allianceGiftVoApi:getNum(num1,4) * 100
		per = per .."%"
		perNum = curExp / gradeExpTb[curLvl].exp * 100
		nextLvl = gradeExpTb[curLvl + 1] and gradeExpTb[curLvl + 1].grade or curLvl + 1
	else--满级情况
		per = getlocal("donatePointMax")
		-- nextLvl = ""--curLvl + 1
		-- perNum = 0
	end
	-- print("per--->>",per)
	return curLvl,nextLvl,per,perNum
end

function allianceGiftVoApi:getCurGiftNumsAndLimit( )
	local vo = self:getGiftVo()
	return SizeOfTable(vo.giftTb) , allianceGiftCfg.rangeLimit
end

function allianceGiftVoApi:getCurGiftTb( )
	local vo = self:getGiftVo()
	return SizeOfTable(vo.giftTb), vo.giftTb
end

function allianceGiftVoApi:getCurGiftNumsPer( )
	local vo = self:getGiftVo()
	local curNum = SizeOfTable(vo.giftTb)
	return curNum / allianceGiftCfg.rangeLimit * 100
end

function allianceGiftVoApi:formatCurGiftTb( )--取所有ID 对应的礼包
	local vo = self:getGiftVo()
	self.formatGiftTb = {}
	if vo.giftTb and SizeOfTable(vo.giftTb) > 0 then
		for k,v in pairs(vo.giftTb) do
			if SizeOfTable(v) == 1 then
				local newTb = G_clone(allianceGiftCfg.gradeGift.list[v[1]])
				newTb.grade = v[1]
				table.insert(self.formatGiftTb,newTb)
			else
				local giftId = allianceGiftCfg.commonGiftId[v[1]][v[2]] or nil
				if giftId then
					local newTb = G_clone(allianceGiftCfg.gift.list[giftId])
					newTb.grade = v[1]
					table.insert(self.formatGiftTb,newTb)
				elseif not giftId then
					print "====================== e r r o r ---->>>> giftId is nil ======================"
				end
			end
		end
	end
	return self.formatGiftTb or {}
end

function allianceGiftVoApi:socketRec(socketCallback)
	local aid = playerVoApi:getPlayerAid()
	local vo = self:getGiftVo()
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data and sData.data.reward then
				local reward = {}
				for k,v in pairs(sData.data.reward) do
					local item = FormatItem(v)[1]
					-- print("item.name-->>",item.name)
					table.insert(reward,item)
				end


				-- local reward = FormatItem(sData.data.reward)
				-- print("SizeOfTable(reward)--->>>",SizeOfTable(reward))
				for k,v in pairs(reward) do
					G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
				end
				vo:clearGiftTb()
				if socketCallback then
					socketCallback(reward)
				end
			end
		end
	end
	socketHelper:allianceGiftRec(aid,requestHandler)
end

function allianceGiftVoApi:isCanChangeFlag( )
	local vo = self:getGiftVo()
	for k,v in pairs(allianceGiftCfg.flagLimit) do
		if v.flag then
			local grade = v.grade
			local unlockKey = ""
			if vo.level and vo.level >= grade then
				if v.flag and v.flag.al then
					for m,n in pairs(v.flag.al) do
						unlockKey = m 
						do break end
					end
				end
				if allianceVoApi then
					if unlockKey ~= "" then
						allianceVoApi:setUnlockFlagValue(unlockKey)
					end
				end
			end
		end
	end
end