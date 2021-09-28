
--[[
 --
 -- add by vicky
 -- 2014.10.20 
 --
 --]]

 local data_yueka_yueka =  require("data.data_yueka_yueka") 
 local data_viplevel_viplevel =  require("data.data_viplevel_viplevel") 
 local data_ui_ui = require("data.data_ui_ui")
 local data_chongzhi_chongzhi =  require("data.data_chongzhi_chongzhi") 
 local data_chongzhi_app_chongzhi = require("data.data_chongzhi_app_chongzhi") 
 local data_item_item = require("data.data_item_item")
 local data_card_card = require("data.data_card_card")
 require("data.data_error_error") 

 local MAX_ZORDER = 3222 

 local ChongzhiLayer = class("ChongzhiLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end) 


 function ChongzhiLayer:getDataList(isRefresh) 
 	RequestHelper.GameIap.main({
		callback = function (data) 
			dump(data) 
			if data["0"] ~= "" then 
				CCMessageBox(data["0"], "error") 
			else 
				self:initData(data, isRefresh) 
			end 
		end
		}) 
 end 


 function ChongzhiLayer:buyItem(itemData, isMonthCard)
 	dump("#############")
 	local isBuyMonthCard = false 
 	if isMonthCard ~= nil and isMonthCard == true then 
 		isBuyMonthCard = isMonthCard 
 	end 

 	if ANDROID_DEBUG or (device.platform == "ios" or device.platform == "android") then
 		dump(itemData)
 		dump("#############")
		local iapMgr = require("game.shop.Chongzhi.IapMgr").new() 
--		game.runningScene:addChild(iapMgr)
--		dump(iapMgr)
		iapMgr:buyGold({
			itemData = itemData, 
			callback = function(data)
				dump("=============================")
				dump("========== buy end ==========")
				dump("=============================")
				-- show_tip_label("充值成功(临时)") 

				-- 月卡不计入首充 
				if isBuyMonthCard == false then 
					game.player:setIsHasBuyGold(true) 
				end 

				local getGold = itemData.chixugold 
				local isFirstBuy = false 
				if not isBuyMonthCard and itemData.buyCnt <= 0 then 
					getGold = itemData.firstgold 
					isFirstBuy = true 
				end 

				local buyEndMsgbox = require("game.shop.Chongzhi.ChongzhiBuyEndMsgbox").new({
					buyGold = itemData.basegold, 
					getGold = getGold, 
					isFirstBuy = isFirstBuy, 
					isBuyMonthCard = isBuyMonthCard  
					})
				game.runningScene:addChild(buyEndMsgbox, MAX_ZORDER) 

				self:getDataList(true)  
			end
			})
    else
        dump("#######++++++++++++++++++++++++++++++++######")
	end  
 end 


 function ChongzhiLayer:ctor() 
 	self._curInfoIndex = -1 
 	
 	local proxy = CCBProxy:create() 
 	self._rootnode = {} 
	self._totalSize = CCSizeMake(640, display.height - 45)  
	if self._totalSize.height > 900 then 
		self._totalSize.height = 900 
	elseif self._totalSize.height < 650 then 
		self._totalSize.height = 650 
	end 

	self._node = CCBuilderReaderLoad("ccbi/shop/shop_chongzhi_layer.ccbi", proxy, self._rootnode, self, self._totalSize)  
 	self._node:setPosition(display.cx, display.cy) 
 	self:addChild(self._node) 

 	if game.player:getAppOpenData().c_yueka == APPOPEN_STATE.close then 
 		self._rootnode["tag_appStore_bg"]:setVisible(true)
 	else
 		self._rootnode["tag_appStore_bg"]:setVisible(false) 
 	end 

 	self._rootnode["title_sprite"]:setPosition(display.cx, self._totalSize.height - 10) 

 	self._rootnode["tag_close"]:addHandleOfControlEvent(function()
 		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
 			self:removeFromParentAndCleanup(true) 
 		end, CCControlEventTouchUpInside) 

 	self:getDataList(false)  
 end 


 function ChongzhiLayer:initData(data, isRefresh)  
 	self._vipData = data.rtnObj.vipData 
 	self._listData = data.rtnObj.list 
 	self._monthcardData = data.rtnObj.yueData 

 	-- 获取appstore充值开关
 	game.player:setAppOpenData(data.rtnObj.extend) 

 	-- 更新元宝 lbl 
 	local curGold = data.rtnObj.curGold -- 当前元宝数
 	game.player:updateMainMenu({ gold = curGold, vip = self._vipData.level }) 

 	PostNotice(NoticeKey.CommonUpdate_Label_Gold)
 	PostNotice(NoticeKey.MainMenuScene_Update)

 	self._isFullVip = true 	-- 是否已达到VIP上限 
 	local viplevelData 
 	local nextVipLv = self._vipData.level + 1 
 	for i, v in ipairs(data_viplevel_viplevel) do 
 		if v.vip == nextVipLv and v.open == 1 then 
 			viplevelData = v 
 			self._isFullVip = false 
 		end 
 	end 

 	self:initAllNodePos() 

 	self:initTopVipInfo(isRefresh) 

 	if self._isFullVip then 
 		-- 隐藏豪华礼包、月卡和底部信息上移动 
 		self._rootnode["vipReward_node"]:setVisible(false) 
 		local height = self._rootnode["vipReward_node"]:getContentSize().height - 10 
 		self._rootnode["monthCard_node"]:setPositionY(self._rootnode["monthCard_node"]:getPositionY() + height) 
 	else 
	 	self:initVipRewardInfo(viplevelData) 
	end 

	if not isRefresh then 
		self:initMonthCardDataInfo() 
	end 

	self:initShopItemDataInfo(isRefresh) 

	-- 查看vip特权 
	local checkVipBtn = self._rootnode["checkVipBtn"] 
	if game.player:getAppOpenData().c_vipbtn == APPOPEN_STATE.close then 
		checkVipBtn:setVisible(false) 
	else 
		checkVipBtn:setVisible(true)  
		if not isRefresh then 
		 	checkVipBtn:addHandleOfControlEvent(function()
		 		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
		 		checkVipBtn:setEnabled(false)  
				local vipInfoLayer = require("game.shop.Chongzhi.ChongzhiVipDesInfoLayer").new({
			        curVipLv = self._vipData.level, 
			        curVipExp = self._vipData.curExp,  
			        vipExpLimit = self._vipData.curExpLimit, 
			        confirmFunc = function() 
			        	checkVipBtn:setEnabled(true) 
			        end 
		        }) 

			    game.runningScene:addChild(vipInfoLayer, self:getZOrder() + 1)  

			end, CCControlEventTouchUpInside) 
		end 
	end 
 end 


 -- 根据屏幕尺寸 放置各个信息位置 
 function ChongzhiLayer:initAllNodePos() 
 	local height = 0 

 	self._rootnode["top_node"]:setPositionY(self._totalSize.height - 60) 
 	height = height + self._rootnode["top_node"]:getContentSize().height + 60 

 	self._rootnode["vipReward_node"]:setPositionY(self._totalSize.height - height + 40) 
 	height = height + self._rootnode["vipReward_node"]:getContentSize().height - 40  

 	self._rootnode["monthCard_node"]:setPositionY(self._totalSize.height - height) 
 	height = height + self._rootnode["monthCard_node"]:getContentSize().height 

 	local shopBgViewSize = CCSizeMake(615, self._totalSize.height - height - 15)  
 	if self._isFullVip then 
 		shopBgViewSize.height = shopBgViewSize.height + self._rootnode["vipReward_node"]:getContentSize().height - 40 
 	end 
 	self._shopItemViewSize = CCSizeMake(shopBgViewSize.width, shopBgViewSize.height - 20)  

 	-- 背景
 	self._rootnode["listView_node"]:removeAllChildren() 

 	self._shopItemBg = display.newScale9Sprite("#cz_item_innerBg.png", 0, 0, shopBgViewSize) 
    self._shopItemBg:setAnchorPoint(0.5, 0)
    self._shopItemBg:setPosition(self._rootnode["listView_node"]:getContentSize().width/2, 0)
    self._rootnode["listView_node"]:addChild(self._shopItemBg)

 	self._listViewNode = display.newNode()
    self._listViewNode:setContentSize(self._shopItemViewSize)
    self._listViewNode:setAnchorPoint(0.5, 0.5)
    self._listViewNode:setPosition(self._rootnode["listView_node"]:getContentSize().width/2, shopBgViewSize.height/2)
    self._rootnode["listView_node"]:addChild(self._listViewNode)

    self._listViewTouchNode = display.newNode() 
    self._listViewTouchNode:setContentSize(self._shopItemViewSize) 
    self._listViewTouchNode:setAnchorPoint(0.5, 0.5)
    self._listViewTouchNode:setPosition(self._rootnode["listView_node"]:getContentSize().width/2, shopBgViewSize.height/2)
    self._rootnode["listView_node"]:addChild(self._listViewTouchNode) 

 end


 function ChongzhiLayer:initTopVipInfo(isRefresh)  
 	self._rootnode["cur_vip_level_lbl"]:setString(tostring(self._vipData.level)) 
 	self._rootnode["vip_exp_lbl"]:setString(tostring(self._vipData.curExp) .. "/" .. tostring(self._vipData.curExpLimit)) 
 	local percent = self._vipData.curExp/self._vipData.curExpLimit 

 	if self._isFullVip then 
 		percent = 1 
 		-- self._rootnode["vip_exp_lbl"]:setString(tostring(self._vipData.curExp) .. "/MAX") 
 		self._rootnode["tag_fullVip_node"]:setVisible(true)
 		self._rootnode["next_vip_need_node"]:setVisible(false) 
 		self._rootnode["tag_vip_reward_msg"]:setVisible(false) 
 		self._rootnode["tag_full_gold_lbl"]:setString("您当前已充值" .. tostring(self._vipData.curExp))
 		arrangeTTFByPosX({
 			self._rootnode["tag_full_gold_lbl"], 
 			self._rootnode["tag_full_gold_icon"] 
 			}) 
 	else 
 		self._rootnode["tag_fullVip_node"]:setVisible(false) 
 		self._rootnode["next_vip_need_node"]:setVisible(true)
 		self._rootnode["top_next_vip_lbl"]:setString(tostring(self._vipData.level + 1)) 

 		local needGold = self._vipData.curExpLimit - self._vipData.curExp 

 		if self._vipData.level <= 0 then 
 			self._rootnode["tag_vip_reward_msg"]:setVisible(false) 
 			self._rootnode["tag_needGold_num_lbl"]:setString("充值" .. tostring(needGold)) 
 			self._rootnode["next_vip_need_node"]:setPositionY(self._rootnode["tag_fullVip_node"]:getPositionY()) 
 		else 
 			self._rootnode["tag_vip_reward_msg"]:setVisible(true) 
 			self._rootnode["tag_needGold_num_lbl"]:setString("再充值" .. tostring(needGold)) 
 			self._rootnode["next_vip_need_node"]:setPositionY(self._rootnode["tag_fullVip_node"]:getPositionY() + 17)  
 		end 

 		arrangeTTFByPosX({
 			self._rootnode["tag_needGold_num_lbl"], 
 			self._rootnode["tag_needGold_icon"] 
 			})
 	end 

 	local addBar = self._rootnode["vip_addBar"] 
 	local normalBar = self._rootnode["vip_normalBar"] 
 	addBar:setTextureRect(CCRectMake(addBar:getTextureRect().origin.x, addBar:getTextureRect().origin.y, 
        normalBar:getContentSize().width * percent, normalBar:getTextureRect().size.height)) 

 end 


 function ChongzhiLayer:initVipRewardInfo(viplevelData)
 	local cellDatas = {} 
 	-- 若未充值过则显示首充礼包，否则显示下个vip等级可获得的礼包
 	if self._vipData.level <= 0 then 
 		self._rootnode["first_title_node"]:setVisible(true) 
 		self._rootnode["first_titleEffect_icon"]:setVisible(true) 
 		self._rootnode["vip_title_node"]:setVisible(false) 
 		self._rootnode["vip_titleEffect_icon"]:setVisible(false) 

 		local shouchongData = data_yueka_yueka[1] 
	    for i = 1, shouchongData.num do 
	        local type = shouchongData.arr_type[i] 
	        ResMgr.showAlert(type, "data_yueka_yueka表，月卡赠送物品的type数量和num数量不匹配")
	        local num = shouchongData.arr_num[i]  
	        ResMgr.showAlert(num, "data_yueka_yueka表，月卡赠送物品的num数量和num数量不匹配")
	        local itemId = shouchongData.arr_item[i] 
	        ResMgr.showAlert(itemId, "data_yueka_yueka表，月卡赠送物品的item数量和num数量不匹配")

	        local iconType = ResMgr.getResType(type)
	        local itemInfo 
	        if iconType == ResMgr.HERO then 
	            itemInfo = data_card_card[itemId] 
	        elseif iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then 
	            itemInfo = data_item_item[itemId] 
	        else
	            ResMgr.showAlert(itemId, "data_yueka_yueka表，月卡赠送物品的数据不对index:" .. i) 
	        end 

	        table.insert(cellDatas,  {
	            id = itemId, 
	            name = itemInfo.name, 
	            num = num, 
	            type = type, 
	            iconType = iconType, 
	            describe = itemInfo.describe or ""  
	            })
	    end 
 	else
 		self._rootnode["first_titleEffect_icon"]:setVisible(false) 
 		self._rootnode["first_title_node"]:setVisible(false)
 		self._rootnode["vip_title_node"]:setVisible(true)
 		self._rootnode["vip_titleEffect_icon"]:setVisible(true)
 		self._rootnode["next_vip_level_lbl"]:setString(self._vipData.level + 1)  

		for i, v in ipairs(viplevelData.arr_type1) do 
			local itemId = viplevelData.arr_item1[i] 
			local num = viplevelData.arr_num1[i] 
			ResMgr.showAlert(itemId, "data_viplevel_viplevel数据表，VIP配置的升级奖励id没有，vip: " .. tostring(self._vipData.level + 1) .. ", type:" .. v .. ", id:" .. itemId) 
			ResMgr.showAlert(num, "data_viplevel_viplevel数据表，VIP配置的升级奖励num没有，vip: " .. tostring(self._vipData.level + 1) .. ", type:" .. v .. ", id:" .. itemId) 

			local iconType = ResMgr.getResType(v) 
			local itemInfo
			if iconType == ResMgr.HERO then 
				itemInfo = data_card_card[itemId] 
			else 
				itemInfo = data_item_item[itemId] 
			end 
			ResMgr.showAlert(itemInfo, "data_viplevel_viplevel数据表，arr_type1和arr_item1对应不上，vip：" .. tostring(self._vipData.level + 1) .. ", type:" .. v .. ", id:" .. itemId) 

			table.insert(cellDatas, {
				id = itemId, 
				type = v, 
				num = num, 
				iconType = iconType, 
				name = itemInfo.name, 
				describe = itemInfo.describe or ""  
				})
		end 
	end 

	local boardWidth = self._rootnode["vip_reward_listView"]:getContentSize().width 
	local boardHeight = self._rootnode["vip_reward_listView"]:getContentSize().height

    -- 创建
    local function createFunc(index)
    	local item = require("game.shop.Chongzhi.ChongzhiRewardItem").new()
    	return item:create({
    		id = index, 
    		itemData = cellDatas[index + 1], 
    		informationListener = function(cell)
    			local index = cell:getIdx() + 1 
    			local itemData = cellDatas[index + 1] 
		        local itemInfo = require("game.Huodong.ItemInformation").new({
		            id = itemData.id,
		            type = itemData.type,
		            name = itemData.name,
		            describe = itemData.describe
	            })
		        game.runningScene:addChild(itemInfo, self:getZOrder() + 1) 
	    	end 
    		})
    end

    -- 刷新
    local function refreshFunc(cell, index)
    	cell:refresh({
            index = index, 
            itemData = cellDatas[index + 1]
            })
    end

    local cellContentSize = require("game.shop.Chongzhi.ChongzhiRewardItem").new():getContentSize()

    if self.ListTable ~= nil then 
		self.ListTable:removeFromParentAndCleanup(true)
	end

    self.ListTable = require("utility.TableViewExt").new({
    	size        = CCSizeMake(boardWidth, boardHeight), 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #cellDatas, 
        cellSize    = cellContentSize, 
        touchFunc   = function(cell)
        	if self._curInfoIndex ~= -1 then 
        		return 
        	end 

            local idx = cell:getIdx() + 1 
            self._curInfoIndex = idx 

            local itemData = cellDatas[idx] 
	        local itemInfo = require("game.Huodong.ItemInformation").new({
		            id = itemData.id,
		            type = itemData.type,
		            name = itemData.name,
		            describe = itemData.describe, 
		            endFunc = function() 
                        self._curInfoIndex = -1 
                    end 
	            })
	        game.runningScene:addChild(itemInfo, self:getZOrder() + 1) 
        end
    	})

    self.ListTable:setPosition(0, 0)
    self._rootnode["vip_reward_listView"]:addChild(self.ListTable) 
 end 


 function ChongzhiLayer:initMonthCardDataInfo()
 	-- 查看月卡
 	self._rootnode["month_checkBtn"]:addHandleOfControlEvent(function()
 		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
 		
 		if GameStateManager.currentState == GAME_STATE.STATE_JINGCAI_HUODONG then 
 			game.runningScene:changeShowLayer(nbActivityShowType.MonthCard)
			self:removeFromParentAndCleanup(true) 
		else
			GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.MonthCard) 
		end 

	end, CCControlEventTouchUpInside) 

 	-- 月卡充值
 	self._rootnode["month_chongzhiBtn"]:addHandleOfControlEvent(function()
 		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
 		if not ENABLE_IAP_BUY then 
			show_tip_label("暂未开放")
		else
	 		if self._monthcardData.isCanBuy == 1 then 
	 			local _productID = nil
			 	if CSDKShell.GetSDKTYPE() == CSDKShell.SDKTYPES.IOS_APPSTORE_HANS then 
			 		_productID = data_chongzhi_app_chongzhi[7].appid 
			 	else
			 		_productID = tostring(self._monthcardData.type) 
			 	end 
	 			local msgBox = require("game.shop.Chongzhi.ChongzhiBuyMonthCardMsgbox").new({
	 				leftDay = self._monthcardData.days or 0, 
	 				confirmListen = function()
	 					local itemData = {}
			 			itemData.price = self._monthcardData.cost 
			 			itemData.basegold = self._monthcardData.goldget 
			 			itemData.index = "" 
			 			itemData.type = self._monthcardData.type 
			 			itemData.productName = "月卡"  
			 			itemData.payitemId = _productID
			 			itemData.isMonthCard = true 
			 			itemData.coolpadItemId = 1 	-- 酷派商品编号 
			 			self:buyItem(itemData, true)
		 			end
	 				})

	 			self:addChild(msgBox, MAX_ZORDER) 
	 		else
	 			show_tip_label(data_error_error[1800].prompt)
	 		end 
	 	end 
	end, CCControlEventTouchUpInside) 
 end 


 function ChongzhiLayer:initShopItemDataInfo(isRefresh)  
	self._shopItemData = {} 
	local tmpShopItemData = {} 

 	for i, v in ipairs(self._listData) do 
 		local data 
	 	if CSDKShell.GetSDKTYPE() == CSDKShell.SDKTYPES.IOS_APPSTORE_HANS then 
	 		data = data_chongzhi_app_chongzhi[v.index] 
	 	else
	 		data = data_chongzhi_chongzhi[v.index]  
	 	end 

 		local isShowMark = false 

 		if v.cnt <= 0 and data.mark1 == 1 then 
 			isShowMark = true 
 		end 
 		local _productID = nil
	 	if CSDKShell.GetSDKTYPE() == CSDKShell.SDKTYPES.IOS_APPSTORE_HANS then 
	 		_productID = data_chongzhi_app_chongzhi[v.index].appid 
	 	else
	 		_productID = tostring(v.type) .. "_" .. tostring(v.index)
	 	end 
 		table.insert(tmpShopItemData, {
 			index = v.index, 
 			type = v.type, 
 			buyCnt = v.cnt,  
 			order = data.order, 
 			price = v.coinnum,   			
 			-- price = 1, 
 			basegold = data.basegold, 		-- 可兑换基础元宝数 
 			firstgold = data.firstgold, 	-- 首次赠送元宝数 
 			chixugold = data.chixugold, 	-- 持续赠送元宝数 
 			iconImgName = "#" .. data.icon .. ".png", 
 			isShowMark = isShowMark, 
 			productName = tostring(data.basegold) .. "元宝", 
 			payitemId =  _productID, --tostring(v.type) .. "_" .. tostring(v.index), 
 			isMonthCard = false, 
 			coolpadItemId = v.index + 1 
		}) 
 	end 

 	for i = 1, #tmpShopItemData do 
 		for j, v in ipairs(tmpShopItemData) do 
 			if v.order == i then 
 				table.insert(self._shopItemData, v) 
 				break 
 			end 
 		end 
 	end  

 	local num 
    if #self._listData%3 == 0 then 
        num = #self._listData/3 
    else 
        num = #self._listData/3 + 1 
    end 

    local startIndex = 0 
 	local allItemData = {} 
 	for i = 1, num do 
 		local itemData = {} 
 		for j = 1, 3 do 
 			local index = startIndex + j 
 			-- dump("index: " .. index)
 			if index <= #self._shopItemData then 
	 			table.insert(itemData, self._shopItemData[index])  
	 		end
 		end 
 		startIndex = startIndex + 3 
 		table.insert(allItemData, itemData) 
 	end 


 	local function buyListen(index, tag, closeListener)
		local buyItemData = allItemData[index][tag] 
		dump("购买index: " .. buyItemData.index .. ", tag: " .. tag) 

		if not ENABLE_IAP_BUY then 
			show_tip_label("暂未开放")
		else
			self:buyItemMsgbox({
				itemData = buyItemData, 
				buyFunc = function()
	 				if buyItemData ~= nil then 
	 					self:buyItem(buyItemData) 
	 				end
	 			end,
	 			closeListener = closeListener
			})
		end 
	end

 	local cellContentSize = require("game.shop.Chongzhi.ChongzhiItem").new():getContentSize() 

 	-- 创建
    local function createFunc(index) 
    	local item = require("game.shop.Chongzhi.ChongzhiItem").new()
    	return item:create({
    		viewSize = self._shopItemViewSize, 
            itemData = allItemData[index + 1] 
    		})
    end

    -- 刷新
    local function refreshFunc(cell, index) 
    	cell:refresh(allItemData[index + 1])
    end

    self._listViewTouchNode:setTouchEnabled(true) 
    local posX = 0
    local posY = 0
    self._listViewTouchNode:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        posX = event.x
        posY = event.y
    end) 

    self._shopListView = require("utility.TableViewExt").new({
    	size        = self._shopItemViewSize, 
        direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #allItemData, 
        cellSize    = cellContentSize,
        touchFunc = function(cell)
            local idx = cell:getIdx()
            for i = 1, 3 do
                local icon = cell:getIcon(i)
                local pos = icon:convertToNodeSpace(ccp(posX, posY))
                if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then
                	self._shopListView:setTouchEnabled(false)
                    buyListen(idx + 1, i, function ( ... )                    	
                    	self._shopListView:setTouchEnabled(true)
                    end) 
                    break
                end
            end
        end
    	})

    self._listViewNode:removeAllChildren() 
    self._listViewNode:addChild(self._shopListView) 
    
 end 


 function ChongzhiLayer:buyItemMsgbox(param)
 	local buyFunc = param.buyFunc 
 	local itemData = param.itemData 
 	local rowAll = {} 
 	local closeListener = param.closeListener

 	local yellow = ccc3(255, 210, 0)
 	local white = ccc3(255, 255, 255) 
 	local black = ccc3(0, 0, 0) 
 	local size = 24 

 	if itemData.buyCnt <= 0 then 
 		local rowOneTable = {} 

		local lvTTF_1 = ResMgr.createOutlineMsgTTF({text = "购", color = white, outlineColor = black, size = size})
		local lvTTF_2 = ResMgr.createOutlineMsgTTF({text = tostring(itemData.basegold), color = yellow, outlineColor = black, size = size})
		local lvTTF_3 = ResMgr.createOutlineMsgTTF({text = "元宝送", color = white, outlineColor = black, size = size})
		local lvTTF_4 = ResMgr.createOutlineMsgTTF({text = tostring(itemData.firstgold), color = yellow, outlineColor = black, size = size})
		local lvTTF_5 = ResMgr.createOutlineMsgTTF({text = "元宝!", color = white, outlineColor = black, size = size})

	    local rowOneTable = {lvTTF_1, lvTTF_2, lvTTF_3, lvTTF_4, lvTTF_5} 

	    local rowTwoTable = {}
	    local lvTTF_Two_1 = ResMgr.createOutlineMsgTTF({text = "限购", color = white, outlineColor = black, size = size})
	    local lvTTF_Two_2 = ResMgr.createOutlineMsgTTF({text = "1", color = yellow, outlineColor = black, size = size})
	    local lvTTF_Two_3 = ResMgr.createOutlineMsgTTF({text = "次!", color = white, outlineColor = black, size = size}) 

	    local rowTwoTable = {lvTTF_Two_1, lvTTF_Two_2, lvTTF_Two_3}
	    rowAll = {rowOneTable, rowTwoTable} 

	else
		local rowOneTable = {} 
	    local lvTTF_1 = ResMgr.createOutlineMsgTTF({text = "确定要花费", color = white, outlineColor = black, size = size})
		local lvTTF_2 = ResMgr.createOutlineMsgTTF({text = tostring(itemData.price) .. "元", color = yellow, outlineColor = black, size = size})
		local lvTTF_3 = ResMgr.createOutlineMsgTTF({text = "购买", color = white, outlineColor = black, size = size})
		local lvTTF_4 = ResMgr.createOutlineMsgTTF({text = tostring(itemData.basegold), color = yellow, outlineColor = black, size = size})
		local lvTTF_5 = ResMgr.createOutlineMsgTTF({text = "元宝吗?", color = white, outlineColor = black, size = size})

	    local rowOneTable = {lvTTF_1, lvTTF_2, lvTTF_3, lvTTF_4, lvTTF_5} 
	    rowAll = {rowOneTable}
 	end 

	local msg = require("utility.MsgBoxEx").new({
		resTable = rowAll,
		confirmFunc = function(node) 
			if buyFunc ~= nil then 
				buyFunc()
			end
			if(closeListener ~= nil) then
				closeListener()
			end
			node:removeFromParentAndCleanup(true) 
		end,
		closeListener = closeListener
		})
	
	game.runningScene:addChild(msg, MAX_ZORDER) 
 end



 return ChongzhiLayer 
