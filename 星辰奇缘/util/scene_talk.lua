SceneTalk = SceneTalk or BaseClass(BaseManager)

function SceneTalk:__init()
    if SceneTalk.Instance then
        Logger.Error("单例不可重复初始化")
    end

    SceneTalk.Instance = self
    self.prefab = nil
    self.btnprefab = nil
    self.offestV2 = Vector2(0,90)
    self.uiTalkInfo = {}
    self.listener = function() self:LoadPrefabs() end
    EventMgr.Instance:AddListener(event_name.mainui_loaded, self.listener)
end

function SceneTalk:LoadPrefabs()
    local resources = {
        {file = AssetConfig.scenebtn, type = AssetType.Main}
        ,{file = AssetConfig.scenetalk, type = AssetType.Main}
        ,{file = AssetConfig.sceneblood, type = AssetType.Main}
    }
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources, function() self:PrefabLoaded() end)
end

function SceneTalk:PrefabLoaded ()
    if self.prefab~=nil then
        return
    end
    self.scenetalk_con = GameObject("scenetalk_con")
    self.scenetalk_con:AddComponent(RectTransform)
    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView, self.scenetalk_con)
    Utils.ChangeLayersRecursively(self.scenetalk_con.transform, "UI")
    self.scenetalk_con.transform:SetAsFirstSibling()

    local talkitem = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.scenetalk))
    talkitem.name = "SceneTalk"
    self.prefab = talkitem
    self.prefab.transform.position = Vector3(10000, 10000, 10000)
    self.prefab.transform.localScale = Vector3.one
    -- UIUtils.AddUIChild(self.scenetalk_con, talkitem)
    talkitem.transform:SetParent(self.scenetalk_con.transform)
    talkitem:SetActive(false)

    local btnitem = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.scenebtn))
    btnitem.name = "SceneBtn"
    btnitem.transform:GetComponent(Canvas).worldCamera = ctx.MainCamera
    self.btnprefab = btnitem
    self.btnprefab.transform.position = Vector3(10000, 10000, 10000)
    self.btnprefab.transform.localScale = Vector3.one
    btnitem.transform:SetParent(self.scenetalk_con.transform)
    btnitem:SetActive(false)

    local blooditem = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.sceneblood))
    blooditem.name = "SceneBlood"
    blooditem.transform:GetComponent(Canvas).worldCamera = ctx.MainCamera
    self.bloodprefab = blooditem
    self.bloodprefab.transform.position = Vector3(10000, 10000, 10000)
    self.bloodprefab.transform.localScale = Vector3.one
    blooditem.transform:SetParent(self.scenetalk_con.transform)
    blooditem:SetActive(false)
    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil
end

-- 显示npc头顶对话气泡
function SceneTalk:ShowTalk_NPC(id, battleid, _msg, time)
    local go = ParadeManager.Instance:GetNpcObj(id, battleid )
    if self.prefab == nil then
        self.prefab = GameObject.Find("SceneTalk")
    end
    if go == nil or go.gameObject == nil or self.prefab == nil then
        return
    end
    local has = nil
    local newitem = nil
    has = go.gameObject.transform:Find("talkitem")
    if has then
        newitem = has.gameObject
        local msg = newitem.transform:Find("originitem/talk/msg")
        for i=1,msg.childCount do
            GameObject.DestroyImmediate(msg:GetChild(0).gameObject)
        end
    else
        newitem = GameObject.Instantiate(self.prefab)
        newitem.transform:SetParent(go.gameObject.transform)
        newitem.name = "talkitem"
        newitem.transform.localPosition = Vector3(0,1,-30)
        newitem.transform.localScale = Vector3.one*0.0045
    end
    newitem.transform:Find("originitem/talk/msg"):GetComponent(Text).text = _msg
    newitem:SetActive(true)
    if time then
        LuaTimer.Add(time*1000, function ()  if newitem:Equals(NULL)==false then   newitem:SetActive(false) end end)
    else
        LuaTimer.Add(1500, function ()  if newitem:Equals(NULL)==false then   newitem:SetActive(false) end end)
    end
    -- print(newitem.transform:Find("originitem/talk/msg"):GetComponent(Text).text)
    local msgItem = MsgItemExt.New(newitem.transform:Find("originitem/talk/msg"):GetComponent(Text),240,30,35, true)
    msgItem:SetData(_msg)
end

function SceneTalk:HideTalk_Npc(id, battleid)
    local go = ParadeManager.Instance:GetNpcObj(id, battleid )
    if go == nil then return end
    local has = go.gameObject.transform:Find("talkitem")
    if has then
        has.gameObject:SetActive(false)
    end
end

-- 显示npc头顶按钮
function SceneTalk:ShowBtn_NPC(id, battleid, callback, time)
    local go = ParadeManager.Instance:GetNpcObj(id, battleid )
    if self.btnprefab == nil then
        self.btnprefab = GameObject.Find("SceneBtn")
    end
    if go == nil or go.gameObject == nil or self.btnprefab == nil then
        return
    end
    local has = nil
    has = go.gameObject.transform:Find("btnitem")
    local newitem = nil
    if has then
        newitem = has.gameObject
    else
        newitem = GameObject.Instantiate(self.btnprefab)
        newitem.transform:SetParent(go.gameObject.transform)
        newitem.name = "btnitem"
        newitem.transform.localPosition = Vector3(0.165,1,-1)
        newitem.transform.localScale = Vector3.one*0.0045
    end
    newitem:SetActive(true)
    if callback ~= nil then
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:RemoveAllListeners()
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:AddListener(function () newitem:SetActive(false) callback()        end)
    else
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:RemoveAllListeners()
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:AddListener(function () newitem:SetActive(false)       end)
    end
    if time then
        LuaTimer.Add(time*1000, function ()  if newitem:Equals(NULL)==false then   newitem:SetActive(false) end end)
    else
        LuaTimer.Add(3000, function ()  if newitem:Equals(NULL)==false then   newitem:SetActive(false) end end)
    end
end

function SceneTalk:HideBtn_Npc(id, battleid)
    local go = ParadeManager.Instance:GetNpcObj(id, battleid )
    local has = go.gameObject.transform:Find("btnitem")
    if has then
        has.gameObject:SetActive(false)
    end
end

-- 显示玩家头顶说话气泡
function SceneTalk:ShowTalk_Player(id, zone_id, platform, _msg, time, bgid)
    local go = ParadeManager.Instance:GetRoleObj(id, zone_id, platform)
    if go == nil or go.gameObject == nil  then
        return
    end
    if self.prefab == nil then
        self.prefab = GameObject.Find("SceneTalk")
    end
    local has = nil
    has = go.gameObject.transform:Find("talkitem")
    if has then
        GameObject.DestroyImmediate(has.gameObject)
    end
    local newitem = GameObject.Instantiate(self.prefab)
    newitem.name = "talkitem"
    newitem.transform:SetParent(go.gameObject.transform)
    newitem.transform.localScale = Vector3.one*0.0045
    -- newitem.transform:Find("originitem/talk/msg"):GetComponent(Text).text = _msg
    newitem.transform.localPosition = Vector3(0,1,-1)
    newitem:SetActive(true)
    if time then
        LuaTimer.Add(time*1000, function ()  if not BaseUtils.isnull(newitem) then   newitem:SetActive(false) end end)
    else
        LuaTimer.Add(1500, function ()  if not BaseUtils.isnull(newitem) then   newitem:SetActive(false) end end)
    end

    local msgItem = MsgItemExt.New(newitem.transform:Find("originitem/talk/msg"):GetComponent(Text),240,30,35, true)
    msgItem:SetData(_msg)
    self:SetIcon(newitem, bgid)
end

function SceneTalk:HideTalk_Player(id, zone_id, platform)
    local go = ParadeManager.Instance:GetRoleObj(id, zone_id, platform)
    local has = go.gameObject.transform:Find("talkitem")
    if has then
        has.gameObject:SetActive(false)
    end
end

-- 显示玩家头顶按钮
function SceneTalk:ShowBtn_Player(id, zone_id, platform, callback, time)
    local go = ParadeManager.Instance:GetRoleObj(id, zone_id, platform)
    if self.btnprefab == nil then
        self.btnprefab = GameObject.Find("SceneBtn")
    end
    if go == nil or go.gameObject == nil or self.btnprefab == nil then
        print("找不到ren")
        return
    end
    local has = nil
    has = go.gameObject.transform:Find("btnitem")
    local newitem = nil
    if has then
        newitem = has.gameObject
        newitem.transform:Find("originitem").gameObject:SetActive(true)
    else
        newitem = GameObject.Instantiate(self.btnprefab)
        newitem.transform:SetParent(go.gameObject.transform)
        newitem.name = "btnitem"
        newitem.transform.localPosition = Vector3(0.165,0.5,-1)
        newitem.transform.localScale = Vector3.one*0.0045
    end

    newitem:SetActive(true)
    if callback ~= nil then
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:RemoveAllListeners()
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:AddListener(function ()
            newitem.transform:Find("originitem").gameObject:SetActive(false)
            newitem.transform:Find("20070").gameObject:SetActive(false)
            newitem.transform:Find("20070").gameObject:SetActive(true)
            callback()        end)
    else
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:RemoveAllListeners()
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:AddListener(function ()
            newitem.transform:Find("originitem").gameObject:SetActive(false)
            newitem.transform:Find("20070").gameObject:SetActive(false)
            newitem.transform:Find("20070").gameObject:SetActive(true)        end)
    end
    if time then
        LuaTimer.Add(time*1000, function ()  if newitem:Equals(NULL)==false then   newitem:SetActive(false) end end)
    else
        LuaTimer.Add(3000, function ()  if newitem:Equals(NULL)==false then   newitem:SetActive(false) end end)
    end
end

function SceneTalk:HideBtn_Player(id, zone_id, platform)
    local go = ParadeManager.Instance:GetRoleObj(id, zone_id, platform)
    if go == nil or go.gameObject == nil then return end
    local has = go.gameObject.transform:Find("btnitem")
    if has then
        has.transform:Find("originitem").gameObject:SetActive(false)
        has.transform:Find("20070").gameObject:SetActive(false)
        has.transform:Find("20070").gameObject:SetActive(true)
    end
end

-- function SceneT
function SceneTalk:sceneToUIPos(gameObject)
    local pos = ctx.MainCamera.camera:WorldToScreenPoint(gameObject.transform.position)
    local scaleWidth = ctx.ScreenWidth
    local scaleHeight = ctx.ScreenHeight
    local origin = 960 / 540
    local currentScale = scaleWidth / scaleHeight
    local ch = 0
    local cw = 0
    local newx = 0
    local newy = 0
    local off_x = 0
    local off_y = 0
    if currentScale > origin then
        -- 以宽为准
        ch = 540
        cw = 960 * currentScale / origin

        newx = pos.x * cw / scaleWidth
        newy = pos.y * ch / scaleHeight

        off_x = self.offestV2.x * cw / scaleWidth
        off_y = self.offestV2.y * ch / scaleHeight
    else
        -- 以高为准
        ch = 540 * origin / currentScale
        cw = 960

        newx = pos.x * cw / scaleWidth
        newy = pos.y * ch / scaleHeight

        off_x = self.offestV2.x * cw / scaleWidth
        off_y = self.offestV2.y * ch / scaleHeight
    end
    pos = Vector3(newx + off_x - cw / 2, newy + off_y - ch / 2, 0)
    return pos
end

function SceneTalk:onTick()
    for k,v in pairs(self.uiTalkInfo) do
        if not BaseUtils.isnull(v.ui) and not BaseUtils.isnull(v.go) then
            v.ui.transform.localPosition = self:sceneToUIPos(v.go)
        elseif not BaseUtils.isnull(v.ui) then
            GameObject.Destroy(v.ui)
        end
    end
end


function SceneTalk:SetIcon(bubble, id)
    local cfg_data
    for i,v in ipairs(DataFriendZone.data_bubble) do
        if v.id == id then
            cfg_data = v
        end
    end
    if cfg_data ~= nil then
        local r,g,b = CombatUtil.TryParseHtmlString("#"..cfg_data.color)
        bubble.transform:Find("originitem/talk"):GetComponent(Image).color = Color(r/255,g/255,b/255)
        if cfg_data.outcolor ~= "" then
            local r,g,b = CombatUtil.TryParseHtmlString("#"..cfg_data.outcolor)
            bubble.transform:Find("originitem/talk"):GetComponent(Outline).effectColor = Color(r/255,g/255,b/255)
            bubble.transform:Find("originitem/talk"):GetComponent(Outline).enabled = true
        end
        for i,v in ipairs(cfg_data.location) do
            local spriteid = tostring(v[1])
            local x = v[2]*1.6
            local y = v[3]
            local item = bubble.transform:Find("originitem/talk"):Find(tostring(i))
            local sprite = PreloadManager.Instance:GetSprite(AssetConfig.bubble_icon, spriteid)
            local img = item.transform:GetComponent(Image)
            img.sprite = sprite
            img:SetNativeSize()
            item.transform.anchoredPosition = Vector2(x,y)
            item.gameObject:SetActive(true)
            if cfg_data.id == 30016 and i == 1 then
                item.transform.sizeDelta = Vector2(50,60)
            end
        end
    end
end
