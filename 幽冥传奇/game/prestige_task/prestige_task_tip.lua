--------------------------------------------------------
-- 威望任务提示 
--------------------------------------------------------
PrestigeTaskTip = PrestigeTaskTip or BaseClass(BaseView)

function PrestigeTaskTip:__init()
	self.texture_path_list[1] = 'res/xui/daily_tasks.png'
	-- self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"prestige_task_ui_cfg", 3, {0}},
	}

end

function PrestigeTaskTip:__delete()
end

--释放回调
function PrestigeTaskTip:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end
end

--加载回调
function PrestigeTaskTip:LoadCallBack(index, loaded_times)
	self.data = PrestigeTaskData.Instance:GetData()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_close"].node, BindTool.Bind(self.OnCloseBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_exchange"].node, BindTool.Bind(self.OnExchangeBtn, self))

	-- 数据监听
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.FlushNumber, self))
end

function PrestigeTaskTip:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function PrestigeTaskTip:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function PrestigeTaskTip:ShowIndexCallBack(index)
	self:FlushNumber()	
end

function PrestigeTaskTip:FlushNumber()
	local item_cfg = PrestigeSysConfig.item_list[1] -- 获取屠魔令配置
	local item_num = BagData.Instance:GetItemNumInBagById(item_cfg.id, nil)	--获取背包的屠魔令数量
	self.node_t_list["lbl_count"].node:setString(item_num)
end

----------视图函数----------


----------end----------

function PrestigeTaskTip:OnCloseBtn()
	self:Close()
end

function PrestigeTaskTip:OnExchangeBtn()
	self:Close()
	ViewManager.Instance:OpenViewByDef(ViewDef.PrestigeTask)
end

--------------------
