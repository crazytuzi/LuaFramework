--
-- @Author: chk
-- @Date:   2018-12-30 21:18:33
--
FactionSkillItem = FactionSkillItem or class("FactionSkillItem",BaseItem)
local FactionSkillItem = FactionSkillItem

function FactionSkillItem:ctor(parent_node,layer,index)
	self.abName = "faction"
	self.assetName = "FactionSkillItem"
	self.layer = layer
	self.index = index
	self.events = {}

	self.model = FactionModel.GetInstance()
	FactionSkillItem.super.Load(self)
end

function FactionSkillItem:dctor()
	for k,v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	if self.red_point then
		self.red_point:destroy()
		self.red_point = nil
	end
end

function FactionSkillItem:LoadCallBack()
	self.nodes = {
		"name",
		"icon",
		"lv_bg/lv",
		"lv_bg/max",
		"select",
	}
	self:GetChildren(self.nodes)
	self:GetSelfComponent()
	self:AddEvent()
	self.red_point = RedDot(self.icon, nil, RedDot.RedDotType.Nor)
	self.red_point:SetPosition(64, 77)
	if self.need_load_end then
		self:UpdateView(self.skillCfg)

		self:SetItemPosition()
	end


end

function FactionSkillItem:AddEvent()
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.SkillInfo,handler(self,self.DealSkillInfo))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.SkillUpLv,handler(self,self.DealUpLv))


	AddClickEvent(self.transform.gameObject,handler(self,self.SelectItem))
	--self.transform:GetComponent('Toggle').onValueChanged:AddListener(call_back)

end

function FactionSkillItem:DealSkillInfo(id)
	if self.skillCfg ~= nil and self.skillCfg.id == id then
		self.skillCfg = Config.db_skill[id]
		self:UpdateView(self.skillCfg)
	end
end

function FactionSkillItem:DealUpLv(data)
	if data.id == self.skillCfg.id then
		local nextKey = self.skillCfg.id .. "@" .. (data.level + 1)
		local nextSkilllLVCfg = Config.db_skill_level[nextKey]
		if nextSkilllLVCfg == nil then
			SetVisible(self.max.gameObject,true)
			SetVisible(self.lv.gameObject,false)
			self.red_point:SetRedDotParam(false)
		else
			--local bgValue = RoleInfoModel.GetInstance():GetRoleValue(90010011)
			--local key = self.skillCfg.id .. "@" .. data.level
			--local costTab = String2Table(Config.db_skill_level[key].learn)
			--if costTab[2] <= bgValue then
			--	self.red_point:SetRedDotParam(true)
			--else
			--	self.red_point:SetRedDotParam(false)
			--end
			self.lvTxt.text = tostring(data.level) .. ConfigLanguage.Mix.Level
		end

		self:SelectItem()
	end

end

function FactionSkillItem:SetRedPoint()
	local level = self.model.skillLst[self.skillCfg.id]
	if level == nil then
		level = 1
	end
	local key = self.skillCfg.id .. "@" .. level
	local skillLvCfg = Config.db_skill_level[key]
	local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
	local reqTbl = String2Table(skillLvCfg.reqs)
	if reqTbl[2] > roleData.level then
		self.lvTxt.text = string.format(ConfigLanguage.Faction.NeedlvActive,reqTbl[2])
		self.red_point:SetRedDotParam(false)
	else

		--已经激活
		if self.model.skillLst[self.skillCfg.id] ~= nil then
			local nextKey = self.skillCfg.id .. "@" .. (level + 1)
			local nextSkilllLVCfg = Config.db_skill_level[nextKey]

			if nextSkilllLVCfg == nil then
				self.red_point:SetRedDotParam(false)
			else
				local bgValue = RoleInfoModel.GetInstance():GetRoleValue(90010011)
				local key = self.skillCfg.id .. "@" .. level
				local costTab = String2Table(Config.db_skill_level[key].learn)
				if costTab[2] <= bgValue then
					self.red_point:SetRedDotParam(true)
				else
					self.red_point:SetRedDotParam(false)
				end
			end

		else
			self.red_point:SetRedDotParam(true)
		end
	end


end


function FactionSkillItem:GetSelfComponent()
	self.itemRect = GetRectTransform(self.transform.gameObject)
	self.lvTxt = self.lv:GetComponent('Text')
end
function FactionSkillItem:SetData(data)
	self.data = data
end

function FactionSkillItem:ShowSelectImg(show)
	SetVisible(self.select.gameObject,show)
end

function FactionSkillItem:SetItemPosition()
	local row = math.floor(self.index / 3)
	local col = math.floor(self.index % 3)

	local x = self.itemRect.sizeDelta.x  * col
	local y = self.itemRect.sizeDelta.y  * row
	self.itemRect.anchoredPosition = Vector2(x,-y)
end

function FactionSkillItem:SelectItem()
	if self.model.last_select ~= nil then
		self.model.last_select:ShowSelectImg(false)
	end

	self.model.last_select = self

	self:ShowSelectImg(true)
	self.model:Brocast(FactionEvent.ShowSkillInfo,self.skillCfg,self.lvTxt.text)
end


function FactionSkillItem:UpdateView(skillCfg)
	self.skillCfg = skillCfg
	if self.is_loaded then

		local level = self.model.skillLst[self.skillCfg.id]
		if level == nil then
			level = 1
		end
		local key = self.skillCfg.id .. "@" .. level
		local skillLvCfg = Config.db_skill_level[key]
		local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
		local reqTbl = String2Table(skillLvCfg.reqs)

		--需求等级大于自身等级
		if reqTbl[2] > roleData.level then
			self.lvTxt.text = string.format(ConfigLanguage.Faction.NeedlvActive,reqTbl[2])
			self.red_point:SetRedDotParam(false)
		else

			--已经激活
			if self.model.skillLst[self.skillCfg.id] ~= nil then
				local nextKey = self.skillCfg.id .. "@" .. (level + 1)
				local nextSkilllLVCfg = Config.db_skill_level[nextKey]

				if nextSkilllLVCfg == nil then
					SetVisible(self.max.gameObject,true)
					SetVisible(self.lv.gameObject,false)
					self.red_point:SetRedDotParam(false)
				else
					local bgValue = RoleInfoModel.GetInstance():GetRoleValue(90010011)
					local key = self.skillCfg.id .. "@" .. level
					local costTab = String2Table(Config.db_skill_level[key].learn)
					if costTab[2] <= bgValue then
						self.red_point:SetRedDotParam(true)
					else
						self.red_point:SetRedDotParam(false)
					end
					self.lvTxt.text = level .. ConfigLanguage.Mix.Level
				end

			else
				self.lvTxt.text = ConfigLanguage.Equip.NotActive
				self.red_point:SetRedDotParam(true)
			end
		end

		--GoodIconUtil.GetInstance():CreateIcon(self,GetImage(self.icon),tonumber(self.skillCfg.icon),true)
		lua_resMgr:SetImageTexture(self,GetImage(self.icon),"iconasset/icon_skill",self.skillCfg.icon,true,nil,false)
		self.name:GetComponent('Text').text = self.skillCfg.name

		if self.model.defaultSkill == self.skillCfg.id then
			self:SelectItem()
		end
	else
		self.need_load_end = true
	end

end