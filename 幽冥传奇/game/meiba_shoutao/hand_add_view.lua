
local HandAddView = HandAddView or BaseClass(SubView)
-- local HandAddItemRender = HandAddItemRender or BaseClass(BaseRender)
-- HandAddCtrl.Instance
-- HandAddData.Instance

-- delete obj
--	if nil ~= self.obj then
--		self.obj:DeleteMe()
--	end
--	self.obj = nil

Language.Hand = Language.Hand or {}
Language.Hand.GoCompose = "前往打造"
Language.Hand.MoreTip = "投入个数应少于%s个"
Language.Hand.NoneTip = "需穿戴装备才可增幅"
Language.Hand.NoneTip2 = "需投入更低级的装备"

function HandAddView:__init()
	self.def_index = 1
	self.texture_path_list = {'res/xui/meiba_shoutao.png'}
	self.config_tab = {
		{"meiba_shoutao_ui_cfg", 1, {0}},
	}
	self.def_index = 1
    self.select_index = 1

    self.need_del_objs = {}
end

function HandAddView:__delete()
end

function HandAddView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then	
	end

	local goadd_rich_link = RichTextUtil.CreateLinkText(Language.Hand.GoCompose, 20, COLOR3B.GREEN, nil, true)
	goadd_rich_link:setPosition(500, 60)
	self.node_t_list.layout_add.node:addChild(goadd_rich_link, 999)
	XUI.AddClickEventListener(goadd_rich_link, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.ReXueFuzhuang.MeiBaShouTao)
	end)

    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, function ()
        self:Flush()
    end)
    EventProxy.New(MeiBaShouTaoData.Instance, self):AddEventListener(MeiBaShouTaoData.HAND_ADD_CHANGE, BindTool.Bind(self.Flush, self))

    XUI.AddClickEventListener(self.node_t_list.btn_add.node, function ()
        if nil == EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itGlovePos) then 
            SysMsgCtrl.Instance:FloatingTopRightText(Language.Hand.NoneTip)
            return
        end
        local hand_list = {}
        for i,v in ipairs(self.streng_data_list) do
            table.insert(hand_list, v.series)
        end
        MeiBaShouTaoCtrl.SendHandAdd(hand_list)
    end, true)
    -- EventProxy.New(HandAddData.Instance, self):AddEventListener(HandAddData.Undefine, BindTool.Bind(self.HandAddDataChangeCallback, self))

    self:CreateSelectCell()
    -- self:CreateGridView()
    self:CreateBagView()
    self:CreateProg()
end

function HandAddView:ReleaseCallBack()
    for k, v in pairs(self.need_del_objs) do
        v:DeleteMe()
    end
    self.need_del_objs = {}
end

function HandAddView:OpenCallBack()
end

function HandAddView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HandAddView:ShowIndexCallBack(index)
	self:Flush(index)
end

function HandAddView:CreateGridView()
    local ph = self.ph_list.ph_list
    self.slot_grid = BaseGrid.New()
    self.need_del_objs[#self.need_del_objs + 1] = self.slot_grid
    --self.slot_grid:SetGridName(GRID_TYPE_BAG)
    --self.slot_grid:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))

    local grid_node = self.slot_grid:CreateCells({ w=ph.w, h=ph.h, cell_count=12, col=4, row=1, itemRender = HoroscopeCell,
                                                   direction = ScrollDir.Horizontal, })
    grid_node:setPosition(ph.x, ph.y)
    self.slot_grid:SetSelectCallBack(BindTool.Bind(self.OnClickGrid, self))
    self.slot_grid:SelectCellByIndex(0)
    self.node_t_list.layout_list.node:addChild(grid_node, 100)
    self.slot_grid:SetDataList(HoroscopeData.Instance:GetAllConstellationData())
end

function HandAddView:CreateBagView()
    local ph = self.ph_list.ph_bag
    self.bag_grid = BaseGrid.New()
    self.need_del_objs[#self.need_del_objs + 1] = self.bag_grid
    local grid_node =  self.bag_grid:CreateCells({ w=ph.w, h=ph.h, cell_count=110, col=4, row=6, itemRender = HandBagItemRender,
                                                   direction = ScrollDir.Horizontal, ui_config = self.ph_list.ph_item})
    self.bag_grid:SetSelectCallBack(BindTool.Bind(self.OnClickRenderHandle, self))
    self.node_t_list.layout_bag.node:addChild(grid_node, 100)

    local list = BagData.Instance:GetBagHandList()
    if not list[0] and list[1] then
        list[0] = table.remove(list, 1)
    end
    self.bag_grid:SetDataList(list)
end

function HandAddView:OnClickRenderHandle(cell)
    if nil == cell then
        return
    end

    local cell_data = cell:GetData()
    if nil == cell_data then return end

    if nil == EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itGlovePos) then 
        SysMsgCtrl.Instance:FloatingTopRightText(Language.Hand.NoneTip)
        return
    end


    if ItemData.Instance:GetItemScoreByData(cell_data) > ItemData.Instance:GetItemScoreByData(EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itGlovePos)) then 
        SysMsgCtrl.Instance:FloatingTopRightText(Language.Hand.NoneTip2)
        return
    end

    if #self.streng_data_list >= ThanosGloveEquipConfig.IncreaseCfg.maxEquipCount then
        if cell_data.is_put_in == 1 then
            cell_data.is_put_in = 0
        else
            SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.Hand.MoreTip, ThanosGloveEquipConfig.IncreaseCfg.maxEquipCount))
        end
    else
        if cell_data.is_put_in and cell_data.is_put_in == 1 then
            cell_data.is_put_in = 0
        else
            cell_data.is_put_in = 1
        end
    end


    cell:SetData(cell_data)
    cell:Flush()
    self:Flush()
end

function HandAddView:CreateSelectCell()
    self.select_cell = BaseCell.New()
    self.need_del_objs[#self.need_del_objs + 1]= self.select_cell
    local ph = self.ph_list.ph_cell_select
    self.select_cell:SetPosition(ph.x, ph.y)
    self.node_t_list.layout_add.node:addChild(self.select_cell:GetView(), 100)
end

function HandAddView:CreateProg()
    self.progress = ProgressBar.New()
    self.need_del_objs[#self.need_del_objs + 1]= self.progress
    self.progress:SetView(self.node_t_list.prog9_val.node)
    self.progress:SetTotalTime(0)
    self.progress:SetPercent(0)
end

-- 刷新槽位属性视图
function HandAddView:OnFlushAttr(cur_level, next_level)
        local cur_attrs_data = HoroscopeData.GetAttrTypeValueFormat(self.select_index, cur_level)
        local next_attrs_data = HoroscopeData.GetAttrTypeValueFormat(self.select_index, next_level)

        -- 获取槽位属性,0级,显示"无"
        local text1 = ""
        if cur_level ~= 0 then
            local attr1 = {}
            for k, v in ipairs(cur_attrs_data) do
                attr1[#attr1 + 1] = v
            end
            local color = {
                type_str_color = "9c9181",
                value_str_color = "cdced0",
            }
            text1 = RoleData.Instance.FormatAttrContent(attr1, color)
        else
            text1 = Language.Common.No
        end

        -- 获取下一级的属性,满级时,显示"已是最高级了"
        local text2 = ""
    if next_level ~= 0 then
        if  next_level <= #(HoroscopeData.GetSlotAttrCfg(self.select_index)) then
            local attr2 = {}
            for k, v in ipairs(next_attrs_data) do
                attr2[#attr2 + 1] = v
            end
            local color = {
                type_str_color = "9c9181",
                value_str_color = "1ec449",
            }
            text2 = RoleData.Instance.FormatAttrContent(attr2,color)
        else
            text2 = Language.Common.AlreadyTopLv
            --self.node_t_list.rich_next_bonus.node:setPosition(580, 232)
            --self.node_t_list.layout_btn_1.node:setVisible(false)
        end
    else
        text2 = Language.Common.No
    end


        RichTextUtil.ParseRichText(self.node_t_list.rich_attr1.node, text1, 18, COLOR3B.DULL_GOLD)
        RichTextUtil.ParseRichText(self.node_t_list.rich_attr2.node, text2, 18, COLOR3B.DULL_GOLD)
        --self.node_t_list.rich_attr1.node:setVerticalSpace(-2) --设置垂直间隔
        --self.node_t_list.rich_attr2.node:setVerticalSpace(-2)
end

function HandAddView:OnFlush(param_list, index)
    local curr_lv_info = MeiBaShouTaoData.Instance:GetAddData()
    self.node_t_list.lbl_cur_level.node:setString(curr_lv_info.level)

    local list = BagData.Instance:GetBagHandList()
    -- 返回true时 a 排在 b 前面
    table.sort(list, function (a, b)
        if a == nil or a == b then 
            return false 
        end 
        return a.item_id < b.item_id
    end )
    if not list[0] and list[1] then
        list[0] = table.remove(list, 1)
    end
    self.bag_grid:SetDataList(list)

    self.select_cell:SetData(EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itGlovePos))
    self.select_cell:SetRightTopNumText(MeiBaShouTaoData.Instance:GetAddData().level, COLOR3B.GREEN)

    local item_list = self.bag_grid:GetAllCell()
    local exp = curr_lv_info.exp
    self.streng_data_list = {}
    for _, v in pairs(item_list) do
        local cell_data = v:GetData()
        if cell_data and 1 == cell_data.is_put_in then
            local consume_conf = MeiBaShouTaoData.GetConsumeConf(cell_data.item_id)
            exp = exp + consume_conf
            self.streng_data_list[#self.streng_data_list + 1] = {
                count = cell_data.num,
                series = cell_data.series,}
        end
    end
    local up_cfg = MeiBaShouTaoData.GetUpCfg()
    if nil == up_cfg[curr_lv_info.level + 1] or exp > up_cfg[curr_lv_info.level + 1].needEnergy then
        self.progress:SetPercent(100)
    else
        self.progress:SetPercent(exp / up_cfg[curr_lv_info.level + 1].needEnergy * 100)
    end
    self.node_t_list.lbl_fire_prog.node:setString("")


    local next_level = curr_lv_info.level
    local next_e = 0
    for i = curr_lv_info.level + 1, #up_cfg do
        next_e = next_e + up_cfg[i].needEnergy
        if exp < next_e then
            next_level = i - 1
            break
        else
            next_level = i
        end
    end
    self.node_t_list.lbl_next_level.node:setString(next_level)
    --up_cfg.exp
    self:OnFlushAttr(curr_lv_info.level, next_level)
    --self:FlushPowerValueView()
end

----------------------------------------------------
-- 背包选择itemRender
----------------------------------------------------
HandBagItemRender = HandBagItemRender or BaseClass(BaseRender)
function HandBagItemRender:__init(index)
    self.index = index
    self:AddClickEventListener()
end

function HandBagItemRender:__delete()
    if nil ~= self.item_cell then
        self.item_cell:DeleteMe()
        self.item_cell = nil
    end
end

function HandBagItemRender:CreateChild()
    BaseRender.CreateChild(self)

    self.item_cell = BaseCell.New()
    --self.item_cell.name = GRID_TYPE_RECYCLE_BAG

    self.item_cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
    self.item_cell:GetView():setAnchorPoint(0.5, 0.5)
    self.item_cell:GetView():setTouchEnabled(false)
    self.view:addChild(self.item_cell:GetView())
    
end

function HandBagItemRender:OnFlush()
    if nil == self.data then
        self.item_cell:SetData(nil)
        if nil ~= self.img_put_in then
            self.img_put_in:setVisible(false)
        end
        return
    end
    if nil ~= self.item_cell then
        self.item_cell:SetData(self.data)
    end

    if nil == self.img_put_in then
        self.img_put_in = XUI.CreateImageView(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y, ResPath.GetCommon("common_add"), true)
        --self.img_put_in:setTouchEnabled(true)
        self.view:addChild(self.img_put_in, 1)
    end

    if 1 == self.data.is_put_in then
        self.img_put_in:setVisible(true)
    else
        self.img_put_in:setVisible(false)
    end

    self.item_cell:MakeGray(ItemData.Instance:GetItemScoreByData(self.data) > ItemData.Instance:GetItemScoreByData(EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itGlovePos)))
end

function HandBagItemRender:CreateSelectEffect()

end

return HandAddView