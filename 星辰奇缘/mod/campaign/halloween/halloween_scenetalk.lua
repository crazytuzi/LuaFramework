HalloweenSceneTalk = HalloweenSceneTalk or BaseClass(BaseManager)

function HalloweenSceneTalk:__init()
    if HalloweenSceneTalk.Instance then
        Logger.Error("单例不可重复初始化")
    end

    HalloweenSceneTalk.Instance = self
    self.is_loadprefabs = false
    self.btnprefab = nil
    self.offestV2 = Vector2(0,90)

    self.listener = function() self:LoadPrefabs() end
    EventMgr.Instance:AddListener(event_name.mainui_loaded, self.listener)

    self.btnItem = nil
end

function HalloweenSceneTalk:LoadPrefabs()
    if self.is_loadprefabs then
        return
    end

    local event = RoleManager.Instance.RoleData.event
    if event ~= RoleEumn.Event.Halloween and event ~= RoleEumn.Event.Halloween_sub then
        return 
    end

    local resources = {
        {file = AssetConfig.halloweenscenebtn, type = AssetType.Main}
        , {file = AssetConfig.halloween_textures, type = AssetType.Dep}
    }
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources, function() self:PrefabLoaded() end)
    self.is_loadprefabs = true
end

function HalloweenSceneTalk:PrefabLoaded()
    if self.scenetalk_con then
        return
    end

    self.scenetalk_con = GameObject("halloween_scenetalk_con")
    self.scenetalk_con:AddComponent(RectTransform)
    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView, self.scenetalk_con)
    Utils.ChangeLayersRecursively(self.scenetalk_con.transform, "UI")
    self.scenetalk_con.transform:SetAsFirstSibling()

    local btnitem = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.halloweenscenebtn))
    btnitem.name = "HalloweenSceneBtn"
    btnitem.transform:GetComponent(Canvas).worldCamera = ctx.MainCamera
    self.btnprefab = btnitem
    self.btnprefab.transform.position = Vector3(10000, 10000, 10000)
    self.btnprefab.transform.localScale = Vector3.one
    btnitem.transform:SetParent(self.scenetalk_con.transform)
    btnitem:SetActive(false)

    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil
end

-- 显示npc头顶按钮
function HalloweenSceneTalk:ShowBtn_NPC(id, battleid, callback, time)
    local key = BaseUtils.get_unique_npcid(id, battleid )
    local go = SceneManager.Instance.sceneElementsModel.NpcView_List[key]
    if self.btnprefab == nil then
        self.btnprefab = GameObject.Find("HalloweenSceneBtn")
    end
    if go == nil or go.gameObject == nil or self.btnprefab == nil then
        return
    end
    local has = nil
    has = go.gameObject.transform:Find("btnitem")
    local newitem = nil
    if has then
        newitem = has.gameObject
        newitem.transform:Find("originitem").gameObject:SetActive(true)
        newitem.transform:Find("20070").gameObject:SetActive(false)
    else
        newitem = GameObject.Instantiate(self.btnprefab)
        newitem.transform:SetParent(go.gameObject.transform)
        newitem.name = "btnitem"
        newitem.transform.localPosition = Vector3(0, 0.9,-1)
        newitem.transform.localScale = Vector3.one*0.005
    end
    newitem:SetActive(true)
    if callback ~= nil then
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:RemoveAllListeners()
        -- newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:AddListener(function () newitem:SetActive(false) callback()        end)
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:AddListener(function ()
            newitem.transform:Find("originitem").gameObject:SetActive(false)
            newitem.transform:Find("20070").gameObject:SetActive(false)
            newitem.transform:Find("20070").gameObject:SetActive(true)
            callback()        end)
    else
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:RemoveAllListeners()
        -- newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:AddListener(function () newitem:SetActive(false)       end)
        newitem.transform:Find("originitem/Button"):GetComponent(Button).onClick:AddListener(function ()
            newitem.transform:Find("originitem").gameObject:SetActive(false)
            newitem.transform:Find("20070").gameObject:SetActive(false)
            newitem.transform:Find("20070").gameObject:SetActive(true)        end)
    end
    if time then
        LuaTimer.Add(time*1000, function ()  if newitem:Equals(NULL)==false then   newitem:SetActive(false) end end)
    end

    self.btnItem = { gameObject = newitem, text = newitem.transform:Find("originitem/Button/Text"):GetComponent(Text) }
    self:OnTick()
end

function HalloweenSceneTalk:HideBtn_Npc(id, battleid)
    local key = BaseUtils.get_unique_npcid(id, battleid )
    local go = SceneManager.Instance.sceneElementsModel.NpcView_List[key]
    if go == nil or go.gameObject == nil then return end
    local has = go.gameObject.transform:Find("btnitem")
    if has then
        has.gameObject:SetActive(false)
    end
end

-- 显示玩家头顶按钮
function HalloweenSceneTalk:ShowBtn_Player(id, zone_id, platform, callback, time)
    local key = BaseUtils.get_unique_roleid(id, platform, zone_id)
    local go = SceneManager.Instance.sceneElementsModel.RoleView_List[key]
    if self.btnprefab == nil then
        self.btnprefab = GameObject.Find("HalloweenSceneBtn")
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
        newitem.transform:Find("20070").gameObject:SetActive(false)
    else
        newitem = GameObject.Instantiate(self.btnprefab)
        newitem.transform:SetParent(go.gameObject.transform)
        newitem.name = "btnitem"
        newitem.transform.localPosition = Vector3(0, 0.9,-1)
        newitem.transform.localScale = Vector3.one*0.005
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
    end

    self.btnItem = { gameObject = newitem, text = newitem.transform:Find("originitem/Button/Text"):GetComponent(Text) }
    self:OnTick()
end

function HalloweenSceneTalk:HideBtn_Player(id, zone_id, platform)
    local key = BaseUtils.get_unique_roleid(id, platform, zone_id)
    local go = SceneManager.Instance.sceneElementsModel.RoleView_List[key]
    if go == nil or go.gameObject == nil then return end
    local has = go.gameObject.transform:Find("btnitem")
    if has then
        has.transform:Find("originitem").gameObject:SetActive(false)
        has.transform:Find("20070").gameObject:SetActive(false)
        -- has.transform:Find("20070").gameObject:SetActive(true)
    end
end

function HalloweenSceneTalk:OnTick()
    local roleData = RoleManager.Instance.RoleData
    local halloweenModel = HalloweenManager.Instance.model
    if roleData.event == RoleEumn.Event.Halloween or roleData.event == RoleEumn.Event.Halloween_sub then
        if self.btnItem ~= nil and not BaseUtils.is_null(self.btnItem.gameObject) and not BaseUtils.is_null(self.btnItem.text) then
            if halloweenModel.cooldowm > BaseUtils.BASE_TIME then
                self.btnItem.text.text = string.format("<color='#ffff00'>%s秒</color>", halloweenModel.cooldowm - BaseUtils.BASE_TIME)
            else
                if 20 - halloweenModel.fire_times > 0 then
                    self.btnItem.text.text = string.format("<color='#00ff00'>%s</color>/20", 20 - halloweenModel.fire_times)
                else
                    self.btnItem.text.text = string.format("<color='#ff0000'>%s</color>/20", 0)
                end
            end
        else
            self.btnItem = nil
        end
    end
end