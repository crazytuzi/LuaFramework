acDlbzVoApi={
	name         = nil,
	poolRewardTb = nil,
	rewardLog    = nil,
	oldExtraAwardPic = "",
}
function acDlbzVoApi:clearAll()
	self.oldExtraAwardPic = nil
	self.name         = nil
	self.poolRewardTb = nil
	self.rewardLog    = nil
end
function acDlbzVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acDlbzVoApi:setActiveName(name)
	self.name=name
end

function acDlbzVoApi:getActiveName()
	return self.name or "dlbz"
end

function acDlbzVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acDlbzVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end

function acDlbzVoApi:canReward( )
	if self:getCurReCount( ) == 0 and not self:isAllAwardGetEnd() then
		return true
	end
	return false
end

function acDlbzVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acDlbzVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end
function acDlbzVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acDlbzVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end
function acDlbzVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end

function acDlbzVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
    	activityVoApi:updateShowState(vo)
	end
end

function acDlbzVoApi:getEndRewardTb(idx )
	local vo = self:getAcVo()
	if vo and vo.getRewardTb then
		if idx then
			for k,v in pairs(vo.getRewardTb) do
				if v == idx then
					return true
				end
			end
			return false
		end
		return vo.getRewardTb
	end
	return {}
end

------------------------------------------------ d a t a ------------------------------------------------
function acDlbzVoApi:getLimit()
	local vo=self:getAcVo()
	if vo and vo.openLv then
		return vo.openLv
	end
	return 0
end

function acDlbzVoApi:getCurCostNum(idx)
	local vo = self:getAcVo()
	if vo and vo.costTb then
		return vo.costTb[idx] or 9999
	end
	print(">>>>>>>>>>> e r r o r ----->>> idx,vo.costTb[idx] <<<<<<<<<",idx,vo.costTb[idx])
	return 9999
end

function acDlbzVoApi:getAllRound( )
	local vo = self:getAcVo()
	if vo and vo.bigGiftNeed then
		return vo.bigGiftNeed
	end
	print(" >>> e r r o r in getAllRound <<<")
	return 2
end

function acDlbzVoApi:getOneRoundNum( )
	local vo = self:getAcVo()
	if vo and vo.roundNum then
		return vo.roundNum
	end
	print(" >>> e r r o r in getOneRoundNum <<<")
	return 24
end

function acDlbzVoApi:getLastNum( )
	local vo = self:getAcVo()
	if vo and vo.roundNum and vo.curReCount then
		return vo.roundNum - vo.curReCount , vo.roundNum
	end
	print(" >>> e r r o r in getLastNum <<<")
	return 0 ,vo.roundNum
end

function acDlbzVoApi:getPoolReward(idx)
	local vo = self:getAcVo()
	if vo and vo.poolRewardTb then
		if not self.poolRewardTb then
			self.poolRewardTb = FormatItem(vo.poolRewardTb[1],nil,true)
		end
		if idx then
			return self.poolRewardTb[idx]
		end
		return self.poolRewardTb
	end
	return {}
end

function acDlbzVoApi:getCurExtraRewardToShow()
	local vo = self:getAcVo()
	if vo and vo.extraRewardTb then
		local beginIdx = ( vo.lc and vo.lc > 0 ) and (vo.lc - 1) * 4 + 1 or 1
		local defaultArrNum = 0
		local extraTb       = {}
		local needNum = 0
		for k,v in pairs(vo.extraRewardTb) do
			defaultArrNum = defaultArrNum + SizeOfTable(v)
			if beginIdx <= defaultArrNum then
				extraTb = v
				for mm,nn in pairs(extraTb) do
					addBaseNeedNum = k > 1 and vo.extraRewardTb[1][SizeOfTable(vo.extraRewardTb[1])].needNum * (k - 1) or 0
					needNum = nn.needNum + addBaseNeedNum - vo.rCount
					if needNum > 0 or ( k == SizeOfTable(vo.extraRewardTb) and mm == SizeOfTable(extraTb) )then
						local award = FormatItem(nn.reward)[1]
						-- print("award.pic=======>>>>>",award.pic)
						local isChange = false
						if award.pic ~= self.oldExtraAwardPic then
							self.oldExtraAwardPic = award.pic
							isChange = true
						end
						needNum = needNum > 0 and needNum or nil
						return award,isChange,needNum
					end
				end

			end
		end
	end
	print " >>>> e r r o r  in getCurExtraRewardToShow with award.pic is nil <<<<"
	return nil
end

function acDlbzVoApi:getExtraRewardToShow(showIdx)
	local vo = self:getAcVo()
	if vo and vo.extraRewardTb then
		local defaultArrNum = 0
		local addArrNum     = 0
		local getIdx        = 0
		local extraTb       = {}
		local needNum = 0
		for k,v in pairs(vo.extraRewardTb) do
			defaultArrNum = defaultArrNum + SizeOfTable(v)
			if showIdx <= defaultArrNum then
				extraTb = vo.extraRewardTb[k]
				getIdx = showIdx - addArrNum
				addBaseNeedNum = k > 1 and vo.extraRewardTb[1][SizeOfTable(vo.extraRewardTb[1])].needNum * (k - 1) or 0
				needNum = extraTb[getIdx].needNum + addBaseNeedNum - vo.rCount
				do break end
			end
			addArrNum = addArrNum + SizeOfTable(v)
		end

		return FormatItem(extraTb[getIdx].reward)[1],needNum
	end
	print(" >>> e r r o r in getExtraRewardToShow <<<")
	return {}
end
function acDlbzVoApi:getExtraRewardTbNums( )
	local vo = self:getAcVo()
	if vo and vo.extraRewardTb then
		local exRewardNum = 0
		for k,v in pairs(vo.extraRewardTb) do
			exRewardNum = exRewardNum + SizeOfTable(v)
		end

		return exRewardNum--SizeOfTable(vo.extraRewardTb[1]) + SizeOfTable(vo.extraRewardTb[2])
	end
	print(" >>> e r r o r in getExtraRewardTbNums <<<")
	return 0
end


function acDlbzVoApi:getExtraRewardTb(idx)
	-- print(" in getExtraRewardTb idx is ====>>>>",idx)
	local vo = self:getAcVo()
	local lc = vo.lc > 0 and vo.lc or 1
	if vo and vo.extraRewardTb then
		if idx and vo.extraRewardTb then
			for k,v in pairs(vo.extraRewardTb) do
				for m,n in pairs(v) do
					local useNeedNum = k == 1 and n.needNum or 24 * (k - 1) + n.needNum
					-- print("useNeedNum===>>",useNeedNum)
					if useNeedNum == idx then
						local extrAwardTb = FormatItem(n.reward)[1]
						-- print("extrAwardTb.name==>>",extrAwardTb.name)
						return extrAwardTb,n.reward,n.needNum
					end
				end	
			end
		end
	else
		return vo.extraRewardTb
	end
	return {}
end

function acDlbzVoApi:getCurReCount( )
	local vo = self:getAcVo()
	if vo and vo.curReCount then
		return vo.curReCount,vo.lc
	end
	return nil 
end

function acDlbzVoApi:getLunCi( )
	local vo = self:getAcVo()
	if vo and vo.lc then
		return vo.lc
	end
	return 0
end

function acDlbzVoApi:getCurRate()
	local vo = self:getAcVo()
	if vo and vo.rate then
		return vo.rate
	end
	return nil
end

function acDlbzVoApi:getrCount()
	local vo = self:getAcVo()
	if vo and vo.rCount then
		return vo.rCount
	end
	return nil
end

function acDlbzVoApi:isOver( )
	local vo = self:getAcVo()
	if vo and vo.lc and vo.rCount and vo.bigGiftNeed and vo.roundNum then
		if vo.lc >= 2 and vo.rCount >= vo.bigGiftNeed * vo.roundNum then
			return true
		end
	end
	return false
end

function acDlbzVoApi:isAllAwardGetEnd( )--判断是否全部抽完
	local vo = self:getAcVo()
	if vo.rCount and vo.bigGiftNeed and vo.roundNum then
		return vo.rCount >= vo.bigGiftNeed * vo.roundNum and true or false
	end
	return false
end

function acDlbzVoApi:specicalMarkShow(icon,key)
 	local specShowTb = {[1]="r",[6]="y",[13]="y",[18]="y"}
	local specNumTb = {[1]=5,[6]=3,[13]=3,[18]=3}
	if specShowTb[key] then	
		G_addRectFlicker2(icon,1.1,1.1,specNumTb[key],specShowTb[key],nil,55)
	end
end

----------------------------------------------- l o g i c -------------------------------------------------

function acDlbzVoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		local hxcfg=acVo.activeCfg.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return {}
end

function acDlbzVoApi:showInfoTipTb(layerNum)
	local tabStr = {}
	local acVo=self:getAcVo()
	for i=1,4 do
		if i == 4 then
			table.insert(tabStr,getlocal("activity_dlbz_tip"..i,{SizeOfTable(acVo.extraRewardTb)}))
		else
	        table.insert(tabStr,getlocal("activity_dlbz_tip"..i))
	    end
    end
    local titleStr=getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,tabStr,nil,25)
end

function acDlbzVoApi:getLotteryCost( )
	local vo = self:getAcVo()
	if vo.curReCount and not self:isAllAwardGetEnd() then
		return self:getCurCostNum(vo.curReCount + 1)
	end
	return 0
end

function acDlbzVoApi:acDlbzRequest(cmd,args,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				local awardTime = base.serverTime
				if sData.data.dlbz then
					self:updateSpecialData(sData.data.dlbz)
					if sData.ts then
						awardTime = sData.ts
					end
				end
				if sData.data.dlbz then
					local rewardlist    = {}
					local rCount           = self:getrCount()
					local hxReward      = self:getHexieReward()
					local rewardPos     = self:getCurRate()
					local curPoolReward = self:getPoolReward(rewardPos)
	--activity_pjjnh_chatSystemMessage
					table.insert(rewardlist,curPoolReward)
					G_addPlayerAward(curPoolReward.type,curPoolReward.key,curPoolReward.id,curPoolReward.num,nil,true)

					local curReCount,lc = self:getCurReCount()
					local addBigAward = nil
					if rCount % 6 == 0 then--额外大奖
						-- print("rCount=====>>>",rCount)
						addBigAward = acDlbzVoApi:getExtraRewardTb(rCount) 
						table.insert(rewardlist,addBigAward)
						G_addPlayerAward(addBigAward.type,addBigAward.key,addBigAward.id,addBigAward.num,nil,true)
					end
					-- self:willChatMessage(reward)
					if hxReward then
						G_addPlayerAward(hxReward.type,hxReward.key,hxReward.id,hxReward.num,nil,true)
					end
					if self.rewardLog then
						local awardInfoTb = {}
						awardInfoTb[1] = rCount
						awardInfoTb[2] = curPoolReward
						awardInfoTb[3] = awardTime
						awardInfoTb[4] = addBigAward
						self:formatLog(awardInfoTb,true)
					end

					if callback then
						-- self.rewardPos = rewardPos
						callback(rewardlist,hxReward,rewardPos,{curPoolReward},addBigAward)				
					end
				end
				
				if sData.data.log then --日志
					self.rewardLog={}
					for k,v in pairs(sData.data.log) do
						self:formatLog(v)
					end

					if callback then
						callback()
					end
				end
				
			end
		end
	end
	socketHelper:acDlbzRequest(cmd,args,requestHandler)
end
--格式化抽奖记录
function acDlbzVoApi:formatLog(data,addFlag)
	local rCount=data[1]
	local rewards=data[2]
	local addAward = data[4] or nil
	local rewardlist={}
	if addFlag then
		table.insert(rewardlist,rewards)
		if addAward then
			table.insert(rewardlist,addAward)
		end
	else
		for k,v in pairs(rewards) do
			local reward=FormatItem(v,nil,true)
			if SizeOfTable(reward) > 1 then
				for m,n in pairs(reward) do
					table.insert(rewardlist,n)	
				end
			else
				table.insert(rewardlist,reward[1])
			end
		end
	end
	local hxReward=self:getHexieReward()
	if hxReward then
		-- hxReward.num=hxReward.num*num
		table.insert(rewardlist,1,hxReward)
	end
	local time=data[3] or base.serverTime
	local lcount=SizeOfTable(self.rewardLog)
	if lcount>=10 then
		for i=10,lcount do
			table.remove(self.rewardLog,i)
		end
	end
	if addFlag and addFlag==true then
    	table.insert(self.rewardLog,1,{rCount=rCount,reward=rewardlist,time=time,point=point})
	else
	    table.insert(self.rewardLog,{rCount=rCount,reward=rewardlist,time=time,point=point})
	end
end

function acDlbzVoApi:getRewardLog()
	return self.rewardLog
end

function acDlbzVoApi:getTipData( )
	local vo = self:getAcVo()
	local exRewardNum = 0
	if vo and vo.extraRewardTb then
		for k,v in pairs(vo.extraRewardTb) do
			exRewardNum = exRewardNum + SizeOfTable(v)
		end
	end

	local awardNums = 0
	if vo.roundNum and vo.bigGiftNeed then
		awardNums = vo.roundNum * vo.bigGiftNeed
	end
	local bigAward = self:getExtraRewardToShow(exRewardNum)
	return awardNums,bigAward.name,bigAward.num
end






