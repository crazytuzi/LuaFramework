DragonBoatRankScoreWindow  =  DragonBoatRankScoreWindow or BaseClass(BasePanel)

function DragonBoatRankScoreWindow:__init(model)
    self.name  =  "DragonBoatRankScoreWindow"
    self.model  =  model
    -- 缓存
    self.dataList = { }
    self.resList  =  {
        {file = AssetConfig.dragonboatrankscorewin, type  =  AssetType.Main}
        ,{file = AssetConfig.rank_textures, type  =  AssetType.Dep}
    }

    return self
end

function DragonBoatRankScoreWindow:__delete()
    self.has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function DragonBoatRankScoreWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.dragonboatrankscorewin))
    self.gameObject.name  =  "DragonBoatRankScoreWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    local CloseBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseRankScoreWindow() end)

    self.MyRank = self.transform:FindChild("Main/MyRank"):GetComponent(Text)
    self.DescText = self.transform:FindChild("Main/DescText"):GetComponent(Text)

    self.noRankTips = self.transform:FindChild("Main/NoRankTips").gameObject

    self.rankcloner = self.transform:FindChild("Main/RankPanel/Rank1").gameObject
    self.rankcloner:SetActive(false)

    self.title = self.transform:FindChild("Main/title/TxtTitle"):GetComponent(Text)
    self.title.text = string.format("%s排名", DragonBoatManager.Instance.title_name)

    self:update_my_score()
end

--更新我的答题成绩
-- function DragonBoatRankScoreWindow:update_my_score()
--     local data = DragonBoatManager.Instance.rankData

--     local function sortfun(a,b)
--         return a.rank < b.rank
--     end

--     if #data.dragon_boat_team > 0 then table.sort(data.dragon_boat_team, sortfun) end

--     local rank_panel_transform = self.transform:FindChild("Main/RankPanel")
--     for i = 1, 10 do
--         local rank_data = data.dragon_boat_team[i]
--         if rank_data ~= nil then
--             local rank_transform = rank_panel_transform:FindChild(string.format("Rank%s", i))
--             rank_transform:FindChild("RankText"):GetComponent(Text).text = string.format("%s", i)
--             rank_transform:FindChild("NameText"):GetComponent(Text).text = string.format(TI18N("%s的队伍"), rank_data.leader_name)
--             if rank_data.done == 8 then
--                 rank_transform:FindChild("StarText"):GetComponent(Text).text = TI18N("终 点")
--             else
--                 rank_transform:FindChild("StarText"):GetComponent(Text).text = string.format(TI18N("第%s签到点"), rank_data.done)
--             end

--             local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(rank_data.time_span)
--             my_minute = my_minute + 60 * my_hour
--             my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
--             my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
--             local time_str = string.format("%s%s%s%s", my_minute, TI18N("分"), my_second, TI18N("秒"))
--             rank_transform:FindChild("TimeText"):GetComponent(Text).text = time_str
--         else
--             local rank_transform = rank_panel_transform:FindChild(string.format("Rank%s", i))
--             rank_transform:FindChild("RankText"):GetComponent(Text).text = ""
--             rank_transform:FindChild("NameText"):GetComponent(Text).text = ""
--             rank_transform:FindChild("StarText"):GetComponent(Text).text = ""
--             rank_transform:FindChild("TimeText"):GetComponent(Text).text = ""

--             if i <=3 then
--                 rank_transform:FindChild("RankImage").gameObject:SetActive(false)
--             end
--         end
--     end

--     if #data.dragon_boat_team == 0 then
--         rank_panel_transform.gameObject:SetActive(false)
--         self.noRankTips:SetActive(true)
--     end

--     self.MyRank.text = string.format("%s<color='#c7f9ff'>%s</color>", TI18N("我当前的排名："), data.self_rank)
--     self.DescText.text = TI18N("排行榜每<color='#8de92a'>3分钟</color>刷新一次")
-- end

--加载排行榜数据
function DragonBoatRankScoreWindow:update_my_score()

    local data = DragonBoatManager.Instance.rankData
    local function sortfun(a,b)
        return a.rank < b.rank
    end
    if #data.dragon_boat_team > 0 then table.sort(data.dragon_boat_team, sortfun) end
    local rank_panel_transform = self.transform:FindChild("Main/RankPanel")
    for i = 1, 10 do
        local rankdata = data.dragon_boat_team[i]
        if rankdata ~= nil then
           local item = self.dataList[i]
           if item ==nil then
              item = GameObject.Instantiate(self.rankcloner)
              item.transform:SetParent(rank_panel_transform)
              item.transform.localScale = Vector3(1, 1, 1)
              item:SetActive(true)
              self.dataList[i] = item
           end
           if i <= 3 then
              item.transform:FindChild("RankText"):GetComponent(Text).text = ""
              item.transform:FindChild("RankImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures,string.format("place_%s", i))
           elseif i > 3 and i <= 10 then
              item.transform:FindChild("RankText"):GetComponent(Text).text = string.format("%s", i)  --local itemRect  self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
              item.transform:FindChild("RankImage").gameObject:SetActive(false)
           end

           item.transform:FindChild("NameText"):GetComponent(Text).text = string.format(TI18N("%s的队伍"), rankdata.leader_name)
           if rankdata.done == 8 then
               item.transform:FindChild("StarText"):GetComponent(Text).text = TI18N("终 点")
           else
               item.transform:FindChild("StarText"):GetComponent(Text).text = string.format(TI18N("第%s签到点"), rankdata.done)
           end

           local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(rankdata.time_span)
           my_minute = my_minute + 60 * my_hour
           my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
           my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
           local time_str = string.format("%s%s%s%s", my_minute, TI18N("分"), my_second, TI18N("秒"))
           item.transform:FindChild("TimeText"):GetComponent(Text).text = time_str

           if i % 2 == 0 then
               item.transform:GetComponent(Image).color = ColorHelper.ListItem2
           elseif i % 2 == 1 then
               item.transform:GetComponent(Image).color = ColorHelper.ListItem1
           end
        end

    end

    if #data.dragon_boat_team == 0 then
        print("走的新的流程啦")
        rank_panel_transform.gameObject:SetActive(false)
        self.noRankTips:SetActive(true)
    end

    self.MyRank.text = string.format("%s<color='#c7f9ff'>%s</color>", TI18N("我当前的排名："), data.self_rank)
    self.DescText.text = TI18N("排行榜每<color='#8de92a'>3分钟</color>刷新一次")

end