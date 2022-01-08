
local GoldEggItemResultLayer = class("GoldEggItemResultLayer", BaseLayer)

function GoldEggItemResultLayer:ctor(data)
	self.cardType  = data[1]
	self.roleIndex = data[2]
	self.goodsInfo = GoldEggManager.getCardTypeList[self.roleIndex]
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.zadan.GetItemResultLayer")
    play_zhaomu_chouquxiahun()
end

function GoldEggItemResultLayer:setEggType(EggType)
	self.EggType = EggType
end

function GoldEggItemResultLayer:initUI(ui)
	self.super.initUI(self,ui)


	self.panel_effect 	= TFDirector:getChildByPath(ui, "panel_effect")
	self.img_quality 	= TFDirector:getChildByPath(ui, "img_quality_bg")
	self.img_icon 		= TFDirector:getChildByPath(ui, "img_icon")
	self.txt_num 		= TFDirector:getChildByPath(ui, "txt_num")
	self.returnBtn = TFDirector:getChildByPath(ui, 'returnBtn')

	self.getCardBtn 	= TFDirector:getChildByPath(ui, "getCardBtn")
	self.getTenCardBtn  = TFDirector:getChildByPath(ui, "getTenCardBtn")
	self.getCardBtn:setVisible(false)
	self.getTenCardBtn:setVisible(false)
	self.getCardBtn.logic 		= self
	self.getTenCardBtn.logic 	= self
	self.getCardBtn.times 		= 1
	self.getTenCardBtn.times 	= 10


	self.quality_pos = clone(self.img_quality:getPosition())
	self.img_quality:setVisible(false)
	self:PlayStartEffect()
end

function GoldEggItemResultLayer:removeUI()

end

function GoldEggItemResultLayer:registerEvents()
    ADD_ALERT_CLOSE_LISTENER(self, self.returnBtn)
    self.returnBtn:setClickAreaLength(100)
    self.returnBtn:setVisible(false)

    print("---------self.getTenCardBtn = ", self.getTenCardBtn.times)
    self.getCardBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickAgain),1)
    self.getTenCardBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickAgain),1)

	if self.cardType == 3 then
		self.panel_effect:addMEListener(TFWIDGET_CLICK, 
		audioClickfun(function()
			local roleIndex = self.roleIndex
			AlertManager:close()
			local tenLayer = AlertManager:getLayerByName("lua.logic.shop.GoldEggTenRoleResultLayer")
			if tenLayer ~= nil then
				tenLayer:ShowRoleIcon(roleIndex)
			end
		end))
	end
end

function GoldEggItemResultLayer:removeEvents()

end



function GoldEggItemResultLayer:PlayStartEffect()
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/NewCardEffect.xml")
	local effect = TFArmature:create("NewCardEffect_anim")
	if effect == nil then
		return
	end

	-- local pos = self.img_quality:getPosition()
	-- pos = ccp(pos.x, pos.y)
	self.img_quality:setPosition(ccp(self.quality_pos.x,self.quality_pos.y-50))
	effect:setZOrder(-100)
	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(1, -1, -1, 0)
	-- effect:setPosition(ccp(GameConfig.WS.width/2 - 80, GameConfig.WS.height/2 + 100))
	-- effect:setPosition(ccp(480 - 80, 320 + 100))
	effect:setPosition(self.quality_pos)

	self:addChild(effect)

	effect:addMEListener(TFARMATURE_COMPLETE,function()
        -- effect:removeFromParentAndCleanup(true)
        -- effect:setVisible(false)
        -- self:PlayResultEffect()
    end)
	self.startEffect = effect
    local temp = 0
	effect:addMEListener(TFARMATURE_UPDATE,function()
        temp = temp + 1
        if temp == 18 then
        	self.startEffect:removeFromParentAndCleanup(true)
        	self.startEffect = nil
        	-- self.startEffect:setVisible(false)
            self:PlayResultEffect()
        end
    end)
end

function GoldEggItemResultLayer:PlayResultEffect()
	print("self.goodsInfo = ", self.goodsInfo)
-- ├┄┄number=1,
-- ├┄┄resId=1,
-- ├┄┄resType=1
-- }
	local data = {}
	data.type   = self.goodsInfo.resType
	data.itemId = self.goodsInfo.resId
	data.number = self.goodsInfo.number

	local equip = BaseDataManager:getReward(data)

	-- local equip = ItemData:objectByID(1)
	if equip == nil then
		return
	end

	local pos = self.img_quality:getPosition()

	pos = ccp(pos.x, pos.y + 100)

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/NewCardEffect2.xml")
	local effect = TFArmature:create("NewCardEffect2_anim")
	if effect == nil then
		return
	end

	effect:setZOrder(-100)
	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(0, -1, -1, 1)
	effect:setPosition(pos)
	-- effect:setPosition(ccp(480 - 80, 320 + 100))

	self:addChild(effect)

	local img_quality 	= self.img_quality
	local img_icon  	= self.img_icon

	-- self:addChild(img_quality)
	-- img_quality:setPosition(ccp(480 + 80, 320 + 40))

	-- img_quality:setPosition(ccp(GameConfig.WS.width/2, GameConfig.WS.height/2 + 100))
	-- img_quality:setPosition(ccp(480, 320 + 100))

	img_quality:setPosition(pos)
	img_quality:setVisible(true)
    -- img_icon:setTexture(equip:GetPath())
    img_icon:setTexture(equip.path)
    
    img_quality:setTexture(GetColorIconByQuality(equip.quality))
    self.txt_num:setVisible(true)
    self.txt_num:setText(self.goodsInfo.number)

    equip.itemid = equip.id
    if equip.type == EnumGameItemType.Soul and equip.kind ~= 3 then
		Public:addPieceImg(img_icon,equip,true)
    elseif equip.type == EnumGameItemType.Piece then
		Public:addPieceImg(img_icon,equip,true)
    else
		Public:addPieceImg(img_icon,equip,false)
    end

    local item_name = TFLabel:create()
	item_name:setAnchorPoint(ccp(0.5, 0))
	item_name:setPosition(ccp(0, -100))
	item_name:setText(equip.name)
	item_name:setFontSize(24)
	img_quality:addChild(item_name)


	self:drawBtn(true)
	self.returnBtn:setVisible(true)

end


function GoldEggItemResultLayer:drawBtn(bIsVisible)
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

function GoldEggItemResultLayer:reqeustHitEgg(times)
    --local hammerDesc = {"银锤子", "金锤子"}
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
        toastMessage(stringUtils.format(localizable.goldEggItem_no_hammer, hammerDesc[eggType]))
        return false
    end

    return true
end


function GoldEggItemResultLayer.onClickAgain(sender)
  	local self  = sender.logic
  	local tiems = sender.times

  	if self:reqeustHitEgg(tiems) == false then
  		return
  	end

  	GoldEggManager:RequestBreakGoldEgg(self.EggType, tiems)
	self.getCardCompelete = false
	AlertManager:close()
end

return GoldEggItemResultLayer