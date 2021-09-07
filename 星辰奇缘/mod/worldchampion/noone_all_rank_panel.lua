-- 天下第一武道会群雄排行面板
-- @author zgs
NoOneAllRankPanel = NoOneAllRankPanel or BaseClass(BasePanel)

function NoOneAllRankPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "NoOneAllRankPanel"

    self.resList = {
        {file = AssetConfig.worldchampionallrankpanel, type = AssetType.Main}
        , {file = AssetConfig.glory_textures, type = AssetType.Dep}
        , {file = AssetConfig.half_length, type = AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function()
        self.showType = self.openArgs
        if self.showType == 1 then
            if self.toggleBottom ~= nil and self.toggleBottom.isOn == true then
                self.showType = 2
            end
        end
        WorldChampionManager.Instance:Require16416(self.showType)
    end)

    self.no1world_rank_data_changeFun = function ()
        self:UpdatePanel()
    end
    EventMgr.Instance:AddListener(event_name.no1world_rank_data_change, self.no1world_rank_data_changeFun)

    self.effectCounter = 0
    self.effectShakeCounter = 0
end


-- function NoOneAllRankPanel:RemovePanel()
--     self:DeleteMe()
-- end

function NoOneAllRankPanel:OnInitCompleted()
    self.showType = self.openArgs
    -- self:UpdatePanel()
    WorldChampionManager.Instance:Require16416(self.showType)
end

function NoOneAllRankPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.no1world_rank_data_change, self.no1world_rank_data_changeFun)
    if self.boximgloader ~= nil then
        self.boximgloader:DeleteMe()
        self.boximgloader = nil
    end
    self.model.guildfightSetTimePanel = nil
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.guild_fight_givebox_panel = nil
    self.model = nil
end

function NoOneAllRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionallrankpanel))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.gameObject.name = "NoOneAllRankPanel"
    self.transform = self.gameObject.transform

    self.rankText = self.transform:Find("Personal/Rank"):GetComponent(Text) --我的排名
    self.levText = self.transform:Find("Personal/Score"):GetComponent(Text) --级别
    self.boxName = self.transform:Find("Personal/BoxName"):GetComponent(Text) --级别
    self.boxImage = self.transform:Find("Personal/BoxName/BoxImage"):GetComponent(Image)
    self.boximgloader = SingleIconLoader.New(self.boxImage.gameObject)
    self.boximgloader:SetSprite(SingleIconType.Item, 22504)
    self.boxImage.gameObject:SetActive(true)
    if self.boxImage.gameObject:GetComponent(Button) == nil then
        self.boxImage.gameObject:AddComponent(Button)
    end
    self.treasureRect = self.boxImage.gameObject:GetComponent(RectTransform)
    self.boxImage.gameObject:GetComponent(Button).onClick:AddListener( function()
        if self.shakeTimerId ~= nil then LuaTimer.Delete(self.shakeTimerId) end
        self.effectShakeCounter = 0
        self.shakeTimerId = LuaTimer.Add(0, 20, function() self:ShakeGameObject(true) end)

        self.descRole = {
            self:getLevDesc(),
            TI18N("1.本赛季结束时，将根据<color='#ffff00'>历史最高排名</color>获得结算宝箱"),
            TI18N("2.排名越高，结算宝箱奖励越丰厚"),
        }
        TipsManager.Instance:ShowText({gameObject = self.boxImage.gameObject, itemData = self.descRole})
    end)
    self.roleMOdelImage = self.transform:Find("Personal/RoleImage"):GetComponent(Image)

    self.noneObj = self.transform:Find("Panel4/Panel/Nothing").gameObject
    self.noneObj:SetActive(false)

    self.scroll_con = self.transform:Find("Panel4/Panel")
    self.layoutContainer = self.transform:Find("Panel4/Panel/Container")
    self.scroll = self.transform:Find("Panel4/Panel"):GetComponent(RectTransform)
    self.memberLayout = LuaBoxLayout.New(self.layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})--,scrollRect = self.scroll})
    -- self.memberItem = self.layoutContainer:Find("Cloner").gameObject
    -- self.memberItem:SetActive(false)


    -- self.item_con = self.scroll_con:FindChild("Container")
    self.item_con_last_y = self.layoutContainer:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.scroll_con:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,15 do
        -- local obj = GameObject.Instantiate(self.memberItem)
        -- obj.name = tostring(i)
        -- self.memberLayout:AddCell(obj)
        -- local item = GuildFightBoxMenberItem.New(obj,self)
        -- table.insert(self.item_list, item)

        local obj = self.layoutContainer:Find("Cloner_"..i).gameObject
        -- self.memberLayout:AddCell(obj)
        local item = NoOneRankItem.New(obj,self)
        table.insert(self.item_list, item)
    end

    self.single_item_height = self.item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.scroll_con:GetComponent(RectTransform).sizeDelta.y
    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.layoutContainer  --item列表的父容器
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

    self.bottomDesc = self.transform:Find("Desc"):GetComponent(Text)
    self.bottomRightSA = self.transform:Find("SelectArea").gameObject
    self.toggleBottom = self.transform:Find("SelectArea/Toggle"):GetComponent(Toggle)
    self.toggleBottom.isOn = false
    self.toggleBottom.onValueChanged:AddListener(function (status)
        if status == true then
            self.showType = 2
            WorldChampionManager.Instance:Require16416(2)
        else
            self.showType = 1
            WorldChampionManager.Instance:Require16416(1)
        end
    end)
end

function NoOneAllRankPanel:ShakeGameObject(bool)
    local maxTime = 6280
    self.effectCounter = (self.effectCounter + 40) % maxTime
    self.effectShakeCounter = (self.effectShakeCounter + 2) % 100
    if bool == true and self.effectShakeCounter >= 30 then
        LuaTimer.Delete(self.shakeTimerId)
        self.shakeTimerId = 0
        self.treasureRect.rotation = Quaternion.Euler(0, 0, 0)
        return
    end
    local status = 1
    if self.effectShakeCounter > 30 then status = 0 end
    local diff = math.sin(self.effectCounter / 20)
    self.treasureRect.rotation = Quaternion.Euler(0, 0, diff * status * 5)
end

function NoOneAllRankPanel:getLevDesc()
    return string.format(TI18N("赛季结算宝箱：<color='#ffff00'>%s宝箱</color>"), DataTournament.data_list[WorldChampionManager.Instance.rankData.season_rank_lev].name)
end

function NoOneAllRankPanel:onClickShowReward()
    -- 显示宝箱物品
end

function NoOneAllRankPanel:UpdatePanel()
    self.levText.text = DataTournament.data_list[WorldChampionManager.Instance.rankData.rank_lev].name
    self.boxName.text = string.format(TI18N("%s级宝箱"), tostring(WorldChampionManager.Instance.rankData.season_rank_lev))
    self.roleMOdelImage.sprite = self.assetWrapper:GetSprite(AssetConfig.half_length, "half_"..RoleManager.Instance.RoleData.classes..RoleManager.Instance.RoleData.sex)
    self.roleMOdelImage.gameObject:SetActive(true)
    if self.showType == 1 then
        self.bottomRightSA:SetActive(true)
    elseif self.showType == 3 then
        self.bottomRightSA:SetActive(false)
    end

    local sortFun = function(a, b)
        if a.rank_lev > b.rank_lev then
            return true
        elseif a.rank_lev < b.rank_lev then
            return false
        else
            if a.rank_point > b.rank_point then
                return true
            elseif a.rank_point < b.rank_point then
                return false
            else
                if a.rid < b.rid then
                    return true
                else
                    return false
                end
            end
        end
    end

    table.sort(WorldChampionManager.Instance.rankList[self.showType].rank, sortFun)

    self.rankText.text = TI18N("暂未上榜")
    local roleData = RoleManager.Instance.RoleData
    for i,v in ipairs(WorldChampionManager.Instance.rankList[self.showType].rank) do
        if roleData.id == v.rid and roleData.platform == v.platform and roleData.zone_id == v.zone_id then
            self.rankText.text = string.format(TI18N("我的排名: %s"), tostring(i))
            break
        end
    end

    self:UpdateList(WorldChampionManager.Instance.rankList[self.showType].rank)

    if #WorldChampionManager.Instance.rankList[self.showType].rank > 0 then
        self.noneObj:SetActive(false)
    else
        self.noneObj:SetActive(true)
    end
end

function NoOneAllRankPanel:UpdateList(dataList)
    self.setting_data.data_list = dataList

    BaseUtils.refresh_circular_list(self.setting_data)

end
