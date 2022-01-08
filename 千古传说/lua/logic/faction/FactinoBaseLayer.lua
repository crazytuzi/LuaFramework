--[[
******帮派信息*******

	-- by quanhuan
	-- 2015/10/26
	
]]

local FactinoBaseLayer = class("FactinoBaseLayer",BaseLayer)

function FactinoBaseLayer:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactinoBaseLayer")
end

function FactinoBaseLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.BtnTab = { TFDirector:getChildByPath(ui, "Button_FactinoBaseLayer_1"),
                    TFDirector:getChildByPath(ui, "Button_FactinoBaseLayer_2"),
                    TFDirector:getChildByPath(ui, "Button_FactinoBaseLayer_3"),
                    TFDirector:getChildByPath(ui, "Button_FactinoBaseLayer_4")}

    self.btnNormalTextures = {
        'ui_new/faction/tab_bpxx2.png',
        'ui_new/faction/tab_bpcy2.png',
        'ui_new/faction/tab_bpdt2.png',
        'ui_new/faction/tab_sqlb2.png'}

    self.btnSelectedTextures = {
        'ui_new/faction/tab_bpxx.png',
        'ui_new/faction/tab_bpcy.png',
        'ui_new/faction/tab_bpdt.png',
        'ui_new/faction/tab_sqlb.png'}

    self.panel_content = TFDirector:getChildByPath(ui, "panel_content")

    local layerFile = {
        'lua.logic.faction.FactinoInfo',
        'lua.logic.faction.FactinoMembers',
        'lua.logic.faction.FactinoAccount',
        'lua.logic.faction.FactinApply',
    }
    self.layerTable = {}
    for k,v in pairs(layerFile) do
        local layer = require(v):new()
        self.panel_content:addChild(layer)
        self.layerTable[k] = layer
    end
 
end

function FactinoBaseLayer:removeUI()
    print("removeUI!!!!!!!!!!!!!!!!")
	self.super.removeUI(self)
end

function FactinoBaseLayer:onShow()
    self.super.onShow(self)

    self:refreshWindow()
    self.generalHead:onShow()    

    

end

function FactinoBaseLayer:registerEvents()

	self.super.registerEvents(self)

    for k,v in pairs(self.layerTable) do
        v:registerEvents()
    end

    for k,v in pairs(self.BtnTab) do
        v.logic = self
        v.index = k
        v:addMEListener(TFWIDGET_CLICK, audioClickfun(self.tabButtonClick))
    end 

    self.refreshWindowCallBack = function (event)
        self:refreshWindow()
        self.layerTable[self.btnChoseIdx]:refreshWindow()
    end
    TFDirector:addMEGlobalListener(FactionManager.refreshWindow, self.refreshWindowCallBack)

    self.refreshWindowAndCloseCallBack = function (event)
        AlertManager:close()
        self:refreshWindow()
        self.layerTable[self.btnChoseIdx]:refreshWindow()
    end
    TFDirector:addMEGlobalListener(FactionManager.refreshWindowAndClose, self.refreshWindowAndCloseCallBack)

    --监听查看成员列表中成员信息
    -- self.onOverView = function(event)
    --     local userData   = event.data[1]
    --     local cardRoleId = userData[1].warside[1].id
    --     OtherPlayerManager:openRoleInfo(userData, cardRoleId)
    -- end
    -- TFDirector:addMEGlobalListener(OtherPlayerManager.OVERVIEW, self.onOverView)

    --退出帮派
    self.windowAllCloseCallBack = function (event)
        AlertManager:closeAll()
    end
    TFDirector:addMEGlobalListener(FactionManager.windowAllClose, self.windowAllCloseCallBack)
end

function FactinoBaseLayer:removeEvents()

    print("removeEvents!!!!!!!!!!!!!!!!")
	if self.generalHead then
        self.generalHead:removeEvents()
    end

    for k,v in pairs(self.BtnTab) do
        v:removeMEListener(TFWIDGET_CLICK)
    end

    for k,v in pairs(self.layerTable) do
        v:removeEvents()
    end

    TFDirector:removeMEGlobalListener(FactionManager.refreshWindow, self.refreshWindowCallBack)
    -- TFDirector:removeMEGlobalListener(OtherPlayerManager.OVERVIEW, self.onOverView)
    TFDirector:removeMEGlobalListener(FactionManager.windowAllClose, self.windowAllCloseCallBack)
    TFDirector:removeMEGlobalListener(FactionManager.refreshWindowAndClose, self.refreshWindowAndCloseCallBack)

    self.super.removeEvents(self)

end

function FactinoBaseLayer:dispose()

    self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    
    for k,v in pairs(self.layerTable) do
        v:dispose()
    end
    self.layerTable = {}  
end

function FactinoBaseLayer:setBtnInfo( prevIndex, currIndex )
    for i=1,#self.BtnTab do
        self.BtnTab[i]:setTextureNormal(self.btnNormalTextures[i]) 
    end

    for k,v in pairs(self.layerTable) do
        v:setVisible(false)
    end

    print("currIndex = ",currIndex)

    if self.layerTable[currIndex] then
        self.layerTable[currIndex]:setVisible(true)
    end

    self.BtnTab[currIndex]:setTextureNormal(self.btnSelectedTextures[currIndex]) 
    self.btnChoseIdx = currIndex

    local identity = FactionManager:getCurrIdentity()
    if identity == "others" then
        self.layerTable[currIndex]:refreshWindow()
        return
    end

    if self.btnChoseIdx == 1 then
        FactionManager:requestFactionInfo() --请求公会信息       
    elseif self.btnChoseIdx == 2 then
        FactionManager:requestMemberInfo()  --请求成员信息
    elseif self.btnChoseIdx == 3 then
        self.layerTable[currIndex]:refreshWindow()
    else
        FactionManager:requestOtherMemberList()
    end
end

function FactinoBaseLayer.tabButtonClick(sender)

    local self = sender.logic

    if sender.index == self.btnChoseIdx then
        return
    end

    self:setBtnInfo(self.btnChoseIdx, sender.index)
end

function FactinoBaseLayer:refreshWindow()

    local identity = FactionManager:getCurrIdentity()
    if identity == "self" then
        self.generalHead = CommonManager:addGeneralHead(self)
        self.generalHead:setData(ModuleType.Jyt_Faction,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE}) 
        self.generalHead:registerEvents()

        for i=1,#self.BtnTab do
            self.BtnTab[i]:setVisible(true)
        end
        if  FactionManager:getPostInFaction() == 3 then
            self.BtnTab[4]:setVisible(false)

            if self.btnChoseIdx == 4 then
                self:loadData(1)
            end
        end
        CommonManager:setRedPoint(self.BtnTab[1], FactionManager:canViewRedLevelUp() ,"isHaveCanZhaomu",ccp(-115,-20))
        CommonManager:setRedPoint(self.BtnTab[2], FactionManager:canViewRedPointMakeFriends() ,"isHaveCanZhaomu",ccp(-115,-20))
        CommonManager:setRedPoint(self.BtnTab[4], FactionManager:canViewRedPointApply() ,"isHaveCanZhaomu",ccp(-115,-20))

    elseif identity == "others" then
        self.generalHead = CommonManager:addGeneralHead(self)
        self.generalHead:setData(ModuleType.Faction,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE}) 
        self.generalHead:registerEvents()

        for i=2,#self.BtnTab do
            self.BtnTab[i]:setVisible(false)
        end
    end
end

function FactinoBaseLayer:loadData(index)

    self.btnChoseIdx = nil
    self.tabButtonClick(self.BtnTab[index])

end

return FactinoBaseLayer