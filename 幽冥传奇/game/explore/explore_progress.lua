-- 全服进度

local ExploreProgressView = BaseClass(SubView)

function ExploreProgressView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"explore_ui_cfg", 7, {0}},
	}
end

function ExploreProgressView:__delete()
	
end

function ExploreProgressView:ReleaseCallBack()
	
end

function ExploreProgressView:LoadCallBack(index, loaded_times)
	local index = 0
	for i = 1, 5 do
		index = index + DmkjConfig.fullSvrAwards[i].dmTimes
		self.node_t_list["txt_num_" .. i].node:setString(index .. "次")

		local cell_ph = self.ph_list["ph_rew_cell" .. i]
		local cell = BaseCell.New()
		cell:SetIsUseStepCalc(true)
		cell:SetPosition(cell_ph.x, cell_ph.y)
		cell:SetAnchorPoint(0.5, 0.5)
		local data = DmkjConfig.fullSvrAwards[i].awards[1]
		local item = {item_id = data.id, num = data.count, is_bind = data.bind}
		cell:SetData(item)
		self.node_t_list.layout_progress.node:addChild(cell:GetView(), 10)
		cell:SetCellSpecialBg(ResPath.GetCommon("cell_108"))

	end

	-- 查看详情
	local text = RichTextUtil.CreateLinkText("查看详情", 19, COLOR3B.GREEN, nil, true)
	text:setPosition(460, 80)
	self.node_t_list.layout_progress.node:addChild(text, 9)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnClickXQ, self), true)

	self.join_txt = RichTextUtil.CreateLinkText("点击参与", 19, COLOR3B.GREEN, nil, true)
	self.join_txt:setPosition(350, 15)
	self.node_t_list.layout_progress.node:addChild(self.join_txt, 9)
	XUI.AddClickEventListener(self.join_txt, BindTool.Bind(self.OnClickJoin, self), true)

	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.EXPLORE_SCORE_CHANGE, BindTool.Bind(self.Flush, self))
end

function ExploreProgressView:OnClickXQ()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore.PrizeInfo)
end

function ExploreProgressView:ShowIndexCallBack(index)
	self:Flush()
end

function ExploreProgressView:OnClickJoin()
	-- local own_join = ExploreData.Instance:GetNowIndexState()
	-- if own_join == 0 then
		ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Xunbao)
	-- end
end
	
function ExploreProgressView:OpenCallBack()
	ExploreCtrl.Instance:WorldInfoReq()
end

function ExploreProgressView:CloseCallBack()
end

function ExploreProgressView:OnFlush(param_t, index)
	local now_time = ExploreData.Instance:GetNowTime() 		-- 全服进度次数
	local own_join = ExploreData.Instance:GetNowIndexState() 		-- 个人参与次数
	local bet_time = ExploreData.Instance:GetIndexSubtract() 		-- 档位之差（用来计算中奖率）
	local xbtime = ExploreData.Instance:GetWorldTime() 			--  全服寻宝次数

	for i = 1, 5 do
		self.node_t_list["img_end_" .. i].node:setVisible(xbtime >= ExploreData.Instance:GetExploreTime()[i])
	end

	local now_txt = string.format(Language.JiFenEquipment.OwnXunbao[3], now_time)
	RichTextUtil.ParseRichText(self.node_t_list.rich_now_time.node, now_txt, 18, COLOR3B.G_W2)

	if own_join then
		self.join_txt:setVisible(own_join == 0)
		self.node_t_list.lbl_join_num.node:setVisible(own_join ~= 0)
		local txt = own_join == 0 and Language.JiFenEquipment.OwnXunbao[1] or string.format(Language.JiFenEquipment.OwnXunbao[2], own_join)
		self.node_t_list.lbl_join_num.node:setString(txt)
		local zj_txt = string.format(Language.JiFenEquipment.OwnXunbao[4], math.floor(own_join/bet_time*100) .. "%")
		RichTextUtil.ParseRichText(self.node_t_list.rich_gailv.node, zj_txt, 18, COLOR3B.G_W2)
	else
		self.join_txt:setVisible(false)
		self.node_t_list.lbl_join_num.node:setVisible(true)
		self.node_t_list.rich_gailv.node:setVisible(false)
		self.node_t_list.lbl_join_num.node:setString("所有进度已开奖")
	end
end

return ExploreProgressView