--[[
******周赛 押注*******

    -- by quanhuan
    -- 2015/12/4
]]

local ZhenbashaiBets = class("ZhenbashaiBets", BaseLayer)

CREATE_PANEL_FUN(ZhenbashaiBets)


function ZhenbashaiBets:ctor(id)
    self.super.ctor(self,id)
    self:init("lua.uiconfig_mango_new.zhenbashai.ZhenbashaiBets")
end

function ZhenbashaiBets:initUI(ui)
	self.super.initUI(self,ui)

	--操作按钮
	self.btn_use			= TFDirector:getChildByPath(ui, 'Btn_buy')
	self.btn_close			= TFDirector:getChildByPath(ui, 'btn_close')


	self.slider_OpenMore	= TFDirector:getChildByPath(ui, 'slider_shop')
	self.bg_jindushuzhi		= TFDirector:getChildByPath(ui, 'bg_jindushuzhi')
	self.txt_num			= TFDirector:getChildByPath(ui, 'txt_num')
	self.btn_jia			= TFDirector:getChildByPath(ui, 'btn_add')
	self.btn_jian			= TFDirector:getChildByPath(ui, 'btn_reduce')


	self.txt_numnow			= TFDirector:getChildByPath(ui, 'txt_numnow')


	--为按钮绑定处理逻辑属性，指向self
	self.btn_use.logic = self
	self.btn_jia.logic = self
	self.btn_jian.logic = self
	self.slider_OpenMore.logic = self
	self.slider_OpenMore:setZOrder(10)

	self.choiceNum = 1000
	self.maxNum = MainPlayer:getCoin()
	
	if self.maxNum > 1000000 then
		self.maxNum = 1000000
	end
end

function ZhenbashaiBets:removeUI()
	

	self.btn_use			= nil
	self.btn_close			= nil
	self.slider_OpenMore	= nil
	self.bg_jindushuzhi		= nil
	self.txt_num			= nil
	self.btn_jia			= nil
	self.btn_jian			= nil

	self.txt_numnow			= nil

	--调用父类方法
	self.super.removeUI(self)
end


function ZhenbashaiBets:onShow()
	self.super.onShow(self)


    self:refreshUI()
end

function ZhenbashaiBets:setNum( num )
	self.txt_num:setText(num)
	self.txt_numnow:setText(num)
	local percent = math.ceil(num/self.maxNum*100)
	self.slider_OpenMore:setPercent(percent)



	if self.choiceNum > self.maxNum then
		self.txt_numnow:setColor(ccc3(255,0,0))
	else
		self.txt_numnow:setColor(ccc3(0,0,0))
	end
end


function ZhenbashaiBets:refreshUI()
	self:setNum(self.choiceNum)
	self.bg_jindushuzhi:setVisible(false)

	self:freshButtonState()
end

function ZhenbashaiBets.reduceButtonClickHandle(sender)
	local self = sender.logic
	self.choiceNum = self.choiceNum - 1000
	if self.choiceNum > 0 then
		sender.logic:setNum(self.choiceNum)
	end
	self:freshButtonState()
end

function ZhenbashaiBets.addButtonClickHandle(sender)
	local self = sender.logic
	self.choiceNum = self.choiceNum + 1000
	if self.choiceNum > self.maxNum then
		self.choiceNum = self.maxNum 
	end
	sender.logic:setNum(self.choiceNum)
	self:freshButtonState()
end

function ZhenbashaiBets.useButtonClickHandle(sender)
	local self = sender.logic
	if self.choiceNum < 1000 then
		-- toastMessage("押注不能小于1000");
		toastMessage(stringUtils.format(localizable.weekrace_yazhu, 1000))
		return
	end
	WeekRaceManager:requestBet(self.msgRound,self.msgIndex,self.choiceNum,self.msgPlayerId)
	AlertManager:close()
end

function ZhenbashaiBets.sliderTouchBeginHandle(sender)
	local self = sender.logic
	self.bg_jindushuzhi:setVisible(true)
	self:freshSliderNum()
end

function ZhenbashaiBets.sliderTouchMoveHandle(sender)
	local self = sender.logic
	self:freshSliderNum()
end

function ZhenbashaiBets.sliderTouchEndHandle(sender)
	local self = sender.logic

	local percent = math.ceil(self.choiceNum /self.maxNum*100)
	self.slider_OpenMore:setPercent(percent)

	self.bg_jindushuzhi:setVisible(false)
	self:freshButtonState()
end

function ZhenbashaiBets:freshSliderNum()
	local percent = self.slider_OpenMore:getPercent()/100
	local num = math.ceil(percent*self.maxNum)
	self.choiceNum = math.max(num,1000)
	self.txt_num:setText(self.choiceNum)
	self.txt_numnow:setText(self.choiceNum)
	local width = self.slider_OpenMore:getSize().width
	local temp = math.ceil(width*percent)
	self.bg_jindushuzhi:setPositionX(temp - width/2)
end

--设置按钮状态
function ZhenbashaiBets:freshButtonState()
	if self.choiceNum >= self.maxNum then
		self.btn_jia:setTouchEnabled(false)
		self.btn_jia:setGrayEnabled(true)
	else
		self.btn_jia:setTouchEnabled(true)
		self.btn_jia:setGrayEnabled(false)
	end

	if self.choiceNum > 1000 then
		self.btn_jian:setTouchEnabled(true)
		self.btn_jian:setGrayEnabled(false)
	else
		self.btn_jian:setTouchEnabled(false)
		self.btn_jian:setGrayEnabled(true)
	end
end

--刷新回调
function ZhenbashaiBets:refreshCallback()
    self:refreshUI()
end

function ZhenbashaiBets:registerEvents()
	self.super.registerEvents(self)

	ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
	self.btn_close:setClickAreaLength(100);

	self.btn_use:addMEListener(TFWIDGET_CLICK, audioClickfun(self.useButtonClickHandle),1)
	self.btn_jia:addMEListener(TFWIDGET_CLICK, audioClickfun(self.addButtonClickHandle),1)
	self.btn_jian:addMEListener(TFWIDGET_CLICK, audioClickfun(self.reduceButtonClickHandle),1)
	self.slider_OpenMore:addMEListener(TFWIDGET_TOUCHBEGAN, audioClickfun(self.sliderTouchBeginHandle),1)
	self.slider_OpenMore:addMEListener(TFWIDGET_TOUCHMOVED, audioClickfun(self.sliderTouchMoveHandle),1)
	self.slider_OpenMore:addMEListener(TFWIDGET_TOUCHENDED, audioClickfun(self.sliderTouchEndHandle),1)


end

function ZhenbashaiBets:removeEvents()
    self.btn_jia:removeMEListener(TFWIDGET_CLICK)
	self.btn_jian:removeMEListener(TFWIDGET_CLICK)
	self.btn_use:removeMEListener(TFWIDGET_CLICK)

	self.slider_OpenMore:removeMEListener(TFWIDGET_TOUCHBEGAN)
	self.slider_OpenMore:removeMEListener(TFWIDGET_TOUCHMOVED)
	self.slider_OpenMore:removeMEListener(TFWIDGET_TOUCHENDED)

    self.super.removeEvents(self)
end

function ZhenbashaiBets:setData( msgRound, msgIndex, msgPlayerId )
	 self.msgRound = msgRound
	 self.msgIndex = msgIndex
	 self.msgPlayerId = msgPlayerId
end

return ZhenbashaiBets;
