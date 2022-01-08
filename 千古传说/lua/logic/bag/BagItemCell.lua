--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local BagItemCell = class("BagItemCell", BaseLayer)

--CREATE_SCENE_FUN(BagItemCell)
CREATE_PANEL_FUN(BagItemCell)


function BagItemCell:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagItemCell")
end

function BagItemCell:initUI(ui)
	self.super.initUI(self,ui)

	self.txt_name 			= TFDirector:getChildByPath(ui, 'txt_name')
	self.txt_number			= TFDirector:getChildByPath(ui, 'txt_number')
	self.lbl_num_delim		= TFDirector:getChildByPath(ui, 'lbl_num_delim')
	self.txt_num_max		= TFDirector:getChildByPath(ui, 'txt_num_max')
	self.btn_icon	 		= TFDirector:getChildByPath(ui, 'btn_icon')
	self.btn_node	 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.img_soul	 		= TFDirector:getChildByPath(ui, 'img_soul')
	self.img_select	 		= TFDirector:getChildByPath(ui, 'img_selected_fg')

	self.img_already_had	 		= TFDirector:getChildByPath(ui, 'img_already_had')

	self.lbl_num_delim:setText("/")

	self.img_star = {}

	self.btn_node 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.panel_star	 	= TFDirector:getChildByPath(self.btn_node, 'btn_node')
	for i=1,5 do
		local str = "img_star"..i
		self.img_star[i]	 		= TFDirector:getChildByPath(self.panel_star, str)
	end

	self.btn_node.logic = self

	--显示空白网格逻辑添加
    self.panel_empty            = TFDirector:getChildByPath(ui, 'panel_empty')
    self.panel_info             = TFDirector:getChildByPath(ui, 'panel_info')
end

function BagItemCell:removeUI()
	self.super.removeUI(self)

	self.txt_name 			= nil
	self.txt_number			= nil
	self.btn_icon	 		= nil
	self.img_icon  			= nil
	self.img_soul  			= nil
	self.img_select  		= nil
	self.img_star  			= nil
	self.id 				= nil
	self.lbl_num_delim 		= nil
	self.txt_num_max 		= nil
	self.img_already_had	= nil
	self.itemUpdateCallBack = nil
end

function BagItemCell:setItemInfo( id )
	self.id = id
	self:refreshUI()
end

function BagItemCell:setLogic(logiclayer)
	self.logic = logiclayer
end

function BagItemCell:refreshUI()
	if not self.id then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return false
    end

	local item = BagManager:getItemById(self.id)
	if item == nil  then
		print("item not found : ",self.id)
		self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
		return false
	end

	self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)

	self.txt_number:setText(item.num)
	self.txt_name:setText(item.name)
	-- self.txt_name:setColor(GetColorByQuality(item.quality))
	self.img_icon:setTexture(item:GetTextrue())
	self.btn_icon:setTextureNormal(GetBackgroundForGoods(item:getData()))

	--验证是否已经拥有该角色
	if item.type == EnumGameItemType.Soul then
		local partner = CardRoleManager:getRoleById(item.itemdata.usable)
		if partner then
			self.img_already_had:setVisible(true)
		end
	
			local roleData = RoleData:objectByID(item.itemdata.usable)
			local recruitNum = roleData.merge_card_num
		self.txt_num_max:setText(recruitNum)
	end

	if self.logic  and self.logic.selectId and self.logic.selectId == self.id  then
		self.img_select:setVisible(true)
	else
		self.img_select:setVisible(false)
	end
	self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle,play_xuanz))
end

function BagItemCell.iconBtnClickHandle(sender)
	local self = sender.logic
	if self.logic then
		self.logic:tableCellClick(self)
	end
end


function BagItemCell:setChoice( b )
    self.img_select:setVisible(b)
end

function BagItemCell:registerEvents()
	self.super.registerEvents(self)

	self.itemUpdateCallBack = function (event)
       if event.data[1] ==  self.id then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
end
function BagItemCell:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
end

function BagItemCell:getSize()
	return self.ui:getSize()
end

return BagItemCell
