BossTempleView = BossTempleView or BaseClass(XuiBaseView)

function BossTempleView:__init()
	self.texture_path_list[1] = 'res/xui/boss.png'
	self.config_tab = {
		{"boss_temp_ui_cfg", 1, {0}},
	}
	self.cur_index = 1
end

function BossTempleView:__delete()
end

function BossTempleView:ReleaseCallBack()
	if self.boss_temp_list then
		self.boss_temp_list:DeleteMe()
		self.boss_temp_list = nil 
	end
	if self.reward_cell then
		for k,v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
end

function BossTempleView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateList()
		self:CreateCells()
		self.node_t_list.btn_enter_carbon.node:addClickEventListener(BindTool.Bind(self.OnEnterMayaScene, self))
		--self.node_t_list.btn_tip.node:addClickEventListener(BindTool.Bind(self.OnOpenBossTempleTipsView, self))
	end
end

function BossTempleView:OpenCallBack()

end

function BossTempleView:CloseCallBack()
	
end

function BossTempleView:ShowIndexCallBack(index)
	self:Flush(index)
end

function BossTempleView:OnFlush(param_t, index)
	local cur_data = BossData.Instance:GetMaYaBossInfo()
	self.boss_temp_list:SetDataList(cur_data)
	self.boss_temp_list:SelectIndex(1)
	self:FlushView()
end

function BossTempleView:CreateList()
	if nil == self.boss_temp_list then
		local ph = self.ph_list.ph_list
		self.boss_temp_list = ListView.New()
		self.boss_temp_list:Create(ph.x +38, ph.y+28, ph.w , ph.h, nil, BossMaYaRender, nil, nil, self.ph_list.ph_list_item)
		self.boss_temp_list:GetView():setAnchorPoint(0, 0)
		--self.boss_temp_list:SetMargin(2)
		self.boss_temp_list:SetItemsInterval(10)
		self.boss_temp_list:SetJumpDirection(ListView.Top)
		self.boss_temp_list:SetSelectCallBack(BindTool.Bind(self.OnBossSclectCallBack, self))
		self.node_t_list.layout_boss_temple.node:addChild(self.boss_temp_list:GetView(), 100)
	end	
end

function BossTempleView:OnBossSclectCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	self.select_data = item:GetData()
	self:FlushView()
end

function BossTempleView:FlushView()
	local cur_data = BossData.Instance:GetMaYaBossInfo()
	local select_data = self.select_data or cur_data[self.cur_index]
	local data = BossDropShowConfig[select_data.boss_reward_boss] or {}
	local reward_data = BossData.Instance:GetMyProfReward(data) or {}
	for k, v in pairs(reward_data) do
		if self.reward_cell[k] ~= nil then
			self.reward_cell[k]:SetData(v)
		end
	end
	local consume_count = select_data.enterConsume.count
	local consume_config = ItemData.Instance:GetItemConfig(select_data.enterConsume.id)
	local num = ItemData.Instance:GetItemNumInBagById(select_data.enterConsume.id)
	local color = "ff0000"
	if num >= consume_count then
		color = "00ff00"
	end
	if consume_config == nil then return end
	local name = consume_config.name
	local txt = string.format(Language.Boss.Consume_1, color, name, consume_count)
	RichTextUtil.ParseRichText(self.node_t_list.txt_consume.node, txt, 22)
	local txt = ""
	if select_data.enterLevelLimit[1] == 0 then
		txt = string.format(Language.Role.XXJi, select_data.enterLevelLimit[2])
	else
		txt = string.format(Language.Equipment.Need_Level, select_data.enterLevelLimit[1])
	end
	self.node_t_list.txt_consume_level.node:setString(txt)
	local pos = self.select_data and self.select_data.pos or self.cur_index
	local cur_txt = Language.Boss.MaYaRreshTiem[pos] or ""
	self.node_t_list.txt_time.node:setString(cur_txt)
end

function BossTempleView:OnEnterMayaScene()
	local pos = self.select_data and self.select_data.pos or self.cur_index
	BossCtrl.Instance:SendEnterMaYaTempleReq(pos)
end

-- function BossTempleView:OnOpenBossTempleTipsView()
-- 	DescTip.Instance:SetContent(Language.Boss.MaYaDescContent, Language.Boss.MaYaDescTitle)
-- end
function BossTempleView:CreateCells()
	self.reward_cell = {}
	for i = 1, 6 do
		local ph = self.ph_list.ph_cell
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 85*(i-1), ph.y)
		self.node_t_list["layout_boss_temple"].node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end

BossMaYaRender = BossMaYaRender or BaseClass(BaseRender)
function BossMaYaRender:__init()

end

function BossMaYaRender:__delete()	
end

function BossMaYaRender:OnFlush()
	if self.data == nil then return end
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	self.node_tree.bg_name.node:loadTexture(ResPath.GetBoss("scene_name_"..self.data.pos))
	self.node_tree.img_bg.node:loadTexture(ResPath.GetBigPainting("maya_bg_"..self.data.pos, true))
	--ResPath.GetBigPainting(name, true)
end

function BossMaYaRender:CreateSelectEffect()
	if nil == self.node_tree.img_bg then
		self.cache_select = true
		return
	end
	local size =self.node_tree.img_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width + 20,size.height+20,ResPath.GetCommon("img9_173"), true , cc.rect(20,19,21,17))
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
end