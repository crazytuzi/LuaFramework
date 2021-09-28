--
-- Author: Daneil
-- Date: 2015-02-02 20:11:29
--
local data_ui_ui = require("data.data_ui_ui")
local data_yabiao_jiangli_yabiao_jiangli = require("data.data_yabiao_jiangli_yabiao_jiangli")
local data_config_yabiao_config_yabiao = require("data.data_config_yabiao_config_yabiao")
local data_item_item = require("data.data_item_item")

local btnCloseRes = {
	    normal   =  "#win_base_close.png",
	    pressed  =  "#win_base_close.png",
	    disabled =  "#win_base_close.png"
	}
local YabiaoSelectView = class("YabiaoSelectView", function()
    return display.newLayer("YabiaoSelectView")
end)

function YabiaoSelectView:ctor(param)
	self:loadRes()
	local func = function()
		self:setUpView(param)
	end
	self:_getData(func)
end

function YabiaoSelectView:setUpView(param)

	self:createMask()
	--背景
	local mainBng = display.newScale9Sprite("#win_base_bg2.png", 0, 0, 
                    	cc.size(display.width ,display.width * 1.1))
                    	:pos(display.cx,display.cy)
                    	:addTo(self)

    local mainBngSize = mainBng:getContentSize()
    local innnerBng = display.newScale9Sprite("#win_base_inner_bg_light.png", 0, 0, 
                        cc.size(mainBngSize.width * 0.95,mainBngSize.width * 1.1 * 0.87))
                        :pos(mainBngSize.width/2,mainBngSize.height/2 - 25)
                        :addTo(mainBng)
    --title标签
    local titleText = ui.newBMFontLabel({
        				text = "信息", 
        				size = 22, 
        				align = ui.TEXT_ALIGN_CENTER , 
        				font = "res/fonts/font_title.fnt"})
        				:pos( mainBngSize.width * 0.5, 
         				mainBngSize.height * 0.97)

    titleText:setAnchorPoint(cc.p(0.5,1))
    mainBng:addChild(titleText)
    --关闭按钮
    local closeBtn = display.newSprite(btnCloseRes.normal)

    addTouchListener(closeBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
    		self:close()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)   
    
    closeBtn:pos(mainBngSize.width - 30, mainBngSize.height- 30)
    closeBtn:addTo(mainBng):setAnchorPoint(cc.p(0.5,0.5))

    local offset = 24
    self._cars   = {}
    for i = 1,4 do
    	local node = self:createCardNode(i)
    	node:setPosition((innnerBng:getContentSize().width / 5) * i +  (i - 2.5)*offset, innnerBng:getContentSize().height - 120)
    	self._cars[i] = node
    	innnerBng:addChild(node)
    end



	local shuaxinBtn = display.newSprite("#mianfeishuanxin.png")
	shuaxinBtn:setPosition(cc.p(innnerBng:getContentSize().width * 0.2,innnerBng:getContentSize().height * 0.42))
	local yunbiaoBtn = display.newSprite("#kaishiyunbiao.png")
	yunbiaoBtn:setPosition(cc.p(innnerBng:getContentSize().width * 0.8,innnerBng:getContentSize().height * 0.42))
	innnerBng:addChild(shuaxinBtn)
	innnerBng:addChild(yunbiaoBtn)

	addTouchListener(shuaxinBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            self:_refreshData(1)
            if self._target == 4 then
            	show_tip_label("已经是最高级镖车了，请开始运镖吧")
            	return 
            end
            if self._shuaxinCishu ~= 0 then
            	self:refreshBtns()
            end
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    addTouchListener(yunbiaoBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            if self._target == 0 then
            	show_tip_label("请选择您的镖车")
            	return 
            end
            if self._yabiaoCishu == 0 then
            	show_tip_label("您的可押镖次数为0")
            	return
            end
            self:_startRunCar()
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)
    self._shuaxinBtn = shuaxinBtn
    self._yabiaoBtn = yunbiaoBtn

    if self._shuaxinCishu ~= 0 then
		self:refreshBtns()
	end

	local yabiaoTime = ui.newTTFLabel({  text = "今天可押镖次数:", 
											size = 20, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = ccc3(92,38,1),
									        font = FONTS_NAME.font_fzcy })
	local jiebiaoTime = ui.newTTFLabel({  text = "今天可劫镖次数:", 
											size = 20, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = ccc3(92,38,1),
									        font = FONTS_NAME.font_fzcy })
	local yabiaoTimeValue = ui.newTTFLabel({  text = self._yabiaoCishu, 
											size = 20, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = ccc3(92,38,1),
									        font = FONTS_NAME.font_fzcy })
	local jiebiaoTimeValue = ui.newTTFLabel({  text = self._jiebiaoCishu, 
											size = 20, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = ccc3(92,38,1),
									        font = FONTS_NAME.font_fzcy })
	yabiaoTime:setPosition(cc.p(innnerBng:getContentSize().width * 0.2,innnerBng:getContentSize().height * 0.33))
	jiebiaoTime:setPosition(cc.p(innnerBng:getContentSize().width * 0.8,innnerBng:getContentSize().height * 0.33))
	yabiaoTimeValue:setPosition(cc.p(innnerBng:getContentSize().width * 0.35,innnerBng:getContentSize().height * 0.33))
	jiebiaoTimeValue:setPosition(cc.p(innnerBng:getContentSize().width * 0.95,innnerBng:getContentSize().height * 0.33))
	innnerBng:addChild(yabiaoTime)
	innnerBng:addChild(jiebiaoTime)
	innnerBng:addChild(yabiaoTimeValue)
	innnerBng:addChild(jiebiaoTimeValue)


	local contentBng = display.newScale9Sprite("#guild_cbg_itemInnerBg_1.png", 0, 0, 
                    	cc.size(innnerBng:getContentSize().width - 30,innnerBng:getContentSize().height * 0.27))
                    	:pos(innnerBng:getContentSize().width / 2 , 15)
                    	:addTo(innnerBng)
    contentBng:setAnchorPoint(cc.p(0.5,0)) 
    local txt = data_ui_ui[9].content
    local content    = CCLabelTTF:create(txt, FONTS_NAME.font_fzcy, 18,
        				cc.size(contentBng:getContentSize().width - 30,0), 
        				kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    content:setAnchorPoint(cc.p(0.5,1))
    content:setColor(ccc3(124,0,0))
    content:setPosition(cc.p(contentBng:getContentSize().width / 2,contentBng:getContentSize().height - 20))
    contentBng:addChild(content)   

    if self._carId ~=0 then
    	self:randomCard(self._carId,false)
    end         	
end

function YabiaoSelectView:refreshGold()
	game.player:setGold(self.gold)
    PostNotice(NoticeKey.CommonUpdate_Label_Gold)
end

--重置刷新按钮
function YabiaoSelectView:refreshBtns()
	self._shuaxinBtn:setDisplayFrame(display.newSprite("#yuanbaoshuaxin.png"):getDisplayFrame())
	self._shuaxinPrice = ui.newTTFLabelWithShadow({
		            text = data_config_yabiao_config_yabiao[18].value,
		            size = 18, 
		            color = ccc3(252,28,255),
		            shadowColor = ccc3(0,0,0),
		            font = FONTS_NAME.font_fzcy,
		            align = ui.TEXT_ALIGN_LEFT
		        }) 		
	self._shuaxinPrice:setPosition(cc.p(self._shuaxinBtn:getContentSize().width * 0.7,self._shuaxinBtn:getContentSize().height * 0.5))
	self._shuaxinBtn:addChild(self._shuaxinPrice)
end

function YabiaoSelectView:forbidenBtns()
	if self._shuaxinCishu ~= 0 then
		self._shuaxinBtn:setDisplayFrame(display.newSprite("#yuanbaoshuaxin_p.png"):getDisplayFrame())
	else
		self._shuaxinBtn:setDisplayFrame(display.newSprite("#mianfeishuanxin_p.png"):getDisplayFrame())
	end
	self._yabiaoBtn:setDisplayFrame(display.newSprite("#kaishiyunbiao_p.png"):getDisplayFrame())
	self._yabiaoBtn:setTouchEnabled(false)
	self._shuaxinBtn:setTouchEnabled(false)

end

function YabiaoSelectView:activityBtns()
	if self._shuaxinCishu ~= 0 then
		self._shuaxinBtn:setDisplayFrame(display.newSprite("#yuanbaoshuaxin.png"):getDisplayFrame())
	else
		self._shuaxinBtn:setDisplayFrame(display.newSprite("#mianfeishuanxin.png"):getDisplayFrame())
	end
	self._yabiaoBtn:setDisplayFrame(display.newSprite("#kaishiyunbiao.png"):getDisplayFrame())
	self._yabiaoBtn:setTouchEnabled(true)
	self._shuaxinBtn:setTouchEnabled(true)
end

---
-- 创建卡牌节点
function YabiaoSelectView:createCardNode(types)
	local node = display.newNode()
	local cardSp = display.newSprite("#card_car_0"..types..".png")
	node:addChild(cardSp)

	local disBng = display.newScale9Sprite("#guild_cbg_innerBg_light.png", 0, 0, 
                    	cc.size(cardSp:getContentSize().width ,cardSp:getContentSize().height * 0.3))
	disBng:setAnchorPoint(cc.p(0.5,1))
    disBng:setPosition(cc.p(0,  - 10 - cardSp:getContentSize().height / 2 ))                	
    node:addChild(disBng)


    local titleBng = display.newSprite("#jiangli_tag.png")
    titleBng:setPosition(cc.p(disBng:getContentSize().width/2,disBng:getContentSize().height))
    disBng:addChild(titleBng)

    local dataBase = data_yabiao_jiangli_yabiao_jiangli[types]
    local itemId1 = dataBase.rewardIds[1]
    local itemId2 = dataBase.rewardIds[2]
    local num01 = dataBase.fix[1] + dataBase.ratio[1] * game.player:getLevel()
    local num02 = dataBase.fix[2] + dataBase.ratio[2] * game.player:getLevel()

    local yinbiTag 	=  ui.newTTFLabelWithShadow({
			            text = data_item_item[itemId1].name,
			            size = size or 18, 
			            color = FONT_COLOR.WHITE,
			            shadowColor = ccc3(0,0,0),
			            font = FONTS_NAME.font_fzcy,
			            align = ui.TEXT_ALIGN_LEFT
			        }) 				
    local yinbiValue = ui.newTTFLabelWithShadow({
			            text = num01,
			            size = size or 18, 
			            color = ccc3(0,216,255),
			            shadowColor = ccc3(0,0,0),
			            font = FONTS_NAME.font_fzcy,
			            align = ui.TEXT_ALIGN_LEFT
			        }) 	

    local shengwangTag   = ui.newTTFLabelWithShadow({
			            text = data_item_item[itemId2].name,
			            size = size or 18, 
			            color = FONT_COLOR.WHITE,
			            shadowColor = ccc3(0,0,0),
			            font = FONTS_NAME.font_fzcy,
			            align = ui.TEXT_ALIGN_LEFT
			        }) 	
    local shengwangValue = ui.newTTFLabelWithShadow({
			            text = num02,
			            size = size or 18, 
			            color = ccc3(252,28,255),
			            shadowColor = ccc3(0,0,0),
			            font = FONTS_NAME.font_fzcy,
			            align = ui.TEXT_ALIGN_LEFT
			        }) 	
    yinbiTag:setPosition(cc.p(10,disBng:getContentSize().height * 0.62))
    yinbiValue:setPosition(cc.p(15 + yinbiTag:getContentSize().width ,disBng:getContentSize().height * 0.62))
	shengwangTag:setPosition(cc.p(10,disBng:getContentSize().height * 0.25))
	shengwangValue:setPosition(cc.p(25 + shengwangValue:getContentSize().width ,disBng:getContentSize().height * 0.25))

	local zhaoHuanBtn = display.newSprite("#zhuaohuan.png")
	zhaoHuanBtn:setPosition(cc.p(cardSp:getContentSize().width/2,cardSp:getContentSize().height * 0.1))
	cardSp:addChild(zhaoHuanBtn)
	zhaoHuanBtn:setVisible(types == 4)


	local zhaohuanPrice = ui.newTTFLabelWithShadow({
			            text = data_config_yabiao_config_yabiao[19].value,
			            size = size or 18, 
			            color = ccc3(252,28,255),
			            shadowColor = ccc3(0,0,0),
			            font = FONTS_NAME.font_fzcy,
			            align = ui.TEXT_ALIGN_LEFT
			        }) 		
	zhaohuanPrice:setPosition(cc.p(zhaoHuanBtn:getContentSize().width * 0.7,zhaoHuanBtn:getContentSize().height * 0.5))
	zhaoHuanBtn:addChild(zhaohuanPrice)

	addTouchListener(zhaoHuanBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            if self._target == 4 then
            	show_tip_label("已经是最高级镖车了，请开始运镖吧")
            	return 
            end
            local func = function()
            		self:_refreshData(2)
            	end
            	self:addChild(require("game.Yabiao.YabiaoSpeedUpCommitPopup").new(
            		{ 
            			cost = data_config_yabiao_config_yabiao[19].value,
            			disStr = "召唤金色品质镖车?",
            			confirmFunc = func
            		}
				))
            
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)



   	disBng:addChild(yinbiTag)
   	disBng:addChild(yinbiValue)
	disBng:addChild(shengwangTag)
	disBng:addChild(shengwangValue)

	return node
end

function YabiaoSelectView:randomCard(target,isPlayAnimation)
	
	local baseSeed = 1
	local speed = 2
	local counter = 1
	local select = display.newSprite("#card_car_select.png")
	self._target = target
	for k,v in pairs(self._cars) do
		local select = display.newSprite("#card_car_select.png")
		if not v:getChildByTag(111) then
			v:addChild(select,0,111)
		end
		v:getChildByTag(111):setVisible(false)
	end
	local step = 0.0
	local speed = 0.01
	local counter = 1
	local taget = target
	local countDownFuc 
	countDownFuc = function ()
		self:performWithDelay(function ()
			if step >= speed * 19 + speed * taget then
				self:activityBtns()
				return 
			end
	    	step = step + speed
    		counter = (counter + 1) % 5 == 0 and 1 or (counter + 1) % 5
			for k,v in pairs(self._cars) do
    			v:getChildByTag(111):setVisible(false)
			end
			self._cars[counter]:getChildByTag(111):setVisible(true)
			countDownFuc()
	    end,step)
	end
	if isPlayAnimation then
		self:forbidenBtns()
		countDownFuc()
	else
		self._cars[target]:getChildByTag(111):setVisible(true)
	end
end

---
-- 创建蒙板
function YabiaoSelectView:createMask()
	local winSize = CCDirector:sharedDirector():getWinSize()
    local mask = CCLayerColor:create()
    mask:setContentSize(winSize)
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(150)
    mask:setAnchorPoint(cc.p(0,0))
    mask:setTouchEnabled(true)
    self:addChild(mask)
end
  
function YabiaoSelectView:loadRes()
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")

end

function YabiaoSelectView:releaseRes()
	display.removeSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
end

function YabiaoSelectView:close()
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
	self:releaseRes()
	if self._scheduler then
		self._scheduler.unscheduleGlobal(self._schedule)
	end
	self:removeFromParent()
end

--初始化镖车状态
function YabiaoSelectView:_getData(func)
	local initData = function (data)
		if data.lastQuality == 0 then
			--没有选择镖车
		else
			--已经选择镖车
		end
		self._yabiaoCishu   = data.detainTimes
		self._jiebiaoCishu  = data.robTimes
		self._shuaxinCishu  = data.refreshTimes
		self._shuaxinCost   = data.refreshCost
		self._carId = data.lastQuality
		self._target = data.lastQuality
		func()
	end
	RequestHelper.yaBiaoSystem.carSelectState({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
end

--刷新镖车
function YabiaoSelectView:_refreshData(type)
	local initData = function (data)
		self._target = data.quality
		self.refreshTime = data.refreshTimes
		self:randomCard(self._target, type == 1)
		self.gold = data.gold
		self:refreshGold()
	end
	RequestHelper.yaBiaoSystem.callNBCar({
				tag = type,
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
end

--开始运镖
function YabiaoSelectView:_startRunCar()
	local initData = function (data)
		if data.result == 1 then
			print("success!!")
			selfCarInfo.types  = self._target
			selfCarInfo.name   = game.player.m_name
			selfCarInfo.level  = game.player:getLevel()
			selfCarInfo.roleId = game.player.m_playerID
			selfCarInfo.dartkey = data.dartKey

			for k,v in pairs(selfCarInfo) do
				print(k,v)
			end

			PostNotice(NoticeKey.Yabiao_run_car)
			self:close()
		end
	end
	RequestHelper.yaBiaoSystem.beginRun({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
end

return YabiaoSelectView

