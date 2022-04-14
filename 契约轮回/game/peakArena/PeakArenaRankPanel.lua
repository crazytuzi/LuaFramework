---
--- Created by  Administrator
--- DateTime: 2019/8/1 10:22
---
PeakArenaRankPanel = PeakArenaRankPanel or class("PeakArenaRankPanel", BaseItem)
local this = PeakArenaRankPanel

function PeakArenaRankPanel:ctor(parent_node, parent_panel)
	
	self.abName = "peakArena";
	self.image_ab = "peakArena_image";
	self.assetName = "PeakArenaRankPanel"
	self.layer = "UI"
	self.events = {}
	self.gevents = {}
	self.rankItems = {}
	self.pageIndex  = 1
	self.model = PeakArenaModel:GetInstance()
	self.role = RoleInfoModel.GetInstance():GetMainRoleData()
	PeakArenaRankPanel.super.Load(self)
end

function PeakArenaRankPanel:dctor()
	self.model:RemoveTabListener(self.events)
	GlobalEvent:RemoveTabListener(self.gevents)
	for k, v in pairs(self.rankItems) do
		v:destroy()
	end
	self.rankItems = {}
	
	if self.roleMode  then
		self.roleMode:destroy()
	end
	
	if self.red1 then
		self.red1:destroy()
		self.red1 = nil
	end
end

function PeakArenaRankPanel:LoadCallBack()
	self.nodes = {
		"left/button","left/myrank/myname","PeakArenaRankItem","left/rankItemParent",
		"left/pageTex","left/myrank/mySoccer",
		"left/myrank/mySer","left/myrank/myOrder","left/myrank/myRankTex2",
		"right/roleModelCon","left/myrank/titlebg/maRankTex",
		"down/dayReward/dayrewardTex","down/downOrder/dayOrderTex","down/downOrder/dayOrderIcon",
		"left/button/nextBtn","left/button/lastBtn",
		"left/button/maxBtn","left/button/minBtn","left/button/lqBtn",
		"right/modelName",
	}
	self:GetChildren(self.nodes)
	self.myname = GetText(self.myname)
	self.pageTex = GetText(self.pageTex)
	self.mySoccer = GetText(self.mySoccer)
	self.mySer = GetText(self.mySer)
	self.myOrder = GetText(self.myOrder)
	self.myRankTex2 = GetText(self.myRankTex2)
	self.maRankTex = GetText(self.maRankTex)
	self.dayrewardTex = GetText(self.dayrewardTex)
	self.dayOrderTex = GetText(self.dayOrderTex)
	self.dayOrderIcon = GetImage(self.dayOrderIcon)
	self.modelName = GetText(self.modelName)
	self.lqBtnImg = GetImage(self.lqBtn)
	self:InitUI()
	self:AddEvent()
	
	
	self.red1 = RedDot(self.lqBtn, nil, RedDot.RedDotType.Nor)
	self.red1:SetPosition(68, 22)
	if self.model:GetIsLocal() then
		RankController:GetInstance():RequestRankListInfo(1012,1)
	else
		RankController:GetInstance():RequestRankListInfo(2012,1)
	end
	--RankController:GetInstance():RequestRankListInfo(1012,1)  --2012
	self.layerIndex = LuaPanelManager:GetInstance():GetPanelInLayerIndex(self.layer, self)
end

function PeakArenaRankPanel:InitUI()
	
end

function PeakArenaRankPanel:AddEvent()
	
	local function call_back()
		if self.isReward == 0 then
			Notify.ShowText("No reward is available")
			return 
		end
		if self.isReward == 2  then
			Notify.ShowText("Rewards have been claimed")
			return
		end
		PeakArenaController:GetInstance():RequestDailyReward()
	end
	AddClickEvent(self.lqBtn.gameObject,call_back)
	
	local function call_back()  --上一页
		local page = self.pageIndex - 1
		if page <= 0 then
			Notify.ShowText("You are on the first page")
			return
		end
		if self.model:GetIsLocal() then
			RankController:GetInstance():RequestRankListInfo(1012,page)
		else
			RankController:GetInstance():RequestRankListInfo(2012,page)
		end
		
	end
	AddClickEvent(self.lastBtn.gameObject,call_back)
	
	local function call_back()  --下一页
		local page = self.pageIndex + 1
		if page > self.maxPage  then
			Notify.ShowText("You are on the last page")
			return
		end

		if self.model:GetIsLocal() then
			RankController:GetInstance():RequestRankListInfo(1012,page)
		else
			RankController:GetInstance():RequestRankListInfo(2012,page)
		end
	end
	AddClickEvent(self.nextBtn.gameObject,call_back)
	
	
	local function call_back()  --最大页数
		if self.model:GetIsLocal() then
			RankController:GetInstance():RequestRankListInfo(1012,self.maxPage)
		else
			RankController:GetInstance():RequestRankListInfo(2012,self.maxPage)
		end
	end
	AddClickEvent(self.maxBtn.gameObject,call_back)
	
	
	local function call_back()  --最小页数
		if self.model:GetIsLocal() then
			RankController:GetInstance():RequestRankListInfo(1012,1)
		else
			RankController:GetInstance():RequestRankListInfo(2012,1)
		end
	end
	AddClickEvent(self.minBtn.gameObject,call_back)
	
	
	
	
	self.gevents[#self.gevents + 1] = GlobalEvent:AddListener(RankEvent.RankReturnList, handler(self, self.RankReturnList))
	self.events[#self.events + 1] = self.model:AddListener(PeakArenaEvent.RankItemClick,handler(self,self.RankItemClick))
	self.events[#self.events + 1] = self.model:AddListener(PeakArenaEvent.DailyReward,handler(self,self.DailyReward))
	
end

function PeakArenaRankPanel:SetBtnState()
	self.isReward = self.model.daily_reward
	if self.isReward == 0 then --没有奖励
		self.red1:SetRedDotParam(false)
		ShaderManager:GetInstance():SetImageGray(self.lqBtnImg)
	elseif self.isReward == 1  then  --可领取
		self.red1:SetRedDotParam(true)
		ShaderManager:GetInstance():SetImageNormal(self.lqBtnImg)
	else  --已经领取
		self.red1:SetRedDotParam(false)
		ShaderManager:GetInstance():SetImageGray(self.lqBtnImg)
	end
end

function PeakArenaRankPanel:RankReturnList(data)
	self.data = data
	self.pageIndex = data.page
	local cfg = RankModel:GetInstance():GetRankById(1012)
	local size = cfg.size
	self.maxPage = math.ceil(size / 5) 
	--print2(self.maxPage)
	self:UpdateRankItems(data.list)
	self:UpdateMineInfo(data.mine)
	self:SetPageText(data.page)
	self:SetBtnState()
	self:RankItemClick(1)
end

function PeakArenaRankPanel:SetPageText(page)
	self.pageTex.text = string.format("Page %s/%s",page,self.maxPage)
end

function PeakArenaRankPanel:UpdateMineInfo(mine)
	if mine.rank ~= 0 then
		self.myRankTex2.text = mine.rank
		self.maRankTex.text = "My Ranking:"..mine.rank
	else
		self.myRankTex2.text = "Didn't make list"	
		self.maRankTex.text = "Rank: unranked"
	end
	self.myname.text = self.role.name
	local grade = mine.data.grade
	if grade then
		local cfg = self.model:GetGradeCfg()[grade]
		self.myOrder.text = cfg.name
	else
		self.myOrder.text = self.model:GetGradeCfg()[11].name
	end

	self.mySer.text = "S."..self.role.zoneid
	self.mySoccer.text = mine.sort

	local curGrade = self.model.lastgrade
	if curGrade == 0 then
		self.dayOrderTex.text = "No tier"
		self.dayrewardTex.text = 0
		SetVisible(self.dayOrderIcon,false)
	else
		
		local curCfg = self.model:GetGradeCfg()[curGrade]
		self.dayOrderTex.text = curCfg.name
		local rewardTab = String2Table(curCfg.daily_reward)
		self.dayrewardTex.text = rewardTab[1][2]
		lua_resMgr:SetImageTexture(self, self.dayOrderIcon, "peakArena_image", "PArena_rank"..math.floor(curGrade/10), true, nil, false)
		SetVisible(self.dayOrderIcon,true)
	end
	
	
end

function PeakArenaRankPanel:UpdateRankItems(tab)
	--dump(tab)
	for i = 1, 5 do
		local item = self.rankItems[i]
		if not item then
			item = PeakArenaRankItem(self.PeakArenaRankItem.gameObject,self.rankItemParent,"UI")
			self.rankItems[i] = item
			--item:SetData(tab[i],i)
		--else
			--item:SetData(tab[i],i)
		end
		item:SetData(tab[i],i,self.pageIndex)
	end
end
function PeakArenaRankPanel:RankItemClick(rank)
	for k, v in pairs(self.rankItems) do
		if v.data then
			if v.data.rank == rank then
				v:SetSelect(true)
				self:InitRoleModel(v.data)
				self.modelName.text = v.data.base.name
			else
				v:SetSelect(false)
			end
		end
	end
end

function PeakArenaRankPanel:InitRoleModel(roleData)
	if self.roleMode  then
		self.roleMode:destroy()
	end
	local data = {}
	data.res_id = 11001
	if roleData.base.figure.weapon then
		data.default_weapon = roleData.base.figure.weapon.model
	end
	local config = {}
	config.trans_x = 500
	config.trans_y = 500
	config.trans_offset = {y = 40.46}
	self.roleMode = UIRoleCamera(self.roleModelCon, nil,roleData.base,1,false,1,config,self.layerIndex)
end

function PeakArenaRankPanel:DailyReward(data)
	Notify.ShowText("Claimed")
	self:SetBtnState()
end

