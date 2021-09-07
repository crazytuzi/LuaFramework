QualifyOpenLockWindow  =  QualifyOpenLockWindow or BaseClass(BasePanel)

function QualifyOpenLockWindow:__init(model)
    self.name  =  "QualifyOpenLockWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.qualifying_openlock, type  =  AssetType.Main}
        ,{file  =  AssetConfig.qualifying_lev_icon, type  =  AssetType.Dep}
    }

    self.vec3 = Vector3(0, 0, 0.5)

    return self
end


function QualifyOpenLockWindow:__delete()
    self.ImgLeftIcon.sprite = nil
    if self.rotateId ~= nil then
        LuaTimer.Delete(self.rotateId)
        self.rotateId = nil
    end

    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function QualifyOpenLockWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.qualifying_openlock))
    self.gameObject.name  =  "QualifyOpenLockWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function()
        self.model:CloseQualifyOpenLockUI()
        self.model:OpenQualifyFinishUI()
    end)


    self.ImgLeftIconCon = self.MainCon:FindChild("ImgLeftIconCon")

     self.lightTransform = self.ImgLeftIconCon:Find("ImgZhuanBg")

    self.ImgLeftIcon = self.ImgLeftIconCon:FindChild("ImgLeftIcon"):GetComponent(Image)
    self.TxtLeftIconName = self.ImgLeftIconCon:FindChild("TxtLeftIconName"):GetComponent(Text)
    self.TxtLeftIconPoint = self.ImgLeftIconCon:FindChild("TxtLeftIconPoint"):GetComponent(Text)


    self.Txt1 = self.MainCon:FindChild("Txt1"):GetComponent(Text)
    self.Txt2 = self.MainCon:FindChild("Txt2"):GetComponent(Text)

    self.TxtLeftIconName.text = ""
    self.TxtLeftIconPoint.text = ""
    self.Txt2.text = ""


    self:Rotate()

    self:update_info()
end


--更新内容
function QualifyOpenLockWindow:update_info()
    local cfg_data = DataQualifying.data_qualify_data_list[self.model.open_lock_data.rank_lev]
    local duanwei_name = cfg_data.lev_name
    self.ImgLeftIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.qualifying_lev_icon,tostring(cfg_data.rank_type))

    self.ImgLeftIcon.gameObject:SetActive(true)
    self.TxtLeftIconName.text = duanwei_name
    self.TxtLeftIconPoint.text = ""

    local str1 = string.format("%s<color='#ffff00'>%s</color>%s", TI18N("你已经晋升至"), duanwei_name, TI18N("，祝您在段位赛中再创神话！"))

    local has_tips = {}
    for i=1,#self.model.mine_qualify_data.up_ranklev_reward do
        local temp_data = self.model.mine_qualify_data.up_ranklev_reward[i]
        has_tips[temp_data.rank_lev] = temp_data
    end
    local is_in = false
    local check_lev = math.floor(self.model.open_lock_data.rank_lev/5)*5+1
    for i=1,#self.model.open_lock_data.up_ranklev_reward do
        local socket_data = self.model.open_lock_data.up_ranklev_reward[i]
        if has_tips[socket_data.rank_lev] == nil and socket_data.rank_lev == check_lev then
            is_in = true
        end
    end

    if is_in then
        local temp_cfg_data = DataQualifying.data_qualify_data_list[check_lev]
        if temp_cfg_data.uplev_reward ~= 0 then
            local temp_data = DataItem.data_get[temp_cfg_data.uplev_reward]
            str1 = string.format("%s<color='#ffff00'>%s</color>%s\n<color='#00ff00'>%s%s%s%s</color>", TI18N("你已经晋升至"), duanwei_name, TI18N("，祝您在段位赛中再创神话！"), TI18N("（首次达到，"), TI18N("获得"), temp_data.name ,TI18N("）"))
        end
    end

    self.Txt2.text = str1


    -- （首次达到，获得<color='#2fc823'>xx礼包</color>）
end


function QualifyOpenLockWindow:Rotate()
    if self.rotateId == nil then
        self.rotateId = LuaTimer.Add(0, 10, function() self:Loop() end)
    end
end

function QualifyOpenLockWindow:Loop()
    self.lightTransform:Rotate(self.vec3)
end