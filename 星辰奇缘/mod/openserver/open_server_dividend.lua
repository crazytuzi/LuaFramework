-- @author 黄耀聪
-- @date 2016年12月8日

OpenServerDividend = OpenServerDividend or BaseClass(BasePanel)

function OpenServerDividend:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "OpenServerDividend"

    self.resList = {
        {file = AssetConfig.open_server_dividend, type = AssetType.Main}
        , {file = AssetConfig.open_server_dividend_bg, type = AssetType.Main}
        , {file = AssetConfig.open_server_textures, type = AssetType.Dep}
    }

    self.descString = TI18N("当前累计充值%s元")

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenServerDividend:__delete()
    self.OnHideEvent:Fire()
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.triangleList ~= nil then
        for _,v in pairs(self.triangleList) do
            if v ~= nil then
                v.titleExt:DeleteMe()
                v.descExt:DeleteMe()
            end
        end
        self.triangleList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerDividend:OnHide()
    self:RemoveListeners()
end

function OpenServerDividend:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerDividend:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_dividend))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.maskTrans = t:Find("Slider/Mask")
    self.descExt = MsgItemExt.New(t:Find("Desc"):GetComponent(Text), 250, 16, 17.5)

    self.triangleList = {{}, {}, {}}
    for i=1,3 do
        local tab = self.triangleList[i]
        tab.transform = t:Find("Slider"):GetChild(i)
        tab.gameObject = tab.transform.gameObject
        tab.titleExt = MsgItemExt.New(tab.transform:Find("Talk/Title"):GetComponent(Text), 86, 20, 23.3)
        tab.descExt = MsgItemExt.New(tab.transform:Find("Talk/Desc"):GetComponent(Text), 84, 14, 16.3)
    end

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_dividend_bg)))
    t:Find("Button"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end)
end

function OpenServerDividend:OnOpen()
    self:RemoveListeners()

    self:Reload()
end

function OpenServerDividend:RemoveListeners()
end

-- 传入的value应该在0~1之间
function OpenServerDividend:SetValue(value)
    if value > 1 then value = 1
    elseif value < 0 then value = 0
    end

    self.maskTrans.sizeDelta = Vector2(27.3, 2 + 315 * value)
end

function OpenServerDividend:Reload()
    local money = self.model.gold_14095 or 0
    self.descExt:SetData(string.format(self.descString, tostring(money)))
end

