---
--- Created by  Administrator
--- DateTime: 2020/5/18 11:18
---
FactionSerWarAppItem = FactionSerWarAppItem or class("FactionSerWarAppItem", BaseCloneItem)
local this = FactionSerWarAppItem

function FactionSerWarAppItem:ctor(obj, parent_node, parent_panel)
    FactionSerWarAppItem.super.Load(self)
    self.model = FactionSerWarModel.GetInstance()
    self.events = {}
    self.itemicon = {}
    self.itemicon1 = {}
    self.isShowDes = false
end

function FactionSerWarAppItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}

    for i, v in pairs(self.itemicon1) do
        v:destroy()
    end
    self.itemicon1 = {}
    if self.red_dot then
        self.red_dot:destroy()
    end
    self.red_dot = nil
end

function FactionSerWarAppItem:LoadCallBack()
    self.nodes = {
        "appBtn","addImg","tanhao","name","winIconParent","loseIconParent",
        "showItem/mask","showItem","showItem/showDes",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.showDes = GetText(self.showDes)
    SetVisible(self.showItem,false)
    self:InitUI()
    self:AddEvent()
    if not self.red_dot then
        self.red_dot = RedDot(self.appBtn, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(50, 18)
   -- self.red_dot:SetRedDotParam(isShow)
end

function FactionSerWarAppItem:InitUI()

end

function FactionSerWarAppItem:AddEvent()
    local function call_back()
        self.isShowDes = not self.isShowDes
        SetVisible(self.showItem,self.isShowDes)
    end
    AddClickEvent(self.tanhao.gameObject,call_back)

    local function call_back()

        --local times = self.model:GetBookTimes() --可预约次数
        --if self.model.booktimes >= times then
        --    Notify.ShowText("您的预约次数已用完")
        --    return
        --end
        --if self.model:IsBook() then
        --    Notify.ShowText("您当前已预约了一个工会")
        --    return
        --end
        local times2 = self.model:GetBookTimes2()  --可被预约次数
        if self.data.book_times >= times2  then
            Notify.ShowText(self.model.desTab.append)
            return
        end

        local costScore = self.model:GetCostScore(self.data.book_times + 1)
        local str = string.format(FactionSerWarModel.desTab.appDes,self.data.book_times,costScore)
        local function ok_func()
            if costScore > self.model.my_scroe then
                Notify.ShowText(FactionSerWarModel.desTab.noScore)
                return
            end
            FactionSerWarController:GetInstance():RequstBookInfo(self.data.id)
        end
        Dialog.ShowTwo(FactionSerWarModel.desTab.Tips,str,FactionSerWarModel.desTab.ok,ok_func,nil,FactionSerWarModel.desTab.center,nil)
    end
    AddButtonEvent(self.appBtn.gameObject,call_back)

    local function call_back()
        self.isShowDes = false
        SetVisible(self.showItem,self.isShowDes)
    end
    AddButtonEvent(self.mask.gameObject,call_back)
end

function FactionSerWarAppItem:SetData(data)
    self.data = data
    self.name.text = self.data.name
    --logError("book"..self.data.book)
    --logError("book2"..self.data.book2)
    self:BtnState(self.data.book)
    self.rank = self.model:GetRankInfo(self.data.id).rank
    self:CreateWinIcon()
    --self:CreateLoseIcon()
end

function FactionSerWarAppItem:BtnState(bookId)
    local myGuildId = RoleInfoModel.GetInstance():GetMainRoleData().guild
    local myPost = FactionModel:GetInstance():SetSelfCadre()
    local roleInfo = RoleInfoModel.GetInstance():GetMainRoleData()
    if roleInfo.guild and tostring(roleInfo.guild) == "0" then
        SetVisible(self.tanhao,false)
        SetVisible(self.addImg,false)
        SetVisible(self.appBtn,false)
        self.red_dot:SetRedDotParam(false)
    else
        if self.model.my_rank ==  0 then
            SetVisible(self.tanhao,false)
            SetVisible(self.addImg,false)
            SetVisible(self.appBtn,false)
            self.red_dot:SetRedDotParam(false)
        else
            if bookId == "0" then --未预约
                if myPost ~= enum.GUILD_POST.GUILD_POST_CHIEF then
                    SetVisible(self.appBtn,false)
                    self.red_dot:SetRedDotParam(false)
                else

                    self.red_dot:SetRedDotParam(self.model.reds[2])

                    SetVisible(self.appBtn,true)
                end

                SetVisible(self.addImg,false)
                SetVisible(self.tanhao,false)
            else
                SetVisible(self.tanhao,true)
                local guildName = ""
                if bookId == myGuildId then  --自己公会预约的
                    guildName = RoleInfoModel.GetInstance():GetMainRoleData().gname
                    SetVisible(self.addImg,true)
                    SetVisible(self.appBtn,false)
                else
                    if myPost ~= enum.GUILD_POST.GUILD_POST_CHIEF then
                        SetVisible(self.appBtn,false)
                        self.red_dot:SetRedDotParam(false)
                    else

                        self.red_dot:SetRedDotParam(self.model.reds[2])
                        SetVisible(self.appBtn,true)
                    end
                    SetVisible(self.addImg,false)
                    guildName = self.data.book_guild
                end
                -- guildName = self.model:GetGuildName(bookId)
                local timeTab =  TimeManager:GetInstance():GetTimeDate(self.data.book_time)
                local times =  self.data.book_times
                local score = self.model:GetCostScore(times)
                --self.model:GetCostScore(times)

                local timeStr = ""
                if timeTab.month then
                    timeStr = timeStr .. string.format("%02d", timeTab.month) .. "."
                end
                if timeTab.day then
                    timeStr = timeStr .. string.format("%02d", timeTab.day) .. " "
                end
                if timeTab.hour then
                    timeStr = timeStr .. string.format("%02d", timeTab.hour) .. ":";
                end
                if timeTab.min then
                    timeStr = timeStr .. string.format("%02d", timeTab.min) .. ":";
                end
                if timeTab.sec then
                    timeStr = timeStr .. string.format("%02d", timeTab.sec);
                end

                local str = string.format(FactionSerWarModel.desTab.addSuc,timeStr,guildName,score)
                self.showDes.text = str
            end
        end

    end


end

function FactionSerWarAppItem:CreateWinIcon()
    local tab = self.model:GetRewardCfg(self.rank)
    local winTab = String2Table(tab.win_reward)
    local loseTab = String2Table(tab.lose_reward)
    local winScore = tab.win_score
    local loseScore = tab.lose_score
    for i = 1, #winTab + 1 do
        if i == #winTab + 1 then
            if self.itemicon[i + 1] == nil then
                self.itemicon[i+ 1] = GoodsIconSettorTwo(self.winIconParent)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = 90010036
            param["num"] = winScore
            param["bind"] = 1
            param["can_click"] = true
            self.itemicon[i + 1]:SetIcon(param)
        else
            if self.itemicon[i] == nil then
                self.itemicon[i] = GoodsIconSettorTwo(self.winIconParent)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = winTab[i][1]
            param["num"] = winTab[i][2]
            param["bind"] = winTab[i][3]
            param["can_click"] = true
            -- param["size"] = {x=70,y=70}
            --  param["size"] = {x = 72,y = 72}
            self.itemicon[i]:SetIcon(param)
        end

    end

    for i = 1, #loseTab + 1 do
        if i == #loseTab + 1 then
            if self.itemicon1[i + 1] == nil then
                self.itemicon1[i+ 1] = GoodsIconSettorTwo(self.loseIconParent)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = 90010036
            param["num"] = loseScore
            param["bind"] = 1
            param["can_click"] = true
            self.itemicon1[i + 1]:SetIcon(param)
        else
            if self.itemicon1[i] == nil then
                self.itemicon1[i] = GoodsIconSettorTwo(self.loseIconParent)
            end
            local param = {}
            param["model"] = self.model
            param["item_id"] = loseTab[i][1]
            param["num"] = loseTab[i][2]
            param["bind"] = loseTab[i][3]
            param["can_click"] = true
            -- param["size"] = {x=70,y=70}
            --  param["size"] = {x = 72,y = 72}
            self.itemicon1[i]:SetIcon(param)
        end


    end

end

function FactionSerWarAppItem:CreateLoseIcon()
    local tab = self.model:GetLoseReward()
    for i = 1, #tab do
        if self.itemicon1[i] == nil then
            self.itemicon1[i] = GoodsIconSettorTwo(self.loseIconParent)
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = tab[i][1]
        param["num"] = tab[i][2]
        param["bind"] = tab[i][3]
        param["can_click"] = true
        -- param["size"] = {x=70,y=70}
        --  param["size"] = {x = 72,y = 72}
        self.itemicon1[i]:SetIcon(param)
    end
end