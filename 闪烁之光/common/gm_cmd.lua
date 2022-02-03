
-- GM命令按钮
GmCmd = GmCmd or {}
function GmCmd:show_from_chat(msg)
    if msg == "@sgmcmd" then
        SHOW_GM = not SHOW_GM
        if self.open_button == nil then
            ViewManager:getInstance():initMainFunBar()
        end
        self.open_button:setVisible(SHOW_GM)
        return true
    elseif msg == "@showfps" then
        CC_SHOW_FPS = not CC_SHOW_FPS
        cc.Director:getInstance():setDisplayStats(CC_SHOW_FPS)
        return true
    elseif msg == "@gmclearversionfile" then
        self:clearVerFile()
        return true
    end
    return false
end

function GmCmd:add_gm_button(layer)
    if not self.is_init then
        ProtoMgr:RegisterCmdCallback(10391, "handle10391", self)
        ProtoMgr:RegisterCmdCallback(10399, "handle10399", self)
        self.root_wnd = layer
        self:initTouch()
        self.view_height = 400
        self.view_width = 720
        self.view_in_height = display.height

        self.edit_list = SysEnv:getInstance():getTable(SysEnv.keys.gm_eidt_list)
        self.edit_list_index = #self.edit_list
        self.edit_max = 10

        self.scroll_view = createScrollView(self.view_width,self.view_height,0,-self.view_height,nil)
        self.scroll_view:setAnchorPoint(cc.p(0,1))
        self.scroll_view:setVisible(false)
        self.scroll_view:setPosition(0,0)
        self.scroll_view:setContentSize(cc.size(self.view_width, self.view_height))
        self.scroll_view:setInnerContainerSize(cc.size(self.view_width, self.view_in_height))
        showLayoutRect(self.scroll_view)

        -- 打开关闭gm命令按钮
        self.open_button = self:addButton(layer, "GM",display.getLeft(self.root_wnd) + 200, display.getTop(self.root_wnd) - 50, 1, 99, function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                if self.in_move then 
                    self.in_move = false
                    return 
                end
                if not self.is_init_button then 
                    self:init_button()
                end
                local is_visible = self.scroll_view:isVisible()
                self.scroll_view:setVisible(not is_visible)
            elseif event_type == ccui.TouchEventType.began then
                self.touch_time = GameNet:getInstance():getTime()
            elseif event_type == ccui.TouchEventType.moved then
                local pos = sender:getTouchMovePosition()
                if self.in_move or GameNet:getInstance():getTime() - self.touch_time > 1 then
                    sender:setPosition(pos)
                    self.in_move = true
                end
            end
        end)
        self.open_button:setAnchorPoint(cc.p(0.5, 1))
        self.open_button:setContentSize(cc.size(120,59))
        GlobalKeybordEvent:getInstance():add(function() self:changeGm(-1) end, cc.Handler.EVENT_KEYBOARD_RELEASED, 28, 0)
        GlobalKeybordEvent:getInstance():add(function() self:changeGm(1) end, cc.Handler.EVENT_KEYBOARD_RELEASED, 29, 0)
        GlobalKeybordEvent:getInstance():add(function() self:gm_callback(self.gm_editbox) end, cc.Handler.EVENT_KEYBOARD_RELEASED, cc.KeyCode["KEY_ENTER"], 0)
        self.open_button:addChild(self.scroll_view)

        self.button_width, self.button_height = 120, 59

        -- gm命令框
        self.gm_editbox = createEditBox(self.open_button, PathTool.getResFrame("common", "common_90018"), cc.size(300, 45), nil, 25, nil, 25, "命令", nil, nil, LOADTEXT_TYPE_PLIST)
        if #self.edit_list > 0 then 
            self.gm_editbox:setText(self.edit_list[#self.edit_list].msg)
        end
        self.gm_editbox:setPosition(self.open_button:getContentSize().width + self.gm_editbox:getContentSize().width/2+10, self.open_button:getContentSize().height/2)
        self.gm_editbox:registerScriptEditBoxHandler(function(strEventName,pSender)
            if strEventName == "return" then self:gm_callback(pSender) end
        end)
        if not SHOW_GM then self.open_button:setVisible(false) end
        self.is_init = true
        -- delayOnce(function()
        --    self:req1190()
        -- end, 2)
    end
end

function GmCmd:req1190()
    if not self.root_1190 then
        self.root_1190 = ccui.Widget:create()
        self.root_wnd:addChild(self.root_1190)
    end
    -- print("======>>>>req1190", os.time(), tolua.isnull(self.root_wnd))
    delayRun(self.root_1190, 8.0, function()
        Send(1190, {})
        self:req1190()
    end)
end

-- 服务端动态执行代码
function GmCmd:handle10391(data)
    local str = data.data or ""
    local ret =  assert(loadstring(str))() or 'error'
    if data.type == 1 then -- 需要把结果回调给服务端
        if type(ret) == 'table' then
            ret = luaTable2Str('', ret)
        end
        Send(10391, {msg = tostring(ret)})
    end
end

function GmCmd:handle10399(data)
    if data.code == 99 then
        print_log("==========server==error=====start==>\n" .. data.msg.."\n============server===error=====end==")
    else
        message(data.msg)
        print("gm==recv==>", data.msg)
    end
end

function GmCmd:show()
    if self.open_button then 
        self.open_button:setVisible(true)
    end
end

function GmCmd:showGmList(sender, list)
    if sender.layout == nil then
        local layout = ccui.Layout:create()
        layout:setAnchorPoint(cc.p(0,1))
        showLayoutRect(layout)
        local max_num = 4
        local cell = math.ceil(#list/max_num)
        local width, height = self.button_width * max_num + 5 * 10, self.button_height * cell + (cell + 1) * 4
        layout:setContentSize(width, height)
        self.scroll_view:addChild(layout)
        sender.layout = layout
        sender.is_visible = true
        sender.button_list = {}

        local pos = cc.p(sender:getPosition())
        local x = self.button_width / 2
        local y = height - 4
        local temp_x = pos.x-self.button_width/2
        if temp_x + width >= self.scroll_view:getContentSize().width then
            temp_x = temp_x - width
        end
        if temp_x <= 0 then
            temp_x = 0
        end
        layout:setPosition(temp_x, pos.y-self.button_height)

        x = - 0.5 * self.button_width
        for index, bid in pairs(list) do 
            local typebid = type(bid) == "table"
            -- 二级菜单
            if not typebid then
                if Config.GmData.data_list[bid] == nil then
                    return 
                end
            end
            local name = typebid and bid.name or Config.GmData.data_list[bid].tips
            local fun = typebid and bid.fun or function(sender2, event_type)
                if event_type == ccui.TouchEventType.ended then
                    local protocal = {}
                    protocal.msg = Config.GmData.data_list[bid].info
                    print("gm===send", protocal.msg)
                    BaseController:SendProtocal(10399, protocal)
                    self.button_click_time[name] = (self.button_click_time[name] or 0) + 1
                    sender2:setTitleColor(self:time2Color(self.button_click_time[name]))
                end
            end

            x = x + self.button_width + 10
            if x > layout:getContentSize().width then 
                x = 0.5 * self.button_width + 10
                y = y - self.button_height - 4
            end
            local font_color = self:time2Color(self.button_click_time[name], index)
            local button = self:addButtonList(layout, name, x, y, 1, 1, fun or function( ... ) end, font_color)
            table.insert(sender.button_list, button)
        end
    else 
        sender.is_visible = not sender.is_visible
        sender.layout:setVisible(sender.is_visible)
    end
    if self.last_sender and self.last_sender ~= sender then 
        self.last_sender.layout:setVisible(false)
        self.last_sender.is_visible = false
    end
    self.last_sender = sender
end

-- 添加按钮
function GmCmd:addButtonList(parent, name, x, y, scale, zorder, func, font_color)
    local button = ccui.Button:create()
    local res = PathTool.getResFrame("common", "common_1017")
    if zorder == 1 then 
         res = PathTool.getResFrame("common", "common_1018")
    end
    button:loadTextures(res, "", "", LOADTEXT_TYPE_PLIST)
    button:setAnchorPoint(cc.p(0.5, 1))
    button:setTitleText(name)
    button:setTitleFontSize(18)
    button:setScale9Enabled(true)
    button:setTitleFontName(DEFAULT_FONT)
    button:setContentSize(cc.size(self.button_width, self.button_height))
    button:setTitleColor(font_color or Config.ColorData.data_color3[1])
    button:setPosition(x, y)
    button:addTouchEventListener(function(sender, event_type)
        func(sender, event_type)
    end)
    parent:addChild(button, zorder or 0)
    return button
end

function GmCmd:init_button()
    local gm_button_info = {}
    self.button_click_time = SaveLocalData:getInstance():readTableForKey(SaveLocalData.key_value.gm_cmd) or {}
    -- 计算常用按钮
    local _list = {}
    for k, v in pairs(self.button_click_time) do 
        table.insert(_list, {name=k, time=v})
    end
    table.sort(_list, function(a, b) return b.time < a.time end)
    -- 
    local _all_gm = {}
    for k, v in pairs(Config.GmData.data_list or {}) do 
        _all_gm[v.tips] = {k, v}
        if v.is_show ~= FALSE then 
            local one = {v.tips, function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    if v.list and #v.list > 0 then 
                        self:showGmList(sender, v.list)
                    else
                        if self.last_sender then 
                            self.last_sender.layout:setVisible(false)
                            self.last_sender.is_visible = false
                            self.last_sender = nil
                        end
                        local protocal = {}
                        protocal.msg = v.info
                        print("gm===send", protocal.msg)
                        BaseController:SendProtocal(10399,protocal)
                    end
                    self.button_click_time[v.tips] = (self.button_click_time[v.tips] or 0) + 1
                    sender:setTitleColor(self:time2Color(self.button_click_time[v.tips]))
                    SaveLocalData:getInstance():writeLuaData(SaveLocalData.key_value.gm_cmd, self.button_click_time)
                end
            end}
            table.insert(gm_button_info, one)
        end
    end
    -- 常用按钮
    local useful_button = {}
    local useful_button_name = {}
    for i = 1, #_list do
        if _all_gm[_list[i].name] and #_all_gm[_list[i].name][2].list == 0 then
            table.insert(useful_button, _all_gm[_list[i].name][1]) 
            if #useful_button >= 9 then 
                break
            end
        end
    end

    -- 基础功能按钮
    local loginModeName = LOGIN_MODE == "1" and "默认登录" or "不默认登录"
    self.is_auto = true
    local base_button_info = {{"软重启", "restart"}, {"ui", "f1"},{"纹理信息", "dumpTextureInfo"},
         {"热更游戏", "hot_fix"}, {"输出", "f4"}, {"关闭GM", "closeMe"},
         {"删网络层", "stopNet"}, {"开网络层", "restartNet"}, {"只是断网", "disconnect"}, {"请求网络", "reconnect"}, 
         {"战斗调试", "battle_debug"}, {"UI调试", "ui_debug"}, {"内存变量", "ui_var"}, {"清空版本", "clearVerFile"}, {"清除纹理", "takePhoto"}, {"打印纹理", "dumpCachedTextureInfo"},
         {"乱点", "random_click"}, {"打印内存", "showSysSize"},{"退出战斗", "exitbattle"},{"FPS","closeFPS"},{"网络ping","net_ping"}, {"wx_share", "wx_share"}, {"wx_share_url", "wx_share_url"}, {"savePhoto", "savePhoto"},
         {"time_ticket", "time_ticket"}, {"加qq群", "join_qq"} ,{"模块UI文件重载","reloadluafile"}, {"输出新手资源", "saveResourcesList"}, {"贝塞尔曲线", "showBezierPos"}, {"监测模拟器", "checkInEmulator"}, {"当前节点数", "getNodeTotal"},
         {"代金劵","testPerfer"},{"自定义头像","openCustomWindow"},
        }

    local base_list = {}
    for _, info in pairs(base_button_info) do 
        local fun_name = info[2]
        if self[fun_name] then
            table.insert(base_list, {name=info[1], fun=function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    self[fun_name](self, sender, event_type)
                end
            end})
        end
    end
    local base_button = {"基础功能", function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:showGmList(sender, base_list)
        end
    end}
    table.insert(gm_button_info, 1, base_button)
    table.insert(gm_button_info, 2, {"自己常用", function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            self:showGmList(sender, useful_button)
        end
    end})
    table.insert(gm_button_info, 3, {"修改配置", function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            self:showConfigPanel()
        end
    end})

    local y_num = math.ceil(#gm_button_info / 5)
    local x, y = - 0.5 * self.button_width, self.view_in_height - 4

    x = - 0.5 * self.button_width
    for _, one in pairs(gm_button_info) do 
        local name, fun = unpack(one)
        x = x + self.button_width + 10
        if x > self.view_width - self.button_width then 
            x = 0.5 * self.button_width + 10
            y = y - self.button_height - 4
        end
        local font_color = self:time2Color(self.button_click_time[name], index)
        if name == "联盟战" then
            local aaa = 0
        end
        local button = self:addButtonList(self.scroll_view, name, x, y, 1, 0, fun or function( ... ) end, font_color)
    end
    self.is_init_button = true
end

function GmCmd:testPerfer()
    sdkPerfer_prize()
end
--==============================--
--desc:记录当前总的节点数量,看异常
--time:2019-06-10 11:59:04
--@return 
--==============================--
function GmCmd:getNodeTotal()
    local base_node = ViewManager:getInstance():getBaseLayout()
    local children = {base_node:getChildren()}
    local index = 0  
    while index < #children do  
        index = index + 1  
        for k,v in pairs(children[index]) do
            if not tolua.isnull(v) then
                if v.getChildren then  
                    table.insert(children,v:getChildren())  
                end
            end
        end  
    end
    print(string.format("当前实际节点数:%d, 当前总节点:%d, 当前GM命令节点:%d", index - self:getButtonNodeTotal(), index, self:getButtonNodeTotal()))
end

function GmCmd:getButtonNodeTotal()
    local base_node = self.open_button
    local children = {base_node:getChildren()}
    local index = 0  
    while index < #children do  
        index = index + 1  
        for k,v in pairs(children[index]) do
            if not tolua.isnull(v) then
                if v.getChildren then  
                    table.insert(children,v:getChildren())  
                end
            end
        end  
    end
    return index
end

function GmCmd:saveResourcesList()
    local temp = SysEnv:getInstance():loadResourcesFile()
    local resources_list = ResourcesCacheMgr:getInstance():getLoadRes()
    local spine_list = __down_spine_list
    if temp == nil then temp = {} end

    -- 默认打包包里面的资源有:替代特效,替代模型,断线重连特效,包含推荐码的取名,取名,首充雅典娜图标特效,首充耶梦加得图标特效,登录页特效(亚瑟凯瑟琳,宙斯雅典娜,大祭司)
    local first_list = { "spine/E88888", "spine/H99999", "spine/E51006", "spine/E65004", "spine/E65012", "spine/E31316", "spine/E20986", 
        "spine/E50094", "spine/E51008", "spine/E50130", "fonts/", "csb/", 
        "shaders/", "sound/", "resource/platform/", "resource/item/", "resource/headicon/", "resource/strongericon/", "resource/headcircle/", 
        "resource/skillicon/", "resource/bufficon/", "resource/campicon/", "resource/bigbg/txt_cn_bigbg_20.png", "resource/bigbg/bigbg_3.png",
        "resource/functionicon/", "resource/honor"
    }

    local table_insert = table.insert

    local wait_add_list = {}
    -- 必定包含的
    for k,v in pairs(first_list) do
        table_insert(wait_add_list, v)
    end

    -- 动态下载的ui
    for k,v in pairs(resources_list) do
        table_insert(wait_add_list, v)
    end

    -- 动态下载的特效
    for k,v in pairs(spine_list) do
        local v_path = "spine/"..v
        table_insert(wait_add_list, v_path)
    end

    -- 全部添加进去
    for k,v in pairs(wait_add_list) do
        local can_add = true
        for i, path in ipairs(temp) do
            if v == path then
                can_add = false
                break
            end
        end
        if can_add == true then
            table_insert(temp, v)
        end
    end
    SysEnv:getInstance():saveResourcesFile(temp)
end

-- 调试贝塞尔曲线
function GmCmd:showBezierPos(  )
    if not self.bezierPanel then
        self.bezierPanel = AdjustBezierPanel.New()
    end
    if self.bezierPanel:isOpen() == false then
        self.bezierPanel:open()
    end
end

function GmCmd:random_click()    
    -- 旧的版本是没有这个的
    if cc.GLView.handleTouchesEnd == nil then return end

    if self.start_click == nil then
        self.start_click = false
    end

    local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    self.start_click = not self.start_click
    self.gm_editbox:setVisible(not self.start_click)
    if self.start_click == true then
        self.scroll_view:setVisible(false)
        if self.start_click_time == nil then
            self.start_click_time = GlobalTimeTicket:getInstance():add(function() 
                local x = math.random(0, framesize.width)
                local y = math.random(0, framesize.height)

                cc.Director:getInstance():getOpenGLView():handleTouchesEnd(x, framesize.height-y)
            end, 0.2)
        end
    else
        if self.start_click_time ~= nil then
            GlobalTimeTicket:getInstance():remove(self.start_click_time)
            self.start_click_time = nil
        end
    end
end

function GmCmd:savePhoto()
    local fileName = cc.FileUtils:getInstance():getWritablePath().."CaptureScreenTest.png"
    cc.utils:captureScreen(function(succeed)
        if succeed then
            saveImageToPhoto(fileName)
        else
            message("=====aaaaa")
        end
    end, fileName)
end

function GmCmd:wx_share()
    local fileName = cc.FileUtils:getInstance():getWritablePath().."CaptureScreenTest.png"
    cc.utils:captureScreen(function(succeed)
        if succeed then
            wx_scene = ((wx_scene or 0) + 1) % 2
            wxSharePhoto("title", "content", fileName, nil, wx_scene)
        else
            message("=====aaaaa")
        end
    end, fileName)
end

function GmCmd:checkInEmulator()
    local is_emulator_str = device.callFunc("inEmulator")
    if is_emulator_str ~= "" then
        local frist_letter = string.sub(is_emulator_str, 1, 1)
        if frist_letter == "1" then
            CommonAlert.show(TI18N("模拟器登录  ")..is_emulator_str, TI18N("确定"), nil, TI18N("取消"))
        else
            CommonAlert.show(TI18N("手机登录  ")..is_emulator_str, TI18N("确定"), nil, TI18N("取消"))
        end
    else
        message("旧版本一律认为是模拟器")
    end
end

function GmCmd:wx_share_url()
    local fileName = cc.FileUtils:getInstance():getWritablePath().."CaptureScreenTest.png"
    cc.utils:captureScreen(function(succeed)
        doRemoveFromParent(wx_image)
        wx_image = createImage(self.root_wnd, fileName, 100, 100)
        wx_image:setScale(0.2)
        if succeed then
            wx_scene = ((wx_scene or 0) + 1) % 2
            wxShareUrl("title", "content", "http://tech.qq.com/zt2012/tmtdecode/252.htm", fileName, wx_scene)
        else
            message("=====aaaaa")
        end
    end, fileName)
end

-- 打印当前计时器
function GmCmd:time_ticket()
    AudioManager:getInstance():showLoadMuiscPath()
    -- local list = GlobalTimeTicket:getInstance():getSchedulers()
    -- if list then
    --     Debug.info(list)
    -- end
end

-- 加qq群
function GmCmd:join_qq()
    QQ_GROUP_LIST = QQ_GROUP_LIST or {
        {ios="mqqapi://card/show_pslcard?src_type=internal&version=1&uin=431023033&key=6d9cdcb70ec56076639ca6faa535bafb4896680d47d4627e612e535944c94320&card_type=group&source=external"
        ,android="mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3D".."ItSajVspkR0fkSBeoH9dNr7qYFpMeOoG"}}
    joinQQGroup()
end
 
function GmCmd:reloadluafile()
    local requireList = NewModelFile or {}
    for k,v in pairs(requireList) do
        local require_name = requireList[k]
        if require_name then           
           if package.loaded[require_name]~=nil then           
                package.loaded[require_name] = nil
                require(require_name)
            end
        end
    end
end 

function GmCmd:takePhoto()
    display.removeUnusedTextures()

    -- callWebcamTakePhoto()
end

function GmCmd:dumpCachedTextureInfo()
    print(cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo())

    print(string.format("\n当前lua内存为 ====> %smb",math.floor(collectgarbage("count") / 1024)))
end

function GmCmd:battle_debug()
    require("game/battle/battle_debug")
    BattleDebug:getInstance()
end

function GmCmd:ui_debug()
    require("common/debug_ui_helper")
    DebugUIHelper:getInstance(self.open_button):open()
    self.scroll_view:setVisible(false)
end

function GmCmd:ui_var()
    require("common/debug_ui_var")
    DebugUIVar:getInstance():open()
    self.scroll_view:setVisible(false)
end

function GmCmd:showSysSize()
    message("当前内存为:"..device.sysTotalSize().."       "..EQUIPMENT_QUALITY)
end

function GmCmd:exitbattle()
    BattleController:getInstance():csFightExit()
end

function GmCmd:closeFPS()
    self.is_auto = not self.is_auto
    cc.Director:getInstance():setDisplayStats(self.is_auto)
end

function GmCmd:restart()
    -- local list = AudioManager:getInstance().effect_play_list
    -- Debug.info(list)
end

-- 断开网络
function GmCmd:stopNet()
    -- GameNet:getInstance():stopNetManager()
end

function GmCmd:restartNet()
   -- GameNet:getInstance():restartNetManager() 
end

function GmCmd:disconnect()
    GameNet:getInstance():DisconnectByClient(false)
end

function GmCmd:reconnect()
    -- DengluCtrl:getInstance().is_re_connect = true
    GameNet:getInstance():Connect()
end

function GmCmd:dumpTextureInfo( ... )
    local str = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
    local arr_tmp = Split(str, "\n")
    local args
    for _, v in pairs(arr_tmp) do 
        args = Split(v, "/res/")
        if #args>1 then
            local tmp_str = string.gsub(Split(v, "/res/")[2], '".+=>', " ")
            -- print(tmp_str)
        else
            -- print(v)
        end
    end
    for k, v in pairs(__spine_list) do print(k, v) end
    if tolua.isnull(self.rem_box) then
        GmCmd:dumpTextureInfo2()
        GlobalTimeTicket:getInstance():add(function()
            GmCmd:dumpTextureInfo2()
        end, xzy and 2 or 5, 0, "dumpTextureInfo_timer")
    else
        GlobalTimeTicket:getInstance():remove("dumpTextureInfo_timer")
        self.rem_box:removeFromParent()
        self.rem_box = nil
    end
end

function GmCmd:dumpTextureInfo2()
    local str = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
    local arr = {}
    local arr_tmp = Split(str, "\n")
    local scene_list = {}
    local leakage_spine = {}
    local scene_all = {}
    local resource_all = {}
    local resource_list = {}
    local final_str = ""

    local spine_all = {}
    local spine_str = {}
    local spine_num, free_spine = 0, 0
    for _, v in pairs(arr_tmp) do 
        if string.find(v, "spine") then
            args = Split(v, "/res/")
            local str = Split(Split(args[2], '"')[1], "/")[2]
            if not spine_str[str] then 
                spine_num = spine_num + 1
                table.insert(spine_all, str)
            end
            spine_str[str] = true
        elseif string.find(v, "scene") then
            args = Split(v, "/res/")
            local str = Split(Split(args[2], '"')[1], "/")[2]
            if tonumber(str) then
                if not scene_all[str] then 
                    table.insert(scene_list, str)
                end
                scene_all[str] = true
            end
        elseif string.find(v, "resource") then
            args = Split(v, "/res/")

            local resources_path = Split(args[2], '"')[1]
            if string.find(resources_path, ".jpg") or string.find(resources_path, ".png") then
                if not resource_all[resources_path] then 
                    table.insert(resource_list, resources_path)
                end
                resource_all[str] = true
            end
        end
    end
    collectgarbage("collect")
    local lua_rem = collectgarbage("count")
    local leakage_str = string.format("骨骼数据:[<div fontcolor=#ffff00>%s</div>]", table.concat(spine_all, ","))
    local spine_num_str = string.format("骨骼数量:[总个数<div fontcolor=#ffff00>%s</div>]", spine_num)
    local scene_str = string.format("场景数据:[<div fontcolor=#ffff00>%s</div>]", table.concat(scene_list, ","))
    local resource_str = string.format("UI数据:[<div fontcolor=#ffff00>%s</div>]", table.concat(resource_list, ",\n"))
    local text_info_str = string.format("当前纹理占用内存:<div fontcolor=#ffff00>%s</div>", Split(arr_tmp[#arr_tmp], " for ")[2])
    local lua_info_str = string.format("当前 LUA占用内存:<div fontcolor=#ffff00>%d KB </div>(%.2f MB)", lua_rem, lua_rem/1024)
    if not self.rem_box and self.open_button then 
        self.rem_box = createRichLabel(16, 70 , cc.p(0,0), cc.p(0,0), 0, 0, 400)
        self.open_button:getParent():addChild(self.rem_box)
        local back = ccui.Layout:create()
        back:setAnchorPoint(0,0)
        showLayoutRect(back)
        self.rem_box:addChild(back, -1)
        self.rem_box_back = back
        back:setTouchEnabled(true)
        back:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.moved then
                local pos = sender:getTouchMovePosition()
                self.rem_box:setPosition(pos)
            end
        end)
    end

    final_str = string.format("<div>内存管理监控 ver1.0.0\n%s\n%s\n%s\n%s\n%s\n%s</div>", 
                              leakage_str, spine_num_str, scene_str, resource_str, text_info_str, lua_info_str)
    if self.rem_box then
        self.rem_box:setString(final_str)
        self.rem_box_back:setContentSize(self.rem_box:getContentSize())
    end
end

-- 自动任务
function GmCmd:autoTask()
    -- IS_IN_TEST = not IS_IN_TEST
    -- SaveLocalData:getInstance():writeLuaData("is_in_test_mode", IS_IN_TEST)
    -- if IS_IN_TEST then 
    --     message("你已经开启自动任务状态")
    -- else
    --     cc.Director:getInstance():getScheduler():setTimeScale(1)
    --     message("你已经开关闭动任务状态")
    -- end
end

function GmCmd:time2Color(time, index)
    if time then
        if time < 10 then 
            return Config.ColorData.data_color3[1]
        elseif time < 50 then
            return Config.ColorData.data_color3[1]
        else
            return Config.ColorData.data_color3[1]
        end
    elseif index == 1 then
        return Config.ColorData.data_color3[5]
    else 
        return Config.ColorData.data_color3[1]
    end
end

-- 改变gm内容
function GmCmd:changeGm(index)
    local index2 = self.edit_list_index + index 
    if index2 > #self.edit_list then 
        index2 = 1
    elseif index2 < 1 then 
        index2 = #self.edit_list
    end
    self.edit_list_index = index2
    if self.edit_list[index2] then 
        self.gm_editbox:setText(self.edit_list[index2].msg)
    end
end

-- 自定义处理函数
-- gm命令输入
function GmCmd:gm_callback(pSender)
    local protocal = {}--ProtocalRulesMgr:getInstance():GetPrototype(10399)
    local msg = pSender:getText()
    protocal.msg = msg
    if msg ~= "" then
        if #self.edit_list > self.edit_max then 
            table.remove(self.edit_list, 1)
        end
        keydelete("msg", msg, self.edit_list)
        table.insert(self.edit_list, {msg=msg})

        SysEnv:getInstance():set(SysEnv.keys.gm_eidt_list, self.edit_list, true)

        self.edit_list_index = #self.edit_list
        if string.find(msg, "TC") ~= nil then 
            local cmd_head = tonumber(string.sub(msg, 3, 6))
                local layer = DebugProtocal.create(cmd_head)
                ViewManager:getInstance():getMainScene():addChild(layer, 999)
                return
        elseif string.find(msg, "@") ~= nil then 
            local str = string.sub(msg, 2, string.len(msg))
            if str == "showfps" then
                CC_SHOW_FPS = not CC_SHOW_FPS
                cc.Director:getInstance():setDisplayStats(CC_SHOW_FPS)
            elseif str == "cs" then
                local cur_time_type = MainSceneController:getInstance():getMainScene():getCurTimeType()
                local data_type = 6
                if cur_time_type == 1 then
                    data_type = 18
                else
                    data_type = 6
                end
	            MainSceneController:getInstance():changeMainCityTimeType(data_type)
                HomeworldController:getInstance():changeHomeTimeType(data_type)
            else
                loadstring(str)()
            end
            return
        elseif string.find( msg, "#" ) ~= nil then
            local str = string.sub(msg, 2, string.len(msg))
            cc.Director:getInstance():getScheduler():setTimeScale(tonumber(str))
            return
        elseif string.find( msg, "~" ) ~= nil then
            local str = string.sub(msg, 2, string.len(msg))
            GuideController:getInstance():startPlayGuide(true, tonumber(str), true)
            return
        elseif string.find( msg, "goto" ) ~= nil then
            local str = string.sub(msg, 5, string.len(msg))
            local arr_tmp = Split(str, ",")
            GlobalEvent:getInstance():Fire(BigworldEvent.GotoPosByGrid, tonumber(arr_tmp[1]), tonumber(arr_tmp[2]) )
            return
        elseif string.find(msg, "play") ~= nil then
            local action_name = string.sub(msg, 6)
            cc.Director:getInstance():getScheduler():setTimeScale(0.3)
            return
        elseif string.find(msg, "/") ~= nil then -- 重载指定文件
            local str = string.sub(msg, 2, string.len(msg))
            local str1 = string.gsub(str, "/", ".")
            package.loaded[str] = nil
            package.loaded[str1] = nil
            require(str)
            Debug.info("重载文件", str, str1)
            return
        end
        local firstChar = string.sub(msg, 1, 1)
        local num_2 = tonumber(string.sub(msg, 2, 6))
        local act = string.sub(msg, 8)
        local spine_type = SpineTypeByFristLetter[firstChar]
        if spine_type ~= nil and type(num_2) == "number" then 
            local action = (spine_type == 'role') and PlayerAction.DefaultStand or nil

            if string.len(act) < 3 then 
                act = nil
            else
                if action then 
                    if act == "stand2" then
                        action = PlayerAction.DefaultStand
                    else
                        action = act
                    end
                end
            end
            if spine_type == "hero" and act ~= PlayerAction.DefaultStand and act ~= "hurt" and act ~= "die" then 
                action = "other"
            end
            msg = string.sub(msg, 1, 6)
            json, atlas = PathTool.getSpineByName(msg, action) 
            if isFileExist(json) then
                local container = ccui.Widget:create()
                container:setContentSize(cc.size(100, 100))
                container:setAnchorPoint(cc.p(0.5, 0.5))
                container:setPosition(display.width/2, display.height/2)

                local spine = createSpineByName(msg, action)
                spine:setAnchorPoint(cc.p(0.5, 0.5))
                spine:setPosition(50, 50)
                container:addChild(spine)
                container.spine = spine
                local y_fix, scale_fix
                if firstChar == "E" then 
                    spine:setAnimation(0, PlayerAction.action, true)
                    y_fix = -200
                    scale_fix = 1
                else
                    spine:setAnimation(0, act or PlayerAction.DefaultStand, true)
                    y_fix = -50
                    scale_fix = 0
                end
                container.val = {0,0}
                DebugValue:addSlider(container, 50, y_fix, {["set_fun"]=function(val)
                    if val[1] == 2.5 then 
                        container.val[2] = container.val[2] + 1
                    else 
                        container.val[2] = 0
                    end
                    container.spine:setScale(val[1])
                end}, 1, {0.5, 2.5, 1})
                ViewManager:getInstance():getMainScene():addChild(container, 999)
                return
            end
        end
        local ok, data = pcall(function() return loadstring("return {"..msg.."}")() end)
        if ok and type(data) == 'table' and type(data[1]) == "number" then
            self.proto = self.proto or require("sys.net.proto_mate") or {}
            local sendmeta = self.proto.send[data[1]]
            if sendmeta then
                local f = function(meta, d)
                    local senddata = {}
                    for i, v in pairs(meta) do
                        if v.type == 'array' then
                            senddata[v.name] = f(v.fields, d[v.name] or d[i] or {})
                        elseif v.type == 'string' or v.type == "byte" then
                            senddata[v.name] = d[v.name] or d[i] or ""
                        else
                            senddata[v.name] = d[v.name] or d[i] or 0
                        end
                    end
                    return senddata
                end
                BaseController:SendProtocal(data[1],f(sendmeta, data[2] or {}))
                return
            end
        end
        print("gm===send", protocal.msg)
        BaseController:SendProtocal(10399,protocal)
    end
end

function GmCmd:f1()
    local layout = ViewManager:getInstance():getLayerByTag(ViewMgrTag.UI_TAG)
    local v = layout:isVisible()
    layout:setVisible(not v)
end

function GmCmd:f2()

end

function GmCmd:f3()
end

function GmCmd:f4()
    if not self.gm_print then
        __global_print = __global_print or {}
        self.gm_print = deepCopy(print)
        function print(...)
            if #__global_print > 50 then
                table.remove(__global_print, #__global_print)
            end
            table.insert(__global_print, 1, {...})
            self.gm_print(...)
        end
    end
    local function show_msg()
        local str = ""
        for index = 1, math.min(30, #__global_print) do 
            local str2 = ""
            for _, st in pairs(__global_print[index]) do 
                str2 =  str2 .. tostring(st) .. "    "
            end
            str = str .. str2 .. "\n"
        end

        ErrorMessage.show(str, "最近30条输出，每秒刷新")
    end
    local close_callback = function()
        GlobalTimeTicket:getInstance():remove("show_msg")
    end
    ErrorMessage:getInstance():setCloseCallBack(close_callback)
    show_msg()
    GlobalTimeTicket:getInstance():add(show_msg, 1, 0, "show_msg")
end

function GmCmd:f5()
    -- local layer = DebugProtocal.create(cmd_head)
    -- ViewManager:getInstance():getMainScene():addChild(layer, 999)
end


function GmCmd:sendCmd(msg)
    -- local protocal = ProtocalRulesMgr:getInstance():GetPrototype(10399)
    -- protocal.msg = msg
    -- BaseController:SendProtocal(protocal)
end

function GmCmd:f7()
    -- self:sendCmd("跳转场景 90001")
end

-- 热更
function GmCmd:hot_fix()
    for key, v in pairs(package.loaded) do 
        if string.find(key, "config") ~= nil or string.find(key, "game") ~= nil or string.find(key, "common") ~= nil then
            package.loaded[key] = nil
            require(key)
        end
    end
    message("热更游戏完成")
end

function GmCmd:debug_open(sender, event_type)
    -- setDebugMode()
    -- if DEBUG_MODE then 
    --     sender:setTitleText("debug已开")
    -- else
    --     sender:setTitleText("debug已关")
    -- end
end

-- 滤镜
function GmCmd:lj()
    if self.filter_list == nil then
        self.filter_list = filterTest()
    else 
        for _, v in pairs(self.filter_list) do 
            v:removeFromParent()
        end
        self.filter_list = nil
    end
end

-- ping网络
function GmCmd:net_ping()
    if self.ping_label == nil then
        self.ping_label = cc.Label:createWithTTF("100", DEFAULT_FONT, 16)
        self.ping_label:setTextColor(cc.c4b(255,0,0,255))
        self.ping_label:setAnchorPoint(1, 0)
        self.ping_label:setPosition(600, 20)
        ProtoMgr:RegisterCmdCallback(1198, "handle1198", self)
        self.open_button:addChild(self.ping_label, 100000)
    end
    if self.ping_timer_id then
        GlobalTimeTicket:getInstance():remove(self.ping_timer_id)
        self.ping_timer_id = nil
        self.ping_label:setVisible(false)
    else
        self.ping_label:setVisible(true)
        self.ping_timer_id = GlobalTimeTicket:getInstance():add(function()
            Send(1198, {time = self.get_ping_time()})
        end, 1)
    end
end

function GmCmd:get_ping_time()
    return math.ceil(os.clock() * 1000) + 1000000000
end

function GmCmd:handle1198(data)
    self.ping_label:setString(string.format("ms:%s,msg_len:%s", (self.get_ping_time() - data.time), List.Size(GameNet:getInstance().msg_list)))
end

-- 清空版本更新文件
function GmCmd:clearVerFile()
    restart(function() 
        __clear_ver_file = true
    end)
end

-- 添加按钮
function GmCmd:addButton(parent, name, x, y, scale, zorder, func, font_color)
    local button = ccui.Button:create()
    button:loadTextures(PathTool.getResFrame("common", "common_1017"), "", "", LOADTEXT_TYPE_PLIST)
    button:setTitleText(name)
    button:setTitleFontSize(18)
    button:setScale9Enabled(true)
    button:setTitleFontName(DEFAULT_FONT)
    button:setTitleColor(font_color or Config.ColorData.data_color3[1])
    button:setPosition(x, y)
    button:addTouchEventListener(function(sender, event_type)
        func(sender, event_type)
    end)
    parent:addChild(button, zorder or 0)
    return button
end

-- 输出一些table到gm命令框
function GmCmd:log(table)
    local str = SaveLocalData:writeLuaTable(table)
    self.gm_editbox:setText("@"..str)
end

function GmCmd:closeMe()
    local is_visible = self.open_button:isVisible()
    self.open_button:setVisible(not is_visible)

    -- ViewManager:getInstance():setLayerVisible( false, ViewMgrTag.DEBUG_TAG )
end

--==============================--
--desc:低消耗处理
--time:2017-08-10 10:52:29
--@return 
--==============================--
function GmCmd:initTouch()
    local layer = ViewManager:getInstance():getLayerByTag(ViewMgrTag.DEBUG_TAG)
    layer:setContentSize(display.width+4, display.height+4)
    layer:setAnchorPoint(0.5, 0.5)
    layer:setPosition(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
    layer:setTouchEnabled(true)
    layer:setSwallowTouches(false)
    delayRun(layer, LOW_PERFORMANCE_TIMEOUT, function()              -- 300秒后无操作进入静默模式
        self:setLowPerformance(true, layer)
    end)
    layer:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            local pos = sender:getTouchEndPosition()
            pos = sender:convertToNodeSpace(pos)
            self:showTouchEffect(layer, pos)
            
            self:setLowPerformance(false, layer)
            if layer and not tolua.isnull(layer) then
                layer:stopAllActions()
                delayRun(layer, LOW_PERFORMANCE_TIMEOUT, function()              -- 300秒后无操作进入静默模式
                    self:setLowPerformance(true, layer)
                end)
            end
        end
    end)
end
function GmCmd:setLowPerformance(bool, layer)
    if bool == self.last_status then return end 
    self.last_status = bool
    local fps = display.DEFAULT_FPS
    if bool then
        fps = display.DEFAULT_FPS / 2                       -- 降低帧数
        showLayoutRect(layer, 160)                          -- 变暗
        AudioManager:getInstance():pauseMusic()             -- 暂停音乐
        -- 这里释放掉一些不需要用的资源
		display.removeUnusedTextures()
    	collectgarbage("collect")
    else
        fps = display.DEFAULT_FPS                           -- 帧数恢复
        showLayoutRect(layer, 0)                            -- 变暗恢复
        AudioManager:getInstance():resumeMusic()            -- 音量恢复
    end
    -- if self.cur_fps ~= fps then
    --     self.cur_fps = fps
    --     cc.Director:getInstance():setAnimationInterval(1.0 / fps)
    -- end
end

function GmCmd:clearTouchEffect()
    if not tolua.isnull(self.touch_effect) then
        self.touch_effect:setVisible(false)
        self.touch_effect:clearTracks()
        self.touch_effect:runAction(cc.RemoveSelf:create(true))
        self.touch_effect = nil
    end
end

function GmCmd:showTouchEffect(layer, pos)
    self:clearTouchEffect()
    local function finish_callback(event)
        self:clearTouchEffect()
    end
    local res_id = Config.EffectData.data_effect_info[197]
    if res_id and res_id ~= "" then
        self.touch_effect = createEffectSpine( res_id, pos, cc.p(0.5,0.5), false, PlayerAction.action, finish_callback)
        if not tolua.isnull(layer) then
            layer:addChild(self.touch_effect)
        end
    end
end

function GmCmd:showConfigPanel(  )
    if not self.adjustConfigPanel then
        self.adjustConfigPanel = GmAdjustConfigPanel.New()
    end
    if self.adjustConfigPanel:isOpen() == false then
        self.adjustConfigPanel:open()
    end
end

--[[
    @desc: 打开相册 
    author:{author}
    time:2020-02-17 14:56:08
    @return:
]]
function GmCmd:openCustomWindow()
    MainuiController:getInstance():openCustomHeadImgWin(true)
end

--[[
    @desc: 打开相机
    author:{author}
    time:2020-02-17 14:56:18
    @return:
]]
function GmCmd:takePhot()
end

--[[
    @desc:拍照或者上传照片的返回,用于保存本地待审核的 
    author:{author}
    time:2020-02-17 15:00:27
    --@filepath: 
    @return:
]]
function GmCmd:uploadPhoto(filepath)
end
