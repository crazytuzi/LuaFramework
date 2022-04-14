-- 
-- @Author: LaoY
-- @Date:   2018-07-20 10:02:23
--

require('game.roleinfo.RequireRoleInfo')
RoleInfoController = RoleInfoController or class("RoleInfoController", BaseController)
local this = RoleInfoController

function RoleInfoController:ctor()
    RoleInfoController.Instance = self
    self.model = RoleInfoModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function RoleInfoController:dctor()
    if self.power_change_bind_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.power_change_bind_id)
        self.power_change_bind_id = nil
    end
    if self.lvel_change_bind_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.lvel_change_bind_id)
        self.lvel_change_bind_id = nil
    end
end

function RoleInfoController:GetInstance()
    if not RoleInfoController.Instance then
        RoleInfoController.new()
    end
    return RoleInfoController.Instance
end

function RoleInfoController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1100_role_pb"
    self:RegisterProtocal(proto.ROLE_DETAIL, self.HandleRoleDetail)
    self:RegisterProtocal(proto.ROLE_QUERY, self.HandleRoleQuery)
    --self:RegisterProtocal(proto.ROLE_SETPIC, self.HandleRoleSetpic)
    self:RegisterProtocal(proto.ROLE_RENAME, self.HandleRoleRename)
    self:RegisterProtocal(proto.ROLE_UPDATE, self.HandleRoleUpdate)
    self:RegisterProtocal(proto.ROLE_UPATTR, self.HandleRoleUpAttr)
    self:RegisterProtocal(proto.ROLE_REDOT, self.HandleRoleRedot)
    self:RegisterProtocal(proto.GAME_WORLDLV, self.HandleWorldLv);
    self:RegisterProtocal(proto.ICON_SETPIC, self.HandleSetIcon);

    -- 头衔
    self:RegisterProtocal(proto.JOBTITLE_UPLEVEL, self.HandleJobTitle)
end

function RoleInfoController:AddEvents()
    local function call_back(sub_id, fst_menu)
        --需要跳转标签栏
        sub_id = sub_id or 1
        if sub_id then
            lua_panelMgr:GetPanelOrCreate(RoleInfoPanel):Open(sub_id)
            --翅膀往后
            if fst_menu and sub_id > 1 then
                GlobalEvent:Brocast(MountEvent.MOUNT_OPEN_HUAXING, fst_menu)
            end
        end
    end
    GlobalEvent:AddListener(RoleInfoEvent.OpenRoleInfoPanel, call_back)

    local function call_back()
        local panel = lua_panelMgr:GetPanel(RoleInfoPanel)
        if panel then
            panel:Close()
        end
    end
    GlobalEvent:AddListener(RoleInfoEvent.CloseRoleInfoPanel, call_back)

    local callBack1 = function(subid)
        lua_panelMgr:GetPanelOrCreate(RoleInfoPanel):Open(tonumber(subid))
    end

    GlobalEvent:AddListener(MountEvent.OPEN_VISION_PANEL, callBack1)

    local function call_back()
        local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
        if not main_role_data or not main_role_data.figure.jobtitle or main_role_data.figure.jobtitle.model <= 0 then
            Notify.ShowText("You didn't reach required level yet")
            return
        end
        lua_panelMgr:OpenPanel(RoleTitlePanel)
    end
    GlobalEvent:AddListener(RoleInfoEvent.OpenRoleTitlePanel, call_back)

    --红点检查
    local function call_back()
        self:UpdateGoods()
    end
    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    local function callback(sys_key)
        if sys_key == "fashion" then
            self:RCheckRedPoint()
        end
    end
    GlobalEvent:AddListener(MainEvent.ChangeRedDot, callback)

    self.power_change_bind_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData("power", handler(self, self.RCheckRedPoint))
    local function callback(id)
        if id ~= "100@6" then
            return
        end
        self:RCheckRedPoint()
    end
    self.lvel_change_bind_id = GlobalEvent:AddListener(MainEvent.CheckLoadMainIcon, callback)

    local function call_back(role_id)
        lua_panelMgr:GetPanelOrCreate(OtherRoleInfoPanel):Open(role_id)
    end
    GlobalEvent:AddListener(RoleInfoEvent.OpenOtherInfoPanel, call_back)

    local function call_back(sceneId)
        self.model:ResetExpStatistics()
    end
    GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back);

    local function call_back()
        -- HttpManager.OpenUrl("https://www.wjx.cn/jq/52802335.aspx")
        --HttpManager.OpenUrl("https://menmen.wjx.cn/jq/52957029.aspx")
        HttpManager.OpenUrl("https://www.wjx.cn/jq/53857464.aspx")
    end
    GlobalEvent:AddListener(RoleInfoEvent.OpenQuestionnaire, call_back)

end

function RoleInfoController:UpdateGoods()
    self:RCheckRedPoint()
end

-- overwrite
function RoleInfoController:GameStart()
    self:RequestRoleDetail()
    GlobalSchedule.StartFunOnce(handler(self, self.CheckRedPoint), 3);
    --self:CheckRedPoint()



    -- local data = {
    --     afk_time = 120000,
    --     rewards = {
    --         [13109]    = 2,
    --         [13110]    = 1,
    --         [13111]    = 3,
    --         [13112]    = 9,
    --         [11120]    = 4,
    --         [90010001] = 1,
    --         [90010002] = 11118904404,
    --         [90010005] = 19000,
    --     },
    --     smelt_old = 1,
    --     smelt_new = 2,
    --     smelts = {
    --         [10000006] = 1,
    --         [10000007] = 1,
    --         [10000008] = 1,
    --         [10000009] = 1,
    --     },
    -- }

    -- local function step()
    --     lua_panelMgr:GetPanelOrCreate(AutoPlayRewardPanel):Open(data)
    -- end
    -- -- GlobalSchedule:StartOnce(step,10)

    -- local function step()
    --     for k,v in pairs(data.rewards or {}) do
    --         Notify.ShowGoods(k, v)
    --     end
    -- end
    -- -- GlobalSchedule:StartOnce(step,1)
    self:RequestWorldLevel()
    local function call_back()
        self:RequestWorldLevel()
    end
    GlobalSchedule:Start(call_back, 60)
end

function RoleInfoController:CheckRedPoint()
    if self.rschedule then
        GlobalSchedule.StopFun(self.rschedule);
    end
    self.rschedule = GlobalSchedule.StartFunOnce(handler(self, self.RCheckRedPoint), 0.1);
end

function RoleInfoController:RCheckRedPoint()
    self.model.red_dot_list[1] = false
    self.model.red_dot_list[2] = false
    self.model.red_dot_list[3] = false
    self.model.red_dot_list[4] = false

    if OpenTipModel.GetInstance():IsOpenSystem(100, 2) then
        for i, v in pairs(VisionPanel.WING_ENUM) do
            local nun = BagModel:GetInstance():GetItemNumByItemID(v);
            if nun > 0 then
                self.model.red_dot_list[2] = true
                break
            end
        end
    end
    if OpenTipModel.GetInstance():IsOpenSystem(100, 3) then
        for i, v in pairs(VisionPanel.FABAO_ENUM) do
            local nun = BagModel:GetInstance():GetItemNumByItemID(v);
            if nun > 0 then
                self.model.red_dot_list[3] = true
                break
            end
        end
    end
    if OpenTipModel.GetInstance():IsOpenSystem(100, 4) then
        -- roleLevel >= (GetSysOpenDataById("100@4") or 1)
        for i, v in pairs(VisionPanel.WEAPON_ENUM) do
            local nun = BagModel:GetInstance():GetItemNumByItemID(v);
            if nun > 0 then
                self.model.red_dot_list[4] = true
                break
            end
        end
    end

    ----头衔
    local role_data = RoleInfoModel.GetInstance():GetMainRoleData()
    if OpenTipModel.GetInstance():IsOpenSystem(100, 6) and role_data.figure.jobtitle then
        local cur_jobtitle = role_data.figure.jobtitle.model
        local cur_cf = Config.db_jobtitle[cur_jobtitle]
        local next_id = cur_cf.next_id
        --没有拉满
        local is_show = true
        if next_id ~= 0 then
            --local next_cf = Config.db_jobtitle[next_id]
            local temp_cost_tbl = String2Table(cur_cf.cost)
            local is_enough_mat = true
            local cost_tbl = {}
            if type(temp_cost_tbl[1]) == "number" then
                cost_tbl[1] = {}
                cost_tbl[1][1] = temp_cost_tbl[1]
                cost_tbl[1][2] = temp_cost_tbl[2]
            end
            for i, v in pairs(cost_tbl) do
                local num = BagModel.GetInstance():GetItemNumByItemID(v[1])
                if num < v[2] then
                    is_enough_mat = false
                    is_show = false
                    break
                end
            end
            --材料购
            if is_enough_mat then
                local cur_power = RoleInfoModel.GetInstance():GetRoleValue("power")
                local need_power = cur_cf.need_power
                if cur_power < need_power then
                    is_show = false
                end
            end
        else
            --拉满
            is_show = false
        end
        if is_show then
            self.model.red_dot_list[1] = true
        end
        self.model.is_show_jobtitle_rd = is_show
        self.model:Brocast(RoleInfoEvent.UpdateJobTitleRedDot)
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 13, is_show)
    end

    ----时装
    if OpenTipModel.GetInstance():IsOpenSystem(240, 1) then
        local is_show = FashionModel.GetInstance():IsHaveRD()
        if is_show then
            self.model.red_dot_list[1] = true
        end
        self.model.is_show_fashion_rd = is_show
        self.model:Brocast(RoleInfoEvent.UpdateFashionRedDot)
    end

    local isRed = false
    --for i = 1, #self.model.red_dot_list do
    --    if self.model.red_dot_list[i] then
    --        isRed = true
    --    end
    --end
    --变强
    local keyTab = {
        [2] = 5,
        [3] = 6,
        [4] = 7,
    }

    for i, v in pairs(self.model.red_dot_list) do
        if v or MountModel:GetInstance():GetReddotState(i, 2) then
            if i == 2 or i == 3 or i == 4 then
                isRed = true
            end
            --不要问我为什么加多个1，问就是德灵叫我的
            if i == 1 then
                isRed = true
            end
            GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, keyTab[i], true);
        else
            GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, keyTab[i], false);
        end
    end
    local _aaa, huaxing = MountModel:GetInstance():IsShowMainReddot();

    if (isRed or huaxing) then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "role_info", true);
    else
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "role_info", false);
    end

    GlobalEvent:Brocast(RoleInfoEvent.UpdateRedDot)

end

-- test
local request_time = 0
----请求基本信息
function RoleInfoController:RequestRoleDetail()
    request_time = Time.time
    -- Yzprint('--LaoY RoleInfoController.lua,line 43-- data=',request_time)
    local pb = self:GetPbObject("m_role_detail_tos")
    self:WriteMsg(proto.ROLE_DETAIL, pb)
end

function RoleInfoController:HandleRoleDetail()
    local data = self:ReadMsg("m_role_detail_toc")
    local mainrole_data = self.model.mainrole_data

    self.model.had_role_info = true

    if not mainrole_data then
        -- mainrole_data = MainRoleData:create(data.role)
        -- self.model.mainrole_data = mainrole_data
        -- SceneManager:GetInstance():CreateMainRole(mainrole_data.uid)
    else
        -- mainrole_data

        local object = SceneManager:GetInstance():GetObject(data.role.id)
        if object then
            Yzprint('--LaoY RoleInfoController.lua,line 174--', data)
            logError("服务端下发的其他角色列表包含了自己")
            SceneManager:GetInstance():RemoveObject(data.role.id)
        end

        local scene_info_data = SceneManager:GetInstance():GetSceneInfo()
        if scene_info_data and scene_info_data.actor and scene_info_data.actor.role then
            local role = scene_info_data.actor.role
            data.role.attr = data.role.attr or {}
            data.role.attr.hp = role.hp
            data.role.attr.hpmax = role.hpmax
            data.role.attr.speed = role.speed
        end
        mainrole_data:ChangeMessage(data.role, false)

        mainrole_data.zoneid = LoginModel.ZoneID
        mainrole_data.zonename = LoginModel.ZoneName

        SceneManager:GetInstance():SetObjectInfo(mainrole_data)
        SceneManager:GetInstance():CreateMainRole(mainrole_data.uid)
        SceneManager:GetInstance():SetMainRoleSceneInfo()

        if not AppConfig.Debug then
            if LoginModel:GetInstance().is_create_role then
                PlatformManager:GetInstance():uploadUserDataByRoleData(mainrole_data, 1)
            end
            PlatformManager:GetInstance():uploadUserDataByRoleData(mainrole_data, 2)
        end
    end
    self.model:Brocast(RoleInfoEvent.ReceiveRoleInfo)
    -- Yzprint('--LaoY RoleInfoController.lua,line 56--',Time.time - request_time)
    -- Yzdump(mainrole_data,"tab")

    LoginModel:GetInstance():InitFirstLanding()
end

function RoleInfoController:RequestRoleQuery(uid)
    local pb = self:GetPbObject("m_role_query_tos")
    pb.role_id = uid
    self:WriteMsg(proto.ROLE_QUERY, pb)
end

function RoleInfoController:HandleRoleQuery()
    local data = self:ReadMsg("m_role_query_toc")
    -- Yzprint('--LaoY RoleInfoController.lua,line 91--')
    -- Yzdump(data,"data")
    BrocastModelEvent(RoleInfoEvent.QUERY_OTHER_ROLE, nil, data)
    GlobalEvent:Brocast(RoleInfoEvent.QueryOtherRoleGlobal, data.role)
end

function RoleInfoController:RequestRoleSetpic()
    local pb = self:GetPbObject("m_role_setpic_tos")
    self:WriteMsg(proto.ROLE_SETPIC, pb)
end

function RoleInfoController:HandleRoleSetpic()
    local data = self:ReadMsg("m_role_setpic_toc")
    -- Yzprint('--LaoY RoleInfoController.lua,line 106--',data.pic_vsn)
    -- Yzdump(data,"data")
end

function RoleInfoController:RequestRoleRename(name)
    local pb = self:GetPbObject("m_role_rename_tos")
    pb.name = name
    self:WriteMsg(proto.ROLE_RENAME, pb)
end

function RoleInfoController:HandleRoleRename()
    local data = self:ReadMsg("m_role_rename_toc")
    Notify.ShowText("Name changed")
    -- Yzprint('--LaoY RoleInfoController.lua,line 117--')
    -- Yzdump(data,"data")
    GlobalEvent:Brocast(RoleInfoEvent.RoleReName, data.name)
end

function RoleInfoController:HandleRoleUpdate()
    local data = self:ReadMsg("m_role_update_toc")
    -- Yzprint('--LaoY RoleInfoController.lua,line 123--')
    -- Yzdump(data,"data")
    local mainrole_data = self.model:GetMainRoleData()
    if not mainrole_data then
        return
    end

    local old_power = mainrole_data.power
    local new_power = mainrole_data.power
    if data.upint.power then
        new_power = data.upint.power
    end
    for k, v in pairs(data.upint) do

        --local lastValue = mainrole_data:GetValue(k)
        mainrole_data:ChangeData(k, v, nil, new_power > old_power)

        -- 改到money里面了
        -- if k == "expadd" then
        --     --logError("old Value :" .. tostring(lastValue) .. " | New Value :" .. tostring(v))
        --     Notify.ShowExp(v, data.way)
        -- end

    end
    for k, v in pairs(data.upstr) do
        mainrole_data:ChangeData(k, v)
    end
    for k, v in pairs(data.aspect) do
        mainrole_data:ChangeData(k, v)
    end

    if not table.isempty(data.money) then
        ---Money飘字，要在合并数据前
        for k, v in pairs(data.money) do
            Notify.ShowMoney(k, v)
        end
        --local itemId, num = next(data.money)

        mainrole_data:ChangeData("money", data.money)
        local exp_add = data.money[enum.ITEM.ITEM_EXPADD]
        if exp_add then
            local cf = Config.db_scene[SceneManager:GetInstance():GetSceneId()]
            if cf and cf.stype == enum.SCENE_STYPE.SCENE_STYPE_CANDYROOM then
                FightManager:GetInstance():AddExpTextInfo(exp_add)
            else
                local percent = data.money[enum.ITEM.ITEM_EXPCOEF] or 0
                if (percent) then
                    percent = string.format("(+%d%%)", (percent + 10000) / 100)
                    Notify.ShowExp(exp_add, data.way, percent)
                end
            end
        end

        --经验统计
        if data.way == logConsumeDef.LOG_CREEP_DROP then
            --怪物掉落
            local exp = data.money[enum.ITEM.ITEM_EXPADD]
            if exp then
                local cf = Config.db_scene[SceneManager:GetInstance():GetSceneId()]
                if cf and cf.online == 1 then
                    self.model:UpdateExpStatistics(exp)
                    if self.model.isShowExp == false then
                        self.model:ShowExpStatistics(exp)
                    end
                end
            end

        end

    end
end

function RoleInfoController:HandleRoleUpAttr()
    if not self.model.had_role_info then
        return
    end
    local data = self:ReadMsg("m_role_upattr_toc")
    -- Yzprint('--LaoY RoleInfoController.lua,line 143--')
    -- Yzdump(data,"data")
    self.model:StartTimeUpdateAttr(data)
end

function RoleInfoController:HandleRoleRedot()
    local data = self:ReadMsg("m_role_redot_toc")
    -- Yzprint('--LaoY RoleInfoController.lua,line 138--')
    -- Yzdump(data,"data")
end

function RoleInfoController:RequestJobTitle()
    local pb = self:GetPbObject("m_jobtitle_uplevel_tos", "pb_1119_jobtitle_pb")
    self:WriteMsg(proto.JOBTITLE_UPLEVEL)
end

function RoleInfoController:HandleJobTitle()
    local data = self:ReadMsg("m_jobtitle_uplevel_toc", "pb_1119_jobtitle_pb")
    local mainrole_data = self.model:GetMainRoleData()
    Notify.ShowText("Promoted")
    if not mainrole_data then
        return
    end
    local t = {}
    t.model = data.id
    t.skin = mainrole_data.figure.jobtitle and mainrole_data.figure.jobtitle.skin or 0
    t.show = mainrole_data.figure.jobtitle and mainrole_data.figure.jobtitle.show
    mainrole_data:ChangeData("figure.jobtitle", t)
    self:RCheckRedPoint()
    GlobalEvent:Brocast(RoleInfoEvent.TitleName)
end

function RoleInfoController:RequestWorldLevel()
    local pb = self:GetPbObject("m_game_worldlv_tos", "pb_1000_game_pb");
    self:WriteMsg(proto.GAME_WORLDLV);
end

function RoleInfoController:HandleWorldLv()
    local data = self:ReadMsg("m_game_worldlv_toc", "pb_1000_game_pb");
    local level = data.level;
    self.model.world_level = level
    BrocastModelEvent(RoleInfoEvent.QUERY_WORLD_LEVEL, nil, level);
end

function RoleInfoController:RequestSetIcon(pic, md5)
    local pb = self:GetPbObject("m_icon_setpic_tos", "pb_1137_icon_pb");
    pb.pic = pic
    pb.md5 = md5
    self:WriteMsg(proto.ICON_SETPIC, pb);
end

function RoleInfoController:HandleSetIcon()
    local data = self:ReadMsg("m_icon_setpic_toc", "pb_1137_icon_pb");
    self.model:SetIconData(data.pic, data.md5)
    GlobalEvent:Brocast(MainEvent.UploadingIconSuccess)
end