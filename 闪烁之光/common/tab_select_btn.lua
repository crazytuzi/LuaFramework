-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/8/12
-- Time: 9:57
-- 文件功能：用于有选中状态的按钮，并且选中状态只是加上一个选中页面的

TabSelectBtn = TabSelectBtn or BaseClass()
--[[
-- @param parent 加入的父节点
-- @param unselect_path 非选中的状态
-- @param select_path 选中的状态
-- @param icon_path 标签页中专门显示的提示小点路径
-- @param call_back 点击回调
-- ]]
function TabSelectBtn:__init(parent, select_path, unselect_path, icon_path, arrow_path, call_back, font_size, size, locatzorder, scale,is_plist, extend_name)
    self.select_status = false  -- 选中的状态
    self.parent_wnd = parent
    self.locatzorder = locatzorder
    self.unselect_path = unselect_path
    self.select_path = select_path
    self.arrow_path = arrow_path
    self.icon_path = icon_path
    self.call_back = call_back
    self.font_size = font_size or 24
    self.size = size
    self.extend_name = extend_name or "default"
    self.load_type = LOADTEXT_TYPE_PLIST
    self:setLoadType(is_plist)
    if scale == nil then
        self.scale = true
    else
        self.scale = scale 
    end
    self.offX = 0
    self.offY = 0
    self:initView()
    self:registerEvent()
end

function TabSelectBtn:initView()
    self.item_layout = ccui.Widget:create()
    self.item_layout:setCascadeOpacityEnabled(true)
    self.item_layout:setAnchorPoint(cc.p(0, 0))
    self.parent_wnd:addChild(self.item_layout, self.locatzorder)
    self.item_layout:setTouchEnabled(true)
    self.item_layout:setName(self.extend_name)
    self:createSelectItem()
    --文本显示
end

function TabSelectBtn:registerEvent()
    self.item_layout:setTouchEnabled(true)
    self.item_layout:addTouchEventListener(function(sender, event_type)
        if self.scale == true then
            customClickAction(sender, event_type)
        end
        if event_type == ccui.TouchEventType.began then
        elseif event_type == ccui.TouchEventType.ended or event_type == ccui.TouchEventType.canceled then
        end
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.call_back ~= nil then
                self:call_back(sender, event_type)
            end
        end
    end)
end

function TabSelectBtn:createSelectItem(select_path, unselect_path)
    if unselect_path and select_path then
        self.unselect_path = unselect_path
        self.select_path = select_path
    end

    if self.select_icon == nil then
        self.select_icon = ccui.ImageView:create(self.select_path, self.load_type)
        self.select_icon:setAnchorPoint(cc.p(0, 0))
        self.item_layout:addChild(self.select_icon, 1)
        self.select_icon:setVisible(false)
    else
        self.select_icon:loadTexture(self.select_path, self.load_type)
    end
    if self.size then
        self.select_icon:setScale9Enabled(true)
        self.select_icon:setContentSize(self.size)
    end
    if self.arrow_path and string.len(self.arrow_path) > 0 then
        if self.arrow_icon == nil then
            self.arrow_icon = createSprite(self.arrow_path, self.select_icon:getContentSize().width * 0.5, -7, self.select_icon, cc.p(0.5, 0), self.load_type)
        else
            loadSpriteTexture(self.arrow_icon, self.arrow_path, self.load_type)
        end
    end

    if self.unselect_path and string.len(self.unselect_path) > 0 then
        if self.unselect_icon == nil then
            self.unselect_icon = ccui.ImageView:create(self.unselect_path, self.load_type)
            self.unselect_icon:setAnchorPoint(cc.p(0, 0))
            self.item_layout:addChild(self.unselect_icon, 0)
        else
            self.unselect_icon:loadTexture(self.unselect_path, self.load_type)
        end
        if self.size then
            self.unselect_icon:setScale9Enabled(true)
            self.unselect_icon:setContentSize(self.size)
        end
    end

    local size = self:getContentSize()
    if size ~= nil then
        self.item_layout:setContentSize(size)
    end
end

function TabSelectBtn:setLoadType(is_plist)
    if is_plist == false then 
         self.load_type = LOADTEXT_TYPE
    else 
        self.load_type = LOADTEXT_TYPE_PLIST
    end
end
function TabSelectBtn:createSelectIcon( select_icon_path, unselect_icon_path )
    local size = self:getContentSize()
    if select_icon_path and unselect_icon_path then
        self.unselect_icon_path = unselect_icon_path
        self.select_icon_path = select_icon_path
    end

    if self.select_icon_path ~= nil and self.select_icon_path ~= "" then
        if self.select_item_icon == nil then
            self.select_item_icon = ccui.ImageView:create(self.select_icon_path, self.load_type)
            self.select_item_icon:setPosition(size.width/2-10, size.height/2)
            self.item_layout:addChild(self.select_item_icon, 3)
            self.select_item_icon:setVisible(false)
        else
            self.select_icon:loadTexture(self.select_icon_path, self.load_type)
        end
    end

    if self.unselect_icon_path ~= nil and self.unselect_icon_path ~= "" then
        if self.unselect_item_icon == nil then
            self.unselect_item_icon = ccui.ImageView:create(self.unselect_icon_path, self.load_type)
            self.unselect_item_icon:setPosition(size.width/2-10, size.height/2)
            self.item_layout:addChild(self.unselect_item_icon, 3)
            self.unselect_item_icon:setVisible(true)
        else
            self.unselect_item_icon:loadTexture(self.unselect_icon_path, self.load_type)
        end
    end
end

function TabSelectBtn:createTxtIcon(icon_path)
    local size = self:getContentSize()
    self.btn_txt_icon = createSprite(icon_path, size.width/2, size.height/2)
    self.item_layout:addChild(self.btn_txt_icon, 4)
end


function TabSelectBtn:setSelected(bool)
    self.select_status = bool
    self.select_icon:setVisible(self.select_status)
    self.unselect_icon:setVisible(not self.select_status)

    if self.select_item_icon then
        self.select_item_icon:setVisible(self.select_status)
    end
    if self.unselect_item_icon then
        self.unselect_item_icon:setVisible(not self.select_status)
    end
end
function TabSelectBtn:setIconScale(scaleX,scaleY)
    scaleX =scaleX or 1
    scaleY = scaleY or 1
    if self.select_icon then
        self.select_icon:setScaleX(scaleX)
        self.select_icon:setScaleY(scaleY)
    end
    if self.unselect_icon then
        self.unselect_icon:setScaleX(scaleX)
        self.unselect_icon:setScaleY(scaleY)
    end
end

function TabSelectBtn:isSelected()
    return self.select_status
end

--显示类似红点提示
function TabSelectBtn:showCirclePoint(bool)
    if self.icon_path and string.len(self.icon_path) > 0 then
        if bool then
            if not self.circle_icon then
                self.circle_icon = ccui.ImageView:create(self.icon_path, LOADTEXT_TYPE_PLIST)
                self.item_layout:addChild(self.circle_icon, 10)
            else
                self.circle_icon:loadTexture(self.icon_path, LOADTEXT_TYPE_PLIST)
            end
            self.circle_icon:setVisible(bool)
            local size = self.circle_icon:getContentSize()
            self.circle_icon:setPosition(cc.p(self:getContentSize().width - size.width/2 + 5+self.offX, self:getContentSize().height - size.height/2 + 5+self.offY))
        else
            if self.circle_icon then
                self.circle_icon:setVisible(bool)
                local size = self.circle_icon:getContentSize()
                self.circle_icon:setPosition(cc.p(self:getContentSize().width - size.width/2 + 5+self.offX, self:getContentSize().height - size.height/2 + 5+self.offY))
            end
        end
    else
        print("tishi icon_path is nil!!!")
    end
end
--设置红点的位置
function TabSelectBtn:setCirclePointOffset(x, y)
    self.offX = x
    self.offY = y
end
--显示活动图标
function TabSelectBtn:showActivityIcon(res)
    if res then
        if not self.activityIcon then
            self.activityIcon = ccui.ImageView:create(res, LOADTEXT_TYPE_PLIST)
            local size = self.activityIcon:getContentSize()
            self.activityIcon:setPosition(cc.p(self:getContentSize().width - size.width/2 + 5, self:getContentSize().height - size.height/2 + 5))
            self.item_layout:addChild(self.activityIcon, 10)
        else
            self.activityIcon:loadTexture(res, LOADTEXT_TYPE_PLIST)
        end
        self.activityIcon:setVisible(true)
    else
        if self.activityIcon then
            self.activityIcon:setVisible(false)
        end
    end
end

--显示数字
function TabSelectBtn:showCircleLabel(num)
    if num > 0 then --数字显示大于0
        self:showCirclePoint(true)
        if not self.circle_num then
            self.circle_num = createLabel(20, Config.ColorData.data_color4[1])
            self.circle_num:setAnchorPoint(cc.p(0.5, 0.5))
            self.item_layout:addChild(self.circle_num, 20)
            self.circle_num:setPosition(cc.p(self.circle_icon:getPositionX()-1, self.circle_icon:getPositionY()+2))
        end
        self.circle_num:setString(num)
    else
        self:showCirclePoint(false)
        if self.circle_num then
            self.circle_num:setString("")
        end
    end
end
function TabSelectBtn:setVisible(bool)
    if self.item_layout then
        self.item_layout:setVisible(bool)
    end
end

function TabSelectBtn:getContentSize()
    if self.unselect_icon then
        return self.unselect_icon:getContentSize()
    end
    if self.select_icon then
        return self.select_icon:getContentSize()
    end
end

function TabSelectBtn:enableOutline(color, size)
    if self.label then
        self.label:enableOutline(color, size)
    end
end

function TabSelectBtn:setLocalZOrder(order)
    self.item_layout:setLocalZOrder(order)
end

function TabSelectBtn:setAnchorPoint(x, y)
    self.item_layout:setAnchorPoint(cc.p(x, y))
end

function TabSelectBtn:addToParent(parent)
    self.parent_wnd = parent
    if not tolua.isnull(self.item_layout) and self.item_layout:getParent() then
        self.item_layout:removeFromParent()
    end
    self.parent_wnd:addChild(self.item_layout)
end

function TabSelectBtn:setPosition(x, y)
    self.item_layout:setPosition(cc.p(x, y))
end

function TabSelectBtn:setCallBack(call_back)
    self.call_back = call_back
end

function TabSelectBtn:getLabel()
    return self.label
end
function TabSelectBtn:getPositionX()
    return self.item_layout:getPositionX()
end
function TabSelectBtn:getPositionY()
    return self.item_layout:getPositionY()
end

function TabSelectBtn:setSelectTabPos(x, y)
    if self.select_icon then
       self.select_icon:setPosition(cc.p(x, y))
    end
end

function TabSelectBtn:setSelectTabAnchorPos(x, y)
    if self.select_icon then
        self.select_icon:setAnchorPoint(cc.p(x, y))
    end
end

function TabSelectBtn:setTitleOffset(offset_x, offet_y)
    local size = self:getContentSize()
    if size and self.label then
        self.label:setPosition(cc.p(size.width/2+offset_x, size.height/2+offet_y))
    end
end

--文字图片的偏移量
function TabSelectBtn:setTxtIconOffset(offsetX, offsety)
    if self.btn_txt_icon then
        local size = self:getContentSize()
        self.btn_txt_icon:setPosition(cc.p(size.width/2 + offsetX, size.height/2 + offsety))
    end
end

function TabSelectBtn:setFontSize(size)
    self.font_size = size
end

function TabSelectBtn:setString(label)
    if self.label == nil then
        self.label = createLabel(self.font_size,nil,nil,self:getContentSize().width/2,self:getContentSize().height/2,
            nil,self.item_layout,nil, cc.p(0.5, 0.5),"fonts/title.ttf")
        self.label:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    else
       if self.label:isVisible() == false then
           self.label:setVisible(true)
       end
    end
    self.label:setLocalZOrder(10)
    self.label:setString(label)
end

function TabSelectBtn:setTitleColor(color)
    if self.label then
        self.label:setTextColor(color)
    end
end

function TabSelectBtn:setTitlePosition(x, y)
    if self.label then
        self.label:setPosition(cc.p(x, y))
    end
end

function TabSelectBtn:setBtnContenSize(size)
  if size then
    self.select_icon:setScale9Enabled(true)
    self.select_icon:setContentSize(size)
    self.unselect_icon:setScale9Enabled(true)
    self.unselect_icon:setContentSize(size)
    self.label:setPosition(size.width/2,size.height/2)
  end
end

function TabSelectBtn:setName(name)
    self.name = name
end

function TabSelectBtn:getName()
    return self.name
end
-- function TabSelectBtn:setBgRotation(rotation)
--     rotation = rotation or 0
--     if self.select_icon then 
--         self.select_icon:setRotation(rotation)
--     end
--     if self.unselect_icon then 
--         self.unselect_icon:setRotation(rotation)
--     end
-- end
function TabSelectBtn:getRoot()
    return self.item_layout
end

function TabSelectBtn:__delete()
    self.item_layout:removeAllChildren()
    self.label = nil
    self.call_back = nil
    self.unselect_icon = nil
    self.select_icon = nil
    self.btn_txt_icon = nil
    self.item_layout = nil
    self.parent_wnd = nil
end
