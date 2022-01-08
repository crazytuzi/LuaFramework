--[[
******修炼结果*******

    -- quanhuan
    -- 2015-10-8 17:59:40
]]

local RoleStarUpResultNewLayer = class("RoleStarUpResultNewLayer", BaseLayer)


function RoleStarUpResultNewLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.role_new.RoleStarUpResultNew")
    play_xiuliandengjitisheng()
end


function RoleStarUpResultNewLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.panel_effect       = TFDirector:getChildByPath(ui, 'Panel_RoleStarUpResult')
    self.panel_close        = self.ui

    self.img_role           = TFDirector:getChildByPath(ui, 'panel_role')
    self.txt_power          = TFDirector:getChildByPath(ui, 'txt_power')


    self.panel_star         = TFDirector:getChildByPath(ui, 'panel_star')
    self.panel_star:setZOrder(100)

    self.img_star           = {}
    for i=1,5 do
        self.img_star[i]  = TFDirector:getChildByPath(self.panel_star, 'img_starliang' .. i)
    end


    self.txt_att           = {}
    self.img_att           = {}
    self.txt_att_old       = {}
    self.txt_att_new       = {}
    self.img_arrow         = {}
    for i=1,5 do
        local attr_Node = TFDirector:getChildByPath(ui, "img_attr_" .. i)
        self.img_att[i] = attr_Node
        self.txt_att[i] = TFDirector:getChildByPath(attr_Node, "txt_name")
        self.txt_att_old[i] = TFDirector:getChildByPath(attr_Node, "txt_old_attr")
        self.txt_att_new[i] = TFDirector:getChildByPath(attr_Node, "txt_new_attr")
        self.img_arrow[i] = TFDirector:getChildByPath(attr_Node, "img_arrow")
    end

    self.img_attr         = TFDirector:getChildByPath(ui, 'img_attr')
    self.img_title       = TFDirector:getChildByPath(ui, 'img_title')
    self.fightBgImg       = TFDirector:getChildByPath(ui, 'fightBgImg')

    --激活显示
    local newNode = TFDirector:getChildByPath(ui, 'bg_qianli')
    self.newFuncName = TFDirector:getChildByPath(newNode, 'txt_name')
    self.newFuncContect = TFDirector:getChildByPath(newNode, 'txt_yuanfen_word')
    self.newStarArray = {}
    local Panel_star = TFDirector:getChildByPath(newNode, 'Panel_star')
    for i=1,5 do
        self.newStarArray[i] = TFDirector:getChildByPath(Panel_star, 'img_star_light_'..i)
    end

    self.panel_close:setTouchEnabled(false)
    self.img_attr:setVisible(false)
    self.btn_ok:setVisible(false) 
end

function RoleStarUpResultNewLayer:loadData(roleGmId,oldarr,oldpower)
    self.roleGmId = roleGmId;
    self.oldarr = oldarr;
    self.oldpower = oldpower;
end

function RoleStarUpResultNewLayer:setOldValue(quality, starlevel)
    self.old_quality    = quality
    self.old_starlevel  = starlevel
end



function RoleStarUpResultNewLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function RoleStarUpResultNewLayer:refreshBaseUI()

end

function RoleStarUpResultNewLayer:refreshUI()
    if not self.isShow then
        return;
    end
    self.cardRole = CardRoleManager:getRoleByGmid( self.roleGmId )

    self:drawLeftArea()

    local trainItem_old= RoleTrainData:getRoleTrainByQuality(self.old_quality, self.old_starlevel)
    local trainItem_new = RoleTrainData:getRoleTrainByQuality(self.cardRole.quality, self.cardRole.starlevel)

    local newCardRoleData = RoleData:objectByID(self.cardRole.id)

    local level_up        = newCardRoleData:GetAttrLevelUp()


    -- self.img_role:setTexture(self.cardRole:getBigImagePath())
    self.img_role:removeAllChildren()

    local armatureID = self.cardRole.image
    ModelManager:addResourceFromFile(1, armatureID, 1)
    local model = ModelManager:createResource(1, armatureID)
    model:setPosition(ccp(self.img_role:getSize().width / 2, 0))
    -- model:setScale(0.9)
    ModelManager:playWithNameAndIndex(model, "stand", -1, 1, -1, -1)
    self.img_role:addChild(model)

    self.txt_power:setText(self.oldpower)

    self.oldarr = {}
    self.newarr = {}
    local count = 0

    --local attr_desc = {"气血成长", "武力成长", "防御成长", "内力成长", "身法成长"}
    local attr_desc = localizable.roleStartupPre_desc
    for i=1,5 do

        local old = trainItem_old.streng_then * level_up[i]
        local new = trainItem_new.streng_then * level_up[i]

        if new ~= old then
            count = count + 1
            print(attr_desc[i])
            self.txt_att[i]:setText(attr_desc[i])
            self.txt_att_old[i]:setText(""..old)
            self.txt_att_new[i]:setText(""..new)

            self.newarr[i] = new
            self.oldarr[i] = old        
        end
    end


    local changeArrTemp = {}
    local changeLength = 0;
    for i=1,count do
        local offset = self.newarr[i] - self.oldarr[i];
        if offset ~= 0 then
            changeLength = changeLength + 1;
            changeArrTemp[changeLength] = {i,offset};
        end
    end


    self.changeLength = changeLength;
    self.changeArrTemp = changeArrTemp;


    -- for i=1,5 do
    --     if i <= self.old_starlevel then
    --         self.img_star[i]:setVisible(true)
    --     else
    --         self.img_star[i]:setVisible(false)
    --     end
    -- end
    for i=1,5 do
        self.img_star[i]:setVisible(false)
    end
    for i=1,self.old_starlevel do
        
        local starIdx = i
        local starTextrue = 'ui_new/common/xl_dadian22_icon.png'
        if i > 5 then
            starTextrue = 'ui_new/common/xl_dadian23_icon.png'
            starIdx = i - 5
        end
        self.img_star[starIdx]:setTexture(starTextrue)        
        self.img_star[starIdx]:setVisible(true)     
    end    

    --激活显示
    local roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( self.cardRole.id )
    local newFunInfo = roleInfoList:getObjectAt(self.cardRole.starlevel)
    if newFunInfo then
        self.newFuncName:setText(newFunInfo.name)
        self.newFuncContect:setText(newFunInfo.desc)
        -- for i=1,5 do
        --     if i <= self.cardRole.starlevel then
        --         self.newStarArray[i]:setVisible(true)
        --     else
        --         self.newStarArray[i]:setVisible(false)
        --     end
        -- end
        for i=1,5 do
            self.newStarArray[i]:setVisible(false)
        end
        for i=1,self.cardRole.starlevel do
            local starIdx = i
            local starTextrue = 'ui_new/common/xl_dadian22_icon.png'
            if i > 5 then
                starTextrue = 'ui_new/common/xl_dadian23_icon.png'
                starIdx = i - 5
            end
            
            self.newStarArray[starIdx]:setTexture(starTextrue)        
            self.newStarArray[starIdx]:setVisible(true)     
        end            
    end
end


function RoleStarUpResultNewLayer:removeUI()
    self.super.removeUI(self)
end

function RoleStarUpResultNewLayer:registerEvents()
    self.super.registerEvents(self)
    self.panel_close.logic = self 
    self.panel_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeLayer),1)
end


function RoleStarUpResultNewLayer:removeEvents()
    self.super.removeEvents(self)
    self.panel_close:removeMEListener(TFWIDGET_CLICK)
    if self.powerTimerID then
        TFDirector:removeTimer(self.powerTimerID)
        self.powerTimerID = nil
    end
end

function RoleStarUpResultNewLayer:drawLeftArea()
    self:ShowLeftAreaAction()
end

function RoleStarUpResultNewLayer:openRightArea()
    -- self:drawRightArea()
    --self:resetPosition()
    self.ui:runAnimation("Action0",1);
    self.ui:setAnimationCallBack("Action0", TFANIMATION_END, function()
        self:showTotalPowerAction()
    end)

    self.img_attr:setVisible(true)
end

function RoleStarUpResultNewLayer:ShowLeftAreaAction()
    local layer = self.img_role

    TFDirector:setFPS(GameConfig.FPS * 2)


    layer:setOpacity(0);

    local toastTween = {
        target = layer,
        {
            delay = 1 / 60,
            -- onComplete = function() 
            --     -- layer:setOpacity(100);
            --     layer:setScale(0.7);
            -- end
        },
        {
            duration = 0.15,
            alpha = 1,
            scale = 1.2,
        },
        {
            duration = 0.03,
            scale = 1.0,
        },
        {
            duration = 0,
            onComplete = function() 
                TFDirector:setFPS(GameConfig.FPS)
                self:drawStarAction()
            end
        }
    }

    TFDirector:toTween(toastTween);
 
end

function RoleStarUpResultNewLayer:drawStarAction()
    for i=1,self.cardRole.maxStar do
        if i == self.cardRole.starlevel then
            -- self.img_star[i]:setVisible(true)
            local starIdx = i
            if i > 5 then
                starIdx = i - 5
            end
            local starNode = self.img_star[starIdx]
            local pos = starNode:getPosition()
            local parent = starNode:getParent()

            -- local animJsonPath = "effect/star_up_star_effect.xml"
            -- local animPath = "star_up_star_effect_anim"
            -- if i > 5 then
            --     animJsonPath = "effect/star_up_star_o_effect.xml"
            --     animPath = "star_up_star_o_effect_anim"
            -- end
            -- TFResourceHelper:instance():addArmatureFromJsonFile(animJsonPath)
            -- local effect = TFArmature:create(animPath)
            local effectName = "star_up_star_effect"
            if i > 5 then
                effectName = "star_up_star_o_effect"
            end
            ModelManager:addResourceFromFile(2, effectName, 1)
            local effect = ModelManager:createResource(2, effectName)
            if effect == nil then
                return
            end

            effect:addMEListener(TFARMATURE_COMPLETE,function()
                effect:removeMEListener(TFARMATURE_COMPLETE) 
                effect:removeFromParent()
                local starTextrue = 'ui_new/common/xl_dadian22_icon.png'
                local newStarIdx = 1
                if i > 5 then
                    starTextrue = 'ui_new/common/xl_dadian23_icon.png'
                    newStarIdx = i - 5
                end
                
                starNode:setTexture(starTextrue)        
                starNode:setVisible(true)                
            end)

            -- effect:setAnimationFps(GameConfig.ANIM_FPS)
            -- effect:playByIndex(0, -1, -1, 0)
            ModelManager:playWithNameAndIndex(effect, "", 0, 0, -1, -1)
            effect:setPosition(ccp(pos.x+4, pos.y-8))
            effect:setZOrder(1)
            parent:addChild(effect)

            self.footEffectTimer = TFDirector:addTimer(1000, 1, nil, 
                function()
                    TFDirector:removeTimer(self.footEffectTimer)
                    self.footEffectTimer = nil

                    local effect = Public:addEffect("level_role_down2", self.img_role:getParent(), 260, 100, 0.5, 1)
                    effect:setZOrder(10)
                    self.img_role:setZOrder(11)
                    local temp = 0
                    effect:addMEListener(TFSKELETON_UPDATE,function()
                        temp = temp + 1
                        if temp == 13 then
                            local liziEft = Public:addEffect("level_up_lizi2", self.img_role:getParent(), 260, 90, 0.8, 1)
                            liziEft:setZOrder(12)
                        end
                    end)

                    local upEft = Public:addEffect("level_role_up", self.img_role:getParent(), 260, 70, 0.9, 0)
                    upEft:setZOrder(12)
                    end)
            self.moveToRightTimer = TFDirector:addTimer(1400, 1, nil, 
                function()
                    self:openRightArea()
                    TFDirector:removeTimer(self.moveToRightTimer)
                    self.moveToRightTimer = nil
                    end)
            self.floorEffectTimer = TFDirector:addTimer(1700, 1, nil, 
                function()
                    TFDirector:removeTimer(self.floorEffectTimer)
                    self.floorEffectTimer = nil
                    local resPath = "effect/role_starup1.xml"
                    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                    effect = TFArmature:create("role_starup1_anim")
                  
                    effect:setAnimationFps(GameConfig.ANIM_FPS)
                    effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))
                    self:addChild(effect,2)
                    effect:playByIndex(0, -1, -1, 0)
                    effect:addMEListener(TFARMATURE_COMPLETE,function()
                        effect:removeMEListener(TFARMATURE_COMPLETE) 
                        effect:removeFromParent()
                    end)

                    end)
            return
        end
    end
end



function RoleStarUpResultNewLayer:showTotalPowerAction()
    self.fightBgImg:setVisible(true)
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/star_up_power_effect.xml")
    local effect = TFArmature:create("star_up_power_effect_anim")
    if effect == nil then
        return
    end

    effect:addMEListener(TFARMATURE_COMPLETE,function()
        effect:removeMEListener(TFARMATURE_COMPLETE) 
        effect:removeFromParent()
        self.btn_ok:setVisible(true)
        self.panel_close:setTouchEnabled(true)
        self.allEffectCompelte = true
    end)

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)
    effect:setPosition(ccp(120, 20))
    self.fightBgImg:addChild(effect)


    self:textChange(self.oldpower,self.cardRole.power)
end


function RoleStarUpResultNewLayer.closeLayer(sender)
    local self = sender.logic
    AlertManager:close()
end

function RoleStarUpResultNewLayer:textChange(oldValue,newValue)
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

    self.powerTimerID = TFDirector:addTimer(1000/60, 40, nil, 
                function() 
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
                        TFDirector:removeTimer(self.powerTimerID)
                        self.powerTimerID = nil
                    end
                    frame = frame + 1
                end)
end

return RoleStarUpResultNewLayer

