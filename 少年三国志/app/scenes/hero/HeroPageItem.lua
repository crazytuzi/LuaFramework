--HeroPageItem.lua


local HeroPageItem = class ("HeroPageItem", function (  )
	return CCSPageCellBase:create("ui_layout/knight_pageItem.json")
end)

function HeroPageItem:initPageItem( index , parentLayer, teamId )
		local formationIndex, knightId = G_Me.formationData:getFormationIdKnightIdByOrderIndex(teamId, teamId == 2 and (index - 6) or index)

		self._knightId = knightId
		self._posIndex = index
		self._parentLayer = parentLayer
		self._teamId = teamId

		local panel = self:getWidgetByName("Panel_hero")
    	if panel then
    		panel:removeAllChildren()
    	end

		local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(knightId)
		local resId = 0
		local knightInfo = nil
		if baseId > 0 then
			knightInfo = knight_info.get(baseId)
		end

		if knightInfo ~= nil then
			resId = knightInfo["res_id"]
		end

		if knightId == G_Me.formationData:getMainKnightId() then 
        	resId = G_Me.dressData:getDressedPic()
    	end

		self:showWidgetByName("ImageView_hero", resId <= 0 and index <= 6)

    	if panel and resId > 0 then
    		local size = panel:getSize()
    		local knightPic = require("app.scenes.common.KnightPic")
			local pic = knightPic.createKnightPic(resId, panel, nil, true)
			panel:setScale(1)
            -- --侠客呼吸动作
            local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
            EffectSingleMoving.run(panel, "smoving_idle", nil, {}, 1+ math.floor(math.random()*30))
            
		else
			__Log("panel is nil or resId <= 0")
    	end
end

function HeroPageItem:_onHeroPageIndexClicked( posIndex, knightId )
	local heroDesc = require("app.scenes.hero.HeroDescLayer")
	heroDesc.showHeroDesc(uf_sceneManager:getCurScene(), self._teamId, knightId, posIndex)
end

return HeroPageItem