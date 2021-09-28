local WeddingSysCeremonyAutoPlay = class("WeddingSysCeremonyAutoPlay",function () return cc.Layer:create() end)

local dialogIndex = 1
local scheduleId = nil
local scheduler = cc.Director:getInstance():getScheduler()
local wsCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")

function WeddingSysCeremonyAutoPlay:autoPlay()
    local node = G_MAINSCENE.map_layer.item_Node:getChildByTag(111111)
    if node then
        node:removeFromParent()
    end

    self:setContentSize(cc.size(display.width,display.height))
    SwallowTouches(self)

    self:addNextBubble()
    self:onEnterExist()
end

function WeddingSysCeremonyAutoPlay:addNextBubble()
    if dialogIndex == 1 then
        self:addBubble(11001, game.getStrByKey("wdsys_yuelao_dialog1"), 2)
    elseif dialogIndex == 2 then
        self:delaySomeTime(0.5)
    elseif dialogIndex == 3 then
        self:addBubble(11001, game.getStrByKey("wdsys_yuelao_dialog2"), 2)
    elseif dialogIndex == 4 then
        self:delaySomeTime(0.5)
    elseif dialogIndex == 5 then
        self:addBubble(11001, game.getStrByKey("wdsys_yuelao_dialog3"), 2)
    elseif dialogIndex == 6 then
        self:delaySomeTime(0.5)
    elseif dialogIndex == 7 then
        self:addBubble(wsCommFunc.getFemaleIdMapItemNode(), game.getStrByKey("wdsys_female_dialog"), 2) -- female
    elseif dialogIndex == 8 then
        self:delaySomeTime(1.5)
    elseif dialogIndex == 9 then
        self:addBubble(wsCommFunc.getMaleIdMapItemNode(), game.getStrByKey("wdsys_male_dialog"), 2) -- male
    elseif dialogIndex == 10 then
        self:delaySomeTime(1.5)
    elseif dialogIndex == 11 then
        self:addBubble(11001, game.getStrByKey("wdsys_yuelao_dialog4"), 2)
    elseif dialogIndex == 12 then
        self:showFlowerRain()
    end
    
    dialogIndex = dialogIndex + 1
end

function WeddingSysCeremonyAutoPlay:showFlowerRain()        -- ????
    -- flower rain
    local function addFlowerWithPos(pos)
        local tmpTime = 2
        local flower = cc.Sprite:create("")
        local fadeOutAct = cc.Sequence:create(cc.DelayTime:create(tmpTime-0.5),cc.FadeOut:create(0.5),cc.RemoveSelf:create())
        local downAction = cc.Spawn:create(cc.MoveBy:create(tmpTime,display.height/2),cc.ScaleTo:create(tmpTime,1.3),fadeOutAct)
        flower:runAction(downAction)
    end
    -- randowm pos
    local pointTabs = {{display.width/10,display.height},{display.width/20,display.height},{display.width/35,display.height},{display.width/40,display.height},{display.width/45,display.height},
        {display.width/50,display.height},{display.width/60,display.height},{display.width/70,display.height},{display.width/80,display.height},{display.width/90,display.height}}

    local rIndex = math.random(1,10)
    --addFlowerWithPos(pointTabs[rIndex])

    g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_CEREMONY_FINI, "MarriageCSCeremonyFini", {})
    print("MarriageCSCeremonyFini send ............................................................")
end

function WeddingSysCeremonyAutoPlay:delaySomeTime(time)
    local callBackFunc = function()
        scheduler:unscheduleScriptEntry(scheduleId)
        scheduleId = nil
        self:addNextBubble()
	end
    scheduleId = scheduler:scheduleScriptFunc(callBackFunc,time,false)
end

-- show talk
function WeddingSysCeremonyAutoPlay:addBubble(objId, textCon, showTime)

	local charNode = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(objId), "SpriteMonster")
	if not charNode then
        print("yuelao npc not exist ..............................................")
		return
	end
    print("yuelao npc exist ..............................................")

	local charTopNode = charNode:getTopNode()
	if charTopNode then
		local charBubble = charTopNode:getChildByTag(444)
		if charBubble then
			charBubble:removeFromParent()
		end
	end

	-------------------------------------------------------

	local textval = textCon

	local textPos = cc.p(0, 0)
	if charNode.getMainSprite then
		local mainSprite = charNode:getMainSprite()
		if mainSprite then
			local mainRect = mainSprite:getTextureRect()
			textPos.y = textPos.y + mainRect.height/2
		end
	end


	local charBubbleNew = require("src/base/MonsterBubble").new(textval, textPos,18)
	local charTopNode = charNode:getTopNode()
	if charTopNode then
		charTopNode:addChild(charBubbleNew,4)
	end
	charBubbleNew:setTag(444)

	-------------------------------------------------------
    if showTime == nil then
        showTime = 3
    end

    local funcRemove = function()
        print("funcRemove called .......................")
        charBubbleNew:removeFromParent()
        charBubbleNew = nil
        scheduler:unscheduleScriptEntry(scheduleId)
        scheduleId = nil
        self:addNextBubble()
	end

    scheduleId = scheduler:scheduleScriptFunc(funcRemove,showTime,false)
end

function WeddingSysCeremonyAutoPlay:onEnterExist()
    local function eventCallback(eventType)
        if eventType == "exit" then
            print("eventType == exit ....................................")
            dialogIndex = 1
            if scheduleId then
                scheduler:unscheduleScriptEntry(scheduleId)
                scheduleId = nil
            end
        end
    end
    self:registerScriptHandler(eventCallback)
end

return WeddingSysCeremonyAutoPlay