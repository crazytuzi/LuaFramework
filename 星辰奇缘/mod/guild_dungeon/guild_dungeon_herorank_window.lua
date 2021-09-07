-- 公会副本 
-- ljh 20170301
GuildDungeonHeroRankWindow = GuildDungeonHeroRankWindow or BaseClass(BaseWindow)

function GuildDungeonHeroRankWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.guilddungeonherorank
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.guilddungeonherorank, type = AssetType.Main}
        ,{file = AssetConfig.guilddungeon_textures, type = AssetType.Dep}
        ,{file = AssetConfig.rank_textures, type = AssetType.Dep}
    }

    -----------------------------------------------------------
    self.cellObjList = {}

    -----------------------------------------------------------
    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self._Update = function() self:Update() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function GuildDungeonHeroRankWindow:__delete()
    self.OnHideEvent:Fire()
    
    if self.cellObjList ~= nil then
        for _,v in pairs(self.cellObjList) do
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

function GuildDungeonHeroRankWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddungeonherorank))
    self.gameObject.name = "GuildDungeonHeroRankWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    
    self.mainTransform = self.transform:FindChild("Main")

    self.mainTransform:FindChild("Close"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.infoContainer = self.mainTransform:Find("RankPanel/Panel/Container").gameObject
    self.infoContainerRect = self.infoContainer:GetComponent(RectTransform)
    self.cloner = self.infoContainer.transform:Find("Cloner").gameObject
    self.vScroll = self.mainTransform:Find("RankPanel/Panel").gameObject:GetComponent(ScrollRect)
    self.nothing = self.mainTransform:Find("RankPanel/Panel/Nothing").gameObject

    self.setting_data = {
       item_list = self.cellObjList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.infoContainer  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.infoContainer:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.vScroll:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.Layout = LuaBoxLayout.New(self.infoContainer, {axis = BoxLayoutAxis.Y, cspacing = 0})

    local obj = nil
    for i=1,15 do
        obj = GameObject.Instantiate(self.cloner)
        obj.name = tostring(i)
        self.Layout:AddCell(obj)
        self.cellObjList[i] = GuildDungeonRankItem.New(self.model, obj, self.assetWrapper)
    end
end

function GuildDungeonHeroRankWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function GuildDungeonHeroRankWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDungeonHeroRankWindow:OnOpen()
    self:Update()

    GuildDungeonManager.Instance.OnUpdateRank:Add(self._Update)

    GuildDungeonManager.Instance:Send19502(0, 0)
end

function GuildDungeonHeroRankWindow:OnHide()
    GuildDungeonManager.Instance.OnUpdateRank:Remove(self._Update)
end

function GuildDungeonHeroRankWindow:Update()
    local datalist = self.model.heroRankData
    if #datalist == 0 then
        self.nothing:SetActive(true)
    else
        self.nothing:SetActive(false)
    end

    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)
end
