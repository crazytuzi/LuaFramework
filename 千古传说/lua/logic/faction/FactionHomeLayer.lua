--[[
******帮派主界面*******

	-- by quanhuan
	-- 2015/10/23
	
]]

local FactionHomeLayer = class("FactionHomeLayer",BaseLayer)

function FactionHomeLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionHomeLayer")
end

function FactionHomeLayer:initUI( ui )
	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.Faction,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE}) 

    self.panel_title = TFDirector:getChildByPath(ui, "Panel_title")    
    self.panel_title:setTouchEnabled(true)
    self.panel_title:setSwallowTouch(false)

    local contentWidth = self.ui:getContentSize().width

    local panel_list = TFDirector:getChildByPath(ui, "Panel_List")
    self.panel_list = panel_list
    panel_list.moveMinX = self.panel_list:getPositionX() - (1800 - contentWidth)
    panel_list.moveMaxX = self.panel_list:getPositionX()
    local distance = math.abs(panel_list.moveMinX - panel_list.moveMaxX)

    local mountain1 = TFDirector:getChildByPath(ui, "img_shan1")
    self.mountain1 = mountain1
    mountain1.moveMinX = mountain1:getPositionX()
    mountain1.moveMaxX = mountain1:getPositionX() + 1200 - contentWidth
    mountain1.moveFaction = math.abs(mountain1.moveMinX - mountain1.moveMaxX) * 1.0 / distance

    local mountain2 = TFDirector:getChildByPath(ui, "img_shan2")
    self.mountain2 = mountain2
    mountain2.moveMinX = mountain2:getPositionX()
    mountain2.moveMaxX = mountain2:getPositionX() + 1375 - contentWidth
    mountain2.moveFaction = math.abs(mountain2.moveMinX - mountain2.moveMaxX) * 1.0 / distance

    print(panel_list.moveMinX, panel_list.moveMaxX)
    print(mountain1.moveMinX, mountain1.moveMaxX, mountain1.moveFaction)
    print(mountain2.moveMinX, mountain2.moveMaxX, mountain2.moveFaction)

    local panel_yun1 = TFDirector:getChildByPath(ui, "Panel_Yun1")
    local panel_yun2 = TFDirector:getChildByPath(ui, "Panel_Yun2")
    Public:addEffectWidthPosY("cloud2", panel_yun1, 300)
    Public:addEffectWidthPosY("cloud2", panel_yun1, 200)
    Public:addEffectWidthPosY("cloud2", panel_yun2, 50)
    Public:addEffectWidthPosY("cloud1", panel_yun2, 60)

    self.btn_zyt = TFDirector:getChildByPath(ui, "btn_zyt")
    self.point_zyt = TFDirector:getChildByPath(self.btn_zyt, "img_biaoti")

    self.btn_jyt = TFDirector:getChildByPath(ui, "btn_jyt")
    self.point_jyt = TFDirector:getChildByPath(self.btn_jyt, "img_biaoti")    

    self.btn_zbg = TFDirector:getChildByPath(ui, "btn_zbg")
    self.point_zbg = TFDirector:getChildByPath(self.btn_zbg, "img_biaoti")    

    self.btn_xlc = TFDirector:getChildByPath(ui, "btn_xlc")
    self.point_xlc = TFDirector:getChildByPath(self.btn_xlc, "img_biaoti")  

    self.btn_hs = TFDirector:getChildByPath(ui, "btn_hs")
    self.point_hs = TFDirector:getChildByPath(self.btn_hs, "img_biaoti")  

    self.btn_bangpaizhan = TFDirector:getChildByPath(ui, "btn_bangpaizhan")
    self.point_bangpaizhan = TFDirector:getChildByPath(self.btn_bangpaizhan, "img_biaoti")  

    self.Btn_jhp = TFDirector:getChildByPath(ui, "Btn_jhp")
    self.Btn_gonggao = TFDirector:getChildByPath(ui, "Btn_gonggao")
    self.panelMsg = TFDirector:getChildByPath(ui, "panel_msg")

    self.txtName = TFDirector:getChildByPath(ui, "txt_name")
    self.level = TFDirector:getChildByPath(ui, "txt_level")
    self.txt_exp = TFDirector:getChildByPath(ui, "txt_exp")
    self.expBar = TFDirector:getChildByPath(ui, "bar_exp")
    self.fanrong = TFDirector:getChildByPath(ui, "txt_fangrong")
    self.gongxian = TFDirector:getChildByPath(ui, "txt_gongxian")
    self.gonggao = TFDirector:getChildByPath(ui, "Label_FactionHomeLayer_1")

    -- local panelArrowNode = TFDirector:getChildByPath(ui, 'panel_arrow')
    self.imgArrow = TFDirector:getChildByPath(ui, "img_jiantou")

    self.expBar:setDirection(TFLOADINGBAR_LEFT)
    self.expBar:setPercent(0)
    self.expBar:setVisible(true)  

    self.fontPosition = self.gonggao:getPosition()

    self:showArrowAnim(self.imgArrow, self.imgArrow:getPosition())

    FactionManager:initGonggaoView()
end

function FactionHomeLayer:removeUI()
	self.super.removeUI(self)
end

function FactionHomeLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()

    if FactionManager:isNeedPopNotice() then
        local content = FactionManager:getNoticeContent()
        FactionManager:newNoticeShow()
        local layer  = require("lua.logic.faction.FactionNoticeLayer"):new()
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
        layer:setContentText(content)
        AlertManager:show()
    end
    self:refreshWindow()
end

function FactionHomeLayer:registerEvents()

	self.super.registerEvents(self)
    self.isFirstIn = true

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_zyt:addMEListener(TFWIDGET_CLICK, audioClickfun(self.zytButtonClick))
    self.btn_jyt:addMEListener(TFWIDGET_CLICK, audioClickfun(self.jytButtonClick))
    self.btn_zbg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.zbgButtonClick))
    self.btn_xlc:addMEListener(TFWIDGET_CLICK, audioClickfun(self.xlcButtonClick))
    self.btn_hs:addMEListener(TFWIDGET_CLICK, audioClickfun(self.hsButtonClick))
    self.btn_bangpaizhan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.fightButtonClick))
    self.Btn_jhp:addMEListener(TFWIDGET_CLICK, audioClickfun(self.jhpButtonClick))
    self.Btn_gonggao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.gonggaoButtonClick))
    self.Btn_gonggao.logic = self  

    FactionManager:addLayerInFaction()

    -- FactionManager:requestMemberInfo()
    -- local post = FactionManager:getPostInFaction()
    -- if post == 1 or post == 2 then
    --     FactionManager:requestOtherMemberList()
    -- end

    self.updateRedPointCallBack = function (event)
        self:refreshWindow()
    end
    TFDirector:addMEGlobalListener(FactionManager.updateRedPoint, self.updateRedPointCallBack)  

    self.guildNotExistCallBack = function (event)
        if FactionManager.layerCount then
            AlertManager:closeAll()
            FactionManager:initPersonalInfo(0, 3)
            FactionManager:exitAndClearData()            
        end
    end
    TFDirector:addMEGlobalListener(FactionManager.guildNotExist, self.guildNotExistCallBack)  

    --
    --滑动事件监听，切换装备
    function onTouchBegin(widget,pos,offset)        
        self.touchBeginPos = pos
        -- print('onTouchBegin = ',pos)
    end

    function onTouchMove(widget,pos,offset)
        local Dx = pos.x - self.touchBeginPos.x

        local dist = self.panel_list:getPositionX() + Dx
        dist = math.max(self.panel_list.moveMinX, math.min(self.panel_list.moveMaxX, dist))
        self.panel_list:setPositionX(dist)


        dist = self.mountain1:getPositionX() - Dx * self.mountain1.moveFaction
        dist = math.max(self.mountain1.moveMinX, math.min(self.mountain1.moveMaxX, dist))
        self.mountain1:setPositionX(dist)

        dist = self.mountain2:getPositionX() - Dx * self.mountain2.moveFaction
        dist = math.max(self.mountain2.moveMinX, math.min(self.mountain2.moveMaxX, dist))
        self.mountain2:setPositionX(dist)

        self.touchBeginPos = pos

        if (self.panel_list.moveMaxX - dist) < 200 then
            self.imgArrow:setVisible(true)
        else
            self.imgArrow:setVisible(false)
        end
    end

    function onTouchEnd(widget,pos)

    end

    self.panel_title:addMEListener(TFWIDGET_TOUCHBEGAN, onTouchBegin)
    self.panel_title:addMEListener(TFWIDGET_TOUCHMOVED, onTouchMove)
    self.panel_title:addMEListener(TFWIDGET_TOUCHENDED, onTouchEnd)
end

function FactionHomeLayer:removeEvents()

	if self.generalHead then
        self.generalHead:removeEvents()
    end
 	
 	self.btn_zyt:removeMEListener(TFWIDGET_CLICK)
    self.btn_jyt:removeMEListener(TFWIDGET_CLICK)
    self.btn_zbg:removeMEListener(TFWIDGET_CLICK)
    self.btn_xlc:removeMEListener(TFWIDGET_CLICK)
    self.btn_hs:removeMEListener(TFWIDGET_CLICK)
    self.Btn_jhp:removeMEListener(TFWIDGET_CLICK)
    self.Btn_gonggao:removeMEListener(TFWIDGET_CLICK)

    if self.fontDelayTime then
        TFDirector:removeTimer(self.fontDelayTime)
        self.fontDelayTime = nil
    end
    if self.fontMoveTime then
        TFDirector:removeTimer(self.fontMoveTime)
        self.fontMoveTime = nil
    end    

    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(FactionManager.updateRedPoint, self.updateRedPointCallBack)  
    self.updateRedPointCallBack = nil
    TFDirector:removeMEGlobalListener(FactionManager.guildNotExist, self.guildNotExistCallBack) 
    self.guildNotExistCallBack = nil   

    FactionManager:deleteLayerInFaction()    
end

function FactionHomeLayer:dispose()
	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
end
function FactionHomeLayer:refreshWindow()
    local personalInfo = FactionManager:getPersonalInfo() or {}
    if personalInfo.guildId == nil or personalInfo.guildId == 0 then
        return
    end

    if FactionManager:getGonggaoView() then
        self.panelMsg:setVisible(true)
        self:moveFont()
    else
        if self.fontDelayTime then
            TFDirector:removeTimer(self.fontDelayTime)
            self.fontDelayTime = nil
        end
        if self.fontMoveTime then
            TFDirector:removeTimer(self.fontMoveTime)
            self.fontMoveTime = nil
        end
        self.panelMsg:setVisible(false)     
    end

    local factionInfo = FactionManager:getFactionInfo()
    if factionInfo then
        self.txtName:setText(factionInfo.name)
        print("factionInfo = ",factionInfo)
        self.level:setText(factionInfo.level..'d')
        local currExp = factionInfo.exp
        local totalExp = FactionManager:getFactionLevelUpExp(factionInfo.level+1)    --需要读表
        self.txt_exp:setText(currExp.."/"..totalExp)
        self.expBar:setPercent(math.floor(currExp*100/totalExp))
        self.fanrong:setText(factionInfo.boom)
        self.gonggao:setText(factionInfo.notice)

        
        CommonManager:setRedPoint(self.Btn_gonggao, FactionManager.noticeRed ,"isHaveCanZhaomu",ccp(0,0)) 
    end
    -- local personalInfo = FactionManager:getPersonalInfo()
    if personalInfo then
        self.gongxian:setText(MainPlayer:getDedication())
    end

    CommonManager:setRedPoint(self.point_jyt, FactionManager:canViewRedPointInHomeLayer() ,"isHaveCanZhaomu",ccp(0,0))  
    CommonManager:setRedPoint(self.point_zyt, FactionManager:canRedPointWorShip(),"isHaveCanZhaomu",ccp(0,0))   
    CommonManager:setRedPoint(self.point_hs, FactionManager:canRedPointHouShan(),"isRedHouShan",ccp(0,0))  
    CommonManager:setRedPoint(self.point_xlc, FactionPracticeManager:canRedPointPractice(),"isRedPractice",ccp(0,0))
    
    -- CommonManager:setRedPoint(self.point_zyt, true,"isHaveCanZhaomu",ccp(0,0))   

end

function FactionHomeLayer:moveFont()

    if self.fontDelayTime then
        TFDirector:removeTimer(self.fontDelayTime)
        self.fontDelayTime = nil
    end
    if self.fontMoveTime then
        TFDirector:removeTimer(self.fontMoveTime)
        self.fontMoveTime = nil
    end


    local factionInfo = FactionManager:getFactionInfo()
    local prevTxt = self.gonggao:getText()

    if string.len(prevTxt) ~= string.len(factionInfo.notice) then
        self.gonggao:setPosition(self.fontPosition)
    end
    self.gonggao:setText(factionInfo.notice)
    
    
    local clipSize = self.panelMsg:getContentSize().width
    local fontSize = self.gonggao:getContentSize().width + math.ceil(clipSize/2 + self.gonggao:getPositionX())

    if clipSize < fontSize then
        local moveX = 10
        local times = math.ceil((fontSize - clipSize)/10)

        local function fontMove()
            if self.fontDelayTime then
                TFDirector:removeTimer(self.fontDelayTime)
                self.fontDelayTime = nil
            end
            self.gonggao:setPosition(self.fontPosition)
            self.fontDelayTime = TFDirector:addTimer(1000, 1, function ()  
                if self.fontDelayTime then
                    TFDirector:removeTimer(self.fontDelayTime)
                    self.fontDelayTime = nil
                end              
                self.fontMoveTime = TFDirector:addTimer(300, times, 
                function()
                    --移动结束开始延迟
                    if self.fontMoveTime then
                        TFDirector:removeTimer(self.fontMoveTime)
                        self.fontMoveTime = nil
                    end
                    self.fontDelayTime = TFDirector:addTimer(1000, 1, fontMove,nil)
                end,
                function()
                    --每次进来
                    local currX = self.gonggao:getPositionX()
                    currX = currX - 10
                    self.gonggao:setPositionX(currX)
                end)
            end,nil)
        end
        fontMove()
    end
end
function FactionHomeLayer.zytButtonClick( btn )
    -- toastMessage("即将开放，敬请期待！")
    FactionManager:openZhongYiLayer()
end

function FactionHomeLayer.jytButtonClick( btn )
	FactionManager:openFactinoBaseLayer()
end

function FactionHomeLayer.zbgButtonClick( btn )
    local openLevel = FactionManager:getShopOpenLevel()
    if openLevel == 0 then
        --toastMessage("即将开放，敬请期待！")
        toastMessage(localizable.common_open_tips1)
        return
    elseif FactionManager.factionInfo.level < openLevel then
        --toastMessage("珍宝阁需要帮派等级"..openLevel.."级")
        toastMessage(stringUtils.format(localizable.factionHomeLayer_openlevel,openLevel))
        return
    end
    MallManager:openFactionMallLayer()
end
function FactionHomeLayer.xlcButtonClick( btn )
    -- toastMessage("即将开放，敬请期待！")
    FactionPracticeManager:enterXiulianCLayer()
end
function FactionHomeLayer.hsButtonClick( btn )
    -- toastMessage("即将开放，敬请期待！")
    FactionManager:enterHoushanLayer()
end
function FactionHomeLayer.fightButtonClick( btn )
    FactionFightManager:openCurrLayer()
end
function FactionHomeLayer.jhpButtonClick( btn )
    FactionManager:openFactionRankLayer()
end
function FactionHomeLayer.gonggaoButtonClick( btn )

    local self = btn.logic

    if FactionManager:getGonggaoView() then
        FactionManager:setGonggaoView(false)
        self.panelMsg:setVisible(false)
        if self.fontDelayTime then
            TFDirector:removeTimer(self.fontDelayTime)
            self.fontDelayTime = nil
        end
        if self.fontMoveTime then
            TFDirector:removeTimer(self.fontMoveTime)
            self.fontMoveTime = nil
        end
    else
        -- FactionManager:requestFactionInfo()
        self.gonggao:setPosition(self.fontPosition)
        FactionManager.noticeRed = false
        CommonManager:setRedPoint(self.Btn_gonggao, false ,"isHaveCanZhaomu",ccp(0,0)) 
        FactionManager:setGonggaoView(true)
        self.panelMsg:setVisible(true)     
        self:moveFont()
    end
end

function FactionHomeLayer:showArrowAnim(sender,pos)

    local btnTween = 
    {
        target = sender,
        repeated = -1,
        {
            duration = 1,
            x = pos.x + 10,
            y = pos.y,            
        },
        {
            duration = 1,
            x = pos.x - 10,
            y = pos.y,            
        },
    }
    TFDirector:toTween(btnTween)
end

return FactionHomeLayer