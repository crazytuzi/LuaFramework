-- ------------------------------
-- 宠物坐骑链接界面
-- hosr
-- ------------------------------
RidePetPanel = RidePetPanel or BaseClass(BasePanel)

function RidePetPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.ridepet, type = AssetType.Main},
		{file = AssetConfig.ride_texture, type = AssetType.Dep},
        {file = AssetConfig.headride, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.skillItemList = {}
    self.currItem = nil
    self.currRideData = nil

    self.listener = function() self:SetData() end

    self.descString1 = TI18N("1.与坐骑建立<color='#00ff00'>契约关系</color>的宠物可获得坐骑携带的技能\n2.该坐骑最多与<color='#00ff00'>两只宠物</color>建立契约\n3.建立或<color='#00ff00'>解除契约</color>均无消耗\n4.坐骑精力值低于<color='#00ff00'>50点</color>时，无法发挥契约效果")
    self.descString2 = TI18N("1.与坐骑建立<color='#00ff00'>契约关系</color>的宠物可获得坐骑携带的技能\n2.该坐骑最多与<color='#00ff00'>三只宠物</color>建立契约\n3.建立或<color='#00ff00'>解除契约</color>均无消耗\n4.坐骑精力值低于<color='#00ff00'>50点</color>时，无法发挥契约效果\n5.一只宠物只能契约第一、二坐骑的其中一个，第三坐骑不受影响")
end

function RidePetPanel:__delete()
	RideManager.Instance.OnContractUpdate:Remove(self.listener)
	if self.skillItemList ~= nil then
		for i,v in ipairs(self.skillItemList) do
			v:DeleteMe()
		end
		self.skillItemList = nil
	end

	if self.rank_item_list ~= nil then
		for i,v in ipairs(self.rank_item_list) do
			v:DeleteMe()
		end
		self.rank_item_list = nil
	end
end

function RidePetPanel:OnShow()
	self.petData = self.openArgs
	self:SetData()
	RideManager.Instance.OnContractUpdate:Add(self.listener)
end

function RidePetPanel:OnHide()
	RideManager.Instance.OnContractUpdate:Remove(self.listener)
end

function RidePetPanel:Close()
	self.model:CloseRidePet()
end

function RidePetPanel:InitPanel()
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.ridepet))
    self.gameObject.name = "RidePetPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    local main = self.transform:Find("Main")
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.desc1 = main:Find("Desc1"):GetComponent(Text)
    self.desc2 = main:Find("Desc2"):GetComponent(Text)
    self.state = main:Find("State").gameObject
    self.button = main:Find("Button").gameObject
    self.button:GetComponent(Button).onClick:AddListener(function() self:OnClickButton() end)

    self.desc1.text = TI18N("建立契约后宠物可享有技能:")
    self.desc2.text = self.descString1

    self.skillsContainer = main:Find("Mask/Container")
    self.skillContainerRect = self.skillsContainer:GetComponent(RectTransform)
    for i = 1, self.skillsContainer.childCount do
        local index = i
        local item = RideSkillItem.New(self.skillsContainer:GetChild(i - 1).gameObject, self, true, false, index)
        table.insert(self.skillItemList, item)
    end

    self.Container = main:Find("Left/Container")
    self.ScrollCon = main:Find("Left")
    self.rank_item_list = {}
    for i = 1, 10 do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = RidePetItem.New(go, self)
        go:SetActive(false)
        table.insert(self.rank_item_list, item)

        go:GetComponent(Button).onClick:AddListener(function() self:ItemClick(item) end)
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

    self:OnShow()
end

function RidePetPanel:SetData()
	self:UpdateLeft()

	if self.currItem ~= nil then
		self.currItem:Select(false)
	else
		self.currItem = self.rank_item_list[1]
	end
	self.currItem:ClickOne()
end

function RidePetPanel:ItemClick(item)
    if self.currItem ~= nil then
        self.currItem:Select(false)
    end
    self.currItem = item
    self.currItem:ClickOne()

    if self.currItem.rideData.index == 1 or self.currItem.rideData.index == 2 then
        self.desc2.text = self.descString1
    elseif self.currItem.rideData.index == 3 then
        self.desc2.text = self.descString2
    end
end

function RidePetPanel:UpdateLeft()
	local list = {}
	for k,v in pairs(RideManager.Instance.model.ridelist) do
        if v.live_status >= 3 and DataMount.data_ride_new_data[v.base.base_id] == nil then
            table.insert(list, v)
        end
	end
	self.setting.data_list = list
	BaseUtils.refresh_circular_list(self.setting)
end

function RidePetPanel:SelectOne()
	self:UpdateInfo()
end

function RidePetPanel:UpdateInfo()
	if self.currItem.bind then
		self.state:SetActive(true)
		self.button:SetActive(false)
	else
		self.state:SetActive(false)
		self.button:SetActive(true)
	end

    if self.currItem.rideData == nil then return end
    
    local list = self.currItem.rideData.skill_list
    table.sort(list, function(a,b) return a.skill_index < b.skill_index end)

    local skill_num = 4
    if self.currItem.rideData.index == 2 or self.currItem.rideData.index == 3 then
        skill_num = 5
    end

    for i = 1, #list do
        local v = list[i]
        self.skillItemList[i]:SetData(v)
    end

    if #list < skill_num then
        for i = #list+1, skill_num do
            self.skillItemList[i]:SetData(nil)
        end
    end

    if skill_num < #self.skillItemList then
        for i = skill_num+1, #self.skillItemList do
            self.skillItemList[i].gameObject:SetActive(false)
        end
    end

    self.skillContainerRect.sizeDelta = Vector2(110 * skill_num, 100)
end

function RidePetPanel:OnClickButton()
	if self.currItem.full then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("该坐骑的契约宠物已满，前往更改?")
        data.sureLabel = TI18N("前往")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
        	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow, {4})
        	self:Close()
        end
        NoticeManager.Instance:ConfirmTips(data)
        return
	end
    if self.currItem.rideData ~= nil then
        RideManager.Instance:Send17007(self.currItem.rideData.index, self.petData.id)
    end
end