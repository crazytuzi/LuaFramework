-- HeroGodCommon.lua

local KnightConst = require("app.const.KnightConst")
require("app.cfg.knight_info")
local HeroGodCommon = {}

function HeroGodCommon.getDisplyLevel(godLevel)
	local bigLevel = math.floor(godLevel / KnightConst.KNIGHT_GOD_ZHENGJIE)
	local smallLevel = godLevel % KnightConst.KNIGHT_GOD_ZHENGJIE
	-- return bigLevel .. "-" .. smallLevel
	return G_lang:get("LANG_GOD_DISPLY_LEVEL", {god = bigLevel, level = smallLevel})
end

function HeroGodCommon.getDisplyLevel2(godLevel)
	local bigLevel = math.floor(godLevel / KnightConst.KNIGHT_GOD_ZHENGJIE)
	local smallLevel = godLevel % KnightConst.KNIGHT_GOD_ZHENGJIE
	return bigLevel, smallLevel
end

-- 预览界面专用
function HeroGodCommon.getDisplyLevel3(godLevel)
	local bigLevel = math.floor(godLevel / KnightConst.KNIGHT_GOD_ZHENGJIE)
	local smallLevel = godLevel % KnightConst.KNIGHT_GOD_ZHENGJIE

	if bigLevel == 0 and smallLevel == 0 then
		bigLevel = KnightConst.KNIGHT_GOD_MAX_LEVEL
	end
	-- return bigLevel .. "-" .. smallLevel
	return G_lang:get("LANG_GOD_DISPLY_LEVEL", {god = bigLevel, level = smallLevel})
end

function HeroGodCommon.getDisplyLevel4(godLevel, quality)
	local bigLevel = math.floor(godLevel / KnightConst.KNIGHT_GOD_ZHENGJIE)
	local text = G_lang:get("LANG_GOD_JIESHU", {level = bigLevel})
	if quality == 5 then
		text = G_lang:get("LANG_GOD_CHENG") .. text
	elseif quality == 6 then
		text = G_lang:get("LANG_GOD_HONG") .. text
	end
	return text
end

-- 设置水印
function HeroGodCommon.setGodShuiYin(image, label, knightInfo)
	
	if not knightInfo then
		__LogError("HeroGodCommon.setGodShuiYin() knightInfo is nil")
		return
	end

	if not image then
		__LogError("HeroGodCommon.setGodShuiYin() image is nil")
		return
	end

	image:setVisible(false)

	if not label then
		__LogError("HeroGodCommon.setGodShuiYin() label is nil")
		return
	end

	label:setVisible(false)

	local knightBaseInfo = knight_info.get(knightInfo.base_id)
	if not knightBaseInfo then
		__LogError("HeroGodCommon.setGodShuiYin() knightBaseInfo is nil, id = " .. tostring(knightInfo.base_id))
		return
	end

	local nowGodLevel = G_Me.bagData.knightsData:getGodLevelByBaseInfo(knightBaseInfo, knightInfo.pulse_level)
	if type(nowGodLevel) ~= "number" then
		return
	end

	if knightBaseInfo.god_level > 0 or knightInfo.pulse_level > 0 then
		label:setText(HeroGodCommon.getDisplyLevel4(nowGodLevel, knightBaseInfo.quality))
		image:loadTexture(G_Path.getGodQualityShuiYin(knightBaseInfo.quality))
		image:setVisible(true)
		label:setVisible(true)
	end
end

-- 箭头的Action
function HeroGodCommon.trainingArrowAnimation(rootNode, arrowName, followLabel, showArrow, changeColor)
	if not arrowName  then
		return 
	end
	local arrow = rootNode:getImageViewByName(arrowName)
	if not arrow then 
		return 
	end

	local arrowX, arrowY = arrow:getPosition()
	local arrowSize = arrow:getSize()
	if followLabel then 
		local followLabelCtrl = rootNode:getLabelByName(followLabel)
		if followLabelCtrl then 
			local posx, posy = followLabelCtrl:getPosition()
			local anchorPt = followLabelCtrl:getAnchorPoint()
			local followLabelSize = followLabelCtrl:getSize()
			--arrowX = posx + (1 - anchorPt.x)*followLabelSize.width + arrowSize.width/2
			arrowY = posy
			if changeColor then
				followLabelCtrl:setColor(showArrow and Colors.darkColors.ATTRIBUTE or Colors.darkColors.DESCRIPTION)
			end
		end			
	end

	showArrow = showArrow or false
	arrow:stopAllActions()
	arrow:setVisible(showArrow)
	if showArrow then 
		
		arrow:setVisible(true)
		arrow:setOpacity(255)
	--arrow:loadTexture(G_Path.getGrowupIcon(isGrowup))
		local moveDistUp = 10
		local startPosy = (arrowY - moveDistUp/2)

		local arr = CCArray:create()
		arr:addObject(CCResetPosition:create(arrow, ccp(arrowX, startPosy)))
		arr:addObject(CCResetOpacity:create(arrow, 255))
		local moveby = CCMoveBy:create(0.8, ccp(0, moveDistUp))
		arr:addObject(CCEaseIn:create(moveby, 0.3))
		arr:addObject(CCFadeOut:create(0.2))
		
		arrow:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	end
end

return HeroGodCommon