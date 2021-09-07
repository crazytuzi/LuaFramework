-- 主界面 宠物头像
PetInfoView = PetInfoView or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2

function PetInfoView:__init()
    self.model = model
	self.resList = {
        {file = AssetConfig.petinfoarea, type = AssetType.Main}
    }

    self.name = "PetInfoView"

    self.originPos = Vector3(-455, 13, 0)
    self.isShow = true
    self.gameObject = nil
    self.transform = nil

    ------------------------------------
    -- self.petNameText = nil
    self.petLevelText = nil
    self.petHeadImage = nil
    self.hpBar = nil
    self.mpBar = nil
    self.expBar = nil

    ------------------------------------
    self._update = function()
    	self:update()
	end

    self.adaptListener = function() self:AdaptIPhoneX() end

	-- self:LoadAssetBundleBatch()
    self.loadList = BaseUtils.create_queue()
    self:LoadAssetBundleBatch(self.resList, function() self:InitPanel() end)
end

function PetInfoView:ShowCanvas(bool)
    if self.gameObject == nil then
        return
    end

    if bool then
        self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    else
        self.gameObject.transform.localPosition = Vector3(0, -2000, 0)
    end
end

function PetInfoView:__delete()
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)
    BaseUtils.CancelIPhoneXTween(self.transform)
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetInfoView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petinfoarea))
    self.gameObject.name = "PetInfoView"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one

    self.transform = self.gameObject.transform

    self.mainRect = self.transform:FindChild("Main"):GetComponent(RectTransform)
    -----------------------------
    -- self.petNameText = self.transform:FindChild("Main/PetNameText"):GetComponent(Text)
    self.petLevelText = self.transform:FindChild("Main/PetLvText"):GetComponent(Text)
    self.petHeadImage = self.transform:FindChild("Main/PetHeadContainer/PetImage"):GetComponent(Image)

    self.barBg = self.transform:Find("Main/BarBG").gameObject
    self.hpBar = self.transform:FindChild("Main/HPBar").gameObject
    self.mpBar = self.transform:FindChild("Main/MPBar").gameObject
    self.expBar = self.transform:FindChild("Main/ExpBar").gameObject

    self.transform:FindChild("Main"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet) end)

    -----------------------------
    self:update()
    self:AdaptIPhoneX()
    EventMgr.Instance:AddListener(event_name.battlepet_update, function(change_list) self:update_battlepet(change_list) end)
    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)

    self:ClearMainAsset()

    if BaseUtils.IsVerify then
        BaseUtils.VestChangeWindowBg(self.gameObject)
        BaseUtils.VestChangeMainUIPos(self)
    end
end

function PetInfoView:update()
    if self.gameObject == nil then return end
    self:updateHead()
    self:updateInfo()
	-- self:ClearDepAsset()
end

function PetInfoView:update_battlepet(change_list)
    if change_list == nil or table.containValue(change_list, "base_id") then self:updateHead() end
    self:updateInfo()
end

function PetInfoView:updateInfo()
    local data = PetManager.Instance.model.battle_petdata

    if data == nil then
        -- self.petNameText.text = ""
        self.petLevelText.text = ""
        self.hpBar.transform.localScale = Vector3(0, 1, 1)
        self.mpBar.transform.localScale = Vector3(0, 1, 1)
        self.expBar.transform.localScale = Vector3(0, 1, 1)
    else
        -- self.petNameText.text = data.name
        self.petLevelText.text = tostring(data.lev)

        local hpX = data.hp / data.hp_max
        if hpX > 1 then
            hpX = 1
        elseif hpX < 0 then
            hpX = 0
        end
        self.hpBar.transform.localScale = Vector3(hpX, 1, 1)

        local mpX = data.mp / data.mp_max
        if mpX > 1 then
            mpX = 1
        elseif mpX < 0 then
            mpX = 0
        end
        self.mpBar.transform.localScale = Vector3(mpX, 1, 1)

        local expX = data.exp / data.max_exp
        if expX > 1 then
            expX = 1
        elseif expX < 0 then
            expX = 0
        end
        self.expBar.transform.localScale = Vector3(expX, 1, 1)
    end

    self:updatePointEffect()
end

function PetInfoView:updateHead()
    local data = PetManager.Instance.model.battle_petdata
    local resList = {}
    if data == nil then
        if self.headId ~= "DefaultPetHead" then
            self.headId = "DefaultPetHead"
            self:updateHead_resLoadCompleted()
        end
    else
        -- if self.headId ~= string.format("%s", data.base.head_id) then
        --     self.headId = string.format("%s", data.base.head_id)
        --     table.insert(resList, {file = BaseUtils.PetHeadPath(self.headId), type = AssetType.Dep})
        -- end
    end

    -- if #resList > 0 then
    --     self:LoadAssetBundleBatch(resList, function() self:updateHead_resLoadCompleted() end)
    -- end
    self:updateHead_resLoadCompleted()
end

function PetInfoView:updateHead_resLoadCompleted()
    local data = PetManager.Instance.model.battle_petdata
    if data == nil then
        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.petHeadImage.gameObject)
        end
        self.headLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "DefaultPetHead"))
        -- self.petHeadImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "DefaultPetHead")
        -- self.petHeadImage:SetNativeSize()
    else
        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.petHeadImage.gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,data.base.head_id)

        -- self.petHeadImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(data.base.head_id), string.format("%s", data.base.head_id))
        -- self.petHeadImage:SetNativeSize()
        -- self.petHeadImage.rectTransform.sizeDelta = Vector2(68, 68)
    end
end

function PetInfoView:updatePointEffect()
    local data = PetManager.Instance.model.battle_petdata
    if data ~= nil then
        if data.point > 0 then
            if self.effect == nil then
                local fun = function(effectView)
                    local effectObject = effectView.gameObject

                    effectObject.transform:SetParent(self.transform:FindChild("Main/PetHeadContainer"))
                    effectObject.transform.localScale = Vector3(0.7, 0.7, 0.7)
                    effectObject.transform.localPosition = Vector3(15, 20, -400)
                    effectObject.transform.localRotation = Quaternion.identity

                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                end
                self.effect = BaseEffectView.New({effectId = 20122, time = nil, callback = fun})
            else
                self.effect:SetActive(true)
            end
        elseif self.effect ~= nil then
            self.effect:SetActive(false)
        end
    elseif self.effect ~= nil then
        self.effect:SetActive(false)
    end
end
------------------------------------

-- 资源加载
function PetInfoView:LoadAssetBundleBatch(resList, OnCompleted)
    if self.assetWrapper == nil then
        self.assetWrapper = AssetBatchWrapper.New()
        local callback = function()
            OnCompleted()
            self:OnResLoadCompleted()
        end
        self.assetWrapper:LoadAssetBundle(resList, callback)
    else
        BaseUtils.enqueue(self.loadList, { resList = resList, OnCompleted = OnCompleted })
    end
end

-- 资源加载完成，加载下一波资源
function PetInfoView:OnResLoadCompleted()
    self.assetWrapper:DeleteMe()
    self.assetWrapper = nil

    if self.gameObject == nil then return end

    local loadData = BaseUtils.dequeue(self.loadList)
    if loadData ~= nil then
        self:LoadAssetBundleBatch(loadData.resList, loadData.OnCompleted)
    end
end

function PetInfoView:TweenHide()
    if BaseUtils.IsVerify then return end
    if not BaseUtils.is_null(self.mainRect) then
        Tween.Instance:Move(self.mainRect, Vector3(self.originPos.x, 100, self.originPos.z), 0.2)
        self.isShow = false
    end
end

function PetInfoView:TweenShow()
    if BaseUtils.IsVerify then return end
    if not BaseUtils.is_null(self.mainRect) then
        Tween.Instance:Move(self.mainRect, self.originPos, 0.2)
        self.isShow = true
    end
end

function PetInfoView:AdaptIPhoneX()
    BaseUtils.AdaptIPhoneX(self.transform)
end


