-- 个人寻宝
ExplorePersonalPage = ExplorePersonalPage or BaseClass()


function ExplorePersonalPage:__init()
	
end	

function ExplorePersonalPage:__delete()
	if self.personal_cell_list ~= nil then
		for k,v in pairs(self.personal_cell_list) do
			v:DeleteMe()
		end
		self.personal_cell_list = {}
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	self:RemoveEvent()
end	

--初始化页面接口
function ExplorePersonalPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.show_data = {}	

	Runner.Instance:AddRunObj(self)
	self:InitEvent()
end	


--初始化事件	
function ExplorePersonalPage:InitEvent()
	-- self.show_data = {}
 	
	ExploreCtrl.Instance:SendPersonalXunbaoReq()
	self:CreateTreasureCell()

	XUI.AddClickEventListener(self.view.node_t_list.btn_start.node, BindTool.Bind2(self.OnXunbaoReceive, self, 1))
	XUI.AddClickEventListener(self.view.node_t_list.btn_all.node, BindTool.Bind2(self.OnXunbaoReceive, self, 0))
	XUI.AddClickEventListener(self.view.node_t_list.btn_flush.node, BindTool.Bind2(self.OnFlushData, self))

	self.view.node_t_list.img_point.node:setAnchorPoint(0.5, 0)

	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self, -1),  1)
end

--移除事件
function ExplorePersonalPage:RemoveEvent()
	
end

function ExplorePersonalPage:Update(now_time, elapse_time)
	
end	

--更新视图界面
function ExplorePersonalPage:UpdateData(data)
	local times, flush_time, xunbao_data = ExploreData.Instance:GetXunbaoInfo()
	self.show_data = {}
	local path = ResPath.GetExplore("bg_4")
	for k,v in pairs(xunbao_data) do
		local item = {item_id = v.id,num = v.count,is_bind = v.bind}
		table.insert(self.show_data,item)
		self.personal_cell_list[k]:SetData(self.show_data[k])
		if v.is_receive == 1 then
			XUI.SetLayoutImgsGrey(self.personal_cell_list[k]:GetCellView(), true)
			self.personal_cell_list[k]:SetXunbaoBg(path)
		else
			XUI.SetLayoutImgsGrey(self.personal_cell_list[k]:GetCellView(), false)
		end
	end

		
	local xunbao_times, rec_data = ExploreData.Instance:GetReceiveResult()

	self.view.node_t_list.btn_start.node:setEnabled(xunbao_times ~= 10)
	self.view.node_t_list.img_all.node:setEnabled(xunbao_times ~= 10)
	self.view.node_t_list.btn_all.node:setEnabled(xunbao_times ~= 10)
	self.view.node_t_list.img_flush.node:setEnabled(xunbao_times ~= 10)
	self.view.node_t_list.btn_flush.node:setEnabled(xunbao_times ~= 10)
	self.view.node_t_list.flush_time.node:setVisible(xunbao_times == 10)

	if nil ~= rec_data then
		for k1,v1 in pairs(rec_data) do
			if v1 == 0 then
				for i = 1,10 do
					XUI.SetLayoutImgsGrey(self.personal_cell_list[i]:GetCellView(), true)
					self.personal_cell_list[i]:SetXunbaoBg(path)
				end
			else
				self:RotateToTargetPos(rec_data, xunbao_times)
				-- XUI.SetLayoutImgsGrey(self.personal_cell_list[v1]:GetCellView(), true)
				-- self.personal_cell_list[v1]:SetXunbaoBg(path)
			end
		end
	end



	local id = DmkjConf.DmParam[2][1].item.id 
	local item_cfg = ItemData.Instance:GetItemConfig(id)
	if nil == item_cfg then
		return 
	end
	local all_get = DmkjConf.DmParam[2][1].yb * 10
	local one_get = DmkjConf.DmParam[2][1].yb
	local flush_num = (flush_time+1) * DmkjConf.DmParam[3][1].yb
	self.view.node_t_list.txt_all_get.node:setString(string.format(Language.Explore.NeedMoney, DmkjConf.DmParam[2][1].yb))
	self.view.node_t_list.txt_all_get.node:setString(all_get..Language.Common.Gold)
	self.view.node_t_list.txt_need_flush.node:setString(flush_num..Language.Common.Gold)
    self.view.node_t_list.txt_need_yb.node:setString(one_get..Language.Common.Gold.."("..item_cfg.name.."X".."1"..")")
	self:FlushTime()
end	

function ExplorePersonalPage:CreateTreasureCell()
	self.personal_cell_list = {}
	for i = 1, 10 do
		local ph = self.view.ph_list["ph_cell_"..i]
		local cell = ExplorePersonalCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetCellBg(ResPath.GetCommon("cell_100"))
		self.view.node_t_list.layout_per_showitem.node:addChild(cell:GetView(), 103)
		cell:AddClickEventListener(BindTool.Bind(self.SelectBaoWuCallBack, self, cell))

		table.insert(self.personal_cell_list, cell)
		local act_eff = RenderUnit.CreateEffect(920, self.view.node_t_list.layout_per_showitem.node, 200, nil, nil,  ph.x + 2, ph.y + 2)
	end
end

function ExplorePersonalPage:FlushTime()
	local xunbao_times, rec_data = ExploreData.Instance:GetReceiveResult()
	local time = ExploreData.Instance:XunbaoFlushTime() - TimeCtrl.Instance:GetPhpServerTime()
	local time_str = TimeUtil.FormatSecond2Str(time, 1)
	if time <= 0 or xunbao_times == 10 then
		self.view.node_t_list.flush_time.node:setVisible(false)
	else
		self.view.node_t_list.flush_time.node:setVisible(true)
		self.view.node_t_list.flush_time.node:setString(string.format(Language.Explore.FlushTime, time_str))
	end
end

function ExplorePersonalPage:SelectBaoWuCallBack()
end

function ExplorePersonalPage:OnXunbaoReceive(rec_type)
	ExploreCtrl.Instance:SendPersonalXunbaoReceive(rec_type)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function ExplorePersonalPage:OnFlushData()
	ExploreCtrl.Instance:SendFlushData()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function ExplorePersonalPage:RotateToTargetPos(data, num)
	local index = ExploreData.Instance:GetXunbaoNum()
	local target_deg = 0
	local rotate_to = nil
	local sequ_actions = nil
	local call_back_fun = nil

	if index ~= nil and index ~= 0 then
		self.view.node_t_list.btn_start.node:setEnabled(false)
		local laps = math.random(5, 8)
		target_deg = (index  - 1) * 36 + 360 * laps 
		rotate_to = cc.RotateTo:create(5, target_deg)
		local easeOptionOut = cc.EaseExponentialOut:create(rotate_to)
		local turn_complete_call_fun = function()
			ExploreData.Instance:ResetRecriveId()	
			self.view.node_t_list.btn_start.node:setEnabled(num < 10)

			local path = ResPath.GetExplore("bg_4")
			if nil ~= data then
				for k1,v1 in pairs(data) do
					if v1 == 0 then
						for i = 1,10 do
							XUI.SetLayoutImgsGrey(self.personal_cell_list[i]:GetCellView(), true)
							self.personal_cell_list[i]:SetXunbaoBg(path)
						end
					else
						XUI.SetLayoutImgsGrey(self.personal_cell_list[v1]:GetCellView(), true)
						self.personal_cell_list[v1]:SetXunbaoBg(path)
					end
				end
			end
		end

		call_back_fun = cc.CallFunc:create(turn_complete_call_fun)
		sequ_actions = cc.Sequence:create(easeOptionOut, call_back_fun)

		self.view.node_t_list.img_point.node:runAction(sequ_actions)
	end
end


ExplorePersonalCell = ExplorePersonalCell or BaseClass(BaseRender)
function ExplorePersonalCell:__init()
	self:SetIsUseStepCalc(false)
	self.item_cell = BaseCell.New()
	self.item_cell:SetIsUseStepCalc(false)
	self.view:addChild(self.item_cell:GetView())

	self.item_cell:SetAnchorPoint(0.5, 0.5)	

	self.award_state_img = nil
end

function ExplorePersonalCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end	
end

function ExplorePersonalCell:OnFlush()
	if self.data then
		self.item_cell:SetData(self.data)
	end	
end	

function ExplorePersonalCell:GetCellView()
	return self.item_cell:GetView()
end	

function ExplorePersonalCell:SetCellBg(path)
	self.item_cell:SetCellBg(path)
end	

function ExplorePersonalCell:SetXunbaoBg(path) 
	if not self.award_state_img then
		self.award_state_img = XUI.CreateImageView(0,0)
		self.view:addChild(self.award_state_img)
	end	

	self.award_state_img:loadTexture(path)
end	

