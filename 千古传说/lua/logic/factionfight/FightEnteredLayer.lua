--[[
******帮派战-报名界面*******

	-- by quanhuan
	-- 2016/2/22
	
]]

local FightEnteredLayer = class("FightEnteredLayer")

function FightEnteredLayer:ctor(data, layer)

    self.ui = data
    self.parentLayer = layer
    self:initUI(data)
end

function FightEnteredLayer:initUI( ui )
    local myNode = TFDirector:getChildByPath(ui, "img_bangpai")
    local localNode = TFDirector:getChildByPath(myNode, "txt_paiming")
    self.myRank = TFDirector:getChildByPath(localNode, "txt_num1")
    localNode = nil
    localNode = TFDirector:getChildByPath(myNode, "txt_fanrongdu")
    self.myFanRong = TFDirector:getChildByPath(localNode, "txt_num1")
    localNode = nil
    localNode = TFDirector:getChildByPath(myNode, "txt_time")
    self.endTime = TFDirector:getChildByPath(localNode, "txt_num1")

    self.FlagFrame = TFDirector:getChildByPath(ui, "img_qizhi")
    self.FlagIcon = TFDirector:getChildByPath(ui, "img_biaozhi")

    self.btn_baoming = TFDirector:getChildByPath(ui, "btn_baoming")
    self.img_jinji = TFDirector:getChildByPath(ui, "img_jinji")
    self.img_weijinji = TFDirector:getChildByPath(ui, "img_weijinji")

end


function FightEnteredLayer:removeUI()
    
end

function FightEnteredLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end

    self.btn_baoming:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnBaomingClick))

    --更新布阵信息
    self.updatePlayerListCallBack = function(event)
        local playerList = event.data[1].playerList;
        ZhengbaManager:qunHaoDefFormationSet( EnumFightStrategyType.StrategyType_AREAN, playerList[1].formation )
        ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_AREAN)
    end;
    TFDirector:addMEGlobalListener(ArenaManager.updatePlayerList ,self.updatePlayerListCallBack )

    --获取帮派繁荣排名信息
    self.updateRankSuccessCallBack = function (event)
        self:showDetailsInfo()
        self:showCutDownTimer()
    end
    TFDirector:addMEGlobalListener(FactionFightManager.updateRankSuccess, self.updateRankSuccessCallBack)

    self.registerEventCallFlag = true 
end

function FightEnteredLayer:removeEvents()

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end

    self.btn_baoming:removeMEListener(TFWIDGET_CLICK)

    if self.updatePlayerListCallBack then
        TFDirector:removeMEGlobalListener(ArenaManager.updatePlayerList ,self.updatePlayerListCallBack)
        self.updatePlayerListCallBack = nil
    end

    if self.updateRankSuccessCallBack then
        TFDirector:removeMEGlobalListener(FactionFightManager.updateRankSuccess, self.updateRankSuccessCallBack)    
        self.updateRankSuccessCallBack = nil
    end    
    self.registerEventCallFlag = nil  
end

function FightEnteredLayer:dispose()

end

function FightEnteredLayer:setVisible(v)
    
    self.ui:setVisible(v)
    if v then
        self:registerEvents()
        FactionFightManager:requestUpdateRank()
    else
        self:removeEvents()
    end
end

function FightEnteredLayer:showDetailsInfo()

    self.FlagFrame:setTexture(FactionManager:getMyBannerBgPath())
    self.FlagIcon:setTexture(FactionManager:getMyBannerIconPath())

    local data = FactionFightManager:getMyGuildBoomRank()
    
    if data.rank > 0 and data.rank <= 16 then
        self.img_jinji:setVisible(true)
        self.img_weijinji:setVisible(false)
        self.btn_baoming:setVisible(true)
        self.myRank:setText(data.rank)
        self.myFanRong:setText(data.boom)  
    else
        self.img_jinji:setVisible(false)
        self.img_weijinji:setVisible(true)
        self.btn_baoming:setVisible(false)
        --self.myRank:setText('未上榜')
	self.myRank:setText(localizable.faction_no_rank)
        self.myFanRong:setText(0)
    end
end

function FightEnteredLayer:showCutDownTimer()
    self.countDown = FactionFightManager:getCutDownTimeByState( FactionFightManager.ActivityState_2 )
    self.endTime:setText(FactionFightManager:getTimeString( self.countDown ))
    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end
    self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function () 
        if self.countDown <= 0 then
            if self.countDownTimer then
                TFDirector:removeTimer(self.countDownTimer)
                self.countDownTimer = nil
            end
            self.endTime:setText(FactionFightManager:getTimeString( self.countDown ))
        else
            self.countDown = self.countDown - 1
            self.endTime:setText(FactionFightManager:getTimeString( self.countDown ))
        end
    end)
end

function FightEnteredLayer.btnBaomingClick( btn ) 
    local data = FactionFightManager:getMyGuildBoomRank()
    if data.rank and data.rank <= 16 then
        local layer = require("lua.logic.factionfight.FightSignUp"):new()
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
        layer:updateMemberInfo()
        AlertManager:show()
    else
        --toastMessage('帮派未晋级')
	toastMessage(localizable.faction_no_levelup)
    end
end

return FightEnteredLayer