--作者:hzf
--11/19/2016 10:51:05
--功能:冠军联赛名人堂

GuildLeagueCupWindow = GuildLeagueCupWindow or BaseClass(BaseWindow)
function GuildLeagueCupWindow:__init(model)
	self.model = model
	self.Mgr = GuildLeagueManager.Instance
    self.EffectPath = "prefabs/effect/20225.unity3d"
	self.resList = {
		{file = AssetConfig.guildleaguecupwindow, type = AssetType.Main},
		{file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = self.EffectPath, type = AssetType.Main},
		{file = AssetConfig.guild_totem_icon, type = AssetType.Dep},
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.animating = false
end

function GuildLeagueCupWindow:__delete()
	if self.preview ~= nil then
		self.preview:DeleteMe()
		self.preview = nil
	end
	if self.worshippreview ~= nil then
		self.worshippreview:DeleteMe()
		self.worshippreview = nil
	end
	if self.friendPanel ~= nil then
		self.friendPanel:DeleteMe()
		self.friendPanel = nil
	end
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function GuildLeagueCupWindow:OnHide()

end

function GuildLeagueCupWindow:OnOpen()

end

function GuildLeagueCupWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleaguecupwindow))
	self.gameObject.name = "GuildLeagueCupWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.Panel = self.transform:Find("Panel")
	self.Main = self.transform:Find("Main")
	self.Title = self.transform:Find("Main/Title")
	self.Text = self.transform:Find("Main/Title/Text"):GetComponent(Text)
	self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function()
        self.model:CloseCupWindow()
    end)
	self.Con = self.transform:Find("Main/Con")
	self.seasonTitle = self.transform:Find("Main/Con/seasonTitle")
	self.seasonTitleText = self.transform:Find("Main/Con/seasonTitle/Text"):GetComponent(Text)
	self.previewCon = self.transform:Find("Main/Con/preview")
	self.no1 = self.transform:Find("Main/Con/no1")
	self.icon = self.transform:Find("Main/Con/no1/icon")
	self.name1Text = self.transform:Find("Main/Con/no1/name1Text"):GetComponent(Text)
	self.no2 = self.transform:Find("Main/Con/no2")
	self.name2Text = self.transform:Find("Main/Con/no2/name2Text"):GetComponent(Text)
	self.no3 = self.transform:Find("Main/Con/no3")
	self.name3Text = self.transform:Find("Main/Con/no3/name3Text"):GetComponent(Text)
	self.cupText = self.transform:Find("Main/Con/cupText"):GetComponent(Text)
	self.Image = self.transform:Find("Main/Con/cupText/Image"):GetComponent(Image)
	self.History = self.transform:Find("Main/Con/History")
	self.MaskScroll = self.transform:Find("Main/Con/History/MaskScroll")
	self.ListCon = self.transform:Find("Main/Con/History/MaskScroll/List")

	self.HeadBar = self.transform:Find("Main/Con/History/HeadBar")
	self.Text1 = self.transform:Find("Main/Con/History/HeadBar/Text1"):GetComponent(Text)
	self.Text2 = self.transform:Find("Main/Con/History/HeadBar/Text2"):GetComponent(Text)
	self.Text3 = self.transform:Find("Main/Con/History/HeadBar/Text3"):GetComponent(Text)

	self.WorshipButton = self.transform:Find("Main/Con/WorshipButton"):GetComponent(Button)
	self.ShowButton = self.transform:Find("Main/Con/ShowButton"):GetComponent(Button)
    self.TipsText = self.transform:Find("Main/TipsText").gameObject

	self.SharePanel = self.transform:Find("SharePanel").gameObject
	self.SharePanel.transform:GetComponent(Button).onClick:AddListener(function()
		self.SharePanel:SetActive(false)
	end)
	self.transform:Find("SharePanel/bg/WorldButton"):GetComponent(Button).onClick:AddListener(function()
		self:ShareToWorld()
	end)
	self.transform:Find("SharePanel/bg/FriendButton"):GetComponent(Button).onClick:AddListener(function()
		self:ShareToFriend()
	end)
	self.WorshipPanel = self.transform:Find("WorshipPanel").gameObject
	self.WorshipPanel.transform:GetComponent(Button).onClick:AddListener(function()
		if self.animating then
			return
		end
		self.WorshipPanel:SetActive(false)
	end)
	self.worshippreviewCon = self.transform:Find("WorshipPanel/bg")

	self:SetLeft()
end

function GuildLeagueCupWindow:InitList()
	self.rank_item_list = {}
	for i=1, self.ListCon.childCount do
        local go = self.ListCon.transform:GetChild(i - 1).gameObject
        local item = GuildLeagueCupItem.New(go, self)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.ListCon.transform:GetChild(0):GetComponent(RectTransform).sizeDelta.y
    self.height_height = self.MaskScroll:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.ListCon:GetComponent(RectTransform).anchoredPosition.y

    self.setting_data = {
       item_list = self.rank_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.ListCon  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.height_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.MaskScroll:GetComponent(ScrollRect).onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.setting_data.data_list = self.Mgr.championHistory
    BaseUtils.refresh_circular_list(self.setting_data)
end

function GuildLeagueCupWindow:SetLeft()
	self.LastData = self.Mgr.championHistory[1]
	self.lastSeason = #self.Mgr.championHistory
	self.seasonTitleText.text = string.format(TI18N("第%s届冠军联赛"), self.lastSeason)
	self.name1Text.text = self.LastData.top3[1].name1
	self.name2Text.text = TI18N("亚军:")..self.LastData.top3[2].name1
	self.name3Text.text = TI18N("季军:")..self.LastData.top3[3].name1
    BaseUtils.SetGrey(self.WorshipButton.gameObject.transform:GetComponent(Image), self.Mgr.worshed)
    if self.Mgr.worshed then
        self.WorshipButton.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("已膜拜")
    end
	if GuildManager.Instance.model.my_guild_data ~= nil and self.LastData.top3[1].name1 == GuildManager.Instance.model.my_guild_data.Name then
		self:LoadWorshipPreview()
		self.WorshipButton.onClick:AddListener(function()
			self:DoWorship()
		end)
		self.ShowButton.onClick:AddListener(function()
			self:DoShow()
		end)
	else
		self.WorshipButton.gameObject:SetActive(false)
		self.ShowButton.gameObject:SetActive(false)
        self.TipsText:SetActive(true)
		-- self.History.sizeDelta = Vector2(425.3, 401)
	end
    local serverName = ""
    for k, v in pairs(DataServerList.data_server_name) do
        if v.platform == self.LastData.top3[1].platform and v.zone_id == self.LastData.top3[1].zone_id then
            serverName = v.platform_name
            break
        end
    end
    self.TipsText.transform:GetComponent(Text).text = string.format("当前冠军奖杯在<color='#ffff00'>%s-%s</color>处，下赛季夺过来！", serverName, self.LastData.top3[1].name1)
	self:LoadPreview()
	self:InitList()
end

function GuildLeagueCupWindow:DoWorship()
	if self.Mgr.worshed == true then
        NoticeManager.Instance:FloatTipsByString(TI18N("您已经膜拜过"))
        return
    end
    self.WorshipButton.gameObject.transform:Find("Text"):GetComponent(Text).text = TI18N("已膜拜")
    BaseUtils.SetGrey(self.WorshipButton.gameObject.transform:GetComponent(Image), true)
    self:DoWorshipAnima()
end

function GuildLeagueCupWindow:DoShow()
	self.SharePanel:SetActive(true)
end

function GuildLeagueCupWindow:LoadPreview()
	local unit_data = DataUnit.data_unit[62318]
    local setting = {
        name = "GuildLeagueCupWindow"
        ,orthographicSize = 1.12
        ,width = 256
        ,height = 256
        ,offsetY = -1
        ,noDrag = true
    }
    local modelData = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1, effects = unit_data.effects}
    self.preview = PreviewComposite.New(function(composite) self:PreViewLoaded(composite, 1) end, setting, modelData)
end

function GuildLeagueCupWindow:LoadWorshipPreview()
	local unit_data = DataUnit.data_unit[62318]
    local setting = {
        name = "DoWorship"
        ,orthographicSize = 1.2
        ,width = 341
        ,height = 341
        ,offsetY = -1
        ,noDrag = true
    }
    local modelData = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1, effects = unit_data.effects}
    self.worshippreview = PreviewComposite.New(function(composite) self:PreViewLoaded(composite, 2) end, setting, modelData)
end


function GuildLeagueCupWindow:PreViewLoaded(composite, previewtype)
	if previewtype == 1 then
	    local rawImage = composite.rawImage
	    if rawImage ~= nil then
	        rawImage.transform:SetParent(self.previewCon)
	        rawImage.transform.localPosition = Vector3(0, 20, 0)
	        rawImage.transform.localScale = Vector3(1, 1, 1)
	        -- composite.tpose.transform:Rotate(Vector3(350,340,5))
	        composite.tpose.transform.rotation = Quaternion.identity
	        -- local btn = rawImage:AddComponent(Button)
	        -- btn.onClick:AddListener(function() self:OnClickBox() end)
            if self.preview ~= nil then
                self.preview:PlayAnimation("Idle1")
            end
	    end
	else
		local rawImage = composite.rawImage
	    if rawImage ~= nil then
	        rawImage.transform:SetParent(self.worshippreviewCon)
	        rawImage.transform.localPosition = Vector3.zero
	        rawImage.transform.localScale = Vector3(1, 1, 1)
	        -- composite.tpose.transform:Rotate(Vector3(350,340,5))
	        composite.tpose.transform.rotation = Quaternion.identity
            self.WorshipEffect = GameObject.Instantiate(self:GetPrefab(self.EffectPath))
            self.WorshipEffect.transform:SetParent(self.worshippreviewCon)
            self.WorshipEffect.transform.localScale = Vector3.one
            self.WorshipEffect.transform.localPosition = Vector3(0, 92, 0)

            -- self.WorshipEffect.transform.localRotation = Quaternion.identity
            -- self.WorshipEffect.transform.localRotation = Quaternion.Euler(0 , 270, 180)

            Utils.ChangeLayersRecursively(self.WorshipEffect.transform, "UI")
            self.WorshipEffect:SetActive(false)
	    end
	end

end

function GuildLeagueCupWindow:DoWorshipAnima()
	if self.animating then
		return
	end
	self.WorshipPanel:SetActive(true)
	self.animating = true
	if self.worshippreview ~= nil and self.worshippreview.tpose ~= nil then
		-- local originpos = self.worshippreview.tpose.transform.localPosition
		-- local endpos = self.worshippreview.tpose.transform.localPosition + Vector3(0.2, 0, 0)
		-- self.worshippreview.tpose.transform.localPosition = self.worshippreview.tpose.transform.localPosition - Vector3(0.2, 0, 0)
		-- Tween.Instance:MoveLocal(self.worshippreview.tpose, endpos, 0.2, function()self.animating = false self.worshippreview.tpose.transform.localPosition = originpos end, LeanTweenType.linear):setLoopPingPong(6)
		-- Tween.Instance:MoveLocalY(self.worshippreview.tpose, originpos.y+0.1, 0.1, function() self.worshippreview.tpose.transform.localPosition = originpos end, LeanTweenType.linear):setLoopPingPong(12)
		-- self.worshippreview.tpose.transform:Rotate(Vector3(0, 0, 15))
        self.worshippreview:PlayAnimation("Idle2")
        LuaTimer.Add(800, function()
            self.WorshipEffect:SetActive(true)
            self.animating = false
            self.Mgr:Require17630()
        end)
	end
end

function GuildLeagueCupWindow:ShareToWorld()
	self.SharePanel:SetActive(false)
	ChatManager.Instance:SendMsg(MsgEumn.ChatChannel.World, TI18N("{panel_2, 17603, 4, 冠军联赛奖杯, 0}"))
end

function GuildLeagueCupWindow:ShareToFriend()
	self.SharePanel:SetActive(false)
	self:OpenFrendShare()
end

function GuildLeagueCupWindow:OpenFrendShare()
	local str = "{panel_2, 17603, 4, 冠军联赛奖杯, 0}"
	local sendcallback = function(list)
		for i,v in ipairs(list) do
	        FriendManager.Instance:SendMsg(v.id, v.platform, v.zone_id, str)
	    end
	end
    local setting = {
        ismulti = false,
        callback = sendcallback
    }
    if self.friendPanel == nil then
        self.friendPanel = FriendSelectPanel.New(self.gameObject, setting)
    end
    self.friendPanel:Show()
end
