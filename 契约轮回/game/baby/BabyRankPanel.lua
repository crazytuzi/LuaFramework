---
--- Created by  Administrator
--- DateTime: 2019/11/11 15:00
---
BabyRankPanel = BabyRankPanel or class("BabyRankPanel", WindowPanel)
local this = BabyRankPanel

function BabyRankPanel:ctor(parent_node, parent_panel)
    self.abName = "baby"
    self.assetName = "BabyRankPanel"
    self.image_ab = "baby_image";
    self.layer = "UI"
    self.events = {}
    self.modelEvents = {}
    self.rankItems = {}
    self.rewards = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 3
    self.pageIndex = 1
    self.nowPage = 1
    self.model = BabyModel:GetInstance()
end

function BabyRankPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)
    if self.roleMode  then
        self.roleMode:destroy()
    end
    self.roleMode = nil
    if self.rankItems then
        for i, v in pairs(self.rankItems) do
            v:destroy()
        end
        self.rankItems = {}
    end

    if self.rewards then
        for i, v in pairs(self.rewards) do
            v:destroy()
        end
        self.rewards = {}
    end
end

function BabyRankPanel:LoadCallBack()
    self.nodes = {
        "headObj/nameObj/nameTitle","BabyRankItem","headObj/title","myZan","headObj/nameObj/name",
        "BabyRankRewadItem","roleModelCon","headObj/union","rewardObj/rewardParent","myRank",
        "rankScrollView/Viewport/rankContent","rankScrollView","headObj",
        "noObj",
    }
    self:GetChildren(self.nodes)
    self.rankScrollView = GetScrollRect(self.rankScrollView)
    self.myRank = GetText(self.myRank)
    self.myZan = GetText(self.myZan)
    self.titleImg = GetImage(self.title)
    self.nameTitleTex = GetText(self.nameTitle)
    self.nameTex = GetText(self.name)
    self.union = GetText(self.union)
    SetVisible(self.headObj,false)
    self.text_title_1_outline = self.nameTitle:GetComponent('Outline')
    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage("baby_image", "baby_titile_tex3")
    RankController:GetInstance():RequestRankListInfo(1017,1)
end

function BabyRankPanel:InitUI()
    self:CreateReward()
end

function BabyRankPanel:CreateReward()
    local cfg = Config.db_baby_like_reward
    for i = 1, #cfg do
        local item = self.rewards[i]
        if not item then
            item = BabyRankRewadItem(self.BabyRankRewadItem.gameObject,self.rewardParent,"UI")
            self.rewards[i] = item
        end
        item:SetData(cfg[i])
    end
end

function BabyRankPanel:AddEvent()
    function DragEnd_Call_Back()
        if self.rankScrollView.verticalNormalizedPosition <= 0 then
            self.nowPage = self.nowPage + 1
            RankController:GetInstance():RequestRankListInfo(1017,self.nowPage)
        end
    end
    AddDragEndEvent(self.rankScrollView.gameObject,DragEnd_Call_Back)

    self.events[#self.events + 1] = GlobalEvent:AddListener(RankEvent.RankReturnList, handler(self, self.RankReturnList))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(BabyEvent.BabyRankClick, handler(self, self.BabyRankClick))

end

function BabyRankPanel:BabyRankClick(rank)
    for i, v in pairs(self.cacheRankItems) do
        if v.data.rank == rank then
            v:SetSelect(true)
            self:InitRoleModel(v.data)
            self:SetTitle(v.data)
        else
            v:SetSelect(false)
        end
    end
end

function BabyRankPanel:RankReturnList(data)
    if data.id ~= 1017 then
        return
    end
    if self.nowPage == 1 then
        self:SetOwnInfo(data)
    end
    if #data.list == 0 and self.nowPage == 1 then ---暂时没人上榜
        Notify.ShowText("Empty")
        SetVisible(self.noObj,true)
        SetVisible(self.rankScrollView,false)
        --self.nowPage = 1
       -- SetVisible(self.noRank,true)
       -- SetVisible(self.rankObj,false)
        return
    end
    SetVisible(self.noObj,false)
    SetVisible(self.rankScrollView,true)
    if #data.list == 0  and self.nowPage ~= 1  then --下一页没有数据
        Notify.ShowText("You reached the bottom! No data")
        return
    end



     self:UpdateRankItems(data.list)

end

function BabyRankPanel:SetOwnInfo(data)
    if data.mine.rank == 0 then
        self.myRank.text = "Rank: unranked"
    else
        self.myRank.text = "My Ranking:"..data.mine.rank
    end
    self.myZan.text = "My likes:"..data.mine.sort

end

function BabyRankPanel:UpdateRankItems(list)
    self.cacheRankItems = self.cacheRankItems or {}
    for i = 1, #list do
        local buyItem =  self.cacheRankItems[i]
        if  not buyItem then
            buyItem = BabyRankItem(self.BabyRankItem.gameObject,self.rankContent,"UI")

            self.cacheRankItems[i] = buyItem
        else
            buyItem:SetVisible(true)
        end
        buyItem:SetData(list[i])
    end
    for i = #list + 1,#self.cacheRankItems do
        local buyItem = self.cacheRankItems[i]
        buyItem:SetVisible(false)
    end
    if self.nowPage == 1 then
        self:BabyRankClick(1)
    end
end

function BabyRankPanel:InitRoleModel(roleData)
    if self.roleMode  then
        self.roleMode:destroy()
    end
    local data = {}
    data.res_id = 11001
    if roleData.base.figure.weapon then
        data.default_weapon = roleData.base.figure.weapon.model
    end

    local config = {}
    config.trans_x = 450
    config.trans_y = 450
    self.roleMode = UIRoleCamera(self.roleModelCon, nil,roleData.base,1,false,1,config,self.layerIndex)
end

function BabyRankPanel:SetTitle(data)
    SetVisible(self.headObj,true)
    local roleBase = data.base
    --  SetVisible(self.title,true)
    SetVisible(self.union,true)
    SetVisible(self.nameTitle,true)
    self.nameTex.text = roleBase.name
    self.title_id = roleBase.figure.jobtitle and roleBase.figure.jobtitle.model
    self.title_id = self.title_id or 0
    local cur_config = Config.db_jobtitle[self.title_id]
    if not cur_config then
        self.nameTitleTex.text = ""
        return
    end
    self.nameTitleTex.text = cur_config.name
    local r,g,b,a = HtmlColorStringToColor(cur_config.color)
    SetOutLineColor(self.text_title_1_outline, r,g,b,a)
    self:UpdateTitelPos()
    if roleBase.guild == nil or roleBase.gname == "" then
        self.union.text = "No guild yet"
    else
        self.union.text = roleBase.gname
    end
    if roleBase.figure.title.model == 0 then
        SetVisible(self.title,false)
    else
        lua_resMgr:SetImageTexture(self, self.titleImg, Constant.TITLE_IMG_PATH, tostring(roleBase.figure.title.model), false, nil, false)
        SetVisible(self.title,true)
    end
end

function BabyRankPanel:UpdateTitelPos()
    local name_width = self.nameTex.preferredWidth
    local job_title_width = self.nameTitleTex.preferredWidth
    local name_x = job_title_width * 0.5
    local job_title_x = -name_width * 0.5 - name_x
    -- SetLocalPositionX(self.name, name_x)
    SetLocalPositionX(self.nameTitle, job_title_x)
end