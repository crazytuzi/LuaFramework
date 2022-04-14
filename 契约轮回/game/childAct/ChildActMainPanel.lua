--- Created by Admin.
--- DateTime: 2019/12/18 19:43

ChildActMainPanel = ChildActMainPanel or class("ChildActMainPanel", BasePanel)
local this = ChildActMainPanel

function ChildActMainPanel:ctor()
    self.abName = "sevenDayActive"
    self.assetName = "IllustratedMainPanel"
    self.image_ab = "sevenDayActive_image";
    self.layer = "UI"
    self.events = {}
    self.modelEvents = {}
    self.selectedId = -1;
    self.use_background = true
    self.show_sidebar = false

    self.panels = {}
    self.panelType =  -1
    self.btnList = {}
    self.sevenDayType = {
        { text = ConfigLanguage.Illustrated.Rank, id = 770 },
        { text = ConfigLanguage.Illustrated.Buy, id = 771},
        { text = ConfigLanguage.Illustrated.Recharge, id = 772 },
        { text = ConfigLanguage.Illustrated.Target, id = 773 },
        { text = ConfigLanguage.Illustrated.Box, id = 774 },
        { text = ConfigLanguage.Illustrated.Box, id = 777 },
    }
    self.model = ChildActModel.GetInstance()
end

function ChildActMainPanel:dctor()
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
    if self.currentView then
        self.currentView:destroy()
        self.currentView = nil
    end
	
end

function ChildActMainPanel:Open(idx)
    self.index = idx
    WindowPanel.Open(self)
end

function ChildActMainPanel:LoadCallBack()
    self.nodes = {
        "closeBtn","ScrollView/Viewport/btnListItemContent","SevenDayPetPageItem",
        "ScrollView","panelParent","SevenDayActivePanel","money_con","titlepanel/title",
    }
    self:GetChildren(self.nodes)
    self.titleBg = GetImage(self.title)
	
    self:InitUI()
    self:AddEvent()

    if self.btnList[self.index] then
        self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
    else
        Notify.ShowText("All events are over")
    end
	
	local res = "act_1"
	lua_resMgr:SetImageTexture(self, self.titleBg, "sevenDayActive_image", res, true, nil, false)
end

function ChildActMainPanel:AddEvent()

    local function close_callback(target, x, y)
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject, close_callback)

    self.events[#self.events + 1] = GlobalEvent:AddListener(SevenDayActiveEvent.SevenDayPetClickPageItem, handler(self, self.SevenDayPetClickPageItem))
    self.events[#self.events + 1] = self.model:AddListener(SevenDayActiveEvent.RedPointInfo, handler(self, self.RedPointInfo))


    local function call_back()
        self.index = 1
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(ChildActEvent.OpenChildRankPanel, call_back)
    local function call_back()
        self.index = 2
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(ChildActEvent.OpenChildBuyPanel, call_back)
    local function call_back()
        self.index = 3
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(ChildActEvent.OpenChildRechargePanel, call_back)
    local function call_back()
        self.index = 4
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(ChildActEvent.OpenChildTargetPanel, call_back)
    local function call_back()
        self.index = 5
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(ChildActEvent.OpenChildBoxPanel, call_back)

    local function call_back()
        self.index = 6
        if self.btnList[self.index] then
            self:SevenDayPetClickPageItem(self.btnList[self.index].data.id,self.btnList[self.index].actId) --默认选择第一个
        else
            Notify.ShowText("All events are over")
        end

    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(ChildActEvent.OpenChildShopPanel, call_back)


    --local function call_back()
    --    lua_panelMgr:GetPanelOrCreate(SevenDayPetBuyPanel):Open(6)
    --end
    --GlobalEvent:AddListener(SevenDayActiveEvent.OpenSevenDayBuyPanel, call_back)
    self.events[#self.events + 1] =  GlobalEvent:AddListener(ChildActEvent.UpdateMainRed, handler(self, self.RedPointInfo))
end


function ChildActMainPanel:InitUI()
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

function ChildActMainPanel:RedPointInfo()
    local is_show = false
    local is_showTarget = false
    local is_showRechage = false
	local is_exchange = false

    local targetData = OperateModel:GetInstance():GetActInfo(277300)
    if targetData then
        for i, v in pairs(targetData.tasks) do
            if v.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                is_showTarget = true
                is_show = true
                break
            end
        end
    end

    local rechageData1 = self.model:GetIllRewaCfByActId(277600)
    if rechageData1 then
        for i = 1, #rechageData1 do
            local con = self.model:GetSingleTaskInfo(277600, rechageData1[i].id)
            if con.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                is_showRechage = true
                is_show = true
                break
            end
        end
    end

    if not is_showRechage then
        local rechageData2 =  self.model:GetAcIllRewaCf(277200)
        if rechageData2 then
            for i = 1, #rechageData2 do
                for j = 1, 3 do
                    local con = self.model:GetSingleTaskInfo(277200, rechageData2[i][j].id)
                    if con and con.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                        is_showRechage = true
                        is_show = true
                        break
                    end
                end
            end
        end

    end

	
	local id = 277700
	local num = BagModel.GetInstance():GetItemNumByItemID(13141)
	local list = OperateModel.GetInstance():GetRewardConfig(id)
	local act_info = OperateModel:GetInstance():GetActInfo(id)
	if not act_info then
		return
	end
	local info_list = act_info.tasks
	local is_show = false
	for i = 1, #list do
		local data = list[i]
		local info = self.model:GetExchangeTaskInfo(info_list, data.id)
		if info then
			local cur_ex_count = info.count
			local limit = String2Table(data.limit)[2]
			local need_num = String2Table(data.cost)[1][2]
				--有剩余兑换数量
			if cur_ex_count < limit then
				if num >= need_num then
					is_show = true
					is_exchange = true 
					break
				end
			end
		end
	end
	
	
    for i, v in pairs(self.btnList) do
        if v.actId == 277300 then
            v:SetRedPoint(is_showTarget)
        end
        if v.actId == 277200 then
            v:SetRedPoint(is_showRechage)
        end
		if v.actId == 277700 then
			v:SetRedPoint(is_exchange)
		end
    end

    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "soncele", is_show)
end


function ChildActMainPanel:SevenDayPetClickPageItem(id,actId)
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


function ChildActMainPanel:SwitchSubView(actId)
    if self.currentView then
		self.currentView:destroy()
        self.currentView = nil
    end

    local p
    local asset
    if self.panelType == 770 then   -- 排行榜
        local id  = OperateModel:GetInstance():GetActIdByType(775)
        p = ChildActRankPanel(self.panelParent,actId, id)
    elseif self.panelType == 771 then   -- 图鉴限购
        asset = "ChildActBuyView"
        p = ChildActBuyPanel(self.panelParent, self,actId, asset)
    elseif self.panelType == 772 then   -- 图鉴连充
        local abName = "sevenDayActive"
        asset = "IllustrateRechargeView"
        p = ChildActRecPanel(self.panelParent,"UI", self, actId, abName, asset)
    elseif self.panelType == 773 then
        asset = "ChildActTargetView"   --图鉴目标
        p = ChildActTargetPanel(self.panelParent, self,actId, asset)
    elseif self.panelType == 774 then
        asset = "ChildActBoxView"      -- 图鉴宝箱
        p = ChildActBoxPanel(self.panelParent, self,actId, asset)
    elseif self.panelType == 777 then
        asset = "ChildActExchangeView"      -- 兑换
        p = ChildActExchangePanel(self.panelParent, self, actId, asset)
    end

    self.currentView = p
end


function ChildActMainPanel:InitPanel()
end


function ChildActMainPanel:CloseCallBack()

end