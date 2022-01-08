--[[
    指导员禁言 
    quanhuan
    2015-11-18 19:16:43
]]

local ChatBanned = class("ChatBanned", BaseLayer)


local myStruct = {
    btnCount = 3,
    btnName = {"btn_hour","btn_day","btn_forever"},
    btnNormalTexture = {"ui_new/chat/btn_hour.png","ui_new/chat/btn_day.png","ui_new/chat/btn_forever.png"},
    btnSelectTexture = {"ui_new/chat/btn_hour_1.png","ui_new/chat/btn_day_1.png","ui_new/chat/btn_forever_1.png"},    
}

function ChatBanned:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.chat.ChatBanned")
end

function ChatBanned:initUI(ui)
	self.super.initUI(self,ui)

    self.txt_name = TFDirector:getChildByPath(ui, "txt_name")
    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")

    self.btnTable = {}
    for i=1,myStruct.btnCount do
        self.btnTable[i] = TFDirector:getChildByPath(ui, myStruct.btnName[i])
    end
    self.btn_ok = TFDirector:getChildByPath(ui, "btn_ok") 
end

function ChatBanned:onShow()
    self.super.onShow(self)
end

function ChatBanned:dispose()
    self.super.dispose(self)
end

function ChatBanned:onHide()
end

function ChatBanned:registerEvents()
	self.super.registerEvents(self)

    for i=1,myStruct.btnCount do
        self.btnTable[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickBtnTableHandle))
        self.btnTable[i].logic = self
        self.btnTable[i].idx = i
    end
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickCloseHandle))
    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickOKHandle))
    self.btn_ok.logic = self
end

function ChatBanned:removeEvents()
    self.super.removeEvents(self)

    for i=1,myStruct.btnCount do
        self.btnTable[i]:removeMEListener(TFWIDGET_CLICK)
    end    
    self.btn_ok:removeMEListener(TFWIDGET_CLICK)
    self.btn_close:removeMEListener(TFWIDGET_CLICK)
end

function ChatBanned.onClickBtnTableHandle(btn)

    local self = btn.logic
    self.selectIdx = btn.idx
    for k,v in pairs(self.btnTable) do
        if v == btn then
            v:setTextureNormal(myStruct.btnSelectTexture[k])
        else
            v:setTextureNormal(myStruct.btnNormalTexture[k])
        end
    end
end

function ChatBanned.onClickOKHandle(btn)  

    local self = btn.logic
    if self.selectIdx ~= 0 then
        local msg = {self.playerId, self.selectIdx}

        TFDirector:send(c2s.GAG_PLAYER_REQUEST, msg) 
        AlertManager:close()
        showLoading();
    else
        --toastMessage("请选择禁言按钮")
        toastMessage(localizable.chatBanned_no_speak)

    end
end

function ChatBanned:setData(playerId, playerName)
    self.playerId = playerId
    self.playerName = playerName
    self.selectIdx = 0

    self.txt_name:setText(playerName)
end

function ChatBanned.onClickCloseHandle( btn )
    AlertManager:close()
end

return ChatBanned