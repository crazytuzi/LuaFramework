-- ----------------------------------------------------------
-- GM命令实现 59
-- ----------------------------------------------------------
gm_cmd = {
}

-- 自定义控制台命令添加到gm_cmd.commands中c
-- 其中desc和func项为必须， args可选
-- args参数格式说明:
-- desc: 参数说明文字(必须项)
-- type: string|number 参数类型(必须项)
-- optional: true|false 该参数是否可选(不填的话默认为false)
-- range: 格式{max, min}，类型为数字时表示一个数字范围，类型为字符串时表示一个长度范围(可选项)
gm_cmd.commands = {
    printevent = {
        desc = "当前人物event",
        args = {

        },
        func = function()
            print(string.format("角色event:  %s ...", RoleManager.Instance.RoleData.event))
        end
    },

    sreasureChest = {
        desc = "找冒险宝箱",
        args = {

        },
        func = function()
            gm_cmd.findsreasurechest()

        end
    },
    speedup = {
        desc = "客户端加速运行",
        args = {
            {desc = "比例，有效范围0.1~10之间", type = "number", range = {0.1, 10}},
        },
        func = function(ratio)
            Cmd.speedup(tonumber(ratio))
        end
    },
    help = {
        desc = "显示帮助信息",
        args = {
            {desc = "关键字", type = "string", optional = true},
        },
        func = function(keyword)
            gm_cmd.help(keyword)
        end
    },
    env = {
        desc = "显示当前设备的环境信息",
        func = function()
            Cmd.env()
        end
    },
    role_info = {
        desc = "显示指定的角色信息",
        args = {
            {desc = "平台标识", type = "string", range = {3, 8}},
            {desc = "区号", type = "number", range = {1, 255}},
            {desc = "角色ID", type = "number", range = {1, 65535}},
        },
        func = function(platform, zone_id, role_id)
            print(string.format("测试角色 %s_%s_%s 的信息: ...", platform, zone_id, role_id))
        end
    },
    relogin = {
        desc = "重新登录",
        func = function()
            LoginManager.Instance:returnto_login(true)
        end
    },
    disconnect = {
        desc = "模拟断线",
        func = function()
            Connection.Instance:disconnect()
        end
    },
    auto = {
        desc = "循环悬赏",
        func = function()
            if gm_cmd.auto then
                NoticeManager.Instance:FloatTipsByString("悬赏老司机停车")
                gm_cmd.auto = false
            else
                NoticeManager.Instance:FloatTipsByString("悬赏老司机不停车模式启动，赏金猎人将会不鸟你")
                gm_cmd.auto = true
            end
        end
    },
    auto1 = {
        desc = "暴力上古",
        func = function()
            if gm_cmd.auto_ancient then
                NoticeManager.Instance:FloatTipsByString("上古老司机停车")
                gm_cmd.auto_ancient = false
                if gm_cmd.ancient_timer ~= nil then
                    LuaTimer.Delete(gm_cmd.ancient_timer)
                    gm_cmd.ancient_timer = nil
                end
            else
                NoticeManager.Instance:FloatTipsByString("暴力上古老司机启动，自动搜索当前地图的上古怪")
                gm_cmd.auto_ancient = true
                gm_cmd.ancient_timer = LuaTimer.Add(0, 2500, function()
                    if gm_cmd.auto_ancient == false then
                        return false
                    end
                    if (TeamManager.Instance:IsSelfCaptin()or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None) and (CombatManager.Instance.isFighting or SceneManager.Instance.sceneElementsModel.autopath_data ~= nil) then
                    else
                        local temp = {}
                        -- for uniqueid,npcView in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
                        --     if string.find(uniqueid, "_8") ~= nil and npcView.data.status ~= 2 then
                        --         table.insert(temp, uniqueid)
                        --     end
                        -- end

                        -- for uniqueid,npcData in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
                        --     if string.find(uniqueid, "_8") ~= nil and npcData.status ~= 2 then
                        --         table.insert(temp, uniqueid)
                        --     end
                        -- end
                        local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
                        for k,v in pairs(units) do
                            if v.unittype == SceneConstData.unittype_monster then
                                local baseData = DataUnit.data_unit[v.baseid]
                                if baseData.fun_type == SceneConstData.fun_type_treasure_ghost and v.status == 0 then
                                    -- SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(v.uniqueid)
                                    table.insert(temp, v.uniqueid)
                                end
                            end
                        end
                        if #temp > 0 then
                            local val = Random.Range(1, #temp)
                            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                            SceneManager.Instance.sceneElementsModel:Self_AutoPath(SceneManager.Instance:CurrentMapId(), temp[val])
                            return
                        end
                        NoticeManager.Instance:FloatTipsByString("当前地图没有上古怪,嫌我烦可以auto1关掉{face_1,10}")
                    end
                end)
            end
        end
    },
    auto2 = {
        desc = "循环任务链",
        func = function()
            if gm_cmd.auto2 then
                NoticeManager.Instance:FloatTipsByString("跑环老司机停车")
                gm_cmd.auto2 = false
                if gm_cmd.auto2_timer ~= nil then
                    LuaTimer.Delete(gm_cmd.auto2_timer)
                    gm_cmd.auto2_timer = nil
                end
            else
                NoticeManager.Instance:FloatTipsByString("跑环老司机开车嘟嘟嘟~~")
                gm_cmd.auto2 = true
                if gm_cmd.auto2_timer == nil then
                    gm_cmd.auto2_timer = LuaTimer.Add(0, 3000, function()
                        if not gm_cmd.auto2 then
                            return false
                        end
                        if (TeamManager.Instance:IsSelfCaptin()or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None) and (CombatManager.Instance.isFighting or SceneManager.Instance.sceneElementsModel.autopath_data ~= nil) then
                        else
                            QuestManager.Instance.model:DoChain()
                        end
                    end)
                end
            end
        end
    },
    auto3 = {
        desc = "疯狂挖宝图",
        func = function()
            if gm_cmd.auto3 then
                NoticeManager.Instance:FloatTipsByString("挖累了休息一下")
                gm_cmd.auto3 = false
                if gm_cmd.auto3_timer ~= nil then
                    LuaTimer.Delete(gm_cmd.auto3_timer)
                    gm_cmd.auto3_timer = nil
                end
            else
                NoticeManager.Instance:FloatTipsByString("疯狂挖宝图开始~~")
                gm_cmd.auto3 = true
                if gm_cmd.auto3_timer == nil then
                    gm_cmd.auto3_timer = LuaTimer.Add(0, 3000, function()
                        if not gm_cmd.auto3 then
                            return false
                        end
                        if not (TeamManager.Instance:IsSelfCaptin()or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None) and (CombatManager.Instance.isFighting or SceneManager.Instance.sceneElementsModel.autopath_data ~= nil) then
                        else
                            if BackpackManager.Instance:GetCurrentGirdNum() > 0 then
                                local item_list = BackpackManager.Instance:GetItemByBaseid(20052)
                                if #item_list > 0 then
                                    TreasuremapManager.Instance.model:use_treasuremap(item_list[1])
                                    return
                                end

                                item_list = BackpackManager.Instance:GetItemByBaseid(20053)
                                if #item_list > 0 then
                                    TreasuremapManager.Instance.model:use_treasuremap(item_list[1])
                                    return
                                end
                            end
                        end
                    end)
                end
            end
        end
    },
    floatTest = {
        desc = "上浮测试",
        func = function()
            NoticeManager.Instance:FlostTxtTest()
        end
    },
    startscenelog = {
        desc = "开始记录场景协议",
        func = function()
            Debug.Log("开始记录场景协议")
            SceneManager.Instance.sceneLog = {}
            SceneManager.Instance.sceneLogMark = true
        end
    },
    endscenelog = {
        desc = "停止记录场景协议",
        func = function()
            Debug.Log("停止记录场景协议")
            SceneManager.Instance.sceneLogMark = false
        end
    },
    outputscenelog = {
        desc = "打印记录场景协议",
        func = function()
            Debug.Log("打印记录场景协议")
            BaseUtils.dump(SceneManager.Instance.sceneLog, "场景协议记录")
        end
    },
    outputscenelogone = {
        desc = "打印关于某人的记录场景协议, 传入参数为角色名",
        args = {
            {desc = "角色名", type = "string", optional = true},
        },
        func = function(name)
            Debug.Log(string.format("打印记录场景协议, 角色名:%s", name))
            local data = SceneManager.Instance:FindSceneLogBuy(name)
            BaseUtils.dump(data, "场景协议记录")
        end
    },
    hg = {
        desc = "家园工具 生成格子",
        args = {
            {desc = "格子初始数据", type = "string", optional = true},
        },
        func = function(list)
            Log.Error("家园工具 生成格子")
            HomeManager.Instance:Utils_MakeGrid(list)
        end
    },
    screenshot = {
        desc = "截图测试",
        func = function(list)
            Log.Error("截图测试")
            BaseUtils.ScreenShot()
        end
    },
    printmap = {
        desc = "打印该地图所有可行走点",
        func = function()
            HomeManager.Instance:PrintMapGrid()
        end
    },
    printgrid = {
        desc = "转换像素坐标为格子坐标",
        args = {
            {desc = "x坐标", type = "number", range = {0, 10000}},
            {desc = "y坐标", type = "number", range = {0, 10000}},
        },
        func = function(x, y)
            HomeManager.Instance:PrintGrid(x, y)
        end
    },
    openwindow = {
        desc = "打开指定窗口",
        args = {
            {desc = "窗口id", type = "string", range = {0, 30000}},
            {desc = "窗口参数", type = "string", optional = true},
        },
        func = function(winId, args)
            local tab = nil
            if args ~= nil and args ~= "" then
                tab = BaseUtils.unserialize(args)
            end
            if WindowConfig.WinID[winId] ~= nil then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID[winId], tab)
            else
                WindowManager.Instance:OpenWindowById(tonumber(winId), tab)
            end
        end
    },
    showgrid = {
        desc = "显示家园格子",
        func = function()
            HomeManager.Instance.showGrid = true
        end
    },
    fastmove = {
        desc = "飞毛腿",
        func = function()
            if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
                SceneManager.Instance.sceneElementsModel.self_view.Speed = 1000 * SceneManager.Instance.sceneModel.mapsizeconvertvalue
            end
        end
    },
    showspeed = {
        desc = "打印玩家速度",
        func = function()
            if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
                Log.Error(tostring(SceneManager.Instance.sceneElementsModel.self_view.Speed / SceneManager.Instance.sceneModel.mapsizeconvertvalue))
            end
        end
    },
    showlooks = {
        desc = "打印玩家looks",
        func = function()
            if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
                BaseUtils.dump(SceneManager.Instance.sceneElementsModel.self_view.data.looks)
            end
        end
    },
    bigman = {
        desc = "变巨人",
        func = function()
            if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
                SceneManager.Instance.sceneElementsModel.self_view:SetScale(1.8)
            end
        end
    },
    killcombat = {
        desc = "干掉战斗场景",
        func = function()
            if CombatManager.Instance.controller ~= nil then
                CombatManager.Instance.controller:EndOfCombat()
            end
        end
    },
    lookmem = {
        desc = "查看前10个类",
        func = function()
            ctx:DoUnloadUnusedAssets()
            local currtime = Time.time
            local str = ""
            local temp = {}
            for k,v in pairs(MemoryCheckTable) do
                if v.time > 5 and currtime - v.time > 10 then
                    if temp[v.origin] == nil then
                        -- local str = ZTest.GetRef(k, "")
                        -- temp[v.origin] = {num = 0, ref = str}
                        temp[v.origin] = {num = 0}
                    end
                    temp[v.origin].num = temp[v.origin].num + 1
                end
            end
            local temp2 = {}
            for k,v in pairs(temp) do
                table.insert(temp2, {num = v.num, ref = v.ref, origin = k})
            end
            table.sort( temp2, function(a,b) return a.num > b.num end )
            for i,v in ipairs(temp2) do
                -- str = string.format("%s\n**\n数量：%s\n%s\n%s", str, v.num, v.origin, v.ref)
                str = string.format("%s\n**\n数量：%s\n%s", str, v.num, v.origin)
            end
            local savepath = "/tmp"
            if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
                savepath = ctx.ResourcesPath
            end
            LocalSaveManager.Instance:writeFile("MemoryCheck", str, savepath)
        end
    },
    maincamerasize = {
        desc = "设摄像机视野",
        args = {
            {desc = "size", type = "string"}
        },
        func = function(size)
            SceneManager.Instance.MainCamera.camera.orthographicSize = tonumber(size)
        end
    },
    test = {
        desc = "剧情测试",
        args = {
        },
        func = function()
            DramaManagerCli.Instance:ExquisiteShelf()
        end
    },
    cleancache = {
        desc = "清空缓存",
        args = {},
        func = function() gm_cmd.clean_cache() end
    },
    iphonex = {
        desc = "iPhoneX适配开关",
        args = {},
        func = function()
            MainUIManager.Instance.adaptIPhoneX = not MainUIManager.Instance.adaptIPhoneX
            MainUIManager.Instance:Switch()
        end
    },
    print_download_url = {
        desc = "输出远程下载的资源列表",
        args = {},
        func = function() 
            Log.Error("远程下载的资源列表:"..ctx.Download_Res_Url_List)
        end
    },
    vest_recharge_test = {
        desc = "请求马甲包计费点",
        args = {
            {desc = "name", type = "string"}
        },
        func = function(name) 
            ShopManager.Instance:send9957(name)
        end
    },
    combat_test = {
        desc = "战斗测试",
        args = {},
        func = function() 
            -- CombatManager.Instance:OnCombatTest()
            LuaTimer.Add(2000, function() CombatManager.Instance:On10778({ }) end)

            -- LuaTimer.Add(2000, function() GodsWarManager.Instance:On17962({ status = 1, team_name = "123asd" }) end)
        end
    },
    active_icon_test = {
        desc = "活动图标测试",
        args = {
            {desc = "iconId", type = "number"}
        },
        func = function(iconId) 
            local activeIconData = AtiveIconData.New()
            local iconData = DataSystem.data_daily_icon[tonumber(iconId)]
            activeIconData.id = iconData.id
            activeIconData.iconPath = iconData.res_name
            activeIconData.sort = iconData.sort
            activeIconData.lev = iconData.lev

            activeIconData.clickCallBack = function()
                NoticeManager.Instance:FloatTipsByString(TI18N("点击了图标"))
            end
            MainUIManager.Instance:AddAtiveIcon(activeIconData)
        end
    },
    web_delay = {
        desc = "模拟网络延迟",
        args = {
            {desc = "time", type = "number"}
        },
        func = function(time) 
            if time == nil then
                time = 1000
            end
            Connection.Instance.delayTime = tonumber(time)
        end
    },
    caton = {
        desc = "卡一卡(开1,关其它)",
        args = {
            {desc = "flag", type = "number"}
        },
        func = function(flag) 
             GmManager.Instance.caton = (flag == "1")
        end
    },
    test = {
        desc = "临时测试用gm，可是随意删改内容",
        args = {
        },
        func = function() 
            print(string.format( "峡谷图标时间戳：%s", CanYonManager.Instance.activity_time))
            print(string.format( "服务器时间：%s", BaseUtils.BASE_TIME))
        end
    },
    
}
-- 检查参数错误
local check_args = function(args_info, args)
    local err = {}
    for k, v in pairs(args_info) do
        if v.optional == true and args[k] == nil then
            -- 参数是一个可选项且为空，跳过
        elseif v.type == 'number' then
            local num = tonumber(args[k])
            if args[k] == nil then
                table.insert(err, string.format("缺少参数: %s\n", v.desc))
            elseif num == nil then
                table.insert(err, string.format("参数 %s 无效: 非数字\n", args[k]))
            elseif v.range ~= nil and (num < v.range[1] or num > v.range[2]) then
                table.insert(err, string.format("参数 %s 无效: 超出有效范围 %d ~ %d\n", args[k], v.range[1], v.range[2]))
            end
        elseif v.type == 'string' then
            local str = tostring(args[k])
            local len = string.len(str)
            if args[k] == nil then
                table.insert(err, string.format("缺少参数: %s\n", v.desc))
            elseif v.range ~= nil and (len < v.range[1] or len > v.range[2]) then
                table.insert(err, string.format("参数 %s 无效: 长度超出有效范围 %d ~ %d\n", args[k], v.range[1], v.range[2]))
            end
        end
    end
    return table.concat(err)
end

-- 初始化
gm_cmd.init = function()
    Connection.Instance:add_handler(9900, gm_cmd.on9900)
end

-- 处理帮助信息
gm_cmd.help = function(keyword)
    if keyword == nil then
        print("调用lua版控制台指令:[命令] [参数1] [参数2] ...")
        print("设用C#控制台指令:[类名].[方法名] [参数1] [参数2] ...")
        print("快捷键:F1显示/隐藏 F2改变尺寸 ctrl+n和ctrl+p浏览历史命令 ctrl+a和ctrl+e移动光标 ctrl+w和ctrl+k删除当前输入的内容")
    end
    for cmd, info in pairs(gm_cmd.commands) do
        if keyword ~= nil and string.find(cmd, keyword) == nil and string.find(info.desc, keyword) == nil then
            -- 查找不到指定关键词相关的命令
        else
            local text = {}
            table.insert(text, "<color=#393>" .. cmd .. "</color>")
            if info.args ~= nil then
                for _, v in pairs(info.args) do
                    local opt = ""
                    if v.optional then
                        opt = "(可选)"
                    end
                    table.insert(text, "[<color=#393>" .. v.desc .. opt .. "</color>]")
                end
            end
            table.insert(text, info.desc)
            print(table.concat(text))
        end
    end
end

-- 一键找冒险宝箱
gm_cmd.findsreasurechest = function()
    print("hahahha")
    local t = false
    for k,v in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do


        if v.baseData.fun_type == SceneConstData.fun_type_skill_prac_box and v.baseData.type == SceneConstData.unittype_pick then
            SceneManager.Instance.sceneElementsModel:ClickUnitObject(tostring(k))
            t = true
            break
        end
    end

    if t == false then
        for k,v in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
            if v.name == "冒险宝箱" then
                local id = BaseUtils.get_unique_npcid(v.id,v.battle_id)
                local p = SceneManager.Instance.sceneModel:transport_small_pos(v.x + 1, v.y)
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(p.x,p.y)
                t = true
                break
            end
        end
    end


    if t == false then
        NoticeManager.Instance:FloatTipsByString(TI18N("该地图已经没有冒险宝箱了"))
    end
end

-- 执行命令
gm_cmd.run = function(str)
    local cmd = nil
    local args = {}
    for token in string.gmatch(str, "%S+") do
        if cmd == nil then
            cmd = token
        else
            table.insert(args, token)
        end
    end

    -- gm命令特殊处理
    if cmd == "gm" then
        Connection.Instance:send(9900, {cmd = table.concat(args, " ")})
        return
    end
    -- 代码调试特殊处理
    if cmd == "run" then
        if #args > 0 then
            local program = ""
            for i,v in ipairs(args) do
                program = string.format("%s %s", program, v)
            end
            assert(loadstring(" return "..program))()
        end
        return
    end

    -- 热更模块
    if cmd == "hot" then
        if #args > 0 then
            if package.loaded[args[1]] ~= nil then
                package.loaded[args[1]] = nil
                require(args[1])
            else
                print("<color='#ffff00'>找不到该文件</color>")
            end
        end
        return
    end

    local info = gm_cmd.commands[cmd]
    if info == nil then
        for k,v in pairs(gm_cmd.commands) do
            if cmd == v.desc then
                info = v
            end
        end

        if info == nil then
            return
        end
    end

    if info.args == nil then
        info.func()
    else
        local err = check_args(info.args, args)
        if string.len(err) > 0 then
            print(err)
        else
            info.func(unpack(args))
        end
    end
end

-- 处理gm命令执行结果
gm_cmd.on9900 = function(data)
    print(data.msg)
    -- 刷新控制台显示
    -- GameContext.GetInstance().GameConsole:Reload()
end

gm_cmd.clean_cache = function(data)
    if not UtilsIO then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = TI18N("当前版本不支持该功能，需要安装最新应用")
        data.sureLabel = TI18N("确认")
        NoticeManager.Instance:ConfirmTips(data)
        return
    end

    if UtilsIO.CleanCache() then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = TI18N("清空完成，请重启游戏")
        data.sureLabel = TI18N("确认")
        data.sureCallback = function() Application.Quit() end
        NoticeManager.Instance:ConfirmTips(data)
        return
    else
    end
end
