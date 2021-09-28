--VipPageItem.lua


local VipPageItem = class ("VipPageItem", function (  )
	return CCSPageCellBase:create("ui_layout/vip_PageItem.json")
end)

function VipPageItem:initPageItem( index , parentLayer )
	self._bossEffect = nil
	local dungeonInfoList = G_Me.vipData:getDailyDungeonList()
	if index > #dungeonInfoList then
		return
	end

	local info = dungeonInfoList[index]

	local panel = self:getPanelByName("Panel_hero")
	panel:removeAllChildren()
	self._knight =KnightPic.createKnightPic( info.monster_image, panel, "vip_hero" ,true)
	self:getPanelByName("Panel_hero"):setScale(0.75)
	self:getLabelByName("Label_talk"):setText(info.talk)
	local qipao = self:getImageViewByName("Image_qipao") 
	qipao:setVisible(false)

	if self._bossEffect == nil then
        local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        self._bossEffect = EffectSingleMoving.run(panel, "smoving_idle", nil, {})
	end
end

function VipPageItem:showQipao( )
	local qipao = self:getImageViewByName("Image_qipao") 
	local animeScale = CCEaseBounceOut:create(CCScaleTo:create(0.5,1))
	qipao:setScale(0.1)
	qipao:setVisible(true)
	qipao:runAction(animeScale)
end

function VipPageItem:hideQipao( )
	local qipao = self:getImageViewByName("Image_qipao") 
	qipao:setVisible(false)
end

function VipPageItem:_onHeroPageIndexClicked( posIndex, knightId )
	
end

return VipPageItem