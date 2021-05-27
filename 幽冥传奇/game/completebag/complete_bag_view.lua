CompleteBagView = CompleteBagView or BaseClass(XuiBaseView)

function CompleteBagView:__init()
	self.def_index = 1
 	self.texture_path_list[1] = 'res/xui/download_gift.png'
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		
		{"download_gift_ui_cfg", 1, {0}},
		
	}	

	self.prev_loaded_size = 0
end

function CompleteBagView:__delete()
	
end

function CompleteBagView:ReleaseCallBack()
	if self.progress_handler then
		GlobalEventSystem:UnBind(self.progress_handler)
		self.progress_handler = nil
	end	
	if self.complete_handler then
		GlobalEventSystem:UnBind(self.complete_handler)
		self.complete_handler = nil
	end	
	if self.achieve_handler then
		GlobalEventSystem:UnBind(self.achieve_handler)
		self.achieve_handler = nil
	end	

	if nil ~= self.cell_gift_list then
		for k, v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end
end

function CompleteBagView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateRewardCell()
		XUI.AddClickEventListener(self.node_t_list.btn_download.node, BindTool.Bind1(self.OnDownLoad, self))
		XUI.AddClickEventListener(self.node_t_list.btn_award.node, BindTool.Bind1(self.OnAwardGift, self))
		self.progress_handler = GlobalEventSystem:Bind(CompleteBagEvent.PROGRESS,BindTool.Bind(self.OnProgress,self))
		self.complete_handler = GlobalEventSystem:Bind(CompleteBagEvent.COMPLETE,BindTool.Bind(self.OnComplete,self))
		self.achieve_handler = GlobalEventSystem:Bind(AchievementEventType.ACHIEVE_DATA_CHANGE,BindTool.Bind(self.OnAchieveChange,self))
		XUI.AddClickEventListener(self.node_t_list.layout_checkbox.node, BindTool.Bind(self.OnClickCheckbox, self))

		self.node_t_list.layout_checkbox.img_setting_hook1.node:setVisible(CompleteBagData.Instance.is_auto_down > 0 and true or false)

		if CompleteBagData.Instance.is_down_ing < 1 then
			self.node_t_list.btn_download.node:setTitleText("立即下载")
		else
			self.node_t_list.btn_download.node:setTitleText("正在下载")
		end	
	end

	self:UpdateContent()
end

-- check
function CompleteBagView:OnClickCheckbox()
	local img_hook =  self.node_t_list.layout_checkbox.img_setting_hook1.node
	img_hook:setVisible(not img_hook:isVisible())

	local auto_down = img_hook:isVisible() and 1 or 0
	CompleteBagData.Instance.is_auto_down = auto_down
	cc.UserDefault:getInstance():setIntegerForKey("auto_down_load",auto_down)
end

function CompleteBagView:OnProgress()
	self:UpdateContent()
end	

function CompleteBagView:OnComplete()
	self:UpdateContent()
end	

function CompleteBagView:OnAchieveChange()
	self:UpdateContent()
end

function CompleteBagView:OpenCallBack()

end

function CompleteBagView:CloseCallBack()
	if CompleteBagData.Instance.is_auto_down < 1 then
		if CompleteBagData.Instance.is_down_ing > 0 then
			CompleteBagData.Instance:End()
			CompleteBagData.Instance:RecordEnd()
			self.node_t_list.btn_download.node:setTitleText("立即下载")
		end
	end	 
end

function CompleteBagView:OnFlush(param_t, index)
	
end

function CompleteBagView:ShowIndexCallBack(index)
	self:Flush(index)
end

function CompleteBagView:UpdateContent()
	local achieve = AchieveData.Instance:GetAwardState(CompleteBagData.AchieveID)
	local total_file = CompleteBagData.Instance.total_file
	local loaded_file = CompleteBagData.Instance.has_loaded
	local total_size = CompleteBagData.Instance.total_size
	local loaded_size = CompleteBagData.Instance.loaded_size
	local loaded_error = loaded_size - self.prev_loaded_size
	
	if total_file <= 0 or total_file <= loaded_file then
		self.node_t_list.txt_size.node:setString("100%")
		self.node_t_list.progress_bar.node:setPercent(100)
	else
		local percent = loaded_size / total_size
		self.node_t_list.progress_bar.node:setPercent(math.floor(percent * 100))
		local temp_format = "速度:%sK/S  加载进度:%sM 总大小:%sM"
		loaded_error = loaded_error / 1024
		local down_speed = 0
		down_speed = math.floor(math.max(loaded_error,down_speed))
		local fac = 0.5
		self.node_t_list.txt_size.node:setString(string.format(temp_format,down_speed * fac,math.ceil(loaded_size / 1024 / 1024 * fac),math.ceil(total_size / 1024 / 1024 * fac)))
	end	

	if loaded_file >= total_file then
		self.node_t_list.btn_download.node:setTitleText("下载完成")
		self.node_t_list.btn_download.node:setEnabled(false)
	else	
		self.node_t_list.btn_download.node:setEnabled(true)
	end	

	self.node_t_list.btn_award.node:setEnabled(false)
	--self.node_t_list.bg_recieve.node:setEnabled(false)
	self.node_t_list.img_award.node:setVisible(false)
	--self.node_t_list.bg_recieve.node:setVisible(true)	
	if achieve.finish ~= 0 and achieve.reward == 0 then --完成未领取
		self.node_t_list.btn_award.node:setVisible(true)
		self.node_t_list.btn_award.node:setEnabled(true)
		--self.node_t_list.bg_recieve.node:setEnabled(true)
		--self.node_t_list.bg_recieve.node:setVisible(true)
	elseif achieve.finish == 0 then --未完成

	else
		--self.node_t_list.bg_recieve.node:setVisible(false)
		self.node_t_list.btn_award.node:setVisible(false)
		self.node_t_list.img_award.node:setVisible(true)	
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end	

	self.prev_loaded_size = loaded_size
end	

-- 下载完整包
function CompleteBagView:OnDownLoad()
	if CompleteBagData.Instance.is_down_ing < 1 then
		CompleteBagData.Instance:Start()
		CompleteBagData.Instance:RecordStart()
		self.node_t_list.btn_download.node:setTitleText("正在下载")
	else
		CompleteBagData.Instance:End()
		CompleteBagData.Instance:RecordEnd()
		self.node_t_list.btn_download.node:setTitleText("立即下载")
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()	
end

-- 领取完整包奖励
function CompleteBagView:OnAwardGift()
	AchieveCtrl.Instance:SendAchieveRewardReq(CompleteBagData.AchieveID)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function CompleteBagView:CreateRewardCell()
	self.cell_gift_list = {}
	for i = 1, 5 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_gift_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetVisible(false)
		self.node_t_list.layout_gift_cells.node:addChild(cell:GetView(), 300)

		-- local cell_effect = AnimateSprite:create()
		-- cell_effect:setPosition(ph.x, ph.y)
		-- self.node_t_list.layout_gift_cells.node:addChild(cell_effect, 300)
		-- cell_effect:setVisible(false)
		-- cell.cell_effect = cell_effect

		table.insert(self.cell_gift_list, cell)
	end

	local data = AchieveData.GetAchieveConfig(CompleteBagData.AchieveID)
	local cur_data = {}
	if data then
		for i, v in ipairs(data[1].awards) do
			cur_data[i] = {item_id = v.id, num = v.count, is_bind = 0}
		end
	end
	
	for i1, v1 in ipairs(cur_data) do
		if self.cell_gift_list[i1] then
			self.cell_gift_list[i1]:SetData(v1)
			self.cell_gift_list[i1]:SetVisible(true)
		end	
	end
end





