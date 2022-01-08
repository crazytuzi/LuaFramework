--[[
******技能详情*******

	-- by haidong.gan
	-- 2013/12/5
]]

local SkillDetailLayer = class("SkillDetailLayer", BaseLayer)


--CREATE_SCENE_FUN(SkillDetailLayer)
CREATE_PANEL_FUN(SkillDetailLayer)

function SkillDetailLayer:ctor()
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.role.SkillDetailLayer")

end

function SkillDetailLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.btn_close          = TFDirector:getChildByPath(ui, 'btn_close')

    self.txt_name             = TFDirector:getChildByPath(ui, 'txt_name');
    self.img_skillkuang       = TFDirector:getChildByPath(ui, 'img_skillkuang');
    self.img_skill            = TFDirector:getChildByPath(ui, 'img_skill');

    self.txt_skill_type       = TFDirector:getChildByPath(ui, 'txt_skill_type');
    self.txt_attack_type      = TFDirector:getChildByPath(ui, 'txt_attack_type');

    self.txt_level    = TFDirector:getChildByPath(ui, 'txt_level');
    self.txt_need     = TFDirector:getChildByPath(ui, 'txt_need');

    self.panel_des1      = TFDirector:getChildByPath(ui, 'panel_des1');
    self.panel_des2      = TFDirector:getChildByPath(ui, 'panel_des2');
    self.panel_des3      = TFDirector:getChildByPath(ui, 'panel_des3');


    local richText_1 = TFRichText:create(self.panel_des1:getSize())
    -- richText_1:setTouchEnabled(true)
    richText_1:setPosition(ccp(0,0))
    richText_1:setAnchorPoint(ccp(0, 0.5))
    self.panel_des1:removeAllChildren()
    self.panel_des1:addChild(richText_1)

    self.txt_des1      = richText_1;


    local richText_2 = TFRichText:create(self.panel_des2:getSize())
    -- richText_2:setTouchEnabled(true)
    richText_2:setPosition(ccp(0,0))
    richText_2:setAnchorPoint(ccp(0, 0.5))
    self.panel_des2:removeAllChildren()
    self.panel_des2:addChild(richText_2)

    self.txt_des2      = richText_2;

    local richText_3 = TFRichText:create(self.panel_des3:getSize())
    -- richText_3:setTouchEnabled(true)
    richText_3:setPosition(ccp(0,0))
    richText_3:setAnchorPoint(ccp(0, 0.5))
    self.panel_des3:removeAllChildren()
    self.panel_des3:addChild(richText_3)

    self.txt_des3      = richText_3;

end

function SkillDetailLayer:loadData(spellInfo,spellLevelInfo)
    self.spellInfo   = spellInfo;
    self.spellLevelInfo  = spellLevelInfo;
    self:refreshUI();
end

function SkillDetailLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function SkillDetailLayer:refreshBaseUI()

end

function SkillDetailLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end
    self.txt_name:setText(self.spellInfo.name);
    self.img_skill:setTexture(self.spellInfo:GetPath());  

    if self.spellInfo.hidden_skill == 1 then
        --self.txt_skill_type:setText("被动技能");
        self.txt_skill_type:setText(localizable.SkillDetail_reactive_skill);
    else
        self.txt_skill_type:setText(SkillTypeStr[self.spellInfo.type]);
    end

    self.txt_attack_type:setText(SkillTargetTypeStr[self.spellInfo.target_type]);

    self.txt_level:setText(self.spellLevelInfo.level);
    --self.txt_need:setText(self.spellInfo.trigger_anger .. "点怒气");
    self.txt_need:setText(stringUtils.format(localizable.SkillDetail_nuqi,self.spellInfo.trigger_anger));
    if self.spellInfo.trigger_anger < 1 then
        --self.txt_need:setText("不消耗怒气");
        self.txt_need:setText(localizable.SkillDetail_not_nuqi);
    end
    -- self.txt_des1:setText(self.spellInfo.description);
    
    self.txt_des1:setText(self.spellInfo:getTichTextDes(self.spellLevelInfo,self.spellInfo.description))
    self.txt_des2:setText(self.spellInfo:getTichTextDes(self.spellLevelInfo,self.spellInfo.power))
    self.txt_des3:setText(self.spellInfo:getTichTextDes(self.spellLevelInfo,self.spellInfo.skill_add))

--     [[<p style="text-align:left margin:5px">
-- <font color="#000000" fontSize = "20">对敌方全体造成</font>
-- <font color="#000000" fontSize = "20">51% </font>
-- <font color="#FF0000" fontSize = "20" fontSize = "20">（+0 %）</font>
-- <font color="#000000" fontSize = "20">的武力，</font>
-- <font color="#000000" fontSize = "20">41% </font>
-- <font color="#FF0000" fontSize = "20">（+0 %）</font>
-- <font color="#000000" fontSize = "20">的内力，</fon
-- t>
-- <font color="#F
-- F0000">140% </font>
-- <font color="#FF0000" fontSize = "20">（+10 %）</font>
-- <font color="#FF0000">的火属性伤害，一定概率使对方烧伤。</font>
-- </p>]]
end

function SkillDetailLayer:removeUI()
	self.super.removeUI(self)
end

function SkillDetailLayer:registerEvents(ui)
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close)
end

function SkillDetailLayer:removeEvents()
	self.super.removeEvents(self)
end

return SkillDetailLayer

