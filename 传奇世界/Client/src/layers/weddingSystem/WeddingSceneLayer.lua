local WeddingSceneLayer = class("WeddingSceneLayer", function () return cc.Layer:create() end )

WeddingSceneLayer.s9 = nil      -- only used for qifen node to resize bg size

function WeddingSceneLayer:ctor()

    local bg = self:addBgSprite()
    local select_index = 0
    local subLayers =  self:addSubLayers(bg)
	
    local onMenuClick = function (index)
        if select_index == index then
            return
        end
        select_index = index
        for k,v in pairs(subLayers) do
            v:setVisible(false)
        end
        subLayers[select_index]:setVisible(true)
        if select_index == 2 or select_index == 3 then
            self.s9:setContentSize(cc.size(499,100))
        elseif select_index == 1 then
            self.s9:setContentSize(cc.size(499,289))
        end
    end

-------------------------------------------------------------------------

    local tab_missionBtn = game.getStrByKey("wdsys_sceneBtn")
    local tab_weddingBtn = game.getStrByKey("wdsys_qifenBtn")
    local tab_otherBtn   = game.getStrByKey("wdsys_wanfaBtn")

    local tabs = {}
    tabs[#tabs+1] = tab_missionBtn
    tabs[#tabs+1] = tab_weddingBtn
    tabs[#tabs+1] = tab_otherBtn

    local TabControl = Mnode.createTabControl(
    {
        src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
        size = 22,
        titles = tabs,
        margins = 2,
        ori = "|",
        align = "r",
        side_title = true,
        cb = function(node, tag)
            onMenuClick(tag)
            local title_label = bg:getChildByTag(12580)
            if title_label then title_label:setString(tabs[tag]) end
        end,
        selected = theIndex or 1,
    })

    Mnode.addChild(
    {
        parent = bg,
        child = TabControl,
        anchor = cc.p(0, 0.0),
        pos = cc.p(955, 370),
        zOrder = 200,
    })
    G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(2), TOUCH_SKILL_SET_TAB)
    --subLayers = self:addSubLayers()

	SwallowTouches(self)

    self:registerNetWorkCallBack()
    self:unregisterNetWorkCallBack()
end
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
function WeddingSceneLayer:registerNetWorkCallBack()
    local function onOpenFlowerLiYueShiRecv()
        print("onOpenFlowerLiYueShiRecv")
        local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingAmbienceSucc", luaBuffer)
        local qfType = tonumber(retTable.ambience)
        local qfStartTime = retTable.startTime
        local qfEndTime = retTable.endTime
        if qfType == 1 then -- flower
            -- to do
        elseif qfType == 2 then -- liyueshi
            -- 

        else
            return
        end

        self:removeFromParent()
    end
    g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_AMBIENCE_SUCC , onOpenFlowerLiYueShiRecv )
    local function onOpenXiuQiuPinJiuRecv()
        print("onOpenXiuQiuPinJiuRecv")
        local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingPlaySucc", luaBuffer)
        local play = retTable.play
        local startTime = retTable.startTime
        local endTime = retTable.endTime

        self:removeFromParent()
    end
    g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_PLAY_SUCC , onOpenXiuQiuPinJiuRecv )

end

function WeddingSceneLayer:unregisterNetWorkCallBack()
    local function eventCallback(eventType)
        if eventType == "exit" then
            g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_GUEST_LIST , nil )
            g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_AMBIENCE_SUCC , nil )
            g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_PLAY_SUCC , nil )
        end
    end
     self:registerScriptHandler(eventCallback)
end

function WeddingSceneLayer:addSubLayers(bg)
    local subLayers = {}
    subLayers[1] = self:addWeddingSceneBoard()
    subLayers[2] = self:addQiFenBoard()
    subLayers[3] = self:addWanFaBoard()
    for k,v in pairs(subLayers) do
        v:setPosition(cc.p(0,0))
        v:setVisible(false)
        bg:addChild(v)
    end
    return subLayers
end

function WeddingSceneLayer:addBgSprite()
    local bg = createSprite(self,"res/weddingSystem/yuelaobg.png",cc.p(display.cx-20,display.cy),cc.p(0.5,0.5))

    local s9 = cc.Scale9Sprite:create("res/weddingSystem/yellowbg.png")
    s9:setContentSize(cc.size(499,289))
    s9:setAnchorPoint(cc.p(0,1))
    s9:setCapInsets(cc.rect(20,20,24,24))
    s9:setPosition(cc.p(440,435))
    bg:addChild(s9)
    self.s9 = s9

    local closeFunc = function() 
		-- clean work before exit
		local cb = function() 
			TextureCache:removeUnusedTextures()
		end
		removeFromParent(self,cb)	
	end
    local close_item = createTouchItem(bg, "res/component/button/X.png", cc.p(950,480), closeFunc, nil)
	close_item:setLocalZOrder(500)
    return bg
end

function WeddingSceneLayer:addWeddingSceneBoard()
    local node = cc.Node:create()
    -- here will get server data to decide which text should be shown & which function should be bind ????
    local data = require("src/config/PromptOp")
    local str = data:content(78)
	local richText = require("src/RichText").new(node, cc.p(450, 430), cc.size(500, 30), cc.p(0, 1), 22, 20, MColor.brown)
	richText:addText(str)
    richText:format()
    local function getGuestListBtnFunc()
        local function onGuestListRecv(luaBuffer)
            print("onGuestListRecv recv ........................................................")
            local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingGuestList", luaBuffer)
            local guestList = retTable.infoList
            
            package.loaded["src/layers/weddingSystem/GuestList"] = nil
            local xlMissonlayer = require("src/layers/weddingSystem/GuestList").new(guestList)
            getRunScene():addChild(xlMissonlayer)
            self:removeFromParent()
        end

        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_GUEST_LIST, "MarriageCSWeddingGuestList", {} )
        g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_GUEST_LIST , onGuestListRecv )
        print("MARRIAGE_CS_WEDDING_GUEST_LIST send ......................................................")
	end

	local missionBtn = createMenuItem(node, "res/component/button/50.png", cc.p(850, 110), getGuestListBtnFunc)
    createLabel(missionBtn,game.getStrByKey("wdsys_guestList"),cc.p(68,30),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    
    return node
end

function WeddingSceneLayer:addQiFenBoard()
    local node = cc.Node:create()

    local data = require("src/config/PromptOp")
    local str = data:content(79)
	local richText = require("src/RichText").new(node, cc.p(450, 430), cc.size(500, 30), cc.p(0, 1), 22, 20, MColor.brown)
	richText:addText(str)
    richText:format()

    local flowerTouch = createSprite(node,"res/weddingSystem/qifenFlower.png",cc.p(display.cx,display.cy-80),cc.p(0.5,0.5)) 
    local musicTouch = createSprite(node,"res/weddingSystem/qifenMusic.png",cc.p(display.cx+240,display.cy-80),cc.p(0.5,0.5))

    local function rBtnGroupCallBack(rButton,index,eventType)
        -- index 0 first one 1 second one
        if index == 0 then
        elseif index == 1 then
        end
    end

    createLabel(node,game.getStrByKey("wdsys_romanticflower"),cc.p(display.cx,display.cy-170),cc.p(0.5,0.5),18,nil,nil,nil,MColor.brown_gray)
    createLabel(node,game.getStrByKey("wdsys_liyueshi"),cc.p(display.cx+240,display.cy-170),cc.p(0.5,0.5),18,nil,nil,nil,MColor.brown_gray)

    -- add touch event
    local function flowerTouchCallBack()
        if not node:isVisible() then
            return
        end
        print("fower touch call back")
        local function yesFunc()
            g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_AMBIENCE, "MarriageCSWeddingAmbience", {ambience=1} )
        end
        MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("wdsys_openFlower"),yesFunc)
    end
    addTouchEventListen(flowerTouch,flowerTouchCallBack)

    local function musicTouchCallBack()
        if not node:isVisible() then
            return
        end
        print("music touch call back")
        local function yesFunc()
            g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_AMBIENCE, "MarriageCSWeddingAmbience", {ambience=2} )
            print("MarriageCSWeddingAmbience sended .....")
        end
        MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("wdsys_openLiYueShi"),yesFunc)
    end
    addTouchEventListen(musicTouch,musicTouchCallBack)

    --[[
    local function confirmQiFenBtnFunc()
		-- send radio res to server
	end
    local missionBtn = createMenuItem(node, "res/component/button/50.png", cc.p(850, 110), confirmQiFenBtnFunc)
    createLabel(missionBtn,game.getStrByKey("wdsys_confirm"),cc.p(68,30),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    ]]
    ------------------------------------------------------------
    
    g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_GUEST_LIST , onGuestListRecv )
    
    ------------------------------------------------------------

    return node
end

function WeddingSceneLayer:addWanFaBoard()
    local node = cc.Node:create()
    
    local data = require("src/config/PromptOp")
    local str = data:content(80)
	local richText = require("src/RichText").new(node, cc.p(450, 430), cc.size(500, 30), cc.p(0, 1), 22, 20, MColor.brown)
	richText:addText(str)
    richText:format()

    local pinjiuTouch = createSprite(node,"res/weddingSystem/pinjiu.png",cc.p(display.cx,display.cy-80),cc.p(0.5,0.5)) 
    local qxqTouch = createSprite(node,"res/weddingSystem/qiangxiuqiu.png",cc.p(display.cx+240,display.cy-80),cc.p(0.5,0.5))

    local function rBtnGroupCallBack(rButton,index,eventType)
        -- index 0 first one 1 second one
        if index == 0 then
        elseif index == 1 then
        end
    end

    createLabel(node,game.getStrByKey("wdsys_pinjiu"),cc.p(display.cx,display.cy-170),cc.p(0.5,0.5),18,nil,nil,nil,MColor.brown_gray)
    createLabel(node,game.getStrByKey("wdsys_qiangxiuqiu"),cc.p(display.cx+240,display.cy-170),cc.p(0.5,0.5),18,nil,nil,nil,MColor.brown_gray)
    
    -- add touch event
    local function pinjiuTouchCallBack()
        if not node:isVisible() then
            return
        end
        print("pinjiuTouchCallBack touch call back")
        local function yesFunc()
            g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_PLAY, "MarriageCSWeddingPlay", {play=2} )
        end
        MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("wdsys_openPinJiu"),yesFunc)
    end
    addTouchEventListen(pinjiuTouch,pinjiuTouchCallBack)

    local function qxqTouchCallBack()
        if not node:isVisible() then
            return
        end
        print("qxqTouchCallBack touch call back")
        local function yesFunc()
            g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_PLAY, "MarriageCSWeddingPlay", {play=1} )
        end
        MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("wdsys_openQXQ"),yesFunc)
    end
    addTouchEventListen(qxqTouch,qxqTouchCallBack)

    --[[
    local function yfyjBtnFunc()
		
	end
	local missionBtn = createMenuItem(node, "res/component/button/50.png", cc.p(850, 110), yfyjBtnFunc)
    createLabel(missionBtn,game.getStrByKey("wdsys_confirm"),cc.p(68,30),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    ]]
    return node
end

return WeddingSceneLayer