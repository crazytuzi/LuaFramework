--[[
******修炼结果*******

    -- by haidong.gan
    -- 2014/4/16
]]

--测试用例
    -- local layer =  AlertManager:addLayerByFile("lua.logic.role.RoleStarUpResultLayer");
    -- local cardRole1 = CardRoleManager.cardRoleList:objectAt(1);
    -- local cardRole2 = CardRoleManager.cardRoleList:objectAt(2);
    -- cardRole1.starlevel = 2
    --  local oldarr = {}
    -- --角色属性
    -- for i=1,EnumAttributeType.Max do
    --     oldarr[i] = cardRole2:getTotalAttribute(i);
    -- end

    -- layer:loadData(cardRole1.gmId,oldarr,cardRole1:getpower());
    -- AlertManager:show();


local RoleStarUpResultLayer = class("RoleStarUpResultLayer", BaseLayer)



local UI_STATES_INIT = 1
local UI_STATES_SHOW_LEFT_COM = 2
local UI_STATES_SHOW_RIGHT_COM = 3
local UI_STATES_SHOW_ATT_COM = 4
local UI_STATES_SHOW_ALL_COM = 5


function RoleStarUpResultLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.role_new.RoleStarUpResult")
    play_xiuliandengjitisheng()
end



function RoleStarUpResultLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.panel_close        = TFDirector:getChildByPath(ui, 'panel_close')
    
    self.panel_effect       = TFDirector:getChildByPath(ui, 'panel_effect')
    self.panel_arr          = TFDirector:getChildByPath(ui, 'panel_arr')

    self.img_role           = TFDirector:getChildByPath(ui, 'img_role')

    local panel_jiemianbiaoti = TFDirector:getChildByPath(ui, 'panel_jiemianbiaoti')
    self.txt_name           = TFDirector:getChildByPath(panel_jiemianbiaoti, 'txt_name')

    self.txt_level          = TFDirector:getChildByPath(ui, 'txt_level')
    self.img_quality_icon   = TFDirector:getChildByPath(ui, 'img_quality_icon')

    self.txt_power          = TFDirector:getChildByPath(ui, 'txt_power')
    self.panel_starbg       = TFDirector:getChildByPath(ui, 'panel_starbg')
    self.panel_star         = TFDirector:getChildByPath(ui, 'panel_star')
    self.img_namebg         = TFDirector:getChildByPath(ui, 'img_namebg')

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
        -- 

        self.img_arrow[i]:setVisible(false)
    end


    self.img_role_bg      = TFDirector:getChildByPath(ui, 'img_role_bg')
    self.img_attr         = TFDirector:getChildByPath(ui, 'img_attr')
    self.img_title       = TFDirector:getChildByPath(ui, 'img_title')
    self.fightBgImg       = TFDirector:getChildByPath(ui, 'fightBgImg')


    self.txt_level:setVisible(false)

    self.img_role_bg:setVisible(true)
    self.img_attr:setVisible(false)
    self.fightBgImg:setVisible(false)

    self.ui_satus = UI_STATES_INIT


    self.btn_ok:setVisible(false)
    -- local resPath = "effect/role_starup.xml"
    -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    -- self.effect = TFArmature:create("role_starup_anim")
  
    -- -- effect:setPosition(ccp(effPosX, effPosY))
    -- self.effect:setAnimationFps(GameConfig.ANIM_FPS)
    -- self.effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))
    -- self.panel_effect:addChild(self.effect,2)

    self.allEffectCompelte = false
end

function RoleStarUpResultLayer:loadData(roleGmId,oldarr,oldpower)
    self.roleGmId = roleGmId;
    self.oldarr = oldarr;
    self.oldpower = oldpower;
    print("oldpower：",oldpower)
end

function RoleStarUpResultLayer:setOldValue(quality, starlevel)
    self.old_quality    = quality
    self.old_starlevel  = starlevel
end



function RoleStarUpResultLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function RoleStarUpResultLayer:refreshBaseUI()

end

function RoleStarUpResultLayer:refreshUI()
    if not self.isShow then
        return;
    end
    self.cardRole = CardRoleManager:getRoleByGmid( self.roleGmId )

-- local UI_STATES_INIT = 1
-- local UI_STATES_SHOW_LEFT_COM = 2
-- local UI_STATES_SHOW_RIGHT_COM = 3
-- local UI_STATES_SHOW_ATT_COM = 4
-- local UI_STATES_SHOW_ALL_COM = 5
    -- self.ui_satus = UI_STATES_SHOW_LEFT_COM

    if self.ui_satus == UI_STATES_INIT then
        self.ui_satus = UI_STATES_SHOW_LEFT_COM
        self:drawLeftArea()
    else
        -- self:drawFullLayer()
        return
    end


    local trainItem_old= RoleTrainData:getRoleTrainByQuality(self.old_quality, self.old_starlevel)
    local trainItem_new = RoleTrainData:getRoleTrainByQuality(self.cardRole.quality, self.cardRole.starlevel)

    local newCardRoleData = RoleData:objectByID(self.cardRole.id)

    local level_up        = newCardRoleData:GetAttrLevelUp()


    self.img_role:setTexture(self.cardRole:getBigImagePath())
    self.txt_name:setText(self.cardRole.name)
    self.img_namebg:setTexture(GetRoleNameBgByQuality(self.cardRole.quality))
    -- self.txt_name:setColor(GetColorByQuality(self.cardRole.quality))
    self.txt_level:setText(self.cardRole.level .. "d")
    self.txt_power:setText(self.oldpower)
    self.img_quality_icon:setTexture(GetFontByQuality( self.cardRole.quality ))

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
            
            self.img_att[i]:setVisible(true)
            -- self.img_att[i]:setTexture("ui_new/common/icon_power_word/attr_" .. i .. ".png")
            print(attr_desc[i])
            self.txt_att[i]:setText(attr_desc[i])
            self.txt_att_old[i]:setText(""..old)
            self.txt_att_new[i]:setText(""..new)

            self.newarr[i] = new
            self.oldarr[i] = old
        else
            self.img_att[i]:setVisible(false)
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


    for i=1,5 do
        if i <= self.old_starlevel then
            self.img_star[i]:setVisible(true)
        else
            self.img_star[i]:setVisible(false)
        end
    end

    self.txt_level:setVisible(false)

    -- self.img_role:setVisible(false)
    -- self.txt_name:setVisible(false)
    -- self.img_quality_icon:setVisible(false)
    -- self.panel_starbg:setVisible(false)
    -- self.btn_ok:setVisible(false)
    -- self.panel_close:setVisible(false)
    

end


function RoleStarUpResultLayer:removeUI()
    self.super.removeUI(self)
end

function RoleStarUpResultLayer:registerEvents()
    self.super.registerEvents(self)

    -- ADD_ALERT_CLOSE_LISTENER(self, self.btn_ok)
    -- ADD_ALERT_CLOSE_LISTENER(self, self.panel_close)

    self.panel_close.logic = self 
    self.panel_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeLayer),1)
end


function RoleStarUpResultLayer:removeEvents()
    self.super.removeEvents(self)
    -- self.ui:updateToFrame("power_change",100)
    -- if self.power_effect then
    --     self.power_effect:setVisible(false)
    -- end
end

function RoleStarUpResultLayer:drawLeftArea()

    -- 左边居中 
    self:setLeftOnMiddle()

    self:ShowLeftAreaAction()
end

function RoleStarUpResultLayer:openRightArea()
    -- self:drawRightArea()
    self:resetPosition()

    self.img_attr:setVisible(true)
end

function RoleStarUpResultLayer:setLeftOnMiddle()
    -- 居中
    local parent        = self.img_role_bg:getParent()
    local sizeParent    = parent:getContentSize()
    local sizeImage     = self.img_role_bg:getContentSize()
    local pos           = self.img_role_bg:getPosition()

    local x = sizeParent.width/2
    local y = sizeParent.height/2

    self.img_role_bg:setPosition(ccp(x,y))
    self.img_attr:setPosition(ccp(x,y))
end


function RoleStarUpResultLayer:resetPosition()
    -- 居中
    local parent        = self.img_role_bg:getParent()
    local sizeParent    = parent:getContentSize()
    local sizeImage     = self.img_role_bg:getContentSize()
    local pos           = self.img_role_bg:getPosition()

    local center_x = sizeParent.width/2
    local center_y = sizeParent.height/2 + 15
    local gap      = 10 -- 两个框的间隔


    local left_x   = center_x - gap / 2 - sizeImage.width / 2
    local right_x  = center_x + gap / 2 + sizeImage.width / 2

    -- self.img_role_bg:setPosition(ccp(left_x,center_y))
    -- self.img_hechengdiag:setPosition(ccp(right_x,center_y))

    -- 开启动画
    self:moveArea(self.img_role_bg, ccp(left_x,center_y), -20)
    self:moveArea(self.img_attr, ccp(right_x,center_y), 20)

    local resPath = "effect/role_starup1.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    effect = TFArmature:create("role_starup1_anim")
  
    -- effect:setPosition(ccp(effPosX, effPosY))
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))
    self:addChild(effect,2)
    effect:playByIndex(0, -1, -1, 0)
end


function RoleStarUpResultLayer:ShowLeftAreaAction()
    local layer = self.img_role_bg

    TFDirector:setFPS(GameConfig.FPS * 2)


    layer:setOpacity(0);

    local toastTween = {
        target = layer,
        {
            delay = 1 / 60,
            onComplete = function() 
                -- layer:setOpacity(100);
                layer:setScale(0.7);
            end
        },
        {
            duration = 0.15,
            alpha = 1,
            scale = 1.05,
        },
        {
            duration = 0.03,
            scale = 1,
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

function RoleStarUpResultLayer:moveArea(target_, toPos, xGap)
    local toastTween = {
      target = target_,
      {
        duration = 0.2,
        x = toPos.x + xGap,
        y = toPos.y
      },
      {
        duration = 0.05,
        x = toPos.x,
        y = toPos.y
      },
      {
        duration = 0,
        onComplete = function()
         self:DisplayMoveComplete(target_)
       end
      }
    }

    TFDirector:toTween(toastTween);
end

function RoleStarUpResultLayer:DisplayMoveComplete(target)

    if target == self.img_attr then
        print("right area is move end")

        self:ShowTitleAction(self.img_title, "star_up_title_effect", 168, 23)
    end
end

function RoleStarUpResultLayer:drawStarAction()
    for i=1,5 do
        if i == self.cardRole.starlevel then
            -- self.img_star[i]:setVisible(true)
            local starNode = self.img_star[i]
            local pos = starNode:getPosition()
            local parent = starNode:getParent()

            -- TFResourceHelper:instance():addArmatureFromJsonFile("effect/star_up_star_effect.xml")
            -- local effect = TFArmature:create("star_up_star_effect_anim")
            ModelManager:addResourceFromFile(2, "star_up_star_effect", 1)
            local effect = ModelManager:createResource(2, "star_up_star_effect")
            if effect == nil then
                return
            end

            effect:addMEListener(TFARMATURE_COMPLETE,function()
                effect:removeMEListener(TFARMATURE_COMPLETE) 
                effect:removeFromParent()

                starNode:setVisible(true)
                self:openRightArea()
            end)

            effect:setAnimationFps(GameConfig.ANIM_FPS)
            ModelManager:playWithNameAndIndex(effect, "", 0, 1, -1, -1)
            -- effect:playByIndex(0, -1, -1, 0)
            -- effect:setPosition(ccp(25 + pos.x, 20 + pos.y))
            effect:setPosition(ccp(pos.x, pos.y))
            parent:addChild(effect)
            return
        end
    end
end

function RoleStarUpResultLayer:ShowTitleAction(button, effName, posX, posY)
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effName..".xml")
    local effect = TFArmature:create(effName.."_anim")
    if effect == nil then
        return
    end

    effect:addMEListener(TFARMATURE_COMPLETE,function()
        effect:removeMEListener(TFARMATURE_COMPLETE) 
        effect:removeFromParent()

        self:showAttrValueAction()
    end)

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)
    effect:setPosition(ccp(posX, posY))
    button:addChild(effect)
end

function RoleStarUpResultLayer:showAttrValueAction()
    if self.attr_index == nil then
        self.attr_index = 1
    end

    if self.attr_index > 5 then
        self:showTotalPowerAction()
        return
    end

    local layer = self.img_arrow[self.attr_index]

    TFDirector:setFPS(GameConfig.FPS * 2)

    layer:setVisible(true)
    layer:setOpacity(0);

    local toastTween = {
        target = layer,
        {
            delay = 1 / 60,
            onComplete = function() 
                -- layer:setOpacity(100);
                layer:setScale(0.7);
            end
        },
        {
            duration = 0.15,
            alpha = 1,
            scale = 1.05,
        },
        {
            duration = 0.03,
            scale = 1,
        },
        {
            duration = 0,
            onComplete = function() 
                TFDirector:setFPS(GameConfig.FPS)
                self.attr_index = self.attr_index + 1
                self:showAttrValueAction()
            end
        }
    }

    TFDirector:toTween(toastTween);
    -- self:showTotalPowerAction()
end

function RoleStarUpResultLayer:showTotalPowerAction()
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
        self.allEffectCompelte = true
    end)

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)
    effect:setPosition(ccp(120, 20))
    self.fightBgImg:addChild(effect)


    self:textChange(self.oldpower,self.cardRole.power)
end


function RoleStarUpResultLayer.closeLayer(sender)
    local self = sender.logic

    if self.allEffectCompelte == true then
        AlertManager:close()

    else
        self.allEffectCompelte = true
        self:drawFullLayer()
    end



end

function RoleStarUpResultLayer:drawFullLayer()

    for i=1,5 do
        self.img_arrow[i]:setVisible(true)
    end

    for j=1,5 do
        if j <= self.cardRole.starlevel then
            self.img_star[j]:setVisible(true)
        else
            self.img_star[j]:setVisible(false)
        end
    end

    local parent        = self.img_role_bg:getParent()
    local sizeParent    = parent:getContentSize()
    local sizeImage     = self.img_role_bg:getContentSize()

    local center_x = sizeParent.width/2
    local center_y = sizeParent.height/2 + 15
    local gap      = 10 -- 两个框的间隔

    local left_x   = center_x - gap / 2 - sizeImage.width / 2
    local right_x  = center_x + gap / 2 + sizeImage.width / 2

    self.img_role_bg:setPosition(ccp(left_x,center_y))
    self.img_attr:setPosition(ccp(right_x,center_y))

    self.img_role_bg:setVisible(true)
    self.img_attr:setVisible(true)


    self.fightBgImg:setVisible(true)

    self.btn_ok:setVisible(true)
    self.allEffectCompelte = true
end


function RoleStarUpResultLayer:textChange(oldValue,newValue)
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

return RoleStarUpResultLayer

