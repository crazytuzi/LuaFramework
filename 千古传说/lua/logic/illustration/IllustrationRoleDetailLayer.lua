
local IllustrationRoleDetailLayer = class("IllustrationRoleDetailLayer", BaseLayer)
local CardRole = require('lua.gamedata.base.CardRole')
function IllustrationRoleDetailLayer:ctor(roleid)
    self.super.ctor(self)
    print("roleid = ", roleid)
    self.roleid = roleid
    self:init("lua.uiconfig_mango_new.handbook.HandbookRoleDetail")

    self:removeUnuseTexEnabled(true);

end

function IllustrationRoleDetailLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn           = TFDirector:getChildByPath(ui, 'btn_close')

    self.panel_list     = TFDirector:getChildByPath(ui, 'panel_list')


    self.btn_equip      = TFDirector:getChildByPath(ui, 'btn_equipment');
    self.btn_train      = TFDirector:getChildByPath(ui, 'btn_jm');
    -- self.btn_book       = TFDirector:getChildByPath(ui, 'btn_book');
    self.btn_transfer   = TFDirector:getChildByPath(ui, 'btn_transfer');
    self.btn_upStar     = TFDirector:getChildByPath(ui, 'btn_xiulian');
    

    self.btn_skill      = TFDirector:getChildByPath(ui, 'btn_skill');
    self.btn_fate       = TFDirector:getChildByPath(ui, 'btn_yuanfenxiang');
    self.btn_moreattr   = TFDirector:getChildByPath(ui, 'btn_jingmaixiang');
    -- self:setBtnOpen();


    self.panel_level    = TFDirector:getChildByPath(ui, 'panel_level');

    self.panel_role     = TFDirector:getChildByPath(ui, 'panel_role');
    self.img_quality    = TFDirector:getChildByPath(ui, 'img_pinzhi');
    self.img_role       = TFDirector:getChildByPath(ui, 'img_role');

    self.img_type       = TFDirector:getChildByPath(ui, 'img_zhiye');
    self.txt_name       = TFDirector:getChildByPath(ui, 'txt_name');
    self.txt_power      = TFDirector:getChildByPath(ui, 'txt_power');
    -- self.bg_pos         = TFDirector:getChildByPath(ui, 'bg_pos');
    -- self.img_point      = TFDirector:getChildByPath(ui, 'img_point');
    self.btn_jinengzhanshi = TFDirector:getChildByPath(ui, 'btn_jinengzhanshi');

    self.txt_wenbenList = {}
    for i=1,2 do
        self.txt_wenbenList[i] = TFDirector:getChildByPath(ui, "txt_wenben"..i)
    end

    self.attrLabelList = {}
    for i=1,(EnumAttributeType.Max-1) do
        self.attrLabelList[i] = TFDirector:getChildByPath(ui, "attrLabel"..i)
    end



    self.img_starList = {}
    for i=1,5 do
        self.img_starList[i] = TFDirector:getChildByPath(ui, "img_star_light_"..i)
    end

    local panel_fate = TFDirector:getChildByPath(ui, "panel_huiseyuanfen")
    self.node_fateList = {}
    self.txt_fateList = {}
    for i=1,6 do
        self.node_fateList[i] = TFDirector:getChildByPath(panel_fate, "img_huisedian"..i)
        self.txt_fateList[i] = TFDirector:getChildByPath(self.node_fateList[i], "txt_yuanfen")
    end

    local panel_fateL = TFDirector:getChildByPath(ui, "panel_dianliangyuanfen")
    self.node_fateLList = {}
    self.txt_fateLList = {}
    for i=1,6 do
        self.node_fateLList[i] = TFDirector:getChildByPath(panel_fateL, "img_huisedian"..i)
        self.txt_fateLList[i] = TFDirector:getChildByPath(self.node_fateLList[i], "txt_yuanfen")
    end

    local panel_arr = TFDirector:getChildByPath(ui, "panel_jingmaixiangqing")
    self.txt_arr_base = {}
    self.txt_arr_base[EnumAttributeType.Blood]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_qixue"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Force]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_wuli"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Defence] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_fangyu"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Magic]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_neili"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Agility] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_shenfa"),"txt_base")


    self.txt_arr_add = {}
    self.txt_arr_add[EnumAttributeType.Blood]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_qixue"),"txt_add")
    self.txt_arr_add[EnumAttributeType.Force]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_wuli"),"txt_add")
    self.txt_arr_add[EnumAttributeType.Defence] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_fangyu"),"txt_add")
    self.txt_arr_add[EnumAttributeType.Magic]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_neili"),"txt_add")
    self.txt_arr_add[EnumAttributeType.Agility] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_shenfa"),"txt_add")

    self.panel_fight_skill = TFDirector:getChildByPath(ui, "panel_zhanchangjineng")

    self.node_skillList = {}
    self.img_skillList = {}
    self.txt_skillLevelList = {}
    self.img_openQualityList = {}

    for i=1,3 do
        self.node_skillList[i]   =  TFDirector:getChildByPath(self.panel_fight_skill,"btn_jinengkuang" .. i)
        self.img_skillList[i]   =  TFDirector:getChildByPath(self.node_skillList[i],"img_skill")
        self.txt_skillLevelList[i]   =  TFDirector:getChildByPath(self.node_skillList[i],"txt_lv")
        self.img_openQualityList[i]   =  TFDirector:getChildByPath(self.node_skillList[i],"img_jiesuo")
    end

    -- self.txt_des        = TFDirector:getChildByPath(ui, 'txt_renwumiaosu');
    -- self.panel_des      = TFDirector:getChildByPath(ui, 'panel_renwushiji');

    -- self.img_skill      = TFDirector:getChildByPath(ui, 'img_skill_icon');


    self.btn_huodetujin     = TFDirector:getChildByPath(ui, 'btn_huodetujin')
    self.btn_huodetujin.logic = self
    -- self.btn_mission        = TFDirector:getChildByPath(ui, 'btn_mission')
    -- self.img_open           = TFDirector:getChildByPath(ui, 'img_open')
    -- self.txt_way            = TFDirector:getChildByPath(ui, 'txt_way')
    -- self.ui                 = ui

    self:refreshRoleInfo()

    local role  = RoleData:objectByID(self.roleid)
    self.output = role.show_way


    self.btn_huodetujin:setVisible(false)
    if self.output and string.len(self.output) > 0 then
        self.btn_huodetujin:setVisible(true)
    end
end

function IllustrationRoleDetailLayer:registerEvents(ui)
    self.super.registerEvents(self)    
    self.btn_fate.logic          = self;
    self.btn_fate:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onFateClickHandle),1);
    
    self.btn_jinengzhanshi.logic = self
    self.btn_jinengzhanshi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSkillClickHandle),1);

    for i=1,3 do
        self.node_skillList[i].logic     = self;
        self.node_skillList[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSkillItemClickHandle),1);
    end

    self.btn_huodetujin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onclikOutPut),1);
    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn)
end

function IllustrationRoleDetailLayer:removeEvents()
    self.super.removeEvents(self)

end

function IllustrationRoleDetailLayer.onclikOutPut(sender)
    local self     = sender.logic
    -- local role     = RoleData:objectByID(self.cardRoleId)

    -- local layer  = require("lua.logic.illustration.IllustrationOutPutLayer"):new({roleId = self.cardRoleId})
    -- AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
    
    -- -- AlertManager:addLayer(layer, AlertManager.BLOCK_CLOSE)
    -- local winSize =  GameConfig.WS
    -- -- layer:setPosition(ccp(winSize.width/2, winSize.height/2))
    -- -- layer:setZOrder(1)
    -- AlertManager:show()
    -- 


    -- IllustrationManager:showOutputList({roleId = self.cardRoleId})
    IllustrationManager:showOutputList({output = self.output, id = 1})
end

function IllustrationRoleDetailLayer.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

function IllustrationRoleDetailLayer.onFateClickHandle(sender)
    local self = sender.logic;
    local layer = AlertManager:addLayerByFile("lua.logic.role.FateDetail",AlertManager.BLOCK_AND_GRAY);
    layer:setRoleId(self.cardRoleId);
    -- layer:setZOrder(2)
    AlertManager:show();
end

function IllustrationRoleDetailLayer.onSkillItemClickHandle(sender)
    local self = sender.logic;
    -- if sender.level ~= -1 then
    --     if self.cardRole:getIsMainPlayer() then
    --        local spellInfoConfig = sender.spellInfoConfig;
    --        local spellInfo = spellInfoConfig:GetSpellInfo();
    --        local spellLevelInfo = spellInfo:GetLevelItem(sender.level)
    --        CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
    --     else
    --        local spellInfo = sender.spellInfo;
    --        local spellLevelInfo = spellInfo:GetLevelItem(sender.level)
    --        CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
    --     end
    -- else
    --     toastMessage(sender.des)
    -- end

               local spellInfo = sender.spellInfo;
           local spellLevelInfo = spellInfo:GetLevelItem(sender.level)
           CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
end

function IllustrationRoleDetailLayer.onSkillClickHandle(sender)
    FightManager:BeginSkillShowFight(sender.logic.cardRoleId)
end

function IllustrationRoleDetailLayer:refreshRoleInfo()
    self.cardRole   = CardRole:new(self.roleid)
    self.cardRoleId = self.cardRole.id
    print("IllustrationRoleDetailLayer:refreshRoleInfo")


    self:refreshSkillInfo();
    self:drawRole()
    -- self:drawOutput()
    -- self:setDefualtVisible();

    self.cardRole:setLevel(1)
    --角色信息
    -- self.img_role:setVisible(true)
    -- self.img_role:setTexture(self.cardRole:getBigImagePath());
    self.img_type:setTexture("ui_new/common/img_role_type" .. self.cardRole.outline .. ".png");
    self.txt_name:setText(self.cardRole.name);
    self.img_quality:setTexture(GetFontByQuality(self.cardRole.quality));
    self.txt_power:setText(self.cardRole.power);
  

    
    --星级
    for i=1, 5 do
        if (i <= self.cardRole.starlevel) then
            self.img_starList[i]:setVisible(true);
        else
            self.img_starList[i]:setVisible(false);    
        end
    end


    --基础属性
    self.cardRole:setLevel(1)
    -- local baseAttr = self.cardRole.baseAttribute.attribute
    local baseAttr = self.cardRole.totalAttribute.attribute
    print("baseAttr num = ", #baseAttr)
    local count = 1
    for i=1,5 do
        if baseAttr[i] then
            -- self.txt_arr_base[count]:setText(AttributeTypeStr[i])
            self.txt_arr_base[count]:setText(covertToDisplayValue(i,baseAttr[i]))
            self.txt_arr_base[count]:setVisible(true)
            -- self.txt_arr_add[count]:setVisible(true)
            -- print(AttributeTypeStr[i].."---"..covertToDisplayValue(i,baseAttr[i]))
            count = count + 1
        end
    end

    -- --角色属性
    -- for index,txt_arr in pairs(self.txt_arr_base) do
    --     local arrStr = 0;
    --     arrStr = self.cardRole.totalAttribute[index]

    --     txt_arr:setText(arrStr);
    -- end

    -- for index,txt_arr in pairs(self.txt_arr_add) do
    --     txt_arr:setVisible(false);
    -- end

    -- for i=1,6 do
    --     local acupointInfo = self.cardRole:GetAcupointInfo(i)

    --     print ("self.cardRole.acupointInfo = ", self.cardRole:GetAcupointInfo(i))
    --     if acupointInfo ~= nil then
    --         local table_arr = GetAttrByString(acupointInfo.buffStr);
    --         for attribute,num in pairs(table_arr) do
    --             if (self.txt_arr_add[attribute] ~= nil) then
    --                 -- self.txt_arr_add[attribute]:setVisible(true);
    --                 self.txt_arr_add[attribute]:setText("(+"..num .. ")")
    --             end
    --             break;
    --         end
    --     end
    -- end

    --缘分
    for index,node in pairs(self.node_fateList) do
        node:setVisible(false);
    end
    for index,node in pairs(self.node_fateLList) do
        node:setVisible(false);
    end
    local fateArray = RoleFateData:getRoleFateById(self.cardRole.id)
    local index = 1;

    local fateStatusArray = {};
    for fate in fateArray:iterator() do
        fateStatusArray[fate.id] = self.cardRole:getFateStatus(fate.id);
    end
    self.cardRole.fateStatusArray = fateStatusArray;

    for fate in fateArray:iterator() do

        local status = self.cardRole.fateStatusArray[fate.id];

        if status then
            self.node_fateLList[index]:setVisible(true);
        else
            self.node_fateList[index]:setVisible(true);
        end
        
        self.txt_fateList[index]:setText(fate.title);
        self.txt_fateLList[index]:setText(fate.title);

        index = index +1;
    end

end

function IllustrationRoleDetailLayer:refreshSkillInfo()
    if (not self.cardRole:getIsMainPlayer()) then

        local openQuality = {QUALITY_DING,QUALITY_YI,QUALITY_JIA}
        for index=1,3 do

            self.node_skillList[index].level = -1
            local spellInfo = self.cardRole.spellInfoList:objectAt(index);
            if spellInfo then
                self.node_skillList[index]:setVisible(true);
                self.img_skillList[index]:setTexture(spellInfo:GetPath());   

                if self.cardRole.quality < openQuality[index] then
                    self.img_skillList[index]:setColor(ccc3(166, 166, 166));
                    --self.node_skillList[index].des =QUALITY_STR[openQuality[index]] .. "品解锁"
                    self.node_skillList[index].des =stringUtils.format(localizable.IllRoleDetaLayer_unlock,QUALITY_STR[openQuality[index]])

                    self.txt_skillLevelList[index]:setVisible(false);
                    self.img_openQualityList[index]:setVisible(true);
                    self.img_openQualityList[index]:setTexture(GetFontSmallByQuality(openQuality[index]));

                    print(QUALITY_STR[openQuality[index]] .. "品解锁")

                    -- add by king, ,没解锁的可以查看
                    self.node_skillList[index].spellInfo = spellInfo
                    self.node_skillList[index].level     = 1
                else
                    local levelInfo = nil;
                    if self.cardRole.spellLevelIdList then
                        for i,levelId in pairs(self.cardRole.spellLevelIdList) do
                            local levelItem = SkillLevelData:objectByID(levelId);
                            if spellInfo.id == levelId.skillId then
                                levelInfo = levelItem;
                            end
                        end
                    end
                    local level = 1;
                    if levelInfo then
                        level = levelInfo.level;
                    end
                    self.img_skillList[index]:setColor(ccc3(255, 255, 255));
                    self.txt_skillLevelList[index]:setVisible(true);
                    self.img_openQualityList[index]:setVisible(false);
                    self.txt_skillLevelList[index]:setText("LV：" .. level);

                    self.node_skillList[index].spellInfo = spellInfo
                    self.node_skillList[index].level = level
                    print("LV：" .. level)
                end
            else
                self.node_skillList[index]:setVisible(false);
            end
        end
    end
--     self.leadingSpellInfoConfigList = roleConfig:getLeadingSpellInfoConfigList();
    -- self.leadingSpellInfoList       = roleConfig:getLeadingSpellInfoList();
-- cardRole.leadingRoleSpellList
    if self.cardRole:getIsMainPlayer() then
    
        local tempSpellInfoConfigList = TFArray:new();
        local tempLevelList  = TFArray:new();

        for index=1,3 do
            local spellInfoConfig = self.cardRole.leadingSpellInfoConfigList:objectAt((index - 1)*3 + 1);
            local level = 1;
            if self.cardRole.leadingRoleSpellList then
                for i=(index - 1)*3 + 1,(index - 1)*3 + 3 do
                    local tempSpellInfoConfig = self.cardRole.leadingSpellInfoConfigList:objectAt(i);
                    for i,spell in pairs(self.cardRole.leadingRoleSpellList) do
                        if tempSpellInfoConfig.spell_id == spell.sid and spell.choice then
                            spellInfoConfig = tempSpellInfoConfig;
                            level = spell.spellId.level;
                        end
                    end
                end
            end
            tempSpellInfoConfigList:push(spellInfoConfig);
            tempLevelList:push(level);
        end

        -- print(tempSpellInfoConfigList,tempLevelList)
        for index=1,3 do
            self.node_skillList[index].level = -1;
            local spellInfoConfig = tempSpellInfoConfigList:objectAt(index);
            local level = tempLevelList:objectAt(index);
              self.node_skillList[index]:setVisible(false);
      
            if spellInfoConfig then
                local spellInfo = SkillBaseData:objectByID(spellInfoConfig.spell_id);
                if spellInfo then
                    self.node_skillList[index]:setVisible(true);
                    self.img_skillList[index]:setTexture(spellInfo:GetPath());   

                    if not spellInfoConfig:GetQualityIsOpen(self.cardRole.quality)then
                        self.img_skillList[index]:setColor(ccc3(166, 166, 166));
                        --self.node_skillList[index].des = QUALITY_STR[spellInfoConfig.enable_quality] .. "品解锁"
                        self.node_skillList[index].des =stringUtils.format(localizable.IllRoleDetaLayer_unlock, QUALITY_STR[spellInfoConfig.enable_quality])

                        self.txt_skillLevelList[index]:setVisible(false);
                        self.img_openQualityList[index]:setVisible(true);
                        self.img_openQualityList[index]:setTexture(GetFontByQuality(spellInfoConfig.enable_quality));

                        --print(QUALITY_STR[spellInfoConfig.enable_quality] .. "品解锁")
                    elseif not spellInfoConfig:GetLevelIsOpen(self.cardRole.level) then
                        self.img_skillList[index]:setColor(ccc3(166, 166, 166));
                        --self.node_skillList[index].des = spellInfoConfig.enable_level .. "级解锁"
                        self.node_skillList[index].des = stringUtils.format(localizable.common_level_unlock,spellInfoConfig.enable_level)

                        self.txt_skillLevelList[index]:setVisible(true);
                        self.img_openQualityList[index]:setVisible(false);
                        --self.txt_skillLevelList[index]:setText(spellInfoConfig.enable_level .. "级解锁");
                        self.txt_skillLevelList[index]:setText(stringUtils.format(localizable.common_level_unlock,spellInfoConfig.enable_level));

                        --print(spellInfoConfig.enable_level .. "级解锁")
                    else
                        self.img_skillList[index]:setColor(ccc3(255, 255, 255));
                        self.node_skillList[index].spellInfoConfig = spellInfoConfig
                        self.node_skillList[index].level = level

                        self.txt_skillLevelList[index]:setVisible(true);
                        self.img_openQualityList[index]:setVisible(false);
                        self.txt_skillLevelList[index]:setText("LV：" .. level);

                        print("LV：" .. level)
                    end
                end
            end
        end
    end
end

function IllustrationRoleDetailLayer:drawRole()
    if self.IamgeRole ~= nil then
        return
    end

    local img_role = TFImage:create(self.cardRole:getBigImagePath())
    img_role:setFlipX(true)
    img_role:setAnchorPoint(ccp(0.5,0.5))
    img_role:setScale(0.65)
    img_role:setPosition(ccp(320/2, 500/2))
    self.panel_list:addChild(img_role)
    self.IamgeRole = img_role
end

function IllustrationRoleDetailLayer:drawOutput()
    -- local ui = self.ui

    -- self.btn_mission        = TFDirector:getChildByPath(ui, 'btn_mission')
    -- self.img_open           = TFDirector:getChildByPath(ui, 'img_open')
    -- self.txt_way            = TFDirector:getChildByPath(ui, 'txt_way')

    -- self.img_open:setVisible(false)
    -- -- 
    -- local role              = RoleData:objectByID(self.cardRoleId)
    -- local showWay           = string.split(role.show_way, "|")

    -- local function onclikMission()
    --     MissionManager:showHomeToMissionLayer(1)
    -- end

    -- if showWay[1] then
    --     print("showWay = ", showWay[1])
    --     local missionId = tonumber(showWay[1])
    --     local open    = MissionManager:getMissionIsOpen(missionId)
    --     self.img_open:setVisible(not open)

    --     self.btn_mission:addMEListener(TFWIDGET_CLICK, audioClickfun(onclikMission))

    --     local mission = MissionManager:getMissionById(missionId);
    --     local missionlist = MissionManager:getMissionListByMapId(mission.mapid);
    --     local curMissionlist = missionlist[mission.difficulty];
    --     local index = curMissionlist:indexOf(mission);
    --     local map = MissionManager:getMapById(mission.mapid)
    --     self.txt_way:setText( map.name .. " " .. mission.stagename);
    -- end

end


return IllustrationRoleDetailLayer