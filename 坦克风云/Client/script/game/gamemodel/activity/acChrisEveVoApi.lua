acChrisEveVoApi ={}

function  acChrisEveVoApi:getAcVo( )
	return activityVoApi:getActivityVo("shengdanqianxi")
end
function acChrisEveVoApi:canReward()
	local otherData,maxNums = acChrisEveVoApi:getRecGiftTbNoName()
	if self:getFirstRecTime() ==0 or maxNums >0 then
		return true
	end
	local acVo = self:getAcVo()
	if  base.serverTime > acVo.acEt -86400 then
		local rankList = acChrisEveVoApi:getRankList()
        local listNum = SizeOfTable(rankList)
        local myUid = playerVoApi:getUid()
        for i=1,listNum do
            if rankList[i][1]==myUid then
                return true
            end
        end
	end
	return false
end
function acChrisEveVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end
function acChrisEveVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end
function acChrisEveVoApi:getRewardTb( )
	local vo = self:getAcVo()
	if vo and vo.reward then
		return vo.reward,vo.rewardIdxBigTb
	end
	return nil
end

function acChrisEveVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = vo.et - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.et - 86400 - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return getlocal("activityCountdown")..":"..activeTime
	end
	return str
end

function acChrisEveVoApi:getShopByIdIdx(idIdx)
	local shopRewardTb= self:getShopTb( )
	for k,v in pairs(shopRewardTb) do
			if idIdx ==k then
				local unAwardTb = v["reward"]
				award =FormatItem(unAwardTb,false)[1]
				print("award---->",award.name)
				return award
			end
	end
end

function acChrisEveVoApi:getUseUpLoveGems(id)---返回接收礼物所需的爱心值
	local vo = self:getAcVo()
	-- print("in ---->getUseUpLoveGems----id>",id)
	for k,v in pairs(vo.reward) do
		for i,j in pairs(v) do
			if id ==vo.rewardIdxBigTb[k][i] then
				return j["l"],FormatItem(j["r"],false)[1]
			end
		end
	end
	print(" error in Use up~~~~~")
	return nil
end

function acChrisEveVoApi:getUseUpLoveGemsNoName(idx)
	local vo = self:getAcVo()
	local giftNoNameTb = acChrisEveVoApi:getRecGiftTbNoName()
	local formatAwardTb = {}
	local giftAllUseUp = 0
	local curIdx = 1

	for k,v in pairs(giftNoNameTb) do
		if curIdx ==idx then
			for i,j in pairs(vo.reward) do
				for o,p in pairs(j) do
					if o ==k then
						formatAwardTb =FormatItem(p["r"],false)[1]
						giftAllUseUp =p["l"]*v
						return formatAwardTb,giftAllUseUp,v
					end
				end
			end
		end
		curIdx =curIdx+1
	end
end

function acChrisEveVoApi:getChooseReward()
	local vo = self:getAcVo()
	if vo and vo.chooseReward then
		return vo.chooseReward
	end
	return{}
end
function acChrisEveVoApi:setChooseReward(chooseReward)
	local vo = self:getAcVo()
	if vo and chooseReward then
		vo.chooseReward =chooseReward
	else
		vo.chooseReward ={}
	end
end

function acChrisEveVoApi:getChooseRewardIdx()
	local vo = self:getAcVo()
	if vo and vo.chooseRewardIdx then
		return vo.chooseRewardIdx
	end
	return{}
end
function acChrisEveVoApi:setChooseRewardIdx(chooseRewardIdx)
	local vo = self:getAcVo()
	if vo and chooseRewardIdx then
		vo.chooseRewardIdx =chooseRewardIdx
	else
		vo.chooseRewardIdx =0
	end
end
function acChrisEveVoApi:getWhiSid(giftIdx,rewardIdx)
	local vo = self:getAcVo()
	if vo and vo.rewardIdxBigTb then
			return  vo.rewardIdxBigTb[giftIdx][rewardIdx]
	end
	return nil
end

function acChrisEveVoApi:getWhiRewardTb(rewardIdx)
	-- self:setChooseRewardIdx(rewardIdx)
	local rewardTb,rewardIdxBigTb = self:getRewardTb()
	local sendGiftTimesTb = self:getSendGiftTimesTb()
	local rewardFTb = {}
	local lostGemsTbTop = {}
	local inMyGiftTimesTb = {}
	local nums = 0
	for k,v in pairs(rewardTb[rewardIdx]) do
		
		local Iidx = rewardIdxBigTb[rewardIdx][k]
		-- print("k----Iidx--->",k,Iidx)
		local singleReward = FormatItem(v["r"],false)
		local lostGems = v.s
		local curLost = nil
		table.insert(rewardFTb,singleReward[1])
		table.insert(lostGemsTbTop,lostGems)
		if sendGiftTimesTb[Iidx] ==nil then
			curLost=0
		else
			curLost =sendGiftTimesTb[Iidx]
		end
		table.insert(inMyGiftTimesTb,curLost)
		nums = nums+1
	end
	return rewardFTb,nums,lostGemsTbTop,inMyGiftTimesTb
end

function acChrisEveVoApi:setWhiPayTb(needTbIdx,needSelectTbIdx)
	local needTb = self:getRewardTb()
	local vo = self:getAcVo()
	if vo and needTbIdx and needSelectTbIdx then
		local allIdx = SizeOfTable(needTb[needTbIdx])+1
		for k,v in pairs(needTb[needTbIdx]) do
			-- print("v.index------>",v.index,allIdx,needSelectTbIdx,allIdx-needSelectTbIdx)
			if allIdx-needSelectTbIdx == tonumber(v.index) then
				-- print("vo.singleGiftAllData.index---->",vo.singleGiftAllData.index,v.index)
				vo.singleGiftAllData = v
			end
		end
	else
		vo.singleGiftAllData ={}
	end
end
function acChrisEveVoApi:getWhiPayTb( )
	local vo = self:getAcVo()
	if vo and vo.singleGiftAllData then
		return vo.singleGiftAllData
	end
	return {}
end
function acChrisEveVoApi:setSelectIdx(selectIconIdx)
	local vo = self:getAcVo()
	if vo and selectIconIdx then
		vo.selectIconIdx =selectIconIdx
	else
		vo.selectIconIdx =0
	end
end
function acChrisEveVoApi:getSelectIdx()
	local vo = self:getAcVo()
	if vo and vo.selectIconIdx then
		return vo.selectIconIdx
	end
	return 0
end

function acChrisEveVoApi:setSelectTb(selectTb)
	local vo = self:getAcVo()
	if vo and selectTb then
		vo.selectTb =selectTb
	else
		vo.selectTb ={}
	end
end
function acChrisEveVoApi:getSelectTb()
	local vo = self:getAcVo()
	if vo and vo.selectTb then
		return vo.selectTb
	end
	return {}
end

function acChrisEveVoApi:setClickTag(clickTag)
	local vo = self:getAcVo()
	if vo and clickTag then
		vo.clickTag =clickTag
	else
		vo.clickTag =0
	end
end
function acChrisEveVoApi:getClickTag()
	local vo = self:getAcVo()
	if vo and vo.clickTag then
		return vo.clickTag
	end
	return 0
end

function acChrisEveVoApi:setFriendTb(friendTb)
	local vo = self:getAcVo()
	if vo and friendTb then
		vo.friendTb =friendTb
	else
		vo.friendTb ={}
	end
end
function acChrisEveVoApi:getFriendTb()
	local vo = self:getAcVo()
	if vo and vo.friendTb then
		return vo.friendTb
	end
	return {}
end

function acChrisEveVoApi:setRecId(recId)
	local vo = self:getAcVo()
	if vo and recId then
		vo.recId =recId
	else
		vo.recId =nil
	end
end
function acChrisEveVoApi:getRecId()
	local vo = self:getAcVo()
	if vo and vo.recId then
		return vo.recId
	end
	return nil
end

function acChrisEveVoApi:setTuid(tuid)
	local vo = self:getAcVo()
	if vo and tuid then
		vo.tuid =tuid
	else
		vo.tuid =nil
	end
end
function acChrisEveVoApi:getTuid()
	local vo = self:getAcVo()
	if vo and vo.tuid then
		return vo.tuid
	end
	return nil
end

function acChrisEveVoApi:setExpendLoveGems(expendLoveGems)
	local vo = self:getAcVo()
	if vo and expendLoveGems then
		vo.expendLoveGems =expendLoveGems
	else
		vo.expendLoveGems =nil
	end
end
function acChrisEveVoApi:getExpendLoveGems()
	local vo = self:getAcVo()
	if vo and vo.expendLoveGems then
		return vo.expendLoveGems
	end
	return 0
end
function acChrisEveVoApi:setRecNeedLoves(recNeedLoves)--接收某一个礼物所需要的爱心值
	local vo = self:getAcVo()
	if vo and recNeedLoves then
		vo.recNeedLoves =recNeedLoves
	else
		vo.recNeedLoves =nil
	end
end
function acChrisEveVoApi:getRecNeedLoves()
	local vo = self:getAcVo()
	if vo and vo.recNeedLoves then
		return vo.recNeedLoves
	end
	return nil
end

function acChrisEveVoApi:setSureFriend(SureFriend,idx)
	local vo = self:getAcVo()
	if vo and SureFriend then
		vo.SureFriend =SureFriend
		self:setTuid(SureFriend.uid)
	else
		vo.SureFriend ={}
	end
end
function acChrisEveVoApi:getSureFriend()
	local vo = self:getAcVo()
	if vo and vo.SureFriend then
		return vo.SureFriend
	end
	return {}
end
function acChrisEveVoApi:getRankReward()
	local vo = self:getAcVo()
	local rankRewardAllIdx = {}
	G_dayin(vo.rankReward)
	if vo and vo.rankReward then
		for k,v in pairs(vo.rankReward) do
			local fReward =FormatItem(v.reward,false) 
			local awardShow = ""
			for m,n in pairs(fReward) do
				if m > 1 then
					awardShow = awardShow..", "
				end
				awardShow = awardShow..n.name.."x"..n.num

			end
			-- local award = 
			local pm = nil
			-- local awardShow = award.name.."x"..award.num
			if v.range[1] ==v.range[2] then
				pm =getlocal("activity_cuikulaxiu_rankToReward",{v.range[1],awardShow})
			else
				pm =getlocal("activity_cuikulaxiu_rankTorankReward",{v.range[1],v.range[2],awardShow})
			end
			table.insert(rankRewardAllIdx,pm)
		end
		return vo.rankReward,SizeOfTable(rankRewardAllIdx),rankRewardAllIdx
	end
	return {}
end

function acChrisEveVoApi:setSendGiftTimesTb(sendGiftTimesTb)
	local vo = self:getAcVo()
	if vo and sendGiftTimesTb then
		vo.sendGiftTimesTb =sendGiftTimesTb
	else
		vo.sendGiftTimesTb ={}
	end
end
function acChrisEveVoApi:getSendGiftTimesTb()
	local vo = self:getAcVo()
	if vo and vo.sendGiftTimesTb then
		return vo.sendGiftTimesTb
	end
	return {}
end

function acChrisEveVoApi:setLoveGems(loveGems)--慷慨值==爱心值
	local vo = self:getAcVo()
	if vo and loveGems then
		vo.loveGems =loveGems
	else
		vo.loveGems =0
	end
end
function acChrisEveVoApi:getLoveGems()
	local vo = self:getAcVo()
	if vo and vo.loveGems then
		return vo.loveGems
	end
	return 0
end

function acChrisEveVoApi:setSendAllTimes(sendAllTimes)
	local vo = self:getAcVo()
	if vo and sendAllTimes then
		vo.sendAllTimes =sendAllTimes
	else
		vo.sendAllTimes =0
	end
end
function acChrisEveVoApi:getSendAllTimes()
	local vo = self:getAcVo()
	if vo and vo.sendAllTimes then
		return vo.sendAllTimes
	end
	return 0
end

function acChrisEveVoApi:setChoosePayType(choosePayType)--1  是 用物品抵扣   =0是 用金币代替  3 什么都不是
	local vo = self:getAcVo()
	if vo and choosePayType then
		vo.choosePayType =choosePayType
	else
		vo.choosePayType =3
	end
end
function acChrisEveVoApi:getChoosePayType()
	local vo = self:getAcVo()
	if vo and vo.choosePayType then
		return vo.choosePayType
	end
	return 3
end


function acChrisEveVoApi:setRecGiftTb(recGiftTb)--有 人名的
	local vo = self:getAcVo()
	if vo and recGiftTb then
		vo.recGiftTb =recGiftTb
	else
		vo.recGiftTb ={}
	end
end
function acChrisEveVoApi:getRecGiftTb()
	local vo = self:getAcVo()
	if vo and vo.recGiftTb then
		local allNums = 0
		if vo.recGiftTbNoName then
			for k,v in pairs(vo.recGiftTbNoName) do
				allNums = allNums + v
			end
		end
		return vo.recGiftTb,allNums
	end
	return {}
end

function acChrisEveVoApi:setRewardHas(rewardedhas)--有 人名的
	local vo = self:getAcVo()
	if vo and rewardedhas then
		vo.rewardedhas =rewardedhas
	end
end
function acChrisEveVoApi:getRewardHas()
	local vo = self:getAcVo()
	if vo and vo.rewardedhas then
		return vo.rewardedhas
	end
	return nil
end



function acChrisEveVoApi:setRecGiftTbNoName(recGiftTbNoName)
	local vo = self:getAcVo()
	if vo and recGiftTbNoName then
		vo.recGiftTbNoName =recGiftTbNoName
	else
		vo.recGiftTbNoName ={}
	end
end
function acChrisEveVoApi:getRecGiftTbNoName()
	local vo = self:getAcVo()
	if vo and vo.recGiftTbNoName then
		local giftMaxNum,giftNums = 0,0
		for k,v in pairs(vo.recGiftTbNoName) do
			giftMaxNum =giftMaxNum+v
			giftNums = giftNums + v
		end
		return vo.recGiftTbNoName,giftMaxNum,giftNums
	end
	return {}
end

function acChrisEveVoApi:getGAndListInTb( )
	
	local vo = self:getAcVo()
	-- print("SizeOfTable(vo.gAndListInTb)----->",SizeOfTable(vo.gAndListInTb))
	if vo and vo.gAndListInTb and SizeOfTable(vo.gAndListInTb)>0 then
		return vo.gAndListInTb
	end
	return {}
end

function acChrisEveVoApi:setGAndListInTb()--整合g 和list
	local recGiftTbNoName,nodata,giftNums = self:getRecGiftTbNoName()
	local recGiftTb = self:getRecGiftTb()--有人名的
	-- print("SizeOfTable(recGiftTbNoName)====>>>>",SizeOfTable(recGiftTbNoName))
	-- print("SizeOfTable(recGiftTb)=====>>>",SizeOfTable(recGiftTb))
	local vo = self:getAcVo()
	local noNameTb = {}
	local sortTb = {}
	if vo.gAndListInTb and SizeOfTable(vo.gAndListInTb)>0 then
		vo.gAndListInTb ={}
	end
	if vo and vo.gAndListInTb then
		for k,v in pairs(recGiftTbNoName) do
			-- print("k=====>>>>>",k)
			table.insert(noNameTb,tonumber(RemoveFirstChar(k)))
		end
		local function sortAsc(a, b)
			return a<b
	    end
		table.sort(noNameTb,sortAsc)

		local markTb = {}
		for k,v in pairs(recGiftTbNoName) do
			local isInNewTb = false
			-- if SizeOfTable(recGiftTb) > 0 then
				for m,n in pairs(recGiftTb) do--有人名的
					-- print("n[1]----v",n[1],v)
					-- print("n[1]==k----v---->>>",n[1],k,v)
					if n[1] ==k then
						markTb[k] = markTb[k] ==nil and 1 or markTb[k] + 1
	 					isInNewTb = true
						local index = m
						table.insert(n,index)
						table.insert(vo.gAndListInTb,n)
					end
				end
				-- print("isInNewTb==>>",isInNewTb)
				if isInNewTb == false or (markTb[k] and markTb[k] < v) then
					-- table.insert(n,SizeOfTable(vo.gAndListInTb) + 1)
					for i=1,v do
						if markTb[k] == nil or markTb[k] < v then
							markTb[k] = markTb[k] ==nil and 1 or markTb[k] + 1
							local playerName =getlocal("activity_chrisEve_oldMan")
							if(acChrisEveVoApi:isNormalVersion() or self:getVersion() == 5)then
			                    playerName =getlocal("activity_chrisEve_oldMan_1")
			                end
							table.insert(vo.gAndListInTb,{k,playerName,0,0})	
						end
					end
					
				end
			-- end
		end
		-- if giftNums > SizeOfTable(vo.gAndListInTb) + 1 then
		-- 	vo.gAndListInTb = {}
		-- end
		-- for k,v in pairs(vo.gAndListInTb) do
		-- 	print("v[1]===>",v[1])
		-- 	print("v[2]===>",v[2])
		-- 	print("v[3]===>",v[3])
		-- 	print("v[4]===>",v[4])
		-- end
	end
end

-- function acChrisEveVoApi:setIidx( )
-- 	local vo = self:getAcVo()
-- 	if vo and vo.rewardIdxBigTb and vo.iMax then
-- 		local outNums = SizeOfTable(vo.rewardIdxBigTb)
-- 		for k,v in pairs(vo.rewardIdxBigTb[outNums]) do
-- 			print("--------->",tonumber(RemoveFirstChar(v)),vo.iMax,outNums)
-- 			if tonumber(RemoveFirstChar(v))>vo.iMax then
-- 				vo.iMax =tonumber(RemoveFirstChar(v))
-- 			end
-- 		end
-- 	end
-- end

function acChrisEveVoApi:setIsNewData(isTrue)--
	local vo = self:getAcVo()
	if vo then
		vo.isNewData =isTrue
	end
end
function acChrisEveVoApi:getIsNewData()
	local vo = self:getAcVo()
	return vo.isNewData
end

function acChrisEveVoApi:setRefrInSmallDia(refrInSmallDia)--
	local vo = self:getAcVo()
	if vo then
		vo.refrInSmallDia =refrInSmallDia
	end
end
function acChrisEveVoApi:getRefrInSmallDia()
	local vo = self:getAcVo()
	return vo.refrInSmallDia
end



function acChrisEveVoApi:getMaxPage()
	local otherData,giftMaxNum = self:getRecGiftTbNoName()
	local pagenum =nil
	if self:getFirstRecTime() ==0 then
		giftMaxNum =giftMaxNum+1
		pagenum = math.ceil(giftMaxNum/11)
	else
		pagenum = math.ceil(giftMaxNum/10)
	end
	return pagenum
end


function acChrisEveVoApi:setFirstRecTime(firstT)--第一次领奖标识
	local vo = self:getAcVo()
	if vo and firstT then
		vo.firstT =firstT
	else
		vo.firstT =0
	end
end
function acChrisEveVoApi:getFirstRecTime()
	local vo = self:getAcVo()
	if vo and vo.firstT then
		return vo.firstT
	end
	return 0
end

function acChrisEveVoApi:setCostType(costType)--消耗类型 只给 配件使用
	local vo = self:getAcVo()
	if vo and costType then
		vo.costType =costType
	else
		vo.costType ="0"
	end
end
function acChrisEveVoApi:getCostType()
	local vo = self:getAcVo()
	if vo and vo.costType then
		return vo.costType
	end
	return {}
end

function acChrisEveVoApi:setBuyedTimeTb(buy)--购买记录TB
	local vo = self:getAcVo()
	if vo and buy then
		vo.buy =buy
	else
		vo.buy ={}
	end
end
function acChrisEveVoApi:getBuyedTimeTb()
	local vo = self:getAcVo()
	if vo and vo.buy then
		return vo.buy
	end
	return {}
end

function acChrisEveVoApi:setFirstreward(firstreward)--购买记录TB
	local vo = self:getAcVo()
	if vo and firstreward then
		vo.firstreward =firstreward
	else
		vo.firstreward ={}
	end
end
function acChrisEveVoApi:getFirstreward()
	local vo = self:getAcVo()
	if vo and vo.firstReward then
		return FormatItem(vo.firstReward,false)[1]
	end
	return {}
end
function acChrisEveVoApi:setCurBuyId(curBuyId)--当前购买商品的id
	local vo = self:getAcVo()
	if vo and curBuyId then
		vo.curBuyId =curBuyId
	else
		vo.curBuyId =nil
	end
end
function acChrisEveVoApi:getCurBuyId()
	local vo = self:getAcVo()
	if vo and vo.curBuyId then
		return vo.curcurBuyId
	end
	return nil
end

function acChrisEveVoApi:setRankList(rankList)--当前购买商品的id
	local vo = self:getAcVo()
	if vo and rankList then
		vo.rankList =rankList
	else
		vo.rankList ={}
	end
end
function acChrisEveVoApi:getRankList()
	local vo = self:getAcVo()
	if vo and vo.rankList then
		return vo.rankList
	end
	return nil
end


function acChrisEveVoApi:getShopTb( )--商店
	local vo = self:getAcVo()
	if vo and vo.shop then
		return vo.shop
	end
	return {}
end

function acChrisEveVoApi:getTopSendTime( )
	local vo = self:getAcVo()
	if vo and vo.daysend then
		return vo.daysend
	end
	return 99999
end

function acChrisEveVoApi:getRankPoint( )
	local vo = self:getAcVo()
	if vo and vo.rankPoint then
		return vo.rankPoint
	end
end

function acChrisEveVoApi:setlastTime(lastTime)
	local vo = self:getAcVo()
	if vo and lastTime then
		vo.lastTime =lastTime
	end
end
function acChrisEveVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acChrisEveVoApi:setCurrType( isCurr)
	local vo = self:getAcVo()

	if vo  then
		vo.isCurr =isCurr
	end
end
function acChrisEveVoApi:getCurrType()
	local acVo = self:getAcVo()
	return acVo.isCurr
end
function acChrisEveVoApi:setCurrTime( currTime)
	local vo = self:getAcVo()
	if vo and currTime then
		vo.currTime =currTime
	end
end
function acChrisEveVoApi:getCurrTime()
	local acVo = self:getAcVo()
	if acVo and acVo.currTime then
		return acVo.currTime
	end
	return nil
end
function acChrisEveVoApi:getConditiongems( )
	local vo = self:getAcVo()
	if vo and vo.conditiongems then
		return vo.conditiongems
	end
end
function acChrisEveVoApi:isRefreshAllServerData( )--------------
	local currTime = self:getCurrTime()
	local isCurr = self:getCurrType()
	-- print("isCurr---currTime---->",isCurr)
	if isCurr ==false then
		if currTime+300 < base.serverTime then
			self:setCurrType(true)
			return true
		else
			return false
		end
	end
end

function acChrisEveVoApi:getRewardTimeStr( )
	-- local vo  = self:getAcVo()
	-- local reTimeStr = activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
	-- return reTimeStr
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = G_formatActiveDate(vo.et - base.serverTime)
		if (base.serverTime > vo.acEt-86400 and base.serverTime < vo.acEt)==false then
			activeTime=getlocal("notYetStr")
		end
		return getlocal("onlinePackage_next_title")..activeTime
	end
	return str
end

function acChrisEveVoApi:getAllGiftToChat(noNeedFirst)--you_get_title
    local recGiftTb= acChrisEveVoApi:getGAndListInTb( )
    local recGiftTbNoName = acChrisEveVoApi:getRecGiftTbNoName()
    local rewardTb,rewardIdxBigTb = acChrisEveVoApi:getRewardTb()
    local showTb = {}
    local singleTb = {}
        for k,v in pairs(recGiftTbNoName) do
            for m,n in pairs(rewardTb) do
                for i,j in pairs(n) do
                    if rewardIdxBigTb[m][i] ==k then
                         singleTb =FormatItem(j["r"],false)[1]
                         singleTb.num =singleTb.num*v
                         -- print("singleTb.name--->",singleTb.name)
                         table.insert(showTb,singleTb)
                     end
                end
            end
        end
        if self:getFirstRecTime() ==0 and noNeedFirst ==nil then
        	local formatRewardTb =self:getFirstreward()
        	table.insert(showTb,formatRewardTb)
        end
        return showTb
end

--是否是非节日版本
function acChrisEveVoApi:isNormalVersion()
	local acVo = acChrisEveVoApi:getAcVo()
	if(acVo and acVo.version and (acVo.version==3 or acVo.version==4))then
		return true
	else
		return false
	end
end

function acChrisEveVoApi:getVersion( )
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		-- print("acVo.version ====>>>>",acVo.version)
		return acVo.version
	end
	return 1
end