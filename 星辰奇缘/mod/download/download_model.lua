-- 下载数据
-- @ljh 2016.06.12

DownLoadModel = DownLoadModel or BaseClass(BaseModel)

function DownLoadModel:__init()
    self.window = nil

    self.hasReward = true

    self._update_icon = function()
        -- if self:IsSubpackage() then
        --     CSSubpackageManager.GetInstance():StartDownload()
        -- end
        self:update_icon()
    end
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, self._update_icon)

    self.OnUpdate = EventLib.New()

    if CSSubpackageManager then
        local fun = function(total, remain) self:checkRedPoint(total, remain) self.OnUpdate:Fire(total, remain) end
        CSSubpackageManager.GetInstance():AddProgressEvent(fun)
    end
end

function DownLoadModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end

    self.OnUpdate:DeleteMe()
    self.OnUpdate = nil
end

function DownLoadModel:OpenWindow(args)
    if self.window == nil then
        self.window = DownLoadView.New(self)
    end
    self.window:Open(args)
end

function DownLoadModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function DownLoadModel:update_icon()

    if BaseUtils.IsVerify == true then
        return
    end

	if MainUIManager.Instance.isMainUIInconInit == false then return end

	if self:IsSubpackage() and not self.hasReward then
        MainUIManager.Instance:DelAtiveIcon(305)

        local icon_id = 305
        local cfg_data = DataSystem.data_daily_icon[icon_id]
        local data = AtiveIconData.New()
        data.id = cfg_data.id
        data.iconPath = cfg_data.res_name
        data.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.download_win) end
        data.sort = cfg_data.sort
        data.lev = cfg_data.lev
        if false then
            -- data.text = string.format("<color='#ff4343'>%s级领取</color>", DataPet.data_pet_fresh[self.fresh_id].need_lev)
        else
            -- data.createCallBack = function(gameObject)
            --     self.newPetIconObj = gameObject
            --     local fun = function(effectView)
            --         if BaseUtils.is_null(gameObject) then
            --             effectView:DeleteMe()
            --             return
            --         end
            --         local effectObject = effectView.gameObject

            --         effectObject.transform:SetParent(gameObject.transform)
            --         effectObject.transform.localScale = Vector3(0.9, 0.9, 0.9)
            --         effectObject.transform.localPosition = Vector3(-1.6, 30, -400)
            --         effectObject.transform.localRotation = Quaternion.identity

            --         Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            --     end
            --     BaseEffectView.New({effectId = 20121, time = nil, callback = fun})
            -- end
            -- data.text = "<color='#00ea00'>下载下载</color>"
        end
        MainUIManager.Instance:AddAtiveIcon(data)

        self:checkRedPoint(CSSubpackageManager.GetInstance():GetTotal(), CSSubpackageManager.GetInstance():GetRemain())
    else
        MainUIManager.Instance:DelAtiveIcon(305)
    end
end

function DownLoadModel:checkRedPoint(total, remain)
    if total == 0 or remain == 0 then
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(305, true)
        end
    end
end

function DownLoadModel:IsSubpackage()
    if CSSubpackageManager then
        return CSSubpackageManager.GetInstance().IsSubpackage
    else
        return false
    end
end

function DownLoadModel:NeedDownload()
    if CSSubpackageManager then
        return CSSubpackageManager.GetInstance().NeedDownload
    else
        return false
    end
end

function DownLoadModel:IsDowning()
    if CSSubpackageManager then
        local status = CSSubpackageManager.GetInstance():CurrentStatus()
        if status == "Loading" then
            return true
        else
            return false
        end
    else
        return false
    end
end

function DownLoadModel:StartDownload()
    if CSSubpackageManager then
        CSSubpackageManager.GetInstance():StartDownloadOnPause()
    end
end

function DownLoadModel:PauseDownload()
    if CSSubpackageManager then
        CSSubpackageManager.GetInstance():PauseDownload()
    end
end