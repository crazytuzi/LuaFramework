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


function RoleStarUpResultLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.role.RoleStarUpResultLayer")
    play_xiuliandengjitisheng()
end
    -- self.node_roleArr = {}
    -- self.img_roleArr = {}
    -- self.txt_LevelArr = {}
    -- self.txt_NameArr = {}

    -- self.img_qualityWordArr = {}
    -- self.txt_trainMaxArr = {}
    -- self.txt_openTrainArr = {}
    -- for i=1,2 do
    --     self.node_roleArr[i] = TFDirector:getChildByPath(ui, "panel_card_"..i)
    --     self.img_roleArr[i] = TFDirector:getChildByPath(self.node_roleArr[i], "img_touxiang")
    --     self.txt_LevelArr[i] = TFDirector:getChildByPath(self.node_roleArr[i], "txt_lv_word")
    --     self.txt_NameArr[i] = TFDirector:getChildByPath(self.node_roleArr[i], "txt_name")

    --     self.img_qualityWordArr[i] = TFDirector:getChildByPath(ui, "img_pinzhi" .. i)
    --     self.txt_trainMaxArr[i] = TFDirector:getChildByPath(ui, "img_lv" .. i)
    --     self.txt_openTrainArr[i] = TFDirector:getChildByPath(ui, "txt_jingmai" .. i)

    -- end

    -- self.txt_skillname = TFDirector:getChildByPath(ui, "txt_skillname")


function RoleStarUpResultLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.panel_close             = TFDirector:getChildByPath(ui, 'panel_close')
    
    self.panel_effect        = TFDirector:getChildByPath(ui, 'panel_effect')
    self.panel_arr        = TFDirector:getChildByPath(ui, 'panel_arr')

    self.img_role           = TFDirector:getChildByPath(ui, 'img_role')
    self.txt_name           = TFDirector:getChildByPath(ui, 'txt_name')
    self.txt_level          = TFDirector:getChildByPath(ui, 'txt_level')
    self.img_quality_icon   = TFDirector:getChildByPath(ui, 'img_quality_icon')

    self.txt_power          = TFDirector:getChildByPath(ui, 'txt_power')
    self.panel_starbg       = TFDirector:getChildByPath(ui, 'panel_starbg')
    self.panel_star         = TFDirector:getChildByPath(ui, 'panel_star')

    self.img_star           = {}
    for i=1,5 do
        self.img_star[i]  = TFDirector:getChildByPath(self.panel_star, 'img_starliang' .. i)
    end


    self.txt_att           = {}
    for i=1,11 do
        self.txt_att[i] = TFDirector:getChildByPath(ui, "txt_add" .. i)
    end


    local resPath = "effect/role_starup.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    self.effect = TFArmature:create("role_starup_anim")
  
    -- effect:setPosition(ccp(effPosX, effPosY))
    self.effect:setAnimationFps(GameConfig.ANIM_FPS)
    self.effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))
    self.panel_effect:addChild(self.effect,2)
end

function RoleStarUpResultLayer:loadData(roleGmId,oldarr,oldpower)
    self.roleGmId = roleGmId;
    self.oldarr = oldarr;
    self.oldpower = oldpower;
    print("oldpower：",oldpower)
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

    self.img_role:setTexture(self.cardRole:getBigImagePath())
    self.txt_name:setText(self.cardRole.name)
    -- self.txt_name:setColor(GetColorByQuality(self.cardRole.quality))
    self.txt_level:setText(self.cardRole.level .. "d")
    self.txt_power:setText(self.oldpower)
    self.img_quality_icon:setTexture(GetFontByQuality( self.cardRole.quality ))


    self.newarr = {}
    --角色属性
    for i=1,EnumAttributeType.Max do
        self.newarr[i] = self.cardRole:getTotalAttribute(i);
    end


    local changeArrTemp = {}
    local changeLength = 0;
    for i=1,EnumAttributeType.Max do
        local offset = self.newarr[i] - self.oldarr[i];
        if offset ~= 0 then
            changeLength = changeLength + 1;
            changeArrTemp[changeLength] = {i,offset};
        end
    end

    for i=1,11 do
        if i <= changeLength and i < 7 then
            self.txt_att[i]:setVisible(true)
            self.txt_att[i]:setIcon("ui_new/common/icon_power_word/attr_" .. i .. ".png")
            self.txt_att[i]:setText("  " .. covertToDisplayValue(i,self.oldarr[i]))
            -- self.txt_att[i]:setColor(ccc3(0,0,0))
            -- self.txt_att[i]:setText(AttributeTypeStr[changeArrTemp[i][1]] .. "+" .. changeArrTemp[i][2])
        else
            self.txt_att[i]:setVisible(false)
        end
    end
    self.changeLength = changeLength;
    self.changeArrTemp = changeArrTemp;

    -- self.cardRole.starlevel = 3;
    for i=1,5 do
        self.img_star[i]:setVisible(false)
    end

    self.img_role:setVisible(false)
    self.txt_name:setVisible(false)
    self.txt_level:setVisible(false)
    self.img_quality_icon:setVisible(false)
    self.panel_arr:setVisible(false)
    self.panel_starbg:setVisible(false)
    self.btn_ok:setVisible(false)
    self.panel_close:setVisible(false)
    
    self.ui:setAnimationCallBack("delay", TFANIMATION_END, function()
        for i=1,5 do
            if i <= self.cardRole.starlevel then
                self.img_star[i]:setVisible(true)
            else
                self.img_star[i]:setVisible(false)
            end
        end
        self.txt_name:setVisible(true)
        self.txt_level:setVisible(true)
        self.img_quality_icon:setVisible(true)
        self.panel_arr:setVisible(true)
        self.panel_starbg:setVisible(true)

        self.ui:setAnimationCallBack("action_star" .. self.cardRole.starlevel, TFANIMATION_END, function()
            self.img_role:setVisible(true)

            self.ui:setAnimationCallBack("show_info", TFANIMATION_END, function()
                local resPath = "effect/role_starup1.xml"
                TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                effect = TFArmature:create("role_starup1_anim")
              
                -- effect:setPosition(ccp(effPosX, effPosY))
                effect:setAnimationFps(GameConfig.ANIM_FPS)
                effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))
                self:addChild(effect,2)
                effect:playByIndex(0, -1, -1, 0)

                self.arrTimeId = {}
                self:arrChange(1,self.oldarr[changeArrTemp[1][1]],self.newarr[changeArrTemp[1][1]])
            end)
            self.ui:runAnimation("show_info",1);
        end)
        self.ui:runAnimation("action_star" .. self.cardRole.starlevel,1);

    end)

    self.effect:playByIndex(0, -1, -1, 0)
    self.ui:runAnimation("delay",1);
end


function RoleStarUpResultLayer:arrChange(arrIndex,oldValue,newValue)
    self.txt_att[arrIndex]:setText("  " ..oldValue);

    local changeSum = newValue - oldValue
    local changeCab = math.min(1,changeSum/60)
    local changeTimes = math.min(15,math.abs((changeCab*60)))

    local index = 1;
    function change()
        play_shuzibiandong()
        local tempValue = oldValue + index *((changeSum)/changeTimes)
        self.txt_att[arrIndex]:setText("  " .. math.floor(tempValue));
        index = index + 1;
    end

    function changeCom()
        self.txt_att[arrIndex]:setText("  " .. newValue);
        self:addToast(arrIndex,changeSum)

        if arrIndex < self.changeLength and arrIndex < 6 then
            self:arrChange(arrIndex + 1,self.oldarr[self.changeArrTemp[arrIndex + 1][1]],self.newarr[self.changeArrTemp[arrIndex + 1][1]])
        else
            -- local resPath = "effect/role_starup2.xml"
            -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
            -- effect = TFArmature:create("role_starup2_anim")
          
            -- -- effect:setPosition(ccp(effPosX, effPosY))
            -- effect:setAnimationFps(GameConfig.ANIM_FPS)
            -- effect:setPosition(ccp(self:getSize().width/2 + 220,self:getSize().height/2 - 150))
            -- self:addChild(effect,2)
            -- effect:playByIndex(0, -1, -1, 0)

            self:powerChange(self.oldpower,self.cardRole:getpower())
        end
    end
    if self.arrTimeId[arrIndex] ~= nil then
        TFDirector:removeTimer(self.arrTimeId[arrIndex]);
    end
    self.arrTimeId[arrIndex]= TFDirector:addTimer(1/60, changeTimes, changeCom, change);
end

function RoleStarUpResultLayer:addToast(arrIndex,value)

    local label = TFLabelBMFont:create();

    label:setPosition(ccp(self.txt_att[arrIndex]:getPosition().x + 70,self.txt_att[arrIndex]:getPosition().y -4));
    label:setFntFile("font/new/num_22.fnt");
    -- label:setFontName("黑体");
    label:setAnchorPoint(ccp(0,0.5))
    self.panel_arr:addChild(label,10);

    label:setColor(ccc3(  0, 255,   0));
    label:setText("D" .. value);
   
    local toY = label:getPosition().y ;
    local toX = label:getPosition().x + 80;
    

    local toastTween = {
          target = label,
          {
            duration = 0.5,
            x = toX,
            y = toY
          },
          { 
            duration = 0,
            delay = 2, 
          },
          {
             duration = 0.5,
             alpha = 1,
          },
          {
            duration = 0,
            onComplete = function() 
                -- label:removeFromParent();
           end
          }
        }

    TFDirector:toTween(toastTween);
end

function RoleStarUpResultLayer:powerChange(oldValue,newValue)
    self.txt_power:setText(oldValue);

    local changeSum = newValue - oldValue
    local changeCab = math.min(1,changeSum/60)
    local changeTimes = math.min(30,math.abs((changeCab*60)))

    local index = 1;
    function change()
        play_shuzibiandong()
        local tempValue = oldValue + index *((changeSum)/changeTimes)
        self.txt_power:setText(math.floor(tempValue));
        index = index + 1;
    end

    function changeCom()
        self.btn_ok:setVisible(true)
        self.panel_close:setVisible(true)
        self.txt_power:setText(newValue);

        local resPath = "effect/role_starup3.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        effect = TFArmature:create("role_starup3_anim")
      
        -- effect:setPosition(ccp(effPosX, effPosY))
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(self:getSize().width/2 + 250,150))
        self:addChild(effect,2)
        effect:playByIndex(0, -1, -1, 0)
    end
    if self.powerTimeId ~= nil then
        TFDirector:removeTimer(self.powerTimeId);
    end
    self.powerTimeId = TFDirector:addTimer(1/60, changeTimes, changeCom, change);
end

function RoleStarUpResultLayer:removeUI()
    self.super.removeUI(self)
end

function RoleStarUpResultLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_ok)
    ADD_ALERT_CLOSE_LISTENER(self, self.panel_close)
end


function RoleStarUpResultLayer:removeEvents()
    self.super.removeEvents(self)
end


return RoleStarUpResultLayer
