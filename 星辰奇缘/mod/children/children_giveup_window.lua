--作者:hzf
--01/19/2017 15:44:13
--功能:子女抛弃

ChildrenGiveUpWindow = ChildrenGiveUpWindow or BaseClass(BaseWindow)
function ChildrenGiveUpWindow:__init(model)
	self.model = model
	self.Mgr = ChildrenManager.Instance
	self.resList = {
		{file = AssetConfig.childdepositwindow, type = AssetType.Main},
		{file = AssetConfig.childhead, type = AssetType.Dep},
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.currData = nil
	self.selectObj = nil
    self.listener = function()
        self:RefreshList()
    end
end

function ChildrenGiveUpWindow:__delete()
    ChildrenManager.Instance.OnChildDataUpdate:Remove(self.listener)
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChildrenGiveUpWindow:OnHide()

end

function ChildrenGiveUpWindow:OnOpen()

end

function ChildrenGiveUpWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childdepositwindow))
	self.gameObject.name = "ChildrenGiveUpWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	local canvas = self.gameObject:AddComponent(Canvas)
	canvas.overrideSorting = true
	canvas.sortingOrder = 20
	canvas.overrideSorting = false
	self.gameObject:AddComponent(GraphicRaycaster)

	self.transform = self.gameObject.transform
	self.Panel = self.transform:Find("Panel")
	self.Panel.gameObject:AddComponent(Button).onClick:AddListener(function()
		ChildrenManager.Instance.model:CloseGiveUpWindow()
	end)
	self.Main = self.transform:Find("Main")
	self.Title = self.transform:Find("Main/Title")
	self.Text = self.transform:Find("Main/Title/Text"):GetComponent(Text)
	self.transform:Find("Main/I18N_Text"):GetComponent(Text).text = TI18N("1.请选择要<color='#ffff00'>托管</color>的子女，托管后可重新孕育1名子女\n2.托管后子女将被送往精灵乐园，<color='#ff0000'>无法找回</color>")
	self.Scroll = self.transform:Find("Main/Scroll")
	self.Container = self.transform:Find("Main/Scroll/Container")
	self.transform:Find("Main/Image"):SetSiblingIndex(2)
	self.itemList = {}

	for i=1, 6 do
		local trans = self.Container:GetChild(i-1).gameObject
		local item = ChildrenGiveUpItem.New(trans, self)
		self.itemList[i] = item
	end

	self.transform:Find("Main/Sure"):GetComponent(Button).onClick:AddListener(function()
		self:OnSure()
	end)
	self.Text = self.transform:Find("Main/Sure/Text"):GetComponent(Text)

	self.SurePanel = self.transform:Find("SurePanel")
	local cc = self.SurePanel:GetComponent(Canvas)
	local gr = self.SurePanel:GetComponent(GraphicRaycaster)
	GameObject.Destroy(gr)
	GameObject.Destroy(cc)
	self.transform:Find("SurePanel/Panel"):GetComponent(Button).onClick:AddListener(function()
		self.SurePanel.gameObject:SetActive(false)
	end)
	self.Main = self.transform:Find("SurePanel/Main")
	self.Title = self.transform:Find("SurePanel/Main/Title")
	-- self.Text = self.transform:Find("SurePanel/Main/Title/Text"):GetComponent(Text)
	self.I18N_Text = self.transform:Find("SurePanel/Main/I18N_Text"):GetComponent(Text)
	self.InputField = self.transform:Find("SurePanel/Main/InputField"):GetComponent(InputField)
	-- self.Placeholder = self.transform:Find("SurePanel/Main/InputField/Placeholder")
	self.transform:Find("SurePanel/Main/Cancel"):GetComponent(Button).onClick:AddListener(function()
		self.SurePanel.gameObject:SetActive(false)
	end)
	self.transform:Find("SurePanel/Main/Confirm"):GetComponent(Button).onClick:AddListener(function()
		self:OnSecondSure()
	end)

	self:InitList()
    ChildrenManager.Instance.OnChildDataUpdate:Add(self.listener)
end


function ChildrenGiveUpWindow:OnSure()
	if self.currData ~= nil then
		self.SurePanel.gameObject:SetActive(true)
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("请选择一名子女"))
	end
end

function ChildrenGiveUpWindow:OnSecondSure()
	if self.currData ~= nil and self.InputField.text == "yes" then
		ChildrenManager.Instance:Require18630(self.currData.child_id, self.currData.platform, self.currData.zone_id)
		self.InputField.text = ""
		self.SurePanel.gameObject:SetActive(false)
	elseif self.currData ~= nil and self.InputField.text ~= "yes" then
		NoticeManager.Instance:FloatTipsByString(TI18N("托管需要输入“yes”进行确认"))
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("请选择一名子女"))
		self.SurePanel.gameObject:SetActive(false)
	end
end

function ChildrenGiveUpWindow:InitList()
    self.item_list = {}
    self.item_con = self.Container
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.single_item_height = 74
    self.scroll_con_height = 280

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.item_con  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.vScroll = self.Scroll:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.setting_data.data_list = self.Mgr.childData
    BaseUtils.refresh_circular_list(self.setting_data)
end

function ChildrenGiveUpWindow:OnClickItem(item, data)
	if self.currData == nil or self.currData.child_id ~= data.child_id then
		if self.selectObj ~= nil then
			self.selectObj:SetActive(false)
		end
		self.selectObj = item.Select
		self.selectObj:SetActive(true)
		self.currData = data
        self:SetConfirmText(data)
	end
end

function ChildrenGiveUpWindow:SetConfirmText(data)
    local str = TI18N("子女<color='#ffff00'>[%s]</color>托管后，将<color='#ff0000'>无法找回</color>\n请输入<color='#ffff00'>YES</color>进行确认")
    if data.name == "" then
        if data.sex == 1 then
            self.I18N_Text.text = string.format(str, TI18N("男宝宝"))
        else
            self.I18N_Text.text = string.format(str, TI18N("女宝宝"))
        end
        if data.stage == 2 then
            self.I18N_Text.text = string.format(str, TI18N("胎儿"))
        end
    else
        self.I18N_Text.text = string.format(str, data.name)
    end
end

function ChildrenGiveUpWindow:RefreshList()
    self.setting_data.data_list = self.Mgr.childData
    BaseUtils.refresh_circular_list(self.setting_data)
end