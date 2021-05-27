PersonalBossData = PersonalBossData or BaseClass()

function PersonalBossData:__init()
	if PersonalBossData.Instance then
		ErrorLog("[PersonalBossData]:Attempt to create singleton twice!")
	end
	PersonalBossData.Instance = self
	self.personal_boss_list = nil

	--keytest
	-- GlobalEventSystem:Bind(LayerEventType.KEYBOARD_RELEASED, function (key_code, event)
	-- 	if cc.KeyCode.KEY_T == key_code and event == cc.Handler.EVENT_KEYBOARD_PRESSED then
	-- 		GlobalEventSystem:Fire(OtherEventType.PASS_DAY)
	-- 	end
	-- end)

end

function PersonalBossData:__delete()
	PersonalBossData.Instance = nil
end

local is_tequan_id = {
	[50] = 1,
	[51] = 2,
	[52] = 3,
}

function PersonalBossData:SetListenerEvent()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
	-- EventProxy.New(LunHuiData.Instance, self):AddEventListener(LunHuiData.LUNHUI_DATA_CHANGE, BindTool.Bind(self.BossStateChange, self))
	EventProxy.New(FubenData.Instance, self):AddEventListener(FubenData.BOSS_ENTER_TIMES, BindTool.Bind(self.BossStateChange, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.CanEnterBossFuben, self), RemindName.PerBoss, true)
	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.PassDayCallBack, self))
end

function PersonalBossData:PassDayCallBack()
	-- self:SetPersonalBossList()
	self:BossStateChange()
end

function PersonalBossData:GetPersonalBossList()
	-- if nil == self.personal_boss_list then 
	-- 	self:SetPersonalBossList()
	-- end
	-- return self.personal_boss_list
end

function PersonalBossData:SetPersonalBossList()
	local tq_boss = {}

	local fuben_list = FubenData.Instance:GetFubenEnterInfo()

	-- local sort_idx = 1
	local function format_boss_data(v)
		v.index = v.index
		local enter_time = fuben_list[v.fubenId] and fuben_list[v.fubenId].enter_time or 0
		v.times = enter_time
		v.cd_time = fuben_list[v.fubenId] and fuben_list[v.fubenId].cd_time or 0
		v.boss_level = v.needLevel
		v.boss_lv = v.bosslv
		v.boss_circle = v.circle
		v.vip_level = v.viplevel or 0
		v.boss_lunhui = v.lhGrade or v.lhlevel
		v.item_id = v.needItem.id
		v.item_count = v.needItem.count
		v.is_tequan = nil ~= is_tequan_id[v.fubenId]
		local is_enough = BossData.BossIsEnoughAndTip(v)
		
		v.state = is_enough and (enter_time > 0 and 2 or 0) or 1 		-- 0-没次数 1-未开启 2-可参与

		-- sort_idx = sort_idx + 1
		return v
	end

	--加入特权boss
	for fubenId = 50, 52 do
		-- if PrivilegeData.Instance:IsTeQuan(is_tequan_id[fubenId]) then
			table.insert(tq_boss, format_boss_data(GameFubenCfg.fubenList[fubenId]))
		-- end
	end

	for i,v in ipairs(GameFubenCfg.fubenList) do
		if not is_tequan_id[v.fubenId] then
            if IS_AUDIT_VERSION and v.viplv then
                break
            elseif v.viplv then
			    table.insert(tq_boss, format_boss_data(v))
            end
		end
	end

	table.sort(tq_boss, function(a, b)
		if a.state ~= b.state then
			return a.state > b.state
		else
			return a.index < b.index
		end
	end)

	-- RemindManager.Instance:DoRemind(RemindName.PerBoss)
	return tq_boss
end

function PersonalBossData:CanEnterBossFuben()
	local data = self:SetPersonalBossList() or {}
	for k,v in pairs(data) do
		if v.state == 2 then
			return 1
		end
	end
	return 0
end

function PersonalBossData:TeQuanChange()
	-- self:SetPersonalBossList()
end

function PersonalBossData:RoleAttrChange(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or 
		vo.key == OBJ_ATTR.ACTOR_CIRCLE or
		vo.key == OBJ_ATTR.ACTOR_VIP_GRADE then 
		self:BossStateChange()
	end
end

function PersonalBossData:BossStateChange()
	-- if nil == self.personal_boss_list then 
		-- self:SetPersonalBossList()
	-- else
	local data = self:SetPersonalBossList() or {}
	local fuben_list = FubenData.Instance:GetFubenEnterInfo()
	for k,v in pairs(data) do
		local is_enough = BossData.BossIsEnoughAndTip(v)
		local enter_time = fuben_list[v.fubenId] and fuben_list[v.fubenId].enter_time or 0
		v.state = is_enough and (enter_time > 0 and 2 or 0) or 1
	end
	table.sort(data, function(a, b)
		if a.state ~= b.state then
			return a.state > b.state
		else
			return a.index < b.index
		end
	end)
	-- RemindManager.Instance:DoRemind(RemindName.PerBoss)
	-- end
end
