-- OpenMore
-- Author: david.dai
-- Date: 2014-06-16 11:14:56
--

local OpenMore = class("OpenMore", BaseLayer)

CREATE_PANEL_FUN(OpenMore)


function OpenMore:ctor(id)
    self.super.ctor(self,id)
    self.id = id
  --   if maxNum then
		-- self.maxNum = maxNum
  --   end
    self:init("lua.uiconfig_mango_new.common.OpenMore")
end

function OpenMore:initUI(ui)
	self.super.initUI(self,ui)

	--操作按钮
	self.img_quality		= TFDirector:getChildByPath(ui, 'img_quality')
	self.img_icon			= TFDirector:getChildByPath(ui, 'img_icon')
	self.txt_name			= TFDirector:getChildByPath(ui, 'txt_name')
	self.btn_use			= TFDirector:getChildByPath(ui, 'btn_qianghua')
	self.btn_close			= TFDirector:getChildByPath(ui, 'btn_close')
	self.txt_info			= TFDirector:getChildByPath(ui, 'txt_info')
	self.slider_OpenMore	= TFDirector:getChildByPath(ui, 'Slider_OpenMore')
	self.bg_jindushuzhi		= TFDirector:getChildByPath(ui, 'bg_jindushuzhi')
	self.txt_num			= TFDirector:getChildByPath(ui, 'txt_num')
	self.btn_jia			= TFDirector:getChildByPath(ui, 'btn_jia')
	self.btn_jian			= TFDirector:getChildByPath(ui, 'btn_jian')
	self.txt_maxnum			= TFDirector:getChildByPath(ui, 'txt_maxnum')
	self.txt_numnow			= TFDirector:getChildByPath(ui, 'txt_numnow')
	self.txt_num22			= TFDirector:getChildByPath(ui, 'txt_num22')
	self.txt_boxnum			= TFDirector:getChildByPath(ui, 'txt_boxnum')


	--为按钮绑定处理逻辑属性，指向self
	self.btn_use.logic = self
	self.btn_jia.logic = self
	self.btn_jian.logic = self
	self.slider_OpenMore.logic = self
	self.slider_OpenMore:setZOrder(10)
	self:initInfo(self.id)
end

function OpenMore:removeUI()
	self.img_quality		= nil
	self.img_icon			= nil
	self.txt_name			= nil
	self.btn_use			= nil
	self.btn_close			= nil
	self.txt_info			= nil
	self.slider_OpenMore	= nil
	self.bg_jindushuzhi		= nil
	self.txt_num			= nil
	self.btn_jia			= nil
	self.btn_jian			= nil
	self.txt_maxnum			= nil
	self.txt_numnow			= nil

	--调用父类方法
	self.super.removeUI(self)
end


function OpenMore:onShow()
	self.super.onShow(self)
    self:refreshUI()
end



function OpenMore:initInfo( id )
	local itemInfo = BagManager:getItemById(id)
	if itemInfo == nil then
		print("背包没有该物品 id == ",id)
		return
	end
	self.itemInfo = itemInfo

	self.img_quality:setTexture(GetColorIconByQuality(itemInfo.quality))
	self.img_icon:setTexture(itemInfo:GetPath())
	self.txt_name:setText(itemInfo.name)
	self.txt_info:setText(itemInfo.describe2)

	self.txt_num22:setVisible(false)
	self.maxNum = self.itemInfo.num
	if itemInfo.kind == 32 then
		local statusCode,boxId,keyId = BagManager:isBoxHaveKeyToOpen(id)
		if statusCode == 0 then
			local boxItem = BagManager:getItemById(boxId)
			local keyItem = BagManager:getItemById(keyId)
			local maxNum = math.min(boxItem.num,keyItem.num)
			self.maxNum = math.min(maxNum,10)
			self.txt_num22:setVisible(true)

			if boxId == id then
				--self.txt_num22:setText("钥匙数量：")
				self.txt_num22:setText(localizable.openMore_key)
				self.txt_boxnum:setText(keyItem.num)
			else
				--self.txt_num22:setText("宝箱数量：")
				self.txt_num22:setText(localizable.openMore_box_number)
				self.txt_boxnum:setText(boxItem.num)
			end
		end
	end


	self.choiceNum = self.maxNum
	self:refreshUI()
end

function OpenMore:setNum( num )
	self.txt_num:setText(num)
	self.txt_numnow:setText(num .."/"..self.maxNum)
	local percent = math.ceil(num/self.maxNum*100)
	self.slider_OpenMore:setPercent(percent)
end


function OpenMore:refreshUI()
	local itemInfo = self.itemInfo
    self.txt_maxnum:setText(itemInfo.num)
	self:setNum(self.choiceNum)
	self.bg_jindushuzhi:setVisible(false)

	self:freshButtonState()
end

function OpenMore.reduceButtonClickHandle(sender)
	local self = sender.logic
	self.choiceNum = self.choiceNum - 1
	if self.choiceNum > 0 then
		sender.logic:setNum(self.choiceNum)
	end
	self:freshButtonState()
end

function OpenMore.addButtonClickHandle(sender)
	local self = sender.logic
	self.choiceNum = self.choiceNum + 1
	sender.logic:setNum(self.choiceNum)
	self:freshButtonState()
end

function OpenMore.useButtonClickHandle(sender)
	local self = sender.logic
	if self.choiceNum < 1 then
		--toastMessage("数量不能为0");
		toastMessage(stringUtils.format(localizable.openMore_number_no_zero,0));

		return
	end
	BagManager:useBatchItem( self.id ,self.choiceNum)
	AlertManager:close()
end

function OpenMore.sliderTouchBeginHandle(sender)
	local self = sender.logic
	self.bg_jindushuzhi:setVisible(true)
	self:freshSliderNum()
end

function OpenMore.sliderTouchMoveHandle(sender)
	local self = sender.logic
	self:freshSliderNum()
end

function OpenMore.sliderTouchEndHandle(sender)
	local self = sender.logic

	local percent = math.ceil(self.choiceNum /self.maxNum*100)
	self.slider_OpenMore:setPercent(percent)

	self.bg_jindushuzhi:setVisible(false)
	self:freshButtonState()
end

function OpenMore:freshSliderNum()
	local percent = self.slider_OpenMore:getPercent()/100
	local num = math.ceil(percent*self.maxNum)
	self.choiceNum = math.max(num,1)
	self.txt_num:setText(self.choiceNum)
	self.txt_numnow:setText(self.choiceNum .."/"..self.maxNum)
	local width = self.slider_OpenMore:getSize().width
	local temp = math.ceil(width*percent)
	self.bg_jindushuzhi:setPositionX(temp - width/2)
end

--设置按钮状态
function OpenMore:freshButtonState()
	if self.choiceNum >= self.maxNum then
		self.btn_jia:setTouchEnabled(false)
		self.btn_jia:setGrayEnabled(true)
	else
		self.btn_jia:setTouchEnabled(true)
		self.btn_jia:setGrayEnabled(false)
	end

	if self.choiceNum > 1 then
		self.btn_jian:setTouchEnabled(true)
		self.btn_jian:setGrayEnabled(false)
	else
		self.btn_jian:setTouchEnabled(false)
		self.btn_jian:setGrayEnabled(true)
	end
end

--刷新回调
function OpenMore:refreshCallback()
    self:refreshUI()
end

function OpenMore:registerEvents()
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

function OpenMore:removeEvents()
    self.btn_jia:removeMEListener(TFWIDGET_CLICK)
	self.btn_jian:removeMEListener(TFWIDGET_CLICK)
	self.btn_use:removeMEListener(TFWIDGET_CLICK)

	self.slider_OpenMore:removeMEListener(TFWIDGET_TOUCHBEGAN)
	self.slider_OpenMore:removeMEListener(TFWIDGET_TOUCHMOVED)
	self.slider_OpenMore:removeMEListener(TFWIDGET_TOUCHENDED)

    self.super.removeEvents(self)
end

return OpenMore;
