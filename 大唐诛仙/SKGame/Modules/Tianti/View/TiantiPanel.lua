TiantiPanel = BaseClass(BaseView)

function TiantiPanel:__init( ... )
	self.ui = UIPackage.CreateObject("Tianti","TiantiPanel")
	self.c1 = self.ui:GetController("c1")
	self.c2 = self.ui:GetController("c2")
	self.c3 = self.ui:GetController("c3")
	self.c4 = self.ui:GetController("c4")
	self.bg = self.ui:GetChild("bg")
	self.levelLogo = self.ui:GetChild("levelLogo")
	self.icon_title = self.ui:GetChild("icon_title")
	self.bottom = self.ui:GetChild("bottom")
	self.top = self.ui:GetChild("top")
	self.rankUI = self.ui:GetChild("rankUI")
	self.infoUI = self.ui:GetChild("infoUI")
	self.btnOpenInfo = self.ui:GetChild("btnOpenInfo")
	self.btnOpenRank = self.ui:GetChild("btnOpenRank")
	self.t0 = self.ui:GetTransition("t0")
	self.t1 = self.ui:GetTransition("t1")
	self.t2 = self.ui:GetTransition("t2")
	self.t3 = self.ui:GetTransition("t3")
	self.btnMatch = self.ui:GetChild("btnMatch")
	self.txtMatch = self.ui:GetChild("txtMatch")
	self.imgMatching = self.ui:GetChild("imgMatching")
	self.txtFinding = self.ui:GetChild("txtFinding")
	self.btnLingqu = self.bottom:GetChild("btnLingqu")
	self.txtRewardNum = self.top:GetChild("txtRewardNum")
	self.tipsBtn = self.ui:GetChild("tipsBtn")

	self:Config()
	self:InitEvent()
end
function TiantiPanel:Config()
	self.id = "TiantiPanel"
	self.openTopUI = true -- 打开顶部资产UI
	self.useFade = true -- 开启淡化效果

	self.rootRes = "Icon/Tianti/"
	self.model = TiantiModel:GetInstance()
	self.bgUrl = self.rootRes.."1"
	self.bg.url = self.bgUrl
	self.icon_title.url = "Icon/Title/A1"
	-- self.starBar = self.bottom:GetChild("starBar")

	-- 积分进度光点
	-- self.light = self.starBar:GetChild("light")
	-- self.lightMask = self.starBar:GetChild("bar")
	-- self.lightRotCenter = Vector2.New((self.starBar.width-self.light.width)*0.5, (self.starBar.height-self.light.height)*0.5)
	-- self.lightR = 58

	self.rankList = {}
	self.stars = {}
	self.curSelected = nil

	local owner = self.rankUI:GetChild("owner")
	self.owner = TiantiOwnerRankItem.Create(owner)


	self.listConn = self.rankUI:GetChild("listConn")
	self.resourceH = self.listConn.height
	self.totalH = self.resourceH -- 滚动总高度
	self.listConn.scrollPane.inertiaDisabled = false
	self.listConn.scrollPane.onScrollEnd:Add(function (e)
		if e.sender.isBottomMost then
			self.model:DispatchEvent(TiantiConst.GET_RANKDATA)
		end
	end)
	self.levelLogo = TiantiLevelLogo.Create(self.levelLogo)
	self.matchPastTime = 0

	self:CleanDescTipsUI()
end
function TiantiPanel:Update()
	-- 由model数据 更新种个组件(信息及排行数据)
	local model = self.model
	self:UpdateInfo()
	self:UpdateRank()
	self:RefreshMatchArea()
end

function TiantiPanel:UpdateInfo()
	local model = self.model
	local infoData = model:GetInfo()
	local txt = nil
	infoData.killNum = infoData.killNum or 0
	infoData.deadNum = infoData.deadNum or 0
	infoData.startTime = infoData.startTime or 0
	infoData.endTime = infoData.endTime or 0
	infoData.star = infoData.star or 0
	infoData.stage = infoData.stage or 1
	local img = self.infoUI:GetChild("icon")
	txt = self.infoUI:GetChild("t2") -- 胜利
	txt.text = StringFormat("胜利: {0}", infoData.killNum)
	txt = self.infoUI:GetChild("t4") -- 失败
	txt.text = StringFormat("失败: {0}", infoData.deadNum)
	txt = self.infoUI:GetChild("t3") -- 胜率
	local v = 0
	if infoData.deadNum + infoData.killNum ~= 0 then
		v = infoData.killNum / (infoData.deadNum + infoData.killNum)
	-- elseif infoData.killNum ~= 0 then
	-- 	v = infoData.killNum
	end
	txt.text = StringFormat("胜率：{0}", string.format("%d%%", math.floor(v * 100) ))
	txt = self.infoUI:GetChild("t7") -- 积分
	txt.text = StringFormat("积分: {0}", self.model:GetCurScore())

	txt = self.infoUI:GetChild("t6") -- 时间
	v = "赛季即将开启，敬请期待!"
	local v2 = "本赛季时间"
	if infoData.startTime == 0 or infoData.endTime == 0 then
	elseif infoData.endTime > TimeTool.GetCurTime() and infoData.startTime < TimeTool.GetCurTime() then
		v = StringFormat("{0}--{1}", TimeTool.GetTimeYMD(infoData.startTime), TimeTool.GetTimeYMD(infoData.endTime))
	elseif TimeTool.GetCurTime() > infoData.startTime then
		v2 = "下一赛季时间"
		v = StringFormat("{0}--{1}", TimeTool.GetTimeYMD(infoData.startTime), TimeTool.GetTimeYMD(infoData.endTime))
	end
	txt.text = StringFormat("{0}", v)
	self.infoUI:GetChild("t5").text = v2 -- 标题
	local cur, total = self.model:GetScoreInfo()
	if total == 0 then
		total = 100
	end
	self.levelLogo.txtJifen.text = StringFormat("{0}/{1}", cur, total)
	self.levelLogo.iconDuanwei.url = UIPackage.GetItemURL("Tianti", TiantiConst.IconDuanweiTab[infoData.stage])
	self.levelLogo.imgJindu.fillAmount = cur / total
	self.levelLogo.icon.url = self.rootRes.."dwicon0"..(infoData.stage or 1)
	local conn = self.levelLogo
	local star = nil
	local pos = {0, 0}
	self:DestroyStars()
	self.stars = {}
	local maxStar = self.model:GetMaxStar()
	if #self.stars > maxStar then
		for i=1, #self.stars-maxStar do
			star = table.remove(self.stars, #self.stars)
			destroyUI( star )
		end
	end
	if infoData.stage == 6 then
		if self.stars[1] then
			star = self.stars[1]
			if #self.stars > 1 then
				for i=#self.stars, 2, -1 do
					star = table.remove(self.stars, #self.stars)
					destroyUI( star )
				end
			end
		else
			star = UIPackage.CreateObject("Tianti" , "TiantiStar")
			conn:AddChild(star)
			table.insert(self.stars, star)
		end
		if not self.starLabel then
			txt = createText( "", 174, 54, 100, 48, 48, nil, nil, nil, nil, nil, conn )
			setTxtAutoSizeType( txt, 1 )
			setTxtAlignType( txt, 1 )
			self.starLabel = txt
		end
		self.starLabel.text = StringFormat(" *{0}", infoData.star)

		star:GetController("c1").selectedIndex = 2
		pos = TiantiConst.starPos[1]
		star:SetXY(pos[1]-63, pos[2]-15)
		star:SetScale(2, 2) 
	else
		if self.starLabel then
			destroyUI( self.starLabel )
			self.starLabel = nil
		end
		local tab = {}
		for i=1, maxStar do
			tab[i] = {}
			if self.stars[i] then
				star = self.stars[i]
			else
				star = UIPackage.CreateObject("Tianti" , "TiantiStar")
				conn:AddChild(star)
			end
			tab[i].star = star
			if infoData.star < i then
				tab[i].selectedIndex = 0
				--star:GetController("c1").selectedIndex = 0
			else
				tab[i].selectedIndex = 1
				--star:GetController("c1").selectedIndex = 1
			end
			tab[i].pos = TiantiConst.starPos[i]
			--star:SetXY(pos[1], pos[2])
			self.stars[i] = star
		end
		table.sort(tab, function(a, b)
			return a.pos[1] < b.pos[1]
		end)
		local num = #tab
		local isEven = num % 2 == 0
		for i = 1, num do
			local star = tab[i].star
			if infoData.star < i then
				star:GetController("c1").selectedIndex = 0
			else
				star:GetController("c1").selectedIndex = 1
			end
			if isEven then
				local posTab = TiantiConst.starPosEven2
				if num == 4 then
					posTab = TiantiConst.starPosEven4
				end
				star:SetXY(posTab[i][1], posTab[i][2])
			else
				star:SetXY(tab[i].pos[1], tab[i].pos[2])
			end
		end
	end
	self:RefreshMatchArea()
	self:UpdateRankReward()
	self:UpdateChongfengReward()
end

function TiantiPanel:DestroyStars()
	if not self.stars then return end
	for _, v in pairs(self.stars) do
		if v then 
			destroyUI(v)
		end
	end
	self.stars = nil
end

function TiantiPanel:UpdateRankReward()
	self:DestroyRankAwardIcons()
	self.rankAwardIcons = {}
	local conn = self.bottom:GetChild("awardContainerLeft")
	if conn.numChildren ~= 0 then
		conn:RemoveChildren(0, -1, true)
	end
	local rewards = self.model:GetRankRewardInfo()
	if rewards then
		for i, v in ipairs(rewards) do
			local icon = PkgCell.New(conn)
			icon:SetXY(i*100, 10)
			icon:OpenTips(true)
			icon:SetDataByCfg(v[1], v[2], v[3], v[4])
			table.insert(self.rankAwardIcons, icon)
		end
	end
end

function TiantiPanel:UpdateChongfengReward()
	local showStage, state = self.model:GetChongfengRewardInfo()
	local data = self.model:GetCFRewardData(showStage)
	local isFull = false
	if (not data) or (not data.stageReward) then
		isFull = true
		showStage = showStage - 1
		data = self.model:GetCFRewardData(showStage)
	end
	self.showStage = showStage
	local rewards = data.stageReward or {}
	local title4 = self.bottom:GetChild("title4")
	--local stageData = self.model:GetStageCfg(showStage) or {}
	title4.text = StringFormat("达到{0}可领取", data.des)
	local conn = self.bottom:GetChild("awardContainer")
	self:DestroyCFAwardIcons()
	self.cfAwardIcons = {}
	if conn.numChildren ~= 0 then
		conn:RemoveChildren(0, -1, true)
	end
	if rewards then
		for i, v in ipairs(rewards) do
			local icon = PkgCell.New(conn)
			icon:SetXY(i*100, 10)
			icon:OpenTips(true)
			icon:SetDataByCfg(v[1], v[2], v[3], v[4])
			table.insert(self.cfAwardIcons, icon)
		end
	end
	if state == TiantiConst.CF_REWARD_STATE.CAN_GET and #rewards > 0 then
		self.btnLingqu:GetChild("icon").grayed = false
		self.btnLingqu.touchable = true
		self.btnLingqu:GetChild("title").color = newColorByString( "000000" )
	else
		self.btnLingqu:GetChild("icon").grayed = true
		self.btnLingqu.touchable = false
		self.btnLingqu:GetChild("title").color = newColorByString( "999999" )
	end
	local num1, num2 = self.model:GetFightTimesInfo()
	self.txtRewardNum.text = StringFormat("战斗奖励: {0}/{1}", num1, num2)

	if isFull then
		conn.visible = false
		self.btnLingqu.visible = false
		title4.text = "已获取所有奖励"
		title4:SetXY(670, 90)
	else
		conn.visible = true
		self.btnLingqu.visible = true
		title4:SetXY(800, 40)
	end
end

function TiantiPanel:DestroyRankAwardIcons()
	if not self.rankAwardIcons then return end
	for _, v in pairs(self.rankAwardIcons) do
		if v then 
			v:Destroy()
			v = nil
		end
	end
	self.rankAwardIcons = nil
end

function TiantiPanel:DestroyCFAwardIcons()
	if not self.cfAwardIcons then return end
	for _, v in pairs(self.cfAwardIcons) do
		if v then 
			v:Destroy()
			v = nil
		end
	end
	self.cfAwardIcons = nil
end

function TiantiPanel:CreateAwardIcon(conn, x, y, res, rare)
	local ui = UIPackage.CreateObject("Common" , "AwardIcon")
	conn:AddChild(ui)
	ui.x = x
	ui.y = y
	ui.icon = res
	ui:GetChild("bg").url = "Icon/Common/grid_cell_"..(rare or 0)
	return ui
end
-- function TiantiPanel:UpdateJifen()
-- 	local model = self.model
-- 	local infoData = model:GetInfo()
-- 	local starBar = self.starBar
-- 	local angel = -self.lightMask.fillAmount*GameConst.PI2
-- 	self.light.x = self.lightRotCenter.x + math.sin(angel)*self.lightR
-- 	self.light.y = self.lightRotCenter.y + math.cos(angel)*self.lightR+5
-- end
function TiantiPanel:UpdateRank()
	local model = self.model
	local infoData = model:GetInfo()
	
	local my = SceneModel:GetInstance():GetMainPlayer()
	local cfg = model:GetStageCfg(infoData.stage or 1)
	local txt = self.owner:GetChild("order")
	local rank, font = model:GetRankChar(model:GetMyRank(), true)
	setTxtFontOrSize(txt, font)
	txt.text = rank
	txt = self.owner:GetChild("txtLv1")
	txt.text = StringFormat("等级 {0}", my.level)
	txt = self.owner:GetChild("txtLv2")
	txt.text = StringFormat("{0}段位", cfg.stageName)
	txt = self.owner:GetChild("txtName")
	txt.text = my.name
	txt = self.owner:GetChild("txtCareer")
	txt.text = GetCfgData("newroleDefaultvalue"):Get(my.career).careerName or "??"
	txt = self.owner:GetChild("txtStarNum")
	txt.text = StringFormat("x{0}", infoData.star or 0)
	local icon = self.owner:GetChild("icon")
	icon.url = self.rootRes.."dwicon1"..(infoData.stage or 1)
	local ui = self.owner:GetChild("headComp")
	ui.icon = "Icon/Head/r"..my.career
	self:RenderRankUI()
end
function TiantiPanel:RenderRankUI()
	local rankListData = self.model:GetRankPageList()
	local item = nil
	local cellH = 107
	local offH = 3
	local cH = cellH + offH
	self.totalH = #rankListData*cH - offH

	if #self.rankList > #rankListData then
		local more = #self.rankList - #rankListData
		for i=1, more do
			item = table.remove(self.rankList, #self.rankList)
			if self.curSelected == item then
				self.curSelected = nil
			end
			item:Destroy()
		end
	end
	for i=1,#rankListData do -- if i== 6 then break end
		local vo = rankListData[i]
		item = self.rankList[i]
		if item then
			item:Update(vo)
		else
			item = TiantiItem.New(vo, function ( obj )
				if self.curSelected ~= obj then
					if self.curSelected then
						self.curSelected.c1.selectedIndex = 0
					end
					self.curSelected = obj
					obj.c1.selectedIndex = 1
					-- print("显示其他作用>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
				end
			end)
			self.rankList[i] = item
			item:AddTo(self.listConn)
			item:SetXY(0, (i-1)*cH)
		end
	end
end

function TiantiPanel:InitEvent()
	self.closeCallback = function () -- 关闭时重置
		self.c1.selectedIndex = 0
		self.c2.selectedIndex = 0
		self.c3.selectedIndex = 0
		self.c4.selectedIndex = 0
		if self.curSelected then
			self.curSelected.c1.selectedIndex = 0
			self.curSelected = nil
		end
		if self.rankList then
			for i=1,#self.rankList do
				self.rankList[i]:Destroy()
			end
		end
		self.rankList = {}
		if self.model then
			self.model:ClearRankData()
		end

		self.descTipsUI = nil
	end
	self.openCallback  = function () -- 打开时刷新
		local openType = self.model.openType
		if openType == 1 then
			self.c1.selectedIndex = 1
		elseif openType == 2 then
			self.c2.selectedIndex = 1
		end
		self:Update()
	end
	local btnClose = self.top:GetChild("close")
	btnClose.onClick:Add(function ()
		self:Close()
	end)
	self.c1.onChanged:Add(function ( e )
		-- local bgRes = self.bgUrl
		if self.c1.selectedIndex == 1 then
			if self.model:GetCurNum() <= TiantiConst.offset then -- 如果数量少了，请求
				self.model:DispatchEvent(TiantiConst.GET_RANKDATA)
			end
			self.c3.selectedIndex = 0
			self.c4.selectedIndex = 0
			-- bgRes = self.rootRes.."bg1"
		else
			if self.c2.selectedIndex == 0 then
				self.c3.selectedIndex = 0
				self.c4.selectedIndex = 0
			end
			-- bgRes = self.rootRes.."bg0"
		end
		-- if self.bgUrl ~= bgRes then
		-- 	self.bgUrl = bgRes
		-- 	self.bg.url = bgRes
		-- end
		self.levelLogo:SetVisible(self.c1.selectedIndex ~= 1)
		self.icon_title.visible = self.c1.selectedIndex ~= 1
	end)
	self.c2.onChanged:Add(function (e)
		if self.c2.selectedIndex == 1 then -- 每次打开时请求，刷新信息
			-- self.model:DispatchEvent(TiantiConst.GET_INFO)
			self.c3.selectedIndex = 0
			self.c4.selectedIndex = 0
		else
			if self.c1.selectedIndex == 0 then
				self.c3.selectedIndex = 0
				self.c4.selectedIndex = 0
			end
		end
	end)
	self.btnMatch.onClick:Add(function()
		self:OnBtnMatchClick()
	end)
	self.btnLingqu.onClick:Add(function()
		self:OnBtnLingquClick()
	end)

	-- self.tipsBtn.onClick:Add(function()
	-- 	local descPanel = DescPanel.New()
	-- 	descPanel:SetContent(4)
	-- 	UIMgr.ShowPopup(descPanel, false, 0, 0, function()
	-- 		UIMgr.HidePopup()
	-- 	end)
	-- end, self)

	self.tipsBtn.onClick:Add(self.OnTipsBtnClick ,self)

	local function onMatchChange()
		self:RefreshMatchArea()
	end
	self.handler1 = self.model:AddEventListener(TiantiConst.E_MATCH_STATE_CHANGE, onMatchChange)
	local function cfRewardChange()
		self:UpdateChongfengReward()
	end
	self.handler2 = self.model:AddEventListener(TiantiConst.E_CF_REWARD_UPDATE, cfRewardChange)
	self.handler3 = self.model:AddEventListener(TiantiConst.E_MATCH_ENTER, function()
		if self.model then
			self.model:SetMatchState(1)
		end
	end)
end

function TiantiPanel:RemoveEvents()
	if self.model then
		self.model:RemoveEventListener(self.handler1)
		self.model:RemoveEventListener(self.handler2)
		self.model:RemoveEventListener(self.handler3)
	end
end

-- Dispose use TiantiPanel obj:Destroy()
function TiantiPanel:__delete()
	self:RemoveEvents()
	self:RemoveMatchingTimer()
	self:DestroyRankAwardIcons()
	self:DestroyCFAwardIcons()
	self:DestroyStars()
	self:SetMatch(false)
	if self.owner then
		self.owner:Destroy()
	end
	if self.levelLogo then
		self.levelLogo:Destroy()
	end
	if self.starLabel then
		destroyUI( self.starLabel )
		self.starLabel = nil
	end
	self.levelLogo = nil
	self.curSelected = nil
	self.owner = nil

end

function TiantiPanel:OnTipsBtnClick()
	if self.descTipsUI == nil then
		self.descTipsUI = DescPanel.New()
	end

	self.descTipsUI:SetContent(4)

	UIMgr.ShowPopup(self.descTipsUI, false, 0, 0, function()
		if self.descTipsUI ~= nil then
			UIMgr.HidePopup(self.descTipsUI.ui)
			self:CleanDescTipsUI()
		end
	end)
end

function TiantiPanel:CleanDescTipsUI()
	self.descTipsUI = nil
end

function TiantiPanel:OnBtnMatchClick()
	-- if not self.model:IsOpen() then
	-- 	UIMgr.Win_FloatTip("不在活动期间")
	-- 	return
	-- end
	if SceneModel:GetInstance():GetSceneId() ~= SceneConst.MainCitySceneId then
		UIMgr.Win_FloatTip("不在主城中无法进行匹配")
		return
	end
	local num1, _ = self.model:GetFightTimesInfo()
	if num1 <= 0 then
		UIMgr.Win_FloatTip("战斗奖励次数已满，继续匹配只能改变积分！")
	end
	--local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
	--local zdModel = ZDModel:GetInstance()
	--if mainPlayer.teamId == 0 then
		local state = self.model:GetMatchState()
		local ctrl = TiantiController:GetInstance()
		if state == 0 then
			self:SetMatch(true)
		else
			self:SetMatch(false)
		end
	-- else
	-- 	UIMgr.Win_FloatTip("只有未组队，或者队伍只有自己一个人的情况下，才可匹配")
	--end
end

function TiantiPanel:OnBtnLingquClick()
	TiantiController:GetInstance():C_GetStageReward(self.showStage or 1)
end

function TiantiPanel:SetMatch(bool)
	local ctrl = TiantiController:GetInstance()
	if bool then
		ctrl:C_Match()
		--self.model:SetMatchState(1)
	else
		local state = self.model:GetMatchState()
		if state == 1 then
			ctrl:C_CancelMatch()
			self.model:SetMatchState(0)
		end
	end
end

function TiantiPanel:RefreshMatchArea()
	local state = self.model:GetMatchState()
	self:RemoveMatchingTimer()
	if state == 0 then
		self.txtMatch.url = UIPackage.GetItemURL("Tianti", "pipeizhandou")
		self.imgMatching.visible = false
		self.txtFinding.visible = false
	else
		self.txtMatch.url = UIPackage.GetItemURL("Tianti", "quxiaopipei")
		self.imgMatching.visible = true
		self.txtFinding.visible = true
		self:StartMatchingTimer()
	end
end

function TiantiPanel:StartMatchingTimer()
	local function timerUpdate()
		self.matchPastTime = self.matchPastTime + 1
		self:SetPastTime(self.matchPastTime)
	end
	RenderMgr.AddInterval(timerUpdate, "TiantiPanel_timer1", 1)
end

function TiantiPanel:RemoveMatchingTimer()
	self.matchPastTime = 0
	self:SetPastTime(0)
	RenderMgr.Realse("TiantiPanel_timer1")
end

function TiantiPanel:SetPastTime(tm)
	self.txtFinding.text = StringFormat("寻找对手中......( {0}s )", tm)
end