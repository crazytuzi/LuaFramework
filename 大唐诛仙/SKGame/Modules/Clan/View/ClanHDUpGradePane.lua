ClanHDUpGradePane = BaseClass(LuaUI)
function ClanHDUpGradePane:__init(root)
	self.ui = UIPackage.CreateObject("Duhufu","HDUpGradePane")
	self.txtLv = self.ui:GetChild("txtLv")
	self.labelCurLv = self.ui:GetChild("labelCurLv")
	self.labelNextLv = self.ui:GetChild("labelNextLv")
	self.btnUpGrade = self.ui:GetChild("btnUpGrade")
	self.txtLvDesc = self.ui:GetChild("txtLvDesc")
	self.txtCurLvDesc = self.ui:GetChild("txtCurLvDesc")
	self.txtNextLvDesc = self.ui:GetChild("txtNextLvDesc")
	self.txtNeedDesc = self.ui:GetChild("txtNeedDesc")
	self.parent = root
	self.cfg = GetCfgData("guild")
	self.maxLv = GetCfgData("constant"):Get(62).value
	self:Layout()
	self:Update()
end

function ClanHDUpGradePane:Layout()
	self:AddTo(self.parent)
	self.btnUpGrade.onClick:Add(function ()
		if self.isLack then
			UIMgr.Win_FloatTip("操作失败，贵俯资金或建设度不足！")
			return
		end
		ClanCtrl:GetInstance():C_UpgradeGuild()
	end)
end
function ClanHDUpGradePane:SetVisible(v, isfirst)
	LuaUI.SetVisible(self, v)
	-- if v and not isfirst then
	-- 	local model = ClanModel:GetInstance()
	-- 	local clanInfo = model.clanInfo
	-- end
end
function ClanHDUpGradePane:Update()
	local model = ClanModel:GetInstance()
	local clanInfo = model.clanInfo
	local curLv = clanInfo.level
	self.btnUpGrade.visible = model.job>=2
	local curVo = self.cfg:Get(curLv)
	local nextVo = nil
	local desc
	if curLv < self.maxLv then
		nextVo = self.cfg:Get(curLv+1)
	end
	self.txtLv.text = StringFormat("当前都护府 {0} 级", curLv)
	desc = "每天消耗 {0} 点都护府资金，每天所需 {1} 点都护府建设度，\n当前最大人数 {2} 人，可以设置 {3} 名副都护帮忙打理帮会事务。"
	self.txtLvDesc.text = StringFormat(desc, curVo.costMoney, curVo.costBuildNum, curVo.maxNum, curVo.assistantNum)
	self.isLack = false -- 缺失条件
	if nextVo then
		desc = "最大人数:  {0}\n最大副都护人数:  {1}"
		self.txtCurLvDesc.text = StringFormat(desc, curVo.maxNum, curVo.assistantNum)
		desc = "最大人数:  {0}\n最大副都护人数:  {1}"
		self.txtNextLvDesc.text = StringFormat(desc, nextVo.maxNum, nextVo.assistantNum)
		desc = "1、需消耗都护府资金 {1} 点, \n2、需消耗都护府建设度 [color={2}]{3}[/color] 点"
		local needMoneyColor,needBuildNumColor
		if clanInfo.money < nextVo.needMoney then
			self.isLack = true
			needMoneyColor = "#ff0000"
		else
			needMoneyColor = "#00ff00"
		end
		if clanInfo.buildNum < nextVo.needBuildNum then
			self.isLack = true
			needBuildNumColor = "#ff0000"
		else
			needBuildNumColor = "#00ff00"
		end

		self.txtNeedDesc.text = StringFormat(desc, needMoneyColor, nextVo.needMoney, needBuildNumColor, nextVo.needBuildNum)
	else
		self.txtCurLvDesc.text = " 已达最大等级 "
		self.txtNextLvDesc.text = ""
		self.txtNeedDesc.text = ""
	end
end

function ClanHDUpGradePane:__delete()
	self.cfg = nil
end