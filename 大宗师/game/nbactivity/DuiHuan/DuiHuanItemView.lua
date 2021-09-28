--
-- Author: Daneil
-- Date: 2015-01-15 22:14:24
--
local COLOR_GREEN = ccc3(0, 255, 0) 
local data_item_item = require("data.data_item_item")
local DuiHuanItemView = class("DuiHuanItemView", function()
    return CCTableViewCell:new()
end)

function DuiHuanItemView:create(param)
    
	--初始化界面

	
	self:setUpView(param)

    return self
end

function DuiHuanItemView:setUpView(param)
	self:refresh(param)
end

function DuiHuanItemView:refresh(param)
	self.isEnough = true
	self:removeAllChildren()
	local data = param.data
	local type = #data.exchExp.exchItem
	--背景框
    local mainFrameBng = display.newScale9Sprite("#month_item_bg.png", 0, 0, 
                        cc.size(param.viewSize.width * 0.96,param.viewSize.height * 0.93))
    mainFrameBng:setAnchorPoint(cc.p(0.5,0.5))
    mainFrameBng:setPosition(cc.p(param.viewSize.width / 2 , param.viewSize.height / 2 - 10))
    self:addChild(mainFrameBng)

    local mainFrameBngSize = mainFrameBng:getContentSize()
    local titleBng = display.newSprite("#month_item_titleBg.png")
	titleBng:setAnchorPoint(cc.p(0.5,0.5))
	titleBng:setPosition(cc.p(mainFrameBngSize.width * 0.24, mainFrameBngSize.height))
	mainFrameBng:addChild(titleBng)

	
	local nameLabel = ui.newBMFontLabel({
		text = data.tagName,
		font = "fonts/font_title.fnt",
		align = ui.TEXT_ALIGN_LEFT
		})
	nameLabel:setPosition(cc.p(titleBng:getContentSize().width * 0.3,titleBng:getContentSize().height - 30))
	titleBng:addChild(nameLabel)


	
    --描述
    local disLabel = ui.newTTFLabel({text = "可兑换次数:", 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(99,47,8)})
    disLabel:setAnchorPoint(cc.p(0,0.5))
    disLabel:setPosition(cc.p(mainFrameBngSize.width * 0.065, mainFrameBngSize.height - 45))
    mainFrameBng:addChild(disLabel)

    disLabel:setString(data.exchType == 1 and "今日可兑换次数" or "可兑换次数")

    --描述value
    local disValueLabel = ui.newTTFLabel({text = "("..(data.totalNum - data.exchNum).."/"..data.totalNum..")", 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(6,129,18)})
    disValueLabel:setAnchorPoint(cc.p(0,0.5))
    disValueLabel:setPosition(cc.p(disLabel:getPositionX() + disLabel:getContentSize().width + 10, mainFrameBngSize.height - 45))
    mainFrameBng:addChild(disValueLabel)


    local shuaxinBtn = display.newSprite("#shuaxin_n.png")
	shuaxinBtn:setPosition(cc.p(mainFrameBng:getContentSize().width * 0.2,50))
	local duihuanBtn = display.newSprite("#duihuan_n.png")
	duihuanBtn:setPosition(cc.p(mainFrameBng:getContentSize().width * 0.8,50))
	mainFrameBng:addChild(shuaxinBtn)
	mainFrameBng:addChild(duihuanBtn)

	--兑换按钮
	local priceLabel = ui.newTTFLabelWithShadow({
		            text = data.refGold,
		            size = 22, 
		            color = ccc3(255,210,0),
		            shadowColor = ccc3(0,0,0),
		            font = FONTS_NAME.font_fzcy,
		            align = ui.TEXT_ALIGN_LEFT
		        }) 	

	priceLabel:setPosition(cc.p(shuaxinBtn:getContentSize().width * 0.7,shuaxinBtn:getContentSize().height * 0.5))
	shuaxinBtn:addChild(priceLabel)

	if data.isRefresh == 0 then
        priceLabel:setVisible(false)
        shuaxinBtn:setVisible(false)
    end

    
    addTouchListener(shuaxinBtn, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            if data.isRefresh == 0 then
            	show_tip_label("不可刷新")
            	return
            end
           	if param.refreshFunc then
           		param.refreshFunc(param.index,data.id)	
           	end
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    addTouchListener(duihuanBtn, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            print(tostring(self.isEnough))
            if not self.isEnough then
            	show_tip_label("材料不足")
            	return
            end
            if param.exChangeFunc then
           		param.exChangeFunc(param.index,data.id)	
           	end
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    if data.exchNum == 0 then
        duihuanBtn:setDisplayFrame(display.newSprite("#duihuan_p.png"):getDisplayFrame())  
        shuaxinBtn:setDisplayFrame(display.newSprite("#shuaxin_p.png"):getDisplayFrame()) 
        duihuanBtn:setTouchEnabled(false) 
        shuaxinBtn:setTouchEnabled(false) 
    else
        duihuanBtn:setDisplayFrame(display.newSprite("#duihuan_n.png"):getDisplayFrame())  
        shuaxinBtn:setDisplayFrame(display.newSprite("#shuaxin_n.png"):getDisplayFrame())
        duihuanBtn:setTouchEnabled(true) 
        shuaxinBtn:setTouchEnabled(true) 
    end



    --背景框
    local innerFrame = display.newScale9Sprite("#month_item_innerBg.png", 0, 0, 
                        cc.size(mainFrameBng:getContentSize().width * 0.9,mainFrameBng:getContentSize().height * 0.6))
    innerFrame:setAnchorPoint(cc.p(0.5,0))
    innerFrame:setPosition(cc.p(mainFrameBng:getContentSize().width * 0.5,90))
    mainFrameBng:addChild(innerFrame)

    if type == 3 then
    	innerFrame:setContentSize(cc.size(mainFrameBng:getContentSize().width * 0.9,160))
    else
    	innerFrame:setContentSize(cc.size(mainFrameBng:getContentSize().width * 0.9,280))
    end




    local innerFrameSize = innerFrame:getContentSize()

    local addIcon = display.newSprite("#add.png")
    addIcon:setPosition(cc.p(innerFrameSize.width * 0.245,innerFrameSize.height * 0.55))
    innerFrame:addChild(addIcon)

    local addIcon = display.newSprite("#add.png")
    addIcon:setPosition(cc.p(innerFrameSize.width * 0.495,innerFrameSize.height * 0.55))
    innerFrame:addChild(addIcon)

    local equireIcon = display.newSprite("#denghao.png")
    equireIcon:setPosition(cc.p(innerFrameSize.width * 0.745,innerFrameSize.height * 0.55))
    innerFrame:addChild(equireIcon)

    


    self.constPos = {
    	{ x = innerFrameSize.width * 0.12, y = innerFrameSize.height * 0.8},
    	{ x = innerFrameSize.width * 0.12, y = innerFrameSize.height * 0.55},
    	{ x = innerFrameSize.width * 0.12, y = innerFrameSize.height * 0.3},
    	{ x = innerFrameSize.width * 0.37,y = innerFrameSize.height * 0.8},
    	{ x = innerFrameSize.width * 0.37,y = innerFrameSize.height * 0.55},
    	{ x = innerFrameSize.width * 0.37,y = innerFrameSize.height * 0.3},
    	{ x = innerFrameSize.width * 0.62, y = innerFrameSize.height * 0.8},
    	{ x = innerFrameSize.width * 0.62, y = innerFrameSize.height * 0.55},
    	{ x = innerFrameSize.width * 0.62, y = innerFrameSize.height * 0.3},
    	{ x = innerFrameSize.width * 0.87,y = innerFrameSize.height * 0.55},

	}

	
    self.type3 = {2,5,8,10}
    self.type4 = {2,4,6,8,10}
    self.type5 = {1,3,5,7,9,10}
    self._icons = {}
    for k,v in pairs(self["type"..type]) do
    	if k == #self["type"..type] then
    		table.insert(self._icons,self:createItemView(v,innerFrame,data.exchExp.exchRst[1]))
    	else
			table.insert(self._icons,self:createItemView(v,innerFrame,data.exchExp.exchItem[k]))
    	end
    end

    self._typedata = self["type"..type]
    self._dataTemp = data
end

function DuiHuanItemView:getItemData(index)
	if index == #self:getData() then
		return self._dataTemp.exchExp.exchRst[1]
	else
		return self._dataTemp.exchExp.exchItem[index]
	end
end

function DuiHuanItemView:getData()
	return self._typedata
end

function DuiHuanItemView:getIcon(index)
	return self._icons[index]
end

function DuiHuanItemView:createItemView(index,node,data)
    local marginTop  = 10
    local marginLeft = 10
    local offset = 100
    local icon
	if data.type == 6 then
    	local iconSp = require("game.Spirit.SpiritIcon").new({
            resId = data.id,
            bShowName = true,
    	})
    	node:addChild(iconSp)
    	iconSp:setAnchorPoint(cc.p(0,0.5)) 
    	iconSp:setPosition(cc.p(self.constPos[index].x - 50,self.constPos[index].y - 10))
		return iconSp
    else
    	icon = ResMgr.refreshIcon(
	    {
	        id = data.id, 
	        resType = ResMgr.getResType(data.type)
	    }) 
	    icon:setAnchorPoint(cc.p(0,0.5)) 
	    icon:setPosition(cc.p(self.constPos[index].x,self.constPos[index].y))
	    icon:setAnchorPoint(cc.p(0.5,0.5))
    	node:addChild(icon)

    end
    -- 名称
    local nameColor = ccc3(255, 255, 255) 
    if ResMgr.getResType(data.type) == ResMgr.HERO then 
        nameColor = ResMgr.getHeroNameColor(tonumber(data.id))
    elseif ResMgr.getResType(data.type) == ResMgr.ITEM or ResMgr.getResType(data.type) == ResMgr.EQUIP then 
        nameColor = ResMgr.getItemNameColor(tonumber(data.id)) 
    end 

    --[[addTouchListener(icon, function (sender,eventType)
    	if eventType == EventType.ended then
    		local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = data.id, 
                        type = data.type, 
                        name = data_item_item[data.id].name, 
                        describe = data_item_item[data.id].dis
                        })

        	CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
    	end
    end)--]]

    ui.newTTFLabelWithShadow({
        text = data_item_item[data.id].name,
        size = 20,
        color = nameColor,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER
    	})
        :pos(icon:getContentSize().width /2 , -15)
        :addTo(icon)
        :setAnchorPoint(cc.p(0,1))
	local tag
    -- 装备碎片
    if data.type == 3 then
        tag = display.newSprite("#sx_suipian.png")
    elseif data.type == 5 then
        -- 残魂(武将碎片)
        tag = display.newSprite("#sx_canhun.png")
    end
    if tag then
        icon:addChild(tag)
        tag:setRotation(-20)
        tag:setPosition(cc.p(40,75))
    end

    local hasNum = CCLabelTTF:create(data.had, FONTS_NAME.font_fzcy, 20,
        								cc.size(0,0),
         								kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    local need = CCLabelTTF:create("/"..data.num, FONTS_NAME.font_fzcy, 20,
        								cc.size(0,0),
         								kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)

	hasNum:setColor(COLOR_GREEN)
	need:setColor(COLOR_GREEN)

	if data.had >= data.num then
		hasNum:setColor(COLOR_GREEN)
	else
		hasNum:setColor(FONT_COLOR.RED)
		if index ~= 10 then
			self.isEnough = false
		end
	end 

	need:setPosition(icon:getContentSize().width - 5 - need:getContentSize().width/2, 
							need:getContentSize().height/2 + 7)

	hasNum:setPosition(need:getPositionX() - need:getContentSize().width/2 - hasNum:getContentSize().width/2,
	 								need:getPositionY())
	if data.type ~= 6 then
		if index ~= 10 then
			icon:addChild(need, 10)
			icon:addChild(hasNum, 10)
			if data.id <= 8 then
				need:setString(data.num)
				hasNum:setVisible(false)
			end
		end
	end
	
    return icon
end


return DuiHuanItemView

