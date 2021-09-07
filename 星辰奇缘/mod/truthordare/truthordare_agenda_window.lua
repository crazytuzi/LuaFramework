-- ----------------------------------------------------------
-- UI - 真心话大冒险
-- ----------------------------------------------------------
TruthordareAgendaWindow = TruthordareAgendaWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function TruthordareAgendaWindow:__init(model)
    self.model = model
    self.name = "TruthordareAgendaWindow"
    self.windowId = WindowConfig.WinID.truthordareagendawindow

    self.resList = {
        {file = AssetConfig.truthordareagendawindow, type = AssetType.Main}
        ,{file = AssetConfig.truthordare_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------

    self.currentIndex = 0
    self.filterType = 0

    self.container_item_list = {}

	------------------------------------------------
	self.tabGroup = nil
    self.tabGroupObj = nil
    
    self.btnType ={
        [1] = TI18N("显示全部"),
        [2] = TI18N("显示当天"),
        [3] = TI18N("显示本周"),
        [4] = TI18N("显示上周")
    }

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    -- self._SelectUpdate = function(index) 
    --     self:ChangeType(index)
    -- end

    self._Update = function() 
        self:UpdateList()
    end
end

function TruthordareAgendaWindow:__delete()
    self:OnHide()

    self:AssetClearAll()
end

function TruthordareAgendaWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordareagendawindow))
    self.gameObject.name = "TruthordareAgendaWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

	self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup")    --侧边栏

    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0, 0},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, tabGroupSetting)

    self.panel = self.mainTransform:FindChild("Panel").gameObject
    self.panel2 = self.mainTransform:FindChild("Panel2").gameObject
    
    self.UpArea = self.panel2.transform:Find("UpArea")
    self.UpArea.gameObject:SetActive(false)

    self.updescText = self.panel2.transform:Find("UpArea/DescText"):GetComponent(Text)
    self.chooseBtn = self.panel2.transform:Find("UpArea/btn_season"):GetComponent(Button)
    self.chooseBtn.onClick:AddListener(function() self.model:OpenSelect() end)
    self.chooseType = self.chooseBtn.transform:Find("Text"):GetComponent(Text)

    self.container = self.panel2.transform:FindChild("Mask/Container")
    self.containerItem = self.container.transform:FindChild("Item").gameObject
    self.container_vScroll =  self.panel2.transform:FindChild("Mask"):GetComponent(ScrollRect)
    self.container_vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.container_setting_data)
        -- self:OnValueChanged(1)
    end)

    for i=1, 6 do
        local go = GameObject.Instantiate(self.containerItem)
        go.transform:SetParent(self.container)
        go.transform.localScale = Vector3.one

        local item = TruthordareLuckydorItem.New(go, self)
        table.insert(self.container_item_list, item)
    end
    self.containerItem:SetActive(false)

    self.container_single_item_height = self.containerItem.transform:GetComponent(RectTransform).sizeDelta.y
    self.container_scroll_con_height = self.panel2.transform:FindChild("Mask"):GetComponent(RectTransform).sizeDelta.y
    self.container_item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y

    self.container_setting_data = {
       item_list = self.container_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.container_single_item_height + 10 --一条item的高度
       ,item_con_last_y = self.container_item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.container_scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }


    self.OnHideEvent:AddListener(function() self.previewComposite:Hide() end)
    self.OnOpenEvent:AddListener(function() self.previewComposite:Show() end)
    ----------------------------

    self.tabGroup:ChangeTab(2)
    self:OnShow()
    self:ClearMainAsset()
end

function TruthordareAgendaWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function TruthordareAgendaWindow:OnShow()
    --TruthordareManager.Instance.OnluckydorSelectUpdate:AddListener(self._SelectUpdate)
    TruthordareManager.Instance.OnluckydorUpdate:AddListener(self._Update)
end

function TruthordareAgendaWindow:OnHide()
    --TruthordareManager.Instance.OnluckydorSelectUpdate:RemoveListener(self._SelectUpdate)
    TruthordareManager.Instance.OnluckydorUpdate:RemoveListener(self._Update)
end

function TruthordareAgendaWindow:ChangeTab(index)
    self.currentIndex = index
    if index == 1 then
        self.panel:SetActive(true)
        self.panel2:SetActive(false)
    else
        self.panel:SetActive(false)
        self.panel2:SetActive(true)
        TruthordareManager.Instance:Send19527()
    end
end

function TruthordareAgendaWindow:UpdateList()
    local datalist = TruthordareManager.Instance.model.hisLuckyInfo or {
		[1] = {
			quest = "这是问题部分的内容",
			type = 0,
			flower = 199,
			egg = 185,
			sex = 0,
			role_name = "工藤新一",
			classes = 1,
	    },
		[2] = {
			quest = "这是问题部分的内容",
			type = 1,
			flower = 199,
			egg = 18,
			sex = 1,
			role_name = "工藤新二",
			classes = 2,
		},
		[3] = {
			quest = "这是问题部分的内容",
			type = 1,
			flower = 199,
			egg = 185,
			sex = 0,
			role_name = "工藤新三",
			classes = 3,
		},
		[4] = {
			quest = "这是问题部分的内容",
			type = 0,
			flower = 199,
			egg = 185,
			sex = 0,
			role_name = "工藤新一",
			classes = 4,
		},
		[5] = {
			quest = "这是问题部分的内容",
			type = 0,
			flower = 199,
			egg = 185,
			sex = 1,
			role_name = "工藤新一",
			classes = 5,
		},
	}
    self.container_setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.container_setting_data)
end

-- --上方切换回调
-- function TruthordareAgendaWindow:ChangeType(index)
--     --print("选择"..index)
--     self.chooseType.text = self.btnType[index]
--     --请求幸运儿协议 index区分
-- end