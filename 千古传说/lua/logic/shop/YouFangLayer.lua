--[[
******祈愿界面*******

	-- by baosiqi
	-- 2016/4/19
]]

local YouFangLayer = class("YouFangLayer", BaseLayer)

function YouFangLayer:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.shop.Youfangshop")
end

function YouFangLayer:initUI(ui)
	self.super.initUI(self, ui)

	self.img_icon = TFDirector:getChildByPath(ui, 'img_icon')
	self.img_iconbg = TFDirector:getChildByPath(ui, 'img_iconbg')
	self.img_iconbg2 = TFDirector:getChildByPath(ui, 'img_iconbg2')
	self.txt_iconname = TFDirector:getChildByPath(ui, 'txt_iconname')
	self.txt_price = TFDirector:getChildByPath(ui, 'txt_price')
	self.btn_buy = TFDirector:getChildByPath(ui, 'btn_buy')
	self.txt_leavetime = TFDirector:getChildByPath(ui, 'txt_leavetime')
	self.img_yuanbao = TFDirector:getChildByPath(ui, 'img_yuanbao')
	self.txt_number = TFDirector:getChildByPath(ui, 'txt_number')
	self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')

	self:refreshUI()
end

function YouFangLayer:registerEvents()
	self.super.registerEvents(self)

	self.buyCallback = function (event)
		if event.data[1] == 0 then
			self:close()
		end 
	end
	TFDirector:addMEGlobalListener(MallManager.ReceiveTraveBusinessBuyResult, self.buyCallback)

	self.btn_buy.logic = self
	self.btn_buy:addMEListener(TFWIDGET_CLICK, audioClickfun(YouFangLayer.OnBuyClick), 1)

	self.btn_close:setClickAreaLength(100)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close)

end

function YouFangLayer:refreshUI()
	local tbData = MallManager:getTravelBusinessData()

	if not tbData then
		return
	end

	self.id = tbData.id
	local itemData = ItemData:objectByID(tbData.resId)

	if itemData == nil then
		print("道具表无此数据 id == " , tbData.resId)
		return 
	end

	self.txt_iconname:setText(itemData.name)
	self.img_icon:setTexture(itemData:GetPath())
	self.img_iconbg2:setTexture(GetBackgroundForGoods(itemData))
	self.img_yuanbao:setTexture(GetResourceIcon(tbData.consumeType))
	self.txt_price:setText(tbData.consumeNumber)
	self.txt_number:setText(tbData.resNumber)

	
	self.leftTime = MallManager:getTravelBusinessLeftTime()

	if not self.leftTime then
		print("剩余时间为空")
		return
	end
	print("YouFangLayer:refreshUI() :",self.leftTime)
	self.timerId = TFDirector:addTimer(1000, -1, nil, 
			function() 
				self:refreshTime()
			end)
	self:refreshTime()
end

function YouFangLayer:refreshTime()
	self.leftTime = self.leftTime - 1
	if self.leftTime <= 0 then
		self:close()
		return
	end


	local timeStr = self:TimeConvertString(self.leftTime)
	self.txt_leavetime:setText(timeStr)
end

-- 时间转换
function YouFangLayer:TimeConvertString(time)
	if time <= 0 then
		return "00:00:00"
	end

	local hour = math.floor(time/3600)
	local min  = math.floor((time-hour * 3600)/60)
	local sec  = math.mod(time, 60)
	return string.format("%02d:%02d:%02d", hour, min, sec)
end


function YouFangLayer.OnBuyClick(sender)
	local self = sender.logic

	MallManager:buyYouFang(self.id)

end

function YouFangLayer:close()
	if self.timerId ~= nil then 
		TFDirector:removeTimer(self.timerId)
		self.timerId = nil
	end

	AlertManager:close()
end


function YouFangLayer:removeUI()
	print("YouFangLayer:removeUI")
	self.super.removeUI(self)

end

function YouFangLayer:removeEvents()
	if self.timerId ~= nil then 
		TFDirector:removeTimer(self.timerId)
		self.timerId = nil
	end
    TFDirector:removeMEGlobalListener(MallManager.ReceiveTraveBusinessBuyResult, self.buyCallback)
    self.buyCallback = nil
    self.super.removeEvents(self)
end

return YouFangLayer