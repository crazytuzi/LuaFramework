-- @author 黄耀聪
-- @date 2017年3月17日

TalismanManager = TalismanManager or BaseClass(BaseManager)

function TalismanManager:__init()
    if TalismanManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    TalismanManager.Instance = self

    self.isShow = true

    self.model = TalismanModel.New()


    self.onUpdateFormulaEvent = EventLib.New()
    self.onUpdateNeddItemEvent = EventLib.New()
    self.onUpdateGridNumEvent = EventLib.New()

    self:InitHandler()
end

function TalismanManager:__delete()
end

function TalismanManager:InitHandler()
    self:AddNetHandler(19600, self.on19600)
    self:AddNetHandler(19601, self.on19601)
    self:AddNetHandler(19602, self.on19602)
    self:AddNetHandler(19603, self.on19603)
    self:AddNetHandler(19604, self.on19604)
    self:AddNetHandler(19605, self.on19605)
    self:AddNetHandler(19606, self.on19606)
    self:AddNetHandler(19607, self.on19607)
    self:AddNetHandler(19608, self.on19608)
    self:AddNetHandler(19609, self.on19609)
    self:AddNetHandler(19610, self.on19610)
    self:AddNetHandler(19611, self.on19611)
    self:AddNetHandler(19612, self.on19612)
end

-- ================================= 外部接口 =============================================

function TalismanManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function TalismanManager:OpenAbsorb(args)
    self.model:OpenAbsorb(args)
end

function TalismanManager:RequireInitData()
    self.model.old_fusion_val = nil
    self.model.old_fusion_lev = nil
    self.model.newItemId = {}

    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.talisman_absorb)
    self:send19600()
end

function TalismanManager:OpenFusion(args)
    self.model:OpenFusion(args)
end

-- 判断一件宝物是否正在被装备
function TalismanManager:IsSuting(base_id)
    return self.model:IsSuiting(base_id)
end

-- 获取激活的技能列表
function TalismanManager:GetSkillList()
    return self.model:GetSkillList()
end

-- ================================== 协议处理 ============================================

-- 查看法宝
function TalismanManager:send19600()
    Connection.Instance:send(19600, {})
end

function TalismanManager:on19600(data)
    --BaseUtils.dump(data, "<color='#ff0000'>on19600</color>")
    self.model.hasLockGridNum = data.volume
    self.model:SetBase(data)

    EventMgr.Instance:Fire(event_name.talisman_item_change)
end

-- 增加法宝
function TalismanManager:send19601()
    Connection.Instance:send(19601, {})
end

function TalismanManager:on19601(data)
    -- BaseUtils.dump(data, "on19601")
    -- self.model.newItemId = {}
    for i,v in ipairs(data.items) do
        self.model.itemDic[v.id] = v
        self.model.newItemId[v.id] = 1
    end
    self.isShow = false
    EventMgr.Instance:Fire(event_name.talisman_item_change)
end

-- 删除法宝
function TalismanManager:send19602()
    Connection.Instance:send(19602, {})
end

function TalismanManager:on19602(data)
    -- BaseUtils.dump(data, "on19602")
    for i,v in ipairs(data.items) do
        self.model.itemDic[v.id] = nil
    end
    EventMgr.Instance:Fire(event_name.talisman_item_change)
end

-- 更新法宝
function TalismanManager:send19603()
    Connection.Instance:send(19603, {})
end

function TalismanManager:on19603(data)
    -- BaseUtils.dump(data, "on19603")
    for i,v in ipairs(data.items) do
        self.model.itemDic[v.id] = v
    end
    EventMgr.Instance:Fire(event_name.talisman_item_change)
end

-- 熔炉更新
function TalismanManager:send19604()
    Connection.Instance:send(19604, {})
end

function TalismanManager:on19604(data)
    self.model.fusion_lev = data.fusion_lev
    self.model.fusion_val = data.fusion_val
    self.model.times = data.times
    self.model.fc = data.fc

    EventMgr.Instance:Fire(event_name.talisman_item_change)
end

-- 切换方案
function TalismanManager:send19605(plan)
    Connection.Instance:send(19605, {plan = plan})
end

function TalismanManager:on19605(data)
    self.model:UsePlan(data.use_plan)
    NoticeManager.Instance:FloatTipsByString(data.msg)

    EventMgr.Instance:Fire(event_name.talisman_item_change)
end

-- 熔化道具
function TalismanManager:send19606(items1, items2)
    Connection.Instance:send(19606, {items1 = items1, items2 = items2})
end

function TalismanManager:on19606(data)
    -- BaseUtils.dump(data, "on19606")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 吸收法宝
function TalismanManager:send19607(id1, flag1, id2, flag2)
    local dst_flags = {}
    local src_flags = {}
    for i, v in ipairs(flag1) do
        table.insert(dst_flags, { flag1 = v })
    end
    for i, v in ipairs(flag2) do
        table.insert(src_flags, { flag2 = v })
    end
    local data = {id1 = id1, dst_flags = dst_flags, id2 = id2, src_flags = src_flags}
    Connection.Instance:send(19607, data)
end

function TalismanManager:on19607(data)
    -- BaseUtils.dump(data, "on19607")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.talisman_window, {1})
    if data.flag == 1 then
        -- TipsManager.Instance:ShowTalismanAttr({attrNow = {name = data.name1, type = data.type1, flag = data.flag1, val = data.val1}, attrOrigin = {name = data.name2, type = data.type2, flag = data.flag2, val = data.val2}})
        TipsManager.Instance:ShowTalismanAttr({attrNow = data.attr_info1, attrOrigin = data.attr_info2})
    end
end

-- 装备法宝
function TalismanManager:send19608(id)
    -- print("send19608")
    self.model.isChanging = true
    Connection.Instance:send(19608, {id = id})
end

function TalismanManager:on19608(data)
    -- BaseUtils.dump(data, "on19608")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        self.model:SetBase(data)
    end
    EventMgr.Instance:Fire(event_name.talisman_item_change)
    self.model.isChanging = false
end

-- 卸下法宝
function TalismanManager:send19609(type)
    -- print("send19609")
    self.model.isChanging = true
    Connection.Instance:send(19609, {type = type})
end

function TalismanManager:on19609(data)
    -- BaseUtils.dump(data, "on19609")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        self.model:SetBase(data)
    end
    EventMgr.Instance:Fire(event_name.talisman_item_change)
    self.model.isChanging = false
end

-- 请求法宝配方表
function TalismanManager:send19610()
    -- print("send19610")
    Connection.Instance:send(19610, {})
end

function TalismanManager:on19610(data)
    -- BaseUtils.dump(data, "on19610")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data ~= nil then
        self.model.formula_list = data.formula
    end
    self.onUpdateFormulaEvent:Fire()
end

-- 重塑宝物
function TalismanManager:send19611(args)
    -- print("send19611")
    Connection.Instance:send(19611, args)
end

function TalismanManager:on19611(data)
    -- BaseUtils.dump(data, "on19611")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        local args = { }
        args.item_list = {{base_id = data.id ,num = 1}}
        LuaTimer.Add(1200,function() self.model:OpenGiftShow(args) end)
        self.model.initStatus = true
        self:send19610()
        EventMgr.Instance:Fire(event_name.talisman_item_change)
    end
end

--宝物背包扩充
function TalismanManager:send19612(data)
    --print("发送19612协议")
    Connection.Instance:send(19612, {})
end

function TalismanManager:on19612(data)
    --BaseUtils.dump(data, "on19612")
    if data ~= nil then
        self.model.hasLockGridNum = data.volume
        self.onUpdateGridNumEvent:Fire()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
