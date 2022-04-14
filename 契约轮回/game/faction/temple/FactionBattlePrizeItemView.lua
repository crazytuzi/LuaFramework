---
--- Created by R2D2.
--- DateTime: 2019/2/21 10:20
---
FactionBattlePrizeItemView = FactionBattlePrizeItemView or class("FactionBattlePrizeItemView", BaseItem)
local this = FactionBattlePrizeItemView

function FactionBattlePrizeItemView:ctor(parent_node, layer)
    --self.transform = obj.transform
    --self.data = tab
    --self.worldLv = level
    --self.gameObject = self.transform.gameObject;
    --self.transform_find = self.transform.Find;
    --
    --self:InitUI();
    --self:AddEvent();

    self.abName = "faction"
    self.assetName = "FactionBattlePrizeItemView"
    self.layer = layer

    BaseItem.Load(self)
    self.dataModel = FactionBattleModel.GetInstance()
    self.modelEvents = {}
    self.dataModel:RemoveTabListener(self.modelEvents)
end

function FactionBattlePrizeItemView:dctor()
    self.dataModel:RemoveTabListener(self.modelEvents)
    for _, v in pairs(self.goodItems) do
        v:destroy()
    end
    self.goodItems = {}
end

function FactionBattlePrizeItemView:LoadCallBack()
    self.is_loaded = true
    self.nodes = {"OkBtn","AssignedBtn","Items","Title",}
    self:GetChildren(self.nodes)

    self.timesText = GetText(self.Title)
    self:AddEvent()
    --self:RefreshView()
    --self:InitGoodsItem()
    if self.is_need_setData then
        self:SetData(self.data, self.worldLv,self.visible, self.isAssigned,self.winTimes)
    end
end

function FactionBattlePrizeItemView:AddEvent()
    local function OnAllot()
        if(FactionModel:GetInstance():GetIsPresidentSelf()) then
            lua_panelMgr:GetPanelOrCreate(FactionBattlePrizeAssignPanel):Open(1)
        else
            Notify.ShowText(ConfigLanguage.FactionBattle.NotGuildPresidentTip)
        end
    end
    AddButtonEvent(self.OkBtn.gameObject, OnAllot)

    self.modelEvents[#self.modelEvents + 1] = self.dataModel:AddListener(FactionBattleEvent.FactionBattle_Model_AssignedWinAwardEvent, handler(self, self.OnAssignedWinAward))
end

function FactionBattlePrizeItemView:OnAssignedWinAward()
    local isAssigned = self.dataModel.WinnerInfo.v_allot
    local visible = self:IsShowButton()
    local winTimes = 0

    if (self.dataModel.WinnerInfo) then
        winTimes = self.dataModel.WinnerInfo.victory
    end

   -- for _, v in pairs(self.itemList) do
        if (visible) then
            if (isAssigned) then
                self:SetButtonVisible(false, self.data.times == winTimes)
            else
                self:SetButtonVisible(self.data.times == winTimes, false)
            end
        else
            self:SetButtonVisible(false, false)
        end
   -- end
end

function FactionBattlePrizeItemView:RefreshView()
    self.timesText.text= string.format("Win streak %s times", self.data.times)
end

function FactionBattlePrizeItemView:SetButtonVisible(showBtn, showAssigned)
    SetVisible(self.OkBtn, showBtn)
    SetVisible(self.AssignedBtn, showAssigned)
end

function FactionBattlePrizeItemView:InitGoodsItem()

    if self.goodItems then
        for _, v in pairs(self.goodItems) do
            v:destroy()
        end
    end
    self.goodItems = {}
	local lv = RoleInfoModel:GetInstance():GetRoleValue("level")
	local rewardTab = String2Table(self.data.victory)
	local goods
	
	for _, v in ipairs(rewardTab) do
		if( self.worldLv >= v[1] and  self.worldLv <= v[2])then
			goods = v[3]
			break
		end
	end
	
    --local goods = String2Table(self.data.victory)

    for _,v in pairs(goods) do
        local item = AwardItem(self.Items)
        item:SetData(v[1], v[2])
        item:AddClickTips()
        table.insert(self.goodItems, item)

        local index = #self.goodItems - 1
        local col = index % 2
        local row = math.floor( index / 2)

        SetLocalScale(item.transform, 1, 1, 1)
        SetLocalPosition(item.transform, col * 80, row* -86, 0)
    end
end

function FactionBattlePrizeItemView:SetData(data,level,visible,isAssigned,winTimes)
   -- logError(level)
    self.data = data
    self.worldLv = level
    self.visible = visible
    self.isAssigned = isAssigned
    self.winTimes = winTimes
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    self:RefreshView()
    self:InitGoodsItem()
    if (self.visible) then
        if (self.isAssigned ) then
            self:SetButtonVisible(false, self.data.times == self.winTimes)
        else
            self:SetButtonVisible(self.data.times == self.winTimes, false)
        end
    else
        self:SetButtonVisible(false, false)
    end
    --logError(self.data.times)
end

function FactionBattlePrizeItemView:IsShowButton()
    if (self.dataModel.WinnerInfo) then

        --if (self.dataModel.WinnerInfo.v_allot) then
        --    return false
        --end

        if (self.dataModel.WinnerInfo.guild == 0) then
            return false
        else
            local gId = RoleInfoModel.GetInstance():GetMainRoleData().guild

            if (gId == self.dataModel.WinnerInfo.guild) then
                return true
            else
                return false
            end
        end
    end

    return false
end