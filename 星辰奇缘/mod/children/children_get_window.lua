--作者:hzf
--01/04/2017 15:46:51
--功能:子女获取窗口

ChildrenGetWindow = ChildrenGetWindow or BaseClass(BaseWindow)
function ChildrenGetWindow:__init(model)
	self.model = model
	self.Mgr = ChildrenManager.Instance
	self.resList = {
		{file = AssetConfig.childrengetwindow, type = AssetType.Main}
	}
	self.child_update = function()
		self:OnChildUpdate()
	end

	self.hasInit = false
	self.currindex = nil
	self.panelList = {}
	self.indexname = {
		[1] = TI18N("灵心初见"),
		[2] = TI18N("孕育期"),
		[3] = TI18N("幼年期"),
		[4] = TI18N("成长期"),
	}
end

function ChildrenGetWindow:__delete()
	ChildrenManager.Instance.OnChildDataUpdate:RemoveListener(self.child_update)
	for k,v in pairs(self.panelList) do
		v:DeleteMe()
	end
	self.panelList = nil
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChildrenGetWindow:OnHide()

end

function ChildrenGetWindow:OnOpen()

end

function ChildrenGetWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childrengetwindow))
	self.gameObject.name = "ChildrenGetWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.Panel = self.transform:Find("Panel")
	self.Main = self.transform:Find("Main")
	self.Title = self.transform:Find("Main/Title")
	self.Text = self.transform:Find("Main/Title/Text"):GetComponent(Text)
	self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
	self.CloseButton.onClick:AddListener(function()
		self.model:CloseGetWindow()
	end)
	self.TabButtonGroup = self.transform:Find("Main/TabButtonGroup")
	self.tabBtnList = {}
	for i=1,4 do
		local tab = {}
		local btn = self.TabButtonGroup:GetChild(i-1)
		tab.Normal = btn:Find("Normal").gameObject
		tab.Select = btn:Find("Select").gameObject
		self.tabBtnList[i] = tab
	end
	self.Con = self.transform:Find("Main/Con")
	self.panelList = {
		[1] = ChildrenHowToGetPanel.New(self.Con),
		[2] = ChildrenBirthPanel.New(self.Con),
		[3] = ChildrenAfterBirthPanel.New(self.Con),
	}
	self.defaultindex = 1
	if #self.Mgr.childData == 0 then
		--还没有孩子

	else
		local minstage = nil
		for k,v in pairs(self.Mgr.childData) do
			if v.stage < 3 and minstage == nil then
				minstage = v.stage
			end
		end
		if minstage ~= nil then
			-- 有正在养成阶段的孩子
			print("有正在养成阶段的孩子"..tostring(minstage))
			self.defaultindex = minstage + 1
			if minstage == 0 then
				self.defaultindex = 2
			end
		end
	end
	self.tabgroup = TabGroup.New(self.TabButtonGroup.gameObject, function (tab) self:OnTabChange(tab) end, {notAutoSelect = true, noCheckRepeat = true})
	self.tabgroup:ChangeTab(self.defaultindex)
	ChildrenManager.Instance.OnChildDataUpdate:AddListener(self.child_update)
end

function ChildrenGetWindow:OnTabChange(index)
	if self.currindex == nil then
		for k,v in pairs(self.panelList) do
			if index == k then
				v:Show()
			else
				v:Hiden()
			end
		end
		self.currindex = index
	else
		if self.currindex ~= index then
			NoticeManager.Instance:FloatTipsByString(string.format(TI18N("当前处于%s阶段哦{face_1,3}"), self.indexname[self.currindex]))
		end
	end
	self:ResetTopButton()
end

function ChildrenGetWindow:ResetTopButton()
	if self.currindex ~= nil then
		for i=1, 4 do
			self.tabBtnList[i].Normal:SetActive(i ~= self.currindex)
			self.tabBtnList[i].Select:SetActive(i == self.currindex)
		end
	end
end

function ChildrenGetWindow:OnChildUpdate()
	self.defaultindex = 1
	self.currindex = nil
	if #self.Mgr.childData == 0 then
		--还没有孩子

	else
		local minstage = nil
		for k,v in pairs(self.Mgr.childData) do
			if v.stage < 3 and minstage == nil then
				minstage = v.stage
			end
		end
		if minstage ~= nil then
			-- 有正在养成阶段的孩子
			print("有正在养成阶段的孩子"..tostring(minstage))
			self.defaultindex = minstage + 1
			if minstage == 0 then
				self.defaultindex = 2
			end
		end
	end
	self.tabgroup:ChangeTab(self.defaultindex)
	self:ResetTopButton()
end