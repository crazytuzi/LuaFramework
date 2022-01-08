--[[
******礼包内容cell*******
]]

local GiftCell = class("GiftCell", BaseLayer)

function GiftCell:ctor(goods,number)
    self.super.ctor(self)
    self.goods = goods
    self.number = number
    self:init("lua.uiconfig_mango_new.bag.GiftCell")
end

function GiftCell:initUI(ui)
	self.super.initUI(self,ui)

	self.txt_number			= TFDirector:getChildByPath(ui, 'txt_number')
	self.img_icon	 		= TFDirector:getChildByPath(ui, 'img_icon')
	self.img_soul	 		= TFDirector:getChildByPath(ui, 'img_soul')
	self.img_select	 		= TFDirector:getChildByPath(ui, 'img_selected_fg')

	self.img_already_had	 		= TFDirector:getChildByPath(ui, 'img_already_had')
	self.img_already_had:setVisible(false)

	self.btn_node 		= TFDirector:getChildByPath(ui, 'btn_node')

	self.btn_node.logic = self

	--显示空白网格逻辑添加
    self.panel_empty            = TFDirector:getChildByPath(ui, 'panel_empty')
    self.panel_info             = TFDirector:getChildByPath(ui, 'panel_info')
end

function GiftCell:removeUI()
	self.super.removeUI(self)

	self.txt_number			= nil
	self.img_icon  			= nil
	self.img_soul  			= nil
	self.img_select  		= nil
	self.img_star  			= nil
	self.id 				= nil
	self.img_already_had	= nil
	self.itemUpdateCallBack = nil
end

function GiftCell:setLogic(logic)
	self.logic = logic
end

function GiftCell:setData(data)
	self.data = data
	print("gift cell set data : ",data)
	self:refreshUI()
end

function GiftCell:updateIcon()
	
end

function GiftCell:updateIconForGoods()
	local itemdata = self.itemdata

	local rewardItem = {itemid = itemdata.id}
	self.btn_node:setTextureNormal(GetColorIconByQuality_58(itemdata.quality))
	if itemdata.type == EnumGameItemType.Soul and itemdata.kind ~= 3 then
		self:updateIconForSoul()
		Public:addPieceImg(self.img_icon,rewardItem,true)
	else
		if itemdata.type == EnumGameItemType.Piece then
			Public:addPieceImg(self.img_icon,rewardItem,true)
		else
			Public:addPieceImg(self.img_icon,rewardItem,false)
		end
		self.img_already_had:setVisible(false)
		self.img_icon:setTexture(itemdata:GetPath())
	end
end

function GiftCell:updateIconForSoul()
	local itemdata = self.itemdata
	if itemdata.kind == 2 then
		self.img_icon:setTexture(MainPlayer:getIconPath())
	else
		local role = RoleData:objectByID(itemdata.usable)
		if role == nil then
			self.img_icon:setTexture(itemdata:GetPath())
		else
			self.img_icon:setTexture(role:getIconPath())
		end
	end
	--验证是否已经拥有该角色
	local partner = CardRoleManager:getRoleById(itemdata.usable)
	if partner then
		self.img_already_had:setVisible(true)
	else
		self.img_already_had:setVisible(false)
	end
end

function GiftCell:refreshUI()
	if not self.data then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return false
    end

    local rewardInfo = BaseDataManager:getReward(self.data )
    if rewardInfo == nil then
        print("策划配置数据出了问题，找不到奖励的物品")
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return false
    end

    self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)

    if self.data.type == 1 then --物品
    	self.itemdata = ItemData:objectByID(self.data.itemId)
    	self:updateIconForGoods()
    	self.txt_number:setScale(1.2)
    else
    	Public:addPieceImg(self.img_icon,nil,false)
    	self.itemdata = nil
    	if self.data.type == 2 then --角色	
    	else --资源
    	end
        if self.data.number >= 100000 then
            self.txt_number:setScale(0.8)
        else
            self.txt_number:setScale(1.2)
        end
        if rewardInfo == nil then
            print("策划配置数据出了问题，找不到奖励的物品")
            self.img_icon:setTexture("icon/notfound.png")
        else
            self.img_icon:setTexture(rewardInfo.path)
        end
        self.btn_node:setTextureNormal(GetColorIconByQuality_58(rewardInfo.quality))
    end
  --   if self.data.number >= 100000 then
		-- self.txt_number:setText(math.floor(self.data.number/10000).."w")
  --   else
	self.txt_number:setText(self.data.number)
    -- end

end

function GiftCell.iconBtnClickHandle(sender)
	local self = sender.logic
	Public:ShowItemTipLayer(self.data.itemId, self.data.type)
end

function GiftCell:registerEvents()
	self.super.registerEvents(self)
    self.btn_node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle,play_xuanz))
end
function GiftCell:removeEvents()
    self.super.removeEvents(self)
    self.btn_node:removeMEListener(TFWIDGET_CLICK)
end

function GiftCell:getSize()
	return self.ui:getSize()
end

return GiftCell
