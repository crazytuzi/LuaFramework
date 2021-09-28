require("game/marriage/marriage_halo_content_view")

MarriageHaloView = MarriageHaloView or BaseClass(BaseRender)

function MarriageHaloView:__init(instance)
	-- self.halo_view = MarriageHaloContentView.New(self:FindObj("HaloContent"))
	self.love_tree_view = MarriageLoveTreeView.New(self:FindObj("LoveTreeContent"))

	self.tab_halo = self:FindObj("TabHalo")
	self.tab_love_tree = self:FindObj("TabLoveTree")

	self.lover_tree_red = self:FindVariable("LoverTreeRed")

	self.tab_halo.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_halo_content))
	self.tab_love_tree.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_love_tree))
end

function MarriageHaloView:__delete()
	if self.halo_view then
		self.halo_view:DeleteMe()
		self.halo_view = nil
	end

	if self.love_tree_view then
		self.love_tree_view:DeleteMe()
		self.love_tree_view = nil
	end
end

function MarriageHaloView:ShowOrHideTab()
	local open_fun_data = OpenFunData.Instance
	local data = {}
	data["tab_halo"] = open_fun_data:CheckIsHide("marriage_halo_content")
	data["tab_love_tree"] = open_fun_data:CheckIsHide("marriage_love_tree")
	for k, v in pairs(data) do
		if self[k] then
			self[k]:SetActive(v)
		end
	end
end

function MarriageHaloView:OnToggleChange(index, ison)
	if ison then
		if index == TabIndex.marriage_love_tree then
			MarriageCtrl.Instance:SendLoveTreeInfoReq(1)
			self.love_tree_view.init_progess = true
		end
	end
end

function MarriageHaloView:SetLoveTreeRedPoint()
	local show_red_point = MarriageData.Instance:GetRedPointByKey("love_tree")
	self.lover_tree_red:SetValue(show_red_point)
end

function MarriageHaloView:OpenHaloCallBack()
	GlobalTimerQuest:AddDelayTimer(function()
		if self.tab_halo.gameObject.activeInHierarchy then
			self.tab_halo.toggle.isOn = true
		elseif self.tab_love_tree.gameObject.activeInHierarchy then
			if self.tab_love_tree.toggle.isOn then
				MarriageCtrl.Instance:SendLoveTreeInfoReq(1)
				self.love_tree_view.init_progess = true
			else
				self.tab_love_tree.toggle.isOn = true
			end
		end
		self:SetLoveTreeRedPoint()
	end, 0)
end

function MarriageHaloView:ShowHaloIndex(index)
	if index == TabIndex.marriage_love_tree then
		if self.tab_love_tree.toggle.isOn then
			MarriageCtrl.Instance:SendLoveTreeInfoReq(1)
			self.love_tree_view.init_progess = true
		else
			self.tab_love_tree.toggle.isOn = true
		end
	elseif index == TabIndex.marriage_halo_content then
		self.tab_halo.toggle.isOn = true
	end
	self:SetLoveTreeRedPoint()
end

function MarriageHaloView:HaloChange()
	-- if self.tab_halo.toggle.isOn then
	-- 	self.halo_view:HaloChange()
	-- end
end

function MarriageHaloView:FlushLoveTreeView()
	if self.tab_love_tree.toggle.isOn then
		self.love_tree_view:FlushLoveTreeView()
		self:SetLoveTreeRedPoint()
	end
end