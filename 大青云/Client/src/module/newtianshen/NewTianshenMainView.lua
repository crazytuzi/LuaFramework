--[[
	新天神
]]

_G.UINewTianshenMain = BaseSlotPanel:new('UINewTianshenMain');

UINewTianshenMain.SlotTotalNum = 6;

UINewTianshenMain.SelectList = {true,true,true,true,true}
function UINewTianshenMain:Create()
	self:AddSWF('newTianShenMain.swf',true,nil);
	self:AddChild(UINewTianshenResp,"resp")
end

function UINewTianshenMain:OnLoaded(objSwf)
	self:GetChild('resp'):SetContainer(objSwf.childPanel)
	for i=0,self.SlotTotalNum - 1 do
		self:AddSlotItem(BaseItemSlot:new(objSwf["fight"..i]),i + 1);
	end
	for i = 1, self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i + 6);
	end
	objSwf.godList.click1 = function(e)
		--自己做一个列表
		if not e.item then
			return
		end
		local pos = UIManager:GetMcPos(e.renderer);
		pos.x = pos.x + 89;
		pos.y = pos.y + 92;
		UINewTianshenOper:Open(NewTianshenModel:GetTianshen(e.item.id), pos)
		TipsManager:Hide()
	end
	objSwf.godList.rollOver1 = function(e)
		if not e.item then
			return
		end
		TipsManager:ShowNewTianshenTips(NewTianshenModel:GetTianshen(e.item.id))
	end
	objSwf.godList.rollOut1 = function(e)
		TipsManager:Hide()
	end
	objSwf.godList.rClick1 = function(e)
		UINewTianshenOper:Hide()
		TipsManager:Hide()
		UIConfirm:Hide()
		if not e.item then
			return
		end
		local tianshen = NewTianshenModel:GetTianshen(e.item.id)
		if not tianshen then
			return
		end

		if not NewTianshenModel:GetNoTianshenPos() or NewTianshenModel:HaveFightByTianshenID(tianshen:GetTianshenID()) then
			local changeTianshen = NewTianshenModel:GetCanChangeTianshen(tianshen)
			if changeTianshen then
				local goFunc = function ()
					if tianshen and changeTianshen then
						NewTianshenController:AskFight(tianshen:GetId(), changeTianshen:GetPos())
					end
				end
				local str = string.format(StrConfig['newtianshen42'], tianshen:GetColor(), tianshen:GetHtmlName(), tianshen:GetColor(), tianshen:GetHtmlZizhi(),
					changeTianshen:GetColor(), changeTianshen:GetHtmlName(), changeTianshen:GetColor(), changeTianshen:GetHtmlZizhi())
				local bLv, bStar = NewTianshenUtil:IsCanAcceptLvAndStar(changeTianshen, tianshen)
				str = str .. '\n'
				if bLv then
					str = str .. '\n' .. StrConfig['newtianshen48']
				end
				if bStar then
					str = str .. '\n' .. StrConfig['newtianshen49']
				end
				UIConfirm:Open(str, goFunc)
				return
			else
				FloatManager:AddNormal(StrConfig['newtianshen107'])
				return
			end
		end
		NewTianshenController:AskFight(tianshen:GetId(), NewTianshenModel:GetNoTianshenPos())
	end
	-- objSwf.fightBtn.click = function()
	-- 	self:OnCardCom()
	-- end
	objSwf.itemGetBtn.click = function()
		if UITianshenBag:IsShow() then
			UITianshenBag:Top()
		else
			UITianshenBag:Show()
		end
	end
	objSwf.itemComBtn.click = function()
		UINewTianshenCompose:Show()
	end
	for i = 0, 5 do
		objSwf['fight' ..i].button.click = function()
			-- self:OnFightBack(i)
			local pos = UIManager:GetMcPos(objSwf['fight' ..i]);
			pos.x = pos.x + 90;
			pos.y = pos.y + 90;
			UINewTianshenOper:Open(NewTianshenModel:GetTianshenByFightSize(i), pos)
		end
		objSwf['fight' ..i].button.rclick = function()
			UIConfirm:Hide()
			UINewTianshenOper:Hide()
			local tianshen = NewTianshenModel:GetTianshenByFightSize(i)
			if tianshen then
				NewTianshenController:AskFight(tianshen:GetId(), -1)
			end
		end
		objSwf['fight' ..i].button.rollOver = function(e)
			local tianshen = NewTianshenModel:GetTianshenByFightSize(i)
			if tianshen then
				TipsManager:ShowNewTianshenTips(tianshen)
			else
				local str = ""
				local openLv = NewTianshenUtil:GetTianshenFightOpenLv(i)
				if MainPlayerModel.humanDetailInfo.eaLevel < openLv then
					str = str .. StrConfig['newtianshen38'] .. StrConfig['newtianshen39'] .. string.format(StrConfig['newtianshen40'], openLv)
				else
					if i == 0 then
						str = str .. StrConfig['newtianshen36']
					else
						str = str .. StrConfig['newtianshen37']
					end
					str = str .. StrConfig['newtianshen39']
				end
				TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightUp)
			end
		end
		objSwf['fight' ..i].button.rollOut = function(e)
			TipsManager:Hide()
		end
	end
	for i = 1, 5 do
		objSwf['quality' ..i].click = function()
			self.SelectList[i] = objSwf['quality' ..i].selected
			self:ShowTianshenList()
		end
	end

	objSwf.btnVipLvUp.click = function() UIVip:Show() end	
	objSwf.btnVipLvUp.rollOver = function(e) 
		local attMap = PublicUtil.GetVipShowPro(NewTianshenUtil:GetAllPro())
		VipController:ShowAttrTips( attMap, UIVipAttrTips.ts,VipConsts.TYPE_SUPREME)
	end
	objSwf.btnVipLvUp.rollOut = function(e) VipController:HideAttrTips() end

	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["newtianshen201"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end
end

function UINewTianshenMain:OnShow()
	self:ShowSelectInfo()
	self:ShowTianshenList()
	self:ShowFightList()
	self:ShowModel()
	self:RegisterTimes()
end

--显示选择框
function UINewTianshenMain:ShowSelectInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	for i = 1, 5 do
		objSwf['quality' ..i].selected = self.SelectList[i]
		objSwf['quality' ..i].htmlLabel = UIStrConfig["newtianshen" ..(i + 3)]
	end
	objSwf.quality5._visible = false
end

--显示出战列表
function UINewTianshenMain:ShowFightList()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = NewTianshenModel:GetFightList()
	local fight = 0
	for i = 0, 5 do
		local vo = {};
		vo.dragType = BagConsts.Drag_Tianshen
		vo.acceptType = tostring(BagConsts.Drag_Tianshen);
		objSwf['fight' ..i].icon._visible = true
		objSwf['fight' ..i].iconLock._visible = false
		if list[i] then
			--设置天神位信息
			NewTianshenUtil:SetTianshenSlot(objSwf['fight' ..i], list[i])
			objSwf['fight' ..i].txt_limitLv.htmlText = ""
			fight = fight + list[i]:GetFightValue()
			vo.pos = list[i]:GetPos()
			vo.hasTianshen = true
			vo.iconUrl =  list[i]:GetIcon()

		else
			NewTianshenUtil:SetTianshenSlot(objSwf['fight' ..i])
			--判断天神位开启情况
			local openLv = NewTianshenUtil:GetTianshenFightOpenLv(i)
			if MainPlayerModel.humanDetailInfo.eaLevel < openLv then
				objSwf['fight' ..i].txt_limitLv.htmlText = openLv ..StrConfig['newtianshen43']
				objSwf['fight' ..i].iconLock._visible = true
			else
				objSwf['fight' ..i].txt_limitLv.htmlText = StrConfig['newtianshen45']
			end
			vo.hasTianshen = false
			vo.pos = i;
		end
		objSwf['fight' .. i]:setData(UIData.encode(vo));
	end
	objSwf.fightLoader.num = fight
end

--显示列表
function UINewTianshenMain:ShowTianshenList()
	local objSwf = self.objSwf
	self.tianshenList = {}
	for k, v in pairs(NewTianshenModel:GetTianshenList()) do
		local quality = v:GetQuality()
		if v:GetPos() == -1 and self.SelectList[quality + 1] then
			local vo = {}
			vo.name = string.format("<font color='%s'>%s</font>", TipsConsts:GetItemQualityColor(v:GetShowQuality()), v:GetName())
			vo.lv = v:GetLv() .. "级"
			vo.zizhi = "" --"资质：" .. v:GetZizhi()
			vo.nZiZhi = v:GetZizhi()
			vo.fight = "战斗力：" .. string.format("<font color = '#ffffff''>%s</font>", v:GetFightValue())
			vo.headUrl = v:GetIcon()
			vo.id = v:GetId()
			vo.star = "+" .. v:GetStar()
			vo.quality = quality + 1
			vo.isNew = NewTianshenModel.newList[v:GetId()] and true or false
			vo.bFight = NewTianshenModel:IsMoreFight(v)
			vo.dragType = BagConsts.Drag_Tianshen;
			vo.iconUrl = v:GetIcon()
			vo.bagType = BagConsts.Drag_Tianshen
			vo.acceptType = tostring(BagConsts.Drag_Tianshen);
			vo.open = true
			table.insert(self.tianshenList, vo)
		end
	end
	table.sort(self.tianshenList, function(a, b)
		return a.nZiZhi > b.nZiZhi
	end)
	objSwf.godList.dataProvider:cleanUp()
	for k, v in pairs(self.tianshenList) do
		objSwf.godList.dataProvider:push(UIData.encode(v))
	end
	objSwf.godList:invalidateData()
end

--出战列表返回
function UINewTianshenMain:OnFightBack(i)
	local tianshen = NewTianshenModel:GetTianshenByFightSize(i)
	if tianshen then
		NewTianshenController:AskFight(tianshen:GetId(), -1)
	end
end

--模型展示
function UINewTianshenMain:ShowModel()
	local objSwf = self.objSwf;
	if not objSwf then return end 
	
	local tianshen = NewTianshenModel:GetTianshenByFightSize(0)
	if not tianshen then
		objSwf.icon._visible = false
		objSwf.iconName._visible = false
		return
	end
	objSwf.iconName._visible = true
	if objSwf.iconName.source ~= tianshen:GetMainNameIcon() then
		objSwf.iconName.source = tianshen:GetMainNameIcon()
	end
	objSwf.icon._visible = true
	objSwf.icon._x = -1200
	objSwf.icon._y = -600

	if not self.objUIDraw then
		local viewPort = _Vector2.new(4000, 2000)
		self.objUIDraw = UISceneDraw:new( "UINewTianshenMain", objSwf.icon, viewPort )
	else
		self.objUIDraw:SetUILoader(objSwf.icon)
	end
	self.objUIDraw:SetScene(tianshen:GetScene(), function() self:PlayAnimal() end)
	-- 模型旋转
	self.objUIDraw:SetDraw(true)
end

function UINewTianshenMain:PlayAnimal()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.objUIDraw then return end
	local tianshen = NewTianshenModel:GetTianshenByFightSize(0)
	if not tianshen then return end
	local cfg = t_bianshenmodel[tianshen:GetCfg().model]
	if not cfg then return end
	
	self.objUIDraw:NodeAnimation(cfg.skn_ui, cfg.bianshen_idle)
end

function UINewTianshenMain:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
	end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil
	end
	UINewTianshenOper:Hide()
	NewTianshenModel.newList = {}
end

function UINewTianshenMain:OnDelete()
	self:RemoveAllSlotItem();
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

---打开天神卡合成界面
function UINewTianshenMain:OnCardCom()
	if UINewTianshenCompose:IsShow() then
		UINewTianshenCompose:Top()
	else
		UINewTianshenCompose:Show()
	end
end

function UINewTianshenMain:ListNotificationInterests()
	return {NotifyConsts.tianShenOutUpdata,NotifyConsts.tianShenDisUpdata,NotifyConsts.newtianShenUpUpdata,NotifyConsts.tianShenRespUpdata,NotifyConsts.PlayerAttrChange}
end

function UINewTianshenMain:HandleNotification(name,body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:ShowTianshenList()
			self:ShowFightList()
		end
	elseif name == NotifyConsts.tianShenOutUpdata then
		if body[1] == 0 or not NewTianshenModel:GetTianshenByFightSize(0) then
			self:ShowModel()
		end
	end
	self:ShowTianshenList()
	self:ShowFightList()
end

function UINewTianshenMain:InitSmithingRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return end
	
	for i = 0, 5 do
		if NewTianshenUtil:IsCanStarUpBySize(i) or NewTianshenUtil:IsCanLvupBySize(i) then
			PublicUtil:SetRedPoint(objSwf['fight' ..i], nil, 1, nil, nil, 90, 0)
		else
			PublicUtil:SetRedPoint(objSwf['fight' ..i], nil, 0, nil, nil, 90, 0)
		end
	end
end

function UINewTianshenMain:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:InitSmithingRedPoint()
	end,1000,0); 
	self:InitSmithingRedPoint()
end

--开始拖拽
function UINewTianshenMain:OnItemDragBegin(item)
	--print("开始拖拽")
end;
-- 拖拽结束
function UINewTianshenMain:OnItemDragEnd(item)
	--print("拖拽结束")
end;
-- 拖拽中
function UINewTianshenMain:OnItemDragIn(fromData,toData)
	UINewTianshenOper:Hide()
	--print("拖拽中")
	if fromData.open then
		-- 列表拖到装备位
		if fromData.bagType ~= BagConsts.Drag_Tianshen or toData.bagType then
			return
		end
		local tianshen = NewTianshenModel:GetTianshen(fromData.id)
		if not tianshen then
			return
		end
		local pos = toData.pos
		local changeTianshen = NewTianshenModel:GetTianshenByFightSize(pos)
		if NewTianshenModel:HaveFightByTianshenID(tianshen:GetTianshenID()) then
			changeTianshen = NewTianshenModel:GetCanChangeTianshen(tianshen)
		end
		if not changeTianshen then
			NewTianshenController:AskFight(tianshen:GetId(), pos)
		else
			local goFunc = function ()
				if tianshen and changeTianshen then
					NewTianshenController:AskFight(tianshen:GetId(), changeTianshen:GetPos())
				end
			end
			local str = string.format(StrConfig['newtianshen42'], tianshen:GetColor(), tianshen:GetHtmlName(), tianshen:GetColor(), tianshen:GetHtmlZizhi(),
			changeTianshen:GetColor(), changeTianshen:GetHtmlName(), changeTianshen:GetColor(), changeTianshen:GetHtmlZizhi())
			local bLv, bStar = NewTianshenUtil:IsCanAcceptLvAndStar(changeTianshen, tianshen)
			str = str .. '\n'
			if bLv then
				str = str .. '\n' .. StrConfig['newtianshen48']
			end
			if bStar then
				str = str .. '\n' .. StrConfig['newtianshen49']
			end
			UIConfirm:Open(str,goFunc)
		end
	elseif fromData.hasTianshen then
		if toData.bagType == BagConsts.Drag_Tianshen then
			--下阵
			local tianshen = NewTianshenModel:GetTianshenByFightSize(fromData.pos)
			if not tianshen then return end
			NewTianshenController:AskFight(tianshen:GetId(), -1)
		else
			-- 天神位之间替换
			local tianshen = NewTianshenModel:GetTianshenByFightSize(fromData.pos)
			if not tianshen then
				return
			end
			local toTianshen = NewTianshenModel:GetTianshenByFightSize(toData.pos)
			if not toTianshen then
				NewTianshenController:AskFight(tianshen:GetId(), -1)
				NewTianshenController:AskFight(tianshen:GetId(), toData.pos)
				return
			else
				NewTianshenController:AskFight(toTianshen:GetId(), -1)
				NewTianshenController:AskFight(tianshen:GetId(), -1)
				NewTianshenController:AskFight(tianshen:GetId(), toData.pos)
				NewTianshenController:AskFight(toTianshen:GetId(), fromData.pos)
			end
		end
	else
		--这里暂时不管它是什么玩意
		return
	end
end;