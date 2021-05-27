ZsVipData = ZsVipData or BaseClass()

ZsVipData.INFO_CHANGE = "info_change"
function ZsVipData:__init()
	if ZsVipData.Instance then
		ErrorLog("[ZsVipData] attempt to create singleton twice!")
		return
	end
	--数据派发组件
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, function (vo)
		if vo.key == OBJ_ATTR.ACTOR_CUTTING_LEVEL then
			RemindManager.Instance:DoRemindDelayTime(RemindName.ZsVip)
		end
	end)

	ZsVipData.Instance = self
end

function ZsVipData:__delete()
	self.is_lingqu_t = nil
end

function ZsVipData:GetRewardRemind()
	return self:GetCanLingquPage() and 1 or 0
	-- return 1
end

function ZsVipData:GetCanLingquLeft(curr_idx)
	local can_lingqu_page = self:GetCanLingquPage()
	return can_lingqu_page and can_lingqu_page < curr_idx
end

function ZsVipData:GetCanLingquRight(curr_idx)
	local can_lingqu_page = self:GetCanLingquPage()
	return can_lingqu_page and can_lingqu_page >= curr_idx
end

function ZsVipData:SetFlag(free_flag, gold_flag)
	self.is_lingqu_t = {}
	for i = 1, #SVipConfig.SVipGrade do
		self.is_lingqu_t[i] = {}
		self.is_lingqu_t[i].is_lingqu_free = bit:_and(1, bit:_rshift(free_flag, i - 1)) == 1
		self.is_lingqu_t[i].is_lingqu_gold = bit:_and(1, bit:_rshift(gold_flag, i - 1)) == 1
	end
	RemindManager.Instance:DoRemindDelayTime(RemindName.ZsVip)
	self:DispatchEvent(ZsVipData.INFO_CHANGE, {})
	-- GameCondMgr.Instance:CheckCondType(GameCondType.IsHunHuanOpen)
	-- PrintTable(self.is_lingqu_t, level)
end

function ZsVipData:GetIsCanFreeLingQuByLv(lv)
	return not self.is_lingqu_t[lv].is_lingqu_free and self:GetZsVipPoint() >= SVipConfig.SVipGrade[lv].needYuanBao
end

function ZsVipData:GetIsFreeLingQuByLv(lv)
	if self.is_lingqu_t and self.is_lingqu_t[lv] then
		return self.is_lingqu_t[lv].is_lingqu_free
	end
end

function ZsVipData:GetIsBuyLingQuByLv(lv)
	if self.is_lingqu_t and self.is_lingqu_t[lv] then
		return self.is_lingqu_t[lv].is_lingqu_gold
	end
end

function ZsVipData:GetCanLingquPage()
	if nil == self.is_lingqu_t then return end
	for i,v in ipairs(self.is_lingqu_t) do
		if not v.is_lingqu_free and self:GetZsVipPoint() >= SVipConfig.SVipGrade[i].needYuanBao then
			return i
		end
	end
end

function ZsVipData:GetZsVipLv()
	return bit:_and(bit:_rshift(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CUTTING_LEVEL), 16), 0xffff)
end

function ZsVipData:GetZsVipPoint()
	return bit:merge64(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ZS_VIP_L), RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ZS_VIP_H))
end
