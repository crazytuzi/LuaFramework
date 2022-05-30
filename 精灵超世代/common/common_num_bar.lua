-- Created by IntelliJ IDEA.
-- User: lfl
-- Date: 2015/1/8
-- Time: 17:15
-- [[文件功能：通用的数量条，具有数量加减的功能]]
Numerickeyboard = Numerickeyboard or BaseClass()
function Numerickeyboard:__init(callBack, parent, pos,scale)
    self.isCompleted = false
    self.parent = parent
    if self.parent == nil then
        self.parent = ViewManager:getInstance():getLayerByTag( ViewMgrTag.UI_TAG )
    end
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setAnchorPoint(cc.p(0, 1))
    self.root_wnd:setContentSize(cc.size(356, 229))
    
    self.parent:addChild(self.root_wnd)
    if pos ~= nil then
        self.root_wnd:setPosition(pos)
    end
    if scale ~= nil then
        self.root_wnd:setScale(scale);
    end
    self.callBack = callBack
    self:config()
    self:initEvent()
end

function Numerickeyboard:config()
    -- res= PathTool.getResFrame("common","common_1001")
    -- local jiantou = createSprite( res, 751, 266, self.panel)
    local res = PathTool.getResFrame("common","common_1056")
    local size = cc.size(356, 229)
    self.bg = createImage(self.root_wnd, res, size.width/2, size.height/2,nil,true)
    self.bg:setScale9Enabled(true)
    self.bg:setTouchEnabled(true)
    self.bg:setCapInsets(cc.rect(26, 27, 2, 2))
    self.bg:setContentSize(size)
    self.info_bg = createImage(self.bg, PathTool.getResFrame("common", "common_90024"), size.width / 2, size.height / 2, nil, true)
    self.info_bg:setScale9Enabled(true)
    self.info_bg:setTouchEnabled(true)
    self.info_bg:setCapInsets(cc.rect(26, 27, 2, 2))
    self.info_bg:setContentSize(cc.size(333,203))
    self.btn_list = {}
    for i=1, 13 do
        res = PathTool.getResFrame("common","common_1029")
        local btn = nil
        local m = (i-1) % 3
        local n = math.ceil(i/3)
        if i == 10 then -- 10 -- 删除
            m=3
            n=1
            res = PathTool.getResFrame("common","common_1046")
            btn = createButton( self.bg, TI18N("删除"), size.width-(4-m)*84 + 30, size.height-n*65 +14, cc.size(67, 50), res, 24,Config.ColorData.data_color4[1])
            --btn:enableOutline(Config.ColorData.data_color3[157],1)
            -- res = PathTool.getResFrame("common","common_btn6")
            -- local sprite = createSprite( res, size.width-(4-m)*75 +24,size.height-n*75 +25,self.bg)
        elseif i == 11 then -- 11 -- 0
            m=3
            n=2
            res = PathTool.getResFrame("common","common_1046")
            btn = createButton( self.bg, 0, size.width-(4-m)*84 + 30, size.height-n*65 +14, cc.size(67, 50), res, 28,Config.ColorData.data_color4[1])
            --btn:enableOutline(Config.ColorData.data_color3[157], 1)
        elseif i == 12 then -- 12 -- 确定
            m=3
            n=3
            res = PathTool.getResFrame("common","common_1046")
            btn = createButton( self.bg, TI18N("确定"), size.width-(4-m)*84  + 30, size.height-n*65 +14, cc.size(67, 50), res, 24,Config.ColorData.data_color4[1])
        elseif i == 13 then -- 13 -- 关闭
        else
            res = PathTool.getResFrame("common","common_1046")
            btn = createButton( self.bg, i, size.width-(4-m)*84 + 30, size.height-n*65 +14, cc.size(67, 50), res, 28,Config.ColorData.data_color4[1])
            --btn:enableOutline(Config.ColorData.data_color3[157], 1)
        end
        self.btn_list[i] = btn
    end
end

function Numerickeyboard:initEvent()
    if self.callBack ~= nil then
        for i, btn in ipairs(self.btn_list) do
            btn:addTouchEventListener(function(sender, eventType)
                customClickAction(sender,eventType)
                if eventType == ccui.TouchEventType.ended then
                    if i ~= 11 then
                        self.callBack(i)
                    else
                        self.callBack(0)
                    end
                end
            end)
        end
    end
end

function Numerickeyboard:setPosition(x, y)
    self.root_wnd:setPosition(cc.p(x, y))
end

function Numerickeyboard:close()
    self:DeleteMe()
end

function Numerickeyboard:__delete()
    if self.root_wnd and self.root_wnd:getParent() then
        self.root_wnd:removeAllChildren()
        self.root_wnd:removeFromParent()
        self.root_wnd = nil
    end
end


CommonNumBar = CommonNumBar or BaseClass()
function CommonNumBar:__init(parent_wnd, size, font_size,NumerickeyboardScale)
    self.parent_wnd = parent_wnd
    self.size = size
    self.font_size = font_size or 26
    self.num = 0
    self.callBack = nil
    self.NumerickeyboardScale = NumerickeyboardScale or 1
    self:initView()
    self:registerEvents()
end

function CommonNumBar:initView()
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self.parent_wnd:addChild(self.root_wnd)
    --背景
    self.background = createScale9Sprite(PathTool.getResFrame("common","common_1021"), self.size.width/2, self.size.height/2)
    self.background:setContentSize(self.size)
    self.background:setPosition(cc.p(self.size.width/2, self.size.height/2))
    self.root_wnd:addChild(self.background)
    --文本  
    self.num_label = createLabel(self.font_size,Config.ColorData.data_color4[151],nil,0,0,"",self.root_wnd,nil, cc.p(0.5, 0.5))
    self.num_label:setPosition(cc.p(self.size.width/2, self.size.height/2))
    --减按钮
    local res = PathTool.getResFrame("common","common_1046")
    self.sub_btn = createButton(self.root_wnd, "-", 0, 0, cc.size(56, 50), res, 30, Config.ColorData.data_color4[1], nil, nil, LOADTEXT_TYPE_PLIST)
    self.sub_btn:setLabelPosition(28,28)
    self.sub_btn:setAnchorPoint(cc.p(0.5,0.5))
    self.sub_btn:enableOutline(Config.ColorData.data_color3[157], 1)
    self.sub_btn:setPosition(cc.p(self.size.width/2-118, self.size.height/2))
    --加按钮
    res = PathTool.getResFrame("common","common_1046")
    self.add_btn = createButton(self.root_wnd, "+", 0, 0, cc.size(56, 50), res, 30, Config.ColorData.data_color4[1], nil, nil, LOADTEXT_TYPE_PLIST)
    self.add_btn:setAnchorPoint(cc.p(0.5, 0.5))
    self.add_btn:setLabelPosition(27,28)
    self.add_btn:enableOutline(Config.ColorData.data_color3[157], 1)
    self.add_btn:setPosition(cc.p(self.size.width/2+118, self.size.height/2))
end

function CommonNumBar:unRegisterEvents()
    self.root_wnd:setTouchEnabled(false)
end
function CommonNumBar:registerEvents()
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if not self.number_type then
                self.number_type = Numerickeyboard.New(function(index)
                    if index == 13 then  --关闭
                        self.number_type:close()
                        self.number_type = nil
                    elseif index == 10 then -- 10 -- 删除
                        self:popNum()
                    elseif index == 12 then -- 12 -- 确定
                        self.number_type:close()
                        self.number_type = nil
                        if self.callBack then self.callBack("enter",self:getNum()) end
                    else
                        self:pushNum(index)
                        if self.callBack then self.callBack("push", self:getNum()) end
                    end
                end, ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG), cc.p(0,0),self.NumerickeyboardScale)
                local point = self.root_wnd:convertToWorldSpace(cc.p(self.background:getPositionX() + 65, self.background:getPositionY()))
                self:adjustTipsPosition( self.number_type, point)
                self:setNum(0)
            end
        end
    end)

    self.add_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:addOne()
            if self.callBack then self.callBack("add", self:getNum()) end
        end
    end)

    self.sub_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:subOne()
            if self.callBack then self.callBack("sub", self:getNum()) end
        end
    end)

    self:registerNodeScriptHandler()
end
function CommonNumBar:closeNumkeyboard()
    if self.number_type then
        self.number_type:close()
        self.number_type = nil
    end
end
--事件注册，当根节点离开父节点的时候触发，保障根节点不会变成“野指针”
function CommonNumBar:registerNodeScriptHandler()
    local function onNodeEvent(event)
        if "enter" == event then  --进场
        elseif "exit" == event then --离场
            if self.number_type then
                self.number_type:close()
                self.number_type = nil
            end
        end
    end
    self.root_wnd:registerScriptHandler(onNodeEvent)
end


function CommonNumBar:getNum()
    return self.num
end

function CommonNumBar:setMaxUseNum(num)
    self.max_use_num = num
end

function CommonNumBar:setNum(num)
    if self.max_suffix_num then
        if num >self.max_suffix_num then
            message("单次输入已达最大数量")
        end
        self.num = math.min(num, self.max_suffix_num)
    else
        self.num = num
    end
    if self.call_back then
        self.call_back(self.num)
    end
    if self.num_label then
        local str = self.num..(self.suffix_str and ("/"..self.suffix_str) or "")
        self.num_label:setString(str)
    end
end

--末尾追加一个数
function CommonNumBar:pushNum(num)
    self:setNum(tonumber(self.num..num))
end

--末尾减少一个数
function CommonNumBar:popNum()
   local len = string.len(tostring(self.num))
   if len > 1 then
       self:setNum(tonumber(string.sub(self.num, 1, len - 1)))
   else
       self:setNum(0)
   end
end

function CommonNumBar:addOne()
    if self.max_use_num and self.max_use_num>0 then
        if self.max_suffix_num and self.max_use_num <= self.max_suffix_num then
            self:setNum(math.min(self:getNum() + 1, self.max_use_num))
            if self:getNum() >= self.max_use_num then
                message(string.format(TI18N("单次最大操作数量为%s个！"),self.max_use_num))
            end 
        elseif self.max_use_num > self.max_suffix_num then
            self:setNum(math.min(self:getNum() + 1, self.max_suffix_num)) 
        else
            self:setNum(self:getNum() + 1)
        end
    else
        if self.max_suffix_num then
            if self:getNum()+1 >self.max_suffix_num then
                message(TI18N("单次输入已达最大数量"))
            end
            self:setNum(math.min(self:getNum() + 1, self.max_suffix_num))
        else
            self:setNum(self:getNum() + 1)
        end
    end
end

function CommonNumBar:subOne()
    self:setNum(math.max(self:getNum() - 1, self.min_suffix_num))
end

--如果要加后缀的话，就加上(表示上限)
function CommonNumBar:setMaxSuffix(next)
    self.max_suffix_num = next
end

--如果要加后缀的话，就加上(表示上限)
function CommonNumBar:setMinSuffix(next)
    self.min_suffix_num = next
end

function CommonNumBar:setAnchorPoint(x, y)
    self.root_wnd:setAnchorPoint(cc.p(x, y))
end

function CommonNumBar:setPosition(x, y)
    self.root_wnd:setPosition(cc.p(x, y))
end
function CommonNumBar:setVisible(bool)
    self.root_wnd:setVisible(bool)
end

function CommonNumBar:addChangeEventListener(call_back)
    self.call_back = call_back
end

--位置调整(现在某认为显示的tips的anchorPoint的为cc.p(0, 1)自己主动的去设)
function CommonNumBar:adjustTipsPosition(target, point)
    local win_size = cc.Director:getInstance():getWinSize()
    local size = target.root_wnd:getContentSize()
    local offset_height = 10
    if point.x + size.width > win_size.width then -- 显示左边
        if point.y + size.height + offset_height > win_size.height then -- 显示下边
            if point.y - offset_height - size.height > 0 then
                target:setPosition(point.x - size.width - offset_height , point.y - offset_height)
            else --超出屏幕
                target:setPosition(point.x - size.width - offset_height , point.y - offset_height + math.abs(point.y - offset_height - size.height))
            end
        else
            target:setPosition(point.x - size.width - offset_height , point.y + size.height + offset_height)
        end
    else  -- 显示右边
        if point.y + size.height + offset_height > win_size.height then -- 显示下边
            if point.y - offset_height - size.height > 0 then
                target:setPosition(point.x + offset_height , point.y - offset_height)
            else --超出屏幕
                target:setPosition(point.x + offset_height , point.y - offset_height + math.abs(point.y - offset_height - size.height))
            end
        else
            target:setPosition(point.x + offset_height , point.y + size.height + offset_height)
        end
    end
end

function CommonNumBar:getLabel()
    return self.num_label
end

function CommonNumBar:setBackgroundVisible(bool)
    self.background:setVisible(bool)
end

function CommonNumBar:registerHandle(callFun)
    self.callBack = callFun
end
function CommonNumBar:__delete()
    if self.number_type then
        self.number_type:close()
        self.number_type = nil
    end
end