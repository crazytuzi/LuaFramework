--作者:hzf
--17-2-7 下02时52分06秒
--功能:宝藏石板

TreasureMazeWindow = TreasureMazeWindow or BaseClass(BaseWindow)
function TreasureMazeWindow:__init(model)
	self.model = model
	self.cacheMode = CacheMode.Visible
    -- self.winLinkType = WinLinkType.Link
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
	self.mgr = TreasureMazeManager.Instance
    self.specialEffect = "prefabs/effect/20266.unity3d"
    self.scanEffect = "prefabs/effect/20278.unity3d"
    self.clickEffect = "prefabs/effect/20279.unity3d"
    self.breakEffect = "prefabs/effect/20280.unity3d"
    self.mosterEffect = "prefabs/effect/20281.unity3d"
    self.dragonEffect = "prefabs/effect/20282.unity3d"
    self.dragonbeforeEffect = "prefabs/effect/20283.unity3d"
    self.doubleEffect = "prefabs/effect/20284.unity3d"
    self.p2Effect = "prefabs/effect/20285.unity3d"
    self.p1Effect = "prefabs/effect/20286.unity3d"
    self.p3Effect = "prefabs/effect/20287.unity3d"
    self.openEffect = "prefabs/effect/20288.unity3d"
    self.resetEffect = "prefabs/effect/20289.unity3d"
    self.ghostEffect = "prefabs/effect/20290.unity3d"
    self.ghosttipsEffect = "prefabs/effect/20291.unity3d"
    self.ghostclickEffect = "prefabs/effect/20292.unity3d"
    self.ghostkillEffect = "prefabs/effect/20356.unity3d"
    self.flyEffect = "prefabs/effect/20296.unity3d"
    self.guideflyEffect = "prefabs/effect/20309.unity3d"
    self.guideEffect = "prefabs/effect/20310.unity3d"
    self.hotEffect = "prefabs/effect/20311.unity3d"
    self.goldEffect = "prefabs/effect/20312.unity3d"
    self.eventEffect = "prefabs/effect/20319.unity3d"
    self.animalEffect = "prefabs/effect/20320.unity3d"
	self.animalendEffect = "prefabs/effect/20322.unity3d"
	self.resList = {
		{file = AssetConfig.treasuremazewindow, type = AssetType.Main},
		{file = self.flyEffect, type = AssetType.Main},
		{file = self.scanEffect, type = AssetType.Main},
		{file = self.clickEffect, type = AssetType.Main},
		{file = self.breakEffect, type = AssetType.Main},
		{file = self.mosterEffect, type = AssetType.Main},
		{file = self.dragonbeforeEffect, type = AssetType.Main},
		{file = self.dragonEffect, type = AssetType.Main},
		{file = self.doubleEffect, type = AssetType.Main},
		{file = self.p2Effect, type = AssetType.Main},
		{file = self.p1Effect, type = AssetType.Main},
		{file = self.p3Effect, type = AssetType.Main},
        {file = self.openEffect, type = AssetType.Main},
        {file = self.resetEffect, type = AssetType.Main},
        {file = self.ghostEffect, type = AssetType.Main},
        {file = self.ghosttipsEffect, type = AssetType.Main},
        {file = self.ghostclickEffect, type = AssetType.Main},
        {file = self.ghostkillEffect, type = AssetType.Main},
        {file = self.specialEffect, type = AssetType.Main},
        {file = self.goldEffect, type = AssetType.Main},
        {file = self.guideEffect, type = AssetType.Main},
        {file = self.guideflyEffect, type = AssetType.Main},
        {file = self.hotEffect, type = AssetType.Main},
        {file = self.animalEffect, type = AssetType.Main},
        {file = self.animalendEffect, type = AssetType.Main},
		{file = self.eventEffect, type = AssetType.Main},
        {file = AssetConfig.treasuremazetexture, type = AssetType.Dep},
		{file = AssetConfig.treasuremazestyle, type = AssetType.Dep},
		{file = AssetConfig.dungeonname, type = AssetType.Dep},
	}
	self.OnOpenEvent:Add(function() self:OnShow() end)
	self.OnHideEvent:Add(function() self:OnHide() end)
	self.listener = function()
		self:InitBlock()
	end
    self.dragonObjList = {}
	self.guideObjList = {}
	self.flyObjList = {}
	self.dragonlistener = function()
        self:OnDragon()
    end
    self.guidelistener = function()
		self:OnGuide()
	end
	self.resetListener = function()
		self:OnReset()
	end
	self.ghostListener = function()
		self:OnGhostResult()
	end
    self.ghostkillListener = function(data)
        BaseUtils.dump(data, "事件数据")
        self:PlayKillMoster(data.x, data.y)
    end
	self.infoListener = function()
		self:SetItemNum()
	end
    self.timesListener = function()
        self:UpdateDungeonTimes()
    end
	self.currstyle = nil
	self.currstyleid = nil
	self.clicknum = 0
	self.ghostdata = {x = 2, y = 2, id = 3}
	self.hasInit = false
	self.firstInit = true
    self.CycleitemList = {}
    self.isopen = false
	self.closefunc = function(cbtype)
        if cbtype ~= 55 then
            --队伍状态进战斗不关闭
            return
        end
        if self.GhostPanel.gameObject.activeSelf then
            return
        end
        if self.isopen then
            self.fightClose = true
            self.model:CloseMazeWindow()
            BackpackManager.Instance.mainModel:CloseMain()
        end
    end
    self.openfunc = function(cbtype)
        if self.fightClose then
            self.fightClose = false
            self.model:OpenMazeWindow()
        end
    end
    self.currpiece_num = nil
    self.currpiece_data = {}
end

function TreasureMazeWindow:__delete()
	if self.keyTween ~= nil then
        Tween.Instance:Cancel(self.keyTween.id)
        self.keyTween = nil
    end
    if self.previewCom ~= nil then
		self.previewCom:DeleteMe()
		self.previewCom = nil
	end
    if self.GridList ~= nil and next(self.GridList) ~= nil then
        for i=1,5 do
            for j=1,5 do
                self.GridList[i][j]:DeleteMe()
                self.FloorList[i][j].sprite = nil
                self.FloorList[i][j] = nil
            end
        end
        self.GridList = nil
        self.FloorList = nil
    end
	EventMgr.Instance:RemoveListener(event_name.end_fight, self.openfunc)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.closefunc)
	self.mgr.mazeUpdate:Remove(self.listener)
    self.mgr.dragonUpdate:Remove(self.dragonlistener)
	self.mgr.guideUpdate:Remove(self.guidelistener)
	self.mgr.onmazeReset:Remove(self.resetListener)
    self.mgr.onCatchGhost:Remove(self.ghostListener)
	self.mgr.onKillGhost:Remove(self.ghostkillListener)
    TeamDungeonManager.Instance.OnUpdate:Remove(self.timesListener)
	EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.infoListener)
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function TreasureMazeWindow:OnHide()
    self.isopen = false
end

function TreasureMazeWindow:OnShow()
    if self.ghostkillObj ~= nil then
        self.ghostkillObj:SetActive(false)
    end
    self.isopen = true
    self.fightClose = false
    self.mgr:Send18800()
end

function TreasureMazeWindow:InitPanel()
    self.isopen = true
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.treasuremazewindow))
	self.gameObject.name = "TreasureMazeWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.Panel = self.transform:Find("Panel")
	self.MainCon = self.transform:Find("MainCon")
	self.MainConGroup = self.MainCon:GetComponent(CanvasGroup)
	self.bg = self.transform:Find("MainCon/bg")
	self.Title = self.transform:Find("MainCon/Title")
	self.transform:Find("MainCon/Title/Text"):GetComponent(Text).text = TI18N("宝藏迷城")
    self.MinorText = self.transform:Find("MainCon/MinorText"):GetComponent(Text)
	self.Maze = self.transform:Find("MainCon/Maze")

	self.Grid = self.transform:Find("MainCon/Maze/Mask/Grid")
	self.GridList = {}
	self.FloorList = {}
	local floor = self.Maze:Find("Mask/floor")
	local block_temp = self.Grid:Find("blocktemp").gameObject
	local floor_temp = floor:Find("floortemp").gameObject
	for i=1,5 do
		self.GridList[i] = {}
		self.FloorList[i] = {}
		for j=1,5 do
			local blocktransform = GameObject.Instantiate(block_temp).transform
			blocktransform:SetParent(self.Grid)
			blocktransform.localScale = Vector3.one
			blocktransform.anchoredPosition3D = Vector2((i-1)*72, -(j-1)*67, 0)
			local floortransform = GameObject.Instantiate(floor_temp).transform
			floortransform:SetParent(floor)
			floortransform.localScale = Vector3.one
			floortransform.anchoredPosition3D = Vector3((i-1)*72, -(j-1)*67, 0)
			self.GridList[i][j] = TreasureMazeBlock.New(blocktransform, self, i, j)
			self.FloorList[i][j] = floortransform:GetComponent(Image)
		end
	end
	block_temp:SetActive(false)
	floor_temp:SetActive(false)

	self.LBorder = self.Maze:Find("Mask/border/L"):GetComponent(Image)
	self.RBorder = self.Maze:Find("Mask/border/R"):GetComponent(Image)
	self.TBorder = self.Maze:Find("Mask/border/T"):GetComponent(Image)
	self.BBorder = self.Maze:Find("Mask/border/B"):GetComponent(Image)

	self.Top = self.transform:Find("MainCon/Top")
    self.NameImg = self.transform:Find("MainCon/Top/NameImg"):GetComponent(Image)
    self.DescText = self.transform:Find("MainCon/Top/DescText"):GetComponent(Text)
    self.TipsButton = self.transform:Find("MainCon/Top/TipsButton"):GetComponent(Button)
    self.TipsButton.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.TipsButton.gameObject, itemData = {
            TI18N("1、使用<color='#ffff00'>秘宝锤</color>，敲开石板获得奖励"),
            TI18N("2、每次敲开石板有概率获得<color='#ffff00'>秘宝钥匙碎片</color>，集齐三块秘宝钥匙碎片可获得<color='#ffff00'>秘宝钥匙</color>"),
            TI18N("3、宝藏迷城的<color='#ffff00'>最终秘宝</color>需要<color='#ffff00'>秘宝钥匙</color>才能解开"),
            TI18N("4、解开最终秘宝后将<color='#ffff00'>自动重置</color>宝藏迷城"),
            TI18N("5、主题重置顺序：<color='#ffff00'>精灵公主>熔火之心>水帘洞天>遗忘洞穴</color>（越后面终点奖励越好）"),
            TI18N("6、宝藏迷城只会出现<color='#ffff00'>已通关</color>副本主题"),
            }})
        end)
    self.transform:Find("MainCon/Right/numbg"):GetComponent(Button).onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.TipsButton.gameObject, itemData = {
            TI18N("使用<color='#ffff00'>秘宝锤</color>可以敲碎一块宝藏迷城，有机会获得丰厚的奖励哦，秘宝锤可在<color='#ffff00'>挑战副本、积分兑换</color>等地方获得"),
            }})
    end)


    -- self.TipsButton.onClick:AddListener(function()
    --     TipsManager.Instance:ShowText({gameObject = self.TipsButton.gameObject, itemData = {
    --         TI18N("1、使用<color='#ffff00'>秘宝锤</color>，敲开石板获得奖励"),
    --         TI18N("2、每次敲开石板有概率获得<color='#ffff00'>秘宝钥匙碎片</color>，集齐三块秘宝钥匙碎片可获得<color='#ffff00'>秘宝钥匙</color>"),
    --         TI18N("3、宝藏迷城的<color='#ffff00'>最终秘宝</color>需要<color='#ffff00'>秘宝钥匙</color>才能解开"),
    --         TI18N("4、解开最终秘宝后将<color='#ffff00'>自动重置</color>宝藏迷城"),
    --         TI18N("5、重置宝藏迷城时将随机出现<color='#ffff00'>已通关</color>的副本主题，不同的副本主题拥有不同的神秘事件"),
    --         }})
    --     end)

    self.Left = self.transform:Find("MainCon/Left")
    self.TipsButton = self.transform:Find("MainCon/Left/TipsButton"):GetComponent(Button)
    self.TipsButton.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.TipsButton.gameObject, itemData = {
            TI18N("1、道具获取：<color='#ffff00'>挑战副本</color>、<color='#ffff00'>敲开石板</color>有概率获得道具"),
            TI18N("2、道具使用：点击道具按钮，<color='#ffff00'>消耗</color>一个背包里的道具来触发效果"),
            TI18N("3、道具效果：使用<color='#ffff00'>[感知]</color>，可探查并排除一个未发现的<color='#ffff00'>地穴</color>，避免踩坑；使用<color='#ffff00'>[双倍]</color>，可使下一个<color='#ffff00'>道具奖励</color>变为双倍。非道具奖励<color='#ffff00'>不消耗</color>双倍。"),
            }})
        end)

    self.Button1 = self.transform:Find("MainCon/Left/Button1"):GetComponent(Button)
    self.Button1.onClick:AddListener(function()
    	local scanCardnum = BackpackManager.Instance:GetItemCount(21221)
        local holenum = 0
        if self.mgr.mazeData ~= nil and self.mgr.mazeData.opens ~= nil then
            for k,v in pairs(self.mgr.mazeData.opens) do
                if v.type == 0 and v.hard == v.times then
                    holenum = holenum + 1
                end
            end
        end
        if holenum >= 5 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有更多的坑了，勇敢上吧"))
            return
        end
		if scanCardnum > 0 then
			self:PlayScan()
			LuaTimer.Add(1500, function()
    			self.mgr:Send18809()
			end)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("道具不足，无法操作"))
    	end
    end)
    self.Button1Text = self.transform:Find("MainCon/Left/Button1/Text"):GetComponent(Text)
    self.Button2 = self.transform:Find("MainCon/Left/Button2"):GetComponent(Button)
    self.Button2.onClick:AddListener(function()
    	self.mgr:Send18810()
    end)
    self.Button2Text = self.transform:Find("MainCon/Left/Button2/Text"):GetComponent(Text)

    self.Right = self.transform:Find("MainCon/Right")
    -- self.numbg = self.transform:Find("MainCon/Right/numbg")
    self.numText = self.transform:Find("MainCon/Right/numbg/Text"):GetComponent(Text)
    self.numText.text = "0"
    -- self.Image = self.transform:Find("MainCon/Right/numbg/Image"):GetComponent(Image)
    self.Desc = self.transform:Find("MainCon/Right/Desc")
    self.TeamButton = self.transform:Find("MainCon/Right/TeamButton"):GetComponent(Button)
    self.TeamButton.onClick:AddListener(function()
    	self.model:CloseMazeWindow()
    	TeamDungeonManager.Instance.model:OpenTeamDungeonWindowByHand()
    end)
    self.TeamButtonText = self.transform:Find("MainCon/Right/TeamButton/Text"):GetComponent(Text)
    local lev = RoleManager.Instance.RoleData.lev
    local times = DataDungeon.data_team_dungeon_times[lev].limit
    local color = "<color='#906014'>"
    if times == TeamDungeonManager.Instance.model.passTimes then
        color = "<color='#ffff00'>"
    end
    local showtimes = times - TeamDungeonManager.Instance.model.passTimes
    if showtimes < 0 then
        showtimes = 0
    end
    self.TeamButtonText.text = string.format(TI18N("组队副本%s（%s/%s）</color>"), color, showtimes, times)

    self.ShopButton = self.transform:Find("MainCon/Right/ShopButton"):GetComponent(Button)
    self.ShopButton.onClick:AddListener(function()
    	-- self.model:CloseMazeWindow()
    	ShopManager.Instance:OpenWindow({2})
    end)
    self.ShopButtonText = self.transform:Find("MainCon/Right/ShopButton/Text"):GetComponent(Text)

    self.StylePanel = self.transform:Find("MainCon/StylePanel")
    self.StylePanel.gameObject:SetActive(true)
    self.StylePanelItem = self.StylePanel:Find("Image").gameObject
    self.styleItemList = {}


    self.KeyNum = self.transform:Find("MainCon/Right/KeyNum")
    local button = self.KeyNum.gameObject:GetComponent(Button) or self.KeyNum.gameObject:AddComponent(Button)
    button.onClick:AddListener(function()
        if self.currpiece_num ~= 3 then
            NoticeManager.Instance:FloatTipsByString(TI18N("找到藏在石板中的<color='#ffff00'>水晶能量</color>，可激活<color='#ffff00'>秘宝钥匙</color>"))
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>秘宝钥匙</color>已激活，请点击最终秘宝开启"))
            if not self.playingEnd then
                self:PlayOpenEffect()
                self.playingEnd = true
                LuaTimer.Add(3000, function()
                    self.playingEnd = false
                    TreasureMazeManager.Instance:Send18808()
                end)
            end
        end
    end)
    self.KeyImg = self.transform:Find("MainCon/Right/KeyNum/key").gameObject
    self.pieceList = {}
    self.piecePos = {
    	Vector3(282, 68.6, -300),
    	Vector3(282, 70.3, -300),
    	Vector3(279, 69.6, -300)
	}
    for i=1,3 do
    	self.pieceList[i] = self.KeyNum:Find("p"..tostring(i)).gameObject
    	self.pieceList[i]:SetActive(false)
    end

    self.GhostPanel = self.transform:Find("GhostPanel"):GetComponent(Button)
    self.GhostPanel.onClick:AddListener(function()
        local curScreenSpace=Vector3(Input.mousePosition.x*1,Input.mousePosition.y*1, -2)
        if self.ghostclickObj ~= nil then
            self.ghostclickObj:SetActive(false)
            self.ghostclickObj.transform.position= ctx.UICamera:ScreenToWorldPoint(curScreenSpace)
            self.ghostclickObj:SetActive(true)
        end
    	self.clicknum = self.clicknum + 1
    	if self.clicknum >= 5 then
    		self.mgr:Send18805(self.ghostdata)
    		self.clicknum = 0
    	end
        SoundManager.Instance:Play(214)
    end)

	self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseMazeWindow()
	end)
	self:InitEffect()
	self.mgr.mazeUpdate:AddListener(self.listener)
    self.mgr.dragonUpdate:AddListener(self.dragonlistener)
	self.mgr.guideUpdate:AddListener(self.guidelistener)
	self.mgr.onmazeReset:AddListener(self.resetListener)
	self.mgr.onCatchGhost:AddListener(self.ghostListener)
    self.mgr.onKillGhost:AddListener(self.ghostkillListener)
    TeamDungeonManager.Instance.OnUpdate:AddListener(self.timesListener)
	EventMgr.Instance:AddListener(event_name.backpack_item_change, self.infoListener)
	self.mgr:Send18800()
	self:SetItemNum()
	self:SetDungeonStyle()
	EventMgr.Instance:AddListener(event_name.end_fight, self.openfunc)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.closefunc)
    self.hasInit = true
end

function TreasureMazeWindow:InitEffect()

    self.clickObj = GameObject.Instantiate(self:GetPrefab(self.clickEffect))
    self.clickObj.transform:SetParent(self.MainCon)
    self.clickObj.transform.localScale = Vector3(1, 1, 1)
    self.clickObj.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.clickObj.transform, "UI")
    self.clickObj:SetActive(false)

    self.flyObj = GameObject.Instantiate(self:GetPrefab(self.flyEffect))
    self.flyObj.transform:SetParent(self.MainCon)
    self.flyObj.transform.localScale = Vector3(1, 1, 1)
    self.flyObj.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.flyObj.transform, "UI")
    self.flyObj:SetActive(false)

    self.breakObj = GameObject.Instantiate(self:GetPrefab(self.breakEffect))
    self.breakObj.transform:SetParent(self.MainCon)
    self.breakObj.transform.localScale = Vector3(1, 1, 1)
    self.breakObj.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.breakObj.transform, "UI")
    self.breakObj:SetActive(false)

    self.goldObj = GameObject.Instantiate(self:GetPrefab(self.goldEffect))
    self.goldObj.transform:SetParent(self.MainCon)
    self.goldObj.transform.localScale = Vector3(1, 1, 1)
    self.goldObj.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.goldObj.transform, "UI")
    self.goldObj:SetActive(false)

    self.scanObj = GameObject.Instantiate(self:GetPrefab(self.scanEffect))
    self.scanObj.transform:SetParent(self.MainCon)
    self.scanObj.transform.localScale = Vector3(1, 1, 1)
    self.scanObj.transform.localPosition = Vector3(0, -51.7, -300)
    Utils.ChangeLayersRecursively(self.scanObj.transform, "UI")
    self.scanObj:SetActive(false)

    self.mosterObj = GameObject.Instantiate(self:GetPrefab(self.mosterEffect))
    self.mosterObj.transform:SetParent(self.MainCon)
    self.mosterObj.transform.localScale = Vector3(1, 1, 1)
    self.mosterObj.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.mosterObj.transform, "UI")
    self.mosterObj:SetActive(false)

    self.helpendObj = GameObject.Instantiate(self:GetPrefab(self.animalendEffect))
    self.helpendObj.transform:SetParent(self.MainCon)
    self.helpendObj.transform.localScale = Vector3(1, 1, 1)
    self.helpendObj.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.helpendObj.transform, "UI")
    self.helpendObj:SetActive(false)

    self.beforeObj = GameObject.Instantiate(self:GetPrefab(self.dragonbeforeEffect))
    self.beforeObj.transform:SetParent(self.MainCon)
    self.beforeObj.transform.localScale = Vector3(1, 1, 1)
    self.beforeObj.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.beforeObj.transform, "UI")
    self.beforeObj:SetActive(false)

    self.doubleObj = GameObject.Instantiate(self:GetPrefab(self.doubleEffect))
    self.doubleObj.transform:SetParent(self.Button2.gameObject.transform)
    self.doubleObj.transform.localScale = Vector3(1, 1, 1)
    self.doubleObj.transform.localPosition = Vector3(0, 0 , -300)
    Utils.ChangeLayersRecursively(self.doubleObj.transform, "UI")
    self.doubleObj:SetActive(false)

    self.p1Obj = GameObject.Instantiate(self:GetPrefab(self.p1Effect))
    self.p1Obj.transform:SetParent(self.MainCon)
    self.p1Obj.transform.localScale = Vector3(1, 1, 1)
    self.p1Obj.transform.localPosition = Vector3(0, 0 , -300)
    Utils.ChangeLayersRecursively(self.p1Obj.transform, "UI")
    self.p1Obj:SetActive(false)

    self.p2Obj = GameObject.Instantiate(self:GetPrefab(self.p2Effect))
    self.p2Obj.transform:SetParent(self.MainCon)
    self.p2Obj.transform.localScale = Vector3(1, 1, 1)
    self.p2Obj.transform.localPosition = Vector3(0, 0 , -300)
    Utils.ChangeLayersRecursively(self.p2Obj.transform, "UI")
    self.p2Obj:SetActive(false)

    self.p3Obj = GameObject.Instantiate(self:GetPrefab(self.p3Effect))
    self.p3Obj.transform:SetParent(self.MainCon)
    self.p3Obj.transform.localScale = Vector3(1, 1, 1)
    self.p3Obj.transform.localPosition = Vector3(0, 0 , -300)
    Utils.ChangeLayersRecursively(self.p3Obj.transform, "UI")
    self.p3Obj:SetActive(false)

    self.openObj = GameObject.Instantiate(self:GetPrefab(self.openEffect))
    self.openObj.transform:SetParent(self.MainCon)
    self.openObj.transform.localScale = Vector3(1, 1, 1)
    self.openObj.transform.localPosition = Vector3(0, 0 , -300)
    Utils.ChangeLayersRecursively(self.openObj.transform, "UI")
    self.openObj:SetActive(false)

    self.resetObj = GameObject.Instantiate(self:GetPrefab(self.resetEffect))
    self.resetObj.transform:SetParent(self.MainCon)
    self.resetObj.transform.localScale = Vector3.one
    self.resetObj.transform.localPosition = Vector3(0, -217, -300)
    Utils.ChangeLayersRecursively(self.resetObj.transform, "UI")
    self.resetObj:SetActive(false)

    self.ghostObj = GameObject.Instantiate(self:GetPrefab(self.ghostEffect))
    self.ghostObj.transform:SetParent(self.GhostPanel.gameObject.transform)
    self.ghostObj.transform.localScale = Vector3.one
    self.ghostObj.transform.localPosition = Vector3(0, 0, -300)
    Utils.ChangeLayersRecursively(self.ghostObj.transform, "UI")
    self.ghostObj:SetActive(true)

    self.ghosttipsObj = GameObject.Instantiate(self:GetPrefab(self.ghosttipsEffect))
    self.ghosttipsObj.transform:SetParent(self.GhostPanel.gameObject.transform)
    self.ghosttipsObj.transform.localScale = Vector3.one
    self.ghosttipsObj.transform.localPosition = Vector3(150, -110, -300)
    Utils.ChangeLayersRecursively(self.ghosttipsObj.transform, "UI")
    self.ghosttipsObj:SetActive(true)

    self.ghostclickObj = GameObject.Instantiate(self:GetPrefab(self.ghostclickEffect))
    self.ghostclickObj.transform:SetParent(self.GhostPanel.gameObject.transform)
    self.ghostclickObj.transform.localScale = Vector3.one
    self.ghostclickObj.transform.localPosition = Vector3(0, 0, -300)
    Utils.ChangeLayersRecursively(self.ghostclickObj.transform, "UI")
    self.ghostclickObj:SetActive(true)

    self.ghostkillObj = GameObject.Instantiate(self:GetPrefab(self.ghostkillEffect))
    self.ghostkillObj.transform:SetParent(self.gameObject.transform)
    self.ghostkillObj.transform.localScale = Vector3.one
    self.ghostkillObj.transform.localPosition = Vector3(0, 0, -300)
    Utils.ChangeLayersRecursively(self.ghostkillObj.transform, "UI")
    self.ghostkillObj:SetActive(false)

    self:LoadPreview()
end

function TreasureMazeWindow:InitBlock()
	local data = self.mgr.mazeData.opens
	self:SetDungeonStyle()
	if self.currpiece_num == nil then
		if self.mgr.mazeData.piece ~= nil then

			self.currpiece_num = #self.mgr.mazeData.piece
			self.currpiece_data = {}
			for k,v in pairs(self.mgr.mazeData.piece) do
				self.currpiece_data[v.pos] = true
			end
			for i=1,3 do
				self.pieceList[i]:SetActive(self.currpiece_data[i] == true)
			end
			self.KeyImg:SetActive(self.currpiece_num == 3)
		end
		if self.currpiece_num == 3 then
			if self.keyTween == nil then
				self.KeyImg.transform.anchoredPosition = Vector2(-5.3, 14)
				local startPos = self.KeyImg.gameObject.transform.localPosition
				self.keyTween = Tween.Instance:MoveLocalY(self.KeyImg, startPos.y + 10, 0.9, function() end, LeanTweenType.linear):setLoopPingPong()
			end
		end
	end
	for i=1,5 do
		for j=1,5 do
            xpcall(function() self.GridList[i][j]:Update({}) end,
            function()  Log.Error(debug.traceback()) end )

		end
	end
	self.firstInit = false
	self.doubleObj:SetActive(self.mgr.mazeData.double == 1)
end

-- 碎片更新特效
function TreasureMazeWindow:PlayFly(x, y)
	if x < 1 or x > 5 or y < 1 or y > 5 then
		Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
	end
	if self.currpiece_num == #self.mgr.mazeData.piece then
		return
	end
	self.currpiece_num = #self.mgr.mazeData.piece
	local targetfloor = self.FloorList[x][y].gameObject.transform.position
	local numTextPos = self.KeyNum.gameObject.transform.position
	local flyObj = nil
	local currpos = 1
	for k,v in pairs(self.mgr.mazeData.piece) do
		if self.currpiece_data[v.pos] ~= true then
			currpos = v.pos
		end
		self.currpiece_data[v.pos] = true
	end
	if currpos == 1 then
		flyObj = self.p1Obj
	elseif currpos == 2 then
		flyObj = self.p2Obj
	elseif currpos == 3 then
		flyObj = self.p3Obj
	end
	numTextPos = self.pieceList[currpos].transform.position
    flyObj.transform:SetParent(self.MainCon)
    flyObj.transform.localScale = Vector3(1, 1, 1)
    flyObj.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(flyObj.transform, "UI")
    flyObj:SetActive(false)
	flyObj.transform.position = Vector3(targetfloor.x+40/145, targetfloor.y-35/145, -2)
	local targetpos = self.piecePos[currpos]
	flyObj:SetActive(true)
	local endfunc = function()
		for k,v in pairs(self.mgr.mazeData.piece) do
			self.currpiece_data[v.pos] = true
		end
		for i=1,3 do
			self.pieceList[i]:SetActive(self.currpiece_data[i] == true)
		end
		self.KeyImg:SetActive(self.currpiece_num == 3)
		if self.currpiece_num == 3 then
			if self.keyTween == nil then
				self.KeyImg.gameObject.transform.anchoredPosition = Vector2(-5.3, 17)
				local startPos = self.KeyImg.gameObject.transform.localPosition
				self.keyTween = Tween.Instance:MoveLocalY(self.KeyImg, startPos.y + 10, 0.9, function() end, LeanTweenType.linear):setLoopPingPong()
			end
		end
	end
	Tween.Instance:MoveLocal(flyObj, targetpos, 1.5, function() endfunc() flyObj:SetActive(false) table.insert(self.flyObjList, flyObj) end, LeanTweenType.easeOutCubic)
    SoundManager.Instance:PlayCombat(944)
end
-- 单击特效
function TreasureMazeWindow:PlayClick(x, y)
    if x < 1 or x > 5 or y < 1 or y > 5 then
        Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
    end
    local targetfloor = self.FloorList[x][y].gameObject.transform.position
    self.clickObj:SetActive(false)
    self.clickObj.transform.position = Vector3(targetfloor.x+40/145, targetfloor.y-35/145, -2)
    self.clickObj:SetActive(true)
    SoundManager.Instance:PlayCombat(930)

end
-- 怪被锤死特效
function TreasureMazeWindow:PlayKillMoster(x, y)
    if self.firstInit then
        return
    end
	if x < 1 or x > 5 or y < 1 or y > 5 then
		Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
	end
	local targetfloor = self.FloorList[x][y].gameObject.transform.position
	self.ghostkillObj:SetActive(false)
	self.ghostkillObj.transform.position = Vector3(targetfloor.x+40/145, targetfloor.y-35/145, -2)
	self.ghostkillObj:SetActive(true)
    SoundManager.Instance:PlayCombat(930)

end
-- 破开特效
function TreasureMazeWindow:PlayBreak(x, y)
	if x < 1 or x > 5 or y < 1 or y > 5 then
		Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
	end
	local targetfloor = self.FloorList[x][y].gameObject.transform.position
	self.breakObj:SetActive(false)
	self.breakObj.transform.position = Vector3(targetfloor.x+40/145, targetfloor.y-35/145, -2)
	self.breakObj:SetActive(true)
end
-- 爆炸特效
function TreasureMazeWindow:PlayBoom(x, y)
	if x < 1 or x > 5 or y < 1 or y > 5 then
		Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
	end
	local targetfloor = self.FloorList[x][y].gameObject.transform.position
	self.breakObj:SetActive(false)
	self.breakObj.transform.position = Vector3(targetfloor.x+40/145, targetfloor.y-35/145, -2)
	self.breakObj:SetActive(true)
end
-- 扫描特效
function TreasureMazeWindow:PlayScan()
	self.scanObj:SetActive(false)
	self.scanObj:SetActive(true)
	LuaTimer.Add(1500, function()
		if not BaseUtils.isnull(self.scanObj) then
			self.scanObj:SetActive(false)
		end
	end)
end
-- 刷怪特效
function TreasureMazeWindow:PlayMoster(x, y, isshow)
	if x < 1 or x > 5 or y < 1 or y > 5 then
		Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
	end
    if self.mosterList == nil then
        self.mosterList = {}
    end
    if self.mosterList[x] == nil then
        self.mosterList[x] = {}
    end
	local targetfloor = self.FloorList[x][y].gameObject.transform.position
    if self.mosterList[x][y] == nil then
        if isshow then
            local go = GameObject.Instantiate(self.mosterObj)
            go.transform:SetParent(self.MainCon)
            go.transform.localScale = Vector3(1, 1, 1)
            go.transform.localPosition = Vector3.zero
            Utils.ChangeLayersRecursively(self.mosterObj.transform, "UI")
        	-- go:SetActive(false)
        	go.transform.position = Vector3(targetfloor.x+40/145, targetfloor.y-15/145, -1)
        	go:SetActive(true)
            self.mosterList[x][y] = go
        end
    else
        self.mosterList[x][y]:SetActive(isshow)
    end
	-- LuaTimer.Add(1500, function()
	-- 	if not BaseUtils.isnull(self.mosterObj) then
	-- 		self.mosterObj:SetActive(false)
	-- 	end
	-- end)
end
-- 变双倍特效
function TreasureMazeWindow:PlayDouble(x, y, callback)
	if x < 1 or x > 5 or y < 1 or y > 5 then
		Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
	end
	local targetfloor = self.FloorList[x][y].gameObject.transform.position
	self.flyObj:SetActive(false)
	local btn2pos = self.Button2.gameObject.transform.position
	self.flyObj.transform.position = Vector3(btn2pos.x, btn2pos.y, -2)
	self.flyObj:SetActive(true)
	local targetpos = Vector3(targetfloor.x+40/145, targetfloor.y-35/145, -2)
	Tween.Instance:Move(self.flyObj, targetpos, 1, function() callback() self.flyObj:SetActive(false) end, LeanTweenType.easeOutCubic)
end

function TreasureMazeWindow:PlayOpenEffect(x, y)
	self.openObj:SetActive(false)
	self.openObj.transform.localPosition = Vector3(288, 87, -300)
	self.openObj:SetActive(true)
	LuaTimer.Add(3500, function()
		if not BaseUtils.isnull(self.openObj) then
			self.openObj:SetActive(false)
		end
	end)
end


-- 变双倍特效
function TreasureMazeWindow:PlayMonkey(x, y)
    if x < 1 or x > 5 or y < 1 or y > 5 then
        Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
    end
    local targetfloor = self.FloorList[x][y].gameObject.transform.position
    if BaseUtils.isnull(self.rawImage) then
        return
    end
    if self.rawImage.gameObject.activeSelf == false then
        self.rawImage.transform.position = Vector3(targetfloor.x+35/145, targetfloor.y-15/145, -2)
        self.rawImage:SetActive(true)
        self.currmonkey = {x = x, y = y}
    else
        local rotateVal = Vector3.zero
        if self.currmonkey ~= nil then
            if x > self.currmonkey.x then
                rotateVal = Vector3(0, -60, 0)
            elseif x < self.currmonkey.x then
                rotateVal = Vector3(0, 60, 0)
            elseif y < self.currmonkey.y then
                -- rotateVal = Vector3(60, 180, 0)
            elseif y > self.currmonkey.y then
                -- rotateVal = Vector3(-60, 0, 0)
            end
        end
        self.currmonkey = {x = x, y = y}
        self.previewCom.tpose.transform.localRotation = Quaternion.identity
        self.previewCom.tpose.transform:Rotate(rotateVal)
        local targetpos = Vector3(targetfloor.x+35/145, targetfloor.y-15/145, -2)
        -- Tween.Instance:Rotate(self.previewCom.tpose.gameObject, rotateVal, 0.25, function()  end, LeanTweenType.linear)
        Tween.Instance:Move(self.rawImage.gameObject, targetpos, 0.5, function() self.previewCom.tpose.transform.localRotation = Quaternion.identity end, LeanTweenType.easeOutCubic)
    end
    -- self.rawImage.transform.position = Vector3(btn2pos.x, btn2pos.y, -2)
end

function TreasureMazeWindow:PlayMiner(x, y, data)
    if x < 1 or x > 5 or y < 1 or y > 5 then
        Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
    end
    local targetfloor = self.FloorList[x][y].gameObject.transform.position
    self.goldObj:SetActive(false)
    self.goldObj.transform.position = Vector3(targetfloor.x+40/145, targetfloor.y-35/145, -2)
    self.goldObj:SetActive(true)
end

function TreasureMazeWindow:PlayHelpEnd(x, y)
    if x < 1 or x > 5 or y < 1 or y > 5 then
        Log.Error(string.format("格子数值有问题，是否协议对不上？x=%s,y=%s", x, y))
    end
    local targetfloor = self.FloorList[x][y].gameObject.transform.position
    self.helpendObj:SetActive(false)
    self.helpendObj.transform.position = Vector3(targetfloor.x+40/145, targetfloor.y-35/145, -2)
    self.helpendObj:SetActive(true)
    LuaTimer.Add(1000, function()
        if not BaseUtils.isnull(self.helpendObj) then
            self.helpendObj:SetActive(false)
        end
    end)
end

function TreasureMazeWindow:HideMonkey()
    if BaseUtils.isnull(self.rawImage) then
        return
    end
    self.rawImage:SetActive(false)
end

function TreasureMazeWindow:OnDragon()
	local data = self.mgr.dragonData
	local startfloor = self.FloorList[data.start_x][data.start_y].gameObject.transform.position
	self.beforeObj:SetActive(false)
	self.beforeObj.transform.position = Vector3(startfloor.x+40/145, startfloor.y-35/145, -2)
	self.beforeObj:SetActive(true)

    local EndofBefore = function()
        if self.beforeObj ~= nil then 
            self.beforeObj:SetActive(false)
        end
		for k,v in pairs(data.opens) do
			local obj = nil
			if #self.dragonObjList > 0 then
				obj = table.remove(self.dragonObjList)
			else
				obj = GameObject.Instantiate(self:GetPrefab(self.dragonEffect))
			end
		    obj.transform:SetParent(self.MainCon)
		    obj.transform.localScale = Vector3(1, 1, 1)
		    obj.transform.transform.position = Vector3(startfloor.x+40/145, startfloor.y-35/145, -2)
		    Utils.ChangeLayersRecursively(obj.transform, "UI")
		    obj:SetActive(false)
		    obj:SetActive(true)
		    local targetfloor = self.FloorList[v.end_x][v.end_y].gameObject.transform.position
		    local targetpos = Vector3(targetfloor.x+40/145, targetfloor.y-21/145, -2)
	    	Tween.Instance:Move(obj, targetpos, 0.7, function() table.insert(self.dragonObjList, obj) end, LeanTweenType.linear)
		end
		LuaTimer.Add(650, function() self.mgr:Send18803() end)
	end
	LuaTimer.Add(800, EndofBefore)
    SoundManager.Instance:PlayCombat(911)
end

function TreasureMazeWindow:OnGuide()

    local data = self.mgr.guideData
    local startfloor = self.FloorList[data.start_x][data.start_y].gameObject.transform.position
    -- self.beforeObj:SetActive(false)
    -- self.beforeObj.transform.position = Vector3(startfloor.x+40/145, startfloor.y-35/145, -2)
    -- self.beforeObj:SetActive(true)

    -- self.beforeObj:SetActive(false)
    for k,v in pairs(data.opens) do
        if self.pieceList[v.piece].activeSelf == false then
            local obj = nil
            if #self.guideObjList > 0 then
                obj = table.remove(self.guideObjList)
            else
                obj = GameObject.Instantiate(self:GetPrefab(self.guideflyEffect))
            end
            obj.transform:SetParent(self.MainCon)
            obj.transform.localScale = Vector3(1, 1, 1)
            obj.transform.transform.position = Vector3(startfloor.x+40/145, startfloor.y-35/145, -2)
            Utils.ChangeLayersRecursively(obj.transform, "UI")
            obj:SetActive(false)
            obj:SetActive(true)
            local targetfloor = self.FloorList[v.end_x][v.end_y].gameObject.transform.position
            local targetpos = Vector3(targetfloor.x+40/145, targetfloor.y-21/145, -2)
            Tween.Instance:Move(obj, targetpos, 0.7, function() obj:SetActive(false) table.insert(self.guideObjList, obj) end, LeanTweenType.linear)
        end
    end
    LuaTimer.Add(700, function() self.mgr:Send18813() end)
    -- LuaTimer.Add(800, EndofBefore)
    SoundManager.Instance:PlayCombat(911)
end

function TreasureMazeWindow:OnReset()
	self.currpiece_data = {}
	if self.hasInit and self.currpiece_num ~= nil then

        self.Grid.localPosition = Vector3(0, 370, 0)
        local floor = self.Maze:Find("Mask/floor")
        floor.localPosition = Vector3(0, 370, 0)
        Tween.Instance:MoveLocalY(self.Grid.gameObject, -1.5, 0.3, function()  end, LeanTweenType.linear)
        Tween.Instance:MoveLocalY(floor.gameObject, -1.5, 0.3, function()  end, LeanTweenType.linear)
        LuaTimer.Add(300, function()
            if not BaseUtils.isnull(self.resetObj) then
        		self.resetObj:SetActive(false)
        		self.resetObj:SetActive(true)
            end
        end)
		LuaTimer.Add(800, function()
			if not BaseUtils.isnull(self.resetObj) then
				self.resetObj:SetActive(false)
			end
		end)
        self.firstInit = true
        self:HideMonkey()
    end
    self.currpiece_num = nil
    for i=1,3 do
        self.pieceList[i]:SetActive(false)
    end
    self.KeyImg:SetActive(false)
    for i=1,5 do
        for j=1,5 do
            if self.mosterList ~= nil and self.mosterList[i] ~= nil then
                if not BaseUtils.isnull(self.mosterList[i][j]) then
                    self.mosterList[i][j]:SetActive(false)
                end
            end
            self.FloorList[i][j].sprite = self.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, "floor"..tostring(self.currstyleid))
        end
    end
end

function TreasureMazeWindow:SwitchGhostPanel(open, x, y, id)
	if open then
        -- NoticeManager.Instance:FloatTipsByString(TI18N("妖气四散，快点击屏幕抓妖！{face_1, 46}"))
        if id ~= self.ghostdata.id then
            SoundManager.Instance:PlayCombat(915)
        end
        self.ghostdata = {x = x, y = y, id = id}
        self.GhostPanel.gameObject:SetActive(true)
        self.clicknum = 0
	else
        if self.ghostdata.id == id then
            if self.GhostPanel.gameObject.activeSelf and self.hideid == nil then
                self.hideid = LuaTimer.Add(2000, function()
                    self.GhostPanel.gameObject:SetActive(false)
                    self.hideid = nil
                end)
            end
        end
	end
end

function TreasureMazeWindow:OnGhostResult()
	-- if self.mgr.ghostResult ~= nil then
	-- 	if self.mgr.ghostResult
	-- end
end

function TreasureMazeWindow:SetItemNum()
	local num = BackpackManager.Instance:GetItemCount(21220)
	if num > 0 then
		self.numText.text = tostring(num)
	else
		self.numText.text = string.format("<color='#ff0000'>%s</color>", num)
	end
	local doubleCardnum = BackpackManager.Instance:GetItemCount(21222)
	local scanCardnum = BackpackManager.Instance:GetItemCount(21221)
	if scanCardnum > 0 then
		self.Button1Text.text = string.format("可用次数：<color='#248813'>%s</color>", scanCardnum)
	else
		self.Button1Text.text = string.format("可用次数：<color='#ff0000'>%s</color>", scanCardnum)
	end
	if doubleCardnum > 0 then
		self.Button2Text.text = string.format("可用次数：<color='#248813'>%s</color>", doubleCardnum)
	else
		self.Button2Text.text = string.format("可用次数：<color='#ff0000'>%s</color>", doubleCardnum)
	end
end

function TreasureMazeWindow:SetDungeonStyle()
	if self.mgr.mazeData.dungeon ~= nil and (self.currstyle == nil or self.currstyle ~= self.mgr.mazeData.dungeon) then
		if DataMaze.data_dungeon[self.mgr.mazeData.dungeon] ~= nil then
			local data = DataMaze.data_dungeon[self.mgr.mazeData.dungeon]
			self.currstyle = self.mgr.mazeData.dungeon
			self.currstyleid = data.blockstyle
			self.NameImg.sprite = self.assetWrapper:GetSprite(AssetConfig.dungeonname, data.dungeon_name)
			self.DescText.text = data.desc
			self.LBorder.sprite = self.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, tostring(self.currstyleid).."l")
			self.RBorder.sprite = self.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, tostring(self.currstyleid).."r")
			self.TBorder.sprite = self.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, tostring(self.currstyleid).."t")
			self.BBorder.sprite = self.assetWrapper:GetSprite(AssetConfig.treasuremazetexture, tostring(self.currstyleid).."b")
            self:LoadStyle(data)
		end
		self:OnReset()
	end
end

function TreasureMazeWindow:LoadStyle(dungeondata)
    self:CycleStyleItem()
    for i,v in ipairs(dungeondata.location) do
        local name = tostring(v[1])
        local x = v[2]--[+3.3]
        local y = v[3]
        local item = self:GetStyleItem()
        local sprite = self.assetWrapper:GetSprite(AssetConfig.treasuremazestyle, name)
        table.insert(self.styleItemList, item)
        local img = item.transform:GetComponent(Image)
        img.sprite = sprite
        img:SetNativeSize()
        item.transform.anchoredPosition3D = Vector2(x, y, 0)
        item.gameObject:SetActive(true)
    end
end

function TreasureMazeWindow:GetStyleItem()
    if #self.CycleitemList > 0 then
        local item = table.remove(self.CycleitemList)
        item.transform:SetParent(self.StylePanel)
        item.transform.localScale = Vector3.one
        return item
    else
        local item = GameObject.Instantiate(self.StylePanelItem)
        item.transform:SetParent(self.StylePanel)
        item.transform.localScale = Vector3.one
        return item
    end
end

function TreasureMazeWindow:CycleStyleItem()
    for i,v in ipairs(self.styleItemList) do
        v:SetActive(false)
        table.insert(self.CycleitemList, v)
    end
    self.styleItemList = {}
end

function TreasureMazeWindow:UpdateDungeonTimes()
    local lev = RoleManager.Instance.RoleData.lev
    local times = DataDungeon.data_team_dungeon_times[lev].limit
    local color = "<color='#906014'>"
    if times == TeamDungeonManager.Instance.model.passTimes then
        color = "<color='#ffff00'>"
    end
    local showtimes = times - TeamDungeonManager.Instance.model.passTimes
    if showtimes < 0 then
        showtimes = 0
    end
    self.TeamButtonText.text = string.format(TI18N("组队副本%s（%s/%s）</color>"), color, showtimes, times)

end

function TreasureMazeWindow:ShowItemTips()
    local itemdata = ItemData.New()
    itemdata:SetBase(BackpackManager.Instance:GetItemBase(21220))
    TipsManager.Instance:ShowItem({["gameObject"] = self.transform:Find("MainCon/Right/numbg").gameObject, ["itemData"] = itemdata })
end


function TreasureMazeWindow:LoadPreview()
    local unit_data = DataUnit.data_unit[73063]
    local setting = {
        name = "Monkey"
        ,orthographicSize = 0.45
        ,width = 70
        ,height = 70
        ,offsetY = -0.43
    }
    local modelData = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1}
    self.preview_loaded = function(com)
        self:PreviewLoaded(com)
    end
    if self.previewCom == nil then
        self.previewCom = PreviewComposite.New(self.preview_loaded, setting, modelData)

        -- 有缓存的窗口要写这个
        -- self.OnHideEvent:AddListener(function() self.previewCom:Hide() end)
        -- self.OnOpenEvent:AddListener(function() self.previewCom:Show() end)
    else
        self.previewCom:Reload(modelData, self.preview_loaded)
    end

end


function TreasureMazeWindow:PreviewLoaded(composite)
    local rawImage = composite.rawImage
    if rawImage ~= nil then
        self.rawImage = rawImage
        rawImage.transform:SetParent(self.Grid)
        local canvasG = self.rawImage.transform:GetComponent(CanvasGroup) or self.rawImage.transform.gameObject:AddComponent(CanvasGroup)
        canvasG.blocksRaycasts = false
        self.rawImage.gameObject:SetActive(false)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        -- composite.tpose.transform:Rotate(Vector3(0, 45, 0))
        -- self.preview.texture = rawImage.texture
    end
end

function TreasureMazeWindow:CheckAll(x, y)
    for i=1,5 do
        for j=1,5 do
            if x ~= i and y ~= j then
                local data = self.model:GetData(i, j)
                if data == nil or next(data) == nil or data.times ~= data.hard then
                    return false
                end
            end
        end
    end
    return true
end