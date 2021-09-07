-- ----------------------------------------------------------
-- 逻辑模块 - 等级突破
-- ----------------------------------------------------------
LevelBreakManager = LevelBreakManager or BaseClass(BaseManager)

function LevelBreakManager:__init()
    if LevelBreakManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	LevelBreakManager.Instance = self

    self.model = LevelBreakModel.New()
    self.assetWrapper = nil

    self.effectHideFunc = nil
    self.effectPath = "prefabs/effect/30131.unity3d"
    self.effect = nil
    self.effectTimeId = 0

    self:InitHandler()
end

function LevelBreakManager:__delete()
    
end

function LevelBreakManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(17400, self.on17400)
    self:AddNetHandler(17401, self.on17401)
    self:AddNetHandler(17402, self.on17402)
    self:AddNetHandler(17403, self.on17403)
    self:AddNetHandler(17404, self.on17404)
    self:AddNetHandler(17405, self.on17405)
end

function LevelBreakManager:on17400(data)
	--BaseUtils.dump(data, "on17400............")
	self.model:SetBreakData(data)
	self.model:UpdateWindow()
end

function LevelBreakManager:on17401(data)
	--BaseUtils.dump(data, "on17401............")
	if data.flag == 1 then
		self.model:CloseWindow()
        --LuaTimer.Add(500, function() self:PlayBreakSuc() end)
        self.model:OpenSuccessWindow()
		EventMgr.Instance:Fire(event_name.world_lev_change)
    	EventMgr.Instance:Fire(event_name.role_attr_change)
	end

	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function LevelBreakManager:on17402(data)
	--BaseUtils.dump(data, "on17402............")
	if data.flag == 1 then
		NoticeManager.Instance:FloatTipsByString(data.msg)
	else
	    local currentNpcData = BaseUtils.copytab(DataUnit.data_unit[73010])
	    local extra = {}
	    extra.base = currentNpcData
	    extra.base.buttons = {}
	    extra.base.plot_talk = data.msg
	    MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)
	end
end

function LevelBreakManager:on17403(data)
	--BaseUtils.dump(data, "on17403............")
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function LevelBreakManager:on17404(data)
	--BaseUtils.dump(data, "on17404............")
	self.model:SetQuestData(data)
	self.model:UpdataQuest()
end

function LevelBreakManager:on17405(data)
	--BaseUtils.dump(data, "on17405............")
	if data.flag == 1 then
		self.model:UpdateExchangeWindow()
	end
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function LevelBreakManager:send17400()
    Connection.Instance:send(17400, {})
end

function LevelBreakManager:send17401()
    Connection.Instance:send(17401, {})
end

function LevelBreakManager:send17402()
    Connection.Instance:send(17402, {})
end

function LevelBreakManager:send17403()
    Connection.Instance:send(17403, {})
end

function LevelBreakManager:send17404()
    Connection.Instance:send(17404, {})
end

function LevelBreakManager:send17405(exchangePoint)
    Connection.Instance:send(17405, {point = exchangePoint})
end

function LevelBreakManager:PlayBreakSuc()
    if BaseUtils.is_null(self.effect) then
        self:LoadEffect()
    else
        self.effect:SetActive(false)
        self.effect:SetActive(true)
        self:EffectTime()
    end
end

function LevelBreakManager:LoadEffect()
    self.assetWrapper = AssetBatchWrapper.New()

    local func = function()
        if self.assetWrapper == nil then
            return
        end

        local self_view = SceneManager.Instance.sceneElementsModel.self_view
        if self_view == nil then
            return
        end

        self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
        self.effect.name = "BreakEffect"
        local transform = self.effect.transform
        transform:SetParent(self_view.gameObject.transform)
        transform.localScale = Vector3.one
        transform.localPosition = Vector3(0, self_view.tpose.transform.localPosition.y, -5)
        transform:Rotate(Vector3(25, 0, 0))
        self.effect:SetActive(true)
        
        self.effectHideFunc = function() self:HideEffect() end

        self:EffectTime()

        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
    self.assetWrapper:LoadAssetBundle({{file = self.effectPath, type = AssetType.Main}}, func)
end

function LevelBreakManager:EffectTime()
    if self.effectTimeId ~= 0 then
        LuaTimer.Delete(self.effectTimeId)
        self.effectTimeId = 0
    end
    self.effectTimeId = LuaTimer.Add(3000, self.effectHideFunc)
end

function LevelBreakManager:HideEffect()
    self.effectTimeId = 0
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end
