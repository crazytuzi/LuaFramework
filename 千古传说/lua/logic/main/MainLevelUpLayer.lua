--[[
******团队升级面板*******

    -- by haidong.gan
    -- 2014/6/14
]]

local MainLevelUpLayer = class("MainLevelUpLayer", BaseLayer)

--CREATE_SCENE_FUN(MainLevelUpLayer)
CREATE_PANEL_FUN(MainLevelUpLayer)


function MainLevelUpLayer:ctor()
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.main.MainLevelUpLayer")
    self.first  = false
end


function MainLevelUpLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close          = TFDirector:getChildByPath(ui, 'btn_close')
  
    self.img_level        = TFDirector:getChildByPath(ui, 'img_level')
    self.img_tili         = TFDirector:getChildByPath(ui, 'img_tili')
    self.panel_info         = TFDirector:getChildByPath(ui, 'panel_info')
    self.img_role         = TFDirector:getChildByPath(self.panel_info , 'img_role')

    self.img_equip        = TFDirector:getChildByPath(ui, 'img_equip')
    self.img_open         = TFDirector:getChildByPath(ui, 'img_open')
    self.img_open_2       = TFDirector:getChildByPath(ui, 'img_open_2')
    self.panel_role       = TFDirector:getChildByPath(ui, 'panel_role')
    self.pic_role         = TFDirector:getChildByPath(self.panel_role, 'panel_spawn')
    self.panel_effect     = TFDirector:getChildByPath(ui, 'panel_effect')
    self.txt_level        = TFDirector:getChildByPath(ui, 'txt_level')


    -- local resPath = "effect/ui/main_levelup.xml"
    -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    -- local effect = TFArmature:create("main_levelup_anim")

    -- effect:setAnimationFps(GameConfig.ANIM_FPS)
    -- effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2+210))

    -- self.panel_role:addChild(effect,2)

    -- effect:addMEListener(TFARMATURE_COMPLETE,function()
    --     -- effect:removeMEListener(TFARMATURE_COMPLETE) 
    --     -- effect:removeFromParent()
    -- end)

    -- self.effect = effect;
    local role_id = MainPlayer:getProfession()
    local role = RoleData:objectByID(role_id)
    -- self.pic_role:setTexture(role:getBigImagePath())
    -- self.pic_role:setVisible(false)

    local armatureID = role.image
    ModelManager:addResourceFromFile(1, armatureID, 1)
    local model = ModelManager:createResource(1, armatureID)
    model:setPosition(ccp(self.panel_role:getSize().width / 2, 25))
    -- model:setZOrder(10)
    ModelManager:playWithNameAndIndex(model, "stand", -1, 1, -1, -1)
    self.pic_role:addChild(model)
end

function MainLevelUpLayer:loadData(info)
    self.newLevel = MainPlayer:getLevel()
    self.oldLevel = self.newLevel - info.levelUp
    self.levelUpInfo = info
    self.txt_level:setText(self.newLevel)
    -- self:freshInfo()
end

function MainLevelUpLayer:onHide()
    self.super.onHide(self)
    self:setVisible(false);
end

function MainLevelUpLayer:onShow()
    self.super.onShow(self)
    self:setVisible(true);
    if self.first == false then
        self:refreshUI();
        self.first  = true
    end
end

function MainLevelUpLayer:refreshUI()

    play_lingdaolitisheng()

    -- local function play_effect(target,index)
    --     local toastTween = {
    --               target = target,
    --               {
    --                 duration = 0,
    --                 delay = 0.4 + (index - 1)*0.3,
    --               },
    --               {
    --                 duration = 0,
    --                 onComplete = function() 
    --                     target:setVisible(true);
    --                 end
    --               },
    --               {
    --                 duration = 0,
    --                 alpha = 1,
    --               },
    --               {
    --                 duration = 4/24,
    --                 scale = 1.3,
    --               },
             

    --               {
    --                  duration = 3/24,
    --                  alpha = 1,
    --                  scale = 1,
    --               },
    --               {
    --                 duration = 0,
    --                 onComplete = function() 
    --                 end
    --               }
    --             }

    --     TFDirector:toTween(toastTween);
    -- end
    -- self.effect:playByIndex(0, -1, -1, 0)

    local LevelOpen = require('lua.table.t_s_open')             --vip配置表
    local openfuncitonStr = "";
    local color = ccc3(0,255,0);
    for i= self.oldLevel + 1, self.newLevel do
        for v in LevelOpen:iterator() do
            if v.level == i then
                if v.openfunction and v.openfunction ~="" then
                    if openfuncitonStr ~= "" then
                        openfuncitonStr = openfuncitonStr .. "|" .. v.openfunction;
                    else
                        openfuncitonStr = openfuncitonStr .. v.openfunction;
                    end
                end
                color = v.color or color
            end
        end
    end
    local opendesArr = string.split(openfuncitonStr,'|')
    local txt_opendes = TFDirector:getChildByPath(self.img_open, 'txt_des')
    local txt_opendes1 = TFDirector:getChildByPath(self.img_open_2, 'txt_des')
    local lb_open = TFDirector:getChildByPath(self.img_open, 'lb')

    lb_open:setVisible(false);
    txt_opendes1:setVisible(true);
    txt_opendes:setColor(color)
    txt_opendes1:setColor(color)

    if #opendesArr > 0 and opendesArr[1] and opendesArr[1] ~="" then
        lb_open:setVisible(true);
        txt_opendes:setText(opendesArr[1]);
    end

    if #opendesArr > 1 then
        txt_opendes1:setText(opendesArr[2]);
    else
        txt_opendes1:setText("");
    end

    local txt_oldlevel = TFDirector:getChildByPath(self.img_level, 'txt_old')
    local txt_newlevel = TFDirector:getChildByPath(self.img_level, 'txt_new')
    txt_oldlevel:setText(self.oldLevel)
    txt_newlevel:setText(self.newLevel)

    local times = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.PUSH_MAP);
    local txt_oldtili = TFDirector:getChildByPath(self.img_tili, 'txt_old')
    local txt_newtili = TFDirector:getChildByPath(self.img_tili, 'txt_new')
    txt_oldtili:setText(self.levelUpInfo.oldStamina)
    txt_newtili:setText(self.levelUpInfo.newStamina)

    local txt_oldrole = TFDirector:getChildByPath(self.img_role, 'txt_old')
    local txt_newrole = TFDirector:getChildByPath(self.img_role, 'txt_new')

    txt_oldrole:setText(ConstantData:getValue("Equip.StrengthenMax.Multiple") * self.oldLevel)
    txt_newrole:setText(ConstantData:getValue("Equip.StrengthenMax.Multiple") * self.newLevel)

    local txt_oldequip = TFDirector:getChildByPath(self.img_equip, 'txt_old')
    local txt_newequip = TFDirector:getChildByPath(self.img_equip, 'txt_new')
    
    txt_oldequip:setText(ConstantData:getValue("Equip.StrengthenMax.Multiple") * self.oldLevel)
    txt_newequip:setText(ConstantData:getValue("Equip.StrengthenMax.Multiple") * self.newLevel)


    self.ui:setAnimationCallBack("put_role", TFANIMATION_END, function()
        -- local resPath = "effect/ui/level_role_down.xml"
        -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        -- local effect = TFArmature:create("level_role_down_anim")

        -- effect:setAnimationFps(GameConfig.ANIM_FPS)
        -- effect:setPosition(ccp(160,220))
        -- self.panel_role:addChild(effect,1)
        -- effect:playByIndex(0, -1, -1, 0)

        local effect = Public:addEffect("level_role_down2", self.panel_role, 160, -30, 0.5, 1)
        effect:setZOrder(1)
        local temp = 0
        effect:addMEListener(TFSKELETON_UPDATE,function()
            temp = temp + 1
            if temp == 13 then
                --  local resPath_1 = "effect/ui/level_up_lizi.xml"
                -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath_1)
                -- local effect_1 = TFArmature:create("level_up_lizi_anim")
                -- effect_1:setAnimationFps(GameConfig.ANIM_FPS)
                -- effect_1:setPosition(ccp(60,-40))
                -- self.panel_role:addChild(effect_1,2)
                -- effect_1:playByIndex(0, -1, -1, 1)
                local liziEft = Public:addEffect("level_up_lizi2", self.panel_role, 160, -40, 0.8, 1)
                liziEft:setZOrder(2)
            end
        end)


        -- resPath = "effect/ui/level_role_up.xml"
        -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        -- effect = TFArmature:create("level_role_up_anim")

        -- effect:setAnimationFps(GameConfig.ANIM_FPS)
        -- effect:setPosition(ccp(160,220))
        -- self.panel_role:addChild(effect,3)        
        -- effect:playByIndex(0, -1, -1, 0)
        local upEft = Public:addEffect("level_role_up", self.panel_role, 160, -60, 0.9, 0)
        upEft:setZOrder(3)

        local resPath = "effect/ui/level_up_light.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        effect = TFArmature:create("level_up_light_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(85,60))
        self.panel_effect:addChild(effect,1)        
        effect:playByIndex(0, -1, -1, 1)

        self.ui:runAnimation("show_info",1);
    end)

    self.ui:runAnimation("put_role",1);


end


function MainLevelUpLayer:removeUI()
	self.super.removeUI(self)
end


function MainLevelUpLayer:registerEvents()
    self.super.registerEvents(self)
    self.btn_close:addMEListener(TFWIDGET_CLICK, 
    audioClickfun(function() 
        AlertManager:close()
        PlayerGuideManager:OnMainLevelUpLayerClose()
    end),1)

    self.btn_close:setClickAreaLength(100);

    self.ui:addMEListener(TFWIDGET_CLICK, 
    audioClickfun(function() 
        if self.skipEffect == nil then
            self.ui:updateToFrame("put_role", 100)
            self.ui:updateToFrame("show_info", 100)
            self.skipEffect = true
        end
    end),1)
end

function MainLevelUpLayer:removeEvents()
    self.super.removeEvents(self)
end

return MainLevelUpLayer
