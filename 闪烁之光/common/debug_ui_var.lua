----------------------------------------------------
---- 内存变量管理UI
---- @author whjing2011@gmail.com
------------------------------------------------------
DebugUIVar = DebugUIVar or BaseClass()

function DebugUIVar:__init()
    DebugUIVar.Instance = self
    self:initUI()
    self:registerEvents()
    self.vars = {}
    self.delList = {}
    self:updateInfo()
end

function DebugUIVar:getInstance()
    if DebugUIVar.Instance == nil then
        DebugUIVar.New()
    end
    return DebugUIVar.Instance
end

function DebugUIVar:initUI()
    self.root = ccui.Layout:create()
    ViewManager:addToLayerByTag(self.root, ViewMgrTag.DEBUG_TAG, 100)
    self.root:setContentSize(cc.size(SCREEN_WIDTH + 200, SCREEN_HEIGHT + 200))
    local size = cc.size(700, 460)
    self.container = ccui.Layout:create()
    self.root:addChild(self.container, 20)
    self.container:setBackGroundColor(cc.c3b(255,255,255))
    self.container:setBackGroundColorOpacity(255)
    self.container:setBackGroundColorType(1)
    self.container:setContentSize(size)
    self.container:setAnchorPoint(0.5, 0.5)
    self.container:setPosition(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)

    self.close_btn = CustomButton.New(self.container, PathTool.getResFrame("common", "common_1028"),nil, nil, LOADTEXT_TYPE_PLIST)
    self.close_btn:setAnchorPoint(cc.p(1,1))
    self.close_btn:setPosition(size.width - 2, size.height + 10)

    local y = size.height - 20
    local x = 10
    self.label_var = createWithSystemFont("", DEFAULT_FONT, 16)
    self.label_var:setAnchorPoint(0,0)
    self.label_var:setPosition(x, y)
    self.container:addChild(self.label_var)
    self.label_var:setTextColor(cc.c4b(0,0,0,255))

    y = y - 25
    self.label_info = createWithSystemFont("", DEFAULT_FONT, 16)
    self.label_info:setAnchorPoint(0,0)
    self.label_info:setPosition(x, y)
    self.container:addChild(self.label_info)
    self.label_info:setTextColor(cc.c4b(0,0,0,255))

    self.root_btn = ccui.Button:create()
    self.container:addChild(self.root_btn)
    self.root_btn:setTitleColor(cc.c3b(0,0,0))
    self.root_btn:setContentSize(cc.size(30, 25))
    self.root_btn:setAnchorPoint(0, 0)
    self.root_btn:setPosition(size.width - 35, y)
    self.root_btn:setTitleText("root")
    self.parent_btn = ccui.Button:create()
    self.container:addChild(self.parent_btn)
    self.parent_btn:setTitleColor(cc.c3b(0,0,0))
    self.parent_btn:setContentSize(cc.size(30, 25))
    self.parent_btn:setAnchorPoint(0, 0)
    self.parent_btn:setPosition(size.width - 70, y)
    self.parent_btn:setTitleText("父层")
    self.back_btn = ccui.Button:create()
    self.container:addChild(self.back_btn)
    self.back_btn:setTitleColor(cc.c3b(0,0,0))
    self.back_btn:setContentSize(cc.size(30, 25))
    self.back_btn:setAnchorPoint(0, 0)
    self.back_btn:setPosition(size.width - 105, y)
    self.back_btn:setTitleText("返回")

    self.finder = createEditBox(self.container, PathTool.getResFrame("common", "common_1048"), cc.size(250, 25), Config.ColorData.data_color3[5], 26, Config.ColorData.data_color3[1], 26, "name", cc.p(330, y), 18, LOADTEXT_TYPE_PLIST)
    self.finder:setAnchorPoint(0, 0)
    self.finder:setText("")
    
    self.var_layer = ccui.ScrollView:create()
    self.container:addChild(self.var_layer)
    self.var_layer:setContentSize(cc.size(size.width - 20, y - 12))
    self.var_layer:setInnerContainerSize(self.var_layer:getContentSize())
    self.var_layer:setAnchorPoint(0,0)
    self.var_layer:setPosition(3, 10)
    -- self.var_layer:setTouchEnabled(true)
    self.var_layer:setSwallowTouches(true)
    self.var_layer:setBounceEnabled(true)
    self.var_layer:setClippingEnabled(true)
    self.var_layer:setScrollBarEnabled(false)
end

function DebugUIVar:updateInfo()
    self.list = self:getTableVar()
    -- print("self================", tableLen(self.list))
    self.label_var:setString(table.concat(self.vars, "."))
    self.keys = {}
    local len, f_len, t_len = 0, 0, 0
    local find_str = self.finder:getText() or ""
    local f_type = 0
    if string.find(find_str, "@") then
        find_str = string.sub(find_str, 2, string.len(find_str))
        f_type = 1
    elseif string.find(find_str, "/") then
        find_str = string.sub(find_str, 2, string.len(find_str))
        f_type = 2
    elseif string.find(find_str, "#") then
        find_str = string.sub(find_str, 2, string.len(find_str))
        f_type = 3
    end
    for k, v in pairs(self.list) do
        if (f_type == 0 and string.find(tostring(k), find_str)) 
            or (f_type == 1 and string.find(type(v), find_str)) 
            or (f_type == 2 and string.find(tostring(k), find_str) == 1) 
            or (f_type == 3 and type(v) == "table" and v[find_str]) 
            then
            table.insert(self.keys, k)
            len = len + 1
            if type(v) == "function" then
                f_len = f_len + 1
            elseif type(v) == "table" then
                t_len = t_len + 1
            end
        end
    end
    self.label_info:setString(string.format("变量数量:%d function:%d table:%d", len, f_len, t_len))
    self.h = 35
    self:deleteObj(self.itemContainer)
    self.y = math.max(self.h * len, self.var_layer:getContentSize().height)
    self.w = self.var_layer:getContentSize().width
    self.var_layer:setInnerContainerSize(cc.size(self.w, self.y))
    self.itemContainer = ccui.Layout:create()
    self.var_layer:addChild(self.itemContainer)
    self:createItems()
end

function DebugUIVar:deleteObj(obj)
    if not obj then return end
    obj:setVisible(false)
    table.insert(self.delList, obj)
    if not self.deling then
        self.deling = true
        self:doDel()
    end
end

function DebugUIVar:doDel()
    if not next(self.delList) then
        self.deling = nil
        return
    end
    local obj = self.delList[1]
    if obj:getChildrenCount() < 10 then
        doRemoveFromParent(obj)
        table.remove(self.delList, 1)
        print("=====================", #self.delList)
    else
        local items = obj:getChildren()
        for i = 1, 10 do
            doRemoveFromParent(items[i])
        end
    end
    delayRun(self.container, 0.02, function()
        self:doDel()
    end)
end

function DebugUIVar:createItems()
    if not next(self.keys) then return end
    local num = math.min(5, #self.keys)
    for i=1, num do
        local k = table.remove(self.keys, 1)
        self.y = self.y - self.h
        local item = self:createItem(self.list, k, self.w)
        self.itemContainer:addChild(item)
        item:setPositionY(self.y)
    end
    -- self.itemContainer:stopAllActions()
    delayRun(self.itemContainer, 0.015, function()
        self:createItems()
    end)
end

function DebugUIVar:createItem(list, k, width)
    local v = list[k]
    if self.label_var:getString() == "package.loaded" then
        v = require(k) or v
    end
    local item = ccui.Layout:create()
    local t = type(v)
    local x = 210
    local font_size = 24
    local label_k = createWithSystemFont("", DEFAULT_FONT, 16)
    label_k:setAnchorPoint(1,0)
    label_k:setPositionX(x - 10)
    label_k:setTextColor(cc.c4b(0,0,0,255))
    item:addChild(label_k)
    label_k:setString(tostring(k))

    if t == "function" or t == "userdata" or t == "thread" or (t == "table" and not self:checkVarLen(v, 10)) then
        local label_v = createWithSystemFont("", DEFAULT_FONT, 16)
        label_v:setAnchorPoint(0,0)
        label_v:setPositionX(x)
        label_v:setTextColor(cc.c4b(0,0,0,255))
        item:addChild(label_v)
        if t == "userdata" and tolua.type(v) then
            label_v:setString(tostring(v)..":"..tolua.type(v))
        else
            label_v:setString(tostring(v))
        end
    else
        local edit = createEditBox(item, PathTool.getResFrame("common", "common_1048"), cc.size(250, 35), Config.ColorData.data_color3[5], 14, Config.ColorData.data_color3[1], 14, "name", cc.p(x, 0), 18, LOADTEXT_TYPE_PLIST)
        edit:setAnchorPoint(0, 0)
        if t == "table" then
            edit:setText(self:luaTable2Str(v))
        else
            edit:setText(tostring(v))
        end
        edit:registerScriptEditBoxHandler(function(eventType, sender)
            if eventType == "return" then
                if t == "number" then
                    list[k] = tonumber(sender:getText())
                elseif t == "table" then
                    list[k] = loadstring("return "..sender:getText())()
                else
                    list[k] = sender:getText()
                end
            end
        end)
    end

    local x = width - 5
    local btn = ccui.Button:create()
    if self.label_var:getString() == "package.loaded" then
        btn:setTitleColor(cc.c3b(0,0,0))
        btn:setContentSize(cc.size(30, 35))
        btn:setAnchorPoint(1, 0)
        btn:setPosition(x, 0)
        btn:setTitleText("重载")
        item:addChild(btn)
        handleTouchEnded(btn, function() 
            package.loaded[k] = nil
            require(k)
        end)
    else
        btn:setTitleColor(cc.c3b(0,0,0))
        btn:setContentSize(cc.size(30, 35))
        btn:setAnchorPoint(1, 0)
        btn:setPosition(x, 0)
        btn:setTitleText("删除")
        -- if item then return item end
        item:addChild(btn)
        handleTouchEnded(btn, function() 
            list[k] = nil 
            self:updateInfo()
        end)
    end
    if t == "table" then
        x = x - 60
        btn = ccui.Button:create()
        btn:setTitleColor(cc.c3b(0,0,0))
        btn:setContentSize(cc.size(30, 35))
        btn:setAnchorPoint(1, 0)
        btn:setPosition(x, 0)
        btn:setTitleText("打开")
        item:addChild(btn)
        handleTouchEnded(btn, function() 
            table.insert(self.vars, k) 
            self.back_var = nil
            self.finder:setText("")
            self:updateInfo()
        end)
    elseif t == "userdata" and v.getBoundingBox then
        x = x - 60
        btn = ccui.Button:create()
        btn:setTitleColor(cc.c3b(0,0,0))
        btn:setContentSize(cc.size(30, 35))
        btn:setAnchorPoint(1, 0)
        btn:setPosition(x, 0)
        btn:setTitleText("调试")
        item:addChild(btn)
        handleTouchEnded(btn, function() 
            require("common/debug_ui_helper")
            DebugUIHelper:getInstance(v):open()
        end)
    end
    return item
end

--把table写成字符串的格式
function DebugUIVar:luaTable2Str(lua_table, indent)
    indent = indent or 0
    local final_str = "{"
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local TypeV = type(v)
        local szPrefix = "" --  string.rep(" ", indent)
        formatting = szPrefix.."["..k.."]".." = "
        if TypeV == "table" then
            final_str = final_str .. formatting
            final_str = final_str .. self:luaTable2Str(v, indent + 1)
            final_str = final_str .. szPrefix .. ","
        else
            local szValue = ""
            if TypeV == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
           final_str = final_str .. formatting .. szValue .. ","
        end
    end
    return final_str.."}"
end

function DebugUIVar:getTableVar()
    local var = self.vo or _G
    local key
    for i, k in ipairs(self.vars) do
        if var[k] then
            var = var[k]
            if var.Instance and (var.__init or var.ctor or var.registerEvents or var.RegisterProtocal) then
                var = var["getInstance"](var)
            elseif var.New then
                var = getSuperClass(var)
            end
            key = k
        else
            self.vars[i] = nil
        end
    end
    return var
end

function DebugUIVar:checkVarLen(list, len)
    for _, v in pairs(list) do
        len = len - 1
        if type(v) == "function" then
            return false
        elseif len < 0 then
            return false
        elseif type(v) == "table" then
            len = self:checkVarLen(v, len)
            if not len then
                return false 
            end
        end
    end
    return len
end

function DebugUIVar:registerEvents()
    handleTouchEnded(self.close_btn, function()
        self:close()
    end)
    handleTouchEnded(self.root_btn, function()
        if #self.vars == 0 then return end
        self.back_var = self.vars[1]
        self.vars = {}
        self.finder:setText("")
        self:updateInfo()
    end)
    handleTouchEnded(self.parent_btn, function()
        if #self.vars == 0 then return end
        self.back_var = table.remove(self.vars)
        self.finder:setText("")
        self:updateInfo()
    end)
    handleTouchEnded(self.back_btn, function()
        if #self.vars == 0 and not self.back_var then return end
        if self.back_var then
            table.insert(self.vars, self.back_var)
            self.back_var = nil
        else
            self.back_var = table.remove(self.vars)
        end
        self.finder:setText("")
        self:updateInfo()
    end)
    self.container:setTouchEnabled(true)
    self.container:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            local pos = sender:getTouchMovePosition()
            pos = sender:getParent():convertToNodeSpaceAR(pos)
            sender:setPosition(pos)
        end
    end)
    self.finder:registerScriptEditBoxHandler(function(eventType, sender)
        if eventType == "return" then
            self:updateInfo()
        end
    end)
end

function DebugUIVar:downUpLoad(mod)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = ""
    local file = ""
    xhr:open("POST", url)
    xhr:registerScriptHandler(function()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            print("Http Status Code:"..xhr.statusText)
            local response   = xhr.response -- 原json字符串
            response = unicode2utf8(response) -- 将其中的unicode \uxxxx转化成正式字符串，不然在原生 json.decode 中会报错
        else
            print("下载文件失败", url)
        end
    end)
    xhr:send()
end

function DebugUIVar:open(vo)
    self.root:setVisible(true)
    if self.vo ~= vo then
        self.vars = {}
        self.vo = vo
        self:updateInfo()
    end
end

function DebugUIVar:close()
    self.root:setVisible(false)
end
