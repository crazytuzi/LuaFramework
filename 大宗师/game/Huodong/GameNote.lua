 --[[
 --
 -- @authors shan 
 -- @date    2014-08-07 11:27:40
 -- @version 
 --
 --]]

local GameNote = class("GameNote", function ( ... )
	return display.newLayer("GameNote")
end)

local contentSizeHeight = 0 

local Item = class("Item", function(param)
    -- dump(param)
    local itemData = param.itemData 

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBuilderReaderLoad("ccbi/gamenote/noteItem.ccbi", proxy, rootnode)
    local textNode = rootnode["text_node"] 
    -- dump(itemData.tcolor)
    
    local title_color = ccc3(
                            checkint(string.format("%s", '0x' .. string.sub(itemData.tcolor, 1, 2))), 
                            checkint(string.format("%s", '0x' .. string.sub(itemData.tcolor, 3, 4))), 
                            checkint(string.format("%s", '0x' .. string.sub(itemData.tcolor, 5, 6)))
    ) 

    local content_color = ccc3(
                            checkint(string.format("%s", '0x' .. string.sub(itemData.ccolor, 1, 2))), 
                            checkint(string.format("%s", '0x' .. string.sub(itemData.ccolor, 3, 4))), 
                            checkint(string.format("%s", '0x' .. string.sub(itemData.ccolor, 5, 6)))
    ) 

    local titleLabel 
    if itemData.teffect == 1 then 
        titleLabel = ui.newTTFLabelWithOutline({
            text = itemData.title,
            font = FONTS_NAME.font_haibao,
            color = title_color,
            outlineColor = FONT_COLOR.NOTE_TITLE_OUTLINE,
            size = checkint(itemData.tfont),
            align = ui.TEXT_ALIGN_CENTER
            })
    else
        titleLabel = ui.newTTFLabelWithOutline({
            text = itemData.title,
            font = FONTS_NAME.font_haibao,
            color = title_color,
            size = checkint(itemData.tfont),
            align = ui.TEXT_ALIGN_CENTER
            })
    end 

    titleLabel:setPosition(node:getContentSize().width/2, node:getContentSize().height/2)
    node:addChild(titleLabel)

    local viewSize = CCSizeMake(textNode:getContentSize().width, 0)

    -- dump(itemData.content)
    -- dump(json.encode(itemData.content)) 

    local txt = string.gsub(itemData.content, "\r\n", "\n")

    local contentLabel = ui.newTTFLabel({ 
        text = txt, 
        font = FONTS_NAME.font_fzcy,
        color = content_color,
        size = checkint(itemData.cfont),
        align = ui.TEXT_ALIGN_LEFT,
        valign = ui.TEXT_VALIGN_TOP, 
        dimensions = viewSize 
        })

    contentLabel:setAnchorPoint(0.5, 1)
    contentLabel:setPosition(node:getContentSize().width/2, 0)
    node:addChild(contentLabel) 

    contentSizeHeight = contentLabel:getContentSize().height 
    -- dump(contentSizeHeight)
    
    return node 
end)



function GameNote:ctor( )

	self:setNodeEventEnabled(true)

	-- 半透背景
	local bg = display.newColorLayer(ccc4(0,0,0,100))
	bg:setScale(display.height/bg:getContentSize().height)
	self:addChild(bg)

	bg:setTouchEnabled(true)


	local proxy = CCBProxy:create()
    -- local ccbReader = proxy:createCCBReader()
    local rootnode = rootnode or {}

    -- 背景卷轴
    local ccb_mm_name = "ccbi/gamenote/gamenote.ccbi"    
    local node = CCBuilderReaderLoad(ccb_mm_name, proxy, rootnode)
    self.layer = tolua.cast(node,"CCLayer")   
    self.layer:setPosition(display.width/2, display.height/2)
    self:addChild(self.layer)

    -- 进入游戏按钮
    local okBtn = rootnode["btn_ok"]
    okBtn:addHandleOfControlEvent(function(eventName,sender)  
    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))      

        sender:runAction(transition.sequence({
            CCScaleTo:create(0.08, 0.8),
            CCScaleTo:create(0.1, 1.2),
            CCScaleTo:create(0.02, 1),
            CCCallFunc:create(function()
                self:removeSelf()
            end),
            })
        )
    end,
    CCControlEventTouchDown)

    local height = 0 
    local contentViewSize = rootnode["contentView"]:getContentSize() 
	if #game.player.m_gamenote == 0 then
		game.player.m_gamenote[1] = 
		{
			title = "欢迎",
			tfont = 26,
			tcolor = "ff000",
			teffect = 1,
			content = "          欢迎来到武侠大宗师ZHUPF测试服！！！",
			cfont = 20,
			ccolor = "9a32cd"
		}
	else
	
	end
    for i, v in ipairs(game.player.m_gamenote) do 
        local item = Item.new({
            itemData = v 
            })

        item:setPosition(contentViewSize.width / 2, -height)
        rootnode["contentView"]:addChild(item)

        height = height + item:getContentSize().height + contentSizeHeight + 10 
    end

    local sz = CCSizeMake(contentViewSize.width, contentViewSize.height + height)

    rootnode["descView"]:setContentSize(sz)
    rootnode["contentView"]:setPosition(ccp(sz.width / 2, sz.height))

    local scrollView = rootnode["scrollView"]
    scrollView:updateInset()
    scrollView:setContentOffset(CCPointMake(0, -sz.height + scrollView:getViewSize().height), false) 

end

function GameNote:onExit( ... )
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
end


return GameNote
