-- 主界面 万圣节南瓜精菜单
-- ljh 20161021

HalloweenMenuView = HalloweenMenuView or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function HalloweenMenuView:__init(model)
    self.model = model
	self.resList = {
        {file = AssetConfig.halloweenmenu, type = AssetType.Main}
        , {file = AssetConfig.halloween_textures, type = AssetType.Dep}
    }

    self.name = "HalloweenMenuView"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------
    self.timerId = nil

    ------------------------------------
    self._update = function()
    	self:update()
	end

	self:LoadAssetBundleBatch()
end

function HalloweenMenuView:__delete()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    
    EventMgr.Instance:RemoveListener(event_name.treasuremap_compass_update, self._update)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self._change_map)
    self:AssetClearAll()
end

function HalloweenMenuView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenmenu))
    self.gameObject.name = "HalloweenMenuView"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, -110, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    -- local rect = self.gameObject:GetComponent(RectTransform)
    -- rect.anchorMax = Vector2(1, 1)
    -- rect.anchorMin = Vector2(0, 0)
    -- rect.localPosition = Vector3(0, 0, 1)
    -- rect.offsetMin = Vector2(0, 0)
    -- rect.offsetMax = Vector2(0, 0)
    -- rect.localScale = Vector3.one

    self.transform = self.gameObject.transform

	-----------------------------
    local transform = self.transform

 --    self.itemObject = transform:FindChild("Panel/Rank/Item").gameObject
 --    self.itemObject:SetActive(false)
	-- self.container_transform = transform:FindChild("Panel/Rank/Mask/Container")

    self.button1 = transform:FindChild("Button1").gameObject
    self.button1:GetComponent(Button).onClick:AddListener(function() self:button1_click() end)

    self.button2 = transform:FindChild("Button2").gameObject
    self.button2:GetComponent(Button).onClick:AddListener(function() self:button2_click() end)

    self.button1_text = self.button1.transform:FindChild("Text"):GetComponent(Text)
 --    -----------------------------
 --    EventMgr.Instance:AddListener(event_name.treasuremap_compass_update, self._update)
 --    EventMgr.Instance:AddListener(event_name.scene_load, self._change_map)

    self:ClearMainAsset()

    self:Show()
end

function HalloweenMenuView:Show()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(true)
        self:update()
    end
end

function HalloweenMenuView:Hide()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(false)
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
    end
end

function HalloweenMenuView:update()
    if self.model.cooldowm > BaseUtils.BASE_TIME then
        self.button1_text.text = string.format("冷却时间：%s秒", self.model.cooldowm > BaseUtils.BASE_TIME)
        if self.timerId == nil then
            self.timerId = LuaTimer.Add(0, 1000, self._update)
        end
    else
        self.button1_text.text = string.format("火眼石(%s/20)", 20 - self.model.fire_times)
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
    end
end

function HalloweenMenuView:button1_click()
    if self.model.cooldowm > BaseUtils.BASE_TIME then
        NoticeManager.Instance:FloatTipsByString(TI18N("冷却中..."))
    else
        self.model:DoCheck() -- 火眼石检查是否地方阵营玩家
        self:Hide()   
    end
end

function HalloweenMenuView:button2_click()
    self:Hide()
end
