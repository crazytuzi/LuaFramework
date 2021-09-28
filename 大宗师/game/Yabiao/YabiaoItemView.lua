--
-- Author: Daniel
-- Date: 2015-02-02 10:58:58
--
local YabiaoItemView = class("YabiaoItemView", function()
    return display.newNode()
end)

function YabiaoItemView:ctor(param)
	self:setUpView(param)
end
local posX = {
	display.width * 0.2,
	display.width * 0.4,
	display.width * 0.6,
	display.width * 0.8,
}
function YabiaoItemView:setUpView(param)
	local types = param.types
	local name  = param.name 
	local level = param.level
	self._mid   = param.mid
	self._time  = param.time
	self._roleId = param.roleId
	self.timeLeft = self._time
	if self._mid then
		self._posX = display.width / 2
	else
		local  x = randomPosX(self._time)
		print(x)
		self._posX = posX[x]
	end
	
	

	--镖车
	self.carSprite = nil
	if self._mid then
		self.carSprite = display.newSprite("#car_0"..types.."_h"..".png")
		self:setScale(0.7)
	else
		self.carSprite = display.newSprite("#car_0"..types..".png")
		self:setScale(0.7)
	end
	
	
	self._totalTime = param.totalTime

	self._dartkey = param.dartkey

	self._posY = self:getYposBytime(self._time)

	self._speed = self:getSpeed()

	
	local upShadowBng = display.newSprite("#up_mash_bng.png")
	local downShadowBng = display.newSprite("#down_mash_bng.png")

	local nameColor = nil
	if self._mid then
		nameColor = ccc3(7,239,2)
	else
		nameColor = FONT_COLOR.WHITE
	end

	local nameLabel  =  ui.newTTFLabel({text = name, 
				    	font = FONTS_NAME.font_fzcy, 
				    	align = ui.TEXT_ALIGN_LEFT,
				        size = 18,color = nameColor})
	local levelLabel =  ui.newTTFLabel({text = "Lv:"..level, 
				    	font = FONTS_NAME.font_fzcy, 
				    	align = ui.TEXT_ALIGN_LEFT,
				        size = 18,color = ccc3(255,222,0)})
	local timeLabel  =  ui.newTTFLabel({text = format_time(self._time), 
				    	font = FONTS_NAME.font_fzcy, 
				    	align = ui.TEXT_ALIGN_LEFT,
				        size = 18,color = ccc3(7,239,2)})
	local timeTitle  =  ui.newTTFLabel({text = "到达时间", 
				    	font = FONTS_NAME.font_fzcy, 
				    	align = ui.TEXT_ALIGN_LEFT,
				        size = 18,color = FONT_COLOR.WHITE})

	

	upShadowBng:addChild(nameLabel,0,1)
	upShadowBng:addChild(levelLabel,0,2)
	downShadowBng:addChild(timeLabel,0,3)
	downShadowBng:addChild(timeTitle,0,4)

	upShadowBng:setPositionY(180)
	self.carSprite:setAnchorPoint(cc.p(0.5,0))

	self:addChild(self.carSprite,0,1)
	self:addChild(upShadowBng,0,2)
	self:addChild(downShadowBng,0,3)

	nameLabel:setPosition(cc.p(upShadowBng:getContentSize().width / 2,(upShadowBng:getContentSize().height * 2) / 3))
	levelLabel:setPosition(cc.p(upShadowBng:getContentSize().width / 2,(upShadowBng:getContentSize().height * 1) / 3))

	timeTitle:setPosition(cc.p(50,(downShadowBng:getContentSize().height ) / 2))
	timeLabel:setPosition(cc.p(timeTitle:getPositionX() + timeTitle:getContentSize().width + 10,(downShadowBng:getContentSize().height ) / 2))
	timeLabel:setAnchorPoint(cc.p(0,0.5))
	timeTitle:setAnchorPoint(cc.p(0,0.5))


	self:setPosition(self:getX(), self:getY() + self:getSpeed() / speedSeed)

    local countDown = function()
    			self:setPosition(self:getX(), self:getY() + self:getSpeed() / speedSeed)
    			self:setY(self:getY() + self:getSpeed() / speedSeed)
			end
	self._scheduler = require("framework.scheduler")
	self._schedule = self._scheduler.scheduleGlobal(countDown, 1 / speedSeed, false )	


	local countDownTimer = function()
    			self._time = self._time - 1
    			timeLabel:setString(format_time(self._time))
    			if self._time <= 0 then
    				self._scheduler.unscheduleGlobal(self._schedule)
    				self._schedulerTimer.unscheduleGlobal(self._scheduleTimer)
    				self:completeTask()
    			end
			end
	self._schedulerTimer = require("framework.scheduler")
	self._scheduleTimer = self._schedulerTimer.scheduleGlobal(countDownTimer, 1 , false )	


	addTouchListener(self.carSprite, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            CCDirector:sharedDirector():getRunningScene():addChild(require("game.Yabiao.YabiaoDetailView").new(
            		{ 
            			roleId  = self._roleId,
            			dartkey = self._dartkey,
            			type = self._roleId == game.player.m_playerID and 2 or 1
					}
            	))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)


   
end

--计算Y坐标
function YabiaoItemView:getYposBytime(time)
	return (mapHeight) * ( 1 - (time / (self._totalTime * 60)))
end

function YabiaoItemView:completeTask()
	BeingRemoveId = self._roleId
	PostNotice(NoticeKey.Yabiao_repair_enemy)
	local callBack = function ()
		self:getChildByTag(1):setTouchEnabled(false)
	end
	if not self._mid then
		self:getChildByTag(1):runAction(self:createFadeAction(callBack))
		self:getChildByTag(2):runAction(self:createFadeAction())
		self:getChildByTag(3):runAction(self:createFadeAction())
		self:getChildByTag(2):getChildByTag(1):runAction(self:createFadeAction())
		self:getChildByTag(2):getChildByTag(2):runAction(self:createFadeAction())
		self:getChildByTag(3):getChildByTag(3):runAction(self:createFadeAction())
		self:getChildByTag(3):getChildByTag(4):runAction(self:createFadeAction())
	end
end

function YabiaoItemView:createFadeAction(func)
	return transition.sequence({
	    	CCFadeOut:create(2.0), 
	    	CCCallFunc:create(function()
	    		if func then
	    			func()
	    		end
    		end)
    	})
end

function YabiaoItemView:removeSelf()
	if self._scheduler then
		self._scheduler.unscheduleGlobal(self._schedule)
	end
	if self._schedulerTimer then
		self._schedulerTimer.unscheduleGlobal(self._scheduleTimer)
	end
	self:removeFromParent()	
end

function YabiaoItemView:getSpeed()
	return (mapHeight) / (self._totalTime * 60)
end

function YabiaoItemView:getY()
	return self._posY
end

function YabiaoItemView:getX()
	return self._posX
end

function YabiaoItemView:setX(postionX)
	self._posX = postionX
end

function YabiaoItemView:setY(postionY)
	self._posY = postionY
end


return YabiaoItemView

