-- @author hze
-- @date #2018/06/26#
--新充值返利

NewRebatePanel = NewRebatePanel or BaseClass(BasePanel)

function NewRebatePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "NewRebatePanel"

    self.resList = {
        {file = AssetConfig.newrebatepanel, type = AssetType.Main}
        ,{file = AssetConfig.newrebatebg, type = AssetType.Main}
        ,{file = AssetConfig.newrebatedesc, type = AssetType.Main}
        ,{file = AssetConfig.rebatereward_texture,type = AssetType.Dep}
        ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
        ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}
    }

    self.str = TI18N("充值<color='#ffff00'>%d</color>元送<color='#ffff00'>%d</color>{assets_2,90002}(剩余<color='#ffff00'>%d</color>次)")

    self.messageList = {}
    self.textObjsList = {}

    self.updateListener = function() self:SendHandle() end
    self.updateDataListener = function() self:SetBaseData() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NewRebatePanel:__delete()
    self.OnHideEvent:Fire()



    if self.messageList ~= nil then
        for i,v in ipairs(self.messageList) do
            v:DeleteMe()
        end
        self.messageList = {}
    end



    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NewRebatePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newrebatepanel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    UIUtils.AddBigbg(t:Find("BgImage"), GameObject.Instantiate(self:GetPrefab(AssetConfig.newrebatebg)))
    UIUtils.AddBigbg(t:Find("CenterImage"), GameObject.Instantiate(self:GetPrefab(AssetConfig.newrebatedesc)))

    self.houtTxt = self.transform:Find("TimeArea/TimeHour/HourText"):GetComponent(Text)
    self.minTxt = self.transform:Find("TimeArea/TimeMin/MinText"):GetComponent(Text)
    self.secTxt = self.transform:Find("TimeArea/TimeSec/SecText"):GetComponent(Text)

    self.textContainer = self.transform:Find("TextContainer")
    self.textLayout = LuaBoxLayout.New(self.textContainer.gameObject,{axis = BoxLayoutAxis.Y, cspacing = 3,border = 13})

    self.textTemplate = self.transform:Find("TextTemplate")
    self.textTemplate.gameObject:SetActive(false)


    self.rechargeButton = self.transform:Find("Button"):GetComponent(Button)
    self.rechargeButton.onClick:AddListener(function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
        end)

    self.descTxt = self.transform:Find("DescText"):GetComponent(Text)

    self.slider = self.transform:Find("Slider"):GetComponent(Slider)
    self.slider.interactable = false
    self.handleObj = self.transform:Find("Slider/Handle Slide Area/Handle")

    self.effect =  BaseUtils.ShowEffect(20161, self.handleObj, Vector3(1, 1, 1), Vector3(0, 0, -400))

    self.effTimerId = LuaTimer.Add(1000, 3000, function()
        self.rechargeButton.gameObject.transform.localScale = Vector3(1.2,1.1,1)
        Tween.Instance:Scale(self.rechargeButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
     end)
end

function NewRebatePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NewRebatePanel:OnOpen()
    self:RemoveListeners()
    ShopManager.Instance.onUpdateRebateReward:AddListener(self.updateListener)
    CampaignManager.Instance.onUpdateRecharge:AddListener(self.updateDataListener)

    ShopManager.Instance:send9937()

    self.descTxt.text = DataCampaign.data_list[self.campId].cond_desc

    self:updateTime()
end

function NewRebatePanel:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

end

function NewRebatePanel:RemoveListeners()
    ShopManager.Instance.onUpdateRebateReward:RemoveListener(self.updateListener)
    CampaignManager.Instance.onUpdateRecharge:RemoveListener(self.updateDataListener)
end

function NewRebatePanel:SendHandle()
     CampaignManager.Instance:Send14000()
end

function NewRebatePanel:SetBaseData()
    ShopManager.Instance.model.chargeList = ShopManager.Instance.model:GetChargeList()
    
    local length = 0
    for i,v in ipairs(self.dataList) do
            length = length + 1
            if self.messageList[length] == nil then
                if self.textObjsList[length] == nil then
                    self.textObjsList[length] = GameObject.Instantiate(self.textTemplate.gameObject)
                    self.textLayout:AddCell(self.textObjsList[length].gameObject)
                end

                local msg = MsgItemExt.New(self.textObjsList[length].transform:Find("Text"):GetComponent(Text),272,18,21)
                self.messageList[length] = msg
            else
                self.textObjsList[length].gameObject:SetActive(true)
            end

            local tokesData = nil

            for i2,v2 in ipairs(ShopManager.Instance.model.chargeList) do

                if v2.gold == self.dataList[i].camp_cond[1][1] then
                    tokesData = v2
                end
            end
            local str = string.format(self.str, self.dataList[i].camp_cond[1][1] / 10, self.dataList[i].camp_cond[1][3] / 1000 * self.dataList[i].camp_cond[1][1], CampaignManager.Instance.campaignData[i].reward_can)
            self.messageList[length]:SetData(str)
    end

    if #self.textObjsList > length then
        for i=length + 1,#self.textObjsList do
            self.textObjsList[i].gameObject:SetActive(false)
        end
    end

    local t_length = math.floor(length / 2) 
    for i=1,length do
        if i <= t_length then    
            self.textObjsList[i].transform.anchoredPosition = Vector2(-10*i,self.textObjsList[i].transform.anchoredPosition.y)
        else
            self.textObjsList[i].transform.anchoredPosition = Vector2(-10*(length - i + 1),self.textObjsList[i].transform.anchoredPosition.y)
        end 
        
    end
end



function NewRebatePanel:updateTime()
    local campaignData = DataCampaign.data_list[self.campId]

    local startTime = campaignData.cli_start_time[1]
    local endTime = campaignData.cli_end_time[1]

    self.timeTemp = Time.time -- 当前时间
    self.timeT = Time.time --上次的时间

    local end_time = nil
    local start_time = nil
    if endTime[1] == nil then
        end_time = CampaignManager.Instance.open_srv_time + endTime[2] * 86400 + endTime[3]
        start_time = CampaignManager.Instance.open_srv_time + startTime[2] * 86400 + startTime[3]
    else
        end_time = os.time{year = endTime[1], month = endTime[2], day = endTime[3], hour = endTime[4], min = endTime[5], sec = endTime[6]}
        start_time = os.time{year = startTime[1], month = startTime[2], day = startTime[3], hour = startTime[4], min = startTime[5], sec = startTime[6]}
    end
    self.countData = end_time - BaseUtils.BASE_TIME


    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    self.timerId = LuaTimer.Add(0, 1000, function()
        if self.countData > 0 then
            self.timeTemp = Time.time
            self.countData = self.countData - (self.timeTemp - self.timeT)
            self.timeT = Time.time

            if self.slider ~= nil then
                self.slider.value = self.countData / (end_time - start_time)
            end

            local day,hour,min,second = BaseUtils.time_gap_to_timer(math.floor(self.countData))
            local hour = hour + day * 24
            if hour < 10 then
                self.houtTxt.text = string.format("0%d",hour)
            else
                self.houtTxt.text = string.format("%d",hour)
            end
            if min > 9 then
                self.minTxt.text = string.format("%d",min)
            else
                self.minTxt.text = string.format("0%d",min)
            end
            if second > 9 then
                self.secTxt.text = string.format("%d",second)
            else
                self.secTxt.text = string.format("0%d",second)
            end
        else
            self.slider.value = 0
            self.houtTxt.text = string.format("00")
            self.minTxt.text = string.format("00")
            self.secTxt.text = string.format("00")
            if self.timerId ~= nil then
                LuaTimer.Delete(self.timerId)
                self.timerId = nil
            end
        end
    end)
end
