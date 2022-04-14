---
--- Created by  Administrator
--- DateTime: 2020/4/8 18:59
---
ThroneStarDungeRightView = ThroneStarDungeRightView or class("ThroneStarDungeRightView", BaseItem)
local this = ThroneStarDungeRightView

function ThroneStarDungeRightView:ctor(parent_node)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "ThroneStarDungeRightView"
    self.layer = "UI"
    self.model = ThroneStarModel.GetInstance()
    self.events = {}
    self.mEvents = {}
    self.rankItems = {}
    self.btnSelects2 = {}
    self.btnSelectsTex2 = {}
    self.roleInfo = RoleInfoModel:GetInstance():GetMainRoleData()
    ThroneStarDungeRightView.super.Load(self)
end

function ThroneStarDungeRightView:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.mEvents)
    if self.schedule_id then
        GlobalSchedule:Stop(self.schedule_id )
        self.schedule_id = nil
    end
    if not table.isempty( self.rankItems) then
        for i, v in pairs( self.rankItems) do
            v:destroy()
        end
    end
    self.rankItems = {}
    self.btnSelects2 = {}
    self.btnSelectsTex2 = {}
end

function ThroneStarDungeRightView:LoadCallBack()
    self.nodes = {
        "con","con/hurtBtn","con/RightScrollView/Viewport/RightContent","con/ThroneStarDungeRankItem","con/hurtBtn/hurtBtnSelect",
        "con/hurtBtn/hurtBtnText","con/scoreBtn/scoreBtnText",
        "con/scoreBtn","con/serRank","ThroneStarDungeRightView","con/scoreBtn/scoreBtnSelect",
    }
    self:GetChildren(self.nodes)
    self.serRank = GetText(self.serRank)
    self.hurtBtnText = GetText(self.hurtBtnText)
    self.scoreBtnText = GetText(self.scoreBtnText)

    self.btnSelects2[1] = self.hurtBtnSelect
    self.btnSelects2[2] = self.scoreBtnSelect


    self.btnSelectsTex2[1] = self.hurtBtnText
    self.btnSelectsTex2[2] = self.scoreBtnText





    self.serRank.text = "Server Rank: None"
    self:InitUI()
    self:AddEvent()
    SetAlignType(self.con.transform, bit.bor(AlignType.Right, AlignType.Null))
    self:SetRightPage(1)
end

function ThroneStarDungeRightView:InitUI()

end

function ThroneStarDungeRightView:AddEvent()


    local function call_back()
        self:SetRightPage(1)
    end
    AddClickEvent(self.hurtBtn.gameObject,call_back)
    local function call_back()
        self:SetRightPage(2)
    end
    AddClickEvent(self.scoreBtn.gameObject,call_back)


    self.mEvents[#self.mEvents + 1] =  self.model:AddListener(ThroneStarEvent.ThroneDamageInfo,handler(self,self.ThroneDamageInfo))
    self.mEvents[#self.mEvents + 1] =  self.model:AddListener(ThroneStarEvent.ThroneScoreInfo,handler(self,self.ThroneScoreInfo))

    local call_back = function()
        --SetGameObjectActive(self.rightObj.gameObject , false);
        SetGameObjectActive(self.con.gameObject , false);
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        --SetGameObjectActive(self.rightObj.gameObject , true);
        SetGameObjectActive(self.con.gameObject , true);
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);

    local function call_back()
        self:destroy()
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.GameReset, call_back)

    local function call_back(sceneId)
        if sceneId == self.model.sceneIds[3] then
            self:SetRightPage(1)
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

function ThroneStarDungeRightView:RequestScoreRank()
    ThroneStarController.GetInstance():RequestScoreInfo()
end

function ThroneStarDungeRightView:RequestDamageRank(bossId)
    ThroneStarController.GetInstance():RequestDamageInfo(bossId)
end

function ThroneStarDungeRightView:RequestRank(index)
    if index == 1 then --伤害排行
        local isNear,bossID = self:IsNearByBoss()
        if not isNear then
            if not table.isempty(self.rankItems) then
                for i = 1, #self.rankItems do
                    self.rankItems[i]:SetVisible(false)
                end
            end

            return
        end
        -- logError("請求傷害",bossID)
        self:RequestDamageRank(tonumber(bossID))
    else  --积分排行
        --  logError("請求積分")
        self:RequestScoreRank()
    end
end

function ThroneStarDungeRightView:IsNearByBoss()
    local list = SceneManager.GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP) or {}
    for k, obj in pairs(list) do
        if obj.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
            local bosscfg = Config.db_throne_boss[obj.object_info.id]
            if bosscfg  then
                return true, obj.object_info.id
            end
        end
    end
    return false
end

function ThroneStarDungeRightView:ThroneDamageInfo(data)
    self:UpdateRankInfo(data,1)
end


function ThroneStarDungeRightView:ThroneScoreInfo(data)
    self:UpdateRankInfo(data,2)
end

function ThroneStarDungeRightView:UpdateRankInfo(data,type)
    --logError(Table2String(data.ranking))
    local tab = data.ranking
    local num = 0
    local myRank = 0
    for i=1, #tab do
        local item = self.rankItems[i]
        if not item then
            item = ThroneStarDungeRankItem(self.ThroneStarDungeRankItem.gameObject,self.RightContent,"UI")
            self.rankItems[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(tab[i],type)
        if tab[i].id == self.roleInfo.suid then
            myRank = tab[i].rank
        end

    end
    for i = #tab + 1,#self.rankItems do
        local buyItem = self.rankItems[i]
        buyItem:SetVisible(false)
    end
    if myRank == 0 then
        self.serRank.text = "Server Rank: None"
    else
        self.serRank.text = string.format("Server Rank: %s",myRank)
    end
end

function ThroneStarDungeRightView:SetRightPage(index)
    if index == 2 and SceneManager:GetInstance():GetSceneId() == self.model.sceneIds[3] then
        Notify.ShowText("Point Ranking of the map is not available")
        return
    end
    for i = 1, 2 do
        if index == i then
            SetColor(self.btnSelectsTex2[i], 255, 255, 255, 255)
            SetVisible(self.btnSelects2[i],true)
        else
            SetColor(self.btnSelectsTex2[i], 133, 132, 176, 255)
            SetVisible(self.btnSelects2[i],false)
        end
    end

    if self.schedule_id then
        GlobalSchedule:Stop(self.schedule_id)
        self.schedule_id = nil
    end
    self:RequestRank(index)
    self.schedule_id = GlobalSchedule:Start(handler(self,self.RequestRank,index), 5)
end