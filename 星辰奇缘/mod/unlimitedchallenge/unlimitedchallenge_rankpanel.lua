UnlimitedChallengeRankpanel = UnlimitedChallengeRankpanel or BaseClass(BasePanel)


function UnlimitedChallengeRankpanel:__init(model)
    self.model = model
    self.Mgr = UnlimitedChallengeManager.Instance
    self.resList = {
        {file = AssetConfig.unlimited_rankpanel, type = AssetType.Main}
        ,{file  =  AssetConfig.unlimited_texture, type  =  AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    -- self.teamupdatefunc = function()
    --     self:OnTeamUpdate()
    -- end
    self.updatelist = function()
        self:UpdateList()
    end
    self.totalSlot = {}
    self.total_cycleSlot = {}
    self.currSlot = {}
    self.curr_cycleSlot = {}
    self.selfdata = nil
    self.slotlist = {}
    self.mateItem = {}
end

function UnlimitedChallengeRankpanel:__delete()
    self.Mgr.UnlimitedChallengeRankUpdate:RemoveListener(self.updatelist)
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    for k,v in pairs(self.mateItem) do
        v.skill1:DeleteMe()
        v.skill2:DeleteMe()
    end
    self.mateItem = {}
end
function UnlimitedChallengeRankpanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.unlimited_rankpanel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "UnlimitedChallengeRankpanel"
    self.transform = self.gameObject.transform
    self.transform:SetAsFirstSibling()

    self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseRankPanel()
    end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseRankPanel()
    end)
    self.NoImg = self.transform:Find("Main/Left/NoImg").gameObject
    self.selfRank = self.transform:Find("Main/Left/SelfItem/Rank"):GetComponent(Text)
    self.selfHeadImg = self.transform:Find("Main/Left/SelfItem/Head/Image"):GetComponent(Image)
    self.selfHead = self.transform:Find("Main/Left/SelfItem/Head")
    self.selfName = self.transform:Find("Main/Left/SelfItem/Name"):GetComponent(Text)
    self.selfTime = self.transform:Find("Main/Left/SelfItem/Time"):GetComponent(Text)
    self.selfRound = self.transform:Find("Main/Left/SelfItem/Round"):GetComponent(Text)
    self.selfButton = self.transform:Find("Main/Left/SelfItem/Button"):GetComponent(Button)
    self.NoText = self.transform:Find("Main/Left/SelfItem/Text"):GetComponent(Text)
    self.selfButton.onClick:AddListener(function()
        self:ShowMate(self.selfdata)
    end)

    self.ViewPanel = self.transform:Find("ViewPanel"):GetComponent(Button)
    self.ViewPanel.onClick:AddListener(function()
        self.ViewPanel.gameObject:SetActive(false)
    end)
    self.mateItem = {}
    for i=1, 5 do
        self.mateItem[i] = {}
        local transform = self.ViewPanel.transform:Find("Con/"..tostring(i))
        self.mateItem[i].transform = transform
        self.mateItem[i].head = transform:Find("Head/Image"):GetComponent(Image)
        self.mateItem[i].name = transform:Find("Name"):GetComponent(Text)
        self.mateItem[i].round = transform:Find("Round"):GetComponent(Text)
        self.mateItem[i].skill1 = SingleIconLoader.New(transform:Find("skill1").gameObject)
        self.mateItem[i].skill2 = SingleIconLoader.New(transform:Find("skill2").gameObject)
    end

    self.ListCon = self.transform:Find("Main/Left/MaskScroll/ListCon")
    self.transform:Find("Main/Right/Button"):GetChild(1).gameObject:SetActive(false)
    self.item_list = {}
    for i=1,10 do
        local go = self.ListCon:GetChild(i-1).gameObject
        local item = UnlimitedRankItem.New(go, self)
        table.insert(self.item_list, item)
    end
    self.item_con = self.ListCon
    self.item_con_last_y = self.ListCon:GetComponent(RectTransform).anchoredPosition.y
    self.single_item_height = self.item_list[1].gameObject.transform.sizeDelta.y
    self.scroll_con_height = self.transform:Find("Main/Left/MaskScroll").sizeDelta.y
    self.vScroll = self.transform:Find("Main/Left/MaskScroll"):GetComponent(ScrollRect)
    self:InitList()
    self:InitRankReward()
    self.Mgr.UnlimitedChallengeRankUpdate:AddListener(self.updatelist)
    self.Mgr:Require17206()
end

function UnlimitedChallengeRankpanel:OnOpen()

end

function UnlimitedChallengeRankpanel:OnHide()

end

function UnlimitedChallengeRankpanel:InitList()
    local list = self.Mgr.rankData
    -- BaseUtils.dump(self.Mgr.rankData)
    table.sort(list, function(a,b)
        return a.rank<b.rank
    end)
    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.item_con  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.setting_data.data_list = list
    BaseUtils.refresh_circular_list(self.setting_data)
    self.NoImg:SetActive(#list <= 0)
    for i,v in ipairs(list) do
        if (RoleManager.Instance.RoleData.id == v.rid and RoleManager.Instance.RoleData.platform == v.platform and RoleManager.Instance.RoleData.zone_id == v.zone_id) then
            self.selfdata = v
        end
    end
    self:UpdateSelfData()
end

function UnlimitedChallengeRankpanel:UpdateList()
    local list = self.Mgr.rankData

    table.sort(list, function(a,b)
        return a.rank<b.rank
    end)
    if self.setting_data == nil then
        return
    end
    self.setting_data.data_list = list
    self.NoImg:SetActive(#list <= 0)
    BaseUtils.static_refresh_circular_list(self.setting_data)
    for i,v in ipairs(list) do
        if (RoleManager.Instance.RoleData.id == v.rid and RoleManager.Instance.RoleData.platform == v.platform and RoleManager.Instance.RoleData.zone_id == v.zone_id) then
            self.selfdata = v
        end
    end
    self:UpdateSelfData()
end

function UnlimitedChallengeRankpanel:UpdateSelfData()
    if self.selfdata == nil then
        self.selfRank.gameObject:SetActive(false)
        self.selfHeadImg.gameObject:SetActive(false)
        self.selfHead.gameObject:SetActive(false)
        self.selfName.gameObject:SetActive(false)
        self.selfTime.gameObject:SetActive(false)
        self.selfRound.gameObject:SetActive(false)
        self.selfButton.gameObject:SetActive(false)
        self.NoText.gameObject:SetActive(true)
    else
        self.selfRank.text = tostring(self.selfdata.rank)
        self.selfHeadImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, self.selfdata.classes.."_"..self.selfdata.sex)
        self.selfName.text = self.selfdata.name
        self.selfTime.text = BaseUtils.formate_time_gap(self.selfdata.use_time, ":", 0, BaseUtils.time_formate.HOUR)
        self.selfRound.text = self.selfdata.round

        self.selfRank.gameObject:SetActive(true)
        self.selfHeadImg.gameObject:SetActive(true)
        self.selfHead.gameObject:SetActive(true)
        self.selfName.gameObject:SetActive(true)
        self.selfTime.gameObject:SetActive(true)
        self.selfRound.gameObject:SetActive(true)
        self.selfButton.gameObject:SetActive(true)
        self.NoText.gameObject:SetActive(false)
    end
end

function UnlimitedChallengeRankpanel:InitRankReward()
    self.rightCon = self.transform:Find("Main/Right")
    for i=1, 4 do
        local item = self.rightCon:Find("rank"..tostring(i))
        local slot1 = item:Find("Item1")
        local slot2 = item:Find("Item2")
        local rewarddata = DataEndlessChallenge.data_rank_reward[i]
        if rewarddata ~= nil then
            rewarddata = rewarddata.cost
            if rewarddata[1] ~= nil then
                self:SetSlot(rewarddata[1][1], slot1, rewarddata[1][2])
            else
                slot1.gameObject:SetActive(false)
            end
            if rewarddata[2] ~= nil then
                self:SetSlot(rewarddata[2][1], slot2, rewarddata[2][2])
            else
                slot2.gameObject:SetActive(false)
            end
        end
    end
end

function UnlimitedChallengeRankpanel:SetSlot(base_id, parent, num)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    local base = DataItem.data_get[base_id]
    info:SetBase(base)
    info.quantity = num
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    table.insert(self.slotlist, slot)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
end

function UnlimitedChallengeRankpanel:ShowMate(data)
    if data ~= nil then
        local list = data.mate_datas
        -- BaseUtils.dump(data,"展示数据")
        for i=1, 5 do
            if list[i] ~= nil then
                self.mateItem[i].head.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, list[i].classes.."_"..list[i].sex)
                self.mateItem[i].name.text = list[i].name
                self.mateItem[i].round.text = string.format("Lv.%s %s", list[i].lev, KvData.classes_name[list[i].classes])
                for ii = 1,2 do
                    local item
                    if ii == 1 then
                        item = self.mateItem[i].skill1
                    else
                        item = self.mateItem[i].skill2
                    end
                    local skilldata = nil
                    for k,v in pairs(list[i].choose_skills) do
                        if v.index == ii then
                            skilldata = DataSkill.data_endless_challenge[v.skill_id]
                        end
                    end
                    if skilldata ~= nil then
                        -- item.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_endless, skilldata.icon)
                        item:SetSprite(SingleIconType.SkillIcon, skilldata.icon)
                        item.gameObject:SetActive(true)
                    else
                        item.gameObject:SetActive(false)
                    end
                end
                self.mateItem[i].transform.gameObject:SetActive(true)
            else
                self.mateItem[i].transform.gameObject:SetActive(false)
            end
        end
        self.ViewPanel.gameObject:SetActive(true)
    end
end