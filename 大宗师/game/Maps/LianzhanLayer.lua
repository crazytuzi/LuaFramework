--[[
 --
 -- add by vicky
 -- 2014.09.09
 --
 --]]

 local data_battle_battle = require("data.data_battle_battle")
 local data_item_item = require("data.data_item_item")


 local LianzhanLayer = class("LianzhanLayer", function()
 		return require("utility.ShadeLayer").new()
 end)


 -- 经验值相关奖励
 local ItemTop = class("ItemTop", function(index, lvData, data, otherRewardNum)
    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBuilderReaderLoad("battle/lianzhan_item_top.ccbi", proxy, rootnode)

    local function getNumByIndex(index)
    	if index == 1 then
    		return "一"
	    elseif index == 2 then
	    	return "二"
	    elseif index == 3 then
	    	return "三"
	    elseif index == 4 then
	    	return "四"
	    elseif index == 5 then
	    	return "五"
	    elseif index == 6 then
	    	return "六"
	    elseif index == 7 then
	    	return "七"
	    elseif index == 8 then
	    	return "八"
	    elseif index == 9 then
	    	return "九"
	    elseif index == 10 then
	    	return "十"
	    end
    end

    local numLbl = rootnode["num_lbl"]
    numLbl:setString("第" .. tostring(getNumByIndex(index)) .. "次")

    if otherRewardNum <= 0 then 
    	rootnode["get_reward_lbl"]:setVisible(false)
    end

    -- no exp from server, set the default value 0
    if(data.exp == nil) then
        data.exp = 0
    end
    if(data.silver == nil) then
        data.silver = 0
    end
    if(data.xiahun == nil) then
        data.xiahun = 0
    end
    -- 每次战斗，得到的经验、银币、侠魂和等级都需要服务器端返回
    rootnode["expLbl"]:setString(tostring(data.exp or 0))
    rootnode["silverLbl"]:setString(tostring(data.silver or 0))
    rootnode["xiahunLbl"]:setString(tostring(data.xiahun or 0))

    local lv 
    local exp 
    local maxExp 

    if lvData == nil then
        lv = game.player:getLevel()
        exp = game.player:getExp()
        maxExp = game.player:getMaxExp()
    else
        lv = lvData.lv 
        exp = lvData.exp 
        maxExp = lvData.limit 
    end

    rootnode["lvLbl"]:setString("LV " .. tostring(lv)) 

    -- 等级条
    local percent = exp/maxExp
    local bar = rootnode["addBar"]
    bar:setTextureRect(CCRectMake(bar:getTextureRect().origin.x, bar:getTextureRect().origin.y, 
        bar:getTextureRect().size.width*percent, bar:getTextureRect().size.height))


    return node
 end)


 -- 奖励图标相关
 local ItemBottom = class("ItemBottom", function(data, startIndex, endIndex)
    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBuilderReaderLoad("battle/lianzhan_item_bottom.ccbi", proxy, rootnode) 

    -- dump(#data) 
    -- dump(startIndex) 
    -- dump(endIndex) 

    local num  
    if #data == 2 then 
        num = 2
        rootnode["reward_node_2"]:setVisible(true)
        rootnode["reward_node_1"]:setVisible(false)
    else 
        num = 1 
        rootnode["reward_node_1"]:setVisible(true) 
        rootnode["reward_node_2"]:setVisible(false)       
    end

    for i, v in ipairs(data) do 
    	if i >= startIndex and i <= endIndex then 
    		local iconType = ResMgr.getResType(v.t) 
			-- 图标
            local tmpIndex = i - startIndex + 1 
            dump("tmpIndex:" .. tmpIndex)

			local rewardIcon = rootnode["reward_icon_" .. num .. "_" ..tostring(tmpIndex)] 

			ResMgr.refreshIcon({id = v.id, resType = iconType, itemBg = rewardIcon})

            dump("reward_icon_" .. num .. "_" .. tmpIndex)
            dump("reward_suipian_" .. num .. "_" .. tmpIndex)

            -- 属性图标
            local canhunIcon = rootnode["reward_canhun_" .. num .. "_" .. tmpIndex]
            local suipianIcon = rootnode["reward_suipian_" .. num .. "_" .. tmpIndex]
            canhunIcon:setVisible(false)
            suipianIcon:setVisible(false) 
            if v.t == 3 then
                -- 装备碎片
                suipianIcon:setVisible(true) 
            elseif v.t == 5 then
                -- 残魂(武将碎片)
                canhunIcon:setVisible(true) 
            end

			-- 名称
			local nameLbl = rootnode["reward_name_" .. num .. "_" .. tmpIndex]
			if iconType == ResMgr.HERO then 
				ResMgr.refreshHeroName({
					label = nameLbl, 
					resId = v.id
					})
			elseif iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then
				ResMgr.refreshItemName({
					label = nameLbl, 
					resId = v.id
					})
			end

			-- 数量 
			local numKey = "reward_num_" .. num .. "_" ..tostring(tmpIndex)
			local numLbl = ui.newTTFLabelWithOutline({
	            text = tostring(v.n),
	            size = 22,
	            color = ccc3(0,255,0),
	            outlineColor = ccc3(0,0,0),
	            font = FONTS_NAME.font_fzcy,
	            align = ui.TEXT_ALIGN_LEFT
	            })
	 		
	 		numLbl:setPosition(-numLbl:getContentSize().width, numLbl:getContentSize().height/2)
		    rootnode[numKey]:addChild(numLbl)
	    end
    end
    
    return node
 end)


 function LianzhanLayer:ctor(param) 
 	self._id = param.id 
 	local data = param.data 
 	local totalNum = data["1"]
 	local baseRewardList = {} 
 	local rewardList = {} 
 	local lvList = data["3"] 
    -- dump(lvList)

 	-- 奖励相关的放到rewardList表里，金币经验值放到baseList表里

 	for j, value in ipairs(data["2"]) do
 		local rewards = {} 
 		local baseReward = {}
 		for i, v in ipairs(value) do
 			if v.id == 2 then 
	 			baseReward.silver = v.n
	 		elseif v.id == 6 then
	 			baseReward.exp = v.n
	 		elseif v.id == 7 then
	 			baseReward.xiahun = v.n
	 		else
	 			table.insert(rewards, v)
	 		end 
 		end 
 		table.insert(baseRewardList, baseReward)
 		table.insert(rewardList, rewards)
 	end 

	local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("battle/lianzhan_layer.ccbi", proxy, self._rootnode) 
    node:setPosition(display.width / 2, display.height / 2)
    self:addChild(node)	

    -- 关卡名称
  	local levelData = data_battle_battle[self._id]
  	local levelNameLbl = self._rootnode["level_name"]
    levelNameLbl:setString(tostring(levelData.name))

    -- 关闭
    self._rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName, sender) 
        local submapID = game.player.m_cur_normal_fuben_ID 
        local data_field_field = require("data.data_field_field")
        local clickedBigMapId = data_field_field[submapID].world 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        RequestHelper.getLevelList({ 
                id = clickedBigMapId, 
                callback = function(data)
                    -- dump(data)    
                    if data["0"] == "" then 
                        local scene = require("game.Maps.SubMap").new({submapID = submapID, subMap = data["4"]}, "fade", 0.3, display.COLOR_WHITE)
                        display.replaceScene(scene,"fade", 0.3, display.COLOR_WHITE)

                        GameStateManager.currentState = GAME_STATE.STATE_SUBMAP 

                    else
                        CCMessageBox(data["0"], "server data error")
                    end
                end
            })
    end, CCControlEventTouchUpInside)

    -- 奖励相关 
    local height = 0 
    for i = 1, totalNum do 
    	local baseReward = baseRewardList[i] 
    	if baseReward ~= nil then 
    		-- 获得的奖励icon个数
    		local otherRewards = rewardList[i] 
    		local otherRdNum = 0
    		if otherRewards ~= nil then
    			otherRdNum = #otherRewards
    		end

    		-- 基本的经验、银币等奖励
    		local lv = lvList[i]
    		local itemTop = ItemTop.new(i, lv, baseReward, otherRdNum)
    		itemTop:setPosition(self._rootnode["contentView"]:getContentSize().width/2, -height) 
    		self._rootnode["contentView"]:addChild(itemTop) 

    		height = height + itemTop:getContentSize().height 

    		-- 奖励icon相关 
    		if otherRewards == nil or #otherRewards <= 0 then 
    			height = height - 40 
    		elseif otherRewards ~= nil then 
    			local num  
                if #otherRewards%3 == 0 then 
                    num = #otherRewards/3 
                else
                    num = #otherRewards/3 + 1 
                end 
    			dump(num) 
    			for i = 1, num, 1 do 
                    dump("i : " .. i)
                    local startIndex = 1 
                    startIndex = startIndex + (i - 1) * 3 
    				local endIndex = i * 3 
    				local itemBottom = ItemBottom.new(otherRewards, startIndex, endIndex)
		    		itemBottom:setPosition(self._rootnode["contentView"]:getContentSize().width/2, -height)
		    		self._rootnode["contentView"]:addChild(itemBottom)

		    		height = height + itemBottom:getContentSize().height 
				end 
    		end
    	end
    end

	local sz = CCSizeMake(self._rootnode["contentView"]:getContentSize().width, self._rootnode["contentView"]:getContentSize().height + height)

    self._rootnode["descView"]:setContentSize(sz)
    self._rootnode["contentView"]:setPosition(ccp(sz.width / 2, sz.height))
    self._rootnode["scrollView"]:updateInset()
    self._rootnode["scrollView"]:setContentOffset(CCPointMake(0, -sz.height + self._rootnode["scrollView"]:getViewSize().height), false)

 end



 return LianzhanLayer
