
local exchangeCell = class("exchangeCell", BaseLayer)

function exchangeCell:ctor(type, rewardId)
	-- 
    self.super.ctor(self)

    self.activityId 	= type
    self.activityType	= id

    self.rewardId  		= rewardId
    self.index  		= rewardId

    self:loadRewardConfigure()

    self:init("lua.uiconfig_mango_new.operatingactivities.Exchange")
end

function exchangeCell:initUI(ui)
    self.super.initUI(self,ui)
    self.btn_exchange 	= TFDirector:getChildByPath(ui, 'Button_Exchange_1')
    self.txt_times 		= TFDirector:getChildByPath(ui, 'txt_times')
    self.img_disCount 	= TFDirector:getChildByPath(ui, 'Image_Exchange_1')

    self.goodsList = {}
    for i=1,3 do
	    self.goodsList[i] = {}
	    self.goodsList[i].img_bg 	= TFDirector:getChildByPath(ui, 'img_bg_'..i)
	    self.goodsList[i].img_bg:setVisible(false)
    end
    self.img_equal 	= TFDirector:getChildByPath(ui, 'img_equal')
    self.img_equal:setVisible(false)

    local panel_view = TFDirector:getChildByPath(ui, 'Panel_Wuping')
	local scrollView = TFScrollView:create()
	scrollView:setPosition(ccp(0,0))
	scrollView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
	scrollView:setDirection(SCROLLVIEW_DIR_HORIZONTAL)

	scrollView:setSize(panel_view:getSize())
	local height = panel_view:getSize().height
	-- local height2 =  70 * row + 40
	-- -- if height2 < height then
	-- -- 	height2 = height
	-- -- end

	-- scrollView:setInnerContainerSize(CCSizeMake(panel_view:getSize().width , height2))
	panel_view:addChild(scrollView)
	scrollView:setBounceEnabled(true)
	scrollView:setTag(617)

	self.scrollView = scrollView
	self.panel_view = panel_view

	self.needGoodsList = TFArray:new()
	self.gotGoodsList = TFArray:new()

	self.bIsRecruitIntegral = false

	self:drawGoodsList()
	-- scrollView:scrollToTop()
end

function exchangeCell:removeUI()
    self.super.removeUI(self)
end

function exchangeCell:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function exchangeCell:dispose()
    self.super.dispose(self)
end

--[[
刷新界面
]]
function exchangeCell:refreshUI()

	-- self.txt_times
	self.rewardData = OperationActivitiesManager:getActivityRewardData(self.activityId, self.rewardId)

	-- print("self.rewardData = ", self.rewardData)

-- 	self.rewardData =    <<table>>{
-- ├┄┄input="1,2009,1",
-- ├┄┄out="1,2000,30&3,0,100000",
-- ├┄┄status=9,
-- ├┄┄changeTime=0,
-- ├┄┄id=2
-- }
	
	self.exchangeCount = self.rewardData.status - self.rewardData.changeTime

	-- self.txt_times:setText(self.rewardData.changeTime .."/"..self.rewardData.status)
	
	self.txt_times:setText(self.exchangeCount)

	self.img_disCount:setVisible(false)
	if self.rewardData.discount > 0 then
		self.img_disCount:setVisible(true)
		local path  = "ui_new/operatingactivities/z"..self.rewardData.discount..".png"
		self.img_disCount:setTexture(path)
	end

	for v in self.needGoodsList:iterator() do
		local node = v.node
		if v.type == EnumDropType.GOODS then
			Public:loadIconBagNode(node,v)
		else
			Public:loadIconNode(node,v,true)
		end
	end
	-- 组合物品的数据

end



function exchangeCell:drawGoodsList()

	self.needGoodsList:clear()

	self.rewardData = OperationActivitiesManager:getActivityRewardData(self.activityId, self.rewardId)
	local temptbl = string.split(self.rewardData.input,'&')
	local count = 0
	local widthPerNode = 0
	local posx = 0
	local posy = 0
	for k,v in pairs(temptbl) do
		local reward = string.split(v,',')
		count = count + 1
		local commonReward = {}
		commonReward.type 	= tonumber(reward[1])
		commonReward.itemId = tonumber(reward[2])
		commonReward.number = tonumber(reward[3])
		local rewarddata = BaseDataManager:getReward(commonReward)
		-- /self.scrollView
		-- print('reward = ', reward)
		-- print('commonReward = ', commonReward)
		-- print('rewarddata = ', rewarddata)

		local node = Public:createIconNumAndBagNode(rewarddata)
		-- local node = Public:createIconNumAndBagNode(rewarddata)
		node:setScale(0.7)
		node:setPosition(ccp(posx, posy))

		self.scrollView:addChild(node)

		widthPerNode = node:getSize().width

		posx = posx + widthPerNode/2 + 30
		rewarddata.node = node
		self.needGoodsList:push(rewarddata)

		if rewarddata.type == EnumDropType.RECRUITINTEGRAL then
			self.bIsRecruitIntegral = true 
			print("有积分兑换的条目")
		end
	end

	-- 绘制  = 
	local img_equal = TFImage:create("ui_new/operatingactivities/img_denghao.png")
	img_equal:setPosition(ccp(posx+30, 50))
	self.scrollView:addChild(img_equal)

	widthPerNode = img_equal:getSize().width
	posx = posx + widthPerNode/2 + 30

	self.gotGoodsList:clear()
	local temptbl = string.split(self.rewardData.out,'&')
	for k,v in pairs(temptbl) do
		local reward = string.split(v,',')
		count = count + 1
		local commonReward = {}
		commonReward.type 	= tonumber(reward[1])
		commonReward.itemId = tonumber(reward[2])
		commonReward.number = tonumber(reward[3])
		local rewarddata = BaseDataManager:getReward(commonReward)
		-- /self.scrollView

		local node = Public:createIconNumNode(rewarddata)
		node:setScale(0.7)
		node:setPosition(ccp(posx, posy))

		self.scrollView:addChild(node)

		widthPerNode = node:getSize().width
		rewarddata.node = node
		posx = posx + widthPerNode/2 + 30
		self.gotGoodsList:push(rewarddata)
	end

	self.scrollView:setInnerContainerSize(CCSizeMake(posx, self.panel_view:getSize().height))
end

--[[
刷新按钮状态
]]
function exchangeCell:refreshButtonState()

end


function exchangeCell:loadRewardConfigure()
	self.rewardData = OperationActivitiesManager:getActivityRewardData(self.activityId, self.rewardId)

	-- print("self.rewardData = ", self.rewardData)
end

function exchangeCell:setLogic(logic)
    self.logic = logic
end


function exchangeCell.onClick(sender)
    local index = sender.index
    local self  = sender.logic

    local rewardItems = self.rewardItems

	local item = rewardItems:objectAt(index)
	Public:ShowItemTipLayer(item.itemid, item.type);
     
end


function exchangeCell.onExchangeClickHandle(sender)
    local self  = sender.logic

    if self.exchangeCount ==  0 then
    	--toastMessage("兑换次数已用完")
    	toastMessage(localizable.exchangeCell_times_over)
    	return
    end

    -- self.needGoodsList
    local inputStr = ""
    local count = 0
    for v in self.needGoodsList:iterator() do
        if MainPlayer:getGoodsIsEnough(v) == false then

        	--toastMessage("您的"..v.name.."不够")
        	toastMessage(stringUtils.format(localizable.exchangeCell_not_enough,v.name))
        	print("shit  = ", v.number)
        	return
        end
        if count > 0 then
        	inputStr = inputStr .. ","
        end
        count = count + 1
        inputStr = inputStr .. v.name.."X"..v.number
    end
    print("inputStr = ", inputStr)

    local  outStr = ""
    count = 0
    for v in self.gotGoodsList:iterator() do
    	if count > 0 then
        	outStr = outStr .. ","
        end
        count = count + 1
        outStr = outStr .. v.name.."X"..v.number
    end
    print("outStr = ", outStr)

    -- OperationActivitiesManager:sendMsgToGetActivityReward(self.type, self.index)
    --local warningMsg = "大侠，是否使用 ["..inputStr.."] 兑换 ["..outStr.."] ?"
    local warningMsg = stringUtils.format(localizable.exchangeCell_exchange_tips,inputStr,outStr)

    CommonManager:showOperateSureLayer(
            function()
                OperationActivitiesManager:sendMsgToGetActivityReward(self.activityId, self.index)
            end,
            nil,
            {
            	msg = warningMsg
            	-- msg =  "大侠，是否开始兑换？"
            }
    )
end

function exchangeCell:registerEvents()
    self.super.registerEvents(self)

    self.btn_exchange.logic    = self   
    self.btn_exchange:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onExchangeClickHandle),1)
end

function exchangeCell:removeEvents()
    self.super.removeEvents(self)
end

return exchangeCell