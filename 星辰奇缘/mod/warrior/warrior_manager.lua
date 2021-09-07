 WarriorManager= WarriorManager or BaseClass(BaseManager)

function WarriorManager:__init()
    if WarriorManager.Instance ~= nil then
        return
    end
    WarriorManager.Instance = self
    self.THidePersons = "warriorshidepersons"
    self.model = WarriorModel.New()

    self:InitHandler()

    self.isHide = false
    self.pushTimes = 0
    self.hasLogin = false

    self.modeConfirmEvent = EventLib.New()
    self.updateFormationEvent = EventLib.New()
end

function WarriorManager:__delete()

end

function WarriorManager:InitHandler()
    self:AddNetHandler(14200, self.on14200)
    self:AddNetHandler(14201, self.on14201)
    self:AddNetHandler(14202, self.on14202)
    self:AddNetHandler(14203, self.on14203)
    self:AddNetHandler(14204, self.on14204)
    self:AddNetHandler(14205, self.on14205)
    self:AddNetHandler(14206, self.on14206)
    self:AddNetHandler(14207, self.on14207)
    self:AddNetHandler(14208, self.on14208)
    self:AddNetHandler(14209, self.on14209)
    self:AddNetHandler(14210, self.on14210)
    self:AddNetHandler(14212, self.on14212)
    self:AddNetHandler(14213, self.on14213)
    self:AddNetHandler(14214, self.on14214)
    self:AddNetHandler(14215, self.on14215)

    EventMgr.Instance:AddListener(event_name.scene_load, function()
        local mapId = SceneManager.Instance:CurrentMapId()
        -- if mapId == 51000 or mapId == 51001 then
        --     SceneManager.Instance.sceneElementsModel:Show_Role_Wing(false)
        -- else
        --     SceneManager.Instance.sceneElementsModel:Show_Role_Wing(true)
        -- end
        if mapId == 51001 then
            SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(PlayerPrefs.GetInt(self.THidePersons) == 1)
            self.model:EnterScene()
        else
            -- SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson) == true)
            self.model:ExitScene()
        end
    end)

    EventMgr.Instance:AddListener(event_name.role_level_change, function ()
        if SceneManager.Instance:CurrentMapId() ~= 51001 and SceneManager.Instance:CurrentMapId() ~= 51000 and (self.model.phase == 3) then
            self:OnPush()
        end
    end)
end

-- 获取勇士战场状态
function WarriorManager:send14200()
    --print("send14200")
    Connection.Instance:send(14200, {})
end

function WarriorManager:on14200(data)
    -- BaseUtils.dump(data, "勇士战场活动状态")
    AgendaManager.Instance:SetCurrLimitID(2010, data.phase == 3)
    if self.timerid ~= nil then
        LuaTimer.Delete(self.timerid)
        self.timerid = nil
    end
    self.model:SetStatus(data)
    if self.callback ~= nil then
        self.callback(data.phase)
        self:send14207()
    end
    if (data.phase > 2 and data.phase < 7)and (SceneManager.Instance:CurrentMapId() == 51001 or SceneManager.Instance:CurrentMapId() == 51000) then
        self.timerid = LuaTimer.Add(0, 1000, function() self:OnTick() end)
    else

    end

    if SceneManager.Instance:CurrentMapId() == 51001 then
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(PlayerPrefs.GetInt(self.THidePersons) == 1)
        self.model:EnterScene()
    else
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson) == true)
        self.model:ExitScene()
    end

    if data.phase == 0 or data.phase == 1 or data.phase == 2 then
        self.pushTimes = 0
    elseif data.phase == 3 then         -- 报名
        self:send14213()
        -- self:send14206()
    elseif data.phase == 4 then     -- 开打
        self:send14205()
        self:send14206()
        self:send14208()
    elseif data.phase == 5 then     -- 结算
        self.pushTimes = 0
        self:send14206()
        self:send14208()
    elseif data.phase == 6 then     -- 奖励
        self.pushTimes = 0
        self:send14206()
        self:send14209()
    end

    if self.model.phase == 6 then
        self.model.mode = 0
        self.hasLogin = false
        self.model.warriors = {}
        self.model.rankList = {}
    else
        self.hasLogin = true
    end

    local activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[104]
    activeIconData.id = iconData.id
    activeIconData.iconPath = iconData.res_name
    activeIconData.sort = iconData.sort
    activeIconData.lev = iconData.lev

    MainUIManager.Instance:DelAtiveIcon(104)
    if self.model.phase == 2 then
        activeIconData.text = TI18N("即将开启")
        activeIconData.clickCallBack = function() NoticeManager.Instance:FloatTipsByString(TI18N("活动即将开启，请留意活动公告")) end
        -- MainUIManager.Instance:AddAtiveIcon(activeIconData)
    elseif self.model.phase == 3 then
        if SceneManager.Instance:CurrentMapId() ~= 51001 and SceneManager.Instance:CurrentMapId() ~= 51000 then
            self:OnPush()
        end

        activeIconData.createCallBack = function(gameObject)
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(gameObject.transform)
                effectObject.transform.localScale = Vector3(1, 1, 1)
                effectObject.transform.localPosition = Vector3(-30,10,-100)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            end
            BaseEffectView.New({effectId = 20256, time = nil, callback = fun})
        end

        -- 暂时去除特效
        activeIconData.createCallBack = nil

        -- activeIconData.clickCallBack = function () self:send14201() end
        activeIconData.clickCallBack = function () self:CheckIn() end
        activeIconData.timestamp = self.model.restTime + Time.time
        activeIconData.timeoutCallBack = function () end
        MainUIManager.Instance:AddAtiveIcon(activeIconData)
    elseif self.model.phase == 4 or self.model.phase == 5 then
        -- activeIconData.clickCallBack = function() NoticeManager.Instance:FloatTipsByString(TI18N("报名时间已过，请留意下次活动公告")) end
        -- activeIconData.clickCallBack = function () self:send14201() end
        activeIconData.clickCallBack = function () self:CheckIn() end
        activeIconData.text = TI18N("进行中")
        MainUIManager.Instance:AddAtiveIcon(activeIconData)
    end
end

-- 报名
function WarriorManager:send14201()
    Connection.Instance:send(14201, {})
end

function WarriorManager:on14201(data)
    BaseUtils.dump(data, "勇士战场报名结果")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.op_code == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_desc_window)
        LuaTimer.Add(3000, function()
            self.model.mode = data.combat_mode or 1
            if self.model.descWin ~= nil and self.model.descWin.isOpen == true then
                self.model.descWin:DoEnd(self.model.mode)
            end
        end)
    end
end

-- 退出
function WarriorManager:send14202()
    self.model.mode = 0
    Connection.Instance:send(14202, {})
end

function WarriorManager:on14202(data)
    --BaseUtils.dump(data, "勇士战场退出结果")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 发起战斗
function WarriorManager:send14203(id, platform, zone_id)
    -- BaseUtils.dump({id = id, platform = platform, zone_id = zone_id})
    Connection.Instance:send(14203, {id = id, platform = platform, zone_id = zone_id})
end

function WarriorManager:on14203(data)
    --BaseUtils.dump(data, "发起战斗结果")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self:send14207()
end

-- 拾取单位
function WarriorManager:send14204(battle_id, id)
    Connection.Instance:send(14204, {battle_id = battle_id, id = id})
end

function WarriorManager:on14204(data)
    --BaseUtils.dump(data, "拾取单位结果")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self:send14209()
end

-- 神器信息
function WarriorManager:send14205()
    Connection.Instance:send(14205, {})
end

function WarriorManager:on14205(data)
    --BaseUtils.dump(data, "神器信息")
    if self.model.warrior_magic_buff == nil then
        self.model.warrior_magic_buff = {}
    end

    if data.warrior_magic_buff ~= nil then
        for _,v in pairs(data.warrior_magic_buff) do
            self.model.warrior_magic_buff[v.buff_id] = v
        end
    end

    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 战场信息
function WarriorManager:send14206()
    Connection.Instance:send(14206, {})
end

function WarriorManager:on14206(data)
    BaseUtils.dump(data, "战场信息")
    self.model.score1 = data.green_score
    self.model.score2 = data.white_score
    self.model.group_id = data.group_id
    self.model.field_id = data.id
    if self.model.mode ~= nil and self.model.mode > 0 and self.model.mode ~= data.combat_mode then
        self.model.mode = data.combat_mode or 0
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_desc_window)
    end
    self.model.mode = data.combat_mode or 0
    self.model:UpdateScores()
end

-- 个人信息
function WarriorManager:send14207()
  -- print("发送请求 14207 请求个人信息")
    Connection.Instance:send(14207, {})
end

function WarriorManager:on14207(data)
    --BaseUtils.dump(data, "个人信息")
    -- NoticeManager.Instance:FloatTipsByString("个人信息")
    local model = self.model
    model.revive = data.revive
    model.rank = data.rank
    model.score = data.score
    model.camp = data.camp

    local roledata = RoleManager.Instance.RoleData
    if model.warriors ~= nil then
        for _,v in pairs(model.warriors) do
            if roledata.id == v.id and roledata.zone_id == v.zone_id and roledata.platform == v.platform then
                v.score = model.score
                break
            end
        end
    end
end

-- 排行榜
function WarriorManager:send14208(callback)
    self.askAllPlayers = true
    if callback ~= nil then
        self.on14208_callback = callback
    end
    Connection.Instance:send(14208, {})
end

function WarriorManager:on14208(data)
    BaseUtils.dump(data, "on14208")
    local warriors = data.warrior
    local key = ""
    local model = self.model

    if self.askAllPlayers == true then
        if model.rankList == nil then
            model.rankList = {}
        end
        local i = 0
        for _,v in pairs(warriors) do
            i = i + 1
            model.rankList[i] = v
        end
        table.sort(model.rankList, function(a, b) return a.score > b.score end)
        if model.warriors == nil then
            model.warriors = {}
        end
        for i=1,3 do
            model.warriors[i] = model.rankList[i]
        end
        if self.on14208_callback ~= nil then
            self.on14208_callback()
            self.on14208_callback = nil
        end
    else
        if model.warriors == nil then
            model.warriors = {}
            self.askAllPlayers = false
            return
        end

        local notInMemory = true
        for _,v in pairs(warriors) do
            notInMemory = true
            local c = #model.warriors
            for i,v1 in pairs(model.warriors) do
                if v.id == v1.id and v.zone_id == v1.zone_id and v.platform == v1.platform then
                    notInMemory = false
                    if v.score > v1.score then
                        model.warriors[i] = v
                    end
                    break
                end
            end
            if notInMemory == true then
                c = c + 1
                model.warriors[c] = v
            end
        end
        local c = #model.warriors
        table.sort(model.warriors, function(a, b) return a.score > b.score end)
        if c > 3 then
            for i=4,c do
                model.warriors[i] = nil
            end
        end
    end
    self.askAllPlayers = false
end

-- 宝箱奖励信息
function WarriorManager:send14209()
    Connection.Instance:send(14209, {})
end

function WarriorManager:on14209(data)
    --BaseUtils.dump(data, "宝箱奖励信息")
    self.model.rewardNum = data.num
end

-- 观战（退出观战，发10706协议）
function WarriorManager:send14210()
    Connection.Instance:send(14210, {})
end

function WarriorManager:on14210(data)
    --BaseUtils.dump(data, "观战（退出观战，发10706协议）")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WarriorManager:on14212(data)
    print("接收14212")
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warrior_window, {data})
end

function WarriorManager:PickUnit(battle_id, id, base_id)
    if DataUnit.data_unit[base_id].fun_type == 19 then  -- 勇士战场
        self:send14204(battle_id, id)
    end
end

function WarriorManager:GetShieldKeeperName(time)
    if self.model.warrior_magic_buff == nil or self.model.warrior_magic_buff[21004] == nil then
        return TI18N("--:--后降临")
    elseif self.model.warrior_magic_buff[21004].status == 2 then
        return ColorHelper.Fill(ColorHelper.color[1], self.model.warrior_magic_buff[21004].owner_name)
    elseif self.model.warrior_magic_buff[21004].status == 1 then
        return ColorHelper.Fill(ColorHelper.color[5], TI18N("已掉落战场中"))
    else
        if self.model.warrior_magic_buff[21004].time - BaseUtils.BASE_TIME < 0 then
            return ColorHelper.Fill(ColorHelper.color[5], TI18N("已掉落战场中"))
        else
            return os.date(TI18N("%M:%S"), self.model.warrior_magic_buff[21004].time - BaseUtils.BASE_TIME)..TI18N("后降临")
        end
    end
end

function WarriorManager:GetSwordKeeperName(time)
    if self.model.warrior_magic_buff == nil or self.model.warrior_magic_buff[21003] == nil then
        return TI18N("--:--后降临")
    elseif self.model.warrior_magic_buff[21003].status == 2 then
        local camp = ""
        -- print(self.model.camp)
        if self.model.warrior_magic_buff[21003].camp == 1 then
            camp = TI18N("[青龙]")
        else
            camp = TI18N("[白虎]")
        end
        return ColorHelper.Fill(ColorHelper.color[1], self.model.warrior_magic_buff[21003].owner_name).."<color=#FFFF00>"..camp.."</color>"
    elseif self.model.warrior_magic_buff[21003].status == 1 then
        return ColorHelper.Fill(ColorHelper.color[5], TI18N("已掉落战场中"))
    else
        if self.model.warrior_magic_buff[21003].time - BaseUtils.BASE_TIME < 0 then
            return ColorHelper.Fill(ColorHelper.color[5], TI18N("已掉落战场中"))
        else
            return os.date("%M:%S", self.model.warrior_magic_buff[21003].time - BaseUtils.BASE_TIME)..TI18N("后降临")
        end
    end
end


function WarriorManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function WarriorManager:OnTick()
    if self.model.restTime ~= nil then
        if self.model.restTime > 0 then
            self.model.restTime = self.model.restTime - 1
        end
    end
end

function WarriorManager:OnPush()
    self.pushTimes = self.pushTimes + 1
    if self.pushTimes > 1 then
        return
    end
    local iconData = DataSystem.data_daily_icon[104]
    if RoleManager.Instance.RoleData.lev < iconData.lev then
        return
    end

    if ActivityManager.Instance:GetNoticeState(GlobalEumn.ActivityEumn.qualify) == false then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.content = TI18N("<color=#FFFF00>勇士战场</color>活动已开启，是否前往参加？")
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() self:send14201() end

        if RoleManager.Instance.RoleData.cross_type == 1 then
            -- 如果处在中央服，先回到本服在参加活动
            RoleManager.Instance.jump_over_call = function() self:send14201() end
            confirmData.sureCallback = SceneManager.Instance.quitCenter
            confirmData.content = TI18N("<color='#ffff00'>勇士战场</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？")
        end

        NoticeManager.Instance:ActiveConfirmTips(confirmData)
        ActivityManager.Instance:MarkNoticeState(GlobalEumn.ActivityEumn.qualify)
    end
end

function WarriorManager:OpenSettle(args)
    BaseUtils.dump(args)
    self.model:OpenSettle(args)
end

function WarriorManager:IsDead()
    return self.model.revive == 0
end

function WarriorManager:OnExit(type)
    local desc = ""
    if type == 1 then
        desc = TI18N("退出准备区域即取消报名，确定退出？ \n（准备阶段结束前可再次报名）")
    elseif type == 2 then
        desc = TI18N("退出后将无法获得阵营获胜奖励，是否退出？")
    end
    local confirmData = NoticeConfirmData.New()

    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = desc
    confirmData.sureLabel = TI18N("确认")
    confirmData.sureSecond = -1
    confirmData.cancelLabel = TI18N("取消")
    confirmData.cancelSecond = -1
    confirmData.sureCallback = function()
        --自动寻路到npc
        self:send14202()
    end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function WarriorManager:HidePersons()
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.isHide)
    -- local res = PlayerPrefs.GetInt(self.THidePersons)
    -- if res == nil then
    --     PlayerPrefs.SetInt(self.THidePersons, 0)
    -- else
    --     SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(res == 1)
    -- end
end

-- 活动报名 统一入口
function WarriorManager:CheckIn()
    if RoleManager.Instance.RoleData.cross_type == 1 then
        -- 如果处在中央服，先回到本服在参加活动
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        RoleManager.Instance.jump_over_call = function() self:send14201() end
        confirmData.sureCallback = SceneManager.Instance.quitCenter
        confirmData.content = TI18N("<color='#ffff00'>勇士战场</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？")
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        self:send14201()
    end
end

function WarriorManager:OpenDesc(args)
    self.model:OpenDesc(args)
end

function WarriorManager:RequestInitData()
    self.model.mode = 0
    self:send14200()
    self:send14215()
end

function WarriorManager:CheckRed()
    local red = (self.hasLogin ~= true)
    if red ~= true then
        red = red or (PetManager.Instance.model.battle_petdata == nil)
        if red ~= true then
            local num = 0
            for i,v in ipairs(FormationManager.Instance.guardList) do
                num = num + v.number
            end
            red = red or (num ~= 14)
        end
    end
    return red
end

function WarriorManager:send14213()
    Connection.Instance:send(14213, {})
end

function WarriorManager:on14213(data)
    BaseUtils.dump(data, "<color='#ff8800'>on14213</color>")
    if self.model.descWin ~= nil then
        LuaTimer.Add(3000, function() self.model.mode = data.combat_mode or 0 end)
    else
        self.model.mode = data.combat_mode or 0
    end
end

-- 出战宠物守护布阵 萌宠模式
function WarriorManager:send14214(pets, guards)
    BaseUtils.dump(pets, "pet")
    BaseUtils.dump(guards, "guards")
    Connection.Instance:send(14214, {pets = pets, guards = guards})
end

function WarriorManager:on14214(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 出战宠物守护布阵信息 萌宠模式
function WarriorManager:send14215()
    Connection.Instance:send(14215, {})
end

function WarriorManager:on14215(data)
    BaseUtils.dump(data, "<color='#88ff00'>on14215</color>")
    self.model.pos_list = self.model.pos_list or {}
    local idList = {}
    for pos,_ in pairs(self.model.pos_list) do
        table.insert(idList, pos)
    end
    for _,pos in ipairs(idList) do
        self.model.pos_list[pos] = nil
    end
    for _,v in ipairs(data.pets) do
        self.model.pos_list[v.pos] = v
    end
    for _,v in ipairs(data.guards) do
        self.model.pos_list[v.pos] = v
    end
    self.updateFormationEvent:Fire()
end

function WarriorManager:CheckBattlePet()
    local battle_pet = PetManager.Instance.model.battle_petdata or {}
    if battle_pet.base_id ~= nil then
        local pets = {}
        local isRepeat = false
        for i=3,4 do
            if self.model.pos_list[i] ~= nil and self.model.pos_list[i].id ~= nil then
                local pet = PetManager.Instance:GetPetById(self.model.pos_list[i].id) or {}
                if pet.base_id == battle_pet.base_id then
                    isRepeat = true
                elseif pet.id ~= nil and pet.id > 0 then
                    table.insert(pets, {pos = i, id = pet.id})
                end
            end
        end
        if isRepeat then
            self:send14214(pets, {})
        end
    end
end

