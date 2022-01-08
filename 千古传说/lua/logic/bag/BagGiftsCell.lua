--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local BagGiftsCell = class("BagGiftsCell", BaseLayer)

function BagGiftsCell:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagGiftsCell")
end

function BagGiftsCell:initUI(ui)
	self.super.initUI(self,ui)

	self.txt_name 			= TFDirector:getChildByPath(ui, 'txt_name')
	self.txt_number			= TFDirector:getChildByPath(ui, 'txt_number')
	self.btn_icon	 		= TFDirector:getChildByPath(ui, 'btn_icon')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.img_select	 		= TFDirector:getChildByPath(ui, 'img_selected_fg')

	self.btn_node 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.btn_node.logic = self

	--显示空白网格逻辑添加
    self.panel_empty            = TFDirector:getChildByPath(ui, 'panel_empty')
    self.panel_info             = TFDirector:getChildByPath(ui, 'panel_info')
end

function BagGiftsCell:removeUI()
	self.super.removeUI(self)

	self.txt_name 			= nil
	self.txt_number			= nil
	self.btn_icon	 		= nil
	self.img_icon  			= nil
	self.img_select  		= nil
	self.btn_node 			= nil
	self.id 				= nil
	self.lbl_num_delim 		= nil
	self.txt_num_max 		= nil
	self.itemUpdateCallBack = nil
end

function BagGiftsCell:setData( id )
	self.id = id
	self:refreshUI()
end

function BagGiftsCell:setLogic(logiclayer)
	self.logic = logiclayer
end

function BagGiftsCell:refreshUI()
	if not self.id then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        CommonManager:removeRedPoint(self)
        
        self.txt_number:setVisible(false)
        return false
    end

    self.txt_number:setVisible(true)

	local item = BagManager:getItemById(self.id)
	if item == nil  then
		print("item not found : ",self.id)
		self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        CommonManager:removeRedPoint(self)
		return false
	end

	self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)

	self.txt_name:setText(item.name)
	-- self.txt_name:setColor(GetColorByQuality(item.quality))
	self.img_icon:setTexture(item:GetTextrue())
	self.btn_icon:setTextureNormal(GetBackgroundForGoods(item:getData()))
	self.txt_number:setText(item.num)

	--是否选中
	if self.logic  and self.logic.selectId and self.logic.selectId == self.id  then
		self.img_select:setVisible(true)
	else
		self.img_select:setVisible(false)
	end
	
	self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle,play_xuanze))

	CommonManager:updateRedPoint(self, BagManager:isCanGift(self.id),ccp(self:getSize().width/2,self:getSize().height/2))
end

function BagGiftsCell.iconBtnClickHandle(sender)
	local self = sender.logic
	if self.logic then
		self.logic:tableCellClick(self)
	end
end


function BagGiftsCell:setChoice( b )
    self.img_select:setVisible(b)
end

function BagGiftsCell:registerEvents()
	self.super.registerEvents(self)


	self.itemUpdateCallBack = function (event)
       if event.data[1] ==  self.id then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
end
function BagGiftsCell:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(BagManager.ItemChange,self.ItemUpdateCallBack)
    self.btn_node:removeMEListener(TFWIDGET_CLICK)
end

function BagGiftsCell:getSize()
	return self.ui:getSize()
end

return BagGiftsCell
