--[[
******操作确定层*******

    -- by quanhuan
    -- 2015/11/10
]]

local jsTipsPop = class("jsTipsPop", BaseLayer)


CREATE_PANEL_FUN(jsTipsPop)


function jsTipsPop:ctor(data)
    self.super.ctor(self,data)
end

function jsTipsPop:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.btn_cancel         = TFDirector:getChildByPath(ui, 'btn_cancel')
    self.txt_message        = TFDirector:getChildByPath(ui, 'txt_message')
    self.txt_title          = TFDirector:getChildByPath(ui, 'txt_title')
    self.img_title          = TFDirector:getChildByPath(ui, 'img_title')
    self.txt_tips           = TFDirector:getChildByPath(ui, 'txt_tips')

end

function jsTipsPop:removeUI()
	self.super.removeUI(self)

    self.btn_ok             = nil
    self.btn_cancel         = nil
end

function jsTipsPop:setData( data )
    self.data = data
end

function jsTipsPop:setUIConfig( uiconfig )
    self:init(uiconfig)
end

function jsTipsPop:setTitleImg( path )
    if self.img_title and path then
        self.img_title:setTexture(path)
    end
end

function jsTipsPop:setBtnOkText( text )
    if self.btn_ok and text then
        self.btn_ok:setText(text)
    end
end

function jsTipsPop:setBtnCancelText( text )
    if self.btn_cancel and text then
        self.btn_cancel:setText(text)
    end
end

function jsTipsPop:setTitle( title )
    if self.txt_title and title then
        self.txt_title:setText(title)
    end
end

function jsTipsPop:setMsg( msg )
    if self.txt_message and msg then
        self.txt_message:setText(msg)
    end
end

function jsTipsPop:setTipsMsg( msg )
    if self.txt_tips and msg then
        self.txt_tips:setText(msg)
    end
end

function jsTipsPop:setBtnHandle(okhandle, cancelhandle)
    if self.btn_ok then
        self.btn_ok.logic       = self
        self.btn_ok:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
            local data = self.data;
            AlertManager:close()
            okhandle(data)
        end),1)
    end
    if self.btn_cancel then
        self.btn_cancel.logic   = self
        if cancelhandle then
            self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
                cancelhandle(self.data)
            end),1)
        else
            self.btn_cancel:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCancelBtnClickHandle),1)
        end
    end

end

function jsTipsPop.onCancelBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

function jsTipsPop:registerEvents()
    self.super.registerEvents(self)
end


return jsTipsPop
