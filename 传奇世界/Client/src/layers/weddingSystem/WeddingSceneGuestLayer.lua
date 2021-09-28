local WeddingSceneGuestLayer = class("WeddingSceneGuestLayer", function () return cc.Layer:create() end )

function WeddingSceneGuestLayer:ctor()
    local bg = self:addBgSprite()
    local node = self:addGuestLayer()
    bg:addChild(node)
    SwallowTouches(self)
end

function WeddingSceneGuestLayer:addBgSprite()
    local bg = createSprite(self,"res/weddingSystem/yuelaobg.png",cc.p(display.cx-20,display.cy),cc.p(0.5,0.5))

    local s9 = cc.Scale9Sprite:create("res/weddingSystem/yellowbg.png")
    s9:setContentSize(cc.size(499,100))
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

function WeddingSceneGuestLayer:addGuestLayer()
    local node = cc.Node:create()

    local data = require("src/config/PromptOp")
    local str = data:content(81)
	local richText = require("src/RichText").new(node, cc.p(450, 430), cc.size(500, 30), cc.p(0, 1), 22, 20, MColor.brown)
	richText:addText(str)
    richText:format()

    local cardSended = false
    local wineSended = false
    local redpackageSended = false
    -- add touch event
    local addGiftMsg = nil
    local function sendGift(giftKind)
        local function onCardSendRecv(luaBuffer)
            print("onCardSendRecv recv ........................................................")
            local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingSendBonusSucc", luaBuffer)
            local giftKind = retTable.bonus
            local textCon = ""
            if giftKind == 1 then
                cardSended = true
                textCon = "wdsys_zscg_card"
            elseif giftKind == 2 then
                wineSended = true
                textCon = "wdsys_zscg_wine"
            elseif giftKind == 3 then
                redpackageSended = true
                textCon = "wdsys_zscg_redpackage"
            end
            addGiftMsg()
            MessageBox( game.getStrByKey(textCon) )
        end

        local wsysCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_SEND_BONUS, "MarriageCSWeddingSendBonus", {bonus=giftKind,marriageID=wsysCommFunc.wdSceneMarriageId} )
        g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_SEND_BONUS_SUCC , onCardSendRecv )
        print("on gift send index :",giftKind)
    end

    local function cardTouchCallBack()
        if cardSended then
            return
        end
        print("on card gift click .........................")
        local function yesFunc()
            sendGift(1)
        end
        MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("wdsys_zs_card"),yesFunc)
    end

    local function wineTouchCallBack()
        if wineSended then
            return
        end
        print("on wine gift click .........................")
        local function yesFunc()
            sendGift(2)
        end
        MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("wdsys_zs_wine"),yesFunc)
    end

    local function redpackageTouchCallBack()
        if redpackageSended then
            return
        end
        print("on redpackage gift click .........................")
        local function yesFunc()
            sendGift(3)
        end
        MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("wdsys_zs_redpackage"),yesFunc)
    end
    
    ------------------------------------------------------------
    -- add UI
    local cardTouch         = createTouchItem(node,"res/weddingSystem/cardIcon.png",cc.p(display.cx-30,display.cy-80),cardTouchCallBack,true) 
    local wineTouch         = createTouchItem(node,"res/weddingSystem/wineIcon.png",cc.p(display.cx+150,display.cy-80),wineTouchCallBack,true) 
    local redpackageTouch   = createTouchItem(node,"res/weddingSystem/redPackgeIcon.png",cc.p(display.cx+320,display.cy-80),redpackageTouchCallBack,true) 

    local cardLabel = createLabel(node,game.getStrByKey("wdsys_card"),cc.p(display.cx-30,display.cy-170),cc.p(0.5,0.5),18,nil,nil,nil,MColor.brown_gray)
    local wineLabel = createLabel(node,game.getStrByKey("wdsys_wine"),cc.p(display.cx+150,display.cy-170),cc.p(0.5,0.5),18,nil,nil,nil,MColor.brown_gray)
    local redpackageLabel = createLabel(node,game.getStrByKey("wdsys_redpackage"),cc.p(display.cx+320,display.cy-170),cc.p(0.5,0.5),18,nil,nil,nil,MColor.brown_gray)
    ------------------------------------------------------------
    addGiftMsg = function()
        if cardSended then
            cardLabel:setString( game.getStrByKey("wdsys_sended") )
        end
        if wineSended then
            wineLabel:setString( game.getStrByKey("wdsys_sended") )
        end
        if redpackageSended then
            redpackageLabel:setString( game.getStrByKey("wdsys_sended") )
        end
        
    end
    local function onGuestGiftRecv(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("MarriageSCWeddingBonusInfo", luaBuffer)
        cardSended = retTable.bonus1 == 1 and true or false
        wineSended = retTable.bonus2 == 1 and true or false
        redpackageSended = retTable.bonus3 == 1 and true or false
        addGiftMsg()
    end
    g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_WEDDING_BONUS_INFO , onGuestGiftRecv )
    local wsysCommFunc = require("src/layers/weddingSystem/WeddingSysCommFunc")
    g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_WEDDING_BONUS_INFO, "MarriageCSWeddingBonusInfo", {marriageID = wsysCommFunc.wdSceneMarriageId} )
    ------------------------------------------------------------

    return node
end

return WeddingSceneGuestLayer