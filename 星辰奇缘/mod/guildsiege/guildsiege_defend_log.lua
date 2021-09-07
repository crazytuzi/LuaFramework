-- @author 黄耀聪
-- @date 2017年2月27日

GuildSiegeDefendLog = GuildSiegeDefendLog or BaseClass(BasePanel)

function GuildSiegeDefendLog:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.name = "GuildSiegeDefendLog"

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.itemList = {}

    self:InitPanel()
end

function GuildSiegeDefendLog:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
    end
    self.setting_data = nil
end

function GuildSiegeDefendLog:InitPanel()
    local t = self.gameObject.transform
    self.transform = t

    self.cloner = t:Find("List/Scroll/Item").gameObject
    self.container = t:Find("List/Scroll/Container")
    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    for i=1,10 do
        local obj = GameObject.Instantiate(self.cloner)
        layout:AddCell(obj)
        self.itemList[i] = GuildSiegeDefendLogItem.New(self.model, obj)
        self.itemList[i].assetWrapper = self.assetWrapper
    end
    layout:DeleteMe()
    self.cloner:SetActive(false)

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner.transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container.transform.anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = t:Find("List/Scroll").rect.height --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    t:Find("List/Scroll"):GetComponent(ScrollRect).onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)
    self.nothing = t:Find("List/Nothing").gameObject
end

function GuildSiegeDefendLog:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeDefendLog:OnOpen()
    self:RemoveListeners()
    local datalist = {}
    for i,v in ipairs((self.castle or {}).castle_log or {}) do
        if v.r_id_1 ~= self.castle.r_id or v.r_plat_1 ~= self.castle.r_plat or v.r_zone_1 ~= self.castle.r_zone then
            table.insert(datalist, v)
        end
    end
    table.sort(datalist, function(a,b) return a.time > b.time end)
    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)

    self.nothing:SetActive(#datalist == 0)
end

function GuildSiegeDefendLog:OnHide()
    self:RemoveListeners()
end

function GuildSiegeDefendLog:RemoveListeners()
end

GuildSiegeDefendLogItem = GuildSiegeDefendLogItem or BaseClass()

function GuildSiegeDefendLogItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    self.bg = gameObject:GetComponent(Image)
    self.timeText = self.transform:Find("Time"):GetComponent(Text)
    self.nameText = self.transform:Find("Player"):GetComponent(Text)
    self.levText = self.transform:Find("Lev"):GetComponent(Text)
    self.starContainer = self.transform:Find("Star")
    self.starList = {}
    for i=1,3 do
        self.starList[i] = self.starContainer:GetChild(i - 1):GetComponent(Image)
    end
    self.resText = self.transform:Find("Res"):GetComponent(Text)
    self.transform:GetComponent(Button).onClick:AddListener(function() self:OnPlay() end)
    -- self.transform:Find("Res/Image"):GetComponent(Button).onClick:AddListener(function() self:OnPlay() end)
end

function GuildSiegeDefendLogItem:OnPlay()
    if self.data ~= nil then
        GuildSiegeManager.Instance:send19111(self.data.replay_id, self.data.replay_plat, self.data.replay_zone)
    end
end

function GuildSiegeDefendLogItem:__delete()
    for _,v in pairs(self.starList) do
        v.sprite = nil
    end
end

function GuildSiegeDefendLogItem:update_my_self(data, index)
    self.data = data
    if index % 2 == 1 then
        self.bg.color = ColorHelper.ListItem1
    else
        self.bg.color = ColorHelper.ListItem2
    end
    self.levText.text = data.role_lev_1

    local dis = BaseUtils.BASE_TIME - data.time
    if dis < 60 then
        self.timeText.text = TI18N("1分钟前")
    elseif dis < 3600 then
        self.timeText.text = string.format(TI18N("%s分钟前"), math.ceil(dis / 60))
    elseif dis < 86400 then
        self.timeText.text = string.format(TI18N("%s小时前"), math.ceil(dis / 3600))
    else
        self.timeText.text = string.format(TI18N("%s天前"), math.ceil(dis / 86400))
    end

    self.nameText.text = BaseUtils.string_cut_utf8(data.role_name_1, 15, 12)
    self.starContainer.sizeDelta = Vector2(24 * data.star, 24)
    for i=1,3 do
        self.starList[i].gameObject:SetActive(i <= data.star)
        if data.is_win == 1 then
            self.starList[i].sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Star")
        else
            self.starList[i].sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "DarkStar")
        end
    end

    -- 挑战胜利，即此人失败
    if data.is_win == 1 then
        self.resText.text = TI18N("<color='#ff0000'>防守失败</color>")
    else
        self.resText.text = TI18N("<color='#00ff00'>防守成功</color>")
    end
end

