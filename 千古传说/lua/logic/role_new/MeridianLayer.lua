--[[
******角色经脉*******
    -- by david.dai
    -- 2015/5/18
]]
local MeridianLayer = class("MeridianLayer", BaseLayer)

function MeridianLayer:ctor(data)
    self.super.ctor(self,data);
    self.fightType = EnumFightStrategyType.StrategyType_PVE
    self:init("lua.uiconfig_mango_new.role.TrainLayer")
end

local acupointCapacity = 6

function MeridianLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.RoleTrain,{HeadResType.COIN,HeadResType.SYCEE,HeadResType.GENUINE_QI})

    self.panel_role        = TFDirector:getChildByPath(ui, 'panel_rolehead')
    self.panel_content     = TFDirector:getChildByPath(ui, 'panel_content')
    self.panel_jingmai     = TFDirector:getChildByPath(ui, 'Panel_jingmai')
    self.panel_exp         = TFDirector:getChildByPath(self.panel_content, 'panel_exp')

    self.img_role       = TFDirector:getChildByPath(self.panel_role, 'img_head')
    self.txt_name       = TFDirector:getChildByPath(self.panel_role, 'txt_name')
    self.img_quality    = TFDirector:getChildByPath(self.panel_role, 'img_quality')
    self.txt_power      = TFDirector:getChildByPath(self.panel_role, 'txt_power')
    self.img_type       = TFDirector:getChildByPath(self.panel_role, 'img_zhiye')
    self.txt_level         = TFDirector:getChildByPath(self.panel_exp, 'txt_level')
    self.bar_percent       = TFDirector:getChildByPath(self.panel_exp, 'bar_percent')
    self.btn_lianti = TFDirector:getChildByPath(ui, 'btn_lianti');
	self.btn_level_up  	= TFDirector:getChildByPath(ui, 'btn_level_up')
	self.txt_consume 	= TFDirector:getChildByPath(ui, 'txt_consume')
    self.btn_yjcx  = TFDirector:getChildByPath(ui, 'btn_yjcx');

    self.img_diwen1        = TFDirector:getChildByPath(ui, 'img_diwen1')

    self.btn_tupo = TFDirector:getChildByPath(ui, 'btn_tupo')

	self.acupointTable = {}
	self.detailsTable = {}
	local acupoint,panelDetails = nil,nil
	for i = 1,acupointCapacity do
		panelDetails = TFDirector:getChildByPath(ui,'panel_details_' .. i)
		panelDetails['level'] = TFDirector:getChildByPath(panelDetails,'txt_acupoint_lv')
		panelDetails['name'] = TFDirector:getChildByPath(panelDetails,'txt_attribute_name')
        panelDetails['value'] = TFDirector:getChildByPath(panelDetails,'txt_attribute_value')
		panelDetails['change'] = TFDirector:getChildByPath(panelDetails,'txt_change')
        panelDetails['change']:setVisible(false)
		self.detailsTable[i] = panelDetails

		acupoint = TFDirector:getChildByPath(ui,'img_acupoint_' .. i)
		acupoint['img'] = TFDirector:getChildByPath(acupoint,'btn_point')
		acupoint['progress'] = TFDirector:getChildByPath(acupoint,'bar_jidu')
		acupoint['selected'] = TFDirector:getChildByPath(acupoint,'img_xuanzhong')
		acupoint['details'] = panelDetails
		self.acupointTable[i] = acupoint
	end

    local img_shenfa     = TFDirector:getChildByPath(self.panel_jingmai, 'img_shenfa')
    local img_kangbao    = TFDirector:getChildByPath(self.panel_jingmai, 'img_kangbao')
    local img_shanbi     = TFDirector:getChildByPath(self.panel_jingmai, 'img_shanbi')
    local img_baoji      = TFDirector:getChildByPath(self.panel_jingmai, 'img_baoji')
    local img_fangyu     = TFDirector:getChildByPath(self.panel_jingmai, 'img_fangyu')
    local img_mingzhong  = TFDirector:getChildByPath(self.panel_jingmai, 'img_mingzhong')
    self.imgs = {[3]=img_fangyu, [5]=img_shenfa, [12]=img_baoji, [13]=img_kangbao, [14]=img_mingzhong, [15]=img_shanbi}

    -- 左右按钮
    self.btn_left           = TFDirector:getChildByPath(ui, 'btn_pageleft')
    self.btn_right          = TFDirector:getChildByPath(ui, 'btn_pageright')
    self.positiony          = self.btn_right:getPosition().y
    self.panel_list         = TFDirector:getChildByPath(ui, 'panel_list')
    self:drawRoleList()
end

function MeridianLayer:removeUI()
    self.super.removeUI(self)
end

function MeridianLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function MeridianLayer:loadData(roleGmId,fightType)
    self.roleGmId   = roleGmId
    self.fightType = fightType
end

function MeridianLayer:onShow()
	self.super.onShow(self)
	self.generalHead:onShow()
    self:refreshBaseUI()
    self:refreshUI()
end

function MeridianLayer:refreshBaseUI()
	-- local cardRole = CardRoleManager:getRoleByGmid(self.roleGmId)

 --    --左侧角色信息显示
	-- self.img_role:setTexture(cardRole:getBigImagePath())
 --    self.txt_name:setText(cardRole.name)
 --    self.img_diwen1:setTexture(GetRoleNameBgByQuality(cardRole.quality))
 --    self.img_quality:setTexture(GetFontByQuality(cardRole.quality))
 --    self.txt_level:setText(cardRole.level)
 --    self.txt_power:setText(cardRole:getPowerByFightType(self.fightType))
 --    self.img_type:setTexture("ui_new/common/img_role_type" .. cardRole.outline .. ".png")
end

function MeridianLayer:refreshUI()

    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);
    self.selectIndex = self.roleList:indexOf(self.cardRole)
    self:refreshRoleList(self.selectIndex)
    
    if self.cardRole then
        if self.cardRole.quality >= 4 then
            local teamLev = MainPlayer:getLevel()
            local openLev = FunctionOpenConfigure:getOpenLevel(2205)
            if teamLev < openLev then
                self.btn_lianti:setVisible(false)
            else
                self.btn_lianti:setVisible(true)
            end
        else
            self.btn_lianti:setVisible(false)
        end
    end
    -- local cardRole = CardRoleManager:getRoleByGmid(self.roleGmId)
    -- local configure = MeridianConfigure:objectByID(cardRole.id)
    -- local currentIndex = cardRole:getCurrentAcupointIndex()

    -- self.txt_power:setText(cardRole:getPowerByFightType(self.fightType))

    -- --每个穴位信息显示
    -- local acupoint = nil
    -- local info = nil
    -- local level = 0
    -- local panelDetails = nil
    -- for i = 1,acupointCapacity do
    --     acupoint = self.acupointTable[i]
    --     info = cardRole:GetAcupointInfo(i)
    --     if info then
    --     	level = info.level
    --     else
    --     	level = 0
    --     end
    --     acupoint['progress']:setPercent(level * 100 /configure.max_level)
    --     acupoint['selected']:setVisible(false)
    --     acupoint['selected']:setGrayEnabled(true)

    --     panelDetails = acupoint['details']
    --     if info then
    --     	--panelDetails:setVisible(true)
    --     	panelDetails['level']:setText(level)
    --     	local attKey,factor = configure:getAttribute(i)
    --     	panelDetails['name']:setText(AttributeTypeStr[attKey] .. ":")
    --     	panelDetails['value']:setText(math.floor(factor * level))
    --     else
    --     	--panelDetails:setVisible(false)
    --         panelDetails['level']:setText(0)
    --         local attKey,factor = configure:getAttribute(i)
    --         panelDetails['name']:setText(AttributeTypeStr[attKey] .. ":")
    --         panelDetails['value']:setText(0)
    --     end
    -- end

    -- local currentAcupoint = cardRole:GetAcupointInfo(currentIndex)
    -- if currentAcupoint then
    --     level = currentAcupoint.level
    --     if level >= configure.max_level then
    --         self.btn_level_up:setGrayEnabled(true)
    --         self.btn_level_up:setTouchEnabled(false)
    --         self.txt_consume:setVisible(false)
    --         return
    --     end
    -- else
    --     level = 0
    -- end


    -- self.btn_level_up:setGrayEnabled(false)
    -- self.btn_level_up:setTouchEnabled(true)

    -- if MainPlayer:getVipLevel() < ConstantData:objectByID("yijianchongxue.VipLevel").value then
    --     self.btn_yjcx:setGrayEnabled(true)
    --     self.btn_yjcx:setTouchEnabled(false)
    -- else
    --     self.btn_yjcx:setGrayEnabled(false)
    --     self.btn_yjcx:setTouchEnabled(true)
    -- end

    -- acupoint = self.acupointTable[currentIndex]
    -- acupoint['selected']:setVisible(false)
    -- acupoint['selected']:setGrayEnabled(false)
    -- self:addXuanzhongEffect(acupoint,"meridianeffect")

    -- self.txt_consume:setVisible(true)
    -- local consumeConfigure = MeridianConsume:objectByID(level + 1)
    -- self.txt_consume:setText(consumeConfigure.cost)

    -- -- local enough = MainPlayer:isEnough(consumeConfigure.type,consumeConfigure.cost)
    -- local haveRes = MainPlayer:getResValueByType(consumeConfigure.type)
    -- if haveRes >= consumeConfigure.cost then
    --     self.txt_consume:setColor(ccc3(255, 255, 255))
    -- else
    --     self.txt_consume:setColor(ccc3(255, 0, 0))
    -- end
end



function MeridianLayer:registerEvents(ui)
	self.super.registerEvents(self)

    self.btn_level_up.logic     = self
    self.btn_level_up:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onlevelUpClickHandle),1)
    -- self.btn_level_up:addMEListener(TFWIDGET_TOUCHBEGAN, self.onlevelUpTouchBeganHandle)
    -- self.btn_level_up:addMEListener(TFWIDGET_TOUCHMOVED, self.onlevelUpTouchMovedHandle)
    -- self.btn_level_up:addMEListener(TFWIDGET_TOUCHENDED, self.onlevelUpTouchEndedHandle)

    self.btn_tupo.logic = self
    self.btn_tupo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTupoClickHandle),1)

    self.btn_yjcx.logic = self
    self.btn_yjcx:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onUplevlToTopClickHandle),1)

    self.btn_lianti.logic = self
    self.btn_lianti:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onLianTiClickHandle),1)
 
	for i=1,acupointCapacity do
        self.acupointTable[i]['img']:setTouchEnabled(false)
		-- self.acupointTable[i]['img']:setTag(i);
  --       self.acupointTable[i]['img'].logic = self;
		-- self.acupointTable[i]['img']:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAcupointClickHandle,play_xuanze));
	end

    self.RoleAcupointUpdate = function(event)
        local data = event.data[1]
        local acupointList = data.acupointList
        --通知的角色实例ID跟当前界面的不一致
        if data.instanceId ~= self.roleGmId then
            return
        end

        local cardRole = CardRoleManager:getRoleByGmid(self.roleGmId)
        if not cardRole then
            return
        end
        local configure = MeridianConfigure:objectByID(cardRole.id)
        for k,acupointInfo in pairs(data.acupointList) do
            local level = acupointInfo.level
            local showEffect = false
            local tempLevel = 0
            if acupointInfo.position >= self.oldAcupoint.index and level > self.oldAcupoint.level then
                showEffect = true
                tempLevel = level - self.oldAcupoint.level
            elseif acupointInfo.position < self.oldAcupoint.index and level > self.oldAcupoint.level+1 then
                showEffect = true
                tempLevel = level - (self.oldAcupoint.level+1)
            end
            if showEffect == true then
                local effect = self.acupointTable[acupointInfo.position].effect
                if not effect or not effect:getParent() then
                    local resPath = "effect/role_train.xml"
                    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                    effect = TFArmature:create("role_train_anim")
                    effect:setAnimationFps(GameConfig.ANIM_FPS)

                    effect:addMEListener(TFARMATURE_COMPLETE,function()
                        effect:removeFromParent()
                        self.acupointTable[acupointInfo.position].effect = nil
                    end)
                    effect:setPosition(ccp(-50,0))
                    -- effect:setZOrder(100)
                    self.acupointTable[acupointInfo.position].effect = effect
                    self.acupointTable[acupointInfo.position]:addChild(effect)
                end
                effect:playByIndex((math.random() * 10) % 3, -1, -1, 0)


                local attKey = configure:getAttribute(acupointInfo.position)
                local breachLevel = acupointInfo.breachLevel or 0
                local _acupointInfo = AcupointBreachData:getData( attKey, breachLevel )
                local factor = _acupointInfo.value

            
                local effect_B = self.detailsTable[acupointInfo.position].effect
                if not effect_B then
                    local resPath = "effect/role_train_B.xml"
                    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                    effect_B = TFArmature:create("role_train_B_anim")

                    effect_B:setAnimationFps(GameConfig.ANIM_FPS)

                    effect_B:addMEListener(TFARMATURE_COMPLETE,function()
                        effect_B:removeFromParent()
                        self.detailsTable[acupointInfo.position].effect = nil
                    end)
                    effect_B:setPosition(ccp(60,20))
                    -- effect:setZOrder(100)
                    self.detailsTable[acupointInfo.position].effect = effect_B
                    self.detailsTable[acupointInfo.position]:addChild(effect_B)


                    self.detailsTable[acupointInfo.position].change:setText("+" .. factor*tempLevel)
                    self:refiningNumEffect(self.detailsTable[acupointInfo.position].change)

                end
                effect_B:playByIndex(0, -1, -1, 0)
            end
            self:refreshUI()

            self:textChange(self.oldPower,cardRole:getPowerByFightType(self.fightType))
        end

    end
    TFDirector:addMEGlobalListener(CardRoleManager.UPDATE_ROLE_TRAIN_INFO,  self.RoleAcupointUpdate)
    self.RoleAllAcupointUpdate = function(event)
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(CardRoleManager.UPDATE_ALL_ROLE_TRAIN_INFO,  self.RoleAllAcupointUpdate)

    self.upLevelResultCallBack = function(event)
        local data = event.data[1]
        local acupointInfo = data.acupointInfo
        --通知的角色实例ID跟当前界面的不一致
        if data.instanceId ~= self.roleGmId then
            return
        end

        local cardRole = CardRoleManager:getRoleByGmid(self.roleGmId)
        if not cardRole then
            return
        end

        local configure = MeridianConfigure:objectByID(cardRole.id)

        -- if self.panel_jingmai.effect == nil  then
        --     local resPath = "effect/role_train_A.xml"
        --     TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        --     local effect = TFArmature:create("role_train_A_anim")

        --     effect:setAnimationFps(GameConfig.ANIM_FPS)

        --     effect:addMEListener(TFARMATURE_COMPLETE,function()
        --         -- effect:removeMEListener(TFARMATURE_COMPLETE) 
        --         effect:removeFromParent()
        --         self.panel_jingmai.effect = nil
        --     end)
        --     effect:setPosition(ccp(195,285))
        --     effect:setZOrder(100)
        --     self.panel_jingmai.effect = effect
        --     self.panel_jingmai:addChild(effect)
        -- end
        -- self.panel_jingmai.effect:playByIndex(acupointInfo.position-1, -1, -1, 0)

        -- local effect = self.acupointTable[acupointInfo.position].effect
        -- if not effect or not effect:getParent() then
        --     local resPath = "effect/role_train.xml"
        --     TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        --     effect = TFArmature:create("role_train_anim")
        --     effect:setAnimationFps(GameConfig.ANIM_FPS)

        --     effect:addMEListener(TFARMATURE_COMPLETE,function()
        --         effect:removeFromParent()
        --         self.acupointTable[acupointInfo.position].effect = nil
        --     end)
        --     effect:setPosition(ccp(-50,0))
        --     -- effect:setZOrder(100)
        --     self.acupointTable[acupointInfo.position].effect = effect
        --     self.acupointTable[acupointInfo.position]:addChild(effect)
        -- end
        -- effect:playByIndex((math.random() * 10) % 3, -1, -1, 0)
        local effect = self.acupointTable[acupointInfo.position].effect
        if not effect then
            effect = Public:addEffect("lianti9", self.acupointTable[acupointInfo.position], -60, 0, 1, 0)
            effect:setZOrder(100)
            self.acupointTable[acupointInfo.position].effect = effect
        else
            ModelManager:playWithNameAndIndex(effect, "", 0, 0, -1, -1)
        end


		local level = acupointInfo.level
		local attKey = configure:getAttribute(acupointInfo.position)
        local breachLevel = acupointInfo.breachLevel or 0
        local AcupointInfo = AcupointBreachData:getData( attKey, breachLevel )
        local factor = AcupointInfo.value
		-- local attributeStr = AttributeTypeStr[attKey] .. "+" .. factor

        local effect_B = self.detailsTable[acupointInfo.position].effect
        if not effect_B then
            local resPath = "effect/role_train_B.xml"
            TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
            effect_B = TFArmature:create("role_train_B_anim")

            effect_B:setAnimationFps(GameConfig.ANIM_FPS)

            effect_B:addMEListener(TFARMATURE_COMPLETE,function()
                effect_B:removeFromParent()
                self.detailsTable[acupointInfo.position].effect = nil
            end)
            effect_B:setPosition(ccp(60,20))
            -- effect:setZOrder(100)
            self.detailsTable[acupointInfo.position].effect = effect_B
            self.detailsTable[acupointInfo.position]:addChild(effect_B)

            self.detailsTable[acupointInfo.position].change:setText("+" .. factor)
            self:refiningNumEffect(self.detailsTable[acupointInfo.position].change)
        end
        effect_B:playByIndex(0, -1, -1, 0)
		-- toastMessage("升级至" .. level .. "级，" .. attributeStr)
        self:refreshUI()

        self:textChange(self.oldPower,cardRole:getPowerByFightType(self.fightType))

    end;
    TFDirector:addMEGlobalListener(CardRoleManager.ACUPOINT_LEVEL_UP_RESULT,self.upLevelResultCallBack);

    if self.generalHead then
        self.generalHead:registerEvents()
    end


    -- 牛逼的策划要加左右滑动
    self.btn_left.logic = self;
    self.btn_left:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onLeftClickHandle),1)
    self.btn_right.logic = self;
    self.btn_right:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onRightClickHandle),1)

end

function MeridianLayer:refiningNumEffect(widget )
    TFDirector:killAllTween(widget)
    widget:setVisible(true)
    widget:setScale(0.1)
    local tween = {
        target = widget,
            {
                duration = 0.1,
                scale = 1,
            },
            {
                duration = 0.1,
                scale = 0.8,
            },
            {
                duration = 0.1,
                scale = 1,
            },
            {
                duration = 0,
                delay = 1,
                onComplete = function ()
                    widget:setVisible(false)
                end,
            },
    }
    TFDirector:toTween(tween)

end
function MeridianLayer:removeEvents()
    TFDirector:removeMEGlobalListener(CardRoleManager.ACUPOINT_LEVEL_UP_RESULT ,self.upLevelResultCallBack)
    TFDirector:removeMEGlobalListener(CardRoleManager.UPDATE_ROLE_TRAIN_INFO, self.RoleAcupointUpdate)
    TFDirector:removeMEGlobalListener(CardRoleManager.UPDATE_ALL_ROLE_TRAIN_INFO, self.RoleAllAcupointUpdate)
    self.upLevelResultCallBack  = nil
    self.RoleAcupointUpdate     = nil
    self.RoleAllAcupointUpdate  = nil
    for i=1,acupointCapacity do
		self.acupointTable[i]['img']:removeMEListener(TFWIDGET_CLICK)
	end
    self.super.removeEvents(self)
    -- self.ui:updateToFrame("power_change",100)
    if self.power_effect then
        self.power_effect:setVisible(false)
    end
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    print('MeridianLayer:removeEvents')
end

function MeridianLayer:textChange(oldValue,newValue)
    if not oldValue or not newValue then
        return;
    end
    self.txt_power:setText(oldValue);

    local changeSum = newValue - oldValue

    if self.power_effect == nil then
        -- local resPath = "effect/ui/power_change.xml"
        -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        -- effect = TFArmature:create("power_change_anim")

        -- self.txt_power:addChild(effect,2)
        local effect = Public:addEffect("power_change", self.txt_power, 0, -10, 0.5, 0)
        effect:setZOrder(2)    
        self.power_effect = effect
        self.power_effect:setVisible(false)
    end

    local frame = 1
    self.txt_power:setScale(1)
    self.ui:setAnimationCallBack("power_change", TFANIMATION_FRAME, function()
        if frame == 11 then
            self.power_effect:setVisible(true)
            -- self.power_effect:playByIndex(0, -1, -1, 0)
            ModelManager:playWithNameAndIndex(self.power_effect, "", 0, 0, -1, -1)
        end
        if frame >= 11 and frame < 34 then
            if newValue > oldValue then
                play_shuzibiandong()
            end
            local tempValue = oldValue + (frame - 11) *(changeSum/23)
            self.txt_power:setText(math.floor(tempValue));
        end
        if frame == 34 then
            self.power_effect:removeFromParent()
            self.power_effect = nil
            self.txt_power:setText(newValue);
        end
        frame = frame + 1
    end)
    self.ui:runAnimation("power_change",1);
end

function MeridianLayer:levelUp(istop)
	local cardRole = CardRoleManager:getRoleByGmid(self.roleGmId)
    local extraLianTiInfo = cardRole:getExtraLianTiAttri()
	local acupointIndex = cardRole:getCurrentAcupointIndex()
    local currentAcupoint = cardRole:GetAcupointInfo(acupointIndex)
    local level = 0
    if currentAcupoint then
        level = currentAcupoint.level
    else
        level = 0
    end
    if level >= cardRole.level + extraLianTiInfo.meridians then
        --toastMessage("角色经脉等级不能超过角色等级")
        toastMessage(localizable.MeridianLayer_text1)
        return
    end
    local consumeConfigure = MeridianConsume:objectByID(level + 1)
    local enough = MainPlayer:isEnough(consumeConfigure.type,consumeConfigure.cost)
    if enough then
        self.oldPower = cardRole:getPowerByFightType(self.fightType)
        self.oldAcupoint = {index = acupointIndex,level = level}
        if istop == true then
            CardRoleManager:upLevelAcupontToTop(cardRole.gmId)
            play_chongxue();
        else
            CardRoleManager:upLevelAcupont(cardRole.gmId,acupointIndex)
        end
    end
end

function MeridianLayer.onlevelUpClickHandle(sender)
	local self = sender.logic
    self:levelUp()
end
function MeridianLayer.onUplevlToTopClickHandle(sender)
    local vipLevel = ConstantData:objectByID("yijianchongxue.VipLevel").value
    if MainPlayer:getVipLevel() < vipLevel then
        --toastMessage("VIP"..vipLevel.."级开放")
        toastMessage(stringUtils.format(localizable.common_vip_open,vipLevel))
        return
    end
    local self = sender.logic;
    self:levelUp(true)
end

function MeridianLayer.onLianTiClickHandle(sender)
    local self = sender.logic;
    local layer = require("lua.logic.role_new.RoleLianTiLayer"):new(self.cardRole.id)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function MeridianLayer.onlevelUpTouchBeganHandle(sender)
    local self = sender.logic;
 	self.haveLongTouch = false;
    local function onLongTouch()
	    self.islevelUpTouch = true;
	    self.haveLongTouch = true;

        TFDirector:removeTimer(self.longTouchTimerId);
	    self:levelUp();
    end

    self.longTouchTimerId = TFDirector:addTimer(300, 1, nil, onLongTouch); 
end

function MeridianLayer.onlevelUpTouchMovedHandle(sender)
    local self = sender.logic;
    -- TFDirector:removeTimer(self.longTouchTimerId);
    -- self.islevelUpTouch = false;
end

function MeridianLayer.onlevelUpTouchEndedHandle(sender)
    local self = sender.logic;
    TFDirector:removeTimer(self.longTouchTimerId);
    self.islevelUpTouch = false;
end

function MeridianLayer.onAcupointClickHandle(sender)
	--local self = sender.logic;
	--local index = sender:getTag();
	--for i=1,acupointCapacity do
	--	self.acupointTable[i]['selected']:setVisible(false)
	--end
	--local acupoint = self.acupointTable[index]
	--acupoint['selected']:setVisible(true)
end

function MeridianLayer:addXuanzhongEffect( widget , effectName )
    if self.xuanzhong_effect then
        self.xuanzhong_effect:removeFromParentAndCleanup(false)
        self.xuanzhong_effect:playByIndex(0, -1, -1, 1)
    else
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effectName..".xml")
        local effect = TFArmature:create(effectName.."_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:playByIndex(0, -1, -1, 1)
        effect:setScale(0.65)
        effect:setPosition(ccp(-85,39))
        self.xuanzhong_effect = effect
    end
    widget:addChild(self.xuanzhong_effect)
    self.xuanzhong_effect:setZOrder(100)
end


function MeridianLayer:setRoleList(cardRoleList)
    self.roleList = cardRoleList
end

function MeridianLayer.onLeftClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:getCurPageIndex() ;
    self.pageView:scrollToPage(pageIndex - 1);

    -- TFDirector:dispatchGlobalEventWith("MoveRoleListToLeft")
end

function MeridianLayer.onRightClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:getCurPageIndex() ;
    self.pageView:scrollToPage(pageIndex + 1);


    -- TFDirector:dispatchGlobalEventWith("MoveRoleListToRight")
end

function MeridianLayer:drawRoleList()
    local pageView = TPageView:create()

    self.pageView = pageView

    pageView:setTouchEnabled(true)
    pageView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    pageView:setSize(self.panel_list:getContentSize())
    pageView:setAnchorPoint(self.panel_list:getAnchorPoint())

    local function onPageChange()
        self:onPageChange();
    end
    pageView:setChangeFunc(onPageChange)

    local function itemAdd(index)
        return  self:addPage(index)
    end 
    pageView:setAddFunc(itemAdd)

    self.panel_list:addChild(pageView,2)
end


function MeridianLayer:addPage(pageIndex) 
    local page = TFPanel:create();
    page:setSize(self.panel_list:getContentSize())

    local cardRole = self.roleList:objectAt(pageIndex)

    -- local img_role = TFImage:create(cardRole:getBigImagePath())

    -- img_role:setScale(0.65)
    -- img_role:setFlipX(true)
    -- img_role:setAnchorPoint(ccp(0.5,0.5))
    -- img_role:setPosition(ccp(320/2,500/2 + 50))
    -- page:addChild(img_role)

    local armatureID = cardRole.image
    ModelManager:addResourceFromFile(1, armatureID, 1)
    local model = ModelManager:createResource(1, armatureID)
    model:setPosition(ccp(140, 130))
    model:setScale(0.9)
    ModelManager:playWithNameAndIndex(model, "stand", -1, 1, -1, -1)
    
    page:addChild(model)
  
    self.pageList[cardRole.id] = page

    return page;
end

function MeridianLayer:onPageChange()
    local pageIndex = self.pageView:_getCurPageIndex()
    -- if self.selectIndex > pageIndex then
    --     TFDirector:dispatchGlobalEventWith("MoveRoleListToLeft")

    -- elseif self.selectIndex < pageIndex then
    --     TFDirector:dispatchGlobalEventWith("MoveRoleListToRight")
    -- end
    TFDirector:dispatchGlobalEventWith("MoveRoleListToLeft",{pageIndex = pageIndex-self.selectIndex})

    self:showInfoForPage(pageIndex);
    if self.cardRole then
        if self.cardRole.quality >= 4 then
            local teamLev = MainPlayer:getLevel()
            local openLev = FunctionOpenConfigure:getOpenLevel(2205)
            if teamLev < openLev then
                self.btn_lianti:setVisible(false)
            else
                self.btn_lianti:setVisible(true)
            end
        else
            self.btn_lianti:setVisible(false)
        end
    end
end

function MeridianLayer:showInfoForPage(pageIndex)
    self.selectIndex = pageIndex;

    -- self:refreshRoleInfo()
    local pageCount = self.roleList:length()

    self.btn_left:setPosition(ccp(self.btn_left:getPosition().x,1000))
    self.btn_right:setPosition(ccp(self.btn_right:getPosition().x,1000))

    if pageIndex < pageCount and pageCount > 1 then
        self.btn_right:setPosition(ccp(self.btn_right:getPosition().x,self.positiony))
    end 

    if pageIndex > 1 and pageCount > 1  then
        self.btn_left:setPosition(ccp(self.btn_left:getPosition().x,self.positiony))
    end


    self:drawRole()

end

function MeridianLayer:refreshRoleList(pageIndex)
    self.pageView:_removeAllPages();

    self.pageView:setMaxLength(self.roleList:length())

    self.pageList        = {};

    self:showInfoForPage(pageIndex);

    self.pageView:InitIndex(pageIndex);      
end

function MeridianLayer:setRoleList(roleList)
    self.roleList = roleList
end

function MeridianLayer:drawRole()
    self.cardRole   = self.roleList:objectAt(self.selectIndex);
    self.roleGmId   = self.cardRole.gmId;


    local cardRole  = self.cardRole --CardRoleManager:getRoleByGmid(self.roleGmId)
    local configure = MeridianConfigure:objectByID(cardRole.id)
    local currentIndex = cardRole:getCurrentAcupointIndex()

    self.txt_power:setText(cardRole:getPowerByFightType(self.fightType))

    --每个穴位信息显示
    local acupoint = nil
    local info = nil
    local level = 0
    local panelDetails = nil
    local breachLevel = 0

    for i,img in pairs(self.imgs) do
        img:setVisible(false)
    end

    for i = 1,acupointCapacity do
        acupoint = self.acupointTable[i]
        info = cardRole:GetAcupointInfo(i)
        if info then
            level = info.level
            breachLevel = info.breachLevel
        else
            level = 0
            breachLevel = 0
        end
        acupoint['progress']:setPercent(level * 100 /configure.max_level)
        acupoint['selected']:setVisible(false)
        acupoint['selected']:setGrayEnabled(true)

        panelDetails = acupoint['details']
        local attKey,factor = configure:getAttribute(i)
        panelDetails['name']:setText(AttributeTypeStr[attKey] .. ":")
        local img = self.imgs[attKey]
        if img then img:setVisible(true) end
        if info then
            --panelDetails:setVisible(true)
            panelDetails['level']:setText(level)
            local AcupointInfo = AcupointBreachData:getData( attKey, breachLevel )
            panelDetails['value']:setText(math.floor(AcupointInfo.value * level))
        else
            --panelDetails:setVisible(false)
            panelDetails['level']:setText(0)
            panelDetails['value']:setText(0)
        end
    end

    local currentAcupoint = cardRole:GetAcupointInfo(currentIndex)
    if currentAcupoint then
        level = currentAcupoint.level
        if level >= configure.max_level then
            self.btn_level_up:setGrayEnabled(true)
            self.btn_level_up:setTouchEnabled(false)
            self.txt_consume:setVisible(false)
            return
        end
    else
        level = 0
    end


    self.btn_level_up:setGrayEnabled(false)
    self.btn_level_up:setTouchEnabled(true)

    if MainPlayer:getVipLevel() < ConstantData:objectByID("yijianchongxue.VipLevel").value then
        self.btn_yjcx:setGrayEnabled(true)
        self.btn_yjcx:setTouchEnabled(false)
    else
        self.btn_yjcx:setGrayEnabled(false)
        self.btn_yjcx:setTouchEnabled(true)
    end

    acupoint = self.acupointTable[currentIndex]
    acupoint['selected']:setVisible(false)
    acupoint['selected']:setGrayEnabled(false)
    self:addXuanzhongEffect(acupoint,"lianti9")

    self.txt_consume:setVisible(true)
    local consumeConfigure = MeridianConsume:objectByID(level + 1)
    self.txt_consume:setText(consumeConfigure.cost)

    -- local enough = MainPlayer:isEnough(consumeConfigure.type,consumeConfigure.cost)
    local haveRes = MainPlayer:getResValueByType(consumeConfigure.type)
    if haveRes >= consumeConfigure.cost then
        self.txt_consume:setColor(ccc3(255, 255, 255))
    else
        self.txt_consume:setColor(ccc3(255, 0, 0))
    end


    --左侧角色信息显示
    self.img_role:setVisible(false)
    self.txt_name:setText(cardRole.name)
    self.img_diwen1:setTexture(GetRoleNameBgByQuality(cardRole.quality))
    self.img_quality:setTexture(GetFontByQuality(cardRole.quality))
    self.txt_level:setText(cardRole.level)
    self.txt_power:setText(cardRole:getPowerByFightType(self.fightType))
    self.bar_percent:setPercent((cardRole.curExp/cardRole.maxExp)*100)
    self.img_type:setTexture("ui_new/common/img_role_type" .. cardRole.outline .. ".png")
end

function MeridianLayer.onTupoClickHandle( btn )
    local self = btn.logic
    -- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.TrainLayerBreakLayer");
    -- layer:loadData(self.roleGmId);
    -- AlertManager:show();
    local needLevelIndex = ConstantData:getValue("North.Cave.Open.Floor");

    if ClimbManager:getClimbFloorNum() < needLevelIndex then        
        -- local str = TFLanguageManager:getString(ErrorCodeData.JINGMAI_SURMOUNT_OPEN_NOT_ENOUGH_LEVEL)
        -- str = string.format(str,needLevelIndex)

        local str = stringUtils.format(localizable.JINGMAI_SURMOUNT_OPEN_NOT_ENOUGH_LEVEL,needLevelIndex)
        toastMessage(str)
        return
    end

    CardRoleManager:openTrainLayerBreakLayer(self.roleGmId)
end

return MeridianLayer
