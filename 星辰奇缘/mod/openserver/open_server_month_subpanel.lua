-- @author hze
-- @date #18/03/15#

OpenServerMonthSubPanel = OpenServerMonthSubPanel or BaseClass(BasePanel)

function OpenServerMonthSubPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "OpenServerMonthSubPanel"

    self.resList = {
    	{file  =  AssetConfig.open_server_monthsub, type  =  AssetType.Main}
       ,{file = AssetConfig.open_server_textures, type = AssetType.Dep}
    }

    self.NoticeTxtData ={
        TI18N("<color='#00ff00'>每天前3次洗髓免费</color>"),
        TI18N("每天可获得<color='#ffff00'>10点</color>饱和度"),
        TI18N("银币市场刷新时间<color='#ffff00'>缩短30秒</color>"),
        TI18N("魔法炼化生产道具<color='#ffff00'>减少10分钟</color>"),
        TI18N("家园每天打扫清洁度<color='#ffff00'>额外增加5点</color>"),
        TI18N("每日赠送好友道具<color='#ffff00'>上限+1</color>"),
        TI18N("活力值<color='#ffff00'>上限+200</color>")
    }

    self.tipsList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenServerMonthSubPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerMonthSubPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_monthsub))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t:Find("Main"):GetComponent(RectTransform).sizeDelta = Vector2(420,280)
    t:Find("Main/Image").anchoredPosition = Vector2(45,0)
    t:Find("Main/Title"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "WindowTitleBg")
    t:Find("Main/Title").sizeDelta = Vector2(108,32)
    t:Find("Main/Image"):GetComponent(Image).enabled = false
    t:Find("Main/Title/Text"):GetComponent(Text).text = "<color='#B1E5F5'>月卡特权</color>"

    local btn = t:Find("Panel"):GetComponent(Button)
    if btn == nil then
        btn = t:Find("Panel").gameObject:AddComponent(Button)
    end
    btn.onClick:AddListener(function() self:Hiden() end)
    self.tips = t:Find("Main/Image/TemplateItem").gameObject
    self.tips:SetActive(false)
    self.layout = LuaBoxLayout.New(t:Find("Main/Image"),{axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})

    for k,v in pairs(self.NoticeTxtData) do
        if self.tipsList[k] == nil then
            local obj = GameObject.Instantiate(self.tips)
            self.layout:AddCell(obj)
            self.tipsList[k] = obj
        end
        self.tipsList[k].transform:Find("Text"):GetComponent(Text).text = v
    end


    -- self.noticeTxt = MsgItemExt.New(t:Find("Main/Image/NoticeText"):GetComponent(Text), 330, 20, 50)
    -- self.noticeTxt:SetData(self.NoticeTxtData)
end

function OpenServerMonthSubPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerMonthSubPanel:OnOpen()
    self:RemoveListeners()
end

function OpenServerMonthSubPanel:OnHide()
    self:RemoveListeners()
end

function OpenServerMonthSubPanel:RemoveListeners()
end


