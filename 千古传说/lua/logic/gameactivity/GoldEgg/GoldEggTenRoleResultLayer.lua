
local GoldEggTenRoleResultLayer = class("GoldEggTenRoleResultLayer", BaseLayer)

function GoldEggTenRoleResultLayer:ctor(data)
	self.cardType = data
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.zadan.GetTenRoleLayer")
    self:PlayStartEffect()

end

function GoldEggTenRoleResultLayer:setEggType(EggType)
	self.EggType = EggType
end

function GoldEggTenRoleResultLayer:initUI(ui)
	self.super.initUI(self,ui)
	self.tenBgImg = TFDirector:getChildByPath(ui, "tenBgImg")
	self.tenBgImg:setVisible(false)
	self.ui = ui


    self.getCardBtn 	= TFDirector:getChildByPath(ui, "getCardBtn")
	self.getTenCardBtn  = TFDirector:getChildByPath(ui, "getTenCardBtn")
	self.getCardBtn:setVisible(false)
	self.getTenCardBtn:setVisible(false)
	self.getCardBtn.logic 		= self
	self.getTenCardBtn.logic 	= self
	self.getCardBtn.times 		= 1
	self.getTenCardBtn.times 	= 10
end

function GoldEggTenRoleResultLayer:registerEvents(ui)
	self.super.registerEvents(self)

	self.returnBtn = TFDirector:getChildByPath(ui, 'returnBtn')
    ADD_ALERT_CLOSE_LISTENER(self, self.returnBtn)
    self.returnBtn:setClickAreaLength(100)
    self.returnBtn:setVisible(false)

    self.getCardBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickAgain),1)
    self.getTenCardBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickAgain),1)



end

function GoldEggTenRoleResultLayer:PlayStartEffect()


	local timerID = TFDirector:addTimer(60, 1, nil, 
	function() 
		-- self.ui:setTouchEnabled(false)
		-- self.ui:removeMEListener(TFWIDGET_CLICK)
		TFDirector:removeTimer(timerID)
		self.tenBgImg:setVisible(true)
		self.roleIndex = 1
		self:OnIconShowEnd()
	end)

end

function GoldEggTenRoleResultLayer:OnIconShowEnd()
	if self.roleIndex > 10 then
		self.getCardCompelete = true

		self.returnBtn:setVisible(true)
		-- self.getCardBtn:setVisible(true)
		self:drawBtn(true)
	else

		local roleTypeId = GoldEggManager.getCardTypeList[self.roleIndex].resId
		local roleType 	 = GoldEggManager.getCardTypeList[self.roleIndex].resType
		local number 	 = GoldEggManager.getCardTypeList[self.roleIndex].number

		if GoldEggManager.getCardTypeList[self.roleIndex].resType == EnumDropType.ROLE then
			local newCardRoleData = RoleData:objectByID(roleTypeId)
			if newCardRoleData ~= nil then
				if newCardRoleData.quality >= QUALITY_JIA then
					play_wanlijiajichuxian()
					self.tenBgImg:setVisible(false)
					GoldEggManager:ShowGetOneRoleLayer(self.cardType, self.roleIndex)
				else
					self:ShowRoleIcon(self.roleIndex)
				end
			end
		else
			-- local newCardRoleData = ItemData:objectByID(roleTypeId)
			-- if newCardRoleData ~= nil then
			-- 	self:ShowRoleIcon(self.roleIndex)
			-- end

			local data = {}
			data.type   = roleType
			data.itemId = roleTypeId
			data.number = number

			local equip = BaseDataManager:getReward(data)

			if equip ~= nil then
				self:ShowRoleIcon(self.roleIndex)
			end
		end
	end
end

function GoldEggTenRoleResultLayer:ShowRoleIcon(roleIndex)
	self.tenBgImg:setVisible(true)
	
	self.roleIndex = self.roleIndex + 1 
	
	local posX = -280+math.mod(roleIndex-1,5)*140
	local posY = 70
	if roleIndex > 5 then
		posY = -70
	end

	local item = GoldEggManager.getCardTypeList[roleIndex]
	local roleTypeId = item.resId
	local newCardRoleData = nil
	local path = nil
	if item.resType == EnumDropType.ROLE then
		newCardRoleData = RoleData:objectByID(roleTypeId)
		path = newCardRoleData:getIconPath()
	else
		-- newCardRoleData = ItemData:objectByID(roleTypeId)
		-- path = newCardRoleData:GetPath()
		local data = {}
		data.type   = item.resType
		data.itemId = item.resId
		data.number = item.number

		newCardRoleData = BaseDataManager:getReward(data)
		path = newCardRoleData.path
	end

	if newCardRoleData == nil then
		print("item = ", item)
		m = n + 1
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
			-- local txt_num = TFLabel:create()
			-- txt_num:setAnchorPoint(ccp(1, 0))
			-- txt_num:setPosition(ccp(52, -54))
			-- txt_num:setText(item.number)
			-- txt_num:setFontSize(20)
			-- roleQualityImg:addChild(txt_num)

			newCardRoleData = ItemData:objectByID(roleTypeId)
			
			newCardRoleData.itemid = newCardRoleData.id

			if newCardRoleData.type == EnumGameItemType.Soul and newCardRoleData.kind ~= 3 then
				Public:addPieceImg(roleIcon,newCardRoleData,true)
			elseif newCardRoleData.type == EnumGameItemType.Piece then
				Public:addPieceImg(roleIcon,newCardRoleData,true)
			else
				Public:addPieceImg(roleIcon,newCardRoleData,false)
			end

		end

					local txt_num = TFLabel:create()
			txt_num:setAnchorPoint(ccp(1, 0))
			txt_num:setPosition(ccp(52, -54))
			txt_num:setText(item.number)
			txt_num:setFontSize(20)
			roleQualityImg:addChild(txt_num)


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

function GoldEggTenRoleResultLayer:drawBtn(bIsVisible)
	self.getTenCardBtn:setVisible(bIsVisible)
	self.getCardBtn:setVisible(bIsVisible)

	local img_icon1  = TFDirector:getChildByPath(self.getCardBtn, 'img_cost') 
	local img_icon2  = TFDirector:getChildByPath(self.getTenCardBtn, 'img_cost') 

	local txt_cost1 = TFDirector:getChildByPath(self.getCardBtn, 'txt_cost') 
	local txt_cost2 = TFDirector:getChildByPath(self.getTenCardBtn, 'txt_cost')

	local eggType = self.EggType
    local eggInfo = GoldEggManager:getEggInfo(eggType)

    txt_cost1:setText(eggInfo.number)
    txt_cost2:setText(eggInfo.number*10)

    local iconPath = "ui_new/zadan/"
    if eggType == 1 then
		iconPath = iconPath .. "img_yincz.png"
	elseif eggType == 2 then
		iconPath = iconPath .. "img_jincz.png"
	end
	img_icon1:setTexture(iconPath)
	img_icon2:setTexture(iconPath)
end

function GoldEggTenRoleResultLayer:reqeustHitEgg(times)
    local hammerDesc = localizable.goldEggItem_hammer_type

	local eggType = self.EggType
    local eggInfo = GoldEggManager:getEggInfo(eggType)

    local commonReward = {}
    commonReward.type   = tonumber(eggInfo.resType)
    commonReward.itemid = tonumber(eggInfo.resId)
    commonReward.number = tonumber(eggInfo.number)
    local rewarddata = BaseDataManager:getReward(commonReward)

    local myToolNum = MainPlayer:getGoodsNum(rewarddata)
	
    if myToolNum < (commonReward.number * times) then
        --toastMessage("没有足够的"..hammerDesc[eggType])
        toastMessage(stringUtils.format(localizable.goldEggItem_no_hammer,hammerDesc[eggType]))
        return false
    end

    return true
end


function GoldEggTenRoleResultLayer.onClickAgain(sender)
  	local self  = sender.logic
  	local tiems = sender.times

  	if self:reqeustHitEgg(tiems) == false then
  		return
  	end


  	GoldEggManager:RequestBreakGoldEgg(self.EggType, tiems)

	self.getCardCompelete = false
	AlertManager:close()
end

return GoldEggTenRoleResultLayer
