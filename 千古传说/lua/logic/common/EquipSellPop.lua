--[[
******装备出售确定层*******

    -- by quanhuan
    -- 2015/9/10
]]

local EquipSellPop = class("EquipSellPop", BaseLayer)

--CREATE_PANEL_FUN(EquipSellPop)


function EquipSellPop:ctor(data)
    self.super.ctor(self,data)

      --绑定英雄榜消息回调
    TFDirector:addProto(s2c.EQUIPMENT_SELL_RESULT, self, self.sellEquipCallBack)
end

function EquipSellPop:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.btn_cancel         = TFDirector:getChildByPath(ui, 'btn_cancel')
    self.txt_message        = TFDirector:getChildByPath(ui, 'txt_message')
    self.txt_messageRed    = TFDirector:getChildByPath(ui, 'txt_message1')

    print("EquipSellPop:initUI(ui)")
end

function EquipSellPop:removeUI()
	self.super.removeUI(self)

    print("EquipSellPop:removeUI(ui)")
    --self.btn_ok             = nil
    --self.btn_cancel         = nil
end

function EquipSellPop:setData( data )
    self.data = data
end

function EquipSellPop:setUIConfig( uiconfig )
    self:init(uiconfig)
end

function EquipSellPop:setTitleImg( path )
    if self.img_title and path then
        self.img_title:setTexture(path)
    end
end

function EquipSellPop:setBtnOkText( text )
    if self.btn_ok and text then
        self.btn_ok:setText(text)
    end
end

function EquipSellPop:setBtnCancelText( text )
    if self.btn_cancel and text then
        self.btn_cancel:setText(text)
    end
end

function EquipSellPop:setTitle( title )
    if self.txt_title and title then
        self.txt_title:setText(title)
    end
end

function EquipSellPop:setMsg( msg )
    if self.txt_message and msg then
        self.txt_message:setText(msg)
    end
end

function EquipSellPop:setMsgRed( msg )
    if self.txt_messageRed and msg then
        self.txt_messageRed:setVisible(true)
        self.txt_messageRed:setText(msg)
    else
        self.txt_messageRed:setVisible(false)
    end
end

function EquipSellPop:setDataTable( table )
    self.tableData = table
end

function EquipSellPop:setBtnHandle(okhandle, cancelhandle)
    if self.btn_ok then
        self.btn_ok.logic       = self
        self.btn_ok.fun         = okhandle
        self.btn_ok:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
            local Msg = {}
            local index = 1
            for k,v in pairs(self.tableData) do
                if v then
                    Msg[index] = k
                    index = index + 1
                end
            end
            AlertManager:close(AlertManager.TWEEN_NONE)
            TFDirector:send(c2s.EQUIPMENT_SELL,{Msg})
            showLoading(); 
        end),1)
    end
    if self.btn_cancel then
        self.btn_cancel.logic   = self
        if cancelhandle then
            self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
                AlertManager:close(AlertManager.TWEEN_1)
                cancelhandle()
            end),1)
        else
            self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCancelBtnClickHandle),1)
        end
    end
end

function EquipSellPop.onCancelBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

function EquipSellPop:registerEvents()
    self.super.registerEvents(self)
end


function EquipSellPop:removeEvents()
    print("-----------removeEvents------------------")
    TFDirector:removeProto(s2c.EQUIPMENT_SELL_RESULT, self, self.sellEquipCallBack)
    self.btn_ok:removeMEListener(TFWIDGET_CLICK)
    self.btn_cancel:removeMEListener(TFWIDGET_CLICK)
    self.super.removeEvents(self)
end


function EquipSellPop:sellEquipCallBack( event )
    self.btn_ok.fun()
end


return EquipSellPop
