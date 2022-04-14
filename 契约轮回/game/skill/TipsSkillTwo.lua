-- @Author: lwj
-- @Date:   2019-01-14 10:38:30
-- @Last Modified time: 2019-01-14 10:38:33

TipsSkillTwo = TipsSkillTwo or class("TipsSkillTwo", TipsSkillPanel)
local TipsSkillTwo = TipsSkillTwo

function TipsSkillTwo:ctor()
    self.abName = "skill"
    self.assetName = "TipsSkillTwo"
    self.layer = "UI"
    --
    --self.use_background=true
    --self.click_bg_close=true
    --self.btnWidth=200
end

function TipsSkillTwo:dctor()

end

function TipsSkillTwo:Open()
    TipsSkillTwo.super.Open(self)
end

function TipsSkillTwo:LoadCallBack()
    self.nodes = {
        "condition", "icon", "desNext", "name", "type", "desCur", "titleCur", "titleNext",
    }
    self:GetChildren(self.nodes)
    self.condition = GetText(self.condition)
    self.name = GetText(self.name)
    self.desNext = GetText(self.desNext)
    self.type = GetText(self.type)
    self.desCur = GetText(self.desCur)
    self.titleCur = GetText(self.titleCur)
    self.titleNext = GetText(self.titleNext)
    self.icon = GetImage(self.icon)
    self.viewRectTra = self.transform:GetComponent('RectTransform')

    self:AddEvent()
    self:InitPanel()
    self:SetViewPosition()
end

function TipsSkillTwo:InitPanel()
    local maxLv = 1
    local maxSkillTbl = {}
    local nextLv = 1
    local nextSkillTbl = {}
    local curSkillTbl = {}
    if self.data.isActivate then
        --已激活
        self.titleCur.text = ConfigLanguage.Skill.CurrentSkillTitle
        --满级套装等级为当前id的max_lv
        maxLv = Config.db_magic_card_suite[self.data.cur_suit_lv].max_lv
        maxSkillTbl = String2Table(Config.db_magic_card_suite[maxLv].skill_id)
        if self.data.cur_suit_lv == maxLv then
            --当前已满级
            nextLv = maxLv
            nextSkillTbl = maxSkillTbl
            curSkillTbl = maxSkillTbl
            self.condition.text = ConfigLanguage.Skill.AlreadyMaxLevel
        else
            --未满级
            nextLv = self.data.cur_suit_lv + 1
            nextSkillTbl = String2Table(Config.db_magic_card_suite[nextLv].skill_id)
            curSkillTbl = String2Table(Config.db_magic_card_suite[nextLv - 1].skill_id)
            self.condition.text = ConfigLanguage.Skill.TipsConditionHead .. Config.db_magic_card_suite[nextLv].desc
        end
    else
        --未激活
        nextLv = 1
        maxLv = Config.db_magic_card_suite[nextLv].max_lv
        self.titleCur.text = ConfigLanguage.Skill.MaxLevelTitle
        curSkillTbl = String2Table(Config.db_magic_card_suite[maxLv].skill_id)
        nextSkillTbl = String2Table(Config.db_magic_card_suite[nextLv].skill_id)
        self.condition.text = ConfigLanguage.Skill.TipsConditionHead .. Config.db_magic_card_suite[nextLv].desc
    end
    local curSkill_id = curSkillTbl[1]
    lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_skill", tostring(curSkill_id), true, nil, false)
    self.name.text = Config.db_skill[curSkill_id].name
    self.type.text = ConfigLanguage.Skill.TipsSkillType .. Config.db_skill[curSkill_id].type_show
    self.titleNext.text = ConfigLanguage.Skill.NextLevelTitle
    self.desCur.text = Config.db_skill_level[curSkill_id .. "@" .. curSkillTbl[2]].dec
    self.desNext.text = Config.db_skill_level[nextSkillTbl[1] .. "@" .. nextSkillTbl[2]].dec
    self.parentRectTra = self.parent_node:GetComponent('RectTransform')
    SetSizeDelta(self.background_transform, 3000, 3000)
end


--[[
    data数据中所包含的：
        cur_suit_lv:    当前套装等级
        isActivate:     是否激活
        parentNode:     所点击技能图标的transform
]]--
function TipsSkillTwo:SetData(data)
    self.data = data
    self.parent_node = data.parentNode
end