--- Created by .
--- DateTime: 2019/11/27 10:51

IllustratedMainPanel = IllustratedMainPanel or class("IllustratedMainPanel", BasePanel)
local this = IllustratedMainPanel

function IllustratedMainPanel:ctor(parent_node, parent_panel)
    self.abName = "sevenDayActive"
    self.assetName = "IllustratedMainPanel"
    self.image_ab = "sevenDayActive_image";
    self.layer = "UI"
    -- self.is_show_money = { Constant.GoldType.Coin, Constant.GoldType.BGold, Constant.GoldType.Gold }
    self.events = {}
    self.modelEvents = {}
    self.selectedId = -1;
    self.use_background = true
    self.show_sidebar = false
    self.panel_type = 2

    self.panels = {}
    self.panelType =  -1
    self.model = SevenDayActiveModel:GetInstance()
    self.sevenDayType = {
        { text = ConfigLanguage.Illustrated.Rank, id = 740 },
        { text = ConfigLanguage.Illustrated.Buy, id = 741},
        { text = ConfigLanguage.Illustrated.Recharge, id = 742 },
        { text = ConfigLanguage.Illustrated.Target, id = 743 },
        { text = ConfigLanguage.Illustrated.Box, id = 744 },
    }
    self.btnList = {}

end
function IllustratedMainPanel:Open(index)
    self.index = index
    WindowPanel.Open(self)
    --if self.btnList[self.index] then
    --    self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
    --else
    --    Notify.ShowText("活动已经全部结束")
    --end
end

function IllustratedMainPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)
    for _, item in pairs(self.panels) do
        item:destroy()
    end
    self.panels = {}

    for _, item in pairs(self.btnList) do
        item:destroy()
    end
    self.btnList = {}


    --for _, item in pairs(self.money_list) do
    --    item:destroy()
    --end
    --self.money_list= {}
end

function IllustratedMainPanel:LoadCallBack()
    self.nodes = {
        "closeBtn","ScrollView/Viewport/btnListItemContent","SevenDayPetPageItem","ScrollView","panelParent","SevenDayActivePanel","money_con"
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if self.btnList[self.index] then
        self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
    else
        Notify.ShowText("All events are over")
    end

    -- self:SetMoney(self.is_show_money)
end

function IllustratedMainPanel:InitUI()
    local index = 0
    for i = 1, #self.sevenDayType do
        local type = self.sevenDayType[i].id
        local id  = OperateModel:GetInstance():GetActIdByType(type)
        if OperateModel:GetInstance():IsActOpenByTime(id) then
            index = index + 1
            self.btnList[index] = SevenDayPetPageItem(self.SevenDayPetPageItem.gameObject,self.btnListItemContent,"UI")
            self.btnList[index]:SetData(self.sevenDayType[i],id)
            -- print2(index,id)
        end
    end
    self:RedPointInfo()
end

function IllustratedMainPanel:AddEvent()

    local function close_callback(target, x, y)
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject, close_callback)

    self.events[#self.events + 1] = GlobalEvent:AddListener(SevenDayActiveEvent.SevenDayPetClickPageItem, handler(self, self.SevenDayPetClickPageItem))
    -- self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(SevenDayActiveEvent.RedPointInfo, handler(self, self.RedPointInfo))


    local function call_back()
        self.index = 1
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(SevenDayActiveEvent.OpenIllustratedRankPanel, call_back)
    local function call_back()
        self.index = 2
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(SevenDayActiveEvent.OpenIllustratedBuyPanel, call_back)
    local function call_back()
        self.index = 3
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(SevenDayActiveEvent.OpenIllustratedRechargePanel, call_back)
    local function call_back()
        self.index = 4
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(SevenDayActiveEvent.OpenIllustratedTargetPanel, call_back)
    local function call_back()
        self.index = 5
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(SevenDayActiveEvent.OpenIllustratedBoxPanel, call_back)


    --local function call_back()
    --    lua_panelMgr:GetPanelOrCreate(SevenDayPetBuyPanel):Open(6)
    --end
    --GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayBuyPanel, call_back)
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(SevenDayActiveEvent.PetRedPointInfo, handler(self, self.RedPointInfo))
    self.events[#self.events + 1] =  GlobalEvent:AddListener(SevenDayActiveEvent.PetRedPointInfo, handler(self, self.RedPointInfo))
end

-- 只有 连冲跟目标有红点要求
function IllustratedMainPanel:RedPointInfo()
    local is_show = false
    local is_showTarget = false
    local is_showRechage = false

    local targetData = OperateModel:GetInstance():GetActInfo(174300)
    if targetData then
		for i, v in pairs(targetData.tasks) do
			if v.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
				is_showTarget = true
				is_show = true
				break
			end
		end
    end

    local rechageData1 =  NationModel.GetInstance():GetIllRewaCfByActId(174201)
    if rechageData1 then
        for i = 1, #rechageData1 do
            local con = NationModel.GetInstance():GetSingleTaskInfo(174201, rechageData1[i].id)
            if con.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                is_showRechage = true
                is_show = true
                break
            end
        end
    end

    if not is_showRechage then
        local rechageData2 =  NationModel.GetInstance():GetAcIllRewaCf(174200)
        if rechageData2 then
            for i = 1, #rechageData2 do
                for j = 1, 3 do
                    local con = NationModel.GetInstance():GetSingleTaskInfo(174200, rechageData2[i][j].id)
                    if con.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                        is_showRechage = true
                        is_show = true
                        break
                    end
                end
            end
        end

    end

    for i, v in pairs(self.btnList) do
        if v.actId == 174300 then
            v:SetRedPoint(is_showTarget)
        end
        if v.actId == 174200 then
            v:SetRedPoint(is_showRechage)
        end
    end

    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "cardcele", is_show)
end

function IllustratedMainPanel:SetMoney(list)
    if table.isempty(list) then
        return
    end
    self.money_list = {}
    local offX = 220
    for i = 1, #list do
        local item = MoneyItem(self.money_con, nil, list[i])
        local x = (i - #list) * offX
        local y = 0
        item:SetPosition(x, y)
        self.money_list[i] = item
    end
end

function IllustratedMainPanel:SevenDayPetClickPageItem(id,actId)
    if self.panelType == id then
        return
    end
    self.panelType = id
    self:SwitchSubView(actId)
    for i, v in pairs(self.btnList) do
        if v.data.id == id then
            v:SetSeletc(true)
        else
            v:SetSeletc(false)
        end
    end
end


function IllustratedMainPanel:SwitchSubView(actId)
    if self.currentView then
        --    self.currentView:destroy()
        --self.currentView:SetVisible(false)
        self.currentView = nil
    end

    if self.panels[self.panelType] then
        self.currentView = self.panels[self.panelType]
    else
        local p
        local asset
        if self.panelType == 740 then       --  图鉴冲榜
            asset = "IllustratedRankView"
            p = SevenDayPetRankPanel(self.panelParent, self, actId, asset)
        elseif self.panelType == 741 then   -- 图鉴限购
            asset = "IllustratedBuyView"
            p = SevenDayPetBuyPanel(self.panelParent, self,actId, asset)
        elseif self.panelType == 742 then   -- 图鉴连充
            local abName = "sevenDayActive"
            asset = "IllustrateRechargeView"
            p = NationSeqRechargeView(self.panelParent,"UI", self, actId, abName,asset)
        elseif self.panelType == 743 then
            asset = "IllustratedTargetView"   --图鉴目标
            p = SevenDayPetTargetPanel(self.panelParent, self,actId, asset)
        elseif self.panelType == 744 then
            asset = "IllustratedBoxView"      -- 图鉴宝箱
            p = SevenDayPetBoxPanel(self.panelParent, self,actId, asset)
        end

        self.panels[self.panelType] = p
        self.currentView = p
    end

    if self.currentView then
        self:PopUpChild(self.currentView)
    end
end


