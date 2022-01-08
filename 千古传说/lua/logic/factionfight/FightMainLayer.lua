--[[
******帮派战-主界面*******

	-- by quanhuan
	-- 2016/2/22
	
]]

local FightMainLayer = class("FightMainLayer",BaseLayer)

function FightMainLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionFightMain")
end

function FightMainLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.FactionFight,{HeadResType.COIN})


    self.btn_guizhe = TFDirector:getChildByPath(ui, "btn_guizhe")
    self.btn_jiangli = TFDirector:getChildByPath(ui, "btn_jiangli")
    self.btn_zhankuang = TFDirector:getChildByPath(ui, "btn_zhankuang")

    self.btn_buzhen = TFDirector:getChildByPath(ui, "btn_buzhen")
    self.btn_yuxuan = TFDirector:getChildByPath(ui, 'btn_yuxuan')
    self.btn_duizhan = TFDirector:getChildByPath(ui, "btn_duizhan")

    local panelContentNode = TFDirector:getChildByPath(ui, 'Panel_Content1')
    panelContentNode:setVisible(true)
    self.img_yuxuan = TFDirector:getChildByPath(panelContentNode, 'img_yuxuan')
    self.img_hongdi = TFDirector:getChildByPath(panelContentNode, 'img_hongdi')
    

    self.layerList = {}
    local layerNode = {'panel_yuxuan', 'panel_baoming', 'panel_jieguo'}
    local layerName = {
        'lua.logic.factionfight.FightReadyLayer',
        'lua.logic.factionfight.FightEnteredLayer',
        'lua.logic.factionfight.FightResultLayer'
    }
    for k,v in pairs(layerNode) do
        local panelNode = TFDirector:getChildByPath(ui, v)
        panelNode:setVisible(false)
        self.layerList[#self.layerList + 1] = require(layerName[k]):new(panelNode,self)
    end
end


function FightMainLayer:removeUI()
	self.super.removeUI(self)

    if self.layerList then
        for _,v in pairs(self.layerList) do
            v:removeUI()
        end
    end
end

function FightMainLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function FightMainLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    if self.layerList then
        for _,v in pairs(self.layerList) do
            v:registerEvents()
        end
    end

    self.btn_guizhe:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnGuizheClick))
    self.btn_jiangli:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnJiangliClick))
    self.btn_zhankuang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnZhankuangClick))
    self.btn_buzhen:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnBuzhenClick))
    self.btn_yuxuan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnYuxuanClick))
    self.btn_duizhan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnDuizhanClick))

    self.activityStateChangeCallBack = function (event)
        local state = FactionFightManager:getActivityState()
        if state == FactionFightManager.ActivityState_1 or state == FactionFightManager.ActivityState_2 then
            self:switchShowLayer(state)
        elseif state == FactionFightManager.ActivityState_4 then
            self:switchShowLayer(state-1)
        else
            FactionFightManager:switchToFightOrMainLayer(self)
        end        
    end
    TFDirector:addMEGlobalListener(FactionFightManager.activityStateChange, self.activityStateChangeCallBack) 

    self.registerEventCallFlag = true 
end

function FightMainLayer:removeEvents()

    self.super.removeEvents(self)

	if self.generalHead then
        self.generalHead:removeEvents()
    end
 	
    if self.layerList then
        for _,v in pairs(self.layerList) do
            v:removeEvents()
        end
    end

    self.btn_guizhe:removeMEListener(TFWIDGET_CLICK)
    self.btn_jiangli:removeMEListener(TFWIDGET_CLICK)
    self.btn_zhankuang:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(FactionFightManager.activityStateChange, self.activityStateChangeCallBack) 
    self.activityStateChangeCallBack = nil

    self.registerEventCallFlag = nil  
end

function FightMainLayer:dispose()
	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    if self.layerList then
        for _,v in pairs(self.layerList) do
            v:dispose()
        end
    end
end

function FightMainLayer:switchShowLayer(index)
    if self.layerList == nil then
        return
    end

    if index == 3 then
        self.img_yuxuan:setVisible(false)
        self.img_hongdi:setVisible(false)
    else
        self.img_yuxuan:setVisible(true)
        self.img_hongdi:setVisible(true)
    end

    if index == 2 then
        self.btn_zhankuang:setVisible(false)
        self.btn_buzhen:setVisible(true)
        self.btn_yuxuan:setVisible(true)
        self.btn_duizhan:setVisible(true)
    else
        self.btn_zhankuang:setVisible(true)
        self.btn_buzhen:setVisible(false)
        self.btn_yuxuan:setVisible(false)
        self.btn_duizhan:setVisible(false)
    end
    for k,v in pairs(self.layerList) do
        if k == index then
            self.currLayerIndex = index
            v:setVisible(true)
        else
            v:setVisible(false)
        end
    end

end

function FightMainLayer.btnGuizheClick( btn )
    FactionFightManager:showRuleLayer()
end

function FightMainLayer.btnJiangliClick( btn )
    FactionFightManager:showAwardLayer()
end

function FightMainLayer.btnZhankuangClick( btn )
    FactionFightManager:enterFightMessage()
end

function FightMainLayer.btnBuzhenClick( btn )
    -- ZhengbaManager:joinChampions()
    ArenaManager:updatePlayerList()
end

function FightMainLayer.btnYuxuanClick( btn )
    local layer = require("lua.logic.factionfight.FactionFightList"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:dataReady()
    AlertManager:show()
end

function FightMainLayer.btnDuizhanClick( btn )
    FactionFightManager:enterFightMessage()
end

return FightMainLayer