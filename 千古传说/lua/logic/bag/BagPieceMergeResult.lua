
local BagPieceMergeResult = class("BagPieceMergeResult", BaseLayer)

function BagPieceMergeResult:ctor(data)
	self.goodsId = data
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.bag.BagPieceMergeResult")
    play_zhaomu_chouquxiahun()
end

function BagPieceMergeResult:initUI(ui)
	self.super.initUI(self,ui)


	self.panel_effect 	= TFDirector:getChildByPath(ui, "panel_effect")
	self.img_quality 	= TFDirector:getChildByPath(ui, "img_quality_bg")
	self.img_icon 		= TFDirector:getChildByPath(ui, "img_icon")

	self.img_quality:setVisible(false)
	self:PlayStartEffect()
end

function BagPieceMergeResult:removeUI()

end

function BagPieceMergeResult:registerEvents()
	self.panel_effect:addMEListener(TFWIDGET_CLICK,
    function()
		AlertManager:close()
    end)
end

function BagPieceMergeResult:removeEvents()

end



function BagPieceMergeResult:PlayStartEffect()
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/NewCardEffect.xml")
	local effect = TFArmature:create("NewCardEffect_anim")
	if effect == nil then
		return
	end

	local pos = self.img_quality:getPosition()
	pos = ccp(pos.x, pos.y + 50)

	effect:setZOrder(-100)
	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(1, -1, -1, 0)
	-- effect:setPosition(ccp(GameConfig.WS.width/2 - 80, GameConfig.WS.height/2 + 100))
	-- effect:setPosition(ccp(480 - 80, 320 + 100))
	effect:setPosition(pos)

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

function BagPieceMergeResult:PlayResultEffect()
	local equip = ItemData:objectByID(self.goodsId)
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
	print("GameConfig.WS = ", GameConfig.WS)
	print("equip = ", pos)
	if equip.type ~= EnumGameItemType.HeadPicFrame then
		img_icon:setTexture(equip:GetPath())
		img_quality:setTexture(GetColorIconByQuality(equip.quality))
		Public:addFrameImg(img_quality,nil,false)
	else
		img_icon:setTexture("")
		img_quality:setTexture(GetColorIconByQuality(5))
		Public:addFrameImg(img_quality,equip.usable)
	end
    
end

return BagPieceMergeResult