
-- User: cloud
-- Date: 2016.12.29
-- [[文件功能：公共控件单选按钮radioButton]]
RadioButton  = class("RadioButton", function()
    return ccui.Layout:create()
end)

RadioButtonDir =
{
    LEFT = 1,  --文字在左边
    RIGHT = 2, --文字在右边
}
--[[
-- @param parent      加入的父节点
-- @param background  单选按钮的背景
-- @param select_path 选中的状态
-- @param label      描述
-- @param dir        方向
-- @param font_size  文本字号
-- @param font_offset 文本偏移
-- ]]
function RadioButton:ctor(parent, background, select_path, label, font_offset, dir, font_size)
    self.parent_wnd = parent
    self.background_path = background
    self.select_path = select_path
    self.string_label = label
    self.dir = dir or RadioButtonDir.RIGHT
    self.font_size = font_size or 25
    self.font_offset = font_offset or 10
    self:initView()
end

function RadioButton:initView()
    self:setEnabled(true)
    self.parent_wnd:addChild(self)
    self:loadAllTextures(self.background_path, self.select_path, self.string_label, self.dir)
end

--设置全部的属性
function RadioButton:loadAllTextures(background_path, select_path, label, dir)
    self.background_path = background_path or self.background_path
    self.select_path = select_path or self.select_path
    self.string_label = label or self.string_label
    self.dir = dir or self.dir

    self.background = createSprite(self.background_path, 0, 0)
    self.background:setScale(0.8)
    self:addChild(self.background)
    self.select_icon = createSprite(self.select_path, 0, 0)
    self:addChild(self.select_icon)

    self.label = createWithSystemFont(self.string_label, DEFAULT_FONT, self.font_size)
    self.label:setAnchorPoint(cc.p(0, 0.5))
    self:addChild(self.label)
    --位置调整
    self:adjustContentSize()
    --初始化
    self:setSelected(false)
end

function RadioButton:adjustContentSize()
    local size_1 = self.background:getContentSize()
    local size_2 = self.select_icon:getContentSize()
    local size_3 = self.label:getContentSize()
    local _width = math.max(size_1.width, size_2.width) + size_3.width/2 + self.font_offset
    local _height = math.max(size_1.height, size_2.height, size_3.height)
    self:setContentSize(cc.size(_width, _height))

    _width = math.max(size_1.width, size_2.width)
    if self.dir == RadioButtonDir.RIGHT then
        self.background:setPosition(cc.p(_width/2, _height/2))
        self.select_icon:setPosition(cc.p(_width/2, _height/2))
        self.label:setPosition(cc.p(_width + self.font_offset, _height/2))
    else
        self.label:setPosition(cc.p(0, _height/2))
        local temp = self.label:getContentSize().width/2 + self.font_offset + _width/2
        self.background:setPosition(cc.p(temp, _height/2))
        self.select_icon:setPosition(cc.p(temp, _height/2))
    end
end

function RadioButton:setBgScale( ScaleX,ScaleY )
    self.background:setScaleX(ScaleX)
    self.background:setScaleY(ScaleY)
end


function RadioButton:getLabel()
    return self.label
end

function RadioButton:setString(label)
    self.label:setString(label)
    self:adjustContentSize()
end

function RadioButton:setBackground(res)
    loadSpriteTexture(self.background, res, LOADTEXT_TYPE)
    self:adjustContentSize()
end

function RadioButton:setSelectIcon(res)
    loadSpriteTexture(self.select_icon, res, LOADTEXT_TYPE)
    self:adjustContentSize()
end

function RadioButton:setSelected(bool)
    self.select_icon:setVisible(bool)
end

function RadioButton:isSelected()
    return self.select_icon:isVisible()
end

function RadioButton:getSelectIcon()
    return self.select_icon
end
function RadioButton:setFontSize(size)
    self.font_size = size
    if self.label then
        self.label:setSystemFontSize(size)
    end
end


function RadioButton:setTitleColor(color)
    self.font_color4 = color
    if self.label then
        self.label:setTextColor(color)
    end
end

function RadioButton:setTitlePosition(x, y)
    if self.label then
        self.label:setPosition(cc.p(x, y))
    end
end

function RadioButton:setName(name)
    self.name = name
end

function RadioButton:getName()
    return self.name
end

function RadioButton:enableOutline(color, size)
    if self.label then
        self.label:enableOutline(color, size)
    end
end

--设置可点击性
function RadioButton:setEnabled(bool)
    self.isEnabled = bool
    self:setTouchEnabled(bool)
    setChildUnEnabled(not bool, self)
end

function RadioButton:isEnabled()
    return self.isEnabled
end


--设置按钮变灰和不可点击
function RadioButton:setGrayAndUnClick(bool)
    self:setChildUnEnabled(bool, self)
    self:setTouchEnabled(not bool)
    if bool then
        self:getLabel():setTextColor(Config.Color4[3])
    else
        if self.font_color4 then
            self:getLabel():setTextColor(self.font_color4)
        end
    end
end

function RadioButton:setChildUnEnabled(bool, parent)
    setChildUnEnabled(bool, parent)
end