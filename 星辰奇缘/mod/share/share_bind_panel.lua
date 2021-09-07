-- ------------------------------
-- 分享绑定操作以及领奖界面
-- hosr
-- ------------------------------
ShareBindPanel = ShareBindPanel or BaseClass(BaseWindow)

function ShareBindPanel:__init(model)
	self.model = model
    self.name = "ShareBindPanel"
	self.windowId = WindowConfig.WinID.share_bind

	self.resList = {
		{file = AssetConfig.sharebindpanel, type = AssetType.Main},
		{file = AssetConfig.shareres, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.listener = function() self:Update() end
end

function ShareBindPanel:__delete()
	EventMgr.Instance:RemoveListener(event_name.share_reward_update, self.listener)
	EventMgr.Instance:RemoveListener(event_name.share_info_update, self.listener)
	if self.rank_item_list ~= nil then
		for i,v in ipairs(self.rank_item_list) do
			v:DeleteMe()
		end
		self.rank_item_list = nil
	end
end

function ShareBindPanel:OnShow()
	EventMgr.Instance:AddListener(event_name.share_reward_update, self.listener)
	EventMgr.Instance:AddListener(event_name.share_info_update, self.listener)
	self:Update()
	if RoleManager.Instance.RoleData.lev <= 20 then
		ShareManager.Instance:Send17502()
	end
end

function ShareBindPanel:OnHide()
	EventMgr.Instance:RemoveListener(event_name.share_reward_update, self.listener)
	EventMgr.Instance:RemoveListener(event_name.share_info_update, self.listener)
end

function ShareBindPanel:Close()
	WindowManager.Instance:CloseWindowById(WindowConfig.WinID.share_bind)
end

function ShareBindPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sharebindpanel))
    self.gameObject.name = "ShareBindPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.Container = self.transform:Find("Main/Scroll/Container")
    self.ScrollCon = self.transform:Find("Main/Scroll")
    self.rank_item_list = {}
    local len = self.Container.childCount
    for i = 1, len do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = ShareBindItem.New(go, self)
        go:SetActive(false)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.rank_item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting = {
       item_list = self.rank_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Container  --item列表的父容器
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

    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting) end)

    self:OnShow()
end

function ShareBindPanel:Update()
	local list = BaseUtils.copytab(DataExtension.data_reward)
	self.setting.data_list = list
	BaseUtils.refresh_circular_list(self.setting)
end