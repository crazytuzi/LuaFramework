acZncfVoApi={
	name=nil,
	showPageIndex = 1,
	dataTb = {},
}
function acZncfVoApi:clearAll()
	self.name = nil
	self.showPageIndex = nil
	self.dataTb = {}
end
function acZncfVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acZncfVoApi:setActiveName(name)
	self.name=name
end

function acZncfVoApi:getActiveName()
	return self.name or "zncf"
end

function acZncfVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end
function acZncfVoApi:getLimit()
	local vo=self:getAcVo()
	if vo and vo.openLv then
		return vo.openLv
	end
	return 0
end

function acZncfVoApi:showInfoTipTb(layerNum)
	local tabStr = {}
	for i=1,4 do
        table.insert(tabStr,getlocal("activity_zncf_tip"..i))
    end
    local titleStr=getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,tabStr,nil,25)
end

function acZncfVoApi:canReward( )
	if not acZncfVoApi:hasReward() then
		return true
	end
	return false
end

function acZncfVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acZncfVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end
function acZncfVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acZncfVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage3.plist")
    spriteController:addTexture("public/activeCommonImage3.png")
end
function acZncfVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage3.plist")
    spriteController:removeTexture("public/activeCommonImage3.png")
end

function acZncfVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acZncfVoApi:isEnd()
    local vo = self:getAcVo()
    if vo and base.serverTime < vo.et then
        return false
    end
    return true
end

--每日福利大奖
function acZncfVoApi:getDailyReward()
    local vo = self:getAcVo()
    if vo == nil then
        do return {} end
    end
    return FormatItem(vo.dailyReward[1].reward, nil, true)
end

function acZncfVoApi:resetDailyReward()
    local vo = self:getAcVo()
    if vo then
        vo.rewardFlag = 0
        vo.lastTime = base.serverTime
    end
end
--是否可以领取奖励
function acZncfVoApi:hasReward()
    local vo = self:getAcVo()
    if vo == nil then
        return true
    end
    if self:isToday() == false then
        vo.rewardFlag = 0
    end

    if vo.rewardFlag and tonumber(vo.rewardFlag) == 1 then
        return true
    end
    return false
end
function acZncfVoApi:updateData(data)
    local vo = self:getAcVo()
    vo:updateData(data)
    activityVoApi:updateShowState(vo)
end
--获取每日奖励
function acZncfVoApi:getRewardRequest(callback)
    local function handler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.zncf then
                self:updateData(sData.data.zncf)
                if callback then
                    callback()
                end
            end
        end
    end
    socketHelper:acZncfRewardRequest(handler)
end

function acZncfVoApi:getDescIdx(tabIdx,rtdData)
	local vo = self:getAcVo()
	if vo and vo.desc and vo.descType then
		for k,v in pairs(vo.desc) do
			if v == tonumber(tabIdx) then
				for m,n in pairs(vo.descType) do
					if tonumber(rtdData) >=n[1] and tonumber(rtdData) <= n[2] then
						return m
					end
				end
			end
		end
	end
	return nil
end

function acZncfVoApi:getRtd(tabIdx)
	local vo = self:getAcVo()
	local rtdData = 0
	local descIdx = 1
	if vo and vo.rtd and vo.rtd[tabIdx] then
		rtdData = vo.rtd[tabIdx] * 100
		descIdx = self:getDescIdx(tabIdx,rtdData)
	else
		descIdx = nil
	end
	return rtdData,descIdx
end

function acZncfVoApi:getDataByTab(tabIdx,callback)
	local rtd,descIdx = self:getRtd(tabIdx)
	local dataTb = {}
	if tabIdx == 1 then--成长
		local regdate  =  G_getDataTimeStr(playerVoApi:getRegdate(),true,true)
		local days     = math.ceil( (base.serverTime - playerVoApi:getRegdate()) / 86400 )
		local curPower = playerVoApi:getPlayerPower()
		
		dataTb = {regdate,days,curPower,rtd}
	elseif tabIdx == 2 then--将领
		local function heroDataHandle( )
			local heroPower = heroVoApi and math.floor(heroVoApi.allPower) or 0
			local heroNums = heroVoApi and SizeOfTable(heroVoApi:getHonoredHeroList()) or 0
			dataTb = {heroPower,heroNums,rtd}

			if descIdx then
				table.insert(dataTb,descIdx)
			end
			self.dataTb[tabIdx] = dataTb

			if callback then
				callback(dataTb)
			end
		end 
		heroEquipVoApi:equipGet(heroDataHandle)
	elseif tabIdx == 3 then--配件 -- a128 > 全是红配  4的倍数 全是橙配
		local function getAccessoryDataHandle(redA_num,orgA_num,allAccessoryPowers)
			dataTb = {redA_num,orgA_num,allAccessoryPowers,rtd}
			if descIdx then
				table.insert(dataTb,descIdx)
			end
			self.dataTb[tabIdx] = dataTb
			if callback then
				callback(dataTb)
			end
		end
		accessoryVoApi:getCurUsedData(getAccessoryDataHandle)
	elseif tabIdx == 4 then--矩阵
		local function getArmorMatrixDataHandle( )
			for i=5,4,-1 do
				local nums = armorMatrixVoApi:getUsedQualityNum(i , true)
				table.insert(dataTb,nums)
			end
			local allLevels = armorMatrixVoApi:getUsedQualityAllLevel()
			table.insert(dataTb,allLevels)
			table.insert(dataTb,rtd)
			table.insert(dataTb,descIdx)
			self.dataTb[tabIdx] = dataTb
			if callback then
				callback(dataTb)
			end
		end 
		armorMatrixVoApi:armorGetData(getArmorMatrixDataHandle)
	elseif tabIdx == 5 then--超级武器
		local function getSuperWeaponDataHandle( )
			local weapon, crystal = superWeaponVoApi:getWeaponAndCrystalLevels( )
			dataTb = {crystal or 0,weapon or 0,rtd}	
			if descIdx then
				table.insert(dataTb,descIdx)
			end
			self.dataTb[tabIdx] = dataTb
			if callback then
				callback(dataTb)
			end
		end
		superWeaponVoApi:init(getSuperWeaponDataHandle)
	elseif tabIdx == 6 then--军徽
		local troopPower,yellowEmblemNums = 0,0
		if emblemVoApi and emblemVoApi.equipList then
			for k,v in pairs(emblemVoApi.equipList) do
				if v.cfg.color == 5 then
					for m,n in pairs(v) do
						if m == "num" then
							yellowEmblemNums = yellowEmblemNums + n
						end
					end
				end
			end
		end
		if emblemTroopVoApi and emblemTroopVoApi.emblemTroopList then
			for k,v in pairs(emblemTroopVoApi.emblemTroopList) do
				if v.getTroopStrength then
					troopPower = troopPower + v:getTroopStrength()
				end
			end
		end
		dataTb = {yellowEmblemNums,troopPower,rtd}
	elseif tabIdx == 7 then--战机
		local function getPlaneSkillDataHandle( )
			local nums2,nums1,allPowers = planeVoApi:getSkillNumsAndPlanePower()
			dataTb = {nums2,nums1,allPowers,rtd}
			if descIdx then
				table.insert(dataTb,descIdx)
			end
			self.dataTb[tabIdx] = dataTb
			if callback then
				callback(dataTb)
			end
		end 
		planeVoApi:planeGet(getPlaneSkillDataHandle)

		
	elseif tabIdx == 8 then--基地装扮
		local buildingExterNums = 0
		local skinNums = tankSkinVoApi:getCurSkinListNum()
		local headFrameNums = playerVoApi:getUnLockHeadFrameNums( )
		if buildDecorateVoApi and buildDecorateVoApi.hasSkinTb then
			-- print("SizeOfTable(buildDecorateVoApi.hasSkinTb)-====>>>",SizeOfTable(buildDecorateVoApi.hasSkinTb))
			for k,v in pairs(buildDecorateVoApi.hasSkinTb) do
				-- for kk,vv in pairs(v) do
				-- 	print(kk,vv)
				-- end

				if v.endTimer == 0 then
					buildingExterNums = buildingExterNums + 1
				end
			end
		end
		local newUnlockTb=playerVoApi:getNewUnlockTb(self.selectedTabBtnIndex)
		local unLockData=playerVoApi:getUnLockData(self.selectedTabBtnIndex)

		dataTb = {buildingExterNums,skinNums,headFrameNums}
	end

	if tabIdx ~= 3 and tabIdx ~= 4 and tabIdx ~= 2 and tabIdx ~= 5 and tabIdx ~= 7 then
		if descIdx then
			table.insert(dataTb,descIdx)
		end
		-- print("tabIdx====>>",tabIdx,SizeOfTable(dataTb))
		-- for k,v in pairs(dataTb) do
		-- 	print(k,v)
		-- end
		self.dataTb[tabIdx] = dataTb
		return dataTb
	end
end

function acZncfVoApi:getCurDesc(tabIdx,pageDesc,pageBg,tvHadDataTv)

	if  ( tabIdx > 1 and tabIdx < 6 ) or tabIdx == 7 then
		local function callback(dataTb)
			if pageDesc then
				if tvHadDataTv then
					tvHadDataTv[tabIdx] = true
				end
				if tabIdx == 2 or tabIdx == 5 then
					pageDesc:setString(getlocal("activity_zncf_sTab"..tabIdx,{dataTb[1],dataTb[2],dataTb[3],getlocal("activity_zncf_sub_s"..dataTb[4])}))
				elseif tabIdx == 7 then
					pageDesc:setString(getlocal("activity_zncf_sTab7",{dataTb[1],dataTb[2],FormatNumber(dataTb[3]),dataTb[4],getlocal("activity_zncf_sub_s"..dataTb[5])}))
				else
					pageDesc:setString(getlocal("activity_zncf_sTab"..tabIdx,{dataTb[1],dataTb[2],dataTb[3],dataTb[4],getlocal("activity_zncf_sub_s"..dataTb[5])}))
				end
				if pageBg then
					pageBg:setContentSize(CCSizeMake(pageDesc:getContentSize().width,pageDesc:getContentSize().height))
				end
			end
		end 
		self:getDataByTab(tabIdx,callback)
		do return end
	end
	local dataTb = self:getDataByTab(tabIdx)
	if tabIdx == 1 then
		pageDesc:setString(getlocal("activity_zncf_sTab1",{dataTb[1],dataTb[2],dataTb[3],dataTb[4]}))
	elseif tabIdx == 6 then
		pageDesc:setString(getlocal("activity_zncf_sTab"..tabIdx,{dataTb[1],dataTb[2],dataTb[3],getlocal("activity_zncf_sub_s"..dataTb[4])}))
	elseif tabIdx == 8 then
		pageDesc:setString(getlocal("activity_zncf_sTab8",{dataTb[1],dataTb[2],dataTb[3]}))
	end
	if pageBg then
		pageBg:setContentSize(CCSizeMake(pageDesc:getContentSize().width,pageDesc:getContentSize().height))
	end
	if tvHadDataTv then
		tvHadDataTv[tabIdx] = true
	end
end

function acZncfVoApi:getrewardList( )
	local vo = self:getAcVo()
	if vo and vo.rewardList then
		return SizeOfTable(vo.rewardList)
	end
	return 8
end

function acZncfVoApi:setCurRewardIdx(showPageIndex)
	self.showPageIndex = showPageIndex
end

function acZncfVoApi:getCurRewardIdx()
	if not self.showPageIndex then
		self.showPageIndex = 1
	end
	return self.showPageIndex
end

function acZncfVoApi:getCurRewardIdxTvRewardAndNum( )
	local vo = self:getAcVo()
	local showPageIndex = self:getCurRewardIdx()
	return SizeOfTable(vo.rewardList[showPageIndex]),vo.rewardList[showPageIndex]
end

function acZncfVoApi:getCurCellRewardData(idx)
	local vo = self:getAcVo()
	local rNum,curTvRewardData = self:getCurRewardIdxTvRewardAndNum()
	-- print("idx====>>>",idx,curTvRewardData[idx])
	local rewardTb = FormatItem(curTvRewardData[idx].reward, nil, true)
	return SizeOfTable(rewardTb),rewardTb
end

function acZncfVoApi:getCurCellDesc(cellIdx)
	local isCanReward = false
	if not self.dataTb[self.showPageIndex] or SizeOfTable(self.dataTb[self.showPageIndex]) == 0 then--数据没有回来，什么也做不了
		return "",isCanReward
	end

	local vo = self:getAcVo()
	local rList = vo.rewardList[self.showPageIndex][cellIdx]
	local rType = rList.type
	local curCellUseData = self.dataTb[self.showPageIndex]
	if self.showPageIndex == 1 then
		local showNum = rList.value1 > 10000 and FormatNumber(rList.value1) or rList.value1
		local addStr = ""
		if rList.type == 1 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{curCellUseData[2] ,rList.value1})
			isCanReward = rList.value1 <= curCellUseData[2] and true or isCanReward
		elseif rList.type == 2 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{FormatNumber(curCellUseData[3]) ,showNum})
			isCanReward = rList.value1 <= curCellUseData[3] and true or isCanReward
		end
		return getlocal("activity_zncf_cell1_"..rType,{showNum})..addStr,isCanReward
	elseif self.showPageIndex == 2 then
		local addStr = ""
		if rList.type == 1 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{curCellUseData[2] ,rList.value1})
			isCanReward = rList.value1 <= curCellUseData[2] and true or isCanReward
		elseif rList.type == 2 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{heroEquipVoApi:getAllEquipFightPower() ,rList.value1})
			isCanReward = rList.value1 <= heroEquipVoApi:getAllEquipFightPower() and true or false
		end
		return getlocal("activity_zncf_cell2_"..rType,{rList.value1})..addStr,isCanReward
	elseif self.showPageIndex == 3 then
		local subDesc = ""
		local addStr = ""
		if rList.type == 1 then
			local hasNum = rList.value2 == 4 and curCellUseData[2] + curCellUseData[1] or curCellUseData[1]
			subDesc = rList.value2 == 4 and getlocal("armorMatrix_color_5") or getlocal("redTitle")
			addStr = getlocal("super_weapon_challenge_troops_schedule",{hasNum ,rList.value1})
			if rList.value1 <= hasNum then
				isCanReward = true
			end
		elseif rList.type == 2 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{curCellUseData[3] ,rList.value1})
			isCanReward = rList.value1 <= curCellUseData[3] and true or isCanReward
		end
		return getlocal("activity_zncf_cell3_"..rType,{rList.value1,subDesc})..addStr,isCanReward
	elseif self.showPageIndex == 4 then
		local subDesc = ""
		local addStr = ""
		if rList.type == 1 then
			local hasNum = rList.value2 == 4 and curCellUseData[2] + curCellUseData[1] or curCellUseData[1]
			subDesc = rList.value2 == 4 and getlocal("armorMatrix_color_4") or getlocal("armorMatrix_color_5")
			addStr = getlocal("super_weapon_challenge_troops_schedule",{hasNum ,rList.value1})
			if rList.value1 <= hasNum then
				isCanReward = true
			end
		elseif rList.type == 2 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{curCellUseData[3] ,rList.value1})
			isCanReward = rList.value1 <= curCellUseData[3] and true or isCanReward
		end
		return getlocal("activity_zncf_cell4_"..rType,{rList.value1,subDesc})..addStr,isCanReward
	elseif self.showPageIndex == 5 then
		local addStr = ""
		if rList.type == 1 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{curCellUseData[2] ,rList.value1})
			isCanReward = rList.value1 <= curCellUseData[2] and true or isCanReward
		elseif rList.type == 2 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{curCellUseData[1] ,rList.value1})
			isCanReward = rList.value1 <= curCellUseData[1] and true or isCanReward
		end
		return getlocal("activity_zncf_cell5_"..rType,{rList.value1})..addStr,isCanReward
	elseif self.showPageIndex == 6 then
		local subDesc = getlocal("armorMatrix_color_5")
		local addStr = ""
		if rList.type == 1 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{curCellUseData[1] ,rList.value1})
			isCanReward = rList.value1 <= curCellUseData[1] and true or isCanReward
		elseif rList.type == 2 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{curCellUseData[2] ,rList.value1})
			isCanReward = rList.value1 <= curCellUseData[2] and true or isCanReward
		end
		return getlocal("activity_zncf_cell6_"..rType,{rList.value1,subDesc})..addStr,isCanReward
	elseif self.showPageIndex == 7 then
		local subDesc = ""
		local addStr = ""
		if rList.type == 1 then
			local hasNum = rList.value2 == 4 and curCellUseData[2] + curCellUseData[1] or curCellUseData[1]
			subDesc = rList.value2 == 4 and getlocal("armorMatrix_color_4") or getlocal("armorMatrix_color_5")
			addStr = getlocal("super_weapon_challenge_troops_schedule",{hasNum ,rList.value1})
			if rList.value1 <= hasNum then
				isCanReward = true
			end
		elseif rList.type == 2 then
			addStr = getlocal("super_weapon_challenge_troops_schedule",{curCellUseData[3] ,rList.value1})
			isCanReward = rList.value1 <= curCellUseData[3] and true or isCanReward
		end
		return getlocal("activity_zncf_cell7_"..rType,{rList.value1,subDesc})..addStr,isCanReward
	elseif self.showPageIndex == 8 then
		local addStr = getlocal("super_weapon_challenge_troops_schedule",{curCellUseData[1] + curCellUseData[2] + curCellUseData[3] ,rList.value1})
		local curHadNum = curCellUseData[1] + curCellUseData[2] + curCellUseData[3]
		if rList.value1 <= curHadNum then
			isCanReward = true
		end
		return getlocal("activity_zncf_cell8_"..rType,{rList.value1})..addStr,isCanReward
	end
end
function acZncfVoApi:rewardSocket(callback,tid)
	local sid = self.showPageIndex
	local function handler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.zncf then
                self:updateData(sData.data.zncf)
                if callback then
                    callback()
                end
            end
            if sData and sData.data and sData.data.accessory then
  				accessoryVoApi:onRefreshData(sData.data.accessory)
  			end
        end
    end
	socketHelper:acZncfTaskRequest(handler,sid,tid)
end

function acZncfVoApi:getTaskRewardState(taskIdx)
	local vo = self:getAcVo()
	if vo and vo.rdb == nil then--任务领取表是空，标示一个奖励都没有领取过
		return false
	elseif vo.rdb[self.showPageIndex] then
		for k,v in pairs(vo.rdb[self.showPageIndex]) do
			if v == taskIdx then
				return true
			end
		end
	end
	return false
end
function acZncfVoApi:readySendCurDataWithChat(layerNum,willShareStr)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
    local titleStr = getlocal("alliance_send_report")
    local needTb = {"zncf",titleStr,willShareStr}
    local sd = acThrivingSmallDialog:new(layerNum,needTb)
    sd:init()
end