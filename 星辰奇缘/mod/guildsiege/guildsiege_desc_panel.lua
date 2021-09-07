-- @author 黄耀聪
-- @date 2017年2月22日

GuildSiegeDescPanel = GuildSiegeDescPanel or BaseClass(BasePanel)

function GuildSiegeDescPanel:__init(model, parent)
    self.model = model
    self.name = "GuildSiegeDescPanel"
    self.parent = parent

    self.windowId = WindowConfig.WinID.guild_siege_desc_window

    self.typeList = {}

    self.resList = {
        {file = AssetConfig.guildsiege_desc_window, type = AssetType.Main},
        {file = AssetConfig.guildsiege, type = AssetType.Dep},
    }

    self.phaseStringList = {
        [1] = {title = TI18N("1.备战阶段"), desc = TI18N([[【公会攻城战】
1.公会攻城战<color='#ffff00'>周一、周五</color>开启，每周匹配两次对手
2.每场攻城战为期<color='#ffff00'>1天</color>，公会成员可自行组织攻打敌方城堡
3.每场比赛结束时，按照双方进攻<color='#ffff00'>总星数</color>宣布获胜公会

【备战阶段】
活动当天15:55公布对阵情况并进入备战阶段：
1.公会<color='#ffff00'>排名前50</color>的成员，将按能力排序，镇守公会城堡
2.镇守人员需设置防守阵容，设置后可随时修改，未设置则默认取当前竞技场布阵
3.建议公会成员共同商讨战术，以便开战后调配人员]])},
        [2] = {title = TI18N("2.正式开战"), desc = TI18N([[【正式开战】
1.活动当天<color='#ffff00'>16:00</color>攻城战正式开启，双方公会可相互进攻
2.<color='#ffff00'>等级≥65</color>且<color='#ffff00'>入会时间≥3天</color>的成员，均有<color='#ffff00'>2次</color>进攻机会
3.选择对手后，可选取1、2、3星难度，不同难度拥有不同奖励
4.攻城获胜后公会获得相应星数，三星摧毁后不可被再次进攻
5.当天<color='#ffff00'>23:30比赛结束</color>时，按照星数判定获胜公会]])},
        [0] = {title = TI18N("3.冠军战场"), desc = TI18N([[【32强晋级】
1.每个组别<color='#ffff00'>前32强</color>将获得定期举办的<color='#ffff00'>冠军联赛</color>资格，角逐冠军奖杯
2.<color='#ffff00'>等级≥65</color>且<color='#ffff00'>入会时间≥8天</color>的成员可组队参加
3.其它未晋级公会将继续安排<color='#ffff00'>公会攻城战</color>比赛

【冠军战场】
1、每场比赛中双方公会各拥有<color='#ffff00'>3座水晶塔</color>，<color='#ffff00'>按顺序</color>摧毁对方3座水晶塔即可获得本场<color='#ffff00'>胜利</color>
2、比赛开始<color='#ffff00'>12</color>分钟时，<color='#ffff00'>战场大炮</color>准备就绪，成功开炮可对敌方水晶塔造成大量伤害
3、获胜的玩家可打开战场胜利宝箱，获胜公会将根据摧毁对方水晶程度获得一定积分
4、注意：双方参战人数<color='#ffff00'>上限</color>均为<color='#ffff00'>100人</color>，请在准备厅合理安排参战人员及战略
5、战斗中将根据双方<color='#ffff00'>平均等级</color>差距，给予落后方一定属性补偿（仅弥补等级上的弱势）]])},
    }

    self.updateListener = function() self:SetMark(self.model.status) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildSiegeDescPanel:__delete()
    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    for _,v in pairs(self.typeList) do
        if v ~= nil then
            v.descExt:DeleteMe()
            if v.effect ~= nil then
                v.effect:DeleteMe()
            end
        end
    end
    self:AssetClearAll()
end

function GuildSiegeDescPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildsiege_desc_window))
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main").localPosition = Vector3(0, 0, -1500)

    t:Find("Main/Title/Text"):GetComponent(Text).text = TI18N("规则说明")
    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self.doing = t:Find("Main/Doing")

    self.tabGroup = TabGroup.New(t:Find("Main/PhaseSelect").gameObject, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = true, perWidth = 128, perHeight = 40, isVertical = false, spacing = 192})
    self.layout = LuaBoxLayout.New(t:Find("Main/Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.descExt = MsgItemExt.New(t:Find("Main/Scroll/Container/Desc"):GetComponent(Text), 512, 17, 19.684)

    for i,v in ipairs(self.tabGroup.buttonTab) do
        local j = i
        -- if j == 3 then
        --     j = 0
        -- end
        v.normalTxt.text = self.phaseStringList[j].title
        v.selectTxt.text = self.phaseStringList[j].title
    end

    self.titleObj = t:Find("Main/Scroll/Container/Title").gameObject
    self.layout:AddCell(self.descExt.contentTrans.gameObject)

    self.castleContainer = t:Find("Main/Scroll/Container/Castle")
    for i=0,#GuildSiegeEumn.CastleType do
        local tab = {}
        tab.transform = self.castleContainer:GetChild(i)
        tab.gameObject = tab.transform.gameObject
        tab.castleImg = tab.transform:Find("Castle"):GetComponent(Image)
        tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        tab.descExt = MsgItemExt.New(tab.transform:Find("Desc"):GetComponent(Text), 150, 17, 19.68)
        self.typeList[i] = tab
    end
    for k,v in pairs(self.typeList) do
        v.nameText.text = GuildSiegeEumn.CastleType[k]
        v.gameObject:SetActive(true)

        if k == 1 then
            v.effect = BibleRewardPanel.ShowEffect(20307, v.castleImg.transform, Vector3(1, 1, 1), Vector3(0, 50, -400))
        elseif k == 3 then
            v.effect = BibleRewardPanel.ShowEffect(20308, v.castleImg.transform, Vector3(1, 1, 1), Vector3(0, 44, -400))
        end

        local data = DataGuildSiege.data_castle_desc[k] or {}
        v.descExt:SetData(data.desc or "")
        v.castleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Castle" .. k)
    end

    self.titleObj.transform.sizeDelta = Vector2(478, 40)
end

function GuildSiegeDescPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeDescPanel:OnOpen()
    self:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateStatus:AddListener(self.updateListener)

    local status = (self.openArgs or {})[1] or 1
    self:SetMark(status)
    if status == 0 then
        status = 1
    end
    self.tabGroup:ChangeTab(status)
    
end

function GuildSiegeDescPanel:OnHide()
    self:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateStatus:Fire()
end

function GuildSiegeDescPanel:SetMark(status)
    self.doing.gameObject:SetActive(status ~= 0)
    if status == 1 then
        self.doing.transform.anchoredPosition = Vector2(-152,173.5)
    elseif status == 2 then
        self.doing.transform.anchoredPosition = Vector2(38.6,173.5)
    elseif status == 0 then
        self.doing.transform.anchoredPosition = Vector2(143.7,173.5)
    end
end

function GuildSiegeDescPanel:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateStatus:RemoveListener(self.updateListener)
end

function GuildSiegeDescPanel:ChangeTab(index)
    -- if index == 3 then
    --     index = 0
    -- end
    self.descExt:SetData(self.phaseStringList[index].desc)
    self:Reload(index)
end

function GuildSiegeDescPanel:Reload(index)
    self.titleObj:SetActive(false)
    self.castleContainer.gameObject:SetActive(false)

    self.layout:ReSet()
    self.layout:AddCell(self.descExt.contentTrans.gameObject)

    if index == 2 then
        self.layout:AddCell(self.titleObj)
        self.layout:AddCell(self.castleContainer.gameObject)
    end
end
