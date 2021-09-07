CheckSpiritView = CheckSpiritView or BaseClass(BaseRender)

local FIX_SHOW_TIME = 8
function CheckSpiritView:__init(instance)
	self.item_index = 1
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.shengming = self:FindVariable("shengming")
	self.kangbao = self:FindVariable("kangbao")
	self.zhan_li = self:FindVariable("zhan_li")
	self.name_text = self:FindVariable("name_text")
	self.show_name = self:FindVariable("show_name")
	self.talent_text_list = {}
	for i=1,3 do
		self.talent_text_list[i] = {}
		self.talent_text_list[i].name = self:FindVariable("talent_name_" .. i)
		self.talent_text_list[i].value = self:FindVariable("talent_value_" .. i)
		self.talent_text_list[i].show_content = self:FindVariable("show_content_" .. i)
	end
	self.item_list = {}
	for i=1,4 do
		self.item_list[i] = {}
		local handler = function()
			local item_id = self.item_list[i].item_cell:GetData().item_id
			if item_id ~= 0 then
				self.item_index = i
				self:SetShowId(self.item_list[i].item_cell:GetData().item_id)
			end
			self:FlushItemHl()
		end
		self.item_list[i].item_cell = ItemCell.New(self:FindObj("item_" .. i))
		self.item_list[i].show_chuzhan = self:FindVariable("show_chuzhan_" .. i)
		self.item_list[i].item_cell:ListenClick(handler)
	end
	self.show_spirit_id = 0
end

function CheckSpiritView:__delete()
	for k, v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_list = {}
	self:CancelTheQuest()
	self.spirit_attr = nil
	self.item_index = 1
end

function CheckSpiritView:FlushItemHl()
	for i=1,4 do
		self.item_list[i].item_cell:ShowHighLight(self.item_index == i and self.spirit_attr.jingling_item_list[i].jingling_id ~= 0)
	end
end

function CheckSpiritView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.spirit_attr then
		self.spirit_attr = check_attr.spirit_attr
		self:Flush()
	end
end

function CheckSpiritView:OnFlush()
	if self.spirit_attr then
		self.show_name:SetValue(false)
		if self.spirit_attr.use_jingling_id == 0 then
			for k,v in pairs(self.spirit_attr.jingling_item_list) do
				if v.jingling_id ~= 0 then
					self.show_name:SetValue(true)
					self.show_spirit_id = v.jingling_id
					self.show_spirit_level = v.jingling_level
					break
				end
			end
		else
			self.show_name:SetValue(true)
			self.show_spirit_id = self.spirit_attr.use_jingling_id
			for k,v in pairs(self.spirit_attr.jingling_item_list) do
				if v.jingling_id == self.show_spirit_id then
					self.show_spirit_level = v.jingling_level
					break
				end
			end
		end
		local spirit_cfg = SpiritData.Instance:GetSpiritLevelCfgById(self.show_spirit_id, self.show_spirit_level)
		local gongji = 0
		local fangyu = 0
		local shengming = 0
		local kangbao = 0
		if self.show_spirit_id ~= 0 then
			local item_cfg = {}
			item_cfg = ItemData.Instance:GetItemConfig(self.show_spirit_id)
			self.name_text:SetValue(item_cfg.name)
			gongji = spirit_cfg.gongji
			fangyu = spirit_cfg.fangyu
			shengming = spirit_cfg.maxhp
			kangbao = spirit_cfg.jianren
		end
		self.gongji:SetValue(gongji)
		self.fangyu:SetValue(fangyu)
		self.shengming:SetValue(shengming)
		self.kangbao:SetValue(kangbao)

		local the_list = SpiritData.Instance:GetShowTalentList(self.show_spirit_id, self.spirit_attr)
		for i=1,3 do
			if the_list[i].value == 0 then
				self.talent_text_list[i].show_content:SetValue(false)
			else
				self.talent_text_list[i].show_content:SetValue(true)
				self.talent_text_list[i].name:SetValue(the_list[i].name)
				self.talent_text_list[i].value:SetValue(the_list[i].value)
			end
		end
		local jingling_item = CheckData.Instance:GetShowJingLingAttr()
		self.zhan_li:SetValue(RankData.Instance:GetJingLingPower(jingling_item.jingling_id, jingling_item.jingling_level))
		for i=1,4 do
			local data = {}
			if self.spirit_attr.jingling_item_list[i].jingling_id ~= 0 then
				data.item_id = self.spirit_attr.jingling_item_list[i].jingling_id
			else
				data.item_id = 0
			end
			self.item_list[i].item_cell:SetData(data)
		end
		self:SetModle()
		self.item_index = 1
		self:FlushItemHl()
	end
end

function CheckSpiritView:SetShowId(item_id)
	if item_id == self.show_spirit_id then return end
	self.show_spirit_id = item_id
	local gongji = 0
	local fangyu = 0
	local shengming = 0
	local kangbao = 0
	if self.show_spirit_id ~= 0 then
		for k,v in pairs(self.spirit_attr.jingling_item_list) do
			if v.jingling_id == item_id then
				self.show_spirit_level = v.jingling_level
				break
			end
		end
		local item_cfg = {}
		local spirit_cfg = SpiritData.Instance:GetSpiritLevelCfgById(self.show_spirit_id, self.show_spirit_level)
		item_cfg = ItemData.Instance:GetItemConfig(self.show_spirit_id)
		self.name_text:SetValue(item_cfg.name)
		gongji = spirit_cfg.gongji
		fangyu = spirit_cfg.fangyu
		shengming = spirit_cfg.maxhp
		kangbao = spirit_cfg.jianren

		self.gongji:SetValue(gongji)
		self.fangyu:SetValue(fangyu)
		self.shengming:SetValue(shengming)
		self.kangbao:SetValue(kangbao)
		local the_list = SpiritData.Instance:GetShowTalentList(self.show_spirit_id, self.spirit_attr)
		for i=1,3 do
			if the_list[i].value == 0 then
				self.talent_text_list[i].show_content:SetValue(false)
			else
				self.talent_text_list[i].show_content:SetValue(true)
				self.talent_text_list[i].name:SetValue(the_list[i].name)
				self.talent_text_list[i].value:SetValue(the_list[i].value)
			end
		end
		self:SetModle()
	end
end

function CheckSpiritView:SetModle()
	UIScene:SetActionEnable(false)
	if self.show_spirit_id == 0 then return end
	self:CancelTheQuest()
	local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.show_spirit_id)
	if spirit_cfg ~= nil then
		local call_back = function(model, obj)
			local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], spirit_cfg.res_id, DISPLAY_PANEL.RANK)
			if obj then
				if cfg then
					obj.transform.localPosition = cfg.position
					obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
					obj.transform.localScale = cfg.scale
				else
					obj.transform.localPosition = Vector3(0, 0, 0)
					obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
					obj.transform.localScale = Vector3(1, 1, 1)
				end
			end
		end
		UIScene:SetModelLoadCallBack(call_back)
		bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
		self:CalToShowAnim()
	end
end

function CheckSpiritView:CalToShowAnim()
	self:CancelTheQuest()
	self.timer = FIX_SHOW_TIME
	local part = nil
	if UIScene.role_model then
		part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			if part then
				part:SetTrigger("rest")
			end
			self.timer = FIX_SHOW_TIME
		end
	end, 0)
end

function CheckSpiritView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end
