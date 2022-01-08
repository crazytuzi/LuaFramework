--[[
******背包物品tableview的cell*******
]]

local GambleCell = class("GambleCell", BaseLayer)

function GambleCell:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagPropCell")
end

function GambleCell:initUI(ui)
	self.super.initUI(self,ui)

	self.panel_empty			= TFDirector:getChildByPath(ui, 'panel_empty')
	self.panel_empty:setVisible(false)

	self.panel_info			= TFDirector:getChildByPath(ui, 'panel_info')

	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.txt_number	 		= TFDirector:getChildByPath(ui, 'txt_number')
	self.img_already_had	 		= TFDirector:getChildByPath(ui, 'img_already_had')
	self.img_already_had:setVisible(false)

	self.btn_node 		= TFDirector:getChildByPath(ui, 'btn_node')
	self.btn_node.logic = self

end

function GambleCell:removeUI()
	self.super.removeUI(self)

	self.panel_empty		= nil
	self.panel_info			= nil
	self.img_icon			= nil
	self.txt_number			= nil
	self.img_already_had	= nil
	self.btn_node			= nil
end

function GambleCell:setData( id )
	self.id = id
	self:refreshUI()
end

function GambleCell:setLogic(logiclayer)
	self.logic = logiclayer
end

function GambleCell:hideRedPoint()
	CommonManager:removeRedPoint(self)
end

function GambleCell:refreshRedPoint(value)
	if value ~= nil then
		self:hideRedPoint()
	end

	if not self.item then
		self:hideRedPoint()
		return
	end

	local status = false
	local _type = self.item.itemdata.type
	local _kind = self.item.itemdata.kind
    if _type == EnumGameItemType.Item or _type == EnumGameItemType.Box or _type == EnumGameItemType.RandomPack then
        status = BagManager:isCanPropQuick(self.item)
    elseif _type == EnumGameItemType.Book then
        status = false
    elseif _type == EnumGameItemType.Soul then
        status = BagManager:isRecruitEnabled(self.item)
    elseif _type == EnumGameItemType.Piece and kind == 3 then
        status = BagManager:isCanMerge(self.item)
    elseif _type == EnumGameItemType.HeadPicFrame then
    	status = HeadPicFrameManager:isEnough(self.item.itemdata.usable)
    else
        status = false
    end

	CommonManager:updateRedPoint(self, status ,ccp(self:getSize().width/2,self:getSize().height/2))
end

function GambleCell:calculateMaxNumberForSoul()
	local roleData = RoleData:objectByID(self.item.itemdata.usable)
	if roleData then
		return roleData.merge_card_num
	else
		return 0
	end
end

function GambleCell:calculateMaxNumberForPiece()
	local itemdata= self.item.itemdata
	if itemdata.kind < 6 then
		local equipmentTemplate = EquipmentTemplateData:findByPieceId(itemdata.id)
		if equipmentTemplate ~= nil then
			return equipmentTemplate.merge_num
		else
			return 0
		end
	elseif itemdata.kind == 10 then
		local martialTemplate,tmpNum = MartialData:findByMaterial(itemdata.id)
		if martialTemplate ~= nil then
			return tmpNum
		else
			return 0
		end
	end
end

function GambleCell:isPiece()
	local _type = self.item.itemdata.type
	if _type == EnumGameItemType.Piece or _type == EnumGameItemType.Soul then
		return true
	end
	return false
end

function GambleCell:showNumber()
	local _type = self.item.itemdata.type
	if _type == EnumGameItemType.Piece then
        self.txt_number:setVisible(true)
        self.lbl_num_delim:setVisible(true)
        self.txt_num_max:setText(self:calculateMaxNumberForPiece())
		self.txt_number:setText(self.item.num)
	elseif _type == EnumGameItemType.Soul then
		if self.item.itemdata.kind == 3 then
			self.txt_number:setVisible(false)
        	self.lbl_num_delim:setVisible(false)
        	self.txt_num_max:setText(self.item.num)
		else
			self.txt_number:setVisible(true)
        	self.lbl_num_delim:setVisible(true)
        	self.txt_num_max:setText(self:calculateMaxNumberForSoul())
			self.txt_number:setText(self.item.num)
		end
		
    else
    	self.txt_number:setVisible(false)
        self.lbl_num_delim:setVisible(false)
        self.txt_num_max:setText(self.item.num)
	end
end

function GambleCell:updateIcon()
	local item = self.item
	self.btn_node:setTextureNormal(GetColorIconByQuality_82(item:getData().quality))

	local rewardItem = {itemid = item.id}

	if item.type == EnumGameItemType.Soul and item.kind ~= 3 then
		self:updateIconForSoul()
		Public:addPieceImg(self.img_icon,rewardItem,true)
	else
		if item.type == EnumGameItemType.Piece then
			Public:addPieceImg(self.img_icon,rewardItem,true)
		else
			Public:addPieceImg(self.img_icon,rewardItem,false)
		end
		self.img_already_had:setVisible(false)
		self.img_icon:setTexture(item:GetTextrue())
	end
end

function GambleCell:updateIconForSoul()
	local item = self.item
	if item.kind == 2 then
		self.img_icon:setTexture(MainPlayer:getIconPath())
	else
		local role = RoleData:objectByID(item.itemdata.usable)
		if role == nil then
			self.img_icon:setTexture(item:GetTextrue())
		else
			self.img_icon:setTexture(role:getIconPath())
		end
	end
	--验证是否已经拥有该角色
	local partner = CardRoleManager:getRoleById(item.itemdata.usable)
	if partner then
		self.img_already_had:setVisible(true)
	else
		self.img_already_had:setVisible(false)
	end
end

function GambleCell:updateSelectedImg()
	--是否选中
	if self.logic  and self.logic.selectId and self.logic.selectId == self.id  then
		self.img_select:setVisible(true)
	else
		self.img_select:setVisible(false)
	end
end

function GambleCell:refreshUI()
	if not self.id then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        self:hideRedPoint()
        return false
    end

	local item = BagManager:getItemById(self.id)
	if item == nil  then
		self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        self:hideRedPoint()
		return false
	end
	self.item = item
	self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)
	self:updateIcon()
	self:showNumber()
	self:updateSelectedImg()
end

function GambleCell.iconBtnClickHandle(sender)
	local self = sender.logic
	if self.logic then
		self.logic:tableCellClick(self)
	end
end


function GambleCell:setChoice( b )
    self.img_select:setVisible(b)
end

function GambleCell:registerEvents()
	self.super.registerEvents(self)

	self.itemUpdateCallBack = function (event)
       if event.data[1] ==  self.id then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
    self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle,play_xuanz))
end
function GambleCell:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
    self.btn_node:removeMEListener(TFWIDGET_CLICK)
end

function GambleCell:getSize()
	return self.ui:getSize()
end

return GambleCell
