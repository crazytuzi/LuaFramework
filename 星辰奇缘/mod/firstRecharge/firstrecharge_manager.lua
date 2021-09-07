--首充
-- @author zgs
FirstRechargeManager = FirstRechargeManager or BaseClass(BaseManager)

function FirstRechargeManager:__init()
    if FirstRechargeManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    FirstRechargeManager.Instance = self
    -- self:initHandle()
    self.model = FirstRechargeModel.New()

    self.rewardDic = {} --活动奖励列表  (id,  "活动ID")
    self.campDic = {}   --活动列表      (id, "活动图标ID")
    self.isFirstClick = false
    -- self.updateIcon = function() self:SendHandle() end
    self.updateIcon = function() self:UpdateIcon() end
    self.updateIconSecond = function() self:UpdateIcon()end

    self.iconData = nil
    self.iconData2 = nil

    self.level=
    { [1] = 10,
      [2] = 40,
      [3] = 70,
      [4] = 95,

    }

end

function FirstRechargeManager:initHandle()
    --[[self:AddNetHandler(11300, self.on11300)--]]
    -- self:AddNetHandler(14000, self.on14000)
    -- self:AddNetHandler(14001, self.on14001)
    -- self:AddNetHandler(14002, self.on14002)
    -- self:AddNetHandler(14003, self.on14003)
    -- self:AddNetHandler(14004, self.on14004)

    -- EventMgr.Instance:AddListener(event_name.mainui_btn_init, function ()
        -- self:send14003()
        -- self:send14000()
    -- end)

--[[
    EventMgr.Instance:AddListener(event_name.role_asset_change, function ()
        self:RoleAssetsListener()
    end)--]]

end

function FirstRechargeManager:on14000(data)
    --BaseUtils.dump(data, "on14000")
    self.rewardDic= nil
    self.rewardDic = {}
    for i,v in ipairs(data.reward_list) do
        self.rewardDic[v.id] = v
    end
    -- self:SetMainUIActiveIconVisible()

    self:CheckShopRedPoint()
end

function FirstRechargeManager:on14001(data)
    --BaseUtils.dump(data, "on14001")
    if data.flag == 1 then
        --成功
        local activeId = data.id
        local activeItem = DataCampaign.data_list[activeId]
        if activeItem ~= nil then
            if (tonumber(activeItem.iconid)) == CampaignEumn.Type.FirstRecharge then --首充
                 self.model:CloseMain()
                 --播飞入动画
            elseif (tonumber(activeItem.iconid)) == CampaignEumn.Type.Rebate then --充值返利
                if ShopManager.Instance.model.shopWin ~= nil then
                    ShopManager.Instance.model.shopWin:UpdateRTPanel()
                end
            end
        else
            Log.Error(string.format("DataCampaign缺少ID=%d", activeId))
        end
    else
        --失败
    end
end

function FirstRechargeManager:on14002(data)
    --BaseUtils.dump(data, "on14002")
    for i,v in ipairs(data.reward_list) do
        if self.rewardDic[v.id] ~= nil then
            self.rewardDic[v.id] = nil
            self.rewardDic[v.id] = v
        end
    end
    -- self:SetMainUIActiveIconVisible()
    self:CheckShopRedPoint()
end

--商城红点是否显示
function FirstRechargeManager:CheckShopRedPoint()
    --红点
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(6, self:isNeedShowRedPoint())
    end
end

--首充是否已做过
function FirstRechargeManager:isHadDoFirstRecharge()
    if CampaignManager.Instance.campaignTree ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.FirstRecharge] ~= nil then
        for _,main in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.FirstRecharge]) do
            if main ~= nil and #main.sub > 0 then
                return main.sub[1].status == CampaignEumn.Status.Accepted or main.sub[1].status == CampaignEumn.Status.Finish, main.sub[1].status
            end
        end
    end

    return false
end

-- 奖励界面,是否显示首充页签
function FirstRechargeManager:isHadDoFirstRecharge2()
    if CampaignManager.Instance.campaignTree ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.FirstRecharge] ~= nil then
        for _,main in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.FirstRecharge]) do
            if main ~= nil and #main.sub > 0 then
                return main.sub[1].status == CampaignEumn.Status.Accepted
            end
        end
    end

    return false
end

function FirstRechargeManager:isNeedShowRedPoint()
    if CampaignManager.Instance.campaignTree ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.Rebate] ~= nil then
        for _,main in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.Rebate]) do
            if main ~= nil and #main.sub > 0 then
                return main.sub[1].status == CampaignEumn.Status.Finish
            end
        end
    end
    return false
end

function FirstRechargeManager:on14003(data)
    --BaseUtils.dump(data, "on14003")
    for i,v in ipairs(data.camp_list) do
        if self.campDic[v.id] == nil then
            self.campDic[v.id] = v
        else
            self.campDic[v.id] = nil
            self.campDic[v.id] = v
        end
    end
    -- self:SetMainUIActiveIconVisible()
end

function FirstRechargeManager:on14004(data)
    --BaseUtils.dump(data, "on14004")
end

function FirstRechargeManager:send14000()
    Connection.Instance:send(14000, {})
end

function FirstRechargeManager:send14001(idTemp)
    Connection.Instance:send(14001, {id = idTemp})
end

function FirstRechargeManager:send14002()
    Connection.Instance:send(14002, {})
end

function FirstRechargeManager:send14003()
    Connection.Instance:send(14003, {})
end

function FirstRechargeManager:send14004()
    Connection.Instance:send(14004, {})
end

function FirstRechargeManager:IsCanShow(iconId,activeId)
    -- body
    if self.campDic[iconId] == nil or self.rewardDic[activeId] == nil then
        return false
    else
        if self.rewardDic[activeId].status == 2 then --已领取的状态，把图标隐藏
            return false
        end
        return true
    end
end
--主界面活动图标是否显示
function FirstRechargeManager:SetMainUIActiveIconVisible()
    -- body
    for k,v in pairs(DataCampaign.data_camp_ico) do
        MainUIManager.Instance:DelAtiveIcon(v.ico_id) --隐藏
        if v.is_show == 1 and v.position_type == CampaignEumn.ShowPosition.MainUI then
            --配置显示
            local dataCampaign = self:GetDataCampaignItemByIconId(tostring(v.ico_id))
            --Log.Error(dataCampaign)
            if dataCampaign ~= nil and self:IsCanShow(v.ico_id,dataCampaign.id) == true then
                --协议中的数据，表示要显示图标
                local dataSystemItem = DataSystem.data_daily_icon[v.ico_id]

                local iconData = AtiveIconData.New()
                iconData.id = dataSystemItem.id
                iconData.iconPath = dataSystemItem.res_name
                iconData.clickCallBack = function ()
                    -- body
                    --首充礼包
                    self.isFirstClick = true
                    if self.rechargeIconEffect ~= nil and not BaseUtils.is_null(self.rechargeIconEffect.gameObject) and self.rewardDic[1].status ~= 1 then
                        self.rechargeIconEffect.gameObject:SetActive(false)
                    end
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window)
                end
                iconData.sort = dataSystemItem.sort
                iconData.lev = dataSystemItem.lev
                if v.ico_id == 107 then
                    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == false then
                        self.icon = MainUIManager.Instance:AddAtiveIcon(iconData) --显示
                    end
                else
                    self.icon = MainUIManager.Instance:AddAtiveIcon(iconData) --显示
                end
                if dataCampaign.id == 1 and not BaseUtils.isnull(self.icon) then
                    local fun = function(effectView)
                        local effectObject = effectView.gameObject
                        if BaseUtils.isnull(self.icon) then
                            self.rechargeIconEffect:DeleteMe()
                            self.rechargeIconEffect = nil
                            return
                        end
                        effectObject.transform:SetParent(self.icon.transform)
                        effectObject.transform.localScale = Vector3(1, 1, 1)
                        effectObject.transform.localPosition = Vector3(0, 32, -400)
                        effectObject.transform.localRotation = Quaternion.identity

                        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                        effectObject:SetActive(true)
                    end

                    if self.isFirstClick == false or  self.rewardDic[1].status == 1 then

                        if self.rechargeIconEffect == nil then
                            -- -- print("----------"..debug.traceback())
                            self.rechargeIconEffect = BaseEffectView.New({effectId = 20256, time = nil, callback = fun})
                            -- print(BaseUtils.isnull(self.rechargeIconEffect.gameObject))
                        elseif BaseUtils.isnull(self.rechargeIconEffect.gameObject) == false then
                            -- print(BaseUtils.isnull(self.rechargeIconEffect.gameObject))
                            fun(self.rechargeIconEffect)
                        end
                    else
                        self.rechargeIconEffect = nil
                    end
                end
            else
                --隐藏
            end
        else
            --隐藏
        end
    end
end

function FirstRechargeManager:GetDataCampaignItemByIconId(iconid)
    -- body
    for k,v in pairs(DataCampaign.data_list) do
        if v.iconid == iconid then
            return v
        end
    end
    return nil
end

function FirstRechargeManager:SetIcon()
    PrivilegeManager.Instance.updateIcon:RemoveListener(self.updateIcon)
    PrivilegeManager.Instance.updateIcon:AddListener(self.updateIcon)
    -- PrivilegeManager.Instance:send9925()
    self:UpdateIcon()
end

-- function FirstRechargeManager:SendHandle()
--    PrivilegeManager.Instance.updateIconSecond:RemoveListener(self.updateIconSecond)
--    PrivilegeManager.Instance.updateIconSecond:AddListener(self.updateIconSecond)
--    PrivilegeManager.Instance:send9926()
--    print("22222222222222222222================================================================================================================================================================")
-- end
function FirstRechargeManager:UpdateIcon()

    local firstRecharge= PrivilegeManager.Instance.charge

    -- local nowLevel = 0
    -- for i=1,DataPrivilege.data_section_length do
    --     local t = DataPrivilege.data_section[i]
    --     if firstRecharge >= t.min then
    --         nowLevel = i
    --     end
    -- end
    -- local continueRechargeData = (CampaignManager.Instance.campaignTree or {})[CampaignEumn.Type.ContinueRecharge]

    -- BaseUtils.dump(continueRechargeData, "<color='#00ff00'>continueRechargeData</color>")
    -- 删除首充和连续充值的图标
    MainUIManager.Instance:DelAtiveIcon(340)
    MainUIManager.Instance:DelAtiveIcon(107)
    -- MainUIManager.Instance:DelAtiveIcon(120)
    MainUIManager.Instance:DelAtiveIcon(120)
    local canGetReward = false
    local hasGetReward = true
    for i,v in ipairs(self.level) do
        if PrivilegeManager.Instance:GetPrivilegeState(v) ~= 3 then
            hasGetReward = false
        end

        if PrivilegeManager.Instance:GetPrivilegeState(v) == 2 then
            canGetReward = true
        end
    end




       if self.iconData == nil then
           self.iconData = AtiveIconData.New()
       end

       if self.iconData2 == nil then
           self.iconData2 = AtiveIconData.New()
        end

       local status = nil
       local iconBaseData = nil
       local iconBaseData2 = nil
       local type = nil


       if firstRecharge <= 1 then
            iconBaseData = DataSystem.data_daily_icon[107]
       end
       -- 首充图标优先，否则连续充值
       local firstChargeTime = (OpenServerManager.Instance.model.chargeData or {}).first_time or 0
       local start_stamp = firstChargeTime

       -- firstChargeTime = BaseUtils.BASE_TIME

       local d = tonumber(os.date("%d", firstChargeTime))
       local m = tonumber(os.date("%m", firstChargeTime))
       local y = tonumber(os.date("%Y", firstChargeTime))

       -- print(firstChargeTime)
       -- print("==================================================================================")
       -- print(string.format("%s %s %s", tostring(y), tostring(m), tostring(d)))
       -- print(os.time{year = y, month = m, day = d, hour = 0, min = 0, sec = 0})
       local end_stamp = (tonumber(os.time{year = y, month = m, day = d, hour = 0, min = 0, sec = 0}) or 0) + 86400 * 15 - 1

       -- print(string.format("<color='#00ff00'>%s %s %s</color>", start_stamp, BaseUtils.BASE_TIME, end_stamp))
       -- print(os.date("%x", end_stamp))

       if iconBaseData == nil then
            if iconBaseData2 == nil and hasGetReward == false then
               iconBaseData2 = DataSystem.data_daily_icon[340]
               self.iconData2.id = iconBaseData2.id
               self.iconData2.iconPath = iconBaseData2.res_name
               self.iconData2.sort = iconBaseData2.sort
               self.iconData2.lev = iconBaseData2.lev
               self.iconData2.clickCallBack = function() self:OpenFirstRechargeIcon() end
               MainUIManager.Instance:AddAtiveIcon(self.iconData2)
            end
        end

       if iconBaseData == nil and start_stamp <= BaseUtils.BASE_TIME and end_stamp > BaseUtils.BASE_TIME then
    --

           iconBaseData = DataSystem.data_daily_icon[120]
           -- self.isFirstClick = true
           local bo = false
           local c = 0
           for i,v in ipairs((OpenServerManager.Instance.model.chargeData or {}).reward or {}) do
               if v ~= nil and v.day_status == 1 then
                   bo = bo or true
               end
               if v ~= nil and v.day_status == 2 then
                   c = c + 1
               end
           end
           if c == 5 then
               iconBaseData = nil
           end
           self.isFirstClick = false
           if bo == true then
               status = CampaignEumn.Status.Finish
           else
               status = CampaignEumn.Status.Doing
           end

           type = 1        -- 首充之后的连充

       end






       if iconBaseData == nil and CampaignManager.Instance.campaignTab[373] ~= nil then
           local bo = false
           local c = 0
           for i,v in ipairs((OpenServerManager.Instance.model.chargeData or {}).reward or {}) do
               if v ~= nil and v.day_status ~= 0 then
                   bo = bo or true
                   iconBaseData = DataSystem.data_daily_icon[120]
               end
               if v ~= nil and v.day_status == 2 then
                   c = c + 1
               end
           end
           if c == 5 then
               iconBaseData = nil
           end
           self.isFirstClick = false
           if bo == true then
               status = CampaignEumn.Status.Finish
           else
               status = CampaignEumn.Status.Doing
           end

           type = 1        -- 开服活动的连充


       end

       if iconBaseData ~= nil then
           self.iconData.id = iconBaseData.id
           self.iconData.iconPath = iconBaseData.res_name
           self.iconData.sort = iconBaseData.sort
           self.iconData.lev = iconBaseData.lev
           if self.iconData.id == 107 then
               self.iconData.clickCallBack = function() self:OpenFirstRechargeIcon() end
           elseif self.iconData.id == 120 then
               self.iconData.clickCallBack = function() self:OpenContinueRechargeIcon(type) end
           else
               self.iconData.clickCallBack = nil
           end
           self.icon = MainUIManager.Instance:AddAtiveIcon(self.iconData)

           if self.isFirstClick ~= true and status == CampaignEumn.Status.Finish then
               local fun = function(effectView)
                   local effectObject = effectView.gameObject
                   if BaseUtils.isnull(self.icon) then
                       if self.rechargeIconEffect ~= nil then
                           self.rechargeIconEffect:DeleteMe()
                           self.rechargeIconEffect = nil
                       end
                       return
                   end
                   effectObject.transform:SetParent(self.icon.transform)
                   effectObject.transform.localScale = Vector3(1, 1, 1)
                   effectObject.transform.localPosition = Vector3(0, 32, -400)
                   effectObject.transform.localRotation = Quaternion.identity

                   Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                   effectObject:SetActive(true)
               end

               if self.rechargeIconEffect == nil then
                   self.rechargeIconEffect = BaseEffectView.New({effectId = 20256, time = nil, callback = fun})
               elseif BaseUtils.isnull(self.rechargeIconEffect.gameObject) == false then
                   fun(self.rechargeIconEffect)
               end
           else
               if self.rechargeIconEffect ~= nil then
                   self.rechargeIconEffect:DeleteMe()
                   self.rechargeIconEffect = nil
               end
           end
       end

    self:CheckMainUIIconRedPoint(canGetReward)
end

function FirstRechargeManager:CheckMainUIIconRedPoint(t)
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(DataCampaign.data_camp_ico[39].ico_id, t)
    end
end



function FirstRechargeManager:OpenFirstRechargeIcon()
    self.isFirstClick = true
    local firstRechargeData = (CampaignManager.Instance.campaignTree or {})[CampaignEumn.Type.FirstRecharge]
    if self.rechargeIconEffect ~= nil and not BaseUtils.is_null(self.rechargeIconEffect.gameObject) and firstRechargeData[1].sub[1].status ~= 1 then
        self.rechargeIconEffect.gameObject:SetActive(false)
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window)
end

function FirstRechargeManager:OpenContinueRechargeIcon(type)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.continue_recharge, type)
end
