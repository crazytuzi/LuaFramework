--
-- Author: Daneil
-- Date: 2015-01-15 22:14:58
--
local fightRes = {
    normal   =  "#arena_exchange_btn.png",
    pressed  =  "#arena_exchange_btn_gray.png",
    disabled =  "#arena_exchange_btn_gray.png"
}

local BiwuDuihuanItem = class("BiwuDuihuanItem", function()
    return CCTableViewCell:new()
end)

function BiwuDuihuanItem:create(param)
    
	--初始化界面
	self:setUpView(param)

    return self
end


function BiwuDuihuanItem:refresh(param)
	self._data = param.cellData
	self:removeAllChildren()
    local padding = { 
		left  = 20,
		right = 20,
		top   = 20,
		down  = 20
	}

	local viewSize = param.viewSize
	local listener = param.listener
	local index = param.index

	--外边大的背景框
	self:setContentSize(param.viewSize)
    local bng = display.newScale9Sprite("#arena_itemBg_4.png", 0, 0, 
                            		cc.size(viewSize.width,viewSize.height))
    bng:setAnchorPoint(cc.p(0,0))
    self:addChild(bng)
    
    --内容背景框
    self:setContentSize(param.viewSize)
    local contentBng = display.newScale9Sprite("#arena_item_inner_bg.png", 0, 0, 
                            		cc.size(viewSize.width * 0.7,viewSize.height * 0.65))
    contentBng:setAnchorPoint(cc.p(0,1))
    contentBng:setPosition(cc.p(viewSize.width * 0.02,viewSize.height * 0.92))
    bng:addChild(contentBng)

    --星星标志 
    local starIcon = display.newSprite("#rongyu_icon.png")
    starIcon:setPosition(cc.p(bng:getContentSize().width * 0.05,bng:getContentSize().height * 0.14))
    bng:addChild(starIcon)	

    --荣誉值
    local nameDis = ui.newTTFLabel({text = "荣誉：", 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(110,0,0)})
    nameDis:setAnchorPoint(cc.p(0,0.5))
    nameDis:setPosition(bng:getContentSize().width * 0.09, 
    bng:getContentSize().height * 0.14)
    bng:addChild(nameDis)	

    --荣誉值
    local nameDis = ui.newTTFLabel({text = self._data.price, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(216,30,0)})
    nameDis:setAnchorPoint(cc.p(0,0.5))
    nameDis:setPosition(bng:getContentSize().width * 0.18, 
    bng:getContentSize().height * 0.14)
    bng:addChild(nameDis)

    --需要人物等级
    local levelDisIcon = ui.newTTFLabel({text = "需要人物等级：", 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(99,47,8)})
    levelDisIcon:setAnchorPoint(cc.p(0,0.5))
    levelDisIcon:setPosition(bng:getContentSize().width * 0.45, 
    bng:getContentSize().height * 0.14)
    bng:addChild(levelDisIcon)

    --需要任务等级
    local levelDis = ui.newTTFLabel({text = self._data.level, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(216,30,0)})
    levelDis:setAnchorPoint(cc.p(0,0.5))
    levelDis:setPosition(bng:getContentSize().width * 0.68, 
    bng:getContentSize().height * 0.14)
    bng:addChild(levelDis)		

    if game.player:getLevel() >= self._data.level then
    	levelDisIcon:setVisible(false)
    	levelDis:setVisible(false)
    end

    --奖励图标
    local icon = ResMgr.refreshIcon(
    {
        id = self._data.item, 
        resType = self._data.iconType, 
        iconNum = self._data.num, 
        isShowIconNum = false, 
        numLblSize = 22, 
        numLblColor = ccc3(0, 255, 0), 
        numLblOutColor = ccc3(0, 0, 0) 
    }) 
    icon:setPosition(contentBng:getContentSize().width * 0.02, contentBng:getContentSize().height * 0.92)
    icon:setAnchorPoint(cc.p(0,1))
    contentBng:addChild(icon)



    -- 名称
    local nameColor = ccc3(255, 255, 255) 
    if self._data.iconType == ResMgr.HERO then 
        nameColor = ResMgr.getHeroNameColor(self._data.item)
    elseif self._data.iconType == ResMgr.ITEM or self._data.iconType == ResMgr.EQUIP then 
        nameColor = ResMgr.getItemNameColor(self._data.item) 
    end 

    --内容标题
    local contentTitleDis = ui.newTTFLabel({text = self._data.name, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = nameColor})
    contentTitleDis:setAnchorPoint(cc.p(0,0.5))
    contentTitleDis:setPosition(contentBng:getContentSize().width * 0.25, 
    contentBng:getContentSize().height * 0.8)
    contentBng:addChild(contentTitleDis)	
    local tips = { 
    	"总共",
    	"本周",
    	"今日"
	}
    --剩余兑换次数
    local timeLiftDis = ui.newTTFLabel({text = string.format("（"..tips[self._data.type1].."可兑换%d次".."）",self._data.num1), 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 18,color = ccc3(6,129,18)})
    timeLiftDis:setPosition(contentBng:getContentSize().width * 0.95, 
    contentBng:getContentSize().height * 0.8)

    timeLiftDis:setAnchorPoint(cc.p(1,0.5))
    contentBng:addChild(timeLiftDis)

    --分割线 
    local diviver = display.newScale9Sprite("#fenge.png", 0, 0, 
                           cc.size(contentBng:getContentSize().width * 0.5, contentBng:getContentSize().height * 0.03))
   	diviver:setPosition(cc.p(contentBng:getContentSize().width * 0.25,contentBng:getContentSize().height * 0.7))
   	diviver:setAnchorPoint(cc.p(0,0))
   	contentBng:addChild(diviver)

    --内容描述
    local text = self._data.dis
    local contentDis = CCLabelTTF:create(text, FONTS_NAME.font_fzcy, 20,
        cc.size(contentBng:getContentSize().width * 0.7,contentBng:getContentSize().height * 0.65), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    contentDis:setColor(ccc3(99,47,8))
    
    contentDis:setPosition(contentBng:getContentSize().width * 0.25, 
    contentBng:getContentSize().height * 0.35)
    contentDis:setAnchorPoint(cc.p(0,0.5))
    contentBng:addChild(contentDis)	


    --标题背景
    
    local titleBng = display.newScale9Sprite("#arena_name_bg_4.png", 0, 0, 
                            		cc.size(viewSize.width - padding.left - padding.right , viewSize.height * 0.18))
    titleBng:setAnchorPoint(cc.p(0,0))
    titleBng:setPosition(cc.p(viewSize.width * 0.02, viewSize.height * 0.7))
    bng:addChild(titleBng)
    titleBng:setVisible(false)

    --角色名字
    local nameDis = ui.newTTFLabel({text = self._data.name, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(0,219,52)})
    nameDis:setAnchorPoint(cc.p(0,0.5))
    nameDis:setPosition(titleBng:getContentSize().width * 0.4, 
    titleBng:getContentSize().height * 0.5)
    titleBng:addChild(nameDis)


    --总共可兑换次数
    local fightDis = ui.newTTFLabel({text = string.format("（"..tips[self._data.type1].."可兑换%d次".."）",self._data.num1), 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(0,219,52)})
    fightDis:setAnchorPoint(cc.p(0,0.5))
    fightDis:setPosition(titleBng:getContentSize().width * 0.95, 
    titleBng:getContentSize().height * 0.5)
    titleBng:addChild(fightDis)



    --背景箭头
    local arrowBng = display.newSprite("#arena_lv_bg_4.png")
    arrowBng:setAnchorPoint(cc.p(0,0))
    titleBng:addChild(arrowBng)

    --等级限制
    local levelDis = ui.newTTFLabel({text = "LV:"..self._data.level, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(0,219,52)})
    levelDis:setAnchorPoint(cc.p(0,0.5))
    levelDis:setPosition(arrowBng:getContentSize().width * 0.2, 
    arrowBng:getContentSize().height * 0.5)
    arrowBng:addChild(levelDis)


    --头像大背景
    local heroBng = display.newScale9Sprite("#arena_itemInner_bg_1.png", 0, 0, 
                            		cc.size(viewSize.width * 0.7 , 
                            				viewSize.height * 0.65 ))
    heroBng:setVisible(false)
    heroBng:setAnchorPoint(cc.p(0,0))
    heroBng:setPosition(cc.p(viewSize.width * 0.01, viewSize.height * 0.05))
    bng:addChild(heroBng)

	addTouchListener(icon, function (sender,eventType)
    	if eventType == EventType.ended then
    		local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = self._data.item, 
                        type = self._data.type, 
                        name = self._data.name, 
                        describe = self._data.dis
                        })

        	CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
    	end
    end)

	local tag
    -- 装备碎片
    if self._data.type == 3 then
    	tag = display.newSprite("#sx_suipian.png")
    elseif self._data.type == 5 then
    	-- 残魂(武将碎片)
    	tag = display.newSprite("#sx_canhun.png")
    end
    if tag then
    	icon:addChild(tag)
    	tag:setRotation(-20)
    	tag:setPosition(cc.p(30,75))
    end
	

    --兑换按钮
    local jiangliBnt = display.newSprite(fightRes.normal)
    jiangliBnt:setPosition(cc.p(viewSize.width * 0.85, viewSize.height * 0.5))
    bng:addChild(jiangliBnt)   
    addTouchListener(jiangliBnt, function(sender,eventType)
    	print(eventType)

    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            if(game.player:getLevel() < self._data.level) then
                show_tip_label(data_error_error[1600].prompt)
            else
                if listener then
                    listener(index)
                end
            end

            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)
end

function BiwuDuihuanItem:setUpView(param)
	self:refresh(param)
    
end

function BiwuDuihuanItem:createHeroView(index,node)
	local i = index
    local marginTop  = 10
    local marginLeft = 10
    local offset = 100
    local icon = ResMgr.refreshIcon(
    {
        id = 1, 
        resType = 3, 
        iconNum = 11, 
        isShowIconNum = true, 
        numLblSize = 22, 
        numLblColor = ccc3(0, 255, 0), 
        numLblOutColor = ccc3(0, 0, 0) 
    }) 
    icon:setAnchorPoint(cc.p(0,0.5)) 
    icon:setPosition((node:getContentSize().width / 5) * (i), node:getContentSize().height/2)
    icon:setAnchorPoint(cc.p(0.5,0.5))
    node:addChild(icon)
    return icon
end

function BiwuDuihuanItem:refreshHeroIcons()
	
end

return BiwuDuihuanItem

