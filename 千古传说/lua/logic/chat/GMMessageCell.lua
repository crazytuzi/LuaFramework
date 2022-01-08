--[[
******聊天消息cell*******

	-- by david.dai
	-- 2014/06/23
]]

local PublicMessageCell = class("PublicMessageCell", BaseLayer)

function PublicMessageCell:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.chat.PublicMessageCell")
end

function PublicMessageCell:initUI(ui)
	self.super.initUI(self,ui)

	--消息背景
	self.panel_bg	 		= TFDirector:getChildByPath(ui, 'panel_bg')
	self.img_msg_bg	 		= TFDirector:getChildByPath(ui, 'img_msg_bg')
	self.img_spilt	 		= TFDirector:getChildByPath(ui, 'img_spilt')


	self.panel_msg	 		= TFDirector:getChildByPath(ui, 'panel_msg')
	self.img_head 			= TFDirector:getChildByPath(ui, 'img_head')
	self.img_icon			= TFDirector:getChildByPath(ui, 'img_icon')
	self.lbl_level 			= TFDirector:getChildByPath(ui, 'lbl_level')
	self.txt_level 			= TFDirector:getChildByPath(ui, 'txt_level')
	--o表示vip文字。如：o15
	self.txt_vip 			= TFDirector:getChildByPath(ui, 'txt_vip')

	self.txt_position 		= TFDirector:getChildByPath(ui, 'txt_position')
	self.img_title			= TFDirector:getChildByPath(ui, "img_title")

	self.txt_name 			= TFDirector:getChildByPath(ui, 'txt_name')
	self.txt_msg 			= TFDirector:getChildByPath(ui, 'txt_msg')
	self.txt_timestamp 		= TFDirector:getChildByPath(ui, 'txt_time')

	self.pos_txt_name1 = self.txt_name:getPosition()
	self.pos_txt_position1 = self.txt_position:getPosition()
	self.pos_img_title1 = self.img_title:getPosition()

	self.pos_txt_name2 = ccp(self.txt_name:getPosition().x - 60, self.txt_name:getPosition().y)
	self.pos_txt_position2 = ccp(self.txt_position:getPosition().x - 60, self.txt_position:getPosition().y)
	self.pos_img_title2 = ccp(self.img_title:getPosition().x - 60, self.img_title:getPosition().y)

	self.img_head.logic 	= self
end

function PublicMessageCell:removeUI()
	self.super.removeUI(self)
end

function PublicMessageCell:setMessage(message)
	self.message = message
	self:refreshUI()
end

function PublicMessageCell:setLogic(logiclayer)
	self.logic = logiclayer
end

function PublicMessageCell:refreshUI()
	local message = self.message
	local roleData =  RoleData:objectByID(message.roleId)
	if roleData == nil then
		-- assert("designer is bad guy.role data not found : ",message.roleId)
		return
	end

	self.txt_vip:setVisible(true)
	self.img_vip:setVisible(false)

	self.img_icon:setTexture(roleData:getIconPath())
	self.img_head:setTexture(GetColorIconByQuality(message.quality))
	self.txt_name:setText(message.name)
	self.txt_vip:setText("o".. message.vipLevel)
	self.txt_level:setText(message.level)
	self.txt_msg:setText(message.content)
	self.txt_timestamp:setText(self:getTimeFormatString())

	--added by wuqi
	if tonumber(message.vipLevel) > 15 and tonumber(message.vipLevel) <= 18 then
		self.txt_vip:setVisible(false)
		self.img_vip:setVisible(true)
		--self.img_vip:setTexture(self.path_new_vip[vipLevel - 15])
		self:addVipEffect(self.img_vip, message.vipLevel)
	end

	--added by wuqi
	if SettingManager.TAG_VIP_YINCANG == tonumber(message.vipLevel) then
		self.txt_vip:setVisible(false)
		self.img_vip:setVisible(false)

		self.txt_name:setPosition(self.pos_txt_name2)
		self.txt_position:setPosition(self.pos_txt_position2)
		self.img_title:setPosition(self.pos_img_title2)
	end
end

--added by wuqi
function PublicMessageCell:addVipEffect(btn, vipLevel)
	if btn.effect then
		btn.effect:removeFromParent()
		btn.effect = nil
	end

	vipLevel = tonumber(vipLevel)
	if vipLevel <= 18 then  --if vipLevel <= 15 or vipLevel > 18 then -- modify by zr 关掉高VIP特效
		return
	end
	local resPath = "effect/ui/vip_" .. vipLevel .. ".xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("vip_" .. vipLevel .. "_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
    effect:setVisible(true)
    effect:setScale(0.85)
    effect:setContentSize(CCSize(57, 14))
    effect:playByIndex(0, -1, -1, 1)
    btn:addChild(effect, 200)
    btn.effect = effect
end


function PublicMessageCell:getTimeFormatString()
	local seconds = self.message.timestamp / 1000
	return os.date("%X", seconds)
end

function PublicMessageCell.iconBtnClickHandle(sender)
	local self = sender.logic
end

function PublicMessageCell:registerEvents()
	self.super.registerEvents(self)
	self.img_head:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle))
end

function PublicMessageCell:removeEvents()
    self.img_head:removeMEListener(TFWIDGET_CLICK)
    self.super.removeEvents(self)
end

function PublicMessageCell:getSize()
	return self.ui:getSize()
end

return PublicMessageCell
