ConsumablesBar = ConsumablesBar or BaseClass(BaseCell)

--有两种不同的监听
--1/是人物信息变更的监听，使用PlayerData.Instance:ListenerAttrChange(self.change_callback)
--2/是物品信息的变更监听，使用ItemData.Instance:NotifyDataChangeCallBack(self.change_callback) // self.change_callback是回调函数
--注意两种监听获取参数的方式，人物信息要去PlayerData.Instance:SetAttr()，物品要判断item_id
--LISTEN_TYPE.player_listener 是人物，LISTEN_TYPE.item_listener是物品 
--若为1，要设置name  若为2，要设置item_id
function ConsumablesBar:__init()
	self.is_use_objpool = false
	if nil == self.root_node then
		local bundle, asset = ResPath.GetWidgets("ConsumablesBar")
		local prefab = PreloadManager.Instance:GetPrefab(bundle, asset)
		local u3dobj = U3DObject(GameObjectPool.Instance:Spawn(prefab, nil))
		self:SetInstance(u3dobj)
		self.is_use_objpool = true
	end
	self.name = nil
	self.listener_type = nil
	self.item_id = nil
	self.data = nil
end

function ConsumablesBar:LoadCallBack()
	self.num = {}
	self.icon = self:FindVariable("Icon")
	self.tmp_num = self:FindVariable("Num")
end

function ConsumablesBar:__delete()
	self.icon = nil
	self.num = nil
	self.name = nil
	self.listener_type = nil
	self.item_id = nil

	if self.item_data_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.change_callback and PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.change_callback)
		self.change_callback = nil
	end
end

function ConsumablesBar:SetListener()
	if self.data.listener_type == LISTEN_TYPE.item_listener then
		self:NotifyDataChangeCallBack()
	elseif self.data.listener_type == LISTEN_TYPE.player_listener then
		if not self.change_callback then
			self.change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
			PlayerData.Instance:ListenerAttrChange(self.change_callback)
		end
	end
end

--人物信息变更监听
function ConsumablesBar:PlayerDataChangeCallback(name, value)
	if self.num[name] then
		local change_value = CommonDataManager.ConverMoney(value)
		self.num[name]:SetValue(change_value)
	end
end

--物品信息变更监听
--这里不用new_num,因为当有不止1格有同样的道具会返回错误的数量
function ConsumablesBar:NotifyDataChangeCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(function(cfg, item_id, reason, put_reason, old_num, new_num)
			if self.item_id == item_id then
				local res_num = ItemData.Instance:GetItemNumInBagById(self.item_id)
				local change_value = CommonDataManager.ConverMoney(res_num)
				self.tmp_num:SetValue(change_value)
			end
		end, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

--data必须有的数据:listener_type, bundle，asset, num, (name or item_id) 注意名字要一样
function ConsumablesBar:SetData(data)
	BaseCell.SetData(self, data)
end

function ConsumablesBar:ListenClick(handler)
	self.handler = handler
end

function ConsumablesBar:OnFlush()
	if not self.data then return end
	local data = self.data
	if self.icon then		
		self.icon:SetAsset(data.bundle, data.asset)
	end
	if data.listener_type == LISTEN_TYPE.player_listener then
		if self.tmp_num and data.name then
			self.num[data.name] = self.tmp_num
			self.num[data.name]:SetValue(data.num)
		end
	elseif data.listener_type == LISTEN_TYPE.item_listener then
		if self.tmp_num and data.item_id then
			self.tmp_num:SetValue(data.num)
			self.item_id = data.item_id
		end
	end
	if self.handler ~= nil then
		self:ClearEvent("Click")
		self:ListenEvent("Click", self.handler)
	end	
	if data.listener_type then
		self:SetListener()
	end
end
