--[[
 --
 -- add by vicky
 -- 2015.01.16 
 --
 --]]

local data_item_item =  require("data.data_item_item") 
local data_card_card = require("data.data_card_card") 
 require("data.data_error_error") 
local data_union_gongfang_union_gongfang = require("data.data_union_gongfang_union_gongfang") 


 local MAX_ZORDER = 110  


 local GuildZuofangLayer = class("GuildZuofangLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end)


 -- 建筑升级
 function GuildZuofangLayer:reqLevelup(msgBox) 
    levelupBtn = self._rootnode["levelup_btn"] 

    RequestHelper.Guild.unionLevelUp({
        unionid = game.player:getGuildMgr():getGuildInfo().m_id, 
        buildtype = self._buildType, 
        errback = function(data)
            levelupBtn:setEnabled(true) 
            msgBox:setBtnEnabled(true) 
        end, 
        callback = function(data) 
            dump(data, "建筑升级", 8)  
            if data.err ~= "" then 
                dump(data.err) 
                levelupBtn:setEnabled(true) 
                msgBox:setBtnEnabled(true)
            else 
                ResMgr.showErr(2900083) 
            	local rtnObj = data.rtnObj 
                msgBox:removeFromParentAndCleanup(true) 
                self:updateLevel(rtnObj.buildLevel, rtnObj.currentUnionMoney) 

                game.player:getGuildInfo():updateData({workshopLevel = rtnObj.buildLevel, currentUnionMoney = rtnObj.currentUnionMoney}) 
                PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA) 
                PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_BUILD_LEVEL) 

                levelupBtn:setEnabled(true) 

                -- 更新生产列表相关数据 
                self:initListData(rtnObj.typeList) 

                -- 更新列表  
                self:updateBuildList(self._buildList) 

                -- 更新当前正在生产的数据  
                if self._curWorkData ~= nil then 
                    local tmpData = self._curWorkData 
                    
                    for i, v in ipairs(self._buildList) do 
                        if v.id == self._curWorkData.id then 
                            self._curWorkData = v 
                            self._curWorkData.surplusTime = tmpData.surplusTime 
                            self._curWorkData.workType = tmpData.workType 
                            break 
                        end 
                    end 
                else 
                    self._curWorkData = self._buildList[1] 
                end 
                
                self:selectedTab(self._curWorkData.id) 
                self:updateCurBuildData(self._curWorkData) 
            end
        end
    })
 end 


 -- 作坊生产 
 function GuildZuofangLayer:startBuild(workData, workType, curBtns)
    local function resetBtns()
        for i, v in ipairs(curBtns) do 
            v:setEnabled(true) 
        end 
    end 

    RequestHelper.Guild.unionWorkShopProduct({
        unionid = game.player:getGuildMgr():getGuildInfo().m_id, 
        workType = workType, 
        workId = workData.id, 
        errback = function(data) 
            resetBtns() 
        end, 
        callback = function(data) 
            dump(data) 
            if data.err ~= "" then 
                dump(data.err) 
                resetBtns() 
            else
                resetBtns() 

                local rtnObj = data.rtnObj 
                workData.workType = workType 
                workData.surplusTime = rtnObj.surplusTime 
                self:updateCurBuildData(workData) 
                self:resetChooseBtnState(false, workData)  

                self:updateGoldNum(rtnObj.surplusGold) 
                self:updateFreeAndExtraCount(rtnObj.freeCount, rtnObj.extCount, rtnObj.extCostGold) 
            end 
        end 
    }) 
 end 


 -- 立即结束 
 function GuildZuofangLayer:endBuild(workData, curBtns) 
     local function resetBtns()
        for i, v in ipairs(curBtns) do 
            v:setEnabled(true) 
        end 
    end
    RequestHelper.Guild.unionWorkShopGetReward({ 
        unionId = game.player:getGuildMgr():getGuildInfo().m_id, 
        errback = function(data) 
            resetBtns() 
        end, 
        callback = function(data) 
            dump(data) 
            if data.err ~= "" then 
                dump(data.err) 
                resetBtns() 
            else 
                local rtnObj = data.rtnObj 

                self:updateGoldNum(rtnObj.gold) 
                self:showRewardMsgBox(rtnObj.rewardList) 

                resetBtns() 
                workData.surplusTime = -1 
                self:updateCurBuildData(workData) 

                -- 按钮设置为可见 
                self:resetChooseBtnState(true) 
            end 
        end 
    }) 
 end 


 -- 校验时间 
 function GuildZuofangLayer:checkWorkShopTime(workData) 
    RequestHelper.Guild.checkWorkShopTime({ 
        type = 1, 
        errback = function(data) 
        end, 
        callback = function(data) 
            dump(data) 
            if data.err ~= "" then 
                dump(data.err) 
            else 
                local rtnObj = data.rtnObj 

                -- isOver:0倒计时结束1倒计时未结束 
                if rtnObj.isOver == 0 then 
                    self:showRewardMsgBox(rtnObj.rewardList) 
                    workData.surplusTime = -1 
                    self:updateCurBuildData(workData) 

                    -- 按钮设置为可见 
                    self:resetChooseBtnState(true) 
                else 
                    workData.surplusTime = rtnObj.leftTime 
                end 
            end 
        end 
    }) 
 end 


 function GuildZuofangLayer:showRewardMsgBox(rewardList) 
 	if rewardList ~= nil and #rewardList > 0 then 
	 	local cellDatas = {} 
	    for i, v in ipairs(rewardList) do 
	        local item 
	        local iconType = ResMgr.getResType(v.t)
	        if iconType == ResMgr.HERO then 
	            item = ResMgr.getCardData(v.id)
	        else
	            item = data_item_item[v.id]
	        end
	        table.insert(cellDatas, {
	            id = v.id, 
	            type = v.t, 
	            name = item.name, 
	            iconType = iconType,  
	            num = v.n 
	            }) 
	    end 

	    msgBox = require("game.Huodong.RewardMsgBox").new({ 
	        cellDatas = cellDatas 
	        })
	    game.runningScene:addChild(msgBox, MAX_ZORDER) 
	end 
 end 


 function GuildZuofangLayer:ctor(data) 
 	dump(data, "作坊数据", 6) 

 	self._buildType = GUILD_BUILD_TYPE.zuofang  

 	local proxy = CCBProxy:create()
 	self._rootnode = {} 
 	local node = CCBuilderReaderLoad("guild/guild_zuofang_layer.ccbi", proxy, self._rootnode) 
 	node:setPosition(display.width/2, display.height/2) 
 	self:addChild(node) 

 	self._rootnode["titleLabel"]:setString("帮派作坊") 

    self._rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName,sender) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            self:removeFromParentAndCleanup(true) 
        end,CCControlEventTouchUpInside) 

    local guildMgr = game.player:getGuildMgr() 
    local guildInfo = guildMgr:getGuildInfo() 

    -- 升级按钮 
    local jopType = guildInfo.m_jopType  
    local levelupBtn = self._rootnode["levelup_btn"] 
    if jopType ~= GUILD_JOB_TYPE.leader and jopType ~= GUILD_JOB_TYPE.assistant then 
        levelupBtn:setVisible(false) 
    else 
        levelupBtn:setVisible(true) 
        levelupBtn:addHandleOfControlEvent(function(eventName,sender) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            if guildMgr:checkIsReachMaxLevel(self._buildType, self._level) == true then 
                show_tip_label(data_error_error[2900021].prompt) 
            else 
                levelupBtn:setEnabled(false) 
                local msgBox = require("game.guild.GuildBuildLevelUpMsgBox").new({
                    curLevel = self._level, 
                    toLevel = self._level + 1, 
                    needCoin = self._needCoin, 
                    curCoin = self._currentUnionMoney, 
                    buildType = self._buildType, 
                    cancelFunc = function()
                        levelupBtn:setEnabled(true)  
                    end,
                    confirmFunc = function(msgBox)
                        self:reqLevelup(msgBox) 
                    end 
                    })
                game.runningScene:addChild(msgBox, MAX_ZORDER) 
            end 
        end,CCControlEventTouchUpInside) 
    end 

    local rtnObj = data.rtnObj 

    self:showRewardMsgBox(rtnObj.rewardList) 

    self:updateLevel(rtnObj.workShopLevel, rtnObj.currentUnionMoney) 
    self:updateGoldNum(rtnObj.gold)   
    self:updateFreeAndExtraCount(rtnObj.freeCount, rtnObj.extNum, rtnObj.extGoldNum) 
    self:createAllLbl() 

	local typeList = rtnObj.typeList 
 	self:initListData(typeList) 
 	
 	-- 初始化 生产列表 若当前没有生产，则默认勾选第一个开启的 
	if rtnObj.isWork == 0 then 
		for i, v in ipairs(self._buildList) do 
			if v.id == rtnObj.workType then 
				self._curWorkData = v 
				self._curWorkData.surplusTime = rtnObj.surplusTime 
				self._curWorkData.workType = rtnObj.overtimeflag 

                self:resetChooseBtnState(false, self._curWorkData)  
				break 
			end 
		end 
	else 
 		self._curWorkData = self._buildList[1]
	end 

 	self:initBuildListView(self._buildList, self._curWorkData) 

    self:initBtnEvent() 
    self:initTimeSchedule() 

 end 


 -- 初始化按钮事件 
 function GuildZuofangLayer:initBtnEvent() 
    local normalBuildBtn = self._rootnode["normal_build_btn"] 
    local fastBuildBtn = self._rootnode["fast_build_btn"] 
    local normalEndBtn = self._rootnode["normal_end_btn"] 
    local fastEndBtn = self._rootnode["fast_end_btn"] 

    local btns = {normalBuildBtn, fastBuildBtn, normalEndBtn, fastEndBtn} 

    local function resetBtns(bEnabled)
        for i, v in ipairs(btns) do 
            v:setEnabled(bEnabled) 
        end 
    end 

    local function buildFunc(workType) 
        resetBtns(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        
        local function confirmBuildFunc() 
            if workType == GUILD_ZF_WORK_TYPE.normal then 
                self:startBuild(self._curWorkData, workType, btns) 

            elseif workType == GUILD_ZF_WORK_TYPE.fast then 
                if self._curGold < self._curWorkData.fastCostGold then 
                    show_tip_label(data_error_error[2900047].prompt) 
                    resetBtns(true) 
                else
                    self:startBuild(self._curWorkData, workType, btns) 
                end 
            end 
        end 

        if self._freeCount > 0 then 
            confirmBuildFunc() 

        elseif self._extraCount <= 0 then 
            -- 提示已不能生产  
            show_tip_label(data_error_error[2900027].prompt) 
            resetBtns(true) 

        elseif self._extraCount > 0 then 
            -- 额外购买次数提示 

            local costGold = self._extraCostGold
            if(workType == GUILD_ZF_WORK_TYPE.fast) then
                costGold = self._extraCostGold + self._curWorkData.fastCostGold
            end

            local msgBox = require("game.guild.utility.GuildNormalMsgBox").new({
                    title = "提示", 
                    isSingleBtn = false, 
                    isBuyExtraBuild = true, 
                    extraCostGold = costGold, 
                    cancelFunc = function()
                        resetBtns(true) 
                    end, 
                    confirmFunc = function(node) 
                        if self._curGold < self._extraCostGold then 
                            -- 元宝不足 
                            show_tip_label(data_error_error[2900050].prompt) 
                            resetBtns(true) 
                        else
                            node:removeFromParentAndCleanup(true) 
                            confirmBuildFunc() 
                        end 
                    end
                }) 
            game.runningScene:addChild(msgBox, MAX_ZORDER) 
        end 
    end 

    local function endFunc() 
        resetBtns(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        -- 判断元宝数
        if self._curGold < self._curWorkData.endCostGold then 
            show_tip_label(data_error_error[2900051].prompt) 
            resetBtns(true) 
        else 
            self:endBuild(self._curWorkData, btns) 
        end 
    end 

    -- 普通生产 
    normalBuildBtn:addHandleOfControlEvent(function(eventName,sender) 
            buildFunc(GUILD_ZF_WORK_TYPE.normal) 
        end,CCControlEventTouchUpInside) 

    -- 加班生产 
    fastBuildBtn:addHandleOfControlEvent(function(eventName,sender)  
            buildFunc(GUILD_ZF_WORK_TYPE.fast) 
        end,CCControlEventTouchUpInside) 

    -- 普通生产立即结束 
    normalEndBtn:addHandleOfControlEvent(function(eventName,sender) 
           endFunc() 
        end,CCControlEventTouchUpInside) 

    -- 加班生产立即结束 
    fastEndBtn:addHandleOfControlEvent(function(eventName,sender) 
            endFunc() 
        end,CCControlEventTouchUpInside) 
 end 


 -- 初始化 
 function GuildZuofangLayer:initTimeSchedule() 
    self._scheduler = require("framework.scheduler") 

    local function updateTime() 
        if self._curWorkData ~= nil and self._curWorkData.surplusTime ~= nil and self._curWorkData.surplusTime > 0 then 
            self._curWorkData.surplusTime = self._curWorkData.surplusTime - 1 
            if self._curWorkData.workType == GUILD_ZF_WORK_TYPE.normal then 
                self._rootnode["normal_time_lbl"]:setString(format_time(self._curWorkData.surplusTime)) 
            else
                self._rootnode["fast_time_lbl"]:setString(format_time(self._curWorkData.surplusTime)) 
            end 
            if self._curWorkData.surplusTime <= 0 then 
                self:checkWorkShopTime(self._curWorkData) 
            end 
        end 
    end 

    self._checkSchedule = self._scheduler.scheduleGlobal(updateTime, 1, false) 
 end 


 function GuildZuofangLayer:initListData(buildList) 
 	self._buildList = {} 

 	local function getAddStr(id, t, n)
 		local item 
        local iconType = ResMgr.getResType(t)
        if iconType == ResMgr.HERO then 
            item = ResMgr.getCardData(id)
        else
        	item = data_item_item[id] 
        end 
        ResMgr.showAlert(item, "奖励的物品返回有问题, id: " .. id .. "type" .. t) 

        local str = "增加" .. tostring(n) .. tostring(item.name) 
        return str 
 	end 

 	for i, v in ipairs(buildList) do 
 		local itemData = v 

 		-- 	isOpen:是否开启(等级是否足够)0开启1未开启
 		if v.isOpen == 0 then 
 			itemData.hasOpen = true 
 		elseif v.isOpen == 1 then 
 			itemData.hasOpen = false 
 		end 

 		local info = self:getDataInfoById(v.id) 
 		itemData.level = info.level 
 		itemData.lock = info.lock 
 		itemData.unlock = info.unlock 
 		itemData.endCostGold = info.end_cost_gold 
 		itemData.fastCostGold = info.fast_build_gold 
 		itemData.normalAddStr = getAddStr(v.itemId, v.itemType, v.normalNum) 
 		itemData.fastAddStr = getAddStr(v.itemId, v.itemType, v.fastNum) 
 		
 		table.insert(self._buildList, itemData) 
 	end 
 end 


 function GuildZuofangLayer:getDataInfoById(id)
 	local info = data_union_gongfang_union_gongfang[id] 
 	ResMgr.showAlert(info, "服务器端返回的工坊id不对, id: " .. id) 

 	return info 
 end 
 

 -- 更新生产列表 
 function GuildZuofangLayer:updateBuildList(buildList) 
 	local bOpened = false 
 	for i, v in ipairs(buildList) do 
 		-- dump(v) 
        
 		self._rootnode["line_" .. i]:setVisible(true) 
 		local openKey = "line_open_" .. tostring(i) 
 		local unopenKey = "line_unopen_" .. tostring(i) 
 		local openMsgKey = "line_open_msg_lbl_" .. tostring(i) 
 		local unopenMsgKey = "line_unopen_msg_lbl_" .. tostring(i) 

 		self._rootnode[openMsgKey]:setString(tostring(v.unlock)) 
 		self._rootnode[unopenMsgKey]:setString(tostring(v.lock)) 

 		if v.hasOpen == true then 
 			bOpened = true 
 			self._rootnode[openKey]:setVisible(true) 
 			self._rootnode[unopenKey]:setVisible(false) 

 		elseif v.hasOpen == false then 
 			self._rootnode[openKey]:setVisible(false) 
 			self._rootnode[unopenKey]:setVisible(true) 
 		end 
 	end 

 	if bOpened == true then 
 		self._rootnode["tag_normal_unopen"]:setVisible(false) 
 		self._rootnode["tag_fast_unopen"]:setVisible(false) 
 	else 
 		self._rootnode["tag_normal_unopen"]:setVisible(true) 
 		self._rootnode["tag_fast_unopen"]:setVisible(true) 
 	end 
 end 


 -- 设置生产列表 选择按钮的状态 
 function GuildZuofangLayer:resetChooseBtnState(bVisible, curWorkData) 
    local index  
    if curWorkData ~= nil then 
        for i, v in ipairs(self._buildList) do 
            if v.id == curWorkData.id then 
                index = i 
                break 
            end 
        end 
    end 

    for i = 1, #data_union_gongfang_union_gongfang do 
        if i ~= index then 
            self._rootnode["choose_btn_" ..tostring(i)]:setVisible(bVisible) 
        end 
    end 
 end 


 function GuildZuofangLayer:selectedTab(tag)  
    for i = 1, #data_union_gongfang_union_gongfang do 
        if tag == i then
            self._rootnode["choose_btn_" ..tostring(i)]:selected()
        else
            self._rootnode["choose_btn_" ..tostring(i)]:unselected() 
        end
    end 
 end 

 -- 初始化 生产列表 
 function GuildZuofangLayer:initBuildListView(buildList, curWorkData) 
 	self:updateBuildList(buildList) 

	local function onTabBtn(tag) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        self:selectedTab(tag) 
        self._curWorkData = self._buildList[tag] 
        self:updateCurBuildData(self._curWorkData)  
    end

    --初始化选项卡
    local function initTab() 
        for i = 1, #data_union_gongfang_union_gongfang do
            self._rootnode["choose_btn_" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
        end 
        if curWorkData.hasOpen == true then 
	        self:selectedTab(curWorkData.id) 
            self:updateCurBuildData(curWorkData) 
	    end 
    end 

    initTab() 
 end 


 -- 更新生产按钮状态、消耗元宝数、生产的道具名称数量等 
 function GuildZuofangLayer:updateCurBuildData(curWorkData) 
 	local info = self:getDataInfoById(curWorkData.id) 

 	-- 立即结束、加班生产消耗的元宝 
 	self._rootnode["normal_end_cost_lbl"]:setString(tostring(info.end_cost_gold)) 
    self._rootnode["fast_cost_lbl"]:setString(tostring(info.fast_build_gold)) 
    self._rootnode["fast_end_cost_lbl"]:setString(tostring(info.end_cost_gold))  

    self._rootnode["normal_add_lbl"]:setVisible(true) 
    self._rootnode["fast_add_lbl"]:setVisible(true) 
	self._normalAddLbl:setString(curWorkData.normalAddStr) 
	self._fastAddLbl:setString(curWorkData.fastAddStr) 

    if curWorkData.surplusTime ~= nil and curWorkData.surplusTime > 0 then 
    	if curWorkData.workType == GUILD_ZF_WORK_TYPE.normal then 
    		-- 倒计时 
	    	self._rootnode["tag_normal_time"]:setVisible(true) 
	    	self._rootnode["normal_time_lbl"]:setString(format_time(curWorkData.surplusTime)) 

	    	-- 普通生产 只显示立即结束按钮  
	    	self._rootnode["normal_build_btn"]:setVisible(false) 
	    	self._rootnode["tag_normal_end"]:setVisible(true) 
	    	self._rootnode["tag_normal_time"]:setVisible(true) 

	    	-- 加班生产 只显示加班生产按钮且不可点击 
	    	self._rootnode["tag_fast_build"]:setVisible(true) 
	    	self._rootnode["fast_build_btn"]:setEnabled(false) 
	    	self._rootnode["tag_fast_end"]:setVisible(false) 
	    	self._rootnode["tag_fast_time"]:setVisible(false) 

	    elseif curWorkData.workType == GUILD_ZF_WORK_TYPE.fast then 
	    	-- 倒计时 
	    	self._rootnode["tag_fast_time"]:setVisible(true) 
	    	self._rootnode["fast_time_lbl"]:setString(format_time(curWorkData.surplusTime)) 

	    	-- 加班生产 只显示立即结束按钮 
	    	self._rootnode["tag_fast_build"]:setVisible(false) 
	    	self._rootnode["tag_fast_end"]:setVisible(true) 
	    	self._rootnode["tag_fast_time"]:setVisible(true)  

	    	-- 普通生产 只显示加班生产按钮且不可点击  
	    	self._rootnode["normal_build_btn"]:setVisible(true)  
	    	self._rootnode["normal_build_btn"]:setEnabled(false) 
	    	self._rootnode["tag_normal_end"]:setVisible(false) 
	    	self._rootnode["tag_normal_time"]:setVisible(false) 
	    end 

    else 
    	self._rootnode["normal_build_btn"]:setVisible(true) 
        self._rootnode["normal_build_btn"]:setEnabled(true)  
    	self._rootnode["tag_normal_end"]:setVisible(false) 
    	self._rootnode["tag_normal_time"]:setVisible(false) 

    	self._rootnode["tag_fast_build"]:setVisible(true) 
        self._rootnode["fast_build_btn"]:setEnabled(true)  
    	self._rootnode["tag_fast_end"]:setVisible(false) 
    	self._rootnode["tag_fast_time"]:setVisible(false) 
    end 

 end 


 function GuildZuofangLayer:updateFreeAndExtraCount(freeCount, extNum, extGoldNum) 
 	self._freeCount = freeCount 
 	self._extraCount = extNum 
 	self._extraCostGold = extGoldNum 

 	if self._freeCount ~= nil and self._freeCount > 0 then 
 		self._rootnode["free_num_lbl"]:setString(tostring(self._freeCount)) 
 		self._rootnode["tag_free"]:setVisible(true) 
 		self._rootnode["tag_extra"]:setVisible(false) 

 	elseif self._extraCount ~= nil and self._extraCount > 0 then 
 		self._rootnode["extra_num_lbl"]:setString(tostring(self._extraCount)) 
 		self._rootnode["extra_cost_gold_lbl"]:setString(tostring(self._extraCostGold)) 
 		self._rootnode["tag_free"]:setVisible(false) 
 		self._rootnode["tag_extra"]:setVisible(true) 
 		
 	else
 		self._rootnode["tag_free"]:setVisible(false) 
 		self._rootnode["tag_extra"]:setVisible(false) 
 	end 
 end 


 -- 更新元宝数 
 function GuildZuofangLayer:updateGoldNum(goldNum)
 	self._curGold = goldNum 
 	game.player:updateMainMenu({gold = self._curGold}) 

 	self._rootnode["cur_gold_lbl"]:setString(tostring(self._curGold)) 

 	arrangeTTFByPosX({
 		self._rootnode["cur_gold_lbl"], 
 		self._rootnode["cur_gold_icon"] 
 		})

 end 


 -- 更新等级 
 function GuildZuofangLayer:updateLevel(level, currentUnionMoney) 
    local guildMgr = game.player:getGuildMgr() 
    self._level = level 
    guildMgr:getGuildInfo().m_workshoplevel = self._level 
    self._needCoin = guildMgr:getNeedCoin(self._buildType, self._level) 

    self._currentUnionMoney = currentUnionMoney  

    -- 当前等级 
    self:createShadowLbl("LV." .. tostring(self._level), ccc3(255, 222, 0), self._rootnode["cur_level_lbl"])

    -- 当前帮派资金 
    self:createShadowLbl(tostring(self._currentUnionMoney), FONT_COLOR.WHITE, self._rootnode["cur_coin_lbl"])
    
    self:updateNeedCoinLbl(self._needCoin) 

 end 


 function GuildZuofangLayer:updateNeedCoinLbl(needCoin)
    local str 
    if game.player:getGuildMgr():checkIsReachMaxLevel(self._buildType, self._level) == true then 
        str = "已升到最大等级" 
    else
        str = tostring(needCoin) 
    end
    self:createShadowLbl(str, FONT_COLOR.WHITE, self._rootnode["cost_coin_lbl"]) 
 end 


 function GuildZuofangLayer:createShadowLbl(text, color, node, size) 
 	node:removeAllChildren() 
 	local lbl = ui.newTTFLabelWithShadow({
            text = text,
            size = size or 20, 
            color = color,
            shadowColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
        }) 

    node:addChild(lbl) 
    return lbl 
 end 


 -- 阴影描边字 
 function GuildZuofangLayer:createAllLbl() 
    local guildMgr = game.player:getGuildMgr() 

    local yColor = ccc3(255, 222, 0) 
    -- 升级消耗资金 
    self:createShadowLbl("升级消耗资金:", yColor, self._rootnode["cost_coin_msg_lbl"]) 

    -- 当前拥有资金 
    self:createShadowLbl("当前拥有资金:", yColor, self._rootnode["cur_coin_msg_lbl"])  
   
    -- "拥有:" 
    self:createShadowLbl("拥有:", FONT_COLOR.WHITE, self._rootnode["cur_gold_msg_lbl"]) 

    -- "今日可额外生产     次，本次消耗" 
    self:createShadowLbl("今日可额外生产     次，本次消耗", FONT_COLOR.WHITE, self._rootnode["extra_num_msg_lbl"]) 

    -- "今日可免费生产     次" 
    local lbl = self:createShadowLbl("今日可免费生产     次", FONT_COLOR.WHITE, self._rootnode["free_num_msg_lbl"]) 
    lbl:setPosition(-lbl:getContentSize().width, 0) 

    -- 普通生产 得到的道具 
    self._normalAddLbl = self:createShadowLbl("待定", ccc3(0, 219, 52), self._rootnode["normal_add_lbl"]) 
    self._normalAddLbl:setPosition(-self._normalAddLbl:getContentSize().width/2, self._normalAddLbl:getContentSize().height/2) 

    -- 加班生产 得到的道具 
    self._fastAddLbl = self:createShadowLbl("待定", ccc3(0, 219, 52), self._rootnode["fast_add_lbl"]) 
    self._fastAddLbl:setPosition(-self._fastAddLbl:getContentSize().width/2, self._fastAddLbl:getContentSize().height/2) 

 end 


 function GuildZuofangLayer:onExit() 
    if self._checkSchedule ~= nil then 
        self._scheduler.unscheduleGlobal(self._checkSchedule) 
    end

    CCTextureCache:sharedTextureCache():removeUnusedTextures()
 end 



 return GuildZuofangLayer 

