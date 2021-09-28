--TrigramsWheelPage.lua
require("app.cfg.wheel_info")
local EffectNode = require "app.common.effects.EffectNode"

local TrigramsWheelPage = class ("TrigramsWheelPage", UFCCSNormalLayer)

local FuCommon = require("app.scenes.dafuweng.FuCommon")


function TrigramsWheelPage.create(...)
	return TrigramsWheelPage.new("ui_layout/trigrams_MyWheel.json", ...)
end

function TrigramsWheelPage:ctor(...)
    self:_initView()
    self.super.ctor(self, ...)

end

function TrigramsWheelPage:setParent(parent)
    self._parent = parent or nil
end

function TrigramsWheelPage:getParent(parent)
    return self._parent
end

function TrigramsWheelPage:_initWheelItems()

	for i = 1, FuCommon.ITEM_MAX_NUM do 
        self:getPanelByName("Panel_item"..i):removeAllChildrenWithCleanup(true)
    end

	self._wheelItemList = {}

	for index = 1, FuCommon.ITEM_MAX_NUM do 
		
		local item = require("app.scenes.trigrams.TrigramsWheelItem").new(index, self)
		
		local panelItem = self:getPanelByName("Panel_item"..index)

		item:setParentPos(panelItem:getPositionX(), panelItem:getPositionY())

        panelItem:addChild(item)

		self._wheelItemList[index] = item
	end
	
end


function TrigramsWheelPage:_initView()

    self:setTouchEnabled(true) 
    
	self._wheelPanel = self:getPanelByName("Panel_wheel")

	self._costPanel = self:getPanelByName("Panel_costInfo")
	self._buttonPanel = self:getPanelByName("Panel_button")

	self._imgPrice1 = self:getImageViewByName("Image_price1")
	self._imgPrice2 = self:getImageViewByName("Image_price2")

	self._count1 = self:getLabelByName("Label_count1")
	self._count2 = self:getLabelByName("Label_count2")
	self._count1:createStroke(Colors.strokeBrown, 1)
	self._count2:createStroke(Colors.strokeBrown, 1)
	self._free1 = self:getLabelByName("Label_free1")
	self._free2 = self:getLabelByName("Label_free2")
	self._free1:createStroke(Colors.strokeBrown, 1)
	self._free2:createStroke(Colors.strokeBrown, 1)
	self._free1:setText(G_lang:get("LANG_TRIGRAMS_FREE"))
	self._free2:setText(G_lang:get("LANG_TRIGRAMS_FREE"))

	--本次开挂花费
	self:getLabelByName("Label_costInfo"):setText(G_lang:get("LANG_TRIGRAMS_COST")) 
            self:getLabelByName("Label_costDesc"):setText(G_lang:get("LANG_TRIGRAMS_COSTDESC")) 
	self:getLabelByName("Label_costInfo"):createStroke(Colors.strokeBrown, 1) 
            self:getLabelByName("Label_costDesc"):createStroke(Colors.strokeBrown, 1) 
	self._playCost = self:getLabelByName("Label_cost")
	self._playCost:createStroke(Colors.strokeBrown, 1)
	self._playCost:setText("")

	--本次开挂免费
	self:getLabelByName("Label_costFree"):setText(G_lang:get("LANG_TRIGRAMS_COSTFREE")) 
	self:getLabelByName("Label_costFree"):createStroke(Colors.strokeBrown, 1)  

    self._refreshButton = self:getButtonByName("Button_refresh")

    self._itemButton = self:getButtonByName("Button_item")

	--刷新花费
	self._refreshCost = self:getLabelByName("Label_refreshCost")
	self._refreshCost:createStroke(Colors.strokeBrown, 1)
	self._refreshFree = self:getLabelByName("Label_refreshFree")
	self._refreshFree:createStroke(Colors.strokeBrown, 1)
	self._refreshFree:setText(G_lang:get("LANG_TRIGRAMS_FREE"))

	--初始化八卦轮盘
	self:_initWheelItems()

	self._pageState = FuCommon.TRIGRAMS_PAGE_STATE_DEFAULT

	--如果上次打开过任意挂盘
	if G_Me.trigramsData:isAniPosOpen() then
		self._pageState = FuCommon.TRIGRAMS_PAGE_STATE_PLAY
	end

    --动画相关
    self._currentFrame = 0
    self._framesCount = 0
    self._startPoints = {}
end


function TrigramsWheelPage:onLayerLoad( ... )

    self:registerBtnClickEvent("Button_buyone", function()
		self:_onTouchPlayOne()
	end)

	self:registerBtnClickEvent("Button_buyall", function()
		self:_onTouchPlayAll()
	end)

	self:registerBtnClickEvent("Button_refresh", function()
		self:_onTouchRefresh()
    end)

    
    self:registerBtnClickEvent("Button_item", function()
        require("app.scenes.trigrams.TrigramsAwardPreviewLayer").show()
    end)

end


function TrigramsWheelPage:onLayerUnload( ... )
    self:_clearAll()
end


--[[
    x' = xcosa + y sina
    y' = ycosa - x sina
    y = sin(Pi*x/d)
]]
--圆心永远在顺时针方向
function TrigramsWheelPage:_startRoundAnimation()
    
    --需要时间
    local frameTime = 0.3  

    self._framesCount = frameTime*30
    --当前帧
    self._currentFrame = 1

    --中心点位置
    local cx = self._wheelPanel:getContentSize().width/2
    local cy = self._wheelPanel:getContentSize().height/2

    --起始点坐标    
    self._startPoints = {}

    for i,v in ipairs(self._wheelItemList) do
        --k 斜率
        local _x,_y = v:getParent():getPosition()

        local width = v:getContentSize().width
        _x = _x + width/2
        _y = _y + width/2
        local k = (_y-cy)/(_x-cx)

        --坐标系旋转角度
        local angle = 0
        if _x < cx then
            angle = math.atan(k)+math.pi
        elseif _x > cx then
            angle = math.atan(k)
        else
            if _y > cy then
                angle = math.pi*0.5
            else
                angle = math.pi*1.5
            end
        end
        local _t ={x = _x, y=_y, angle = angle}
        table.insert(self._startPoints,_t)

    end

    self._actionTimer = GlobalFunc.addTimer(1/30, handler(self,self._playRoundAnimation))
end


--[[
 	播放收拢动画
    x' = xcosa + y sina
    y' = ycosa - x sina

    y = sin(Pi*x/d)
]]
function TrigramsWheelPage:_playRoundAnimation()

	--中心点位置
    local cx = self._wheelPanel:getContentSize().width/2
    local cy = self._wheelPanel:getContentSize().height/2

    --结束
    if self._currentFrame == self._framesCount then
        self._currentFrame = 1   --设置为默认
  
        --先把所有的隐藏掉
        if self._actionTimer ~= nil then
            GlobalFunc.removeTimer(self._actionTimer)
            self._actionTimer = nil
        end
        
        for i,v in ipairs(self._wheelItemList) do
        	--v:removeEffectNode()
            v:setVisible(false)
        end
        self:_playChangeAnimation()
        --self:_playRoundBackAnimation()
        return

    end
    
    for i,v in ipairs(self._wheelItemList) do
        local _t = self._startPoints[i]
        local distance = math.pow((_t.y-cy)*(_t.y-cy)+(_t.x-cx)*(_t.x-cx),1/2)
        local _diff = math.abs(distance/self._framesCount)
        local width = v:getContentSize().width
        local currentX = distance - self._currentFrame*_diff
        local currentY = 50*math.sin(math.pi/distance*(currentX))

        local _currentX = 0
        local _currentY = 0
        _currentX = currentX*math.cos(_t.angle)+currentY*math.sin(_t.angle)+cx-width/2
        _currentY = -currentY*math.cos(_t.angle)+currentX*math.sin(_t.angle)+cy-width/2
        v:getParent():setPositionXY(_currentX,_currentY)
    end

    self._currentFrame = self._currentFrame + 1

end


function TrigramsWheelPage:_changeCallback( ... )
	-- body
	self:setTouchEnabled(true) 

    if self._parent then
        self._parent:setTouchEnabled(true)
    end
	
	for i,v in ipairs(self._wheelItemList) do
	 	--播放打开八卦动画
        --self._wheelItemList[i]:playOpen()  --不用打开
        --增加可打开的发光特效
        self._wheelItemList[i]:addEffectNode("effect_bgqm_light_2", false)
    end
    

    self._pageState = FuCommon.TRIGRAMS_PAGE_STATE_PLAY

    self:_updateOthers()

end

--播放弹开动画
function TrigramsWheelPage:_playRoundBackAnimation()

	local actions = {}

    local delayAction =  CCDelayTime:create(0.25)

    for i,v in ipairs(self._wheelItemList) do
    	local posX, posY = v:getParentPos()
 		v:setVisible(true)
        v:getParent():runAction(CCMoveTo:create(0.15, ccp(posX, posY)))
        --self._wheelItemList[i]:playOpen()
    end

    table.insert(actions,delayAction)

    table.insert(actions, CCCallFunc:create(function() 
        self:_changeCallback()
    end))

    local sequence = transition.sequence(actions)

    self._wheelPanel:runAction(sequence)

end

--播放中心点动画
function TrigramsWheelPage:_playChangeAnimation()

    --让刷新按钮显示在最上层
    self._refreshButton:setZOrder(10)

    self._effectRefreshNode = EffectNode.new("effect_explode_light", function(event, frameIndex)
        if event == "finish" then
            self._effectRefreshNode:removeFromParentAndCleanup(true)
            self._effectRefreshNode = nil
            --self:updatePage()
            self._refreshButton:setZOrder(0)

            self:_playRoundBackAnimation()
        elseif event == "appear" then
            --播放声音特效
            G_SoundManager:playSound(require("app.const.SoundConst").GameSound.TREASURE_COMPOSE) 
            --设置播放动画结束
        end
    end)   

    self._effectRefreshNode:play()

    local size = self._wheelPanel:getContentSize()
    self._effectRefreshNode:setPositionXY(size.width/2,size.height/2)
    self._wheelPanel:addNode(self._effectRefreshNode,5)

end

--刷新所有挂阵
function TrigramsWheelPage:playRefreshAnimation()

    local actions = {}

    --local delayAction =  CCDelayTime:create(0.1)

    local needDelay = false

    --new award list
    local allAwardList = G_Me.trigramsData:getAwardList()

    for i=1, #allAwardList do
        if i <= #self._wheelItemList then
            local level = G_Me.trigramsData:getAwardLevel(i)
    	    self._wheelItemList[i]:setAwardInfo(allAwardList[i], level)
        end
    end


    for i=1, #self._wheelItemList do

    	if not self._wheelItemList[i]:isClose() and not needDelay then
    		needDelay = true
    	end

        local action = CCCallFunc:create(function() 
            self._wheelItemList[i]:playClose(false)
        end)
        table.insert(actions, action)
        --table.insert(actions, delayAction)	    
    end

    if needDelay then
    	table.insert(actions, CCDelayTime:create(FuCommon.MOVE_TIME+0.25))
    end

    for i=1, #self._wheelItemList do
    	--if self._wheelItemList[i]:isClose() then
	        local action = CCCallFunc:create(function() 
	            self._wheelItemList[i]:playOpen(true)
	         end)
	        table.insert(actions, action)
	        --table.insert(actions, delayAction)
	    --end
    end

    table.insert(actions, CCDelayTime:create(FuCommon.MOVE_TIME+0.25))

    table.insert(actions, CCCallFunc:create(function() 
         self:_refreshCallback()
    end))

    local sequence = transition.sequence(actions)
    self._wheelPanel:runAction(sequence)

end


function TrigramsWheelPage:_refreshCallback( ... )
	-- body
	self:setTouchEnabled(true) 

    if self._parent then
        self._parent:setTouchEnabled(true)
    end

    self._pageState = FuCommon.TRIGRAMS_PAGE_STATE_DEFAULT

    self:_updateOthers()

end


function TrigramsWheelPage:playOpenOneAnimation(award, awardLevel, index, bagua, targetCtl)

    --能点刷新按钮
    self:setRefreshButtonEnable(true)

    if type(index) == "number" and index <= #self._wheelItemList then
    	self._wheelItemList[index]:setAwardInfo(award, awardLevel)
    	self._wheelItemList[index]:playOpenOne(bagua, targetCtl)
    	self:_updateOthers()
    end
end


function TrigramsWheelPage:_onTouchPlayOne()

	--禁止重复多次点击
    self:setTouchEnabled(false)  

    if self._parent then
        self._parent:setTouchEnabled(false)
    end


    local actions = {}

    local delayAction =  CCDelayTime:create(0.1)

    for i=1, #self._wheelItemList do 
        local action = CCCallFunc:create(function() 
            --self._wheelItemList[i]:addEffectNode("effect_prepare_compose", true)
            self._wheelItemList[i]:playClose(false)
         end)
        table.insert(actions, action)

        --table.insert(actions, delayAction)
    end

    table.insert(actions, CCDelayTime:create(FuCommon.MOVE_TIME))

    table.insert(actions, CCCallFunc:create(function() 
         self:_startRoundAnimation()
    end))

    local sequence = transition.sequence(actions)
    self._wheelPanel:runAction(sequence)

end

function TrigramsWheelPage:_onTouchPlayAll()
    local cost = G_Me.trigramsData:getPrice(FuCommon.ITEM_MAX_NUM)
    if G_Me.userData.gold >= cost then
        if self._parent then
            self._parent:setPlayAll(true)
        end

        G_HandlersManager.trigramsHandler:sendPlayAll()
    else
        require("app.scenes.shop.GoldNotEnoughDialog").show()
    end
end

function TrigramsWheelPage:_onTouchRefresh()

    if self._effectRefreshNode ~= nil then
        self._effectRefreshNode:removeFromParentAndCleanup(true)
        self._effectRefreshNode = nil
    end

	if self._pageState == FuCommon.TRIGRAMS_PAGE_STATE_DEFAULT or G_Me.trigramsData:isAniPosOpen() then
		local cost = G_Me.trigramsData:getRefreshPrice()
		if cost == 0 or G_Me.userData.gold >= cost then
			--禁止重复多次点击
	        self:setTouchEnabled(false)  
			G_HandlersManager.trigramsHandler:sendRefresh()
		else
			require("app.scenes.shop.GoldNotEnoughDialog").show()
		end
	else
	    --G_MovingTip:showMovingTip(G_lang:get("LANG_TRIGRAMS_REFRESH_TIP"))
        --返回上个界面
        self:setTouchEnabled(false)
        self:playRefreshAnimation()
	end

end


function TrigramsWheelPage:setRefreshButtonEnable(enable)
    local _enable = enable or false

    self._refreshButton:setEnabled(_enable)

end

function TrigramsWheelPage:onLayerEnter( ... )

end

function TrigramsWheelPage:onLayerExit( ... )
	
end


--销毁
function TrigramsWheelPage:_clearAll()

    if self._actionTimer ~= nil then
        GlobalFunc.removeTimer(self._actionTimer)
        self._actionTimer = nil
    end

    for i,v in ipairs(self._wheelItemList) do
        v:destory()
    end

    self._wheelPanel:stopAllActions()

	 if self._effectRefreshNode ~= nil then
        self._effectRefreshNode:removeFromParentAndCleanup(true)
        self._effectRefreshNode = nil
    end
end



function TrigramsWheelPage:setPageState( state )

	self._pageState = state

end


function TrigramsWheelPage:_updateWheelItems( ... )

	for index = 1, #self._wheelItemList do 

        self._wheelItemList[index]:updateView()
	end
end


function TrigramsWheelPage:_updateOthers( )

	local cost1 = G_Me.trigramsData:getPrice(1)
	local cost2 = G_Me.trigramsData:getPrice(FuCommon.ITEM_MAX_NUM)

	self._count1:setText(cost1)
	self._count2:setText(cost2)
	self._count1:setColor(G_Me.userData.gold >= cost1 and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_01)
	self._count2:setColor(G_Me.userData.gold >= cost2 and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_01)

	self._playCost:setText(cost1)
	self._playCost:setColor(G_Me.userData.gold >= cost1 and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_01)

	
	local refresh_cost = G_Me.trigramsData:getRefreshPrice()
    local image_refresh_cost = self:getImageViewByName("Image_refreshCostGold")
	image_refresh_cost:setVisible(self._pageState == FuCommon.TRIGRAMS_PAGE_STATE_DEFAULT)

    local image_refresh = self:getImageViewByName("Image_refresh")
    if self._pageState == FuCommon.TRIGRAMS_PAGE_STATE_PLAY then
        if G_Me.trigramsData:isAniPosOpen() then
            image_refresh:loadTexture("ui/text/txt/qmbg_dianjichongzhi.png")
        else
            image_refresh:loadTexture("ui/text/txt/qmbg_dianjifanhui.png")
        end
    else
        image_refresh:loadTexture("ui/text/txt/qmbg_genghuanwupin.png")
    end
	
	self._refreshCost:setColor(G_Me.userData.gold >= refresh_cost and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_01)
	self._refreshCost:setText(refresh_cost > 0 and tostring(refresh_cost) or  G_lang:get("LANG_TRIGRAMS_FREE") )
	self._refreshFree:setVisible(self._pageState == FuCommon.TRIGRAMS_PAGE_STATE_PLAY)

	self._count1:setVisible(cost1>0)
	self._count2:setVisible(cost2>0)

	self._imgPrice1:setVisible(false)--cost1>0)
	self._imgPrice2:setVisible(cost2>0)
	self._free1:setVisible(false)--cost1==0)
	self._free2:setVisible(cost2==0)

	if cost1 == 0 then
	    self._free1:setText(G_lang:get("LANG_TRIGRAMS_FREE2",{num=G_Me.trigramsData:getFreeLeft(self._index)}))
	end

	self._free2:setVisible(cost2==0)

	self:getLabelByName("Label_costFree"):setVisible(cost1==0)
	self:getPanelByName("Panel_cost"):setVisible(cost1>0)

	self._buttonPanel:setVisible(false)
	self._costPanel:setVisible(false)


	if self._pageState == FuCommon.TRIGRAMS_PAGE_STATE_PLAY then
		self._costPanel:setVisible(true)
	else
		self._buttonPanel:setVisible(true)
	end

end


function TrigramsWheelPage:updateView()

	self:_updateOthers()
	
	self:_updateWheelItems()

end


return TrigramsWheelPage