--[[
 --
 -- add by vicky
 -- 2015.03.12  
 --
 --]]

 local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben") 
 local MAX_ZORDER = 11 

 local ChallengeFubenLayer = class("ChallengeFubenLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end)


 function ChallengeFubenLayer:ctor(param)
 	local refreshCellFunc = param.refreshCellFunc 
 	self._fbId = param.fbId
 	rtnObj = param.rtnObj 
 	dump(rtnObj, "副本详情") 

 	local attrack = rtnObj.attrack 
 	self._level = rtnObj.level 	
 	self._cards = rtnObj.cards 
 	self._formHero = {} 

 	local fbInfo = self:getFbInfo(self._fbId) 

 	local height = display.height 
 	if height > 960 then 
 		height = 960 
 	end 

 	local proxy = CCBProxy:create()
 	self._rootnode = {}
 	local node = CCBuilderReaderLoad("ccbi/challenge/challengeFuben_layer.ccbi", proxy, self._rootnode, self, CCSizeMake(display.width, height)) 
 	node:setPosition(display.cx, display.cy)
 	self:addChild(node)

 	self._rootnode["titleLabel"]:setString("挑战副本") 
 	self._rootnode["rest_num"]:setString(tostring(HuoDongFuBenModel.getRestNum(self._fbId))) 

 	-- 阵容预览
 	self:setFormation(self._cards, attrack) 

 	-- 关闭按钮
 	self._rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        self:removeFromParentAndCleanup(true)  
    end, CCControlEventTouchUpInside) 

    -- 购买挑战次数 
    local buyBtn = self._rootnode["buy_btn"]
    dump(fbInfo.isbuy) 

    if fbInfo.isbuy == 1 then 
    	buyBtn:setVisible(true) 
	 	buyBtn:addHandleOfControlEvent(function(eventName,sender) 
	 		if HuoDongFuBenModel.getRestNum(self._fbId) > 0 then 
	 			ResMgr.showMsg(6) 
	 		else 
		 		buyBtn:setEnabled(false) 
		 		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
		 		local buyMsgBox = require("game.Challenge.HuoDongBuyMsgBox").new({
		 			aid = self._fbId,
		 			closeFunc = function()
		 				buyBtn:setEnabled(true) 
		 			end, 
		 			removeListener = function() 
		 				self._rootnode["rest_num"]:setString(tostring(HuoDongFuBenModel.getRestNum(self._fbId))) 
		 				if refreshCellFunc ~= nil then 
		 					refreshCellFunc() 
		 				end 
		 				buyBtn:setEnabled(true) 
		 			end
		 			})
		      	game.runningScene:addChild(buyMsgBox, self:getZOrder() + 1) 
		    end 
	 	end, CCControlEventTouchUpInside)   

	elseif fbInfo.isbuy == 0 then 
		buyBtn:setVisible(false) 
	end 

	-- 查看概率掉落 
	local checkBtn = self._rootnode["check_reward_btn"]
 	checkBtn:addHandleOfControlEvent(function(eventName,sender)
 		checkBtn:setEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        local layer = require("game.ChallengeFuben.ChallengeFubenRewardLayer").new({
        		rewardList = self._rewardList, 
        		closeFunc = function()
        			checkBtn:setEnabled(true) 
        		end 
        	})
        game.runningScene:addChild(layer, self:getZOrder() + 1) 
    end, CCControlEventTouchUpInside)   

 	-- 布阵按钮 
    local buzhenBtn = self._rootnode["buzhen_btn"] 
    buzhenBtn:addHandleOfControlEvent(function(eventName,sender)
 		buzhenBtn:setEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        push_scene(require("game.ChallengeFuben.ChallengeFubenChooseHeroScene").new({
				fbId = self._fbId, 
				sysId = fbInfo.sys_id, 
				cards = self._cards, 
				formHero = self._formHero, 
				showFunc = function()
					buzhenBtn:setEnabled(true)
				end, 
				changeFormaitonFunc = function(cards, power, fmt)
					self._cards = cards
					self._fmt = fmt 
					self:setFormation(self._cards, power) 
				end 
			}))
    end, CCControlEventTouchUpInside)   

 	-- 底部listView框
 	local sizeH = node:getContentSize().height - self._rootnode["top_node"]:getContentSize().height - self._rootnode["bottom_node"]:getPositionY() 
 	local sizeW = self._rootnode["tag_zhenrong"]:getContentSize().width 
 	local bottomBg = display.newScale9Sprite("#levelinfo_boss_bg2.png", 0, 0, CCSizeMake(sizeW, sizeH)) 
 	bottomBg:setAnchorPoint(0.5, 0) 
 	bottomBg:setPosition(node:getContentSize().width/2, 0) 
 	self._rootnode["bottom_node"]:addChild(bottomBg) 

 	self._listViewSize = CCSizeMake(sizeW, sizeH - self._rootnode["listTile_icon"]:getContentSize().height/2 - 5) 
 	self._listViewNode = display.newNode()
 	self._listViewNode:setContentSize(self._listViewSize) 
 	self._listViewNode:setAnchorPoint(0.5, 0) 
 	self._listViewNode:setPosition(node:getContentSize().width/2, 3) 
 	self._rootnode["bottom_node"]:addChild(self._listViewNode) 

 	self._rootnode["title_lbl"]:setString("挑战." .. fbInfo.title) 
 	self._rootnode["describe_lbl"]:setString(fbInfo.description) 

 	-- 副本列表数据 
 	local fbDataList = {} 
 	self._rewardList = {}
 	for i = 1, fbInfo.diff_cnt do 
 		local fbData = {}
 		fbData.diffBg = fbInfo.arr_diff_bg[i] 
 		fbData.needLv = fbInfo.arr_prebattle[i] 
 		fbData.fight = fbInfo.arr_fight[i] 
 		fbData.hardMsg = fbInfo.arr_diff_name[i]  
 		if self._level >= fbData.needLv then 
	 		fbData.isOpen = true 	
	 	else
	 		fbData.isOpen = false 
	 	end 
	 	table.insert(fbDataList, fbData) 

	 	local rewardItem = {}
	 	rewardItem.arr_id = fbInfo.dropid[i] 
	 	rewardItem.arr_type = fbInfo.droptype[i] 
	 	rewardItem.iconName = fbInfo.arr_diff_bg[i] 
	 	table.insert(self._rewardList, rewardItem) 
 	end 

 	self:createFbListView(fbDataList) 

 end


 -- 剩余战斗次数 
 function ChallengeFubenLayer:setLeftTimes(times)
 	HuoDongFuBenModel.setRestNum(self._fbId, times)  
 	self._rootnode["rest_num"]:setString(tostring(times)) 
 end 


 function ChallengeFubenLayer:getfmtstr()
 	if #self._formHero <= 0 then 
 		self._formHero = {}
	 	for i = 1, 6 do 
		 	for j, v in ipairs(self._cards) do 
		 		if v.pos == i then 
		 			table.insert(self._formHero, {
		 				index = j, 
		 				pos = v.pos 
		 				}) 
		 			break 
		 		end 
		 	end 
		end 
	end 

 	local str = "["
    for k, v in ipairs(self._formHero) do
        local hero = self._cards[v.index] 
        if hero ~= nil then
            str = str .. string.format("[%s,%d],", hero.cardId, v.pos)
        end
    end
    str = str .. "]"
    return str
 end 


 -- 设置阵容预览 
 function ChallengeFubenLayer:setFormation(cards, power)
 	self._rootnode["zhanli_lbl"]:setString(tostring(power)) 

 	self._formHero = {} 
 	local indexList = {} 
 	for i, v in ipairs(cards) do 
 		if v.pos > 0 then 
 			table.insert(indexList, v.pos) 
 			table.insert(self._formHero, {
 				index = i, 
 				pos = v.pos 
 				})
 			local icon = self._rootnode["zhenrong_icon_" .. v.pos] 
	 		icon:setVisible(true) 
	 		ResMgr.refreshIcon({
	            id = v.resId, 
	            cls = v.cls, 
	            resType = ResMgr.HERO, 
	            itemBg = icon, 
	            iconNum = 1, 
	            isShowIconNum = false 
	        }) 
	    end 
 	end 

 	if #indexList < 6 then 
 		local function checkIsFind(pos)
 			local bFind = false 
 			for i, v in ipairs(indexList) do 
 				if v == pos then 
 					bFind = true 
 					break 
 				end 
 			end 
 			return bFind 
 		end 
 		for i = 1, 6 do 
 			if checkIsFind(i) == false then 
 				self._rootnode["zhenrong_icon_" .. i]:setVisible(false) 
 			end 
 		end 
 	end 
 end 


 function ChallengeFubenLayer:getFbInfo(fbId) 
 	local fbInfo = data_huodongfuben_huodongfuben[fbId] 
 	ResMgr.showAlert(fbInfo, "data_huodongfuben_huodongfuben表里没有此id: " .. fbId) 

 	return fbInfo 
 end 


 function ChallengeFubenLayer:createFbListView(fbDataList)
 	local itemFileName = "game.ChallengeFuben.ChallengeFubenCell"

 	local function toBat(cell, fmt) 
 		local fbInfo = self:getFbInfo(self._fbId) 
 		local scene = require("game.Challenge.HuoDongBattleScene").new({
				fubenid = self._fbId, 
				sysId = fbInfo.sys_id, 
				npcLv = cell:getIdx() + 1, 
				fmt = fmt, 
				errback = function()
					cell:setBtnEnabled(true) 
				end, 
				endFunc = function(bIsWin) 
					pop_scene() 
					cell:setBtnEnabled(true) 
					if bIsWin == true then 
						local times = HuoDongFuBenModel.getRestNum(self._fbId) - 1 
						self:setLeftTimes(times) 
					end 
				end
			})
        push_scene(scene) 
 	end 

 	-- 创建 
    local function createFunc(index) 
    	local item = require(itemFileName).new()
    	return item:create({
    		viewSize = self._listViewSize, 
    		itemData = fbDataList[index + 1], 
    		challengFunc = function(cell) 
    			if self._fmt == nil then 
    				self._fmt = self:getfmtstr() 
    			end 
    			if #self._formHero < 6 then 
    				local tipLayer = require("game.huashan.HuaShanHeroLessTip").new({
    					listener = function() 
    						toBat(cell, self._fmt) 
    					end, 
    					closeFunc = function()
    						cell:setBtnEnabled(true) 
    					end, 
    					}) 
		            game.runningScene:addChild(tipLayer, self:getZOrder() + 1)
    			else
    				toBat(cell, self._fmt) 
    			end 
    		end
    		})
    end

    -- 刷新 
    local function refreshFunc(cell, index)
    	cell:refresh(fbDataList[index + 1])
    end

    local cellContentSize = require(itemFileName).new():getContentSize()

    local listTable = require("utility.TableViewExt").new({
    	size        = self._listViewSize, 
    	direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #fbDataList, 
        cellSize    = cellContentSize 
    	})

    listTable:setPosition(0, 0)
    self._listViewNode:addChild(listTable)

    -- 难度最大的，显示在下面 
    local pageCount = (listTable:getViewSize().height) / cellContentSize.height 	-- 当前每页显示的个数
    local tmpIndex = #fbDataList 
    if tmpIndex > pageCount then 
    	local maxMove = #fbDataList - pageCount     
	    if tmpIndex > maxMove then tmpIndex = maxMove end
	    local curIndex = maxMove - tmpIndex

	    listTable:setContentOffset(CCPoint(0, -(curIndex * cellContentSize.height)))
    end 
 end


 function ChallengeFubenLayer:onExit() 
 	CCTextureCache:sharedTextureCache():removeUnusedTextures() 
 end



 return ChallengeFubenLayer 

