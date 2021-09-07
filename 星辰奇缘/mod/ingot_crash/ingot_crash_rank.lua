-- @author 黄耀聪
-- @date 2017年6月19日, 星期一

IngotCrashRank = IngotCrashRank or BaseClass(BaseWindow)

function IngotCrashRank:__init(model)
    self.model = model
    self.name = "IngotCrashRank"

    self.resList = {
        {file = AssetConfig.ingotcrash_rank, type = AssetType.Main},
        {file = AssetConfig.ingotcrash_textures, type = AssetType.Dep},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
        {file = AssetConfig.godswarres, type = AssetType.Dep},
    }

    self.itemList = {}

    self.updateListener = function() self:Reload() self:ReloadInfo() end
    self.infoListener = function() self:ReloadInfo() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IngotCrashRank:__delete()
    self.OnHideEvent:Fire()
    if self.buttonIconLoader ~= nil then
        self.buttonIconLoader:DeleteMe()
        self.buttonIconLoader = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            v:DeleteMe()
        end
        self.itemList = nil
    end
    self:AssetClearAll()
end

function IngotCrashRank:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ingotcrash_rank))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")

    self.scroll = main:Find("Rank/Scroll"):GetComponent(ScrollRect)
    self.container = self.scroll.transform:Find("Container")
    self.cloner = self.scroll.transform:Find("Cloner").gameObject
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.descText = main:Find("Info/Desc"):GetComponent(Text)
    self.myRankText = main:Find("Info/MyRank"):GetComponent(Text)
    self.myScoreText = main:Find("Info/MyScore"):GetComponent(Text)
    self.mySituationImage = main:Find("Info/MySituation"):GetComponent(Image)
    self.button = main:Find("Info/Button"):GetComponent(Button)
    self.hasGetObj = main:Find("Info/HasGet").gameObject
    self.nothing = main:Find("Nothing").gameObject
    self.buttonIconLoader = SingleIconLoader.New(main:Find("Info/Button/Image").gameObject)

    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    for i=1,15 do
        self.itemList[i] = IngotCrashRankItem.New(self.model, GameObject.Instantiate(self.cloner), self.assetWrapper)
        layout:AddCell(self.itemList[i].gameObject)
    end
    layout:DeleteMe()

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner.transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container.transform.anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll.transform.rect.height --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    main:Find("Title/Text"):GetComponent(Text).text = IngotCrashManager.Instance.activityName
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)
    self.button.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ingot_crash_reward) end)
    self.cloner:SetActive(false)
    self.hasGetObj:SetActive(false)
    self.descText.transform.pivot = Vector2(0, 0.5)
    self.descText.transform.anchoredPosition = Vector2(38, 12)
    self.descText.transform.sizeDelta = Vector2(300, 25)
    self.descText.fontSize = 17

    self.buttonIconLoader:SetSprite(SingleIconType.Item, 90026)
end

function IngotCrashRank:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IngotCrashRank:OnOpen()
    self:RemoveListeners()
    IngotCrashManager.Instance.onUpdateRank:AddListener(self.updateListener)
    IngotCrashManager.Instance.onUpdateInfo:AddListener(self.infoListener)

    IngotCrashManager.Instance:send20008()
    IngotCrashManager.Instance:send20007()

    self:ReloadInfo()

    self.countMax = (self.openArgs or {}).time

    self:Reload()
end

function IngotCrashRank:OnHide()
    self:RemoveListeners()
end

function IngotCrashRank:RemoveListeners()
    IngotCrashManager.Instance.onUpdateRank:RemoveListener(self.updateListener)
    IngotCrashManager.Instance.onUpdateInfo:RemoveListener(self.infoListener)
end

function IngotCrashRank:Reload()
    self.setting_data.data_list = self.model.rankData or {}
    self.nothing:SetActive(#self.setting_data.data_list == 0)
    BaseUtils.refresh_circular_list(self.setting_data)
end

function IngotCrashRank:ReloadInfo()
    if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Ready then
        self.myRankText.text = "活动尚未开始"
        self.myScoreText.text = ""
        self.mySituationImage.gameObject:SetActive(false)
    else
        self.myScoreText.text = string.format(TI18N("当前积分:<color='#ffffff'>%s</color>"), self.model.personData.score or 0)
        if self.model.personData.rank ~= nil then
            self.myRankText.text = string.format(TI18N("我的排名:<color='#ffffff'>%s</color>"), self.model.personData.rank)
        else
            self.myRankText.text = string.format(TI18N("我的排名:<color='#ffffff'>%s</color>"), TI18N("未上榜"))
        end

        local is_rise = 0
        local roleData = RoleManager.Instance.RoleData
        for _,v in pairs(self.model.rankData or {}) do
            if v.rid == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
                is_rise = v.is_rise
                break
            end
        end
        if is_rise == 0 then
            self.mySituationImage.gameObject:SetActive(false)
        elseif is_rise == 1 then
            self.mySituationImage.gameObject:SetActive(true)
            self.mySituationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.ingotcrash_textures, "SuccGetInI18N")
        else
            self.mySituationImage.gameObject:SetActive(true)
            self.mySituationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.ingotcrash_textures, "CannotGetInI18N")
        end
    end
    self.descText.text = string.format(TI18N("本次活动前<color='#00ff00'>%s</color>名玩家可晋级淘汰赛"), self.model.canUpgradeNum or 32)
end

function IngotCrashRank:CountDown()

end
