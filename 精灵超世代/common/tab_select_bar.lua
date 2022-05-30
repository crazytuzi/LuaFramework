-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/8/12
-- Time: 10:28
-- 文件功能：标签页的控件,用于选中页只是增加一个选中标签的，和tab_select_btn配合使用
TabSelectBar = TabSelectBar or BaseClass()
TabSelectBarDirection =
{
    vertical = 1,  --竖直方向
    horizontal = 2, -- 水平方向
}

--[[
-- @param parent 标签页加入的父节点  (必要)
-- @param direction 标签页面的扩展的方向  (必要)
-  @param offset 每个标签页面之间的偏移量 （可选有默认值）
   @param tab_array 标签页的数据 （可选有方法setTabArray可以设置）
   @param call_back 每个标签页发生变化的时候会触发的回调函数
  --todo（可选有方法setChangeItemByIndex可以设置。但是在设置顺序中一般要求先于tab_array这个设置
    todo 因为在设置tab_array这个的时候有默认第一个为选中项，那个时候会调用回调方法）
-- ]]
function TabSelectBar:__init(parent, direction, offset, tab_array, call_back, scale, label_offset_x, label_offset_y, btn_need_scale,is_plist,last_btn_scale,is_need_first_select)
    self.parent_wnd = parent
    self.direction = direction
    self.space_offset = offset or 10 -- 按钮之间的偏移量
    self.per_select_index = nil --上一个选中的btn按钮的index
    self.scale = scale or 1
    self.label_offset_x = label_offset_x or 0
    self.label_offset_y = label_offset_y or 0
    self.is_plist = is_plist
    self.changeItemByIndex = call_back
    self.last_btn_scale = last_btn_scale or false
    if btn_need_scale == nil then
        self.btn_need_scale = true
    else
        self.btn_need_scale = btn_need_scale
    end
    self.is_need_first_select = is_need_first_select or true
    self:initView(tab_array)
    self:registerEvent()
end

function TabSelectBar:initView(tab_array)
    self.tab_bar = ccui.Widget:create()
    self.tab_bar:setCascadeOpacityEnabled(true)
    self.tab_bar:setAnchorPoint(cc.p(0, 0))
    self.parent_wnd:addChild(self.tab_bar)
    self:setTabArray(tab_array)
    self.tab_bar:setScale(self.scale)
end

function TabSelectBar:registerEvent()

end

--[[ 设置标签页的标签数据tab_array里面的数据有{{}，{}，{}}
-- @param select_path 选中的标签页路径(必填)
-- @param unselect_path 非选中的标签页路径(必填)
--todo 其他的为可选项
-- @param width 单标签页按钮的宽
 - @param height 单标签页按钮的高
   @param label 标签页上面的label
   @param select_color 选中标签的文本的颜色
   @param select_outline 选中标签的文本的描边颜色
   @param unselect_color 非选中标签的文本颜色
   @param unselect_outline 选中标签的文本的描边颜色
   @param select_label 选中状态的文本要求
   @param name 该标签按钮的name
   @param icon_path 标签页中专门显示的提示小点路径
   @param select_icon 选中的出现的图片
   @param unselect_icon 非选择出现图片
   @param txt_icon 出现的文字图片
-- ]]
function TabSelectBar:setTabArray(tab_array)
    self.tab_array = tab_array
    self.btn_list = {} -- 保存按钮的列表
    self.per_select_index = nil
    self.tab_bar:removeAllChildren()

    --按钮的回调函数
    local btn_click = function(index)
        self:setSelectByIndex(index) -- 内部自己使用改变状态的
    end

    local content_width = 0
    local content_height = 0
    local temp_tab
    if self.tab_array and #self.tab_array > 0 then
        for i = 1, #self.tab_array do  --设置基本的数据
            temp_tab = self.tab_array[i] or {}
            --大小
            local item_size
            if temp_tab["width"] and temp_tab["height"] then
                item_size = cc.size(temp_tab["width"], temp_tab["height"])
            end
            local btn = TabSelectBtn.New(
                self.tab_bar,
                temp_tab["select_path"],
                temp_tab["unselect_path"],
                temp_tab["icon_path"],
                temp_tab["arrow_path"],
                function()
                end,
                self.font_size,
                item_size,
                #tab_array - i,
                self.btn_need_scale,
                self.is_plist,
                temp_tab["extend_name"]
            )

            btn:setCallBack(function()
                btn_click(i)
            end)
            btn:setAnchorPoint(1, 0.5)
            btn:setString(temp_tab["label"] or "")
            btn:setTitleOffset(self.label_offset_x, self.label_offset_y)
            btn:setTitleColor(temp_tab["unselect_color"] or Config.ColorData.data_color4[1])
            if i == #self.tab_array and self.last_btn_scale == true then
                btn:setAnchorPoint(0, 0.5)
                btn:getRoot():setScaleX(-1)
            end
            local name = temp_tab["name"] or i
            btn:setName(name)
            self.btn_list[i] = btn
            if TabSelectBarDirection.vertical == self.direction then --竖直
                content_height = content_height + ((temp_tab["height"] or btn:getContentSize().height) + self.space_offset)
                content_width = math.max(content_width, (temp_tab["width"] or (btn:getContentSize().width)))
            elseif TabSelectBarDirection.horizontal == self.direction then --水平
                content_width = content_width + ((temp_tab["width"] or btn:getContentSize().width) + self.space_offset)
                content_height = math.max(content_height, (temp_tab["height"] or (btn:getContentSize().height)))
            end

            self.btn_list[i]:createSelectIcon(temp_tab["select_icon"], temp_tab["unselect_icon"])
            
            if temp_tab["txt_icon"] and btn["createTxtIcon"] then
                btn:createTxtIcon(temp_tab["txt_icon"])
            end
        end
        self.tab_bar:setContentSize(cc.size(content_width, content_height))

        --设置每个按钮的位置
        local temp_width = 0
        for j = 1, #self.tab_array do
            local btn = self.btn_list[j]
            temp_tab = self.tab_array[j] or {}
            if TabSelectBarDirection.vertical == self.direction then --竖直
                content_height = content_height - ((temp_tab["height"] or btn:getContentSize().height) + self.space_offset)
                btn:setPosition((temp_tab["width"] or btn:getContentSize().width)/2, content_height+(temp_tab["height"] or btn:getContentSize().height)/2)
            elseif TabSelectBarDirection.horizontal == self.direction then --水平
                -- temp_tab = self.tab_array[j - 1]
                if temp_tab then
                    temp_width = temp_width + ((temp_tab["width"] or btn:getContentSize().width) + self.space_offset)
                end
                btn:setPosition(temp_width, (temp_tab["height"] or btn:getContentSize().height)/2)
            end
        end
        if self.is_need_first_select == true then
            self:setSelectByIndex(1)
        end
    end
end

-- 设置隐藏按钮
function TabSelectBar:setTabButtonVisible( btnIdxList, bool )
    --设置每个按钮的位置
    local content_height = self.tab_bar:getContentSize().height
    local temp_tab
    local temp_width = 0
    local function isOnList( idx )
        if btnIdxList == nil or #btnIdxList == 0 then return false end
        for _,v in ipairs(btnIdxList) do
            if v == idx then
                return true
            end
        end
        return false
    end
    for j = 1, #self.tab_array do
        local btn = self.btn_list[j]
        if isOnList( j ) and bool == false then
            btn:setVisible(false)
        else
            btn:setVisible(true)
            temp_tab = self.tab_array[j] or {}
            if TabSelectBarDirection.vertical == self.direction then --竖直
                content_height = content_height - ((temp_tab["height"] or btn:getContentSize().height) + self.space_offset)
                btn:setPosition((temp_tab["width"] or btn:getContentSize().width)/2, content_height+(temp_tab["height"] or btn:getContentSize().height)/2)
                -- btn:setPosition(0, content_height)
            elseif TabSelectBarDirection.horizontal == self.direction then --水平
                -- temp_tab = self.tab_array[j - 1]
                if temp_tab then
                    temp_width = temp_width + ((temp_tab["width"] or btn:getContentSize().width) + self.space_offset)
                end
                btn:setPosition(temp_width, (temp_tab["height"] or btn:getContentSize().height)/2)
                -- btn:setPosition(temp_width, 0)
            end
        end
    end
end

-- 设置设置显示状态按钮 (以一个{{1,true},{2,false},...}) 格式处理
function TabSelectBar:setTabVisibleState( btnIdxList )
    --设置每个按钮的位置
    local content_height = self.tab_bar:getContentSize().height
    local temp_tab
    local temp_width = 0
    local function isOnList( idx )
        if btnIdxList == nil or #btnIdxList == 0 then return nil end
        for _,v in ipairs(btnIdxList) do
            if v[1] == idx then
                return v
            end
        end
        return nil
    end
    for j = 1, #self.tab_array do
        local btn = self.btn_list[j]
        local stateVo = isOnList(j)
        if stateVo then
            if stateVo[2]  == true then
              if stateVo[3] == true  then
                temp_tab = self.tab_array[j] or {}
                if TabSelectBarDirection.vertical == self.direction then --竖直
                    content_height = content_height - ((temp_tab["height"] or btn:getContentSize().height) + self.space_offset)
                    btn:setPosition(0, content_height)
                elseif TabSelectBarDirection.horizontal == self.direction then --水平
                    temp_tab = self.tab_array[j - 1]
                    if temp_tab then
                        temp_width = temp_width + ((temp_tab["width"] or btn:getContentSize().width) + self.space_offset)
                    end
                    btn:setPosition(temp_width, 0)
                end
              else
                temp_tab = self.tab_array[j] or {}
                if TabSelectBarDirection.vertical == self.direction then --竖直
                    content_height = content_height - ((temp_tab["height"] or btn:getContentSize().height) + self.space_offset)
                    btn:setPosition(0, content_height)
                elseif TabSelectBarDirection.horizontal == self.direction then --水平
                    temp_tab = self.tab_array[j - 1]
                    if temp_tab then
                        temp_width = temp_width + ((temp_tab["width"] or btn:getContentSize().width) + self.space_offset)
                    end
                    btn:setPosition(temp_width, 0)
                end
              end
            end
            btn:setVisible(stateVo[2])
        else
            btn:setVisible(true)
            temp_tab = self.tab_array[j] or {}
            if TabSelectBarDirection.vertical == self.direction then --竖直
                content_height = content_height - ((temp_tab["height"] or btn:getContentSize().height) + self.space_offset)
                btn:setPosition(0, content_height)
            elseif TabSelectBarDirection.horizontal == self.direction then --水平
                temp_tab = self.tab_array[j - 1]
                if temp_tab then
                    temp_width = temp_width + ((temp_tab["width"] or btn:getContentSize().width) + self.space_offset)
                end
                btn:setPosition(temp_width, 0)
            end
        end
    end
end

-- 隐藏状态
function TabSelectBar:setVisible( bool )
    self.tab_bar:setVisible(bool)
end

--[[根据index值来设置选中的项,并且改变index项的内容
-- index 从1开始
-- ]]
function TabSelectBar:setSelectByIndex(index)
    if self.per_select_index and self.per_select_index == index then return end
    local btn
    local temp_data
    if self.per_select_index and self.per_select_index <= #self.btn_list then
        btn = self.btn_list[self.per_select_index]
        temp_data = self.tab_array[self.per_select_index]
        btn:setSelected(false)
        if temp_data and temp_data["unselect_outline"] then
            btn:enableOutline(temp_data["unselect_outline"], 1)
        end
        if temp_data and temp_data["unselect_color"] then
            btn:setTitleColor(temp_data["unselect_color"])
        end
        if temp_data and temp_data["label"] then
            btn:setString(temp_data["label"])
        end
    end

    if index and index <= #self.btn_list then
        btn = self.btn_list[index]
        temp_data = self.tab_array[index]
        btn:setSelected(true)
        -- btn:setLocalZOrder(#self.btn_list)
        if temp_data and temp_data["select_outline"] then
            btn:enableOutline(temp_data["select_outline"], 1)
        end
        if temp_data and temp_data["select_color"] then
            btn:setTitleColor(temp_data["select_color"])
        end
        if temp_data and temp_data["select_label"] then
            btn:setString(temp_data["select_label"])
        end
    end
    self:changeBtnByIndex(index) -- 给外面的弄回调的
    self.per_select_index = index
end
--重设按钮大小，坑爹的需求
function TabSelectBar:resetBtnSize(size)
    for i,v in pairs(self.btn_list) do
        v:setBtnContenSize(size)
        self.tab_array[i].width = size.width
        self.tab_array[i].height = size.height
    end
end
--标签页面改变的时候，触发，内部使用
function TabSelectBar:changeBtnByIndex(index)
    --AudioMgr:getInstance():playEffect(AudioMgr.AUDIO_TYPE.COMMON,"c_003")
    if self.per_select_index == index then return end
    if self.changeItemByIndex ~= nil then
        self.changeItemByIndex(index)
    end
end

--设置标签页面的回调函数
function TabSelectBar:setChangeItemByIndex(call_back)
    if call_back ~= nil then
        self.changeItemByIndex = call_back
    end
end

function TabSelectBar:getSelectIndex()
    return self.per_select_index or 1
end

function TabSelectBar:getBtnByName(name)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            if v:getName() == name then
                return v
            end
        end
    end
end

function TabSelectBar:getBtnByIndex(index)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            if k == index then
                return v
            end
        end
    end
end

--设置提示小点的显影情况
function TabSelectBar:setCircleByName(name, bool)
    local btn = self:getBtnByName(name)
    if btn then
        btn:showCirclePoint(bool)
    else
        print("icon name==>"..name.."not found!!!")
    end
end

--设置按钮的缩放
function TabSelectBar:setBtnScale(scaleX,scaleY)
    for i,v in pairs(self.btn_list) do
        v:setIconScale(scaleX,scaleY)
    end
end
--设置按钮父节点size
function TabSelectBar:setBtnRootSize(size)
    size = size 
    for i,v in pairs(self.btn_list) do
        if size then
            v:getRoot():setContentSize(size)
        end
    end
end
--设置活动图标
function TabSelectBar:showActivityIconByName(name, res, bool)
    local btn = self:getBtnByName(name)
    if btn then
        if bool then
            btn:showActivityIcon(res)
        else
            btn:showActivityIcon(nil)
        end
    else
        print("icon name==>"..name.."not found!!!")
    end
end

--设置显示提示数字的情况
function TabSelectBar:setCircleNumByName(name, num)
    local btn = self:getBtnByName(name)
    if btn then
        btn:showCircleLabel(num)
    end
end

function TabSelectBar:getContentSize()
    return self:getRoot():getContentSize()
end
--增加入场动作
function TabSelectBar:setOpenAction()
    for i,v in pairs(self.btn_list) do 
        v:setVisible(false)
    end
    for i ,v in pairs(self.btn_list) do 
        delayRun(self.parent_wnd,0.1*i,function()
            local offx = v:getPositionX()
            local offy= v:getPositionY()
            v:setPosition(cc.p(offx-100,offy))
            v:setVisible(true)
            local action = cc.MoveTo:create(0.2,cc.p(offx, offy))
            v:getRoot():runAction(cc.Sequence:create(action))
        end)
       
    end
end
--增加离场动作
function TabSelectBar:setCloseAction(fun)
    for i,v in pairs(self.btn_list) do 
        v:setVisible(false)
    end
    for i ,v in pairs(self.btn_list) do 
            local offx = v:getPositionX()
            local offy= v:getPositionY()
            v:setPosition(cc.p(offx,offy))
            v:setVisible(true)
            local action = cc.MoveTo:create(0.2,cc.p(offx-200, offy))
            v:getRoot():runAction(cc.Sequence:create(action,cc.CallFunc:create(function(  )
                fun()
            end)))
    end
end
--设置文本的颜色
function TabSelectBar:setTitleColor(color)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            v:setTitleColor(color)
        end
    end
end

--重新设置提示小点的位置
function TabSelectBar:setCirclePointOffset(x, y)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            v:setCirclePointOffset(x, y)
        end
    end
end

--设置描边
function TabSelectBar:enableOutline(color, size)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            if self.per_select_index and self.per_select_index ~= k then
                v:enableOutline(color, size)
            end
        end
    end
end

function TabSelectBar:setTextWidth(width)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            v:getLabel():setWidth(width)
        end
    end
end

function TabSelectBar:setLocalZOrder(order)
    self.tab_bar:setLocalZOrder(order)
end

function TabSelectBar:getBtnTabel()
    return self.btn_list
end

--设置文本的偏移位置
function TabSelectBar:setTitleOffset(offset_x, offset_y)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            v:setTitleOffset(offset_x, offset_y)
        end
    end
end

--设置文本图片的偏移位置
function TabSelectBar:setTxtIconOffset(offset_x, offset_y)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            v:setTxtIconOffset(offset_x, offset_y)
        end
    end
end

--设置选中框的偏移位置
function TabSelectBar:setSelectTabPos(x, y)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            v:setSelectTabPos(x, y)
        end
    end
end

--设置文本的size
function TabSelectBar:setTitleSize(size)
    self.font_size = size
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            v:setFontSize(size)
        end
    end
end
--设置文本的内容
function TabSelectBar:setTitleLabel(list)
     if self.btn_list and #self.btn_list > 0 then
        for i=1,#self.btn_list do
            self.btn_list[i]:setString(list[i])
            local tab = self.tab_array[i]
            tab["label"] = list[i]
        end
    end
end

function TabSelectBar:setAnchorPoint(x, y)
    self.tab_bar:setAnchorPoint(cc.p(x, y))
end

function TabSelectBar:setPosition(x, y)
    self.tab_bar:setPosition(cc.p(x, y))
end

function TabSelectBar:getPosition()
    return self.tab_bar:getPositionX(), self.tab_bar:getPositionY()
end

function TabSelectBar:addToParent(parent)
    self.parent_wnd = parent
    if not tolua.isnull(self.tab_bar) and self.tab_bar:getParent() then
        self.tab_bar:removeFromParent()
    end
    self.parent_wnd:addChild(self.tab_bar)
end

function TabSelectBar:getRoot()
    return self.tab_bar
end

function TabSelectBar:__delete()
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            v:DeleteMe()
            v = nil
        end
        self.btn_list = nil
    end
    self.tab_bar:removeAllChildren()
    self.tab_bar = nil
    self.parent_wnd = nil
end
