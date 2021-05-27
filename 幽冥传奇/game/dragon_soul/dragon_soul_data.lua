--------------------------------------------------------
-- 龙魂圣域数据 配置 dragonSoulSacredAreaCfg
--------------------------------------------------------

DragonSoulData = DragonSoulData or BaseClass()

DragonSoulData.DRAGON_SOUL_DATA_CHANGE = "dragon_soul_data_change"

function DragonSoulData:__init()
	if DragonSoulData.Instance then
		ErrorLog("[DragonSoulData]:Attempt to create singleton twice!")
	end
	DragonSoulData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.data = {
		num = 0,	-- 剩于击杀次数
		blessing = 0 ,	-- 祝福值
	}
	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.DragonSoulCanPray)
end

function DragonSoulData:__delete()
	DragonSoulData.Instance = nil
end

----------龙魂圣域数据----------

-- 设置龙魂圣域数据
function DragonSoulData:SetData(protocol)
	self.data.num = (1 - protocol.free_num) + protocol.pqy_num
	self.data.blessing = protocol.blessing

	if IS_ON_CROSSSERVER then
		RemindManager.Instance:DoRemindDelayTime(RemindName.DragonSoulCanPray)
	end
	self:DispatchEvent(DragonSoulData.DRAGON_SOUL_DATA_CHANGE)
end

-- 获取龙魂圣域数据(只需获取一次)
function DragonSoulData:GetData()
	return self.data
end

--------------------

-- 获取龙魂圣域需要显示的物品
function DragonSoulData.GetItemData()
	--获取显示配置
	local show_cfg = dragonSoulSacredAreaCfg.item_list
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1)	-- 获取角色基础职业,默认是战士
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) -- 获取性别

	return show_cfg[prof][sex + 1]
end

----------红点提示----------

-- 获取提醒显示索引 0不显示红点, 1显示红点
function DragonSoulData.GetRemindIndex()
	return DragonSoulData.Instance.data.blessing
end

----------end----------