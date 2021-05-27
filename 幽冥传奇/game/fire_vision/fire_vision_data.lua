--------------------------------------------------------
-- 烈焰幻境数据 配置 flamingFantasyCfg
--------------------------------------------------------

FireVisionData = FireVisionData or BaseClass()

FireVisionData.FIRE_VISION_DATA_CHANGE = "fire_vision_data_change"

function FireVisionData:__init()
	if FireVisionData.Instance then
		ErrorLog("[FireVisionData]:Attempt to create singleton twice!")
	end
	FireVisionData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.data = {
		num = 0,	-- 剩于击杀次数
		blessing = 0 ,	-- 祝福值
	}
	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.FireVisionCanPray)
end

function FireVisionData:__delete()
	FireVisionData.Instance = nil
end

----------烈焰幻境数据----------

-- 设置烈焰幻境数据
function FireVisionData:SetData(protocol)
	self.data.num = (1 - protocol.free_num) + protocol.pqy_num
	self.data.blessing = protocol.blessing

	if IS_ON_CROSSSERVER then
		RemindManager.Instance:DoRemindDelayTime(RemindName.FireVisionCanPray)
	end
	self:DispatchEvent(FireVisionData.FIRE_VISION_DATA_CHANGE)
end

-- 获取烈焰幻境数据(只需获取一次)
function FireVisionData:GetData()
	return self.data
end

--------------------

-- 获取烈焰幻境需要显示的物品
function FireVisionData.GetItemData()
	--获取显示配置
	local show_cfg = flamingFantasyCfg.item_list
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1)	-- 获取角色基础职业,默认是战士
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) -- 获取性别

	return show_cfg[prof][sex + 1]
end

----------红点提示----------

-- 获取提醒显示索引 0不显示红点, 1显示红点
function FireVisionData.GetRemindIndex()
	return FireVisionData.Instance.data.blessing
end

----------end----------