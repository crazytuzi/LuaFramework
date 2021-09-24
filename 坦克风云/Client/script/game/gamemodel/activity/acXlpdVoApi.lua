acXlpdVoApi = {
	name           = nil,
	editPdLevelNum = 1,
	chatStr        = nil,
	oldPdvTb       = {},
	pdvUpTb        = {},
	isNewData	   = false,
	needRefreshTeamData = false,
}
function acXlpdVoApi:clearAll()
	self.needRefreshTeamData = nil
	self.isNewData		= nil
	self.pdvUpTb        = {}
	self.oldPdv         = {}
	self.editPdLevelNum = nil
	self.name           = nil
	self.chatStr        = nil
end

function acXlpdVoApi:isNewDataGet(isNew)
	self.isNewData = isNew
end
function acXlpdVoApi:getIsNewDataGet( )
	return self.isNewData
end

function acXlpdVoApi:getAcVo(activeName)
    if activeName == nil then
        activeName = self:getActiveName()
    end
    return activityVoApi:getActivityVo(activeName)
end

function acXlpdVoApi:setActiveName(name)
    self.name = name
end

function acXlpdVoApi:getActiveName()
    return self.name or "xlpd"
end

function acXlpdVoApi:getLimit()
	local vo=self:getAcVo()
	if vo and vo.openLv then
		return vo.openLv
	end
	return 0
end

function acXlpdVoApi:getTimer()--倒计时 需要时时显示
    local vo = self:getAcVo()
    local str = ""
    if vo then
        str = getlocal("activityCountdown") .. ":"..G_formatActiveDate(vo.et - base.serverTime)
    end
    return str
end

function acXlpdVoApi:canReward()
    if self:changeSaveOldPdLevel( ) then
    	return true
    else
    	local pdLevelData = self:returnCurlPdLevelWithAnyData()
    	local thisPdLevel  = pdLevelData[7]
		local teamNum      = self:getTeamNum( )
		local per          = self:getPer(thisPdLevel)
		local taskNum,gBox = self:getgBoxNum( )
		for i=1,taskNum do
			local awardType = self:everyBoxAwardType(i,gBox[i],thisPdLevel)
			if awardType == 1 then
				return true
			end
		end
    end
    return false
end

function acXlpdVoApi:isEnd()
    local vo = self:getAcVo()
    if vo and base.serverTime < vo.et then
        return false
    end
    return true
end

function acXlpdVoApi:isToday()
    local isToday = false
    local vo = self:getAcVo()
    if vo and vo.lastTime then
        isToday = G_isToday(vo.lastTime)
    end
    return isToday
end

function acXlpdVoApi:setTodayTick()
    local vo = self:getAcVo()
    if vo and vo.lastTime then
        vo.lastTime = base.serverTime
    end
end
function acXlpdVoApi:getFirstFree()--免费标签
    local vo = self:getAcVo()
    if vo and vo.firstFree then
        return vo.firstFree
    end
    return 1
end
function acXlpdVoApi:setFirstFree(newfree)
    local vo = self:getAcVo()
    if vo and vo.firstFree then
        vo.firstFree = newfree
    end
end
function acXlpdVoApi:addActivieIcon()
    spriteController:addPlist("public/activeCommonImage3.plist")
    spriteController:addTexture("public/activeCommonImage3.png")
end
function acXlpdVoApi:removeActivieIcon()
    spriteController:removePlist("public/activeCommonImage3.plist")
    spriteController:removeTexture("public/activeCommonImage3.png")
end

function acXlpdVoApi:updateSpecialData(data)
    local vo = self:getAcVo()
    if vo then
        vo:updateSpecialData(data)
    end
end
function acXlpdVoApi:updateData(data)
    local vo = self:getAcVo()
    vo:updateData(data)
    activityVoApi:updateShowState(vo)
end

function acXlpdVoApi:getAcNameAndDesc()
    local itemData = {}
    itemData.name = getlocal("activity_xlpd_coinName")
    itemData.desc = "activity_xlpd_coinDesc"
    itemData.pic = "pdCoin.png"
    itemData.bgname = "Icon_BG.png"
    return itemData
end

function acXlpdVoApi:getTip(layerNum, tipType)
	local vo = self:getAcVo()
    local tabStr = "activity_xlpd_tabOneTip"
    local tabNum = 6
    local insert1,insert2,insert3
    local useT = 3600
    if tipType == "tabTwo" then
        tabStr = "activity_xlpd_tabTwoTip"
        tabNum = 8

        insert1 = vo.activeCfg.tTime[1] / useT
    	insert2 = vo.activeCfg.tTime[2] / useT
    	insert3 = vo.activeCfg.tc
    else
    	insert1 = vo.activeCfg.Pktime[1] / useT
    	insert2 = vo.activeCfg.Pktime[2] / useT
    end
    
    local tabStrTb = {}
    for i = 1, tabNum do
    	if tipType == "tabOne" then
    		if i == 5 then
    			table.insert(tabStrTb, getlocal(tabStr..i,{insert1,insert2}))
    		else
    			table.insert(tabStrTb, getlocal(tabStr..i))
    		end
    	elseif tipType == "tabTwo" then
    		if i == 4 then
    			table.insert(tabStrTb, getlocal(tabStr..i,{insert3}))
    		elseif i == 5 then
    			table.insert(tabStrTb, getlocal(tabStr..i,{insert1,insert2}))
    		else
    			table.insert(tabStrTb, getlocal(tabStr..i))
    		end
    	end
    end
    local titleStr = getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum, true, true, nil, titleStr, tabStrTb, nil, 25)
end

function acXlpdVoApi:isCanJoinTeam()--当天是否还可以进入“攀登比拼”页签 如果是商店开启时间内 是可以进去的，
    if self:isShopOpen() then
        return true
    end
    --activity_xlpd_canNotJoinTeam
    local curZero = tostring(G_getWeeTs(base.serverTime))
    local vo = self:getAcVo()
    if vo and ( vo.teamTtb or not vo.teamTtb ) then
        if not vo.teamTtb or not vo.teamTtb[tostring(curZero)] then
            local teamTime = self:getActiveTimeCfg()
            local tab = G_getDate(base.serverTime)
            local curHour = tab.hour
            -- print("teamTime=====curHour=====??????>>>",teamTime,curHour)
            if teamTime > curHour then -- 组队截止时间 > 当前时间
                return true
            end
        elseif vo.teamTtb[tostring(curZero)] then
        	return true
        end
    end
    return false
end

function acXlpdVoApi:isHasTeam()--是否已有队伍
    local curZero = tostring(G_getWeeTs(base.serverTime))
    local vo = self:getAcVo()
    if vo and vo.teamTtb then
        if vo.teamTtb[tostring(curZero)] then
            return true
        end
    end
    return false
end

-----------------------------  我 的 队 伍 面 板（myTeam）-----------------------------

function acXlpdVoApi:getMyTeamInfo()
    local vo = self:getAcVo()
    local teamPdValue = 0
    local selfUid = playerVoApi:getUid()
    local selfTeam = {}
    
    if vo and vo.teams and next(vo.teams) then
        for i = 1, 2 do
            for m, n in pairs(vo.teams[i]) do
                if n[1] == selfUid then
                    selfTeam = vo.teams[i]
                    do break end
                end
            end
        end
    end
    if not next(selfTeam) then
        print("===== e r r o r  getMyTeamInfo  e r r o r =====")
    else
        for k, v in pairs(selfTeam) do
            teamPdValue = teamPdValue + v[5]
        end
    end
    return selfTeam, teamPdValue
end

function acXlpdVoApi:showMyTeamPanel(layerNum, refreshHandle)
    local myTeam, teamPdValue = self:getMyTeamInfo()
    local needTb = {"xlpdMyTeam", getlocal("myTeam"), teamPdValue, myTeam, refreshHandle}
    G_showCustomizeSmallDialog(layerNum, needTb)
end

function acXlpdVoApi:getCurIspool()--自由组队状态 1 已开启 0 未开启
    local vo = self:getAcVo()
    if vo.ispoolTb and SizeOfTable(vo.ispoolTb) > 1 then
    	local teamIdx = self:getCurMyTeamIdx()
    	if teamIdx then
    		vo.ispool = vo.ispoolTb[teamIdx]
    		return vo.ispoolTb[teamIdx]
    	end
   	elseif vo.ispool then
        return vo.ispool
    end
    return 0
end

function acXlpdVoApi:getCurMyTeamIdx()
	local uid = playerVoApi:getUid()
	local vo = self:getAcVo()
	if vo and vo.teams then
		for teamIdx,team in pairs(vo.teams) do
	        for k, v in pairs(team) do
	            if v[1] and tonumber(v[1]) == uid then
	                return teamIdx
	            end
	        end
	    end
	end
	print(" ================ e r r o r  ??? in getCurMyTeamIdx : is not has my team ??? ================ ")
	return nil
end

function acXlpdVoApi:socketRefreshIspool(callback)---是否允许自由进队
    local curIspool = self:getCurIspool()
    local function requestHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.xlpd then
                self:updateData(sData.data.xlpd)
            end
            if callback then
                callback()
            end
        end
    end
    local poolStatus = (curIspool == 1) and 0 or 1
    socketHelper:acXlpdSokcet(requestHandler, "pool", {pool = poolStatus})
end

function acXlpdVoApi:socketTeamJoin(callback)---一键组队
    local function requestHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.xlpd then
                self:updateData(sData.data.xlpd)
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:acXlpdSokcet(requestHandler, "match")
end

function acXlpdVoApi:formatFriendList()
    local vo = self:getAcVo()
    local fmtList = {}
    if vo and vo.flist then
        fmtList = G_clone(vo.flist)
        local function sortFunc(a, b)
            if a and b and a[4] and b[4] then
                return a[4] > b[4]
            end
        end
        table.sort(fmtList, sortFunc)
    end
    return fmtList
end

function acXlpdVoApi:socketGetFriendList(callback)
    local function requestHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.xlpd then
                self:updateData(sData.data.xlpd)
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:acXlpdSokcet(requestHandler, "getflist")
end

-----------------------------  邀请 面 板（invite）-----------------------------
function acXlpdVoApi:isCanBeInviteType(lastInviteT)--teamsTimeCDStr
    if not lastInviteT or lastInviteT + 300 < base.serverTime then
        return true
    else
        return getlocal("teamsTimeCDStr")..":"..G_formatActiveDate(lastInviteT + 300 - base.serverTime)
    end
end

function acXlpdVoApi:showInvitePanel(layerNum, parent)
    local fmtList = acXlpdVoApi:formatFriendList()
    local selfTeam = acXlpdVoApi:getMyTeamInfo()
    local needTb = {"xlpdInvite", getlocal("InviteTeammates"), parent, fmtList, selfTeam}
    G_showCustomizeSmallDialog(layerNum, needTb)
end

function acXlpdVoApi:socketInviteFriend(callback, fid,frData)
	-------------广播 个人邀请数据
    -- print("广播 个人邀请数据 的调用", frData[1],frData[2] )
    local team = self:getChatNeedInfo(true)
    local flag = self:dispatchInvite(team, {uid = frData[1], name = frData[2]}, 0)
    print("flag======>>>>",flag)
    if flag then
	    local function requestHandler(fn, data)
	        local ret, sData = base:checkServerData(data)
	        if ret == true then
	            if sData and sData.data and sData.data.xlpd then
	                self:updateData(sData.data.xlpd)
	            end

	            if callback then
	                callback()
	            end
	        end
	    end
	    socketHelper:acXlpdSokcet(requestHandler, "invite", {fid = fid})
	end
end

function acXlpdVoApi:setEditPdLevelNum(newNum )
	self.editPdLevelNum = newNum
end
function acXlpdVoApi:getEditPdLevelNum( )
	return self.editPdLevelNum or 1
end

function acXlpdVoApi:getPostTime()
	local oldPostTime = tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey(playerVoApi:getUid().."xlpdInviteTime"))
	local vo = self:getAcVo()
	-- print("oldPostTime==>>",oldPostTime,base.serverTime)
	if oldPostTime > 0 then
		local takeTime = base.serverTime - oldPostTime
		local lastTime = vo.activeCfg.jt - takeTime
		local str = getlocal("postNextTime",{G_formatActiveDate(lastTime)})
		if lastTime > 0 then
			return true ,str
		end
	end
	return false
end
function acXlpdVoApi:flushPostTime(newT)
	CCUserDefault:sharedUserDefault():setIntegerForKey(playerVoApi:getUid().."xlpdInviteTime", newT)
    CCUserDefault:sharedUserDefault():flush()
end
----------------------------- l o g -----------------------------

function acXlpdVoApi:socketLog(callback)
    local curZero = G_getWeeTs(base.serverTime)
    local curStatus = self:getStatus()
    local function requestHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            local log, pklog = {}, {}
            if sData.data then --日志
                ---是否需要格式化 Log ~~~~~~
                if sData.data.log then
                    log = sData.data.log[1] or {}
                end
                if sData.data.pklog then
                    -- pklog = sData.data.pklog
                    local idx = 1
                    for k,v in pairs(sData.data.pklog) do
                        if curStatus ~= 5 and v[4] and G_getWeeTs(tonumber(v[4])) == curZero then
                        else
                            pklog[idx] = v
                            idx = idx + 1
                        end
                    end
                    local function sortFunc(a, b)
                        if a and b and a[4] and b[4] then
                            return a[4] > b[4]
                        end
                    end
                    table.sort(pklog, sortFunc)

                end
            end
            if callback then
                callback(log, pklog)
            end
        end
    end
    socketHelper:acXlpdSokcet(requestHandler, "getlog")
end
function acXlpdVoApi:getElevation(pdvalue)
    local vo = self:getAcVo()
    if vo and vo.activeCfg then
        return math.ceil(vo.activeCfg.hNum * pdvalue)
    end
    return 0
end
----------------------------- 攀 登 商 店 -----------------------------
function acXlpdVoApi:getShopCellNum()
    local vo = self:getAcVo()
    if vo and vo.activeCfg.exShop then
        return SizeOfTable(vo.activeCfg.exShop)
    end
    return 0
end
function acXlpdVoApi:getcurShopData()
    if true then--self:isShopOpen() then
        return self:formatExchangeShop()
    else
        return self:getNotOpenShopData()
    end
end

function acXlpdVoApi:getNotOpenShopData()
    local vo = self:getAcVo()
    if vo and vo.activeCfg.exShop then
        return vo.activeCfg.exShop
    end
    return {}
end

function acXlpdVoApi:getCurCoin()
    local vo = self:getAcVo()
    if vo and vo.pdCoin then
        return vo.pdCoin
    end
    return 0
end

function acXlpdVoApi:getExchangedTb()
    local vo = self:getAcVo()
    if vo and vo.exchangedTb then-- "s1":2
        return vo.exchangedTb
    end
    return {}
end

function acXlpdVoApi:formatExchangeShop()
    local curGold = playerVoApi:getGems()
    local vo = self:getAcVo()
    local curCoin = self:getCurCoin()
    local exchangedTb = self:getExchangedTb()
    local exShop, formatShop = self:getNotOpenShopData(), {}
    local canExTb, noCanExTb, exEndTb = {}, {}, {}
    
    for k, v in pairs(exShop) do --v.exType: 1 可兑换，2 无能力对话 3 已兑换 ;nil :未开启
        if v.type == 1 then--金币
            if exchangedTb["s"..v.id] and exchangedTb["s"..v.id] >= v.max then
                v.exType = 3
                v.curExNum = v.max
                table.insert(exEndTb, v)
            elseif curGold < v.cost then
                v.exType = 2
                v.curExNum = exchangedTb["s"..v.id] or 0
                table.insert(noCanExTb, v)
            else
                v.exType = 1
                v.curExNum = exchangedTb["s"..v.id] or 0
                table.insert(canExTb, v)
            end
        elseif v.type == 2 then --攀登币
            if exchangedTb["s"..v.id] and exchangedTb["s"..v.id] >= v.max then
                v.exType = 3
                v.curExNum = v.max
                table.insert(exEndTb, v)
            elseif curCoin < v.cost then
                v.exType = 2
                v.curExNum = exchangedTb["s"..v.id] or  0
                table.insert(noCanExTb, v)
            else
                v.exType = 1
                v.curExNum = exchangedTb["s"..v.id] or 0
                table.insert(canExTb, v)
            end
        end
    end
    for k, v in pairs(canExTb) do
        table.insert(formatShop, v)
    end
    for k, v in pairs(noCanExTb) do
        table.insert(formatShop, v)
    end
    for k, v in pairs(exEndTb) do
        table.insert(formatShop, v)
    end
    return formatShop
end

function acXlpdVoApi:isShopOpen()
    -- do return true end
    local vo = self:getAcVo()
    local shopUseTime = 86400
    if vo and vo.sd then
        shopUseTime = shopUseTime * vo.sd
    end
    -- print("vo.et--->>>",vo.et)
    if vo.et then
        return vo.et - shopUseTime < base.serverTime
    end
    return false
end

function acXlpdVoApi:getShopTime(isOutSide)
    -- local isOpen = self:isShopOpen()
    local vo = self:getAcVo()
    -- if not isOpen then
    --     if not isOutSide then
    --         return getlocal("shopIsNotOpen")
    --     else
    --         local shopUseTime = 86400
    --         if vo and vo.sd then
    --             shopUseTime = shopUseTime * vo.sd
    --         end
    --         return getlocal("exchangeStartCountDown") .. ":"..G_formatActiveDate(vo.et - base.serverTime - shopUseTime)
    --     end
    -- else--shopCountDown
    --     return getlocal("exchangeEndCountDown") .. ":"..G_formatActiveDate(vo.et - base.serverTime)
    -- end

    if isOutSide then
        if self:isShopOpen() then
            return getlocal("activity_xlpd_acIsOver")
        else
            return getlocal("activity_xlpd_acWillOver") .. ":"..G_formatActiveDate(vo.et - base.serverTime - 86400)
        end
    else
        return getlocal("exchangeEndCountDown") .. ":"..G_formatActiveDate(vo.et - base.serverTime)
    end

end

function acXlpdVoApi:getShopTip(layerNum)
    local tabStr = {}
    for i = 1, 2 do
        table.insert(tabStr, getlocal("activity_xlpd_shopTip"..i))
    end
    local titleStr = getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum, true, true, nil, titleStr, tabStr, nil, 25)
end

----------------------------- t a b O n e -----------------------------

function acXlpdVoApi:getCoinExp()--返回当前攀登经验
    local vo = self:getAcVo()
    if vo and vo.coinExp then
        return vo.coinExp
    end
    return 0
end

function acXlpdVoApi:returnCurlPdLevelWithAnyData()--返回攀登当前 以及下一级 的攀登值，攀登币 攀登经验
    local vo = self:getAcVo()
    local curCoinExp = self:getCoinExp()
    local gradeTb =  vo.activeCfg and vo.activeCfg.grade or {}
    local thisPdValue, thisPdLevel, thisPdCoin, nextPdValue, nextPdCoin, nextCoinExp = 0, 0, 0, 0, 0, 0
    local nExpNum = 0
    -- local nCoinNum = 0
    -- print("curCoinExp=---->>>>",curCoinExp)
    for k, v in pairs(gradeTb) do
    	-- nCoinNum = nCoinNum + v.coin
    	nExpNum  = nExpNum + v.exp
        if nExpNum <= curCoinExp and ((gradeTb[k + 1] and gradeTb[k + 1].exp + nExpNum > curCoinExp) or not gradeTb[k + 1]) then
        	
			thisPdValue = v.hNum
			thisPdCoin  = v.coin
			thisPdLevel = k
			thisCoinExp = curCoinExp - nExpNum
            -- or : 满级情况
            nextPdValue = gradeTb[k + 1] and gradeTb[k + 1].hNum or getlocal("itsEnough")
            nextPdCoin = gradeTb[k + 1] and gradeTb[k + 1].coin or getlocal("itsEnough")
            nextCoinExp = gradeTb[k + 1] and gradeTb[k + 1].exp or  nil
            -- print("k====>>>",k, v.exp, nExpNum, gradeTb[k + 1].exp, gradeTb[k + 1].exp + nExpNum)
        elseif k == 1 and nExpNum > curCoinExp then
            thisPdValue = 0
            thisPdCoin = 0
            thisPdLevel = 0
            thisCoinExp = curCoinExp
            
            nextPdValue = v.hNum
            nextPdCoin = v.coin
            nextCoinExp = nExpNum
        end
    end
    -- print("curCoinExp=====>>>",curCoinExp)
    ---- 1 这级攀登值 2 下级攀登值， 3 这级攀登币4 下级攀登值，5 这级攀登经验,6 下级攀登经验 7 这级攀登 等级
    return {thisPdValue, nextPdValue, thisPdCoin, nextPdCoin, thisCoinExp, nextCoinExp, thisPdLevel}
end

function acXlpdVoApi:getGradeTbData()
    local vo = self:getAcVo()
    if vo and vo.activeCfg and vo.activeCfg.grade then
        return vo.activeCfg.grade, SizeOfTable(vo.activeCfg.grade)
    end
    print "===== e r r o r  getGradeTbData  e r r o r ====="
    return {}, 50
end

function acXlpdVoApi:getPer(curValue)
    local orData = self:getGradeTbData()
    local costTb = {}
    for k, v in pairs(orData) do
        costTb[k] = k
    end
    if not next(costTb) then
    	return 0
    end
    local per = G_getPercentage(curValue, costTb)
    return per
end

function acXlpdVoApi:getgBoxNum()
    local vo = self:getAcVo()
    if vo and vo.activeCfg and vo.activeCfg.gBox then
        return SizeOfTable(vo.activeCfg.gBox), vo.activeCfg.gBox
    end
    print "===== e r r o r  getgBoxNum  e r r o r ====="
    return 5, {}
end

function acXlpdVoApi:getgBoxIndexWithAward(idx)
    local vo = self:getAcVo()
    if vo and vo.activeCfg.gBox then
        local award = FormatItem(vo.activeCfg.gBox[idx].r, nil, true)
        -- print("gBox award====num>>>>", SizeOfTable(award))
        return award
    end
    return {}
end

function acXlpdVoApi:getCurBoxTaskType(idx)
    local vo = self:getAcVo()
    if vo and vo.bxTaskedTb then
        for k,v in pairs(vo.bxTaskedTb) do
            if v == idx then
                return v 
            end
        end

        -- return vo.bxTaskedTb[idx] or nil
    end
    return nil
end

function acXlpdVoApi:getTeamNum()
    local vo = self:getAcVo()
    if vo and vo.teamNum then
        return vo.teamNum
    end
    return 0
end

function acXlpdVoApi:setTeamNum(newNum)
	local vo = self:getAcVo()
	if vo and vo.teamNum then
		vo.teamNum = newNum
	end
end

function acXlpdVoApi:getChngeNum()
    local vo = self:getAcVo()
    if vo and vo.chngeNum then
        return vo.chngeNum
    end
    return 0
end

function acXlpdVoApi:setChngeNum(newNum)
	local vo = self:getAcVo()
	if vo and vo.chngeNum then
		vo.chngeNum = newNum
	end
end

function acXlpdVoApi:getTodayLastChngeNum( )--剩余更换队伍的次数
	local vo = self:getAcVo()
	local curChngeNum = self:getChngeNum()
	if vo and vo.activeCfg and vo.activeCfg.tc then
		return vo.activeCfg.tc - curChngeNum
	end
	return 0
end

function acXlpdVoApi:everyBoxAwardType(idx, gBoxTb, thisPdLevel)
	if gBoxTb and next(gBoxTb) then
	    local taskG = gBoxTb.g
	    local taskTeamLim = gBoxTb.lim
	    -- print("thisPdLevel >= taskG and self:getTeamNum() >= taskTeamLim===>>>",idx, thisPdLevel , taskG , self:getTeamNum() , taskTeamLim)
	    if thisPdLevel >= taskG and self:getTeamNum() >= taskTeamLim then
	        if self:getCurBoxTaskType(idx) then
	            return 2 --已领
	        else
	            return 1--可领
	        end
	    end
	end
    return 0
end

function acXlpdVoApi:socketgBoxAward(socketCallBack, tid, award)
    local params = {tid = tid}
    local addCmd = "task"
    local function callback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.xlpd then
                self:updateData(sData.data.xlpd)
            end
            if socketCallBack then
                socketCallBack()
            end
        end
    end
    socketHelper:acXlpdSokcet(callback, addCmd, params)
end

function acXlpdVoApi:getTaskTbData()
    local vo = self:getAcVo()
    if vo and vo.activeCfg.taskList then
        return vo.activeCfg.taskList, SizeOfTable(vo.activeCfg.taskList)
    end
    print "===== e r r o r  getTaskTbData  e r r o r ====="
    return {}, 0
end

function acXlpdVoApi:getTaskedTbFinshTime(idx)
    local vo = self:getAcVo()
    if vo and vo.taskedTb and next(vo.taskedTb) then
        if idx then
            return vo.taskedTb[idx][2] or 0
        else
            return vo.taskedTb
        end
    end
    return idx and 0 or nil
end

function acXlpdVoApi:getTaskedOneTime(idx)--返回当前任务 完成一次 对应的已完成具体数值
    local vo = self:getAcVo()
    if vo and vo.taskedTb then
        if vo.taskedTb[idx] then
        	return vo.taskedTb[idx][1] or 0
        end
    end
    return 0
end

-- function acXlpdVoApi:cleartaskedTb( )
-- 	local vo = self:getAcVo()
-- 	if vo and vo.taskedTb then
-- 		vo.taskedTb = {}
-- 	end
-- end
----------------------------- t a b T w o -----------------------------
-- 组队阶段：组队结束倒计时：XX:XX:XX
-- 等待匹配：PK开始倒计时：XX:XX:XX
-- 开始PK：比拼结算倒计时：XX:XX:XX

function acXlpdVoApi:getActiveTimeCfg()
    local vo = self:getAcVo()
    local teamTime, matchTime, pkTime = nil, nil, nil
    if vo and vo.activeCfg then
        teamTime = vo.activeCfg.tTime[2] / 3600 or nil
        matchTime = vo.activeCfg.Pktime[1] / 3600 or nil
        pkTime = vo.activeCfg.Pktime[2] / 3600 or nil
    end
    return teamTime, matchTime, pkTime
end

function acXlpdVoApi:getActiveTypeAndTime()
    if self:isEnd() then
        return nil
    elseif  self:isShopOpen() then
        return nil,"" 
    end
    local teamTime, matchTime, pkTime = self:getActiveTimeCfg()
    -- print("teamTime---matchTime---pkTime--->>>",teamTime,matchTime,pkTime)
    local tab = G_getDate(base.serverTime)
    -- print("tab.hour===>>>",tab.hour)
    local curHour = tab.hour
    local curZero = G_getWeeTs(base.serverTime)
    local useTime = 3600 * pkTime
    local tType = 5 -- pk时间
    if curHour < teamTime then--组队时间
        tType = 1
        useTime = 3600 * teamTime
    elseif curHour < matchTime then --匹配时间
        tType = 2
        useTime = 3600 * matchTime
    elseif curHour < pkTime then
    	tType = 3
    elseif curHour == pkTime and base.serverTime - curZero <= 300 + useTime then-- 5分钟 结算时间
    	tType = 4
    	useTime = 300 + useTime
    else
    	return tType,getlocal("activity_xlpd_tabTwoTime5")
    end
    return tType, getlocal("activity_xlpd_tabTwoTime"..tType) .. ":"..G_formatActiveDate(useTime - (base.serverTime - curZero))
end--活动关闭倒计时

--该活动请求接口，用action来区分接口
--sync：是否拉取数据显示loading页面
function acXlpdVoApi:xlpdRequest(action, params, callback, sync)
    local function requestHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.xlpd then
                self:updateData(sData.data.xlpd)
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:acXlpdSokcet(requestHandler, action, params, sync)
end

function acXlpdVoApi:chatSendJoinInfo()
	local params = {playerVoApi:getUid(),self:getTeams()}
    chatVoApi:sendUpdateMessage(61,params)
end
function acXlpdVoApi:refreshMyTeamInfoByMsg(newTeamInfo)
	local isIn = self:amIisInThisTeam(newTeamInfo)
	if isIn then
		self.needRefreshTeamData = true
	end
end

function acXlpdVoApi:getNeedRefreshTeamData( )
	return self.needRefreshTeamData
end
function acXlpdVoApi:setNeedRefreshTeamData()
	self.needRefreshTeamData = false
end
function acXlpdVoApi:amIisInThisTeam(teams)
	local myUid = playerVoApi:getUid()
	for k,v in pairs(teams) do
		for m,n in pairs(v) do
			if n[1] and tonumber(n[1]) == myUid then
				return true
			end
		end
	end
	return false
end

--自己的队伍信息
function acXlpdVoApi:getTeams()
    local vo = self:getAcVo()
    if vo and vo.teams then

        if self:isHasTeam() == false or next(vo.teams) == nil then --如果当天没有部队，但是有teams数据，则说明是跨天了需要清空一下
            vo.teams = {{}, {}, 0}
        end
        return vo.teams
    end
    return {{}, {}, 0}
end

function acXlpdVoApi:getMyTeamAnyInfo( )
	local vo = self:getAcVo()
	local uid = playerVoApi:getUid()
	local curZero = G_getWeeTs(base.serverTime)
	local teamId = nil
	local myTeam = {}
	local teamPd = 0
	local teamPn = 0
	local teamMax = 3
	local teamLeader = ""

	if vo and vo.teamTtb and vo.teamTtb[tostring(curZero)] then
		teamId = vo.teamTtb[tostring(curZero)][1]
	else
		print  " ========= e r r o r getMyTeams teamTtb ========= "
	end
    if vo and vo.teams then
    	for i = 1, 2 do
    		for m,n in pairs(vo.teams[i]) do
    			if n[1] and tonumber(n[1]) == uid then
	                myTeam = vo.teams[i]
	                do break end
	            end
    		end
    	end
    	for k,v in pairs(myTeam) do
    		teamPd = v[5] + teamPd --队伍的攀登值
    		if k == 1 then
    			teamLeader = v[2]
    		end
    	end
    	teamPn = SizeOfTable(myTeam)
    end
    return teamId, teamPd, teamPn, teamMax, teamLeader
end

function acXlpdVoApi:getChatNeedInfo(isSingle)--用于 世界 和 军团
	local teamId, teamPd, teamPn, teamMax, teamLeader = self:getMyTeamAnyInfo()
	local pdLv = isSingle and 0 or acXlpdVoApi:getEditPdLevelNum()
	local msg = isSingle and getlocal("xlpd_invite_note") or self:getInputText()

	return { tid = teamId, pd = teamPd, pn = teamPn, max= teamMax, pdLv = pdLv, leader = teamLeader, msg = msg}
end

function acXlpdVoApi:setInputText(newStr)
	self.chatStr = newStr
end
function acXlpdVoApi:getInputText( )
	return self.chatStr or getlocal("xlpd_invite_note")
end

--获取队伍的攀登值
function acXlpdVoApi:getTeamPdv(team,tIdx)
    local pdv = 0
    if team and type(team) == "table" and next(team) then
        for k = 1, 3 do
            local v = team[k] or {}
            pdv = pdv + (v[5] or 0)
        end
    end
    local vo = self:getAcVo()
    local curZero = G_getWeeTs(base.serverTime)
    local pdvKey = curZero..playerVoApi:getUid()..vo.st..vo.et..tIdx.."pdv"
    self.oldPdvTb[tIdx] = tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey(pdvKey))
    if not self.oldPdvTb[tIdx] or self.oldPdvTb[tIdx] < pdv then
    	self.oldPdvTb[tIdx] = pdv
    	CCUserDefault:sharedUserDefault():setIntegerForKey(pdvKey,pdv)
		CCUserDefault:sharedUserDefault():flush()
    	self.pdvUpTb[tIdx] = false
    end
    return pdv
end

function acXlpdVoApi:getPdvUpType( )
	return self.pdvUpTb
end
function acXlpdVoApi:setPdvUpType(tIdx)
	if self.pdvUpTb then
		self.pdvUpTb[tIdx] = true
	end
end
--根据攀登值换算攀登币
function acXlpdVoApi:getTeamPdCoin(pd, isWin, isTie)--isTie: 平局
    local vo = self:getAcVo()
    if vo and vo.activeCfg then
        return math.ceil((pd or 0) * vo.activeCfg.coin3 + ( ( isWin or isTie ) and vo.activeCfg.coin1 or vo.activeCfg.coin2))
    end
    -- local teams = self:getTeams()
    -- local teamData = isWin and ( teams[1] or {} ) or ( teams[2] or {} )
    -- local pdCoin = 0
    -- for k,v in pairs(teamData) do
    -- 	pdCoin = pdCoin + v[6] or 0
    -- end
    -- return pdCoin
end

--根据攀登值换算攀登高度
function acXlpdVoApi:getTeamPdHeight(pd)
    local vo = self:getAcVo()
    if vo and vo.activeCfg then
        return math.ceil((pd or 0) * vo.activeCfg.hNum)
    end
    return 0
end

function acXlpdVoApi:isMyTeam(team)
    local uid = playerVoApi:getUid()
    if team and type(team) == "table" and next(team) then
        for k, v in pairs(team) do
            if v[1] and tonumber(v[1]) == uid then
                return true
            end
        end
    end
    return false
end

--获取攀登状态 1：组队时间 2：匹配时间，3：pk阶段，4：pk结算
function acXlpdVoApi:getStatus()

    local vo = self:getAcVo()
    local weets = G_getWeeTs(base.serverTime)
    if base.serverTime <= (weets + vo.activeCfg.tTime[2]) then
        return 1
    elseif base.serverTime <= (weets + vo.activeCfg.Pktime[1]) then
        return 2
    elseif base.serverTime <= (weets + vo.activeCfg.Pktime[2]) then
        return 3
    elseif base.serverTime <= (weets + vo.activeCfg.Pktime[2] + 300) then
        return 4
    end
    return 5 --当天彻底结算完
end

--聊天发布组队邀请 team： 邀请的队伍
--uid：被邀请的好友uid，可以不传，不传为世界或军团发布邀请
--channel：聊天频道 2：军团 1：世界，0：私聊
function acXlpdVoApi:dispatchInvite(team, receiver, channel)
    if team == nil or next(team) == nil then
        return false
    end
    local allianceName
    local allianceRole
    if allianceVoApi:isHasAlliance() then
        local allianceVo = allianceVoApi:getSelfAlliance()
        allianceName = allianceVo.name
        allianceRole = allianceVo.role
    else
        if channel == 2 then
            G_showTipsDialog(getlocal("xlpd_noalliance_tip"))
            return false
        end
    end
    local language = G_getCurChoseLanguage()
    local subType = 1
    if channel == 0 then
        subType = 2
    elseif channel > 1 then
        subType = 3
    end
    local sender = playerVoApi:getUid()
    local senderName = tostring(playerVoApi:getPlayerName())
    local level = playerVoApi:getPlayerLevel()
    local rank = playerVoApi:getRank()
    local power = playerVoApi:getPlayerPower()
    local params = {subType = subType, contentType = 1, message = getlocal("xlpd_invite_chatMsg", {team.leader}), level = level, rank = rank, power = power, uid = playerVoApi:getUid(), name = tostring(playerVoApi:getPlayerName()), pic = playerVoApi:getPic(), ts = base.serverTime, allianceName = allianceName, allianceRole = allianceRole, vip = playerVoApi:getVipLevel(), language = language, wr = playerVoApi:getServerWarRank(), st = playerVoApi:getServerWarRankStartTime(), title = playerVoApi:getTitle(), bnum = base.clancrossinfoBnum, rpoint = base.clancrossinfoRpoint, hfid = playerVoApi:getHfid()}
    params.xlpd_invite = {
        tid = team.tid, --邀请队伍id
        pd = team.pd or 0, --队伍攀登值
        pn = (team.pn or 1), --当前队伍人数
        max = (team.max or 3), --最大人数
        pdLv = (team.pdLv or 0), --攀登等级要求
        leader = (team.leader or ""), --队伍队长的昵称
        msg = team.msg or "", --邀请宣言
        ts = base.serverTime, --发送邀请的时间
    }
    local flag = true
    if subType == 2 then
        if receiver and next(receiver) then
            local ruid = chatVoApi:getReciverIdByName(receiver.name)
            if chatVoApi:isChat2_0() then
                if ruid == 0 and receiver.uid then
                    ruid = receiver.uid
                end
            end
            -- 取消在线提示所需要的假数据
            G_privateDataTip = {}
            G_privateDataTip.sender = sender
            G_privateDataTip.senderName = senderName
            G_privateDataTip.reciver = ruid
            G_privateDataTip.reciverName = receiver.name
            G_privateDataTip.content = params
            G_privateDataTip.ts = base.serverTime
            flag = chatVoApi:sendChatMessage(0, sender, senderName, ruid, receiver.name, params)
        end
    elseif subType == 3 then
        local alliance = allianceVoApi:getSelfAlliance()
        if alliance and alliance.aid then
            flag = chatVoApi:sendChatMessage(alliance.aid + 1, sender, senderName, 0, "", params)
        end
    else
        flag = chatVoApi:sendChatMessage(1, sender, senderName, 0, "", params)
    end
    return flag
end

--队伍里面的人数
function acXlpdVoApi:getMyTeamPlayerNum()
    local pn = 0
    local myTeam = self:getMyTeamInfo()
    for k = 1, 3 do
        local v = myTeam[k]
        if v and type(v) == "table" and next(v) then
            pn = pn + 1
        end
    end
    return pn
end

--获取自己是否可以加入队伍
--1：没有队伍，2：已有队伍，3：未达到组队要求，4：已过组队时间
function acXlpdVoApi:getJoinTeamStatus(pdLv)
	local vo = self:getAcVo()
	local chngeLimit = 3
	if vo and vo.activeCfg and vo.activeCfg.tc then
		chngeLimit = vo.activeCfg.tc
	end
    local status = self:getStatus()
    if status ~= 1 then
        return 4
    end
    if pdLv and tonumber(pdLv) > 0 then
        local tb = self:returnCurlPdLevelWithAnyData()
        if tb[7] == nil or tb[7] < tonumber(pdLv) then
            return 3
        end
    end
    if self:isHasTeam() == false then
        return 1
    else
        return 2, {self:getChngeNum(), chngeLimit, self:getMyTeamPlayerNum()}
    end
    return 1
end
----------------------- 结算胜利  失败
function acXlpdVoApi:isGetOverData() -- 最近一次的结算 1 领取过， 0 未领取
	local vo = self:getAcVo()
	local curZero = G_getWeeTs(base.serverTime)
	local isgetOver = true

	if not vo.teamTtb or not next(vo.teamTtb) then
			return true
	end

	if vo and vo.teamTtb then
        if vo.teamTtb[tostring(curZero)] and vo.teamTtb[tostring(curZero)][2] == 0 and self:getStatus() == 5 and not self:isShopOpen() then
            return false
        else
            for k,v in pairs(vo.teamTtb) do
                if k ~= tostring(curZero) and v[2] == 0 then
                    return false
                end
            end
        end

	end
	return isgetOver
end

function acXlpdVoApi:isCanSocketGetOverData() -- 是否拉取最近一次 结算数据
	local isgetOver = self:isGetOverData()
	-- print("isgetOver===>>",isgetOver, self:getStatus())
	if isgetOver then --最近一次已结算，所以不需要拉取
		return false
	else
        return true
	end
end

function acXlpdVoApi:socketOverData(callback) --拉取最近一次结算数据
	local function requestHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.xlpd then
                self:updateData(sData.data.xlpd)
            end

            if callback then
                callback()
            end
        end
    end
    socketHelper:acXlpdSokcet(requestHandler, "getcoin")
end

function acXlpdVoApi:getOverNow()
	local vo                         = self:getAcVo()
	local hNum                       = vo.activeCfg.hNum
	local myPdCoin                   = 0
	local elevationNum1,elevationNum2 = 0,0 --海拔
	local overType                   = 0
	if vo and vo.clist and next(vo.clist) then
		myPdCoin      = tonumber(vo.clist[1][2])
		elevationNum1 = math.ceil(tonumber(vo.clist[1][1]) * hNum)
		elevationNum2 = math.ceil(tonumber(vo.clist[2][1]) * hNum)
		overType      = tonumber(vo.clist[3])-- 输赢状态  1 赢， 2 输， 3 平局
	end
	local overTip = getlocal("xlpd_pingJuTip")
	if overType == 1 then
		overTip = getlocal("xlpd_winTip")
	elseif overType == 2 then
		overTip = getlocal("xlpd_loseTip")
	end
	return { elevationNum1, elevationNum2, overTip, myPdCoin},overType
end

function acXlpdVoApi:showOverPanel(layerNum, callback, overData, overType)
	require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"

	local G_ColorType = G_ColorGray
	if overType == 1 then
		G_ColorType = G_ColorGreen2
	elseif overType == 2 then
		G_ColorType = G_ColorRed
	end

	local tabStrTb = {getlocal("xlpd_OverShowStr",{overData[1], overData[2], overData[3], overData[4]})}
	local textFormatTb = {{}}
	textFormatTb[1].alignment = kCCTextAlignmentCenter
	textFormatTb[1].richFlag  = true
	textFormatTb[1].richColor = {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil, G_ColorType, nil, G_ColorYellowPro}
	textFormatTb[1].ws        = 60

    local titleStr = nil
    
    tipShowSmallDialog:showStrInfo(layerNum, true, true, callback, titleStr, tabStrTb, nil, 25,textFormatTb,"xlpdOverShow",{overType = overType})
end


--------------------- 升级 弹板 逻辑 ---------------------
function acXlpdVoApi:getPdGradeMaxAndMin( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg then
		local grade = vo.activeCfg.grade
		return 1, SizeOfTable(grade)
	end
	print " ===================  e r r o r getPdGradeMaxAndMin =================== "
	return 1 ,50
end

function acXlpdVoApi:saveCurPdLevel(curPdLvl)
	local vo = self:getAcVo()
    -- local curZero = G_getWeeTs(base.serverTime)
    -- local pdOldLvlKey = curZero..playerVoApi:getUid()..vo.st..vo.et.."pdOldLevel"
	CCUserDefault:sharedUserDefault():setIntegerForKey(playerVoApi:getUid()..vo.st..vo.et.."pdOldLevel",curPdLvl)
	CCUserDefault:sharedUserDefault():flush()
end
function acXlpdVoApi:getCurPdLevel( )
	local vo = self:getAcVo()
    -- local curZero = G_getWeeTs(base.serverTime)
    -- local pdOldLvlKey = curZero..playerVoApi:getUid()..vo.st..vo.et.."pdOldLevel"
	local oldPdLevel = tonumber(CCUserDefault:sharedUserDefault():getIntegerForKey(playerVoApi:getUid()..vo.st..vo.et.."pdOldLevel"))
	return oldPdLevel
end

function acXlpdVoApi:changeSaveOldPdLevel( )
	local vo                 = self:getAcVo()
	local oldPdLevel         = acXlpdVoApi:getCurPdLevel( )
	local pdMinLvl, pdMaxLvl = self:getPdGradeMaxAndMin()
	-- do return true end
	local curPdLevelData = self:returnCurlPdLevelWithAnyData()
	if oldPdLevel == 0 then
		self:saveCurPdLevel(pdMaxLvl + 1)
		return false
	elseif oldPdLevel > curPdLevelData[7] then---数据错了 修正
		self:saveCurPdLevel(curPdLevelData[7])
		return false
	end	
	-- print("oldPdLevel, pdMaxLvl + 1, curPdLevelData[7]====>>>>",oldPdLevel, pdMaxLvl + 1, curPdLevelData[7])
	if ( oldPdLevel == pdMaxLvl + 1 and curPdLevelData[7] > 0 ) or oldPdLevel < curPdLevelData[7] then
		return true
	end
	return false
end

function acXlpdVoApi:getUpLevelData()
	local vo                 = self:getAcVo()
	local oldPdLevel         = self:getCurPdLevel( )
	local pdMinLvl, pdMaxLvl = self:getPdGradeMaxAndMin()
	local curPdLevelData     = self:returnCurlPdLevelWithAnyData()
	local curLvl             = curPdLevelData[7]
	local gradTb             = vo.activeCfg.grade
	local allGetCoin         = 0
	if oldPdLevel == pdMaxLvl + 1 and curPdLevelData[7] > 0 then
		for i=1,curLvl do
			allGetCoin = allGetCoin + gradTb[i].coin
		end
	elseif oldPdLevel < curPdLevelData[7] then
		for i=oldPdLevel + 1,curLvl do
			allGetCoin = allGetCoin + gradTb[i].coin
		end
	end
	self:saveCurPdLevel(curLvl)
	return curLvl, allGetCoin
end

function acXlpdVoApi:showPdLvlPanel(layerNum, curLvl, allGetCoin)
	require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"

	local tabStrTb = {getlocal("xlpd_upLvlStr",{curLvl, allGetCoin})}
	local textFormatTb = {{}}
	textFormatTb[1].alignment = kCCTextAlignmentCenter
	textFormatTb[1].richFlag  = true
	textFormatTb[1].richColor = {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}
	textFormatTb[1].ws        = 60

    local titleStr = nil
    
    tipShowSmallDialog:showStrInfo(layerNum, true, true, callback, titleStr, tabStrTb, nil, 25,textFormatTb,"xlpd_upLvlStr")
end

function acXlpdVoApi:getLimit()
    local vo = self:getAcVo()
    if vo and vo.activeCfg and vo.activeCfg.Lv then
        return vo.activeCfg.Lv
    end
    return 30
end

function acXlpdVoApi:clearEveryDayData( )
	self.chatStr   = nil
	self.oldPdvTb  = {}
	self.pdvUpTb   = {}
	self.isNewData = false
	self.needRefreshTeamData = false

	local vo = self:getAcVo()
	-- vo.teamNum = 0
	vo.chngeNum = 0
	vo.taskedTb = {}
	vo.ispool = 0
	vo.teams = {}
	vo.ispoolTb = {}
	vo.ispoolTb = {}
	for i=1,2 do
		vo.teams[i] = {}
	end
end