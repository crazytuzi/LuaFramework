
local GetTenRoleResultLayer = class("GetTenRoleResultLayer", BaseLayer)

function GetTenRoleResultLayer:ctor(data)
	self.cardType = data
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.shop.GetTenRoleLayer")
    self:PlayStartEffect()

end

function GetTenRoleResultLayer:initUI(ui)
	self.super.initUI(self,ui)
	self.tenBgImg = TFDirector:getChildByPath(ui, "tenBgImg")
	self.tenBgImg:setVisible(false)
	self.ui = ui
end

function GetTenRoleResultLayer:registerEvents(ui)
	self.super.registerEvents(self)

	self.returnBtn = TFDirector:getChildByPath(ui, 'returnBtn')
    ADD_ALERT_CLOSE_LISTENER(self, self.returnBtn)
    self.returnBtn:setClickAreaLength(100)
    self.returnBtn:setVisible(false)

    self.getCardBtn = TFDirector:getChildByPath(ui, "getCardBtn")
    self.getCardBtn:addMEListener(TFWIDGET_CLICK, 
	audioClickfun(function()
		if GetCardManager:SendGetCardMsgWithAnimation(self.cardType) then
			self.getCardCompelete = false
			AlertManager:close()
		end
	end),1)
	self.getCardBtn:setVisible(false)
	local getCardBtnPath = {"ui_new/shop/zmdj.png", "ui_new/shop/zmj.png", "ui_new/shop/zmjs.png"}
	self.getCardBtn:setTextureNormal(getCardBtnPath[self.cardType])

	local yuanBaoCost = ConstantData:getValue("Recruit.Consume.Sycee.Million.Batch")
	local yuanbaoLabel = TFDirector:getChildByPath(self.ui, "yuanbaoLabel")
	yuanbaoLabel:setText(yuanBaoCost)
end

function GetTenRoleResultLayer:PlayStartEffect()
	-- TFResourceHelper:instance():addArmatureFromJsonFile("effect/zm1.xml")
	-- local effect = TFArmature:create("zm1_anim")
	-- if effect == nil then
	-- 	return
	-- end

	-- effect:setZOrder(-100)
	-- effect:setAnimationFps(GameConfig.ANIM_FPS)
	-- effect:playByIndex(0, -1, -1, 0)

	-- local nViewHeight = GameConfig.WS.height
 --    local nViewWidth = GameConfig.WS.width
	-- effect:setPosition(ccp(nViewWidth/2, nViewHeight/2))

	-- self.ui:addChild(effect)

	local timerID = TFDirector:addTimer(60, 1, nil, 
	function() 
		-- self.ui:setTouchEnabled(false)
		-- self.ui:removeMEListener(TFWIDGET_CLICK)
		TFDirector:removeTimer(timerID)
		self.tenBgImg:setVisible(true)
		self.roleIndex = 1
		self:OnIconShowEnd()
	end)

	-- self.ui:setTouchEnabled(true)
	-- self.ui:addMEListener(TFWIDGET_CLICK, 
	-- audioClickfun(function()
	-- 	self.ui:setTouchEnabled(false)
	-- 	self.ui:removeMEListener(TFWIDGET_CLICK)
	-- 	effect:setAnimationScale(100)
	-- 	TFDirector:removeTimer(timerID)
	-- 	self.tenBgImg:setVisible(true)
	-- 	self.roleIndex = 1
	-- 	self:OnIconShowEnd()
	-- end),1)
end

function GetTenRoleResultLayer:OnIconShowEnd()
	if self.roleIndex > 10 then
		self.getCardCompelete = true

		self.returnBtn:setVisible(true)
		self.getCardBtn:setVisible(true)
		local yuanBaoCost = ConstantData:getValue("Recruit.Consume.Sycee.Million.Batch")
		local yuanbaoLabel = TFDirector:getChildByPath(self.ui, "yuanbaoLabel")
		yuanbaoLabel:setText(yuanBaoCost)

		local zhaomutool = TFDirector:getChildByPath(self.ui, "zhaomutool")
		zhaomutool:setVisible(false)
		local RecruitData = RecruitRateData:objectByID(3)
		if RecruitData then
			local goodId 	= RecruitData.consume_goods_id
			local costTool 	= RecruitData.consume_goods_num
			local tool 		= BagManager:getItemById(goodId)

			if tool and tool.num >= costTool then
				-- yuanbaoLabel:setText(tool.num)
				yuanbaoLabel:setText(1)
				zhaomutool:setVisible(true)
				zhaomutool:setTexture("ui_new/common/zm_nverhong_icon")
			end
		end



	else

		local roleTypeId = GetCardManager.getCardTypeList[self.roleIndex].resId
		if GetCardManager.getCardTypeList[self.roleIndex].resType == EnumDropType.ROLE then
			local newCardRoleData = RoleData:objectByID(roleTypeId)
			if newCardRoleData ~= nil then
				if newCardRoleData.quality >= QUALITY_JIA then
					play_wanlijiajichuxian()
					self.tenBgImg:setVisible(false)
					GetCardManager:ShowGetOneRoleLayer(self.cardType, self.roleIndex)
				else
					self:ShowRoleIcon(self.roleIndex)
				end
			end
		else
			local newCardRoleData = ItemData:objectByID(roleTypeId)
			if newCardRoleData ~= nil then
				-- if newCardRoleData.quality >= QUALITY_JIA then
				-- 	play_wanlijiajichuxian()
				-- 	self.tenBgImg:setVisible(false)
				-- 	GetCardManager:ShowGetOneItemLayer(self.cardType, self.roleIndex)
				-- else
					self:ShowRoleIcon(self.roleIndex)
				-- end
			end
		end
	end
end

function GetTenRoleResultLayer:ShowRoleIcon(roleIndex)
	self.tenBgImg:setVisible(true)
	
	self.roleIndex = self.roleIndex + 1 
	
	local posX = -280+math.mod(roleIndex-1,5)*140
	local posY = 70
	if roleIndex > 5 then
		posY = -70
	end

	local item = GetCardManager.getCardTypeList[roleIndex]
	local roleTypeId = item.resId
	local newCardRoleData = nil
	local path = nil
	if item.resType == EnumDropType.ROLE then
		newCardRoleData = RoleData:objectByID(roleTypeId)
		path = newCardRoleData:getIconPath()
	else
		newCardRoleData = ItemData:objectByID(roleTypeId)
		path = newCardRoleData:GetPath()
	end
	if newCardRoleData ~= nil then
		local roleQualityImg = TFImage:create()
		roleQualityImg:setTexture(GetColorIconByQuality(newCardRoleData.quality))
		roleQualityImg:setPosition(ccp(posX, posY))
		roleQualityImg:setScale(1.7)
		roleQualityImg:setOpacity(0)
		self.tenBgImg:addChild(roleQualityImg)

		local roleIcon = TFImage:create()
		roleQualityImg:addChild(roleIcon)
		roleIcon:setTexture(path)
		roleIcon:setTouchEnabled(true)
		roleIcon:addMEListener(TFWIDGET_CLICK,
		audioClickfun(function()
			if self.getCardCompelete ~= true then
				return
			end

			Public:ShowItemTipLayer(roleTypeId, item.resType)
		end))


		if item.resType == EnumDropType.GOODS then
			local txt_num = TFLabel:create()
			txt_num:setAnchorPoint(ccp(1, 0))
			txt_num:setPosition(ccp(52, -54))
			txt_num:setText(item.number)
			txt_num:setFontSize(20)
			roleQualityImg:addChild(txt_num)
			
			newCardRoleData.itemid = newCardRoleData.id

			if newCardRoleData.type == EnumGameItemType.Soul and newCardRoleData.kind ~= 3 then
				Public:addPieceImg(roleIcon,newCardRoleData,true,1)
			elseif newCardRoleData.type == EnumGameItemType.Piece then
				Public:addPieceImg(roleIcon,newCardRoleData,true,1)
			else
				Public:addPieceImg(roleIcon,newCardRoleData,false)
			end

		end


		local roleTween = 
		{
			target = roleQualityImg,
			{
				duration = 0.1,
				alpha = 255,
				scale = 1,
			},

			onComplete = function ()
				self:OnIconShowEnd()
			end
		}
		TFDirector:toTween(roleTween)
	end
end

return GetTenRoleResultLayer
