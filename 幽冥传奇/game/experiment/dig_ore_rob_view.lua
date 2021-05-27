local DigOreRob = BaseClass(BaseView)

function DigOreRob:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/experiment.png'
	}
	self.config_tab = {
		{"experiment_ui_cfg", 2, {0}},
	}

	-- 管理自定义对象
	self._objs = {}
end

function DigOreRob:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack DigOreRob") end
		v:DeleteMe()
	end
	self._objs = {}
end

function DigOreRob:LoadCallBack(index, loaded_times)	
	EventProxy.New(ExperimentData.Instance, self):AddEventListener(ExperimentData.INTO_PK, function (vo)
		---- 进入掠夺pk状态
		-- 创建pk数据显示界面
		if nil == SceneModal.Instance then
			SceneModal.Instance = SceneModal.New()
		end
		SceneModal.Instance:SetData({role_info = vo.info, slot = self.data.slot})
		SceneModal.Instance:Open()
	end)
	

	XUI.AddClickEventListener(self.node_t_list.btn_get.node, function ()
		ExperimentCtrl.SendExperimentOptReq(6, self.data.slot)
	end)
end

function DigOreRob:ShowIndexCallBack()
	self:FlushView()
end

function DigOreRob:FlushView()
	if nil == self.data then
		return 
	end

	local max_time2 = MiningActConfig.torob.daytimes
	self.node_t_list.lbl_title.node:setString(Language.Dig.AccountName[self.data.quality] .. Language.Dig.RobTip1)
	self.node_t_list.lbl_spare_time.node:setString(Language.Dig.RobTip2 .. (max_time2 - ExperimentData.Instance:GetBaseInfo().plunder_num) .. "/" .. max_time2)
	self.node_t_list.lbl_role_name.node:setString(self.data.role_name)
	self.node_t_list.lbl_glide_name.node:setString(self.data.gilde_name == "" and "无" or self.data.gilde_name)

	self:FlushAwardByIdx(self.data.quality)
end

function DigOreRob:FlushAwardByIdx(idx)
	if nil == self._objs.award_list then
		local ph = self.ph_list.ph_award_list
		local list_view = ListView.New()
		list_view:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, BaseCell, nil, false)
		list_view:SetItemsInterval(3)
		self.node_t_list.layout_dig_rob.node:addChild(list_view:GetView(), 100)
		self._objs.award_list = list_view
	end
	local data = {}
	for k,v in ipairs(MiningActConfig.Miner[idx].Awards) do
		data[k] = {item_id = v.id, num = v.count, is_bind = v.bind}
	end
	self._objs.award_list:SetData(data)
end

function DigOreRob:SetData(data)
	self.data = data
end

function DigOreRob:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DigOreRob:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DigOreRob:OnDataChange(vo)
end

return DigOreRob