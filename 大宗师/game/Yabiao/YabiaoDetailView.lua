--
-- Author: Daneil
-- Date: 2015-02-02 20:11:29
--
local data_item_item = require("data.data_item_item")
local btnCloseRes = {
	    normal   =  "#win_base_close.png",
	    pressed  =  "#win_base_close.png",
	    disabled =  "#win_base_close.png"
	}
local YabiaoDetailView = class("YabiaoDetailView", function()
    return display.newLayer("YabiaoDetailView")
end)

function YabiaoDetailView:ctor(param)
	self:loadRes()
	self._dartkey = param.dartkey
	self._roleId = param.roleId
	local func = function()
		self:setUpView(param)
	end
	self:_getData(func)
end

function YabiaoDetailView:setUpView(param)
	for k,v in pairs(param) do
		print(k,v)
	end

	local padding = { 
		left  = 30,
		right = 30,
		top   = 20,
		down  = 20
	}

	self:createMask()
	--背景
	local mainBng = display.newScale9Sprite("#win_base_bg2.png", 0, 0, 
                    	cc.size(display.width * 0.9 ,display.width * 0.9 * 0.8))
                    	:pos(display.cx,display.cy)
                    	:addTo(self)
    local mainBngSize = mainBng:getContentSize()
    local bng = display.newScale9Sprite("#win_base_inner_bg_light.png", 0, 0, 
                        cc.size(mainBngSize.width * 0.95,mainBngSize.height * 0.83))
                        :pos(mainBngSize.width/2,mainBngSize.height/2 - 25)
                        :addTo(mainBng)
    --title标签
    local titleText = ui.newBMFontLabel({
        				text = "信息", 
        				size = 22, 
        				align = ui.TEXT_ALIGN_CENTER , 
        				font = "res/fonts/font_title.fnt"})
        				:pos( mainBngSize.width * 0.5, 
         				mainBngSize.height * 0.97)
    titleText:setAnchorPoint(cc.p(0.5,1))
    mainBng:addChild(titleText)
    --关闭按钮
    local closeBtn = display.newSprite(btnCloseRes.normal)

    addTouchListener(closeBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
    		self:close()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)   
    
    closeBtn:pos(mainBngSize.width - 30, mainBngSize.height- 30)
    closeBtn:addTo(mainBng):setAnchorPoint(cc.p(0.5,0.5))
    local viewSize = bng:getContentSize()
	     


    local innerBng = display.newScale9Sprite("#heroinfo_prop_bg2.png", 0, 0, 
                            		cc.size(viewSize.width*0.95, viewSize.height * 0.5))
    innerBng:setAnchorPoint(cc.p(0.5,0.5))
    innerBng:setPosition(cc.p(viewSize.width * 0.5, viewSize.height * 0.70))
    bng:addChild(innerBng)




    --标题背景
    
    local titleBng = display.newScale9Sprite("#arena_name_bg_4.png", 0, 0, 
                            		cc.size(viewSize.width - padding.left - padding.right , viewSize.height * 0.09))
    titleBng:setAnchorPoint(cc.p(0.5,0.5))
    titleBng:setPosition(cc.p(viewSize.width * 0.5, viewSize.height * 0.87))
    bng:addChild(titleBng)

    --角色名字
    local nameDis = ui.newTTFLabel({text = self.data.name, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(110,0,0)})
    nameDis:setAnchorPoint(cc.p(0,0.5))
    nameDis:setPosition(titleBng:getContentSize().width * 0.28, 
    titleBng:getContentSize().height * 0.5)
    titleBng:addChild(nameDis)



    --战力title
    local fightBng = display.newSprite("#zhanli.png")
    	:pos(titleBng:getContentSize().width, 
    	titleBng:getContentSize().height * 0.5)
   	fightBng:setAnchorPoint(cc.p(1,0.5))
   	titleBng:addChild(fightBng)

	--战力数值
	ui.newTTFLabel({text = self.data.attack, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(255,185,49)})
		:pos(titleBng:getContentSize().width * 0.90, 
    	titleBng:getContentSize().height * 0.5)
		:addTo(titleBng)


    --背景箭头
    local arrowBng = display.newSprite("#arena_lv_bg_4.png")
    arrowBng:setAnchorPoint(cc.p(0,0))
    titleBng:addChild(arrowBng)

    --等级
    local levelDis = ui.newTTFLabel({text = "LV:"..self.data.lv, 
    	font = FONTS_NAME.font_fzcy, 
    	align = ui.TEXT_ALIGN_LEFT,
        size = 22,color = ccc3(255,255,255)})
    levelDis:setAnchorPoint(cc.p(0,0.5))
    levelDis:setPosition(arrowBng:getContentSize().width * 0.2, 
    arrowBng:getContentSize().height * 0.5)
    arrowBng:addChild(levelDis)

    --头像大背景
    local heroBng = display.newScale9Sprite("#arena_itemInner_bg_1.png", 0, 0, 
                            		cc.size(viewSize.width * 0.9 , 
                            				viewSize.height * 0.35 ))
    heroBng:setAnchorPoint(cc.p(0.5,0.5))
    heroBng:setPosition(cc.p(viewSize.width * 0.5, viewSize.height * 0.65))
    bng:addChild(heroBng)


    for i = 1,#self.data.cardData do
    	local head = self:createHeroView(i, heroBng)
    end

    local cardName = {
    	"绿色镖车",
    	"蓝色镖车",
    	"紫色镖车",
    	"金色镖车"
	}

    local yasongTitle = ui.newTTFLabelWithOutline({  text = "押送:", 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = FONT_COLOR.WHITE,
									        outlineColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })
    local yasongValue = ui.newTTFLabelWithOutline({  text = cardName[self.data.quality], 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = ccc3(252,28,255),
									        outlineColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })
	local yinbiTitle = ui.newTTFLabelWithOutline({  text = data_item_item[self.data.getCoin[1].id].name, 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = FONT_COLOR.WHITE,
									        outlineColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })
	local yinbiValue = ui.newTTFLabelWithOutline({  text = self.data.getCoin[1].num, 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = ccc3(0,216,219),
									        outlineColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })
	local shengwangTitle = ui.newTTFLabelWithOutline({  text = data_item_item[self.data.getCoin[2].id].name, 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = FONT_COLOR.WHITE,
									        outlineColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })
	local shengwangValue = ui.newTTFLabelWithOutline({ text = self.data.getCoin[2].num, 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = ccc3(252,28,255),
									        outlineColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })
	local qiangduoTitle = ui.newTTFLabelWithOutline({  text = "被抢夺次数:", 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = FONT_COLOR.WHITE,
									        outlineColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })
	local qiangduoValue = ui.newTTFLabelWithOutline({  text = self.data.beRobTimes, 
											size = 22, 
									        align= ui.TEXT_ALIGN_CENTE,
									        color = ccc3(252,28,255),
									        outlineColor = ccc3(0,0,0),
									        font = FONTS_NAME.font_fzcy })

	yasongTitle:setPosition(cc.p(bng:getContentSize().width * 0.05,bng:getContentSize().height * 0.40))
	yinbiTitle:setPosition(cc.p(bng:getContentSize().width * 0.45,bng:getContentSize().height * 0.40))
	shengwangTitle:setPosition(cc.p(bng:getContentSize().width * 0.77,bng:getContentSize().height * 0.40))
	qiangduoTitle:setPosition(cc.p(bng:getContentSize().width * 0.05,bng:getContentSize().height * 0.30))


	yasongValue:setPosition(cc.p(bng:getContentSize().width * 0.15,bng:getContentSize().height * 0.40))
	yinbiValue:setPosition(cc.p(bng:getContentSize().width * 0.55,bng:getContentSize().height * 0.40))
	shengwangValue:setPosition(cc.p(bng:getContentSize().width * 0.87,bng:getContentSize().height * 0.40))
	qiangduoValue:setPosition(cc.p(bng:getContentSize().width * 0.3,bng:getContentSize().height * 0.30))


	bng:addChild(yasongTitle)
	bng:addChild(yinbiTitle)
	bng:addChild(shengwangTitle)
	bng:addChild(yasongValue)
	bng:addChild(yinbiValue)
	bng:addChild(shengwangValue)
	bng:addChild(qiangduoTitle)
	bng:addChild(qiangduoValue)


	--按钮
	local qiangduoBtn = display.newSprite("#qiangduo.png")
	qiangduoBtn:setPosition(cc.p(bng:getContentSize().width * 0.2,bng:getContentSize().height * 0.15))
	local likaiBtn = display.newSprite("#likai.png")
	likaiBtn:setPosition(cc.p(bng:getContentSize().width * 0.8,bng:getContentSize().height * 0.15))
	local guanbiBtn = display.newSprite("#likai.png")
	guanbiBtn:setPosition(cc.p(bng:getContentSize().width * 0.5,bng:getContentSize().height * 0.15))
	bng:addChild(qiangduoBtn)
	bng:addChild(likaiBtn)
	bng:addChild(guanbiBtn)


	addTouchListener(qiangduoBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            if self.data.beRobTimes >= 2 then
            	show_tip_label("这两飙车已经没什么油水了，放过他吧")
            	return
            end
            self:fight()
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    addTouchListener(likaiBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            self:close()
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    addTouchListener(guanbiBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
    		self:close()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

   	if param and param.type == 1 then
   		qiangduoBtn:setVisible(true)
		likaiBtn:setVisible(true)
		guanbiBtn:setVisible(false)
   	else
		qiangduoBtn:setVisible(false)
		likaiBtn:setVisible(false)
		guanbiBtn:setVisible(true)
   	end

end


function YabiaoDetailView:createHeroView(index,node)
	local i = index
    local marginTop  = 10
    local marginLeft = 10
    local offset = 100

	local icon = ResMgr.refreshIcon(
    {
        id = self.data.cardData[index].resId, 
        resType = ResMgr.HERO, 
        cls = self.data.cardData[index].cls
    }) 
    
    icon:setAnchorPoint(cc.p(0,0.5)) 
    icon:setPosition((node:getContentSize().width / 5) * (i)  - 20 + 10 * (i-1) , node:getContentSize().height/2)
    icon:setAnchorPoint(cc.p(0.5,0.5))
    node:addChild(icon)
    return icon
end

function YabiaoDetailView:loadRes()
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.addSpriteFramesWithFile("ui/ui_arena.plist", "ui/ui_arena.png")
	display.addSpriteFramesWithFile("ui/ui_xiakelu.plist", "ui/ui_xiakelu.png")
	display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")

end

function YabiaoDetailView:releaseRes()
	display.removeSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.removeSpriteFramesWithFile("ui/ui_arena.plist", "ui/ui_arena.png")
	display.removeSpriteFramesWithFile("ui/ui_xiakelu.plist", "ui/ui_xiakelu.png")
end

---
-- 创建蒙板
function YabiaoDetailView:createMask()
	local winSize = CCDirector:sharedDirector():getWinSize()
    local mask = CCLayerColor:create()
    mask:setContentSize(winSize)
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(150)
    mask:setAnchorPoint(cc.p(0,0))
    mask:setTouchEnabled(true)
    self:addChild(mask)
end

function YabiaoDetailView:close()
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
	self:releaseRes()
	self:removeFromParent()
end

function YabiaoDetailView:_getData(func)
	local function initData(data)
		self.data = data.dartData
		dump(self.data.cardData)
		dump(self.data.getCoin)
		func()
	end

	RequestHelper.yaBiaoSystem.getCarInfo({
				roleID = self._roleId,
				dartkey = self._dartkey,
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
end


function YabiaoDetailView:fight()
	RequestHelper.yaBiaoSystem.forceGetCar({
				otherID = self._roleId,
				dartkey = self._dartkey,
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        GameStateManager:ChangeState(GAME_STATE.STATE_YABIAO_BATTLE_SCENE,{data = data})
                    end
                end 
                })
end


return YabiaoDetailView



