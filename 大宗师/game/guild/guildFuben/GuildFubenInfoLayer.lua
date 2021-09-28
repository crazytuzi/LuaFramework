--[[
 --
 -- add by vicky
 -- 2015.03.10  
 --
 --]]

 local data_union_fubenui_union_fubenui = require("data.data_union_fubenui_union_fubenui") 
 local data_item_item = require("data.data_item_item") 


 local GuildFubenInfoLayer = class("GuildFubenInfoLayer", function()
 		return require("utility.ShadeLayer").new() 
 	end)


 function GuildFubenInfoLayer:ctor(param)
 	local itemData = param.itemData 
 	local showType = param.showType 
 	local rtnObj = param.rtnObj 
 	local showFunc = param.showFunc 
 	local fbItem = game.player:getGuildMgr():getDataByIdAndType(itemData.fbid, showType) 

 	self._hasShowInfo = false 

 	local proxy = CCBProxy:create()
 	self._rootnode = {}
 	local node = CCBuilderReaderLoad("ccbi/guild/guild_fuben_info.ccbi", proxy, self._rootnode)
 	node:setPosition(display.cx, display.cy)
 	self:addChild(node)

 	local function closeBtnFunc() 
 		self:removeFromParentAndCleanup(true) 
 	end 

 	-- X按钮
 	self._rootnode["returnBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        closeBtnFunc() 
    end, CCControlEventTouchUpInside)

 	local closeBtn = self._rootnode["closeBtn"] 
 	local enterBtn = self._rootnode["enterBtn"] 
 	-- isDead:0死了1没死
 	if rtnObj.isDead == 0 then 
 		closeBtn:setVisible(true)
 		enterBtn:setVisible(false)
 	elseif rtnObj.isDead == 1 then 
 		closeBtn:setVisible(false)
 		enterBtn:setVisible(true)
 	end 

 	-- 关闭按钮 
    closeBtn:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        closeBtnFunc() 
    end, CCControlEventTouchUpInside)

    local function enterBtnEnabled(bEnable)
    	enterBtn:setEnabled(bEnable) 
    end 

    -- 进入按钮 
	enterBtn:addHandleOfControlEvent(function(eventName,sender)
		enterBtnEnabled(false) 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
       	game.player:getGuildMgr():RequestFubenChooseCard({
       		errcb = function()
       			enterBtnEnabled(true) 
       		end, 
       		cb = function(rtnObj)
       			-- state:0可战斗，1不可战斗
       			if rtnObj.state == 1 then 
       				ResMgr.showErr(2900094) 
       				enterBtnEnabled(true) 
       			else
       				push_scene(require("game.guild.guildFuben.GuildFubenChooseHeroScene").new({
       					fbId = itemData.fbid, 
       					fbType = showType, 
       					cardsList = rtnObj.cardsList, 
       					showFunc = function()
       						enterBtnEnabled(true) 
       					end, 
       					}))
       			end 
       		end, 
       		}) 
    end, CCControlEventTouchUpInside)    


	self._rootnode["attack_lbl"]:setString(tostring(rtnObj.attackNum)) 
	self._rootnode["hurt_lbl"]:setString(tostring(rtnObj.allDamage)) 
	self._rootnode["blood_lbl"]:setString(tostring(rtnObj.leftHp) .. "/" .. tostring(itemData.totalHp)) 
	
	-- 血量条
    local percent = rtnObj.leftHp/itemData.totalHp 
    local normalBar = self._rootnode["normalBar"]  
    local bar = self._rootnode["addBar"] 
    local rotated = false 
    if bar:isTextureRectRotated() == true then 
        rotated = true 
    end 
    bar:setTextureRect(CCRectMake(bar:getTextureRect().origin.x, bar:getTextureRect().origin.y, 
        normalBar:getContentSize().width * percent, bar:getTextureRect().size.height), rotated, 
        CCSizeMake(normalBar:getContentSize().width * percent, normalBar:getContentSize().height * percent)) 

    -- boss头像
    local bossIcon = self._rootnode["tag_bossIcon"] 
    local bossIconBg = ResMgr.getLevelBossIcon(fbItem.bossicon, 3) 
    bossIcon:addChild(bossIconBg)

    -- 副本名称 
    local titleLabel = ui.newTTFLabelWithOutline({
        text = fbItem.bossname,
        font = FONTS_NAME.font_fzcy,
        size = 30,
        color = FONT_COLOR.LEVEL_NAME,
        align = ui.TEXT_ALIGN_CENTER 
        })

    titleLabel:setPosition(-self._rootnode["title_lbl"]:getContentSize().width/2, 0)
    self._rootnode["title_lbl"]:addChild(titleLabel) 

    -- 奖励预览 
    local rewardList = {} 
    for i = 1, fbItem.dropnum do 
        local rewardId = fbItem.dropIds[i] 
        local rewardType = fbItem.dropTypes[i] 
        local rewardItem 
        local iconType = ResMgr.getResType(rewardType) 
        if iconType == ResMgr.HERO then 
            rewardItem = ResMgr.getCardData(rewardId)
        else
            rewardItem = data_item_item[rewardId] 
        end
        ResMgr.showAlert(rewardItem, "没有此id: " .. rewardId .. "type: " .. rewardType) 

        table.insert(rewardList, {
            id = rewardId, 
            type = rewardType,  
            name = rewardItem.name, 
            describe = rewardItem.describe, 
            iconType = iconType, 
            num = 1, 
            })
    end 

    self:createRewardList(rewardList) 

    -- 副本动态 
    local dynamicList = {} 
    for i, v in ipairs(rtnObj.ufbdlist) do 
    	local item = data_union_fubenui_union_fubenui[v.type] 
    	ResMgr.showAlert(item, "data_union_fubenui_union_fubenui没有此id: " .. v.type) 
    	local itemData = {} 

    	if v.type == 2 then 
    		itemData.content = string.format(item.content, v.name, fbItem.bossname) 
    	elseif v.type == 1 then 
    		itemData.content = string.format(item.content, v.name, v.hurt) 
    	end 
    	table.insert(dynamicList, itemData) 
    end 

    self:createDynamicList(dynamicList) 

	if showFunc ~= nil then 
		showFunc() 
	end 
 end 


 -- 关卡概率掉落 奖励预览 
 function GuildFubenInfoLayer:createRewardList(cellDatas)
 	-- 创建
    local function createFunc(index)
    	local item = require("game.Huodong.RewardItem").new()
    	return item:create({
    		id = index, 
    		itemData = cellDatas[index + 1],
            viewSize = self._rootnode["bottom_listView"]:getContentSize() 
    		})
    end

    -- 刷新
    local function refreshFunc(cell, index)
    	cell:refresh({
            index = index, 
            itemData = cellDatas[index + 1]
            })
    end

    local cellContentSize = require("game.Huodong.RewardItem").new():getContentSize()

    self._rootnode["touchNode"]:setTouchEnabled(true)
    local posX = 0
    local posY = 0
    self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        posX = event.x
        posY = event.y
    end)

    local listTable = require("utility.TableViewExt").new({
    	size        = self._rootnode["bottom_listView"]:getContentSize(), 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #cellDatas, 
        cellSize    = cellContentSize, 
        touchFunc = function(cell) 
            if self._hasShowInfo == false then 
                local icon = cell:getRewardIcon() 
                local pos = icon:convertToNodeSpace(ccp(posX, posY)) 
                if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then
                    self._hasShowInfo = true 
                    local idx = cell:getIdx() + 1 
                    local itemData = cellDatas[idx] 
                    local itemInfo = require("game.Huodong.ItemInformation").new({
                            id = itemData.id,
                            type = itemData.type,
                            name = itemData.name,
                            describe = itemData.describe, 
                            endFunc = function()
                                self._hasShowInfo = false 
                            end
                            }) 
                    game.runningScene:addChild(itemInfo, self:getZOrder() + 1)
                end 
            end 
        end 
    	})

    listTable:setPosition(0, 0)
    self._rootnode["bottom_listView"]:addChild(listTable) 
 end


 function GuildFubenInfoLayer:createDynamicList(dynamicList) 

	local fileName = "game.guild.guildFuben.GuildFubenDynamicItem" 

	-- 创建
    local function createFunc(index)
    	local item = require(fileName).new()
    	return item:create({
    		itemData = dynamicList[index + 1],
            viewSize = self._rootnode["top_listView"]:getContentSize() 
    		})
    end

    -- 刷新
    local function refreshFunc(cell, index)
    	cell:refresh(dynamicList[index + 1])
    end

    local cellContentSize = require(fileName).new():getContentSize() 

	local listTable = require("utility.TableViewExt").new({
    	size        = self._rootnode["top_listView"]:getContentSize(), 
    	direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #dynamicList, 
        cellSize    = cellContentSize  
    	})

    listTable:setPosition(0, 0)
    self._rootnode["top_listView"]:addChild(listTable) 
 end 




 return GuildFubenInfoLayer 

