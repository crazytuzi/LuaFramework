require("app.cfg.role_info")
require("app.cfg.basic_figure_info")
require("app.const.FigureType")
local RoleInfoUIComponent = class("RoleInfoUIComponent",UFCCSNormalLayer)

local EffectNode = require "app.common.effects.EffectNode"
local FunctionLevelConst = require "app.const.FunctionLevelConst"
 
function RoleInfoUIComponent:ctor( ... )
	self.super.ctor(self, ...)
    self._lastFightValue = 0
    self._lastFightValuePet = 0
    self._isUpdate = false
    -- 记录数字跳动label 初始位置
    self.posList = {}
    self._fightValueIndex = 0
    self._barType = nil
    self:enableLabelStroke("Label_Silver", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_Gold", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_FightValue", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_TiLi", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_JingLi", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_fightValueNumber", Colors.strokeBrown, 2 )
    if not self:getLabelByName("Label_petFightValueNumber") then 
        self:enableLabelStroke("Label_petFightValueNumber", Colors.strokeBrown, 2 )
    end
    self:updateInfo()

    if device.platform == "wp8" or device.platform == "winrt" then 
        cc.Director:getInstance():getEventDispatcher():addCustomEventListener("APP_ENTER_FOREGROUND", handler(self,self.passCallback))
    else
        CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(self, handler(self,self.passCallback), "APP_ENTER_FOREGROUND")
    end
end

-- 后台切换到前台
function RoleInfoUIComponent:passCallback()
    self:updateInfo()
end

-- 进入战斗协议
function RoleInfoUIComponent:onEnterBattle()
    self._isEnterBattle = true
end

function RoleInfoUIComponent:_onRecvFlushData()
    self:updateInfo()
end

function RoleInfoUIComponent:initAddLabel(addName)
    local addLabel = self:getLabelByName(addName)
    if addLabel then
        addLabel:setVisible(false)
    end
end

function RoleInfoUIComponent:onLayerEnter( ... )
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_FLUSH_DATA, handler(self, self._onRecvFlushData), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_AVATAR_FRAME_FUNCTION, handler(self, self._onRemoveHeadEffect), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CHANGE_ROLE_NAME_SUCCEED, self._onChangeRoleNameSucceed, self)

    if G_Me.userData:isNeedRequestNewData()  then
       G_HandlersManager.coreHandler:sendFlushUser()
    end
    if not self._isUpdate   then
        function setScale(name,value)
            local label = self:getLabelByName(name)
            if label then
                label:stopAllActions()
                label:setScale(1)
                self:_setText(name,value)
            end
        end
        setScale("Label_Silver",G_Me.userData.money)
        setScale("Label_Gold",G_Me.userData.gold)
        setScale("Label_FightValue",G_Me.userData.fight_value)
        setScale("Label_TiLi",G_Me.userData.vit)
        setScale("Label_JingLi",G_Me.userData.spirit)
        self:initAddLabel("Label_SilverAdd")
        self:initAddLabel("Label_GoldAdd")
        self:initAddLabel("Label_FightValueAdd")
        self:initAddLabel("Label_TiLiAdd")
        self:initAddLabel("Label_JingLiAdd")
        self:updateInfo()
    else
            local arr = CCArray:create()
            arr:addObject(CCDelayTime:create(0.5))
            arr:addObject(CCCallFunc:create(function (  )
                    self:updateInfo()
                end))
            self:runAction(CCSequence:create(arr))   
    end
         self._isUpdate = false
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_ROLE_INFO, self.recvData, self)
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_VIP_GETVIP, self._onVip, self)
    self:registerWidgetClickEvent("Panel_Bg",function(widget)
        --貌似不需要此判断 解决点出角色信息直接注销重新登录 人物头像不能点击的问题
        --if require("app.scenes.common.PopRoleInfoLayer").canShowRoleInfo() then   
            -- uf_notifyLayer:getModelNode():addChild(require("app.scenes.common.PopRoleInfoLayer").create())
            uf_sceneManager:getCurScene():addChild(require("app.scenes.common.PopRoleInfoLayer").create()) 
        --end
    end
        )

    self:registerWidgetClickEvent("ImageView_1168", function ( ... )
        self:showVip()
    end)
    self:registerWidgetClickEvent("LabelAtlas_VIP", function ( ... )
        self:showVip()
    end)
    
    self:registerBtnClickEvent("Button_Activity", handler(self, self.onActivity))
    
    -- vip动画
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        local vipLabel = self:getLabelAtlasByName("LabelAtlas_VIP")
        if vipLabel then
            if not self._vipShine then
                self._vipShine = EffectNode.new("effect_vipshine", function(event, frameIndex) end)
                vipLabel:addNode(self._vipShine,1)
                self._vipShine:play()
            end
        end
    end
    --self:updateInfo()
    
    -- 头像
    local _head = self:getImageViewByName("ImageView_Head")
    if _head then
        local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
        local knightInfo = knight_info.get(baseId)

        if knightInfo then
            -- local resId = knightInfo.res_id
            -- if knightId == G_Me.formationData:getMainKnightId() then 
            --     resId = G_Me.dressData:getDressedPic()
            -- end
            -- local sprite = CCSprite:create(G_Path.getKnightIcon(resId))
            -- local clip=CCClippingNode:create()
            -- clip:setInverted(false)
            -- clip:setAlphaThreshold(0)

            -- local head=CCSprite:create(G_Path.MainPage.MASK)
            -- clip:setStencil(head)
            -- _head:addNode(clip,10)
            -- clip:addChild(sprite)
            local sex = knightInfo.sex
            local sprite = nil
            if sex == 0 then
                sprite = CCSprite:create("ui/mainpage/touxiang_female.png")
            else
                sprite = CCSprite:create("ui/mainpage/touxiang_male.png")
            end
            _head:addNode(sprite)
        end

        if self._headEffect then
            self._headEffect:removeFromParentAndCleanup(true)
            self._headEffect = nil
        end  
        if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.SET_AVATAR) or G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CHANGE_ROLE_NAME) then
            
            if G_moduleUnlock:isNewModule(FunctionLevelConst.SET_AVATAR) or G_moduleUnlock:isNewModule(FunctionLevelConst.CHANGE_ROLE_NAME) then
                -- __Log("===================[RoleInfoUIComponent:onLayerEnter]  2")
                if not self._headEffect then
                    self._headEffect = EffectNode.new("effect_circle_light2", function(event) end)
                    self._headEffect:setPositionXY(-5, 0)
                    self:getImageViewByName("ImageView_Head"):addNode(self._headEffect, 20)                 
                    self._headEffect:play()
                end   
            end
        end    
    end

end

function RoleInfoUIComponent:_onRemoveHeadEffect( ... )
    if self._headEffect then
        self._headEffect:removeFromParentAndCleanup(true)
        self._headEffect = nil
    end  
end

function RoleInfoUIComponent:showVip( ... )
    local p = require("app.scenes.vip.VipMainLayer").create()
    G_Me.shopData:setVipEnter(true)   
    uf_sceneManager:getCurScene():addChild(p)
end

function RoleInfoUIComponent:recvData()
    if self:getParent()  then
        if  not G_commonLayerModel:getDelayUpdate()   then
            self:updateInfo()
            self._isUpdate = false
        else
            self._isUpdate = true
        end
    else
            self._isUpdate = false
    end
end

function RoleInfoUIComponent:onLayerExit(...)
    -- __Log("==============[RoleInfoUIComponent:onLayerExit]")
    uf_eventManager:removeListenerWithTarget(self)

    if self._fightValueChanger then
        self._fightValueChanger:stop()
        self._fightValueChanger = nil 
    end
    if self._fightValueChangerPet then
        self._fightValueChangerPet:stop()
        self._fightValueChangerPet = nil 
    end
    if self._vipShine then
        self._vipShine:removeFromParentAndCleanup(true)
        self._vipShine = nil
    end
    if self._headEffect then
        self._headEffect:removeFromParentAndCleanup(true)
        self._headEffect = nil
    end  
end

function RoleInfoUIComponent.create(barType)
    __LogTag("wkj","---------barType = %s",barType)
    local _josnPath = nil
    if barType == G_TopBarConst.TOPBAR_DUNGEON then
        _josnPath = "ui_layout/common_dungeon_topbar.json"
    elseif barType == G_TopBarConst.TOPBAR_DUNGEON_KONG then
        _josnPath = "ui_layout/common_dungeon_topbar_kong.json"
    elseif barType == G_TopBarConst.TOPBAR_TOWER then
        _josnPath = "ui_layout/common_tower_topbar.json"
    elseif barType == G_TopBarConst.TOPBAR_SHOP then
        _josnPath = "ui_layout/common_shop_topbar.json"
    elseif barType == G_TopBarConst.TOPBAR_BAG then
        _josnPath = "ui_layout/common_bag_topbar.json"
    elseif barType == G_TopBarConst.TOPBAR_STORYDUNGEON then
        _josnPath = "ui_layout/common_storydungeon_topbar.json"
    elseif barType == G_TopBarConst.TOPBAR_STRENGTHEN then
        _josnPath = "ui_layout/common_strengthen_topbar.json"
    elseif barType == G_TopBarConst.TOPBAR_FRIEND then
        _josnPath = "ui_layout/common_friend_topbar.json"
    elseif barType == G_TopBarConst.TOPBAR_TREASURE_ROB then
          _josnPath = "ui_layout/common_treasure_rob_topbar.json"  
    elseif barType == G_TopBarConst.TOPBAR_LEGION then
        _josnPath = "ui_layout/common_legion_topbar.json"
    elseif barType == G_TopBarConst.TOPBAR_EX_DUNGEON then
        _josnPath = "ui_layout/common_ex_dungeon_topbar.json"
    else 
        _josnPath = "ui_layout/common_RoleInfoUIComponent.json"
    end
    local roleInfo = RoleInfoUIComponent.new(_josnPath)
    roleInfo._barType = barType
    return roleInfo
end

-- 活动
function RoleInfoUIComponent:onActivity(widget)
    G_HandlersManager.battleHandler:sendBattleTest()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_BATTLE, self.onActivityCallBack, self)
end

function RoleInfoUIComponent:onActivityCallBack(message)
    uf_sceneManager:pushScene(require("app.scenes.battle.BattleScene").new({["msg"] = message}))
end

function RoleInfoUIComponent:_onChangeRoleNameSucceed(  )
    __Log("[RoleInfoUIComponent:_onChangeRoleName] name: %s", G_Me.userData.name)
    local nameLabel = self:getLabelByName("Label_Name")
    if nameLabel then
        nameLabel:setText(G_Me.userData.name)
    end
end

function RoleInfoUIComponent:updateInfo()

    local _role_info =  role_info.get(G_Me.userData.level)
    if _role_info == nil then return end
    self:updateCostValue()
    local _name = self:getLabelByName("Label_Name")
    if _name then  
        local mainInfo = G_Me.bagData.knightsData:getMainKightInfo()
        if mainInfo then 
            local knightInfo = knight_info.get(mainInfo["base_id"])
            if knightInfo then 
                _name:setColor(Colors.getColor(knightInfo and knightInfo.quality or 1)) 
            end
        end
        _name:setText(G_Me.userData.name)
        _name:createStroke(Colors.strokeBrown,1)
    end
    
    -- VIP
    local vipLabel = self:getLabelAtlasByName("LabelAtlas_VIP")
    if vipLabel then vipLabel:setStringValue(G_Me.userData.vip) end

    -- lv
    local level = self:getLabelByName("Label_Lv")
    if level then   
        level:setText(G_lang:get("LANG_LEVEL_INFO_FORMAT", {levelValue = G_Me.userData.level})) 
        level:createStroke(Colors.strokeBrown,1)
    end
    
    -- 银两
    self:showAddAnimation("Label_Silver",G_Me.userData.money,"money")

    
    -- 元宝
    self:showAddAnimation("Label_Gold",G_Me.userData.gold,"gold")

    -- 经验进度条
    local _proExp = self:getLoadingBarByName("LoadingBar_Exp")
    if _proExp then _proExp:setPercent(G_Me.userData.exp/_role_info.experience*100) end
     
     -- 战斗力Fnt
    --local _fightBMFont = self:getLabelBMFontByName("LabelBMFont_FightValue")
    local fightValueLabel = self:getLabelByName("Label_fightValueNumber")
    if fightValueLabel then 
        local valueSeted = false

        local oldFightValueIndex = self._fightValueIndex
        local fightValueIndex = 0
        local fightValueClr = Colors.qualityColors[1]
        if G_Me.userData.fight_value < 100000 then
            fightValueClr = Colors.qualityColors[1]
            fightValueIndex = 1
        elseif G_Me.userData.fight_value < 500000 then
            fightValueClr = Colors.qualityColors[2]
            fightValueIndex = 2
        elseif G_Me.userData.fight_value < 1000000 then
            fightValueClr = Colors.qualityColors[3]
            fightValueIndex = 3
        elseif G_Me.userData.fight_value < 2000000 then
            fightValueClr = Colors.qualityColors[4]
            fightValueIndex = 4
        elseif G_Me.userData.fight_value < 4000000 then
            fightValueClr = Colors.qualityColors[5]
            fightValueIndex = 5
        elseif G_Me.userData.fight_value < 8000000 then
            fightValueClr = Colors.qualityColors[6]
            fightValueIndex = 6
        else
            fightValueClr = Colors.qualityColors[7]
            fightValueIndex = 7
        end

        self._fightValueIndex = fightValueIndex
        
        if oldFightValueIndex > 0 and fightValueIndex > oldFightValueIndex then
            local backWidget = self:getWidgetByName("ImageView_5866")
            local effect  = EffectNode.new("effect_zl_huoyan", function(event)
                fightValueLabel:setText(GlobalFunc.ConvertNumToCharacter(G_Me.userData.fight_value))
                fightValueLabel:setColor(fightValueClr)
            end)
            backWidget:addNode(effect)
            effect:setVisible(false)
            effect:setPositionXY(40, 15)
            self:callAfterFrameCount(15, function ( ... )
                effect:setVisible(true)
                effect:play()    
            end)     
            valueSeted = true        
        elseif self._lastFightValue > 0 then
            fightValueLabel:setColor(fightValueClr)
            --print("last fight=" .. self._lastFightValue)
            if self._lastFightValue ~= G_Me.userData.fight_value then
                --增加一个变化动画
                if self._fightValueChanger then
                    self._fightValueChanger:stop()
                    self._fightValueChanger = nil 
                end
                local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
                self._fightValueChanger = NumberScaleChanger.new(fightValueLabel,  self._lastFightValue, G_Me.userData.fight_value,
                    function(value) 
                        fightValueLabel:setText(GlobalFunc.ConvertNumToCharacter(value))
                    end
                )

                valueSeted = true
            end
        end

        if not valueSeted then
            fightValueLabel:setText(GlobalFunc.ConvertNumToCharacter(G_Me.userData.fight_value))
        end


    end
    --战斗力Label
     self:showAddAnimation("Label_FightValue",G_Me.userData.fight_value,"fight_value")

    --  判断是否有宠物  判断等级是否够了
    local _pet = self:getImageViewByName("ImageView_pet")
    local fightValueLabelPet = self:getLabelByName("Label_petFightValueNumber")
    if _pet then 
        if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.PET) then 
            _pet:setVisible(false)
        else 
            _pet:setVisible(true)
            -- self:enableLabelStroke("Label_petFightValueNumber", Colors.strokeBrown, 2 )

            local petFightValue = 0
            -- 是否有战宠上阵
            if G_Me.bagData.petData:getFightPet() then
                petFightValue = G_Me.bagData.petData:getFightPet().fight_value
            end 
            -- 战力有变化
            if self._lastFightValuePet ~= petFightValue then
                if self._fightValueChangerPet then
                    self._fightValueChangerPet:stop()
                    self._fightValueChangerPet = nil 
                end
                local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
                self._fightValueChangerPet = NumberScaleChanger.new(fightValueLabelPet,  self._lastFightValuePet, petFightValue ,
                    function(value) 
                        fightValueLabelPet:setText(GlobalFunc.ConvertNumToCharacter(value))
                    end
                )
            else
                fightValueLabelPet:setText(GlobalFunc.ConvertNumToCharacter(petFightValue))
            end
            self._lastFightValuePet = petFightValue
        end
    end

    -- 爬塔积分
    local _score = self:getLabelBMFontByName("LabelBMFont_ScoreValue")
    if _score then 
        _score:setText(GlobalFunc.ConvertNumToCharacter(G_Me.userData.tower_score))
    end

    self._lastFightValue = G_Me.userData.fight_value
end

--VIP走单独协议
function RoleInfoUIComponent:_onVip()
    -- VIP
    local vipLabel = self:getLabelAtlasByName("LabelAtlas_VIP")
    print("RoleInfoUIComponent:_onVip=== vip = " .. G_Me.userData.vip)
    if vipLabel then vipLabel:setStringValue(G_Me.userData.vip) end
end

-- 显示添加数字动画
function RoleInfoUIComponent:showAddAnimation(addName,value,valueName)
    --local lastvalue = G_Me.userData:getLastData(valueName)
    --if lastvalue == nil then
    --    return
    --end
    local labelName = self:getLabelByName(addName .. "Add")    
    if labelName  then 
        local num = G_Me.userData:getLastData(valueName)
        local lastvalue = value - num
            if num == 0 then -- 初始状态
                labelName:setVisible(false)
                self:_setText(addName,value)
            else
                local _start ,_end = 0
                if num > 0 then
                    labelName:setText("+" ..  GlobalFunc.ConvertNumToCharacter(value - lastvalue))
                    labelName:setColor(Colors.uiColors.GREEN)
                    _start = lastvalue
                    _end = value
                else
                    labelName:setText( GlobalFunc.ConvertNumToCharacter(value - lastvalue))
                    _start = lastvalue
                    _end = value
                    labelName:setColor(Colors.uiColors.RED)
                end                
                labelName:setVisible(true)
                --labelName:setText(value)
                local arr = CCArray:create()
                local pt = self:getLabelByName(addName):getPositionInCCPoint()

                arr:addObject(CCShow:create())
                arr:addObject(CCCallFunc:create(function()
                    --labelName:setVisible(false)
                    --labelName:setPosition(self.posList[labelName:getName()].pos)

                    local _time = 0.5
                    local action1 = CCSequence:createWithTwoActions(CCScaleTo:create(_time/2, 2), CCScaleTo:create(_time/2, 1))
                    local growupNumber = CCNumberGrowupAction:create(_start, _end, _time, function ( number )
                        self:_setText(addName,number)
                    end)
                    action1 = CCSpawn:createWithTwoActions(growupNumber, action1)

                    self:getLabelByName(addName):runAction(action1)
            end
                ))
                arr:addObject(CCDelayTime:create(1))
                arr:addObject(CCHide:create())
                labelName:runAction(CCSequence:create(arr))
            end
            G_Me.userData:setLastValue(valueName,value)
    else
        local labelTTF = self:getLabelByName(addName)
        if labelTTF then
            self:_setText(addName,value,lastvalue)
        end
    end

end

function RoleInfoUIComponent:_setText(name,value)
    if value == "" then
            return
    end
    local labelName = self:getLabelByName(name)
    if labelName then
        if name == "Label_TiLi" then
            local _info = basic_figure_info.get(TYPE_VIT) -- 体力
            labelName:setText(tostring(value).. "/" .. tostring(_info.time_limit)) 
        elseif name == "Label_JingLi" then
            
            local _info = basic_figure_info.get(TYPE_SPIRIT) -- 精力
            labelName:setText(tostring(value) .. "/" .. tostring(_info.time_limit))
        else
            local txt = GlobalFunc.ConvertNumToCharacter(value)
            if txt ~= "" then
                 labelName:setText(txt)
            end
        end
    end
end


-- 计算当前点数
function RoleInfoUIComponent:_countCurrValue(_type,refresh_time,currValue)
    
    -- 计算恢复全部需要多长时间
    local _info = basic_figure_info.get(_type)   
    local leftTime = G_ServerTime:getLeftSeconds(refresh_time)
    local _value = math.ceil(leftTime/_info.unit_time)
    local temp = 0
    if _value < 0 then _value = 0 end
    if currValue > _info.time_limit then -- 超过上限值
        temp = currValue
    else
        temp = _info.time_limit - _value
    end
    return temp
end


function RoleInfoUIComponent:updateCostValue()
    self:showAddAnimation("Label_TiLi", G_Me.userData.vit,"vit")

    self:showAddAnimation("Label_JingLi", G_Me.userData.spirit,"spirit")
end




return RoleInfoUIComponent

