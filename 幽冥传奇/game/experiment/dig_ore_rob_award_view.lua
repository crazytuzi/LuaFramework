local DigOreRobAward = BaseClass(BaseView)

function DigOreRobAward:__init()
	self:SetModal(true)
	self.is_any_click_close = true										-- 是否点击其它地方要关闭界面
	self.texture_path_list = {
		'res/xui/experiment.png'
	}
	self.config_tab = {
		{"experiment_ui_cfg", 5, {0}},
	}

	-- 管理自定义对象
	self._objs = {}
	self.data = nil
end

function DigOreRobAward:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack DigOreRobAward") end
		v:DeleteMe()
	end
	self._objs = {}
end

function DigOreRobAward:LoadCallBack(index, loaded_times)
	XUI.AddClickEventListener(self.node_t_list.btn_get_award.node, function ()
		self:Close()
	end)
end

function DigOreRobAward:ShowIndexCallBack() 
	if self.data then	
		local list = {}
		local data = MiningActConfig.Miner[self.data.idx].Awards
		for k,v in ipairs(data) do
			list[k] = {item_id = v.id, num = math.ceil(v.count * (self.data.rate / 10000)), is_bind = v.bind}
		end
		
		if nil == self._objs.bag_grid then
			local ph = self.ph_list.ph_bag
		    self._objs.bag_grid = BaseGrid.New()
			
		    local grid_node = self._objs.bag_grid:CreateCells({ w=ph.w, h=ph.h, cell_count= #data, col=4, row=3, itemRender = BaseCell,
		                                                   direction = ScrollDir.Vertical})
		    self.node_t_list.layout_dig_rob_award.node:addChild(grid_node, 100)
			grid_node:setPosition(ph.x, ph.y)
		end

	    if not list[0] and list[1] then
	        list[0] = table.remove(list, 1)
	    end
	    self._objs.bag_grid:SetDataList(list)
	end
end

function DigOreRobAward:CreateBagView()

end

function DigOreRobAward:SetData(data)
	self.data = data
end

function DigOreRobAward:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DigOreRobAward:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	
	ExperimentCtrl.SendExperimentOptReq(8)
	self.data = nil

	 self._objs.bag_grid:DeleteMe()
	 self._objs.bag_grid = nil
end

function DigOreRobAward:OnDataChange(vo)
end

return DigOreRobAward