local XunLiLayer = class("XunLiLayer", function () return cc.Layer:create() end )

function XunLiLayer:ctor()
    local bg = createSprite(self,"res/weddingSystem/yuelaobg.png",cc.p(display.cx,display.cy), cc.p(0.5,0.5))

    local s9 = cc.Scale9Sprite:create("res/weddingSystem/yellowbg.png")
    s9:setContentSize(cc.size(499,289))
    s9:setAnchorPoint(cc.p(0.5,0.5))
    s9:setCapInsets(cc.rect(20,20,24,24))
    s9:setPosition(cc.p(690,295))
    bg:addChild(s9)
    
    -- text content
    local data = require("src/config/PromptOp")
    local str = data:content(74)
	local richText = require("src/RichText").new(s9, cc.p(15, 260), cc.size(500, 30), cc.p(0, 1), 22, 20, MColor.brown)
	richText:addText(str)
    richText:format()
    -- text content end

    if MRoleStruct:getAttr(PLAYER_SEX) == 1 then
        self:maleLogic(bg)
    else
        self:femaleLogic(bg)
    end
    

    local closeLayer = function()
        removeFromParent(self)
    end
    registerOutsideCloseFunc( bg , closeLayer , true , false ) 


    local closeFunc = function() 
		-- clean work before exit
		local cb = function() 
			TextureCache:removeUnusedTextures()
		end
		removeFromParent(self,cb)	
	end
    local close_item = createTouchItem(bg, "res/component/button/X.png", cc.p(950,480), closeFunc, nil)
	close_item:setLocalZOrder(500)

    self:unregisterNetWorkCallBack()
end

function XunLiLayer:maleLogic(bg)
    
    local function onTourReqRecv(luaBuffer)
        local retTable = g_msgHandlerInst:convertBufferToTable("MarriageTourRtn", luaBuffer)
        require("src/layers/weddingSystem/WeddingSysCommFunc").showMaleCancellXunLiMessageBox()
    end

    local function xunLiBtnFunc()
		-- send proto here
        g_msgHandlerInst:sendNetDataByTableExEx(MARRIAGE_CS_TOUR, "MarriageTourReq", {})
        g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TOUR , onTourReqRecv )
        self:removeFromParent()
        print("MarriageTourReq send .......................................................")
	end
	local xlBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(850, 110), xunLiBtnFunc)
    createLabel(xlBtn,game.getStrByKey("wdsys_xunli"),cc.p(68,30),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
end

function XunLiLayer:femaleLogic(bg)
    createLabel(bg,game.getStrByKey("wdsys_maleclick"),cc.p(850, 110),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow) 
end

function XunLiLayer:unregisterNetWorkCallBack()
    local function eventCallback(eventType)
        if eventType == "exit" then
            g_msgHandlerInst:registerMsgHandler( MARRIAGE_SC_TOUR , nil )  
        end
    end
     self:registerScriptHandler(eventCallback)
end

return XunLiLayer
