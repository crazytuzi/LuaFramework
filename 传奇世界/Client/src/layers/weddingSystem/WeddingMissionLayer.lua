local WeddingMissionLayer = class("WeddingMissionLayer", function () return cc.Layer:create() end )

WeddingMissionLayer.s9 = nil      -- only used for qifen node to resize bg size
WeddingMissionLayer.subLayerTab = nil
WeddingMissionLayer.onWeddingKindRecvCallBack = nil

local wsysCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")

function WeddingMissionLayer:ctor()

    local bg = self:addBgSprite()
    local select_index = 0
    local subLayers =  self:addSubLayers(bg)
	self.subLayerTab = subLayers

    local onMenuClick = function (index)
        if select_index == index then
            return
        end
        select_index = index
        for k,v in pairs(subLayers) do
            v:setVisible(false)
        end
        subLayers[select_index]:setVisible(true)
        if select_index == 2 then
            if wsysCommFunc.weddingOpenedStatus == 0 or wsysCommFunc.weddingOpenedStatus == 2 then
                self.s9:setContentSize(cc.size(499,100))
            elseif wsysCommFunc.weddingOpenedStatus == 1 then
                self.s9:setContentSize(cc.size(499,289))
            end
        elseif select_index == 1 or select_index == 3 then
            self.s9:setContentSize(cc.size(499,289))
        end
    end

-------------------------------------------------------------------------

    local tab_missionBtn = game.getStrByKey("wdsys_missionBtn")
    local tab_weddingBtn = game.getStrByKey("wdsys_weddingBtn")
    local tab_otherBtn   = game.getStrByKey("wdsys_otherBtn")

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

function WeddingMissionLayer:registerNetWorkCallBack()
    local function onWeddingKindRecv(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCStartWeddingSucc", luaBuffer)
        print("-------------------------------MarriageSCStartWeddingSucc---------------------------------------")
        local par = self.subLayerTab[2]:getParent()
        self.subLayerTab[2]:removeFromParent()
        local layer = self:showEnterLayer()
        layer:setPosition(cc.p(0,0))
        par:addChild(layer)
        self.subLayerTab[2] = layer
        wsysCommFunc.weddingOpenedStatus = 1
    end
    self.onWeddingKindRecvCallBack = g_msgHandlerInst:getMsgHandler(MARRIAGE_SC_START_WEDDING_SUCC)
    g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_START_WEDDING_SUCC , onWeddingKindRecv )
end

function WeddingMissionLayer:unregisterNetWorkCallBack()
    local function eventCallback(eventType)
        if eventType == "exit" then
            g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_VENUE_TIME_INFO , nil )  
            g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_START_WEDDING_SUCC , self.onWeddingKindRecvCallBack )
        end
    end
    self:registerScriptHandler(eventCallback)
end

function WeddingMissionLayer:addSubLayers(bg)
    local subLayers = {}
    subLayers[1] = self:addMissionBoard()
    if wsysCommFunc.weddingOpenedStatus == 0 then
        subLayers[2] = self:addWeddingBoard()
    elseif wsysCommFunc.weddingOpenedStatus == 1 then
        subLayers[2] = self:showEnterLayer()
    elseif wsysCommFunc.weddingOpenedStatus == 2 then
        subLayers[2] = self:addWeddingBoard()
    else
        print("wsysCommFunc.weddingOpenedStatus ==== ",wsysCommFunc.weddingOpenedStatus)
        MessageBox(game.getStrByKey("wdsys_err_unno"))
    end
    
    subLayers[3] = self:addDivorceBoard()
    for k,v in pairs(subLayers) do
        v:setPosition(cc.p(0,0))
        v:setVisible(false)
        bg:addChild(v)
    end
    return subLayers
end

function WeddingMissionLayer:addBgSprite()
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
---------------------------------------------------------------------------------------------------------------------------------
-- wedding board content
function WeddingMissionLayer:addMissionBoard()
    --local bg = createSprite(self,"res/weddingSystem/yuelaobg.png",cc.p(display.cx,display.cy), cc.p(0.5,0.5))
    local node = cc.Node:create()
    -- here will get server data to decide which text should be shown & which function should be bind ????
    local data = require("src/config/PromptOp")
    local str = data:content(83)
	local richText = require("src/RichText").new(node, cc.p(450, 430), cc.size(500, 30), cc.p(0, 1), 22, 20, MColor.brown)
	richText:addText(str)
    richText:format()
    --richText:removeFromParent()

    local function getMissionBtnFunc()
		
	end
    local function finishMissionBtnFunc()
		
	end

	local missionBtn = createMenuItem(node, "res/component/button/50.png", cc.p(850, 110), getMissionBtnFunc)
    createLabel(missionBtn,game.getStrByKey("wdsys_getMissionBtn"),cc.p(68,30),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    
    return node
end
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
-- wedding board content
function WeddingMissionLayer:addWeddingBoard()
    local node = cc.Node:create()

    -- scroll view
    -- add text content here
    local data = require("src/config/PromptOp")
    local str = data:content(82)
	local richText = require("src/RichText").new(bg, cc.p(0, 0), cc.size(500, 30), cc.p(0, 1), 22, 20, MColor.brown)
	richText:addText(str)
    richText:format()
    richText:removeFromParent()
    local scrollView = cc.ScrollView:create()
    scrollView:setViewSize(cc.size( 499,92 ))
    scrollView:setPosition( cc.p( 450,340 ) )
    scrollView:ignoreAnchorPointForPosition(true)

    scrollView:setContainer(richText)
    scrollView:updateInset()

    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    scrollView:setContentOffset( cc.p(0, -richText:getContentSize().height+scrollView:getViewSize().height ))
    node:addChild(scrollView)

    --createSprite(node,"res/weddingSystem/wedding_classic.png",cc.p(display.cx,display.cy-80),cc.p(0.5,0.5)) 
    --createSprite(node,"res/weddingSystem/wedding_luxury.png",cc.p(display.cx+240,display.cy-80),cc.p(0.5,0.5))

    if wsysCommFunc.weddingOpenedStatus ~= 2 then

        local function onWeddingCarChoose1()
            local function yesCallBack()
                --MARRIAGE_CS_REQ_START_WEDDING
                g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_REQ_START_WEDDING, "MarriageCSReqStartWedding", {type=1})
                print("classic wedding choose send .......................................................................")
            end
            -- confirm 
            MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("wdsys_weddingOpen_confirm1"),yesCallBack)
        end
        local function onWeddingCarChoose2()
            local function yesCallBack()
                --MARRIAGE_CS_REQ_START_WEDDING
                g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_REQ_START_WEDDING, "MarriageCSReqStartWedding", {type=2})
                print("luxury wedding choose send .......................................................................")
            end
            -- confirm 
            MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("wdsys_weddingOpen_confirm2"),yesCallBack)
        end

        local c1 = createTouchItem(node, "res/weddingSystem/wedding_classic.png", cc.p(display.cx,display.cy-80), onWeddingCarChoose1, true)
        local c2 = createTouchItem(node, "res/weddingSystem/wedding_luxury.png", cc.p(display.cx+240,display.cy-80), onWeddingCarChoose2, true)

        createLabel(c1,game.getStrByKey("wdsys_weddingClassic"),cc.p(120,20),cc.p(0.5,0),18,nil,nil,nil,MColor.brown_gray)
        createLabel(c2,game.getStrByKey("wdsys_weddingLuxury"),cc.p(130,20),cc.p(0.5,0),18,nil,nil,nil,MColor.brown_gray)
    end
    --[[
    local function rBtnGroupCallBack(rButton,index,eventType)
        -- index 0 first one 1 second one
        if index == 0 then
        elseif index == 1 then
        end
    end

    local rBtnGroup = ccui.RadioButtonGroup:create()
    rBtnGroup:setPosition(cc.p(display.cx,display.cy-80))
    node:addChild(rBtnGroup)
    rBtnGroup:addEventListener(rBtnGroupCallBack)

    local rBtn = ccui.RadioButton:create("res/component/checkbox/2.png","res/component/checkbox/2-1.png")
    rBtn:setPosition(cc.p(display.cx-50,display.cy-170))
    rBtnGroup:addRadioButton(rBtn)
    node:addChild(rBtn)
    createLabel(rBtn,game.getStrByKey("wdsys_weddingClassic"),cc.p(75,6),cc.p(0.5,0),18,nil,nil,nil,MColor.brown_gray)

    local rBtn2 = ccui.RadioButton:create("res/component/checkbox/2.png","res/component/checkbox/2-1.png")
    rBtn2:setPosition(cc.p(display.cx+190,display.cy-170))
    rBtnGroup:addRadioButton(rBtn2)
    node:addChild(rBtn2)
    createLabel(rBtn2,game.getStrByKey("wdsys_weddingLuxury"),cc.p(75,6),cc.p(0.5,0),18,nil,nil,nil,MColor.brown_gray)

    local function confirmQiFenBtnFunc()
		-- send radio res to server
	end
    local missionBtn = createMenuItem(node, "res/component/button/50.png", cc.p(850, 110), confirmQiFenBtnFunc)
    createLabel(missionBtn,game.getStrByKey("wdsys_confirm"),cc.p(68,30),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    ]]
    return node
end

function WeddingMissionLayer:showEnterLayer()
    local node = cc.Node:create()

    local function enterGroundBtnFunc()
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_ENTER_WEDDING_VENUE, "MarriageCSEnterWeddingVenue", {})
        self:removeFromParent()
	end

    local data = require("src/config/PromptOp")
    local str = data:content(82)
	local richText = require("src/RichText").new(bg, cc.p(0, 0), cc.size(500, 30), cc.p(0, 1), 22, 20, MColor.brown)
	richText:addText(str)
    richText:format()
    richText:removeFromParent()
    local scrollView = cc.ScrollView:create()
    scrollView:setViewSize(cc.size( 499,92 ))
    scrollView:setPosition( cc.p( 450,340 ) )
    scrollView:ignoreAnchorPointForPosition(true)

    scrollView:setContainer(richText)
    scrollView:updateInset()

    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    scrollView:setContentOffset( cc.p(0, -richText:getContentSize().height+scrollView:getViewSize().height ))
    node:addChild(scrollView)

	local missionBtn = createMenuItem(node, "res/component/button/50.png", cc.p(850, 110), enterGroundBtnFunc)
    createLabel(missionBtn,game.getStrByKey("wdsys_enterGroundBtn"),cc.p(68,30),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)

    -- here will get server data to show a time tick ????
    local timeStamp = os.time() + 1000
    local t = os.date("*t",timeStamp)
    local timeText = string.format(game.getStrByKey("wdsys_groundRemindTime"),t.hour,t.min)
    local timeLabel = createLabel(node,timeText,cc.p(580, 110),cc.p(0.5,0.5),20,nil,nil,nil,MColor.brown_gray)
    timeLabel:setVisible(false)
    local scheduleUpdate = function()
        timeStamp = timeStamp - 60
        local t = {}
        t.hour = 0
        t.second = 0
        if timeStamp > os.time() then
            t= os.date("*t",timeStamp)    
        end
        local timeText = string.format(game.getStrByKey("wdsys_groundRemindTime"),t.hour,t.min)
        timeLabel:setString(timeText)
    end
    schedule(self,scheduleUpdate,60)

    local function onTimeTickRecv(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingVenueTimeInfo", luaBuffer)
        timeStamp = retTable.endTime
        timeLabel:setVisible(true)
        print("onTimeTickRecv total time ==== ",retTable.endTime,timeStamp)
    end
    g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_VENUE_TIME_INFO , onTimeTickRecv )
    g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_VENUE_TIME_INFO, "MarriageCSWeddingVenueTimeInfo", {marriageID=wsysCommFunc.marriageID})

    return node
end
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
-- divorce board
function WeddingMissionLayer:addDivorceBoard()
    local node = cc.Node:create()

    local data = require("src/config/PromptOp")
    local str = data:content(84)
	local richText = require("src/RichText").new(node, cc.p(450, 430), cc.size(500, 30), cc.p(0, 1), 22, 20, MColor.brown)
	richText:addText(str)
    richText:format()

    local function yfyjBtnFunc()
		
	end

	local missionBtn = createMenuItem(node, "res/component/button/50.png", cc.p(850, 110), yfyjBtnFunc)
    createLabel(missionBtn,game.getStrByKey("wdsys_yfyjBtn"),cc.p(68,30),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
    return node
end
---------------------------------------------------------------------------------------------------------------------------------
return WeddingMissionLayer