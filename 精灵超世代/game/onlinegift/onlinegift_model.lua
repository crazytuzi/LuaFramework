OnlineGiftModel = OnlineGiftModel or BaseClass()

function OnlineGiftModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function OnlineGiftModel:config()
end

function OnlineGiftModel:__delete()
end