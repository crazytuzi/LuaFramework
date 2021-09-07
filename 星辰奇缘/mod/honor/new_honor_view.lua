NewHonorView  =  NewHonorView or BaseClass(BasePanel)

function NewHonorView:__init(model)
    self.name  =  "NewHonorView"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.new_honor_window, type  =  AssetType.Main}
        -- , {file = AssetConfig.honor_img, type = AssetType.Dep}
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.type =1
end

function NewHonorView:__delete()
    -- 记得这里销毁
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:NextNewHonor()

    self:AssetClearAll()
end

function NewHonorView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.new_honor_window))
    self.gameObject.name = "NewHonorView"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.TxtHonor = self.transform:Find("Main/TxtHonor"):GetComponent(Text)
    self.TxtHonor.transform.anchoredPosition = Vector2(0,61)
    self.TxtDesc = self.transform:Find("Main/TxtDesc"):GetComponent(Text)
    self.TxtDesc.transform.anchoredPosition = Vector2(4,6)
    self.TxtDesc.transform.sizeDelta = Vector2(304,76)
    self.titleText = self.transform:Find("Main/Title"):GetComponent(Text)

    self.myButton = self.transform:Find("Main/Button"):GetComponent(Button)
    self.myButtonText =self.transform:Find("Main/Button/Text"):GetComponent(Text)
    self.myButton.onClick:AddListener(function() self.model:CloseNewHonorWindow() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseNewHonorWindow() end)

    self:OnShow()
end

function NewHonorView:OnShow()
    local honor_id = 0
    if self.openArgs ~= nil and #self.openArgs > 0 then
        honor_id = self.openArgs[1]
        self.type = self.openArgs[2]
    end

    self.myButton.onClick:RemoveAllListeners()
    if self.type == InfoHonorEumn.Status.ForWard then
        self.titleText.text = "获得新称号"
        local data = DataHonor.data_get_honor_list[honor_id]
        if data ~= nil then
            if data.type == 6 then
                self.TxtHonor.text = string.format(TI18N("%s的%s"), RoleManager.Instance.RoleData.lover_name, data.name)
            elseif data.type == 7 then
                if TeacherManager.Instance.model.myTeacherInfo.status == 3 then     -- 师傅
                    self.TxtHonor.text = data.name
                elseif TeacherManager.Instance.model.myTeacherInfo.status ~= 0 then -- 徒弟或者已出师
                    self.TxtHonor.text = string.format("%s%s", TeacherManager.Instance.model.myTeacherInfo.name, data.name)
                end
            elseif data.type == 10 then    -- 结拜
                if SwornManager.Instance.model.swornData ~= nil and SwornManager.Instance.model.swornData.status == SwornManager.Instance.statusEumn.Sworn then
                    self.TxtHonor.text = string.format("%s·%s", SwornManager.Instance.model.swornData.name, SwornManager.Instance.model.swornData.members[SwornManager.Instance.model.myPos].name_defined)
                end
            else
                self.TxtHonor.text = data.name
            end

            local str1 = string.format("<color='#7EB9F7'>%s</color><color='#FFDC5F'>%s</color>", TI18N("获得条件："), data.cond_desc)
            local str = ""
            local isExt = false;
            for _, attr in pairs(data.attr_list)  do
                 isExt = true
                if attr.name >= 51 and attr.name <= 62 then
                    str = string.format("%s%s+%s%s", str, KvData.attr_name[attr.name], attr.val, "%").."，"
                else
                    str = string.format("%s%s+%s", str, KvData.attr_name[attr.name], attr.val).."，"
                end
            end
            local len = string.len(str);
            local isInStr = false
            if isExt and len > 1 then
              str = string.sub(str, 1, len - 3)
              local fkstr = string.format("<color='#00ffff'>%s</color>",str);
              str1 = string.format("%s\n<color='#7EB9F7'>%s</color>%s", str1, TI18N("附加属性："), fkstr)
              isInStr = true
            end

            if data.collect_desc ~= nil and data.collect_desc ~= "" then
                    print("1111111111111111111111111111111111111111111111111111111111111111111")
                    if isInStr == true then
                        str1 = str1 .. "，" .. data.collect_desc
                    else
                        print("2222222222222222222222222222222222222222222222222222222")
                        str1 = str1 .. "\n" .. "<color='#7EB9F7'>附加属性：</color>" .. data.collect_desc
                    end
             end
            self.TxtDesc.text = str1
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("无该称号配置信息"))
        end
        self.myButton.onClick:AddListener(function() self.model:CloseNewHonorWindow() end)
        self.myButtonText.text = "确定"
    elseif self.type == InfoHonorEumn.Status.Back then
        self.titleText.text = "获得新前缀"
        local data = DataHonor.data_get_pre_honor_list[honor_id]
        if data ~= nil then
            self.TxtHonor.text = data.pre_name
            self.TxtDesc.text = data.desc
        end
        self.myButton.onClick:AddListener(function() self.model:CloseNewHonorWindow() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.info_honor_window,{2}) end)
        self.myButtonText.text = "去搭配"
    end
end

function NewHonorView:OnHide()

end


function NewHonorView:NextNewHonor()
    if #self.model.newHonorCache > 0 then
        local honor_id = self.model.newHonorCache[1]
        LuaTimer.Add(50, function() HonorManager.Instance.model:GetNewHonor(honor_id) end)
        table.remove(self.model.newHonorCache, 1)
    end
end