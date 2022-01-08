--[[
******角色详情*******
    -- by king
    -- 2015/4/17
]]

local RoleBreakResultLayer = class("RoleBreakResultLayer", BaseLayer)

function RoleBreakResultLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.role.RoleBreakResultLayer")
end

function RoleBreakResultLayer:setPower(oldPower)
    self.oldPower = oldPower
end

function RoleBreakResultLayer:setRole(cardRole)
    self.cardRole   = cardRole

    self.roleGmid   = cardRole.gmId
end


function RoleBreakResultLayer:setOldMartialLevel(oldMartialLevel)
    self.oldMartialLevel = oldMartialLevel
end

function RoleBreakResultLayer:onShow()
    self.super.onShow(self)
      
    self:refreshBaseUI()
    self:refreshUI()
end

function RoleBreakResultLayer:refreshBaseUI()

end

function RoleBreakResultLayer:refreshUI()
    if not self.isShow then
        return
    end
    
    if self.oldPower == nil then
        return
    end
    self.cardRole     = CardRoleManager:getRoleByGmid(self.roleGmid)

    self:drawBeforeArea()
    self:drawNowArea()

    local bIsMainPlayer = self.cardRole:getIsMainPlayer()

    -- 1, 2, 2, 3, 3, 3, 4, 4, 4
    -- 1  2  4
    local openQuality = EnumSkillLock

    local function drawOpenSkill(index)
        local spellInfo = self.cardRole.spellInfoList:objectAt(index)

        print("spellInfo = ", spellInfo)
        if spellInfo then
            self.txt_skillname:setText(spellInfo.name)
        end
    end

    local function drawMainPlayerOpenSkill(index)
        local openLevel = openQuality[index]
        local desc = ""

        for i=1,9 do
            local spellInfo = self.cardRole.leadingSpellInfoConfigList:objectAt(i)

            if spellInfo.enable_quality == openLevel then
                -- print("spellInfo = ", spellInfo)
                local spell = {skillId = spellInfo.spell_id ,level = 1}
                local levelInfo = SkillLevelData:objectByID(spell)
                -- print("levelInfo",levelInfo)
                desc = desc .. levelInfo.name .. "\n"
            end
        end

        self.txt_skillname:setText(desc)
    end

    if self.oldMartialLevel ~= self.cardRole.martialLevel then
        local level1 = openQuality[2] - 1
        local level2 = openQuality[2]
        if self.oldMartialLevel == level1 and self.cardRole.martialLevel == level2 then
            if bIsMainPlayer then
                drawMainPlayerOpenSkill(2)
            else
                drawOpenSkill(2)
            end
            return
        end

        local level1 = openQuality[3] - 1
        local level2 = openQuality[3]
        if self.oldMartialLevel == level1 and self.cardRole.martialLevel == level2 then
            if bIsMainPlayer then
                drawMainPlayerOpenSkill(3)
            else
                drawOpenSkill(3)
            end
            return
        end
    end
end

function RoleBreakResultLayer:initUI(ui)
	self.super.initUI(self,ui)

    -- 关闭按钮
    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close')

    self.panel_card_1   = TFDirector:getChildByPath(ui, 'panel_card_1')
    self.panel_card_2   = TFDirector:getChildByPath(ui, 'panel_card_2')
    self.txt_skillname  = TFDirector:getChildByPath(ui, 'txt_skillname')

    --self.txt_skillname:setText("无")
    self.txt_skillname:setText(localizable.common_no)
end

function RoleBreakResultLayer:registerEvents(ui)
    self.super.registerEvents(self)
    -- 关闭按钮
    self.btn_close.logic    = self;
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle),1)
    self.btn_close:setClickAreaLength(100)

end


function RoleBreakResultLayer:removeEvents()
    self.super.removeEvents(self)
end


function RoleBreakResultLayer.onCloseClickHandle(sender)
    local self = sender.logic

    AlertManager:close(AlertManager.TWEEN_1)
end

function RoleBreakResultLayer:drawHeadBaseElement(head, lv, name, bg)
    head:setTexture(self.cardRole.icon) 
    name:setText(self.cardRole.name)
    lv:setText(self.cardRole.level)

    -- local quality = self.cardRole.quality

    -- bg:setTexture(GetColorIconByQuality(quality))
end

function RoleBreakResultLayer:drawBeforeArea()
    local head          = TFDirector:getChildByPath(self.panel_card_1, 'img_touxiang')
    local bg            = TFDirector:getChildByPath(self.panel_card_1, 'img_pinzhiditu')
    local txt_lv_word   = TFDirector:getChildByPath(self.panel_card_1, 'txt_lv_word')
    local txt_name      = TFDirector:getChildByPath(self.panel_card_1, 'txt_name')
    local txt_desc      = TFDirector:getChildByPath(self, 'txt_jingmai1')
    local txt_power     = TFDirector:getChildByPath(self, 'img_lv1')

    local img_wuxueLevel = TFDirector:getChildByPath(self.panel_card_1, 'img_wuxueLevel')

    self:drawHeadBaseElement(head, txt_lv_word, txt_name, bg)

    -- 
    txt_desc:setText(EnumWuxueDescType[self.oldMartialLevel])
    txt_power:setText(self.oldPower)

    local quality = self.cardRole.quality
    bg:setTexture(GetColorIconByQuality(quality))
    -- bg:setTexture(GetRoleBgByWuXueLevel(self.oldMartialLevel))

    img_wuxueLevel:setTexture(GetFightRoleIconByWuXueLevel(self.oldMartialLevel))
end

function RoleBreakResultLayer:drawNowArea()
    local head          = TFDirector:getChildByPath(self.panel_card_2, 'img_touxiang')
    local bg            = TFDirector:getChildByPath(self.panel_card_2, 'img_pinzhiditu')
    local txt_lv_word   = TFDirector:getChildByPath(self.panel_card_2, 'txt_lv_word')
    local txt_name      = TFDirector:getChildByPath(self.panel_card_2, 'txt_name')
    local txt_desc      = TFDirector:getChildByPath(self, 'txt_jingmai2')
    local txt_power     = TFDirector:getChildByPath(self, 'img_lv2')
    self:drawHeadBaseElement(head, txt_lv_word, txt_name, bg)

    local img_wuxueLevel = TFDirector:getChildByPath(self.panel_card_2, 'img_wuxueLevel')

    -- 
    txt_desc:setText(EnumWuxueDescType[self.cardRole.martialLevel])
    txt_power:setText(self.cardRole.power)

    local quality = self.cardRole.quality
    bg:setTexture(GetColorIconByQuality(quality))
    -- bg:setTexture(GetRoleBgByWuXueLevel(self.cardRole.martialLevel))

    
    img_wuxueLevel:setTexture(GetFightRoleIconByWuXueLevel(self.cardRole.martialLevel))
end


return RoleBreakResultLayer
