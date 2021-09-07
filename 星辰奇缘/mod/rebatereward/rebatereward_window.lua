-- @author zyh
--@date 2017
RebateRewardWindow = RebateRewardWindow or BaseClass(BaseWindow)

function RebateRewardWindow:__init(model)
	self.model = model
	self.mgr = RebateRewardManager.Instance

	self.windowId = WindowConfig.WinID.rebatereward_window

	self.resList = {
       {file = AssetConfig.rebatereward_window,type = AssetType.Main}
       ,{file = AssetConfig.rebatereward_texture,type = AssetType.Dep}
       ,{file = AssetConfig.newmoon_textures,type = AssetType.Dep}
       ,{file = AssetConfig.rebatereward_bigbg,type = AssetType.Main}
       ,{file = AssetConfig.RebateRewardBgText1,type = AssetType.Dep}
       ,{file = AssetConfig.RebateRewardBgText3,type = AssetType.Dep}
       -- ,{file = AssetConfig.RebateRewardBgText5,type = AssetType.Dep}
       -- ,{file = AssetConfig.RebateRewardBgText6,type = AssetType.Dep}
       ,{file = AssetConfig.RebateRewardBgText7,type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function()
      self:OnOpen()
    end)

    self.OnHideEvent:AddListener(function()
      self:OnHide()
    end)

    self.updateListener = function() self:SendHandle() end
    self.updateDataListener = function() self:SetBaseData() end

    self.textObjsList = {}
    self.messageList = {}
    self.dataList = {}
    self.textLayout = nil
end


function RebateRewardWindow:__delete()
	self:RemoveListeners()
	WindowManager.Instance.currentWin = nil

    if self.effTimerId ~= nil then
    	LuaTimer.Delete(self.effTimerId)
    	self.effTimerId = nil
    end
    if self.messageList ~= nil then
    	for i,v in ipairs(self.messageList) do
    		v:DeleteMe()
    	end
    	self.messageList = {}
    end

	for i,v in ipairs(self.messageList) do
		v:Delete()
	end

	if self.textLayout ~= nil then
		self.textLayout:DeleteMe()
		self.textLayout = nil
	end

	if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RebateRewardWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rebatereward_window))
	self.gameObject.name = "RebateRewardWindow"
	self.transform = self.gameObject.transform
    self.transform:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function()
   	  self.model:CloseWindow()
   end)
	UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    self.bigBg = self.transform:Find("MainCon/Bg/BigBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.rebatereward_bigbg))
    UIUtils.AddBigbg(self.bigBg, bigObj)

    bigObj.transform.anchoredPosition = Vector2(0,0)

    self.textContainer = self.transform:Find("MainCon/TextContainer")
    self.textLayout = LuaBoxLayout.New(self.textContainer.gameObject,{axis = BoxLayoutAxis.Y, cspacing = 3,border = 10})

	self.textTemplate = self.transform:Find("MainCon/TextTemplate")
	self.textTemplate.gameObject:SetActive(false)
    self.noticeBtn = self.transform:Find("Notice").gameObject:GetComponent(Button)
    self.noticeBtn.onClick:RemoveAllListeners()
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)



    -- self.noticeTextTemplate = GameObject.Instantiate(self.textTemplate.gameObject)
    -- self.noticeTextTemplate.transform:SetParent(self.transform:Find("MainCon"))
    -- self.noticeTextTemplate.transform.localScale = Vector3(1,1,1)
    -- self.noticeTextTemplate.transform.localPosition = Vector3(0,0,0)
    -- self.noticeTextTemplate.transform.anchoredPosition = Vector2(45,-235)

    -- self.noticeTextTemplate.transform:Find("Text"):GetComponent(Text).text = TI18N("<color='#13FC60'>温馨提示:本活动与限时特惠共存时，优先触发本活动</color>")
    -- self.noticeTextTemplate.transform:Find("Text"):GetComponent(Text).fontSize = 15
    -- local color = Color(0,0,0,0)
    -- self.noticeTextTemplate.transform:GetComponent(Image).color = color
    -- self.noticeTextTemplate.gameObject:SetActive(true)



	self.rechargeButton = self.transform:Find("MainCon/Recharge"):GetComponent(Button)
	self.rechargeButton.onClick:AddListener(function() self:ApplyRechargeButton() end)
    self.noticeText = self.transform:Find("MainCon/Bg/NoticeBg/Text"):GetComponent(Text)
    self.dataList = ShopManager.Instance:GetDataList()
    local firstDataId = self.dataList[1].id
    if firstDataId ~= nil then
        self.noticeText.text = string.format(TI18N("活动时间：%d/%d-%d/%d"),DataCampaign.data_list[firstDataId].cli_start_time[1][2],DataCampaign.data_list[firstDataId].cli_start_time[1][3],DataCampaign.data_list[firstDataId].cli_end_time[1][2],DataCampaign.data_list[firstDataId].cli_end_time[1][3])
    end

    self.bigText1 = self.transform:Find("MainCon/Bg/TextBig"):GetComponent(Image)
    self.bigText2 = self.transform:Find("MainCon/Bg/TextBg/TextImg"):GetComponent(Image)
    self.bigText3 = self.transform:Find("MainCon/Grild"):GetComponent(Image)

    self.bigText1.sprite = self.assetWrapper:GetSprite(AssetConfig.RebateRewardBgText1,"RebateRewardBg")
    self.bigText2.sprite = self.assetWrapper:GetSprite(AssetConfig.RebateRewardBgText7,"RebateTitle5")
    self.bigText2:SetNativeSize()
    self.bigText3.sprite = self.assetWrapper:GetSprite(AssetConfig.RebateRewardBgText3,"Witch")

	-- for i = 1,10 do
	-- 	local textObj = self.textContainer.GetChild(i - 1).transform:GetComponent(Text)
	-- 	self.textObjsList[i] = textObj
	-- end
	self.OnOpenEvent:Fire()
end


function RebateRewardWindow:OnOpen()
	ShopManager.Instance:send9937()
	self:CloseRedPoint()
    self.campId = self.openArgs[1] or 991

    self.dataList = ShopManager.Instance:GetDataList()
    --BaseUtils.dump("RebateRewardWindow.dataList",self.dataList)
	self:AddListeners()

	self.effTimerId = LuaTimer.Add(1000, 3000, function()
            self.rechargeButton.gameObject.transform.localScale = Vector3(1.1,1.1,1)
            Tween.Instance:Scale(self.rechargeButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    end)
end


function RebateRewardWindow:AddListeners()
	ShopManager.Instance.onUpdateRebateReward:AddListener(self.updateListener)
	CampaignManager.Instance.onUpdateRecharge:AddListener(self.updateDataListener)
end

function RebateRewardWindow:RemoveListeners()
	ShopManager.Instance.onUpdateRebateReward:RemoveListener(self.updateListener)
	CampaignManager.Instance.onUpdateRecharge:RemoveListener(self.updateDataListener)
end

function RebateRewardWindow:SendHandle()
     CampaignManager.Instance:Send14000()
end
function RebateRewardWindow:SetBaseData()
	-- self.textLayout = LuaBoxLayout.New(self.textContainer.gameObject,{axis = BoxLayoutAxis.Y, cspacing = 3,border = -5})
 --    local model = ShopManager.Instance.model
 --    BaseUtils.dump(ShopManager.Instance.model.chargeList,"布置好的数据")
 --    local monthGold = 0
	-- for i,v in ipairs(model.chargeList) do
 --        if v.gold ~= monthGold and self.dataList[i] ~= nil and CampaignManager.Instance.campaignData[i].reward_can > 0 then

 --        	if self.messageList[i] == nil then
 --        		if self.textObjsList[i] == nil then
 --        			self.textObjsList[i] = GameObject.Instantiate(self.textTemplate.gameObject)
 --        			self.textLayout:Add(self.textObjsList[i].gameObject)
 --        		end
 --        		self.textObjsList[i].gameObject:SetActive(true)

 --        		local msg = MsgItemExt.New(self.textObjsList[i].transform:Find("Text"),500,18,21)
 --        		self.messageList[i] = msg
 --            end

 --        	if ShopManager.Instance.rechargeLogRed[v.gold] == nil then
 --        		local str = string.format(TI18N("充值%s元 = %s{assets_2,90039} + %s{assets_2,90039}(额外赠送%s{assets_2,90039}剩余%s次)"),self.dataList[i].camp_cond[1] / 10,self.dataList[i].camp_cond[1] + self.dataList[i].camp_cond[2],data.gold,self.dataList[i].camp_cond[2],CampaignManager.Instance.campaignData[i].reward_can)
 --        	else
 --                local str = string.format(TI18N("充值%s元 = %s{assets_2,90039}(额外赠送%s{assets_2,90039}剩余%s次)"),self.dataList[i].camp_cond[1] / 10,self.dataList[i].camp_cond[1] + self.dataList[i].camp_cond[2],self.dataList[i].camp_cond[2],CampaignManager.Instance.campaignData[i].reward_can)
 --        	end
 --            self.messageList[i]:SetData(str)
 --        else
 --        	if self.textObjsList[i] ~= nil then
 --        		self.textObjsList[i].gameObject:SetActive(false)
 --        	end
 --        end
 --    end
    ShopManager.Instance.model.chargeList = ShopManager.Instance.model:GetChargeList()
    local length = 0
	for i,v in ipairs(self.dataList) do
        -- print("我进来了循环这里")
		-- if CampaignManager.Instance.campaignData[i].reward_can > 0 then
			length = length + 1
    		if self.messageList[length] == nil then
	    		if self.textObjsList[length] == nil then
	    			self.textObjsList[length] = GameObject.Instantiate(self.textTemplate.gameObject)
	    			self.textLayout:AddCell(self.textObjsList[length].gameObject)
	    		end

	    		local msg = MsgItemExt.New(self.textObjsList[length].transform:Find("Text"):GetComponent(Text),500,18,21)
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
	        local str = nil
	    	if ShopManager.Instance.model.rechargeLogRed[tokesData.gold] == nil then
                if self.dataList[i].camp_cond[1][4] == 1 then
	    		    str = string.format(TI18N("充值<color='#ffff00'>%d</color>元<color='#ffff00'>=%d</color>{assets_2,90002}(活动赠送<color='#ffff00'>%d</color>{assets_2,90002}剩余<color='#2fc823'>%d</color>次)"),self.dataList[i].camp_cond[1][1] / 10,self.dataList[i].camp_cond[1][1] + self.dataList[i].camp_cond[1][2],self.dataList[i].camp_cond[1][2],CampaignManager.Instance.campaignData[i].reward_can)
                elseif self.dataList[i].camp_cond[1][4] == 2 then
                     -- str = string.format(TI18N("充值<color='#ffff00'>%d</color>元<color='#ffff00'>=%d</color>{assets_2,90002}(额外赠送<color='#ffff00'>%d</color>{assets_2,90002}剩余<color='#2fc823'>%d</color>次)"),self.dataList[i].camp_cond[1][1] / 10,self.dataList[i].camp_cond[1][1] + self.dataList[i].camp_cond[1][2],self.dataList[i].camp_cond[1][2],CampaignManager.Instance.campaignData[i].reward_can)


                    str = string.format(TI18N("充值<color='#ffff00'>%d</color>元<color='#ffff00'>=%d</color>{assets_2,90002}+<color='#ffff00'>%d</color>{assets_2,90026}(活动赠送<color='#ffff00'>%d</color>{assets_2,90026}剩余<color='#2fc823'>%d</color>次)"),self.dataList[i].camp_cond[1][1] / 10,self.dataList[i].camp_cond[1][1],self.dataList[i].camp_cond[1][2],self.dataList[i].camp_cond[1][2],CampaignManager.Instance.campaignData[i].reward_can)
                end
	    	else
                if self.dataList[i].camp_cond[1][4] == 1 then
	    		     str = string.format(TI18N("充值<color='#ffff00'>%d</color>元<color='#ffff00'>=%d</color>{assets_2,90002}(活动赠送<color='#ffff00'>%d</color>{assets_2,90002}剩余<color='#2fc823'>%d</color>次)"),self.dataList[i].camp_cond[1][1] / 10,self.dataList[i].camp_cond[1][1] + self.dataList[i].camp_cond[1][2],self.dataList[i].camp_cond[1][2],CampaignManager.Instance.campaignData[i].reward_can)
                elseif self.dataList[i].camp_cond[1][4] == 2 then
                     str = string.format(TI18N("充值<color='#ffff00'>%d</color>元<color='#ffff00'>=%d</color>{assets_2,90002}+<color='#ffff00'>%d</color>{assets_2,90026}(活动赠送<color='#ffff00'>%d</color>{assets_2,90026}剩余<color='#2fc823'>%d</color>次)"),self.dataList[i].camp_cond[1][1] / 10,self.dataList[i].camp_cond[1][1],self.dataList[i].camp_cond[1][2],self.dataList[i].camp_cond[1][2],CampaignManager.Instance.campaignData[i].reward_can)
                end
	    	end
	        self.messageList[length]:SetData(str)
	    -- end
    end

    if #self.textObjsList > length then
    	for i=length + 1,#self.textObjsList do
    		self.textObjsList[i].gameObject:SetActive(false)
    	end
    end

    for i=1,length do
    	self.textObjsList[i].transform.anchoredPosition = Vector2(-10*i,self.textObjsList[i].transform.anchoredPosition.y)
    end

    -- for self.
end

function RebateRewardWindow:ApplyRechargeButton()
	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3})
end

function RebateRewardWindow:CloseRedPoint()
    local str = "init"
    local temData = DataCampaign.data_list[607]
    RebateRewardManager.Instance.redPointDic[temData.index] = false
    local roledata = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id,607)
    PlayerPrefs.SetString(key,str)
 	RebateRewardManager.Instance:CheckRedPoint()
end

function RebateRewardWindow:OnNotice()
    -- print(self.campId)
    -- print(DataCampaign.data_list[self.campId].cond_desc)
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {DataCampaign.data_list[self.campId].cond_desc}})
end

