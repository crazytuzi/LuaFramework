-- --------------------------------
-- 诸神之战邀请列表界面
-- hosr
-- --------------------------------

GodsWarApplyPanel = GodsWarApplyPanel or BaseClass(BasePanel)

function GodsWarApplyPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.godswarapply, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.listener = function() self:UpdateProto() end
    EventMgr.Instance:AddListener(event_name.godswar_apply_update, self.listener)

    self.listTab = {}
    self.currIndex = 0
end

function GodsWarApplyPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.godswar_apply_update, self.listener)
end

function GodsWarApplyPanel:OnShow()
    self.tabGroup:ChangeTab(1)
end

function GodsWarApplyPanel:OnHide()
end

function GodsWarApplyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarapply))
    self.gameObject.name = "GodsWarApplyPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseApply() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseApply() end)

    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
    }
    self.tabGroup = TabGroup.New(self.transform:Find("Main/TabButtonGroup"), function(index) self:ChangeTab(index) end, tabGroupSetting)

    self.Container = self.transform:Find("Main/Scroll/Container")
    self.ScrollCon = self.transform:Find("Main/Scroll")
    self.rank_item_list = {}
    local len = self.Container.childCount
    for i = 1, len do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = GodsWarApplyItem.New(go, self)
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

function GodsWarApplyPanel:ChangeTab(index)
	self.currIndex = index
	if self.listTab[index] == nil or #self.listTab[index] == 0 then
    self:Update()
		GodsWarManager.Instance:Send17910(index)
	else
		self:Update()
	end
end

function GodsWarApplyPanel:UpdateProto()
	self.data = GodsWarManager.Instance.applyData
	if self.data ~= nil then
		self.listTab[self.data.type] = self.data.invite_list or {}
	end

	self:Update()
end

function GodsWarApplyPanel:Update()
	self.setting.data_list = self.listTab[self.currIndex] or {}
  table.sort(self.setting.data_list, function(a,b)
      if a.online == b.online then
          return a.total_fc > b.total_fc
      else
          return a.online > b.online
      end
  end)
	BaseUtils.refresh_circular_list(self.setting)
end

