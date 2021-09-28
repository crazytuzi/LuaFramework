--
-- Author: Daneil
-- Date: 2015-01-15 22:14:24
--
local fightRes = {
    normal   =  "#fuchou_n.png",
    pressed  =  "#fuchou_p.png",
    disabled =  "#fuchou_p.png"
}
local levelRes = { 
	{frame = "#arena_itemBg_1.png",arrowBng = "#arena_lv_bg_1.png",titleBng = "#arena_name_bg_1.png",contentBng = "#arena_itemInner_bg_1.png",rank = "#arena_mark_1.png"},
	{frame = "#arena_itemBg_2.png",arrowBng = "#arena_lv_bg_2.png",titleBng = "#arena_name_bg_2.png",contentBng = "#arena_itemInner_bg_2.png",rank = "#arena_mark_2.png"},
	{frame = "#arena_itemBg_3.png",arrowBng = "#arena_lv_bg_3.png",titleBng = "#arena_name_bg_3.png",contentBng = "#arena_itemInner_bg_3.png",rank = "#arena_mark_3.png"}
	
}

local defaut = { 
	frame = "#arena_itemBg_5.png",
	arrowBng = "#arena_lv_bg_4.png",
	titleBng = "#arena_name_bg_5.png",
	contentBng = "#arena_itemInner_bg_1.png"
}

local BiwuTianbangItem = class("BiwuTianbangItem", function()
    return CCTableViewCell:new()
end)

function BiwuTianbangItem:create(param)
    
	--初始化界面
	self:setUpView(param)

    return self
end

function BiwuTianbangItem:setUpView(param)
	local padding = { 
		left  = 20,
		right = 20,
		top   = 20,
		down  = 20
	}
	self:refresh(param)
end

function BiwuTianbangItem:refresh(param)
	self:removeAllChildren()
	local data = param.data
	local padding = { 
		left  = 20,
		right = 20,
		top   = 20,
		down  = 20
	}

	self.viewSize = param.viewSize

	--外边大的背景框
	self:setContentSize(self.viewSize)
    self.bng = display.newScale9Sprite(data.rank <= 3 and levelRes[data.rank].frame or defaut.frame, 0, 0, 
                            		cc.size(self.viewSize.width,self.viewSize.height))
    self.bng:setAnchorPoint(cc.p(0,0))
    self:addChild(self.bng)

    --标题背景
    
    self.titleBng = display.newScale9Sprite(data.rank <= 3 and levelRes[data.rank].titleBng or defaut.titleBng, 0, 0, 
                            		cc.size(self.viewSize.width - padding.left - padding.right , self.viewSize.height * 0.15))
    self.titleBng:setAnchorPoint(cc.p(0,0))
    self.titleBng:setPosition(cc.p(self.viewSize.width * 0.02, self.viewSize.height * 0.75))
    self.bng:addChild(self.titleBng)

    --角色名字
    local nameDis = ui.newTTFLabel({text = data.name, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(92,38,1)})
    nameDis:setAnchorPoint(cc.p(0,0.5))
    nameDis:setPosition(self.titleBng:getContentSize().width * 0.23, 
    self.titleBng:getContentSize().height * 0.5)
    self.titleBng:addChild(nameDis)


    --帮派名称
    local fightDis = ui.newTTFLabel({text = "【"..data.faction.."】" ,
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(147,5,5)})
    fightDis:setAnchorPoint(cc.p(1,0.5))
    fightDis:setPosition(self.titleBng:getContentSize().width * 0.95, 
    self.titleBng:getContentSize().height * 0.5)
    self.titleBng:addChild(fightDis)

    if data.faction == "" then
    	fightDis:setVisible(false)
    end


    --背景箭头
    self.arrowBng = display.newSprite(data.rank <= 3 and levelRes[data.rank].arrowBng or defaut.arrowBng)
    self.arrowBng:setAnchorPoint(cc.p(0,0))
    self.titleBng:addChild(self.arrowBng)

    --排名
    if data.rank <= 3 then
    	self.rankTag = display.newSprite(levelRes[data.rank].rank)
    	self.rankTag:setAnchorPoint(cc.p(0,0))
    	self.rankTag:setPositionY(self.viewSize.height-70)
    	self.rankTag:setPositionX(20)
    	self.bng:addChild(self.rankTag,20)
    end
    

    --等级
    local levelDis = ui.newTTFLabel({text = "LV:"..data.level, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(255,255,255)})
    levelDis:setAnchorPoint(cc.p(0,0.5))
    levelDis:setPosition(self.arrowBng:getContentSize().width * 0.2 + 20, 
    self.arrowBng:getContentSize().height * 0.5)
    self.arrowBng:addChild(levelDis)


    --头像大背景
    self.heroBng = display.newScale9Sprite(data.rank <= 3 and levelRes[data.rank].contentBng or defaut.contentBng, 0, 0, 
                            		cc.size(self.viewSize.width * 0.7 , 
                            				self.viewSize.height * 0.55 ))
    self.heroBng:setAnchorPoint(cc.p(0,0))
    self.heroBng:setPosition(cc.p(self.viewSize.width * 0.01, self.viewSize.height * 0.2))
    self.bng:addChild(self.heroBng)


    for i = 1,#data.cards do
    	local head = self:createHeroView(i, self.heroBng,data.cards,data)
    end

    --排名
	ui.newTTFLabel({text = "排名："..data.rank, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(4,90,106)})
		:pos(self.viewSize.width * 0.85, self.viewSize.height * 0.6)
		:addTo(self.bng)

	local fightBtn = display.newSprite("#arena_challenge_btn.png")
    fightBtn:setPosition(self.viewSize.width * 0.85, self.viewSize.height * 0.3)
    self.bng:addChild(fightBtn)

	addTouchListener(fightBtn, function(sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
    		if param.rank < data.rank then
        		show_tip_label("不能挑战比自己积分低的人")
        		return
        	end
        	if param.roleid == data.role_id then
        		show_tip_label("不能挑战自己")
        		return
        	end
			if param.times == 0 then
        		show_tip_label("您的挑战次数为0")
        		return 
        	end
            fightBtn:setScale(1)
            BiwuController.sendFightData(BiwuConst.TIAOZHAN,data.role_id,TabIndex.TIANBANG)
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)


    fightBtn:setVisible(param.rank <= 20 and param.rank ~= 0)
    dump(data)
    --战力title
    display.newSprite("#friend_zhandouli.png")
    	:pos(self.viewSize.width * 0.1,self.viewSize.height * 0.15)
    	:addTo(self.bng)
	--战力数值
	ui.newTTFLabel({text = data.attack, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(216,30,0)})
		:pos(self.viewSize.width * 0.22,self.viewSize.height * 0.15)
		:addTo(self.bng)
    --积分title
    ui.newTTFLabel({text = "积分:", 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(147,5,5)})
		:pos(self.viewSize.width * 0.5,self.viewSize.height * 0.15)
		:addTo(self.bng)
	--积分数值
	ui.newTTFLabel({text = data.score, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(216,30,0)})
		:pos(self.viewSize.width * 0.6,self.viewSize.height * 0.15)
		:addTo(self.bng)


end

function BiwuTianbangItem:createHeroView(index,node,data,dataall)
	local i = index
    local marginTop  = 10
    local marginLeft = 10
    local offset = 100
    local icon = ResMgr.refreshIcon(
    {
        id = data[i].resId, 
        resType = ResMgr.HERO, 
        cls = data[i].cls
    }) 
    icon:setAnchorPoint(cc.p(0,0.5)) 
    icon:setPosition((node:getContentSize().width / 5) * (i) - 20 + 10 * (i-1), node:getContentSize().height/2)
    icon:setAnchorPoint(cc.p(0.5,0.5))
    node:addChild(icon)
    addTouchListener(icon, function (sender,eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1.0)
            icon:setScale(1.0)
            local guidName = ""
            if dataall.faction ~= "" then
    			guidName = " 【"..dataall.faction.."】"
    		end  
			local layer = require("game.form.EnemyFormLayer").new(1,dataall.acc,nil,guidName)
	        layer:setPosition(0, 0)
	        CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000000)
    	elseif eventType == EventType.cancel then
    		sender:setScale(1.0)
    	end
    end)
    return icon
end

function BiwuTianbangItem:refreshHeroIcons()
	
end

return BiwuTianbangItem

