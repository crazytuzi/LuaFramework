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

	self.txt_name 			= TFDirector:getChildByPath(ui, 'txt_name')
	self.txt_msg 			= TFDirector:getChildByPath(ui, 'txt_msg')
	self.txt_timestamp 		= TFDirector:getChildByPath(ui, 'txt_time')

	self.txt_position 		= TFDirector:getChildByPath(ui, 'txt_position')

	self.img_title			= TFDirector:getChildByPath(ui, "img_title")
	self.img_title:setVisible(false)

	self.img_zdy			= TFDirector:getChildByPath(ui, "img_zdy")
	self.img_title:setVisible(false)

	self.img_head.logic 	= self
	self:creatRichText()
	self.txt_msg:setVisible(false)

	self.btn_accept = TFDirector:getChildByPath(ui, 'btn_accept')
	self.btn_ignore = TFDirector:getChildByPath(ui, 'btn_ignore')
	self.btn_accept.logic = self
	self.btn_ignore.logic = self
	self.btn_accept:setVisible(false)
	self.btn_ignore:setVisible(false)

	self.namePosition = self.txt_name:getPosition()

	--added by wuqi
	self.path_new_vip = {"ui_new/chat/img_vip_16.png", "ui_new/chat/img_vip_17.png", "ui_new/chat/img_vip_18.png"}
	self.img_vip = TFDirector:getChildByPath(ui, "img_vip")
	self.img_vip:setScale(0.6)

	self.pos_txt_name1 = self.txt_name:getPosition()
	self.pos_txt_position1 = self.txt_position:getPosition()
	self.pos_img_title1 = self.img_title:getPosition()

	self.pos_txt_name2 = ccp(self.txt_name:getPosition().x - 60, self.txt_name:getPosition().y)
	self.pos_txt_position2 = ccp(self.txt_position:getPosition().x - 60, self.txt_position:getPosition().y)
	self.pos_img_title2 = ccp(self.img_title:getPosition().x - 60, self.img_title:getPosition().y)
end

function PublicMessageCell:creatRichText()
	if self.richtext then
		return
	end
	self.richtext  = TFRichText:create(self.txt_msg:getSize())
	self.richtext:setFontSize(20)
	self.richtext:setPosition(self.txt_msg:getPosition())
	self.richtext:setAnchorPoint(self.txt_msg:getAnchorPoint())
	self.txt_msg:getParent():addChild(self.richtext)
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

function PublicMessageCell:refreshUI()
	local message = self.message
	local roleData =  RoleData:objectByID(message.icon)

	-- -- 修改字体大小
	-- if message.chatType == EnumChatType.Gang then
	-- 	if message.systemMsg then
	-- 		self.richtext:setFontSize(20)
	-- 	else
	-- 		self.richtext:setFontSize(30)
	-- 	end
	-- end

	print("++++vip++++", message.vipLevel)

	--added by wuqi
	self.txt_vip:setVisible(true)
	self.img_vip:setVisible(false)

	self.txt_name:setPosition(self.pos_txt_name1)
	self.txt_position:setPosition(self.pos_txt_position1)
	self.img_title:setPosition(self.pos_img_title1)

	print("roleData = ", roleData)
	print("message = ", message)
	if roleData == nil then
		--assert("designer is bad guy.role data not found : ",message.roleId)
		--game master role data fix
		-- roleData =  RoleData:objectByID(1)
		-- self.img_icon:setTexture(roleData:getIconPath())
		-- self.img_head:setTexture(GetColorIconByQuality(message.quality))

		roleData =  RoleData:objectByID(1)
		self.img_icon:setTexture(roleData:getIconPath())		
		--self.img_head:setTexture(GetColorIconByQuality(message.quality))
		Public:addFrameImg(self.img_icon,message.headPicFrame)               --pck change head icon and head icon frame

		self.txt_name:setText(message.name)
		self.txt_vip:setText("1")
		self.txt_level:setText("1")		
		-- self.txt_msg:setText(message.content)
		-- self.txt_timestamp:setText(self:getTimeFormatString())

		--added by wuqi
		self.img_vip:setVisible(false)
	else
		self.img_icon:setTexture(roleData:getIconPath())
		--self.img_head:setTexture(GetColorIconByQuality(message.quality))
		Public:addFrameImg(self.img_icon,message.headPicFrame)               --pck change head icon and head icon frame
		self.txt_name:setText(message.name)
		self.txt_vip:setText("o".. message.vipLevel)
		self.txt_level:setText(message.level)
		-- self.txt_msg:setText(message.content)
		-- self.txt_timestamp:setText(self:getTimeFormatString())

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

	--self.img_icon:setTexture(roleData:getIconPath())
	--self.img_head:setTexture(GetColorIconByQuality(message.quality))
	--self.txt_name:setText(message.name)
	--self.txt_vip:setText("o".. message.vipLevel)
	--self.txt_level:setText(message.level)
	--self.txt_msg:setText(message.content)
	--self.txt_timestamp:setText(self:getTimeFormatString())

	-- self.txt_msg:setText(message.content)
	local tSmileConfig = ChatManager:getSmileConfig()
    local szMSG = ChatManager:getPublicStr()
    -- local szInput = message.content
    local szInput = string.gsub(message.content, "([\\uE000-\\uF8FF]|\\uD83C[\\uDF00-\\uDFFF]|\\uD83D[\\uDC00-\\uDDFF])", "")

    -- 非系统信息则 需要处理html字符
    if message.roleId ~= 0 then
    	szInput = szInput:gsub( "<", '&lt;')
    	szInput = szInput:gsub( ">", '&gt;')
   	end

	print("message.content = ",message.content)
    for k, v in pairs(tSmileConfig) do
        szInput = string.gsub(szInput, k, v)
    end

    local szSendMSG = string.format(szMSG, szInput)
	self.richtext:setText(szSendMSG)
	self.txt_timestamp:setText(self:getTimeFormatString())

	-- GM .....
	if message.roleId == 0 then
		self.txt_vip:setVisible(false)
		self.txt_level:setVisible(false)
		self.lbl_level:setVisible(false)
		self.img_vip:setVisible(false)

		-- self.txt_name:setPosition(self.txt_vip:getPosition())
		self.txt_name:setPosition(ccp(self.txt_vip:getPosition().x - 30, self.txt_vip:getPosition().y))
		self.img_icon:setTexture("icon/roleicon/11000.png")
		--self.img_head:setTexture(GetColorIconByQuality(5))	
	else
		self.txt_vip:setVisible(true)
		self.txt_level:setVisible(true)
		self.lbl_level:setVisible(true)

		self.txt_name:setPosition(self.namePosition)

		--added by wuqi
		--local vipLevel = MainPlayer:getVipLevel()
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

	-- 隐藏按钮
	self.btn_accept:setVisible(false)
	self.btn_ignore:setVisible(false)
	Public:addInfoListen(self.img_icon,false)
	self.img_icon:setFlipX(true)
	if message.chatType == EnumChatType.Public then
		-- 系统消息 guildId 为 nil
		if message.guildId and message.guildId > 0 then
			self.txt_position:setVisible(true)
			self.txt_position:setText("（" .. message.guildName .. "）")

			self.txt_position:setPositionX(self.txt_name:getPositionX() + self.txt_name:getSize().width)
			--if 
			--local titlePic = RankManager:getTitlePic( index )
		else
			self.txt_position:setVisible(false)
		end
		Public:addInfoListen(self.img_icon,true,4,message.playerId)
	elseif message.chatType == EnumChatType.PrivateChat then
		self.txt_position:setVisible(false)
		Public:addInfoListen(self.img_icon,true,1,message.playerId)
	elseif message.chatType == EnumChatType.Gang then
		self.txt_position:setVisible(true)
		-- 如果是系统消息
		if message.systemMsg then
			-- 显示公会名还是职位
			if message.showGuidNameOrPosition == 1 then
				self.txt_position:setText("（" .. message.guildName .. "）")
			elseif message.showGuidNameOrPosition == 2 then
				if message.competence == 1 then
					--self.txt_position:setText("（帮主）")
					self.txt_position:setText(localizable.common_faction_no_1)
				elseif message.competence == 2 then
					--self.txt_position:setText("（副帮主）")
					self.txt_position:setText(localizable.common_faction_no_2)
				else
					--self.txt_position:setText("（帮众）")
					self.txt_position:setText(localizable.common_faction_no_3)
				end
				Public:addInfoListen(self.img_icon,true,3,message.playerId)
			end

			-- 是否显示邀请按钮
			local messageTime = MainPlayer:getNowtime() - math.floor(message.timestamp/1000)
			local viewFlag = true
			if messageTime >= (24*60*60) then
				viewFlag = false
			end
			if viewFlag and message.showInviteBtns then
				self.btn_accept:setVisible(true)
				self.btn_ignore:setVisible(true)
			end
		else
			if message.competence == 1 then
				--self.txt_position:setText("（帮主）")
				self.txt_position:setText(localizable.common_faction_no_1)
			elseif message.competence == 2 then
				--self.txt_position:setText("（副帮主）")
				self.txt_position:setText(localizable.common_faction_no_2)
			else
				--self.txt_position:setText("（帮众）")
				self.txt_position:setText(localizable.common_faction_no_3)
			end
			Public:addInfoListen(self.img_icon,true,3,message.playerId)
		end

		self.txt_position:setPositionX(self.txt_name:getPositionX() + self.txt_name:getSize().width)
	elseif message.chatType == EnumChatType.FactionNotice then
		self.txt_position:setVisible(false)
		self.txt_name:setPositionX(self.txt_msg:getPositionX())
		self.txt_vip:setVisible(false)
		self.txt_level:setText(message.level)
		self.img_vip:setVisible(false)
		local iconPath = FactionManager:getMyBannerIconPath()
		self.img_icon:setTexture(iconPath)	
		self.img_icon:setFlipX(false)
	elseif message.chatType == EnumChatType.Server then
		self.txt_position:setVisible(true)
		local id = message.serverId or 0
		local serverName = message.serverName or ""
		self.txt_position:setText("（" ..serverName .. "）")

		self.txt_position:setPositionX(self.txt_name:getPositionX() + self.txt_name:getSize().width)
		--self.img_head:setTexture(GetColorIconByQuality(message.quality))	
		Public:addInfoListen(self.img_icon,true,5,message.playerId,message.serverId)
	else
		self.txt_position:setVisible(false)
	end
	--增加称号
	self.img_title:setVisible(false)
	if message.titleType then
		if message.titleType > 0 and message.titleType < 11 then
			if self.txt_position:isVisible() then
				local currX = self.txt_position:getPositionX()
				local currX = currX + self.txt_position:getSize().width + 10
				self.img_title:setVisible(true)
				self.img_title:setPositionX(currX)
				self.img_title:setTexture(RankManager:getTitlePic(message.titleType))
			else
				local currX = self.txt_name:getPositionX()
				local currX = currX + self.txt_name:getSize().width + 10
				self.img_title:setVisible(true)
				self.img_title:setPositionX(currX)
				self.img_title:setTexture(RankManager:getTitlePic(message.titleType))
			end
		end
	end
	--增加指导员标签
	print("message.guideType = ",message.guideType)

	if message.guideType then
		local flag = bit_and(message.guideType,1)
		if flag ~= 0 then
			self.img_zdy:setVisible(true)
		else
			self.img_zdy:setVisible(false)
		end
	else
		self.img_zdy:setVisible(false)
	end
end

function PublicMessageCell:getTimeFormatString()
	local seconds = self.message.timestamp / 1000
	return os.date("%X", seconds)
end

function PublicMessageCell.iconBtnClickHandle(sender)
	print(sender.logic.message)

	if sender.logic.message.chatType == EnumChatType.Public or sender.logic.message.chatType == EnumChatType.Gang then
		if sender.logic.message.playerId ~= MainPlayer:getPlayerId() and sender.logic.message.roleId ~= 0 then
    		local layer = AlertManager:addLayerToQueueAndCacheByFile(
        		"lua.logic.chat.ChatOperatePanel", AlertManager.BLOCK_AND_GRAY_CLOSE)

			local bg = TFDirector:getChildByPath(layer, "bg")

    		local pos = sender:getParent():convertToWorldSpaceAR(sender:getPosition())
			pos = layer:convertToNodeSpace(pos);

			local size = sender:getSize()
			pos.x = pos.x + (size.width / 2 * sender:getScaleX())
			pos.y = pos.y + (size.height / 2 * sender:getScaleY())
	
			bg:setPosition(pos)

			layer:setModelType(MainPlayer:getPlayerProperties(), sender.logic.message.playerId, sender.logic.message.name)

			-- 帮派频道不能邀请
			if sender.logic.message.chatType == EnumChatType.Gang then
				layer:setFriendID(sender.logic.message.playerId,sender.logic.message.level)
				layer:setCanInvite(false)

    			AlertManager:show()
    			return
			end

			local canInvite = true

			-- 自己没有帮派
			if not FactionManager:isJoinFaction() then
				canInvite = false
			end

			-- 对方有帮派
			if sender.logic.message.guildId and sender.logic.message.guildId > 0 then
				canInvite = false
				layer:setIsHasFaction(true)
			else
				layer:setIsHasFaction(false)
			end

			-- 已被自己的帮派邀请过
			if canInvite then
				local myGuildID = FactionManager:getPersonalInfo().guildId
				if sender.logic.message.invitationGuilds then
					for _,v in pairs(sender.logic.message.invitationGuilds) do
						if v == myGuildID then
							canInvite = false
							break
						end
					end
				end
			end

			layer:setFriendID(sender.logic.message.playerId,sender.logic.message.level)
			layer:setCanInvite(canInvite)

    		AlertManager:show()
    	end
    end
end

function PublicMessageCell.onAccept(sender)
	local messageTime = MainPlayer:getNowtime() - math.floor(sender.logic.message.timestamp/1000)
	print("CCCCC = ",messageTime)
	print(sender.logic.message)
	if messageTime >= (24*60*60) then
		--toastMessage("邀请已过期")
		toastMessage(localizable.publicMessageCell_time_out)
		sender.logic.btn_accept:setVisible(false)
		sender.logic.btn_ignore:setVisible(false)		
		return
	end
	FactionManager:operateInvitation(1, sender.logic.message.guildId)
end

function PublicMessageCell.onIgnore(sender)
	local messageTime = MainPlayer:getNowtime() - math.floor(sender.logic.message.timestamp/1000)
	if messageTime >= (24*60*60) then
		--toastMessage("邀请已过期")
		toastMessage(localizable.publicMessageCell_time_out)
		sender.logic.btn_accept:setVisible(false)
		sender.logic.btn_ignore:setVisible(false)		
		return
	end
	FactionManager:operateInvitation(2, sender.logic.message.guildId)
end

function PublicMessageCell:registerEvents()
	self.super.registerEvents(self)
	--self.img_head:addMEListener(TFWIDGET_CLICK, audioClickfun(self.iconBtnClickHandle))

	self.btn_accept:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAccept))
	self.btn_ignore:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onIgnore))
end

function PublicMessageCell:removeEvents()
    self.img_head:removeMEListener(TFWIDGET_CLICK)
    self.super.removeEvents(self)

    self.btn_accept:removeMEListener(TFWIDGET_CLICK)
    self.btn_ignore:removeMEListener(TFWIDGET_CLICK)
end

function PublicMessageCell:getSize()
	return self.ui:getSize()
end

return PublicMessageCell
