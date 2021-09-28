-- 招财符宝箱奖励弹窗

local ActivityDailyFortuneBoxAwardLayer = class("ActivityDailyFortuneBoxAwardLayer", UFCCSModelLayer)

require "app.cfg.fortune_box_info"

ActivityDailyFortuneBoxAwardLayer.AWARD_NUM = 2
ActivityDailyFortuneBoxAwardLayer.ANIM_STATE_OPEN = 1
ActivityDailyFortuneBoxAwardLayer.ANIM_STATE_CLOSE = 2
ActivityDailyFortuneBoxAwardLayer.BOX_TIMES = {10, 20, 30}

function ActivityDailyFortuneBoxAwardLayer.show( boxIdx, posX, posY, ... )
	local layer = ActivityDailyFortuneBoxAwardLayer.new( "ui_layout/activity_DailyFortuneBoxAwardLayer.json", Colors.modelColor, boxIdx, posX, posY, ... )
	uf_sceneManager:getCurScene():addChild(layer)
end


function ActivityDailyFortuneBoxAwardLayer:ctor( json, color, boxIdx, posX, posY, ... )
	self._boxIdx = boxIdx
	self._startPosX = posX
	self._startPosY = posY
	self._animState = ActivityDailyFortuneBoxAwardLayer.ANIM_STATE_OPEN
	self:attachImageTextForBtn("Button_Get","ImageView_Light")

	local curTimes = G_Me.activityData.fortune:getTimes()
	if curTimes < ActivityDailyFortuneBoxAwardLayer.BOX_TIMES[self._boxIdx] then 
		self:getButtonByName("Button_Get"):setTouchEnabled(false)
	end

	self.super.ctor(self, json)
end


function ActivityDailyFortuneBoxAwardLayer:onLayerEnter(  )
	self:_playWindowAnim(ActivityDailyFortuneBoxAwardLayer.ANIM_STATE_OPEN)
	self:closeAtReturn(true)

	local boxInfo = fortune_box_info.get(self._boxIdx)
	if not boxInfo then
		return
	end

	-- 奖励物品的显示
	for i = 1, ActivityDailyFortuneBoxAwardLayer.AWARD_NUM do 
		local awardInfo = G_Goods.convert(boxInfo["type_" .. i], boxInfo["value_" .. i])
		if awardInfo then
			self:getImageViewByName("Image_Bouns_Bg_" .. i):loadTexture(awardInfo.icon)
			self:getImageViewByName("Image_Bouns_Icon_" .. i):loadTexture(G_Path.getEquipColorImage(awardInfo.quality, awardInfo.type))
			self:registerWidgetClickEvent("Image_Bouns_Icon_" .. i, function (  )
				require("app.scenes.common.dropinfo.DropInfo").show(awardInfo.type, awardInfo.value)
			end)

			local nameLabel = self:getLabelByName("Label_Bouns_Name_" .. i)
			nameLabel:createStroke(Colors.strokeBrown, 1)
			nameLabel:setColor(Colors.getColor(awardInfo.quality))
			nameLabel:setText(awardInfo.name)


			local numLabel = self:getLabelByName("Label_Bouns_Num_" .. i)
			numLabel:createStroke(Colors.strokeBrown, 1)
			numLabel:setText("x" .. G_GlobalFunc.ConvertNumToCharacter(tonumber(boxInfo["size_" .. i])))	
		else
			self:showWidgetByName("ImageView_Bouns_" .. i, false)

			self:getImageViewByName("ImageView_Bouns_1"):setPositionX(0)
		end
	end

	self:registerBtnClickEvent("Button_Get", function (  )
		self:_getAward()
	end)

	self:registerBtnClickEvent("Button_Close", function (  )
		self:_onCloseBtnClicked()
	end)

	local boxStatusInfo = G_Me.activityData.fortune:getBoxStatus()
	if boxStatusInfo[self._boxIdx] then
		self:showWidgetByName("Button_Get", false)
		self:showWidgetByName("ImageView_AleadyGet", true)
	end
end

function ActivityDailyFortuneBoxAwardLayer:_playWindowAnim( state )
	self._animState = state

    local startScale = 1
    local endScale = 1
    local startPos = ccp(0,0)
    local endPos = ccp(0,0)
    local size = self:getContentSize()
    if state == ActivityDailyFortuneBoxAwardLayer.ANIM_STATE_OPEN then
        startScale = 0.2
        endScale = 1
        startPos = ccp(self._startPosX, self._startPosY)
        endPos = ccp(size.width/2, size.height/2)
    else
        startScale = 1
        endScale = 0.2
        startPos = ccp(size.width/2, size.height/2)
        endPos = ccp(self._startPosX, self._startPosY)
    end
    
    local img = self:getImageViewByName("ImageView_Bg")
    img:setScale(startScale)
    img:setPosition(startPos)
    local array = CCArray:create()
    array:addObject(CCMoveTo:create(0.2, endPos))
    array:addObject(CCScaleTo:create(0.2, endScale))
    local sequence = transition.sequence(
    {
    CCSpawn:create(array),
    CCCallFunc:create(
        function()
            if self._animState == ActivityDailyFortuneBoxAwardLayer.ANIM_STATE_CLOSE then
                self:close()
            else
                -- self:setBackColor(self._color)
            end
        end)
	})
    img:runAction(sequence)
end

function ActivityDailyFortuneBoxAwardLayer:_getAward(  )
	local curTimes = G_Me.activityData.fortune:getTimes()

	if curTimes >= ActivityDailyFortuneBoxAwardLayer.BOX_TIMES[self._boxIdx] then 
		G_HandlersManager.activityHandler:sendFortuneGetBox(self._boxIdx)
		self:animationToClose()
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_FORTUNE_TIMES_NOT_ENOUGH"))
	end
end

function ActivityDailyFortuneBoxAwardLayer:_onCloseBtnClicked(  )
	self:_playWindowAnim(ActivityDailyFortuneBoxAwardLayer.ANIM_STATE_CLOSE)
end

return ActivityDailyFortuneBoxAwardLayer