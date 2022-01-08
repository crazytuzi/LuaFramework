--[[
******背包物品tableview的cell*******
]]

local BagCell = class("BagCell", BaseLayer)

function BagCell:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.BagCell")
end

function BagCell:initUI(ui)
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

	self.btn_node.logic = self

	--显示空白网格逻辑添加
    self.panel_empty            = TFDirector:getChildByPath(ui, 'panel_empty')
    self.panel_info             = TFDirector:getChildByPath(ui, 'panel_info')
    self.txt_qianghualv             = TFDirector:getChildByPath(ui, 'txt_qianghualv')
    self.panel_star             = TFDirector:getChildByPath(ui, 'panel_star')
end

function BagCell:removeUI()
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

function BagCell:setData( item_type,id )
	self.id = id
	self.item_type = item_type 
	self:refreshUI()
end

function BagCell:setLogic(logiclayer)
	self.logic = logiclayer
end

function BagCell:hideRedPoint()
	CommonManager:removeRedPoint(self)
end

function BagCell:refreshRedPoint(value)
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
    elseif _type == EnumGameItemType.Piece and _kind < 6 then
        status = BagManager:isCanMerge(self.item)
    elseif _type == EnumGameItemType.HeadPicFrame then
    	status = BagManager:CanMergeFrame(self.item.itemdata.usable)
    else
        status = false
    end

	CommonManager:updateRedPoint(self, status ,ccp(self:getSize().width/2,self:getSize().height/2))
end
function BagCell:refreshSkyBookRedPoint(value)
	if value ~= nil then
		self:hideRedPoint()
	end

	if not self.item then
		self:hideRedPoint()
		return
	end

	local status = false
	-- local _type = self.item.itemdata.type
	-- local _kind = self.item.itemdata.kind
 --    if _type == EnumGameItemType.Item or _type == EnumGameItemType.Box or _type == EnumGameItemType.RandomPack then
 --        status = BagManager:isCanPropQuick(self.item)
 --    elseif _type == EnumGameItemType.Book then
 --        status = false
 --    elseif _type == EnumGameItemType.Soul then
 --        status = BagManager:isRecruitEnabled(self.item)
 --    elseif _type == EnumGameItemType.Piece and _kind < 6 then
 --        status = BagManager:isCanMerge(self.item)
 --    elseif _type == EnumGameItemType.HeadPicFrame then
 --    	status = BagManager:CanMergeFrame(self.item.itemdata.usable)
 --    else
 --        status = false
 --    end

	CommonManager:updateRedPoint(self, status ,ccp(self:getSize().width/2,self:getSize().height/2))
end

function BagCell:calculateMaxNumberForSoul()
	local roleData = RoleData:objectByID(self.item.itemdata.usable)
	if roleData then
		return roleData.merge_card_num
	else
		return 0
	end
end

function BagCell:calculateMaxNumberForPiece()
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

function BagCell:isPiece()
	local _type = self.item.itemdata.type
	if _type == EnumGameItemType.Piece or _type == EnumGameItemType.Soul then
		return true
	end
	return false
end

function BagCell:showNumber()
	local _type = self.item.itemdata.type
	self.txt_num_max:setVisible(true)
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

function BagCell:updateIcon()
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

function BagCell:updateIconForSoul()
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

function BagCell:updateSelectedImg()
	--是否选中
	if self.logic  and self.logic.selectId and self.logic.selectId == self.id  then
		self.img_select:setVisible(true)
	else
		self.img_select:setVisible(false)
	end
end

function BagCell:refreshUI()
	if not self.id then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        self:hideRedPoint()
        return false
    end
    if self.item_type == EnumGameItemType.SkyBook then
		self:refreshSkyBookByInstance(self.id)
    else
		self:refreshItemById(self.id)
    end
end

function BagCell:refreshItemById(id  )
	local item = BagManager:getItemById(id)
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
	self:refreshRedPoint()
	self.txt_qianghualv:setVisible(false)
	self.panel_star:setVisible(false)
	Public:addStarImg(self.img_icon, 0)
end
function BagCell:refreshSkyBookByInstance( instanceId )
	local item = SkyBookManager:getItemByInstanceId(instanceId)
	if item == nil  then
		self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
		return false
	end
	self.item = item
	self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)
	--self:updateIcon()
	--self:showNumber()
    self.img_icon:setTexture(item:GetTextrue())


    local rewardItem = {itemid = item.id}

	Public:addPieceImg(self.img_icon,rewardItem,false)
    self.btn_node:setTextureNormal(GetColorIconByQuality_82(item.quality))
    --self.txt_number:setText(SkyBookManager:getNumByInstanceId(item.instanceId))
    -- self.txt_number:setVisible(true)
    if item.level == 0 then
        self.txt_qianghualv:setVisible(false)
    else
        --self.txt_qianghualv:setText(EnumSkyBookLevelType[item.level] .. "重")
        local str = stringUtils.format(localizable.common_chong, EnumSkyBookLevelType[item.level])
        self.txt_qianghualv:setText(str)
        self.txt_qianghualv:setVisible(true)
    end

    Public:addStarImg(self.img_icon, item.tupoLevel)

	self:updateSelectedImg()
    self.txt_number:setVisible(false)
	self:refreshSkyBookRedPoint()


	self.txt_num_max:setVisible(false)
    self.lbl_num_delim:setVisible(false)
    self.img_already_had:setVisible(false)

    --若天书中无精要,则不显示重数
    local status = 0
    for i = 1, item.maxStoneNum do        
        if item:getStonePos(i) and self.item:getStonePos(i) > 0 then
            status = 1
        end
    end
    if status == 0 and item.level == 1 then
        self.txt_qianghualv:setVisible(false) 
    end
end


function BagCell.iconBtnClickHandle(sender)
	local self = sender.logic
	if self.logic then
		self.logic:tableCellClick(self)
	end
end


function BagCell:setChoice( b )
    self.img_select:setVisible(b)
end

function BagCell:registerEvents()
	self.super.registerEvents(self)

	self.itemUpdateCallBack = function (event)
       if event.data[1] ==  self.id then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
    self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle,play_xuanz))
end
function BagCell:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
    self.btn_node:removeMEListener(TFWIDGET_CLICK)
end

function BagCell:getSize()
	return self.ui:getSize()
end

return BagCell
