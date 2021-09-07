require("game/shenqi/shenbing_xiangqian_view")
require("game/shenqi/shenbing_jianling_view")
require("game/shenqi/baojia_xiangqian_view")
require("game/shenqi/baojia_qiling_view")
require("game/shenqi/fenjie_view")

ACTIVE_IMAGE_CONDITION = 3      -- 激活形象至少需要的的品质
IMAGE_ACTIVE_CONDITION = 4      -- 形象激活需要4种条件
JIANLING_TAB = 1              	-- 剑灵下标
QILING_TAB = 2                	-- 器灵下标

ShenqiView = ShenqiView or BaseClass(BaseView)

ShenqiView.TabDef = {
	ShenBingXiangQian = 1,
	ShenBingJianLing = 2,
	BaoJiaXiangQian = 3,
	BaoJiaQiLing = 4,
}

-- 神器
function ShenqiView:__init()
	self.ui_config = {"uis/views/shenqiview", "ShenqiView"}
	self.full_screen = false								-- 是否是全屏界面(ViewManager里面调用)
	self.play_audio = true								-- 播放音效
	self:SetMaskBg()
	self.def_index = TabIndex.shenbing_xiangqian 		-- 神兵-镶嵌

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ShenqiView:__delete()
	self.full_screen = nil
	self.play_audio = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function ShenqiView:ReleaseCallBack()
	if self.xiangqian_view then
		self.xiangqian_view:DeleteMe()
		self.xiangqian_view = nil
	end
	if self.jianling_view then
		self.jianling_view:DeleteMe()
		self.jianling_view = nil
	end
	if self.bj_xiangqian_view then
		self.bj_xiangqian_view:DeleteMe()
		self.bj_xiangqian_view = nil
	end

	if self.qiling_view then
		self.qiling_view:DeleteMe()
		self.qiling_view = nil
	end
	if self.fenjie_view then
		self.fenjie_view:DeleteMe()
		self.fenjie_view = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.toggle_list = {}
	self.toggle_xiangqian = nil
	self.toggle_jianling = nil
	self.toggle_bj_xiangqian = nil
	self.toggle_qiling = nil
	self.show_bg = nil
	self.view_list = {}

	self.red_point_list = nil

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function ShenqiView:LoadCallBack()
	self.show_bg = self:FindVariable("show_bg")

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	--监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.OnCloseHandler, self))

	-- 左边的标签页
	self.toggle_list = {}
	self.toggle_list[1] = self:FindObj("ToggleShenbing")				-- 神兵
	self.toggle_list[2] = self:FindObj("ToggleBaojia")					-- 宝甲
	self.toggle_list[3] = self:FindObj("ToggleFenjie")					-- 分解
	-- 切换左边的标签
	-- for k, v in ipairs(self.toggle_list) do
	-- 	v.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, k))
	-- end

	self.toggle_list[1].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.shenbing))
	self.toggle_list[2].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.baojia))
	self.toggle_list[3].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fenjie))

	-- 顶部按钮
	self.toggle_xiangqian = self:FindObj("ButtonXiangqian")				-- 神兵-镶嵌
	self.toggle_jianling = self:FindObj("ButtonJianling")				-- 神兵-剑灵
	self.toggle_bj_xiangqian = self:FindObj("ButtonBjXiangqian")		-- 宝甲-镶嵌
	self.toggle_qiling = self:FindObj("ButtonQiling")					-- 宝甲-器灵

	self.toggle_xiangqian.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.shenbing_xiangqian))
	self.toggle_jianling.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.shenbing_jianling))
	self.toggle_bj_xiangqian.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.baojia_xiangqian))
	self.toggle_qiling.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.baojia_qiling))

	-- 检查功能是否开启
	-- self:CheckTabIsHide()

	-- 面板列表
	self.view_list = {}
	-- 神兵-镶嵌
	self.xiangqian_view = XiangqianView.New()
	local xiangqian_content = self:FindObj("XiangqianContent")
	xiangqian_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.xiangqian_view:SetInstance(obj)
		self.view_list[TabIndex.shenbing_xiangqian] = self.xiangqian_view
	end)

	-- 神兵-剑灵
	self.jianling_view = JianlingView.New()
	local jianling_content = self:FindObj("JianlingContent")
	jianling_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.jianling_view:SetInstance(obj)
		self.view_list[TabIndex.shenbing_jianling] = self.jianling_view
	end)

	-- 宝甲-镶嵌
	self.bj_xiangqian_view = BjXiangqianView.New()
	local baojia_content = self:FindObj("BjXiangqianContent")
	baojia_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.bj_xiangqian_view:SetInstance(obj)
		self.view_list[TabIndex.baojia_xiangqian] = self.bj_xiangqian_view
	end)

	-- 宝甲-器灵
	self.qiling_view = QilingView.New()
	local qiling_content = self:FindObj("QilingContent")
	qiling_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.qiling_view:SetInstance(obj)
		self.view_list[TabIndex.baojia_qiling] = self.qiling_view
	end)

	-- 分解
	self.fenjie_view = FenjieView.New()
	local fenjie_content = self:FindObj("FenjieContent")
	fenjie_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.fenjie_view:SetInstance(obj)
		self.view_list[TabIndex.fenjie] = self.fenjie_view
	end)

	self.red_point_list = {
		[RemindName.ShenBingXiangQian] = self:FindVariable("show_sbxiangqian_rp"),
		[RemindName.BaoJiaXiangQian] = self:FindVariable("show_bjxiangqian_rp"),
		[RemindName.ShenBingJianLing] = self:FindVariable("show_sbjianling_rp"),
		[RemindName.BaoJiaQiLing] = self:FindVariable("show_bjqiling_rp"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self:ShowOrHideTab()
end

function ShenqiView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ShenqiView:ShowOrHideTab()
	if not self:IsOpen() then return end

	-- 右边标签
	local show_list = {}
	local open_fun_data = OpenFunData.Instance
	show_list[1] = open_fun_data:CheckIsHide("shenbing_xiangqian")
	show_list[2] = open_fun_data:CheckIsHide("baojia_xiangqian")
	show_list[3] = open_fun_data:CheckIsHide("fenjie")
	for k,v in pairs(show_list) do
		self.toggle_list[k]:SetActive(v)
	end
end

function ShenqiView:OpenCallBack()
	-- 功能开启有变化触发
	self.open_trigger = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	 -- 请求所有信息
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_INFO)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function ShenqiView:CloseCallBack()
	if self.open_trigger then
		GlobalEventSystem:UnBind(self.open_trigger)
		self.open_trigger = nil
	end
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)

	if self.jianling_view then
		self.jianling_view:ClearData()
	end

	if self.qiling_view then
		self.qiling_view:ClearData()
	end
end

function ShenqiView:OnCloseHandler()
	ViewManager.Instance:Close(ViewName.Shenqi)
end

-- 决定显示哪个界面
function ShenqiView:ShowIndexCallBack(index)
	if self.jianling_view then
		self.jianling_view:ClearData()
	end

	if self.qiling_view then
		self.qiling_view:ClearData()
	end

	if index == TabIndex.shenbing or index == TabIndex.shenbing_xiangqian or index == TabIndex.shenbing_jianling then
		self.toggle_list[1].toggle.isOn = true
	elseif index == TabIndex.baojia or index == TabIndex.baojia_xiangqian or index == TabIndex.baojia_qiling then
		self.toggle_list[2].toggle.isOn = true
	elseif index == TabIndex.fenjie then
		self.toggle_list[3].toggle.isOn = true
	end

	self.show_bg:SetValue(index ~= TabIndex.fenjie)
	
	self:Flush() -- 点击右边的标签时,切换界面
end

-- function ShenqiView:CheckTabIsHide()
-- 	if not self:IsOpen() then return end

-- 	self.toggle_shenbing:SetActive(OpenFunData.Instance:CheckIsHide("ToggleShenbing"))
-- 	self.toggle_baojia:SetActive(OpenFunData.Instance:CheckIsHide("ToggleBaojia"))
-- 	self.toggle_fenjie:SetActive(OpenFunData.Instance:CheckIsHide("ToggleFenjie"))
-- end

function ShenqiView:OnToggleChange(index, ison)
	if ison then
		self:ChangeToIndex(index)
		if index == TabIndex.shenbing_xiangqian then
			if self.xiangqian_view then
				self.xiangqian_view:OpenCallBack()
			end
		elseif index == TabIndex.shenbing_jianling then
			if self.jianling_view then
				self.jianling_view:OpenCallBack()
			end
		elseif index == TabIndex.baojia_xiangqian then
			if self.bj_xiangqian_view then
				self.bj_xiangqian_view:OpenCallBack()
			end
		elseif index == TabIndex.baojia_qiling then
			if self.qiling_view then
				self.qiling_view:OpenCallBack()
			end
		end
	end
end

function ShenqiView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "all" then
			if v.to_ui_name then
				if v.to_ui_name == "shenbing_xiangqian" then
					if self.xiangqian_view then
						self.xiangqian_view:SetSelectIndex(tonumber(v.open_param) or 1)
						self.xiangqian_view:SetModel()
					end
				end
				if v.to_ui_name == "baojia_xiangqian" then
					if self.bj_xiangqian_view then
						self.bj_xiangqian_view:SetSelectIndex(tonumber(v.open_param) or 1)
						self.bj_xiangqian_view:SetModel()
					end
				end
			end

			if self.show_index == TabIndex.shenbing then
				if self.xiangqian_view then
					self.xiangqian_view:Flush()
				end
				if self.jianling_view then
					self.jianling_view:Flush()
				end
			elseif self.show_index == TabIndex.baojia then
				if self.bj_xiangqian_view then
					self.bj_xiangqian_view:Flush()
				end
				if self.qiling_view then
					self.qiling_view:Flush()
				end
			elseif self.show_index == TabIndex.shenbing_xiangqian then
				if self.xiangqian_view then
					self.xiangqian_view:Flush()
				end
			elseif self.show_index == TabIndex.shenbing_jianling then
				if self.jianling_view then
					self.jianling_view:Flush()
				end
			elseif self.show_index == TabIndex.baojia_xiangqian then
				if self.bj_xiangqian_view then
					self.bj_xiangqian_view:Flush()
				end
			elseif self.show_index == TabIndex.baojia_qiling then
				if self.qiling_view then
					self.qiling_view:Flush()
				end
			elseif self.show_index == TabIndex.fenjie then
				if self.fenjie_view then
					self.fenjie_view:Flush()
				end
			end
		end
	end
end

function ShenqiView:ItemDataChangeCallback()
	if self.xiangqian_view ~= nil then
		self.xiangqian_view:Flush()
		RemindManager.Instance:Fire(RemindName.ShenBingXiangQian)
	end
	if self.bj_xiangqian_view ~= nil then
		self.bj_xiangqian_view:Flush()
		RemindManager.Instance:Fire(RemindName.BaoJiaXiangQian)
	end
	if self.jianling_view ~= nil then
		self.jianling_view:Flush()
		RemindManager.Instance:Fire(RemindName.ShenBingJianLing)
	end
	if self.qiling_view ~= nil then
		self.qiling_view:Flush()
		RemindManager.Instance:Fire(RemindName.BaoJiaQiLing)
	end
end

function ShenqiView:ShenbingUpgradeOptResult(result)
	self.jianling_view:FlushUpgradeOptResult(result)
end

function ShenqiView:BaojiaUpgradeOptResult(result)
	self.qiling_view:FlushUpgradeOptResult(result)
end