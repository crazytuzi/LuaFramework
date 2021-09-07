-- @author 黄耀聪
-- @date 2016年11月1日

SwornFriendChooseWindow = SwornFriendChooseWindow or BaseClass(BaseWindow)

function SwornFriendChooseWindow:__init(model)
    self.model = model
    self.name = "SwornFriendChooseWindow"
    self.mgr = SwornManager.Instance
    self.windowId = WindowConfig.WinID.sworn_friend_choose

    self.resList = {
        {file = AssetConfig.sworn_friend_choose, type = AssetType.Main},
        {file = AssetConfig.sworn_textures, tyoe = AssetType.Dep},
    }

    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornFriendChooseWindow:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self.model.selectFriendTab = nil
    self.model.selectUid = nil
    self.model.lastSelect = nil

    self:AssetClearAll()
end

function SwornFriendChooseWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_friend_choose))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    local main = t:Find("Main")
    self.container = main:Find("Scroll/Container")
    self.cloner = main:Find("Scroll/Cloner").gameObject
    self.sureBtn = main:Find("Sure"):GetComponent(Button)
    self.numText = main:Find("Num"):GetComponent(Text)
    self.scroll = main:Find("Scroll"):GetComponent(ScrollRect)

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner.transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container.anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll.transform.sizeDelta.y--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.nothing = self.scroll.transform:Find("Nothing").gameObject

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 10, border = 10})
    for i=1,8 do
        local obj = GameObject.Instantiate(self.cloner)
        self.itemList[i] = SwornFriendItem.New(self.model, obj)
        self.layout:AddCell(obj)
    end
    self.cloner:SetActive(false)
    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)

    self.sureBtn.onClick:AddListener(function() self:OnClick() end)
end

function SwornFriendChooseWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornFriendChooseWindow:OnOpen()
    self:RemoveListeners()

    self:Reload()
end

function SwornFriendChooseWindow:OnHide()
    self:RemoveListeners()
end

function SwornFriendChooseWindow:RemoveListeners()
end

function SwornFriendChooseWindow:Reload()
    local datalist = {}
    for _,v in pairs(FriendManager.Instance.friend_List) do
        if v.online == 1 then
            table.insert(datalist, v)
        end
    end
    table.sort(datalist, function(a,b) return a.intimacy > b.intimacy end)

    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)

    self.nothing:SetActive(#datalist == 0)
    local num = #self.model.swornData.members
    if num < 10 then
        self.numText.text = string.format("<color='#248813'>%s</color>/10", tostring(num))
    else
        self.numText.text = string.format("<color='#ff0000'>%s</color>/10", tostring(num))
    end
end

function SwornFriendChooseWindow:OnClick()
    if self.model.selectFriendTab ~= nil then
        self.mgr:send17709(self.model.selectFriendTab.id, self.model.selectFriendTab.platform, self.model.selectFriendTab.zone_id, self.model.selectFriendTab.name)
    end
end


SwornFriendItem = SwornFriendItem or BaseClass()

function SwornFriendItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    local t = gameObject.transform
    self.transform = t

    self.headImage = t:Find("Head/Image"):GetComponent(Image)
    self.select = t:Find("Select").gameObject
    self.classIconImage = t:Find("Icon"):GetComponent(Image)
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.honorText = t:Find("Honor"):GetComponent(Text)
    self.statusText = t:Find("Status"):GetComponent(Text)

    gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
end

function SwornFriendItem:update_my_self(data)
    self.uid = BaseUtils.Key(data.zone_id, data.platform, data.id)
    self.uidTab = {id = data.id, platform = data.platform, zone_id = data.zone_id, name = data.name}
    self.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes .. "_" .. data.sex)
    self.nameText.text = data.name
    self.classIconImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" .. data.classes)
    if data.intimacy < 300 then
        self.honorText.text = string.format(TI18N("亲密度:<color='%s'>%s</color>"), "#ff0000", tostring(data.intimacy))
    else
        self.honorText.text = string.format(TI18N("亲密度:<color='%s'>%s</color>"), "#248813", tostring(data.intimacy))
    end

    self.select:SetActive(self.model.selectUid == self.uid)

    if self.model.menberTab[self.uid] == nil then
        self.statusText.text = ""
    else
        self.statusText.text = TI18N("已结拜")
    end
end

function SwornFriendItem:__delete()
    self.headImage.sprite = nil
    self.classIconImage.sprite = nil
end

function SwornFriendItem:OnClick()
    self.model.selectUid = self.uid
    if self.model.lastSelect ~= nil then
        self.model.lastSelect:SetActive(false)
    end
    self.model.lastSelect = self.select
    self.select:SetActive(true)
    self.model.selectFriendTab = self.uidTab
end
