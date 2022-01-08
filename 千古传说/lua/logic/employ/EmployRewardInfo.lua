--[[
******放置佣兵队伍*******

]]


local EmployRewardInfo = class("EmployRewardInfo", BaseLayer)

function EmployRewardInfo:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.yongbing.YongbingBack")
end

function EmployRewardInfo:initUI(ui)
    self.super.initUI(self,ui)

    self.txt_money = {}
    local txt_shouru= TFDirector:getChildByPath(ui, 'txt_shouru')
    self.txt_money[1]= TFDirector:getChildByPath(txt_shouru, 'txt_num')

    local txt_guyong= TFDirector:getChildByPath(ui, 'txt_guyong')
    self.txt_money[2]= TFDirector:getChildByPath(txt_guyong, 'txt_num')

    self.btn_ok= TFDirector:getChildByPath(ui, 'btn_ok')
end


function EmployRewardInfo:removeUI()
    self.super.removeUI(self)
end

function EmployRewardInfo:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_ok);
end

function EmployRewardInfo:removeEvents()
    self.super.removeEvents(self)
end

function EmployRewardInfo:dispose()
    self.super.dispose(self)
end


-----断线重连支持方法
function EmployRewardInfo:onShow()
    self.super.onShow(self)
    self:refreshUI()
end


function EmployRewardInfo:refreshUI()

end


function EmployRewardInfo:showInfo( reward_list )
    for i=1,2 do
        self.txt_money[i]:setText(reward_list[i] or 0)
    end
end


return EmployRewardInfo
