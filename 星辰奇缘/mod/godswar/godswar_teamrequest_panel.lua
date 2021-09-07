-- ----------------------------
-- 诸神之战  战队申请列表
-- hosr
-- ----------------------------

GodsWarTeamRequestPanel = GodsWarTeamRequestPanel or BaseClass(BasePanel)

function GodsWarTeamRequestPanel:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.godswarrequestlist, type = AssetType.Main},
        {file = AssetConfig.godswarres, type = AssetType.Dep},
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function GodsWarTeamRequestPanel:__delete()
end

function GodsWarTeamRequestPanel:OnShow()
    self:Update()
end

function GodsWarTeamRequestPanel:OnHide()
end

function GodsWarTeamRequestPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarrequestlist))
    self.gameObject.name = "GodsWarTeamRequestPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -20)

    self.nothing = self.transform:Find("Nothing").gameObject
    self.scroll = self.transform:Find("Scroll").gameObject

    self.Container = self.transform:Find("Scroll/Container")
    self.ScrollCon = self.transform:Find("Scroll")
    self.rank_item_list = {}
    local len = self.Container.childCount
    for i = 1, len do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = GodsWarTeamRequestItem.New(go, self)
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

function GodsWarTeamRequestPanel:Update()
    if GodsWarManager.Instance.myData ~= nil then
        self.setting.data_list = GodsWarManager.Instance.myData.applys
    end
    BaseUtils.refresh_circular_list(self.setting)

    if #self.setting.data_list == 0 then
        self.nothing:SetActive(true)
        self.scroll:SetActive(false)
    else
        self.nothing:SetActive(false)
        self.scroll:SetActive(true)
    end
end