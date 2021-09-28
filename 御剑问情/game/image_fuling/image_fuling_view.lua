ImageFuLingView = ImageFuLingView or BaseClass(BaseView)

function ImageFuLingView:__init()
	self.ui_config = {"uis/views/imagefuling_prefab", "ImageFuLingView"}

	self.full_screen = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	self.def_index = TabIndex.img_fuling_content
	self.play_audio = true

	self.temp_fuling_type_tab = nil

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ImageFuLingView:__delete()
	
end

function ImageFuLingView:ReleaseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.img_fuling_view ~= nil then
		self.img_fuling_view:DeleteMe()
		self.img_fuling_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	-- 清理变量和对象
	self.tab_img_fuling = nil
	self.img_fuling_content = nil

	self.gold = nil
	self.bind_gold = nil
	self.red_point_list = nil

	self.temp_fuling_type_tab = nil
	self.img_fuling_content = nil
end

function ImageFuLingView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("OpenFuLing",
		BindTool.Bind(self.OpenFuLing, self))
	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))

	self.tab_img_fuling = self:FindObj("TabFuLing")

	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")

	self.img_fuling_content = self:FindObj("FuLingContent")

	self.red_point_list = {
		[RemindName.ImgFuLing] = self:FindVariable("FuLingRemind"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function ImageFuLingView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ImageFuLingView:OpenFuLing()
	self:ShowIndex(TabIndex.img_fuling_content)
end

function ImageFuLingView:LoadImgFuLingContent()
	if self.img_fuling_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad(
			"uis/views/imagefuling_prefab", 
			"FuLingContentView", 
			function(obj)
				obj.transform:SetParent(self.img_fuling_content.transform, false)
				obj = U3DObject(obj)
				self.img_fuling_view = ImageFuLingContentView.New(obj)
				self.img_fuling_view:SetCurSelectIndex(self.temp_fuling_type_tab, true)
				self.img_fuling_view:Flush()
			end)
	end
end


function ImageFuLingView:ShowIndexCallBack(index)
	self:Flush()

	if index == TabIndex.img_fuling_content then
		self:LoadImgFuLingContent()
		if self.img_fuling_view then
			self.img_fuling_view:OpenCallBack()
		end
	end
end

function ImageFuLingView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ImageFuLingView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = vo.gold
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		self.gold:SetValue(count)
	end
	if attr_name == "bind_gold" then
		local count = vo.bind_gold
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		self.bind_gold:SetValue(count)
	end
end

function ImageFuLingView:CloseCallBack()
	if self.img_fuling_view then
		self.img_fuling_view:CloseCallBack()
	end

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	end

	self.temp_fuling_type_tab = nil
end

function ImageFuLingView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	-- 监听系统事件
	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
		-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
end

function ImageFuLingView:ItemDataChangeCallback()
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.img_fuling_content then
		self.img_fuling_view:ItemDataChangeCallback()
	end
end

function ImageFuLingView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	for k, v in pairs(param_list) do
		if k == "img_fuling" then
			if self.img_fuling_view and cur_index == TabIndex.img_fuling_content then
				self.img_fuling_view:Flush()
			end
		elseif k == "fuling_type_tab" then
			if self.img_fuling_view and cur_index == TabIndex.img_fuling_content then
				self.img_fuling_view:SetCurSelectIndex(v[1], true)
				self.img_fuling_view:Flush()
			else
				self.temp_fuling_type_tab = v[1]
				self:OpenFuLing()
			end
		elseif k == "all"then
			if cur_index == TabIndex.img_fuling_content then
				if self.img_fuling_view and cur_index == TabIndex.img_fuling_content then
					self.img_fuling_view:Flush()
				end
			end
		end
	end
end

