DanmakuModel = DanmakuModel or BaseClass(BaseModel)

function DanmakuModel:__init()
    self.panel = nil
    self.resList = {
        {file = AssetConfig.danmaku_item, type = AssetType.Main},
        {file = "textures/ui/danmaku.unity3d", type = AssetType.Dep}
    }

    self.container = DanmakuManager.Instance.container
    self.MaxItenNum = 100
    self.itemPool = {}
    self.itemPos = {}
    self.lastTunnel = 0
    self.lastTime = 0
    self.isshow = true

    self.listener = function() self:LoadItem() end
    EventMgr.Instance:AddListener(event_name.mainui_loaded, self.listener)
end

function DanmakuModel:LoadItem()
    DanmakuManager.Instance:InitContainer()
    self.container = DanmakuManager.Instance.container
    self.assetWrapper = AssetBatchWrapper.New()
    local func = function()
        if self.assetWrapper == nil then return end
        self.baseItem = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.danmaku_item))
        -- GameObject.DontDestroyOnLoad(self.baseItem)
        self.baseItem.transform:SetParent(self.container.transform)
        self.baseItem.transform.localScale = Vector3(1, 1, 1)
        self.baseItem.transform.localPosition = Vector3(0, 300, 1)
        self.baseItem:SetActive(false)
        self.assetWrapper:ClearMainAsset()
    end
    self.assetWrapper:LoadAssetBundle(self.resList, func)
end

-- 弹幕发送面板通用参数
-- defaultstr 默认发表内容
-- 点击发送回调sendCall = function(msg)
-- cost = {assets, num}
--
function DanmakuModel:OpenPanel(args)
    if self.panel == nil then
        self.panel = DanmakuPanel.New(self)
        self.panel:Show(args)
    end
end

function DanmakuModel:ClosePanel()
    if self.panel ~= nil then
        self.panel:DeleteMe()
        self.panel = nil
    end
end

function DanmakuModel:OpenHisPanel(args)
    if self.hispanel == nil then
        self.hispanel = DanmakuHistoryPanel.New(self)
        self.hispanel:Show(args)
    end
end

function DanmakuModel:CloseHisPanel()
    if self.hispanel ~= nil then
        self.hispanel:DeleteMe()
        self.hispanel = nil
    end
end

function DanmakuModel:UpdatePanelText()
    if self.panel ~= nil then
        self.panel:UpdateText()
    end
end

function DanmakuModel:ShowMsg(msg, type)
    if self.container == nil then
        DanmakuManager.Instance:InitContainer()
        self.container = DanmakuManager.Instance.container
    end
    local itemobj = DanmakuItem.New(self)
    itemobj:SetMsg(msg,type)
    if itemobj.gameObject == nil then
        return
    end
    local pos = itemobj.gameObject.transform.localPosition
    local speed = Random.Range(1300, 1560)
    Tween.Instance:MoveLocal(itemobj.gameObject, Vector3(pos.x - 2*pos.x, pos.y, pos.z), speed/100, function() itemobj:DeleteMe() end, LeanTweenType.linear)
end

function DanmakuModel:OnOut(item)
    self.itemPool[tonumber(item.name)].using = false
end

function DanmakuModel:GetItem()
    if self.baseItem == nil then
        return nil ,#self.itemPool
    end
    local currtime = Time.time
    if self.lastTime ~= 0 and currtime - self.lastTime > 300 then
        self.lastTime = currtime
        for k,v in pairs(self.itemPool) do
            if not BaseUtils.isnull(v.item) then
                GameObject.Destroy(v.item)
            end
        end
        self.itemPool = {}
    end
    for k,v in pairs(self.itemPool) do
        if v.using == false then
            self.itemPool[k].using = true
            v.item:SetActive(true)
            return v.item, k
        end
    end
    local nitem = GameObject.Instantiate(self.baseItem)
    nitem:SetActive(true)
    nitem.name = tostring(#self.itemPool+1)
    table.insert(self.itemPool, {item = nitem, using = true})
    return nitem, #self.itemPool
end

function DanmakuModel:GetTunnel(type)
    local rt = Random.Range(-4,  8)
    if type == 1 then
        rt = Random.Range(-4, 2)
    end
    if rt == self.lastTunnel then
        rt = (rt*2+1)%4
    end
    self.lastTunnel = rt
    return rt
end

function DanmakuModel:GetText()
    local defaulttext = {
        TI18N("结缘快乐^_^")
        ,TI18N("祝你们白头偕老^_^")
        ,TI18N("早生贵子哟^_^")
        ,TI18N("哇，郎才女貌～～")
        ,TI18N("永结同心^_^")
    }
    local index = 0
    index = Random.Range(1, #defaulttext)
    return defaulttext[index]
end

function DanmakuModel:ClearDanmaku()
    for k,v in pairs(self.itemPool) do
        v.item:SetActive(false)
    end
end

function DanmakuModel:Hide()
    if not BaseUtils.isnull(self.container) then
        self.isshow = false
        self.container:SetActive(false)
        DanmakuManager.Instance.OnDanmakuSwitch:Fire()
    end
end

function DanmakuModel:Show()
    if not BaseUtils.isnull(self.container) then
        self.isshow = true
        self.container:SetActive(true)
        DanmakuManager.Instance.OnDanmakuSwitch:Fire()
    end
end