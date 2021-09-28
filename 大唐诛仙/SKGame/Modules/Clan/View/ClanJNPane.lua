ClanJNPane = BaseClass(LuaUI)
ClanJNPane.Learn = "0"
ClanJNPane.Dev = "1"
function ClanJNPane:__init(root,t)
	local ui = UIPackage.CreateObject("Duhufu","JNPane")
	self.ui = ui
	self.btn = ui:GetChild("btnDev")
	self.txtName = ui:GetChild("txtName")
	self.txtLv = ui:GetChild("txtLv")
	self.txtDesc = ui:GetChild("txtDesc")
	self.labelNextCondition = ui:GetChild("labelNextCondition")
	self.labelCost1 = ui:GetChild("labelCost1")
	self.labelCost2 = ui:GetChild("labelCost2")
	self.txtCost1 = ui:GetChild("txtCost1")
	self.txtCost2 = ui:GetChild("txtCost2")
	self.listConn = ui:GetChild("listConn")
	self.txtLimit = ui:GetChild("txtLimit")

	if t == ClanJNPane.Learn then
		self.btn.title = "学习"
	else
		self.btn.title = "研发"
	end
	self.btn.visible=false

	self.paneType = t
	self.parent = root
	self.model = ClanModel:GetInstance()
	self.cells={}
	self.maxLev = GetCfgData("constant"):Get(65).value
	self:Layout()
	self.btn.onClick:Add(function()
		if not self.selected then
			if t == ClanJNPane.Learn then
				UIMgr.Win_FloatTip("您还未选择要学习的技能！")
			else
				UIMgr.Win_FloatTip("您还未选择要研发的技能！")
			end
			return
		end

		local model = self.model
		local obj = self.selected
		local mapSkills = model.mapSkills
		local maxLev = self.maxLev
		local data = obj.data
		local isMaxLev = maxLev == data.level
		if isMaxLev then return end
		local nextLv = math.min(maxLev, data.level+1)
		local data = mapSkills[data.type][data.level]
		local nextData = mapSkills[data.type][nextLv]
		local owerLv = obj.owerLv

		local roleVo = SceneModel:GetInstance():GetMainPlayer()
		local clanInfo = model.clanInfo
		if t == ClanJNPane.Learn then
			local devList = model.devList
			local maxDevLv = 0
			for i=1,#devList do
				if devList[i].type == data.type then
					maxDevLv = devList[i].level
					break
				end
			end
			if obj.activited and maxDevLv <= data.level then
				UIMgr.Win_FloatTip("您已经学习达到当前研发等级，需要都护府进行研发下一级技能才可再学习！")
				return
			end
			if roleVo.level < nextData.playerLv then
				UIMgr.Win_FloatTip(StringFormat("您的等级不足{0}级才能下一级技能学习", nextData.playerLv))
				return
			end
			if roleVo.gold < nextData.money then
				UIMgr.Win_FloatTip("您的金币不足！")
				return
			end
			if model.contribution < nextData.contribute then
				UIMgr.Win_FloatTip("您的个人贡献不足！")
				return
			end
			ClanCtrl:GetInstance():C_StudyGuildSkill(data.type)
		else
			if clanInfo.level < nextData.guildLv then
				UIMgr.Win_FloatTip(StringFormat("贵府等级不足，需要{0}级才能下一级技能研发",nextData.guildLv))
				return
			end
			if clanInfo.money < nextData.guildMoney or clanInfo.buildNum < nextData.guildBuildNum then
				UIMgr.Win_FloatTip("贵府资金或建设度不足以研发下一级技能")
				return
			end
			ClanCtrl:GetInstance():C_UpgradeGuildSkill(data.type)
		end
	end)
end
function ClanJNPane:Layout()
	self:AddTo(self.parent)
	self:SetXY(0, 0)

	local paneType = self.paneType
	local model = self.model
	local typeSkillList = model.typeSkillList
	local mapSkills = model.mapSkills
	local list
	local num = #typeSkillList
	local offx = 2
	local offy = 2
	local cellW = 134
	local cellH = 178
	local rowNum, r, c= 4, 0, 0
	
	for i=1,num do
		local t = typeSkillList[i]
		r = math.floor((i-1)%rowNum)
		c = math.floor((i-1)/rowNum)
		local data = mapSkills[t][1]
		local cell = ClanSkillCell.New(data,paneType)
		cell:AddTo(self.listConn)
		self.cells[i] = cell
		cell:SetXY(r*cellW+offx, c*cellH+offy)
		cell:OnClickCallback(function (obj)
			self:SelectObj(obj)
		end)
	end
	self:SelectObj( self.cells[1] )
end
function ClanJNPane:SelectObj( obj )
	if self.selected then
		self.selected.ui.selected=false
	end
	obj.ui.selected=true
	self.selected = obj
	self:UpdateInfo()
end

function ClanJNPane:Update()
	self:UpdateCells()
	self:UpdateInfo()
end
function ClanJNPane:UpdateInfo()
	local paneType = self.paneType
	local model = self.model
	
	if self.selected then
		local obj = self.selected
		local mapSkills = model.mapSkills
		local maxLev = self.maxLev
		local isMaxLev = maxLev == obj.data.level
		local nextLv = math.min(maxLev, obj.data.level+1)
		local data = mapSkills[obj.data.type][obj.data.level]
		local nextData = mapSkills[obj.data.type][nextLv]
		local owerLv = obj.owerLv

		local devList = model.devList

		self.txtName.text = obj.ui.title
		self.btn.visible=true
		if paneType == ClanJNPane.Learn then
			local maxDevLv = 0
			for i=1,#devList do
				if devList[i].type == obj.data.type then
					maxDevLv = devList[i].level
					break
				end
			end

			if obj.activited then
				self.txtLv.text = StringFormat("{0} / {1} 级", owerLv, maxDevLv)
				if isMaxLev then
					self.btn.visible=false
					self.txtDesc.text = StringFormat("技能效果：\n  {0} \n已经达到顶级", data.des)
				else
					self.txtDesc.text = StringFormat("技能效果：\n  {0}\n\n学习下一级效果：\n  {1}", data.des, nextData.des)
				end
			else
				self.txtLv.text = obj.txtLv.text
				self.txtDesc.text = StringFormat("技能效果：\n  {0}", data.des)
			end
			
			self.labelCost1.text = "消耗金币"
			self.labelCost2.text = "消耗贡献"
			self.txtCost1.text = nextData.money
			self.txtCost2.text = nextData.contribute

			self.labelNextCondition.text = "学习下一等级需要条件："
			self.txtLimit.text=StringFormat("需要您达到{0}级以上才可以学习", nextData.playerLv)
		else
			if isMaxLev then
				self.txtLv.text = StringFormat("{0}, 研发完毕", obj.txtLv.text)
			else
				if obj.activited then
					self.txtLv.text = StringFormat("{0} / {1} 级", obj.data.level, maxLev)
				else
					self.txtLv.text = obj.txtLv.text
				end
			end
			if obj.activited then
				if isMaxLev then
					self.btn.visible=false
					self.txtDesc.text = StringFormat("都护府成员学习技能后可以获得：\n  {0} \n已经达到顶级", data.des)
				else
					self.txtDesc.text = StringFormat("都护府成员学习技能后可以获得：\n  {0}\n\n研发下一级效果：\n  {1}", data.des, nextData.des)
				end
			else
				self.txtDesc.text = StringFormat("都护府成员学习技能后可以获得：\n  {0}", data.des)
			end
			
			self.labelCost1.text = "消耗建设度"
			self.labelCost2.text = "消耗府资金"
			self.txtCost1.text = nextData.guildBuildNum
			self.txtCost2.text = nextData.guildMoney

			self.labelNextCondition.text = "研发下一等级需要条件："
			self.txtLimit.text=StringFormat("需要都护府达到{0}级以上才可以研发", nextData.guildLv)
		end
		
	end
end

function ClanJNPane:UpdateCells()
	local paneType = self.paneType
	local model = self.model
	local cells = self.cells
	local list
	local mapSkills = model.mapSkills
	if paneType == ClanJNPane.Learn then
		list = model.learnList
	else
		list = model.devList
	end

	for i=1,#list do
		local t = list[i].type
		local l = list[i].level
		local vo = mapSkills[t][l]
		if vo then
			for j=1,#cells do
				local cell = cells[j]
				if cell.data.type == vo.type then
					cell:SetActivited(true)
					cell:Update(vo, l)
				end
			end
		end
	end
end
function ClanJNPane:SetVisible(v, isfirst)
	LuaUI.SetVisible(self, v)
	if v and not isfirst then
		self:Update()
	end
end

function ClanJNPane:__delete()
	self.selected = nil
end