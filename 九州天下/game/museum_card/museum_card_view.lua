MuseumCardView = MuseumCardView or BaseClass(BaseView)

function MuseumCardView:__init()
	self.ui_config = {"uis/views/museumcardview", "MuseumCardChapter"}
	self:SetMaskBg()
	self.play_audio = true
	self.is_async_load = false
	self.active_close = false

	self.item_cell_list = {}
	self.cur_select_file = 1		-- 所选卷
	self.cur_select_chapter = 1		-- 所选章节

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function MuseumCardView:__delete()
end

function MuseumCardView:ReleaseCallBack()
	self.red_point_list = {}
	self.chapter_item_list = {}

	if next(self.item_cell_list) then
		for k, v in pairs(self.item_cell_list) do
			for k2, v2 in pairs(v) do
				v2:DeleteMe()
				v2 = nil
			end
		end
	end
	self.item_cell_list = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function MuseumCardView:LoadCallBack()
	self.chapter_item_list = {}
	for i = 1, 5 do
		self.chapter_item_list[i] = {}
		self.chapter_item_list[i].select_btn = self:FindObj("select_btn_" .. i)
		self.chapter_item_list[i].list = self:FindObj("list_" .. i)
		self:ListenEvent("OnClickBtn" .. i, BindTool.Bind(self.OnClickSelect, self, i))
		self:LoadCell(i)
	end

	self.red_point_list = {
		[RemindName.MuseumCardOne] = self:FindVariable("ShowRp1"),
		[RemindName.MuseumCardTwo] = self:FindVariable("ShowRp2"),
		[RemindName.MuseumCardThree] = self:FindVariable("ShowRp3"),
		[RemindName.MuseumCardFour] = self:FindVariable("ShowRp4"),
		[RemindName.MuseumCardFive] = self:FindVariable("ShowRp5"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self:ListenEvent("OnClickBtnDesc", BindTool.Bind(self.OnClickBtnDesc, self))
	self:ListenEvent("OnClose", BindTool.Bind(self.Close, self))
end

function MuseumCardView:OpenCallBack()
end

function MuseumCardView:OnClickSelect(index)
	self.cur_select_file = index
end

function MuseumCardView:LoadCell(index)
	PrefabPool.Instance:Load(AssetID("uis/views/museumcardview_prefab", "CardChapterItem"), function (prefab)
		if nil == prefab then
			return
		end

		local item_vo = {}
		local data = MuseumCardData.Instance:GetFileCfgById(index)
		for i = 1, #data do
			local obj = GameObject.Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.chapter_item_list[index].list.transform, false)
			obj:GetComponent("Toggle").group = self.chapter_item_list[index].list.toggle_group
			local item_cell = MuseumCardChapterItem.New(obj)
			item_cell.parent = self
			item_cell:SetIndex(i)
			item_cell:SetFileIndex(index)
			item_cell:SetData(data[i])
			item_vo[i] = item_cell
		end
		self.item_cell_list[index] = item_vo
		PrefabPool.Instance:Free(prefab)
	end)
end

function MuseumCardView:OnFlush(param_t)
	if next(self.item_cell_list) then
		for k, v in pairs(self.item_cell_list) do
			for k2, v2 in pairs(v) do
				v2:Flush()
			end
		end
	end
end

function MuseumCardView:GetCurSelectFile()
	return self.cur_select_file
end

function MuseumCardView:OnClickBtnDesc()
	TipsCtrl.Instance:ShowHelpTipView(261)
end

function MuseumCardView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

---------------------------------------------------------------------------
MuseumCardChapterItem = MuseumCardChapterItem or BaseClass(BaseCell)
function MuseumCardChapterItem:__init(instance)
	self.file_id = 1

	self.name = self:FindVariable("Name")
	self.chapter = self:FindVariable("Chapter")
	self.show_rp = self:FindVariable("ShowRp")

	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnItemClick, self))
end

function MuseumCardChapterItem:__delete()
	self.parent = nil
end

function MuseumCardChapterItem:SetFileIndex(file_id)
	self.file_id = file_id
end

function MuseumCardChapterItem:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	self.name:SetValue(self.data.chapter_name)
	self.chapter:SetValue(string.format(Language.MuseumCard.Chapter, Language.Common.NumToChs[self.index]))

	local has_remind = MuseumCardData.Instance:GetHasRemindByFileAndChap(self.file_id, self.index)
	self.show_rp:SetValue(has_remind)
end

function MuseumCardChapterItem:OnItemClick(is_click)
	if is_click then
		MuseumCardCtrl.Instance:OpenCardThemeView(self.parent:GetCurSelectFile(), self.index)
	end
end