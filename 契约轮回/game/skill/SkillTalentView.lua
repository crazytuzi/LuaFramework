SkillTalentView = SkillTalentView or class("SkillTalentView",BaseItem)
local SkillTalentView = SkillTalentView

function SkillTalentView:ctor(parent_node,layer)
	self.abName = "skill"
	self.assetName = "SkillTalentView"
	self.layer = layer

	self.model = SkillUIModel:GetInstance()
	SkillTalentView.super.Load(self)
	self.group = 1
	self.group_items = {}
	self.base_items = {}
	self.guide_items = {}
	self.fight_items = {}
	self.events = {}
end

function SkillTalentView:dctor()
	self.model:RemoveTabListener(self.events)
	self.events = nil
	for i=1, #self.group_items do
		self.group_items[i]:destroy()
	end
	for i=1, #self.base_items do
		self.base_items[i]:destroy()
	end
	for i=1, #self.guide_items do
		self.guide_items[i]:destroy()
	end
	for i=1, #self.fight_items do
		self.fight_items[i]:destroy()
	end
	self.group_items = nil
	self.base_items = nil
	self.guide_items = nil
	self.fight_items = nil
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
end

function SkillTalentView:LoadCallBack()
	self.nodes = {
		"middle/BaseScrollView/Viewport/baseSkillsContent","middle/GuideScrollView/Viewport/guideSkillsContent",
		"middle/FightScrollView/Viewport/fightSkillsContent","ScrollView/Viewport/Content",
		"middle/title","right/icon_bg/icon","right/icon_bg/skill_level_title/skill_level",
		"right/icon_bg/use_point_title/use_point","right/icon_bg/pre_skill_title/pre_skill",
		"right/current/cur_title","right/current/cur_des","right/next/next_des",
		"bottom/point","bottom/resetbtn","bottom/uplevelbtn","ScrollView/Viewport/Content/TalentGroupItem",
		"middle/BaseScrollView/Viewport/baseSkillsContent/TalentSkillItem",
		"middle/BaseScrollView","middle/GuideScrollView","middle/FightScrollView",
		"right/icon_bg/skill_name","right/icon_bg/use_point_title","right/icon_bg/pre_skill_title",
	}
	self:GetChildren(self.nodes)

	self.TalentGroupItem_go = self.TalentGroupItem.gameObject
	SetVisible(self.TalentGroupItem_go, false)
	self.TalentSkillItem_go = self.TalentSkillItem.gameObject
	SetVisible(self.TalentSkillItem_go, false)
	self.title = GetText(self.title)
	self.point = GetText(self.point)
	self.icon = GetImage(self.icon)
	self.skill_level = GetText(self.skill_level)
	self.use_point = GetText(self.use_point)
	self.pre_skill = GetText(self.pre_skill)
	self.cur_title = GetText(self.cur_title)
	self.cur_des = GetText(self.cur_des)
	self.next_des = GetText(self.next_des)
	self.skill_name = GetText(self.skill_name)
	self.use_point_title = GetText(self.use_point_title)
	self:AddEvent()
	self:UpdateView()
end

function SkillTalentView:AddEvent()

	local function call_back(group)
		self:UpdateSkills()
		self:ShowRedDot()
	end
	self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentUpdateInfo, call_back)

	local function call_back(skill_id)
		self.select_skill_id = skill_id
		self:UpdateSkillDetail()
	end
	self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentSelectSkill, call_back)

	local function call_back(skill_id)
		self:UpdateSkillDetail()
		self.point.text = self.model.point
		self:ShowRedDot()
	end
	self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentUpdateSkill, call_back)

	local function call_back()
		SkillUIController:GetInstance():RequestTalentInfo(self.group)
	end
	self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentReset, call_back)

	local function call_back(group)
		self.group = group
		self:UpdateSkills()
	end
	self.events[#self.events+1] = self.model:AddListener(SkillUIEvent.TalentSelectGroup, call_back)


	local function call_back(target,x,y)
		local talentcfg = Config.db_talent[self.select_skill_id]
		local cur_level = self.model.talent_skills[self.select_skill_id] or 0
		if cur_level >= talentcfg.level_limit then
			return Notify.ShowText("Max level reached")
		end
		local reqs = String2Table(talentcfg.reqs)
		if not table.isempty(reqs) then
			for i=1, #reqs do
				local req = reqs[i]
				if req[1] == "allot" then
					local group = req[2]
					local need_point = req[3]
					local had_point = self.model:GetTotalPoint(group)
					local message = ""
					if group == 1 then
						message = "Not enough investment in battle category"
					elseif group == 2 then
						message = "Not enough investment in guardian category"
					elseif group == 3 then
						message = "Not enough investment in basic category"
					end
					if had_point < need_point then
						return Notify.ShowText(message)
					end
				end
				if req[1] == "skill_lv" then
					local skill_id = req[2]
					local need_level = req[3]
					local had_level = self.model.talent_skills[skill_id] or 0
					if had_level < need_level then
						return Notify.ShowText("Level of the preset skill is too low")
					end
				end
			end
		end
		if self.model.point < talentcfg.point then
			return Notify.ShowText("Not enough talent points")
		end
		SkillUIController:GetInstance():RequestTalentUpgrade(self.select_skill_id)
	end
	AddButtonEvent(self.uplevelbtn.gameObject,call_back)

	local function call_back(target,x,y)
		local item_id = self.model.talent_reset_itemid
		local num = BagController.GetInstance():GetItemListNum(item_id)
		local message = ""
		if num <= 0 then
			local need_gold = Config.db_voucher[item_id].price
			local vo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.BGold)
			if not vo then
				return
			end
			message = string.format("Insufficient talent reset books, spend %s bound diamond to buy?", need_gold)
		else
			message = "Use talent reset books*1 to reset talent? (After that, all talents can be re-distributed, return all distributed talent points)"
		end
		local function ok_func()
			SkillUIController:GetInstance():RequestTalentReset()
		end
		Dialog.ShowTwo("Tip",message,"Confirm",ok_func)
	end
	AddClickEvent(self.resetbtn.gameObject,call_back)
end


function SkillTalentView:UpdateView()
	if table.isempty(self.group_items) then
		local groups = self.model:GetGroups()
		for i=1, #groups do
			local item = TalentGroupItem(self.TalentGroupItem_go, self.Content)
			item:SetData(groups[i])
			self.group_items[i] = item
		end
	end
	self:SelectGroup()
	self:ShowRedDot()
end

function SkillTalentView:SelectGroup()
	self.group_items[self.group]:Select()
end

function SkillTalentView:UpdateSkills()
	local skills = self.model:GetGroupSkills(self.group)
	local items, Content
	if self.group == 1 then
		items = self.fight_items
		Content = self.fightSkillsContent
		SetVisible(self.BaseScrollView, false)
		SetVisible(self.GuideScrollView, false)
		SetVisible(self.FightScrollView, true)
		self.title.text = "Battle Talent"
	elseif self.group == 2 then
		items = self.guide_items
		Content = self.guideSkillsContent
		SetVisible(self.BaseScrollView, false)
		SetVisible(self.GuideScrollView, true)
		SetVisible(self.FightScrollView, false)
		self.title.text = "Guardian Talent"
	elseif self.group == 3 then
		items = self.base_items
		Content = self.baseSkillsContent
		SetVisible(self.BaseScrollView, true)
		SetVisible(self.GuideScrollView, false)
		SetVisible(self.FightScrollView, false)
		self.title.text = "Basic talents"
	end
	for i=1, #skills do
		local skill = skills[i]
		local item = items[i] or TalentSkillItem(self.TalentSkillItem_go, Content)
		item:SetData(skill)
		items[i] = item
	end
	self.point.text = self.model.point
	items[1]:Select()
end

function SkillTalentView:UpdateSkillDetail()
	local skillcfg = Config.db_skill[self.select_skill_id]
	local talentcfg = Config.db_talent[self.select_skill_id]
	lua_resMgr:SetImageTexture(self,self.icon, 'iconasset/icon_skill', skillcfg.icon, false)
	self.skill_name.text = skillcfg.name
	local cur_level = self.model.talent_skills[self.select_skill_id] or 0
	self.skill_level.text = string.format("%s/%s", cur_level, talentcfg.level_limit)
	--显示前置条件
	local reqs = String2Table(talentcfg.reqs)
	SetVisible(self.use_point_title, false)
	SetVisible(self.pre_skill_title, false)
	if not table.isempty(reqs) then
		for i=1, #reqs do
			local req = reqs[i]
			if req[1] == "allot" then
				SetVisible(self.use_point_title, true)
				local group = req[2]
				local need_point = req[3]
				local had_point = self.model:GetTotalPoint(group)
				local color = "#e63232"
				if had_point >= need_point then
					color = "#09B005"
				end
				local str = ""
				if group == 1 then
					str = "Battle Category:"
				elseif group == 2 then
					str = "Guardian:"
				elseif group == 3 then
					str = "Basic Category:"
				end
				self.use_point_title.text = str
				self.use_point.text = string.format("<color=%s>%s/%s</color>", color, had_point, need_point)
			end
			if req[1] == "skill_lv" then
				SetVisible(self.pre_skill_title, true)
				local skill_id = req[2]
				local need_level = req[3]
				local had_level = self.model.talent_skills[skill_id] or 0
				local name = Config.db_skill[skill_id].name
				local color = "#e63232"
				if had_level >= need_level then
					color = "#09B005"
				end
				self.pre_skill.text = string.format("<color=%s>%s %s/%s</color>", color, name, had_level, need_level)
			end
		end
	end
	if cur_level == 0 then
		self.cur_title.text = "Max level effect"
		local key = string.format("%s@%s", self.select_skill_id, talentcfg.level_limit)
		self.cur_des.text = Config.db_skill_level[key] and Config.db_skill_level[key].dec or ""
	else
		self.cur_title.text = "Current effect"
		local key = string.format("%s@%s", self.select_skill_id, cur_level)
		self.cur_des.text = Config.db_skill_level[key] and Config.db_skill_level[key].dec or ""
	end
	if cur_level < talentcfg.level_limit then
		local next_level = cur_level+1
		local key = string.format("%s@%s", self.select_skill_id, next_level)
		self.next_des.text = Config.db_skill_level[key] and Config.db_skill_level[key].dec or ""
	else
		self.next_des.text = "This talent has reached its max level"
	end
end


function SkillTalentView:ShowRedDot()
	if not self.reddot then
		self.reddot = RedDot(self.uplevelbtn)
		SetLocalPosition(self.reddot.transform, 55, 14)
	end
	SetVisible(self.reddot, self.model.point>0)
end

