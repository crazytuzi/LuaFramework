require("scripts/game/role/luxury_equip/luxury_equip_data")
local LuxuryEquipView = LuxuryEquipView or BaseClass(SubView)

LuxuryEquipView.EquipPos = LuxuryEquipView.EquipPos or {
    { equip_slot = EquipData.EquipSlot.itSubmachineGunPos, cell_col = 3, cell_row = 4.1, },
    { equip_slot = EquipData.EquipSlot.itOpenCarPos, cell_col = 2.5, cell_row = 2, },
    { equip_slot = EquipData.EquipSlot.itAnCrownPos, cell_col = 1, cell_row = 6, },
    { equip_slot = EquipData.EquipSlot.itGoldenSkullPos, cell_col = 1, cell_row = 5, },
    { equip_slot = EquipData.EquipSlot.itGoldChainPos, cell_col = 1, cell_row = 4, },
    { equip_slot = EquipData.EquipSlot.itGoldPipePos, cell_col = 1, cell_row = 3, },
    { equip_slot = EquipData.EquipSlot.itGoldDicePos, cell_col = 1, cell_row = 2, },
    { equip_slot = EquipData.EquipSlot.itGlobeflowerPos, cell_col = 6, cell_row = 6, },
    { equip_slot = EquipData.EquipSlot.itJazzHatPos, cell_col = 6, cell_row = 5, },
    { equip_slot = EquipData.EquipSlot.itRolexPos, cell_col = 6, cell_row = 4, },
    { equip_slot = EquipData.EquipSlot.itDiamondRingPos, cell_col = 6, cell_row = 3, },
    { equip_slot = EquipData.EquipSlot.itGentlemenBootsPos, cell_col = 6, cell_row = 2, },
}

function LuxuryEquipView:__init()
	self.def_index = 1
	self.texture_path_list = {
        'res/xui/role_btn.png',
    }
	self.config_tab = {
		{"role1_ui_cfg", 6, {0}},
	}
	self.def_index = 1
    self.cell_list = {}
end

function LuxuryEquipView:__delete()
   
end

function LuxuryEquipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
        XUI.AddClickEventListener(self.node_t_list.btn_back.node, BindTool.Bind(self.OnClickBackBtn, self))
       --XUI.AddClickEventListener(self.node_t_list.btn_luxury_suit.node, BindTool.Bind(self.OnClickSuit, self))
        self:CreateEquipGrid()
	end
    self:CreateCell()
	-- EventProxy.New(LuxuryEquipData.Instance, self):AddEventListener(LuxuryEquipData.Undefine, BindTool.Bind(self.LuxuryEquipDataChangeCallback, self))
    EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
end

function LuxuryEquipView:ReleaseCallBack()
     if self.cell_list then
        for _, v in pairs(self.cell_list) do
            v:DeleteMe()
        end
        self.cell_list = {}
    end
    if self.skill_cell then
        self.skill_cell:DeleteMe()
        self.skill_cell = nil 
    end
    self.rich_content = nil 
end

function LuxuryEquipView:OpenCallBack()
end

function LuxuryEquipView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end



function LuxuryEquipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function LuxuryEquipView:OnFlush(param_list, index)
    for _, cell in pairs(self.cell_list) do
        if cell then
            cell:SetData(EquipData.Instance:GetEquipDataBySolt(cell:GetIndex()))
        end
    end
   self:SetSkillShow()
end

------------------------------------------------------------------------------------------------------------------------
---
---
function LuxuryEquipView:CreateEquipGrid()
    local cell_size = cc.size(72, 72)
    local col_interval = 12
    local row_interval = 20
    local begin_x = 18
    local begin_y = 10

    for k, v in pairs(LuxuryEquipView.EquipPos) do
        local x = (v.cell_col - 1) * (cell_size.width + col_interval) + begin_x
        local y = (v.cell_row - 1) * (cell_size.height + row_interval) - 10
        local cell = LuxuryEquipView.Cell.New()
        cell:SetIndex(v.equip_slot)
        cell:GetView():setPosition(x, y)
        self.node_t_list.layout_role_equip.node:addChild(cell:GetView(), 99)
        self.cell_list[k] = cell
    end

end
function LuxuryEquipView:CreateCell()
    local ph = self.ph_list.ph_skill_3
    if self.skill_cell == nil then
        self.skill_cell = NewLuxurySkillCell.New()
        self.node_t_list.layout_skill_3.node:addChild(self.skill_cell:GetView(), 99)
        self.skill_cell:GetView():setPosition(ph.x, ph.y)
        XUI.AddClickEventListener(self.skill_cell:GetView(), BindTool.Bind1(self.OpenSkillTip1, self))
    end
end

function LuxuryEquipView:OpenSkillTip1()
    local level_data = EquipData.Instance:GetCurDataByType(5)
    
    local suitlevel = level_data.suitlevel or 0 --未激活状态
    local skill_item_id = SuitPlusConfig[5].list[1].virtual_skill_item_id
    local  skill_level =  0
    if suitlevel > 0 then
        skill_item_id = SuitPlusConfig[5].list[suitlevel].virtual_skill_item_id
        skill_level =  suitlevel
    end
    TipCtrl.Instance:OpenTipSkill(skill_item_id, skill_level, 5, suitlevel)
end


-----------------------------------------------------------------------------------------------------------------------
function LuxuryEquipView:OnClickBackBtn()
    ViewManager.Instance:OpenViewByDef(ViewDef.Role.RoleInfoList.Intro)
end

-- function LuxuryEquipView:OnClickSuit()
--     ViewManager.Instance:OpenViewByDef(ViewDef.LuxuryEquipTip)
-- end

function LuxuryEquipView:OnChangeOneEquip()
    self:OnFlush(self.index)
end

function LuxuryEquipView:SetSkillShow()
    
    -- local   skill_id = SuitPlusConfig[10].list[1].skillid
    -- local   skill_level =  1
    -- local    suitlevel = EquipData.Instance:GetZhiZunSuitLevel()

    local level_data = EquipData.Instance:GetCurDataByType(5)
    
    local suitlevel = level_data.suitlevel or 0 --未激活状态
    local bool = false
    local is_show = "未激活"
    local skill_item_id = SuitPlusConfig[5].list[1].virtual_skill_item_id
    local  skill_level =  1
    if suitlevel > 0 then
        skill_item_id = SuitPlusConfig[5].list[suitlevel].virtual_skill_item_id
        skill_level =  suitlevel
        bool = true
        is_show = "已激活"
    end
    
    local color = bool and COLOR3B.GREEN or COLOR3B.RED
    self.node_t_list.text_had_jihuo3.node:setString(is_show)
    self.node_t_list.text_had_jihuo3.node:setColor(color)
    
    local lv_cfg = VirtualSkillCfg[skill_item_id]
    local desc = lv_cfg.desc or ""
    RichTextUtil.ParseRichText(self.node_t_list.text_desc_shenhao.node,desc, 16)

    local path = ResPath.GetItem(lv_cfg.icon)
    self.skill_cell:SetItemIcon(path)
    self.skill_cell:MakeGray(not bool)

    local name = lv_cfg.name.."   " .. "LV."..skill_level
    self.node_t_list.text_skill_name3.node:setString(name)

    -- local   skill_id = SuitPlusConfig[11].list[1].skillid
    -- local   skill_level =  1
    -- local   suitlevel = EquipData.Instance:GetBazheLevel()
    -- local bool = false
    -- local is_show = "未激活"
    -- if suitlevel > 0 then
    --     skill_id = SuitPlusConfig[11].list[suitlevel].skillid
    --     skill_level =  SuitPlusConfig[11].list[suitlevel].skillLv
    --     bool = true
    --     is_show = "已激活"
    -- end
    -- local path = ResPath.GetSkillIcon("2001_1")
    -- self.skill_cell1:SetItemIcon(path)
    -- self.skill_cell1:MakeGray(not bool)
    -- local lv_cfg = SkillData.GetSkillLvCfg(skill_id, skill_level)
    -- local desc = lv_cfg.desc or ""
    -- local name = "霸者龙气".."   " .. "LV."..skill_level
    -- self.node_t_list.text_skill_name2.node:setString(name)
    -- RichTextUtil.ParseRichText(self.node_t_list.text_desc2.node,desc, 16)
    -- local color = bool and COLOR3B.GREEN or COLOR3B.RED
    -- self.node_t_list.text_had_jihuo2.node:setString(is_show)
    -- self.node_t_list.text_had_jihuo2.node:setColor(color)
    self:SetTextShow()
end

function LuxuryEquipView:SetTextShow()
    if self.rich_content == nil then
        self.rich_content = XUI.CreateRichText(0, 0, 350, 0, false)
        self.node_t_list.scroll_show1.node:addChild(self.rich_content, 100, 100)
    end

    local text = ""
    for k, v in ipairs(HaoZHuangTypeListCfg) do
        local suittype = HaoZHuangTypeListCfg[k]
        local level_data = EquipData.Instance:GetCurDataByType(suittype)
            
        local suitlevel = level_data.suitlevel or 0 --未激活状态

        local config = SuitPlusConfig[suittype]
                    
        local text1 =  LuxuryEquipTipData.Instance:GetText(suittype, suitlevel, config, k, false, false) 
        text = text .. text1 .. "\n"
    end

   --  local index = 1
 
   --  --RichTextUtil.ParseRichText(self.node_t_list.rich_cur_text.node, text, 20)
   -- -- XUI.SetRichTextVerticalSpace(self.node_t_list.rich_cur_text.node,space)

   -- local index = 2 
   -- local suittype = HaoZHuangTypeListCfg[index]
   -- local level_data = EquipData.Instance:GetCurDataByType(suittype)
   -- local suitlevel = level_data.suitlevel or 0 --未激活状态
   -- local config = SuitPlusConfig[suittype]
   -- local text2 = LuxuryEquipTipData.Instance:GetText(suittype, suitlevel, config, index, false, false)

   -- local index = 3
   -- local suittype = HaoZHuangTypeListCfg[index]
   -- local level_data = EquipData.Instance:GetCurDataByType(suittype)
   -- local suitlevel = level_data.suitlevel or 0 --未激活状态
   -- local config = SuitPlusConfig[suittype]
   -- local text3 = LuxuryEquipTipData.Instance:GetText(suittype, suitlevel, config, index, false, false)

   --  local text = text1.."\n".. text2 .. "\n" .. text3


    RichTextUtil.ParseRichText(self.rich_content,text, 18)
    self.rich_content:refreshView()

    local scroll_size = self.node_t_list.scroll_show1.node:getContentSize()
    local inner_h = math.max(self.rich_content:getInnerContainerSize().height + 20, scroll_size.height)
    self.node_t_list.scroll_show1.node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
    self.rich_content:setPosition(scroll_size.width / 2, inner_h)

    -- 默认跳到顶端
    self.node_t_list.scroll_show1.node:getInnerContainer():setPositionY(scroll_size.height - inner_h)

end

NewLuxurySkillCell = NewLuxurySkillCell or BaseClass(BaseCell)
function NewLuxurySkillCell:SetAddClickEventListener( ... )
    -- body
end
------------------------------------------------------------------------------------------------------------------------
LuxuryEquipView.Cell = LuxuryEquipView.Cell or BaseClass(BaseRender)
local Cell = LuxuryEquipView.Cell
function Cell:__init()

end

function Cell:__delete()
    --if self.cell then
    --    self.cell:DeleteMe()
    --    self.cell = nil
    --end
    if self.item_effect then
        self.item_effect:setStop()
        self.item_effect = nil
    end
end

function Cell:CreateChild()
    --local ui_config = { bg = ResPath.GetCommon("cell_100"),
    --                    bg_ta = ResPath.GetRole("luxury_equip_cell_bg")}
    --self.cell = BaseCell.New()
   -- BaseRender.CreateChild(self)
    local bg = nil
    local off_x = 0
    local off_y = 0
    if EquipData.EquipSlot.itSubmachineGunPos == self.index then
        bg = XUI.CreateImageViewScale9(76,113, 152, 186, ResPath.GetCommon("cell_100"), true, cc.rect(10, 10, 10, 10))
        off_y = 40
    elseif EquipData.EquipSlot.itOpenCarPos == self.index then
        bg = XUI.CreateImageViewScale9(124,99, 248, 158, ResPath.GetCommon("cell_100"), true, cc.rect(10, 10, 10, 10))
        off_y = 40
    else
        bg = XUI.CreateImageView(BaseCell.SIZE / 2,BaseCell.SIZE / 2, ResPath.GetCommon("cell_100"))
    end
    self:SetContentSize(bg:getContentSize().width, bg:getContentSize().height)
    self.view:addChild(bg)
    -- local bg2 = XUI.CreateImageView(self.view:getContentSize().width / 2 + off_x, self.view:getContentSize().height / 2 + off_y, ResPath.GetRole("luxury_equip_cell_bg"))
    -- self.view:addChild(bg2)

    self:AddClickEventListener(BindTool.Bind(self.OnCellClick, self))

    --  if self.item_effect == nil then
    --     --local ph = self.ph_list.ph_effect
    --     self.item_effect = AnimateSprite:create()
    --     --self.item_effect:setPosition(ph.x, ph.y )
    --     self.view:addChild(self.effect_show, 99)
    -- end
end

-- function Cell:SetData(data)
--     self.data = data
--    self:Flush()
-- end

function Cell:OnCellClick()
    if self.data then
        if EquipData.EquipSlot.itSubmachineGunPos == self.index or EquipData.EquipSlot.itOpenCarPos == self.index then
            TipCtrl.Instance:OpenItem(self.data, EquipTip.FROM_GUN_OR_CAR, {pos = self.index, item_id = self.data.item_id})
        else
            TipCtrl.Instance:OpenItem(self.data, EquipTip.FROM_BAG_EQUIP,{pos = self.index, item_id = self.data.item_id})
        end
    else
       -- if EquipData.EquipSlot.itSubmachineGunPos == self.index or EquipData.EquipSlot.itOpenCarPos == self.index then
        if ViewManager.Instance:CanOpen(ViewDef.CrossBoss.LuxuryEquipCompose) then
             ViewManager.Instance:OpenViewByDef(ViewDef.CrossBoss.LuxuryEquipCompose)
        else
            SysMsgCtrl.Instance:FloatingTopRightText(ViewDef.CrossBoss.LuxuryEquipCompose.v_open_cond and GameCond[ViewDef.CrossBoss.LuxuryEquipCompose.v_open_cond].Tip or "策划需在cond配置")
        end
            -- ViewManager.Instance:FlushViewByDef(ViewDef.LuxuryEquipUpgrade, 0, "param", {pos = self.index, item_id = 0})
        -- else
        --     --TipCtrl.Instance:OpenItem(self.data, EquipTip.FROM_BAG_EQUIP)
        -- end
        -- return
    end
end


--function Cell:SetScaleX(scale)
--    if nil ~= self.cell.bg_img then
--        self.cell.bg_img:setScaleX(scale)
--    end
--end
--
--function Cell:SetScaleY()
--    if nil ~= self.cell.bg_img then
--        self.cell.bg_img:setScaleY(scale)
--    end
--end 
function Cell:OnFlush()
    local eff_id = 0
   --local item_type =  EquipData.Instance:GetTypeByEquipSlot(self.index)
     eff_id = EquipData.Instance:GetLuxuryEquipEffectId(self.data and self.data.item_id  or 0, self.index)
    
     local bool = false
    if self.data then
        bool = true
       
    end

   --  self.item_effect:SetScale(0.8)

    -- local size = self.view:getContentSize()
    -- self.effect_show:setPosition(size.width/2, size.height/2 - 15)

    -- local  eff_id = EquipData.Instance:GetLuxuryEquipEffectId(self.data and self.data.item_id  or 0,self.index)

    -- local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
    -- self.item_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

    --  XUI.MakeGrey(self.item_effect, not bool)

    if eff_id > 0 and nil == self.item_effect then
        self.item_effect = RenderUnit.CreateEffect(eff_id, self:GetView(), 99, nil, nil,
                self.view:getContentSize().width / 2, self.view:getContentSize().height / 2 - 10)
        --CommonAction.ShowJumpAction(self.item_effect, 4, 1.5)
        self.item_effect:setScale(0.8)
        self.item_effect.SetAnimateRes = function(node, res_id)
            if nil ~= node.animate_res_id and node.animate_res_id == res_id then
                return
            end

            node.animate_res_id = res_id
            if res_id == 0 then
                node:setStop()
                return
            end

            local anim_path, anim_name = ResPath.GetEffectUiAnimPath(res_id)
            node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
        end
        XUI.MakeGrey(self.item_effect, not bool)
    elseif nil ~= self.item_effect then
        self.item_effect:SetAnimateRes(eff_id)
        self.item_effect:setVisible(eff_id > 0)
       
    end

    XUI.MakeGrey(self.item_effect, not bool)
end
return LuxuryEquipView