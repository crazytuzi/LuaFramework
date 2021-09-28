 --[[
 --
 -- @authors shan 
 -- @date    2014-06-20 15:28:18
 -- @version 
 --
 --]]

local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")
local data_shake_shake = require("data.data_shake_shake")
local data_atk_number_time_time = require("data.data_atk_number_time_time")
local data_viplevel_viplevel = require("data.data_viplevel_viplevel")
local data_message_message = require("data.data_message_message")
local data_item_nature = require("data.data_item_nature")
require("data.data_error_error")
require("utility.MppUI")


local ccs = ccs or {}
ccs.MovementEventType = {
    START = 0,
    COMPLETE = 1,
    LOOP_COMPLETE = 2,
}

local ResMgr = {}
ResMgr.isShowCharName = false

--是否在进入小地图的信息界面
ResMgr.isInSubInfo = false

--是否在进入小地图界面里
ResMgr.intoSubMap = false

-- 战斗缩放的基数
ResMgr.TIME_SCALE_BASE_FACTOR = data_atk_number_time_time[1]["game_scale"]/1000 or 1

ResMgr.battleTimeScale = 1

function ResMgr.setTimeScale(scale)	
	CCDirector:sharedDirector():getScheduler():setTimeScale(scale*ResMgr.TIME_SCALE_BASE_FACTOR)
end

ResMgr.spriteFrameCntTable = {}

function ResMgr.addSpriteFramesWithFile(plistFilename, image)
	if ResMgr.spriteFrameCntTable[plistFilename] == nil then
		ResMgr.spriteFrameCntTable[plistFilename] = 0	
	end
	ResMgr.spriteFrameCntTable[plistFilename] = ResMgr.spriteFrameCntTable[plistFilename] + 1
	display.addSpriteFramesWithFile(plistFilename, image)

end

function ResMgr.removeSpriteFramesWithFile(plistFilename, image)
	if ResMgr.spriteFrameCntTable[plistFilename] ~= nil and ResMgr.spriteFrameCntTable[plistFilename] > 0 then
		ResMgr.spriteFrameCntTable[plistFilename] = ResMgr.spriteFrameCntTable[plistFilename] - 1

	end

	if ResMgr.spriteFrameCntTable[plistFilename] ~= nil and ResMgr.spriteFrameCntTable[plistFilename] == 0 then

		display.removeSpriteFramesWithFile(plistFilename, image)
	end	
end

function ResMgr:getPosInScene(node)
	local nodeCenterPos = ccp(node:getContentSize().width / 2, node:getContentSize().height / 2)
	local nodePos = node:convertToWorldSpace(nodeCenterPos)
	return nodePos
end

function ResMgr.flipCard(sprite,refreshFunc,curTime)
	local time = curTime or 0.2
	sprite:runAction(transition.sequence({
            CCScaleTo:create(time, 0.01, 1.0), 
            CCCallFuncN:create(refreshFunc),
            CCScaleTo:create(time, 1, 1.0)
        })) 

end

function ResMgr.runFuncByOpenCheck(param)
	local openKey  = param.openKey
	local openFunc = param.openFunc

	local bHasOpen, prompt = OpenCheck.getOpenLevelById(openKey, game.player:getLevel(), game.player:getVip()) 
	if not bHasOpen then 
		show_tip_label(prompt) 
	else
		if openFunc ~= nil then
			openFunc()
		end
	end 
end

ResMgr.SFX = "sfx"
ResMgr.BATTLE_SFX = "battlesfx"
ResMgr.SKILL_SFX = "skill"

function ResMgr.playSfx(sfxName,sfxDir)
	local path = "sound/"..sfxDir.."/"..sfxName..".mp3"
    GameAudio.playSound(path, false)   
end

function ResMgr.getMsg(id)
	local msg = data_message_message[id]
	return msg.text
end

function ResMgr.showMsg(id,delay)
	local msg = data_message_message[id]
	if msg ~= nil then
		local text = msg.text
		show_tip_label(text,delay)
	else
		show_tip_label("错误信息ID,ID为"..id)
	end
end

function ResMgr.showErr(id,str)
	local msgStr = str or ""
	local errMsg = data_error_error[id]
	if errMsg ~= nil then
		local text = errMsg.prompt
		show_tip_label(text..msgStr)
	else
		show_tip_label("错误信息ID,ID为"..id)
	end
end

function ResMgr.getNatureName(natureId)
	return data_item_nature[natureId].nature
end

-- 1：装备
-- 2：时装
-- 3：装备碎片
-- 4：内外功
-- 5：武将碎片
-- 6：精元
-- 7：可使用物品
-- 8：武将
-- 9：内功碎片
-- 10：外功碎片
-- 11：礼品
-- 12：材料

-- 1：装备    	
-- 2：时装    
-- 3：装备碎片    
-- 4：内外功    
-- 5：武将碎片    
-- 6：精元    	只有动画icon
-- 7：可使用物品  只有icon  
-- 8：礼品    	只有icon
-- 9：材料    	只有icon
-- 10：内功碎片	只有icon
-- 11：外功碎片	只有icon

ResMgr.HERO     = 1
ResMgr.EQUIP    = 2
ResMgr.ITEM     = 3
--[[
	根据名字跟type在不同路径下寻找资源
	type	1 人物
			2 武器装备
			3 背包物品
]]

ResMgr.UI_EFFECT = 4
ResMgr.NORMAL_EFFECT = 5
ResMgr.SPIRIT = 6
ResMgr.TEST_EFFECT = 7
--[[
	创建动画的类型， 用来规定在哪个路径下
]]

ResMgr.HERO_BG_BATTLE = 6
ResMgr.HERO_BG_UI = 7
ResMgr.ITEM_BG_UI = 8
--[[
	战斗中的侠客卡牌背景图
	UI中的侠客卡牌背景图
	UI中的物品卡牌背景图
]]

--竞技场，夺宝，论剑，的敌人的名字
ResMgr.oppName = ""


--icon's tag 
ResMgr.iconImage = 1
ResMgr.iconFrame = 2

ResMgr.isBottomEnabled = true


function ResMgr.getCardData(index)

	local cardData = data_card_card[index]
	if cardData.table == 0 then
		return cardData
	else
		local cardName = "data_"..cardData.table.."_card"
		local npcCard = require("data."..cardName)
		return npcCard[index]
		-- return loadstring(string.format("return %s[%d]", cardName, index))()
	end
end

function ResMgr.getIconSprite(param)
	local id = param.id
	local resType = param.resType
	local cls = param.cls or 0
    local star = param.star
	local hasCorner = param.hasCorner or false
    display.addSpriteFramesWithFile("ui/ui_icon_frame.plist", "ui/ui_icon_frame.png")

	local path = ""
	local _data = {}

	local itemStar = 1
	local cardData = nil
	if(resType == ResMgr.HERO) then
		path     = "hero"
		cardData = ResMgr.getCardData(id)
		itemStar = star or cardData.star[1]
	elseif(resType == ResMgr.EQUIP) then
		path  = "equip"
		_data = data_item_item
		itemStar = star or _data[id].quality
	elseif(resType == ResMgr.ITEM) then
		path = "items"
		_data = data_item_item
		itemStar = star or _data[id].quality
	end

	if (resType == ResMgr.HERO) then
		--传过来的CLS最少为0，而这里查询最小为1
		path = path .. "/icon/"..cardData["arr_icon"][cls+1]..".png"
	else
		--cls
		path = path .. "/icon/".._data[id].icon..".png"
	end

	local itemBg = display.newSprite(string.format("#icon_frame_bg_%d.png", itemStar))
	local item = display.newSprite(path)
	local itemFrame = display.newSprite(string.format("#icon_frame_board_%d.png", itemStar))

	item:setTag(ResMgr.iconImage)
	itemFrame:setTag(ResMgr.iconFrame)

	itemBg:addChild(item)
	item:setPosition(itemBg:getContentSize().width/2, itemBg:getContentSize().height/2)
	itemBg:addChild(itemFrame)
	itemFrame:setPosition(itemBg:getContentSize().width/2, itemBg:getContentSize().height/2)

	if(hasCorner == true) then
		local itemCorner = display.newSprite(string.format("#icon_corner_%d.png", itemStar))
		itemCorner:setPosition(itemCorner:getContentSize().width/2, itemFrame:getContentSize().height- itemCorner:getContentSize().height/2)
		itemFrame:addChild(itemCorner)
	end

	return itemBg
end

function ResMgr.createMaskLayer(node)
	local trueColor = ccc4(0, 0, 0, 0)
	if GAME_DEBUG == true and  SHOW_MASK_LAYER == true then
		trueColor = ccc4(0, 100, 0, 100)
	end

	if ResMgr.greenLayer == nil then
		ResMgr.greenLayer = require("utility.MaskLayer").new({color = trueColor,notice =NoticeKey.REMOVE_MASKLAYER})
		ResMgr.greenLayer:retain()
	end

	if ResMgr.greenLayer:getParent() ~= nil then
		ResMgr.greenLayer:removeSelf()
	end

	if node == nil then
		display.getRunningScene():addChild(ResMgr.greenLayer,MASK_LAYER_ZORDER)
	else
		node:addChild(ResMgr.greenLayer,MASK_LAYER_ZORDER)
	end
end

function ResMgr.removeTutoMask()
	-- body
	if ResMgr.blueLayer ~= nil then
		if ResMgr.blueLayer:getParent() ~= nil then
			ResMgr.blueLayer:removeSelf()
		end
		if ResMgr.blueLayer ~= nil then
			ResMgr.blueLayer:release()
		end
		
	end
	ResMgr.blueLayer = nil 
end

function ResMgr.setControlBtnEvent(btn,func,sound,maxInterval)
	
	btn.lastPressTime = 0
	local maxInter = maxInterval or 0.4 --0.4秒默认间隔
	btn:addHandleOfControlEvent(function()
		local curTime = GameModel.getLocalTimeInSec()
		if curTime - btn.lastPressTime < maxInter then
			return
		end
		btn.lastPressTime = curTime
		
		if func ~= nil then
        	func()
        end

        if sound == nil then
        	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        else
        	if sound ~= "" then
	        	GameAudio.playSound(ResMgr.getSFX(sound))
	        end
        end
    end, CCControlEventTouchUpInside)

end


function ResMgr.setNodeEvent(param)
	local curNode = param.node
	--用来处理tableview中的按钮,当按钮拖出可视范围时，使按钮无效
	local tableViewRect = param.tableViewRect
	local touchFunc = param.touchFunc
	local isMoved = false

	curNode.lastPressTime = 0
	local maxInter = param.maxInterval or 0.15
	
	curNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)

        dump(event)
	    local touchPos =  ccp(event.x,event.y)
	    local isInViewBg 
	    if tableViewRect == nil then --如果没传 说明不是在tableview或者scrollview里
	    	isInViewBg = true
	    else
	   		isInViewBg =  tableViewRect:containsPoint(touchPos)
	   	end
	    if isInViewBg == true then
	        if event.name == "began" then
	        	local curTime = os.clock()
	        	if curTime - curNode.lastPressTime < maxInter then	        		
	        		return true
	        	end
	        	curNode.lastPressTime = curTime
	        	isMoved = false
	            -- curNode:setTouchEnabled(false)
	            return true
	        elseif event.name == "moved" then
	            if math.abs(event.y - event.prevY) > 10 or  math.abs(event.x - event.prevX) > 10 then
	               isMoved = true
	            end
	        elseif event.name == "ended" then                        
	            ResMgr.delayFunc(1,function()
	                -- curNode:setTouchEnabled(true)
	                isMoved = false
	                end, self)
	            if isMoved ~= true then
	            	if touchFunc ~= nil then
	            		touchFunc()
                    end
	            end
            end
	    end
	end)

end

function ResMgr.createTutoMask(node)

	local trueColor = ccc4(0, 0, 0, 0)
	if GAME_DEBUG == true and  SHOW_MASK_LAYER == true then
		trueColor = ccc4(0, 100, 100, 100)
	end

	ResMgr.blueLayer = require("utility.SimpleColorLayer").new(trueColor)
	ResMgr.blueLayer:setTouchSwallowEnabled(true)
	ResMgr.blueLayer:retain()

	if node == nil then

		display.getRunningScene():addChild(ResMgr.blueLayer,TUTO_MASK_ZORDER)
	else
		node:addChild(ResMgr.blueLayer,TUTO_MASK_ZORDER)
	end
end

function ResMgr.getArrangedNode(rowTable)
	local arrNode = display.newNode()

	local rowWidth = 0
	for i = 1, #rowTable do
		rowWidth = rowWidth + rowTable[i]:getContentSize().width
	end

    local posX = 0
	for i = 1,#rowTable do
		if(tolua.type(rowTable[i]) == "CCLabelBMFont") then
			rowTable[i]:setAnchorPoint(ccp(0,0.9))
		else
			rowTable[i]:setAnchorPoint(ccp(0,0.5))
 		end
		
--		if i == 1 then
--			rowTable[i]:setPosition(-rowWidth/2,rowTable[i]:getContentSize().height/2)
--		else
--			rowTable[i]:setPosition(rowTable[i-1]:getPositionX() + rowTable[i-1]:getContentSize().width,rowTable[i]:getContentSize().height/2)
--		end
        rowTable[i]:setPosition(posX, rowTable[i]:getContentSize().height / 2)
        posX = posX + rowTable[i]:getContentSize().width + 5
		arrNode:addChild(rowTable[i])
	end

	arrNode.rowWidth = rowWidth

	return arrNode
end

function ResMgr.createNomarlMsgTTF(param)
	local text = param.text or ""
	local color = param.color or ccc3(59, 4, 4)
	local size = param.size or 22

	local normalLabel = ui.newTTFLabel({
        text = text,
        color = color,
        size = size,
        font = FONTS_NAME.font_fzcy,        
        align = ui.TEXT_ALIGN_LEFT
    })
    
    return normalLabel
end

function ResMgr.createOutlineMsgTTF(param) 
	local text = param.text or ""

	local color = param.color or ccc3(255,255,255)
	local outlineColor = param.outlineColor or ccc3(0,0,0)

	local size = param.size or 22

	local shaTTF = ui.newTTFLabelWithOutline({
        text = text,
        size = size,
        color = color,
        outlineColor = outlineColor,
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
        })

	if param.parentNode ~= nil then 
		param.parentNode:removeAllChildren() 
		param.parentNode:addChild(shaTTF) 
	end 
	
	return shaTTF
end

function ResMgr.createShadowMsgTTF(param)
	local text = param.text or ""

	local color = param.color or ccc3(255,255,255)
	local shadowColor = param.shadowColor or ccc3(0,0,0)

	local size = param.size or 22

	local shaTTF = ui.newTTFLabelWithShadow({
        text = text,
        size = size,
        color = color,
        shadowColor = shadowColor,
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
        })

	if param.parentNode ~= nil then 
		param.parentNode:removeAllChildren() 
		param.parentNode:addChild(shaTTF) 
	end 
	
	return shaTTF
end

function ResMgr.getVipIconTTF()
	local vipLv = game.player.m_vip

	local vipIcon= display.newSprite("ui/new_btn/vip_icon.png")
	vipIcon:setAnchorPoint(ccp(0,0.5))

	local lvTTF = ui.newBMFontLabel({
	    text = "VIP"..vipLv, 
	    font = "fonts/font_vip.fnt" ,
	    align = ui.TEXT_ALIGN_LEFT
    })

    return vipIcon,lvTTF
end

function  ResMgr.removeBefLayer()
	print("removoeododobebe")
	-- if ResMgr.redMaskLayer ~= nil then
	-- 	ResMgr.redMaskLayer:removeSelf()
	-- 	-- ResMgr.redMaskLayer = nil
	-- end

	for i = 1,#ResMgr.befTutoTable do
		if ResMgr.befTutoTable[i]:getParent() ~= nil then
			ResMgr.befTutoTable[i]:removeSelf()
		end
		ResMgr.befTutoTable[i]:release()
	end
	ResMgr.befTutoTable = {}

end

ResMgr.befTutoTable = {}

function ResMgr.createBefTutoMask(node)
	print("createteetbefffuffu")

	local trueColor = ccc4(0, 0, 0, 0)
	if GAME_DEBUG == true and  SHOW_MASK_LAYER == true then
		trueColor = ccc4(100, 0, 0, 100)
	end

	local befTutoLayer = display.newColorLayer(trueColor)
	befTutoLayer:setTouchEnabled(true)
	befTutoLayer:retain()
	ResMgr.befTutoTable[#ResMgr.befTutoTable + 1] = befTutoLayer
	-- if ResMgr.redMaskLayer == nil then
	-- 	ResMgr.redMaskLayer = display.newColorLayer(trueColor)
	-- 	ResMgr.redMaskLayer:setTouchEnabled(true)
	-- 	ResMgr.redMaskLayer:retain()

	-- end

	-- if ResMgr.redMaskLayer:getParent() ~= nil then
	-- 	ResMgr.redMaskLayer:removeSelf()
	-- end


	-- if ResMgr.redMaskLayer == nil then

	-- 	 ResMgr.redMaskLayer = require("utility.MaskLayer").new({color = trueColor,notice = NoticeKey.REV_BEF_TUTO_MASK,removeTime = 5.5})
	-- 	 ResMgr.redMaskLayer:retain()
	-- end
	-- if ResMgr.redMaskLayer:getParent() ~= nil then
	-- 	ResMgr.redMaskLayer:removeSelf()
	-- end


	-- ResMgr.redMaskLayer:resetTime()
	if node == nil then
		display:getRunningScene():addChild(befTutoLayer,BEF_MASK_ZORDER)
	else
		node:addChild(befTutoLayer,BEF_MASK_ZORDER)
	end
	-- PostNotice(NoticeKey.LOCK_BOTTOM)
end

function ResMgr.removeMaskLayer()
	PostNotice(NoticeKey.REMOVE_MASKLAYER)
end

function ResMgr.createTouchLayer(node)
	print("toutoutotutu")
	local trueColor = ccc4(0, 0, 0, 0)
	if GAME_DEBUG == true and SHOW_MASK_LAYER == true then
		trueColor = ccc4(100, 0, 0, 100)
	end

	if ResMgr.touchLayer == nil then
		 ResMgr.touchLayer = require("utility.MaskLayer").new({color = trueColor})
		 ResMgr.touchLayer:retain()
	end
	if ResMgr.touchLayer:getParent() ~= nil then
		ResMgr.touchLayer:removeSelf()
	end

	if node == nil then
		display:getRunningScene():addChild(ResMgr.touchLayer,BEF_MASK_ZORDER)
	else
		node:addChild(ResMgr.touchLayer,BEF_MASK_ZORDER)
	end
end

function ResMgr.removeTouchLayer()
	ResMgr.touchLayer:removeSelf()
end



function ResMgr.createParticle(filename)
	local path = "ccs/particle/"..filename..".plist"
	local part = CCParticleSystemQuad:create(path)
	return part
end

function ResMgr.debugBanner(str)

	if GAME_DEBUG == true and SHOW_MASK_LAYER == true then
		local debugTip =require("utility.NormalBanner").new({tipContext = str,delayTime = 5})
	    debugTip:setPosition(display.width/2,display.height*0.7)
	    display:getRunningScene():addChild(debugTip,1000000)
	end
    
end

function ResMgr.isEnoughSilver(num)
	if num > game.player.m_silver then
		return false
	else
		return true
	end
end


function ResMgr.refreshMoneyIcon(param)
	
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")

	local itemBg = param.itemBg
	local moneyType = param.moneyType 
	local tempBg 

	if moneyType == 1 then 
		-- 元宝
		tempBg = display.newSprite("#icon_gold.png")
	elseif moneyType == 2 then 
		-- 银币
		tempBg = display.newSprite("#icon_lv_silver.png")
	elseif moneyType == 10 then 
		-- 魂玉 
		tempBg = display.newSprite("#icon_hunyu.png")
	end 

	if tempBg ~= nil then 
		itemBg:setDisplayFrame(tempBg:getDisplayFrame())
	end 
end

function ResMgr.refreshItemWithTagNumName(param)
	display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")
	local itemType = param.itemType
	local itemId = param.id
	local itemCls = param.cls
	local hasCorner = param.hasCorner
	local star = param.star
	local itemNum = param.itemNum or 1
	local isShowIconNum = param.isShowIconNum or 1

	local isGray = param.isGray or false

	local itemBg = param.itemBg
	local resType = param.resType
	local iconType  
	if resType == nil then
		iconType = ResMgr.getResType(param.itemType)
	else
		iconType = resType
	end

	itemBg.group = {}

	--创建icon
	ResMgr.refreshIcon({		
		id = itemId,
		resType = iconType,
		cls = itemCls,
		hasCorner = hasCorner,
		star = star,
		itemBg = itemBg,
		isGray = isGray
		})

	-- 属性图标
	local tagSprite 
	if itemType == 3 then --装备碎片
		tagSprite = display.newSprite("#sx_suipian.png") 
	elseif itemType == 5 then --残魂武将碎片
		tagSprite = display.newSprite("#sx_canhun.png") 
	end

	if tagSprite ~= nil then
		tagSprite:setScale(0.8)
		tagSprite:setPosition(itemBg:getContentSize().width*0.2,itemBg:getContentSize().height*0.9)
		tagSprite:setRotation(-20)
		itemBg:addChild(tagSprite)
		itemBg.group.tag = tagSprite
	end

	--名称
	local nameStr = ""

	if(iconType == ResMgr.HERO) then
		nameStr = ResMgr.getCardData(itemId).name
	elseif(iconType == ResMgr.EQUIP) then
		nameStr = data_item_item[itemId].name
	elseif(iconType == ResMgr.ITEM) then

		nameStr = data_item_item[itemId].name
	end

	local nameColor = ccc3(255, 255, 255)
	if iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then 
		nameColor = ResMgr.getItemNameColor(itemId)
	elseif iconType == ResMgr.HERO then 
		nameColor = ResMgr.getHeroNameColor(itemId)
	end

	if isGray == true then
		nameColor = ccc3(115,115,115)
	end

	local nameLbl = ui.newTTFLabelWithShadow({
        text = nameStr,
        size = 20,
        color = nameColor,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
        })
		
	nameLbl:setPosition(itemBg:getContentSize().width/2 -nameLbl:getContentSize().width/2, -nameLbl:getContentSize().height/2)

	
	local numTTF = ResMgr.createShadowMsgTTF({text = itemNum,color = ccc3(58,209,73),size = 22})
	numTTF:setAnchorPoint(ccp(1,0))
	numTTF:setPosition(itemBg:getContentSize().width-numTTF:getContentSize().width-10 ,itemBg:getContentSize().height*0.2)
	itemBg:addChild(numTTF)

	if isShowIconNum == 0 then
		numTTF:setVisible(false)
	end

	
	if nameLbl ~= nil then
		itemBg:addChild(nameLbl)
		itemBg.group.name = nameLbl
	end
	itemBg.getItem = function(name) 
		return itemBg.group[name]
	end
	itemBg.getGroup = function()
		return itemBg.group
	end

	
end

function ResMgr.getPlateItemIcon(id)
	local path = "items/icon/"..data_item_item[id].icon ..".png"
	local icon = display.newSprite(path)
	return icon
end


function ResMgr.refreshIcon(param)
	local FILETER_TAG = 10001
	local SUIT_ARMA_TAG = 10002


	local itemBg = param.itemBg
	local isReturn = false --如果是nil 则表示这个函数用来创建
	if itemBg == nil then
		isReturn = true
		itemBg = display.newSprite()
	end
	-- itemBg:removeAllChildren()
	local IMAGE_TAG = 1
	local FRAME_TAG = 2

	local id = param.id
	local cardData = nil--ResMgr.getCardData(id)
	local resType = param.resType
	local cls = param.cls or 0
	local hasCorner = param.hasCorner or false
    local star = param.star 
    -- icon的数量 
    local iconNum = param.iconNum or 0 
    -- icon的数量为1时是否显示 
    local isShowIconNum = param.isShowIconNum or false   
    local numLblSize = param.numLblSize or 22 
    local numLblColor = param.numLblColor or ccc3(0, 255, 0) 
    local numLblOutColor = param.numLblOutColor or ccc3(0, 0, 0) 

    local isGray = param.isGray
    local cleanTable = {}

	display.addSpriteFramesWithFile("ui/ui_icon_frame.plist", "ui/ui_icon_frame.png")

	local path = ""
	local _data = {}
	local itemStar = 1
	if(resType == ResMgr.HERO) then
		path = "hero"
		_data = ResMgr.getCardData(id)
		cardData = ResMgr.getCardData(id)
		itemStar = cardData.star[cls + 1]---star or cardData.star[1]
	elseif(resType == ResMgr.EQUIP) then
		path = "equip"
		_data = data_item_item
		itemStar = star or _data[id].quality
	elseif(resType == ResMgr.ITEM) then
		path = "items"
		_data = data_item_item
		itemStar = star or _data[id].quality
	end

	if (resType == ResMgr.HERO) then
		--传过来的CLS最少为0，而这里查询最小为1
		path = path .. "/icon/"..cardData["arr_icon"][cls+1]..".png"
	else
		--cls
		path = path .. "/icon/".._data[id].icon..".png"
	end

	local tempBg 

		tempBg = display.newSprite(string.format("#icon_frame_bg_%d.png", itemStar or 1))



	itemBg:setDisplayFrame(tempBg:getDisplayFrame())

	if isGray == true then
		local fileter = display.newGraySprite(string.format("#icon_frame_bg_%d.png", itemStar or 1),{0.4, 0.4, 0.4, 0.1})
		fileter:setPosition(itemBg:getContentSize().width/2,itemBg:getContentSize().height/2)
		itemBg:addChild(fileter)
		itemBg:removeChildByTag(FILETER_TAG, true)
		fileter:setTag(FILETER_TAG)

	end

	local item = itemBg:getChildByTag(IMAGE_TAG)
	if item == nil then
		if isGray == true then
			item = display.newGraySprite(path, {0.4, 0.4, 0.4, 0.1})
		else
			item = display.newSprite(path)
		end

        itemBg:addChild(item)
        item:setTag(IMAGE_TAG)
        item:setPosition(itemBg:getContentSize().width/2, itemBg:getContentSize().height/2)
	else
		local tempItem 

		if isGray == true then
			tempItem = display.newGraySprite(path, {0.4, 0.4, 0.4, 0.1})
			
		else
			tempItem = display.newSprite(path)
		end


        item:setDisplayFrame(tempItem:getDisplayFrame())
	end

	local itemFrame = itemBg:getChildByTag(FRAME_TAG)
	
	if itemFrame == nil then
		if isGray == true then
			itemFrame = display.newGraySprite(string.format("#icon_frame_board_%d.png", itemStar or 1), {0.4, 0.4, 0.4, 0.1})
		else
			itemFrame = display.newSprite(string.format("#icon_frame_board_%d.png", itemStar or 1))
		end 

		if itemFrame ~= nil then 
			itemBg:addChild(itemFrame)
			itemFrame:setTag(FRAME_TAG)
			itemFrame:setPosition(itemBg:getContentSize().width/2, itemBg:getContentSize().height/2)
		end
	else

		local tempFrame = display.newSprite(string.format("#icon_frame_board_%d.png", itemStar or 1))
		if tempFrame ~= nil then
			itemFrame:setDisplayFrame(tempFrame:getDisplayFrame())
		end
	end
			
	if(hasCorner == true) then
		local itemCorner = display.newSprite(string.format("#icon_corner_%d.png", itemStar or 1))
		itemCorner:setPosition(itemFrame:getContentSize().width - itemCorner:getContentSize().width/2, itemCorner:getContentSize().height/2)
		itemFrame:addChild(itemCorner)
	end

	-- 数量 
	if iconNum > 1 or (iconNum == 1 and isShowIconNum == true) then 
		local numLbl = ui.newTTFLabelWithOutline({
            text = tostring(iconNum),
            size = numLblSize,
            color = numLblColor, 
            outlineColor = numLblOutColor,
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
            })
 		
 		numLbl:setPosition(itemFrame:getContentSize().width - numLbl:getContentSize().width - 5, numLbl:getContentSize().height/2) 
	  	itemFrame:addChild(numLbl) 
	end 

	if itemBg:getChildByTag(SUIT_ARMA_TAG) ~= nil then 
		itemBg:removeChildByTag(SUIT_ARMA_TAG, true)
	end 

	local itemBgWidth = itemBg:getContentSize().width
	local itemBgHeight = itemBg:getContentSize().height 

	if resType == ResMgr.EQUIP then

		if _data[id].Suit ~= nil and isGray ~= true then

			local quas = {"","pinzhikuangliuguang_lv","pinzhikuangliuguang_lan","pinzhikuangliuguang_zi","pinzhikuangliuguang_jin"}
			local holoName = quas[_data[id].quality]
			if holoName ~= "" then
				local suitArma = ResMgr.createArma({
					resType = ResMgr.UI_EFFECT,
					armaName = holoName,
					isRetain = true})
				suitArma:setPosition(itemBg:getContentSize().width/2,itemBg:getContentSize().height/2)	
				suitArma:setTouchEnabled(false)			
				
				itemBg:addChild(suitArma)
				suitArma:setTag(SUIT_ARMA_TAG)
			end
		end
	end

	itemBg:setContentSize(CCSize(itemBgWidth,itemBgHeight))


	if isReturn then
		return itemBg
	end	
end

function ResMgr.getIconImage( name, resType )
	-- print(name)
	-- print(resType)
	local path = ""
	if(resType == ResMgr.HERO) then
		path = "hero"
	elseif(resType == ResMgr.EQUIP) then
		path = "equip"
	elseif(resType == ResMgr.ITEM) then
		path = "items"
	end
	path = path .. "/icon/"..name..".png"
	return path
end

function ResMgr.getLargeImage( name, resType )
	local path = ""
	if(resType == ResMgr.HERO) then
		path = "hero"
	elseif(resType == ResMgr.EQUIP) then
		path = "equip"
	elseif(resType == ResMgr.ITEM) then
		path = "items"
	end
	path = path .. "/large/"..name..".png"
	return path

end

 function ResMgr.getMidImage( name, resType )
     local path = ""
     if(resType == ResMgr.HERO) then
         path = "ccs/cardHeros/"..name .."0.png"
     end
     return path
 end

function ResMgr.getHeroFrame(resId,cls)
	local cardData = ResMgr.getCardData(resId)
	local pngName = cardData["arr_body"][cls+1]
    local pngPath = ResMgr.getLargeImage(pngName,ResMgr.HERO)
    local tempSprite = display.newSprite(pngPath)
    return tempSprite:getDisplayFrame()
end

function ResMgr.getLargeFrame(resType,resId,cls)
	-- local path = ResMgr.getLargeImage(name,resType)
	if(resType == ResMgr.HERO) then
		return ResMgr.getHeroFrame(resId, cls or 0)
	elseif(resType == ResMgr.EQUIP) then
		local bigIcon = "equip/large/"..data_item_item[resId]["icon"]..".png"
		return display.newSprite(bigIcon):getDisplayFrame()
	elseif(resType == ResMgr.ITEM) then
		local bigIcon = "equip/large/"..data_item_item[resId]["icon"]..".png"
		return display.newSprite(bigIcon):getDisplayFrame()
	end
	
end

function ResMgr.refreshCardBg(param)--根据参数更换卡牌的背景图片
	local sprite = param.sprite
	local star = param.star
	local resType = param.resType
	local scaleX = sprite:getScaleX()
	local scaleY = sprite:getScaleY()

	if resType == ResMgr.HERO_BG_BATTLE then
		display.addSpriteFramesWithFile("ui_common/card_bg.plist", "ui_common/card_bg.png")
		sprite:setDisplayFrame(display.newSpriteFrame("kapai_"..star..".png"))
	elseif resType == ResMgr.HERO_BG_UI then
		display.addSpriteFramesWithFile("ui/card_ui_bg.plist", "ui/card_ui_bg.png")
		sprite:setDisplayFrame(display.newSpriteFrame("card_ui_bg_"..star..".png"))
	elseif resType == ResMgr.ITEM_BG_UI then
		display.addSpriteFramesWithFile("ui/ui_item_card_bg.plist", "ui/ui_item_card_bg.png")
		sprite:setDisplayFrame(display.newSpriteFrame("item_card_bg_"..star..".png"))
	else
		print("没这种resType啊")
	end
	sprite:setScaleX(scaleX)
	sprite:setScaleY(scaleY)


end


function ResMgr.createArma(param)
	local resType = param.resType --是哪种类型的动画 是普通动画？还是UI动画  指向不同的路径
	local armaName = param.armaName --动画的名字
	local frameTag = param.frameTag or "atkEff" --规定动画过程中触发的关键帧
	local frameFunc = param.frameFunc --关键帧的回调函数
	local finishFunc = param.finishFunc --动画完结的回调函数
	local playIndex = param.playIndex or 0 
	local isRetain = param.isRetain --是否保留

	local path = ""

	if resType == ResMgr.NORMAL_EFFECT then
		path = "ccs/effect/"..armaName.."/"..armaName..".ExportJson"
	elseif resType == ResMgr.UI_EFFECT then
		path = "ccs/ui_effect/"..armaName.."/"..armaName..".ExportJson"
    elseif resType == ResMgr.SPIRIT then
        path = "jingmai/"..armaName.."/"..armaName..".ExportJson"
    elseif resType == ResMgr.TEST_EFFECT then
        path = "ccs/testAnim/"..armaName.."/"..armaName..".ExportJson"
	end

	if path ~= "" then
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(path)
		local tempArma = CCArmature:create(armaName)
		tempArma:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex) --setMovementEventCallFunc(function(armatureBack,movementType,movementID) 			
				if evt == frameTag then
					if frameFunc ~= nil then
						frameFunc()
					end							
				end
			end)
		tempArma:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
			if movementType == ccs.MovementEventType.COMPLETE then
				if isRetain ~= true then
					-- print("path "..path)
					-- tempArma:setVisible(false)
					-- tempArma:removeSelf()
					-- CCArmatureDataManager:sharedArmatureDataManager():removeAll()
					

					CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
					-- CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
				 --    CCTextureCache:sharedTextureCache():removeUnusedTextures()

					tempArma:removeFromParentAndCleanup(true)
					-- CCTextureCache:sharedTextureCache():removeUnusedTextures()
				end
				if finishFunc ~= nil then
					finishFunc()
				end
				
			end
		end)

		tempArma:getAnimation():playWithIndex(playIndex)
		return tempArma
	else
		print("Not this resTye")
	end

end

function ResMgr.ReleaseUIArmature( armaName )
	local path = "ccs/ui_effect/"..armaName.."/"..armaName..".ExportJson"

	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(path)
end


function ResMgr.getResType(itemType)
	if (itemType == 5 or itemType == 8) then 
		return ResMgr.HERO
	elseif (itemType == 6 or itemType == 7 or itemType == 11 or itemType == 12) then
		return ResMgr.ITEM
	elseif (itemType == 1 or itemType == 2 or itemType == 3 or itemType == 4 or itemType == 9 or itemType == 10) then
		return ResMgr.EQUIP
    else
        return ResMgr.ITEM
	end
end

function ResMgr.getItemTypeByResId(resId) --通过ResId来返回究竟这个resid 是道具 还是装备 仅限装备/道具表
	local curType = data_item_item[resId].type
	if curType ~= nil then
		return ResMgr.getResType(curType)
	else
		show_tip_label("ResMgr.getItemTypeByResId 不存在resId")
	end
end


function ResMgr.getItemNameColorHex(resId) 
	local quality = data_item_item[resId].quality
	local nameColor = NAME_COLOR_HEX[quality]
	return nameColor 
end


function ResMgr.getItemNameColor(resId) 
	local quality = data_item_item[resId].quality
	local nameColor = NAME_COLOR[quality]
	return nameColor 
end


function ResMgr.refreshItemName(param)
	local label = param.label
	local resId = param.resId
	local name = data_item_item[resId].name 
	local nameColor = ResMgr.getItemNameColor(resId)
	label:setString(name)
	label:setColor(nameColor)
end


function ResMgr.getHeroNameColorHexByClass(resId, class)
	local class = class or 1 
	local cardData = ResMgr.getCardData(resId)
	local star = cardData.star[class] or 1 
	if star > #QUALITY_COLOR_HEX then star = 1 end

	local nameColor = QUALITY_COLOR_HEX[star]
	return nameColor 
end


function ResMgr.getHeroNameColor(resId)
	local cardData = ResMgr.getCardData(resId)
	local star = cardData.star[1] or 1 
	if star > #QUALITY_COLOR then star = 1 end

	local nameColor = QUALITY_COLOR[star]
	return nameColor 
end


function ResMgr.refreshHeroName(param)
	local label = param.label
	local resId = param.resId
	local cardData = ResMgr.getCardData(resId)
	local name = cardData.name
	-- local star = cardData.star[1] or 1
	-- if star > #QUALITY_COLOR then star = 1 end
	-- local nameColor = QUALITY_COLOR[star]
	label:setString(name)
	
	local nameColor = ResMgr.getHeroNameColor(resId)
	label:setColor(nameColor)
end


--[[
	关卡boss的icon
	name：图片的名字
	coverType: icon 三种 类型	
]]
function ResMgr.getLevelBossIcon( name, coverType )
	-- name  = "icon_hero_dingchunqiu"
	print("boss icon: " .. name .. "," .. coverType)
	local path = "hero" .. "/icon/".. name ..".png"
	local iconSprite = display.newSprite(path)

	local coverName = ""
	if(coverType == 1) then
		coverName = "#submap_icon_copper.png"
	elseif(coverType == 2) then
		coverName = "#submap_icon_silver.png"
	elseif(coverType == 3) then	
		coverName = "#submap_icon_gold.png"
	end

	local coverSprite = display.newSprite(coverName)
	coverSprite:setPosition(iconSprite:getContentSize().width/2, iconSprite:getContentSize().height/2)
	iconSprite:addChild(coverSprite)

	return iconSprite
end

function ResMgr.delayFunc(delayTime,func,node)
	local runFuncNode = display.newNode()
	if node ~= nil then
		node:addChild(runFuncNode)
	else
		display.getRunningScene():addChild(runFuncNode)
	end

	local delayTime = CCDelayTime:create(delayTime)
	local func = CCCallFunc:create(function() 
		func()
	end)
	local removeNodeFunc = CCCallFunc:create(function() 
		runFuncNode:removeSelf() 
	end)

	runFuncNode:runAction(transition.sequence({delayTime,func,removeNodeFunc}))
end 


-- 背包类型
function ResMgr.getBagTypeDes(bagType)
	if bagType == BAG_TYPE.zhuangbei then
		return "装备"
	elseif bagType == BAG_TYPE.shizhuang then
		return "时装"
	elseif bagType == BAG_TYPE.zhuangbei_suipian then
		return "装备碎片"
	elseif bagType == BAG_TYPE.wuxue then
		return "武学"
	elseif bagType == BAG_TYPE.canhun then
		return "残魂"
	elseif bagType == BAG_TYPE.zhenqi then
		return "真气"
	elseif bagType == BAG_TYPE.daoju then
		return "道具"
	elseif bagType == BAG_TYPE.xiake then
		return "侠客"
	elseif bagType == BAG_TYPE.neigong_suipian then
		return "内功碎片"
	elseif bagType == BAG_TYPE.waigong_suipian then
		return "外功碎片"
	else
		show_tip_label("无此类型背包")
		return ""
	end 

end

-- 
-- 以后可能会根据平台使用不同的音乐文件
--
function ResMgr.getSound( filename )
	-- 
	return "sound/" .. filename .. ".mp3"
end

--
-- SFX_NAME在GameConst中，列出所有音效的文件名
-- GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
--
function ResMgr.getSFX( filename )
	return "sound/sfx/" .. filename .. ".mp3"
end

--
-- data：需要传入的数据，比如某张表，某个id的数据
-- msg ：错误信息，输出哪张表，哪个id
-- example: ResMgr.showAlert(data_item_item[v],"数据表 data_item_item:"..v)
--
function ResMgr.showAlert( data, msg )
	if(GAME_DEBUG == true) then
		if(type(data) == "nil") then
	        CCMessageBox("错误", msg)
	    end
	end
end

function ResMgr.refreshJobIcon(sprite,job)
	if job == 1 then 
		--dps 图标是刀剑		
		sprite:setDisplayFrame(display.newSpriteFrame("hero_warrior_icon.png"))
	elseif job == 2 then
		--肉盾 图标是盾牌
		sprite:setDisplayFrame(display.newSpriteFrame("hero_tank_icon.png"))
	elseif job == 3 then
		--控制 图标是八卦
		sprite:setDisplayFrame(display.newSpriteFrame("hero_magic_icon.png"))
	else
		print("不存在此类job")
	end
end

function ResMgr.shakeScr(param)
	--node是要震动那个节点
	--shakeId是需要调用的shake表中的哪个Id
	local node = param.node
	local shakeId = param.shakeId
	local width = param.width
	local height = param.height
	local orX = param.orX or node:getPositionX()
	local orY = param.orY or node:getPositionY()	


	if shakeId ~= 0 then
		node:stopAllActions()
		local shakeData = data_shake_shake[shakeId]
		local start_time = shakeData.start_time/1000 or 0.1
		local interval = shakeData.interval/1000 or 0.1
		local arr_dir = shakeData.arr_dir or {}

		local startDelayAct = CCDelayTime:create(start_time)
		local shakeActions = {}
		shakeActions[#shakeActions + 1]= startDelayAct

		local node_width = width or node:getContentSize().width
		local node_height = height or node:getContentSize().height

		for i = 1,#arr_dir do
			local offsetX = arr_dir[i][1] * node_width/1000
			local offsetY = arr_dir[i][2] * node_height/1000
			local setPosFuncAct = CCCallFunc:create(function()
				
				node:setPosition(orX + offsetX,orY + offsetY)
				end)
			shakeActions[#shakeActions + 1] = setPosFuncAct
			if i ~= #arr_dir then
				local curDelayAct = CCDelayTime:create(interval)
				shakeActions[#shakeActions + 1] = curDelayAct
			else
				
			end
		end
		local backToAct = CCCallFunc:create(function()
				node:setPosition(orX ,orY)
				
				end)
	
		shakeActions[#shakeActions + 1] =backToAct
		

		local delayEndTime = 0.08
		local delayEnd = CCDelayTime:create(delayEndTime)
		shakeActions[#shakeActions + 1] = delayEnd

		local seqAct = transition.sequence(shakeActions)
		node:runAction(seqAct)
	end
end


function ResMgr.getVipLevelData(vipLevel)
	local vipData
	for i, v in ipairs(data_viplevel_viplevel) do 
		if v.vip == vipLevel then 
			vipData = v 
		end 
	end 

	ResMgr.showAlert(vipData, "data_viplevel_viplevel表里没有vipLevel: " .. vipLevel .. "的数据")
	return vipData 
end


function ResMgr.showTextureCache( ... )

	if(GAME_DEBUG == true and device.platform == "ios") then
		printf("=========[CCTextureCache:sharedTextureCache()]==========")

	    local sharedTextureCache = CCTextureCache:sharedTextureCache()
	    
	    local function showMemoryUsage()
	        printInfo(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
	        sharedTextureCache:dumpCachedTextureInfo()
	        printInfo("---------------------------------------------------")
	    end

	    showMemoryUsage()

	end

end

function ResMgr.startTime()
	ResMgr.m_startTime = os.clock()
end

function ResMgr.endTime( )
	show_tip_label( os.clock()-ResMgr.m_startTime)
	printf("==[test time]==")
	dump(os.clock()-ResMgr.m_startTime)
end


-- 检测是否含有敏感词汇 
function ResMgr.checkSensitiveWord(wordStr) 
	local data_pingbi_pingbi = require("data.data_pingbi_pingbi") 
	
	while string.find(wordStr, " ") do 
	 	wordStr = string.gsub(wordStr, " ", "") 
	end 

	if(string.len(wordStr) == 0) then
		return true
	end
	
	local contian 
	for i, v in ipairs(data_pingbi_pingbi) do 
		contian = string.find(wordStr, v.words)
		if contian ~= nil then 
			dump(contian)
			dump(v.id)
			dump(v.words)
			break
		end
	end 

	if contian ~= nil then 
		return true 
	else
		return false
	end 
end 


function ResMgr.setMetatableByKV(table)
	setmetatable(table, {__mode = "kv"}) 
end 

ResMgr.highEndDevice = nil
function ResMgr.isHighEndDevice(  )

	if(ResMgr.highEndDevice == nil) then
		local isHigh = true
		if(device.platform == "android") then
			local totalMemory = nil
			if(CSDKShell.GetDeviceInfo().totalMemory ~= nil) then
			 	totalMemory = checkint(CSDKShell.GetDeviceInfo().totalMemory)
			end

			if(totalMemory ~= nil and totalMemory < 1000) then
				isHigh = false
			elseif(totalMemory == nil) then
				local devices = require("data.data_android_device_android_device")
				local deviceType = CSDKShell.GetDeviceInfo().deviceType
				for k,v in pairs(devices) do
					if(v.str_name == deviceType) then
						isHigh = true
						break
					end
				end
			end
		end
		ResMgr.highEndDevice = isHigh
	end

	-- return false
	return ResMgr.highEndDevice
end

return ResMgr
