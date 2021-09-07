--作者:hzf
--03/23/2017 16:52:15
--功能:战斗弹幕列表功能

DanmakuHistoryPanel = DanmakuHistoryPanel or BaseClass(BasePanel)
function DanmakuHistoryPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.danmakuhistory, type = AssetType.Main}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.updatefunc = function()
		self:InitList()
	end
	self.switchChange = function()
        self.Toggle.isOn = DanmakuManager.Instance.model.isshow
	end
	self.itemList = {}
	self.oldList = {}
	self.clicktrans = nil
	self.clickdata = nil
	self.endfrightfunct = function()
		self.model:CloseHisPanel()
	end
end

function DanmakuHistoryPanel:__delete()
	CombatManager.Instance.OnDanmakuPoolChange:Remove(self.updatefunc)
	DanmakuManager.Instance.OnDanmakuSwitch:Remove(self.switchChange)
	EventMgr.Instance:RemoveListener(event_name.end_fight, self.endfrightfunct)
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function DanmakuHistoryPanel:OnHide()

end

function DanmakuHistoryPanel:OnOpen()

end

function DanmakuHistoryPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.danmakuhistory))
	self.gameObject.name = "DanmakuHistoryPanel"

	self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
	self.transform.localScale = Vector3.one
	self.transform.localPosition = Vector3.zero
	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseHisPanel()
	end)
	self.Main = self.transform:Find("Main")
	-- self.Container = self.transform:Find("Main/Container")
	self.nothing = self.transform:Find("Main/Container/UnOpen").gameObject
	self.Listbg = self.transform:Find("Main/Container/Listbg")
	self.MaskCon = self.transform:Find("Main/Container/MaskCon")
	self.ScrollLayer = self.transform:Find("Main/Container/MaskCon/ScrollLayer")
	self.Container = self.transform:Find("Main/Container/MaskCon/ScrollLayer/Container")
	self.baseItem = self.transform:Find("Main/Container/MaskCon/ScrollLayer/Container/1").gameObject
	self.baseItem:SetActive(false)
	-- self.ItemNameText = self.transform:Find("Main/Container/MaskCon/ScrollLayer/Container/1/ItemNameText"):GetComponent(Text)
	self.RoundText = self.transform:Find("Main/Container/RoundText"):GetComponent(Text)
	self.Toggle = self.transform:Find("Main/Container/Toggle"):GetComponent(Toggle)
	self.Toggle.isOn = self.model.isshow
	self.Toggle.onValueChanged:AddListener(function(val)
		self:OnToggle(val)
	end)
	-- self.Background = self.transform:Find("Main/Container/Toggle/Background")
	-- self.Checkmark = self.transform:Find("Main/Container/Toggle/Background/Checkmark")
	-- self.Label = self.transform:Find("Main/Container/Toggle/Label")
	self.Button = self.transform:Find("Main/Container/Button"):GetComponent(Button)
	self.Button.onClick:AddListener(function()
		self:OnReport()
	end)
	-- self.Text = self.transform:Find("Main/Container/Button/Text"):GetComponent(Text)
	self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseHisPanel()
	end)
	self:InitList()
	CombatManager.Instance.OnDanmakuPoolChange:AddListener(self.updatefunc)
	DanmakuManager.Instance.OnDanmakuSwitch:AddListener(self.switchChange)
  	EventMgr.Instance:AddListener(event_name.end_fight, self.endfrightfunct)
end

function DanmakuHistoryPanel:InitList()
	if CombatManager.Instance.controller ~= nil and CombatManager.Instance.controller.mainPanel ~= nil then
		self.RoundText.text = string.format(TI18N("第%s回合"), tostring(CombatManager.Instance.controller.mainPanel.round))
	end
	local data = CombatManager.Instance.danmakuHistory
	for i,v in ipairs(self.itemList) do
		v.gameObject:SetActive(false)
		table.insert(self.oldList, v)
	end
	self.itemList = {}
	local H = 0
	for i,danmaku in ipairs(data) do
		-- local key = string.format("%s_%s", danmaku.rid, danmaku.msg)
		local go = table.remove(self.oldList)
		-- local go = self.Container:Find(key) or table.remove(self.oldList)
		if go ~= nil then
			-- go = go.gameObject
			go:SetActive(true)
		else
			go = GameObject.Instantiate(self.baseItem)
			go.name = key
		end
		table.insert(self.itemList, go)
		local currH = self:SetItem(go, danmaku, H)
		H = H + currH
	end
	self.Container.sizeDelta = Vector2(309, H)
	self.nothing:SetActive(#data <= 0)
end

function DanmakuHistoryPanel:SetItem(item, data, lastH)
	item:SetActive(true)
	item.name = tostring(lastH)
	local itemtransform = item.transform
	local textcom = itemtransform:Find("ItemNameText"):GetComponent(Text)
	textcom.text = string.format("<color='#00ff00'>%s</color>:<color='#c7f9ff'>%s</color>", data.name, data.msg)
	local myh = textcom.preferredHeight
	itemtransform:SetParent(self.Container)
	itemtransform.localScale = Vector3.one
	itemtransform.sizeDelta = Vector2(309, myh+4)
	itemtransform.anchoredPosition = Vector3(0, -lastH, 0)
	itemtransform:Find("Select").gameObject:SetActive(self.clickdata ~= nil and self.clickdata.name == data.name and self.clickdata.msg == data.msg)
	local btn = itemtransform:GetComponent(Button) or item:AddComponent(Button)
	itemtransform:GetComponent(Button).onClick:RemoveAllListeners()
	itemtransform:GetComponent(Button).onClick:AddListener(function()
		self:OnClickItem(itemtransform, data)
	end)
	return myh
end

function DanmakuHistoryPanel:OnToggle(ison)
	if self.Toggle.isOn == DanmakuManager.Instance.model.isshow then
		return
	end
	if not ison then
        DanmakuManager.Instance.model:Hide()
        NoticeManager.Instance:FloatTipsByString(TI18N("成功屏蔽弹幕"))
    else
        DanmakuManager.Instance.model:Show()
        NoticeManager.Instance:FloatTipsByString(TI18N("成功开启弹幕"))
    end
end

function DanmakuHistoryPanel:OnClickItem(item, data)
	if self.clicktrans ~= nil then
		self.clicktrans:SetActive(false)
	end
	self.clicktrans = item:Find("Select").gameObject
	item:Find("Select").gameObject:SetActive(true)
	self.clickdata = data
end


function DanmakuHistoryPanel:OnReport()
	if self.clickdata == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先选择一条弹幕"))
		return
	end
	--WindowManager.Instance:OpenWindowById(WindowConfig.WinID.reportwindow, {self.clickdata})
	ReportManager.Instance.model:ReportChat({self.clickdata}, 1)
    self.model:CloseHisPanel()
end