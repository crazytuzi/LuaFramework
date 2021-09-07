HeroRankPanel = HeroRankPanel or BaseClass(BasePanel)

function HeroRankPanel:__init(model, parent)
    self.parent = parent
    self.model = model
    self.mgr = HeroManager.Instance

    self.resList = {
        {file = AssetConfig.hero_rank_panel, type = AssetType.Main}
        , {file = AssetConfig.heads, type = AssetType.Dep}
        , {file = AssetConfig.hero_textures, type = AssetType.Dep}
    }

    self.cellObjList = {}

    self.updateListener = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function HeroRankPanel:__delete()
    self.OnHideEvent:Fire()
    if self.boxYLayout ~= nil then
        self.boxYLayout:DeleteMe()
        self.boxYLayout = nil
    end
    if self.cellObjList ~= nil then
        for k,v in pairs(self.cellObjList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.cellObjList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HeroRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.hero_rank_panel))
    self.gameObject.name = "HeroRankPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t
    self.rect = t:GetComponent(RectTransform)
    self.scorll = t:Find("Scroll"):GetComponent(ScrollRect)
    self.container = t:Find("Scroll/Container")
    self.cloner = self.container:Find("Cloner").gameObject

    self.cloner:SetActive(false)
    self.boxYLayout = LuaBoxLayout.New(self.container, {cspacing = 0, axis = BoxLayoutAxis.Y})

    for i=1,15 do
        local obj = nil
        obj = GameObject.Instantiate(self.cloner)
        obj.name = tostring(i)
        self.boxYLayout:AddCell(obj)
        self.cellObjList[i] = HeroRankItem.New(self.model, obj, self.assetWrapper)
    end

    self.setting_data = {
       item_list = self.cellObjList --放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scorll:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.scorll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)
end

function HeroRankPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function HeroRankPanel:OnOpen()
    self.rect.anchorMax = self.openArgs[1].anchorMax
    self.rect.anchorMin = self.openArgs[1].anchorMin
    self.rect.anchoredPosition = self.openArgs[1].anchoredPosition
    self.rect.sizeDelta = self.openArgs[1].sizeDelta
    self:Update()

    self:RemoveListeners()
    self.mgr.onUpdateRank:AddListener(self.updateListener)
end

function HeroRankPanel:OnHide()
    self:RemoveListeners()
    self.model.currentSelectObj = nil
    self.model.lastIndex = nil
end

function HeroRankPanel:Update()
    local datalist = self.model.settleData.rank_list
    if datalist == nil then
        datalist = {}
    end

    self.model.rankHasMe = false
    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)
    self.scorll.onValueChanged:Invoke({0, 1})
    self.mgr.onUpdateInfo:Fire()
end

function HeroRankPanel:RemoveListeners()
    self.mgr.onUpdateRank:RemoveListener(self.updateListener)
end
