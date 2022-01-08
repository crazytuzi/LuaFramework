--[[
******[主角技能升级]*******

	-- by haidong.gan
	-- 2013/12/5
]]

local MainSkillListLayer = class("MainSkillListLayer", BaseLayer)


--CREATE_SCENE_FUN(MainSkillListLayer)
CREATE_PANEL_FUN(MainSkillListLayer)

function MainSkillListLayer:ctor()
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.role.MainSkillListLayer")
    self.__cname = "RoleSkillListLayer"
end

function MainSkillListLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.btn_close          = TFDirector:getChildByPath(ui, 'btn_close')

    self.btn_tap1          = TFDirector:getChildByPath(ui, 'btn_tap1')
    self.btn_tap2          = TFDirector:getChildByPath(ui, 'btn_tap2')
    self.btn_tap3          = TFDirector:getChildByPath(ui, 'btn_tap3')

    self.groupButtonManager  = GroupButtonManager:new( {[1] = self.btn_tap1, [2] = self.btn_tap2, [3] = self.btn_tap3});
    
    self.groupButtonManager:selectBtn(self.btn_tap1);

    self.txt_skill_time = TFDirector:getChildByPath(ui, "txt_skill_time")
    self.txt_skill_point = TFDirector:getChildByPath(ui, "txt_skill_point")


    self.node_skillArr = {}
    self.txt_skillnameArr = {}

    self.bgArr = {}
    self.btn_skillArr = {}
    self.img_skillArr = {}
    self.txt_levelArr = {}
    self.img_yishangzhenArr = {}
    self.btn_uplevelArr = {}
    self.img_need_bgArr = {}
    self.txt_toplevelArr = {}
    self.txt_needArr = {}
    self.txt_openlevelArr = {}
    self.img_openqualityArr = {}
    self.txt_openqualityArr = {}
    
    self.btn_equipArr = {}
    
    for i=1,3 do
        self.node_skillArr[i] = TFDirector:getChildByPath(ui, "panel_item_"..i)
        self.txt_skillnameArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "txt_skillname")
        self.bgArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "bg")
        self.btn_skillArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "btn_skill")
        self.img_skillArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "img_skill")
        self.txt_levelArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "txt_level")
        self.img_yishangzhenArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "img_yishangzhen")
        self.btn_uplevelArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "btn_uplevel")
        self.img_need_bgArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "img_need_bg")
        self.txt_toplevelArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "txt_toplevel")
        self.txt_needArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "txt_tongqianzhi")    
        self.txt_openlevelArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "txt_openlevel")           
        self.img_openqualityArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "img_openquality")   
        -- self.txt_openqualityArr[i] = TFDirector:getChildByPath(self.img_openqualityArr[i], "txt_wenben") 
        self.txt_openqualityArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "txt_wenben") 

        self.btn_equipArr[i] = TFDirector:getChildByPath(self.node_skillArr[i], "btn_shangzhen")        
    end

end

function MainSkillListLayer.onTypeSelectClickHandle(sender)
    local self = sender.logic;
    if (self.groupButtonManager:getSelectButton() == sender) then
       return;
    end
    self.groupButtonManager:selectBtn(sender);
    self:refreshUI();
end

function MainSkillListLayer:loadData(roleGmId)
    self.roleGmId   = roleGmId;
end

function MainSkillListLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function MainSkillListLayer:refreshBaseUI()
    self:refreshTiemsUI();
    
    self.onUpdated = function(event)
        self:refreshTiemsUI();
    end;

    if not self.nTimerId then
        self.nTimerId = TFDirector:addTimer(10, -1, nil, self.onUpdated); 
    end
end



function MainSkillListLayer:refreshTiemsUI()
    local pointInfo =  MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.SKILL_POINT);
    local leftChallengeTimes = pointInfo:getLeftChallengeTimes();
    self.txt_skill_point:setText(leftChallengeTimes);

    if pointInfo.cdLeaveTimeOjb then
        local leftCoolTime = pointInfo.cdLeaveTimeOjb:getOneRecoverTime()
        if leftCoolTime >= 0 and leftChallengeTimes  < pointInfo.maxValue then
            self.txt_skill_time:setVisible(true);
            self.txt_skill_time:setText(pointInfo.cdLeaveTimeOjb:getOneRecoverTimeString())
        else
            if leftChallengeTimes  >= pointInfo.maxValue then
                self.txt_skill_time:setVisible(false)
            end
        end
    else
        self.txt_skill_time:setVisible(false)
    end

end

function MainSkillListLayer.onUpLevelClickHandle(sender)
    local self = sender.logic;
    self.selectIndex = sender.index;
    local levelInfo =SkillLevelData:getInfoBySkillAndLevel( sender.spellInfo.id , sender.level)

            
    -- print("levelInfo:",levelInfo)
    if MainPlayer:isEnoughTimes(EnumRecoverableResType.SKILL_POINT,1, true) then
        local skillMaxLevel = ConstantData:objectByID("RoleSkill.Max.Level").value or 150
        if  sender.level >=  self.cardRole.level or sender.level >= skillMaxLevel  then
            --toastMessage("已到达上限");
            toastMessage(localizable.mainSkillList_max)
            return;
        end
        if MainPlayer:isEnoughCoin( levelInfo.uplevel_cost , true) then
            CardRoleManager:upLevelSkill(self.cardRole.gmId,levelInfo.id,sender.level)
        end
    end
end

function MainSkillListLayer.onSkillSelectClickHandle(sender)
    local self = sender.logic;

    local spellInfo = sender.spellInfo;
    local levelInfo = spellInfo:GetLevelItem(sender.level)
       
    CardRoleManager:selectSpell(levelInfo.id,sender.level)
end

function MainSkillListLayer.onSkillItemClickHandle(sender)
    local self = sender.logic;
    if sender.level ~= -1 then
        if self.cardRole:getIsMainPlayer() then
           local spellInfo = sender.spellInfo;
            --<<<<<<<<<<<<<<<<<<<技能替换判断
            local replaceSkillId = CardRoleManager:isSkillReplace(self.cardRole.id, self.cardRole.starlevel, spellInfo.id)
            if replaceSkillId ~= spellInfo.id then
                spellInfo = SkillBaseData:objectByID(replaceSkillId)
            end       
            -->>>>>>>>>>>>>>>>>>>>           
           local spellLevelInfo = spellInfo:GetLevelItem(sender.level)
           CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
        else
           local spellInfo = sender.spellInfo;
            --<<<<<<<<<<<<<<<<<<<技能替换判断
            local replaceSkillId = CardRoleManager:isSkillReplace(self.cardRole.id, self.cardRole.starlevel, spellInfo.id)
            if replaceSkillId ~= spellInfo.id then
                spellInfo = SkillBaseData:objectByID(replaceSkillId)
            end       
            -->>>>>>>>>>>>>>>>>>>>             
           local spellLevelInfo = spellInfo:GetLevelItem(sender.level)
           CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
        end
    else
        if self.cardRole:getIsMainPlayer() then
           local spellInfo = sender.spellInfo;
            --<<<<<<<<<<<<<<<<<<<技能替换判断
            local replaceSkillId = CardRoleManager:isSkillReplace(self.cardRole.id, self.cardRole.starlevel, spellInfo.id)
            if replaceSkillId ~= spellInfo.id then
                spellInfo = SkillBaseData:objectByID(replaceSkillId)
            end       
            -->>>>>>>>>>>>>>>>>>>>             
           local spellLevelInfo = spellInfo:GetLevelItem(1)
           CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
        else
           local spellInfo = sender.spellInfo;
            --<<<<<<<<<<<<<<<<<<<技能替换判断
            local replaceSkillId = CardRoleManager:isSkillReplace(self.cardRole.id, self.cardRole.starlevel, spellInfo.id)
            if replaceSkillId ~= spellInfo.id then
                spellInfo = SkillBaseData:objectByID(replaceSkillId)
            end       
            -->>>>>>>>>>>>>>>>>>>>             
           local spellLevelInfo = spellInfo:GetLevelItem(1)
           CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
        end
        -- toastMessage(sender.des)
    end

end

function MainSkillListLayer:refreshUI()
    if not self.isShow then
        return;
    end

    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);

    local selectIndex = self.groupButtonManager:getSelectIndex();

    local starIndex = (selectIndex - 1) * 3 +1;

    local index = 1;
    for i = starIndex,starIndex + 2 do

        self.btn_skillArr[index].level = -1;
        self.bgArr[index].level = -1;

        local spellInfoConfig = self.cardRole.leadingSpellInfoConfigList:objectAt(i);
        self.node_skillArr[index]:setVisible(false);
        if spellInfoConfig then
            self.btn_skillArr[index].spellInfo = spellInfo

            local spellInfo = SkillBaseData:objectByID(spellInfoConfig.spell_id);
            local isOpenQuality = spellInfoConfig:GetQualityIsOpen(self.cardRole.quality);
            local isOpenLevel = spellInfoConfig:GetLevelIsOpen(self.cardRole.level);
            local level = 1;
            local isChoice = false;

            -- add by king
            self.txt_openqualityArr[index]:setVisible(false)

            if spellInfo then
                self.btn_skillArr[index].spellInfo = spellInfo
                self.btn_equipArr[index].spellInfo = spellInfo
                self.bgArr[index].spellInfo = spellInfo
                self.btn_uplevelArr[index].spellInfo = spellInfo;


                self.node_skillArr[index]:setVisible(true);
                --<<<<<<<<<<<<<<<<<<<技能替换判断
                local replaceSkillId = CardRoleManager:isSkillReplace(self.cardRole.id, self.cardRole.starlevel, spellInfo.id)
                if replaceSkillId ~= spellInfo.id then
                    local replaceSpellInfo = SkillBaseData:objectByID(replaceSkillId)
                    self.img_skillArr[index]:setTexture(replaceSpellInfo:GetPath());  
                    self.txt_skillnameArr[index]:setText(replaceSpellInfo.name);            
                else
                    self.img_skillArr[index]:setTexture(spellInfo:GetPath());  
                    self.txt_skillnameArr[index]:setText(spellInfo.name);            
                end       
                -->>>>>>>>>>>>>>>>>>>>

                self.txt_openlevelArr[index]:setVisible(true);
                self.img_yishangzhenArr[index]:setVisible(false);
                self.btn_equipArr[index]:setVisible(false);

                -- if not spellInfoConfig:GetQualityIsOpen(self.cardRole.quality) then
                if not spellInfoConfig:GetQualityIsOpen(self.cardRole.martialLevel)then
                    self.img_skillArr[index]:setColor(ccc3(166, 166, 166));
                    -- self.btn_skillArr[index].des = QUALITY_STR[spellInfoConfig.enable_quality] .. "品解锁"
                    --self.btn_skillArr[index].des = "武学"..EnumWuxueLevelType[spellInfoConfig.enable_quality] .. "重解锁"
                    self.btn_skillArr[index].des = stringUtils.format(localizable.mainSkillList_wuxue,EnumWuxueLevelType[spellInfoConfig.enable_quality])
                    self.bgArr[index].des = self.btn_skillArr[index].des

                    
                    self.img_openqualityArr[index]:setVisible(true);
                    self.img_need_bgArr[index]:setVisible(false);
                    self.txt_toplevelArr[index]:setVisible(false);
                    self.txt_levelArr[index]:setVisible(false);
                    self.btn_uplevelArr[index]:setVisible(false);
                    self.txt_openlevelArr[index]:setVisible(false);

                    self.img_openqualityArr[index]:setTexture(GetFontByQuality(spellInfoConfig.enable_quality));

                    print(self.btn_skillArr[index].des)

                    -- add by king
                    self.txt_openqualityArr[index]:setText(self.btn_skillArr[index].des)
                    self.txt_openqualityArr[index]:setVisible(true)
                    self.img_openqualityArr[index]:setVisible(false)

                elseif not spellInfoConfig:GetLevelIsOpen(self.cardRole.level) then
                    self.img_skillArr[index]:setColor(ccc3(166, 166, 166));
                    --self.btn_skillArr[index].des = "主角" .. spellInfoConfig.enable_level .. "级可用"
                    self.btn_skillArr[index].des = stringUtils.format(localizable.mainSkillList_player,spellInfoConfig.enable_level)
                    self.bgArr[index].des = self.btn_skillArr[index].des
             

                    self.img_openqualityArr[index]:setVisible(false);
                    self.img_need_bgArr[index]:setVisible(false);
                    self.txt_toplevelArr[index]:setVisible(false);
                    self.txt_levelArr[index]:setVisible(false);
                    self.btn_uplevelArr[index]:setVisible(false);
                    self.txt_openlevelArr[index]:setVisible(true);

                    self.txt_openlevelArr[index]:setText(stringUtils.format(localizable.mainSkillList_player,spellInfoConfig.enable_level));

                    print("主角" .. spellInfoConfig.enable_level .. "级解锁")
                else
            
                    self.img_openqualityArr[index]:setVisible(false);
                    self.img_need_bgArr[index]:setVisible(true);
                    self.txt_levelArr[index]:setVisible(true);
                    self.btn_uplevelArr[index]:setVisible(true);
                    self.txt_openlevelArr[index]:setVisible(false);

                    local levelInfo = nil;
                    for i,spell in pairs(self.cardRole.leadingRoleSpellList) do
                        if spellInfoConfig.spell_id == spell.spellId.skillId then
                            levelInfo = SkillLevelData:objectByID(spell.spellId);
                            print("levelInfo",levelInfo)
                            if spell.choice then
                                self.img_yishangzhenArr[index]:setVisible(true);
                                self.btn_equipArr[index]:setVisible(false);
                            else
                                self.img_yishangzhenArr[index]:setVisible(false);
                                self.btn_equipArr[index]:setVisible(true);
                            end
                        end
                    end

                    local level = 1;
                    if levelInfo then
                        level = levelInfo.level;
                    else
                        print("技能异常：");
                        print("spellInfoConfig:",spellInfoConfig);
                        print("self.cardRole.leadingRoleSpellList:",self.cardRole.leadingRoleSpellList);
                        return
                    end
                    self.img_skillArr[index]:setColor(ccc3(255, 255, 255));


                    self.btn_skillArr[index].level = level

                    self.btn_equipArr[index].level = level

                    self.bgArr[index].level = level

                    self.btn_uplevelArr[index].level = level;

                    self.txt_levelArr[index]:setText("LV" .. level);
                    self.txt_needArr[index]:setText(levelInfo.uplevel_cost);

                    if MainPlayer:isEnoughCoin( levelInfo.uplevel_cost , false)  then
                        self.txt_needArr[index]:setColor(ccc3(255, 255, 255));
                    else
                        self.txt_needArr[index]:setColor(ccc3(255,   0,   0));
                    end

                    local skillMaxLevel = ConstantData:objectByID("RoleSkill.Max.Level").value or 150

                    if MainPlayer:isEnoughCoin( levelInfo.uplevel_cost , false) and levelInfo.level <  self.cardRole.level and levelInfo.level < skillMaxLevel then
                        -- self.btn_uplevelArr[index]:setColor(ccc3(255, 255, 255));
                        self.btn_uplevelArr[index]:setBright(true);
                    else
                        -- self.btn_uplevelArr[index]:setColor(ccc3(255,   0,   0));
                        self.btn_uplevelArr[index]:setBright(false);
                    end

                    print("LV：" .. level)

                    if spellInfo:GetLevelItem(level + 1) ~= -1 then
                        self.btn_uplevelArr[index]:setVisible(true);
                        self.img_need_bgArr[index]:setVisible(true);
                        self.txt_toplevelArr[index]:setVisible(false);
                    else
                        self.btn_uplevelArr[index]:setVisible(false);
                        self.img_need_bgArr[index]:setVisible(false);
                        self.txt_toplevelArr[index]:setVisible(true);
                        --self.txt_toplevelArr[index]:setText("满级");
                        self.txt_toplevelArr[index]:setText(localizable.common_max_level);
                    end 
                end

            end
        end
        index = index + 1;
    end
end



function MainSkillListLayer:removeUI()
	self.super.removeUI(self)

    if self.nTimerId then
        TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
    end
end

function MainSkillListLayer:registerEvents(ui)
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close)
    for i=1,3 do
        self.btn_skillArr[i].logic     = self;
        self.btn_skillArr[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSkillItemClickHandle),1);
        self.bgArr[i].logic     = self;
        self.bgArr[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSkillItemClickHandle))

        self.btn_uplevelArr[i].logic     = self;
        self.btn_uplevelArr[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onUpLevelClickHandle),1)

        self.btn_equipArr[i].logic     = self;
        self.btn_equipArr[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSkillSelectClickHandle),1)
        self.btn_uplevelArr[i].index = i;
    end

    self.btn_tap1.logic     = self;
    self.btn_tap1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTypeSelectClickHandle))
    self.btn_tap2.logic     = self;
    self.btn_tap2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTypeSelectClickHandle))
    self.btn_tap3.logic     = self;
    self.btn_tap3:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTypeSelectClickHandle))

    self.RoleUpdateCallBack = function (event)
        self:refreshUI();
    end

    self.LevelUpCallBack = function (event)
        play_jinengxiulian()
        self:refreshUI();
        local selectIndex = self.selectIndex;
        local effect = self.img_skillArr[selectIndex].effect;
        if not effect or not effect:getParent() then
            local resPath = "effect/role_skill_levelup.xml"
            TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
            effect = TFArmature:create("role_skill_levelup_anim")

            effect:setAnimationFps(GameConfig.ANIM_FPS)
            -- local pos = self.node_skillArr[selectIndex]:getPosition();
            -- effect:setPosition(ccp(pos.x,pos.y))
            local img_skill = self.img_skillArr[selectIndex];
            effect:setPosition(ccp(img_skill:getSize().width/2,img_skill:getSize().height/2))
            self.img_skillArr[selectIndex]:addChild(effect,2)
            self.img_skillArr[selectIndex].effect = effect;

            effect:addMEListener(TFARMATURE_COMPLETE,function()
                effect:removeMEListener(TFARMATURE_COMPLETE) 
                effect:removeFromParent()
                self.img_skillArr[selectIndex].effect = nil;
            end)
        end
        effect:playByIndex(0, -1, -1, 0)
        -- self.txt_levelArr[index]:setText("LV" .. level);
        self.levelupTimeId = TFDirector:addTimer(200, 1, nil, function()


            local toastTween = {
                  target = self.txt_levelArr[selectIndex],
                  {
                    duration = 0,
                    alpha = 1,
                  },
                  {
                    duration = 4/24,
                    scale = 1.7,
                  },
                  { 
                    duration = 4/24,
                    scale = 2,
                    alpha = 0,
                  },

                  {
                     duration = 0,
                     alpha = 1,
                     scale = 1,
                  },
                  {
                    duration = 0,
                    onComplete = function() 
                        self.levelupTimeId = nil
                    end
                  }
                }

            TFDirector:toTween(toastTween);

        end);


        function showToastMessage()
            local oldId = clone(event.data[1].oldId);
            local newId = clone(event.data[1].newId);

            oldId.skillId = CardRoleManager:isSkillReplace(self.cardRole.id, self.cardRole.starlevel, oldId.skillId)
            newId.skillId = CardRoleManager:isSkillReplace(self.cardRole.id, self.cardRole.starlevel, newId.skillId)
            
            local oldLevel = SkillLevelData:objectByID(oldId);
            local newLevel = SkillLevelData:objectByID(newId);
            local sepllInfo = SkillBaseData:objectByID(newId.skillId);

            local tempAddArr = {}
            tempAddArr[1] = newLevel.target_num - oldLevel.target_num
            tempAddArr[2] = 0--newLevel.attr_add - oldLevel.attr_add
            tempAddArr[3] = newLevel.effect_value - oldLevel.effect_value
            tempAddArr[4] = newLevel.effect_rate - oldLevel.effect_rate
            tempAddArr[5] = newLevel.buff_hurt - oldLevel.buff_hurt
            tempAddArr[6] = newLevel.extra_hurt - oldLevel.extra_hurt
            tempAddArr[7] = newLevel.outside - oldLevel.outside
            tempAddArr[8] = newLevel.inside - oldLevel.inside
            tempAddArr[9] = newLevel.ice - oldLevel.ice
            tempAddArr[10] = newLevel.fire - oldLevel.fire
            tempAddArr[11] = newLevel.poison - oldLevel.poison
            tempAddArr[12] = 0--newLevel.buff_id - oldLevel.buff_id
            tempAddArr[13] = newLevel.buff_targetnum - oldLevel.buff_targetnum
            tempAddArr[14] = newLevel.buff_rate - oldLevel.buff_rate
            tempAddArr[15] = newLevel.triggerSkill_rate - oldLevel.triggerSkill_rate

            if tempAddArr[4] ~= 0 then
                tempAddArr[4] = tempAddArr[4] / 100 ..'%%'
            end
            if tempAddArr[7] ~= 0 then
                tempAddArr[7] = tempAddArr[7] ..'%%'
            end
            if tempAddArr[8] ~= 0 then
                tempAddArr[8] = tempAddArr[8] ..'%%'
            end
            if tempAddArr[14] ~= 0 then
                tempAddArr[14] = tempAddArr[14] / 100 ..'%%'
            end
            if tempAddArr[15] ~= 0 then
                tempAddArr[15] = tempAddArr[15] / 100 ..'%%'
            end

            local addIndex = 16

            -- local oldattr_add = string.split(oldLevel.attr_add, '|');
            -- local newattr_add = string.split(newLevel.attr_add, '|');
            local oldattr_add = oldLevel.attr_add
            local newattr_add = newLevel.attr_add

            -- print("oldattr_add:",oldattr_add)
            -- print("newattr_add:",newattr_add)

            for key,vaule in pairs(newattr_add) do
                if vaule ~= 0 then
                    if oldattr_add[key] and oldattr_add[key] ~= 0  then
                        local tmp_num = vaule - oldattr_add[key]
                        if tmp_num ~= 0 then
                            if isPercentAttr(key) then
                                tempAddArr[addIndex] =  tmp_num ..'%%'
                            else
                                tempAddArr[addIndex] =  tmp_num
                            end
                            addIndex = addIndex + 1
                        end
                    else
                        -- tempAddArr[addIndex] =  covertToDisplayValue(key,vaule)
                        if isPercentAttr(key) then
                            tempAddArr[addIndex] =  vaule ..'%%'
                        else
                            tempAddArr[addIndex] =  vaule
                        end
                        addIndex = addIndex + 1
                    end
                end
            end

            print("tempAddArr:",tempAddArr)
            local addArr = {}
            local index = 1;
            for k,addValue in ipairs(tempAddArr) do
                if addValue ~= 0 and addValue ~= "" then
                    addArr[index] = addValue;
                    index = index + 1;
                end
            end
            local toastMessageStr = "";
            local splitSyt = "";
            for i,v in ipairs(sepllInfo:getChangeStr()) do
                if i > 1 then
                    splitSyt = ", " ;
                end
                if addArr[i] and v ~= "" then
                    local t = type(addArr[i]);
                    local tmp_str = ""
                    if t == "number" then -- 是数字
                        if addArr[i] >= 0 then
                            if math.floor(addArr[i])<addArr[i] then
                                tmp_str = "+"..string.format("%0.2f",addArr[i])
                            else
                                tmp_str = "+"..addArr[i]
                            end

                            -- toastMessageStr = toastMessageStr .. splitSyt .. v .. "+" .. addArr[i];
                        else
                            tmp_str = addArr[i]
                            -- toastMessageStr = toastMessageStr .. splitSyt .. v .. addArr[i];
                        end
                    elseif t == "string" then -- 是字符串

                        if string.charAt(addArr[i], 1) ~= "-" then
                            -- toastMessageStr = toastMessageStr .. splitSyt .. v .. "+" .. addArr[i];
                            tmp_str = "+"..addArr[i]
                        else
                            tmp_str = addArr[i]
                            -- toastMessageStr = toastMessageStr .. splitSyt .. v .. addArr[i];
                        end
                    end
                    toastMessageStr = toastMessageStr .. splitSyt .. v:gsub("#add_attr#", tmp_str);
                elseif v ~= "" then
                    toastMessageStr = toastMessageStr .. splitSyt .. v ;
                end
            end

            if toastMessageStr then
                toastMessage(toastMessageStr);
            end
            -- print(oldLevel,newLevel,sepllInfo,addArr,sepllInfo:getChangeStr())
        end
        showToastMessage();
    end
    TFDirector:addMEGlobalListener(CardRoleManager.SPELL_LEVEL_UP_NOTIFY,self.LevelUpCallBack)


    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_SPELL_ENABLE_NOTIFY,self.RoleUpdateCallBack)
    TFDirector:addMEGlobalListener(CardRoleManager.SELECT_SPELL_RESULT,self.RoleUpdateCallBack)

    self.updateChallengeTimesCallBack = function(event)
        self:refreshBaseUI();
    end;
    TFDirector:addMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateChallengeTimesCallBack ) ;
    self.updateUserDataCallBack = function(event)
        self:refreshUI()
    end

    TFDirector:addMEGlobalListener(MainPlayer.ResourceUpdateNotifyBatch ,self.updateUserDataCallBack)
end

function MainSkillListLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener(CardRoleManager.SPELL_LEVEL_UP_NOTIFY,self.LevelUpCallBack)
    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_SPELL_ENABLE_NOTIFY,self.RoleUpdateCallBack)
    TFDirector:removeMEGlobalListener(CardRoleManager.SELECT_SPELL_RESULT,self.RoleUpdateCallBack)

    TFDirector:removeMEGlobalListener(MainPlayer.ChallengeTimesChange,self.updateChallengeTimesCallBack)
    TFDirector:removeMEGlobalListener(MainPlayer.ResourceUpdateNotifyBatch,self.updateUserDataCallBack)

    if self.levelupTimeId then
        TFDirector:removeTimer(self.levelupTimeId)
        self.levelupTimeId = nil
    end

    if self.nTimerId then
        TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
    end
end

return MainSkillListLayer

