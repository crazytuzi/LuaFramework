BuffPanelManager = BuffPanelManager or BaseClass(BaseManager)

function BuffPanelManager:__init()
    if BuffPanelManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    BuffPanelManager.Instance = self
    self:initHandle()
    self.model = BuffPanelModel.New()
end

function BuffPanelManager:initHandle()
    --[[self:AddNetHandler(11300, self.on11300)--]]
    self:AddNetHandler(12800, self.on12800)
    self:AddNetHandler(12801, self.on12801)
    self:AddNetHandler(12802, self.on12802)
    self:AddNetHandler(12803, self.on12803)
    self:AddNetHandler(12804, self.on12804)

    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function ()
        self:send12800()
    end)
end

function BuffPanelManager:on12800(data)
    -- BaseUtils.dump(data, "on12800")
    self.model.buffDic = nil
    self.model.buffDic = {}
    for i,v in ipairs(data.buff_list) do
        self.model.buffDic[v.id] = v
    end

    --构造饱食度buff
    local sBuff = {}
    sBuff.id = 99999            --buff_ID
    sBuff.duration = -1         --剩余时间
    sBuff.cancel = 0            --是否可取消
    sBuff.effect_lev = 1        --当前层次
    sBuff.start_time = 0        --开始时间
    sBuff.dynamic_attr = nil    --动态属性
    DataBuff.data_list[99999] = {id=99999,name = TI18N("饱食度"),icon = 10005,desc = TI18N("每场战斗消耗<color='#ffff00'>1</color>点，自动回复生命与魔法值\n<color='#ffff00'>野外挂机</color>每场战斗消耗0.5点")}
    sBuff.sort = 1
    self.model.buffDic[sBuff.id] = sBuff

    --构造双倍点数buff
    sBuff = {}
    sBuff.id = 99998            --buff_ID
    sBuff.duration = -1         --剩余时间
    sBuff.cancel = 0            --是否可取消
    sBuff.effect_lev = 1        --当前层次
    sBuff.start_time = 0        --开始时间
    sBuff.sort = 2
    sBuff.dynamic_attr = nil    --动态属性
    self.model.buffDic[sBuff.id] = sBuff

    --构造怒气值buff
    sBuff = {}
    sBuff.id = 100000            --buff_ID
    sBuff.duration = -1         --剩余时间
    sBuff.cancel = 0            --是否可取消
    sBuff.effect_lev = 1        --当前层次
    sBuff.start_time = 0        --开始时间
    sBuff.sort = 4
    sBuff.dynamic_attr = nil    --动态属性
    DataBuff.data_list[100000] = {id=100000,name = TI18N("怒气值"),icon = 21003,desc = TI18N("受到攻击或使用道具可以提升，用于使用觉醒技能")}
    self.model.buffDic[sBuff.id] = sBuff

    --构造能量值buff
    sBuff = {}
    sBuff.id = 100001            --buff_ID
    sBuff.duration = -1         --剩余时间
    sBuff.cancel = 0            --是否可取消
    sBuff.effect_lev = 1        --当前层次
    sBuff.sort = 3
    sBuff.start_time = 0        --开始时间
    sBuff.dynamic_attr = nil    --动态属性
    DataBuff.data_list[100001] = {id=100001,name = TI18N("翅膀特技能量"),icon = 21003,desc = TI18N("使用高阶翅膀技能时，将消耗特技能量，并发挥最大威力")}
    self.model.buffDic[sBuff.id] = sBuff

    --构造终极技能灵气buff
    sBuff = {}
    sBuff.id = 100002            --buff_ID
    sBuff.duration = -1         --剩余时间
    sBuff.cancel = 0            --是否可取消
    sBuff.effect_lev = 1        --当前层次
    sBuff.sort = 5
    sBuff.start_time = 0        --开始时间
    sBuff.dynamic_attr = nil    --动态属性
    DataBuff.data_list[100002] = {id=100002,name = TI18N("终极技能灵气"),icon = 21003,desc = TI18N("使用职业绝招时，将消耗技能灵气并发挥巨大作用")}
    self.model.buffDic[sBuff.id] = sBuff



    if RoleManager.Instance.RoleData.lev >= 30 then
        local sBuff = {}
        sBuff.id = 99996            --buff_ID
        sBuff.duration = -1         --剩余时间
        sBuff.cancel = 0            --是否可取消
        sBuff.effect_lev = 1        --当前层次
        sBuff.start_time = 0        --开始时间
        sBuff.dynamic_attr = nil    --动态属性
        sBuff.sort = 10
        DataBuff.data_list[99996] = {id=99996,name = TI18N("雕文效果"),icon = 12004,desc = "", icon_member == 10100}
        self.model.buffDic[sBuff.id] = sBuff

        local tempCfgData = DataBuff.data_list[31000]
        self.model.buffDic[tempCfgData.id] = tempCfgData

        local tempCfgData = DataBuff.data_list[31001]
        self.model.buffDic[tempCfgData.id] = tempCfgData
    end


    if SkillManager.Instance.model.finalSkill ~= nil and #SkillManager.Instance.model.finalSkill.skill_unique >0 then
        sBuff = {}
        sBuff.id = 100003            --buff_ID
        sBuff.duration = -1         --剩余时间
        sBuff.cancel = 0            --是否可取消
        sBuff.effect_lev = 1        --当前层次
        if self.model.buffDic[100003] == nil then
                sBuff.sort = nil
        else
            sBuff.sort = 6
        end

        sBuff.start_time = 0        --开始时间
        sBuff.dynamic_attr = nil    --动态属性
        DataBuff.data_list[100003] = {id=100003,name = TI18N("历练加成"),icon = 21003,desc = TI18N("获得妖精的祝福，参与各类活动可额外获得30%的<color='#ffff00'>历练值</color>")}
        self.model.buffDic[sBuff.id] = sBuff
    end

    StarChallengeManager.Instance.model:MakeBuff()
    ApocalypseLordManager.Instance.model:MakeBuff()

    EventMgr.Instance:Fire(event_name.buff_update)
end

function BuffPanelManager:on12801(data)
    -- BaseUtils.dump(data, "on12801")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function BuffPanelManager:on12802(data)
    -- BaseUtils.dump(data, "on12802")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        if data.show == 1 then
            SceneManager.Instance.sceneElementsModel:Show_Transform(true)
        else
            SceneManager.Instance.sceneElementsModel:Show_Transform(false)
        end
    end
end

function BuffPanelManager:on12803(data)
    -- BaseUtils.dump(data, "on12803")
    if data.show == 1 then
        SceneManager.Instance.sceneElementsModel.Show_Transform_Mark = true
    else
        SceneManager.Instance.sceneElementsModel.Show_Transform_Mark = false
    end
end

function BuffPanelManager:on12804(data)
    -- BaseUtils.dump(data, "on12804")

    local buffFata = DataBuff.data_list[data.base_id]
    if buffFata ~= nil and buffFata.item_base_id ~= 0 then
        local backpack_num = BackpackManager.Instance:GetItemCount(buffFata.item_base_id)
        -- print(backpack_num)
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.content = data.msg
        if backpack_num == 0 then
            confirmData.sureLabel = TI18N("前 往")
        else
            confirmData.sureLabel = TI18N("继续变身")
        end
        confirmData.cancelLabel = TI18N("取 消")
        confirmData.sureCallback = function()
            -- print(backpack_num)
            if backpack_num == 0 then
                ImproveManager.Instance.model:OpenMyWindow()
            else
                local itemDataList = BackpackManager.Instance:GetItemByBaseid(buffFata.item_base_id)
                -- BaseUtils.dump(itemDataList, "itemDataList")
                if #itemDataList > 0 then
                    local itemData = itemDataList[1]
                    BackpackManager.Instance:Send10315(itemData.id, 1)
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("没有该物品"))
                end
            end
        end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

function BuffPanelManager:send12800()
    Connection.Instance:send(12800, {})
end

function BuffPanelManager:send12801(idTemp)
    Connection.Instance:send(12801, {id = idTemp})
end

-- function FirstRecharge:send11303(id, num)
--     --print("·¢ËÍ11303")
--     Connection.Instance:send(11303,{["id"] = id, ["num"] = num})
-- end

function BuffPanelManager:send12802(show)
    Connection.Instance:send(12802, {flag = show})
end

function BuffPanelManager:send12803()
    Connection.Instance:send(12803, {})
end

function BuffPanelManager:HasBuff(id)
    if self.model.buffDic[id] ~= nil then
        return true
    end
    return false
end
