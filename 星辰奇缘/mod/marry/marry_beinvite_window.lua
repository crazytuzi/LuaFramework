Marry_BeinviteView = Marry_BeinviteView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function Marry_BeinviteView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_beinvite_window
    self.name = "Marry_BeinviteView"
    self.resList = {
        {file = AssetConfig.marry_beinvite_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
        , {file = AssetConfig.heads, type = AssetType.Dep}
    }

    -----------------------------------------
    self.inviteText = nil
    self.timeText = nil
    self.Button = nil

    self.maleHead = nil
    self.femaleHead = nil
    self.maleText = nil
    self.femaleText = nil
    -----------------------------------------
end

function Marry_BeinviteView:__delete()
    self:ClearDepAsset()
end

function Marry_BeinviteView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_beinvite_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function()
            NoticeManager.Instance:FloatTipsByString(TI18N("典礼中前往NPC-丘比特申请参加典礼可以进入典礼殿堂"))
            self:Close()
        end)

    self.maleHead = self.transform:FindChild("Main/Panel/MaleHead/Head"):GetComponent(Image)
    self.femaleHead = self.transform:FindChild("Main/Panel/FemaleHead/Head"):GetComponent(Image)

    self.maleText = self.transform:FindChild("Main/Panel/MaleText"):GetComponent(Text)
    self.femaleText = self.transform:FindChild("Main/Panel/FemaleText"):GetComponent(Text)

    self.typeText = self.transform:FindChild("Main/Panel/TypeText"):GetComponent(Text)

    self.inviteText = self.transform:FindChild("Main/Panel/InviteText"):GetComponent(Text)
    self.timeText = self.transform:FindChild("Main/Panel/TimeText"):GetComponent(Text)

    self.Button = self.transform:FindChild("Main/Panel/Button"):GetComponent(Button)
    self.Button.onClick:AddListener(function() self:ButtonClick() end)

    local fun = function(effectView)
        if self.gameObject == nil then
            if effectView.gameObject ~= nil then GameObject.Destroy(effectView.gameObject) end
            return
        end
        
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.transform:FindChild("Main/Panel/Button"))
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(-50, 28, -10)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    BaseEffectView.New({effectId = 20118, time = nil, callback = fun})

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.data = self.openArgs[1]
        self:Update()
    end
end

function Marry_BeinviteView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marry_beinvite_window)
end

function Marry_BeinviteView:Update()
	self.maleHead.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_1", self.data.male_classes))
    self.femaleHead.sprite =  self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_0", self.data.female_classes))

    self.maleText.text = self.data.male_name
    self.femaleText.text = self.data.female_name

    if self.data.type == 1 then
        self.typeText.text = TI18N("挚爱典礼")
    else
        self.typeText.text = TI18N("豪华典礼")
    end

    self.inviteText.text = self.data.msg


    local my_hour = tonumber(os.date("%H", self.data.time))
    local my_minute = tonumber(os.date("%M", self.data.time))
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    self.timeText.text = string.format("%s:%s", my_hour, my_minute)
end

function Marry_BeinviteView:ButtonClick()
	self:Close()
    MarryManager.Instance:Send15009()
end

