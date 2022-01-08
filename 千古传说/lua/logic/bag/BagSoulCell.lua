--[[
******背包滑动道具cell*******

	-- by Stephen.tao
	-- 2013/12/5
]]

local BagSoulCell = class("BagSoulCell", BaseLayer)

function BagSoulCell:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagSoulCell")
end

function BagSoulCell:initUI(ui)
	self.super.initUI(self,ui)

	self.txt_number			= TFDirector:getChildByPath(ui, 'txt_number')
	self.lbl_num_delim		= TFDirector:getChildByPath(ui, 'lbl_num_delim')
	self.txt_num_max		= TFDirector:getChildByPath(ui, 'txt_num_max')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.img_soul	 		= TFDirector:getChildByPath(ui, 'img_soul')
	self.img_select	 		= TFDirector:getChildByPath(ui, 'img_selected_fg')

	self.img_already_had	 		= TFDirector:getChildByPath(ui, 'img_already_had')

	self.lbl_num_delim:setText("/")

	self.btn_node 		= TFDirector:getChildByPath(ui, 'btn_node')
	--self.panel_star	 	= TFDirector:getChildByPath(self.btn_node, 'btn_node')
	--self.img_star = {}
	--for i=1,5 do
	--	local str = "img_star"..i
	--	self.img_star[i]	 		= TFDirector:getChildByPath(self.panel_star, str)
	--end

	self.btn_node.logic = self

	--显示空白网格逻辑添加
    self.panel_empty            = TFDirector:getChildByPath(ui, 'panel_empty')
    self.panel_info             = TFDirector:getChildByPath(ui, 'panel_info')
end

function BagSoulCell:removeUI()
	self.super.removeUI(self)

	self.txt_number			= nil
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

function BagSoulCell:setData( id )
	self.id = id
	self:refreshUI()
end

function BagSoulCell:setLogic(logiclayer)
	self.logic = logiclayer
end

function BagSoulCell:refreshUI()
	if not self.id then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        CommonManager:removeRedPoint(self)
       	
       	-- 格子没有内容则隐藏
        self.txt_num_max:setVisible(false)
        self.txt_number:setVisible(false)
        self.lbl_num_delim:setVisible(false)
        return false
    end

    self.lbl_num_delim:setVisible(true)
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

	if item.type == EnumGameItemType.Soul and item.kind == 2 then
		self.img_icon:setTexture(MainPlayer:getIconPath())
	else
		local role = RoleData:objectByID(item.itemdata.usable)
		if role == nil then
			self.img_icon:setTexture(item:GetTextrue())
		else
			self.img_icon:setTexture(role:getIconPath())
		end
		
	end
	self.btn_node:setTextureNormal(GetColorIconByQuality_82(item:getData().quality))

	local rewardItem = {itemid = self.id}
	Public:addPieceImg(self.img_icon,rewardItem,true);
	
	local roleData = RoleData:objectByID(item.itemdata.usable)
	if roleData then
		local recruitNum = roleData.merge_card_num
		self.txt_num_max:setText(recruitNum)
		self.txt_num_max:setVisible(true)
	else
		self.txt_num_max:setVisible(false)
	end

	self.txt_number:setText(item.num)

	--验证是否已经拥有该角色
	local partner = CardRoleManager:getRoleById(item.itemdata.usable)
	if partner then
		self.img_already_had:setVisible(true)
	else
		self.img_already_had:setVisible(false)
	end

	--是否选中
	if self.logic  and self.logic.selectId and self.logic.selectId == self.id  then
		self.img_select:setVisible(true)
	else
		self.img_select:setVisible(false)
	end

	self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle,play_xuanz))

	CommonManager:updateRedPoint(self, BagManager:isCanZhaomu(self.id),ccp(self:getSize().width/2,self:getSize().height/2))
end

function BagSoulCell.iconBtnClickHandle(sender)
	local self = sender.logic
	if self.logic then
		self.logic:tableCellClick(self)
	end
end


function BagSoulCell:setChoice( b )
    self.img_select:setVisible(b)
end

function BagSoulCell:registerEvents()
	self.super.registerEvents(self)

	self.itemUpdateCallBack = function (event)
       if event.data[1] ==  self.id then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
end
function BagSoulCell:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
    self.btn_node:removeMEListener(TFWIDGET_CLICK)
end

function BagSoulCell:getSize()
	return self.ui:getSize()
end

return BagSoulCell
