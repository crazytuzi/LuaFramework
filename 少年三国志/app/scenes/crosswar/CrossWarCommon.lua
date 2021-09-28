require("app.cfg.contest_value_info")

local CrossWarCommon = {
	
	-- 事件类型
	EVENT_STATE_CHANGED			= "event_cross_war_state_changed",		-- 比赛状态改变
	EVENT_UPDATE_COUNTDOWN		= "event_cross_war_update_countdown",	-- 更新倒计时

	-- 比赛模式
	MODE_SCORE_MATCH			= 1,	-- 积分赛
	MODE_CHAMPIONSHIP			= 2,	-- 争霸赛

	-- 比赛阶段
	STATE_UNOPEN				= 0,	-- 休赛期
	STATE_BEFORE_SCORE_MATCH	= 1,	-- 积分赛之前
	STATE_IN_SCORE_MATCH		= 2,	-- 积分赛进行中
	STATE_AFTER_SCORE_MATCH		= 3,	-- 积分赛之后，争霸赛之前
	STATE_IN_CHAMPIONSHIP		= 4,	-- 争霸赛进行中
	STATE_AFTER_CHAMPIONSHIP	= 5,	-- 争霸赛之后

	-- 排行榜类型
	RANK_SCORE					= 1,	-- 积分排行
	RANK_CHAMPIONSHIP 			= 2,	-- 争霸排行
	RANK_BET					= 3,	-- 押注排行

	-- 需要显示或押注的最高排名范围
	CHAMPIONSHIP_TOP_RANKS		= 10,

	-- 鲜花道具的ID和类型
	ITEM_FLOWER_SHOP_ID			= 30,
	ITEM_FLOWER_ID				= 127,
	ITEM_FLOWER_TYPE			= 25,

	-- 演武勋章的图标
	ICON_MEDAL_BIG				= "icon/basic/14.png"
}

-- get the limit number to bet
function CrossWarCommon.getLimitBetNum()
	return contest_value_info.get(28).value
end

-- center a line of contents in the panel horizontally
function CrossWarCommon.centerContent(panel)
	local children = {}
	if device.platform == "wp8" or device.platform == "winrt" then
        children = panel:getChildrenWidget() or {}
    else
       	children = panel:getChildren() or {}
    end
    if not children then 
       	return 0
    end
    local count = children:count()

	-- calculate the total width of whole contents
	local totalWidth = 0
	for i = 0, count - 1 do
		local obj = children:objectAtIndex(i)
		if obj:isVisible() then
			obj:setPositionX(totalWidth)
			totalWidth = totalWidth + obj:getContentSize().width
		end
	end

	-- get parent's attribute
	local parent		= panel:getParent()
	local parentWidth 	= parent:getContentSize().width
	local parentAnchorX	= parent:getAnchorPointXY()

	-- calculate the position of the panel
	local center = parentWidth / 2 - parentWidth * parentAnchorX
	local x =  center - totalWidth / 2
	panel:setPositionX(x)
end

-- create a rich-text from a normal template label
function CrossWarCommon.createRichTextFromTemplate(template, parent, content, align)
	local posX, posY = template:getPositionX(), template:getPositionY()
    local anchorX, anchorY = template:getAnchorPointXY()
    local anchor
    local size = template:getSize()
    local richText = CCSRichText:create(size.width, size.height)
    richText:setFontName(template:getFontName())
    richText:setFontSize(template:getFontSize())
    richText:setPosition(ccp(posX, posY))
    richText:setAnchorPoint(ccp(anchorX, anchorY))
    richText:setShowTextFromTop(true)

    richText:appendContent(content, Colors.uiColors.WHITE)
    richText:setTextAlignment(align or kCCTextAlignmentCenter)
    richText:reloadData()
    parent:addChild(richText)

    return richText
end

-- play the effect of jumping out a number
function CrossWarCommon.jumpOutNumber(label, oldNum, newNum)
	if label then
		local scale = CCSequence:createWithTwoActions(CCScaleTo:create(0.25, 2), CCScaleTo:create(0.25, 1))
		local growUp = CCNumberGrowupAction:create(oldNum, newNum, 0.5, function(number) 
			label:setText(tostring(number))
		end)
		local act = CCSpawn:createWithTwoActions(scale, growUp)
		label:runAction(act)
	end
end

return CrossWarCommon