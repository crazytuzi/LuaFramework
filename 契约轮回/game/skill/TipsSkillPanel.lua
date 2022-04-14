-- @Author: lwj
-- @Date:   2018-10-23 14:42:52
-- @Last Modified time: 2018-10-25 15:09:39
TipsSkillPanel = TipsSkillPanel or class("TipsSkillPanel", BasePanel)
local TipsSkillPanel = TipsSkillPanel

function TipsSkillPanel:ctor(layer)
    self.abName = "skill"
    self.assetName = "TipsSkillPanel"
    self.layer = layer or "UI"

    self.normal_height = 256
    self.un_activate_height = 256.54
    self.use_background = true
    self.click_bg_close = true
end

function TipsSkillPanel:dctor()

end

function TipsSkillPanel:Open()
    TipsSkillPanel.super.Open(self)
end

function TipsSkillPanel:LoadCallBack()
    self.nodes = {
        "icon",
        "name",
        "type",
        "des",
        "cdText",
        "cdText/cd",
        "way", "extra_line", "bg",
    }
    self:GetChildren(self.nodes)
    self.icon_Img = self.icon:GetComponent('Image')
    self.name_Text = self.name:GetComponent('Text')
    self.type_Text = self.type:GetComponent('Text')
    self.des_Text = self.des:GetComponent('Text')
    self.way = GetText(self.way)

    self.viewRectTra = self.transform:GetComponent('RectTransform')
    self.bg_rect = GetRectTransform(self.bg)

    self:AddEvent()
    self:InitPanel()
    self:SetViewPosition()
    if self.isSetMax then
        self:SetOrderByParentMax();
    end
end

function TipsSkillPanel:AddEvent()
end

function TipsSkillPanel:InitPanel()
    if self.id then
        lua_resMgr:SetImageTexture(self, self.icon_Img, "iconasset/icon_skill", tostring(Config.db_skill[self.id].icon), true, nil, false)
        self.name_Text.text = Config.db_skill[self.id].name
        self.des_Text.text = Config.db_skill[self.id].desc
        local type = Config.db_skill[self.id].type
        if type == 1 then
            SetVisible(self.type, false)
            SetVisible(self.cdText, true)
            local combineId = self.id .. "@1"
            local time = Config.db_skill_level[combineId].cd
            self.cd:GetComponent('Text').text = tonumber(time) / 1000
        else
            SetVisible(self.type, true)
            SetVisible(self.cdText, false)
            self.type_Text.text = Config.db_skill[self.id].type_show
        end
        self:UpdateWayShow()
        --取得所点击的技能的Rect Transform
        self.parentRectTra = self.parent_node:GetComponent('RectTransform')
        SetSizeDelta(self.background_transform, 3000, 3000)
    end
end

function TipsSkillPanel:UpdateWayShow()
    local is_got = SkillUIModel.GetInstance():IsGetSkill(self.id)
    local height = is_got and self.normal_height or self.un_activate_height
    SetSizeDelta(self.bg_rect, self.bg_rect.sizeDelta.x, height)
    SetVisible(self.extra_line, not is_got)
    SetVisible(self.way, not is_got)
    local des = is_got and "" or Config.db_skill[self.id].cond_tips
    self.way.text = string.format("<color=#eb0000>%s</color>", des)

end


--按钮点击时 传过来  技能id与 需要比较的物体
function TipsSkillPanel:SetId(id, parentNode, pos, setmaxlayer)
    self.id = id
    self.parent_node = parentNode
    self.default_pos = pos;
    self.isSetMax = setmaxlayer;
end

function TipsSkillPanel:SetViewPosition()
    local parentWidth = 0
    local parentHeight = 0
    local spanX = 0
    local spanY = 0
    if self.parentRectTra.anchorMin.x == 0.5 then
        spanX = 10
        parentWidth = self.parentRectTra.sizeDelta.x / 2
        parentHeight = self.parentRectTra.sizeDelta.y / 2
    else
        parentWidth = self.parentRectTra.sizeDelta.x
        parentHeight = self.parentRectTra.sizeDelta.y
    end

    --local parentRectTra = self.parent_node:GetComponent('RectTransform')
    local pos = self.parent_node.position
    local x = ScreenWidth / 2 + pos.x * 100 + parentWidth
    local y = pos.y * 100 - ScreenHeight / 2 - parentHeight
    local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    self.transform:SetParent(UITransform)
    SetLocalScale(self.transform, 1, 1, 1)

    --判断是否超出右边界
    if ScreenWidth - (x + parentWidth + self.viewRectTra.sizeDelta.x) < 10 then
        --spanX = ScreenWidth - (x + self.viewRectTra.sizeDelta.x + self.btnWidth)
        if self.parentRectTra.anchorMin.x == 0.5 then
            x = x - self.viewRectTra.sizeDelta.x - parentWidth * 2 - 20
        else
            x = x - self.viewRectTra.sizeDelta.x - parentWidth
        end

    end

    if ScreenHeight + y - self.viewRectTra.sizeDelta.y < 10 then
        spanY = ScreenHeight + y - self.viewRectTra.sizeDelta.y - 10
    end

    self.viewRectTra.anchoredPosition = Vector2(x + spanX, y - spanY)
end
