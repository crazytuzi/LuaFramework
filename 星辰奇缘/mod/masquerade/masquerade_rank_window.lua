-- @author 黄耀聪
-- @date 2016年6月30日

MasqueradeRankWindow = MasqueradeRankWindow or BaseClass(BaseWindow)

function MasqueradeRankWindow:__init(model)
    self.model = model
    self.name = "MasqueradeRankWindow"
    self.windowId = WindowConfig.WinID.masquerade_rank_window
    self.mgr = MasqueradeManager.Instance

    self.resList = {
        {file = AssetConfig.masquerade_rank_window, type = AssetType.Main},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
    }

    self.cellObjList = {}
    self.updateListener = function() self:ReloadRank() end
    self.updateMyListener = function() self:UpdateMy() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MasqueradeRankWindow:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.model.selectObj = nil
    self:AssetClearAll()
end

function MasqueradeRankWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.masquerade_rank_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.container = t:Find("Main/RankPanel/ScrollLayer/Container")
    self.vScroll = t:Find("Main/RankPanel/ScrollLayer"):GetComponent(ScrollRect)
    self.cloner = t:Find("Main/RankPanel/ScrollLayer/Cloner").gameObject
    self.myScoreObj = t:Find("Main/RankPanel/MyScore").gameObject

    self.Layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})

    self.setting_data = {
       item_list = self.cellObjList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.vScroll:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    local obj = nil
    for i=1,15 do
        obj = GameObject.Instantiate(self.cloner)
        obj.name = tostring(i)
        self.Layout:AddCell(obj)
        self.cellObjList[i] = MasqueradeRankItem.New(self.model, obj, self.assetWrapper)
    end
    self.cloner:SetActive(false)
    self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)
end

function MasqueradeRankWindow:OnClose()
    self.model:CloseWindow()
end

function MasqueradeRankWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MasqueradeRankWindow:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateRank:AddListener(self.updateListener)
    self.mgr:send16505()

    self.lastPosition = 0
    self:ReloadRank()
    self:UpdateMy()
end

function MasqueradeRankWindow:OnHide()
    self:RemoveListeners()
    self.lastPosition = self.Layout.panelRect.anchoredPosition.y
end

function MasqueradeRankWindow:RemoveListeners()
    self.mgr.onUpdateRank:RemoveListener(self.updateListener)
    self.mgr.onUpdateMy:RemoveListener(self.updateMyListener)
end

function MasqueradeRankWindow:ReloadRank()
    local model = self.model
    local roledata = RoleManager.Instance.RoleData

    local datalist = {}
    for k,v in pairs(self.model.playerList) do
        table.insert(datalist, v)
        if #datalist == model.rankSize then
            break
        end
    end
    if #datalist > 0 then
        table.sort(datalist, function(a,b) return self.mgr:Cmp(a,b) end)
    else
        local dat = {platform = RoleManager.Instance.RoleData.platform, rid = RoleManager.Instance.RoleData.id, r_zone_id = RoleManager.Instance.RoleData.zone_id,classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, lev = RoleManager.Instance.RoleData.lev, name = RoleManager.Instance.RoleData.name, score = 0, rank = 1, map_base_id = 71000}
        table.insert(datalist, dat)
    end
    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)

    self.vScroll.onValueChanged:Invoke({0, 1})
    self.Layout.panelRect.anchoredPosition = Vector2(0, self.lastPosition)
    self.vScroll.onValueChanged:Invoke({0,1 - self.lastPosition / self.Layout.panelRect.sizeDelta.y})

    model.myInfo.rank = 0
    for i,v in ipairs(datalist) do
        if BaseUtils.Key(v.rid, v.platform, v.r_zone_id) == BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id) then
            model.myInfo.rank = i
            model.playerList[BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id)].rank = i
            break
        end
    end
    self:UpdateMy()
end

function MasqueradeRankWindow:UpdateMy()
    self.cellObjList[0] = self.cellObjList[0] or MasqueradeRankItem.New(self.model, self.myScoreObj, self.assetWrapper)

    local roledata = RoleManager.Instance.RoleData
    local data = self.model.myInfo
    if data.map_base_id == nil then
        data = self.model.playerList[BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id)]
    end
    self.cellObjList[0]:update_my_self(data, data.rank)
end


