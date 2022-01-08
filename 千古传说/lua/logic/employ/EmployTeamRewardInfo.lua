--[[
******放置佣兵队伍*******

]]


local EmployTeamRewardInfo = class("EmployTeamRewardInfo", BaseLayer)

function EmployTeamRewardInfo:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.yongbing.EmployTeamBack")
end

function EmployTeamRewardInfo:initUI(ui)
    self.super.initUI(self,ui)

    self.txt_money = {}
    local txt_shouru= TFDirector:getChildByPath(ui, 'txt_shouru')
    self.txt_money[1]= TFDirector:getChildByPath(txt_shouru, 'txt_num')

    local txt_guyong= TFDirector:getChildByPath(ui, 'txt_guyong')
    self.txt_money[2]= TFDirector:getChildByPath(txt_guyong, 'txt_num')

    self.btn_guidui= TFDirector:getChildByPath(ui, 'btn_guidui')
    self.btn_paichu= TFDirector:getChildByPath(ui, 'btn_paichu')
end


function EmployTeamRewardInfo:removeUI()
    self.super.removeUI(self)
end

function EmployTeamRewardInfo:registerEvents()
    self.super.registerEvents(self)
    self.btn_guidui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onGuiDuiClick,play_lingqu))
    self.btn_paichu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onPaiChuClick,play_lingqu))
end

function EmployTeamRewardInfo:removeEvents()
    self.super.removeEvents(self)
end

function EmployTeamRewardInfo:dispose()
    self.super.dispose(self)
end


-----断线重连支持方法
function EmployTeamRewardInfo:onShow()
    self.super.onShow(self)
    self:refreshUI()
end


function EmployTeamRewardInfo:refreshUI()

end


function EmployTeamRewardInfo:showInfo( reward_list )
    for i=1,2 do
        self.txt_money[i]:setText(reward_list[i] or 0)
    end
end

function EmployTeamRewardInfo.onPaiChuClick(sender )
    AlertManager:close();
    EmployManager:sendTeamInfo()
end

function EmployTeamRewardInfo.onGuiDuiClick(sender )
    AlertManager:close();
    EmployManager:clearMyEmployTeamDetalis()
    TFDirector:dispatchGlobalEventWith(EmployManager.MyEmployTeamMessage ,{})

end


return EmployTeamRewardInfo
