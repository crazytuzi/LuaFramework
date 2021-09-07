UnlimitedChallengePanel = UnlimitedChallengePanel or BaseClass(BasePanel)


function UnlimitedChallengePanel:__init(model)
    self.model = model
    self.Mgr = UnlimitedChallengeManager.Instance
    self.btnEffect = "prefabs/effect/20053.unity3d"
    self.resList = {
        {file = AssetConfig.unlimited_panel, type = AssetType.Main}
        ,{file = self.btnEffect, type = AssetType.Main}
        ,{file  =  AssetConfig.unlimited_texture, type  =  AssetType.Dep}
        ,{file = AssetConfig.bigatlas_taskBg, type = AssetType.Main}
        ,{file  =  AssetConfig.maxnumber_13, type  =  AssetType.Dep}
    }
    self.readystatus = 0
    self.leaderCanGo = false
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.teamupdatefunc = function()
        self:OnTeamUpdate()
    end
    self.begin_fightCall = function()
        self.model:CloseMainPanel()
    end
    self.updateslot = function()
        self:UpdateSkillSet()
    end
    self.time = 60
    self.autoTimer = nil
    self.MemberTimer = {}

    self.imgLoader = {}
    self.SkillSetIcon = {}
    self.MemberList = {}
end

function UnlimitedChallengePanel:__delete()
    for k,v in pairs(self.imgLoader) do
        v:DeleteMe()
    end
    self.imgLoader = {}

    for k,v in pairs(self.SkillSetIcon) do
        v.Icon:DeleteMe()
    end
    self.SkillSetIcon = {}

    for k,v in pairs(self.MemberList) do
        v.Skill1:DeleteMe()
        v.Skill2:DeleteMe()
    end
    self.MemberList = {}

    for i=1,5 do
        self:StopMemberCountDown(i)
    end
    self:StopCountDown()
    self.Mgr.UnlimitedChallengeUpdate:RemoveListener(self.updateslot)
    EventMgr.Instance:RemoveListener(event_name.team_info_update, self.teamupdatefunc)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.begin_fightCall)

end
function UnlimitedChallengePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.unlimited_panel))
    UIUtils.AddUIChild(ChatManager.Instance.model.chatCanvas, self.gameObject)
    self.gameObject.name = "UnlimitedChallengePanel"
    self.transform = self.gameObject.transform
    self.transform:SetSiblingIndex(3)

    UIUtils.AddBigbg(self.transform:Find("Main/Right/BgImage"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_taskBg)))
    self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
        self:OnClose()
    end)
    self.MemberListCon = self.transform:Find("Main/Left/MaskScroll/ListCon")
    self.MemberList = {}
    for i=1,5 do
        local goname = "Item"..tostring(i)
        local gotransform = self.MemberListCon:Find(goname)
        self.MemberList[i] = {}
        self.MemberList[i].transform = gotransform
        self.MemberList[i].Name = gotransform:Find("Name"):GetComponent(Text)
        self.MemberList[i].LevClass = gotransform:Find("LevClass"):GetComponent(Text)
        self.MemberList[i].Ready = gotransform:Find("Ready"):GetComponent(Text)
        self.MemberList[i].HeadImg = gotransform:Find("Head/Image"):GetComponent(Image)
        self.MemberList[i].Skill1 = SingleIconLoader.New(gotransform:Find("skillCon1/skill1").gameObject)
        self.MemberList[i].Skill1btn = gotransform:Find("skillCon1"):GetComponent(Button)
        self.MemberList[i].Skill2 = SingleIconLoader.New(gotransform:Find("skillCon1/skill2").gameObject)
        self.MemberList[i].Skill2btn = gotransform:Find("skillCon2"):GetComponent(Button)
        self.MemberList[i].bubble = self.transform:Find("Main/Left/Bubble"..tostring(i))
        self.MemberList[i].bubbleText = self.MemberList[i].bubble:Find("Text"):GetComponent(Text)
        self.MemberList[i].Ext = MsgItemExt.New(self.MemberList[i].bubbleText, 159.65, 19, 29)
    end

    self.transform:Find("Main/Right/MoreButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnClickRank()
    end)
    self.NumCon = self.transform:Find("Main/Right/NumCon")
    self.num1 = self.NumCon:Find("num1"):GetComponent(Image)
    self.num2 = self.NumCon:Find("num2"):GetComponent(Image)
    self.transform:Find("Main/Right/InfoButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnClickInfo()
    end)

    self.rewardCon = self.transform:Find("Main/Right/MaskScroll/Page")

    self.SkillSetIcon = {}
    for i=1, 2 do
        self.SkillSetIcon[i] = {}
        self.SkillSetIcon[i].transform = self.transform:Find("Main/Right/Skill"..tostring(i))
        self.SkillSetIcon[i].Icon = SingleIconLoader.New(self.SkillSetIcon[i].transform:Find("Icon").gameObject)
        self.SkillSetIcon[i].Add = self.SkillSetIcon[i].transform:Find("Add").gameObject
        self.SkillSetIcon[i].Reset = self.SkillSetIcon[i].transform:Find("Reset").gameObject
        self.SkillSetIcon[i].Red = self.SkillSetIcon[i].transform:Find("Red").gameObject
        self.SkillSetIcon[i].Red:SetActive(PlayerPrefs.GetString("Unlimit") ~= "1")
        self.SkillSetIcon[i].transform:GetComponent(Button).onClick:AddListener(function()
            PlayerPrefs.SetString("Unlimit", "1")
            self.Mgr.UnlimitedChallengeFightTimesUpdate:Fire()
            self:OpenSkillSet(i)
        end)
    end
    self.StartButton = self.transform:Find("Main/Right/StartButton"):GetComponent(Button)
    self.ReadyButton = self.transform:Find("Main/Right/ReadyButton"):GetComponent(Button)
    self.ReadyText = self.transform:Find("Main/Right/ReadyButton/Text"):GetComponent(Text)
    self.ReadyImage = self.transform:Find("Main/Right/ReadyButton"):GetComponent(Image)
    self.StartButton.onClick:AddListener(function()
        self:OnStart()
    end)
    self.ReadyButton.onClick:AddListener(function()
        self:OnReady()
    end)
    self.transform:Find("ShowButton"):GetComponent(Button).onClick:AddListener(function()
        self.transform:SetSiblingIndex(3)
        ChatManager.Instance.model:ShowChatWindow({2})
    end)

    self.StartEffect = GameObject.Instantiate(self:GetPrefab(self.btnEffect))
    self.StartEffect.transform:SetParent(self.StartButton.gameObject.transform)
    self.StartEffect.transform.localScale = Vector3(2, 0.7, 1)
    self.StartEffect.transform.localPosition = Vector3(-61, -16, -1000)
    Utils.ChangeLayersRecursively(self.StartEffect.transform, "UI")
    self.ReadyEffect = GameObject.Instantiate(self:GetPrefab(self.btnEffect))
    self.ReadyEffect.transform:SetParent(self.ReadyButton.gameObject.transform)
    self.ReadyEffect.transform.localScale = Vector3(2, 0.7, 1)
    self.ReadyEffect.transform.localPosition = Vector3(-61, -16, -1000)
    Utils.ChangeLayersRecursively(self.ReadyEffect.transform, "UI")

    self:UpdateMemberList()
    -- self:UpdateRound(12)
    self:InitReward()
    self:UpdateSkillSet()
    EventMgr.Instance:AddListener(event_name.team_info_update, self.teamupdatefunc)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.begin_fightCall)
    self.Mgr.UnlimitedChallengeUpdate:AddListener(self.updateslot)
    if self.Mgr.fight_times > 0 and self.Mgr.best_wave > 0 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("今日已领<color='#ffff00'>%s波</color>奖励，重置奖励后可重新领取"), tostring(self.Mgr.best_wave))
        data.sureLabel = TI18N("重置奖励")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 60
        data.sureCallback = function()
                UnlimitedChallengeManager.Instance:Require17216()
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
end
function UnlimitedChallengePanel:OnOpen()

end

function UnlimitedChallengePanel:OnHide()

end

function UnlimitedChallengePanel:UpdateMemberList()
    if self.MemberList == nil then
        return
    end
    local data = self.Mgr.mateData
    if data[1] ~= nil and data[1].is_prepare ~= 2 then
        -- 第一不是队长倒叙
        local temp = {}
        for i= #data, 1, -1 do
            table.insert(temp, data[i])
        end
        data = temp
    end
    local allready = true
    for i=1,5 do
        local Member = data[i]
        if Member ~= nil then
            local isself = (RoleManager.Instance.RoleData.id == Member.rid and RoleManager.Instance.RoleData.platform == Member.platform and RoleManager.Instance.RoleData.zone_id == Member.zone_id)
            self.MemberList[i].Name.text = Member.name
            self.MemberList[i].uid = BaseUtils.Key(Member.rid, Member.platform, Member.zone_id)
            self.MemberList[i].LevClass.text = string.format("Lv.%s %s", Member.lev, KvData.classes_name[Member.classes])
            if Member.is_prepare == 1 then
                self.MemberList[i].Ready.text = TI18N("已准备")
                self:StopMemberCountDown(i)
            elseif Member.is_prepare == 0 then
                allready = false
                -- self.MemberList[i].Ready.text = TI18N("<color='#ffff00'>准备中</color>")
                self:StartMemberCountDown(i)
            elseif Member.is_prepare == 2 then
                self.MemberList[i].Ready.text = TI18N("<color='#ffff00'>队长</color>")
            end
            if isself then
                self:UpdateRound(Member.best_wave)
                if Member.is_prepare ~= 2 then
                    self.StartButton.gameObject:SetActive(false)
                    self.ReadyButton.gameObject:SetActive(true)
                    if Member.is_prepare == 0 then
                        self.ReadyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                        self.ReadyText.text = TI18N("准备完毕")
                    else
                        self.ReadyImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                        self.ReadyText.text = TI18N("取消准备")
                    end
                    self.readystatus = Member.is_prepare
                end
            end
            self.MemberList[i].HeadImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, Member.classes.."_"..Member.sex)
            local skilldata1 = nil
            local skilldata2 = nil
            for i,v in ipairs(Member.choose_skills) do
                if v.index == 1 then
                    skilldata1 = v.skill_id
                elseif v.index == 2 then
                    skilldata2 = v.skill_id
                end
            end

            local skill_Ok = true
            self.MemberList[i].Skill1btn.onClick:RemoveAllListeners()
            self.MemberList[i].Skill2btn.onClick:RemoveAllListeners()
            if skilldata1 ~= nil then
                BaseUtils.dump(Member)
                local endlessskill = DataSkill.data_endless_challenge[skilldata1]
                -- self.MemberList[i].Skill1.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_endless, endlessskill.icon)
                self.MemberList[i].Skill1:SetSprite(SingleIconType.SkillIcon, endlessskill.icon)
                self.MemberList[i].Skill1.gameObject:SetActive(true)
                self.MemberList[i].Skill1btn.onClick:AddListener(function()
                    local tipsinfo = {gameObject = self.MemberList[i].Skill1.gameObject, skillData = endlessskill, type = Skilltype.endlessskill}
                    TipsManager.Instance:ShowSkill(tipsinfo)
                end)
            else
                skill_Ok = false
                self.MemberList[i].Skill1.gameObject:SetActive(false)
            end
            if skilldata2 ~= nil then
                local endlessskill = DataSkill.data_endless_challenge[skilldata2]
                -- self.MemberList[i].Skill2.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_endless, endlessskill.icon)
                self.MemberList[i].Skill2:SetSprite(SingleIconType.SkillIcon, endlessskill.icon)
                self.MemberList[i].Skill2.gameObject:SetActive(true)
                self.MemberList[i].Skill2btn.onClick:AddListener(function()
                    local tipsinfo = {gameObject = self.MemberList[i].Skill2.gameObject, skillData = endlessskill, type = Skilltype.endlessskill}
                    TipsManager.Instance:ShowSkill(tipsinfo)
                end)
            else
                skill_Ok = false
                self.MemberList[i].Skill2.gameObject:SetActive(false)
            end
            if isself then
                self.ReadyEffect:SetActive(skill_Ok and self.readystatus == 0)
            end

            self.MemberList[i].transform.gameObject:SetActive(true)
        else
            self.MemberList[i].transform.gameObject:SetActive(false)
        end
    end
    self.leaderCanGo = allready
    self.StartEffect:SetActive(allready)
    if self.readystatus == 0 and self.autoTimer == nil then
        self:StartCountDown()
    elseif self.readystatus == 1 and self.autoTimer ~= nil then
        self:StopCountDown()
    end
end

function UnlimitedChallengePanel:UpdateRound(num)
    local first = math.floor(num/10)
    local second = num%10
    if first ~= 0 then
        self.num1.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_13, "Num13_"..tostring(first))
        self.num2.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_13, "Num13_"..tostring(second))
        self.num1:SetNativeSize()
        self.num2:SetNativeSize()
        self.num1.transform.anchoredPosition = Vector2(-self.num1.transform.sizeDelta.x/2, 0)
        self.num2.transform.anchoredPosition = Vector2(self.num2.transform.sizeDelta.x/2, 0)
        self.num1.gameObject:SetActive(true)
        self.num2.gameObject:SetActive(true)
    else
        self.num1.gameObject:SetActive(false)
        self.num2.sprite = self.assetWrapper:GetTextures(AssetConfig.maxnumber_13, "Num13_"..tostring(second))
        self.num2:SetNativeSize()
        self.num2.transform.anchoredPosition = Vector2.zero
        self.num2.gameObject:SetActive(true)
    end
end

function UnlimitedChallengePanel:UpdateSkillSet()
    local skillchose = self.Mgr.skillData.choose_skills
    local temp = {}
    for k,v in pairs(skillchose) do
        temp[v.index] = v.skill_id
    end
    for i=1, 2 do
        self.SkillSetIcon[i].Red:SetActive(PlayerPrefs.GetString("Unlimit") ~= "1")
        if temp[i] ~= nil then
            local icon = DataSkill.data_endless_challenge[temp[i]].icon
            -- self.SkillSetIcon[i].Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_endless, icon)
            self.SkillSetIcon[i].Icon:SetSprite(SingleIconType.SkillIcon, icon)
            self.SkillSetIcon[i].Icon.gameObject:SetActive(true)

            self.SkillSetIcon[i].Add:SetActive(false)
            self.SkillSetIcon[i].Reset:SetActive(true)

        else
            self.SkillSetIcon[i].Icon.sprite = nil
            self.SkillSetIcon[i].Icon.gameObject:SetActive(false)

            self.SkillSetIcon[i].Add:SetActive(true)
            self.SkillSetIcon[i].Reset:SetActive(false)
        end
    end
end

function UnlimitedChallengePanel:OnClickRank()
    self.model:OpenRankPanel()
end

function UnlimitedChallengePanel:OnClickInfo()
    local go = self.transform:Find("Main/Right/InfoButton").gameObject
    TipsManager.Instance:ShowText({gameObject = go, itemData = {
            TI18N("1、每波次怪物每日可获<color='#ffff00'>一次</color>奖励"),
            TI18N("2、<color='#ffff00'>爵位等级</color>越高，可获得越稀有的道具"),
            TI18N("3、每日23：00，根据挑战排行发放额外奖励"),
            TI18N("4、无尽挑战中药品使用数量限制为<color='$ffff00'>3</color>个"),
            }})
end

function UnlimitedChallengePanel:OnStart()
    if self.leaderCanGo then
        self.Mgr:Require17202()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请等待队友完成准备"))
        ChatManager.Instance:Send10400(MsgEumn.ChatChannel.Team, TI18N("马上开始战斗了，请大家做好准备！{face_1, 7}"))
    end
end

function UnlimitedChallengePanel:OnReady()
    if self.readystatus == 0 then
        self.Mgr:Require17204(1)
        -- NoticeManager.Instance:FloatTipsByString(TI18N("准备完成，等待队长开启战斗"))
        ChatManager.Instance:Send10400(MsgEumn.ChatChannel.Team, TI18N("准备就绪！{face_1, 1}"))
    else
        -- NoticeManager.Instance:FloatTipsByString(TI18N("准备已取消，请尽快做好准备"))
        ChatManager.Instance:Send10400(MsgEumn.ChatChannel.Team, TI18N("等等，我还没准备好{face_1, 48}"))
        self.Mgr:Require17204(0)
    end
end

function UnlimitedChallengePanel:OpenSkillSet(index)
    self.model:OpenSkillSetPanel(index)
end

function UnlimitedChallengePanel:InitReward()
    local data = DataEndlessChallenge.data_wave[1].cost
    for i=1, self.rewardCon.childCount do
        self.rewardCon:Find(tostring(i)).gameObject:SetActive(false)
    end
    for i,v in ipairs(data) do
        local Item = self.rewardCon:Find(tostring(i))
        if Item == nil then
            Item = GameObject.Instantiate(self.rewardCon:Find("1").gameObject)
            Item.name = tostring(i)
            Item.transform:SetParent(self.rewardCon)
            Item.transform.localScale = Vector3.one
            Item.transform.anchoredPosition = Vector2((i-1)*70, 0)
            Item = Item.transform
        end
        local baseData = DataItem.data_get[v[1]]
        local btn = Item:GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
            TipsManager.Instance:ShowItem({gameObject = Item.gameObject, itemData = baseData})
        end)

        if self.imgLoader[i] == nil then
            local go = Item:Find("Icon").gameObject
            self.imgLoader[i] = SingleIconLoader.New(go)
        end
        self.imgLoader[i]:SetSprite(SingleIconType.Item, baseData.icon)

        Item:Find("Icon").gameObject:SetActive(true)
        Item.gameObject:SetActive(true)
    end
    self.rewardCon.sizeDelta = Vector2(#data*70, 60)
end

function UnlimitedChallengePanel:ShowMsg(rid, platform, zone_id, text, BubbleID)
    if self.MemberList == nil then
        return
    end
    local data = self.Mgr.mateData
    local uid = BaseUtils.Key(rid, platform, zone_id)
    for i,member in ipairs(self.MemberList) do
        if member.uid == uid then
            self.MemberList[i].Ext:SetData(text)
            self.MemberList[i].bubble.gameObject:SetActive(true)
            local size = self.MemberList[i].bubbleText.transform.sizeDelta
            self.MemberList[i].bubble.sizeDelta = Vector2(size.x+33, size.y+16)
            local ID = Time.time
            self.MemberList[i].bubbleID = ID
            LuaTimer.Add(3500, function()
                if self.MemberList ~= nil and BaseUtils.isnull(self.MemberList[i].bubble) == false and self.MemberList[i].bubbleID == ID then
                    self.MemberList[i].bubble.gameObject:SetActive(false)
                end
            end)
            break
        end
    end
end

function UnlimitedChallengePanel:OnClose()
    if TeamManager.Instance:IsSelfCaptin() then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("正在准备中，关闭界面后队员需要重新准备")
        data.sureLabel = TI18N("关闭")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            self.Mgr:Require17204(0)
            self.model:CloseMainPanel()
        end
        data.cancelCallback = function()
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("正在准备中，关闭界面将自动离队")
        data.sureLabel = TI18N("离队")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            -- self.Mgr:Require17204(0)
            self.model:CloseMainPanel()
            TeamManager.Instance:Send11708()
        end
        data.cancelCallback = function()
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function UnlimitedChallengePanel:OnTeamUpdate()
    if RoleManager.Instance.RoleData.event == 29 then
        if TeamManager.Instance:IsSelfCaptin() and TeamManager.Instance:MemberCount() < 3 then
            self.Mgr:Require17204(0)
            self.model:CloseMainPanel()
            NoticeManager.Instance:FloatTipsByString(TI18N("当前队伍人数不足，请<color='#ffff00'>重新招募</color>队员"))
        elseif TeamManager.Instance:MemberCount() < 5 then
            if TeamManager.Instance:IsSelfCaptin() then
                self.Mgr:Require17211()
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("当前队伍未满，建议退出准备<color='#ffff00'>重新招募</color>队员")
                data.sureLabel = TI18N("确定")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    self.Mgr:Require17204(0)
                    self.model:CloseMainPanel()
                    self.Mgr:AutoMatch()
                end
                data.cancelCallback = function()
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        end
    end
end

function UnlimitedChallengePanel:StartCountDown()
    self.time = 60
    self.autoTimer = LuaTimer.Add(0, 1000, function()
        self.time = self.time - 1
        if self.time <= 1 then
            self:StopCountDown()
            if self.readystatus == 0 then
                self.Mgr:Require17204(1)
            end
        end
        self.ReadyText.text = string.format(TI18N("准备(%s)"), self.time)
    end)
end

function UnlimitedChallengePanel:StopCountDown()
    if self.autoTimer ~= nil then
        LuaTimer.Delete(self.autoTimer)
        self.autoTimer = nil
        self.ReadyText.text = TI18N("取消准备")
    end
end

function UnlimitedChallengePanel:StartMemberCountDown(i)
    if self.MemberTimer[i] == nil then
        self.MemberTimer[i] = {}
        self.MemberTimer[i].time = 60
        self.MemberTimer[i].timer = LuaTimer.Add(0, 1000, function()
            self.MemberTimer[i].time = self.MemberTimer[i].time - 1
            if self.MemberTimer[i].time <= 1 or self.MemberList == nil or self.MemberList[i] == nil or self.MemberList[i].Ready == nil then
                self.MemberList[i].Ready.text = TI18N("<color='#ffff00'>准备中</color>")
                self:StopMemberCountDown(i)
                return
            end
            -- if not BaseUtils.isnull(self.MemberList[i].Ready) then
                self.MemberList[i].Ready.text = string.format(TI18N("<color='#ffff00'>准备中(%ss)</color>"), self.MemberTimer[i].time)
            -- end
        end)
    end
end


function UnlimitedChallengePanel:StopMemberCountDown(i)
    if self.MemberTimer[i] ~= nil then
        if self.MemberTimer[i].timer ~= nil then
            LuaTimer.Delete(self.MemberTimer[i].timer)
            self.MemberTimer[i] = nil
        end
    end
end