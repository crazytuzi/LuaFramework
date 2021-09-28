SpiritAptitudeView = SpiritAptitudeView or BaseClass(BaseRender)
--aptitude:代表资质

local APTITUDE_TYPE = {"gongji", "fangyu", "maxhp", "maxhp_zizhi"}
function SpiritAptitudeView:__init(Instance)
    self.use_lucky_mark = false
    self.auto_buy = false
    self.base_attr_list = {}
    self.cur_owned = {}
    self.cur_deleption = {}
    for i = 1, 4 do
        self.base_attr_list[i] = {name = self:FindVariable("BaseAttrName"..i), value = self:FindVariable("BaseAttrValue"..i), 
            next_value = self:FindVariable("BaseAttrNextValue"..i), 

        }
    end
    for i = 1, 2 do
        self.cur_owned[i] = self:FindVariable("CurOwned" .. i)
        self.cur_deleption[i] = self:FindVariable("CurDepletion" .. i)
    end
    self.show_lucky = self:FindVariable("ShowLucky")
    self.use_lucky = self:FindVariable("UseLucky")
    self.lucky_item = self:FindVariable("LuckyItem")
    self.wu_xing = self:FindVariable("WuXing")
    self.percent = self:FindVariable("Percent")
    self.show_next = self:FindVariable("ShowNext")
    self.show_uplevel_btn = self:FindVariable("ShowUplevelBtn")
    self.skill_num = self:FindVariable("SkillNum")
    self.cur_level = self:FindVariable("CurLevel")
    self.need_level = self:FindVariable("NeedLevel")
    self.show_limit = self:FindVariable("ShowLimit")
    self.next_skill = self:FindVariable("NextSkill")


    self.auto_buy_toggle = self:FindObj("AutoBuyToggle").toggle
    self.material = ItemCellReward.New()
    self.material:SetInstanceParent(self:FindObj("Material"))

    self:ListenEvent("OpenSpiritAptitudeTip", BindTool.Bind(self.OpenSpiritAptitudeTip, self))
    self:ListenEvent("ToggleAutoBuy", BindTool.Bind(self.ToggleAutoBuy, self))
    self:ListenEvent("OnClickUseLuckyMark", BindTool.Bind(self.OnClickUseLuckyMark, self))
    self:ListenEvent("OnClickUpgrade", BindTool.Bind(self.OnClickUpgrade, self))
    self.wuxing_data = SpiritData.Instance:GetWuXing()

    self.titles, self.title_needs, self.extra_attr, self.title_effect = self:GetAllTitle()
    self.maxlevel = #self.wuxing_data
end

function SpiritAptitudeView:__delete()
    if self.material then
        self.material:DeleteMe()
        self.material = nil
    end
    
end

function SpiritAptitudeView:SetAptitude(data)
    if data then
        self.show_uplevel_btn:SetValue(data.wu_xing ~= self.maxlevel)
        if data.safe_id ~= 0 then
            self.lucky_item:SetAsset(ResPath.GetItemIcon(data.safe_id))
        end
        if tonumber(data.wu_xing) == self.maxlevel then
            self.show_next:SetValue(false)
        else
            self.show_next:SetValue(true)
        end
        if data.cur_deleption[2] == 0 then
            self.show_lucky:SetValue(false)
        else 
            self.show_lucky:SetValue(true)
        end
        self.wu_xing:SetValue(data.wu_xing)
        local x = {}
        x.item_id = data.item_id
        self.material:SetData(x)
        self.percent:SetValue(data.percent)
        for i = 1, 4 do
            self.base_attr_list[i].name:SetValue(data.aptitude_list[i].name)
            self.base_attr_list[i].value:SetValue(data.aptitude_list[i].value)
            self.base_attr_list[i].next_value:SetValue(data.aptitude_list[i].next_value)
        end
        for i = 1, 2 do
            if self.cur_data.cur_owned[i] < self.cur_data.cur_deleption[i] then
                local value = string.format(Language.Mount.ShowRedNum, self.cur_data.cur_owned[i])
                self.cur_owned[i]:SetValue(value)
            else
				local value = string.format(Language.Mount.ShowBlueNum, data.cur_owned[i])
				self.cur_owned[i]:SetValue(value)
            end
            
            self.cur_deleption[i]:SetValue(data.cur_deleption[i])
        end
        if data.cur_owned[2] < data.cur_deleption[2] then
            self.use_lucky_mark = false
            self.use_lucky:SetValue(false)
        end
        self.skill_num:SetValue(data.skill_num)
        self.cur_level:SetValue(data.cur_level)
        self.need_level:SetValue(data.need_level)
        self.show_limit:SetValue(data.show_limit)
        self.next_skill:SetValue(data.next_skill)
    end
end

function SpiritAptitudeView:OpenSpiritAptitudeTip()
    TipsCtrl.Instance:ShowSpiritAptitudeView(self.cur_data)
end

-- 对外的入口
function SpiritAptitudeView:FlushData(data)
    if next(data) then
        if data.item_id ~= self.cur_item then
            self.use_lucky_mark = false
            self.use_lucky:SetValue(self.use_lucky_mark)
        end
        self.aptitude_data = SpiritData.Instance:GetSpiritTalentAttrCfgById(data.item_id)
        self.cur_item = data.item_id
        self:ConstructData(data)
    end
end


function SpiritAptitudeView:ConstructData(data)
    if data == nil then 
        return
    end
    self.cur_data = {}

    self.cur_data.titles = self.titles
    self.cur_data.title_needs = self.title_needs
    self.cur_data.extra_attr = self.extra_attr
    self.cur_data.title_effect = self.title_effect
    
    self.cur_data.wu_xing = data.param.param1
    local wu_xing = tonumber(self.cur_data.wu_xing)
    -- 无需修改 已屏蔽
    local highest_wu_xing = tonumber(data.param.param2)
    self.cur_data.skill_num = self.wuxing_data[highest_wu_xing].skill_num
    self.cur_data.cur_level = "<color=" .. TEXT_COLOR.RED .. ">" .. highest_wu_xing .. "</color>"
    self.cur_data.need_level = SpiritData.Instance:GetNextWuXingBySkillNum(self.cur_data.skill_num)
    self.cur_data.show_limit = SpiritData.Instance:GetMaxSkillNum() ~= self.cur_data.skill_num
    self.cur_data.next_skill = self.cur_data.skill_num + 1
    self.cur_data.percent = self.wuxing_data[wu_xing].succ_rate
    self.cur_data.item_id = self.wuxing_data[wu_xing].stuff_id
    self.cur_data.safe_id = self.wuxing_data[wu_xing].safe_id
    self.cur_data.index = data.index
    self.cur_data.aptitude_list = {}
    self.cur_data.cur_owned = {}
    self.cur_data.cur_deleption = {}
    for i = 1, 4 do
        self.cur_data.aptitude_list[i] = {}
        self.cur_data.aptitude_list[i].name = Language.ZiZhi[i]
        self.cur_data.aptitude_list[i].original_value = self.aptitude_data[APTITUDE_TYPE[i]]
        local next_wuxing = wu_xing == self.maxlevel and wu_xing or wu_xing + 1
        if i == 4 then
            self.cur_data.aptitude_list[i].value = math.floor(self:CalculateAptitude(self.aptitude_data[APTITUDE_TYPE[i]], self.wuxing_data[wu_xing][APTITUDE_TYPE[i]]) / 10) .. "%"
            self.cur_data.aptitude_list[i].next_value = math.floor(self:CalculateAptitude(self.aptitude_data[APTITUDE_TYPE[i]], self.wuxing_data[next_wuxing][APTITUDE_TYPE[i]]) / 10) .. "%"
        else
            self.cur_data.aptitude_list[i].value = math.floor(self.wuxing_data[wu_xing][APTITUDE_TYPE[i]])
            self.cur_data.aptitude_list[i].next_value = math.floor(self.wuxing_data[next_wuxing][APTITUDE_TYPE[i]])
        end 
    end
    local items = {}
    table.insert(items, self.cur_data.item_id)
    table.insert(items, self.cur_data.safe_id)
    local itemsNum = {}
    table.insert(itemsNum, self.wuxing_data[wu_xing].stuff_num)
    table.insert(itemsNum, self.wuxing_data[wu_xing].safe_num)
    for i = 1, 2 do
        self.cur_data.cur_owned[i] = ItemData.Instance:GetItemNumInBagById(items[i])
        self.cur_data.cur_deleption[i] = itemsNum[i] 
    end
    self:SetAptitude(self.cur_data)
end

function SpiritAptitudeView:OnClickUpgrade()
    if self:CheckLevel() then
        TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.MaxJingLingLevel)
        return
    end

    if not self.auto_buy then
        if self.cur_data.cur_owned[1] < self.cur_data.cur_deleption[1] then
            local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
                MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
                --勾选自动购买
                if is_buy_quick then
                    self.auto_buy_toggle.isOn = true
                    self.auto_buy = true
                end
            end
            TipsCtrl.Instance:ShowCommonBuyView(func, self.cur_data.item_id, nil, self.cur_data.cur_deleption[1] - self.cur_data.cur_owned[1])
        else
            local lucky_mark_number = self.use_lucky_mark and 1 or 0
            SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_WUXING, self.cur_data.index, lucky_mark_number, 0)
        end
    else
        local lucky_mark_number = self.use_lucky_mark and 1 or 0
        SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL_WUXING, 
        self.cur_data.index, lucky_mark_number, 1)
    end
end

function SpiritAptitudeView:OnClickUseLuckyMark()
    if self.cur_data.cur_owned[2] < self.cur_data.cur_deleption[2] then
        self.use_lucky_mark = false
        self.use_lucky:SetValue(false)
        TipsCtrl.Instance:ShowItemGetWayView(self.cur_data.safe_id)
        return
    end
    self.use_lucky_mark = not self.use_lucky_mark
    self.use_lucky:SetValue(self.use_lucky_mark)

end

function SpiritAptitudeView:ToggleAutoBuy()
    self.auto_buy = not self.auto_buy
end

-- 检查是否顶级
function SpiritAptitudeView:CheckLevel()
    return self.cur_data.wu_xing == self.maxlevel
end

function SpiritAptitudeView:CalculateAptitude(aptitude, wu_xing)
    return aptitude + wu_xing
end

function SpiritAptitudeView:GetAllTitle()
    local titles = {}
    local title_needs = {}
    local title_extra_add = {}
    local title_effect = {}
    for i, v in ipairs(self.wuxing_data) do
        if titles[#titles] ~= v.title then
            table.insert(titles, v.title)
            table.insert(title_effect, v.effect_id)
            table.insert(title_extra_add, v.extra_attr)
            if v.title ~= "" then
                table.insert(title_needs, i)

            end
        end
    end
    return titles, title_needs, title_extra_add, title_effect
end
