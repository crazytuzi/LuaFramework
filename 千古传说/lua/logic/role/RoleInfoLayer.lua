--[[
******角色详情*******
    -- by haidong.gan
    -- 2014/4/10
]]

local RoleInfoLayer = class("RoleInfoLayer", BaseLayer)

function RoleInfoLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.role.RoleInfoLayer")
end

function RoleInfoLayer:loadSelfData(selectIndex)
    self.selectIndex    = selectIndex;
    self.cardRoleId     = nil;
    self.roleList       = CardRoleManager.cardRoleList; -- add by king 
    self.type           = "self";
end

function RoleInfoLayer:loadOtherData(selectIndex,roleList)
    self.selectIndex  = selectIndex;
    self.cardRoleId     = nil;
    self.roleList     = roleList;

    self.type         = "other";
end

-- 增加血战的详细角色查看 add by king
function RoleInfoLayer:loadBloodyData(selectIndex,roleList)
    self.selectIndex  = selectIndex;
    self.cardRoleId     = nil;
    self.roleList     = roleList;

    self.type         = "self";
end

function RoleInfoLayer:onShow()
    self.super.onShow(self)
      
    self:refreshBaseUI();
    self:refreshUI();
end

function RoleInfoLayer:refreshBaseUI()

end

function RoleInfoLayer:refreshUI()
    if not self.isShow then
        return;
    end
    self.isHaveEquip = {}
    if self.type == "self" then
        -- self.roleList = CardRoleManager.cardRoleList; --del by king
        if self.cardRoleId then
            local cardRole = CardRoleManager:getRoleById(self.cardRoleId);
            self.selectIndex = self.roleList:indexOf(cardRole);
        end
        for i=1,5 do
            local equipList = EquipmentManager:GetEquipByTypeAndUsed(i,false);
            if equipList and equipList:length() > 0 then
                self.isHaveEquip[i] = true;
            else
                self.isHaveEquip[i] = false;
            end
        end
    end
    self:refreshRoleList(self.selectIndex);
end

function RoleInfoLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_auto       = TFDirector:getChildByPath(ui, 'btn_auto');

    self.panel_list     = TFDirector:getChildByPath(ui, 'panel_list')


    -- self.btn_equip      = TFDirector:getChildByPath(ui, 'btn_equipment');
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
    -- self.img_role       = TFDirector:getChildByPath(ui, 'img_role');
    self.img_type       = TFDirector:getChildByPath(ui, 'img_zhiye');
    self.bar_exp        = TFDirector:getChildByPath(ui, 'bar_exp');
    self.txt_exp        = TFDirector:getChildByPath(ui, 'txt_exp');
    self.txt_level      = TFDirector:getChildByPath(ui, 'txt_level');
    self.txt_name       = TFDirector:getChildByPath(ui, 'txt_name');
    self.txt_power      = TFDirector:getChildByPath(ui, 'txt_power');
    -- self.bg_pos         = TFDirector:getChildByPath(ui, 'bg_pos');
    -- self.img_point      = TFDirector:getChildByPath(ui, 'img_point');

    self.panel_equip     = TFDirector:getChildByPath(ui, 'panel_zhuangbei');
    self.img_equipList = {}
    self.img_equipQualityList = {}
    self.img_equipEmptyList = {}
    self.img_gemBg = {}
    self.img_gem = {}
    self.img_add = {}

    for i=1,5 do
        local panel_equip = TFDirector:getChildByPath(ui, "panel_equip_"..i)


        self.img_equipList[i] = TFDirector:getChildByPath(panel_equip, "img_equip")

        self.img_equipQualityList[i] = TFDirector:getChildByPath(panel_equip, "img_quality")
        self.img_equipQualityList[i]:setTag(i); 
        self.img_equipQualityList[i].logic = self;
        self.img_equipQualityList[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onEquipIconClickHandle,play_xuanze));
        self.img_equipQualityList[i].type = "Quality";

        self.img_equipEmptyList[i] = TFDirector:getChildByPath(panel_equip, "img_bg")
        self.img_equipEmptyList[i]:setTag(i); 
        self.img_equipEmptyList[i].logic = self;
        self.img_equipEmptyList[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onEquipIconClickHandle,play_xuanze));
        self.img_equipEmptyList[i].type = "Empty";

        self.img_gemBg[i] = {}
        self.img_gem[i] = {}
        for j=1,EquipmentManager.kGemMergeTargetNum do
            self.img_gemBg[i][j] = TFDirector:getChildByPath(panel_equip, "img_baoshicao"..j)
            self.img_gem[i][j] = TFDirector:getChildByPath(panel_equip, "img_gem"..j)
        end
        self.img_add[i] = TFDirector:getChildByPath(panel_equip, "img_add")
    end
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


    -- self.txt_arr_base[EnumAttributeType.Agility]:enableShadow(CCSizeMake(10, 10),0,0);

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

    self.img_skill      = TFDirector:getChildByPath(ui, 'img_skill_icon');



    self.img_soul_max       = TFDirector:getChildByPath(ui, 'img_soul_max');
    self.img_soul_bg        = TFDirector:getChildByPath(ui, 'img_soul_bg');
    self.bar_soul           = TFDirector:getChildByPath(ui, 'bar_soul');
    self.txt_soul_num_need        = TFDirector:getChildByPath(ui, 'txt_soul_num_need');
    self.txt_soul_num_have        = TFDirector:getChildByPath(ui, 'txt_soul_num_have');

    local pageView = TPageView:create()
    self.pageView = pageView

    pageView:setTouchEnabled(true)
    pageView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    pageView:setSize(self.panel_list:getContentSize())
    -- pageView:setPosition(self.panel_list:getPosition())
    pageView:setAnchorPoint(self.panel_list:getAnchorPoint())

    local function onPageChange()
        self:onPageChange();
    end
    pageView:setChangeFunc(onPageChange)

    local function itemAdd(index)
        return  self:addPage(index);
    end 
    pageView:setAddFunc(itemAdd)

    self.panel_list:addChild(pageView,2);

    self.btn_left           = TFDirector:getChildByPath(ui, 'btn_pageleft')
    self.btn_right          = TFDirector:getChildByPath(ui, 'btn_pageright')
    self.positiony          = self.btn_right:getPosition().y;

end

function RoleInfoLayer.onLeftClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:getCurPageIndex() ;
    self.pageView:scrollToPage(pageIndex - 1);
end

function RoleInfoLayer.onRightClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:getCurPageIndex() ;
    self.pageView:scrollToPage(pageIndex + 1);
end

function RoleInfoLayer:refreshRoleList(pageIndex)
    self.pageView:_removeAllPages();

    self.pageView:setMaxLength(self.roleList:length())

    self.pageList        = {};

    self:showInfoForPage(pageIndex);

    self.pageView:InitIndex(pageIndex);      
end

function RoleInfoLayer:onPageChange()
    local pageIndex = self.pageView:_getCurPageIndex() ;
    self:showInfoForPage(pageIndex);
end

function RoleInfoLayer:addPage(pageIndex) 
    local page = TFPanel:create();
    page:setSize(self.panel_list:getContentSize())


    local cardRole = self.roleList:objectAt(pageIndex);

    local img_role = TFImage:create(cardRole:getBigImagePath());
    -- print(cardRole.name)
    img_role:setScale(0.65);
    img_role:setFlipX(true);
    img_role:setAnchorPoint(ccp(0.5,0.5))
    -- img_role:setPosition(ccp(img_role:getSize().width/2*img_role:getScaleX() - 30,img_role:getSize().height/2*img_role:getScaleY() + 50))
    img_role:setPosition(ccp(320/2,500/2))
    page:addChild(img_role);
  
    self.pageList[cardRole.id] = page;

    return page;
end

function RoleInfoLayer:showInfoForPage(pageIndex)
   self.selectIndex = pageIndex;

   self:refreshRoleInfo();

    local pageCount = self.roleList:length();

    self.btn_left:setPosition(ccp(self.btn_left:getPosition().x,1000));
    self.btn_right:setPosition(ccp(self.btn_right:getPosition().x,1000));

    if pageIndex < pageCount and pageCount > 1 then
        self.btn_right:setPosition(ccp(self.btn_right:getPosition().x,self.positiony));
    end 

    if pageIndex > 1 and pageCount > 1  then
        self.btn_left:setPosition(ccp(self.btn_left:getPosition().x,self.positiony));
    end

end

function RoleInfoLayer:refreshSkillInfo()

-- //主角技能信息，单个技能信息
-- message LeadingRoleSpell
-- {
--  required int32 spellId = 1;         //法术ID
--  required bool choice = 2;           //是否选中
--  required int32 sid = 3;             //法术的种类ID，一种法术有多个等级，但是统一法术SID一致
-- }
-- self.spellInfoShowArr = {}

--  local index = 1;
--  for spellInfoItem in self.spellInfoList do
--      self.spellInfoShowArr[index] = {spellInfoItem,nil};
--      for k,spellLevelId in pairs(self.spellLevelIdList) do
--          local spellLevelItem = SkillLevelData:objectByID(v);
--          if spellLevelItem.sid == spellInfoItem.id then
--              self.spellInfoShowArr[index] = {spellInfoItem,spellLevelItem};
--          end
--      end
--  end
    -- self.spellLevelIdList   = {}
    -- self.leadingRoleSpellList   = {}

    -- self.spellInfoList              = roleConfig:getSpellInfoList();
    -- self.leadingSpellInfoConfigList = roleConfig:getLeadingSpellInfoConfigList();
    -- self.leadingSpellInfoList       = roleConfig:getLeadingSpellInfoList();

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
                    self.node_skillList[index].des = stringUtils.format(localizable.IllRoleDetaLayer_unlock, QUALITY_STR[openQuality[index]] )

                    self.txt_skillLevelList[index]:setVisible(false);
                    self.img_openQualityList[index]:setVisible(true);
                    self.img_openQualityList[index]:setTexture(GetFontSmallByQuality(openQuality[index]));

                    print(QUALITY_STR[openQuality[index]] .. "品解锁")
                else
                    local levelInfo = nil;
                    if self.cardRole.spellLevelIdList then
                        for i,levelId in pairs(self.cardRole.spellLevelIdList) do
                            local levelItem = SkillLevelData:objectByID(levelId);
                            if spellInfo.id == levelItem.sid then
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

                    self.node_skillList[index].level = level
                    print("LV：" .. level)
                end

                self.node_skillList[index].spellInfo = spellInfo
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
                            level = SkillLevelData:objectByID(spell.spellId).level;
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
                        self.node_skillList[index].des = stringUtils.format(localizable.IllRoleDetaLayer_unlock, QUALITY_STR[spellInfoConfig.enable_quality] )

                        self.txt_skillLevelList[index]:setVisible(false);
                        self.img_openQualityList[index]:setVisible(true);
                        self.img_openQualityList[index]:setTexture(GetFontByQuality(spellInfoConfig.enable_quality));

                        --print(QUALITY_STR[spellInfoConfig.enable_quality] .. "品解锁")
                    elseif not spellInfoConfig:GetLevelIsOpen(self.cardRole.level) then
                        self.img_skillList[index]:setColor(ccc3(166, 166, 166));
                        --self.node_skillList[index].des = spellInfoConfig.enable_level .. "级解锁"
                        self.node_skillList[index].des =stringUtils.format(localizable.common_level_unlock, spellInfoConfig.enable_level)

                        self.txt_skillLevelList[index]:setVisible(true);
                        self.img_openQualityList[index]:setVisible(false);
                        --self.txt_skillLevelList[index]:setText(spellInfoConfig.enable_level .. "级解锁");
                        self.txt_skillLevelList[index]:setText(stringUtils.format(localizable.common_level_unlock, spellInfoConfig.enable_level ));

                        --print(spellInfoConfig.enable_level .. "级解锁")
                    else
                        self.img_skillList[index]:setColor(ccc3(255, 255, 255));
                        self.node_skillList[index].level = level

                        self.txt_skillLevelList[index]:setVisible(true);
                        self.img_openQualityList[index]:setVisible(false);
                        self.txt_skillLevelList[index]:setText("LV：" .. level);

                        print("LV：" .. level)
                    end
                    self.node_skillList[index].spellInfoConfig = spellInfoConfig
                end
            end
        end
    end
end

function RoleInfoLayer:refreshRoleInfo()
    self.cardRole = self.roleList:objectAt(self.selectIndex);
    self.cardRoleId = self.cardRole.id;

    if self.type == "self" then
        local fateArray = RoleFateData:getRoleFateById(self.cardRole.id)

        local index = 1;
        local fateStatusArray = {};
        for fate in fateArray:iterator() do
            fateStatusArray[fate.id] = self.cardRole:getFateStatus(fate.id);
        end
        self.cardRole.fateStatusArray = fateStatusArray;

        
        CommonManager:setRedPoint(self.btn_upStar, CardRoleManager:isCanStarUp(self.cardRole.gmId),"isCanStarUp",ccp(5,5),1201)
        CommonManager:setRedPoint(self.btn_train, CardRoleManager:isCanBreakUp(self.cardRole.gmId),"isCanBreakUp",ccp(5,5),901)
    end

    self:refreshSkillInfo();
    self:setDefualtVisible();

    --角色信息
    -- self.img_role:setTexture(self.cardRole:getBigImagePath());
    self.img_type:setTexture("ui_new/common/img_role_type" .. self.cardRole.outline .. ".png");
    self.txt_name:setText(self.cardRole.name);
    -- self.txt_name:setColor(GetColorByQuality(self.cardRole.quality));
    self.img_quality:setTexture(GetFontByQuality(self.cardRole.quality));
    self.txt_level:setText(self.cardRole.level .. "d");
    self.txt_power:setText(self.cardRole.power);
    
    if self.cardRole.maxExp == 0 then
        --self.txt_exp:setText("满级")
        self.txt_exp:setText(localizable.common_max_level)
        self.bar_exp:setPercent(100)
    else
        self.bar_exp:setPercent((self.cardRole.curExp/self.cardRole.maxExp)*100);
        self.txt_exp:setText((self.cardRole.curExp.."/"..self.cardRole.maxExp));
    end

    -- if self.cardRole.pos ~= nil and self.cardRole.pos > 0 then
    --     self.bg_pos:setVisible(true)
    --     self.img_point:setPosition(ccp(((1-(self.cardRole.pos - 1)%3) * 16),(1 - math.floor((self.cardRole.pos-1)/3)) * 16 ));
    -- else
    --     self.bg_pos:setVisible(false);
    -- end
    -- for i=1,17 do
    --     local attribute = self.cardRole:getTotalAttribute(i);
    --     self.attrLabelList[i]:setText(attribute);
    -- end

    -- self.txt_des:setText(self.cardRole.describe1);

    -- self.img_skill:setTexture(SkillLevelData:objectByID(self.cardRole.skill):GetPath());

    -- local arrStr = self.cardRole:getOutline();
    -- for i=1,2 do
    --     self.txt_wenbenList[i]:setVisible(false);
    -- end
    -- for i,arrStr in ipairs(arrStr) do
    --     self.txt_wenbenList[i]:setVisible(true);
    --     self.txt_wenbenList[i]:setText(arrStr);
    -- end
    
    --星级
    for i=1, 5 do
        if (i <= self.cardRole.starlevel) then
            self.img_starList[i]:setVisible(true);
        else
            self.img_starList[i]:setVisible(false);    
        end
    end

    --角色属性
    for index,txt_arr in pairs(self.txt_arr_base) do
        local arrStr = 0;
        if self.type == "self" then
            arrStr = self.cardRole:getTotalAttribute(index)
        else
            arrStr = self.cardRole.totalAttribute[index]
        end

        txt_arr:setText(arrStr);
    end
    for index,txt_arr in pairs(self.txt_arr_add) do
        txt_arr:setVisible(false);
    end

    for i=1,6 do
        local acupointInfo = self.cardRole:GetAcupointInfo(i)
        if acupointInfo ~= nil then
            local table_arr = GetAttrByString(acupointInfo.buffStr);
            for attribute,num in pairs(table_arr) do
                if (self.txt_arr_add[attribute] ~= nil) then
                    -- self.txt_arr_add[attribute]:setVisible(true);
                    self.txt_arr_add[attribute]:setText("(+"..num .. ")")
                end
                break;
            end
        end
    end

    --缘分
    for index,node in pairs(self.node_fateList) do
        node:setVisible(false);
    end
    for index,node in pairs(self.node_fateLList) do
        node:setVisible(false);
    end
    local fateArray = RoleFateData:getRoleFateById(self.cardRole.id)
    
    local index = 1;

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


    --主角特殊处理
    if self.cardRole:getIsMainPlayer() then
        -- self.panel_des:setVisible(false);
        self.panel_fight_skill:setVisible(true);
    else
        -- self.panel_des:setVisible(false);
        self.panel_fight_skill:setVisible(true);
    end

    --魂魄修炼
    if  self.cardRole.starlevel == 5 then
        self.img_soul_max:setVisible(true)
        self.img_soul_bg:setVisible(false)
        self.btn_upStar:setVisible(false)
    else
        self.img_soul_max:setVisible(false)
        self.img_soul_bg:setVisible(true)
        self.btn_upStar:setVisible(true)
        
        self.bar_soul:setPercent((self.cardRole:getHaveSoulNum()/self.cardRole:getUpstarNeedSoulNum())*100);
        self.txt_soul_num_need:setText("/" .. self.cardRole:getUpstarNeedSoulNum());
        self.txt_soul_num_have:setText(self.cardRole:getHaveSoulNum());
        if self.cardRole:getHaveSoulNum() < self.cardRole:getUpstarNeedSoulNum() then
            self.txt_soul_num_have:setColor(ccc3(255,   0,   0))
        else
            self.txt_soul_num_have:setColor(ccc3(  0, 255,   0))
        end
    end

    self:refreshEquipIcon();

    self:setOtherVisible();

end

function RoleInfoLayer:setDefualtVisible()
    self.btn_auto:setVisible(true);
    -- self.btn_equip:setVisible(true);
    self.btn_train:setVisible(true);
    self.btn_transfer:setVisible(true);
    self.btn_upStar:setVisible(true);

    self.btn_skill:setVisible(true);
    self.btn_fate:setVisible(true);
    self.btn_moreattr:setVisible(true);

end

function RoleInfoLayer:setOtherVisible()
    if self.type == "other" then
        self.btn_auto:setVisible(false);
        -- self.btn_equip:setVisible(false);
        self.btn_train:setVisible(false);
        self.btn_transfer:setVisible(false);
        self.btn_upStar:setVisible(false);

        self.btn_skill:setVisible(false);
        self.btn_fate:setVisible(false);
        self.btn_moreattr:setVisible(false);

        for i=1,5 do
            self.img_equipQualityList[i]:setTouchEnabled(false);

            self.img_equipEmptyList[i]:setTouchEnabled(false);
        end
    else

    end
end

function RoleInfoLayer:setBtnOpen()
end

function RoleInfoLayer.onEquipIconClickHandle(sender)
    local self = sender.logic;
    local index = sender:getTag();

    local laseIndex = nil;
    if (self.img_select) then
       laseIndex = self.img_select:getTag();
    end 
    self:removeSelectIcon();

    if (laseIndex == index) then
        --选择了同一个，直接返回
        self:closeEquipListLayer();
        return;
    end

    local index = sender:getTag();
    local equipItem = self.cardRole:getEquipmentByIndex(index);
    local equipList = EquipmentManager:GetEquipByType(index);
    
    if  equipList:length() > 0 or equipItem then
        self:addSelectIcon(index);
        self:showEquipListLayer(index);
    else

        self:closeEquipListLayer();
        --param = {equipId = self.equipid}) or {roleId = self.cardRoleId})
        -- IllustrationManager:showOutputList(param)
        CommonManager:showNeedEquipComfirmLayer();
    end
end

function RoleInfoLayer.onEquipCloseClickHandle(sender)
    local self = sender.logic;
    self:removeSelectIcon();
    self:closeEquipListLayer();
end

function RoleInfoLayer:addSelectIcon(index)
    self:removeSelectIcon();

    local img_select = TFImage:create("ui_new/roleequip/js_zbkxuanzhong_icon.png")
    img_select:setTag(index);

    img_select:setPosition(self.img_equipEmptyList[index]:getPosition());
    self.img_equipEmptyList[index]:getParent():addChild(img_select,10);

    self.img_select = img_select;
end

function RoleInfoLayer:removeSelectIcon()
    if (self.img_select) then
       self.img_select:removeFromParent();
       self.img_select = nil;
    end 
end

function RoleInfoLayer:showEquipListLayer(index)
    if (self.equipLayer == nil) then
        local equipLayer = require("lua.logic.role.RoleEquipInfoLayer"):new();
        equipLayer:setTag(10086);
        equipLayer:setZOrder(2);
        self:addLayer(equipLayer);

        local btn_close = TFDirector:getChildByPath(equipLayer,"btn_close");
        btn_close.logic     = self;
        btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onEquipCloseClickHandle),1);

        self.equipLayer = equipLayer;

    end

    self.equipLayer:loadData(self.cardRole.gmId,index);
    self.equipLayer:onShow();
    
    self.panel_level:setVisible(false);
end

function RoleInfoLayer:closeEquipListLayer()
    if self.equipLayer then
        self:removeLayer(self.equipLayer,true);
        self.equipLayer = nil;
        self.panel_level:setVisible(true);
    end
end

function RoleInfoLayer.onEquipClickHandle(sender)
    local self = sender.logic;
    self.panel_equip:setVisible(not self.panel_equip:isVisible());
end

function RoleInfoLayer.onTrainClickHandle(sender)
    local self = sender.logic;
    CardRoleManager:openTrainLayer(self.cardRole.gmId);
end

function RoleInfoLayer.onBookClickHandle(sender)
    local self = sender.logic;

end

function RoleInfoLayer.onTransferClickHandle(sender)
    local self = sender.logic;
    CardRoleManager:openRoleTransferLayer( self.cardRole.gmId )
end

function RoleInfoLayer.onUpStarClickHandle(sender)
    local self = sender.logic;
    if self.cardRole:getHaveSoulNum() < self.cardRole:getUpstarNeedSoulNum() then
        CommonManager:showNeedRoleComfirmLayer();
        return;
    end

    self.oldarr = {}
    --角色属性
    for i=1,EnumAttributeType.Max do
        self.oldarr[i] = self.cardRole:getTotalAttribute(i);
    end

    CardRoleManager:roleStarUp( self.cardRole.gmId  );

end

function RoleInfoLayer:onUpStarUpCompelete()
    local layer =  AlertManager:addLayerByFile("lua.logic.role.RoleStarUpResultLayer");
    layer:loadData(self.cardRole.gmId,self.oldarr,self.cardRole:getpower());

    AlertManager:show();
end

function RoleInfoLayer.onSkillClickHandle(sender)
    local self = sender.logic;
    if self.cardRole:getIsMainPlayer() then
        CardRoleManager:openMainSkillListLayer( self.cardRole.gmId )
    else
        CardRoleManager:openRoleSkillListLayer( self.cardRole.gmId )
    end
end


function RoleInfoLayer.onSkillItemClickHandle(sender)
    local self = sender.logic;
    if sender.level ~= -1 then
        if self.cardRole:getIsMainPlayer() then
           local spellInfoConfig = sender.spellInfoConfig;
           local spellInfo = spellInfoConfig:GetSpellInfo();
           local spellLevelInfo = spellInfo:GetLevelItem(sender.level)
           CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
        else
           local spellInfo = sender.spellInfo;
           local spellLevelInfo = spellInfo:GetLevelItem(sender.level)
           CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
        end
    else
        if self.cardRole:getIsMainPlayer() then
           local spellInfoConfig = sender.spellInfoConfig;
           local spellInfo = spellInfoConfig:GetSpellInfo();
           local spellLevelInfo = spellInfo:GetLevelItem(1)
           CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
        else
           local spellInfo = sender.spellInfo;
           local spellLevelInfo = spellInfo:GetLevelItem(1)
           CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
        end
        -- toastMessage(sender.des)
    end


    -- self.img_skillList[index].spellInfoConfig = spellInfoConfig
    -- self.img_skillList[index].level = level

end

function RoleInfoLayer.onFateClickHandle(sender)
    local self = sender.logic;
    CardRoleManager:openFateDetail(self.cardRole.gmId);
end

function RoleInfoLayer.onMoreAttrClickHandle(sender)
    local self = sender.logic;
    CardRoleManager:openMoreAttr( self.cardRole.gmId );
end

function RoleInfoLayer.onCloseClickHandle(sender)
    local self = sender.logic;

    if (self.img_select) then
        self:removeSelectIcon();
        self:closeEquipListLayer();
       return;
    end 
    AlertManager:close(AlertManager.TWEEN_1);
end
function RoleInfoLayer.onAutoClickHandle(sender)
     local self = sender.logic;
     TFAudio.playEffect("sound/effect/btn_wear.mp3", false)

     TFDirector:dispatchGlobalEventWith("EquipmentChangeBegin",{isAuto = true});    

     TFDirector:send(c2s.ONE_KEY_EQUIP,{self.cardRole.gmId});
end
function RoleInfoLayer:registerEvents(ui)
    self.super.registerEvents(self)
    -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    self.btn_close.logic    = self;
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle),1);
    self.btn_close:setClickAreaLength(100);


    -- self.btn_equip.logic = self;
    self.btn_train.logic = self;
    -- self.btn_book.logic  = self;
    self.btn_transfer.logic = self;
    self.btn_upStar.logic = self;
    self.btn_skill.logic    = self;
    self.btn_fate.logic    = self;
    self.btn_moreattr.logic    = self;

    self.btn_auto.logic     = self;
    self.btn_auto:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAutoClickHandle),1);

    self.btn_train:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTrainClickHandle),1);
    self.btn_transfer:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTransferClickHandle),1);
    self.btn_upStar:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onUpStarClickHandle),1);
    self.btn_skill:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSkillClickHandle),1);
    self.btn_fate:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onFateClickHandle),1);
    self.btn_moreattr:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onMoreAttrClickHandle),1);

    for i=1,3 do
        self.node_skillList[i].logic     = self;
        self.node_skillList[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSkillItemClickHandle));
    end

    self.btn_left.logic = self;
    self.btn_left:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onLeftClickHandle),1);
    self.btn_right.logic = self;
    self.btn_right:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onRightClickHandle),1);

    self.EquipUpdateCallBack = function(event)
        self:removeSelectIcon();
        self:closeEquipListLayer();
        self:refreshUI();
    end
    TFDirector:addMEGlobalListener(EquipmentManager.EQUIP_OPERATION,  self.EquipUpdateCallBack)
    TFDirector:addMEGlobalListener(EquipmentManager.UNEQUIP_OPERATION ,  self.EquipUpdateCallBack)
 

    self.RoleStarUpResultCallBack = function (event)
        self:onUpStarUpCompelete();
    end
    TFDirector:addMEGlobalListener(CardRoleManager.ROLE_PRACTICE_RESULT,self.RoleStarUpResultCallBack)


    self.EquipmentChangeBeginCallBack = function (event)
        self.oldarr = {}
        --角色属性
        for i=1,EnumAttributeType.Max do
            self.oldarr[i] = self.cardRole:getTotalAttribute(i);
        end
        self.isAuto = event.data[1].isAuto;

        self.oldpower = self.cardRole.power;
    end
    TFDirector:addMEGlobalListener("EquipmentChangeBegin",self.EquipmentChangeBeginCallBack)


    self.EquipmentChangeEndCallBack = function (event)

        if self.isAuto then
            return;
        end

        local  newarr = {}
        --角色属性
        for i=1,EnumAttributeType.Max do
            newarr[i] = self.cardRole:getTotalAttribute(i);
        end

        if self.oldarr and newarr then
            self:arrChange( self.oldarr,newarr);
        end

        local newpower = self.cardRole.power;
        self:textChange(self.oldpower,newpower);

    end
    TFDirector:addMEGlobalListener("EquipmentChangeEnd",self.EquipmentChangeEndCallBack)

end

function RoleInfoLayer:textChange(oldValue,newValue)
    if not oldValue or not newValue then
        return;
    end
    
    self.txt_power:setText(oldValue);

    local changeSum = newValue - oldValue
    local changeCab = math.min(1,changeSum/60)
    local changeTimes = math.min(30,math.abs((changeCab*60)))

    local index = 1;
    local function change()
        if newValue > oldValue then
            play_shuzibiandong()
        end

        local tempValue = oldValue + index *((changeSum)/changeTimes)
        self.txt_power:setText(math.floor(tempValue));
        index = index + 1;
    end

    local function changeCom()
        self.txt_power:setText(newValue);
    end
    if self.textTimeId ~= nil then
        TFDirector:removeTimer(self.textTimeId);
    end
    self.textTimeId = TFDirector:addTimer(1/60, changeTimes, changeCom, change);
end

function RoleInfoLayer:arrChange(oldarr,newarr)
    local changeArrTemp = {}
    local changeLength = 0;
    for i=1,EnumAttributeType.Max do
        local offset = newarr[i] - oldarr[i];
        if offset ~= 0 then
            changeLength = changeLength + 1;
            changeArrTemp[changeLength] = {i,offset};

        end
    end

    local changeArr = {}

    local index = 0;
    for i=1,#changeArrTemp do
        local offsetTb = changeArrTemp[i];
        if offsetTb[2] > 0 then
            index = index + 1;
            changeArr[index] = offsetTb;
        end
    end

    for i=1,#changeArrTemp do
        local offsetTb = changeArrTemp[i];
        if offsetTb[2] < 0 then
            index = index + 1;
            changeArr[index] = offsetTb;
        end
    end


    local index = 1;
    function addToast()

        if #changeArr < 1 then
            return;
        end

        local offsetTb = changeArr[index];

        -- print("offset:",AttributeTypeStr[offsetTb[1]],offsetTb[2])


        local label = TFLabelBMFont:create();
        label:setPosition(ccp(280,100));
        self:addChild(label,10);

        if offsetTb[2] > 0 then
            label:setFntFile("font/num_100.fnt")
            -- label:setColor(ccc3(  0, 255,   0));
            label:setText(AttributeTypeStr[offsetTb[1]] .. "+" .. covertToDisplayValue(offsetTb[1],offsetTb[2]));
        end

        if offsetTb[2] < 0 then
            label:setFntFile("font/num_99.fnt")
            -- label:setColor(ccc3(255,   0,   0));
            label:setText(AttributeTypeStr[offsetTb[1]] .. covertToDisplayValue(offsetTb[1],offsetTb[2]));
        end
        -- local toY = label:getPosition().y + (changeLength - index + 2) * 40;
        local toY = label:getPosition().y + 200;
        local toX = label:getPosition().x;
        

        local toastTween = {
              target = label,
              {
                duration = 1.5,
                x = toX,
                y = toY
              },
              { 
                duration = 0,
                delay = 0.2, 
              },
              {
                 duration = 0.5,
                 alpha = 0.2,
              },
              {
                duration = 0,
                onComplete = function() 
                    label:removeFromParent();
               end
              }
            }
 
        TFDirector:toTween(toastTween);
        index = index + 1;
    end

    function addToastCom()
        TFDirector:removeTimer(self.toastTimeId);
        self.toastTimeId = nil;
    end

    addToast();

    if self.toastTimeId ~= nil then
        TFDirector:removeTimer(self.toastTimeId);
    end
    if  changeLength > 1 then
        self.toastTimeId = TFDirector:addTimer(500, changeLength -1, addToastCom, addToast);
    end
end

function RoleInfoLayer:removeEvents()
    self.super.removeEvents(self);

    TFDirector:removeTimer(self.toastTimeId);
    self.toastTimeId = nil;

    TFDirector:removeTimer(self.textTimeId);
    self.textTimeId = nil;

    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIP_OPERATION, self.EquipUpdateCallBack)
    TFDirector:removeMEGlobalListener(EquipmentManager.UNEQUIP_OPERATION, self.EquipUpdateCallBack)

    TFDirector:removeMEGlobalListener("EquipmentChangeBegin",self.EquipmentChangeBeginCallBack)
    TFDirector:removeMEGlobalListener("EquipmentChangeEnd",self.EquipmentChangeEndCallBack)

    TFDirector:removeMEGlobalListener(CardRoleManager.ROLE_PRACTICE_RESULT,self.RoleStarUpResultCallBack)
end


function RoleInfoLayer:refreshEquipIcon()
    for i=1, 5 do
        self.img_equipList[i]:setFlipX(true);
        self.img_equipEmptyList[i]:setFlipX(true);

        local equipInfo = self.cardRole:getEquipment():GetEquipByType(i)
        -- local equipList = EquipmentManager:GetEquipByTypeAndUsed(i,false);
        for j=1,EquipmentManager.kGemMergeTargetNum do
            self.img_gemBg[i][j]:setVisible(false);
        end
        
        if equipInfo == nil then
            self.img_equipList[i]:setVisible(false);
            self.img_equipQualityList[i]:setVisible(false);
            for j=1,EquipmentManager.kGemMergeTargetNum do
                self.img_gemBg[i][j]:setVisible(false);
            end

            self.img_equipEmptyList[i]:setVisible(true);


            if self.isHaveEquip[i] then
                self.img_add[i]:setVisible(true);
                -- self.img_add[i]:setShaderProgramDefault(true)
            else
                self.img_add[i]:setVisible(false);
                -- self.img_add[i]:setShaderProgram("GrayShader", true)
            end
                
            else
                self.img_equipList[i]:setVisible(true);
                self.img_equipQualityList[i]:setVisible(true);
                -- self.img_equipEmptyList[i]:setVisible(false);
                local gemid = nil;
                for j=1,EquipmentManager.kGemMergeTargetNum do
                     if self.type == "self" then
                        gemid = equipInfo:getGemPos(j)
                    else
                        gemid = equipInfo.gemid;
                    end
          
                    if gemid ~= nil and gemid ~= 0 then
                        self.img_gemBg[i][j]:setVisible(true);
                        print(gem,gemid)
                        local gem = ItemData:objectByID(gemid)
                        self.img_gem[i][j]:setTexture(gem:GetPath())
                    end                   
                end
                self.img_equipList[i]:setTexture(equipInfo.textrueName);
                self.img_equipQualityList[i]:setTextureNormal(GetColorIconByQuality(equipInfo.quality));
            end

        -- if equipList:length() > 0 then
        --     self.img_equipEmptyList[i]:setColor(ccc3(255, 255, 255));
        -- else
        --     self.img_equipEmptyList[i]:setColor(ccc3(166, 166, 166));
        -- end

    end
end

return RoleInfoLayer
