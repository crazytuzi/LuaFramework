DemoMainUIWindow = DemoMainUIWindow or BaseClass(BaseWindow)

function DemoMainUIWindow:__init(model)
    self.name = "DemoMainUIWindow"
    self.demoModel = model
    self.resList = {
        {file = AssetConfig.font, type = AssetType.Dep}
        -- ,{file = AssetConfig.base_textures, type = AssetType.Dep}
        ,{file = AssetConfig.effect_path, type = AssetType.Main}
        ,{file = AssetConfig.demo_mainui_prefab, type = AssetType.Main}
    }

    self.button1 = nil
    self.button2 = nil
    self.button3 = nil
    self.effect = nil

    self.fps = nil
    self.timerId = 0

end

function DemoMainUIWindow:__delete()
    GameObject.DestroyImmediate(self.effect)
    self.effect = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    LuaTimer.Delete(self.timerId)
end

function DemoMainUIWindow:InitPanel()
    if self.gameObject ~= nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.demo_mainui_prefab))
    self.gameObject.name = "DemoMainUI"
    self.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.button1 = self.gameObject.transform:FindChild("Button1").gameObject
    self.button2 = self.gameObject.transform:FindChild("Button2").gameObject
    self.button3 = self.gameObject.transform:FindChild("Button3").gameObject

    self.fps = self.gameObject.transform:FindChild("FPS"):GetComponent(Text)
    self.fps.text = "fps:0"

    self.button1:GetComponent(Button).onClick:AddListener(function() self:OnButton1Click() end)
    self.button2:GetComponent(Button).onClick:AddListener(function() self:OnButton2Click() end)
    self.button3:GetComponent(Button).onClick:AddListener(function() self:OnButton3Click() end)

    self.timeStamp = Time.realtimeSinceStartup
    self.frameStamp = Time.frameCount
    LuaTimer.Add(0, 100, function(id) self:ShowFPS(id) end)

    self.gameObject:GetComponent(Canvas).worldCamera = ctx.UICamera

    self:ShowEffect()
end

function DemoMainUIWindow:OnButton1Click()
    self.demoModel:OpenWindow1()
end

function DemoMainUIWindow:OnButton2Click()
    Demo2Manager.Instance:OpenWindow()
end

function DemoMainUIWindow:OnButton3Click()
end

function DemoMainUIWindow:ShowFPS(id)
    self.timerId = id
    local f = (Time.frameCount - self.frameStamp) / (Time.realtimeSinceStartup - self.timeStamp)
    self.fps.text = "FPS:"..math.floor(f)
    self.timeStamp = Time.realtimeSinceStartup
    self.frameStamp = Time.frameCount
end

function DemoMainUIWindow:ShowEffect()
    self.effect = GameObject.Instantiate(self:GetPrefab(AssetConfig.effect_path)).gameObject
    self.effect.transform:SetParent(self.gameObject.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(-330, 230, -10)
    self.effect:SetActive(true)
end
