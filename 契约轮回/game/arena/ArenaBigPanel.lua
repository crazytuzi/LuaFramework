---
--- Created by  Administrator
--- DateTime: 2019/5/6 15:09
---
ArenaBigPanel = ArenaBigPanel or class("ArenaBigPanel", BasePanel)
local this = ArenaBigPanel

function ArenaBigPanel:ctor()
    self.abName = "arena";
    self.image_ab = "arena_image";
    self.assetName = "ArenaBigPanel"
    self.use_background = false
    self.show_sidebar = false
    self.model = ArenaModel:GetInstance()
    self.events = {}
    self.gloEvents = {}
    self.roloIndex = 0
    self.isFisrt = true
    self.is_hide_other_panel = true
 --   ArenaBigPanel.super.Load(self)
    self.main_role_data = RoleInfoModel.GetInstance():GetMainRoleData()
    local uid = tostring(self.main_role_data.uid)
    self.skinKey = "ArenaSkin"..uid
end

function ArenaBigPanel:Open()
    self.model.isFirstOpenBigPanel = false
    ArenaController:GetInstance():RequstRedPoineInfo()
    self.model.isOpenArenaBagPanel = true
    BasePanel.Open(self)
end
function ArenaBigPanel:OnEnable()
    self.model.isOpenArenaBagPanel = true
    if self.isFisrt == false then
        ArenaController:GetInstance():RequstTopInfo()
    end
end

function ArenaBigPanel:OnDisable()
    self.model.isOpenArenaBagPanel = false
end


function ArenaBigPanel:dctor()
   -- GlobalEvent:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gloEvents)
    self.model.isOpenArenaBagPanel = false
    self.model:RemoveTabListener(self.events)

    if self.roleList then
        for i, v in pairs(self.roleList) do
            v:destroy()
        end
        self.roleList = {}
    end

    if self.rewardBtn_red then
        self.rewardBtn_red:destroy()
        self.rewardBtn_red = nil
    end

    if self.challenge_red then
        self.challenge_red:destroy()
        self.challenge_red = nil
    end

end

function ArenaBigPanel:LoadCallBack()
    self.nodes = {
        "closeBtn","timesBg/times","ArenaBigTopItem","powerBg/power","lqBtn","topParent","wenhBtn","downParent","ArenaBigDownItem","bg","challengeBtn"
    }
    self:GetChildren(self.nodes)
    self.bg = GetImage(self.bg)
    self.times = GetText(self.times)
    self.power = GetText(self.power)
    self.lqBtnImg = GetImage(self.lqBtn)
    self:InitUI()
    self:AddEvent()

    self.rewardBtn_red = RedDot(self.lqBtn, nil, RedDot.RedDotType.Nor)
    self.rewardBtn_red:SetPosition(25, 28)

    self.challenge_red = RedDot(self.challengeBtn, nil, RedDot.RedDotType.Nor)
    self.challenge_red:SetPosition(70, 25)

    ArenaController:GetInstance():RequstTopInfo()
    ArenaController:GetInstance():RequstTopRank()

end

function ArenaBigPanel:CheckRedPoint()
    --
    --if self.model.isRankReward then
    --
    --end
    self.rewardBtn_red:SetRedDotParam(self.model.isBigGodReward)
    self.challenge_red:SetRedDotParam(self.model.isTopChallenge)


end

function ArenaBigPanel:InitUI()
    lua_resMgr:SetImageTexture(self, self.bg, "iconasset/icon_big_bg_arena_bigBg", "arena_bigBg", true)
end

function ArenaBigPanel:AddEvent()

    local function call_back()  --问号
        ShowHelpTip(HelpConfig.Arena.bigGod,true);
    end

    AddClickEvent(self.wenhBtn.gameObject,call_back)
    
    local function call_back() --领取奖励
        if not self.model.isBigGodReward then
            Notify.ShowText("You didn't meet requirements!")
            return
        end
        ArenaController:GetInstance():RequstTopRankfetch()
    end
    AddClickEvent(self.lqBtn.gameObject,call_back)


    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)
    
    local function call_back()
        if self.roloIndex == 0 then
            Notify.ShowText("Please select a player")
            return
        end
        local role =  self.roleList[self.roloIndex]
        self.model.curChallenger = role.data

        local isSkin = CacheManager:GetInstance():GetInt(self.skinKey ,0)
        if isSkin == 0 then
            ArenaController:GetInstance():RequstStart(role.data.rank,role.data.id,false,true,false)
        else
            if isSkin == 1 then
                ArenaController:GetInstance():RequstStart(role.data.rank,role.data.id,false,true,true)
            elseif isSkin == 2 then
                ArenaController:GetInstance():RequstStart(role.data.rank,role.data.id,false,true,false)
            end
        end

    end
    AddClickEvent(self.challengeBtn.gameObject,call_back)


    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaTopInfo, handler(self, self.ArenaTopInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaBigGodFetch, handler(self, self.ArenaBigGodFetch))
    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaLqBigGodFetch, handler(self, self.ArenaLqBigGodFetch))
    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaBigItemClick, handler(self, self.ArenaBigItemClick))
    self.gloEvents[#self.gloEvents + 1] = GlobalEvent:AddListener(ArenaEvent.ArenaRedInfo, handler(self, self.ArenaRedInfo))


end


function ArenaBigPanel:ArenaTopInfo(data)
    self.isFisrt = false
    self:UpdateTopItems(data.list)
    self:CheckRedPoint()
    self.times.text = "Challenges:   "..data.challenge
    self.power.text =  "My CP:".. self.main_role_data.power
    if not self.model.isBigGodReward then --已领取
        ShaderManager.GetInstance():SetImageGray(self.lqBtnImg)
    else
        ShaderManager.GetInstance():SetImageNormal(self.lqBtnImg)
    end
end

function ArenaBigPanel:UpdateTopItems(list)
    local tab = list
    self.roleList = self.roleList or {}
    for i = 1, #tab do
        local role = self.roleList[i]
        if not role then
            if tab[i].rank > 3 then
                role = ArenaBigDownItem(self.ArenaBigDownItem.gameObject,self.downParent,"UI")
            else
                role = ArenaBigTopItem(self.ArenaBigTopItem.gameObject,self.topParent,"UI")
            end

            self.roleList[i] = role
        else
            role:SetVisible(true)
        end
        role:SetData(tab[i],i)
    end
    for i = #tab + 1,#self.roleList do
        local Item = self.roleList[i]
        Item:SetVisible(false)
    end
end


function ArenaBigPanel:ArenaBigGodFetch()
    if not self.model.isBigGodReward then --已领取
        ShaderManager.GetInstance():SetImageGray(self.lqBtnImg)
    else
        ShaderManager.GetInstance():SetImageNormal(self.lqBtnImg)
    end

end


function ArenaBigPanel:ArenaLqBigGodFetch()
    if self.model.isBigGodReward then --已领取
        ShaderManager.GetInstance():SetImageGray(self.lqBtnImg)
    else
        ShaderManager.GetInstance():SetImageNormal(self.lqBtnImg)
    end
end

function ArenaBigPanel:ArenaBigItemClick(index)
    if self.roloIndex == index then
        return
    end
    self.roloIndex = index
    for i = 1, #self.roleList do
        if i == index then
            self.roleList[i]:SetShow(true)
        else
            self.roleList[i]:SetShow(false)
        end
    end
end

function ArenaBigPanel:ArenaRedInfo()
    self:CheckRedPoint()
end