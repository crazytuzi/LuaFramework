-- -----------------------------
-- 场景聊天气泡
-- hosr
-- -----------------------------

DramaSceneTalk = DramaSceneTalk or BaseClass()

function DramaSceneTalk:__init()
	if DramaSceneTalk.Instance then
		return
	end
	DramaSceneTalk.Instance = self

	self.assetWrapper = nil
	self.path = "prefabs/ui/scenetalk/scenetalktype2.unity3d"
	self.res = "textures/ui/talkbubble.unity3d"

    self.listener = function() self:OnMainUiLoad() end
    EventMgr.Instance:AddListener(event_name.mainui_loaded, self.listener)

    -- 剧情使用到的记录
    self.dramaUseList = {}
end

function DramaSceneTalk:OnMainUiLoad()
    EventMgr.Instance:RemoveListener(event_name.mainui_loaded, self.listener)
    local resources = {
        {file = self.path, type = AssetType.Main},
        {file = self.res, type = AssetType.Dep},
    }
    if self.assetWrapper == nil then
	    self.assetWrapper = AssetBatchWrapper.New()
	    self.assetWrapper:LoadAssetBundle(resources, function() self:PrefabLoaded() end)
    end
end

function DramaSceneTalk:PrefabLoaded()
    self.prefab = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.path))
    self.prefab.name = "DramaSceneTalk"
    local transform = self.prefab.transform
    transform.position = Vector3(10000, 10000, 10000)
    transform.localScale = Vector3.one
    transform:SetParent(DramaManager.Instance.model.dramaCanvas.transform)
    self.prefab:SetActive(false)

	if self.assetWrapper ~= nil then
		self.assetWrapper:DeleteMe()
		self.assetWrapper = nil
	end
end

function DramaSceneTalk:DramaEnd()
	for _,v in pairs(self.dramaUseList) do
		v:DeleteMe()
	end
	self.dramaUseList = {}
end

-- type = 0 剧情
-- type = 1 场景
function DramaSceneTalk:ShowNpcTalk(type, id, battleid, msg, time ,callback)
    local key = BaseUtils.get_unique_npcid(id, battleid)
    local npc = SceneManager.Instance.sceneElementsModel.NpcView_List[key]
    if npc ~= nil then
	    local item = self.dramaUseList[string.format("%s_%s", id, battleid)]
	    if item == nil then
	    	item = DramaSceneTalkItem.New(GameObject.Instantiate(self.prefab), npc.gameObject)
	    	if type == 0 then
	    		self.dramaUseList[string.format("%s_%s", id, battleid)] = item
	    	end
	    end
	    item:Show(msg, time, callback)
	else
		print("找不到npc " .. tostring(key))
		if callback ~= nil then
			callback()
		end
    end
end

function DramaSceneTalk:ShowPlayerTalk(type, rid, platform, zone_id, msg, time, callback)
    local key = BaseUtils.get_unique_roleid(rid, zone_id, platform)
    local player = SceneManager.Instance.sceneElementsModel.RoleView_List[key]
    if player ~= nil then
	    local item = self.dramaUseList[string.format("%s_%s_%s", rid, platform, zone_id)]
	    if item == nil then
	    	item = DramaSceneTalkItem.New(GameObject.Instantiate(self.prefab), player.gameObject)
	    	if type == 0 then
	    		self.dramaUseList[string.format("%s_%s_%s", rid, platform, zone_id)] = item
	    	end
	    end
	    item:Show(msg, time, callback)
	else
		print("找不到player " .. tostring(key))
		if callback ~= nil then
			callback()
		end
    end
end

