-- ----------------------------------------------------------
-- UI - 宠物窗口 宠物突破
-- ----------------------------------------------------------
ClassesChangeWindow = ClassesChangeWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function ClassesChangeWindow:__init(model)
    self.model = model
    self.name = "ClassesChangeWindow"
    self.windowId = WindowConfig.WinID.classeschangewindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.classeschangewindow, type = AssetType.Main}
        , {file = AssetConfig.createrole_texture, type = AssetType.Dep}
        , {file = AssetConfig.createrole2_texture, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

    self.coldClick = true --点击cd

	------------------------------------------------
	self.classesList = { 1, 2, 3, 4, 5, 6 ,7}
	self.changeClassesList = {
		[1] = {3,7}
		,[2] = {6}
		,[3] = {1,7}
		,[4] = {5}
		,[5] = {4}
		,[6] = {2}
        ,[7] = {1,3}
	}


	self.maleHeadImageList = { 51001,51003,51005,51007,51009,51011,51013 }

	self.femaleHeadImageList = { 51002,51004,51006,51008,51010,51012,51014 }

    -- self.descString = TI18N("1.等级≥60级，且15天之内没转换过职业\n2.时装、和染色信息仍然保持原状态\n3.装备附带的职业天赋将随机转为新职业天赋\n4.装备精炼可获得一次重置属性的机会\n5.所有装备宝石可以在7天内进行一次免费转换")
	self.descString = TI18N("1.<color='#ffff00'>60级</color>后可进行同系别转职，<color='#ffff00'>85级</color>后可自由转职\n2.时装将<color='#ffff00'>保持原状态</color>,染色转为对应新职业染色\n3.人物属性加点将<color='#ffff00'>全部重置</color>，请重新加点\n4.装备附带的职业天赋将<color='#ffff00'>随机</color>转为新职业天赋\n5.<color='#ffff00'>装备精炼</color>属性类型将对应转换，属性值保持不变\n6.普通宝石、英雄宝石<color='#00ff00'>7天内可免费转换</color>一次")

	self.tipsString = { TI18N("1.角色<color='#ffff00'>等级≥60级</color>后可进行<color='#ffff00'>同系别内转职</color>,即物理系(狂剑-战弓-圣骑)、魔法系(魔导-月魂)、辅助系(兽灵-秘言）")
						, TI18N("2.角色<color='#ffff00'>85级可转</color>可进行<color='#ffff00'>自由转职</color>，由于体验差异较大，请谨慎转职非同系别职业")
						, TI18N("3.若需要可<color='#ffff00'>转回原职业</color>，消耗减半且不受系别限制")
						, TI18N("4.转职成功后，需等待一定天数才可进行下次转职")
						, TI18N("5.可选择消耗金币或钻石进行转职，<color='#ffff00'>转职消耗</color>与职业<color='#ffff00'>装备魂价格比例、转职次数</color>相关")
						, TI18N("6.为确保转职体验，需拥有<color='#ffff00'>双倍金币</color>才可选择金币转职")
					}

	------------------------------------------------
    self.itemList = { }  --RoleItem列表
    self.list = {}  --职业对应位置

    self.selectedItem = nil  --当前选中的RoleItem

    self.selectClasses = 0   --当前选中的职业ID
    self.totalRoleItem = 6

    self.skillItemList = {}
    self.skillSlotList = {}
    self.skillTextList = {}

    ------------------------------------------------
    self._ShowNoticeConfirm = function(data)       
        -- self:ShowNoticeConfirm(data)
        self:ShowNoticeSurePanel(data)
     end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function ClassesChangeWindow:__delete()
    self:OnHide()


    for i,v in ipairs(self.itemList) do
        v:DeleteMe()
    end

    for i,v in ipairs(self.skillSlotList) do
    	v:DeleteMe()
    end
    self.skillSlotList = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self.assetWrapper = nil
    self:AssetClearAll()
end

function ClassesChangeWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.classeschangewindow))
    self.gameObject.name = "ClassesChangeWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    ----------------------------
    local transform = self.transform

    transform:FindChild("Main/OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnOkButton() end)

    transform:FindChild("Main/TipsButton"):GetComponent(Button).onClick:AddListener(function()
    		TipsManager.Instance:ShowText({gameObject = self.transform:FindChild("Main/TipsButton").gameObject
            , itemData = self.tipsString})
    	end)


    ----------------------------------------------------------------------------------------
    self.scroll = self.mainTransform:FindChild("Scroll"):GetComponent(ScrollRect)
    self.cloner = self.scroll.transform:FindChild("Cloner").gameObject
    self.container = self.scroll.transform:FindChild("Container")

    self.pageController = self.scroll.gameObject:AddComponent(PageTabbedController)
    self.pageController.onUpEvent:AddListener(function() self:OnUp() end)
    self.pageController.onEndDragEvent:AddListener(function() self:OnUp() end)

    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})

    for i = 1 ,self.totalRoleItem * 3 do
         self.itemList[i] = ClassesChangeItem.New(self.model,GameObject.Instantiate(self.cloner),self)
         self.itemList[i].assetWrapper = self.assetWrapper
         layout:AddCell(self.itemList[i].gameObject)
         self.itemList[i].clickCallback = function(index)
                                            if self.coldClick then
                                                self.coldClick = false
                                                self:UpdateInfo(tonumber(self.itemList[index].gameObject.name))
                                                self:TweenTo( index - 3 )
                                            end
                                        end
    end

    self.cloner:SetActive(false)
    layout:DeleteMe()

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll:GetComponent(RectTransform).rect.height --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) self:UpdatePos() end)

    ---------------------------------------------------------------------------------------------------------------------------

    self.skillItemList = {}
    self.skillSlotList = {}
    self.skillTextList = {}

    local scontainer = transform:FindChild("Main/SkillPanel/Mask/Container")
    local itemObject = scontainer.transform:FindChild("Item").gameObject
    for i=1,10 do
    	local item = GameObject.Instantiate(itemObject)
        UIUtils.AddUIChild(scontainer, item)

        local slot = SkillSlot.New()
        UIUtils.AddUIChild(item, slot.gameObject)
        slot.gameObject:AddComponent(TransitionButton).scaleRate = 1.1

        local text = item.transform:FindChild("Text"):GetComponent(Text)

        table.insert(self.skillItemList, item)
        table.insert(self.skillSlotList, slot)
        table.insert(self.skillTextList, text)
    end


    self.noticeConfirmPanel = self.transform:Find("NoticeConfirmPanel")
    self.noticeConfirmPanel.gameObject:SetActive(false)
    self.contentText = self.noticeConfirmPanel:Find("Main/Content/Text"):GetComponent(Text)
    self.contentMsgExt = MsgItemExt.New(self.contentText, 324.7, 18, 23)

    self.noticeConfirmPanel:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:CancelNoticeSurePanel() end)
    
    self.sureBtn = self.noticeConfirmPanel:Find("Main/SureButton")
    self.suretext = self.sureBtn:Find("Text"):GetComponent(Text)
    self.suretext.color = ColorHelper.DefaultButton3
    self.cancalBtn = self.noticeConfirmPanel:Find("Main/CancelButton")
    self.cancaltext = self.cancalBtn:Find("Text"):GetComponent(Text)
    self.cancaltext.color = ColorHelper.DefaultButton1

    self.key_text = self.noticeConfirmPanel:Find("Main/Key_Text"):GetComponent(Text)

    self.input_field = 
    self.noticeConfirmPanel:Find("Main/InputCon/InputField"):GetComponent(InputField)

    self.input_field.textComponent = 
    self.noticeConfirmPanel:Find("Main/InputCon/InputField/Text"):GetComponent(Text)
    self.input_field.text = TI18N("请输入上方的验证码")
    --self.lockKey = tostring(math.random(1000, 9999))
    --self.transform:FindChild("LockPanel/Main/Key_Text"):GetComponent(Text).text = self.lockKey


    -----------------------------------------------------------------------------
    self:OnShow()
    self:ClearMainAsset()
end


function ClassesChangeWindow:Reload()
    local datalist = {}

    for i=1,self.totalRoleItem * 3 do
        table.insert(datalist, {id = i, isEmpty = false, unknown = false})
    end

    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)

    --第一次更新初始化
    self:update_head()
    --更新位置
    self:UpdatePos()
end

function ClassesChangeWindow:UpdatePos()
    local y = nil
    local res = nil

    -- 这个算法。。。看不懂也别问我
    -- 运动轨迹是椭圆，设坐标原点是左上角，然后标准方程是(x + 123)^2 / 250^2 + (y + 210)^2 / 296.5^2 = 1
    -- 然后就有下面的算法
    for i,v in ipairs(self.itemList) do
        y = v.transform.anchoredPosition.y + self.container.anchoredPosition.y - v.transform.sizeDelta.y / 2

        res = 1 - ((y + 210)*(y + 210) / (296.5*296.5))
        if res >= 0 then
            v.item.anchoredPosition = Vector2(math.sqrt(res) * 250 - 123 - 138.25 - 11, 0)
            --v:SetScale(1 - (y + 210) * (y + 210) * (1 - 0.6)/44100)
            local value = (1 - (y + 210) * (y + 210) * (1 - 0.5)/44100) - 0.2

            if value < 0.72 then
                value = 0.72
            end
            v:SetScale( value )

        end
    end
end

-- 转到
function ClassesChangeWindow:TweenTo(index)

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    self.tweenId = Tween.Instance:ValueChange(self.container.anchoredPosition.y, 84 * index, 0.5,
        function()
            self.tweenId = nil
            self.coldClick = true
            -------------设置container位置------------------
            self:SetContainerPos(self.container.anchoredPosition.y)
        end
        , LeanTweenType.easeOutQuart,
        function(value)
            self.container.anchoredPosition = Vector2(0, value)
        end).id
end

function ClassesChangeWindow:OnUp()

    local y = self.container.anchoredPosition.y
    if self.tweenId1 ~= nil then
        Tween.Instance:Cancel(self.tweenId1)

    end
    self.tweenId1 = Tween.Instance:ValueChange(y, 84 * math.ceil(math.floor(y * 2 / 84) / 2), 0.5,
        function()
            self.tweenId1 = nil
            ----------------------------------翻页时更新位置
            self:SetContainerPos(self.container.anchoredPosition.y)
            ------------------tag-------------翻页时更新数据
            self:SetInfo(self.container.anchoredPosition.y)
        end
        , LeanTweenType.easeOutQuart,
        function(value)
            self.container.anchoredPosition = Vector2(0, value)
        end).id
end

    --将条目设置成准确位置
function ClassesChangeWindow:SetContainerPos(y)
    local index = math.floor((y - 42) / 84) + 1  + 3

    --根据不同的序号重置条目
    local temp = index
    if temp < self.totalRoleItem + 1  then
        temp = temp +  self.totalRoleItem
    elseif temp > self.totalRoleItem * 2 then
        temp = temp - self.totalRoleItem
    end

    --设置位置
    self.container.anchoredPosition = Vector2(0, 84*(temp - 3))

end

------更新数据
function ClassesChangeWindow:SetInfo(y)
    --计算出停留的位置
    local index = math.floor((y - 42) / 84) + 1  + 3

    local pos = index % self.totalRoleItem
    if pos == 0 then
        pos = self.totalRoleItem
    end
    --根据停留的位置得到当前的职业序号
    local classes = self.list[pos]
    self:UpdateInfo(classes)
end




---------------------------------------------------------------------------------------------------












function ClassesChangeWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function ClassesChangeWindow:OnShow()
	EventMgr.Instance:AddListener(event_name.change_classes_price, self._ShowNoticeConfirm)

    --已经突破过
    if RoleManager.Instance.RoleData.lev >= 85 then
        self.changeClassesList = {
            [1] = {2,3,4,5,6,7}
            ,[2] = {1,3,4,5,6,7}
            ,[3] = {1,2,4,5,6,7}
            ,[4] = {1,2,3,5,6,7}
            ,[5] = {1,2,3,4,6,7}
            ,[6] = {1,2,3,4,5,7}
            ,[7] = {1,2,3,4,5,6}
        }
    end

	--初次加载
    self:Reload()
    self:updateClassesTime()
end

function ClassesChangeWindow:OnHide()
	EventMgr.Instance:RemoveListener(event_name.change_classes_price, self._ShowNoticeConfirm)

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end

    if self.tweenId1 ~= nil then
        Tween.Instance:Cancel(self.tweenId1)
        self.tweenId1 = nil
    end
end

function ClassesChangeWindow:updateClassesTime()
	self.transform:FindChild("Main/DescPanel/DescText"):GetComponent(Text).text = string.format(self.descString, self.model:GetClassesChangeDay())
	if RoleManager.Instance.RoleData.last_classes_modify_time ~= 0 then
		local day,hour,min = BaseUtils.time_gap_to_timer(BaseUtils.BASE_TIME - RoleManager.Instance.RoleData.last_classes_modify_time)
		if tonumber(day) == 0 then
			self.transform:FindChild("Main/TimeText"):GetComponent(Text).text = string.format(TI18N("上次转职时间: %s小时%s分"), hour, min)
		else
			self.transform:FindChild("Main/TimeText"):GetComponent(Text).text = string.format(TI18N("上次转职时间: %s天%s小时"), day, hour)
		end
	else
		self.transform:FindChild("Main/TimeText"):GetComponent(Text).text = TI18N("上次转职时间: 未转职")
	end
end


function ClassesChangeWindow:update_head()
	local roleData = RoleManager.Instance.RoleData

	for _,value in ipairs(self.classesList) do
		if value ~= roleData.classes then
			table.insert(self.list, value)
		end
	end

	local headImage = {}
	for _,value in ipairs(self.list) do
		if roleData.sex == 1 then
			table.insert(headImage, self.maleHeadImageList[value])
		else
			table.insert(headImage, self.femaleHeadImageList[value])
		end
	end

    for i=1, #self.itemList do
        local item = self.itemList[i]
        local icon = item.transform:FindChild("Item/Icon"):GetComponent(Image)

        --循环处理
        local j = i % self.totalRoleItem
        if j == 0 then
            j = self.totalRoleItem
        end

        item.gameObject.name = tostring(self.list[j])

        icon.name = tostring(self.list[j])
        icon.sprite = self.assetWrapper:GetSprite(AssetConfig.createrole2_texture, string.format("%s", headImage[j]))

        icon:SetNativeSize()
    end


    local myClasses = RoleManager.Instance.RoleData.classes
    for index, item in ipairs(self.itemList) do
    	if tonumber(item.gameObject.name) == self.changeClassesList[myClasses][1] then

            local index = tonumber(item.gameObject.name)  --得到对应的可转换职业
            self:UpdateInfo(index)        --更新信息

            local indexPos = 0
            for i=1, #self.list do
                if self.list[i] == index then
                    indexPos = i + 6
                end
            end
            self:TweenTo( indexPos - 3 )
	        break
        end
	end
end


function ClassesChangeWindow:UpdateInfo(classes)

    self.selectClasses = classes

    --撤销选中状态
    if self.selectedItem ~= nil then
        local img_selected = self.selectedItem.transform:FindChild("Item/Selected"):GetComponent(Image)
        img_selected.gameObject:SetActive(false)
    end

    local indexPos = 0
    for i = 1, #self.list do
        if self.list[i] == classes then
            indexPos = i
        end
    end

    self.selectedItem = self.itemList[indexPos + self.totalRoleItem]

    --将新选中的RoleItem设置为选中状态
    local img_selected = self.selectedItem.transform:FindChild("Item/Selected"):GetComponent(Image)
    img_selected.gameObject:SetActive(true)


    self:update_skill()

    local myClasses = RoleManager.Instance.RoleData.classes

    if table.containValue(self.changeClassesList[myClasses], self.selectClasses) then
        self.transform:FindChild("Main/OkButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.transform:FindChild("Main/OkButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton1Str, TI18N("转 职"))

        self.transform:FindChild("Main/OkButton"):GetComponent(Button).enabled = true
        self.transform:FindChild("Main/OkButton"):GetComponent(TransitionButton).enabled = true
    else
        self.transform:FindChild("Main/OkButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")

        self.transform:FindChild("Main/OkButton/Text"):GetComponent(Text).text = string.format(ColorHelper.DefaultButton1Str, TI18N("85级可转"))

        local state = false
        --新职业特殊处理
        -- if 7 == myClasses  then
        --     state = true
        -- end

        self.transform:FindChild("Main/OkButton"):GetComponent(Button).enabled = state
        self.transform:FindChild("Main/OkButton"):GetComponent(TransitionButton).enabled = false
    end

end


function ClassesChangeWindow:update_skill()
	local skill_id_list = BaseUtils.copytab(DataSkill.data_skill_role_init[self.selectClasses].skills)
    if RoleManager.Instance.RoleData.lev > 87 then table.insert(skill_id_list,DataSkillUnique.data_skill_unique[self.selectClasses.."_1"].id) end
	for i=1,#skill_id_list do
		self.skillItemList[i]:SetActive(true)

		local data = DataSkill.data_skill_role[string.format("%s_1", skill_id_list[i])]
		self.skillSlotList[i]:SetAll(Skilltype.roleskill, data, { classes = self.selectClasses })
		self.skillSlotList[i]:ShowName(false)
		self.skillSlotList[i]:ShowLevel(false)
    	self.skillTextList[i].text = data.name
	end


	for i=#skill_id_list+1, #self.skillItemList do
		self.skillItemList[i]:SetActive(false)
	end
end

function ClassesChangeWindow:OnOkButton()
	if RoleManager.Instance.RoleData.last_classes_modify_time ~= 0 then
		local day = BaseUtils.time_gap_to_timer(BaseUtils.BASE_TIME - RoleManager.Instance.RoleData.last_classes_modify_time)
		local needday = self.model:GetClassesChangeDay()
		if tonumber(day) < needday then
			NoticeManager.Instance:FloatTipsByString(string.format(TI18N("距离上次转职不足<color='#ffff00'>%s天</color>，无法进行转职"), needday))
		else
			ClassesChangeManager.Instance:Send10027(self.selectClasses)
		end

    -- --新职业的特殊处理
    -- elseif 7 == RoleManager.Instance.RoleData.classes and  (2 == self.selectClasses or 4 == self.selectClasses or 6 == self.selectClasses) then
    --         NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>圣骑</color>只能转职成<color='#ffff00'>狂剑，战弓，秘言</color>哟~{face_1, 22}")))
	else

		ClassesChangeManager.Instance:Send10027(self.selectClasses)
	end
end

function ClassesChangeWindow:ShowNoticeConfirm(dat)
    local targetClasses = KvData.classes_name[self.selectClasses]
	local data = NoticeConfirmData.New()
	data.type = ConfirmData.Style.Normal
	if dat.rate > 1000 then
		data.content = string.format(TI18N("转职将消耗{assets_1,90002,%s}或者{assets_1,90003,%s}，确定要转职<color='#ffff00'>%s</color>吗?"), dat.cost, dat.cost_gold, targetClasses)
	else
		data.content = string.format(TI18N("<color='#ffff00'>%s</color>在全服所占比例为<color='#00ff00'>%s%%</color>，转职将消耗{assets_1,90002,%s}或者{assets_1,90003,%s}，确定要转职<color='#ffff00'>%s</color>吗?"), targetClasses, dat.rate/10, dat.cost, dat.cost_gold, targetClasses)
	end
	data.sureLabel = TI18N("{assets_2,90003}转 职")
	data.cancelLabel = TI18N("{assets_2,90002}转 职")
    data.showClose = 1
	data.cancelCallback = function()
		ClassesChangeManager.Instance:Send10028(self.selectClasses,2)
	    self:OnClickClose()
	end
    data.sureCallback = function()
        LuaTimer.Add(50,function()
            if dat.cost_gold * 2 > RoleManager.Instance.RoleData.gold_bind then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Sure
                data.content = TI18N("<color='#00ff00'>温馨提示：</color>\n\n为确保转职体验，需拥有<color='#ffff00'>双倍金币</color>才可选择金币转职哟，当前拥有的<color='#ffff00'>金币不足</color>{face_1,3}")
                NoticeManager.Instance:ConfirmTips(data)
            else
                ClassesChangeManager.Instance:Send10028(self.selectClasses,1)
                self:OnClickClose()
            end
        end)
    end

	-- if self:CheckDiffTypeClasses() then
	-- 	data.content = string.format("%s\n<color='#ffff00'>(注：所转职业与当前职业属性需求不同，转职后短时间内可能会对实力带来一定影响）</color>", data.content)
	-- end
	data.content = string.format(TI18N("%s\n\n<color='#ffff00'>1、为确保转职体验，需拥有双倍金币才可选择金币转职\n2、如果选择转职回原来的职业，消耗将减半</color>"), data.content)

	NoticeManager.Instance:ConfirmTips(data)

end

function ClassesChangeWindow:ShowNoticeSurePanel(dat)
    local contentText = ""
    self.noticeConfirmPanel.gameObject:SetActive(true)
    self.input_field.text = TI18N("请输入上方的验证码")
    local targetClasses = KvData.classes_name[self.selectClasses]

    if dat.rate > 1000 then
		contentText = string.format(TI18N("转职将消耗{assets_1,90002,%s}或者{assets_1,90003,%s}，请输入验证码确认转职<color='#ffff00'>%s</color>\n\n<color='#ffff00'>1、为确保转职体验，需拥有双倍金币才可选择金币转职\n2、如果选择转职回原来的职业，消耗将减半</color>"), dat.cost, dat.cost_gold, targetClasses)
	else
		contentText = string.format(TI18N("<color='#ffff00'>%s</color>在全服所占比例为<color='#00ff00'>%s%%</color>，转职将消耗{assets_1,90002,%s}或者{assets_1,90003,%s}，请输入验证码确认转职<color='#ffff00'>%s</color>\n<color='#ffff00'>1、为确保转职体验，需拥有双倍金币才可选择金币转职\n2、如果选择转职回原来的职业，消耗将减半</color>"), targetClasses, dat.rate/10, dat.cost, dat.cost_gold, targetClasses)
    end
    self.contentMsgExt:SetData(contentText)

    self.lockKey = tostring(math.random(1000, 9999))
    self.key_text.text = string.format(TI18N("验证码: %s"), self.lockKey)

    self.cancalBtn:GetComponent(Button).onClick:RemoveAllListeners()
    self.cancalBtn:GetComponent(Button).onClick:AddListener(function() 
        local str = self.input_field.text
        if str == self.lockKey then
            ClassesChangeManager.Instance:Send10028(self.selectClasses,2) 
            self:CancelNoticeSurePanel() 
            self:OnClickClose()
        else
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请输入验证码<color='#ffff00'>%s</color>确认"), self.lockKey))
        end
    end)   --钻石

    self.sureBtn:GetComponent(Button).onClick:RemoveAllListeners()
    self.sureBtn:GetComponent(Button).onClick:AddListener(function() 
        LuaTimer.Add(50,function()
            local str = self.input_field.text
            if str == self.lockKey then
                if dat.cost_gold * 2 > RoleManager.Instance.RoleData.gold_bind then
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Sure
                    data.content = TI18N("<color='#00ff00'>温馨提示：</color>\n\n为确保转职体验，需拥有<color='#ffff00'>双倍金币</color>才可选择金币转职哟，当前拥有的<color='#ffff00'>金币不足</color>{face_1,3}")
                    NoticeManager.Instance:ConfirmTips(data)
                else
                    ClassesChangeManager.Instance:Send10028(self.selectClasses,1)
                    self:CancelNoticeSurePanel()
                    self:OnClickClose()
                end
            else
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请输入验证码<color='#ffff00'>%s</color>确认"), self.lockKey))
            end
            
        end)
    end)   --金币
    --self.suretext
    --self.cancaltext
end

function ClassesChangeWindow:CancelNoticeSurePanel()
    self.noticeConfirmPanel.gameObject:SetActive(false)
end

-- function ClassesChangeWindow:CheckDiffTypeClasses()
-- 	local list = {
-- 		[1] = { false, true, false, true, true, true},
-- 		[2] = { true, false, true, true, true, false},
-- 		[3] = { false, true, false, true, true, true},
-- 		[4] = { true, true, true, false, false, true},
-- 		[5] = { true, true, true, false, false, true},
-- 		[6] = { true, false, true, true, true, false}
-- 	}
-- 	return list[RoleManager.Instance.RoleData.classes][self.selectClasses]
-- end

--特殊职业处理
-- function ClassesChangeWindow:ShowNoticeConfirm(dat)
--     if 7 ~= RoleManager.Instance.RoleData.classes then
--         self:ShowNoticeConfirm2(dat)
--     else
--         local data = NoticeConfirmData.New()
--         data.type = ConfirmData.Style.Normal
--         data.content = string.format(TI18N("圣骑转职后暂时不可再次转职回圣骑，请仔细考虑后再进行操作"))
--         data.sureLabel = TI18N("我再想想")
--         data.cancelLabel = TI18N("确认转职")
--         data.cancelCallback = function()
--             LuaTimer.Add(50, function() self:ShowNoticeConfirm2(dat) end)
--         end
--             NoticeManager.Instance:ConfirmTips(data)
--     end
-- end
