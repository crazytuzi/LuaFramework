require("game/shenqi/shenqi_jianling_view")
require("game/shenqi/shenqi_fenjie_view")
require("game/shenqi/shenqi_baojia_view")

ShenqiView = ShenqiView or BaseClass(BaseView)

--这个prefab通用链接 (asset)
local url = "uis/views/shenqi_prefab"

-- 神器
function ShenqiView:__init()
	self.ui_config = {url, "ShenqiView"}
	self.full_screen = false								-- 是否是全屏界面(ViewManager里面调用)
	self.play_audio = true								-- 播放音效
	-- self:SetMaskBg()
	self.def_index = TabIndex.shenbing 					-- 神兵-升级

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ShenqiView:__delete()
	self.full_screen = nil
	self.play_audio = nil
	self.remind_change = nil
end

function ShenqiView:ReleaseCallBack()
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.jianling_view then
		self.jianling_view:DeleteMe()
		self.jianling_view = nil
	end

	if self.baojia_view then
		self.baojia_view:DeleteMe()
		self.baojia_view = nil
	end
	if self.fenjie_view then
		self.fenjie_view:DeleteMe()
		self.fenjie_view = nil
	end

	if self.toggle_list then
		for k,v in pairs(self.toggle_list) do
			if v then
				v = nil
			end
		end
		self.toggle_list = {}
	end

	if self.red_point_list then
		for k,v in pairs (self.red_point_list) do
			if v then
				v = nil
			end
		end
		self.red_point_list = nil
	end

	self.bind_gold = nil
	self.gold = nil

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end	

end

function ShenqiView:LoadCallBack()

	--监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickShenQi", BindTool.Bind(self.ClickShenQi, self))
	self:ListenEvent("ClickBaoJia", BindTool.Bind(self.ClickBaoJia, self))
	self:ListenEvent("ClickFenJie", BindTool.Bind(self.ClickFenJie, self))
	self:ListenEvent("AddGold",BindTool.Bind(self.HandleAddGold, self))

	-- 左边的标签页
	self.toggle_list = {}
	self.toggle_list[TabIndex.shenbing] = self:FindObj("ToggleEquip")				-- 神兵
	self.toggle_list[TabIndex.baojia] = self:FindObj("ToggleCloth")					-- 宝甲
	self.toggle_list[TabIndex.fenjie] = self:FindObj("ToggleRecyle")					-- 分解

	--variable
	self.bind_gold = self:FindVariable("BindGold")
	self.gold = self:FindVariable("Gold")
	-- 面板列表

	self.red_point_list = {
		[RemindName.ShenQiJiangLing] = self:FindVariable("JianLingRedPoint"),
		[RemindName.ShenQiBaoJia] = self:FindVariable("BaoJiaPoint"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	RemindManager.Instance:Fire(RemindName.ShenQi)
end

function ShenqiView:ShowIndexCallBack(index)
	self.show_index = index
	self.toggle_list[index].toggle.isOn = true
	self:LoadPrefabAsyn(index)
end

function ShenqiView:ReleaseAutoUpLevel()
	if self.jianling_view then
		self.jianling_view:SetUpLevelState(false)
	end

	if self.baojia_view then
		self.baojia_view:SetUpLevelState(false)
	end
end
function ShenqiView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		local count = value
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. "万"
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. "亿"
		end
		if attr_name == "bind_gold" then
			self.bind_gold:SetValue(count)
		else
			self.gold:SetValue(count)
		end
	end
end


function ShenqiView:OpenCallBack()
	--监听系统事件

	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	RemindManager.Instance:Fire(RemindName.ShenQiJiangLing)
	RemindManager.Instance:Fire(RemindName.ShenQiBaoJia)

	 -- 请求所有信息
	-- ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_INFO)
end

function ShenqiView:CloseCallBack()
	
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function ShenqiView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ShenqiView:OnFlush()
	if self.show_index == TabIndex.baojia and nil ~= self.baojia_view then
		self.baojia_view:Flush()
	elseif self.show_index == TabIndex.shenbing and nil ~= self.jianling_view then
		self.jianling_view:Flush()
	elseif self.show_index == TabIndex.fenjie and nil ~= self.fenjie_view then
		self.fenjie_view:Flush()
	end
end

function ShenqiView:ToggleChange(index)
	if self.show_index == index then
		return
	end

	self:ShowIndex(index)
end

function ShenqiView:LoadPrefabAsyn(index)
	if index == TabIndex.shenbing then
		if nil == self.jianling_view then
			local equip_content = self:FindObj("EquipContent")
			UtilU3d.PrefabLoad(url, "EquipContent",
				function(obj)
					obj.transform:SetParent(equip_content.transform, false)
					obj = U3DObject(obj)
					self.jianling_view = JianLingView.New(obj)
					self.jianling_view:Flush()
			end)
		else
			self.jianling_view:Flush()
		end
	elseif index == TabIndex.baojia then
		if nil == self.baojia_view then		
			local baojia_content = self:FindObj("ClothContent")
			UtilU3d.PrefabLoad(url, "ClothContent",
				function(obj)
					obj.transform:SetParent(baojia_content.transform, false)
					obj = U3DObject(obj)
					self.baojia_view = BaoJiaView.New(obj)
					self.baojia_view:Flush()
			end)
		else
			self.baojia_view:Flush()
		end
	elseif index == TabIndex.fenjie then
		if nil == self.fenjie_view then
			local fenjie_content = self:FindObj("RecyleContent")
			UtilU3d.PrefabLoad(url, "RecykleContent",
				function(obj)
					obj.transform:SetParent(fenjie_content.transform, false)
					obj = U3DObject(obj)
					self.fenjie_view = FenjieView.New(obj)
					self.fenjie_view:Flush()
			end)
		else
			self.fenjie_view:Flush()
		end
	end
end

function ShenqiView:CloseView()
	self:Close()
end

function ShenqiView:ClickShenQi()
	if nil ~= self.jianling_view then
		self.jianling_view:SetLevel(0)
		self.jianling_view:ClearEffect()
	end
	self:ToggleChange(TabIndex.shenbing)
	ShenqiData.Instance:ChangeOpenJiangLing()
	RemindManager.Instance:Fire(RemindName.ShenQiJiangLing)
end

function ShenqiView:ClickBaoJia()
	if nil ~= self.baojia_view then
		self.baojia_view:SetLevel(0)
		self.baojia_view:ClearEffect()
	end
	self:ToggleChange(TabIndex.baojia)
	ShenqiData.Instance:ChangeOpenBaoJia()
	RemindManager.Instance:Fire(RemindName.ShenQiBaoJia)
end

function ShenqiView:ClickFenJie()
	self:ToggleChange(TabIndex.fenjie)
end

function ShenqiView:FlushCellUpLevelState()
	if self.jianling_view then
		self.jianling_view:FlushItemUpState()
	end

	if self.baojia_view then
		self.baojia_view:FlushItemUpState()
	end
end

function ShenqiView:ShenbingUpgradeOptResult(result)
	self.jianling_view:FlushUpgradeOptResult(result)
end

function ShenqiView:BaojiaUpgradeOptResult(result)
	self.baojia_view:FlushUpgradeOptResult(result)
end

function ShenqiView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end