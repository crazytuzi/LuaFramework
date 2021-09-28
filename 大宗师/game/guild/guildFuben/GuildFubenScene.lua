--[[
 --
 -- add by vicky
 -- 2015.03.05 
 --
 --]]

 local data_item_item = require("data.data_item_item") 
 
 local data_npc_npc = require("data.data_npc_npc") 
 local data_ui_ui = require("data.data_ui_ui") 


 local MAX_ZORDER = 100 
 local MAX_TYPE = 1 


 local GuildFubenScene = class("GuildFubenScene", function() 
    local bottomFile = "guild/guild_bottom_frame_normal.ccbi" 
    local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType  
    if jopType ~= GUILD_JOB_TYPE.normal then 
        bottomFile = "guild/guild_bottom_frame.ccbi" 
    end 

    return require("game.guild.utility.GuildBaseScene").new({
        contentFile = "guild/guild_fuben_bg.ccbi",
        subTopFile = "guild/guild_fuben_up_tab.ccbi",
        bottomFile = bottomFile 
        }) 
 end) 


 -- 建筑升级
 function GuildFubenScene:reqLevelup(msgBox) 
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
                
                game.player:getGuildInfo():updateData({fubenLevel = rtnObj.buildLevel, currentUnionMoney = rtnObj.currentUnionMoney}) 
                
                -- 重新判断副本是否已开放 若有新开放的需要reload 
                local needReload = false 
                for i, v in ipairs(self._listData) do 
                    -- 如果当前副本是未开启的，并且等级达到了开启等级条件 
                    if v.state == FUBEN_STATE.notOpen and self._level >= v.limitlevel then 
                        if v.bCanShow == true then 
                            if i == 1 or (i > 1 and self._listData[i - 1].state == FUBEN_STATE.hasPass) then 
                                v.state = FUBEN_STATE.hasOpen 
                                needReload = true 
                            end 
                        elseif i > 1 and i < #self._listData then 
                            local befData = self._listData[i - 1] 
                            if befData.state == FUBEN_STATE.hasOpen or befData.state == FUBEN_STATE.hasPass then 
                                v.bCanShow = true 
                                v.state = FUBEN_STATE.notOpen 
                                self:createItemData(v, self._showType) 
                                needReload = true 
                            end 
                        end 
                    end 
                end 

                if needReload == true then 
                    self:reloadListView(self._listData) 
                end 
                
                levelupBtn:setEnabled(true) 
            end
        end
    })
 end 


  -- 列表
 function GuildFubenScene:reqListData(showType, cb) 
    RequestHelper.Guild.enterUnionCopy({
    	type = showType, 
        errback = function()
        end, 
        callback = function(data) 
            dump(data, "副本", 8)  
            if data.err ~= "" then 
                dump(data.err) 
            else 
            	if cb ~= nil then 
            		cb(data.rtnObj.fbList) 
            	end 
            end 
        end
   })
 end 


 function GuildFubenScene:getReward(showType, cell, itemData, msgBox)
    RequestHelper.Guild.getFubenReward({
        id = itemData.fbid, 
        type = showType, 
        errback = function()
            msgBox:setBtnEnabled(true) 
        end, 
        callback = function(data) 
            dump(data, "领取帮派副本奖励", 8)  
            if data.err ~= "" then 
                dump(data.err) 
                msgBox:setBtnEnabled(true) 
            else 
                ResMgr.showErr(2900090) 
                itemData.boxState = FUBEN_REWARD_STATE.hasGet 
                cell:setBoxState(itemData.boxState) 
                msgBox:removeFromParentAndCleanup(true) 
            end 
        end
       })
 end 


 -- 伤害排行 
 function GuildFubenScene:showRankLayer() 
    RequestHelper.Guild.showHurtList({ 
        errback = function()
            self._rootnode["shuchuBtn"]:setEnabled(true) 
        end, 
        callback = function(data) 
            dump(data, "伤害排行", 8)  
            if data.err ~= "" then 
                dump(data.err) 
                self._rootnode["shuchuBtn"]:setEnabled(true) 
            else 
                local rtnObj = data.rtnObj 
                local hurtList = rtnObj.hurtList 
                local layer = require("game.guild.guildFuben.GuildFubenRankLayer").new({
                    hurtList = hurtList, 
                    confirmFunc = function()
                        self._rootnode["shuchuBtn"]:setEnabled(true) 
                    end 
                    })
                self:addChild(layer, MAX_ZORDER) 
            end 
        end
       })
 end 


 function GuildFubenScene:ctor(param) 
 	self._buildType = GUILD_BUILD_TYPE.fuben  
    self._hasShowRewardBox = false 
 	local data = param.data 

    dump(data, "帮派副本", 8) 

 	self._listViewSize = CCSizeMake(self._rootnode["listView"]:getContentSize().width, self:getCenterHeightWithSubTop()) 

    -- 返回
 	self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        GameStateManager:ChangeState(GAME_STATE.STATE_GUILD) 
    end, CCControlEventTouchUpInside)  

     -- 输出排行  
    local shuchuBtn = self._rootnode["shuchuBtn"] 
    shuchuBtn:addHandleOfControlEvent(function(eventName,sender)
        shuchuBtn:setEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        self:showRankLayer() 
    end, CCControlEventTouchUpInside) 

    -- 帮派副本 说明 
    local helpBtn = self._rootnode["helpBtn"] 
    helpBtn:addHandleOfControlEvent(function(eventName,sender)
        helpBtn:setEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        local helpLayer = require("game.guild.guildFuben.GuildFubenHelpLayer").new({
            msg = data_ui_ui[10].content, 
            closeFunc = function()
                helpBtn:setEnabled(true) 
            end, 
            })
        self:addChild(helpLayer, MAX_ZORDER) 
    end, CCControlEventTouchUpInside) 

 	local jopType = game.player:getGuildInfo().m_jopType 
 	local guildMgr = game.player:getGuildMgr() 

 	local levelupBtn = self._rootnode["levelup_btn"] 
    if jopType == GUILD_JOB_TYPE.leader or jopType == GUILD_JOB_TYPE.assistant then 
        levelupBtn:addHandleOfControlEvent(function(eventName,sender) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            if guildMgr:checkIsReachMaxLevel(self._buildType, self._level) == true then 
                ResMgr.showErr(2900021)
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
	else
		levelupBtn:setVisible(false) 
    end 

    local rtnObj = data.rtnObj 
    self._showType = rtnObj.type 
    self._canBuyCount = rtnObj.canBuyCount 
    self._vipLevel = rtnObj.vipLevel 
    local fbList = rtnObj.fbList 

    self:updateLeftCount(rtnObj.leftCount) 

    -- 等级、帮派资金 
    self:updateLevel(rtnObj.copyLevel, rtnObj.currentUnionMoney) 

    self:createAllLbl() 

    self:createTab(self._showType, fbList)

    self._bExit = false
    
 end 


 function GuildFubenScene:updateLeftCount(count)
    self._leftCount = count or 0 
    -- 剩余战斗次数
    self._rootnode["today_left_num"]:setString(tostring(self._leftCount)) 
 end 


 -- 更新等级 
 function GuildFubenScene:updateLevel(level, currentUnionMoney) 
    local guildMgr = game.player:getGuildMgr() 
    self._level = level 
    guildMgr:getGuildInfo().m_fubenLevel = self._level 
    self._needCoin = guildMgr:getNeedCoin(self._buildType, self._level) 

    self._currentUnionMoney = currentUnionMoney  

    -- 当前等级 
    self:createShadowLbl("LV." .. tostring(self._level), ccc3(255, 222, 0), self._rootnode["cur_level_lbl"])

    -- 当前帮派资金 
    self:createShadowLbl(tostring(self._currentUnionMoney), FONT_COLOR.WHITE, self._rootnode["cur_coin_lbl"])

    self:updateNeedCoinLbl(self._needCoin) 

 end 


 function GuildFubenScene:updateNeedCoinLbl(needCoin)
    local str 
    local isMax  
    if game.player:getGuildMgr():checkIsReachMaxLevel(self._buildType, self._level) == true then 
        str = "已满级" 
        isMax = true 
    else
        str = tostring(needCoin) 
        isMax = false 
    end
    self:createShadowLbl(str, FONT_COLOR.WHITE, self._rootnode["cost_coin_lbl"]) 

    if isMax == true then 
    	self._rootnode["levelup_btn"]:setPosition(self._rootnode["levelup_btn"]:getPositionX() + 163, self._rootnode["levelup_btn"]:getPositionY()) 
    end 
 end 


 function GuildFubenScene:createShadowLbl(text, color, node, size) 
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
 function GuildFubenScene:createAllLbl() 
    local yColor = ccc3(255, 222, 0) 

    -- 升级消耗资金 
    self:createShadowLbl("升级消耗资金:", yColor, self._rootnode["cost_coin_msg_lbl"])  

    -- 当前拥有资金 
    self:createShadowLbl("当前拥有资金:", yColor, self._rootnode["cur_coin_msg_lbl"])  
 end 
 

 function GuildFubenScene:createTab(showType, fbList)  

 	local function selectedTab(tag) 
	    for i = 1, MAX_TYPE do
	        if tag == i then
	            self._rootnode["tab" ..tostring(i)]:selected()
	            self._rootnode["btn" ..tostring(i)]:setZOrder(10)
	        else
	            self._rootnode["tab" ..tostring(i)]:unselected()
	            self._rootnode["btn" ..tostring(i)]:setZOrder(0)
	        end
	    end
	end

    local function onTabBtn(tag) 
        selectedTab(tag) 
    	if tag ~= self._showType then 
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
	        self:setShowType(tag) 
	    end 
    end

    --初始化选项卡
    local function initTab()
        for i = 1, MAX_TYPE do
            self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
        end 
        selectedTab(showType) 
        self:setShowType(showType, fbList)
    end

    initTab() 
 end 


 -- 计算总血量
 function GuildFubenScene:getTotalHp(npcId)
 	local npcData = data_npc_npc[npcId]
 	local hp = 0 
 	for i = 1, 6 do 
 		local cardId = npcData["npc" .. i] 
 		if cardId ~= nil then 
	 		local cardData = ResMgr.getCardData(cardId) 
	 		hp = hp + cardData.base[1] 
	 	end 
 	end 

 	return hp 
 end 


 function GuildFubenScene:createItemData(fbItem, showType)
    local item = game.player:getGuildMgr():getDataByIdAndType(fbItem.fbid, showType) 

    if fbItem.state == FUBEN_STATE.hasPass then 
        if fbItem.rewardState == 0 then 
            fbItem.boxState = FUBEN_REWARD_STATE.canGet 
        elseif fbItem.rewardState == 1 then 
            fbItem.boxState = FUBEN_REWARD_STATE.hasGet  
        end 
    else
        fbItem.boxState = FUBEN_REWARD_STATE.notOpen 
        if fbItem.state == FUBEN_STATE.notOpen then 
            fbItem.needLvMsg = "帮派副本" .. tostring(item.limitlevel) .. "级开启" 
            fbItem.limitlevel = item.limitlevel 
            if item.prefield == 0 then 
                fbItem.openMsg = ""
            else
                fbItem.openMsg = "通关上一副本后解锁"  
            end 
        end 
    end 

    -- 血量
    fbItem.totalHp = self:getTotalHp(item.npc) 
    fbItem.icon = item.icon 

    -- 奖励
    local rewardList = {}
    for j = 1, item.num do 
        local rewardId = item.rewardIds[j] 
        local rewardType = item.rewardTypes[j] 
        local rewardItem 
        local iconType = ResMgr.getResType(rewardType) 
        if iconType == ResMgr.HERO then 
            rewardItem = ResMgr.getCardData(rewardId)
        else
            rewardItem = data_item_item[rewardId] 
        end

        table.insert(rewardList, {
            id = rewardId, 
            type = rewardType,  
            name = rewardItem.name, 
            describe = rewardItem.describe, 
            iconType = iconType, 
            num = item.rewardNums[j] 
            })
    end 

    fbItem.rewardList = rewardList 
 end 


 function GuildFubenScene:setShowType(showType, listData) 
    self._showType = showType 

    local function setData(data, showType)
    	self._listData = data 
    	for i, v in ipairs(self._listData) do 
            local bCanShow = false 
            if v.state == FUBEN_STATE.notOpen then 
                if i == 1 then 
                    bCanShow = true 
                elseif i > 1 and self._listData[i - 1].state == FUBEN_STATE.hasOpen then 
                    bCanShow = true 
                end 
            else
                bCanShow = true 
            end 

            v.bCanShow = bCanShow 

            if v.bCanShow == true then 
        		self:createItemData(v, showType) 
            else
                local item = game.player:getGuildMgr():getDataByIdAndType(v.fbid, showType) 
                v.limitlevel = item.limitlevel 
            end 
    	end 

    	self:reloadListView(self._listData) 
    end 

    if listData ~= nil then 
    	setData(listData, self._showType)
    else
    	self:reqListData(self._showType, function(data)
    			setData(data, self._showType) 
    		end )
    end 
 end 


 function GuildFubenScene:reloadListView(listData)
 	if self._listTable ~= nil then 
 		self._listTable:removeFromParentAndCleanup(true) 
 	end 

    local dataList = {} 

    for i, v in ipairs(listData) do 
        if v.bCanShow == true then 
            table.insert(dataList, v) 
        end 
    end 

    local function showRewardBox(itemData, cell)
        -- 显示奖励信息 
        local msgBox = require("game.guild.guildFuben.GuildFubenRewardMsgBox").new({
            boxState = itemData.boxState, 
            cellDatas = itemData.rewardList, 
            closeFunc = function(cell)
                self._hasShowRewardBox = false 
            end, 
            rewardFunc = function(cell) 
                self._hasShowRewardBox = false 
                self:getReward(self._showType, cell, itemData, msgBox) 
            end 
            })
        self:addChild(msgBox, MAX_ZORDER) 
    end 

    local function showFubenInfoLayer(itemData, showType, cell) 
        game.player:getGuildMgr():RequestFubenInfo({
            id = itemData.fbid, 
            showType = showType, 
            errcb = function()
                self._hasShowRewardBox = false 
            end, 
            cb = function(rtnObj)
                -- 更新此cell 相关的血量、血条、关卡状态、宝箱状态 
                itemData.leftHp = rtnObj.leftHp 
                -- isDead:0死了1没死
                if rtnObj.isDead == 0 then 
                    itemData.state = FUBEN_STATE.hasPass 
                    if itemData.boxState == FUBEN_REWARD_STATE.notOpen then 
                        itemData.boxState = FUBEN_REWARD_STATE.canGet 
                    end 
                end 
                cell:updateHp(itemData) 

                local infoLayer = require("game.guild.guildFuben.GuildFubenInfoLayer").new({ 
                    itemData = itemData, 
                    showType = showType, 
                    rtnObj = rtnObj, 
                    showFunc = function()
                        self._hasShowRewardBox = false            
                    end, 
                })
                self:addChild(infoLayer, MAX_ZORDER) 
            end, 
            })
    end 

 	local itemFileName = "game.guild.guildFuben.GuildFubenCell" 

 	-- 创建 
    local function createFunc(index) 
    	local item = require(itemFileName).new()
    	return item:create({
    		viewSize = self._listViewSize, 
    		itemData = dataList[index + 1], 
    		})
    end

    -- 刷新 
    local function refreshFunc(cell, index)
    	cell:refresh(dataList[index + 1])
    end

    local cellContentSize = require(itemFileName).new():getContentSize()

    self._rootnode["touchNode"]:setTouchEnabled(true)
    local posX = 0
    local posY = 0
    self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        posX = event.x
        posY = event.y
    end)  

    self._listTable = require("utility.TableViewExt").new({
    	size        = self._listViewSize, 
    	direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #dataList, 
        cellSize    = cellContentSize, 
        touchFunc = function(cell) 
            if self._hasShowRewardBox == false then 
            	local icon = cell:getRewardBoxIcon() 
                local itemData = dataList[cell:getIdx() + 1] 
                local pos = icon:convertToNodeSpace(ccp(posX, posY)) 
                if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then
                    self._hasShowRewardBox = true 
                    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
                    showRewardBox(itemData, cell) 
                else
                    -- -- 根据不同的状态，显示不同的信息
                    -- if itemData.state == FUBEN_STATE.notOpen then 
                    --     ResMgr.showErr(2900093) 
                    -- else
                    --     if self._leftCount <= 0 then 
                    --         ResMgr.showErr(2900089) 
                    --     else 
                    --         self._hasShowRewardBox = true 
                    --         showFubenInfoLayer(itemData, self._showType, cell) 
                    --     end 
                    -- end 
                    
                    self._hasShowRewardBox = true 
                    showFubenInfoLayer(itemData, self._showType, cell) 

                    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
                end 
            end 
        end 
    	})

    self._listTable:setPosition(0, 0)
    self._rootnode["listView"]:addChild(self._listTable)
 end 


 function GuildFubenScene:onExit() 
 	if self._checkSchedule ~= nil then 
    	self._scheduler.unscheduleGlobal(self._checkSchedule)
    end

    self._bExit = true 

 	CCTextureCache:sharedTextureCache():removeUnusedTextures() 
 end



 function GuildFubenScene:onEnter()
    game.runningScene = self 
    -- 广播
    if self._bExit == true then
        self._bExit = false
        local broadcastBg = self._rootnode["broadcast_tag"]
        if game.broadcast:getParent() ~= nil then
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end
 end 



 return GuildFubenScene


