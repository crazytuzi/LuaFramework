--[[
******放置佣兵队伍*******

]]


local EmployTeamLayer = class("EmployTeamLayer", BaseLayer)

function EmployTeamLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.yongbing.EmployRoleCell2")
end

function EmployTeamLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.btn_icon = {}
    for i=1,9 do
        self.btn_icon[i] = TFDirector:getChildByPath(ui, 'btn_icon'..i)
    end
    self.rolebg = {}
    for i=1,7 do
        self.rolebg[i] = TFDirector:getChildByPath(ui, 'rolebg'..i)
    end

    for i=1,6 do
        local icon_suo = TFDirector:getChildByPath(ui, 'icon_suo'..i)
        icon_suo:setVisible(false)
    end

    local txt_shouru = TFDirector:getChildByPath(ui, 'txt_shouru');
    self.txt_coin = TFDirector:getChildByPath(txt_shouru, 'txt_num');

    local txt_time = TFDirector:getChildByPath(ui, 'txt_time');
    self.txt_time_show = TFDirector:getChildByPath(txt_time, 'txt_num');

    local txt_cishu = TFDirector:getChildByPath(ui, 'txt_cishu');
    self.txt_cishu_show = TFDirector:getChildByPath(txt_cishu, 'txt_num');

    self.panel_reward= TFDirector:getChildByPath(ui, 'panel_reward')
    self.txt_miaoshu= TFDirector:getChildByPath(ui, 'txt_miaoshu')

    self.txt_zhanlizhi_word= TFDirector:getChildByPath(ui, 'txt_zhanlizhi_word')
    self.btn_help= TFDirector:getChildByPath(ui, 'btn_help')

    self.btn_guidui= TFDirector:getChildByPath(ui, 'btn_guidui')
    self.btn_lingqu= TFDirector:getChildByPath(ui, 'btn_lingqu')
    self.btn_paichu= TFDirector:getChildByPath(ui, 'btn_paichu')


    self.panel_buzhen= TFDirector:getChildByPath(ui, 'panel_buzhen')
end


function EmployTeamLayer:removeUI()
    self.super.removeUI(self)
end

function EmployTeamLayer:registerEvents()
    self.super.registerEvents(self)

    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.helpButtonClick))
    self.btn_guidui.logic = self
    self.btn_lingqu.logic = self
    self.btn_paichu.logic = self
    self.btn_guidui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.guiduiButtonClick,play_lingqu))
    self.btn_lingqu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.guiduiButtonClick,play_lingqu))
    self.btn_lingqu:setTextureNormal("ui_new/yongbing/btn_guidui.png")
    -- self.btn_lingqu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.lingquButtonClick,play_lingqu))
    self.btn_paichu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.paichuButtonClick,play_buzhenluoxia))
    self.panel_buzhen:addMEListener(TFWIDGET_CLICK, audioClickfun(self.paichuButtonClick,play_buzhenluoxia))

    self.MyEmployTeamMessageCallBack = function(event)
        self:refreshUI()
    end

    TFDirector:addMEGlobalListener(EmployManager.MyEmployTeamMessage, self.MyEmployTeamMessageCallBack)
end

function EmployTeamLayer:removeEvents()
    self.btn_help:removeMEListener(TFWIDGET_CLICK)


    TFDirector:removeMEGlobalListener(EmployManager.MyEmployTeamMessage, self.MyEmployTeamMessageCallBack)
    self.MyEmployTeamMessageCallBack = nil

    self.super.removeEvents(self)
end

function EmployTeamLayer:dispose()
    self.super.dispose(self)
end


-----断线重连支持方法
function EmployTeamLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()

end

function EmployTeamLayer:refreshUI()
    if EmployManager.myEmployTeamDetalis.battleRole == nil then
        self:showFree()
        return
    end
    self:showInfo()
end

function EmployTeamLayer:showFree()
    for i=1,9 do
        self.btn_icon[i]:setVisible(false)
    end
    for i=1,7 do
        self.rolebg[i]:setVisible(false)
    end
    self.panel_reward:setVisible(false)
    self.txt_miaoshu:setVisible(true)
    self.txt_coin:setText(0)
    --self.txt_time_show:setText("未派遣")
    self.txt_time_show:setText(localizable.EmTeamLayer_text1)
    --self.txt_cishu_show:setText("未派遣")
    self.txt_cishu_show:setText(localizable.EmTeamLayer_text1)
    self.txt_zhanlizhi_word:setText(0)
    self.btn_guidui:setVisible(false)
    self.btn_lingqu:setVisible(false)
    self.btn_paichu:setVisible(true)
    self.panel_buzhen:setTouchEnabled(true)
end

function EmployTeamLayer:showInfo()
    for i=1,9 do
        self.btn_icon[i]:setVisible(false)
    end

    for i=1,#EmployManager.myEmployTeamDetalis.battleRole do
        local info = EmployManager.myEmployTeamDetalis.battleRole[i]
        local pos = info.position +1
        local roleInfo = CardRoleManager:getRoleByGmid( info.instanceId )
        if roleInfo then
            self.btn_icon[pos]:setVisible(true)
            local img_touxiang = TFDirector:getChildByPath(self.btn_icon[pos],"img_touxiang")
            img_touxiang:setTexture(roleInfo:getHeadPath())
            local img_zhiye = TFDirector:getChildByPath(self.btn_icon[pos],"img_zhiye")
            img_zhiye:setTexture("ui_new/fight/zhiye_".. roleInfo.outline ..".png")

            self.btn_icon[pos]:setTextureNormal(GetColorRoadIconByQuality(roleInfo.quality))
            Public:addLianTiEffect(img_touxiang,roleInfo:getMaxLianTiQua(),true)
        end
    end

    for i=1,7 do
        self.rolebg[i]:setVisible(false)
    end
    if EmployManager.myEmployTeamDetalis.assistant then
        for i=1,#EmployManager.myEmployTeamDetalis.assistant do
            local info = EmployManager.myEmployTeamDetalis.assistant[i]
            local pos = info.position +1
            local roleInfo = CardRoleManager:getRoleByGmid( info.instanceId )
            if roleInfo then
                self.rolebg[pos]:setVisible(true)
                self.rolebg[pos]:setTexture(GetColorRoadIconByQuality(roleInfo.quality))
                local img_role = TFDirector:getChildByPath(self.rolebg[pos],"img_role")
                img_role:setTexture(roleInfo:getHeadPath())
            end
        end
    end


    self.panel_reward:setVisible(true)
    self.txt_miaoshu:setVisible(false)

    self.txt_coin:setText(EmployManager.myEmployTeamDetalis.coin)

    self.txt_time_show:setText(self:showTime(EmployManager.myEmployTeamDetalis.startTime))
    -- self.txt_cishu_show:setText(EmployManager.myEmployTeamDetalis.employCount.."次")
    self.txt_cishu_show:setText(stringUtils.format(localizable.common_times, EmployManager.myEmployTeamDetalis.employCount))
    
    self.txt_zhanlizhi_word:setText(ZhengbaManager:getPower(EnumFightStrategyType.StrategyType_MERCENARY_TEAM))
    self.btn_guidui:setVisible(false)
    self.btn_lingqu:setVisible(true)
    self.btn_paichu:setVisible(false)
    self.panel_buzhen:setTouchEnabled(false)
end

function EmployTeamLayer:showTime( startTime )
    local temp = MainPlayer:getNowtime() - startTime
    local hour = math.floor(temp/3600)
    local min = math.floor( (temp - hour*3600)/60)
    if hour > 0 then
        --return string.format("%d小时%d分钟",hour,min)
        return stringUtils.format(localizable.common_time_1,hour,min)
    end
    --return string.format("%d分钟",min)
    return stringUtils.format(localizable.common_time_2,min)
end

function EmployTeamLayer.helpButtonClick(sender)
    CommonManager:showRuleLyaer('yongbingshuoming')
end
function EmployTeamLayer.guiduiButtonClick(sender)
    local tempTime = MainPlayer:getNowtime() - EmployManager.myEmployTeamDetalis.startTime
    if tempTime < 1800 then
        -- toastMessage("最少要30分钟才能归队")
        toastMessage(localizable.Mercenary_The_team_returned_to_limit)
        return
    end
    EmployManager:merceanryTeamOperation( EmployManager.RemoveEmployTeam )
end

function EmployTeamLayer.lingquButtonClick(sender)
    local tempTime = MainPlayer:getNowtime() - EmployManager.myEmployTeamDetalis.startTime
    if tempTime < 1800 then
        -- toastMessage("最少要30分钟才能领取")
        toastMessage(localizable.Mercenary_The_team_returned_to_limit)
        return
    end
    EmployManager:merceanryTeamOperation( EmployManager.GetRewardEmployTeam )
end

function EmployTeamLayer.paichuButtonClick(sender)
    EmployManager:openArmyLayer()
end

return EmployTeamLayer
