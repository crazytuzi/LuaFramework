KnightView = KnightView or BaseClass(XuiBaseView)

function KnightView:__init()
	self.texture_path_list[1] = 'res/xui/knight.png'
	self.is_async_load = false
	self.is_modal = true	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"knight_ui_cfg", 1, {0}},
		{"knight_ui_cfg", 2, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.cur_chapter = 1
	self.title_img_path = ResPath.GetKnight("target_txt")
end

function KnightView:__delete()
	
end

function KnightView:ReleaseCallBack()
	if self.kighttak_list then
		self.kighttak_list:DeleteMe()
		self.kighttak_list = nil
	end
	self:DeleteReceive()
	self.text_node = nil
end

function KnightView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreatKnightList()
		self:InitReceive()
		self.node_t_list.layout_1.node:setVisible(true)
		self.node_t_list.layout_2.node:setVisible(false)

		local ph = self.ph_list.ph_pos
		self.text_node = RichTextUtil.CreateLinkText("", 20, COLOR3B.GREEN, nil, true)
		self.node_t_list.layout_common.node:addChild(self.text_node, 999)
		self.text_node:setPosition(ph.x+70, ph.y)
		self.text_node:setString(Language.Knight.Desc)
		XUI.AddClickEventListener(self.text_node, BindTool.Bind1(self.ShowFashionView, self), true)
	end
end

function KnightView:ShowFashionView()
	KnightCtrl.Instance:OpenShowWing()
end

function KnightView:OpenCallBack()
	local knight_cfg = KnightData.Instance:GetKnightChapterCfg()
	self.kighttak_list:SetData(knight_cfg)
	self:FlushText()
	self:CheckHaveAwardAndOpen()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function KnightView:ShowIndexCallBack(index)
	self:Flush(index)
end

function KnightView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function KnightView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "just_data" then
			self:UpdateData()
			self:FlushText()
		end
	end
end

function KnightView:FlushText()

	local left_time = KnightData.Instance:GetRoleCreat()
	self.node_t_list.txt_day.node:setString(Language.Common.RemainTime.."："..left_time..Language.Guild.Day)
	local all_progress = KnightErrantCfg.KnightErrantTotalProgress	
	local all_finish = KnightData.Instance:GetProgressData()
	self.node_t_list.prog_knight.node:setPercent(all_finish/all_progress * 100)
	self.node_t_list.txt_uplev.node:setString(all_finish.."/" .. all_progress)
	

end
function KnightView:CreatKnightList()
	if nil == self.kighttak_list then
		self.kighttak_list = ListView.New()
		local ph = self.ph_list.ph_knight_list
		self.kighttak_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, KnightViewAttrRender, gravity, is_bounce, self.ph_list.ph_knight_item)
		self.kighttak_list:SetItemsInterval(2.7)
		self.node_t_list.layout_1.node:addChild(self.kighttak_list:GetView(), 100)
		self.kighttak_list:SetSelectCallBack(BindTool.Bind(self.SelectCallItemBack, self))
	end
end

function KnightView:SelectCallItemBack(item)
	if item == nil or item:GetData() == nil then return end
	local data = item:GetData()
	if data.is_open then
			self:OpenChapterInfoPanel(data)	
		-- local index = KnightData.Instance:GetMinRemindDataIndex()
		-- if index then
		-- 	item = self.kighttak_list:GetItemAt(index)
		-- 	local temp_data = item:GetData()
		-- 	self:OpenChapterInfoPanel(temp_data)
		-- else
		-- end
	else
		local open_day = data.createRoleOpenDay
		local txt = string.format(Language.Knight.Knight_Remind, open_day or "")
		SysMsgCtrl.Instance:FloatingTopRightText(txt)
	end

end

function KnightView:OpenChapterInfoPanel(data)
	self.node_t_list.layout_1.node:setVisible(false)
	self.node_t_list.layout_2.node:setVisible(true)
	self:FlushChapterInfo(data, true)
end	

function KnightView:CheckHaveAwardAndOpen()
	local index = KnightData.Instance:GetMinRemindDataIndex()
	if index then
		item = self.kighttak_list:GetItemAt(index)
		data = item:GetData()
		self:OpenChapterInfoPanel(data)
	end
end




KnightViewAttrRender = KnightViewAttrRender or BaseClass(BaseRender)
function KnightViewAttrRender:__init()
end

function KnightViewAttrRender:__delete()
end

function KnightViewAttrRender:CreateChild()
	BaseRender.CreateChild(self)
end


function KnightViewAttrRender:OnFlush()
	if self.data == nil then return end
	local chapter_task = self.data.progressValue
	local finish_num = self.data.finish_num
	if self.data.is_open == true then
		self.node_tree.pic_nochapter.node:setVisible(true)
		self.node_tree.pic_chapter.node:setVisible(true)
		self.node_tree.txt_finish.node:setVisible(true)
		self.node_tree.pic_word.node:setVisible(true)
		self.node_tree.pic_word.node:loadTexture(ResPath.GetKnight("task_".. self.data.chapterId))
		self.node_tree.txt_finish.node:setString(finish_num.."/"..chapter_task)
	else
		self.node_tree.pic_chapter.node:setVisible(false)
		self.node_tree.txt_finish.node:setVisible(false)
		self.node_tree.pic_word.node:setVisible(false)
		self.node_tree.pic_nochapter.node:setVisible(false)
	end
	RichTextUtil.ParseRichText(self.node_tree.txt_chapter.node, self.data.chapterName, 28, cc.c3b(0xe3, 0xe0, 0xad),33,366)
	self.node_tree.img_lock.node:setVisible( not self.data.is_open)
	self.node_tree.remind_name.node:setVisible(self.data.need_remind)

end



