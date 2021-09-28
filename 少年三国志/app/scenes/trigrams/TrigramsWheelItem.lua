
local EffectNode = require "app.common.effects.EffectNode"

local FuCommon = require("app.scenes.dafuweng.FuCommon")

local ICON_BG_ZORDER = 0     --道具背景图标
local ICON_ZORDER = 1        --获得道具图标
local AWARD_ZORDER = 8       --获得八卦阵图图标
local COVER_ZORDER = 3       --八卦遮罩图标
local NUMBER_ZORDER = 10     --道具数目
local EFFECT_ZORDER = 20     --特效

local ICON_TAG = 100
local ICON_NAME_TAG = 1000
local AWARD_NAME_TAG = 2000
local LEFT_NAME_TAG = 3000
local RIGHT_NAME_TAG = 4000

local MINI_ICON_CIRCLE_RADIUS = 30
local ICON_CIRCLE_RADIUS = 40
local COVER_CIRCLE_RADIUS = 48

local MOVE_DISTANCE = 92     --移动距离

local ICON_DEFAULT_POS = ccp(-3, 2)  --道具图标位置调整
local COVER_DEFAULT_POS = ccp(-3, 2) --八卦图标位置调整

local BORDER_TEXTURE = { }

local TrigramsWheelItem = class("TrigramsWheelItem", function (  )
    return CCSItemCellBase:create("ui_layout/trigrams_MyWheelItem.json")
end)

function TrigramsWheelItem:ctor(index, parent)

    self._index = index or 1   --位置序号

    self._parent = parent or nil

    self._awardInfo = G_Me.trigramsData:getAwardInfo(self._index)

    self._awardLevel = G_Me.trigramsData:getAwardLevel(self._index)

    self._isClose = false

    --上次打开过任意非本位置的挂盘
    if G_Me.trigramsData:isAniPosOpen() and not self._awardInfo then
    	self._isClose = true
    end

    self._parentX = 0
    self._parentY = 0

	self._bgImage = self:getImageViewByName("Image_bg")
	self._borderKuang = self:getImageViewByName("Image_border")
	self._iconBg = self:getImageViewByName("Image_back")
	self._iconImage = self:getImageViewByName("Image_icon")
	self._numberLable = self:getLabelByName("Label_num")
	self._numberLable:setText("")
	self._numberLable:createStroke(Colors.strokeBrown, 1)

	--道具背景
	self._iconBgNode = self:_createClippingNode(FuCommon.ICON_TEST, ICON_CIRCLE_RADIUS)
	self._iconBgNode:getChildByTag(ICON_TAG):setScale(0.95)
	self._bgImage:addNode(self._iconBgNode, ICON_BG_ZORDER)
	self._iconBgNode:setVisible(false)

	--道具图标
	self._iconNode = self:_createClippingNode(FuCommon.ICON_TEST, ICON_CIRCLE_RADIUS)
	self._iconNode:getChildByTag(ICON_TAG):setScale(0.95)
	self._bgImage:addNode(self._iconNode, ICON_ZORDER)
	self._iconNode:setVisible(false)

	--获得卦阵图标
	self._awardNode = nil

	--八卦左半边
	self._leftNode = self:_createClippingNode(FuCommon.ICON_LEFT_WHEEL, COVER_CIRCLE_RADIUS)
	self._bgImage:addNode(self._leftNode, COVER_ZORDER)
	self._leftNode:setVisible(self._isClose)
	self._leftNode:setPositionY(2)

	--八卦右半边
	self._rightNode = self:_createClippingNode(FuCommon.ICON_RIGHT_WHEEL, COVER_CIRCLE_RADIUS)
	self._bgImage:addNode(self._rightNode, COVER_ZORDER)
	self._rightNode:setVisible(self._isClose)
	self._rightNode:setPositionY(2)

	self:registerWidgetTouchEvent("Image_border", handler(self, self._onClickItem))

end


function TrigramsWheelItem:_onClickItem(widget, event)

    if event == TOUCH_EVENT_BEGAN then
	    self._bgImage:setScale(1.1)
    elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
        self._bgImage:setScale(1)
    end

    -- deal with the logic when touch ended
    if event == TOUCH_EVENT_ENDED then

    	-- 没有被打开过 
    	if self._isClose and not G_Me.trigramsData:isPosOpen(self._index) then

    		local cost = G_Me.trigramsData:getPrice(1)
			if G_Me.userData.gold >= cost then

				--不能点刷新按钮
				if self._parent then
					self._parent:setRefreshButtonEnable(false)
					self._parent:getParent():setButtonEnable(false)
				end

	    		G_HandlersManager.trigramsHandler:sendPlay(self._index)
	    	else
				require("app.scenes.shop.GoldNotEnoughDialog").show()
	    	end
    	elseif self._awardInfo then						
    		require("app.scenes.common.dropinfo.DropInfo").show(self._awardInfo.type, self._awardInfo.value)
		end
    end


end


function TrigramsWheelItem:_flyAward(bagua, targetCtl)

	if not self._awardNode and bagua and targetCtl then

		local good = G_Goods.convert(bagua.type, bagua.value)
		self._awardNode = self:_createClippingNode(good.icon, MINI_ICON_CIRCLE_RADIUS)
		self._awardNode:getChildByTag(ICON_TAG):setScale(1)
		self._bgImage:addNode(self._awardNode, AWARD_ZORDER)
		self._awardNode:getChildByTag(ICON_TAG):setPositionXY(0, 0)
		self._awardNode:setPosition(ICON_DEFAULT_POS)

		local effect1 = EffectNode.new("effect_juexing_a")
    	effect1:play()
    	self._bgImage:addNode(effect1,AWARD_ZORDER-1)

    	local effect2 = EffectNode.new("effect_particle_star")
    	effect2:play()
    	effect2:setScale(0.6)
    	self._bgImage:addNode(effect2,EFFECT_ZORDER)

		local startPtx, startPty = self._awardNode:convertToWorldSpaceXY(0, 0)
		local endPtx, endPty = targetCtl:convertToWorldSpaceXY(0, 0)

		local moveAction = CCMoveBy:create(0.4, ccp(endPtx - startPtx, endPty - startPty))
		local scaleAction = CCScaleTo:create(0.4, 0.01)

		local easeAction = CCSpawn:createWithTwoActions(moveAction, scaleAction)
		
		local callback1 = CCCallFunc:create(function ( node )
			--print("-------------effect remove")
			effect1:removeFromParentAndCleanup(true)
			effect2:removeFromParentAndCleanup(true)
		end)

		local callback2 = CCCallFunc:create(function ( node )
			self._awardNode:removeFromParentAndCleanup(true)
			self._awardNode = nil

			if self._parent then
				self._parent:getParent():setButtonEnable(true)
			end
		end)

		local actionArr = CCArray:create()
		actionArr:addObject(CCDelayTime:create(0.75))
		actionArr:addObject(callback1)
		actionArr:addObject(easeAction)
		actionArr:addObject(callback2)
		self._awardNode:runAction(CCSequence:create(actionArr))
	end

end


function TrigramsWheelItem:playOpenOne(bagua, targetCtl)
	self:addEffectNode("effect_bgqm_light_1", true, function()
		self:playOpen(false)
		self:_flyAward(bagua, targetCtl)
	end)
end


--打开卦象
function TrigramsWheelItem:playOpen(needShowTip)

	--已经处于打开状态
	if not self._isClose then
		return
	end

	self:removeEffectNode()
	self:_removeOpenEffectNode()

	self._isClose = false

	self._leftNode:setVisible(true)
	self._leftNode:getChildByTag(ICON_TAG):setPosition(COVER_DEFAULT_POS)
	self._rightNode:setVisible(true)
	self._rightNode:getChildByTag(ICON_TAG):setPosition(COVER_DEFAULT_POS)

	local leftActions = {}
	table.insert(leftActions,CCMoveBy:create(FuCommon.MOVE_TIME, ccp(-MOVE_DISTANCE, 0 )))
    table.insert(leftActions, CCCallFunc:create(function() 
        self._leftNode:setVisible(false)
    end))

    local leftSequence = transition.sequence(leftActions)
    self._leftNode:getChildByTag(ICON_TAG):runAction(leftSequence)

	local rightActions = {}

	table.insert(rightActions, CCCallFunc:create(function()
	    self:updateView()
	end))

	table.insert(rightActions,CCMoveBy:create(FuCommon.MOVE_TIME, ccp(MOVE_DISTANCE, 0 )))
    table.insert(rightActions, CCCallFunc:create(function() 
        self._rightNode:setVisible(false)
    end))

    if needShowTip then
	    --table.insert(rightActions, CCDelayTime:create(FuCommon.MOVE_TIME))
		table.insert(rightActions, CCCallFunc:create(function() 
		    self:_playTipAction()
		end))
	end

    local rightSequence = transition.sequence(rightActions)
    self._rightNode:getChildByTag(ICON_TAG):runAction(rightSequence)



end

function TrigramsWheelItem:isClose()
	return self._isClose
end

--关闭卦象
function TrigramsWheelItem:playClose()

	if self._isClose then
		return
	end

	self._isClose = true

	self:removeEffectNode()

	self._numberLable:setVisible(false)

	self._leftNode:setVisible(true)
	self._leftNode:getChildByTag(ICON_TAG):setPositionX(COVER_DEFAULT_POS.x - MOVE_DISTANCE)
	self._rightNode:setVisible(true)
	self._rightNode:getChildByTag(ICON_TAG):setPositionX(COVER_DEFAULT_POS.x + MOVE_DISTANCE)

	self._leftNode:getChildByTag(ICON_TAG):runAction(CCMoveBy:create(FuCommon.MOVE_TIME, ccp(MOVE_DISTANCE, 0 )))
	self._rightNode:getChildByTag(ICON_TAG):runAction(CCMoveBy:create(FuCommon.MOVE_TIME, ccp(-MOVE_DISTANCE, 0 )))

end


function TrigramsWheelItem:_createClippingNode(maskInfo, radius)

	local drawNode = CCDrawNode:create()
    local pointsCount = 200
    local pointarr1 = CCPointArray:create(pointsCount)

    local angle = 2*math.pi/pointsCount

    for i=1, pointsCount do
       pointarr1:add(ccp(radius*math.cos((i-1)*angle), radius*math.sin((i-1)*angle)))
    end
    
    if device.platform == "wp8" or device.platform == "winrt" then
        G_WP8.drawPolygon(drawNode, pointarr1, pointsCount, ccc4f(1, 1, 1, 1), 1, ccc4f(1, 1, 1, 1))
    else
        drawNode:drawPolygon(pointarr1:fetchPoints(), pointsCount, ccc4f(1, 1, 1, 1), 1, ccc4f(1, 1, 1, 1) )
    end

    local iconStencil = ImageView:create()
    iconStencil:loadTexture(maskInfo)

    local clipNode = CCClippingNode:create()
    clipNode:setTouchEnabled(false)
    --clipNode:setInverted(true)
    --clipNode:setAlphaThreshold(0)
    clipNode:setStencil(drawNode)
    clipNode:setPositionXY(0,0)
    clipNode:addChild(iconStencil, ICON_TAG, ICON_TAG)

    --背景框有阴影，遮盖部分位置微调
    iconStencil:setPosition(COVER_DEFAULT_POS)

    return clipNode

end


function TrigramsWheelItem:setAwardInfo( awardInfo, awardLevel)
	
	if type(awardInfo) ~= "table" then return end

	self._awardInfo = awardInfo

	self._awardLevel = awardLevel or G_Me.trigramsData:getAwardLevel(self._index)

end

function TrigramsWheelItem:updateView()

	if self._awardInfo and not self._isClose then
		self._iconNode:setVisible(true)
		self._iconBgNode:setVisible(true)

		local good = G_Goods.convert(self._awardInfo.type, self._awardInfo.value)
		if good then
			self._iconImage:setVisible(false)
			self._iconNode:getChildByTag(ICON_TAG):loadTexture(good.icon)
			self._iconBgNode:getChildByTag(ICON_TAG):loadTexture(G_Path.getEquipIconBack(good.quality))
			self._borderKuang:loadTexture(FuCommon["TRIGRAMS_BORDER_"..self._awardLevel])
          	
          	--self:_playTipAction()

		else
			self._iconNode:setVisible(false)
			self._borderKuang:loadTexture(FuCommon["TRIGRAMS_BORDER_1"])
			self._iconImage:setVisible(true)
		end
	else

	end

	self:_updateOthers()

end

function TrigramsWheelItem:_updateOthers()

	self._numberLable:setVisible(false)

	if self._awardInfo and not self._isClose then
		local good = G_Goods.convert(self._awardInfo.type, self._awardInfo.value)
		if good then
			self._numberLable:setVisible(true)
			self._numberLable:setText("x"..GlobalFunc.ConvertNumToCharacter3(self._awardInfo.size))
            if self._awardLevel == FuCommon.TRIGRAMS_BORDER_MAX then
                self:addEffectNode("effect_bgqm_startquan", false)
            end
		end
	end

	if self._isClose then
        self:addOpenEffectNode()
    end
end


--记录初始位置
function TrigramsWheelItem:setParentPos(x, y)
	self._parentX = x
	self._parentY = y
end

function TrigramsWheelItem:getParentPos()
	return self._parentX, self._parentY
end


function TrigramsWheelItem:setVisible(visible)
	self._bgImage:setVisible(visible)
end


function TrigramsWheelItem:_playTipAction()

	--刷新时 高等级有个放大效果
	if self._awardLevel == FuCommon.TRIGRAMS_REWARD_LEVEL_1 then
	
		self._bgImage:stopAllActions()

		local actions = {}

	    table.insert(actions,CCScaleTo:create(0.25, 1.3))
	    table.insert(actions,CCScaleTo:create(0.25, 1))
	    table.insert(actions,CCCallFunc:create(function() 
	            self._bgImage:stopAllActions()
	        end))
	    
	    self._bgImage:runAction(transition.sequence(actions))
	end

end

function TrigramsWheelItem:_removeOpenEffectNode()

	if self._openEffectNode then
		self._openEffectNode:removeFromParentAndCleanup(true)
        self._openEffectNode = nil
	end

end


function TrigramsWheelItem:addOpenEffectNode()

	self:_removeOpenEffectNode()

	self._openEffectNode = EffectNode.new("effect_bgqm_light_2")
  
    self._openEffectNode:play()

    local pt = self._openEffectNode:getPositionInCCPoint()
    local size = self:getContentSize()
    self._openEffectNode:setPosition(ccp(-3, 4))

    self._bgImage:addNode(self._openEffectNode,EFFECT_ZORDER)

end

function TrigramsWheelItem:addEffectNode(effectName, finishRemove, finishCallback)

	self:removeEffectNode()

	self._effectNode = EffectNode.new(effectName,function(event, frameIndex)
        if event == "finish" and finishRemove then
            self._effectNode:removeFromParentAndCleanup(true)
            self._effectNode = nil
            if finishCallback then
            	finishCallback()
            end
        end
    end)
  
    self._effectNode:play()

    local pt = self._effectNode:getPositionInCCPoint()
    local size = self:getContentSize()
    self._effectNode:setPosition(ccp(2, 5))

    if effectName == "effect_bgqm_light_1" then
    	self._effectNode:setPosition(ccp(-4, 3))
    elseif effectName == "effect_bgqm_light_2" then
    	self._effectNode:setPosition(ccp(-3, 4))
    end

    self._bgImage:addNode(self._effectNode,EFFECT_ZORDER)

end


function TrigramsWheelItem:removeEffectNode()

	if self._effectNode then
		self._effectNode:removeFromParentAndCleanup(true)
        self._effectNode = nil
	end

end


function TrigramsWheelItem:destory()
	self:removeEffectNode()
	self:_removeOpenEffectNode()
	self:removeAllNodes()
	self:stopAllActions()
end

return TrigramsWheelItem


