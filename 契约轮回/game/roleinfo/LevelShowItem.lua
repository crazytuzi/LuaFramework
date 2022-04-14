-- @Author: lwj
-- @Date:   2019-08-09 16:15:46
-- @Last Modified time: 2019-08-09 16:15:53

LevelShowItem = LevelShowItem or class("LevelShowItem", BaseItem)
local LevelShowItem = LevelShowItem

function LevelShowItem:ctor(parent_node, layer)
    self.abName = "roleinfo"
    self.assetName = "LevelShowItem"
    self.layer = layer or "UI"
    self.is_need_init = false

    self.text_scale = 0.84
    BaseItem.Load(self)
end

function LevelShowItem:dctor()

end

function LevelShowItem:LoadCallBack()
    self.nodes = {
        "con/icon", "con/lv",
    }
    self:GetChildren(self.nodes)
    self.icon_rect = GetRectTransform(self.icon)
    self.lv = GetText(self.lv)
    self.outline = GetOutLine(self.lv)

    self:AddEvent()
    if self.is_need_init then
        self:InitPanel()
    end
end

function LevelShowItem:AddEvent()
end

--[[
    font_size:          字体大小，默认22
    lv:                 显示等级，默认自身等级

    color:              字体颜色(颜色代码)
    outline_color:      传入之后，显示描边

    format_str:         显示格式
    ...:                不定参代表填format的坑的参数
--]]
function LevelShowItem:SetData(font_size, lv, color, outline_color, format_str, ...)
    self.level_will_show = lv
    self.font_size = font_size or 22
    self.color = color
    self.outline_color = outline_color
    self.format_str = format_str
    self.format_param = { ... }

    if (self.is_loaded) then
        self:InitPanel()
    else
        self.is_need_init = true
    end
end

function LevelShowItem:InitPanel()
    if self.font_size then
        self.lv.fontSize = self.font_size
    end
    local height = self.lv.preferredHeight
    local icon_width = height / self.text_scale
    SetSizeDelta(self.icon_rect, icon_width, icon_width)
    self:UpdateLevel()
    SetLocalScale(self.transform, 1, 1, 1)
    SetLocalPosition(self.transform, 0, 0, 0)
    SetLocalRotation(self.transform, 0, 0, 0)
end

function LevelShowItem:UpdateLevel(lv)
    if not self.is_loaded then
        return
    end
    if lv then
        self.level_will_show = lv
    end
    local show_level = self.level_will_show or RoleInfoModel.GetInstance():GetMainRoleLevel()
    local remain = show_level
    local critical = String2Table(Config.db_game.level_max.val)[1]
    local is_show_icon = false
    if show_level > critical then
        remain = show_level - critical
        is_show_icon = true
    else
        if (not self.format_str) then
            remain = "Lv."..remain
        end
    end
    if self.format_str then
        remain = string.format(self.format_str, remain, #self.format_param > 0 and unpack(self.format_param))
    end

    SetVisible(self.icon, is_show_icon)
    SetVisible(self.lv, true)
    if self.color then
        local txt = remain
        txt = "<color=#" .. self.color .. ">" .. txt .. "</color>"
        self.lv.text = txt
    end
    if self.outline_color then
        self.outline.enabled = true
        --self.outline.color=
        SetOutLineColor(self.outline, HtmlColorStringToColor(self.outline_color))
    end
end