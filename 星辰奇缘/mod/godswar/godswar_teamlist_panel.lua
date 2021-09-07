-- ----------------------------
-- 诸神之战  战队列表
-- hosr
-- ----------------------------

GodsWarTeamListPanel = GodsWarTeamListPanel or BaseClass(BasePanel)

function GodsWarTeamListPanel:__init(parent)
	self.parent = parent
    self.btnEffect = "prefabs/effect/20053.unity3d"
	self.resList = {
		{file = AssetConfig.godswarteamlist, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
        {file = self.btnEffect, type = AssetType.Main},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.listener = function(list) self:Update(list) end

    self.currItem = nil

    self.helpNormal = {
        TI18N("1.创建战队无任何消耗，但需要至少<color='#00ff00'>2</color>人组队，且都在归队状态"),
        TI18N("2.解散战队后需要等待<color='#00ff00'>5</color>分钟方可重新建队"),
        TI18N("3.创建战队后，至少拥有<color='#00ff00'>5</color>名成员方可报名"),
    }
end

function GodsWarTeamListPanel:__delete()
    GodsWarManager.Instance.model.cooldownUpdateCall = nil
    GodsWarManager.Instance.model.cooldownEndCall = nil
    EventMgr.Instance:RemoveListener(event_name.godswar_list_update, self.listener)
end

function GodsWarTeamListPanel:OnShow()
	self:Update({})
	GodsWarManager.Instance:Send17906()
    self:UpadteCoolDown()
end

function GodsWarTeamListPanel:OnHide()
end

function GodsWarTeamListPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarteamlist))
    self.gameObject.name = "GodsWarTeamListPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -20)

    self.tips = self.transform:Find("Tips").gameObject
    self.tipsRect = self.tips:GetComponent(RectTransform)

    self.create = self.transform:Find("Create").gameObject
    self.create:GetComponent(Button).onClick:AddListener(function() self:Create() end)
    self.createTxt = self.create.transform:Find("Text"):GetComponent(Text)

    self.SingleEffect = GameObject.Instantiate(self:GetPrefab(self.btnEffect))
    self.SingleEffect.transform:SetParent(self.create.transform)
    self.SingleEffect.transform.localScale = Vector3(1.8, 0.68, 1)
    self.SingleEffect.transform.localPosition = Vector3(-118, 8, -1000)
    Utils.ChangeLayersRecursively(self.SingleEffect.transform, "UI")
    self.SingleEffect:SetActive(GodsWarManager.Instance.status == GodsWarEumn.Step.Sign and GodsWarManager.Instance.myData ~= nil and GodsWarManager.Instance.myData.tid == 0 and RoleManager.Instance.RoleData.lev >= 80)

    self.call = self.transform:Find("Call").gameObject
    self.call:GetComponent(Button).onClick:AddListener(function() self:Call() end)

   	self.request = self.transform:Find("Request").gameObject
    self.request:GetComponent(Button).onClick:AddListener(function() self:Request() end)
    self.requestTxt = self.request.transform:Find("Text"):GetComponent(Text)
    self.requestTxt.text = TI18N("申 请")

    self.lookup = self.transform:Find("Lookup").gameObject
    self.lookup:GetComponent(Button).onClick:AddListener(function() self:Lookup() end)

    self.infoBtn = self.transform:Find("InfoBtn").gameObject
    self.infoBtn:GetComponent(Button).onClick:AddListener(function() self:ClickInfo() end)

    self.nothing = self.transform:Find("Nothing").gameObject
    self.scroll = self.transform:Find("Scroll").gameObject

    self.Container = self.transform:Find("Scroll/Container")
    self.ScrollCon = self.transform:Find("Scroll")
    self.rank_item_list = {}
    local len = self.Container.childCount
    for i = 1, len do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = GodsWarTeamListItem.New(go, self)
        go:SetActive(false)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.rank_item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting = {
       item_list = self.rank_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Container  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting) end)

    self.gameObject:SetActive(true)
    self:OnShow()

    EventMgr.Instance:AddListener(event_name.godswar_list_update, self.listener)
end

function GodsWarTeamListPanel:Update(list)
    -- BaseUtils.dump(list,"我的队伍=================================================================")

	self.setting.data_list = list or {}
	if #self.setting.data_list == 0 then
		self.nothing:SetActive(true)
		self.scroll:SetActive(false)
		self.call:SetActive(false)
		self.request:SetActive(false)
		self.lookup:SetActive(false)
	else
		self.nothing:SetActive(false)
		self.scroll:SetActive(true)
		self.call:SetActive(true)
		self.request:SetActive(true)
		self.lookup:SetActive(true)
		BaseUtils.refresh_circular_list(self.setting)
		self:Select(self.rank_item_list[1])
	end

    if GodsWarManager.Instance.myData ~= nil and GodsWarManager.Instance.myData.tid ~= 0 then
        self.tipsRect.anchoredPosition = Vector3(248, 217, 0)
        self.request:SetActive(false)
    else
        self.request:SetActive(true)
        self.tipsRect.anchoredPosition = Vector3(0, 217, 0)
    end
end

function GodsWarTeamListPanel:Create()
    if GodsWarManager.Instance.model.cooldownCount == 0 then
        GodsWarManager.Instance.model:OpenCreate()
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("创建冷却中，<color='#ffff00'>%s秒</color>后再次尝试"), GodsWarManager.Instance.model.cooldownCount))
    end
end

function GodsWarTeamListPanel:Call()
	if self.currItem ~= nil and self.currItem.captin ~= nil then
		local data = {}
		data.id = self.currItem.captin.tid
		data.platform = self.currItem.captin.platform
		data.zone_id = self.currItem.captin.zone_id
		data.name = self.currItem.captin.name
		data.classes = self.currItem.captin.classes
		data.sex = self.currItem.captin.sex
		data.lev = self.currItem.captin.lev
		FriendManager.Instance:TalkToUnknowMan(data)
	end
end

function GodsWarTeamListPanel:Lookup()
	if self.currItem ~= nil and self.currItem.data ~= nil then
		GodsWarManager.Instance.model:OpenTeam(self.currItem.data)
	end
end

function GodsWarTeamListPanel:Request()
	if self.currItem ~= nil then
		local tid = self.currItem.data.tid
		local platform = self.currItem.data.platform
		local zone_id = self.currItem.data.zone_id
        self.currItem.data.isRequest = true
		GodsWarManager.Instance:Send17907(tid, platform, zone_id)
        self:UpdateButton()
	end
end

function GodsWarTeamListPanel:Select(item)
	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = item
	self.currItem:Select(true)
    self:UpdateButton()
end

function GodsWarTeamListPanel:UpadteCoolDown()
    GodsWarManager.Instance.model.cooldownUpdateCall = function() self:CoolDownCall() end
    GodsWarManager.Instance.model.cooldownEndCall = function() self:EndCoolDown() end

    if GodsWarManager.Instance.model.cooldownCount > 0 then
        self:CoolDownCall()
    else
        self:EndCoolDown()
    end
end

function GodsWarTeamListPanel:CoolDownCall()
    self.createTxt.text = string.format(TI18N("%s秒"), GodsWarManager.Instance.model.cooldownCount)
end

function GodsWarTeamListPanel:EndCoolDown()
    self.createTxt.text = "创建战队"
end

function GodsWarTeamListPanel:UpdateButton()
    if self.currItem ~= nil and self.currItem.data ~= nil then
        if self.currItem.data.isRequest then
            self.requestTxt.text = TI18N("已申请")
        else
            self.requestTxt.text = TI18N("申 请")
        end
    end
end

function GodsWarTeamListPanel:ClickInfo()
    TipsManager.Instance:ShowText({gameObject = self.infoBtn, itemData = self.helpNormal})
end