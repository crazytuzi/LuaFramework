-- -----------------------------------
-- 诸神之战投票总览界面
-- hosr
-- -----------------------------------
GodsWarVoteWindow = GodsWarVoteWindow or BaseClass(BaseWindow)

function GodsWarVoteWindow:__init(model)
	self.model = model
    self.windowId = WindowConfig.WinID.godswar_vote
    -- self.cacheMode = CacheMode.Visible
    self.effectPath = "prefabs/effect/20053.unity3d"
    self.effect = nil
	self.resList = {
		{file = AssetConfig.godswarfinalvote, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
		{file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = self.effectPath, type = AssetType.Dep},
	}
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.round1List = {}
    self.round2List = {}
    self.round3List = {}

    self.light1List = {}
    self.light2List = {}
    self.light3List = {}

    self.tipsTxt = {
        TI18N("1.投票的战队获胜后，玩家将获得银币奖励，奖励将在当轮比赛结束后邮件发放"),
        TI18N("2.奖励将根据比赛双方战队的投票支持率发放"),
        TI18N("3.支持率越低的战队获胜，投票的玩家获得奖励越丰厚"),
        TI18N("4.一轮比赛中越多投票支持的战队胜利，奖励越丰厚"),
    }

    self.firstData = nil
    self.secondData = nil
    self.thirdData = nil

    self.listener = function(data) self:ProtoUpdate(data) end
    self.listenerSucc = function() self:SuccUpdate() end
    self.listenerMatch = function() self:OnShow() end
    self.numberListener = function() self:SetNumber() end
end

function GodsWarVoteWindow:__delete()
    GodsWarManager.Instance.OnUpdateTime:RemoveListener(self.numberListener)
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end

    EventMgr.Instance:RemoveListener(event_name.godswar_vote_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.godswar_vote_success, self.listenerSucc)
    EventMgr.Instance:RemoveListener(event_name.godswar_match_update, self.listenerMatch)
    GodsWarManager.Instance.mySelectData = {}
    self.btnImg.sprite = nil
end

function GodsWarVoteWindow:OnShow()
    GodsWarManager.Instance.OnUpdateTime:RemoveListener(self.numberListener)
    GodsWarManager.Instance.OnUpdateTime:AddListener(self.numberListener)
    GodsWarManager.Instance:Send17933()
    GodsWarManager.Instance.mySelectData = {}
    if self.openArgs == nil then
        self.match_zone = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)
        self.dataList = GodsWarManager.Instance:GetElimintionData(self.match_zone) or {}
    else
        self.match_zone = self.openArgs.zone
        self.dataList = self.openArgs.dataList

        if self.match_zone == nil then
            self.match_zone = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)
        end

        if self.dataList == nil then
            self.dataList = GodsWarManager.Instance:GetElimintionData(self.match_zone) or {}
        end
    end


    self:Update()
    if #self.dataList > 0 then
        GodsWarManager.Instance:Send17930()
    end
end

function GodsWarVoteWindow:OnHide()
end

function GodsWarVoteWindow:ClickVote()
    if GodsWarManager.Instance.voted then
        NoticeManager.Instance:FloatTipsByString(TI18N("已投票"))
        return
    end

    if BackpackManager.Instance:GetItemCount(21719) == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("选票不足，无法投票"))
        return
    end

    local list = {}
    for k,v in pairs(GodsWarManager.Instance.mySelectData) do
        table.insert(list, {tid = v.tid, platform = v.platform, zone_id = v.zone_id})
    end

    if #list == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择投票对象"))
        return
    end

    if not self:CheckOk(#list) then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = TI18N("需要全部投完才能提交投票哦{face_1,32}")
        NoticeManager.Instance:ConfirmTips(data)
        return
    end

    GodsWarManager.Instance:Send17931(self.match_zone, list)
end

function GodsWarVoteWindow:ClickGift()
    TipsManager.Instance:ShowText({gameObject = self.giftBtn, itemData = self.tipsTxt})
end

function GodsWarVoteWindow:Close()
    local count = 0
    if GodsWarManager.Instance.mySelectData ~= nil then
        for k,v in pairs(GodsWarManager.Instance.mySelectData) do
            count = count + 1
        end
    end

    if count > 0 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("您当前的投票尚未提交，界面关闭后将不会保存投票信息")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() self.model:CloseVote() end
        NoticeManager.Instance:ConfirmTips(data)
    else
        self.model:CloseVote()
    end
end

function GodsWarVoteWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarfinalvote))
    self.gameObject.name = "GodsWarVoteWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    local btn = self.transform:Find("Main/Container/Button")
    btn:GetComponent(Button).onClick:AddListener(function() self:ClickVote() end)
    self.btnImg = btn:GetComponent(Image)
    self.btnTxt = btn:Find("Text"):GetComponent(Text)

    self.giftBtn = self.transform:Find("Main/Container/GiftBtn").gameObject
    self.giftBtn:GetComponent(Button).onClick:AddListener(function() self:ClickGift() end)

    self.tips = self.transform:Find("Main/Container/Tips"):GetComponent(Text)
    self.tips.text = TI18N("规则说明:\n1.每次参与投票将消耗<color='#249015'>一叠选票</color>\n2.每次对<color='#249015'>即将开启</color>的比赛进行投票\n3.投票后<color='#249015'>无法修改</color>")

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Main/Container/Slot").gameObject, self.slot.gameObject)
    local itemBase = ItemData.New()
    itemBase:SetBase(BaseUtils.copytab(DataItem.data_get[21719]))
    self.slot:SetAll(itemBase)

    self.finaltxt = self.transform:Find("Main/Container/Right/1/Text"):GetComponent(Text)
    self.transform:Find("Main/Container/Right/1"):GetComponent(Button).onClick:AddListener(function() self:ClickFinal() end)

    self.thirdtxt = self.transform:Find("Main/Container/Right/3/Text"):GetComponent(Text)
    self.transform:Find("Main/Container/Right/3"):GetComponent(Button).onClick:AddListener(function() self:ClickThird() end)

    self.numberImg1 = self.transform:Find("Main/Title/Image1"):GetComponent(Image)
    self.numberImg2 = self.transform:Find("Main/Title/Image2"):GetComponent(Image)

    local right = self.transform:Find("Main/Container/Right")
    for i = 1, 8 do
    	local item = GodsWarFightElimintionItem.New(right:Find("Team1" .. i).gameObject, self)
    	table.insert(self.round1List, item)
    end

    for i = 1, 4 do
    	local item = GodsWarFightElimintionItem.New(right:Find("Team2" .. i).gameObject, self)
        item.index = 20 + i
    	table.insert(self.round2List, item)
    end

    for i = 1, 4 do
    	local item = GodsWarFightElimintionItem.New(right:Find("Team3" .. i).gameObject, self)
        item.index = 30 + i
        table.insert(self.round3List, item)
    end

    local light = right:Find("Light")
    for i = 1, 8 do
    	table.insert(self.light1List, light:Find("Team1" .. i).gameObject)
    end

    for i = 1, 4 do
    	table.insert(self.light2List, light:Find("Team2" .. i).gameObject)
    end

    for i = 1, 4 do
    	table.insert(self.light3List, light:Find("Team3" .. i).gameObject)
    end

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.name = "BtnEffect"
    self.effect.transform:SetParent(btn)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3(1.6, 0.7, 1)
    self.effect.transform.localPosition = Vector3(-51, -13, -400)
    self.effect:SetActive(false)

    EventMgr.Instance:AddListener(event_name.godswar_vote_update, self.listener)
    EventMgr.Instance:AddListener(event_name.godswar_vote_success, self.listenerSucc)
    EventMgr.Instance:AddListener(event_name.godswar_match_update, self.listenerMatch)
    self:OnShow()
end

function GodsWarVoteWindow:SetNumber()
    local number1 = nil
    local number2 = nil
    local isNumberDouble = false

    if tonumber(GodsWarManager.Instance.godTimeNumber) >= 10 then

        local i,j,tag,val = string.find(tostring(GodsWarManager.Instance.godTimeNumber),"(%d)(%d)")
       number1 = tostring(tag)
       number2 = tostring(val)
       isNumberDouble = true

    end


    if isNumberDouble == true then
        self.number1 = self.assetWrapper:GetSprite(AssetConfig.godswarres,"Number" .. number1)
        self.number2 = self.assetWrapper:GetSprite(AssetConfig.godswarres,"Number" .. number2)
    else
        self.number1 = self.assetWrapper:GetSprite(AssetConfig.godswarres,"Number" .. GodsWarManager.Instance.godTimeNumber)
        self.number2 = nil
    end

    if self.number1 == nil then
        self.numberImg1.gameObject:SetActive(false)
    else
        self.numberImg1.gameObject:SetActive(true)
        self.numberImg1:SetNativeSize()
        self.numberImg1.sprite = self.number1
    end

    if self.number2 == nil then
        self.numberImg2.gameObject:SetActive(false)
    else
        self.numberImg2.gameObject:SetActive(true)
        self.numberImg2:SetNativeSize()
        self.numberImg2.sprite = self.number2
    end
end

function GodsWarVoteWindow:Update()
    self:UpdateTools()

    self:FormatList(self.dataList)
    for i,item in ipairs(self.round1List) do
        item:SetData(self.dataList1[i], true)
    end

    for i,item in ipairs(self.round2List) do
        local data = self.dataList2[i]
        item:SetData(data, true)
        if data ~= nil then
            item:ChangeTxt(string.format("<color='#ffff9a'>%s</color>", data.name))
        end
    end

    for i,item in ipairs(self.round3List) do
        if i <= 2 then
            local data = self.dataList4[i]
            item:SetData(data, true)
            if data ~= nil then
                item:ChangeTxt(string.format("<color='#ffff9a'>%s</color>", data.name))
            end
        else
            local data = self.dataList3[i - 2]
            item:SetData(data, true)
            if data ~= nil then
                item:ChangeTxt(string.format("<color='#ffff9a'>%s</color>", data.name))
            end
        end
    end

    if self.firstData ~= nil then
        self.finaltxt.text = string.format("<color='#ffff9a'>%s</color>", self.firstData.name)
    end
    if self.thirdData ~= nil then
        self.thirdtxt.text = string.format("<color='#ffff9a'>%s</color>", self.thirdData.name)
    end

    self:UpdateProgress()
    self:UpdataTxt()
end

function GodsWarVoteWindow:FormatList(list)
    self.dataList1 = {}
    self.dataList2 = {}
    self.dataList3 = {}
    self.dataList4 = {}

    for i,v in ipairs(list) do
        if v.qualification >= GodsWarEumn.Quality.Q8 then
            table.insert(self.dataList1, v)
        end
        if v.qualification >= GodsWarEumn.Quality.Q4 then
            local key = math.ceil(i / 2)
            self.dataList2[key] = v
        end
        if v.qualification >= GodsWarEumn.Quality.ThirdPlace and v.qualification < GodsWarEumn.Quality.ChampionPlace then
            local key = math.ceil(i / 4)
            self.dataList3[key] = v

            if v.qualification == GodsWarEumn.Quality.Third then
                self.thirdData = v
            end
        end
        if v.qualification >= GodsWarEumn.Quality.ChampionPlace then
            local key = math.ceil(i / 4)
            self.dataList4[key] = v

            if v.qualification == GodsWarEumn.Quality.Champion then
                self.firstData = v
            elseif v.qualification == GodsWarEumn.Quality.Second then
                self.secondData = v
            end
        end
    end
end

function GodsWarVoteWindow:UpdateProgress()
    for i,v in ipairs(self.round1List) do
        if v.data == nil then
            self.light1List[i]:SetActive(false)
        else
            if v.data.qualification > GodsWarEumn.Quality.Q8 then
                self.light1List[i]:SetActive(true)
            else
                self.light1List[i]:SetActive(false)
            end
        end
    end

    for i,v in ipairs(self.round2List) do
        if v.data == nil then
            self.light2List[i]:SetActive(false)
        else
            if v.data.qualification >= GodsWarEumn.Quality.ChampionPlace then
                self.light2List[i]:SetActive(true)
            else
                self.light2List[i]:SetActive(false)
            end
        end
    end

    for i,v in ipairs(self.round3List) do
        if v.data == nil then
            self.light3List[i]:SetActive(false)
        else
            if i <= 2 and v.data.qualification == GodsWarEumn.Quality.Champion then
                self.light3List[i]:SetActive(true)
            elseif i >= 3 and v.data.qualification == GodsWarEumn.Quality.Third then
                self.light3List[i]:SetActive(true)
            else
                self.light3List[i]:SetActive(false)
            end
        end
    end
end

function GodsWarVoteWindow:ClickItem(item)
    local index = item.index
    if index == 0 then
        return
    end

    if GodsWarManager.Instance.status == GodsWarEumn.Step.Elimination4
        or GodsWarManager.Instance.status == GodsWarEumn.Step.Semifinal
        or GodsWarManager.Instance.status == GodsWarEumn.Step.Thirdfinal
        or GodsWarManager.Instance.status == GodsWarEumn.Step.Final then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前不在投票阶段"))
    end

    local data = {}
    if index > 20 and index < 30 then
        if GodsWarManager.Instance.status == GodsWarEumn.Step.Elimination4Idel then
            local v = index - 20
            table.insert(data, self.dataList1[v * 2 - 1])
            table.insert(data, self.dataList1[v * 2])
        else
            if item.data ~= nil then
                GodsWarManager.Instance.model:OpenTeam(item.data)
            end
        end
    elseif index > 30 then
        if GodsWarManager.Instance.status == GodsWarEumn.Step.SemifinalIdel then
            local v = index - 30
            table.insert(data, self.dataList2[v * 2 - 1])
            table.insert(data, self.dataList2[v * 2])
        else
            if item.data ~= nil then
                GodsWarManager.Instance.model:OpenTeam(item.data)
            end
        end
    end

    if #data == 0 then
        return
    end

    self.model:OpenVoteDetail({index = index, data = data, callback = function(index, data) self:ChooseUpdate(index, data) end})
end

function GodsWarVoteWindow:ClickFinal()
    if GodsWarManager.Instance.status == GodsWarEumn.Step.FinalIdel then
        local data = {}
        table.insert(data, self.dataList4[1])
        table.insert(data, self.dataList4[2])
        self.model:OpenVoteDetail({index = 1, data = data, callback = function(index, data) self:ChooseUpdate(index, data) end})
    end
end

function GodsWarVoteWindow:ClickThird()
    if GodsWarManager.Instance.status == GodsWarEumn.Step.ThirdfinalIdel then
        local data = {}
        table.insert(data, self.dataList3[1])
        table.insert(data, self.dataList3[2])
        self.model:OpenVoteDetail({index = 3, data = data, callback = function(index, data) self:ChooseUpdate(index, data) end})
    end
end

function GodsWarVoteWindow:ChooseUpdate(index, data)
    if self.gameObject == nil then
        return
    end

    GodsWarManager.Instance.mySelectData[index] = data
    if index == 1 then
        self.finaltxt.text = string.format("<color='#ffff9a'>%s</color>", data.name)
    elseif index == 3 then
        self.thirdtxt.text = string.format("<color='#ffff9a'>%s</color>", data.name)
    elseif index < 30 then
        local v = index - 20
        self.round2List[v]:ChangeTxt(string.format("<color='#ffff9a'>%s</color>", data.name))
    else
        local v = index - 30
        self.round3List[v]:ChangeTxt(string.format("<color='#ffff9a'>%s</color>", data.name))
    end
    local count = 0
    for k,v in pairs(GodsWarManager.Instance.mySelectData) do
        count = count + 1
    end

    local has = false
    if BackpackManager.Instance:GetItemCount(21719) > 0 then
        has = true
    end
    if self:CheckOk(count) and has then
        NoticeManager.Instance:FloatTipsByString(TI18N("选择完成,点击投票"))
        self.effect:SetActive(true)
    end
end

function GodsWarVoteWindow:ProtoUpdate(data)
    local result4 = {}
    local result5 = {}
    for round,match in pairs(GodsWarManager.Instance.voteDic) do
        local dlist = self:GetData(round, match)
        if round <= 5 then
            local list = nil
            if round == 4 then
                list = self.round2List
            elseif round == 5 then
                list = self.round3List
            end
            for i,item in ipairs(list) do
                if item.data ~= nil then
                    local key = string.format("%s_%s_%s", item.data.tid, item.data.platform, item.data.zone_id)
                    local result = match[key]
                    if result ~= nil then
                        -- 猜对
                        if round == 5 then
                            if i < 3 then
                                -- item:SetResult(1)
                                table.insert(result5, item)
                            end
                        else
                            table.insert(result4, item)
                            -- item:SetResult(1)
                        end
                    else
                        -- 猜错
                    end
                else
                    -- 猜了没出结果
                    local dd = dlist[i]
                    if dd ~= nil then
                        item:ChangeTxt(string.format("<color='#ffff9a'>%s</color>", dd.name))
                    end
                end
            end
        elseif round == 6 then
            result4 = {}
            result5 = {}
            if #dlist > 0 then
                self.thirdtxt.text = string.format("<color='#ffff9a'>%s</color>", dlist[1].name)
            end
        elseif round == 7 then
            result4 = {}
            result5 = {}
            if #dlist > 0 then
                self.finaltxt.text = string.format("<color='#ffff9a'>%s</color>", dlist[1].name)
            end
        end
    end

    if #result5 > 0 then
        for i,v in ipairs(result5) do
            v:SetResult(1)
        end
    elseif #result4 > 0 then
        for i,v in ipairs(result4) do
            v:SetResult(1)
        end
    end

    self:UpdateBtn()
end

function GodsWarVoteWindow:UpdateBtn()
    self.effect:SetActive(false)
    if GodsWarManager.Instance.voted then
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.btnTxt.text = TI18N("已投票")
    else
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.btnTxt.text = TI18N("投票")
    end
end

function GodsWarVoteWindow:UpdateTools()
    self.slot:SetNum(BackpackManager.Instance:GetItemCount(21719), 1)
end

function GodsWarVoteWindow:GetData(round, match)
    local list = {}
    for i,v1 in ipairs(self.dataList1) do
        for key,v2 in pairs(match) do
            if v1.tid == v2.tid and v1.platform == v2.platform and v1.zone_id == v2.zone_id then
                local index = i
                if round == 4 then
                    index = math.ceil(i / 2)
                elseif round == 5 then
                    index = math.ceil(i / 4)
                else
                    index = 1
                end
                list[index] = v1
            end
        end
    end
    return list
end

function GodsWarVoteWindow:UpdataTxt()
    if GodsWarManager.Instance.status == GodsWarEumn.Step.Elimination4Idel then
        for i,item in ipairs(self.round2List) do
            item:ChangeTxt(TI18N("<color='#ffff9a'>点击竞猜</color>"))
        end
    elseif GodsWarManager.Instance.status == GodsWarEumn.Step.SemifinalIdel then
        for i,item in ipairs(self.round3List) do
            if i < 3 then
                item:ChangeTxt(TI18N("<color='#ffff9a'>点击竞猜</color>"))
            end
        end
    elseif GodsWarManager.Instance.status == GodsWarEumn.Step.ThirdfinalIdel then
        self.thirdtxt.text = TI18N("<color='#ffff9a'>点击竞猜</color>")
    elseif GodsWarManager.Instance.status == GodsWarEumn.Step.FinalIdel then
        self.finaltxt.text = TI18N("<color='#ffff9a'>点击竞猜</color>")
    end
end

function GodsWarVoteWindow:SuccUpdate()
    GodsWarManager.Instance.mySelectData = {}
    self:UpdateBtn()
    self:UpdateTools()
end

function GodsWarVoteWindow:CheckOk(count)
    if GodsWarManager.Instance.status == GodsWarEumn.Step.Elimination4Idel then
        if count == 4 then
            return true
        end
    elseif GodsWarManager.Instance.status == GodsWarEumn.Step.SemifinalIdel then
        if count == 2 then
            return true
        end
    else
        if count == 1 then
            return true
        end
    end
    return false
end
