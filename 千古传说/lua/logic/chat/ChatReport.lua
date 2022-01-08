--[[
    举报玩家
    quanhuan
    2015-11-18 19:16:43
]]

local ChatReport = class("ChatReport", BaseLayer)


local myStruct = {
    btnCount = 3,
    btnName = {"btn_Cheat","btn_ad","btn_chat"},       
}

function ChatReport:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.chat.ChatReport")
end

function ChatReport:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")

    self.btnTable = {}
    for i=1,myStruct.btnCount do
        self.btnTable[i] = TFDirector:getChildByPath(ui, myStruct.btnName[i])
    end
end

function ChatReport:onShow()
    self.super.onShow(self)
end

function ChatReport:dispose()
    self.super.dispose(self)
end

function ChatReport:onHide()
end

function ChatReport:registerEvents()
	self.super.registerEvents(self)

    for i=1,myStruct.btnCount do
        self.btnTable[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickBtnTableHandle))
        self.btnTable[i].logic = self
        self.btnTable[i].idx = i
    end
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickCloseHandle))    
end

function ChatReport:removeEvents()
    self.super.removeEvents(self)

    for i=1,myStruct.btnCount do
        self.btnTable[i]:removeMEListener(TFWIDGET_CLICK)
    end    
    self.btn_close:removeMEListener(TFWIDGET_CLICK)
end

function ChatReport.onClickBtnTableHandle(btn)

    local self = btn.logic
    local msg = {self.playerId, btn.idx}
    TFDirector:send(c2s.REPORT_PLAYER_REQUEST, msg)
    AlertManager:close()
    showLoading();
end

function ChatReport:setData(playerId)

    self.playerId = playerId

end

function ChatReport.onClickCloseHandle( btn )
    AlertManager:close()
end

return ChatReport