--------------------------------------------------------
-- 官职视图     配置 office_cfg
--------------------------------------------------------

OfficeView = OfficeView or BaseClass(BaseView)

function OfficeView:__init()
    self:SetModal(true)
    self:SetBackRenderTexture(true)
    
    self.texture_path_list[1] = "res/xui/office.png"
    self.config_tab = {
        {"common_ui_cfg", 1, {0}},
        {"office_ui_cfg", 1, {0}, false}, -- 默认隐藏 layout_office_1,加载完之后才显示
        {"common_ui_cfg", 2, {0}, nil, 999},
	}

    self.phase_num = nil -- 阶位等级数字
    self.power_view = nil --战力视图
    self.text_btn = nil -- 获取材料途径按钮
    self.effect = nil -- 神鼎特效
    self.phase = nil -- 当前阶位

    self.is_bullet_window = false -- 是否弹出获取途径

    self.door = DoorModal.New()
    self.door:BindClickActBtnFunc(BindTool.Bind(self.OnClickUPHandler, self))
end

function OfficeView:ReleaseCallBack()

    if self.phase_num then
        self.phase_num:DeleteMe()
        self.phase_num = nil
    end

    if self.power_view then
        self.power_view:DeleteMe()
        self.power_view = nil
    end
    
    self.door:Release()

    self.text_btn = nil
    self.effect = nil
    self.phase = nil
    self.is_bullet_window = nil
end

function OfficeView:LoadCallBack(index, loaded_times)
    self.phase = OfficeData.Instance:GetPhase()

    --按钮特效
    self.node_t_list.layout_btn_1.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.layout_btn_1.node, 1)

    self:CreateGetDanBtn()
    self:CreateEffextView()
    self:FlushPhaseView()
    self:FlushBtnUpView()
    self:FlushVolumeView()
    self:FlushStarsView()
    self:FlushBonusView()

    -- 生成战力视图
    local ph = self.ph_list.ph_power_value
    self.power_view = FightPowerView.New(ph.x, ph.y,self.node_t_list.layout_office_1.node, 20)
    self.power_view:SetScale(1)
    self:FlushPowerValueView() -- 刷新战力值视图

    --按钮监听
    XUI.AddClickEventListener(self.node_t_list.layout_btn_1.node, BindTool.Bind(self.OnClickUPHandler, self), true)

    --数据监听
    EventProxy.New(OfficeData.Instance, self):AddEventListener(OfficeData.OFFICE_LEVEL_CHANGE, BindTool.Bind(self.LevelChangeHandler, self))
    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function OfficeView:OpenCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()

    local level = OfficeData.Instance:GetLevel()
    self.door:SetVis(level == 0, self:GetRootNode())
    if level == 0 then
        self.door:CloseTheDoor()
    end
end

function OfficeView:CloseCallBack()
    AudioManager.Instance:PlayOpenCloseUiEffect()
end

function OfficeView:ShowIndexCallBack(index)
    
    self.node_t_list.layout_office_1.node:setVisible(true)
end

function OfficeView:OnFlush(param_list)
    if param_list.bag_item_change then
        self:FlushVolumeView()
    end
end

function OfficeView:OnBagItemChange()
    self:Flush(0, "bag_item_change")
end

----------视图函数----------

-- 刷新战力值视图
function OfficeView:FlushPowerValueView()
    local level = OfficeData.Instance:GetLevel()   -- 获取官职基础等级

     -- 如果配置为空,战力显示为0
    if nil == office_cfg.level_list[level] then
        self.power_view:SetNumber(0)
        return
    end

    -- 获取角色的官职属性
    local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
    local attr = {}
    for k, v in ipairs(office_cfg.level_list[level].attrs) do
        if v.job == prof or v.job == 0 then
            attr[#attr + 1] = v
        end
    end

    local power_value = CommonDataManager.GetAttrSetScore(attr)
    self.power_view:SetNumber(power_value)
end

-- 刷新阶位视图
function OfficeView:FlushPhaseView()
    local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1)
    local data = OfficeData.Instance:GetData()
    local level = data.level
    local phase = data.phase == 0 and 1 or data.phase

    self.node_t_list.img_gz_m.node:loadTexture(ResPath.GetOffice("img_gz_m_" .. prof  .. "_" .. phase)) --刷新阶位名字图片

    if nil == self.phase_num then
        self.phase_num = NumberBar.New()
        self.phase_num:SetRootPath(ResPath.GetOffice("img_gz_lv_"))
        self.phase_num:SetPosition(165, 385)
        -- self.phase_num:GetView():setScale(0.8)
        self.node_t_list.layout_office_1.node:addChild(self.phase_num:GetView(), 10)
    end

    self.phase_num:SetNumber(phase)

    --刷新官职特效
    if phase == 2 then
        self.effect:setPosition(470, 463)
    elseif phase == 3 then
        self.effect:setPosition(470, 473)
    else
        self.effect:setPosition(470, 425)
    end

    if level > 0 then
        local index = office_cfg.level_list[level].icon --获取配置的特效ID
        local path, name = ResPath.GetEffectUiAnimPath(index)
        self.effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.1, false)
    end
end

-- 神鼎特效视图
function OfficeView:CreateEffextView()
    if nil == self.effect then
        local phase = OfficeData.Instance:GetPhase()
        local index = office_cfg.level_list[1].icon --获取配置的特效ID

        local path, name = ResPath.GetEffectUiAnimPath(index)
        self.effect = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, 0.1, false)
        -- self.effect:setVisible(true)
        self.node_t_list.layout_office_1.node:addChild(self.effect, 19)
    end
end

-- 刷新升级按钮视图
function OfficeView:FlushBtnUpView()
    local data = OfficeData.Instance:GetData()

    if data.level == 0 then 
        self.node_t_list.lbl_btn.node:setString(Language.Common.Activate)    
    elseif data.child_level == 5 then
        self.node_t_list.lbl_btn.node:setString("进阶")
        self.node_t_list.lbl_btn.node:setColor(COLOR3B.ORANGE)
    else
        self.node_t_list.lbl_btn.node:setString(Language.Common.Up)
        self.node_t_list.lbl_btn.node:setColor(cc.c3b(0xED, 0xE6, 0xC1))
    end
end

-- 刷新消耗声望卷视图
function OfficeView:FlushVolumeView()
    local level = OfficeData.Instance:GetLevel()

    if nil == office_cfg.level_list[level + 1] then
        self.node_t_list.rich_prompt.node:setVisible(false)
        return
    end
    local item = office_cfg.level_list[level + 1].consume[1] -- 获取声望卷配置
    local item_num = BagData.Instance:GetItemNumInBagById(item.id, nil) --获取背包的声望卷数量
    local bool = item_num >= item.count
    -- 背包的声望卷数量足够升级时,显示绿色,否则显示红色
    item_num = bool and "{color;1eff00;" .. item_num .. "}" or "{color;ff2828;" .. item_num .. "}"

    local text = string.format(Language.Office.Need, item_num, item.count)
    RichTextUtil.ParseRichText(self.node_t_list.rich_prompt.node, text, 18, COLOR3B.DULL_GOLD)
    XUI.RichTextSetCenter(self.node_t_list.rich_prompt.node)

    self.node_t_list.layout_btn_1.remind_eff:setVisible(bool)

    self.is_bullet_window = not bool
end

-- 创建获取官职丹按钮
function OfficeView:CreateGetDanBtn()
    self.text_btn = RichTextUtil.CreateLinkText(Language.Office.GetVolume, 19, COLOR3B.GREEN)
    self.text_btn:setPosition(730, 45)
    self.node_t_list.layout_office_1.node:addChild(self.text_btn, 20)
    XUI.AddClickEventListener(self.text_btn, BindTool.Bind(self.OpenGetVolumeWindow, self), true)
end

-- 刷新星星视图
function OfficeView:FlushStarsView()
    local child_level = OfficeData.Instance:GetChildLevel()

    for i = 1, 5 do
        self.node_t_list["img_office_stars_" .. i].node:setVisible(child_level >= i)
    end
end

-- 刷新加成属性视图
function OfficeView:FlushBonusView()
    local level = OfficeData.Instance:GetLevel()
    local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1)

    -- 获取角色的官职属性,未激活时,显示"未激活"
    local text1 = ""
    if level ~= 0 then
        local attr1 = {}
        for k, v in ipairs(office_cfg.level_list[level].attrs) do
            if v.job == prof or v.job == 0 then
                attr1[#attr1 + 1] = v
            end
        end
        text1 = RoleData.Instance.FormatAttrContent(attr1)
    else
        text1 = Language.Common.NoActivate
    end

    -- 获取角色官职下一级的属性,满级时,显示"已是最高级了",并且升级按钮
    local text2 = ""
    if (level + 1) <= #office_cfg.level_list then
        local attr2 = {}
        for k, v in ipairs(office_cfg.level_list[level + 1].attrs) do
            if v.job == prof or v.job == 0 then
                attr2[#attr2 + 1] = v
            end
        end
        text2 = RoleData.Instance.FormatAttrContent(attr2)
    else
        text2 = Language.Common.AlreadyTopLv
        self.node_t_list.rich_next_bonus.node:setPosition(580, 232)
        self.node_t_list.layout_btn_1.node:setVisible(false)
    end

    RichTextUtil.ParseRichText(self.node_t_list.rich_bonus.node, text1, 18, COLOR3B.DULL_GOLD)
    RichTextUtil.ParseRichText(self.node_t_list.rich_next_bonus.node, text2, 18, COLOR3B.DULL_GOLD)
    self.node_t_list.rich_bonus.node:setVerticalSpace(-2) --设置垂直间隔
    self.node_t_list.rich_next_bonus.node:setVerticalSpace(-2)
end

----------end----------

-- 打开获取官职单窗口
function OfficeView:OpenGetVolumeWindow()
    local item = office_cfg.level_list[1].consume[1] -- 获取声望卷配置

    local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item.id]
    local data = string.format("{reward;0;%d;1}", item.id) .. (ways and ways or "")
    TipCtrl.Instance:OpenBuyTip(data)
end

-- 升级按钮处理程序
function OfficeView:OnClickUPHandler()
    if self.is_bullet_window then
        self:OpenGetVolumeWindow()
    else
        local index = OfficeData.Instance:GetLevel() == 0 and 2 or 3
        OfficeCtrl.Instance:SendOfficeReq(index) 
    end
end

-- 等级改变处理程序
function OfficeView:LevelChangeHandler()
    self:FlushPowerValueView()
    self:FlushBtnUpView()
    self:FlushVolumeView()
    self:FlushStarsView()
    self:FlushBonusView()

    local phase = OfficeData.Instance:GetPhase()
    if self.phase ~= phase then
        self.phase = phase
        self:FlushPhaseView()
    end

    self.door:OpenTheDoor()
end

function OfficeView:OnGetUiNode(node_name)
    if node_name == NodeName.OfficeActBtn then
        return self.door:GetActBtnNode(), true
    end

    return OfficeView.super.OnGetUiNode(self, node_name)
end