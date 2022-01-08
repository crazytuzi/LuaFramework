--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local BagPropCell = class("BagPropCell", BaseLayer)

function BagPropCell:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagPropCell")
end

function BagPropCell:initUI(ui)
	self.super.initUI(self,ui)

	self.txt_number			= TFDirector:getChildByPath(ui, 'txt_number')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.img_select	 		= TFDirector:getChildByPath(ui, 'img_selected_fg')

	self.btn_node 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.btn_node.logic = self

	--显示空白网格逻辑添加
    self.panel_empty            = TFDirector:getChildByPath(ui, 'panel_empty')
    self.panel_info             = TFDirector:getChildByPath(ui, 'panel_info')
end

function BagPropCell:removeUI()
	self.super.removeUI(self)

	self.txt_number			= nil
	self.img_icon  			= nil
	self.img_select  		= nil
	self.btn_node 			= nil
	self.id 				= nil
	self.lbl_num_delim 		= nil
	self.txt_num_max 		= nil
	self.itemUpdateCallBack = nil
end

function BagPropCell:setData( id )
	self.id = id
	self:refreshUI()
end

function BagPropCell:setLogic(logiclayer)
	self.logic = logiclayer
end

function BagPropCell:refreshUI()
	if not self.id then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        self.txt_number:setVisible(false)
        CommonManager:removeRedPoint(self)
        return false
    end

	local item = BagManager:getItemById(self.id)
	if item == nil  then
		print("item not found : ",self.id)
		self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        self.txt_number:setVisible(false)
		return false
	end

	
	self.txt_number:setVisible(true)

	self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)

	self.img_icon:setTexture(item:GetTextrue())
	self.btn_node:setTextureNormal(GetColorIconByQuality_82(item:getData().quality))

	self.txt_number:setText(item.num)

	--是否选中
	if self.logic  and self.logic.selectId and self.logic.selectId == self.id  then
		self.img_select:setVisible(true)
	else
		self.img_select:setVisible(false)
	end

	self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle,play_xuanz))

	CommonManager:updateRedPoint(self, BagManager:isCanProp(self.id),ccp(self:getSize().width/2,self:getSize().height/2))
end

function BagPropCell.iconBtnClickHandle(sender)
	local self = sender.logic
	if self.logic then
		self.logic:tableCellClick(self)
	end
end

function BagPropCell:setChoice( b )
    self.img_select:setVisible(b)
end

function BagPropCell:registerEvents()
	self.super.registerEvents(self)

	self.itemUpdateCallBack = function (event)
       if event.data[1] ==  self.id then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
end
function BagPropCell:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
    self.btn_node:removeMEListener(TFWIDGET_CLICK)
end

function BagPropCell:getSize()
	return self.ui:getSize()
end

return BagPropCell
