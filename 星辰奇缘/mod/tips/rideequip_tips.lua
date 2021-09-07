-- ------------------------------
-- 坐骑装备tips
-- ljh 20160824
-- ------------------------------
RideEquipTips = RideEquipTips or BaseClass(BaseTips)

function RideEquipTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_ride_equip, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 20
    self.buttons = {}
    self.DefaultSize = Vector2(315, 0)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)
end

function RideEquipTips:__delete()
    if self.itemCell ~= nil then
        self.itemCell:DeleteMe()
        self.itemCell = nil
    end
    self.mgr = nil
    self.buttons = {}
    self.height = 20
    self:RemoveTime()
end

function RideEquipTips:RemoveTime()
    self.mgr.updateCall = nil
end

function RideEquipTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_ride_equip))
    self.gameObject.name = "RideEquipTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.model:Closetips() end)

    self.rect = self.gameObject:GetComponent(RectTransform)

    local head = self.transform:Find("HeadArea")
    self.itemCell = ItemSlot.New(head:Find("ItemSlot").gameObject)
    self.itemCell:SetNotips()
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.bindObj = head:Find("Bind").gameObject

    local mid = self.transform:Find("MidArea")
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.descTxt = mid:Find("Desc"):GetComponent(Text)
    self.descTxt.horizontalOverflow = HorizontalWrapMode.Overflow
    self.descRect = self.descTxt.gameObject:GetComponent(RectTransform)
    self.text1 = mid:Find("Text1"):GetComponent(Text)
    self.text2 = mid:Find("Text2"):GetComponent(Text)
    self.text3 = mid:Find("Text3"):GetComponent(Text)

    self.msg1 = MsgItemExt.New(self.text1, 250, 18, 21)
    self.msg2 = MsgItemExt.New(self.text2, 250, 18, 21)
    self.msg3 = MsgItemExt.New(self.text3, 250, 18, 21)

    self.trect1 = self.text1.gameObject:GetComponent(RectTransform)
    self.trect2 = self.text2.gameObject:GetComponent(RectTransform)
    self.trect3 = self.text3.gameObject:GetComponent(RectTransform)

    local bottom = self.transform:Find("BottomArea")
    self.bottomRect = bottom.gameObject:GetComponent(RectTransform)

    -- self.toggle = bottom.transform:FindChild("Toggle"):GetComponent(Toggle)
    -- self.toggle.onValueChanged:AddListener(function(on) self:onToggleChange(on) end)

    self.buttons = {

    }
end

function RideEquipTips:UnRealUpdate()
    if Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began then
        local v2 = Input.GetTouch(0).position
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end

    if Input.GetMouseButtonDown(0) then
        local v2 = Input.mousePosition
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end
end

function RideEquipTips:Default()
    self.height = 20
    self.nameTxt.text = ""
    self.bindObj:SetActive(false)
    self.descTxt.text = ""
    self.text1.text = ""
    self.text2.text = ""
    self.text3.text = ""

    for _,button in pairs(self.buttons) do
        button.gameObject:SetActive(false)
    end

    self.rect.sizeDelta = self.DefaultSize
end

-- ------------------------------------
-- 外部调用更新数据
-- 参数说明:
-- info = 道具数据
-- extra = 扩展参数
-- ---- inbag = 是否在背包
-- ---- nobutton = 是否不要任何按钮
-- ---- button_list = 自定义列表 {id,show}
-- ---- 注意，传人button_list就直接根据该列表处理，不做默认处理
-- ------------------------------------
function RideEquipTips:UpdateInfo(info, extra)
    self:Default()

    self.itemData = info
    self.nameTxt.text = ColorHelper.color_item_name(info.quality, info.name)
    self.itemCell:SetAll(info, extra)
    self.itemCell:ShowNum(false)
    self.bindObj:SetActive(info.bind == 1)

    local ddesc = info.desc

    -- 处理品阶描述显示
    if info.step ~= nil and info.step ~= 0 then
        local step_data = DataSkillLife.data_fight_effect[string.format("%s_%s", info.base_id, info.step)]
        if step_data ~= nil then
            ddesc = string.gsub(ddesc, "%[skill_life1%]", tostring(step_data.args[1]))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", tostring(step_data.args[2]))
        else
            ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
            ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
        end
    else
        ddesc = string.gsub(ddesc, "%[skill_life1%]", TI18N("一定"))
        ddesc = string.gsub(ddesc, "%[skill_life2%]", TI18N("一定"))
    end

    self.height = 105

    -- 处理描述显示
    local th = 0
    local descStr = ""

    -- 处理有效时间显示
    if info.expire_type == nil or info.expire_type == BackpackEumn.ExpireType.None then
        descStr = ""
    elseif info.expire_type == BackpackEumn.ExpireType.StartTime or info.expire_type == BackpackEumn.ExpireType.StartDate then
        if BaseUtils.BASE_TIME > info.expire_time then
            descStr = ""
        else
            local timeStr = string.format("%s %s", os.date("%Y-%m-%d", info.expire_time), os.date("%H:%M", info.expire_time))
            descStr = string.format(TI18N("\n<color='#00ffff'>%s 可开启</color>"), timeStr)
        end
    else
        local timeStr = string.format("%s %s", os.date("%Y-%m-%d", info.expire_time), os.date("%H:%M:00", info.expire_time))
        descStr = string.format(TI18N("\n<color='#00ffff'>过期:%s</color>"), timeStr)
    end

    if descStr ~= "" then
        self.descRect.sizeDelta = Vector2(250, 60)
        th = -65
    else
        self.descRect.sizeDelta = Vector2(250, 40)
        th = -45
    end

    self.descTxt.text = string.format(TI18N("作用:%s"), info.func) .. descStr

    local strs = {}
    for s1, s2 in string.gmatch(ddesc, "(.+);(.+)") do
        strs = {s1, s2}
    end
    if #strs == 0 then
        self.trect1.anchoredPosition = Vector2(0, th)
        self.msg1:SetData(ddesc)
        self.text1.gameObject:SetActive(true)
        self.text2.text = ""
        self.text2.gameObject:SetActive(false)
        th = th - self.msg1.selfHeight - 5
    else
        self.trect1.anchoredPosition = Vector2(0, th)
        self.msg1:SetData(strs[1])
        self.text1.gameObject:SetActive(true)
        th = th - self.msg1.selfHeight - 5

        self.trect2.anchoredPosition = Vector2(0, th)
        self.msg2:SetData(strs[2])
        self.text2.gameObject:SetActive(true)
        th = th - self.msg2.selfHeight - 5
    end

    -- 处理价格显示
    local price = BackpackEumn.GetSellPrice(info)
    if price ~= 0 and info.bind ~= 1 then
        self.trect3.anchoredPosition = Vector2(0, th)
        self.msg3:SetData(string.format(TI18N("出售价格: {assets_1,90003,%s}"), price))
        self.text3.gameObject:SetActive(true)
        th = th - self.msg3.selfHeight - 5
    else
        self.text3.text = ""
        self.text3.gameObject:SetActive(false)
    end
    self.midRect.sizeDelta = Vector2(255, math.abs(th))
    self.height = self.height + math.abs(th) + 10

    self.bottomRect.anchoredPosition = Vector2(0, -self.height)

    -- 处理按钮
    self:ShowButton(info, extra)

    self.rect.sizeDelta = Vector2(self.width, self.height)

    self.mgr.updateCall = self.updateCall
end

-- 处理tips按钮
function RideEquipTips:ShowButton(info, extra)
	self.extra = extra
 --    if extra ~= nil and extra.decorate_data ~= nil then
	-- 	self.height = self.height + 45
	-- 	self.toggle.isOn = (extra.decorate_data.is_hide == 0)
	-- 	self.toggle.gameObject:SetActive(true)
	-- else
	-- 	self.toggle.gameObject:SetActive(false)
	-- end

    self.height = self.height + 15
end

function RideEquipTips:onToggleChange(on)
    if self.extra ~= nil and self.extra.decorate_data ~= nil and self.extra.index ~= nil then
    	local is_hide = 1
    	if on then
    		is_hide = 0
    	end
    	RideManager.Instance:Send17020(self.extra.index, self.extra.decorate_data.decorate_index, is_hide)
    end
end
