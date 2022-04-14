---
--- Created by  Administrator
--- DateTime: 2019/7/31 16:12
---
PeakArenaMainPanel = PeakArenaMainPanel or class("PeakArenaMainPanel", BaseItem)
local this = PeakArenaMainPanel

function PeakArenaMainPanel:ctor(parent_node, parent_panel)
	self.abName = "peakArena";
	self.image_ab = "peakArena_image";
	self.assetName = "PeakArenaMainPanel"
	self.layer = "UI"
	self.events = {}
	self.gevents = {}
	self.rewards = {}
	self.model = PeakArenaModel:GetInstance()
	self.isFirst = true
	PeakArenaMainPanel.super.Load(self)
end

function PeakArenaMainPanel:dctor()
	self.model:RemoveTabListener(self.events)
	GlobalEvent:RemoveTabListener(self.gevents)
	for k, v in pairs(self.rewards) do
		v:destroy()
	end
	self.rewards = {}
	if self.readypanel  then
		self.readypanel:Close()
	end
	
	if self.red1 then
		self.red1:destroy()
		self.red1 = nil
	end
	if self.red2 then
		self.red2:destroy()
		self.red2 = nil
	end
end

function PeakArenaMainPanel:OnEnable()
	--self.model.isOpenArenaPanel = true
	if self.isFirst == false then
		PeakArenaController:GetInstance():Reques1v1Info()
	end
end

function PeakArenaMainPanel:LoadCallBack()
	self.nodes = {
		"leftTop/orderImg","leftTop/rankRewardBtn",
		"leftTop/orderTex","leftTop/sliderobj/slider","leftTop/sliderobj/sliderNum",
		"down/dayTimesTex","down/reward/rewardSlider","down/dayRewardTex","down/reward/rewardIconParent",
		"down/gxTex","down/gxIcon","down/startBtn","iconObj/rankBtn","iconObj/skillBtn","PeakArenaItem",
		"iconObj/shopBtn","leftTop/helpBtn","down/startBtn/startBtnText",
		
		"showPanel/topObj/topNum","showPanel/downObj/downGrade",
		"showPanel/topObj/topGrade","showPanel/topObj/topIcon",
		"showPanel/downObj/downIcon","showPanel/downObj/downNum","showPanel",
		"showPanel/mask","showPanel/line","showPanel/downObj",
		"showPanel/showBg","buyTimesBtn","rTime",
	}
	self:GetChildren(self.nodes)
	self.orderImg = GetImage(self.orderImg)
	self.orderTex = GetText(self.orderTex)
	self.slider = GetImage(self.slider)
	self.sliderNum = GetText(self.sliderNum)
	self.dayTimesTex = GetText(self.dayTimesTex)
	self.rewardSlider = GetImage(self.rewardSlider)
	self.dayRewardTex = GetText(self.dayRewardTex)
	self.gxTex = GetText(self.gxTex)
	self.gxIcon = GetImage(self.gxIcon)
	self.startBtnText = GetText(self.startBtnText)
	self.startBtnImg = GetImage(self.startBtn)
	self.rTime = GetText(self.rTime)
	self.topNum = GetText(self.topNum)
	self.downGrade = GetText(self.downGrade)
	self.topGrade = GetText(self.topGrade)
	self.topIcon = GetImage(self.topIcon)
	self.downIcon = GetImage(self.downIcon)
	self.downNum = GetText(self.downNum)
	
	self:InitUI()
	self:AddEvent()
	
	
	
	self.red1 = RedDot(self.rankRewardBtn, nil, RedDot.RedDotType.Nor)
	self.red1:SetPosition(68, 17)
	
	self.red2 = RedDot(self.rankBtn, nil, RedDot.RedDotType.Nor)
	self.red2:SetPosition(25, 28)
	
	PeakArenaController:GetInstance():Reques1v1Info()
end

function PeakArenaMainPanel:InitUI()
	self:SetBtnState()
end

function PeakArenaMainPanel:AddEvent()
	
	
	local function callBack()
		--PeakBuyTimesPanel
		if self.model.remain_buy <= 0 then
			Notify.ShowText("You don't have purchase attempt left for today")
			return 
		end
		lua_panelMgr:GetPanelOrCreate(PeakBuyTimesPanel):Open()
	end
	AddClickEvent(self.buyTimesBtn.gameObject,callBack)
	
	local function callBack()
		lua_panelMgr:GetPanelOrCreate(PeakArenaThreePanel):Open(3)
	end
	AddClickEvent(self.rankRewardBtn.gameObject,callBack)
	
	local function callBack()
		lua_panelMgr:GetPanelOrCreate(PeakArenaTowPanel):Open()
	end
	AddClickEvent(self.helpBtn.gameObject,callBack)
	
	local function callBack() --开始匹配
		--local cfg = Config.db_combat1v1_limit
		--self.data.today_join
		PeakArenaController:GetInstance():RequesMatchStart()
		--if self.data.today_join < self.model.maxJoin then
			--PeakArenaController:GetInstance():RequesMatchStart()
		--else
			----local cfg = Config.db_combat1v1_limit
			--local cfg = self.model:GetLimitCfg()
			--for i = 1, #cfg do
				--if self.data.mode == cfg[i].mode and self.data.today_join + 1 >= cfg[i].min and self.data.today_join + 1 <= cfg[i].max then
					--local tab = String2Table(cfg[i].buy) 
					----tab[1][2]
					--local id = tab[1][1]
					--local num = tab[1][2]
					--local str = string.format("当前次数已用完，是否花费%sx%s够买一次挑战次数。",enumName.ITEM[id],num)
					--local function call_back()
						--PeakArenaController:GetInstance():RequestBuyTimes()
					--end
					--Dialog.ShowTwo("提示", str, "确定", call_back, nil, "取消", nil, nil)
					----if  table.isempty(tab) == false or #tab <= 0  then
					----PeakArenaController:GetInstance():RequesMatchStart()
					----else
					----dump(tab)	
					----end
					--break
				--end
				
			--end	
		--end
		
	end
	AddClickEvent(self.startBtn.gameObject,callBack)
	
	local function callBack()  --排名奖励
		lua_panelMgr:GetPanelOrCreate(PeakArenaThreePanel):Open(1)
	end
	
	AddButtonEvent(self.rankBtn.gameObject,callBack)
	
	local function callBack()  --技能
		--lua_panelMgr:GetPanelOrCreate(PeakArenaThreePanel):Open(1)
		OpenLink(140,1)
	end
	
	AddButtonEvent(self.skillBtn.gameObject,callBack)
	
	local function callBack()  --商城
		--lua_panelMgr:GetPanelOrCreate(PeakArenaThreePanel):Open(1)
		UnpackLinkConfig("180@1@3")
	end
	
	AddButtonEvent(self.shopBtn.gameObject,callBack)
	
	local function callBack()
		SetVisible(self.showPanel,false)
	end
	AddClickEvent(self.mask.gameObject,callBack)
	
	local function callBack()
		SetVisible(self.showPanel,true)
	end
	AddClickEvent(self.orderImg.gameObject,callBack)
	AddClickEvent(self.orderTex.gameObject,callBack)
	
	
	local function callBack()
		self:CheckRedPoint()
	end
	self.gevents[#self.gevents +  1] = GlobalEvent:AddListener(PeakArenaEvent.ShowRedPoint,callBack)
	self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.PeakArenaInfo,handler(self,self.PeakArenaInfo))
	self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.MatchStart,handler(self,self.MatchStart))
	self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.WinReward,handler(self,self.WinReward))
	self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.BuyTimes,handler(self,self.BuyTimes))
	self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.PeakArenaItemClick,handler(self,self.PeakArenaItemClick))
	
	--self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.MatchCancel,handler(self,self.MatchCancel))
	--self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.MatchSucc,handler(self,self.MatchSucc))
end


function PeakArenaMainPanel:PeakArenaItemClick(data)
	for k, v in pairs(self.rewards) do
		if v.data.num == data.num then
			v:isShowPanel(true)
		else
			v:isShowPanel(false)
		end
	end
end


function PeakArenaMainPanel:SetSlider()
	
	local curGrade = self.data.grade
	--local cfg = Config.db_combat1v1_grade[curGrade]
	local cfg = self.model:GetGradeCfg()[curGrade]
	local nextId = cfg.nextgrade
	if nextId == 0 then
		self.slider.fillAmount = 1
		self.sliderNum.text = "max"
	else
		local curMaxScore = self.model:GetScoreForGrade()
		local curGrade = self.model:GetGrade()
		
		local lastGrade = self.model:GetGradeCfg()[curGrade].lastgrade
		local curSorre
		if lastGrade ~= 0 then
			local lastCfg = self.model:GetGradeCfg()[lastGrade]
			curSorre = self.model.score - lastCfg.score
			curMaxScore = self.model:GetScoreForGrade() - lastCfg.score
		else
			curSorre = self.model.score
		end
		self.slider.fillAmount = curSorre/curMaxScore
		self.sliderNum.text = string.format("%s/%s",curSorre,curMaxScore)
	end

	--local allScore = self.model.score
	
end

function PeakArenaMainPanel:SetBtnState()
	if ActivityModel:GetInstance():GetActivity(10125) or ActivityModel:GetInstance():GetActivity(10126) then
		self.startBtnText.text = "Match"
		ShaderManager:GetInstance():SetImageNormal(self.startBtnImg)
	else
		self.startBtnText.text = "Unlock at 9:00 PM"
		ShaderManager:GetInstance():SetImageGray(self.startBtnImg)
	end
end

function PeakArenaMainPanel:PeakArenaInfo(data)
	dump(data)
	self.isFirst = false
	self.data = data
	SetVisible(self.buyTimesBtn,not self.model:GetIsLocal())
	self:InitShowPanel()
	self:UpdateInfo()
	self:SetSlider()
	self:CheckRedPoint()
	self:ShowRTime()
end

function PeakArenaMainPanel:ShowRTime()
	--logError(self.data.season_end)
	--logError(os.time())
	local day = TimeManager:GetInstance():GetDifDay(self.data.season_end,os.time())
	if day < 0 then
		day = 0
	end
	self.rTime.text = day
end

function PeakArenaMainPanel:CheckRedPoint()
	--local isRed = false
	--if self.model.daily_reward == 1 then
	--isRed = true
	--end
	--local cfg = Config.db_combat1v1_merit_reward
	--for i = 1, #cfg do
	--if self.model:IsMeritReward(cfg[i].merit) == 0 then
	--isRed = true
	--break
	--end
	--end
	local isRed = false
	--local cfg = Config.db_combat1v1_merit_reward
	local cfg = self.model:GetMeritCfg()
	for i = 1, #cfg do
		if self.model:IsMeritReward(cfg[i].merit) == 0 then
			isRed = true
			break
		end
	end
	
	self.red1:SetRedDotParam(self.model.daily_reward == 1)
	
	self.red2:SetRedDotParam(isRed)
	
	
end

function PeakArenaMainPanel:InitShowPanel()
	local curGrade = self.data.grade
	--local cfg = Config.db_combat1v1_grade[curGrade]
	local cfg = self.model:GetGradeCfg()[curGrade]
	--dump(cfg)
	if not cfg then
		logError("没有当前阶数")
		return
	end
	local rewardTab = String2Table(cfg.win_reward)
	
	
	
	self.topNum.text = "x"..rewardTab[1][2]
	self.topGrade.text = cfg.name
	lua_resMgr:SetImageTexture(self, self.topIcon, "peakArena_image", "PArena_rank"..math.floor(cfg.grade/10), true, nil, false)
	
	
	local nextId = cfg.nextgrade
	if nextId ~= 0 then
		--local nextCfg = Config.db_combat1v1_grade[nextId]
		local nextCfg = self.model:GetGradeCfg()[nextId]
		local rewardTab = String2Table(nextCfg.win_reward)
		self.downNum.text = "x"..rewardTab[1][2]
		self.downGrade.text = nextCfg.name
		lua_resMgr:SetImageTexture(self, self.downIcon, "peakArena_image", "PArena_rank"..math.floor(nextCfg.grade/10), true, nil, false)
		
	else
		SetVisible(self.downObj,false)
		SetVisible(self.line,false)
		SetLocalPositionY(self.showBg, 80)
		SetSizeDeltaY(self.showBg, 178)
	end
	--nextgrade
	
	
end


function PeakArenaMainPanel:UpdateInfo()
	local curGrade = self.data.grade
	--local cfg = Config.db_combat1v1_grade[curGrade]
	local cfg = self.model:GetGradeCfg()[curGrade]
	if not cfg then
		return 
	end
	self.orderTex.text = cfg.name
	lua_resMgr:SetImageTexture(self, self.orderImg, "peakArena_image", "PArena_rank"..math.floor(curGrade/10), false, nil, false)
	self.dayTimesTex.text = "Daily attempts left:"..self.data.remain_join
	self.dayRewardTex.text = "Daily merit earned:"..self.data.today_merit
	self.gxTex.text = self.data.merit
	self:InitWinReward()
end

function PeakArenaMainPanel:InitWinReward()
	--local cfg = Config.db_combat1v1_join_reward
	local cfg = self.model:GetJoinCfg()
	local max = cfg[#cfg].num
	self.rewardSlider.fillAmount = self.data.today_join/max
	
	for i = 1, #cfg do
		--rewardIconParent
		local item = self.rewards[i]
		if not item then
			item = PeakArenaItem(self.PeakArenaItem.gameObject,self.rewardIconParent,"UI")
			self.rewards[i] = item
		end
		item:SetData(cfg[i])
	end
end

--匹配开始
function PeakArenaMainPanel:MatchStart()
	--logError("匹配开始")
	
	self.readypanel = lua_panelMgr:GetPanelOrCreate(PeakArenaReadyPanel):Open()
end

function PeakArenaMainPanel:WinReward(data)
	for k, v in pairs(self.rewards) do
		if v.data.num == data.num then
			v:SetState()
		end
	end
end

function PeakArenaMainPanel:BuyTimes(data)
	self.dayTimesTex.text = "Daily attempts left:"..data.remain_join
end

----取消匹配
--function PeakArenaMainPanel:MatchCancel()
--logError("匹配取消")
--self.readypanel:Close()
--end

----匹配成功
--function PeakArenaMainPanel:MatchSucc()
--logError("匹配成功")
--end


