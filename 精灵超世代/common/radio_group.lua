
-- User: cloud
-- Date: 2016.12.29

-- [[文件功能：单选按钮组]]
RadioGroup = class("RadioGroup", function()
    return ccui.Layout:create()
end)

RadioGroupDir =
{
    vertical = 1,  --竖直方向
    horizontal = 2, -- 水平方向
}
--[[
-- @param parent      加入的父节点
-- @param dir         单选按钮的方向
-- @param offset      偏移量
-- @param tab_array   单选的数据组
-- @param call_back   点击的回调
-- ]]
function RadioGroup:ctor(parent, direction, offset, tab_array, call_back)
    self.parent = parent
    self.direction = direction or RadioGroupDir.horizontal
    self.space_offset = offset or 10
    self.tab_array = tab_array
    self.changeItemByIndex = call_back
    --加入父节点
    self.parent:addChild(self)
    if tab_array then
        self:setRadioArray(tab_array)
    end
end

--[[设置单选的标签数据tab_array里面的数据有{{}，{}，{}}
-- @param background  单选按钮的背景(必填)
-- @param select_path 选中的状态(必填)
-- @param label      描述(必填)
-- @param dir        方向
-- @param font_size  文本字号
-- @param font_offset 文本偏移
-- @param select_color 选中标签的文本的颜色
-- @param select_outline 选中标签的文本的描边颜色
-- @param unselect_color 非选中标签的文本颜色
-- @param unselect_outline 选中标签的文本的描边颜色
-- ]]
function RadioGroup:setRadioArray(tab_array)
    self.tab_array = tab_array
    self.btn_list = {} -- 保存按钮的列表
    self:removeAllChildren()

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
            local btn = RadioButton.new(self, temp_tab["background"], temp_tab["select_path"], temp_tab["label"]
                , temp_tab["font_offset"], temp_tab["dir"], self.font_size)
            btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    btn_click(i)
                end
            end) --点击的时候触发
            btn:setAnchorPoint(0, 0)
            btn:setTitleColor(temp_tab["unselect_color"] or Config.ColorData.data_color4[1])
            local name = temp_tab["name"] or i
            btn:setName(name)
            self.btn_list[i] = btn
            if RadioGroupDir.vertical == self.direction then --竖直
                content_height = content_height + (temp_tab["height"] or (btn:getContentSize().height + self.space_offset))
                content_width = math.max(content_width, (temp_tab["width"] or (btn:getContentSize().width)))
            elseif RadioGroupDir.horizontal == self.direction then --水平
                content_width = content_width + (temp_tab["width"] or (btn:getContentSize().width + self.space_offset))
                content_height = math.max(content_height, (temp_tab["height"] or (btn:getContentSize().height)))
            end
        end

        self:setContentSize(cc.size(content_width, content_height))

        --设置每个按钮的位置
        local temp_width = 0
        for j = 1, #self.tab_array do
            local btn = self.btn_list[j]
            temp_tab = self.tab_array[j] or {}
            if RadioGroupDir.vertical == self.direction then --竖直
                content_height = content_height - (temp_tab["height"] or btn:getContentSize().height) - self.space_offset
                btn:setPosition(0, content_height)
            elseif RadioGroupDir.horizontal == self.direction then --水平
                temp_tab = self.tab_array[j - 1]
                if temp_tab then
                    temp_width = temp_width + (temp_tab["width"] or btn:getContentSize().width) + self.space_offset
                end
                btn:setPosition(temp_width, 0)
            end
        end
        self:setSelectByIndex(1)
    end
end

--[[根据index值来设置选中的项,并且改变index项的内容
-- index 从1开始
-- limit_event 限制事件派发
-- ]]
function RadioGroup:setSelectByIndex(index,limit_event)
    local btn
    local temp_data

    if self.per_select_index and self.btn_list[self.per_select_index]
            and self.per_select_index <= #self.btn_list then
        btn = self.btn_list[self.per_select_index]
        temp_data = self.tab_array[self.per_select_index]
        btn:setSelected(false)
        btn:setLocalZOrder(#self.btn_list - 1)
        if temp_data and temp_data["unselect_outline"] then
            btn:enableOutline(temp_data["unselect_outline"], 2)
        end
        if temp_data and temp_data["unselect_color"] then
            btn:setTitleColor(temp_data["unselect_color"])
        end
    end

    if index and index <= #self.btn_list and self.btn_list[index] then
        btn = self.btn_list[index]
        temp_data = self.tab_array[index]
        btn:setSelected(true)
        btn:setLocalZOrder(#self.btn_list)
        if temp_data and temp_data["select_outline"] then
            btn:enableOutline(temp_data["select_outline"], 2)
        end
        if temp_data and temp_data["select_color"] then
            btn:setTitleColor(temp_data["select_color"])
        end
    end
    if limit_event == nil then
        self:changeBtnByIndex(index) -- 给外面的弄回调的
    end
    self.per_select_index = index
end

--标签页面改变的时候，触发，内部使用
function RadioGroup:changeBtnByIndex(index)
    if self.per_select_index == index then
        if self.curItemByIndex ~= nil then
            self.curItemByIndex(index)
        end
        return
    end
    if self.changeItemByIndex ~= nil then
        self.changeItemByIndex(index)
    end
end

function RadioGroup:getSelectIndex()
    return self.per_select_index
end

--设置标签页面的回调函数
function RadioGroup:setChangeItemByIndex(call_back)
    if call_back ~= nil then
        self.changeItemByIndex = call_back
    end
end

--设置文本的size
function RadioGroup:setTitleSize(size)
    self.font_size = size
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            v:setFontSize(size)
        end
    end
end

--设置文本的颜色
function RadioGroup:setTitleColor(color)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            v:setTitleColor(color)
        end
    end
end

function RadioGroup:getBtnByName(name)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            if not tolua.isnull(v) and v:getName() == name then
                return v
            end
        end
    end
end

function RadioGroup:getBtnByIndex(index)
    if self.btn_list and #self.btn_list > 0 then
        for k, v in pairs(self.btn_list) do
            if k == index then
                return v
            end
        end
    end
end


function RadioGroup:getSelectedRadio()
    return self:getBtnByIndex(self:getSelectIndex())
end

function RadioGroup:unSelectedRadio()
    if self:getBtnByIndex(self:getSelectIndex()) then 
        self:getBtnByIndex(self:getSelectIndex()):setSelected(false)
        self.per_select_index = nil
    end
end