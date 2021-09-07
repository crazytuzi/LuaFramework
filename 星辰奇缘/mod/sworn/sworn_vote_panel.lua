-- @author 黄耀聪
-- @date 2016年10月22日

-- 结拜投票结果

SwornVotePanel = SwornVotePanel or BaseClass(BasePanel)

function SwornVotePanel:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.name = "SwornVotePanel"

    self.assetWrapper = assetWrapper

    self.rankResultList = {}
    self.memberList = {}
    self.statusListener = function() self:ReloadTeam() self:ReloadStatus() end

    self.selectIndex = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornVotePanel:__delete()
    self.OnHideEvent:Fire()
end

function SwornVotePanel:InitPanel()
    local t = self.gameObject.transform
    self.transform = t

    local result = t:Find("Result")
    for i=1,5 do
        local tab = {}
        tab.transform = result:GetChild(i - 1)
        tab.transform:Find("Mask"):GetComponent(Image).color = Color(1, 1, 1, 5/255)
        tab.headImage = tab.transform:Find("Mask/Head"):GetComponent(Image)
        tab.gameObject = tab.transform.gameObject
        tab.select = tab.transform:Find("Select").gameObject
        tab.rankHonorText = tab.transform:Find("Rank/Text"):GetComponent(Text)
        tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        self.rankResultList[i] = tab
    end
    self.resultContainer = result

    local list = t:Find("List")
    for i=1,5 do
        local tab = {}
        tab.transform = list:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        tab.headImage = tab.transform:Find("Head/Image"):GetComponent(Image)
        -- tab.btn = tab.gameObject:GetComponent(Button)
        tab.select = tab.transform:Find("Select").gameObject
        tab.button = tab.transform:Find("Button"):GetComponent(Button)
        tab.buttonImage = tab.button.gameObject:GetComponent(Image)
        tab.buttonText = tab.transform:Find("Button/Text"):GetComponent(Text)

        tab.select:SetActive(false)

        local j = i
        tab.button.onClick:AddListener(function() self:OnClick(j) end)
        self.memberList[i] = tab
    end
    self.memberContainer = list
    self.listTitleText = t:Find("Title/Text"):GetComponent(Text)
    self.listTimeText = t:Find("Title/Time"):GetComponent(Text)
end

function SwornVotePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornVotePanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.sworn_status_change, self.statusListener)

    self:ReloadTeam()
    self:ReloadStatus()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)
end

function SwornVotePanel:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
end

function SwornVotePanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.sworn_status_change, self.statusListener)
end

function SwornVotePanel:ReloadStatus()
    local model = self.model
    local swornData = self.model.swornData or {}
    local teamMgr = TeamManager.Instance

    local teamNum = #teamMgr.memberOrderList
    local memberData = swornData.members or {}

    for i,v in ipairs(self.rankResultList) do
        if teamMgr.memberOrderList[i] ~= nil then
            -- v.gameObject:SetActive(true)
            if i == model.votePos then
                v.select:SetActive(true)
            else
                v.select:SetActive(false)
            end
            local member = memberData[i]
            if member ~= nil then
                v.nameText.text = member.name
                v.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, member.classes .. "_" .. member.sex)
                v.rankHonorText.text = model.normalList[i]
            else
                v.rankHonorText.text = model.normalList[i]
                v.headImage.sprite = self.assetWrapper:GetSprite(AssetConfig.sworn_textures, "Unknow")
                v.nameText.text = TI18N("尚未投票")
            end
        else
            v.select:SetActive(false)
            v.headImage.sprite = self.assetWrapper:GetSprite(AssetConfig.sworn_textures, "Unknow")
            v.rankHonorText.text = ""
            v.nameText.text = ""
        end
    end
    self.rankResultList[model.votePos].rankHonorText.text = TI18N("<color='#00ff00'>投票中</color>")
    self.listTitleText.text = string.format(TI18N("投票选出<color='#00ff00'>%s</color>"), model.normalList[model.votePos])
end

function SwornVotePanel:ReloadTeam()
    local model = self.model
    local teamMgr = TeamManager.Instance
    local swornData = model.swornData or {}
    local voteData = swornData.votes or {}

    -- print("self.model.voteUid = " .. tostring(self.model.voteUid))

    local hasVote = false
    for i,tab in ipairs(self.memberList) do
        local member = teamMgr.memberTab[teamMgr.memberOrderList[i]]
        tab.data = member
        if member ~= nil then
            tab.nameText.text = member.name
            tab.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, member.classes .. "_" .. member.sex)
            tab.button.gameObject:SetActive(true)
            tab.button.onClick:RemoveAllListeners()
            local uid = BaseUtils.get_unique_roleid(member.rid, member.zone_id, member.platform)
            local j = i
            if model.menberTab[uid] ~= nil then
                tab.button.onClick:AddListener(function() self:NoVote(model.menberTab[uid]) end)
                tab.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                tab.buttonText.text = model.normalList[model.menberTab[uid]]
            else
                if self.model.voteUid ~= nil then
                    if uid == self.model.voteUid then
                        tab.button.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("已投票")) end)
                        tab.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                        tab.buttonText.text = TI18N("已投票")
                        hasVote = true
                    else
                        tab.button.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("等待其他人投票")) end)
                        tab.buttonText.text = TI18N("投票")
                        tab.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                    end
                else
                    tab.button.onClick:AddListener(function() self:DoVote(j) end)
                    tab.buttonText.text = TI18N("投票")
                    tab.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                end
            end
        else
            tab.headImage.sprite = self.assetWrapper:GetSprite(AssetConfig.sworn_textures, "Unknow")
            tab.nameText.text = ""
            tab.button.gameObject:SetActive(false)
        end
    end
end

function SwornVotePanel:NoVote(i)
    NoticeManager.Instance:FloatTipsByString(string.format(TI18N("TA已经是<color='#00ff00'>%s</color>了"), self.model.normalList[i]))
end

function SwornVotePanel:DoVote(i)
    if i == nil then
        return
    end
    local teamData = self.memberList[i].data
    if teamData == nil then return end

    local roleData = RoleManager.Instance.RoleData
    local confirmData = NoticeConfirmData.New()
    if teamData.rid == roleData.id and teamData.platform == roleData.platform and roleData.zone_id == teamData.zone_id then
        confirmData.content = TI18N("确定要为自己投出你宝贵的一票吗？")
    else
        confirmData.content = string.format(TI18N("确定要为<color='#00ff00'>%s</color>投出你宝贵的一票吗？"), teamData.name)
    end
    confirmData.sureCallback = function()
        self.model.voteUid = BaseUtils.get_unique_roleid(teamData.rid, teamData.zone_id, teamData.platform)
        SwornManager.Instance:send17701(teamData.rid, teamData.platform, teamData.zone_id, self.model.votePos)
    end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function SwornVotePanel:OnTick()
    local swornData = SwornManager.Instance.model.swornData or {}
    local timeout = swornData.timeout or BaseUtils.BASE_TIME

    local m = nil
    local s = nil
    local _ = nil
    
    local t = timeout - BaseUtils.BASE_TIME
    if t < 0 then t = 0 end
    _,_,m,s = BaseUtils.time_gap_to_timer(t)
    if m < 10 then
        if s < 10 then
            self.listTimeText.text = string.format("0%s:0%s", tostring(m), tostring(s))
        else
            self.listTimeText.text = string.format("0%s:%s", tostring(m), tostring(s))
        end
    else
        if s < 10 then
            self.listTimeText.text = string.format("%s:0%s", tostring(m), tostring(s))
        else
            self.listTimeText.text = string.format("%s:%s", tostring(m), tostring(s))
        end
    end
end

function SwornVotePanel:OnClick(i)
    if self.selectIndex ~= nil then
        self.memberList[self.selectIndex].select:SetActive(false)
    end
    self.selectIndex = i
    local member = self.memberList[i]
    member.select:SetActive(true)
end
