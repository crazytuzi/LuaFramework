BaoBaoAptitudeView = BaoBaoAptitudeView or BaseClass(BaseRender)

function BaoBaoAptitudeView:__init(instance)
end

function BaoBaoAptitudeView:__delete()
	self.cur_level = nil
	self.capacity = nil
	self.name = nil
	self.stuff1 = nil
	self.stuff2 = nil
	self.stuff3 = nil
	self.stuff4 = nil
	self.up_btn_gray = nil
	self.life = nil
	self.attack = nil
	self.defence = nil
	self.next_life = nil
	self.next_attack = nil
	self.next_defence = nil
	self.upgrade = nil
	self.attr_content = nil

	if self.stuff_list ~= nil then
		for k,v in pairs(self.stuff_list) do
			v:DeleteMe()
		end

		self.stuff_list = nil
	end

	for k,v in pairs(self.cell_list) do
        v:DeleteMe()
    end
    self.cell_list = {}
 
	--self.mother_view = nil
end

-- function BaoBaoAptitudeView:ReturnClick()
-- 		self.mother_view:OpenZizhiClick(false)
-- end

function BaoBaoAptitudeView:LoadCallBack()
	--self.mother_view = mother_view
	self:ListenEvent("UpGrade", BindTool.Bind(self.UpGradeClick, self))

	self.cur_level = self:FindVariable("CurLevel")
	self.capacity = self:FindVariable("Cap")
	self.name = self:FindVariable("name")
	self.stuff1 = self:FindVariable("Stuff1")
	self.stuff2 = self:FindVariable("Stuff2")
	self.stuff3 = self:FindVariable("Stuff3")
	self.stuff4 = self:FindVariable("Stuff4")
	self.up_btn_gray = self:FindVariable("UpBtnGray")
	self.life = self:FindVariable("Life")
	self.attack = self:FindVariable("Attack")
	self.defence = self:FindVariable("Defence")
	self.next_life = self:FindVariable("NextLife")
	self.next_attack = self:FindVariable("NextAttack")
	self.next_defence = self:FindVariable("NextDefence")
	self.upgrade = self:FindVariable("UpGrade")
	self.stuff_list = {}
	for i = 1, 4 do
		self.stuff_list[i] = ItemCell.New()
		self.stuff_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end

	self.attr_content = self:FindObj("AptitudeList")
    self.cell_list = {}
    self.list_view_delegate = self.attr_content.list_simple_delegate
    self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
    self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function BaoBaoAptitudeView:UpGradeClick()
	local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
	if selected_baby_index then
		BaobaoCtrl.SendUpBabyReq(selected_baby_index - 1)
	end
end

function BaoBaoAptitudeView:GetNumberOfCells()
    local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then return end

	local level = 0
	if baby_info.level == 0 then
		level = 1
	else
		level = baby_info.level
	end
    local cur_attr = BaobaoData.Instance:GetBabyLevelAttribute(baby_info.baby_id, level)
    local count = 0
    for k,v in pairs(cur_attr) do 
    	if v > 0 then
    		count = count + 1
    	end
    end
    return count
end

function BaoBaoAptitudeView:RefreshView(cell,data_index)
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then return end

	data_index = data_index +1 
    local attr_cell = self.cell_list[cell]
    if nil == attr_cell then
        attr_cell = BaobaoAttrCell.New(cell.gameObject)
        self.cell_list[cell] = attr_cell
    end
    local attribute = CommonStruct.Attribute()
    local cur_attr = BaobaoData.Instance:GetAptitudeCfg(baby_info.baby_id, baby_info.level)
    attr_cell:SetData(cur_attr[data_index])
end

function BaoBaoAptitudeView:OnFlush(param_t)
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info or next(baby_info) == nil then return end

	local next_level = baby_info.level >= GameEnum.BABY_MAX_LEVEL and GameEnum.BABY_MAX_LEVEL or baby_info.level + 1
	self.cur_level:SetValue(baby_info.level)
	local cur_attr = BaobaoData.Instance:GetBabyLevelAttribute(baby_info.baby_id, baby_info.level)
	local next_attr = BaobaoData.Instance:GetBabyLevelAttribute(baby_info.baby_id, next_level)
	self.capacity:SetValue(CommonDataManager.GetCapability(cur_attr))
	local stuff_data = BaobaoData.Instance:GetGridUpgradeStuffDataList() or {}
	self.name:SetValue(ToColorStr(baby_info.baby_name, BAOBAO_COLOR[baby_info.baby_id + 1]))

	if self.stuff_list ~= nil then
		for i = 1, 4 do
			if stuff_data[i - 1] and self.stuff_list[i] ~= nil then
				local data = stuff_data[i - 1]
				self.stuff_list[i]:SetData(data)
				local stuff_num = ItemData.Instance:GetItemNumInBagById(data.item_id)
				local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
				local baby_index_info = BaobaoData.Instance:GetBabyInfo(selected_baby_index)
				if nil == baby_index_info then return end
				if baby_index_info.level >= GameEnum.BABY_MAX_LEVEL then
					self["stuff" .. i]:SetValue("")
					self.up_btn_gray:SetValue(false)
					self.upgrade:SetValue(string.format(Language.Marriage.UpGrade[2]))
				else
					local color = stuff_num >= data.nedd_stuff_num and "#ffe500" or "#ff0000" 
					self["stuff" .. i]:SetValue("<color=" .. color .. ">" .. stuff_num .. "</color>".." / ".. data.nedd_stuff_num)
					self.up_btn_gray:SetValue(true)
			
					self.upgrade:SetValue(string.format(Language.Marriage.UpGrade[1]))
				end
			end
		end
	end
	self.attr_content.scroller:RefreshAndReloadActiveCellViews(true)
end

--------------------------------------------AttrCell---------------------------------------------------------------
BaobaoAttrCell = BaobaoAttrCell or BaseClass(BaseCell)

function BaobaoAttrCell:__init()
    self.cur_attr = self:FindVariable("cur_attr")
    self.next_attr = self:FindVariable("next_attr")
    --self.attr_icon = self:FindVariable("attr_icon")
    self.next_icon = self:FindVariable("next_icon")
end

function BaobaoAttrCell:FlushAttr()
    self.cur_attr:SetValue(Language.Common.AttrName2[self.data.name].."：".."<size=22>"..self.data.cur_value.."</size>")
    if self.data.next_value > 0 then
   		self.next_attr:SetValue("<size=22>"..self.data.next_value.."</size>")
   	end
    --self.attr_icon:SetAsset(ResPath.GetBabyImage(self.data.name)) 
    local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then return end

    local cur_level = baby_info.level
    self.next_icon:SetValue(cur_level ~= BaobaoData.Instance:GetMaxBabyUpleveCfgLength())
end

function BaobaoAttrCell:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

    self:FlushAttr()
end