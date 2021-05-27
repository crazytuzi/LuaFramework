KnightView = KnightView or BaseClass(XuiBaseView)

function KnightView:InitReceive()
	XUI.AddClickEventListener(self.node_t_list.btn_proreceive.node, BindTool.Bind1(self.OpenProgressAward, self), true)
	XUI.AddClickEventListener(self.node_t_list.pic_chapter.node, BindTool.Bind1(self.ReturnKnightView, self), false)
	XUI.AddClickEventListener(self.node_t_list.pic_left.node, BindTool.Bind1(self.OnLeftChapterCallBack, self), true)
	XUI.AddClickEventListener(self.node_t_list.pic_right.node, BindTool.Bind1(self.OnRightChapterCallBack, self), true)
	self:KnightReceiveList()
	self:CreateCells()
	self.max_chapter = KnightData.Instance:GetMaxChpater()
	self.achieve_evt = GlobalEventSystem:Bind(AchievementEventType.ACHIEVE_DATA_CHANGE, BindTool.Bind(self.UpdateData, self))
end	

function KnightView:DeleteReceive()
	if self.kightreceive_list then
		self.kightreceive_list:DeleteMe()
		self.kightreceive_list = nil
	end
	if self.cell_gift_list then
		for _, v in ipairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end
	if self.achieve_evt then
		GlobalEventSystem:UnBind(self.achieve_evt)
		self.achieve_evt = nil
	end
	ClientCommonButtonDic[CommonButtonType.KNIGHT_AWARD_GRID] = nil
end

function KnightView:UpdateData()
	local total_data = KnightData.Instance:GetKnightChapterCfg()
	local cur_data = total_data[self.cur_chapter]
	self:FlushChapterInfo(cur_data)
end


function KnightView:FlushChapterInfo(cur_data, is_jump)
	local total_data = KnightData.Instance:GetKnightChapterCfg()
	self.cur_chapter = cur_data.chapterId
	if self.cur_chapter == 1 then
		self.node_t_list.remind_left.node:setVisible(false)
	else
		local left_remind =KnightData.Instance:RemindLeft(self.cur_chapter)
		if left_remind ~= nil then
			self.node_t_list.remind_left.node:setVisible(left_remind<self.cur_chapter)
		else
			self.node_t_list.remind_left.node:setVisible(false)
		end
	end
	if self.cur_chapter == self.max_chapter then
		self.node_t_list.remind_right.node:setVisible(false)
	else
		local right_remind =KnightData.Instance:RemindRight(self.cur_chapter)
		if right_remind ~= nil then
			self.node_t_list.remind_right.node:setVisible(self.cur_chapter<right_remind)
		else
			self.node_t_list.remind_right.node:setVisible(false)
		end
	end
	self.node_t_list.pic_left.node:setVisible(self.cur_chapter ~= 1)
 	local chapter_next = total_data[self.cur_chapter+ 1] 
 	self.node_t_list.pic_right.node:setVisible(self.cur_chapter ~= self.max_chapter and (chapter_next and chapter_next.is_open))

 	self.node_t_list.btn_proreceive.node:setVisible(cur_data.state == 1)
	self.node_t_list.img_already_pro.node:setVisible(cur_data.state == 2)
	self.node_t_list.img_unsuccess_pro.node:setVisible(cur_data.state == 0)
	
	local award_data = cur_data.myAwards
	local cur_award_data = {}
	if award_data then
		for k2, v2 in pairs(award_data) do
			cur_award_data[k2] = {item_id = v2.id, num = v2.count, is_bind = 0}
		end
	end
	for k3, v3 in pairs(cur_award_data) do
		if self.cell_gift_list[k3] then
			self.cell_gift_list[k3]:SetData(v3)
			self.cell_gift_list[k3]:SetVisible(true)
		end	
	end
	KnightData.Instance:SortListData(cur_data)

	self.kightreceive_list:SetDataList(cur_data.content)
	if is_jump then
		self.kightreceive_list:AutoJump()
	end	
	self.node_t_list.pic_word.node:loadTexture(ResPath.GetKnight("task_".. cur_data.chapterId))
	self.node_t_list.txt_chapter.node:setString(cur_data.chapterName)
	self.node_t_list.txt_finish.node:setString(cur_data.finish_num.."/"..cur_data.progressValue)	
	self.node_t_list.txt_protask.node:setString(cur_data.chapterName..Language.Knight.Knight_Award)
	self.node_t_list.finish_count.node:setString(cur_data.finish_num.."/"..cur_data.progressValue)
end

function KnightView:CreateCells()
	self.cell_gift_list = {}
	for i = 1, 2 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_gift_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetVisible(false)
		self.node_t_list.layout_progress_cells.node:addChild(cell:GetView(), 300)
		table.insert(self.cell_gift_list, cell)
	end
end

function KnightView:KnightReceiveList()
	if nil == self.kightreceive_list then
		self.kightreceive_list = ListView.New()
		local ph = self.ph_list.ph_reward_list
		self.kightreceive_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, KnightReceiveAttrRender, gravity, is_bounce, self.ph_list.ph_reward_item)
		self.kightreceive_list:SetItemsInterval(1)
		self.kightreceive_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_2.node:addChild(self.kightreceive_list:GetView(), 100)
		ClientCommonButtonDic[CommonButtonType.KNIGHT_AWARD_GRID] = self.kightreceive_list
	end
end

function KnightView:ReturnKnightView()
	self.node_t_list.layout_1.node:setVisible(true)
	self.node_t_list.layout_2.node:setVisible(false)
	local knight_cfg = KnightData.Instance:GetKnightChapterCfg()	--返回界面刷新
	self.kighttak_list:SetData(knight_cfg)
end

function KnightView:OpenProgressAward()
	if self.cur_chapter then
		KnightCtrl.Instance:SendKnightInfoReq(self.cur_chapter)
	end
end

function KnightView:OnLeftChapterCallBack()
	if self.cur_chapter > 1 then
		self.cur_chapter = self.cur_chapter - 1
	end	
	local total_data = KnightData.Instance:GetKnightChapterCfg()
	local cur_data = total_data[self.cur_chapter]
	local left_remind =KnightData.Instance:RemindLeft(self.cur_chapter)
	if left_remind ~= nil then
		self.node_t_list.remind_left.node:setVisible(left_remind<self.cur_chapter)
	else
		self.node_t_list.remind_left.node:setVisible(false)
	end
	self:FlushChapterInfo(cur_data, true)
	self.node_t_list.pic_left.node:setVisible(self.cur_chapter ~= 1)
end

function KnightView:OnRightChapterCallBack()
	local next_chapter = self.cur_chapter + 1
	local total_data = KnightData.Instance:GetKnightChapterCfg()
	local cur_data = total_data[next_chapter]


	if self.cur_chapter < self.max_chapter 
		and cur_data.is_open then
		self.cur_chapter = next_chapter
		self:FlushChapterInfo(cur_data, true)
	end	

	if self.cur_chapter ~= self.max_chapter then
		local cur_data = total_data[self.cur_chapter + 1]
		local right_remind =KnightData.Instance:RemindRight(self.cur_chapter)
		if right_remind ~= nil then
			self.node_t_list.remind_right.node:setVisible(self.cur_chapter<right_remind)
		else
			self.node_t_list.remind_right.node:setVisible(false)
		end
		self.node_t_list.pic_right.node:setVisible(cur_data.is_open)
	else
		self.node_t_list.pic_right.node:setVisible(false)
	end	

end

KnightReceiveAttrRender = KnightReceiveAttrRender or BaseClass(BaseRender)
function KnightReceiveAttrRender:__init()
end

function KnightReceiveAttrRender:__delete()
	if self.cell_gift_list then
		for _, v in ipairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = nil
	end
end

function KnightReceiveAttrRender:CreateChild()
	BaseRender.CreateChild(self)
	
	self.cell_gift_list = {}
	for i = 1, 2 do
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_gift_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetVisible(false)
		self.node_tree.layout_task_cells.node:addChild(cell:GetView(), 300)
		table.insert(self.cell_gift_list, cell)
	end
	
	XUI.AddClickEventListener(self.node_tree.btn_get.node, BindTool.Bind1(self.OnClickGetAwardsHandler, self))
end


function KnightReceiveAttrRender:OnFlush()
	if self.data == nil then return end
	local achieve_cfg = AchieveData.GetAchieveConfig(self.data.achieveId)
	local achieve_award = achieve_cfg[1].awards
	local cur_data = {}
	if achieve_award then
		for k1, v1 in pairs(achieve_award) do
			cur_data[k1] = {item_id = v1.id, num = v1.count, is_bind = v1.bind}
		end
	end
	for k3, v3 in pairs(cur_data) do
		if self.cell_gift_list[k3] then
			self.cell_gift_list[k3]:SetData(v3)
			self.cell_gift_list[k3]:SetVisible(true)
		end	
	end
	local ph = self.ph_list.ph_quick_links
	if self.text_node == nil then
		self.text_node = RichTextUtil.CreateLinkText("", 20, COLOR3B.WHITE, nil, true)
		self.text_node:setPosition(ph.x, ph.y)
		self.text_node:setColor(COLOR3B.GREEN)
		self.view:addChild(self.text_node, 999)
		XUI.AddClickEventListener(self.text_node, BindTool.Bind1(self.QuickLinks, self), true)
	end
	if self.data.teleId == nil then
		self.text_node:setVisible(false)
	else
		self.text_node:setVisible(true)
	end
	self.text_node:setString(Language.ActiveDegree.ActivityQuickLinks)

	self.node_tree.txt_task.node:setString(self.data.name)
	local achieve_finish = AchieveData.Instance:GetAwardState(self.data.achieveId)
	local achieve_cfg = AchieveData.GetAchieveConfig(self.data.achieveId)
	local achieve_all = achieve_cfg[1].conds[1]
	local count = nil

	if achieve_finish.finish == 1 then
		self.already_complete = true
	else
		self.already_complete = false
	end	
	--完成时
	if self.already_complete then
		self.node_tree.txt_percent.node:setString(achieve_all.count.."/"..achieve_all.count)
		self.node_tree.btn_get.node:setVisible(true)
		self.node_tree.img_already_get.node:setVisible(false)
		self.node_tree.img_unsuccess.node:setVisible(false)
	else
		self.node_tree.btn_get.node:setVisible(false)
		self.node_tree.img_already_get.node:setVisible(false)
		self.node_tree.img_unsuccess.node:setVisible(true)
		local num_tab = AchieveData.Instance:GetAchieveFinishCount(achieve_all.eventId)
		count = num_tab and num_tab.count or 0
		self.node_tree.txt_percent.node:setString(count.."/"..achieve_all.count)

	end
	if achieve_finish.reward == 1 then
		self.node_tree.btn_get.node:setVisible(false)
		self.node_tree.img_already_get.node:setVisible(true)
		self.node_tree.img_unsuccess.node:setVisible(false)	
	end	

end
function KnightReceiveAttrRender:QuickLinks()
	if self.data == nil or self.is_finish == true then return end
	ActivityCtrl.DoTelActionByTelId(self.data.teleId)
	ViewManager.Instance:Close(ViewName.Knight)
end


function KnightReceiveAttrRender:OnClickGetAwardsHandler()
	AchieveCtrl.Instance:SendAchieveRewardReq(self.data.achieveId)
end

function KnightReceiveAttrRender:GetGuideView()
	return self.node_tree.btn_get.node
end

function KnightReceiveAttrRender:CompareGuideData(data)
	return self.data and self.data.achieveId == data
end








