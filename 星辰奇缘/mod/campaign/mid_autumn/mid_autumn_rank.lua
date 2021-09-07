-- @author 黄耀聪
-- @date 2016年9月12日

MidAutumnRank = MidAutumnRank or BaseClass(BasePanel)

function MidAutumnRank:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.name = "MidAutumnRank"
    self.assetWrapper = assetWrapper
    self.mgr = MidAutumnFestivalManager.Instance

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.itemList = {}
    self.rankListener = function() self:ReloadList() end

    self:InitPanel()
end

function MidAutumnRank:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
end

function MidAutumnRank:InitPanel()
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    self.scroll = t:Find("Panel"):GetComponent(ScrollRect)
    self.container =  t:Find("Panel/Container")
    self.cloner = t:Find("Panel/Cloner").gameObject

    self.nothing= t:Find("Panel/Nothing").gameObject
    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})

    for i=1,10 do
        local obj = GameObject.Instantiate(self.cloner)
        obj.name = tostring(i)
        self.itemList[i] = MidAutumnRankItem.New(self.model, obj, self.assetWrapper)
        layout:AddCell(obj)
    end

    layout:DeleteMe()

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll.gameObject:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.scroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.cloner:SetActive(false)
end

function MidAutumnRank:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnRank:OnOpen()
    self:RemoveListeners()
    self.mgr.rankEvent:AddListener(self.rankListener)

    self.model:AskRankData()
    self:ReloadList()
end

function MidAutumnRank:OnHide()
    self:RemoveListeners()
end

function MidAutumnRank:RemoveListeners()
    self.mgr.rankEvent:RemoveListener(self.rankListener)
end

function MidAutumnRank:ReloadList()
    local model = self.model
    self.setting_data.data_list = model.rankDataList
    BaseUtils.refresh_circular_list(self.setting_data)

    self.nothing:SetActive(#model.rankDataList == 0)
end

MidAutumnRankItem = MidAutumnRankItem or BaseClass()

function MidAutumnRankItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.transform = gameObject.transform

    local t = self.transform
    self.rankText = t:Find("RankValue"):GetComponent(Text)
    self.rankImage = t:Find("RankValue/RankImage"):GetComponent(Image)
    self.rankCampImage = t:Find("RankValue/Camp"):GetComponent(Image)
    self.nameText = t:Find("Character/Name"):GetComponent(Text)
    self.centernameText = t:Find("Character/CenterName"):GetComponent(Text)
    self.iconObj = t:Find("Character/Icon").gameObject
    self.characterImage = t:Find("Character/Icon/Image"):GetComponent(Image)
    self.guildText = t:Find("Guild"):GetComponent(Text)
    self.scoreText = t:Find("Score"):GetComponent(Text)
    self.bgObj = t:Find("Bg").gameObject
    self.selectObj = t:Find("Select").gameObject
    self.button = self.gameObject:GetComponent(Button)

    self.characterImage.transform.parent.gameObject:SetActive(false)
    self.nameText.gameObject:SetActive(false)
    self.centernameText.gameObject:SetActive(true)
end

function MidAutumnRankItem:update_my_self(data, index)
    if index % 2 == 0 then
        self.bgObj:SetActive(true)
    else
        self.bgObj:SetActive(false)
    end

    if index < 4 then
        self.rankImage.gameObject:SetActive(true)
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..index)
        self.rankText.text = ""
    else
        self.rankImage.gameObject:SetActive(false)
        self.rankText.text = tostring(index)
    end
    self.centernameText.text = data.name
    if data.guild_name == "" or data.guild_name == nil then
        self.guildText.text = TI18N("无公会")
    else
        self.guildText.text = tostring(data.guild_name)
    end
    self.scoreText.text = tostring(data.wish_val or 0)
end

function MidAutumnRankItem:__delete()
end



