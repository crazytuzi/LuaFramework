ChristmasRidePanel = ChristmasRidePanel or BaseClass(BasePanel)

function ChristmasRidePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ChristmasRidePanel"
    self.index = 1
    self.canClick = true
    --self.btnImg = {"StandI18N","RunI18N"}
    self.btnImg = {"ColorI18N","ColorI18N"}
    
    self.resList = {
        {file = AssetConfig.christmas_ride, type = AssetType.Main}
        ,{file = AssetConfig.christmas_textures, type = AssetType.Dep}
    }

    --self.rideIdList = {2057,2058,2059,2060,2061,2062}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ChristmasRidePanel:__delete()
    self.OnHideEvent:Fire()

    if self.iconloader ~= nil then
        self.iconloader:DeleteMe()
        self.iconloader = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.changeEffect ~= nil then
        self.changeEffect:DeleteMe()
        self.changeEffect = nil
    end

    if self.btnEffect ~= nil then
        self.btnEffect:DeleteMe()
        self.btnEffect = nil
    end

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ChristmasRidePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.christmas_ride))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(self.bg)))

    self.preview = t:Find("Preview").gameObject
    t:Find("Preview").anchoredPosition3D  = Vector3(0,20,-143)
    --self.preview:SetActive(false)
    self.effect = t:Find("Effect")
    self.changeBtnImg = t:Find("ChangeBtn"):GetComponent(Image)
    t:Find("ChangeBtn"):GetComponent(Button).onClick:AddListener(function() self:ChangeLook() end)
    self.changeBtnImg.sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_textures,self.btnImg[self.index])

    self.desc = t:Find("Desc"):GetComponent(Text)
    self.desc.text = TI18N("可通过收集铃铛叮铃获得")
    -- t:Find("JumpBtn"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow,{5,2031}) end)
    if self.iconloader == nil then
        self.iconloader = SingleIconLoader.New(t:Find("JumpBtn/Image").gameObject)
    end
    self.iconloader:SetSprite(SingleIconType.Item, 70408, false)
    if RideManager.Instance.model.myRideData ~= nil then
        if #RideManager.Instance.model.myRideData.mount_list == 0 or (#RideManager.Instance.model.myRideData.mount_list == 1 and RideManager.Instance.model.myRideData.mount_list[1].live_status ~= 3) or (#RideManager.Instance.model.myRideData.mount_list == 2 and RideManager.Instance.model.myRideData.mount_list[1].live_status ~= 3 and RideManager.Instance.model.myRideData.mount_list[2].live_status ~= 3) then
            t:Find("JumpBtn/Text"):GetComponent(Text).text = TI18N("      前往收集")
            t:Find("JumpBtn"):GetComponent(Button).onClick:AddListener(function()
                if CampaignManager.Instance.christmas_ride_click == false then
                    CampaignManager.Instance.christmas_ride_click = true
                    self.btnEffect:SetActive(false)
                end
                local base_data = DataItem.data_get[70408]
                local info = { itemData = base_data, gameObject = t:Find("JumpBtn").gameObject }
                TipsManager.Instance:ShowItem(info)
                NoticeManager.Instance:FloatTipsByString(TI18N("拥有坐骑后可进行幻化{face_1,3}"))
            end)
        else
            t:Find("JumpBtn/Text"):GetComponent(Text).text = TI18N("      查看详情")
            t:Find("JumpBtn"):GetComponent(Button).onClick:AddListener(function()
                if CampaignManager.Instance.christmas_ride_click == false then
                    CampaignManager.Instance.christmas_ride_click = true
                    self.btnEffect:SetActive(false)
                end
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow,{5, 0, 2057})
            end)
        end
    end

    if CampaignManager.Instance.christmas_ride_click == false then
        if self.btnEffect == nil then
            self.btnEffect = BaseUtils.ShowEffect(20053, t:Find("JumpBtn"), Vector3(2.2,0.75,1), Vector3(-70,-16,-1000))
        end
    end

    self:ButtonEffect()

end

function ChristmasRidePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
    CampaignManager.Instance.christmas_ride = false
    CampaignManager.Instance.model:CheckActiveRed(self.campId)
end

function ChristmasRidePanel:OnOpen()
    self:UpdatePreview()
    if self.changeEffect ~= nil then
        self.changeEffect:SetActive(false)
    end
    self.canClick = true
end

function ChristmasRidePanel:OnHide()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.timeId_Run ~= nil then
        LuaTimer.Delete(self.timeId_Run)
        self.timeId_Run = nil
    end
    if self.timeId_Stand ~= nil then
        LuaTimer.Delete(self.timeId_Stand)
        self.timeId_Stand = nil
    end
    if self.timeId_Idle1 ~= nil then
        LuaTimer.Delete(self.timeId_Idle1)
        self.timeId_Idle1 = nil
    end
    if self.timeId_Idle2 ~= nil then
        LuaTimer.Delete(self.timeId_Idle2)
        self.timeId_Idle2 = nil
    end
end

function ChristmasRidePanel:UpdatePreview()
    local callback = function(composite)
        local ride = composite.tpose
        self.animator = ride:GetComponent(Animator)
        local rideAnimationData = composite.animationData
        self.data = {
            [1] = {
                classes = 2,
                sex = 1,
                looks = {
                    [1] = {
                        looks_str = "",
                        looks_val = 50104,
                        looks_mode = 50104,
                        looks_type = 2,
                    },
                    [2] = {
                        looks_str = "",
                        looks_val = 51104,
                        looks_mode = 51104,
                        looks_type = 3,
                    },
                    [3] = {
                        looks_str = "",
                        looks_val = 52067,
                        looks_mode = 0,
                        looks_type = 4,
                    }
                }
            },
            [2] = {
                classes = 3,
                sex = 0,
                looks = {
                    [1] = {
                        looks_str = "",
                        looks_val = 50101,
                        looks_mode = 50101,
                        looks_type = 2,
                    },
                    [2] = {
                        looks_str = "",
                        looks_val = 51101,
                        looks_mode = 51101,
                        looks_type = 3,
                    },
                    [3] = {
                        looks_str = "",
                        looks_val = 52067,
                        looks_mode = 0,
                        looks_type = 4,
                    }
                }
            }
            
        }
        local callback2 = function(animationData, tpose, headAnimationData, headTpose)
            self:RoleTposeComplete(ride, rideAnimationData, animationData, tpose, headAnimationData, headTpose, 1)
        end
        RoleTposeLoader.New(self.data[1].classes, self.data[1].sex, self.data[1].looks, callback2)

        local callback3 = function(animationData, tpose, headAnimationData, headTpose)
            self:RoleTposeComplete(ride, rideAnimationData, animationData, tpose, headAnimationData, headTpose, 2)
        end
        RoleTposeLoader.New(self.data[2].classes, self.data[2].sex, self.data[2].looks, callback3)

        self:SetAnimation()
    end

    self.looks = {
        {
            {looks_val = 2057,looks_type = 20}
            ,{looks_val = 10288,looks_type = 57}
        },
        {
            {looks_val = 2058,looks_type = 20}
            ,{looks_val = 10289,looks_type = 57}
        },
        {
            {looks_val = 2059,looks_type = 20}
            ,{looks_val = 10290,looks_type = 57}
        },
        {
            {looks_val = 2060,looks_type = 20}
            ,{looks_val = 10291,looks_type = 57}
        },
        {
            {looks_val = 2061,looks_type = 20}
            ,{looks_val = 10292,looks_type = 57}
        },
        {
            {looks_val = 2062,looks_type = 20}
            ,{looks_val = 10293,looks_type = 57}
        }
    }
    
    local modelData = {type = PreViewType.Ride, classes = 1, sex = 1, looks = self.looks[self.index]}
    if self.previewComp == nil then
        local setting = {
            name = "ride"
            ,layer = "UI"
            ,parent = self.preview.transform
            ,localRot = Vector3(0, 45, 0)
            ,localPos = Vector3(0, -109, 0)
            ,localScale = Vector3(200,200,200)
            ,usemask = false
            ,sortingOrder = 21
        }
        self.previewComp = PreviewmodelComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end

    
end

function ChristmasRidePanel:ChangeLook()
    if self.canClick == true then
        self.canClick = false

        if self.changeEffect == nil then
            self.changeEffect = BaseUtils.ShowEffect(20519, self.effect, Vector3(1,1,1), Vector3(0,0,-1000))
        end
        self.changeEffect:SetActive(false)
        self.changeEffect:SetActive(true)

        self.timerId = LuaTimer.Add(1000, function()
            self.index = self.index + 1
            if self.index > 6 then
                self.index = self.index - 6
            end
            self:UpdatePreview()
            self.canClick = true
            self.changeBtnImg.sprite = self.assetWrapper:GetSprite(AssetConfig.christmas_textures,self.btnImg[1])
            self:ButtonEffect()
        end)
    end
end


function ChristmasRidePanel:ButtonEffect()
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

    if self.index == 1 then
        if self.effTimerId == nil then
            self.effTimerId = LuaTimer.Add(1000, 3000, function()
                self.changeBtnImg.gameObject.transform.localScale = Vector3(1.1,1.1,1)
                Tween.Instance:Scale(self.changeBtnImg.gameObject, Vector3(1,1,1), 1.4, function() end, LeanTweenType.easeOutElastic)
            end)
        end
    end
end

function ChristmasRidePanel:RoleTposeComplete(ride, rideAnimationData, animationData, tpose, headAnimationData, headTpose, index)
    --self.animationData = rideAnimationData
    --self.headAnimationData = headAnimationData
    local tposeAnimator = tpose:GetComponent(Animator)
    local path = BaseUtils.GetChildPath(ride.transform, "bp_body")
    if index == 2 then
        path = BaseUtils.GetChildPath(ride.transform, "bp_body2")
    end
    local bind = ride.transform:Find(path)
    if bind ~= nil then
        local t = tpose:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, "UI")
        local looks_ride
        for k, v in pairs(self.looks[self.index]) do
            if v.looks_type == SceneConstData.looktype_ride then -- 坐骑
                looks_ride = v.looks_val
            end
        end
        local looksData = DataMount.data_ride_data[looks_ride]
        if looksData then
            local action_type = looksData.action_type_male
            if self.data[index].sex == 0 then
                action_type = looksData.action_type_female
            end
            if action_type == 2 or action_type == 3 then
                tposeAnimator:Play(SceneConstData.genanimationname("Sit", animationData.ridestand_id2))
            elseif action_type == 4 then
                tposeAnimator:Play(SceneConstData.genanimationname("Sit", animationData.ridestand_id3))
            elseif action_type == 5 then
                if RoleManager.Instance.RoleData.sex == 0 then
                    tposeAnimator:Play(SceneConstData.genanimationname("Stand", 6))
                else
                    tposeAnimator:Play(SceneConstData.genanimationname("Stand", 1))
                end
            elseif action_type == 6 then
                tposeAnimator:Play(SceneConstData.genanimationname("Sit", 5))
            else
                tposeAnimator:Play(SceneConstData.genanimationname("Sit", animationData.ridestand_id))
            end
        end
    end
end

function ChristmasRidePanel:SetAnimation()

    if self.timeId_Stand ~= nil then
        LuaTimer.Delete(self.timeId_Stand)
    end
    if self.timeId_Idle1 ~= nil then
        LuaTimer.Delete(self.timeId_Idle1)
    end
    local animationData = DataAnimation.data_ride_data[DataMount.data_ride_data[2057].animation_id]
    if animationData ~= nil then
        self.timeId_Stand = LuaTimer.Add(0,20000,function ()
            self.animator:Play( string.format("Idle%s", animationData.idle_id))
            self.timeId_Idle1 = LuaTimer.Add(3667, function()
                self.animator:Play( string.format("Stand%s", animationData.stand_id))
            end)
        end)
    end
end
