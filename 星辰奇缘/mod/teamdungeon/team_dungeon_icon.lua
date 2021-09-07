-- 主界面 组队副本招募匹配状态按钮
-- ljh 20170216

TeamDungeonIcon = TeamDungeonIcon or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function TeamDungeonIcon:__init(model)
    self.model = model
	self.resList = {
        {file = AssetConfig.teamdungeonicon, type = AssetType.Main}
        , {file = AssetConfig.teamdungeon_textures, type = AssetType.Dep}
    }

    self.name = "TeamDungeonIcon"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------

    ------------------------------------
    self._update = function()
    	self:update()
	end

	self:LoadAssetBundleBatch()
end

function TeamDungeonIcon:__delete()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function TeamDungeonIcon:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teamdungeonicon))
    self.gameObject.name = "TeamDungeonIcon"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 45, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

	-----------------------------
    local transform = self.transform

    self.button = transform:FindChild("Button").gameObject
    self.button:GetComponent(Button).onClick:AddListener(function() self:button_click() end)
    self.buttonImage = self.button.gameObject:GetComponent(Image)

    self.timeObj = transform:Find("Time").gameObject
    self.timeText = transform:Find("Time/Text"):GetComponent(Text)

    self:Show()
    -- self:update()
    -- TeamDungeonManager.Instance.OnUpdate:Add(self._update)

    -- self:ClearMainAsset()
end

function TeamDungeonIcon:Show()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(true)
        self:update()

        TeamDungeonManager.Instance.OnUpdate:Remove(self._update)
        TeamDungeonManager.Instance.OnUpdate:Add(self._update)
    end
end

function TeamDungeonIcon:Hide()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(false)
    end
    
    TeamDungeonManager.Instance.OnUpdate:Remove(self._update)
end

function TeamDungeonIcon:update()
	if self.model.status > 0 then
        self.timeText.text = TI18N("招募中")
        -- if self.timerId == nil then
        --     self.timerId = LuaTimer.Add(0, 50, function() self:OnTimer() end)
        -- end
    elseif self.model.quickJionMark then
        self.timeText.text = TI18N("匹配中")    
        -- if self.timerId == nil then
        --     self.timerId = LuaTimer.Add(0, 50, function() self:OnTimer() end)
        -- end
	end
end

function TeamDungeonIcon:button_click()
	-- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.teamdungeonwindow)
    TeamDungeonManager.Instance.model:JustDoItOpenTeamDungeonWindow()
end

function TeamDungeonIcon:OnTimer()
    
end

