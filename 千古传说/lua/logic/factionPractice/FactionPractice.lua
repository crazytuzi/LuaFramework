--[[
******帮派-修炼-传承*******

	-- by quanhuan
	-- 2016/1/7
	
]]

local FactionPractice = class("FactionPractice",BaseLayer)

function FactionPractice:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionPractice")
end

local HouseDetailData = {}
--[[
    -state                  是否开启
    -canOpen                是否能够开启
    -openLimit              开启条件
    -gmId                   正在修炼的侠客
    -headImg                侠客图像
    -skillName              修炼的技能名称
    -complete               修炼剩余时间
    -completeTotal          修炼总时间
    -sycee                  完成需要消耗的元宝
]]
function FactionPractice:initUI( ui )

	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.PracticeFaction,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE})
        
    self.btn_yanjiu = TFDirector:getChildByPath(ui, 'btn_yanjiu')
    self.btn_chuancheng = TFDirector:getChildByPath(ui, 'btn_chuancheng')
    self.btn_help = TFDirector:getChildByPath(ui, 'btn_help')

    self.inHeritHouse = {}
    for i=1,5 do
        local heritNode = TFDirector:getChildByPath(ui, 'panel_xiulian'..i)
        self.inHeritHouse[i] = {}

        local unOpenNode = TFDirector:getChildByPath(heritNode, 'Panel_unkaiqi')
        self.inHeritHouse[i].unOpenNode = TFDirector:getChildByPath(heritNode, 'Panel_unkaiqi')
        self.inHeritHouse[i].unOpenBtn = TFDirector:getChildByPath(unOpenNode, 'btn_kaiqi')
        self.inHeritHouse[i].unOpenTxt = TFDirector:getChildByPath(unOpenNode, 'txt_jr')

        local openNode = TFDirector:getChildByPath(heritNode, 'Panel_kaiqi')
        self.inHeritHouse[i].openNode = TFDirector:getChildByPath(heritNode, 'Panel_kaiqi')
        self.inHeritHouse[i].head = TFDirector:getChildByPath(openNode, 'img_touxiang')
        self.inHeritHouse[i].headFrame = TFDirector:getChildByPath(openNode, 'btn_icon') 
        self.inHeritHouse[i].headFrame:setTouchEnabled(false)
        self.inHeritHouse[i].imgZhiye = TFDirector:getChildByPath(openNode, 'img_zhiye')        
        self.inHeritHouse[i].btnAdd = TFDirector:getChildByPath(openNode, 'btn_jiahao')
        self.inHeritHouse[i].inHeritName = TFDirector:getChildByPath(openNode, 'txt_jr')
        self.inHeritHouse[i].inHeriting = TFDirector:getChildByPath(openNode, 'txt_xiulian')
        self.inHeritHouse[i].loadingBar = TFDirector:getChildByPath(openNode, 'load_di')
        self.inHeritHouse[i].loadingBar:setDirection(TFLOADINGBAR_LEFT)
        self.inHeritHouse[i].loadingTime = TFDirector:getChildByPath(openNode, 'txt_time')
        self.inHeritHouse[i].btnComplete = TFDirector:getChildByPath(openNode, 'btn_liji')
        self.inHeritHouse[i].txtPrice = TFDirector:getChildByPath(openNode, 'txt_price')
        self.inHeritHouse[i].priceNode = TFDirector:getChildByPath(openNode, 'img_newprice_bg')
        self.inHeritHouse[i].effectNode = TFDirector:getChildByPath(openNode, 'img_dicard')
        

        self.inHeritHouse[i].noCardNode = TFDirector:getChildByPath(openNode, 'panel_nocard')
    end    
end


function FactionPractice:removeUI()
	self.super.removeUI(self)
end

function FactionPractice:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()

end

function FactionPractice:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_yanjiu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onYanjiuBtnClick))
    self.btn_yanjiu.logic = self
    self.btn_chuancheng:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onChuanChengBtnClick))
    self.btn_chuancheng.logic = self
    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHelpBtnClick))

    for i=1,#self.inHeritHouse do       
        self.inHeritHouse[i].unOpenBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onUnOpenBtnClick))
        self.inHeritHouse[i].unOpenBtn.logic = self
        self.inHeritHouse[i].unOpenBtn.idx = i

        self.inHeritHouse[i].btnAdd:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAddBtnClick))
        self.inHeritHouse[i].btnAdd.logic = self
        self.inHeritHouse[i].btnAdd.idx = i

        self.inHeritHouse[i].btnComplete:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCompleteBtnClick))
        self.inHeritHouse[i].btnComplete.logic = self
        self.inHeritHouse[i].btnComplete.idx = i        
    end

    self.startPracticeSucessCallBack = function (event)
        local pos = event.data[1][1]
        HouseDetailData[pos] = FactionPracticeManager:getHouseInfoById(pos)
        self:loadHouseDetailInfo(pos)
        self:showCutDownTime()
        self:playSelectRoleAnim(pos)
    end
    TFDirector:addMEGlobalListener(FactionPracticeManager.startPracticeSucess, self.startPracticeSucessCallBack) 

    self.endPracticeSucessCallBack = function (event)
    print('data = ',event.data)
        local data = event.data[1]
        HouseDetailData[data.pos] = FactionPracticeManager:getHouseInfoById(data.pos)
        self:loadHouseDetailInfo(data.pos)
        self:showCutDownTime()

        -- if state then
            --显示修炼完成界面
        -- end

        local layer  = require("lua.logic.factionPractice.PracticeResult"):new()
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE) 
        layer:setData(data.attributeType, data.instanceId)   
        AlertManager:show()
    end
    TFDirector:addMEGlobalListener(FactionPracticeManager.endPracticeSucess, self.endPracticeSucessCallBack) 

    self.registerEventCallFlag = true 
end

function FactionPractice:removeEvents()

    self.super.removeEvents(self)

	if self.generalHead then
        self.generalHead:removeEvents()
    end

    self.btn_yanjiu:removeMEListener(TFWIDGET_CLICK)
    self.btn_chuancheng:removeMEListener(TFWIDGET_CLICK)
    self.btn_help:removeMEListener(TFWIDGET_CLICK)
    for i=1,#self.inHeritHouse do       
        self.inHeritHouse[i].unOpenBtn:removeMEListener(TFWIDGET_CLICK)
        self.inHeritHouse[i].btnAdd:removeMEListener(TFWIDGET_CLICK)
        self.inHeritHouse[i].btnComplete:removeMEListener(TFWIDGET_CLICK)
    end

    if self.cutDownTimer then
        TFDirector:removeTimer(self.cutDownTimer)
        self.cutDownTimer = nil
    end

    TFDirector:removeMEGlobalListener(FactionPracticeManager.startPracticeSucess, self.startPracticeSucessCallBack)
    self.startPracticeSucessCallBack = nil
    TFDirector:removeMEGlobalListener(FactionPracticeManager.endPracticeSucess, self.endPracticeSucessCallBack)
    self.endPracticeSucessCallBack = nil

    self.registerEventCallFlag = nil  
end

function FactionPractice:dispose()
	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
end

function FactionPractice:dataReady()
    HouseDetailData = {}

    for i=1,#self.inHeritHouse do
        HouseDetailData[i] = FactionPracticeManager:getHouseInfoById(i)
        self:loadHouseDetailInfo(i)
    end

    --研究按钮显示状态
    local myPost = FactionManager:getPostInFaction()
    if myPost ~= 1 and myPost ~= 2 then
        self.btn_yanjiu:setVisible(false)
    else
        self.btn_yanjiu:setVisible(true)
    end

    self:showCutDownTime()
end

function FactionPractice.onYanjiuBtnClick( btn )
    local self = btn.logic
    local myPost = FactionManager:getPostInFaction()
    if myPost ~= 1 and myPost ~= 2 then
        --toastMessage('权限不够')
        toastMessage(localizable.common_no_power)

    else
        FactionPracticeManager:showPracticeStudyLayer()
    end

    -- local cardRole = CardRoleManager:getRoleById(1)

    -- FactionPracticeManager:requestStartPractice(1,cardRole.gmId,1)
end

function FactionPractice.onChuanChengBtnClick( btn )
    FactionPracticeManager:openPracticeInheritLayer()
end

function FactionPractice.onAddBtnClick( btn )
    local pos = btn.idx
    local dataInfo = HouseDetailData[btn.idx] or {}
    local completeTime = HouseDetailData[pos].gmId or 0
    if completeTime ~= 0 then
        return
    end
    FactionPracticeManager:showPracticeChooseLayer(btn.idx)
end

function FactionPractice.onUnOpenBtnClick( btn )
    -- body
end

function FactionPractice.onCompleteBtnClick( btn )
    local self = btn.logic
    local dataInfo = HouseDetailData[btn.idx] or {}

    local completeTime = dataInfo.complete or 0
    if completeTime == 0 then
        FactionPracticeManager:requestEndPractice(btn.idx,true)
        return
    end
    print('dataInfo = ',dataInfo)
    --判断元宝
    local speakerConstant = ConstantData:objectByID("guild.cd.practice")
    local need = math.ceil((dataInfo.complete/60)/speakerConstant.value)    
    -- local str = TFLanguageManager:getString(ErrorCodeData.Field_Finish_at_once)
    -- str = string.format(str,need)
    local str = stringUtils.format(localizable.Field_Finish_at_once, need)

    CommonManager:showOperateSureLayer(
        function()
            if MainPlayer:isEnoughSycee( need , true) then
                FactionPracticeManager:requestEndPractice(btn.idx,false)
            end
        end,
        nil,
        {
            msg = str
        }
    )
end

function FactionPractice:loadHouseDetailInfo( house_id )

    local dataInfo = HouseDetailData[house_id]
    local houseUiInfo = self.inHeritHouse[house_id]

    if dataInfo.gmId ~= 0 then
        houseUiInfo.unOpenNode:setVisible(false)
        houseUiInfo.openNode:setVisible(true)
        houseUiInfo.noCardNode:setVisible(true)
        houseUiInfo.headFrame:setVisible(true)
        houseUiInfo.headFrame:setTextureNormal(GetColorRoadIconByQuality(dataInfo.quality))
        houseUiInfo.head:setTexture(dataInfo.headImg)
        houseUiInfo.imgZhiye:setTexture("ui_new/fight/zhiye_".. dataInfo.outline ..".png")
        houseUiInfo.inHeritName:setText(dataInfo.skillName)
        houseUiInfo.txtPrice:setText(dataInfo.sycee)
        houseUiInfo.btnAdd:setTouchEnabled(false)
    elseif dataInfo.state then
        houseUiInfo.unOpenNode:setVisible(false)
        houseUiInfo.openNode:setVisible(true)
        houseUiInfo.headFrame:setVisible(false)
        houseUiInfo.noCardNode:setVisible(false)
        houseUiInfo.btnAdd:setTouchEnabled(true)
    else
        houseUiInfo.unOpenNode:setVisible(true)
        houseUiInfo.openNode:setVisible(false)
        houseUiInfo.unOpenBtn:setVisible(false)
        houseUiInfo.unOpenTxt:setVisible(true)
        houseUiInfo.unOpenTxt:setText(dataInfo.openLimit)
    end    
end

function FactionPractice:showCutDownTime()

    if self.cutDownTimer then
        TFDirector:removeTimer(self.cutDownTimer)
        self.cutDownTimer = nil
    end

    for i=1,#(HouseDetailData) do
        Public:addBtnWaterEffect(self.inHeritHouse[i].btnComplete, false,1)
        if HouseDetailData[i].gmId ~= 0 then

            local timeStr = FactionManager:getTimeString( HouseDetailData[i].complete )
            self.inHeritHouse[i].loadingTime:setText(timeStr)
            local percent = math.floor((HouseDetailData[i].completeTotal-HouseDetailData[i].complete)*100/HouseDetailData[i].completeTotal)
            self.inHeritHouse[i].loadingBar:setPercent(percent)

            if self.inHeritHouse[i].effect == nil then
                TFResourceHelper:instance():addArmatureFromJsonFile("effect/factionPractice.xml")
                local effect = TFArmature:create("factionPractice_anim")
                effect:setAnimationFps(GameConfig.ANIM_FPS)
                effect:playByIndex(0, -1, -1, 1)
                effect:setVisible(true)
                effect:setPosition(ccp(85,240))
                self.inHeritHouse[i].effect = effect
                self.inHeritHouse[i].effectNode:addChild(effect,1)
            end

            if HouseDetailData[i].complete == 0 then
                self.inHeritHouse[i].btnComplete:setTextureNormal('ui_new/faction/xiulian/btn_wancheng.png')
                self.inHeritHouse[i].priceNode:setVisible(false)
                if self.inHeritHouse[i].btnComplete.effect == nil then
                    Public:addBtnWaterEffect(self.inHeritHouse[i].btnComplete, true,1)
                    -- self.inHeritHouse[i].btnComplete.effect:setScale(0.6)
                end
            else
                self.inHeritHouse[i].priceNode:setVisible(true)
                self.inHeritHouse[i].btnComplete:setTextureNormal('ui_new/faction/xiulian/btn_liji.png')
            end     

            local speakerConstant = ConstantData:objectByID("guild.cd.practice")
            local need = math.ceil((HouseDetailData[i].complete/60)/speakerConstant.value)    
            self.inHeritHouse[i].txtPrice:setText(need)
        else         
            if self.inHeritHouse[i].effect then
                self.inHeritHouse[i].effect:removeFromParent()
                self.inHeritHouse[i].effect = nil
            end
        end
    end

    self.cutDownTimer = TFDirector:addTimer(1000, -1, nil, 
        function ()
            local killTimer = true
            for i=1,#(HouseDetailData) do
                if HouseDetailData[i].gmId ~= 0 then
                    if HouseDetailData[i].complete > 0 then
                        HouseDetailData[i].complete = HouseDetailData[i].complete - 1
                        killTimer = false
                    end

                    local timeStr = FactionManager:getTimeString( HouseDetailData[i].complete )
                    self.inHeritHouse[i].loadingTime:setText(timeStr)
                    local percent = math.floor((HouseDetailData[i].completeTotal-HouseDetailData[i].complete)*100/HouseDetailData[i].completeTotal)
                    self.inHeritHouse[i].loadingBar:setPercent(percent)

                    if HouseDetailData[i].complete == 0 then
                        self.inHeritHouse[i].btnComplete:setTextureNormal('ui_new/faction/xiulian/btn_wancheng.png')
                        self.inHeritHouse[i].priceNode:setVisible(false)
                        if self.inHeritHouse[i].btnComplete.effect == nil then
                            Public:addBtnWaterEffect(self.inHeritHouse[i].btnComplete, true,1)
                            -- self.inHeritHouse[i].btnComplete.effect:setScale(0.6)
                        end
                    end            
                    local speakerConstant = ConstantData:objectByID("guild.cd.practice")
                    local need = math.ceil((HouseDetailData[i].complete/60)/speakerConstant.value)   
                    self.inHeritHouse[i].txtPrice:setText(need)             
                end
            end
            if killTimer then
                if self.cutDownTimer then
                    TFDirector:removeTimer(self.cutDownTimer)
                    self.cutDownTimer = nil
                end  
            end
        end)

end

function FactionPractice.onHelpBtnClick( btn )
    CommonManager:showRuleLyaer( 'bangpaixiulianchang' )
end

function FactionPractice:playSelectRoleAnim(pos)
    
    if self.currSelectRoleAnim then
        self.currSelectRoleAnim:removeFromParent()
        self.currSelectRoleAnim = nil
    end

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/assistOpen.xml")
    local effect = TFArmature:create("assistOpen_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)
    effect:setVisible(true)
       
    self.currSelectRoleAnim = effect
    local desNode = self.inHeritHouse[pos].btnAdd
    desNode:addChild(effect,100)
    local x = desNode:getPosition().x
    local y = desNode:getPosition().y

    effect:setPosition(ccp(0,0))
    effect:addMEListener(TFARMATURE_COMPLETE, function ()
        effect:removeMEListener(TFARMATURE_COMPLETE) 
        effect:removeFromParent()
        self.currSelectRoleAnim = nil
    end)
end

return FactionPractice