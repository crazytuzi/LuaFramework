WorldRedBagInputWindow  =  WorldRedBagInputWindow or BaseClass(BasePanel)

function WorldRedBagInputWindow:__init(model)
    self.name  =  "WorldRedBagInputWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.world_red_bag_input_window, type  =  AssetType.Main}
    }

    self.windowId = WindowConfig.WinID.world_red_bag_input_window
    self.is_open = false

    return self
end

function WorldRedBagInputWindow:__delete()
    self.is_open = false

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function WorldRedBagInputWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.world_red_bag_input_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "WorldRedBagInputWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseRedBagInputUI() end)

    local close_btn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseRedBagInputUI() end)

    -- local input_field = self.transform:FindChild("Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
    -- input_field.textComponent = self.transform:FindChild("Main/InputCon/InputField/Text"):GetComponent(Text)
    -- input_field.text = ""
    self.transform:FindChild("Main/Input/Text"):GetComponent(Text).text = self.model.current_red_bag.title

    self.transform:FindChild("Main/OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnOkButton() end)
end

function WorldRedBagInputWindow:OnOkButton()
    -- local input_field = self.transform:FindChild("Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
    -- local send_msg = input_field.text
    ChatManager.Instance:Send10400(MsgEumn.ChatChannel.World, self.model.current_red_bag.title)
    RedBagManager.Instance.model:CheckRedBagPassword(MsgEumn.ChatChannel.World, self.model.current_red_bag.title)

    self.model:CloseRedBagInputUI()
end