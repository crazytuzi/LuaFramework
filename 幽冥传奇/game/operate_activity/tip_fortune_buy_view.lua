TipFortuneBuyView = TipFortuneBuyView or BaseClass(XuiBaseView)

function TipFortuneBuyView:__init()
	--self.is_async_load = false	
	self.is_any_click_close = true
	self.is_modal = true
	self.config_tab = {
		{"privilege_ui_cfg", 4, {0}},
	}

	self.background_opacity = 150
end

function TipFortuneBuyView:__delete()
	
end

function TipFortuneBuyView:ReleaseCallBack()
	if self.grid_list ~= nil then
		self.grid_list:DeleteMe()
		self.grid_list = nil 
	end
end

function TipFortuneBuyView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateGrid()
	end
end

function TipFortuneBuyView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.grid_list then
		local dailyInfo= OperateActivityData.Instance:GetLuckyBuyAwardList()
		if dailyInfo then
			table.sort(dailyInfo,function(a,b)
					return a.tiemr > b.tiemr
				end)
			self.grid_list:SetDataList(dailyInfo)
			self.grid_list:SetJumpDirection(ListView.Top)
		end
	end

end


function TipFortuneBuyView:OnFlush()
end

function TipFortuneBuyView:CloseCallBack(is_all)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function TipFortuneBuyView:CreateGrid()
	if nil == self.grid_list then
		self.grid_list = ListView.New()
		local ph = self.ph_list.ph_name_list
		self.grid_list:Create(ph.x+232, ph.y+225,ph.w,ph.h, nil, TipFortuneBuyRender, nil, nil,self.ph_list.ph_list_item)
		self.grid_list:SetItemsInterval(6)
		self.node_t_list.layout_4.node:addChild(self.grid_list:GetView(), 100)
		self.grid_list:SetJumpDirection(ListView.Top)
		self.grid_list:SetMargin(3)
		local dailyInfo= OperateActivityData.Instance:GetLuckyBuyAwardList()
		if dailyInfo then
			table.sort(dailyInfo,function(a,b)
					return a.tiemr > b.tiemr
				end)
			self.grid_list:SetDataList(dailyInfo)
		end
	end

end


TipFortuneBuyRender = TipFortuneBuyRender or BaseClass(BaseRender)
function TipFortuneBuyRender:__init()

end

function TipFortuneBuyRender:__delete()

end

function TipFortuneBuyRender:CreateChild()
	BaseRender.CreateChild(self)	
end

function TipFortuneBuyRender:OnFlush()	
	if self.data == nil then return end
	if self.data and self.data.tiemr and self.data.tiemr>0 then
		self.node_tree.txt_money_1.node:setString(self.data.player_name)
		local dtas = os.date("%m-%d %H:%M",  self.data.tiemr)
		self.node_tree.txt_countdown_2.node:setString(dtas)
	else
		self.node_tree.txt_countdown_2.node:setString("")
		self.node_tree.txt_money_1.node:setString("")
	end
end
