--[[
******自动更新确定*******

    -- by king
    -- 2015/11/13
]]

local UpdateNotice = class("UpdateNotice", BaseLayer)

--CREATE_SCENE_FUN(UpdateNotice)
CREATE_PANEL_FUN(UpdateNotice)


function UpdateNotice:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.login.UpdateNotice")
end

function UpdateNotice:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok        = TFDirector:getChildByPath(ui, 'btn_comfirm')
    self.txt_content   = TFDirector:getChildByPath(ui, 'txt_content')
    self.txt_title     = TFDirector:getChildByPath(ui, 'txt_title')

end

function UpdateNotice:removeUI()
	self.super.removeUI(self)
end

function UpdateNotice:setTitle(title)
    if self.txt_title then
        self.txt_title:setText(title)
    end
end

function UpdateNotice:setcontent( content )
    if self.txt_content then
        self.txt_content:setText(content)
    end
end

function UpdateNotice:setBtnHandle(okhandle)
    if self.btn_ok then
        self.btn_ok.logic       = self
        self.btn_ok:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
            local data = self.data;
            AlertManager:close()
            okhandle(data)
        end),1)
    end

end

function UpdateNotice:registerEvents()
    self.super.registerEvents(self)
end


return UpdateNotice
