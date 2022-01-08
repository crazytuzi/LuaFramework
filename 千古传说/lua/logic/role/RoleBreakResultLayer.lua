--[[
******品质提升结果*******

    -- by haidong.gan
    -- 2014/4/16
]]

local RoleBreakResultLayer = class("RoleBreakResultLayer", BaseLayer)
--local trainNames = {"带脉","冲脉","任脉","督脉","维脉","跷脉"};
local trainNames = localizable.role_train_names

function RoleBreakResultLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.role.RoleBreakResultLayer")
end

function RoleBreakResultLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close             = TFDirector:getChildByPath(ui, 'btn_close')

    self.node_roleArr = {}
    self.img_roleArr = {}
    self.txt_LevelArr = {}
    self.txt_nameArr = {}
    self.img_qualityArr = {}
    self.img_qualityWordArr = {}
    self.txt_trainMaxArr = {}
    self.txt_openTrainArr = {}

    for i=1,2 do
        self.node_roleArr[i] = TFDirector:getChildByPath(ui, "panel_card_"..i)
        self.img_roleArr[i] = TFDirector:getChildByPath(self.node_roleArr[i], "img_touxiang")
        self.txt_LevelArr[i] = TFDirector:getChildByPath(self.node_roleArr[i], "txt_lv_word")
        self.txt_nameArr[i] = TFDirector:getChildByPath(self.node_roleArr[i], "txt_name")

        self.img_qualityArr[i] = TFDirector:getChildByPath(self.node_roleArr[i], "img_pinzhiditu")
        self.img_qualityWordArr[i] = TFDirector:getChildByPath(ui, "img_pinzhi" .. i)
        self.txt_trainMaxArr[i] = TFDirector:getChildByPath(ui, "img_lv" .. i)
        self.txt_openTrainArr[i] = TFDirector:getChildByPath(ui, "txt_jingmai" .. i)
    end


    self.txt_name             = TFDirector:getChildByPath(ui, 'txt_skillname');

    self.txt_skill_type       = TFDirector:getChildByPath(ui, 'txt_skillleixing');
    self.txt_attack_type      = TFDirector:getChildByPath(ui, 'txt_skillmubiao');

    self.panel_des      = TFDirector:getChildByPath(ui, 'panel_des');
    local richText = TFRichText:create(self.panel_des:getSize())
    -- richText:setTouchEnabled(true)
    richText:setPosition(ccp(0,0))
    richText:setAnchorPoint(ccp(0, 1))
    self.panel_des:removeAllChildren()
    self.panel_des:addChild(richText)

    self.txt_des      = richText;

    self.img_skill    = TFDirector:getChildByPath(ui, 'img_skill');

    self.bg_skill      = TFDirector:getChildByPath(ui, 'bg_skill');
end

function RoleBreakResultLayer:loadData(roleGmId)
    self.roleGmId = roleGmId;
end

function RoleBreakResultLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function RoleBreakResultLayer:refreshBaseUI()

end

function RoleBreakResultLayer:refreshUI()
    if not self.isShow then
        return;
    end
    print("RoleBreakResultLayer:refreshUI")
    self.cardRole = CardRoleManager:getRoleByGmid( self.roleGmId )

    -- self.txt_trainMaxArr = {}
    -- self.txt_openTrainArr = {}

    for i=1,2 do
        self.img_roleArr[i]:setTexture(self.cardRole:getIconPath())
        self.txt_nameArr[i]:setText(self.cardRole.name)

        -- self.txt_nameArr[i]:setColor(GetColorByQuality(self.cardRole.quality + i - 2))

        self.txt_LevelArr[i]:setText(self.cardRole.level)

        self.img_qualityArr[i]:setTexture(GetColorIconByQuality( self.cardRole.quality  + i - 2))

        self.txt_trainMaxArr[i]:setText(CardRoleManager:getTrainMaxLevel(self.roleGmId,self.cardRole.quality + i - 2))
        self.img_qualityWordArr[i]:setTexture(GetFontSmallByQuality( self.cardRole.quality  + i - 2))
    end

    for i=1,2 do
        self.txt_openTrainArr[i]:setVisible(false);
    end
    local openIndex = 1;
    for i=1,6 do
        local quality = ConstantData:getValue("Pulse.Position" .. i .. ".Quality.open");
        if quality == self.cardRole.quality then
            self.txt_openTrainArr[openIndex]:setText(trainNames[i])
            self.txt_openTrainArr[openIndex]:setVisible(true);
            openIndex = openIndex + 1;
        end
    end

    --新增技能
    local spellInfo = nil;
    if self.cardRole.quality ~= QUALITY_BING then
        if self.cardRole:getIsMainPlayer() then
            for spellInfoConfig in self.cardRole.leadingSpellInfoConfigList:iterator() do
                if spellInfoConfig.enable_quality == self.cardRole.quality then
                    -- if spellInfoConfig.enable_level <= self.cardRole.level then
                        spellInfo = SkillBaseData:objectByID(spellInfoConfig.spell_id);
                        break;
                    -- end
                end
            end
        else
            spellInfo = self.cardRole.spellInfoList:objectAt(self.cardRole.quality - 1);
        end
    end

    if spellInfo then
        self.bg_skill:setVisible(true);
        self.txt_name:setText(spellInfo.name);
        if spellInfo.hidden_skill == 1 then
            --self.txt_skill_type:setText("被动技能");
             self.txt_skill_type:setText(localizable.SkillDetail_reactive_skill)
        else
            self.txt_skill_type:setText(SkillTypeStr[spellInfo.type]);
        end

        self.txt_attack_type:setText(SkillTargetTypeStr[spellInfo.target_type]);
        
        self.img_skill:setTexture(spellInfo:GetPath())
        
        local spellLevelInfo = spellInfo:GetLevelItem(1);
        self.txt_des:setText(spellInfo:getTichTextDes(spellLevelInfo,spellInfo.description))
    else
        self.bg_skill:setVisible(false);
    end

end



function RoleBreakResultLayer:removeUI()
    self.super.removeUI(self)
end

function RoleBreakResultLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close)
end


function RoleBreakResultLayer:removeEvents()
    self.super.removeEvents(self)
end


return RoleBreakResultLayer
