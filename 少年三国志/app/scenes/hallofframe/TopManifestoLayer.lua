local TopManifestoLayer = class("TopManifestoLayer", UFCCSModelLayer)

function TopManifestoLayer:ctor(...)
    self.super.ctor(self,...)
    self:adapterWithScreen()
    
    local txt = self:getTextFieldByName("TextField_Sign")
    txt:setMaxLengthEnabled(true)
    txt:setMaxLength(60)
    
    self:registerBtnClickEvent("Button_Confrim",function()
        if G_Me.userData.gold >= 10 then
            G_HandlersManager.hallOfFrameHandler:sendRequestSign(txt:getStringValue())
        else
            require("app.scenes.shop.GoldNotEnoughDialog").show()
        end
        self:animationToClose()
    end)
        
    self:registerBtnClickEvent("Button_Cancel",function()
        self:animationToClose() 
    end)

        self:registerBtnClickEvent("Button_Close",function()
        self:animationToClose() 
    end)
    
     self:registerTextfieldEvent("TextField_Sign",function ( textfield, eventType )
         if eventType == CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_HIDE then
--             local i = 1
--             local str = ""
--             for uchar in string.gfind(textfield:getStringValue(), "[%z\1-\127\194-\244][\128-\191]*") do
--                 if i <= 20 then
--                     str = str .. uchar 
--                 else
--                     G_MovingTip:showMovingTip(G_lang:get("LANG_TOP_TEXT_LIMIT"))
--                     break
--                 end
--                 i = i +1
--             end
             textfield:setText(G_GlobalFunc.filterText(textfield:getStringValue()))
         end
     end)
    
    local txtPanel = self:getPanelByName("Panel_Txt")
    if txtPanel then
        local text = G_lang:get("LANG_TOP_COST", {num=10})
	    local label = GlobalFunc.createGameRichtext(text, 24, ccc3(0x50, 0x3e, 0x32))
        self:getImageViewByName("Image_1"):addChild(label,10)
         label:setPosition(txtPanel:getPositionInCCPoint())
    end
end

function TopManifestoLayer.create()
    return TopManifestoLayer.new("ui_layout/top_Manifesto.json",Colors.modelColor)
end

return TopManifestoLayer

