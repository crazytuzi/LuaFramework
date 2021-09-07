-- @author 黄耀聪
-- @date 2017年6月22日, 星期四

GloryVideo = GloryVideo or BaseClass(BaseWindow)

function GloryVideo:__init(model)
    self.model = model
    self.name = "GloryVideo"
    self.windowId = WindowConfig.WinID.glory_video

    self.resList = {
        {file = AssetConfig.glory_video, type = AssetType.Main}
    }

    self.updateListener = function(floor) self:Reload() end

    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GloryVideo:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            v:DeleteMe()
        end
    end
    self:AssetClearAll()
end

function GloryVideo:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glory_video))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.scroll = t:Find("Main/Rank/Scroll"):GetComponent(ScrollRect)
    self.cloner = t:Find("Main/Rank/Scroll/Item").gameObject
    self.container = t:Find("Main/Rank/Scroll/Container")

    self.nothing = t:Find("Main/Rank/Nothing")

    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    for i=1,10 do
        self.itemList[i] = GloryVideoItem.New(self.model, GameObject.Instantiate(self.cloner))
        layout:AddCell(self.itemList[i].gameObject)
    end
    layout:DeleteMe()

    self.setting_data = {
       item_list = self.itemList --放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner.transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container.anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll:GetComponent(RectTransform).rect.height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.cloner:SetActive(false)
    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)

    t:Find("Main/Rank/Title"):GetChild(1):GetComponent(Text).text = TI18N("所用回合")
end

function GloryVideo:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GloryVideo:OnOpen()
    self:RemoveListeners()
    GloryManager.Instance.onUpdateVideo:AddListener(self.updateListener)

    self.floor = self.openArgs[1] or 1
    GloryManager.Instance:send14428(self.floor)
    self:Reload()
end

function GloryVideo:OnHide()
    self:RemoveListeners()
end

function GloryVideo:RemoveListeners()
    GloryManager.Instance.onUpdateVideo:RemoveListener(self.updateListener)
end

function GloryVideo:Reload()
    self.setting_data.data_list = (self.model.videoData[self.floor] or {}).list or {}
    BaseUtils.refresh_circular_list(self.setting_data)
    self.nothing.gameObject:SetActive(#self.setting_data.data_list == 0)
end


