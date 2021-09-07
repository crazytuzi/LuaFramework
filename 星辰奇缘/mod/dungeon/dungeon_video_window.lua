-- @author 黄耀聪
-- @date 2016年7月11日

DungeonVideoWindow = DungeonVideoWindow or BaseClass(BaseWindow)

function DungeonVideoWindow:__init(model)
    self.model = model
    self.name = "DungeonVideoWindow"
    -- self.windowId = WindowConfig.WinID.dungeon_video_window
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.dungeon_video_window, type = AssetType.Main},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
    }

    self.cellObjList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function DungeonVideoWindow:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DungeonVideoWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dungeon_video_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.scroll = t:Find("Main/RankPanel/ScrollLayer"):GetComponent(ScrollRect)
    self.container = t:Find("Main/RankPanel/ScrollLayer/Container")
    self.cloner = self.container.parent:Find("Cloner").gameObject

    self.setting_data = {
       item_list = self.cellObjList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container.anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.cloner:SetActive(false)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})
    for i=1,15 do
        local obj = GameObject.Instantiate(self.cloner)
        obj.name = tostring(i)
        self.cellObjList[i] = DungeonVideoItem.New(self.model, obj, self.assetWrapper)
        self.layout:AddCell(obj)
        obj:SetActive(false)
    end
    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self.model:CloseVideoWindow() end)
end

function DungeonVideoWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DungeonVideoWindow:OnOpen()
    self:RemoveListeners()

    self.openArgs = self.openArgs or {}
    local list = self.openArgs.list or {}

    self.setting_data.data_list = list
    BaseUtils.refresh_circular_list(self.setting_data)
end

function DungeonVideoWindow:OnHide()
    self:RemoveListeners()
end

function DungeonVideoWindow:RemoveListeners()
end


