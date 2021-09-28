--
-- Author: Daneil
-- Date: 2015-03-12 12:56:56
--
require("game.Biwu.BiwuFuc")
local WaBaoMainView = class("WaBaoMainView", function ()
    return display.newLayer("WaBaoMainView")
end)

local data_item_item = require("data.data_item_item")

function WaBaoMainView:setUpView(param)        
	self:setContentSize(param.size)
	local bng = display.newSprite("#main_bng.jpg")
	bng:setAnchorPoint(cc.p(0.5,0.5))
	bng:setPosition(cc.p(display.width / 2,display.height / 2 - 100))
	self:addChild(bng)


	--屏幕适配
	--[[local bngHeight = bng:getContentSize().height
	local bngWidth  = bng:getContentSize().width
	local scaleOne  = bngHeight / bngWidth
	local scaleTwo  = param.size.height / param.size.width

	local scaleScreen = param.size.height / bngHeight
	local scaleView   = param.size.width / bngWidth

	if scaleTwo >= scaleOne then
		bng:setScaleY(scaleScreen) 
		bng:setScaleX(scaleScreen)
	else
		bng:setScaleX(scaleView)
		bng:setScaleY(scaleView)
	end--]]

	local centerIcon = display.newSprite("#center_icon.png")
	centerIcon:setAnchorPoint(cc.p(0.5,0.6))
	centerIcon:setPosition(cc.p(param.size.width/2,param.size.height * 0.75))
	self:addChild(centerIcon)

	

	--预览
    local preBtn = display.newSprite("#wj_extraReward_btn.png")
	preBtn:setPosition(cc.p(param.size.width  * 0.1, param.size.height - preBtn:getContentSize().height / 2 - 10))
	self:addChild(preBtn)  

	addTouchListener(preBtn, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
            sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            if not CCDirector:sharedDirector():getRunningScene():getChildByTag(10000000) then
        		CCDirector:sharedDirector():getRunningScene():addChild(require ("game.nbactivity.WaBao.WaBaoGiftPopup").new(),1222222,10000000)
        	end
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)


	--说明
    local disBtn = display.newSprite("#shuoming.png")
	disBtn:setPosition(cc.p(param.size.width  * 0.9, param.size.height- preBtn:getContentSize().height / 2 - 10))
	self:addChild(disBtn)  

	addTouchListener(disBtn, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
            sender:setScale(1)
            local layer = require("game.SplitStove.SplitDescLayer").new(4)
            CCDirector:sharedDirector():getRunningScene():addChild(layer, 100)
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)


    local timeLabel = display.newSprite("#countdown.png")
	timeLabel:setAnchorPoint(cc.p(1,0))
	timeLabel:setPosition(cc.p(param.size.width - 10 , disBtn:getPositionY() - disBtn:getContentSize().height / 2 - 30))
	self:addChild(timeLabel)

	--self._countDownTime = math.floor(self._countDownTime / 1000)
	--local nowTimeStr = self:timeFormat(self._countDownTime)
	self._timeLabelCountDown = ui.newTTFLabelWithOutline({  text = "00:00:00", 
											size = 23, 
											color = ccc3(0,254,60),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	self._timeLabelCountDown:setAnchorPoint(cc.p(1,0))
	self._timeLabelCountDown:setPosition(cc.p(param.size.width - self._timeLabelCountDown:getContentSize().width - 20 , timeLabel:getPositionY() - 10))
	self:addChild(self._timeLabelCountDown)



	-- 挖一次
    local oneBtn = display.newSprite("#btn_one.png")
	oneBtn:setPosition(cc.p( - 100 + centerIcon:getContentSize().width / 2, 0))
	centerIcon:addChild(oneBtn)  

	addTouchListener(oneBtn, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
            sender:setScale(1)
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	        self:startDig(1)
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)


    --挖宝价格标签
    self._onePriceLabel = ui.newTTFLabelWithOutline({  text = "220", 
											size = 20, 
											color = ccc3(255,210,0),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	self._onePriceLabel:setPosition(cc.p(0,-10))

	self._oneMoneyIcon = display.newSprite("#icon_gold.png")
	self._oneMoneyIcon:setPosition(cc.p(self._onePriceLabel:getPositionX() + self._onePriceLabel:getContentSize().width + 20,-10))
	oneBtn:addChild(self._onePriceLabel)
	oneBtn:addChild(self._oneMoneyIcon)

    --挖全部
    local allBtn = display.newSprite("#btn_all.png")
	allBtn:setPosition(cc.p(100 + centerIcon:getContentSize().width / 2,  0))
	centerIcon:addChild(allBtn)  

	addTouchListener(allBtn, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
            sender:setScale(1)
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	        self:startDig(2)
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    if (display.width / display.height) >= (768 / 1024) then
		centerIcon:setPosition(cc.p(param.size.width / 2,param.size.height * 0.75))
		allBtn:setPosition(cc.p(100 + centerIcon:getContentSize().width / 2,  60))
		oneBtn:setPosition(cc.p(- 100 + centerIcon:getContentSize().width / 2,  60))
	end

    self._freeTimeLabel = ui.newTTFLabelWithOutline({  text = "免费一次", 
											size = 20, 
											color = ccc3(0,240,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
    self._freeTimeLabel:setPosition(cc.p(0, -10))
    oneBtn:addChild(self._freeTimeLabel)


    

	self._refAllPriceLabel = ui.newTTFLabelWithOutline({  text = "220", 
											size = 20, 
											color = ccc3(255,210,0),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	self._refAllPriceLabel:setPosition(cc.p(30,-10))

	local moneyIcon = display.newSprite("#icon_gold.png")
	moneyIcon:setPosition(cc.p(self._refAllPriceLabel:getPositionX() + self._refAllPriceLabel:getContentSize().width + 20,-10))
	allBtn:addChild(self._refAllPriceLabel)
	allBtn:addChild(moneyIcon)



    --活动描述
	local disLabel1 = ui.newTTFLabelWithOutline({  text = "活动时间:", 
											size = 23, 
											color = FONT_COLOR.WHITE,
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	disLabel1:setPosition(cc.p(param.size.width * 0.1,240))
	self:addChild(disLabel1)


	self._actLabel = ui.newTTFLabelWithOutline({  text = "2012-10-10 20:23:20至2012-10-10 20:23:20", 
											size = 23, 
											color = ccc3(0,254,60),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	self._actLabel:setPosition(cc.p(disLabel1:getPositionX() + disLabel1:getContentSize().width,240))
	self:addChild(self._actLabel)

	local Label1 = ui.newTTFLabelWithOutline({  text = "今日剩余元宝探宝次数", 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label1:setPosition(cc.p(param.size.width * 0.2,270))

	self._timeLeftLabel = ui.newTTFLabelWithOutline({  text = 200, 
											size = 20, 
											color = ccc3(0,240,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	self._timeLeftLabel:setPosition(cc.p(Label1:getPositionX() + Label1:getContentSize().width + 10,270))

	local Label3 = ui.newTTFLabelWithOutline({  text = "次", 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label3:setPosition(cc.p(self._timeLeftLabel:getPositionX() + self._timeLeftLabel:getContentSize().width + 10,270))
	self:addChild(Label1)
	self:addChild(self._timeLeftLabel)
	self:addChild(Label3)




	self._bottomBng = display.newScale9Sprite("#buttom_bng.png", 0, 0, 
                        cc.size(param.size.width - 40, 180))
	self._bottomBng:setAnchorPoint(cc.p(0.5,0))
	self._bottomBng:setPosition(cc.p(param.size.width / 2, 20))
	self:addChild(self._bottomBng)



	
    local titleIcon = display.newSprite("#buttom_title.png")
	titleIcon:setPosition(cc.p(self._bottomBng:getContentSize().width * 0.5, self._bottomBng:getContentSize().height * 1))
	self._bottomBng:addChild(titleIcon)  


	local refreshBtn = display.newSprite("#btn_refresh.png")
	refreshBtn:setAnchorPoint(cc.p(0.5,0))
	refreshBtn:setPosition(cc.p(self._bottomBng:getContentSize().width  * 0.5, 10))

	addTouchListener(refreshBtn, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
            sender:setScale(1)
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	        self:getRefreshData(function()
	        	self:refresh(self._itemData)
	        	self:refreshAll(self._itemData)
	        end)
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)
    self._bottomBng:addChild(refreshBtn)

    self._refreshPrice = ui.newTTFLabelWithOutline({  text = "20", 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	self._refreshPrice:setPosition(cc.p(refreshBtn:getContentSize().width - 75,refreshBtn:getContentSize().height/2 - 2))
	self._refreshPrice:setAnchorPoint(cc.p(1,0.5))
	refreshBtn:addChild(self._refreshPrice)

    
end

function WaBaoMainView:showResetPopup()
	local okFunc = function()
    	local func = function ()
			self:refresh()
			self:refreshAll(self._itemData)
		end
		self:getData(func)
	end
    local msgBox = require("utility.MsgBox").new({
        size = CCSizeMake(500, 300),
        content = "----------",
        showClose = true, 
        directclose = true,
        midBtnFunc = okFunc
	})
	self:addChild(msgBox)
end

function WaBaoMainView:refreshItem(target)
	if self._itemInstance[target] then
		local getTag = display.newSprite("#tag_get.png")
		getTag:setAnchorPoint(cc.p(0.5,0.5))
		getTag:setPosition(cc.p(self._itemInstance[target]:getContentSize().width/2,self._itemInstance[target]:getContentSize().height/2))
		getTag:setRotation(-45)
		self._itemInstance[target]:addChild(getTag)
	else
		print("重复选择")
	end
end


function WaBaoMainView:showItemDetail(node,data)
	addTouchListener(node, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.65)
    	elseif eventType == EventType.ended then
            sender:setScale(0.7)
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))

	        local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = data.id, 
                        type = data.type, 
                        name = require("data.data_item_item").name, 
                        describe = require("data.data_item_item").dis
                        })

        	CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
        elseif eventType == EventType.cancel then
        	sender:setScale(0.7)
        end
    end)
end

function WaBaoMainView:selectAll(data)
	for i = 1,8 do
		self:refreshItem(i)
	end
end

function WaBaoMainView:refreshAll(data)
	if self._itemInstance then 
		for k,v in pairs(self._itemInstance) do
			if v then
				self._itemInstance[k]:removeFromParent()
			end
		end
	end
	self._itemInstance = {}

	for k,v in pairs(data) do
		local icon = self:createItemView(k,self._bottomBng,v)
    	icon:setPosition( k * (self._bottomBng:getContentSize().width / 8 - 3) - 25,self._bottomBng:getContentSize().height - 50)
    	self._itemInstance[tonumber(k)] = icon
    	print(k)
	end
	dump(self._itemInstance)
end

function WaBaoMainView:createItemView(index,node,dataTemp)
	data = { 
		id = dataTemp.id,
		type = dataTemp.t,
		num = dataTemp.n
	}
    local marginTop  = 10
    local marginLeft = 10
    local offset = 100
    local icon = ResMgr.refreshIcon(
    {
        id = data.id, 
        resType = ResMgr.getResType(data.type), 
    }) 
    icon:setAnchorPoint(cc.p(0,0.5)) 
    icon:setAnchorPoint(cc.p(0.5,0.5))

    self:showItemDetail(icon,data)
	icon:setScale(0.70)

    -- 名称
    local nameColor = ccc3(255, 255, 255) 
    if ResMgr.getResType(data.type) == ResMgr.HERO then 
        nameColor = ResMgr.getHeroNameColor(tonumber(data.id))
    elseif ResMgr.getResType(data.type) == ResMgr.ITEM or ResMgr.getResType(data.type) == ResMgr.EQUIP then 
        nameColor = ResMgr.getItemNameColor(tonumber(data.id)) 
    end 
	local nameLabel = ui.newTTFLabelWithOutline({
        text = require("data.data_item_item")[data.id].name,
        size = 20,
        color = nameColor,
        outlineColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER
    	})
    nameLabel:setPosition(cc.p(icon:getContentSize().width /2 , -15))
	icon:addChild(nameLabel)
    nameLabel:setAnchorPoint(cc.p(0,1))
    nameLabel:setScale(1.0)
	local tag
    -- 装备碎片
    if tonumber(data.type) == 3 then
        tag = display.newSprite("#sx_suipian.png")
    elseif tonumber(data.type) == 5 then
        -- 残魂(武将碎片)
        tag = display.newSprite("#sx_canhun.png")
    end
    if tag then
        icon:addChild(tag)
        tag:setRotation(-20)
        tag:setPosition(cc.p(40,75))
    end
	if tonumber(data.type) == 6 then
        local iconSp = require("game.Spirit.SpiritIcon").new({
            resId = self._data.giftData[index].id,
            bShowName = true,
        })
        node:addChild(iconSp)
        iconSp:setAnchorPoint(cc.p(0,0.5)) 
        iconSp:setPosition(icon:getPosition())
    else
    	node:addChild(icon)
    end
	return icon
end


function WaBaoMainView:clear()
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
	end
end

function WaBaoMainView:timeFormat(timeAll)
	local basehour = 60 * 60
	local basemin  = 60
	local hour = math.floor(timeAll / basehour) 
	local time = timeAll - hour * basehour
	local min  = math.floor(time / basemin) 
	local time = time - basemin * min
	local sec  = math.floor(time)
	hour = hour < 10 and "0"..hour or hour
	min = min < 10 and "0"..min or min
	sec = sec < 10 and "0"..sec or sec
	local nowTimeStr = hour.."时"..min.."分"..sec.."秒"
	return nowTimeStr
end

function WaBaoMainView:ctor(param)
	self:load()
	self:setUpView(param)
    local func = function ()
		self:refresh()
		self:refreshAll(self._itemData)
	end
	self:getData(func)
end 

function WaBaoMainView:getData(func)

	local init = function (data)
		self._nowTime  = data.nowTime / 1000 or 200
		self._actTime  = data.activetime or "2010-11-10"
		self._timeLeft = data.surGoldTimes or "200"
		self._timeFree = data.freeTimes or "10"
		self._priceAll = data.digAllGold or "20"
		self._priceOne = data.digOneGold or 0
		self._priceRef = data.refreshCost or "20"
		self._itemData = data.treasuryMap or {1,2,3,4,5,6,7,8}
		self._hasgetAry = data.hasGetAry 
		self._selectCount = #data.hasGetAry
		func()
		dump(self._hasgetAry)
		for k,v in pairs(self._hasgetAry) do
			self:refreshItem(tonumber(v))
		end
	end

	RequestHelper.wabaoSystem.getBaseInfo({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end 
                })
	
end

function WaBaoMainView:timeFormat(timeAll)
	local basehour = 60 * 60
	local basemin  = 60
	local hour = math.floor(timeAll / basehour) 
	local time = timeAll - hour * basehour
	local min  = math.floor(time / basemin) 
	local time = time - basemin * min
	local sec  = math.floor(time)
	hour = hour < 10 and "0"..hour or hour
	min = min < 10 and "0"..min or min
	sec = sec < 10 and "0"..sec or sec
	local nowTimeStr = hour..":"..min..":"..sec
	return nowTimeStr
end

function WaBaoMainView:clear()
	if self._scheduleTime then
		self._schedulerTime.unscheduleGlobal(self._scheduleTime)
	end
	self:release()
end 

function WaBaoMainView:getRefreshData(func)

	local init = function(data)
		if data.hasGetAry == 1 then 
			self:showResetPopup()
			return 
		end 
		self._priceAll = data.digAllGold
		self._priceOne = data.digOneGold
		self._priceRef = data.refreshCost
		self._itemData = data.treasuryMap
		self._selectCount = 0
		func()
	end

	RequestHelper.wabaoSystem.refresh({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end 
                })

end

function WaBaoMainView:startDig(index)
	--index 1 一次 2全部
	local init = function(data)
		if data.checkBag and #data.checkBag > 0 then
        	local layer = require("utility.LackBagSpaceLayer").new({
                bagObj = data.checkBag,
            })
            self:addChild(layer, 10)
        else
			if data.hasGetAry == 1 then 
				self:showResetPopup()
				return
			end 
			local target = data.treasuryMap
			dump(target)
			self._timeLeft = data.surGoldTimes
			self._timeFree = data.freeTimes
			self._priceAll = data.digAllGold
			self._priceOne = data.digOneGold
			if index == 1 then
				self._selectCount = self._selectCount + 1
			else
				self._selectCount = 8
			end
			
			self:refresh()

			for k,v in pairs(target) do
				self:refreshItem(tonumber(k))
			end

			local dataTemp = {}
			for k,v in pairs(target) do
				local temp = {}
				temp.id = v.id
				temp.num = v.n
				temp.type = v.t
				temp.iconType = ResMgr.getResType(v.t)
				temp.name = require("data.data_item_item")[v.id].name
				table.insert(dataTemp,temp)
			end

			self:createArmature(dataTemp,func)
	    end
	end

	
	if self._selectCount >= 8 then
		show_tip_label(data_error_error[1500803].prompt)
		return 
	end

	RequestHelper.wabaoSystem.beginDig({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end,
                type = index 
                })

end

function WaBaoMainView:createArmature(dataTemp,func)

	local secondArm = function()
		local callback = function()
			if CCDirector:sharedDirector():getRunningScene():getChildByTag(11111) then
				CCDirector:sharedDirector():getRunningScene():removeChildByTag(11111)
			end
			if CCDirector:sharedDirector():getRunningScene():getChildByTag(22222) then
				CCDirector:sharedDirector():getRunningScene():removeChildByTag(22222)
			end
			if self:getChildByTag(1000) then
				self:removeChildByTag(1000)
			end
			if func then
				func()
			end

		end
		local msgBox = require("game.Huodong.RewardMsgBox").new({
		        title = "恭喜您获得如下物品", 
		        cellDatas = dataTemp,
		        confirmFunc = callback
	        })	
	    CCDirector:sharedDirector():getRunningScene():addChild(msgBox,1000)
		local bgEffect = ResMgr.createArma({
	    	resType = ResMgr.UI_EFFECT, 
	    	armaName = "xiakejinjie_xunhuan", 
	    	isRetain = false
    	})
    	bgEffect:setScale(0.6)
	    bgEffect:setPosition(display.width/2,display.height/2)
	    CCDirector:sharedDirector():getRunningScene():addChild(bgEffect,10,22222) 
	end

	local winSize = CCDirector:sharedDirector():getWinSize()
    local mask = CCLayerColor:create()
    mask:setContentSize(winSize)
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(150)
    mask:setAnchorPoint(cc.p(0,0))
    mask:setTouchEnabled(true)
    self:addChild(mask,1,1000)

	local bgEffect = ResMgr.createArma({
	    	resType = ResMgr.UI_EFFECT, 
	    	armaName = "xiakejinjie_qishou", 
	    	isRetain = false,
	    	frameFunc = secondArm,
            finishFunc = function ()
                
            end
    	})
	bgEffect:setScale(0.6)
    bgEffect:setPosition(display.width/2,display.height/2)
    CCDirector:sharedDirector():getRunningScene():addChild(bgEffect,10,11111)
end

function WaBaoMainView:refresh()
	self._countDownTime = self._nowTime
	--倒计时
	if not self._schedulerTime then
		self._schedulerTime = require("framework.scheduler")
		local countDown = function()
			--剩余时间 
			self._countDownTime = self._countDownTime - 1
			if self._countDownTime <= 0 then
				self._schedulerTime.unscheduleGlobal(self._scheduleTime)
				self._timeLabelCountDown:setString("活动已结束")
				show_tip_label("活动已结束")
			else
				self._timeLabelCountDown:setString(self:timeFormat(self._countDownTime))
			end
		end
		self._scheduleTime = self._schedulerTime.scheduleGlobal(countDown, 1, false)
	end


	self._actLabel:setString(self._actTime)
	self._timeLeftLabel:setString(self._timeLeft)
	self._freeTimeLabel:setString("免费"..self._timeFree.."次")
	self._refAllPriceLabel:setString(self._priceAll)


    if self._timeFree == 0 then
    	self._freeTimeLabel:setVisible(false)
    	self._oneMoneyIcon:setVisible(true)
    	self._onePriceLabel:setVisible(true)
    else
     	self._freeTimeLabel:setVisible(true)
    	self._oneMoneyIcon:setVisible(false)
    	self._onePriceLabel:setVisible(false)
	end 
	self._onePriceLabel:setString(self._priceOne)
end

function WaBaoMainView:load()
	display.addSpriteFramesWithFile("ui/ui_nbactivity_duihuan.plist", "ui/ui_nbactivity_duihuan.png")
	display.addSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
	display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")  
	display.addSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	display.addSpriteFramesWithFile("ui/ui_nbactivity_wabao.plist", "ui/ui_nbactivity_wabao.png")
	display.addSpriteFramesWithFile("ui/ui_tanbao.plist", "ui/ui_tanbao.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.addSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
	display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png") 
	display.addSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
end

function WaBaoMainView:release()
	
end

return WaBaoMainView