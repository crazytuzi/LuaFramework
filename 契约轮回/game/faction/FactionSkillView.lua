--
-- @Author: chk
-- @Date:   2018-12-05 11:50:40
--
FactionSkillView = FactionSkillView or class("FactionSkillView",BaseItem)
local FactionSkillView = FactionSkillView

function FactionSkillView:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionSkillViw"
	self.layer = layer
	self.events = {}
	self.skillItems = {}
	self.skillAttrItems = {}
	self.model = FactionModel:GetInstance()
	FactionSkillView.super.Load(self)
end

function FactionSkillView:dctor()
	self.model.last_select = nil


	for k,v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	if self.scrollView ~= nil then
		self.scrollView:OnDestroy()
	end

	if self.emptyGirl ~= nil then
		self.emptyGirl:destroy()
	end

	for i, v in pairs(self.skillItems or {}) do
		v:destroy()
	end

	self.skillItems = {}

	self.model.defaultSkill = nil
end

function FactionSkillView:LoadCallBack()

	self.nodes = {
		"Left",
		"Right",
		"girlContain",
		"Left/LScrollView",
		"Left/LScrollView/Viewport/LContent",
		"Right/bg/title/title",
		"Right/bg/icon",
		"Right/bg/lv_bg/lv",
		"Right/bg/lv_bg/maxlv",
		"Right/bg/attri/Scroll View/Viewport/AContent",
		"Right/bg/cost/cost_icon",
		"Right/bg/cost/cost_value",
		"Right/bg/learnBtn",
		"Right/bg/learnBtn/learnBtnTex",
		"value",
		"Right/bg/maxImg",
	}
	self:GetChildren(self.nodes)

	self.learnBtnTex = GetText(self.learnBtnTex)

	if self.model.roleData.guild == "0" then
		if self.emptyGirl == nil then
			self.emptyGirl = EmptyGirl(self.girlContain,ConfigLanguage.Faction.EnterFactionPlease)
		end
		SetVisible(self.emptyGirl.gameObject,true)

		SetVisible(self.Left.gameObject,false)
		SetVisible(self.Right.gameObject,false)
	else
		self:GetSelfComponent()
		self:AddEvent()


		FactionSkillController.GetInstance():RequestFactionSkills()

		self:LoadSkillItems()
		--找帮贡图标
		local itemCfg = Config.db_item[90010011]
		GoodIconUtil.GetInstance():CreateIcon(self,GetImage(self.cost_icon),itemCfg.icon,true)


		if self.need_loaded_end then
			self:ShowViewInfo(self.skillCfg)
		end
	end


end

function FactionSkillView:AddEvent()
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.ShowSkillInfo,handler(self,self.ShowViewInfo))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.SkillUpLv,handler(self,self.DealSkillUpLv))
	local function call_back( ... )
		local level = self.model.skillLst[self.skillCfg.id]
		if level == nil then
			level = 0
		end
		--判断人物等级是否达到
		local key = self.skillCfg.id .. "@" .. level
		local skillLvCfg = Config.db_skill_level[key]
		local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
		local reqTbl = String2Table(skillLvCfg.reqs)
		if reqTbl[2] > roleData.level then
			Notify.ShowText(string.format(ConfigLanguage.Faction.NeedLV,reqTbl[2]))
			return
		end


		--判断技能是否最高级
		local key = self.skillCfg.id .. "@" .. level
		if Config.db_skill_level[key] == nil then
			Notify.ShowText(ConfigLanguage.Faction.HadToMaxLv)
			return
		end

		if self.model:GetSkillStatus(self.skillCfg.id) == 2 then
			FactionSkillController.GetInstance():RequestLearnSkill(self.skillCfg.id)
		else
			--判断帮贡是否足够
			local bgValue = RoleInfoModel.GetInstance():GetRoleValue(90010011)
			local costTbl = String2Table(Config.db_skill_level[key].learn)
			if costTbl[2] > bgValue then
				Notify.ShowText(ConfigLanguage.Faction.BgNotEnough)
				return
			end
			FactionSkillController.GetInstance():RequestLearnSkill(self.skillCfg.id)
		end

	end
	AddClickEvent(self.learnBtn.gameObject,call_back)
end

function FactionSkillView:GetSelfComponent()
	self.LScrollViewTra = self.LScrollView:GetComponent('RectTransform')
	self.iconImg = self.icon:GetComponent('Image')
	self.costIconImg = self.cost_icon:GetComponent('Image')
	self.lvTxt = self.lv:GetComponent('Text')
	self.titleTxt = self.title:GetComponent('Text')
	self.costValueTxt = self.cost_value:GetComponent('Text')
	self.valueTxt = self.value:GetComponent('Text')
	self.AContentRect = self.AContent:GetComponent('RectTransform')
	self.LContentRect = self.LContent:GetComponent('RectTransform')
end


function FactionSkillView:DealSkillUpLv(data)
	--self.skillCfg = Config.db_skill[data.id]
	for i = 1, #self.skillItems do
		self.skillItems[i]:SetRedPoint()
	end
end

function FactionSkillView:LoadSkillItems()
	local skillTbl = {}
	local skills = Config.db_skill
	for i, v in pairs(skills) do
		if v.group == enum.SKILL_GROUP.SKILL_GROUP_GUILD then
			Chkprint("添加————————",v.name)
			table.insert(skillTbl, #skillTbl+1, v)
		end
	end

	local function call_back(s1,s2)
		if s1 ~= nil and s2 ~= nil then
			return s1.id < s2.id
		end
	end
	table.sort(skillTbl,call_back)

	local index = 0
	for i, v in pairs(skillTbl) do
		if self.model.defaultSkill == nil then
			self.model.defaultSkill = v.id
		end

		self.skillItems[i] = FactionSkillItem(self.LContent,nil,index)
		self.skillItems[i]:UpdateView(v)
		index = index + 1
	end

	local row = math.ceil(table.nums(skillTbl) / 3)
	self.LContentRect.sizeDelta = Vector2(self.LContentRect.sizeDelta.x,200 * row)
end

function FactionSkillView:SetSkillAttr(k,v)
	local attrInfo = ""
	local valueInfo = EquipModel.GetInstance():GetAttrTypeInfo(k, v)
	attrInfo =  attrInfo .. enumName.ATTR[k] .. "" .. string.format("<color=#%s>",
			"2faa22") .. valueInfo .. "</color>" .. "\n"
	return attrInfo
end


function FactionSkillView:ShowViewInfo(skillCfg,levelInfo)
	self.skillCfg  = skillCfg
	if self.is_loaded then
		local level = self.model.skillLst[skillCfg.id]
		if level == nil then
			level = 0
		end
		self.lvTxt.text = levelInfo
		self.titleTxt.text = skillCfg.name

		local key = skillCfg.id .. "@" .. level
		local bgValue = RoleInfoModel.GetInstance():GetRoleValue(90010011)
		if Config.db_skill_level[key] ~= nil then
			local skillLvCfg = Config.db_skill_level[key]
			local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
			local reqTbl = String2Table(skillLvCfg.reqs)

			--需求等级大于自身等级
			if reqTbl[2] > roleData.level then
				self.costValueTxt.text = string.format("<color=#089D0F>%s</color>",bgValue) .. "/" .. "0"
			else
				if self.model.skillLst[self.skillCfg.id] == nil then  --未激活
					self.costValueTxt.text = string.format("<color=#089D0F>%s</color>",bgValue) .. "/" .. "0"
					self.learnBtnTex.text = "Activate"
				else
					self.learnBtnTex.text = "Upgrade"
					local costTbl = String2Table(Config.db_skill_level[key].learn)


					if costTbl[2] > bgValue then
						self.costValueTxt.text = string.format("<color=#D91A1A>%s</color>",bgValue) .. "/" .. costTbl[2]
					else
						self.costValueTxt.text = string.format("<color=#089D0F>%s</color>",bgValue) .. "/" .. costTbl[2]
					end
				end
			end
			if table.nums(self.skillAttrItems) <= 0 then
				--1表示当前
				--2表示下一级
				self.skillAttrItems[1] = FactionSkillAttrItem(self.AContent,"UI",1)
				self.skillAttrItems[2] = FactionSkillAttrItem(self.AContent,"UI",2)
			end

			--当前技能加成
			local crntAttr = String2Table(Config.db_skill_level[key].attrs)
			local crntAttrInfo = ""
			for i, v in pairs(crntAttr) do
				crntAttrInfo = crntAttrInfo .. self:SetSkillAttr(v[1],v[2])
			end

			crntAttrInfo = ConfigLanguage.Faction.CrntSkill .. crntAttrInfo
			self.valueTxt.text = crntAttrInfo

			local pos = self.valueTxt.preferredHeight
			local height = pos
			self.skillAttrItems[1]:UpdatInfo(crntAttrInfo,self.valueTxt.preferredHeight,0)
			local nextKey = skillCfg.id .. "@" .. (level + 1)

			--下一级技能加成
			if Config.db_skill_level[nextKey] ~= nil then  --有下一级技能
				SetVisible(self.maxlv.gameObject,false)
				SetVisible(self.lv.gameObject,true)
				SetVisible(self.maxImg.gameObject,false)
				SetVisible(self.learnBtn.gameObject,true)

				local nextAttr = String2Table(Config.db_skill_level[nextKey].attrs)
				local nextAttrInfo = ""
				for i, v in pairs(nextAttr) do
					nextAttrInfo = nextAttrInfo .. self:SetSkillAttr(v[1],v[2])
				end

				nextAttrInfo = ConfigLanguage.Faction.NextSkill .. nextAttrInfo
				self.valueTxt.text = nextAttrInfo
				self.skillAttrItems[2]:UpdatInfo(nextAttrInfo,self.valueTxt.preferredHeight,pos)

				height = height + self.valueTxt.preferredHeight
			else   --没下一级，就是最高级了
				SetVisible(self.maxlv.gameObject,true)
				SetVisible(self.lv.gameObject,false)
				SetVisible(self.maxImg.gameObject,true)
				SetVisible(self.learnBtn.gameObject,false)
				self.skillAttrItems[2]:UpdatInfo("")
			end

			self.AContentRect.sizeDelta = Vector2(self.AContentRect.sizeDelta.x,height)

		else
			self.costValueTxt.text = "0"
		end

		lua_resMgr:SetImageTexture(self,self.iconImg,"iconasset/icon_skill",self.skillCfg.icon,true,nil,false)
		--lua_resMgr:SetImageTexture(self,self.costIconImg,"faction","faction_image_",true,nil,false)
	else
		self.need_loaded_end = true
	end
end


function FactionSkillView:SetData(data)

end