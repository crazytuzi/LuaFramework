--[[
 --
 -- add by vicky
 -- 2015.02.09 
 --
 --]]

 require("data.data_error_error") 
 local data_item_item = require("data.data_item_item") 

 local MAX_ZORDER = 100 

 -- 列表类型
 local SHOWTYPE = {
    none = 0, 
 	gem = 1,   -- 珍宝列表 
 	item = 2,  -- 道具列表 
 }


 local GuildShopScene = class("GuildShopScene", function() 
    local bottomFile = "guild/guild_bottom_frame_normal.ccbi" 
    local jopType = game.player:getGuildMgr():getGuildInfo().m_jopType  
    if jopType ~= GUILD_JOB_TYPE.normal then 
        bottomFile = "guild/guild_bottom_frame.ccbi" 
    end 

    return require("game.guild.utility.GuildBaseScene").new({
        contentFile = "guild/guild_shop_layer.ccbi",
        topFile = "guild/guild_shop_up_tab.ccbi",
        bottomFile = bottomFile, 
        adjustSize = CCSizeMake(0, -108) 
        }) 
 end) 


 -- 建筑升级
 function GuildShopScene:reqLevelup(msgBox) 
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
                
                game.player:getGuildInfo():updateData({qinglongLevel = rtnObj.buildLevel, currentUnionMoney = rtnObj.currentUnionMoney}) 
                PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_MSG_DATA) 
                PostNotice(NoticeKey.UPDATE_GUILD_MAINSCENE_BUILD_LEVEL) 

                for i, v in ipairs(self._propDataList) do 
                	if self._level >= v.openLevel then 
		        		v.hasOpen = true 
		        	else 
		        		v.hasOpen = false 
		        	end 
                end 
                if self._showType == GUILD_SHOP_TYPE.prop then 
                	self:reloadListData(self._showType, self._propDataList) 
                end 

                levelupBtn:setEnabled(true) 
            end
        end
    })
 end 


 function GuildShopScene:RequestShopList(showType) 
	RequestHelper.Guild.unionShopList({
		unionId = game.player:getGuildMgr():getGuildInfo().m_id, 
		shopflag = showType, 
        callback = function(data) 
            dump(data) 
            if data.err ~= "" then 
        		dump(data.err)
        	else 
            	local rtnObj = data.rtnObj 
            	local dataList 
            	if showType == GUILD_SHOP_TYPE.gem then 
            		self._leftTime = rtnObj.surplusTime 
            		self._gemDataList = rtnObj.shopListA 
            		dataList = self._gemDataList 

            	elseif showType == GUILD_SHOP_TYPE.prop then 
            		self._propDataList = rtnObj.shopListB  
            		dataList = self._propDataList 
            	end 

            	self:initData(showType, dataList)
				self:reloadListData(showType, dataList) 
            end 
        end 
    }) 
 end 


 function GuildShopScene:checkUnionShopTime()
 	RequestHelper.Guild.checkUnionShopTime({ 
        callback = function(data) 
            dump(data, "更新珍宝", 8) 
            if data.err ~= "" then 
        		dump(data.err)
        	else 
            	local rtnObj = data.rtnObj 
            	self._leftTime = rtnObj.leftTime 
        	
        		self._gemDataList = rtnObj.shopListA 
        		self:initData(GUILD_SHOP_TYPE.gem, self._gemDataList) 

        		if self._showType == GUILD_SHOP_TYPE.gem then 
        			self:reloadListData(self._showType, self._gemDataList) 
        		end 
            end 
        end 
    }) 
 end


 function GuildShopScene:exchangeGoods(showType, count, cell) 
  	local itemData = cell:getItemData() 

  	-- 判断背包空间是否足，如否则提示扩展空间
    local bagObj = {}
    local function extendBag(data)
        -- 更新第一个背包，先判断当前拥有数量是否小于上限，若是则接着提示下一个背包类型需要扩展，否则更新cost和size
        if bagObj[1].curCnt < data["1"] then
            table.remove(bagObj, 1)
        else
            bagObj[1].cost = data["4"]
            bagObj[1].size = data["5"]
        end

        if #bagObj > 0 then
            game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
                bagObj = bagObj,
                callback = function(data)
                    extendBag(data)
                end}), MAX_ZORDER)
        end
    end

  	local function checkBagState(bagList)
  		bagObj = bagList 
  		if #bagObj > 0 then 
            game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
                bagObj = bagObj,
                callback = function(data)
                    extendBag(data)
                end}), MAX_ZORDER) 
        end 
  	end 

 	RequestHelper.Guild.exchangeGoods({ 
 		id = itemData.shopId, 
 		count = count, 
        type = showType,  
        errback = function()
        	cell:setBtnEnabled(true) 
        end, 
        callback = function(data) 
            -- dump(data, "兑换结果", 8)  
            dump(data) 
            if data.err ~= "" then 
        		dump(data.err)
        		cell:setBtnEnabled(true) 
        	else 
            	local rtnObj = data.rtnObj 
            	local isShowRewardMsg = false 

            	-- 道具 
            	if showType == GUILD_SHOP_TYPE.prop then 
	            	-- isrefresh:0不需要刷新 1需要刷新 (到12点的强制刷新，只针对道具商店)
	            	if rtnObj.isrefresh == 0 then 
	            		-- 判断背包状态 
	            		if rtnObj.checkBagList ~= nil and #rtnObj.checkBagList > 0 then 
	            			checkBagState(rtnObj.checkBagList) 
	            		else
	            			-- 刷新数量
		            		itemData.exchange = rtnObj.leftNum 
		            		itemData.had = rtnObj.hadNum  
		            		self:updateData(itemData, self._propDataList)  
		            		isShowRewardMsg = true 
		            		cell:getReward(itemData)  
		            	end 

	            	elseif rtnObj.isrefresh == 1 then 
	            		self._propDataList = rtnObj.shopListB 
	            		self:initData(GUILD_SHOP_TYPE.prop, self._propDataList) 
	            		self:reloadListData(GUILD_SHOP_TYPE.prop, self._propDataList) 
	            	end

	            -- 珍宝
	            elseif showType == GUILD_SHOP_TYPE.gem then 
	            	-- 判断背包状态 
            		if rtnObj.checkBagList ~= nil and #rtnObj.checkBagList > 0 then 
            			checkBagState(rtnObj.checkBagList) 
            		else 
            			isShowRewardMsg = true 
	            		self._gemDataList = rtnObj.shopListA 
	            		self:initData(GUILD_SHOP_TYPE.gem, self._gemDataList) 
	            		self:reloadListData(GUILD_SHOP_TYPE.gem, self._gemDataList) 
	            	end 
	            end 

	            -- 弹出购买的物品确认框
	            if isShowRewardMsg == true then 
                    local cellDatas = {}
                    table.insert(cellDatas, itemData)
                    game.runningScene:addChild(require("game.Huodong.rewardInfo.RewardInfoMsgBox").new({
                            cellDatas = cellDatas, 
                            num = count, 
                        }), MAX_ZORDER)

                     -- 刷新个人贡献  
                     self:updateSelfMoney(rtnObj.lastContribute) 
	            end 
            end 
        end 
    }) 
 end


 -- 更新数量、同一个道具数量都需要更新
 function GuildShopScene:updateData(itemData, dataList)
 	for i, v in ipairs(dataList) do 
 		if itemData.shopId == v.shopId then 
 			v = itemData 
        else
            if v.itemId == itemData.itemId and v.type == itemData.type then 
                v.had = itemData.had 
            end 
 		end 
 	end 
 end 


 function GuildShopScene:ctor(param) 
 	self._buildType = GUILD_BUILD_TYPE.shop 

 	local data = param.data 
 	-- dump(data, "帮派商店", 8) 
 	-- dump(data) 

    local showType = param.showType 
    if showType == nil then 
    	showType = GUILD_SHOP_TYPE.gem 
    end 

    -- 返回
 	self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        GameStateManager:ChangeState(GAME_STATE.STATE_GUILD) 
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

    local function createScrollBg() 
    	local disW = display.width * 0.1 
		local listBgHeight = self._rootnode["node_bg"]:getContentSize().height - self._rootnode["top_node"]:getContentSize().height 
	    local listBg = display.newScale9Sprite("#month_item_bg_bg.png", 0, 0, CCSize(display.width + disW, listBgHeight))
	    listBg:setAnchorPoint(0.5, 0) 
	    listBg:setPosition(display.width/2, 0) 
	    self._rootnode["tag_listview_node"]:addChild(listBg)  

	    local girl = display.newSprite("#guild_shop_girl.png")
	    girl:setAnchorPoint(0, 0.5) 
	    girl:setPosition(disW/2, listBg:getContentSize().height/2) 
	    listBg:addChild(girl) 
	    if girl:getContentSize().height > listBg:getContentSize().height then 
	    	girl:setScale(listBg:getContentSize().height/girl:getContentSize().height)
	    end 

	    self._listViewSize = CCSizeMake(480, listBgHeight - 25) 
	    self._listViewNode = display.newNode() 
	    self._listViewNode:setContentSize(self._listViewSize) 
	    self._listViewNode:setAnchorPoint(1, 0.5) 
	    self._listViewNode:setPosition(display.width + disW - 40, listBgHeight/2) 
	    listBg:addChild(self._listViewNode)

	    self._touchNode = display.newNode() 
	    self._touchNode:setContentSize(self._listViewSize) 
	    self._touchNode:setAnchorPoint(0.5, 0.5) 
	    self._touchNode:setPosition(display.width/2, listBgHeight/2) 
	    listBg:addChild(self._touchNode, 1) 
    end 

    createScrollBg() 

    local rtnObj = data.rtnObj 
    -- 剩余刷新时间
    self._leftTime = rtnObj.surplusTime 

    -- 个人贡献
    self._selfMoney = rtnObj.lastContribute  

    -- 等级、帮派资金 
    self:updateLevel(rtnObj.shopLevel, rtnObj.unionCurrentMoney) 

    self:createAllLbl() 

    if showType == GUILD_SHOP_TYPE.gem then 
    	self._gemDataList = rtnObj.shopListA 

    elseif showType == GUILD_SHOP_TYPE.prop then 
    	self._propDataList = rtnObj.shopListB 

    elseif showType == GUILD_SHOP_TYPE.all then 
    	self._gemDataList = rtnObj.shopListA 
    	self._propDataList = rtnObj.shopListB 

    	showType = GUILD_SHOP_TYPE.gem 
    end 

    self:initData(GUILD_SHOP_TYPE.gem, self._gemDataList) 
    self:initData(GUILD_SHOP_TYPE.prop, self._propDataList) 

    self:createTab(showType) 

    self:initTimeSchedule() 
 end 


 function GuildShopScene:initTimeSchedule() 
 	local function updateTime()
 		if self._leftTime ~= nil and self._leftTime > 0 then 
	 		self._leftTime = self._leftTime - 1 
	 		if self._leftTimeLbl ~= nil then 
	 			self._leftTimeLbl:setString(format_time(self._leftTime)) 
	 		end 

	 		if self._leftTime <= 0 then 
	 			-- 检测时间，刷新数据 
	 			-- 如果当前界面是珍宝 则刷新界面 
	 			self:checkUnionShopTime()
	 		end 
	 	end
 	end

 	self._scheduler = require("framework.scheduler")
    self._checkSchedule = self._scheduler.scheduleGlobal(updateTime, 1, false ) 
 end 


 function GuildShopScene:initData(dataType, data) 
 	if data ~= nil then 
	 	for i, v in ipairs(data) do 
	 		local item 
	        local iconType = ResMgr.getResType(v.type)
	        if iconType == ResMgr.HERO then 
	            item = ResMgr.getCardData(v.itemId)
	        else
	        	item = data_item_item[v.itemId] 
	        end

	        ResMgr.showAlert(item, "服务器端返回的item有问题, itemId: " .. v.itemId .. ", type: " .. v.type) 

	        v.iconType = iconType 
	        v.name = item.name 
	        v.describe = item.describe 
	        v.needReputation = v.cost 
	        local id = v.id 
	        v.id = v.itemId 
	        v.shopId = id 

	        if dataType == GUILD_SHOP_TYPE.prop then 
	        	v.openMsg = "商店" .. tostring(v.openLevel) .. "级开启"  
	        	if self._level >= v.openLevel then 
	        		v.hasOpen = true 
	        	else
	        		v.hasOpen = false 
	        	end 

	        elseif dataType == GUILD_SHOP_TYPE.gem then 
	        	-- hasBuy:0已兑换1未兑换
	        	if v.hasBuy == 0 then 
	        		v.isBuyed = true 
	        	elseif v.hasBuy == 1 then 
	        		v.isBuyed = false 
	        	end 
	        end 
	 	end 
	end 
 end 


 -- 更新等级 
 function GuildShopScene:updateLevel(level, currentUnionMoney) 
    local guildMgr = game.player:getGuildMgr() 
    self._level = level 
    guildMgr:getGuildInfo().m_greenDragonTempleLevel = self._level 
    self._needCoin = guildMgr:getNeedCoin(self._buildType, self._level) 

    self._currentUnionMoney = currentUnionMoney  

    -- 当前等级 
    self:createShadowLbl("LV." .. tostring(self._level), ccc3(255, 222, 0), self._rootnode["cur_level_lbl"])

    -- 当前帮派资金 
    self:createShadowLbl(tostring(self._currentUnionMoney), FONT_COLOR.WHITE, self._rootnode["cur_coin_lbl"])

    self:updateNeedCoinLbl(self._needCoin) 

 end 


 function GuildShopScene:updateNeedCoinLbl(needCoin)
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
    	self._rootnode["levelup_btn"]:setPosition(self._rootnode["levelup_btn"]:getPositionX() + 26, self._rootnode["levelup_btn"]:getPositionY()) 
    end 
 end 


 function GuildShopScene:createShadowLbl(text, color, node, size) 
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
 function GuildShopScene:createAllLbl() 
    local guildMgr = game.player:getGuildMgr() 
    local jopType = guildMgr:getGuildInfo().m_jopType 

    local yColor = ccc3(255, 222, 0) 
    local vColor = ccc3(252, 28, 255) 

    -- 升级消耗资金 
    self:createShadowLbl("升级消耗资金:", yColor, self._rootnode["cost_coin_msg_lbl"])  

    -- 当前拥有资金 
    self:createShadowLbl("当前拥有资金:", yColor, self._rootnode["cur_coin_msg_lbl"])  

    -- 当前拥有贡献 
    self:createShadowLbl("当前拥有贡献:", vColor, self._rootnode["cur_contribute_msg_lbl"])  

    -- 剩余刷新时间 
    self:createShadowLbl("剩余刷新时间:", vColor, self._rootnode["time_msg_lbl"])  
    self._leftTimeLbl = self:createShadowLbl(format_time(self._leftTime), ccc3(0, 219, 52), self._rootnode["left_time_lbl"])  
  	
  	-- 升级帮派商店，会出现更多物品可购买 
	local msgLbl = self:createShadowLbl("升级帮派商店，会出现更多物品可购买", ccc3(255, 144, 0), self._rootnode["tag_levelup_msg"], 18)  
	msgLbl:setPosition(0, -msgLbl:getContentSize().height/2) 

	self:updateSelfMoney(self._selfMoney) 

 end 


 -- 个人贡献 
 function GuildShopScene:updateSelfMoney(money)
 	self._selfMoney = money 
	self:createShadowLbl(tostring(money), ccc3(255, 222, 0), self._rootnode["cur_contribute_lbl"])  
 end 


 function GuildShopScene:selectedTab(tag) 
    for i = 1, 2 do
        if tag == i then
            self._rootnode["tab" ..tostring(i)]:selected()
            self._rootnode["btn" ..tostring(i)]:setZOrder(10)
        else
            self._rootnode["tab" ..tostring(i)]:unselected()
            self._rootnode["btn" ..tostring(i)]:setZOrder(0)
        end
    end
 end
 

 function GuildShopScene:createTab(showType)  
    local function onTabBtn(tag) 
        self:selectedTab(tag) 
    	if tag ~= self._showType then 
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
	        self:setShowType(tag) 
	    end 
    end

    --初始化选项卡
    local function initTab()
        for i = 1, 2 do
            self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
        end 
        self:selectedTab(showType) 
        self:setShowType(showType)
    end

    initTab() 
 end


 function GuildShopScene:setShowType(showType, data) 
    self._showType = showType 

    local guildMgr = game.player:getGuildMgr() 

    if self._showType == GUILD_SHOP_TYPE.gem then 
    	if self._gemDataList == nil then 
	    	self:RequestShopList(self._showType) 
	    else
	    	self._rootnode["tag_time_node"]:setVisible(true) 
	    	self:reloadListData(self._showType, self._gemDataList) 
	    end

    elseif self._showType == GUILD_SHOP_TYPE.prop then 
    	if self._propDataList == nil then 
	    	self:RequestShopList(self._showType) 
	    else 
	    	self._rootnode["tag_time_node"]:setVisible(false) 
	    	self:reloadListData(self._showType, self._propDataList) 
	    end
    end 
 end 


 function GuildShopScene:reloadListData(showType, dataList)
 	if self._listTable ~= nil then 
 		self._listTable:removeFromParentAndCleanup(true) 
 	end 

 	-- 点击图标，显示道具详细信息
    local function onInformation(cell)
        local index = cell:getIdx() + 1
        local icon_data = dataList[index]
        local itemInfo = require("game.Huodong.ItemInformation").new({
            id = icon_data.id,
            type = icon_data.type,
            name = icon_data.name,
            describe = icon_data.describe, 
            endFunc = function() 
                cell:setIconTouchEnabled(true) 
            end
        })
        game.runningScene:addChild(itemInfo, MAX_ZORDER)  
    end

 	local itemFileName = "game.guild.guildShop.GuildShopGemItem" 

 	-- 创建 
    local function createFunc(index) 
    	local item = require(itemFileName).new()
    	return item:create({
    		viewSize = self._listViewSize, 
    		itemData = dataList[index + 1], 
    		showType = showType, 
    		informationFunc = onInformation, 
    		exchangeFunc = function(cell)
    			local idx = cell:getIdx() + 1 
    			local itemData = dataList[idx] 
    			dump("============= exchangeFunc ==========") 
    			
    			if showType == GUILD_SHOP_TYPE.gem then 
    				if self._selfMoney < itemData.cost then 
    					ResMgr.showErr(2900030) 
    					cell:setBtnEnabled(true) 
    				else 
		    			self:exchangeGoods(showType, 1, cell) 
		    		end 

	    		elseif showType == GUILD_SHOP_TYPE.prop then 
	    			itemData.limitNum = itemData.exchange  
	    			self:addChild(require("game.Arena.ExchangeCountBox").new({
				            reputation = self._selfMoney, 
				            itemData = itemData, 
				            shopType = GUILD_SHOP_TYPE,
				            listener = function(num)
				                self:exchangeGoods(showType, num, cell) 
				            end, 
				            closeFunc = function()
				                cell:setBtnEnabled(true) 
				            end
				        }), MAX_ZORDER) 
	    		end 
    		end, 
    		})
    end

    -- 刷新 
    local function refreshFunc(cell, index)
    	cell:refresh(dataList[index + 1])
    end

    local cellContentSize = require(itemFileName).new():getContentSize()

    self._touchNode:setTouchEnabled(true)
    local posX = 0
    local posY = 0
    self._touchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
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
        	if showType == GUILD_SHOP_TYPE.prop then 
        		local idx = cell:getIdx() + 1  
        		if dataList[idx].hasOpen == false then 
	        		local icon = cell:getIcon()
	                local pos = icon:convertToNodeSpace(ccp(posX, posY))
	                if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then 
	                	show_tip_label(data_error_error[2900031].prompt) 
	               	end 
	            end 
        	end 
        end 
    	})

    self._listTable:setPosition(0, 0)
    self._listViewNode:addChild(self._listTable)
 end 


 function GuildShopScene:onExit() 
 	if self._checkSchedule ~= nil then 
    	self._scheduler.unscheduleGlobal(self._checkSchedule)
    end

 	CCTextureCache:sharedTextureCache():removeUnusedTextures() 
 end



 return GuildShopScene 

