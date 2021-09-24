local CardView = classGc(view, function(self)

end)
local rightbgSize = cc.size(580, 460)
local FONTSIZE     = 24

function CardView.create(self)
    self.m_container = cc.Node : create()

    -- local doubleSor = ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
    -- doubleSor : setContentSize(566,444)
    -- doubleSor : setPosition(105,-20)
    -- self.m_container : addChild(doubleSor)

    local ExchangeLab= _G.Util:createBorderLabel("请输入兑换码", FONTSIZE+2,_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BLACK))
    ExchangeLab      : setPosition(102, 55)
    -- ExchangeLab      : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN)) 
    self.m_container : addChild(ExchangeLab)
    
    local textbgSpr  = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
    self.textField=ccui.EditBox:create(cc.size(rightbgSize.width/2, 48),textbgSpr)
    self.textField:setPosition(102, 0)
    self.textField:setFont(font_TextName,20)
    self.textField:setPlaceholderFont(font_TextName,20)
    self.textField:setPlaceHolder("              不区分大小写")
    self.textField:setMaxLength(20)
    self.textField:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.m_container:addChild(self.textField)

    local function onButtonCallBack(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("验证兑换码")
            if self.textField ~= nil then 
                local _string = self.textField : getText()
                local xskStr  = string.match(_string,"%s*(.-)%s*$")
                if xskStr ~= "" then
                    print("领取新手卡 ---- "..xskStr)
                    local msg = REQ_CARD_GETS()
                    msg : setArgs( xskStr )
                    _G.Network : send( msg )
                else
                    local command = CErrorBoxCommand("请输入兑换码")
                    controller : sendCommand( command )
                end
            end
        end 
    end
    local ExchangeBtn= gc.CButton : create("general_btn_gold.png")
    ExchangeBtn      : setTitleText("领 取")
    ExchangeBtn      : setTitleFontName(_G.FontName.Heiti)
    ExchangeBtn      : setTitleFontSize(FONTSIZE)
    ExchangeBtn      : setPosition(102, -80)
    --ExchangeBtn      : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    ExchangeBtn      : addTouchEventListener(onButtonCallBack)
    self.m_container : addChild(ExchangeBtn)

    return self.m_container
end

---------------------协议返回-------------------

function CardView.cardData(self, _ackMsg )
    print("充值获得：", _ackMsg.msg_xxx[self.rmbcount])
    if _ackMsg.count ~= nil and  _ackMsg.count > 0 then
        local twoStr = "充值获得"..self.goldNum[self.rmbcount].."元宝"
        self.oneLab[self.rmbcount] : setString(twoStr)
        self.goldImg[self.rmbcount] : setVisible(false)
    end
    _G.Util:playAudioEffect("ui_receive_awards")
end

return CardView