--[[
******操作确定层*******

    -- by Stephen.tao
    -- 2014/2/27
]]

local OperateSureTip = class("OperateSureTip", BaseLayer)

--CREATE_SCENE_FUN(OperateSureTip)
CREATE_PANEL_FUN(OperateSureTip)


function OperateSureTip:ctor(data)
    self.super.ctor(self,data)
end

function OperateSureTip:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.btn_cancel         = TFDirector:getChildByPath(ui, 'btn_cancel')
    self.txt_message        = TFDirector:getChildByPath(ui, 'txt_message')
    self.txt_title          = TFDirector:getChildByPath(ui, 'txt_title')
    self.img_title          = TFDirector:getChildByPath(ui, 'img_title')
    self.img_title          = TFDirector:getChildByPath(ui, 'img_title')
    self.checkbox_tip          = TFDirector:getChildByPath(ui, 'CheckBox_Game_1')

end

function OperateSureTip:removeUI()
	self.super.removeUI(self)

    self.btn_ok             = nil
    self.btn_cancel         = nil
end

function OperateSureTip:setData( data )
    self.data = data
end

function OperateSureTip:setUIConfig( uiconfig )
    self:init(uiconfig)
end

function OperateSureTip:setTitleImg( path )
    if self.img_title and path then
        self.img_title:setTexture(path)
    end
end

function OperateSureTip:setBtnOkText( text )
    if self.btn_ok and text then
        self.btn_ok:setText(text)
    end
end

function OperateSureTip:setBtnCancelText( text )
    if self.btn_cancel and text then
        self.btn_cancel:setText(text)
    end
end

function OperateSureTip:setTitle( title )
    if self.txt_title and title then
        self.txt_title:setText(title)
    end
end

function OperateSureTip:setMsg( msg )
    if self.txt_message and msg then
        self.txt_message:setText(msg)
    end
end

function OperateSureTip:setBtnHandle(okhandle, cancelhandle)
    if self.btn_ok then
        self.btn_ok.logic       = self
        self.btn_ok:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
            local data = self.data;
            AlertManager:close()
            okhandle(data,self.checkbox_tip)
        end),1)
    end
    if self.btn_cancel then
        self.btn_cancel.logic   = self
        if cancelhandle then
            self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
                cancelhandle(self.data,self.checkbox_tip)
            end),1)
        else
            self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCancelBtnClickHandle),1)
        end
    end
end

function OperateSureTip.onCancelBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

function OperateSureTip:registerEvents()
    self.super.registerEvents(self)
end


return OperateSureTip
