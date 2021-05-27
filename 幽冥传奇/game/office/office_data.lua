--------------------------------------------------------
-- 官职数据
--------------------------------------------------------

OfficeData = OfficeData or BaseClass()

OfficeData.OFFICE_LEVEL_CHANGE = "office_level_change"

function OfficeData:__init()
    if OfficeData.Instance then
		ErrorLog("[OfficeData]:Attempt to create singleton twice!")
	end
	OfficeData.Instance = self

    GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

    self.data = {
        level = 0,          -- 官职基础等级(从服务端发送过来的等级)
        phase = 1,          -- 官职阶数
        child_level = 0     -- 官职等级
    }

    -- 绑定红点提示触发条件
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.OfficeCanUp)
    -- 背包数据监听
    BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagDataChange))
end

function OfficeData:__delete()
    OfficeData.Instance = nil
    self.data = nil
end

----------官职数据----------

function OfficeData:SetOfficeResults(protocol)
    self.data.level = protocol.level

    -- 算出官职等级和官职阶数
    self.data.child_level = (protocol.level - 1) % 6
    self.data.phase = math.min((protocol.level - 1 - self.data.child_level) / 6 + 1, 12) -- 官职阶数

    if protocol.index == 3 then
        self:DispatchEvent(OfficeData.OFFICE_LEVEL_CHANGE)
    elseif protocol.index == 2 then
        self:DispatchEvent(OfficeData.OFFICE_LEVEL_CHANGE)
        RemindManager.Instance:DoRemindDelayTime(RemindName.OfficeCanUp) -- 激活时无物品消耗变化,修正红点提示
    end
end

-- 获取官职数据 .level总等级 .phase官职阶数 .child_level官职等级
function OfficeData:GetData()
    return self.data
end

-- 获取官职基础等级
function OfficeData:GetLevel()
    return self.data.level
end

-- 获取官职阶数
function OfficeData:GetPhase()
    return self.data.phase
end

-- 获取当前官职等级
function OfficeData:GetChildLevel()
    return self.data.child_level
end

----------end----------

----------红点提示----------

function OfficeData.OnBagDataChange()
    RemindManager.Instance:DoRemindDelayTime(RemindName.OfficeCanUp)
end

-- 获取提醒显示索引 0不显示红点, 1显示红点
function OfficeData.GetRemindIndex()
    local level = OfficeData.Instance:GetLevel()
    if level >= #office_cfg.level_list then return 0 end
    
    local item = office_cfg.level_list[level + 1].consume[1] -- 获取声望卷配置
    local item_num = BagData.Instance:GetItemNumInBagById(item.id, nil) --获取背包的经脉丹数量

    local index = item_num >= item.count and 1 or 0
    return index
end

----------end----------