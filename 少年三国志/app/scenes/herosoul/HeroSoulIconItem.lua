local HeroSoulIconItem = class("HeroSoulIconItem", function()
	return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/herosoul_IconItem.json")
end)

require("app.cfg.ksoul_info")

local SOUL_QUALITY_FRAME = { nil, nil, nil,
							 "ui/herosoul/kuang_zi.png",
							 "ui/herosoul/kuang_cheng.png",
							 "ui/herosoul/kuang_hong.png",
							 "ui/herosoul/kuang_jin.png"}

function HeroSoulIconItem:ctor(soulId, isHighlight, showName)
	self._soulId 		= soulId 		-- 将灵ID
	self._isHighlight 	= isHighlight 	-- 是否高亮
	self._showName		= showName 		-- 是否显示名字
	
	self._icon 			= nil			-- 图标
	self._frame			= nil			-- 品质框（用来注册点击）
	self._nameLabel		= nil			-- 名字
	self._lightCover	= nil			-- 高亮遮罩

	-- initialize widgets
	self:_initWidgets()

	-- create a clipped icon firstly
	self:_createClippedIcon()

	-- update
	if self._soulId and self._soulId > 0 then
		self:update(self._soulId, self._isHighlight, self._showName)
	end
end

function HeroSoulIconItem:_initWidgets()
	self._frame = UIHelper:seekWidgetByName(self, "Image_Frame")
	self._frame = tolua.cast(self._frame, "ImageView")

	self._nameLabel = UIHelper:seekWidgetByName(self, "Label_SoulName")
	self._nameLabel = tolua.cast(self._nameLabel, "Label")
	self._nameLabel:createStroke(Colors.strokeBrown, 1)

	self._lightCover = UIHelper:seekWidgetByName(self, "Image_Light")
end

function HeroSoulIconItem:_createClippedIcon()
	-- we use a hexagon as the clipping area
	local clipArea = CCDrawNode:create()
	local r = 48 -- the radius of the hexagon
	local startAngle = 30 * math.pi / 180
	local deltaAngle = 60 * math.pi / 180

	local vertsNum = 6
	local vertsArr = CCPointArray:create(vertsNum)
	for i = 1, 6 do
		local radian = startAngle + deltaAngle * (i - 1)
		vertsArr:add(ccp(r * math.cos(radian), r * math.sin(radian)))
	end

	if device.platform == "wp8" or device.platform == "winrt" then
        G_WP8.drawPolygon(clipArea, vertsArr, vertsNum, ccc4f(1, 1, 1, 1), 1, ccc4f(1, 1, 1, 1))
    else
        clipArea:drawPolygon(vertsArr:fetchPoints(), vertsNum, ccc4f(1, 1, 1, 1), 1, ccc4f(1, 1, 1, 1))
    end

    -- create clipping node
    local clipNode = CCClippingNode:create()
    clipNode:setCascadeOpacityEnabled(true)
    clipNode:setStencil(clipArea)
    clipArea:setPosition(ccp(-1, 3))

    local parent = UIHelper:seekWidgetByName(self, "Panel_Clip")
    parent:addNode(clipNode)

    -- create an empty icon
	self._icon = ImageView:create()
	self._icon:setPosition(ccp(-2, 3))
	clipNode:addChild(self._icon)
end

function HeroSoulIconItem:update(soulId, isHighlight, showName)
	self._soulId = soulId
	self._isHighlight = isHighlight
	self._showName = showName
	local soulInfo = ksoul_info.get(soulId)

	-- update soul icon
	local imgPath = G_Path.getKnightIcon(soulInfo.res_id)
	self._icon:loadTexture(imgPath)
	self._icon:setScale(1.02)
	self._icon:showAsGray(not self._isHighlight)

	-- light cover
	self._lightCover:setVisible(self._isHighlight)

	-- update quality frame	
	self._frame:loadTexture(SOUL_QUALITY_FRAME[soulInfo.quality])
	self._frame:setName("frame_" .. soulId)

	-- update soul name
	self._nameLabel:setVisible(showName)
	if showName then
		self._nameLabel:setText(soulInfo.name2)
		self._nameLabel:setColor(Colors.qualityColors[soulInfo.quality])
	end
end

function HeroSoulIconItem:setClickFunc(topNode, func)
	if self._frame then
		self._frame:setTouchEnabled(true)
		topNode:registerWidgetClickEvent(self._frame:getName(), func)
	end
end

return HeroSoulIconItem