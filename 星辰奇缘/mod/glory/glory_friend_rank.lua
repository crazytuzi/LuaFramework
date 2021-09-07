-- 2017/7/26
-- 黄耀聪
-- 爵位好友排行榜

GloryFriendRank = GloryFriendRank or BaseClass(BasePanel)

function GloryFriendRank:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GloryFriendRank"
    self.windowId = WindowConfig.WinID.glory_reward

    self.resList = {
        {file = AssetConfig.glory_friend_rank, type = AssetType.Main}
        , {file = AssetConfig.glory_textures, type = AssetType.Dep}
        , {file = AssetConfig.rank_textures, type = AssetType.Dep}
    }

    self.itemList = {}
    self.closeCallback = nil
    self.updateListener = function(type) if type == "ReloadRankpanel" then self:Update() end end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GloryFriendRank:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            v:DeleteMe()
        end
    end
    self:AssetClearAll()
    self.model = nil
end

function GloryFriendRank:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glory_friend_rank))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    local main = t:Find("Main")
    local scroll = main:Find("Scroll"):GetComponent(ScrollRect)
    self.container = scroll.transform:Find("Container")
    self.nothing = main:Find("Nothing").gameObject

    if main:Find("Close") ~= nil then
        self.closeBtn = main:Find("Close"):GetComponent(Button)
    end

    for i=0,9 do
        self.itemList[i + 1] = GloryFriendRankItem.New(self.model, self.container:GetChild(i).gameObject, self.assetWrapper)
    end

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.itemList[1].transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container.anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = scroll.transform.sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    scroll.content  = self.container
    scroll.horizontal = false
    scroll.gameObject:SetActive(true)
    scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() if self.closeCallback ~= nil then self.closeCallback() end end)

    if self.closeBtn ~= nil then
        self.closeBtn.onClick:AddListener(function() if self.closeCallback ~= nil then self.closeCallback() end end)
    end
end

function GloryFriendRank:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GloryFriendRank:OnOpen()
    self:RemoveListeners()
    RankManager.Instance.OnUpdateList:AddListener(self.updateListener)

    RankManager.Instance:send12500({type = 56, sub_type = 2, page = 1, num = 100})
    self:Update()
end

function GloryFriendRank:Update()
    self.setting_data.data_list = RankManager.Instance.model:GetDataList(56,2)
    BaseUtils.refresh_circular_list(self.setting_data)

    self.nothing:SetActive(#self.setting_data.data_list == 0)
end

function GloryFriendRank:OnHide()
    self:RemoveListeners()
end

function GloryFriendRank:RemoveListeners()
    RankManager.Instance.OnUpdateList:RemoveListener(self.updateListener)
end
