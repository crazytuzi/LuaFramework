--2016/7/14
--zzl
--暑假活动
SummerManager = SummerManager or BaseClass(BaseManager)

function SummerManager:__init()
    if SummerManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    SummerManager.Instance = self;
    self:InitHandler()
    self.model = SummerModel.New()

    self.isFirstRequestData = true

    self.childrensGroupData = {}
    self.npcDataSeekChild = {}

    self.redPointDataDic = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false
    } --model.tab_data_list里面的{id=true/false,}
end

function SummerManager:__delete()
    self.model:DeleteMe()
    self.model = nil

    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
end

function SummerManager:InitHandler()
    self:AddNetHandler(14021,self.on14021)
    self:AddNetHandler(14022,self.on14022)
    self:AddNetHandler(14023,self.on14023)
    self:AddNetHandler(14024,self.on14024)
    self:AddNetHandler(14025,self.on14025)
    self:AddNetHandler(14026,self.on14026)
    self:AddNetHandler(14027,self.on14027)
    self:AddNetHandler(14029,self.on14029)
    self:AddNetHandler(14030,self.on14030)

    self:AddNetHandler(14031,self.on14031)
    self:AddNetHandler(14032,self.on14032)
    self:AddNetHandler(14033,self.on14033)
    self:AddNetHandler(14034,self.on14034)
    self:AddNetHandler(14035,self.on14035)


    self:AddNetHandler(14036,self.on14036)
    self:AddNetHandler(14037,self.on14037)
end

--狂欢活动
function SummerManager:SetIcon()
    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
        return
    end
    local systemIcon = DataCampaign.data_camp_ico[CampaignEumn.Type.SummerActivity]
    MainUIManager.Instance:DelAtiveIcon3(307)

    local base_time = BaseUtils.BASE_TIME

    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.SummerActivity] == nil then
        return
    end

    if self.model:CheckHasGetAll() == false then
        self.activeIconData = AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[307]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev
        self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.summer_activity_window) end

        MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    end

    self:RequestData()
    SummerManager.Instance:request14021(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)

    SummerManager.Instance:request14027()

    self.on_item_update = function()
        self.redPointDataDic[1] = self:check_fruit_red_point() --检查水果种植的红点状态
        self:check_red_point()
    end
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)
end

function SummerManager:RequestData()
    -- -- print("-------3333333333333333333------------请求数据---------")
    self.request14032() -- 请求捉迷藏数据
    self.request14033() -- 请求捉迷藏单位
end

----------------------检查是否显示红点
--各个自功能检查是否图标需要显示红点
function SummerManager:check_red_point()
    local state = false

    state = self.redPointDataDic[1]
    state = state or self.redPointDataDic[3]
    state = state or self.redPointDataDic[4]

    local cfg_data = DataSystem.data_daily_icon[307]
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(cfg_data.id, state)
    end
end

--检查水果种植是否显示红点
function SummerManager:check_fruit_red_point()
    if self.model.fruit_plant_data == nil then
        return false
    end

    local state = false
    local count_time = 0
    if self.model.fruit_plant_data.end_time == 0 then
        --不在冷却之中
        local map_data_list = self.model.fruit_plant_data.list
        local all_finish = true
        for i=1,#map_data_list do
            local map_data = map_data_list[i]
            if map_data.status == 1 then
                all_finish = false
                local cfg_data = DataCampFruit.data_fruit_base[map_data.id]
                local left_time = map_data.start_time + cfg_data.cd - BaseUtils.BASE_TIME
                if left_time <= 0 then
                    state = true --可收获
                    break
                else
                    --还不可收获
                    if count_time == 0 then
                        count_time = left_time
                    else
                        if left_time < count_time then
                            count_time = left_time
                        end
                    end
                end
            elseif map_data.status == 0 then
                all_finish = false
                --还没种植，检查下是否有足够道具可以种植
                local cfg_data = DataCampFruit.data_fruit_base[map_data.id]
                local has_num = BackpackManager.Instance:GetItemCount(cfg_data.item_id)
                if has_num >= cfg_data.num then
                    state = true --够
                end
            end
        end
        if all_finish then
            state = true --可领奖
        end
    else
        state = false
        --在冷却之中
        local left_time = self.model.fruit_plant_data.end_time - BaseUtils.BASE_TIME

        count_time = left_time
        if left_time <= 0 then
            state = true
        end
    end

    if state == false then
        if count_time > 0 then
            LuaTimer.Add(count_time*1000, function()
                --再次检查红点
                self.redPointDataDic[1] = self:check_fruit_red_point() --检查水果种植的红点状态
                self:check_red_point()
            end)
        end
    end

    return state
end

--检查捉迷藏小孩红点逻辑
function SummerManager:check_seek_child_red_point()
    if self.childrensGroupData ~= nil and self.childrensGroupData.list ~= nil and #self.childrensGroupData.list == 5 and self.childrensGroupData.is_reward == 0 then
        return true
    end
    return false
end

--检查暑期登录红点逻辑
function SummerManager:check_summer_login_red_point()
    if self.model.summer_login_data == nil then
        return false
    end
    local state = false
    local key_days = {}
    local login_data = self.model.summer_login_data
    for i=1,#login_data.days do
        key_days[login_data.days[i].day] = login_data.days[i]
    end

    local data_list = {}
    for k, v in pairs(DataCampLogin.data_base) do
        if key_days[v.day] == nil and v.day <= login_data.num then
            state = true
            break
        end
    end
    return state
end

------接收协议逻辑
--水果种植数据
function SummerManager:on14021(data)
    print("1----------------------------收到14021")
    BaseUtils.dump(data)
    local temp_data = BaseUtils.copytab(data)
    if #temp_data.list == 0 then
        for i=1,6 do
            local plant_data = {}
            plant_data.id = i
            plant_data.status = 0
            plant_data.num = 0
            plant_data.need_num = 0
            plant_data.start_time = 0
            plant_data.end_time = 0
            plant_data.guilds = {}
            plant_data.friends = {}
            table.insert(temp_data.list, plant_data)
        end
    end
    self.model.fruit_plant_data = temp_data

    --检查下红点
    self.redPointDataDic[1] = self:check_fruit_red_point() --检查水果种植的红点状态
    self:check_red_point()
    EventMgr.Instance:Fire(event_name.summer_fruit_plant_update)

end


--水果种植好友求助
function SummerManager:on14022(data)
    -- print("1----------------------------收到14022")
    if data.flag == 0 then --失败

    else--成功
        self.model:CloseFruitHelpUI()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)

end

--水果种植
function SummerManager:on14023(data)
    -- print("1----------------------------收到14023")
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--帮助水果种植
function SummerManager:on14024(data)
    -- print("1----------------------------收到14024")
    if data.flag == 0 then --失败

    else--成功
        self.model:CloseFruitToHelpUI()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--水果种植收获
function SummerManager:on14025(data)
    -- print("1----------------------------收到14025")
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--水果种植领奖
function SummerManager:on14026(data)
    -- print("1----------------------------收到14026")
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--暑期登陆
function SummerManager:on14027(data)
    -- print("1----------------------------收到14027")
    self.model.summer_login_data = data
    self.redPointDataDic[3] = self:check_summer_login_red_point() --暑期登录
    self:check_red_point()
    EventMgr.Instance:Fire(event_name.summer_login_update, data)
    if self.model:CheckHasGetAll() then
        MainUIManager.Instance:DelAtiveIcon3(307)
    end
end


--暑期登陆领奖
function SummerManager:on14029(data)
    -- print("1----------------------------收到14029")
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--暑期登陆领奖
function SummerManager:on14030(data)
    -- print("1----------------------------收到14030")
    if data.flag == 0 then --失败

    else--成功

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
--捉迷藏领奖
function SummerManager:on14031(data)
    -- BaseUtils.dump(data,"SummerManager:on14031(data)")
end
--捉迷藏推送
function SummerManager:on14032(data)
    -- BaseUtils.dump(data,"SummerManager:on14032(data)")
    self.childrensGroupData = data
    self.redPointDataDic[4] = self:check_seek_child_red_point() --捉迷藏
    self:check_red_point()
    EventMgr.Instance:Fire(event_name.seek_child_finish_refresh)
    self.model:NpcState()

    CampaignManager.Instance.model.redPointList[737] = self:check_seek_child_red_point()
    CampaignManager.Instance.model:ReloadIconById(737)
    EventMgr.Instance:Fire(event_name.campaign_change)
end
--捉迷藏单位
function SummerManager:on14033(dataTemp)
    -- BaseUtils.dump(dataTemp,"SummerManager:on14033(dataTemp)")

    for i,data in ipairs(dataTemp.list) do

        self.npcDataSeekChild[data.base_id] = data

        local battleId = data.battle_id
        local unitId = data.u_id
        local baseId = data.base_id
        local x = data.x
        local y = data.y
        local mapId = data.map
        -- --取出单位配置数据
        -- local baseData = DataUnit.data_unit[data.base_id]
        -- --组装单位场景key id
        local uniquenpcid = BaseUtils.get_unique_npcid(data.u_id, data.battle_id)

        -- --模拟场景单位数据
        -- local data = {
        --     battle_id = battleId,
        --     id = unitId,
        --     base_id = baseId,
        --     type = baseData.type,
        --     name = baseData.name,
        --     status = 0,
        --     guide_lev = 0,
        --     speed = RoleManager.Instance.RoleData.speed,
        --     x = x,
        --     y = y,
        --     gx = 0,
        --     gy = 0,
        --     looks = {},
        --     prop = {},
        --     -- dir = SceneConstData.UnitFaceToIndex[dir + 1],
        --     -- sex = sex,
        --     -- classes = classes,
        --     -- action = SceneConstData.UnitActionStr[act],
        --     -- no_hide = true,
        -- }

        -- local npc = NpcData.New()
        -- npc:update_data(data)

        -- 在当前场景就创建，不在就只记录下来
        -- if mapId == SceneManager.Instance:CurrentMapId() then
        --     SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniquenpcid, npc, nil) -- 创建虚拟单位
        -- end

        --把新创建的单位加入到场景寻路信息表
        -- print(uniquenpcid)
        DataWorldNpc.data_world_npc[uniquenpcid] = {battleid = battleId, id = unitId, baseid = baseId , mapbaseid = mapId, posx = x, posy = y}
    end
end
--捉迷藏单位问询
function SummerManager:on14034(data)
    -- BaseUtils.dump(data,"SummerManager:on14034(data)")
end
--捉迷藏单位回复
function SummerManager:on14035(data)
    -- BaseUtils.dump(data,"SummerManager:on14035(data)")
end


--水果种植帮助返回数据
function SummerManager:on14036(data)
    -- print('---------------------------------------收到14036')
    -- BaseUtils.dump(data,"SummerManager:on14036(data)")

    local help_data = data
    SummerManager.Instance.model:InitFruitToHelpUI(help_data)
end
--捉迷藏单位激活
function SummerManager:on14037(data)
    -- BaseUtils.dump(data,"SummerManager:on14036(data)")
end


-----请求协议逻辑
--水果种植数据
function SummerManager:request14021(_id, _platform, _zone_id)
    -- print("1---------------------------------请求14021")
    Connection.Instance:send(14021, {id = _id, platform = _platform, zone_id = _zone_id})
end

--水果种植好友求助
function SummerManager:request14022(_type, _id, _friends)
    -- print("1---------------------------------请求14022")
    Connection.Instance:send(14022, {type = _type, id = _id, friends = _friends})
end


--水果种植
function SummerManager:request14023(_id)
    -- print("1---------------------------------请求14023")
    Connection.Instance:send(14023, {id = _id})
end


--帮助水果种植
function SummerManager:request14024(_r_id, _r_platform, _r_zone_id, _id, _type, _base_id, _num)
    -- print("1---------------------------------请求14024")
    Connection.Instance:send(14024, {r_id = _r_id, r_platform = _r_platform, r_zone_id = _r_zone_id, id = _id, type = _type, base_id = _base_id, num = _num})
end


--水果种植收获
function SummerManager:request14025(_id)
    -- print("1---------------------------------请求14025")
    Connection.Instance:send(14025, {id = _id})
end

--水果种植领奖
function SummerManager:request14026()
    -- print("1---------------------------------请求14026")
    Connection.Instance:send(14026, {})
end

--暑期登陆
function SummerManager:request14027()
    -- print("1---------------------------------请求14027")
    Connection.Instance:send(14027, {})
end


--暑期登陆领奖
function SummerManager:request14029(_day)
    -- print("1---------------------------------请求14029")
    Connection.Instance:send(14029, {day = _day})
end

--暑期登陆购买
function SummerManager:request14030(_id)
    -- print("1---------------------------------请求14030")
    Connection.Instance:send(14030, {id = _id})
end

--捉迷藏领奖
function SummerManager:request14031()
    Connection.Instance:send(14031, {})
end
--捉迷藏推送
function SummerManager:request14032()
    Connection.Instance:send(14032, {})
end
--捉迷藏单位
function SummerManager:request14033()
    Connection.Instance:send(14033, {})
end
--捉迷藏单位问询
function SummerManager:request14034(type,base_id,id,platform,zone_id)
    print(type.."--request14034--"..base_id)
    if id == nil then
        Connection.Instance:send(14034, {type = type,base_id = base_id,
             friends = {}
            })
    else
        Connection.Instance:send(14034, {type = type,base_id = base_id,
             friends = {{g_id = id,g_platform = platform,g_zone_id = zone_id}}
            })
    end
end
--捉迷藏单位回复
function SummerManager:request14035(type,base_id,id,platform,zone_id)
    print(type.."--request14035--"..base_id)
    if id == nil then
        Connection.Instance:send(14035, {type = type,base_id = base_id,
            friends = {},
        })
    else
        Connection.Instance:send(14035, {type = type,base_id = base_id,
            friends = {
                {g_id = id, g_platform = platform, g_zone_id = zone_id}
            },
        })
    end
end
--捉迷藏单位激活
function SummerManager:request14037(base_id)
    print("request14037 =="..base_id)
    Connection.Instance:send(14037, {base_id = base_id})
end