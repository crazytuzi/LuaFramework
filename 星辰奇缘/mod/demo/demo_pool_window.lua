DemoPoolWindow = DemoPoolWindow or BaseClass(BaseWindow)

function DemoPoolWindow:__init(model)
    self.model = model
    self.name = "DemoPoolWindow"
    self.resList = {
        {file = AssetConfig.demo_pool_window, type = AssetType.Main}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
    }

    self.closeBut = nil

    self.vPanel = nil
    self.vScroll = nil

    self.hPanel = nil
    self.hScroll = nil
end

function DemoPoolWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DemoPoolWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.demo_pool_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "DemoPoolWindow"
    self.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.closeBut = self.gameObject.transform:FindChild("Window/CloseBut").gameObject
    self.closeBut:GetComponent(Button).onClick:AddListener(function() self:OnCloseButtonClick() end)

    self.vPanel = self.gameObject.transform:FindChild("Window/Panel").gameObject
    self.vScroll = self.vPanel:GetComponent(LVerticalScrollRect)

    self.hPanel = self.gameObject.transform:FindChild("Window/HPanel").gameObject
    self.hScroll = self.hPanel:GetComponent(LHorizontalScrollRect)

    self.gameObject:SetActive(true)
    self:InitData()
end

function DemoPoolWindow:InitData()
    local GetData = function(index)
        local name = nil
        if index % 2 == 0 then
            name = TI18N("偶数")
        else
            name = TI18N("奇数")
        end
        return {id = index, name = name, num = index}
    end

    local OnClick = function(but, data)
        self:OnButClick(but, data)
    end
    self.vScroll:SetPoolInfo(50, "PoolCellPanel", GetData, {callback = OnClick})
    self.hScroll:SetPoolInfo(50, "PoolCellPanel", GetData, {callback = OnClick})
end

function DemoPoolWindow:OnCloseButtonClick()
    self.model:ClosePoolWindow()
end

function DemoPoolWindow:OnButClick(but, data)
    -- print("=================点击:" .. data.num)
end

PoolCellPanel = PoolCellPanel or BaseClass()

function PoolCellPanel:__init(gameObject, args)
    self.gameObject = gameObject
    self.data = nil
    self.args = args

    self.text = self.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.button = self.gameObject:GetComponent(Button)
    self.button.onClick:AddListener(function() self:OnButClick() end)
end

function PoolCellPanel:InitPanel(data)
    self.data = data
    self.text.text = data.name .. " " .. data.num
end

function PoolCellPanel:OnButClick()
    self.args.callback(self.gameObject, self.data)
end


function PoolCellPanel:Release()
    self.text.text = ""
end
