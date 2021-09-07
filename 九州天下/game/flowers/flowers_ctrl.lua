require("game/flowers/flowers_view")
require("game/flowers/backflowers_view")
require("game/flowers/flowers_data")

FlowersCtrl = FlowersCtrl or BaseClass(BaseController)

local UILayer = GameObject.Find("GameRoot/UILayer").transform

function FlowersCtrl:__init()
	if nil ~= FlowersCtrl.Instance then
		print_error("[FlowersCtrl] Attemp to create a singleton twice !")
		return
	end
	FlowersCtrl.Instance = self

	self.flowers_view = FlowersView.New(ViewName.Flowers)
	self.backflowers_view = BackFlowersView.New(ViewName.BackFlowers)
	self.flowers_data = FlowersData.New()

	self.is_hideeffect = false

	self:RegisterAllProtocols()
end

function FlowersCtrl:__delete()
	if self.flowers_view ~= nil then
		self.flowers_view:DeleteMe()
		self.flowers_view = nil
	end

	if self.backflowers_view ~= nil then
		self.backflowers_view:DeleteMe()
		self.backflowers_view = nil
	end

	if self.flowers_data ~= nil then
		self.flowers_data:DeleteMe()
		self.flowers_data = nil
	end

	if self.task_effect then
		self.task_effect:Destroy()
		self.task_effect:DeleteMe()
		self.task_effect = nil
	end

	FlowersCtrl.Instance = nil
	self:ClearCheckRoleInfo()
end

function FlowersCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGiveFlower, "OnGiveFlower")
	self:RegisterProtocol(SCSoneHuaInfo, "SCFlowerInfo")
end

function FlowersCtrl:ClearCheckRoleInfo()
	if self.role_info then
		GlobalEventSystem:UnBind(self.role_info)
		self.role_info = nil
	end
end

function FlowersCtrl:RoleInfo(role_id, protocol)
	if role_id == self.from_uid then
		self.from_uid = 0
		self:ClearCheckRoleInfo()
		self.backflowers_view:SetRoleInfotable(protocol)
		self.backflowers_view:Open()
		self.backflowers_view:Flush()
	end
end

function FlowersCtrl:OnGiveFlower(protocol)
	self.flowers_data:OnGiveFlower(protocol)
	-- 被送花
	if protocol.target_uid == GameVoManager.Instance:GetMainRoleVo().role_id and self.flowers_data:GetIsTips() then
		if not self.flowers_view:IsOpen() then
			self.backflowers_view:SetInfo(protocol)
			self.from_uid = protocol.from_uid
			self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfo, self))
			CheckCtrl.Instance:SendQueryRoleInfoReq(self.from_uid)
		end
	end

	if protocol.target_uid == GameVoManager.Instance:GetMainRoleVo().role_id then
		self.backflowers_view:SetInfo(protocol)
		self.from_uid = protocol.from_uid
		self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfo, self))
		CheckCtrl.Instance:SendQueryRoleInfoReq(self.from_uid)
		-- self.backflowers_view:SetRoleInfotable(protocol)
		-- self.backflowers_view:Open()
	end

	self.is_hideeffect = SettingData.Instance:GetSettingData(SETTING_TYPE.FLOWER_EFFECT)
	if self.is_hideeffect then
		return
	end

	-- 播放特效
	local is_all_man = false
	local effect_cfg = nil
	-- if self.protocol.item_id == 26903 then      	--1   双方 纯色
	-- 	is_all_man = false

	if protocol.item_id == 26904 then      	--9   双方 纯色
		is_all_man = false
		effect_cfg = 1
	elseif protocol.item_id == 26905 then      --99全服 纯色
		is_all_man = true
		effect_cfg = 2

	elseif protocol.item_id == 26906 then		--999 全服 双色
		is_all_man = true
		effect_cfg = 3
	end

	if effect_cfg ~= nil then
		if is_all_man then
			if effect_cfg == 2 then
				self:PlayerEffect2("effects2/prefab/ui/ui_songhuaxinxing_hong_prefab","UI_songhuaxinxing_hong")
				-- self:PlayerEffect2("effects2/prefab/ui/ui_songhuaxinxing_prefab","UI_songhuaxinxing")
			else
				self:PlayerEffect("effects2/prefab/ui/ui_songhua999_prefab","UI_songhua999")
				self:PlayerEffect2("effects2/prefab/ui/ui_songhuaxinxing_hong_prefab","UI_songhuaxinxing_hong")
			end
		else
			if protocol.target_uid ==  GameVoManager.Instance:GetMainRoleVo().role_id or protocol.from_uid ==  GameVoManager.Instance:GetMainRoleVo().role_id then
				self:PlayerEffect("effects2/prefab/ui/ui_songhuaxinxing_hong_prefab","UI_songhuaxinxing_hong")
			end
		end
	end
end

function FlowersCtrl:SCFlowerInfo(protocol)
	self.flowers_data:SetFreeFlowerTime(protocol.daily_use_free_times)
	RemindManager.Instance:Fire(RemindName.ScoietyFriend)
	if self.flowers_view:IsOpen() then
		self.flowers_view:Flush()
	end
end

function FlowersCtrl:GetFlowersView()
	return self.flowers_view
end

function FlowersData:GetFlowersData()
	return self.flowers_data
end

function FlowersCtrl:GetFriendName(friend_name)
	FlowersData.Instance:SetFriendName(friend_name)
end

function FlowersCtrl:GetFlowerName(flower_name)
	FlowersData.Instance:SetFlowerName(flower_name)
end

function FlowersCtrl:SetFlowerId(item_id)
	FlowersData.Instance:SetFlowerId(item_id)
end

function FlowersCtrl:SetFriendInfo(info)
	FlowersData.Instance:SetFriendInfo(info)
end

function FlowersCtrl:SendFlowersReq(grid_index, item_id, target_uid, is_anonymity, auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGiveFlower)
	send_protocol.grid_index = grid_index
	send_protocol.item_id = item_id
	send_protocol.target_uid = target_uid
	send_protocol.is_anonymity = is_anonymity
	send_protocol.is_marry = auto_buy			-- 0 自动购买 1 消耗背包
	send_protocol:EncodeAndSend()
end


function FlowersCtrl.SendFlowerInfoReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSoneHuaInfoReq)
	send_protocol:EncodeAndSend()
end

function FlowersCtrl:PlayerEffect(path,objname)
	local play_effect = SettingData.Instance:GetGlobleType(SETTING_TYPE.FLOWER_EFFECT)
	if not play_effect then return end
	
	local flower_play_state = FlowersData.Instance:IsFlowerPlay()
	if flower_play_state then
		return
	end

	PrefabPool.Instance:Load(AssetID(path, objname), function (prefab)
		if prefab ~= nil then
			FlowersData.Instance:SetFlowerPlay(true)
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)

			if IsNil(obj) then
				return
			end

			local transform = obj.transform
			if IsNil(transform) then
				return
			end
			-- transform.localPosition = Vector3(110, 110, 0)
			transform:SetParent(UILayer, false)

			GlobalTimerQuest:AddDelayTimer(function()
				FlowersData.Instance:SetFlowerPlay(false)
				if IsNil(obj) then
					return
				end

				GameObject.Destroy(obj)
				end, 7)
		end
	end)
end

function FlowersCtrl:PlayerEffect2(path,objname)
	local play_effect = SettingData.Instance:GetGlobleType(SETTING_TYPE.FLOWER_EFFECT)
	if not play_effect then return end

	local flower_play_state = FlowersData.Instance:IsFlowerPlay999()
	if flower_play_state then
		return
	end
	PrefabPool.Instance:Load(AssetID(path, objname), function (prefab)
		if prefab ~= nil then
			FlowersData.Instance:SetFlowerPlay999(true)
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)

			if IsNil(obj) then
				return
			end

			local transform = obj.transform
			if IsNil(transform) then
				return
			end
			-- transform.localPosition = Vector3(110, 110, 0)
			transform:SetParent(UILayer, false)

			GlobalTimerQuest:AddDelayTimer(function()
				FlowersData.Instance:SetFlowerPlay999(false)
				if IsNil(obj) then
					return
				end
				GameObject.Destroy(obj)
				end, 6)
		end
	end)
end

function FlowersCtrl:PlayerTaskEffect2(path, objname)
	if UILayer then
		if self.task_effect then
			self.task_effect:Destroy()
			self.task_effect:DeleteMe()
			self.task_effect = nil
		end
		self.task_effect = AsyncLoader.New(UILayer.transform)
		local call_back = function(effect_obj)
			if effect_obj then
				effect_obj.transform.localPosition = Vector3(0, 250, 0)
				effect_obj.transform.localScale = Vector3(0.8, 0.8, 0.8)
			end
		end
		self.task_effect:Load(path, objname, call_back)
		GlobalTimerQuest:AddDelayTimer(function()
			if self.task_effect then
				self.task_effect:Destroy()
				self.task_effect:DeleteMe()
				self.task_effect = nil
			end
		end, 3)
	end
end