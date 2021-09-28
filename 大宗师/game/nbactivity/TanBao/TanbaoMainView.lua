--
-- Author: Daneil
-- Date: 2015-01-15 22:13:07
--
require("game.Biwu.BiwuFuc")

local radius = 130
local ratios  = 0.0
local baseRatio = 2 * 3.141592
local data_item_item = require("data.data_item_item")
local TanbaoMainView = class("TanbaoMainView", function ()
    return display.newLayer("TanbaoMainView")
end)


local boxType = { 
	jifen = 1,
	suiji = 2,
	common = 3
}

function TanbaoMainView:setUpView(param)
	local maskBng = display.newSprite("#bng.png")
	maskBng:setAnchorPoint(cc.p(0.5,0.5))
	maskBng:setPosition(cc.p(param.size.width/2,param.size.height * 0.5))
	self:addChild(maskBng)

	local timeLabeldis = ui.newTTFLabelWithOutline({  text = "活动时间:"..self._timeStr, 
											size = 23, 
											color = ccc3(0,254,60),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	timeLabeldis:setPosition(cc.p(param.size.width * 0.02,param.size.height - 30))
	self:addChild(timeLabeldis)

	local titleBng = display.newSprite("#huanggongtanbao.png")
	titleBng:setAnchorPoint(cc.p(0,0))
	titleBng:setPosition(cc.p(param.size.width * 0.01, timeLabeldis:getPositionY() - timeLabeldis:getContentSize().height - 40))
	self:addChild(titleBng)

	local timeLabel = display.newSprite("#countdown.png")
	timeLabel:setAnchorPoint(cc.p(0,0))
	timeLabel:setPosition(cc.p(param.size.width * 0.02,titleBng:getPositionY()  -  40))
	self:addChild(timeLabel)

	self._countDownTime = math.floor(self._countDownTime / 1000)
	local nowTimeStr = self:timeFormat(self._countDownTime)
	local timeLabelCountDown = ui.newTTFLabelWithOutline({  text = nowTimeStr, 
											size = 23, 
											color = ccc3(0,254,60),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	timeLabelCountDown:setPosition(cc.p(param.size.width * 0.03,timeLabel:getPositionY()  -  20))
	self:addChild(timeLabelCountDown)



	--转盘背景
	local roteBng = display.newSprite("#zhuanpandizuo.png")
	roteBng:setPosition(cc.p(param.size.width * 0.5, param.size.height * 0.6))
	self:addChild(roteBng) 

	if (display.width / display.height) >= (768 / 1024) then
		roteBng:setScale(0.9)
	else
		roteBng:setScale(1)
	end

	local roteInnerBng = display.newSprite("#zhuanpanyuandi.png")
	roteInnerBng:setPosition(cc.p(roteBng:getContentSize().width/2, roteBng:getContentSize().height/2))
	roteBng:addChild(roteInnerBng,1)

	--积分
	local jinfenBng = display.newSprite("#jifenbng_1.png")
	jinfenBng:setAnchorPoint(cc.p(1,0.5))
	jinfenBng:setPosition(cc.p(param.size.width, param.size.height * 0.3))
	self:addChild(jinfenBng) 


	--当前积分
	local jinfenTitle = ui.newTTFLabelWithOutline({  text = "当前积分:", 
											size = 20, 
											color = ccc3(255,210,0),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	jinfenTitle:setAnchorPoint(cc.p(0.5,0.5))
	jinfenTitle:setPosition(cc.p(jinfenBng:getContentSize().width * 0.2,jinfenBng:getContentSize().height * 0.75))

	local jinfenValue = ui.newTTFLabelWithOutline({  text = self._jifen, 
											size = 20, 
											color = ccc3(36,255,0),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	jinfenValue:setAnchorPoint(cc.p(0.5,0.5))
    jinfenValue:setPosition(cc.p(jinfenBng:getContentSize().width * 0.7,jinfenBng:getContentSize().height * 0.75))
    jinfenBng:addChild(jinfenTitle)
    jinfenBng:addChild(jinfenValue)

	--剩余次数
	local timeTitle = ui.newTTFLabelWithOutline({  text = "剩余次数:", 
											size = 20, 
											color = ccc3(255,210,0),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	timeTitle:setAnchorPoint(cc.p(0.5,0.5))
	timeTitle:setPosition(cc.p(jinfenBng:getContentSize().width * 0.2,jinfenBng:getContentSize().height * 0.25))
	local timeValue = ui.newTTFLabelWithOutline({  text = self._time, 
											size = 20, 
											color = ccc3(0,240,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	timeValue:setAnchorPoint(cc.p(0.5,0.5))
	timeValue:setPosition(cc.p(jinfenBng:getContentSize().width * 0.7,jinfenBng:getContentSize().height * 0.25))
	jinfenBng:addChild(timeTitle)
    jinfenBng:addChild(timeValue)

	self.btnOne = display.newSprite("#tanbaoyici.png")
	self.btnOne:setAnchorPoint(cc.p(0.5,0))
	self.btnOne:setPosition(cc.p(roteInnerBng:getContentSize().width * 0.5, roteInnerBng:getContentSize().height * 0.55))
	roteInnerBng:addChild(self.btnOne) 

	self.btnTen = display.newSprite("#tanbaoshici.png")
	self.btnTen:setAnchorPoint(cc.p(0.5,1))
	self.btnTen:setPosition(cc.p(roteInnerBng:getContentSize().width * 0.5, roteInnerBng:getContentSize().height * 0.44))
	roteInnerBng:addChild(self.btnTen) 

	local freeTimeLabel = ui.newTTFLabelWithOutline({  text = "今日免费次数:"..self._freeTime, 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	freeTimeLabel:setAnchorPoint(cc.p(0.5,0.5))
	freeTimeLabel:setPosition(cc.p(roteInnerBng:getContentSize().width * 0.15, roteInnerBng:getContentSize().height * 0.5))
	roteInnerBng:addChild(freeTimeLabel)

	local nodeGoldOne = display.newNode()
    local goldIconOne    = display.newSprite("#icon_gold.png")
    goldIconOne:setPositionX(-10)
    nodeGoldOne:addChild(goldIconOne)
    local preLabelOne = ui.newTTFLabelWithOutline({  text = self._priceOne, 
											size = 20, 
											color = ccc3(255,210,0),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
    preLabelOne:setPositionX(10)
    nodeGoldOne:addChild(preLabelOne)
    nodeGoldOne:setPosition(cc.p(self.btnOne:getContentSize().width/2,self.btnOne:getContentSize().height * 0.7))
    self.btnOne:addChild(nodeGoldOne)

    local nodeGoldTwo = display.newNode()
    local goldIconTwo    = display.newSprite("#icon_gold.png")
    goldIconTwo:setPositionX(-10)
    nodeGoldTwo:addChild(goldIconTwo)
    local preLabelTen = ui.newTTFLabelWithOutline({  text = self._priceTen, 
											size = 20, 
											color = ccc3(255,210,0),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
    preLabelTen:setPositionX(10)
    nodeGoldTwo:addChild(preLabelTen)
    nodeGoldTwo:setPosition(cc.p(self.btnOne:getContentSize().width/2,self.btnOne:getContentSize().height * 0.3))
    self.btnTen:addChild(nodeGoldTwo)


    if self._type == 1 or self._type == 2 then
    	nodeGoldOne:setVisible(false)
    	nodeGoldTwo:setVisible(false)
    else
    	nodeGoldOne:setVisible(true)
    	nodeGoldTwo:setVisible(true)
    	if self._freeTime ~= 0 then
    		preLabelOne:setVisible(false)
    		goldIconOne:setVisible(false)
    	end
    end


	local refreshFunc = function (type)
		freeTimeLabel:setString("今日免费次数:"..self._freeTime)
		timeValue:setString(self._time)
		jinfenValue:setString(self._jifen)
		if self._freeTime ~= 0 then
			self.btnOne:setDisplayFrame(display.newSprite("#mianfei.png"):getDisplayFrame())
		else
			self.btnOne:setDisplayFrame(display.newSprite("#tanbaoyici.png"):getDisplayFrame())
		end
		if self._freeTime ~= 0 then
    		preLabelOne:setVisible(false)
    		goldIconOne:setVisible(false)
    	else
    		preLabelOne:setVisible(self._type == 3)
    		goldIconOne:setVisible(self._type == 3)
    	end
    	self:refreshGoldBox()
	end

	if self._freeTime ~= 0 then
		self.btnOne:setDisplayFrame(display.newSprite("#mianfei.png"):getDisplayFrame())
	end


	addTouchListener(self.btnOne, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.95)
    	elseif eventType == EventType.ended then
            sender:setScale(1)
            if self._time == 0 and self._freeTime == 0 and self._type ~= 3 then
            	show_tip_label("探宝次数不足!")
            	return
            end
            self:tanBaoRequest(refreshFunc,1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    addTouchListener(self.btnTen, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.95)
    	elseif eventType == EventType.ended then
            sender:setScale(1)
            if self._time + self._freeTime < 10 and self._type ~= 3 then
            	show_tip_label("探宝次数不足!")
            	return
            end
            self:tanBaoRequest(refreshFunc,10)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    


    local centerNode = display.newNode()
    centerNode:setPosition(roteBng:getContentSize().width/2, roteBng:getContentSize().height/2)
    roteBng:addChild(centerNode)
    


    --活动说明
    local disBtn = display.newSprite("#shuoming.png")
	disBtn:setPosition(cc.p(param.size.width  * 0.9, param.size.height * 0.9))
	self:addChild(disBtn)  

	addTouchListener(disBtn, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
            sender:setScale(1)
            local layer = require("game.SplitStove.SplitDescLayer").new(3)
            CCDirector:sharedDirector():getRunningScene():addChild(layer, 100)
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

	self:createLabel01(param)
	self:createLabel02(param)
	self:createProgress(param)

	

    self._roteArrow = display.newSprite("#arraw.png")
	self._roteArrow:setPosition(cc.p(roteInnerBng:getContentSize().width * 0.7, roteInnerBng:getContentSize().height * 0.58))
	centerNode:addChild(self._roteArrow,2) 

	self:setUpArrowPos()
	self._scheduler = require("framework.scheduler")
	self._schedulerTime = require("framework.scheduler")

	
	self.countDown = function()
		self.timer = self.timer + 1
		if self.timer <= self.t1 then
			self.speed = self.speed + self.a1
		elseif self.timer > self.t1 and self.timer <= self.t1 + self.t2 then
			self.speed = self.speed - self.a2
		end
		ratios = ratios + self.speed
		if self.speed < 0.00001 then
			self._scheduler.unscheduleGlobal(self._schedule)
			print(self._totalRatio)
			self.btnOne:setTouchEnabled(true)
			self.btnTen:setTouchEnabled(true)
			self:showGiftPopup(self._tanbaoGift,"恭喜获得如下奖励",nil,boxType.common)
		end
		self:setUpArrowPos()
	end


	for i = 1,10 do
		local ratios = (i - 1) * 0.1 
		local x = 170 * math.sin(ratios * (baseRatio))
		local y = 170 * math.cos(ratios * (baseRatio))
		local item = self:createItemView(cc.p(x,y),centerNode,self._baseItem[i])
	end

	
	
	--倒计时
	local countDown = function()
		--剩余时间 
		self._countDownTime = self._countDownTime - 1
		if self._countDownTime <= 0 then
			self._schedulerTime.unscheduleGlobal(self._scheduleTime)
			timeLabelCountDown:setString("活动已结束")
			self.btnOne:setTouchEnabled(false)
			self.btnTen:setTouchEnabled(false)
			timeLabelCountDown:setPositionX(timeLabelCountDown:getPositionX() + 20)
			show_tip_label("活动已结束")
		else
			timeLabelCountDown:setString(self:timeFormat(self._countDownTime))
		end
		
	end
	self._scheduleTime = self._schedulerTime.scheduleGlobal(countDown, 1, false)

end

function TanbaoMainView:timeFormat(timeAll)
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

function TanbaoMainView:clear()
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
	end
	if self._scheduleTime then
		self._schedulerTime.unscheduleGlobal(self._scheduleTime)
	end
	self:close()
end 

function TanbaoMainView:setUpArrowPos()
	local x = radius * math.sin(ratios * (baseRatio))
	local y = radius * math.cos(ratios * (baseRatio))
	self._roteArrow:setPosition(cc.p(x,y))
	self._roteArrow:setRotation(360 * ratios)
end

function TanbaoMainView:setUpExtraView(param)


end

function TanbaoMainView:createLabel01(param)

	local titleDisConst = {"每充值","每消费","免费次数用尽后，可使用元宝购买。累积最大购买次数为 "..self._maxTime}

	local bng = display.newScale9Sprite("#jifenbng_2.png", 0, 0, 
                        cc.size(param.size.width * 0.8, 35))
	local Label1 = ui.newTTFLabelWithOutline({  text = titleDisConst[self._type], 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label1:setPosition(cc.p(bng:getContentSize().width * 0.02,bng:getContentSize().height*0.5))

	local moneyIcon = display.newSprite("#icon_gold.png")
	moneyIcon:setPosition(cc.p(bng:getContentSize().width * 0.17,bng:getContentSize().height*0.5))

	local Label2 = ui.newTTFLabelWithOutline({  text = self._priceOne, 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label2:setPosition(cc.p(bng:getContentSize().width * 0.2,bng:getContentSize().height*0.5))

	local Label3 = ui.newTTFLabelWithOutline({  text = "可获得", 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label3:setPosition(cc.p(bng:getContentSize().width * 0.26,bng:getContentSize().height*0.5))

	local Label4 = ui.newTTFLabelWithOutline({  text = "1", 
											size = 20, 
											color = ccc3(36,255,0),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label4:setPosition(cc.p(bng:getContentSize().width * 0.38,bng:getContentSize().height*0.5))

	local Label5 = ui.newTTFLabelWithOutline({  text = "次探宝机会,每日上限", 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label5:setPosition(cc.p(bng:getContentSize().width * 0.4,bng:getContentSize().height*0.5))

	local Label6 = ui.newTTFLabelWithOutline({  text = self._maxTime, 
											size = 20, 
											color = ccc3(0,240,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label6:setPosition(cc.p(bng:getContentSize().width * 0.79,bng:getContentSize().height*0.5))

	local Label7 = ui.newTTFLabelWithOutline({  text = "次", 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label7:setPosition(cc.p(bng:getContentSize().width * 0.87,bng:getContentSize().height*0.5))
	

	bng:addChild(Label1)
	bng:addChild(Label2)
	bng:addChild(Label3)
	bng:addChild(Label4)
	bng:addChild(Label5)
	bng:addChild(Label6)
	bng:addChild(Label7)
	bng:addChild(moneyIcon)


	bng:setAnchorPoint(cc.p(0,0))
	bng:setPosition(cc.p(param.size.width * 0.06,param.size.height * 0.22))

	local instance = {Label2,Label3,Label4,Label5,Label6,Label7,moneyIcon}
	if self._type == 3 then
		for k,v in pairs(instance) do
			v:setVisible(false)
		end
		bng:setPositionY(bng:getPositionY() - 20)
	end

	self:addChild(bng)

end

function TanbaoMainView:createLabel02(param)
	local titleDisConst = {"今日累计充值:","今日累计消耗:",""}
	local bng = display.newScale9Sprite("#jifenbng_2.png", 0, 0, 
                        cc.size(param.size.width * 0.8, 35))
	local Label1 = ui.newTTFLabelWithOutline({  text = titleDisConst[self._type], 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label1:setPosition(cc.p(bng:getContentSize().width * 0.02,bng:getContentSize().height*0.5))

	local posX = Label1:getPositionX()
	local moneyIcon = display.newSprite("#icon_gold.png")
	moneyIcon:setPosition(cc.p(posX + Label1:getContentSize().width + 20,bng:getContentSize().height*0.5))

	local posX = moneyIcon:getPositionX()
	local Label2 = ui.newTTFLabelWithOutline({  text = self._dayAdd, 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label2:setPosition(cc.p(posX + moneyIcon:getContentSize().width - 10,bng:getContentSize().height*0.5))

	local posX = Label2:getPositionX()
	local Label3 = ui.newTTFLabelWithOutline({  text = "(", 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label3:setPosition(cc.p(posX + Label2:getContentSize().width + 10,bng:getContentSize().height*0.5))

	
	local posX = Label3:getPositionX()
	local Label5 = ui.newTTFLabelWithOutline({  text = self._addTime.."/", 
											size = 20, 
											color = ccc3(255,255,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label5:setPosition(cc.p(posX + Label3:getContentSize().width,bng:getContentSize().height*0.5))

	local posX = Label5:getPositionX()
	local Label6 = ui.newTTFLabelWithOutline({  text = self._maxTime..")", 
											size = 20, 
											color = ccc3(0,240,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	Label6:setPosition(cc.p(posX + Label5:getContentSize().width,bng:getContentSize().height*0.5))
	

	bng:addChild(Label1)
	bng:addChild(Label2)
	bng:addChild(Label3)
	bng:addChild(Label5)
	bng:addChild(Label6)
	bng:addChild(moneyIcon)
	bng:setAnchorPoint(cc.p(0,0))
	bng:setPosition(cc.p(param.size.width * 0.06,param.size.height * 0.15))
	if self._type == 3 then
		bng:setVisible(false)
	end
	self:addChild(bng)
end

function TanbaoMainView:createProgress(param)
	local progress = display.newSprite("#progressbngnull.png")
    local fill = display.newProgressTimer("#progressbng.png", display.PROGRESS_TIMER_BAR)
    fill:setMidpoint(CCPoint(0,0.5))
    fill:setBarChangeRate(CCPoint(1.0,0))
    fill:setPosition(progress:getContentSize().width * 0.5, progress:getContentSize().height * 0.5)
    progress:addChild(fill)
    progress:setPosition(cc.p(param.size.width * 0.5, 75))
    fill:setPercentage(50)
    progress:setAnchorPoint(cc.p(0.5,1))
    self:addChild(progress)


    --宝箱1
    local goldOne = display.newSprite("#submap_box_open_1.png")
	goldOne:setPosition(progress:getContentSize().width * 0.0 + 10, progress:getContentSize().height * 0.5)

	local disLabel = ui.newTTFLabelWithOutline({  text = self._jifenLevel[1].value.."积分", 
											size = 20, 
											color = ccc3(0,240,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	disLabel:setPosition(12,-10)
	goldOne:addChild(disLabel)
	--宝箱2
    local goldTwo = display.newSprite("#submap_box_open_2.png")
	goldTwo:setPosition(progress:getContentSize().width * 0.5 + 10, progress:getContentSize().height * 0.5)

	local disLabel = ui.newTTFLabelWithOutline({  text = self._jifenLevel[2].value.."积分", 
											size = 20,
											color = ccc3(240,0,255),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	disLabel:setPosition(12,-10)
	goldTwo:addChild(disLabel)
	--宝箱3
    local goldThree = display.newSprite("#submap_box_open_3.png")
	goldThree:setPosition(progress:getContentSize().width * 1 + 10, progress:getContentSize().height * 0.5)

	local disLabel = ui.newTTFLabelWithOutline({  text = self._jifenLevel[3].value.."积分", 
											size = 20, 
											color = ccc3(255,210,0),
											outlineColor = ccc3(0,0,0),
									        align= ui.TEXT_ALIGN_CENTE,
									        font = FONTS_NAME.font_fzcy 
									        })
	disLabel:setPosition(12,-10)
	goldThree:addChild(disLabel)

	progress:addChild(goldOne)
	progress:addChild(goldTwo)
	progress:addChild(goldThree)


	self.goldBoxInstance = { goldOne, goldTwo, goldThree }
	self.progress = fill

	local confimFunc = function ()
		local callBack = function (index)
			self._jifenLevel[index].state = 0
			self:refreshGoldBox()
			self:showGiftPopup(self._giftData[index],"恭喜获得如下奖励",nil,boxType.common)
		end
		self:jifenRequest(callBack,self._index)
	end


	for k,v in pairs(self.goldBoxInstance) do
		addTouchListener(v, function(sender,eventType)
	    	if eventType == EventType.began then
	    		sender:setScale(0.9)
	    	elseif eventType == EventType.ended then
	            sender:setScale(1)
	            self._index = k
		        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		        self:showGiftPopup(self._giftData[k],"领奖",confimFunc,boxType.jifen,self._jifenLevel[k])
		        dump(self._giftData)
	        elseif eventType == EventType.cancel then
	        	sender:setScale(1)
	        end
    	end)
	end

	self:refreshGoldBox()
end

function TanbaoMainView:refreshGoldBox()
	local goldRes = { 
		{"#submap_box_close_1.png","#submap_box_close_2.png","#submap_box_close_3.png"},
		{"#submap_box_open_1.png","#submap_box_open_2.png","#submap_box_open_3.png"},
		{"#submap_box_end_1.png","#submap_box_end_3.png","#submap_box_end_3.png"}
	}

	for k,v in pairs(self.goldBoxInstance) do
		if v:getChildByTag(100) then
			v:removeChildByTag(100,true)
		end	
		if self._jifenLevel[k].state == 0 then 	    --完成已领奖
			v:setDisplayFrame(display.newSprite(goldRes[3][k]):getDisplayFrame())
		elseif self._jifenLevel[k].state == -1 then --没完成
			v:setDisplayFrame(display.newSprite(goldRes[1][k]):getDisplayFrame())
		elseif self._jifenLevel[k].state == 1 then -- 完成未领奖
			v:setDisplayFrame(display.newSprite(goldRes[2][k]):getDisplayFrame())
			if not v:getChildByTag(100) then
				local xunhuanEffect = ResMgr.createArma({
	            resType = ResMgr.UI_EFFECT,
	            armaName = "fubenjiangli_shanguang",
	        	})
	        	xunhuanEffect:setPosition(v:getContentSize().width/2,v:getContentSize().height/2)
	        	v:addChild(xunhuanEffect,1,100)
			end
		end
	end

	--刷新进度条
	self.progress:setPercentage(math.ceil(((self._jifen - self._jifenLevel[1].value)/ (self._jifenLevel[3].value - self._jifenLevel[1].value)) * 100))
	local progress
	--分段计算积分进度
	if self._jifen <= self._jifenLevel[2].value then
		local offset = self._jifen - self._jifenLevel[1].value
		progress = ((offset / ((self._jifenLevel[2].value - self._jifenLevel[1].value))) * 100 ) * (0.5)
	elseif self._jifen > self._jifenLevel[2].value then
		local offset = self._jifen - self._jifenLevel[2].value
		progress = ((offset / ((self._jifenLevel[3].value - self._jifenLevel[2].value))) * 100 ) * (0.5) + 50
	elseif self._jifen < self._jifenLevel[1].value then
		progress = 0
	end
	self.progress:setPercentage(math.ceil(progress))
end

function TanbaoMainView:resetRoadLenth(target)
	if self._preTarget and self._preTarget ~= target then
		local temp = self._preTarget
		self._preTarget = target
		target = target - temp + 1
	elseif self._preTarget and self._preTarget == target then
		target = 1 
		self._preTarget = self._preTarget
	elseif not self._preTarget then
		self._preTarget = target
	end
	local round = 6 --动画圈数
	self._totalRatio = (target - 1) * 0.1 + 1 * round
	if self._offset  then
		local offset = math.random(-4,4) * 0.01 --一个单元格弧度0.1
		self._totalRatio = self._totalRatio - self._offset + offset
		self._offset = offset
	else
		self._offset = math.random(-4,4) * 0.01 --一个单元格弧度0.1
		self._totalRatio = self._totalRatio + self._offset
	end
	self.speed = 0 
	self.t1 = 50 -- 加速时间 (缩放因子 100)
	self.t2 = 350-- 减速时间 (缩放因子 100)
	self.timer = 0
	self.a1 = ((self._totalRatio * 2) / (self.t1 + self.t2)) / (self.t1)
	self.a2 = ((self._totalRatio * 2) / (self.t1 + self.t2)) / (self.t2)
	self._schedule = self._scheduler.scheduleGlobal(self.countDown, 0.01, false)
	self.btnOne:setTouchEnabled(false)
	self.btnTen:setTouchEnabled(false)
end

function TanbaoMainView:ctor(param)
	self:load()
	local bng = display.newScale9Sprite("#month_bg.png", 0, 0, 
                param.size)
	bng:setAnchorPoint(cc.p(0,0))
    self:addChild(bng)
	local func = function()
		self:setUpView(param)
	end
	
	self:getData(func)
end 

function TanbaoMainView:close()
	self:release()
end

function TanbaoMainView:load()
	display.addSpriteFramesWithFile("ui/ui_tanbao.plist", "ui/ui_tanbao.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	display.addSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
end

function TanbaoMainView:release()
	display.removeSpriteFramesWithFile("ui/ui_tanbao.plist", "ui/ui_tanbao.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.removeSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.removeSpriteFramesWithFile("ui/taskcommon.plist", "ui/taskcommon.png")
	display.removeSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")  
	display.removeSpriteFramesWithFile("ui/ui_month_card.plist", "ui/ui_month_card.png")
end

function TanbaoMainView:createItemView(pos,node,data)
    local marginTop  = 10
    local marginLeft = 10
    local offset = 100
    local icon = ResMgr.refreshIcon(
    {
        id = data.id, 
        resType = ResMgr.getResType(data.type), 
    }) 
    icon:setAnchorPoint(cc.p(0,0.5)) 
    icon:setPosition(pos)
    icon:setAnchorPoint(cc.p(0.5,0.5))

    addTouchListener(icon, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.73)
    	elseif eventType == EventType.ended then
            sender:setScale(0.75)
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	        local callback = function (data)
	        	self:showGiftPopup(data,"可随机获得一种奖励",nil,boxType.suiji)
	        end
	        self:yuLanRequest(callback,data.itemId)
        elseif eventType == EventType.cancel then
        	sender:setScale(0.75)
        end
    end)
	icon:setScale(0.75)

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
    	node:addChild(icon,1)
    end





    return icon
end

function TanbaoMainView:showGiftPopup(data,title,func,type,dataExtra)
	dump(data)
	local dataTemp = {}
	for k,v in pairs(data) do
		local temp = {}
		temp.id = v.id
		temp.num = v.num
		temp.type = v.type
		temp.iconType = ResMgr.getResType(v.type)
		temp.name = require("data.data_item_item")[v.id].name
		table.insert(dataTemp,temp)
	end
	local msgBox
	if type == boxType.jifen then
		msgBox = require("game.nbactivity.TanBao.JifenRewordBox").new({
	        title = title, 
	        num = dataExtra.value,
	        cellDatas = dataTemp,
	        jifen     = self._jifen,
	        state     = dataExtra.state,
	        confirmFunc = func
        })
	elseif type == boxType.suiji then
		msgBox = require("game.nbactivity.TanBao.SuijiRewordBox").new({
	        title = title, 
	        cellDatas = dataTemp,
	        confirmFunc = func
        })
	elseif type == boxType.common then
		msgBox = require("game.Huodong.RewardMsgBox").new({
	        title = title, 
	        cellDatas = dataTemp,
	        confirmFunc = func
        })
	end
    CCDirector:sharedDirector():getRunningScene():addChild(msgBox,1000)
end

function TanbaoMainView:getData(func)
	ratios = 0
	local function init(data)
		self._type = data.activeData.type
		self._jifen = data.roleDataState.credit
		self._time = data.roleDataState.surTimes
		self._freeTime = data.roleDataState.freeTimes
		self._priceOne = data.activeData.price
		self._priceTen = data.activeData.price * 10       --价格
		self._timeStr = data.roleDataState.activeTime
		self._countDownTime = data.roleDataState.countDown
	    self._maxTime = data.activeData.limitCnt		  --最大的探宝次数
	    self._addTime = data.roleDataState.rouletteTimes  --已获得探宝次数
	    self._dayAdd   = data.roleDataState.dayAdd         --今日累积消耗


		self._baseItem = {}
		self._giftData = {}

		

		for index = 1,3 do
			local dataTemp = {}

			for k,v in pairs(data.activeData["rewardType"..index]) do
				local temp = {}
				temp.id = data.activeData["rewardId"..index][k]
				temp.type = v
				temp.num = data.activeData["rewardCnt"..index][k]
				table.insert(dataTemp,temp)
			end
			table.insert(self._giftData,dataTemp)
		end



		-- dump(data.rouletteState)

		for k,v in pairs(data.rouletteState) do
			local item = {}
			item.id = v.itemDisplay 
			item.itemId = v.id
			if not data_item_item[v.itemDisplay] then
				print(v.itemDisplay)
			end
			if not data_item_item[v.itemDisplay] then 
				printf("-------------erro"..v.itemDisplay)
			end
			item.type   = data_item_item[v.itemDisplay].type
			table.insert(self._baseItem,item)
		end

		table.sort( self._baseItem, function (a,b)
			return a.itemId < b.itemId
		end )
		dump(self._baseItem)

		self._jifenLevel = {
			{value = data.activeData.score[1],state = 1},
			{value = data.activeData.score[2],state = 1},
			{value = data.activeData.score[3],state = 1}
		}

		for k,v in pairs(self._jifenLevel) do
			print(v.value)
			if self._jifen >= v.value then
				v.state = 1
			else
				v.state = -1
			end
		end

		for k,v in pairs(data.roleDataState.getBox) do
			self._jifenLevel[v].state = 0
		end



		local jifen = data.activeData.score1
		func()
	end
	RequestHelper.tanbaoSystem.getBaseInfo({
                callback = function(data)
                    -- dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end
                })
end

function TanbaoMainView:tanBaoRequest(func,type)

	local function init(data)
		dump(data.checkBag)
		if data.checkBag and #data.checkBag > 0 then
        	local layer = require("utility.LackBagSpaceLayer").new({
                bagObj = data.checkBag,
            })
            self:addChild(layer, 10)
        else
        	self._jifen = data.credit
			self._freeTime = data.freeTimes
			self._time = data.surTimes
			self._target = data.position
			self._tanbaoGift = data.itemAry
			self:resetRoadLenth(self._target)

			for k,v in pairs(self._jifenLevel) do
				if self._jifen >= v.value then
					if v.state == 0 then
						v.state = 0
					else
						v.state = 1
					end
				else
					v.state = -1
				end
			end
			func(type)
        end
	end
	RequestHelper.tanbaoSystem.startFind({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end,
                num = type
                })
end

function TanbaoMainView:yuLanRequest(func,index)

	local function init(data)
		local dataTemp = {}
		for k,v in pairs(data.itemType) do
			local temp = {}
			temp.id = data.itemId[k]
			temp.type = v
			temp.num = data.itemCnt[k]
			table.insert(dataTemp,temp)
		end
		func(dataTemp)
	end
	RequestHelper.tanbaoSystem.preViewItem({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end,
                id = index
                })
end

function TanbaoMainView:jifenRequest(func,index)

	local function init(data)
		if data.checkBag and #data.checkBag > 0 then
        	local layer = require("utility.LackBagSpaceLayer").new({
                bagObj = data.checkBag,
            })
            self:addChild(layer, 10)
        else
        	func(index)
        end
	end

	RequestHelper.tanbaoSystem.getReword({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        init(data.rtnObj)
                    end
                end,
                index = index
                })
end

return TanbaoMainView


