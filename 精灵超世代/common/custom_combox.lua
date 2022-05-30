-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/10/27
-- Time: 16:44
-- 文件功能：通用下拉框
CustomCombox = CustomCombox or BaseClass()
CustomComboxDirection =
{
    TOP = 1,  --上拉
    BOTTOM = 2, --下拉
}

--[[ 下拉框的三个背景图片
-- @param bg_1 下拉框的背景
-- @param bg_2 下拉框的倒三角部分的图片
 - @param bg_3 下拉框下拉部分的背景图片
-- ]]
function CustomCombox:__init(parent, dir, size, bg_1, bg_2, bg_3,bg_4)
   self.parent_wnd = parent
   self.bg_1 = bg_1
   self.bg_2 = bg_2
   self.bg_3 = bg_3
   self.button_bg = bg_4
   self.direction = dir or CustomComboxDirection.BOTTOM
   self.combox_size = size
   self:initView()

   self:registerEvent()
end

function CustomCombox:initView()
    self.root_wnd = ccui.Widget:create()
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.parent_wnd:addChild(self.root_wnd)

    if self.bg_1 and self.bg_2 then
        self:initComBoxView(self.bg_1, self.bg_2, self.bg_3)
    end
end

function CustomCombox:setSkinType(index)
    self.type_index = index
    local bg_1 = PathTool.getResFrame("common","common_1048")
    local bg_2 = PathTool.getResFrame("common","common_arrow2")
    self:initComBoxView(bg_1, bg_2)
end

--[[ 下拉框的三个背景图片
-- @param bg_1 下拉框的背景
-- @param bg_2 下拉框的倒三角部分的图片
 - @param bg_3 下拉框下拉部分的背景图片
-- ]]
function CustomCombox:initComBoxView(bg_1, bg_2)
    self.combox_bg = createScale9Sprite(bg_1, 0, 0)
    self.root_wnd:addChild(self.combox_bg)

    --倒三角部分
    self.combox_right = createScale9Sprite(bg_2, 0, 0)
    self.root_wnd:addChild(self.combox_right)

    self:setContentSize(self.combox_size)
end

function CustomCombox:setBg2Show(bool)
    self.combox_right:setVisible(bool)
end
function CustomCombox:setContentSize(s)
    self.combox_size = s or self.combox_bg:getContentSize()
    self.root_wnd:setContentSize( self.combox_size)
    local size = self.combox_bg:getContentSize()
    self.combox_bg:setContentSize(self.combox_size)
    self.combox_bg:setPosition(cc.p(self.combox_size.width/2, self.combox_size.height/2))
    local temp_size = self.combox_right:getContentSize()
    self.combox_right:setPosition(cc.p(self.combox_size.width - temp_size.width/2, self.combox_size.height/2))
end

--设置字体的类型
function CustomCombox:setFontLabel(fontSize, fontColor_index, fontOutline_index)
    self.font_size = fontSize
    self.font_color = fontColor_index
    self.font_outline = fontOutline_index
end

--[[设置combox的数据
--  必须先调用setFontLabel
-- @param list:选择的数据列表 {[1] = {label = "xxx", index = xx}}
-- @param bg_3 下拉的背景部分
-- @param select_bg 选中的背景
-- ]]
function CustomCombox:setComboxArray(list, bg_3, bg_width,icon_res,type)
   self.combox_list = list
   self.bg_3 = bg_3 or PathTool.getResFrame("common","common_90005")
   self.bg_width = bg_width or self.combox_size.width
   self.menu_list = {}

   if self.combox_layout then
       if self.combox_layout:getParent() then
           self.combox_layout:removeFromParent()
       end
       self.combox_layout = nil
   end

   local max_width = 0
   local space_height = 0

   if self.combox_list then
       for i = 1, #self.combox_list do
           local info = self.combox_list[i]
           local label = createWithSystemFont(info.label, DEFAULT_FONT, self.font_size)
           label:setTextColor(Config.ColorData.data_color4[self.font_color or 1])
           if self.font_outline then
               label:enableOutline(Config.ColorData.data_color4[self.font_outline], 2)
           end
           max_width = math.max(max_width, label:getContentSize().width)
           if space_height == 0 then
               space_height = label:getContentSize().height + 10
           end
           local menu_label = cc.MenuItemLabel:create(label)
           self.menu_list[i] = menu_label
       end

       --加入父节点
       self.combox_layout = ccui.Widget:create()
       self.combox_layout:setAnchorPoint(cc.p(0, 0))
       local m_w = math.max(max_width, self.bg_width)
       -- print("========m_w========",m_w)
       self.combox_layout:setContentSize(cc.size(m_w, space_height*#self.combox_list + 10))
       self.root_wnd:addChild(self.combox_layout)
       if self.direction == CustomComboxDirection.BOTTOM then
           self.combox_layout:setPosition(cc.p(0, -self.combox_layout:getContentSize().height))
       elseif self.direction == CustomComboxDirection.TOP then
           self.combox_right:setScaleY(-1)
           self.combox_layout:setPosition(cc.p(0, self:getContentSize().height))
       end

       local size = self.combox_layout:getContentSize()

       self.combox_bg_3 = createScale9Sprite(self.bg_3, 0, 0)
       self.combox_layout:addChild(self.combox_bg_3)
       self.combox_bg_3:setContentSize(size)
       self.combox_bg_3:setPosition(cc.p(size.width/2, size.height/2))


       if self.select_bg then
           self.combox_select_bg = createScale9Sprite(self.select_bg, 0, 0)
           self.combox_select_bg:setContentSize(cc.size(m_w, space_height))
           self.combox_layout:addChild(self.combox_select_bg)
           self.combox_select_bg:setPosition(cc.p(m_w/2, space_height/2))
       end
       if  self.button_bg then
         for i = 1, #self.menu_list do
           self.buttonBg = createScale9Sprite(self.button_bg, 0, 0)
           self.buttonBg:setContentSize(cc.size(m_w, space_height))
           self.buttonBg:setPosition(cc.p(m_w/2, size.height - space_height/2 - space_height*(i - 1) - 5))
           self.combox_layout:addChild(self.buttonBg)
         end
       end


       local menu = cc.Menu:create()
       menu:setPosition(cc.p(0, 0))
       self.combox_layout:addChild(menu)
       --按钮
       for i = 1, #self.menu_list do
           local btn = self.menu_list[i]
           btn:setPosition(cc.p(m_w/2, size.height - space_height/2 - space_height*(i - 1) - 5))
           menu:addChild(btn)
           btn:setContentSize(cc.size(m_w, space_height))
           local label = btn:getLabel()
           label:setAnchorPoint(cc.p(0.5, 0.5))
           label:setPosition(cc.p(m_w/2-3, space_height/2))
           btn:registerScriptTapHandler(function(tag, sender)
               self:changeIndexHander(i)
           end)
       end
       self:setComboxMenuVisible(false)

       if not self.select_label then
           --显示选择文本
           self.select_label = createWithSystemFont("", DEFAULT_FONT, self.font_size)
           self.select_label:setAnchorPoint(cc.p(0.5, 0.5))
           self.select_label:setTextColor(Config.ColorData.data_color4[self.font_color or 1])
           if self.font_outline then
               self.select_label:enableOutline(Config.ColorData.data_color4[self.font_outline], 2)
           end
           self.root_wnd:addChild(self.select_label)
       end
       self.select_label:setPosition(cc.p(m_w/2-20, self:getContentSize().height/2))

       self.pre_select_index = nil
       self:changeIndexHander(1)

       --前缀资源
       if icon_res then
          local icon_res = icon_res
          local load_type = type or LOADTEXT_TYPE_PLIST
          local icon_sp = createSprite(icon_res, 25, self:getContentSize().height/2, self.root_wnd , cc.p(0.5, 0.5), load_type )
          icon_sp:setScale(0.4)
        end
   end
end

--
function CustomCombox:changeIndexHander(index)
    if self.combox_list[index] then
        local info = self.combox_list[index]
        local label = info.label
        self.select_label:setString(label)
    end
    --选中背景
    if self.menu_list[index] and self.combox_select_bg then
        local size = self.combox_layout:getContentSize()
        local space_height = self.combox_select_bg:getContentSize().height
        local btn = self.menu_list[index]
        self.combox_select_bg:setPositionY(size.height - space_height/2 - space_height*(index - 1) - 5)
    end

    --回调
    if self.pre_select_index ~= index then
        if self.click_call_back then
            self.click_call_back(index)
        end
    end
    self.pre_select_index = index
    self:setComboxMenuVisible(false)
end

function CustomCombox:addCallBack(call_back)
    self.click_call_back = call_back
end

--最好在设置setComboxArray之前设置
function CustomCombox:setSelectedBg(bg)
    self.select_bg = bg
end

function CustomCombox:setComboxMenuVisible(bool)
    if self.combox_layout then
        self.combox_layout:setVisible(bool)
        self.combox_layout:setTouchEnabled(bool)
    end
end

function CustomCombox:isComboxMenuVisible()
    return self.combox_layout:isVisible()
end

function CustomCombox:setComboxBgSize(size)
    if self.combox_bg_3 then
        self.combox_bg_3:setScale9Enabled(true)
        self.combox_bg_3:setContentSize(size)
    end
end

function CustomCombox:registerEvent()
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self:setComboxMenuVisible(not self:isComboxMenuVisible())
        end
    end)
end

function CustomCombox:getContentSize()
   return self.combox_size
end

function CustomCombox:setPosition(x, y)
    self.root_wnd:setPosition(cc.p(x, y))
end

function CustomCombox:setAnchorPoint(x, y)
    self.root_wnd:setAnchorPoint(cc.p(x, y))
end

function CustomCombox:setVisible(bool)
    self.root_wnd:setVisible(bool)
    self.root_wnd:setTouchEnabled(bool)
end

function CustomCombox:setLocalZOrder(order)
    self.root_wnd:setLocalZOrder(order)
end
