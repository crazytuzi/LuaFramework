-- ----------------------------------------------------------
-- 逻辑模块 - 职业转换
-- ----------------------------------------------------------
ClassesChangeManager = ClassesChangeManager or BaseClass(BaseManager)

function ClassesChangeManager:__init()
    if ClassesChangeManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	ClassesChangeManager.Instance = self

    self.model = ClassesChangeModel.New()

    self:InitHandler()

    self.isWash = false

    self.onTalisDataEvent = EventLib.New()
end

function ClassesChangeManager:__delete()

end

function ClassesChangeManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
   	self:AddNetHandler(10027, self.on10027)
    self:AddNetHandler(10028, self.on10028)
    self:AddNetHandler(10029, self.on10029)

    self:AddNetHandler(10039, self.on10039)
    self:AddNetHandler(10040, self.on10040)

    self:AddNetHandler(10625, self.on10625)
    self:AddNetHandler(10627, self.on10627)
    self:AddNetHandler(10628, self.on10628)
end

-------------------------------------------
-------------------------------------------
------------- 逻辑处理 -----------------
-------------------------------------------
-------------------------------------------

function ClassesChangeManager:RequestInitData()
    -- self:Send10500()
    self:Send10040()
end

function ClassesChangeManager:InitData()
    -- self.model.pet_nums = 5
    -- self.model.petlist = {}
    -- self.model.cur_petdata = nil
    -- self.model.battle_petdata = nil
    -- self.model.quickshow_petdata = nil
    -- self.model.isnotify_watch = false
    -- self.model.isnotify_watch_baobao = false
    -- self.model.select_gem = 1

    -- self.model.sure_useskillbook = false
    -- self.model.quickBuySkillBook = false
end

-- 请求转职价格
function ClassesChangeManager:Send10027(classes)
    -- print('------------------------------发送10027')
    Connection.Instance:send(10027, {classes = classes})
end

--请求转职价格
function ClassesChangeManager:on10027(data)
    -- print("-----------------------------收到10027")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        EventMgr.Instance:Fire(event_name.change_classes_price, data)
    end
end

-- 角色转职
function ClassesChangeManager:Send10028(classes,cost_type)
    -- print('------------------------------发送10028')
    Connection.Instance:send(10028, {classes = classes, cost_type = cost_type})
end

--角色转职通知（仅通知）
function ClassesChangeManager:on10028(data)
    print("-----------------------------收到10028")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then --成功
        EventMgr.Instance:Fire(event_name.change_classes_success, data)
        self.model.IsChangedStone = true
    end
end

--角色转职处理
function ClassesChangeManager:on10029(data)
	-- print("-----------------------------收到10029")
	-- BaseUtils.dump(data)
    RoleManager.Instance.RoleData.classes = data.classes
    RoleManager.Instance.RoleData.last_classes_modify_time = data.last_classes_modify_time
    RoleManager.Instance.RoleData.classes_modify_times = data.classes_modify_times
    -- BackpackManager.Instance.mainModel:DeleteMain()
    SkillManager.Instance.model:CloseSkillWindow()
    AutoFarmManager.Instance.model:DeleteMain()
    EncyclopediaManager.Instance:InitData()
    StrategyManager.Instance.model:DeleteWindow()
	EventMgr.Instance:Fire(event_name.change_classes, data)
end

--转换晶石
function ClassesChangeManager:Send10039()
    Connection.Instance:send(10039, {})
end
function ClassesChangeManager:on10039(data)
    --BaseUtils.dump(data,"on10039")
    local Querdata = data
    NoticeManager.Instance:FloatTipsByString(Querdata.msg)
    if Querdata.flag == 1 then
        self.model.IsChangedStone = true

    end
end

--请求上一职业 和是否转换过晶石
function ClassesChangeManager:Send10040()
    -- print("Send10040")
    Connection.Instance:send(10040, {})
end
function ClassesChangeManager:on10040(data)
    --BaseUtils.dump(data,"on10040")
    local Querdata = data
    if Querdata ~= nil then
        if Querdata.last_classes ~= 0 then
            self.model.lastClass = Querdata.last_classes
        end
        if Querdata.IsChangedStone == 1 then
            self.IsChangedStone = true
        elseif Querdata.IsChangedStone == 0 then
            self.IsChangedStone = false
        end
    end
end
-- 角色转职
function ClassesChangeManager:Send10625(id, hole_id, base_id)
    -- print('------------------------------发送10625')
    Connection.Instance:send(10625, {id = id, hole_id = hole_id, base_id = base_id})
end

--角色转职通知（仅通知）
function ClassesChangeManager:on10625(data)
    print("-----------------------------收到10625")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then --成功
        EventMgr.Instance:Fire(event_name.gem_change_success)
    else
        if self.model.gemChangeWindow ~= nil then
            MarketManager.Instance:send12416({ base_ids = { {base_id = 20800}, {base_id = 20801}, {base_id = 20802}, {base_id = 20803}, {base_id = 20804}, {base_id = 20805}, {base_id = 20806}, {base_id = 20807} } }, self.model.gemChangeWindow._on12416_callback)
        end
    end
end

--转职宝物列表请求
function ClassesChangeManager:Send10627()
    print("发送10627协议")
    Connection.Instance:send(10627, {})
end

function ClassesChangeManager:on10627(data)
    BaseUtils.dump(data,"on10627")
    if next(data) ~= nil then
        self.model.talisman_list = data.talisman_list
        self.model:SetTailsChangeData()
        self.onTalisDataEvent:Fire()
    end
end

--转职宝物切换
function ClassesChangeManager:Send10628(id, baseid, targetbaseid)
    print("发送10628协议--"..id.."--"..baseid.."--"..targetbaseid)
    Connection.Instance:send(10628, {id = id, base_id = baseid, target_base_id = targetbaseid})
end

function ClassesChangeManager:on10628(data)
    BaseUtils.dump(data,"on10628")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then --成功
        EventMgr.Instance:Fire(event_name.talis_change_success)
    end
end
