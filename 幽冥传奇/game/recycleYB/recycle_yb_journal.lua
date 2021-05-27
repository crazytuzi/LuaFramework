RecycleYBJournalView = RecycleYBJournalView or BaseClass()

function RecycleYBJournalView:__init()
	self.view = nil
	self.page = nil	
end

function RecycleYBJournalView:__delete()
	self:RemoveEvent()
	if self.journal_YB_list then
		self.journal_YB_list:DeleteMe()
		self.journal_YB_list = nil
	end
	self.view = nil
	self.page = nil
end

function RecycleYBJournalView:RemoveEvent()
	
end
function RecycleYBJournalView:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.page = view.node_t_list.layout_recycle_journal
	self:InitEvent()
	self:CreatJournalYBInfoList()
end	
--初始化事件
function RecycleYBJournalView:InitEvent()
	
end
function RecycleYBJournalView:UpdateData(data)
	local journal = RecycleYBData.Instance:GetJournal()
	self.journal_YB_list:SetData(journal)
end	
function RecycleYBJournalView:CreatJournalYBInfoList()
	if nil == self.journal_YB_list then
		self.journal_YB_list = ListView.New()
		local ph = self.view.ph_list.ph_rejournal_list
		self.journal_YB_list:Create(ph.x, ph.y,ph.w,ph.h, nil, JournalYBInfoRender, nil, nil, self.view.ph_list.ph_list_rejournal)
		self.view.node_t_list.layout_recycle_journal.node:addChild(self.journal_YB_list:GetView(), 100)
		self.journal_YB_list:SetSelectCallBack(BindTool.Bind(self.SelectCallItemBack, self))
		self.journal_YB_list:SetJumpDirection(ListView.Top)
		self.journal_YB_list:SetItemsInterval(1)
	end
end

function RecycleYBJournalView:SelectCallItemBack(item, index)
	if item == nil or item:GetData() == nil then return end
	local tmp_data = item:GetData()
end


JournalYBInfoRender = JournalYBInfoRender or BaseClass(BaseRender)
function JournalYBInfoRender:__init()
end

function JournalYBInfoRender:__delete()

end

function JournalYBInfoRender:CreateChild()
	BaseRender.CreateChild(self)

end

function JournalYBInfoRender:OnFlush()
	if self.data == nil then return end
	local journalnum  = RecycleYBData.Instance:ProJournalNum()
	self.node_tree.ranking_head.node:setVisible(self.index <= journalnum)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.goods_ids)
	if nil == item_cfg then 
		return 
	end
	local  color = string.format("%06x", item_cfg and item_cfg.color or 0xccccc)
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername == self.data.role_names then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end
	local text = string.format(Language.RecycleYB.ProJournalTxt, self.rolename_color, self.rolename_color, self.data.role_names, self.rolename_color, Language.RecycleYB.JournalTxt[1], color, item_cfg and item_cfg.name or "xxxx", self.data.goods_ids)
	local state_string = nil
	if self.index <= journalnum then
		local txt_1 = string.format(Language.RecycleYB.JournalTxt[4],self.data.YuanBaos)
		state_string = Language.RecycleYB.JournalTxt[2]..text..txt_1
	else
		local txt_1 = string.format(Language.RecycleYB.JournalTxt[5],self.data.YuanBaos)
		state_string = Language.RecycleYB.JournalTxt[3]..text..txt_1
	end
	RichTextUtil.ParseRichText(self.node_tree.rich_txtjournal.node, state_string, 26)
   	XUI.RichTextSetCenter(self.node_tree.rich_txtjournal.node)
end