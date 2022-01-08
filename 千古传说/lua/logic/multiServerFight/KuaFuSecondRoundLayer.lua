--[[
******跨服个人战-淘汰赛第二轮*******

	-- by quanhuan
	-- 2016/2/22
	
]]

local KuaFuSecondRoundLayer = class("KuaFuSecondRoundLayer",BaseLayer)

PanelCount = {[2] = 4,[3] = 2,[4] = 1}
function KuaFuSecondRoundLayer:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.kuafuwulin.KuaFu_8qiang")
end

function KuaFuSecondRoundLayer:initUI( ui )

	self.super.initUI(self, ui)
    self.copyUi = ui
    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.KFWLDH,{HeadResType.SYCEE})

    self.btn_guizhe = TFDirector:getChildByPath(ui, 'btn_guizhe')
    self.btn_jiangli = TFDirector:getChildByPath(ui, 'btn_jiangli')
    self.btn_zhanbao = TFDirector:getChildByPath(ui, 'btn_zhanbao')

    local bg = TFDirector:getChildByPath(ui, 'bg')
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/zhengbasai_jifen_bg.xml")
    local effect = TFArmature:create("zhengbasai_jifen_bg_anim")
    effect:setPosition(ccp(568,320))
    bg:addChild(effect,100)
    effect:playByIndex(0,-1,-1,1)
end

function KuaFuSecondRoundLayer:reLoadUI()
    local ui = self.copyUi

    local Panel_shaichen = TFDirector:getChildByPath(ui, "Panel_shaichen")
    local panelName = {'Panel_8to4','Panel_4to2','Panel_2to1'}
    local dataNode
    for i=1,3 do
        local index = i+1
        local pointNode = TFDirector:getChildByPath(Panel_shaichen, 'y'..i)
        if index == self.currRound then
            dataNode = TFDirector:getChildByPath(ui, panelName[i])
            dataNode:setVisible(true)
            pointNode:setTexture('ui_new/Zhenbashai/img_yuandian2.png')
        else
            local otherNode = TFDirector:getChildByPath(ui, panelName[i])
            otherNode:setVisible(false)
            pointNode:setTexture('ui_new/Zhenbashai/img_yuandian1.png')
        end
    end

    self.playerData = {}    
    for i=1,self.currPanelCount do
        local playerNode = TFDirector:getChildByPath(dataNode, 'panel_'..i)
        self.playerData[i] = {}

        local atkNode = TFDirector:getChildByPath(playerNode, 'role1_bg')
        self.playerData[i].atkHeadIcon = TFDirector:getChildByPath(atkNode, 'icon_head')
        self.playerData[i].atkHeadFrame = TFDirector:getChildByPath(atkNode, 'img_di')
        self.playerData[i].atkWinIcon = TFDirector:getChildByPath(atkNode, 'icon_sheng')
        self.playerData[i].atkLoseIcon = TFDirector:getChildByPath(atkNode, 'icon_fu')
        self.playerData[i].atkYiYaImg = TFDirector:getChildByPath(atkNode, 'icon_yiya')
        self.playerData[i].atkName = TFDirector:getChildByPath(atkNode, 'txt_name')        
        self.playerData[i].atkBtnYazhu = TFDirector:getChildByPath(atkNode, 'btn_yazhu')

        local defNode = TFDirector:getChildByPath(playerNode, 'role2_bg')
        self.playerData[i].defHeadIcon = TFDirector:getChildByPath(defNode, 'icon_head')
        self.playerData[i].defHeadFrame = TFDirector:getChildByPath(defNode, 'img_di')
        self.playerData[i].defWinIcon = TFDirector:getChildByPath(defNode, 'icon_sheng')
        self.playerData[i].defLoseIcon = TFDirector:getChildByPath(defNode, 'icon_fu')
        self.playerData[i].defYiYaImg = TFDirector:getChildByPath(defNode, 'icon_yiya')
        self.playerData[i].defName = TFDirector:getChildByPath(defNode, 'txt_name')        
        self.playerData[i].defBtnYazhu = TFDirector:getChildByPath(defNode, 'btn_yazhu')

        self.playerData[i].btnReport = TFDirector:getChildByPath(playerNode, 'btn_zhanbao1')
        self.playerData[i].effectNode = TFDirector:getChildByPath(dataNode, 'panelAnim'..i)

        TFResourceHelper:instance():addArmatureFromJsonFile("effect/weekFight.xml")
        local effect = TFArmature:create("weekFight_anim")
        effect:setPosition(ccp(0,0))
        effect:setScale(0.5)
        self.playerData[i].effectNode:addChild(effect,100)
        effect:playByIndex(0,-1,-1,1)
        self.playerData[i].effect = effect
        self.playerData[i].effect:setVisible(false)
    end

    self.tipsNode = TFDirector:getChildByPath(dataNode, 'bg_yazhushijian')
    self.txtTips = TFDirector:getChildByPath(self.tipsNode, 'txt_time')
    self.txtTime = TFDirector:getChildByPath(self.tipsNode, 'txt_num')

    local Panel_Content = TFDirector:getChildByPath(ui, "Panel_Content")
    local img_title = TFDirector:getChildByPath(Panel_Content, "img_title")
    local img_title2 = TFDirector:getChildByPath(Panel_Content, "img_title2")

    if self.currRound == 2 then
        img_title:setVisible(true)
        img_title2:setVisible(false)
    else
        img_title:setVisible(false)
        img_title2:setVisible(true)
    end


end
function KuaFuSecondRoundLayer:removeUI()
	self.super.removeUI(self)
end

function KuaFuSecondRoundLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function KuaFuSecondRoundLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.CrossBetUpdateCallBack = function (event)
        self:showCutDownTimer()
    end
    TFDirector:addMEGlobalListener(MultiServerFightManager.CrossBetUpdate, self.CrossBetUpdateCallBack)

    self.btn_guizhe:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnRuleClick))
    self.btn_jiangli:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnRewardClick))
    self.btn_zhanbao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnReportClick))
    self.btn_zhanbao.logic = self

    self.registerEventCallFlag = true 
end

function KuaFuSecondRoundLayer:removeEvents()

    self.super.removeEvents(self)

	if self.generalHead then
        self.generalHead:removeEvents()
    end	

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end

    self.btn_guizhe:removeMEListener(TFWIDGET_CLICK)
    self.btn_jiangli:removeMEListener(TFWIDGET_CLICK)
    self.btn_zhanbao:removeMEListener(TFWIDGET_CLICK)

    if self.CrossBetUpdateCallBack then
        TFDirector:removeMEGlobalListener(MultiServerFightManager.CrossBetUpdate, self.CrossBetUpdateCallBack)  
        self.CrossBetUpdateCallBack = nil
    end

    self.registerEventCallFlag = nil  
end

function KuaFuSecondRoundLayer:dispose()
	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end    
end

function KuaFuSecondRoundLayer:setData(data)
    print('data = ',data)
    self.currPanelCount = PanelCount[data]
    self.currRound = data
    self.currTimeState = data + 4
    self.reportRound = self.currRound - 1
    self:reLoadUI()
    self:showCutDownTimer()
end

function KuaFuSecondRoundLayer:showFightDetailsInfo()

    local fightData = MultiServerFightManager:getFightDataByRound(self.currRound)

    -- print('fightData = ',fightData)
    for i=1,self.currPanelCount do
        local data = fightData[i]
        local playerNode = self.playerData[i]
        playerNode.atkHeadIcon:setVisible(false)
        playerNode.atkHeadIcon:setTouchEnabled(true)
        playerNode.atkHeadIcon.dataIndex = i
        playerNode.atkHeadIcon.logic = self
        playerNode.atkHeadIcon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnAtkHeadClick))

        playerNode.atkWinIcon:setVisible(false)
        playerNode.atkLoseIcon:setVisible(false)
        playerNode.atkYiYaImg:setVisible(false)
        playerNode.atkName:setVisible(false)
        playerNode.atkBtnYazhu:setVisible(true)
        playerNode.atkBtnYazhu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnYazhuClick))

        playerNode.defHeadIcon:setVisible(false)
        playerNode.defHeadIcon:setTouchEnabled(true)
        playerNode.defHeadIcon.dataIndex = i
        playerNode.defHeadIcon.logic = self
        playerNode.defHeadIcon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnDefHeadClick))

        playerNode.defWinIcon:setVisible(false)
        playerNode.defLoseIcon:setVisible(false)
        playerNode.defYiYaImg:setVisible(false)
        playerNode.defName:setVisible(false)
        playerNode.defBtnYazhu:setVisible(true)
        playerNode.defBtnYazhu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnYazhuClick))

        playerNode.btnReport:setVisible(false)
        playerNode.btnReport:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnReportClick))

        playerNode.effect:setVisible(false)

        if data then
            if data.atkPlayerId then
                playerNode.atkHeadIcon:setVisible(true)
                local RoleIcon = RoleData:objectByID(data.atkIcon)
                playerNode.atkHeadIcon:setTexture(RoleIcon:getIconPath())
                Public:addFrameImg(playerNode.atkHeadIcon,data.atkHeadPicFrame)
                -- Public:addInfoListen(playerNode.atkHeadIcon,true,1,data.atkPlayerId)
                playerNode.atkName:setVisible(true)
                playerNode.atkName:setText(data.atkPlayerName)
                playerNode.atkBtnYazhu.logic = self
                playerNode.atkBtnYazhu.playerId = data.atkPlayerId
                playerNode.atkBtnYazhu.index = data.index
            end

            if data.defPlayerId then
                playerNode.defHeadIcon:setVisible(true)
                local RoleIcon = RoleData:objectByID(data.defIcon)
                playerNode.defHeadIcon:setTexture(RoleIcon:getIconPath())
                Public:addFrameImg(playerNode.defHeadIcon,data.defHeadPicFrame)
                -- Public:addInfoListen(playerNode.defHeadIcon,true,1,data.defPlayerId)
                playerNode.defName:setVisible(true)
                playerNode.defName:setText(data.defPlayerName)
                playerNode.defBtnYazhu.logic = self
                playerNode.defBtnYazhu.playerId = data.defPlayerId
                playerNode.defBtnYazhu.index = data.index
            else
                playerNode.defBtnYazhu:setVisible(false)
                playerNode.atkBtnYazhu:setVisible(false)
            end

            if data.betPlayerId and data.betPlayerId ~= 0 then
                playerNode.defBtnYazhu:setVisible(false)
                playerNode.atkBtnYazhu:setVisible(false)
                if data.betPlayerId == data.atkPlayerId then
                    playerNode.atkYiYaImg:setVisible(true)
                elseif data.betPlayerId == data.defPlayerId then
                    playerNode.defYiYaImg:setVisible(true)
                end
            end

            if data.winPlayerId and data.winPlayerId ~= 0 then
                if data.winPlayerId == data.atkPlayerId then
                    playerNode.atkWinIcon:setVisible(true)
                    if data.defPlayerId ~= nil then
                        playerNode.defLoseIcon:setVisible(true)
                    end
                else
                    playerNode.atkLoseIcon:setVisible(true)
                    playerNode.defWinIcon:setVisible(true)
                end
            end            

            playerNode.btnReport.logic = self
            if (data.winPlayerId and data.winPlayerId ~= 0) and (data.defPlayerId and data.defPlayerId ~= 0) then
                playerNode.btnReport:setVisible(true)
                playerNode.btnReport.replayId = data.replayId
            end
        else
            playerNode.defBtnYazhu:setVisible(false)
            playerNode.atkBtnYazhu:setVisible(false)
        end
    end
end
function KuaFuSecondRoundLayer:showCutDownTimer()
    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end
    self:showFightDetailsInfo()
    local timeInfo = MultiServerFightManager:getFightTimeByState( self.currTimeState )
    local currTime = MultiServerFightManager:getCurrSecond()
    if currTime < timeInfo.fightTime then
        --押注时间
        for i=1,self.currPanelCount do
            local playerNode = self.playerData[i]            
            playerNode.atkWinIcon:setVisible(false)
            playerNode.atkLoseIcon:setVisible(false)
            playerNode.defWinIcon:setVisible(false)
            playerNode.defLoseIcon:setVisible(false)
            playerNode.btnReport:setVisible(false)
        end
        self.tipsNode:setVisible(true)
        self.txtTips:setText(localizable.multiFight_yzsyTime)
        local countDown = timeInfo.fightTime - currTime
        self.txtTime:setText(FactionManager:getTimeString(countDown))
        self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function ()
            -- print('countDown = ',countDown)
            if countDown <= 0 then
                if self.countDownTimer then
                    TFDirector:removeTimer(self.countDownTimer)
                    self.countDownTimer = nil
                end
                self:showCutDownTimer()
            else
                countDown = countDown - 1
                self.txtTime:setText(FactionManager:getTimeString(countDown))
            end
        end)
    elseif currTime < timeInfo.endTime then
        --战斗时间
        for i=1,self.currPanelCount do
            local playerNode = self.playerData[i]            
            playerNode.atkBtnYazhu:setVisible(false)
            playerNode.atkWinIcon:setVisible(false)
            playerNode.atkLoseIcon:setVisible(false)
            playerNode.defBtnYazhu:setVisible(false)
            playerNode.defWinIcon:setVisible(false)
            playerNode.defLoseIcon:setVisible(false)
            playerNode.btnReport:setVisible(false)

            playerNode.effect:setVisible(true)
            playerNode.effect:playByIndex(0,-1,-1,1)
        end
        self.tipsNode:setVisible(true)
        self.txtTips:setText(localizable.multiFight_fightTime)
        local countDown = timeInfo.endTime - currTime
        self.txtTime:setText(FactionManager:getTimeString(countDown))
        self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function ()
            if countDown <= 0 then
                if self.countDownTimer then
                    TFDirector:removeTimer(self.countDownTimer)
                    self.countDownTimer = nil
                end
                self:showCutDownTimer()
            else
                countDown = countDown - 1
                self.txtTime:setText(FactionManager:getTimeString(countDown))
            end
        end)
    else--if currTime < timeInfo.nextFightTime then
        --战斗结果展示
        self.reportRound = self.currRound
        for i=1,self.currPanelCount do
            local playerNode = self.playerData[i]
            playerNode.atkBtnYazhu:setVisible(false)
            playerNode.defBtnYazhu:setVisible(false)
        end
        self.tipsNode:setVisible(true)
        self.txtTips:setText(localizable.multiFight_viewTime)
        local countDown = timeInfo.nextFightTime - currTime
        if countDown <= 0 then
            countDown = 0
        end
        self.txtTime:setText(FactionManager:getTimeString(countDown))
        self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function ()
            if countDown <= 0 then
                if self.countDownTimer then
                    TFDirector:removeTimer(self.countDownTimer)
                    self.countDownTimer = nil
                end
                -- self:showCutDownTimer()
                MultiServerFightManager:switchFightLayer()
            else
                countDown = countDown - 1
                self.txtTime:setText(FactionManager:getTimeString(countDown))
            end
        end)
    -- else
        --显示下一轮信息
        -- self.reportRound = self.currRound
        -- MultiServerFightManager:openCurrLayer()
    end
end

function KuaFuSecondRoundLayer.btnRuleClick( btn )
    MultiServerFightManager:openRuleLayer()
end

function KuaFuSecondRoundLayer.btnRewardClick( btn )
    MultiServerFightManager:openRewardLayer()
end

function KuaFuSecondRoundLayer.btnReportClick( btn )
    local self = btn.logic
    MultiServerFightManager:openReportLayer(self.reportRound)
end

function KuaFuSecondRoundLayer.onBtnYazhuClick( btn )
    local self = btn.logic
    local layer = AlertManager:addLayerByFile("lua.logic.multiServerFight.KuaFuBetsLayer",AlertManager.BLOCK_AND_GRAY_CLOSE)
    layer:setData(btn.playerId, self.currRound, btn.index)
    AlertManager:show()
end

function KuaFuSecondRoundLayer.onBtnReportClick( btn )
    MultiServerFightManager:onBtnReportClick( btn.replayId )
end

function KuaFuSecondRoundLayer.onBtnAtkHeadClick( btn )
    local index = btn.dataIndex
    local self = btn.logic
    local fightData = MultiServerFightManager:getFightDataByRound(self.currRound) or {}
    if fightData[index] and fightData[index].atkPlayerId then
        local data = {}
        data.playerName = fightData[index].atkPlayerName
        data.serverName = fightData[index].atkServerName
        data.power = fightData[index].atkPower
        data.headIcon = fightData[index].atkIcon
        data.headFrame = fightData[index].atkHeadPicFrame
        local layer = require("lua.logic.multiServerFight.KuaFuCheckLayer"):new()
        layer:setData(data)
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_NONE)
        AlertManager:show()
    end    
end

function KuaFuSecondRoundLayer.onBtnDefHeadClick( btn )
    local index = btn.dataIndex
    local self = btn.logic
    local fightData = MultiServerFightManager:getFightDataByRound(self.currRound) or {}
    if fightData[index] and fightData[index].defPlayerId then
        local data = {}
        data.playerName = fightData[index].defPlayerName
        data.serverName = fightData[index].defServerName
        data.power = fightData[index].defPower
        data.headIcon = fightData[index].defIcon
        data.headFrame = fightData[index].defHeadPicFrame
        local layer = require("lua.logic.multiServerFight.KuaFuCheckLayer"):new()
        layer:setData(data)
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_NONE)
        AlertManager:show()
    end    
end
return KuaFuSecondRoundLayer