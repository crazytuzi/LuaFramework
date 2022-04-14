                                             ---
--- Created by  Administrator
--- DateTime: 2019/4/30 10:50
---
ArenaPanel = ArenaPanel or class("ArenaPanel", BaseItem)
local this = ArenaPanel

function ArenaPanel:ctor(parent_node, parent_panel)
    self.abName = "arena";
    self.image_ab = "arena_image";
    self.assetName = "ArenaPanel"
    self.layer = "UI"
    self.events = {}
    self.gloEvents = {}
    self.model = ArenaModel:GetInstance()
    self.roleList = {}
    self.creepModelList = {}
    self.roloIndex = 0
    self.isFirst = true
    self.isRefTime = false
    self.refTimer = 5
    ArenaPanel.super.Load(self)
    self.main_role_data = RoleInfoModel.GetInstance():GetMainRoleData()
    self.model.isOpenArenaPanel = true
    local uid = tostring(self.main_role_data.uid)
    self.skinKey = "ArenaSkin" .. uid
    self.timesKey = "ArenaTimes" .. uid
    self.wingKey = "ArenaWing" .. uid
end

function ArenaPanel:dctor()
    self.model:RemoveTabListener(self.events)

    GlobalEvent:RemoveTabListener(self.gloEvents)
    self.model.isOpenArenaPanel = false
    for i, v in pairs(self.roleList) do
        v:destroy()
    end
    self.roleList = {}

    for i, v in pairs(self.creepModelList) do
        v:destroy()
    end
    self.creepModelList = {}

    if self.rewardBtn_red then
        self.rewardBtn_red:destroy()
        self.rewardBtn_red = nil
    end

    if self.rankBtn_red then
        self.rankBtn_red:destroy()
        self.rankBtn_red = nil
    end

    if self.bigGodBtn_red then
        self.bigGodBtn_red:destroy()
        self.bigGodBtn_red = nil
    end

    if self.challenge_red then
        self.challenge_red:destroy()
        self.challenge_red = nil
    end

    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
end

function ArenaPanel:OnEnable()
    self.model.isOpenArenaPanel = true
    if self.isFirst == false then
        ArenaController:GetInstance():RequstArenaInfo()
    end
    --if self.is_loaded then
    --    ArenaController:GetInstance():RequstArenaInfo()
    --end
end

function ArenaPanel:OnDisable()
    self.model.isOpenArenaPanel = false
end

function ArenaPanel:LoadCallBack()
    self.nodes = {
        "down/shopBtn", "down/rankRewardBtn", "down/rewardShowBtn", "down/money/moneyNum", "down/myObj/myRank",
        "refreshBtn", "down/challengeBtn", "bigGodBtn", "leftTop/wingBox", "RoleParent", "leftTop/timesObj/rTimes",
        "leftTop/wenhBtn", "leftTop/timesBox", "down/myObj/powerObj/power", "down/myObj/upBtn", "leftTop/addBtn",
        "ArenaRoleItem", "creepModelCon", "down/myObj/headBG/mask/headImg", "leftTop/skinBox", "leftTop/timesObj",
		"down/money/moneyIcon",
    }
    self:GetChildren(self.nodes)
    self.myRank = GetText(self.myRank)
    self.power = GetText(self.power)
    self.rTimes = GetText(self.rTimes)
    self.timesBox = GetToggle(self.timesBox)
    self.wingBox = GetToggle(self.wingBox)
    self.moneyNum = GetText(self.moneyNum)
    self.headImg = GetImage(self.headImg)
    self.skinBox = GetToggle(self.skinBox)
	self.moneyIcon = GetImage(self.moneyIcon)
    --  self:SetTimesBox(false)
    --  self:SetWingBox(false)
    self:InitUI()
    self:AddEvent()
    --self.isFirst = false
    self.rewardBtn_red = RedDot(self.rewardShowBtn, nil, RedDot.RedDotType.Nor)
    self.rewardBtn_red:SetPosition(25, 28)
    --  self.rewardBtn_red:SetRedDotParam(true)

    self.rankBtn_red = RedDot(self.rankRewardBtn, nil, RedDot.RedDotType.Nor)
    self.rankBtn_red:SetPosition(25, 28)
    --  self.rankBtn_red:SetRedDotParam(true)

    self.bigGodBtn_red = RedDot(self.bigGodBtn, nil, RedDot.RedDotType.Nor)
    self.bigGodBtn_red:SetPosition(25, 28)

    self.challenge_red = RedDot(self.challengeBtn, nil, RedDot.RedDotType.Nor)
    self.challenge_red:SetPosition(66, 20)
    --  self.bigGodBtn_red:SetRedDotParam(true)
    ArenaController:GetInstance():RequstArenaInfo()


end

function ArenaPanel:CheckRedPoint()
    self.rewardBtn_red:SetRedDotParam(self.model.isHightReward)
    self.rankBtn_red:SetRedDotParam(self.model.isRankReward)
    self.challenge_red:SetRedDotParam(self.model.isChallenge)
    self.bigGodBtn_red:SetRedDotParam(self.model.bigRedPoint)
    if self.model.bigRedPoint == false then
        if self.model.isTopChallenge or self.model.isBigGodReward then
            self.bigGodBtn_red:SetRedDotParam(true)
        else
            self.bigGodBtn_red:SetRedDotParam(false)
        end
    end


end

function ArenaPanel:InitUI()

	local iconName = Config.db_item[enum.ITEM.ITEM_HONOR].icon
	GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
    local isSkin = CacheManager:GetInstance():GetInt(self.skinKey, 0)
    if isSkin == 0 then
        CacheManager:GetInstance():SetInt(self.skinKey, 2)
        self:SetSkikBox(false)
    else
        if isSkin == 1 then
            --跳过战斗
            self:SetSkikBox(true)
        elseif isSkin == 2 then
            self:SetSkikBox(false)
        end
    end

    local isTimes = CacheManager:GetInstance():GetInt(self.timesKey, 0)
    if isTimes == 0 then
        CacheManager:GetInstance():SetInt(self.timesKey, 2)
        self:SetTimesBox(false)
    else
        if isTimes == 1 then
            --跳过战斗
            self:SetTimesBox(true)
        elseif isTimes == 2 then
            self:SetTimesBox(false)
        end
    end

    local isWing = CacheManager:GetInstance():GetInt(self.wingKey, 0)
    if isWing == 0 then
        CacheManager:GetInstance():SetInt(self.wingKey, 2)
        self:SetWingBox(false)
        self.model.isShowWing = false
    else
        if isWing == 1 then
            --跳过战斗
            self:SetWingBox(true)
            self.model.isShowWing = true
        elseif isWing == 2 then
            self:SetWingBox(false)
            self.model.isShowWing = false
        end
    end


end

function ArenaPanel:SetFunction()
    local cfg = Config.db_arena
    local skipLv = String2Table(cfg.skip_lv.val)[1]  --跳过等级
    local comLv = String2Table(cfg.com_lv.val)[1]   --合并等级
    local curLevel = self.main_role_data.level
    SetVisible(self.skinBox.transform, curLevel >= skipLv)
    SetVisible(self.timesBox.transform, curLevel >= comLv)

    if curLevel < skipLv then
        SetLocalPosition(self.wingBox.transform, -482, 109, 0)
    end
    if curLevel >= skipLv and curLevel < comLv then
        SetLocalPosition(self.skinBox.transform, -482, 109, 0)
        SetLocalPosition(self.wingBox.transform, -482, 51, 0)
    end
    if curLevel >= comLv then
        SetLocalPosition(self.skinBox.transform, -482, 5, 0)
        SetLocalPosition(self.wingBox.transform, -482, 51, 0)
    end
    --if curLevel >= comLv then
    --    SetLocalPosition(self.timesObj.transform,0,0,0)
    --else
    --    SetLocalPosition(self.timesObj.transform,0,-20,0)
    --end


end

function ArenaPanel:SetTimesBox(bool)
    bool = bool and true or false;
    self.model.isTimes = bool
    self.timesBox.isOn = bool
end

function ArenaPanel:SetWingBox(bool)
    bool = bool and true or false;
    --  self.model.lvBox = false
    self.wingBox.isOn = bool
end

function ArenaPanel:SetSkikBox(bool)
    bool = bool and true or false;
    --  self.model.lvBox = false
    --local uid = tostring(self.main_role_data.uid)
    --local key = "ArenaSkin"..uid
    self.skinBox.isOn = bool
end

function ArenaPanel:AddEvent()
    local function call_back()
        --if self.schedule then
        --    return
        --end
        --
        --self.schedule = GlobalSchedule:Start(handler(self, self.refreshTime), 0.2, -1);
        -- self.isRefTime = true
        if self.isRefTime then
            Notify.ShowText(string.format("You can refresh after %s sec", self.refTimer))
            return
        end
        self.isRefTime = true
        ArenaController:GetInstance():RequstRefresh()
    end
    AddClickEvent(self.refreshBtn.gameObject, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ArenaBigPanel):Open()
    end
    AddClickEvent(self.bigGodBtn.gameObject, call_back)

    local function call_back()
        --添加次数
        lua_panelMgr:GetPanelOrCreate(ArenaBuyPanel):Open(self.arenaData.buy_times)
    end
    AddClickEvent(self.addBtn.gameObject, call_back)

    local function call_back()
        --排行
        lua_panelMgr:GetPanelOrCreate(ArenaRankPanel):Open()
    end
    AddClickEvent(self.rankRewardBtn.gameObject, call_back)

    local function call_back()
        --商城
        UnpackLinkConfig("180@1@3")
    end
    AddClickEvent(self.shopBtn.gameObject, call_back)

    local function call_back()
        --奖励列表
        lua_panelMgr:GetPanelOrCreate(ArenaAwardPanel):Open()
    end
    AddClickEvent(self.rewardShowBtn.gameObject, call_back)

    local function call_back()
        --激励
        lua_panelMgr:GetPanelOrCreate(ArenaInspirePanel):Open(self.arenaData.sti_times)
    end

    AddClickEvent(self.upBtn.gameObject, call_back)

    local function call_back()
        --问号
        ShowHelpTip(HelpConfig.Arena.panel,true);
    end

    AddClickEvent(self.wenhBtn.gameObject, call_back)

    local function call_back()
        --   print2(self.timesBox.isOn)
        if self.roloIndex == 0 then
            Notify.ShowText("Please select a player")
            return
        end

        local role = self.roleList[self.roloIndex]
        self.model.curChallenger = role.data
        print2(role.data.rank, role.data.id, self.timesBox.isOn, false, self.skinBox.isOn)
        ArenaController:GetInstance():RequstStart(role.data.rank, role.data.id, self.timesBox.isOn, false, self.skinBox.isOn)

    end
    AddClickEvent(self.challengeBtn.gameObject, call_back)

    --local call_back = function(target, bool)
    --    if bool then
    --        CacheManager:GetInstance():SetInt(self.wingKey,1)
    --    else
    --        CacheManager:GetInstance():SetInt(self.wingKey,2)
    --    end
    --
    --    self.model:Brocast(ArenaEvent.ArenaIsWing,bool)
    --end
    AddValueChange(self.wingBox.gameObject, handler(self, self.isShowWing));

    local call_back = function(target, bool)
        if bool then
            CacheManager:GetInstance():SetInt(self.skinKey, 1)
        else
            CacheManager:GetInstance():SetInt(self.skinKey, 2)
        end
    end

    AddValueChange(self.skinBox.gameObject, call_back)

    local call_back = function(target, bool)
        if bool then
            Notify.ShowText("Next challenge will use up all your attempts")
            CacheManager:GetInstance():SetInt(self.timesKey, 1)
        else
            CacheManager:GetInstance():SetInt(self.timesKey, 2)
        end
    end
    AddValueChange(self.timesBox.gameObject, call_back)

    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaInfo, handler(self, self.ArenaInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaRefresh, handler(self, self.ArenaRefresh))

    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaItemClick, handler(self, self.ArenaItemClick))
    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaAddChallenge, handler(self, self.ArenaAddChallenge))
    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaStinulate, handler(self, self.ArenaStinulate))

    self.gloEvents[#self.gloEvents + 1] = GlobalEvent:AddListener(ArenaEvent.ArenaRedInfo, handler(self, self.ArenaRedInfo))
end

function ArenaPanel:refreshTime()
    self.isRefTime = true
    self.refTimer = self.refTimer - 1
    if self.refTimer < 0 then
        self.refTimer = 5
        self.isRefTime = false
        if self.schedule then
            GlobalSchedule:Stop(self.schedule);
        end
    end
end

function ArenaPanel:isShowWing(target, bool)
    if bool then
        CacheManager:GetInstance():SetInt(self.wingKey, 1)
    else
        CacheManager:GetInstance():SetInt(self.wingKey, 2)
    end
    self.model.isShowWing = bool
    self.model:Brocast(ArenaEvent.ArenaIsWing, bool)
end

function ArenaPanel:ArenaInfo(data)
    self.isFirst = false
    self.rTimes.text = data.challenge
    self.arenaData = data
    self:SetMyInfo(data.rank)
    self:UpdateRoleInfo(data.list)
    self:SetFunction()
    self:CheckRedPoint()
end

function ArenaPanel:ArenaRefresh(data)
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
    self.schedule = GlobalSchedule:Start(handler(self, self.refreshTime), 1, -1);
    self:UpdateRoleInfo(data.list)
    self:ArenaItemClick(0)
end

function ArenaPanel:SetMyInfo(rank)
    -- dump(self.main_role_data.power)
    if rank == 0 then
        self.myRank.text = "No rankings yet"
        self.moneyNum.text = "0"
    else
        self.myRank.text = "No." .. rank .. "No. X"
       local money =  self.model:GetRankHonerReward(rank)
        self.moneyNum.text = money
    end
    if self.main_role_data.gender == 1 then
        lua_resMgr:SetImageTexture(self, self.headImg, "main_image", "img_role_head_1", true, nil, false)
    else
        lua_resMgr:SetImageTexture(self, self.headImg, "main_image", "img_role_head_2", true, nil, false)
    end
    local power = string.gsub(GetShowNumber(self.main_role_data.power), "%.", "d")
    if self.model.sti_times > 0 then
        local curPower = string.gsub(GetShowNumber(self.model:GetPower(self.model.sti_times, self.main_role_data.power)), "%.", "d")
        self.power.text = curPower
    else
        self.power.text = power
    end

    --local money = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.Honor)
    --self.moneyNum.text = money
    -- self.main_role_data
end

---更新挑战者信息
function ArenaPanel:UpdateRoleInfo(list)
    local tab = list
    self.roleList = self.roleList or {}
    local index = 0
    for i = 1, #tab do
        local role = self.roleList[i]
        if not role then
            role = ArenaRoleItem(self.ArenaRoleItem.gameObject, self.RoleParent, "UI")
            self.roleList[i] = role
        else
            role:SetVisible(true)
        end
        role:SetData(tab[i], i)
        --if tab[i].creep ~= 0 then  --怪物
        --    index = index + 1
        --    self:InitCreepModel(tab[i].creep)
        --end
    end
    for i = #tab + 1, #self.roleList do
        local Item = self.roleList[i]
        Item:SetVisible(false)
    end
end

function ArenaPanel:InitCreepModel(creepId)

end

function ArenaPanel:ArenaItemClick(index)
    if self.roloIndex == index then
        return
    end
    self.roloIndex = index
    for i = 1, #self.roleList do
        if index == i then
            self.roleList[i]:SetSelect(true)
        else
            self.roleList[i]:SetSelect(false)
        end
    end
end

function ArenaPanel:ArenaAddChallenge(data)
    self.rTimes.text = data.challenge
end

function ArenaPanel:ArenaStinulate()
    local num = self.model:GetPower(self.model.sti_times, self.main_role_data.power)
    local result = GetShowNumber(num)
    local curPower = string.gsub(result, "%.", "d")
    self.power.text = curPower
end

function ArenaPanel:ArenaRedInfo()
    self:CheckRedPoint()
end


