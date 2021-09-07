-- @author zgs
FirstRechargeModel = FirstRechargeModel or BaseClass(BaseModel)

function FirstRechargeModel:__init()
    self.gaWin = nil
    self.petShow = nil
    self.listener = function() self:OnRoleLevelUp() end
    self.mainListener = function() self:MainUiLoad() end
    EventMgr.Instance:AddListener(event_name.mainui_loaded, self.mainListener)
end

function FirstRechargeModel:__delete()
    if self.gaWin then
        self.gaWin = nil
    end
end

function FirstRechargeModel:MainUiLoad()
    EventMgr.Instance:RemoveListener(event_name.mainui_loaded, self.mainListener)
    if RoleManager.Instance.RoleData.lev < 6 then
        EventMgr.Instance:AddListener(event_name.role_level_change, self.listener)
    end
end

function FirstRechargeModel:OnRoleLevelUp()
    if RoleManager.Instance.RoleData.lev >= 6  and FirstRechargeManager.Instance:isHadDoFirstRecharge() == false then
        EventMgr.Instance:RemoveListener(event_name.role_level_change, self.listener)
        self:OpenPetShow()
    end

end

function FirstRechargeModel:OpenWindow(args)
    if self.gaWin == nil then
        -- self.gaWin = FirstRechargeWindow.New(self)
        self.gaWin = FirstRechargeDevelopWindow.New(self)
    end
    self.gaWin:Open(args)
end

function FirstRechargeModel:CloseMain()
    WindowManager.Instance:CloseWindow(self.gaWin, true)
end

function FirstRechargeModel:GetDataItem(index)
    -- body
    local rewardList = CampaignManager.ItemFilter(DataCampaign.data_list[1].reward)
    local baseId = rewardList[index][1]
    local cnt = rewardList[index][2]
    local dataItem ={baseData =  DataItem.data_get[baseId],count = cnt}
    return dataItem
end

function FirstRechargeModel:OpenPetShow()
    if self.petShow == nil then
        self.petShow = FirstRechargePetShowPanel.New(self)
    end
    self.petShow:Show()
end

function FirstRechargeModel:ClosePetShow()
    if self.petShow ~= nil then
        self.petShow:DeleteMe()
        self.petShow = nil
    end
end

function FirstRechargeModel:OpenContinueCharge(args)
    if self.continueWin == nil then
        self.continueWin = ContinueChargeWindow.New(self)
    end
    self.continueWin:Open(args)
end
