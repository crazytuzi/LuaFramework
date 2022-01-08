--[[
******背包物品tableview的cell*******
]]

local SkyBookCell = class("SkyBookCell", BaseLayer)

function SkyBookCell:ctor(data)
    self.super.ctor(self,data)
    self.id = 0
    self:init("lua.uiconfig_mango_new.bag.SkyBookCell")
end

function SkyBookCell:initUI(ui)
	self.super.initUI(self,ui)

	self.txt_number			= TFDirector:getChildByPath(ui, 'txt_number')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.img_select	 		= TFDirector:getChildByPath(ui, 'img_selected_fg')

    self.txt_qianghualv = TFDirector:getChildByPath(ui, 'txt_qianghualv')

	self.btn_node 		= TFDirector:getChildByPath(ui, 'btn_node')

	self.btn_node.logic = self

	--显示空白网格逻辑添加
    self.panel_empty            = TFDirector:getChildByPath(ui, 'panel_empty')
    self.panel_info             = TFDirector:getChildByPath(ui, 'panel_info')
    self.img_already_had = TFDirector:getChildByPath(ui, "img_already_had")
    self.img_already_had:setVisible(false)
end

function SkyBookCell:removeUI()
	self.super.removeUI(self)

	self.txt_number			= nil
	self.img_icon  			= nil
	self.img_select  		= nil
	self.img_star  			= nil
	self.id 				= nil
	self.itemUpdateCallBack = nil
end

function SkyBookCell:setData( id )
	self.id = id
	self:refreshUI()
end

function SkyBookCell:setLogic(logiclayer)
	self.logic = logiclayer
end

function SkyBookCell:showNumber()
    self.txt_number:setVisible(false)
end

function SkyBookCell:updateIcon()
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
    self.img_already_had:setVisible(false)
end

function SkyBookCell:updateSelectedImg()
	--是否选中
	if self.logic  and self.logic.selectId and self.logic.selectId == self.id  then
		self.img_select:setVisible(true)
	else
		self.img_select:setVisible(false)
	end
end

function SkyBookCell:refreshUI()
	if not self.id then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return false
    end

	local item = SkyBookManager:getItemByInstanceId(self.id)
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
    self.btn_node:setTextureNormal(GetColorIconByQuality_82(item.quality))
    --self.txt_number:setText(SkyBookManager:getNumByInstanceId(item.instanceId))
    self.txt_number:setVisible(true)
    if item.level == 0 then
        self.txt_qianghualv:setVisible(false)
    else
        --self.txt_qianghualv:setText(EnumSkyBookLevelType[item.level] .. "重")
        local str = stringUtils.format(localizable.common_chong, EnumSkyBookLevelType[item.level])
        self.txt_qianghualv:setText(str)
        self.txt_qianghualv:setVisible(true)
    end

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

    Public:addStarImg(self.img_icon, item.tupoLevel)

	self:updateSelectedImg()
    self.txt_number:setVisible(false)
    self.img_already_had:setVisible(false)
end

function SkyBookCell.iconBtnClickHandle(sender)
	local self = sender.logic
	if self.logic then
		self.logic:tableCellClick(self)
	end
end


function SkyBookCell:setChoice( b )
    self.img_select:setVisible(b)
end

function SkyBookCell:registerEvents()
	self.super.registerEvents(self)

	self.itemUpdateCallBack = function (event)
       if event.data[1] ==  self.id then
            self:refreshUI()
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
    self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle,play_xuanz))
end
function SkyBookCell:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(BagManager.ItemChange,self.itemUpdateCallBack)
    self.btn_node:removeMEListener(TFWIDGET_CLICK)
end

function SkyBookCell:getSize()
	return self.ui:getSize()
end

return SkyBookCell
