-- @author 黄耀聪
-- @date 2016年10月10日
-- 后台排行榜

BackendRankWindow = BackendRankWindow or BaseClass(BaseWindow)

function BackendRankWindow:__init(model)
    self.model = model
    self.name = "BackendRankWindow"
    self.mgr = BackendManager.Instance
    self.windowId = WindowConfig.WinID.backend_rank

    self.resList = {
        {file = AssetConfig.backend_rank_window, type = AssetType.Main},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
    }

    self.itemList = {}
    self.rankListener = function(type) if self.type == type then self:ReloadRank() end end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendRankWindow:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackendRankWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_rank_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    self.nothing = main:Find("Nothing").gameObject
    self.titleRect = main:Find("Title")
    self.titleText = self.titleRect:GetComponent(Text)
    self.scroll = main:Find("Scroll"):GetComponent(ScrollRect)
    self.container = self.scroll.transform:Find("Container")
    self.cloner = self.scroll.transform:Find("Cloner").gameObject

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})
    for i=1,10 do
        local obj = GameObject.Instantiate(self.cloner)
        self.itemList[i] = BackendRankItem.New(self.model, obj, self.assetWrapper)
        self.layout:AddCell(obj)
    end
    self.cloner:SetActive(false)

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner.transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container.anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll.transform.sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)
end

function BackendRankWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendRankWindow:OnOpen()
    self:RemoveListeners()
    self.mgr.onRank:AddListener(self.rankListener)

    self.menuData = self.openArgs.menuData
    self.type = self.menuData.sec_type

    self.mgr:send14054(self.type)
    self:ReloadRank()
    self:ReloadInfo()
end

function BackendRankWindow:OnHide()
    self:RemoveListeners()
    self.model.rankSelect = nil
    self.model.lastRankSelect = nil
end

function BackendRankWindow:RemoveListeners()
    self.mgr.onRank:RemoveListener(self.rankListener)
end

function BackendRankWindow:ReloadInfo()
    local height = self.titleRect.sizeDelta.y
    self.titleText.text = self.menuData.title
    local width = math.ceil(self.titleText.preferredWidth) + 20
    if width < 50 then
        width = 50
    end
    self.titleRect.sizeDelta = Vector2(width, height)
end

function BackendRankWindow:ReloadRank()
    local model = self.model
    local rankList = model.rankDataTab[self.type] or {}
    self.setting_data.data_list = rankList
    BaseUtils.refresh_circular_list(self.setting_data)

    self.nothing:SetActive(#rankList == 0)
end

BackendRankItem = BackendRankItem or BaseClass()

function BackendRankItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper

    local t = gameObject.transform
    self.transform = t

    self.select = t:Find("Select").gameObject
    self.rankText = t:Find("RankValue"):GetComponent(Text)
    self.rankImage = t:Find("RankValue/RankImage"):GetComponent(Image)
    self.headImage = t:Find("Character/Icon/Image"):GetComponent(Image)
    self.nameText = t:Find("Character/Name"):GetComponent(Text)
    self.otherText = t:Find("Job"):GetComponent(Text)
    self.btn = gameObject:GetComponent(Button)

    self.btn.onClick:AddListener(function() self:OnClick() end)
end

function BackendRankItem:update_my_self(data, index)
    self.data = data
    local model = self.model
    if index < 4 then
        self.rankText.text = ""
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_" .. index)
        self.rankImage.gameObject:SetActive(true)
    else
        self.rankText.text = tostring(index)
        self.rankImage.gameObject:SetActive(false)
    end
    self.nameText.text = data.name
    self.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes .. "_" .. data.sex)
    self.otherText.text = tostring(data.val1)

    self.select:SetActive(model.rankSelect == data.rank)
end

function BackendRankItem:__delete()
    self.rankImage.sprite = nil
end

function BackendRankItem:OnClick()
    if self.data ~= nil then
        local data = self.data
        if self.model.lastRankSelect ~= nil then
            self.model.lastRankSelect:SetActive(false)
        end
        self.model.rankSelect = data.rank
        self.select:SetActive(true)
        self.model.lastRankSelect = self.select
        local showData = {id = data.role_id, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.name, lev = data.lev}
        TipsManager.Instance:ShowPlayer(showData)
    end
end

