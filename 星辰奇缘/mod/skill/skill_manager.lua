-- ----------------------------------------------------------
-- 逻辑模块 - 技能
-- ----------------------------------------------------------
SkillManager = SkillManager or BaseClass(BaseManager)

Skilltype = {
    roleskill = 1
    , roletalent = 2
    , petskill = 3
    , shouhuskill = 4
    , marryskill = 5
    , rideskill = 6
    , wingskill = 7
    , endlessskill = 8
    , swornskill = 9
    , childskill = 10
    , childtelent = 11
    , talisman = 12
}
Skill_life_Sound = {
    [10001] = 254,
    [10005] = 255,
    [10006] = 255,
    [10000] = 253,
    [10007] = 252,
}

function SkillManager:__init()
    if SkillManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	SkillManager.Instance = self

    self.model = SkillModel.New()

    self.OnUpdateRoleSkill = EventLib.New()
    self.OnUpdatePracSkill = EventLib.New()
    self.OnUpdatePracSkillChestBox = EventLib.New()
    self.OnUpdateMarrySkill = EventLib.New()
    self.OnLearnFinalSkill = EventLib.New()
    self.OnGetFinalInfo = EventLib.New()
    self.OnUpdateSkillEnergy = EventLib.New()
    self.OnUpdateDoublePoint = EventLib.New()
    self.OnHideTips = EventLib.New()

    self:InitHandler()
    self.sq_point = 0
    self.finalSkillUp = false

    -- EventMgr.Instance:AddListener(event_name.socket_connect, function() self:onConnected() end)


    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function ()
        --判断活力值
        SkillManager.Instance.model:updateroleskill()
        EventMgr.Instance:AddListener(event_name.role_asset_change, function()
            SkillManager.Instance.model:updateroleskill()
        end)
        EventMgr.Instance:AddListener(event_name.backpack_item_change, function()
            SkillManager.Instance.model:updateroleskill()
        end)
    end)
end

function SkillManager:__delete()
    self.OnUpdateRoleSkill:DeleteMe()
    self.OnUpdateRoleSkill = nil
    self.OnUpdatePracSkill:DeleteMe()
    self.OnUpdatePracSkill = nil
end

function SkillManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(10800, self.On10800)
    self:AddNetHandler(10801, self.On10801)
    self:AddNetHandler(10802, self.On10802)
    self:AddNetHandler(10803, self.On10803)
    self:AddNetHandler(10804, self.On10804)
    self:AddNetHandler(10805, self.On10805)
    self:AddNetHandler(10806, self.On10806)
    self:AddNetHandler(10807, self.On10807)
    self:AddNetHandler(10808, self.On10808)
    self:AddNetHandler(10809, self.On10809)
    self:AddNetHandler(10810, self.On10810)
    self:AddNetHandler(10812, self.On10812)
    self:AddNetHandler(10813, self.On10813)
    self:AddNetHandler(10814, self.On10814)
    self:AddNetHandler(10815, self.On10815)
    self:AddNetHandler(10816, self.On10816)
    self:AddNetHandler(10817, self.On10817)
    self:AddNetHandler(10818, self.On10818)
    self:AddNetHandler(10819, self.On10819)
    self:AddNetHandler(10820, self.On10820)
    self:AddNetHandler(10821, self.On10821)
    self:AddNetHandler(10822, self.On10822)
    self:AddNetHandler(10823, self.On10823)
    self:AddNetHandler(10824, self.On10824)
    self:AddNetHandler(10825, self.On10825)
    self:AddNetHandler(10828, self.On10828)
    self:AddNetHandler(10829, self.On10829)
    self:AddNetHandler(10830, self.On10830)
    self:AddNetHandler(10833, self.On10833)
    self:AddNetHandler(10834, self.On10834)
    self:AddNetHandler(10835, self.On10835)
end

function SkillManager:Send10800()
    Connection.Instance:send(10800, { })
end

function SkillManager:On10800(data)
    self.model:On10800(data)
end

function SkillManager:Send10801(id)
    Connection.Instance:send(10801, { id = id })
end

function SkillManager:On10801(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        -- sound_player:PlayOption(228)
        SoundManager.Instance:Play(235)
    end
end

function SkillManager:On10802(data)
    self.model:On10802(data)
end

function SkillManager:Send10803()
    Connection.Instance:send(10803, { })
end

function SkillManager:On10803(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        -- sound_player:PlayOption(228)
    end
end

function SkillManager:Send10804()
    Connection.Instance:send(10804, { })
end

function SkillManager:On10804(data)
    self.model:On10804(data)
end

function SkillManager:Send10805()
    Connection.Instance:send(10805, { })
end

function SkillManager:On10805(data)
    -- BaseUtils.dump(data, "10805")
    self.model:On10805(data)
end

function SkillManager:Send10806(id)
    Connection.Instance:send(10806, { id = id})
end

function SkillManager:On10806(data)
    self.model:On10806(data)
end

function SkillManager:Send10807(id, num)
    Connection.Instance:send(10807, { id = id, num = num})
end

function SkillManager:On10807(data)
    self.model:On10807(data)
end

--请求生活技能数据
function SkillManager:Send10808()
    Connection.Instance:send(10808, {})
end

 --请求生活技能数据返回
function SkillManager:On10808(data)
    self.model:On10808(data)
end

function SkillManager:Send10809(_id)
    Connection.Instance:send(10809, { id = _id})
end

--使用生活技能
function SkillManager:Send10810(_id)
    if Skill_life_Sound[_id] ~= nil then
        SoundManager.Instance:Play(Skill_life_Sound[_id])
    end
    Connection.Instance:send(10810, { id = _id})
end

--使用生活技能
function SkillManager:On10810(data)
    local base_id = data.base_id
    if data.flag == 0 then --失败

    else --成功
        self.model:UpdateSkillLifeProduce()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--升级生活技能
function SkillManager:On10809(data)
    if data.flag == 0 then --失败
    else --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--获取冒险宝箱信息
function SkillManager:Send10812(_id, _battle_id)
    Connection.Instance:send(10812, { id = _id, battle_id = _battle_id})
end

--获取冒险宝箱信息
function SkillManager:On10812(data)
    self.model:On10812(data)
end

--获取冒险宝箱信息
function SkillManager:Send10813(_id, _battle_id)
    if self.model.chest_box_data ~= nil then
        self.model.chest_box_data.has_get = true
    end
    Connection.Instance:send(10813, { id = _id, battle_id = _battle_id})
end

 --抽取宝箱经验
function SkillManager:On10813(data)
    self.model:On10813(data)
end

--领取抽取宝箱经验
function SkillManager:Send10814()
    Connection.Instance:send(10814, {})
end

function SkillManager:On10814(data)
    if data.flag == 0 then --失败

        return
    else --成功
        self.model.chest_box_data = nil
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--生活技能升级10次
function SkillManager:Send10815(_id)
    Connection.Instance:send(10815, {id = _id})
end

--生活技能升级10次
function SkillManager:On10815(data)
    if data.flag == 0 then --失败
    else --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--使用生活技能（裁缝、打造）
function SkillManager:Send10816(_id, _base_id)
    -- -- print("----------------------------发送10816")
    if Skill_life_Sound[_id] ~= nil then
        SoundManager.Instance:Play(Skill_life_Sound[_id])
    end
    Connection.Instance:send(10816, {id = _id, base_id = _base_id})
end

--使用生活技能（裁缝、打造）
function SkillManager:On10816(data)
    -- -- print("---------------------------收到10816")
    if data.flag == 0 then --失败
    else --成功
    end
    -- print(data.base_id)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function SkillManager:Send10817(_id)
    Connection.Instance:send(10817, {id = _id})
end

function SkillManager:On10817(data)
    self.model:On10817(data)
end

function SkillManager:On10818(data)
    -- BaseUtils.dump(data, "On10818")
    self.model:On10818(data)
end

function SkillManager:Send10819()
    Connection.Instance:send(10819, {})
end

function SkillManager:On10819(data)
    if data.flag == 0 then
        self.model.skill_prac_redpoint = true
    elseif data.flag == 1 then
        self.model.skill_prac_redpoint = false
        EventMgr.Instance:Fire(event_name.backpack_item_change, {})
    end
end

function SkillManager:On10820(data)
    -- BaseUtils.dump(data, "On10820")
    self.model:On10820(data)
end

function SkillManager:Send10821(id)
    Connection.Instance:send(10821, {id = id})
end

function SkillManager:On10821(data)
    -- BaseUtils.dump(data, "On10821")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function SkillManager:Send10822()
    Connection.Instance:send(10822, { })
end

function SkillManager:On10822(data)
    -- BaseUtils.dump(data, "On10822")
    self.model:On10822(data)
end

function SkillManager:Send10823(id, num)
    Connection.Instance:send(10823, { id = id, num = num })
end

function SkillManager:On10823(data)
    self.model:On10823(data)
end

function SkillManager:Send10824(id, flag)
    Connection.Instance:send(10824, {id = id, flag = flag})
end

function SkillManager:On10824(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function SkillManager:Send10825()
    Connection.Instance:send(10825, {})
end

function SkillManager:On10825(data)
    -- BaseUtils.dump(data,"绝招技能")
    self.model.finalSkill = data
    self.OnGetFinalInfo:Fire()
end

function SkillManager:Send10828()
    Connection.Instance:send(10828, {})
end

function SkillManager:On10828(data)
    if self.is_open_sq_double == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已开启历练点数的使用{face_1,3}悬赏和挂野时获得双倍历练值"))
    elseif self.is_open_sq_double == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已关闭历练点数的使用{face_1,3}"))
    end
end

-- 领悟
function SkillManager:Send10829(id)
    Connection.Instance:send(10829, {skill_id = id})
end

function SkillManager:On10829(data)
    -- BaseUtils.dump(data,"领悟技能")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
        self.OnLearnFinalSkill:Fire()
        self.model:OpenFinalSkillGet()
    end
end

-- 升级
function SkillManager:Send10830(id)
    Connection.Instance:send(10830, {skill_id = id})
end

function SkillManager:On10830(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function SkillManager:Send10833()
    Connection.Instance:send(10833, {})
end

function SkillManager:On10833(data)
    -- BaseUtils.dump(data,"绝招灵气")
    self.sq_point = data.sq_point
    self.OnUpdateSkillEnergy:Fire(data.sq_point)
end

function SkillManager:Send10834()
    Connection.Instance:send(10834, {})
end

function SkillManager:On10834(data)
    -- BaseUtils.dump(data)
    self.sq_double = data.sq_double
    self.count = data.sq_exp_statistics
    self.actual = data.gain
    self.OnUpdateDoublePoint:Fire(data)
end


function SkillManager:Send10835()
    Connection.Instance:send(10835, {})
end

function SkillManager:On10835(data)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = "您的<color='#ffff00'>历练小精灵</color>已经离开了，将不再拥有30%历练值加成，是否前往继续补充"
    data.sureLabel = "前往查看"
    data.cancelLabel = "我再想想"
    data.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.exercisequickbuywindow) end
    data.showClose = 1
    data.cancelCallback = sure
    NoticeManager.Instance:ConfirmTips(data)
end

-------------------------------------------
-------------------------------------------
------------- 逻辑处理 -----------------
-------------------------------------------
-------------------------------------------

function SkillManager:RequestInitData()
    self.model:ReadPracSelect()
    self:Send10800()
    self:Send10804()
    self:Send10805()
    self:Send10819()
    self:Send10822()
    self:Send10825()
    self:Send10833()
    self:Send10834()
end

-------------------------------------
-------------------------------------
-------------------------------------
-------------------------------------
-- function SkillManager:TempLoad()
--     local func = function()
--     end
--     self.assestWrapper = AssetBatchWrapper.New()
--     local list = {
--         {file = AssetConfig.slot_skill}
--         -- ,{file = AssetConfig.skillIcon_role}
--         ,{file = AssetConfig.skillIcon_pet}
--     }
--     self.assestWrapper:LoadAssetBundle(list, func)
-- end

-- -- 获取prefab
-- function SkillManager:GetPrefab(file)
--     if self.assestWrapper ~= nil then
--         return self.assestWrapper:GetMainAsset(file)
--     else
--         return nil
--     end
-- end

function SkillManager:GetSkillType(id, lev)
    local key = CombatUtil.Key(id, lev)
    local skillCfg = nil
    local skilltype = Skilltype.roleskill
    local assestPath = ""
    if DataSkill.data_skill_role[key] ~= nil then
        skilltype = Skilltype.roleskill
        skillCfg = DataSkill.data_skill_role[key]
        if skillCfg.icon >= 69500 and skillCfg.icon <= 69999 then
            assestPath = string.format("textures/skilliconbig/roleskill/%s.unity3d", 7)
        else
            assestPath = string.format("textures/skilliconbig/roleskill/%s.unity3d", tostring(math.floor(skillCfg.icon/10000)))
        end
    elseif DataSkill.data_petSkill[key] ~= nil then
        skilltype = Skilltype.petskill
        skillCfg = DataSkill.data_petSkill[key]
        if skillCfg.icon < 60130 then
            -- assestPath = AssetConfig.skillIcon_pet
            assestPath = ""
        else
            -- assestPath = AssetConfig.skillIcon_pet2
            assestPath = ""
        end
    elseif DataSkill.data_skill_guard[key] ~= nil then
        skilltype = Skilltype.shouhuskill
        skillCfg = DataSkill.data_skill_guard[key]
        assestPath = AssetConfig.skillIcon_guard
    elseif DataSkill.data_skill_effect[id] ~= nil then
        skilltype = Skilltype.roleskill
        skillCfg = DataSkill.data_skill_effect[id]
    elseif DataSkill.data_skill_other[id] ~= nil then
        skilltype = Skilltype.endlessskill
        skillCfg = DataSkill.data_skill_other[id]
        assestPath = AssetConfig.skillIcon_endless
    elseif DataSkill.data_marry_skill[key] ~= nil then
        skilltype = Skilltype.marryskill
        skillCfg = DataSkill.data_marry_skill[key]
        assestPath = AssetConfig.skillIcon_roleother
    elseif DataSkill.data_wing_skill[key] ~= nil then
        skilltype = Skilltype.wingskill
        skillCfg = DataSkill.data_wing_skill[key]
        assestPath = AssetConfig.wing_skill
    elseif DataSkill.data_get_pet_stone[id] ~= nil then
        skillCfg = DataSkill.data_get_pet_stone[id]
    elseif DataSkill.data_mount_skill[key] ~= nil then
        skilltype = Skilltype.rideskill
        skillCfg = DataSkill.data_mount_skill[key]
        assestPath = AssetConfig.skillIcon_ride
    elseif DataSkill.data_endless_challenge[id] ~= nil then
        skilltype = Skilltype.endlessskill
        skillCfg = DataSkill.data_endless_challenge[id]
        assestPath = AssetConfig.skillIcon_endless
    elseif DataSkill.data_talisman_skill[key] ~= nil then
        skilltype = Skilltype.talisman
        local combatcfg = DataCombatSkill.data_combat_skill[key]
        skillCfg = DataSkill.data_talisman_skill[key]
        if combatcfg ~= nil then
            for k,v in pairs(combatcfg) do
                skillCfg[k] = v
            end
        end
        assestPath = AssetConfig.talisman_skill
    elseif DataSkill.data_child_skill[id] ~= nil then
        skilltype = Skilltype.childskill
        skillCfg = DataSkill.data_child_skill[id]
        assestPath = AssetConfig.childtelenticon
        if skillCfg.source == 1 then
            if skillCfg.icon >= 69500 and skillCfg.icon <= 69999 then
                assestPath = string.format("textures/skilliconbig/roleskill/%s.unity3d", 7)
            else
                assestPath = string.format("textures/skilliconbig/roleskill/%s.unity3d", tostring(math.floor(skillCfg.icon/10000)))
            end
        elseif skillCfg.source == 2 then
            if skillCfg.icon < 60130 then
                -- assestPath = AssetConfig.skillIcon_pet
                assestPath = ""
            else
                -- assestPath = AssetConfig.skillIcon_pet2
                assestPath = ""
            end
        end
    end
    local combatcfg = DataCombatSkill.data_combat_skill[key]
    if skillCfg ~= nil and combatcfg ~= nil then
        for k,v in pairs(combatcfg) do
            skillCfg[k] = v
        end
    end
    if skillCfg == nil and id == 1000 then
        skillCfg = {id = 1000, lev = 1, name = TI18N("普攻"), icon = 1000, step = 1, max_exp = 1, desc = TI18N("普攻"), cost_mp = 0}
    end
    return skilltype, skillCfg, assestPath
end

function SkillManager:NeedEnergyBuff()
    if self.model.finalSkill ~= nil and #self.model.finalSkill.skill_unique > 0 then
        return true
    end
    return false
end

function SkillManager:NeedExerciseBuff()
    if self.sq_double > BaseUtils.BASE_TIME then
        return true
    end
    return false
end