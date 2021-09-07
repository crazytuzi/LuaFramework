-- @author 黄耀聪
-- @date 2017年2月27日

GuildSiegeAttackLog = GuildSiegeAttackLog or BaseClass(BasePanel)

function GuildSiegeAttackLog:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.name = "GuildSiegeAttackLog"

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.itemList = {}
    self.is_init = {}

    self.updateListener = function(type) self:Update(type) end

    self:InitPanel()
end

function GuildSiegeAttackLog:__delete()
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

function GuildSiegeAttackLog:InitPanel()
    local t = self.gameObject.transform
    self.transform = t

    self.cloner = t:Find("Scroll/Cloner").gameObject
    self.container = t:Find("Scroll/Container")
    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    for i=1,15 do
        local obj = GameObject.Instantiate(self.cloner)
        layout:AddCell(obj)
        self.itemList[i] = GuildSiegeAttackLogItem.New(self.model, obj)
        self.itemList[i].assetWrapper = self.assetWrapper
    end
    layout:DeleteMe()
    self.cloner:SetActive(false)

    local scroll = t:Find("Scroll")
    scroll.anchorMax = Vector2(0.5, 1)
    scroll.anchorMin = Vector2(0.5, 1)
    scroll.anchoredPosition = Vector2(0, -283)
    scroll.sizeDelta = Vector2(574, 360)

    self.myButton = t:Find("ResultTitle/My"):GetComponent(Button)
    self.myTick = t:Find("ResultTitle/My/Toggle/Tick").gameObject
    self.enemyButton = t:Find("ResultTitle/Enemy"):GetComponent(Button)
    self.enemyTick = t:Find("ResultTitle/Enemy/Toggle/Tick").gameObject

    self.myGuildNameText = t:Find("ResultTitle/Name1"):GetComponent(Text)
    self.enemyNameText = t:Find("ResultTitle/Name2"):GetComponent(Text)
    self.scoreText = t:Find("ResultTitle/Score"):GetComponent(Text)

    self.nothing = t:Find("Nothing").gameObject

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner.transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container.transform.anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = t:Find("Scroll").rect.height --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    t:Find("Scroll"):GetComponent(ScrollRect).onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)

    self.cloner:SetActive(false)

    self.myButton.onClick:AddListener(function() self:SelecType(1) end)
    self.enemyButton.onClick:AddListener(function() self:SelecType(2) end)
end

function GuildSiegeAttackLog:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeAttackLog:OnOpen()
    self:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateLog:AddListener(self.updateListener)

    self:ReloadInfo()
    self:SelecType(self.currentType or 1)
end

function GuildSiegeAttackLog:OnHide()
    self:RemoveListeners()

    self.currentType = nil
    self.is_init[1] = false
    self.is_init[2] = false
end

function GuildSiegeAttackLog:Update(type)
    if type == self.currentType then
        self:SelecType(type or 1)
    end
end

function GuildSiegeAttackLog:SelecType(type)
    if self.is_init[type] ~= true then
        GuildSiegeManager.Instance:send19105(type)
        self.is_init[type] = true
    end

    self.currentType = type
    local datalist = {}

    if type == 1 then
        self.myTick.gameObject:SetActive(true)
        self.enemyTick.gameObject:SetActive(false)
        for _,v in pairs(self.model.guard_attack_log or {}) do
            table.insert(datalist, v)
        end
    else
        self.myTick.gameObject:SetActive(false)
        self.enemyTick.gameObject:SetActive(true)
        for _,v in pairs(self.model.enemy_attack_log or {}) do
            table.insert(datalist, v)
        end
    end

    table.sort(datalist, function(a,b) return a.time > b.time end)
    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)

    self.nothing:SetActive(#datalist == 0)
end

function GuildSiegeAttackLog:ReloadInfo()
    local guildList = (self.model.statusData or {}).guild_match_list or {{}, {}}
    self.myGuildNameText.text = guildList[1].guild_name or ""
    self.enemyNameText.text = guildList[2].guild_name or ""
    self.scoreText.text = string.format("%s-%s", guildList[1].score or 0, guildList[2].score or 0)
end

function GuildSiegeAttackLog:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateLog:RemoveListener(self.updateListener)
end

GuildSiegeAttackLogItem = GuildSiegeAttackLogItem or BaseClass()

function GuildSiegeAttackLogItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    self.bg = gameObject:GetComponent(Image)
    self.timeText = self.transform:Find("Time"):GetComponent(Text)
    self.nameText1 = self.transform:Find("Player1"):GetComponent(Text)
    self.nameText2 = self.transform:Find("Player2"):GetComponent(Text)
    self.starContainer = self.transform:Find("Container")
    self.starList = {}
    for i=1,3 do
        self.starList[i] = self.starContainer:GetChild(i - 1):GetComponent(Image)
    end
    self.resText = self.transform:Find("Res"):GetComponent(Text)

    local btn = self.resText.gameObject:GetComponent(Button)
    if btn == nil then
        btn = self.resText.gameObject:AddComponent(Button)
    end
    btn.onClick:AddListener(function() GuildSiegeManager.Instance:send19111(self.data.replay_id, self.data.replay_plat, self.data.replay_zone) end)
    local btn = self.resText.transform:Find("Play").gameObject:GetComponent(Button)
    if btn == nil then
        btn = self.resText.transform:Find("Play").gameObject:AddComponent(Button)
    end
    btn.onClick:AddListener(function() GuildSiegeManager.Instance:send19111(self.data.replay_id, self.data.replay_plat, self.data.replay_zone) end)
end

function GuildSiegeAttackLogItem:__delete()
    for _,v in pairs(self.starList) do
        v.sprite = nil
    end
end

function GuildSiegeAttackLogItem:update_my_self(data, index)
    self.data = data
    if index % 2 == 1 then
        self.bg.color = ColorHelper.ListItem1
    else
        self.bg.color = ColorHelper.ListItem2
    end

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

    self.nameText1.text = data.role_name_1
    self.nameText2.text = data.role_name_2
    self.starContainer.sizeDelta = Vector2(24 * data.star, 24)
    for i=1,3 do
        self.starList[i].gameObject:SetActive(i <= data.star)
        if data.is_win == 1 then
            self.starList[i].sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Star")
        else
            self.starList[i].sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "DarkStar")
        end
    end

    if data.is_win == 1 then
        self.resText.text = TI18N("<color='#ff0000'>胜利</color>")
    else
        self.resText.text = TI18N("<color='#00ff00'>失败</color>")
    end
end

