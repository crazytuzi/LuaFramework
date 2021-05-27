local BrowseXingHun  = BaseClass(SubView)
function BrowseXingHun:__init( ... )
	-- self.texture_path_list = {
	-- 	'res/xui/equipbg.png',
	-- 	'res/xui/rexue.png',
	-- 
	self.texture_path_list = {
        'res/xui/horoscope.png',
    }
	self.config_tab = {
		--{"chuanshi_ui_cfg", 1, {0}},
		{"browse_ui_cfg", 4, {0}},
		-- {"role1_ui_cfg", 8, {0}},
	}
end

function BrowseXingHun:__delete( ... )
	-- body
end


function BrowseXingHun:ReleaseCallBack( ... )
	if self.cell_list ~= nil then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
end

function BrowseXingHun:LoadCallBack( ... )
	self:CreateHoroscope()
end

function BrowseXingHun:OpenCallBack( ... )
	-- body
end


function BrowseXingHun:CloseCallBack( ... )
	-- body
end

function BrowseXingHun:OnFlush()
	-- for k, v in pairs(self.cell_list) do
	-- 	print(">>>>>>")
	-- 	v:SetData(BrowseData.Instance:GetXinghunData(k))
	-- end
end

function BrowseXingHun:ShowIndexCallBack(index)
	self:FlushIndex(index)

end


function BrowseXingHun:CreateHoroscope()
	self.cell_list = {}
    for i = 0, 11 do
        local ph = self.ph_list["ph_cell_" .. i + 1 ]
        local cell = self:CreateCellRender(i, ph, cur_data)
        cell:SetIndex(i)
        cell:AddClickEventListener(BindTool.Bind1(self.OnClickEquipCell, self), true)
        -- table.insert(self.equip_cell, cell)
       
        self.cell_list[i] = cell
    end
    for k, v in pairs(self.cell_list) do
		v:SetData(BrowseData.Instance:GetXinghunData(k))
	end
end

function BrowseXingHun:CreateCellRender(i, ph, cur_data)
    local cell = BrowseXingHunCellRender.New()
   local render_ph = self.ph_list.ph_item_render 
    cell:SetUiConfig(render_ph, true)
    cell:GetView():setPosition(ph.x+3, ph.y-1)
    cell:GetView():setAnchorPoint(0.5, 0.5)
    self.node_t_list.layout_horoscope1.node:addChild(cell:GetView(), 99)
    if cur_data then
        cell:SetData(cur_data)
    end
    return cell
end


function BrowseXingHun:OnClickEquipCell(cell)
	if cell == nil or cell:GetData() == nil then
		return
	end
	local slot = cell:GetIndex()
	TipCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_BROWSE_HOROLOPE, {horoscope_slot = slot})
end


BrowseXingHunCellRender = BrowseXingHunCellRender or BaseClass(BaseRender)

function BrowseXingHunCellRender:__init( ... )
	-- body
end

function BrowseXingHunCellRender:__delete( ... )
	-- body
end

function BrowseXingHunCellRender:CreateChild( ... )
	BaseRender.CreateChild(self)
end

function BrowseXingHunCellRender:OnFlush( ... )
	 self:Clear()
    if self.data == nil then 
        return
    end
    self.node_tree.img_bg1.node:setVisible(false)
    local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
    local icon = ResPath.GetItem(item_cfg.icon)
    self.node_tree.img_icon.node:setVisible(true)
    self.node_tree.img_icon.node:loadTexture(icon)
end

function BrowseXingHunCellRender:Clear()
    self.node_tree.text_strength_level.node:setString("")
    self.node_tree.img_icon.node:setVisible(false)
    self.node_tree.img_bg1.node:setVisible(true)
    self.node_tree.img_bg1.node:loadTexture(ResPath.Horoscope("constellatory_bg_" .. self.index + 1))

end

return BrowseXingHun
