--[[
星图面板
yujia
]]

_G.UIXingtu = BaseUI:new("UIXingtu");

UIXingtu.showPage = 1;

UIXingtu.showIndex = 1;

UIXingtu.isAuto = false;

UIXingtu.timerKey = nil;
local s_skl = {"v_qinglong", "v_baihu", "v_zhuqueyingying", "v_xuanwu"}
local s_playerSkl = {"v_xingtu_qinglong_fmt", "v_xingtu_baihu_fmt", "v_xingtu_zhuque_fmt", "v_xingtu_xuanwu_fmt"}
local s_animal = {"v_xingtu_qinglong_xiuxian.san", "v_xingtu_baihu_xiuxian.san", "v_xingtu_zhuque_xiuxian.san", "v_xingtu_xuanwu_xiuxian.san"}

local s_animal2 = {"v_xingtu_qinglong_zhanshi.san", "v_xingtu_baihu_zhanshi.san", "v_xingtu_zhuque_zhanshi.san", "v_xingtu_xuanwu_zhanshi.san"}
local s_StarPfx = {
	[1] = {"v_xingtu_lanse_dianliang.pfx", "v_xingtu_lanse_ximie.pfx", "v_xingtu_lanse_xuanzhong.pfx"},
	[2] = {"v_xingtu_zise_dianliang.pfx", "v_xingtu_zise_ximie.pfx", "v_xingtu_zise_xuanzhong.pfx"},
	[3] = {"v_xingtu_chengse_dianliang.pfx", "v_xingtu_chengse_ximie.pfx", "v_xingtu_chengse_xuanzhong.pfx"},
}

function UIXingtu:Create()
	self:AddSWF("xingtu.swf", true, "center");
end

function UIXingtu:OnLoaded(objSwf)
	self:RegisterEventHandler(objSwf);
end

function UIXingtu:RegisterEventHandler(objSwf)
	objSwf.btn_close.click       = function() self:Hide() end

	for i = 1, 4 do
		objSwf["PageBtn" ..i].click = function() self:clearStarTime() self:InitGreenPoint() self:OnPageClick(i) end
	end
	for i = 1, 7 do
		objSwf["item" ..i].click = function() self:PlayAnimal() self:InitGreenPoint() self:clearStarTime() self:OnIndexClick(i) end
	end

	objSwf.curInfo.btn_lvUpAuto.click = function() self:OnLvUpClick(true) end
	objSwf.curInfo.btn_lvUp.click = function() self:OnLvUpClick(nil, true) end
	objSwf.curInfo.btn_lvUp.rollOver = function() self:OnbtnrollOver() end
	objSwf.curInfo.btn_lvUp.rollOut = function() self:OnbtnrollOut() end
	objSwf.panelBtn.rollOver = function() 
		local  pro = XingtuUtil:GetAllPro()
		local nValue = 0
		for k, v in pairs(pro) do
			nValue = nValue + 1
		end
		if nValue == 0 then
			return
		end
		PublicUtil:ShowProTips(XingtuUtil:GetAllPro(), TipsConsts.Dir_RightDown) 
	end
	objSwf.panelBtn.rollOut = function() TipsManager:Hide() end
	objSwf.curInfo.btn_lvUpAuto.rollOver = function() self:OnbtnrollOver() end
	objSwf.curInfo.btn_lvUpAuto.rollOut = function() self:OnbtnrollOut() end

	self.slot = {}
	for i = 1, 7 do
		table.push(self.slot, objSwf["txt_pro" ..i])
	end
	objSwf.btnVipLvUp.click = function() UIVip:Show() end	
	objSwf.btnVipLvUp.rollOver = function(e) 
		local attMap = PublicUtil.GetVipShowPro(XingtuUtil:GetAllPro())
		VipController:ShowAttrTips( attMap, UIVipAttrTips.xt,VipConsts.TYPE_SUPREME)
	end
	objSwf.btnVipLvUp.rollOut = function(e) VipController:HideAttrTips() end
end

function UIXingtu:OnShow()
	self:ResetShowPageAndIndex()
	self:initPageBtn()
	self:ShowXingtuList()
	self:ShowFightInfo()
	self:ShowLvUpInfo()
	self:DrawModel()
	self:SetStarPos()
	self:SetLvUpBtn()
	self:InitWidth()
	self:UnRegisterTime()
	self:InitXingTuRedPoint()
	self:RegisterTime()
	self:InitGreenPoint()
	self:ShowStarLightInfo()
end

function UIXingtu:OnFullShow()
	-- self:ShowMask()
end

function UIXingtu:ResetShowPageAndIndex()
	for i = 1, 4 do
		for j = 1, 7 do
			if XingtuUtil:isCanLvUp((i - 1)*7 + j) == 0 then
				self.showPage = i
				self.showIndex = j
				return
			end
		end
	end
	-- 这里获取一次没满的大页
	for i = 1, 4 do
		for j = 1, 7 do
			if XingtuUtil:isCanLvUp((i - 1)*7 + j) == -3 then
				self.showPage = i
				self.showIndex = j
				return
			end
		end
	end
	self.showPage = 1
	self.showIndex = 1
end

function UIXingtu:ResetShowIndex()
	for i = 1, 7 do
		if XingtuUtil:isCanLvUp((self.showPage-1)* 7 + i) == 0 then
			self.showIndex = i
			return
		end
	end
	--找没满级的
	for i = 1, 7 do
		if XingtuUtil:isCanLvUp((self.showPage-1) * 7 + i) == -3 then
			self.showIndex = i
			return
		end
	end
	self.showIndex = 1
end

function UIXingtu:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end

-- function UIXingtu:GetWidth()
	-- return 1397;
-- end

-- function UIXingtu:GetHeight()
	-- return 823;
-- end

----显示下已等级的属性加成

function UIXingtu:InitGreenPoint(  )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1,7 do
		objSwf["jiantou"..i].visible = false
		objSwf["tf"..i]._visible = false
	end
	objSwf.fightimg.visible = false
	objSwf.fightaddLoader.visible = false

end
function UIXingtu:OnbtnrollOver(  )
	self.isShow = true
	self:CheckShowOrHide(true)
	
end

function UIXingtu:OnbtnrollOut(  )
	self.isShow = false
	self:CheckShowOrHide(false)
	
end

function UIXingtu:CheckShowOrHide( isShow )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg, curAddPro, lv, nSize = XingtuUtil:getNextStarCfg((self.showPage - 1) *7 + self.showIndex)
	if isShow and nSize then
		for i=1,7 do
			objSwf["jiantou"..nSize].visible = true
			objSwf["tf"..nSize]._visible = true
			objSwf["tf"..nSize].text ="+"..curAddPro[2]
		end
		objSwf.fightimg.visible = true
		objSwf.fightaddLoader.visible = true
		self:ShowNextFightInfo()
	else
		for i=1,7 do
			objSwf["jiantou"..i].visible = false
			objSwf["tf"..i]._visible = false
		end
		objSwf.fightimg.visible = false
		objSwf.fightaddLoader.visible = false
	end
end

function UIXingtu:InitWidth( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	self.width1 = objSwf.PageBtn1._width;
	self.width2 = objSwf.PageBtn2._width;
	self.width3 = objSwf.PageBtn3._width;
	self.width4 = objSwf.PageBtn4._width;
end

--星图红点提示
--adder:houxudong
--date:2016/7/29 15:38:25
UIXingtu.xingtuTimerKey = nil;

function UIXingtu:InitXingTuRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return; end
	--青龙
	if XingtuModel:IsHaveCanLvUp(1) then
		PublicUtil:SetRedPoint(objSwf.PageBtn1, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.PageBtn1, nil, 0)
	end
	--白虎
	if XingtuModel:IsHaveCanLvUp(2) then
		PublicUtil:SetRedPoint(objSwf.PageBtn2, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.PageBtn2, nil, 0)
	end
	--朱雀
	if XingtuModel:IsHaveCanLvUp(3) then
		PublicUtil:SetRedPoint(objSwf.PageBtn3, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.PageBtn3, nil, 0)
	end
	--玄武
	if XingtuModel:IsHaveCanLvUp(4) then
		PublicUtil:SetRedPoint(objSwf.PageBtn4, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.PageBtn4, nil, 0)
	end
end

function UIXingtu:RegisterTime(  )
	self.xingtuTimerKey = TimerManager:RegisterTimer(function()
		self:InitXingTuRedPoint()
	end,1000,0); 
end
-- 

function UIXingtu:UnRegisterTime(  )
	if self.xingtuTimerKey then
		TimerManager:UnRegisterTimer(self.xingtuTimerKey);
		self.xingtuTimerKey = nil;
	end
end

function UIXingtu:SetLvUpBtn()
	local objSwf = self.objSwf
	if not objSwf then return end

	local UI = objSwf.curInfo
	UI.btn_lvUp.visible = not self.isAuto
	UI.btn_lvUpAuto.label = self.isAuto and StrConfig["xingtu1"] or StrConfig["xingtu2"]
	if not self.isAuto and self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

function UIXingtu:initPageBtn()
	local objSwf = self.objSwf
	if not objSwf then return end
	for i = 1, 4 do
		objSwf["PageBtn" ..i].disabled = XingtuUtil:IsDisabledBtn(i)
		objSwf["pageBtn" ..i]._visible = XingtuUtil:IsDisabledBtn(i)
		if i == self.showPage then
			objSwf['PageBtn' ..i].selected = true
		end
		objSwf["pageBtn" ..i].rollOver = function() TipsManager:ShowBtnTips(XingtuUtil:getOpenLevByPage(i) .. StrConfig['xingtu3']) end
		objSwf["pageBtn" ..i].rollOut = function() TipsManager:Hide() end
	end
end

function UIXingtu:OnPageClick(i)
	if self.showPage == i then return end
	self.isAuto = false
	self:SetLvUpBtn()
	self.showPage = i
	-- self.showIndex = 1
	self:ResetShowIndex()
	self:ShowXingtuList()
	self:ShowFightInfo()
	self:ShowLvUpInfo()
	self:DrawModel()
	self:SetStarPos()
	self:ShowStarLightInfo()
end

function UIXingtu:OnIndexClick(i)
	if self.showIndex == i then return end
	self.isAuto = false
	self:SetLvUpBtn()
	self.showIndex = i
	-- self:ResetShowIndex()
	self:ShowFightInfo()
	self:ShowLvUpInfo()
	self:DrawModel()
	self:SetStarPos()
	self:ShowStarLightInfo()
end

function UIXingtu:ShowStarLightInfo()
	local objSwf = self.objSwf
	if not objSwf then return end

	local info = XingtuModel:GetInfoById((self.showPage - 1) *7 + self.showIndex)
	for i = 1, 9 do
		if not info or i > info.nLev then
			self:SetStarInfo(i, 0)
		elseif i == info.nLev and info.nSize < 7 then
			self:SetStarInfo(i, 1)
		else
			self:SetStarInfo(i, 2)
		end
	end
end

function UIXingtu:SetStarInfo(i, flag)
	local UI = self.objSwf['StarPfx' ..i]
	local cfg = string.format(StrConfig.xingtu20, StrConfig['xingtu' .. 10 + i])
	local color = "#e1e1e1"
	if flag == 2 then
		UI.starmax._visible = true
		UI.starlight._visible = true
		UI.star._visible = false
	elseif flag == 1 then
		UI.starmax._visible = false
		UI.starlight._visible = true
		UI.star._visible = false
	else
		UI.starmax._visible = false
		UI.starlight._visible = false
		UI.star._visible = true
		color = "#808080"
	end
	UI.txt_star.htmlText = string.format("<font color = '%s'>%s</font>", color, cfg)
end

function UIXingtu:ShowXingtuList()
	local objSwf = self.objSwf
	if not objSwf then return end

	for i = 1, 7 do
		local UI = objSwf["item" ..i]
		local UI1 = objSwf["itemBtn" ..i]
		local info = XingtuModel:GetInfoById((self.showPage - 1) *7 + i)
		local cfg = t_xingtu[info.id * 10000 + info.nLev * 100 + (info.nSize == 0 and 1 or info.nSize)]
		UI.maxIcon.maxIcon._visible = false
		if cfg then
			local icon
			local openLv = t_xingtu[info.id * 10000 + 101].lv
			-- 功能未开启
			if openLv > MainPlayerModel.humanDetailInfo.eaLevel then
				icon = ResUtil:GetXingtuIcon(cfg.name_3)
				UI.disabled = true
				UI1._visible = true
				UI1.rollOver = function() TipsManager:ShowBtnTips(openLv .. StrConfig['xingtu3']) end
				UI1.rollOut = function() TipsManager:Hide() end
				UI.maxPfx.maxPfx._visible = false
				UI.operatePfx.operatePfx._visible = false
				UI.txt_txt.txt_lv.text = ""
				UI.redpoint._visible = false
			else
			-- 功能已开启
				local value = XingtuUtil:isCanLvUp(info.id)
				if value == -1 then                      --等级已满
					UI.maxPfx.maxPfx._visible = true
					UI.maxIcon.maxIcon._visible = true
					-- UI.choosefect._visible = false
					UI.redpoint._visible = false
					UI.operatePfx.operatePfx._visible = false
				elseif value == 0 then
					UI.maxPfx.maxPfx._visible = false
					-- UI.maxIcon._visible = false
					UI.redpoint._visible = true
					UI.operatePfx.operatePfx._visible = true
					-- UI.choosefect._visible = true
				else
					UI.maxPfx.maxPfx._visible = false
					-- UI.maxIcon._visible = false
					UI.redpoint._visible = false
					UI.operatePfx.operatePfx._visible = false
					-- UI.choosefect._visible = false
				end
				icon = ResUtil:GetXingtuIcon(cfg.name_2)
				UI.disabled = false
				UI1._visible = false
				UI.txt_txt.txt_lv.text = StrConfig['xingtu' ..(10 + info.nLev)] .. StrConfig['xingtu4']

			end
			if info.id == (self.showPage - 1) *7 + self.showIndex then
				UI.selected = true
			end
			UI._visible = true
			if UI.icon.icon_name.source ~= icon then
				UI.icon.icon_name.source = icon
			end
			-- UI.txt_lv.text = StrConfig['xingtu' ..(10 + info.nLev)] .. StrConfig['xingtu4']
		else
			UI._visible = false
		end
	end
end

local s_pro = {"att", "def", "hp", "hit", "dodge", "cri", "defcri"}
local getProValue = function(pro, name)
	for k, v in pairs(pro) do
		if v.name == name then
			return v.val
		end
	end
	return 0
end

local s_str1 = "%s<font color = '#1ec71e'>%s</font>"

function UIXingtu:ShowFightInfo()
	local objSwf = self.objSwf
	if not objSwf then return end

	local tPro = XingtuUtil:GetProById((self.showPage - 1) *7 + self.showIndex) or {}
	PublicUtil:ShowProInfoForUI(tPro, self.slot, nil, nil, s_pro, true,nil,"#FFFFFF")
	objSwf.fightLoader.num = PublicUtil:GetFigthValue(tPro)

	objSwf.fightLoader1.num = PublicUtil:GetFigthValue(XingtuUtil:GetAllPro())
end


function UIXingtu:ShowNextFightInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg, curAddPro, lv, nSize = XingtuUtil:getNextStarCfg((self.showPage - 1) *7 + self.showIndex)
	objSwf.fightaddLoader.num = PublicUtil:GetFigthValue({{type = curAddPro[1], val = curAddPro[2]},})
end

function UIXingtu:ClearPfx(nSize)
	local objUIDraw = self.objUIDraw
	if objUIDraw and objUIDraw.sceneLoaded and objUIDraw.objScene then
		local nodes = objUIDraw.objScene:getNodes();
		local node = nil;
		for i,v in ipairs(nodes) do
			if v.mesh and v.mesh.skeleton and v.name:find(s_skl[self.showPage]) then
				node = v;
				break;
			end
		end
		if node then
			if nSize then
				node.mesh.skeleton.pfxPlayer:stop("v_xingtu_xian_an_" .. nSize ..".pfx", true)
				node.mesh.skeleton.pfxPlayer:stop("curpfx" .. nSize, true)
			else
				node.mesh.skeleton.pfxPlayer:stopAll(true)
			end
			-- node.mesh.skeleton.pfxPlayer:clearParams()
		end
	end
	TimerManager:UnRegisterTimer(self.pfxTime)
end

function UIXingtu:PlayAnimation()
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	if not objUIDraw.sceneLoaded then return; end
	if not objUIDraw.objScene then return; end
	local nodes = objUIDraw.objScene:getNodes();
	local node = nil
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(s_playerSkl[self.showPage]) then
			node = v;
			break;
		end
	end
	if not node then return; end
	local cfg = t_xingtuscene[(self.showPage - 1) *7 + self.showIndex]
	if not cfg.wait_animal then
		return
	end
	local anima = node.mesh.skeleton:getAnima(cfg.wait_animal);
	if not anima then
		anima = node.mesh.skeleton:addAnima(cfg.wait_animal);
	end
	anima:play();
end

function UIXingtu:ShowStarInfo(bRefresh)
	local objSwf = self.objSwf
	if not objSwf then return end

	local info = XingtuModel:GetInfoById((self.showPage - 1) *7 + self.showIndex)
	local nLev = info.nLev
	local nSize = info.nSize
	local bClear = false
	local bSuccess = false
	if nSize == 7 and nLev < XingtuModel.nMaxLev then
		nLev = nLev + 1
		nSize = 0
		bClear = true
		if bRefresh then
			self:PlayAnimation()
		end
	end
	if not bRefresh then
		bClear = true
	end

	-- 这里把星星的特效清理掉
	if bClear then
		self:ClearPfx()
	else
		self:ClearPfx(nSize)
	end
	for i = 1, 7 do
		local UI = objSwf["star" ..i]
		-- todo 这里需要处理下几重的显示 之后一起做
		if i <= nSize then
			UI.rollOver = function() TipsManager:ShowBtnTips(XingtuUtil:GetStrForTips(info.id, nLev, i, 1),TipsConsts.Dir_RightUp); end
			UI.rollOut = function() TipsManager:Hide(); end
			if bClear or i == nSize then
				self:PlayLinePfx(i - 1, true, false, nLev)
				self:PlayNodePfx(i, nLev, 1)
			end
		elseif i == nSize + 1 then
			UI.rollOver = function() TipsManager:ShowBtnTips(XingtuUtil:GetStrForTips(info.id, nLev, i, 2),TipsConsts.Dir_RightUp); end
			UI.rollOut = function() TipsManager:Hide(); end
			self:PlayLinePfx(i - 1, true, bRefresh, nLev)
			self:PlayNodePfx(i, nLev, 3)
		else
			UI.rollOver = function() TipsManager:ShowBtnTips(XingtuUtil:GetStrForTips(info.id, nLev, i, 3),TipsConsts.Dir_RightUp); end
			UI.rollOut = function() TipsManager:Hide(); end
			if bClear then
				self:PlayLinePfx(i - 1, false, false, nLev)
				self:PlayNodePfx(i, nLev, 2)
			end
		end
	end
end

function UIXingtu:PlayLinePfx(index, bLight, bRefresh, nLev)
	if index < 1 or index > 6 then return end
	---最多６条线
	local func = function(index, bLight)
		local objUIDraw = self.objUIDraw
		if not objUIDraw then return end
		if not objUIDraw.sceneLoaded then return; end
		if not objUIDraw.objScene then return; end
		local nodes = objUIDraw.objScene:getNodes();
		local node = nil
		for i,v in ipairs(nodes) do
			if v.mesh and v.mesh.skeleton and v.name:find(s_skl[self.showPage]) then
				node = v;
				break;
			end
		end
		if not node then return; end
		node.mesh.skeleton.pfxPlayer:play(bLight and "v_xingtu_xian_liang_" .. index ..".pfx" or "v_xingtu_xian_an_" .. index ..".pfx")
	end

	if bRefresh then
		self:PlayPfxBeforeLine(index, nLev)
		self.lineTime = TimerManager:RegisterTimer(function() func(index, bLight) end, 150, 1)
	else
		func(index, bLight)
	end
end

local s_liuguang = {"v_xingtu_liudong_lan.pfx", "v_xingtu_liudong_zise.pfx", "v_xingtu_liudong_chengse.pfx"}

local s_smat = nil
local s_tmat = nil
local s_startTime = 0
local s_pfx = nil
function UIXingtu:PlayPfxBeforeLine(index, nLev)
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	if not objUIDraw.sceneLoaded then return; end
	if not objUIDraw.objScene then return; end
	local nodes = objUIDraw.objScene:getNodes();
	local node = nil
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(s_skl[self.showPage]) then
			node = v;
			break;
		end
	end
	if not node then return; end
	if s_pfx then
		s_pfx:stop()
	end
	s_smat  = node.mesh.skeleton:getBone("v_xingtu" ..index)
	s_tmat  = node.mesh.skeleton:getBone("v_xingtu" ..(index + 1))

	if not s_smat or not s_tmat then
		return
	end

	s_pfx = node.mesh.skeleton.pfxPlayer:play("s_play", s_liuguang[math.ceil(nLev/3)])
	TimerManager:UnRegisterTimer(self.pfxTime)
	s_pfx.transform = s_smat
	s_startTime = GetCurTime()
	local func = function()
		local time = GetCurTime()
		local nValue = time - s_startTime
		if nValue > 150 then
			nValue = 150
		end
		if not s_pfx then return end
		local vec = _Vector3.add(s_smat:getTranslation(), _Vector3.mul(_Vector3.sub(s_tmat:getTranslation(), s_smat:getTranslation()), nValue/150))
		s_pfx:stop()
		s_pfx = node.mesh.skeleton.pfxPlayer:play("s_play", s_liuguang[math.ceil(nLev/3)])
		s_pfx.transform:setTranslation(vec.x, vec.y, vec.z)
		if nValue >= 150 then
			s_smat = nil
			s_tmat = nil
			TimerManager:UnRegisterTimer(self.pfxTime)
			s_pfx:stop()
			s_pfx = nil
		end

	end

	-- 这里其实注册了一个每帧调用的定时器
	self.pfxTime = TimerManager:RegisterTimer(function() func() end,1,0)
end

--某个节点播放某个特效
local s_StarTime = {}
function UIXingtu:PlayNodePfx(bindIndex, lev, nType)
	local func = function(bindIndex, lev, nType)
		local objUIDraw = self.objUIDraw
		if not objUIDraw then return end
		if not objUIDraw.sceneLoaded then return; end
		if not objUIDraw.objScene then return; end

		local nodes = objUIDraw.objScene:getNodes();
		local node = nil;
		for i,v in ipairs(nodes) do
			if v.mesh and v.mesh.skeleton and v.name:find(s_skl[self.showPage]) then
				node = v;
				break;
			end
		end
		if not node then return; end
		
		asyncLoad(true); --异步

		local pfx = node.mesh.skeleton.pfxPlayer:play("curpfx" .. bindIndex, s_StarPfx[math.ceil(lev/3)][nType])
		local BindMat  = node.mesh.skeleton:getBone("v_xingtu" ..bindIndex);
		local vec = BindMat:getTranslation()
	    if BindMat then
	        pfx.transform = BindMat
	    end
	end
	if s_StarTime[bindIndex] then
		TimerManager:UnRegisterTimer(s_StarTime[bindIndex])
		s_StarTime[bindIndex] = nil
	end
	s_StarTime[bindIndex] = TimerManager:RegisterTimer(function() func(bindIndex, lev, nType) end,(math.random(500)),1)
end

function UIXingtu:clearStarTime()
	for k, v in pairs(s_StarTime) do
		TimerManager:UnRegisterTimer(v)
		s_StarTime[k] = nil
	end
end

function UIXingtu:ShowLvUpInfo()
	local objSwf = self.objSwf
	if not objSwf then return end

	local cfg, curAddPro, lv, nSize = XingtuUtil:getNextStarCfg((self.showPage - 1) *7 + self.showIndex)
	if not cfg then
		objSwf.curInfo._visible = false
		objSwf.txt_maxLv._visible = true
		self:InitGreenPoint()
	else
		objSwf.curInfo._visible = true
		objSwf.txt_maxLv._visible = false
		objSwf.curInfo.txt_star.text = StrConfig['xingtu' ..(10 + lv)] .. StrConfig['xingtu4'] .. nSize .. StrConfig['xingtu5']
		-- objSwf.curInfo.txt_addPro.text = curAddPro[2] .. enAttrTypeName[curAddPro[1]]
		local bCanUp = true
		if toint(cfg.lv) > MainPlayerModel.humanDetailInfo.eaLevel then
			bCanUp = false
			objSwf.curInfo.txt_lv.htmlText = string.format("<font color='#FF0000'>%s</font>",cfg.lv)
		else
			objSwf.curInfo.txt_lv.text = cfg.lv
		end
		-- objSwf.curInfo.txt_success.text = cfg.success / 100 .. "%"
		if cfg.consume > MainPlayerModel.humanDetailInfo.eaBindGold then
			bCanUp = false
			objSwf.curInfo.txt_cost.htmlText = string.format("<font color='#FF0000'>%s</font>",cfg.consume)
		else
			objSwf.curInfo.txt_cost.text = cfg.consume
		end
		objSwf.curInfo.txt_have.text = getNumShow(MainPlayerModel.humanDetailInfo.eaBindGold)
		if bCanUp then
			objSwf.curInfo.btn_lvUp:showEffect(ResUtil:GetButtonEffect7())
			objSwf.curInfo.btn_lvUpAuto:showEffect(ResUtil:GetButtonEffect7())
		else
			objSwf.curInfo.btn_lvUp:clearEffect()
			objSwf.curInfo.btn_lvUpAuto:clearEffect()
		end
	end
	self:SetCurTips(cfg, curAddPro, nSize)
end

function UIXingtu:SetCurTips(cfg, curAddPro, nSize)
	local tips = self.objSwf.curTips
	local tips1 = self.objSwf.curTips1
	local tips2 = self.objSwf.curTips2
	local tips3 = self.objSwf.curTips3

	tips._visible = false
	tips1._visible = false
	tips2._visible = false
	tips3._visible = false
	if cfg then
		local tipUI 
		local cfg1 = XingtuStarPos[(self.showPage - 1) *7 + self.showIndex];
		local pos = cfg1[nSize]
		-- if not cfg1 then return end
		-- local pos = split(cfg1["size" ..nSize], ",")
		if toint(pos[1]) < 580 and toint(pos[2]) <=350 then
			tipUI = tips
			tipUI._x = toint(pos[1]) - 112
			tipUI._y = toint(pos[2]) -55
		elseif toint(pos[1]) >= 580 and toint(pos[2]) <=350 then
			tipUI = tips1
			tipUI._x = toint(pos[1]) + 40
			tipUI._y = toint(pos[2]) -55
		elseif toint(pos[1]) < 580 and toint(pos[2]) > 350 then
			tipUI = tips2
			tipUI._x = toint(pos[1]) - 120
			tipUI._y = toint(pos[2]) + 20
		elseif toint(pos[1]) >= 580 and toint(pos[2]) > 350 then
			tipUI = tips3
			tipUI._x = toint(pos[1]) + 35
			tipUI._y = toint(pos[2]) + 20
		end
		tipUI._visible = true
		tipUI.txt_pro.text = enAttrTypeName[curAddPro[1]] .. "："
		tipUI.txt_pro1.text = curAddPro[2]
		tipUI.txt_suc.text = cfg.success / 100 .. "%"
	end
end

function UIXingtu:AutoLvUp()
	if self.isAuto then
		self:OnLvUpClick()
	end
end

function UIXingtu:OnLvUpClick(isAuto, bFirst)
	local id = (self.showPage - 1) * 7 + self.showIndex
	local nResult = XingtuUtil:isCanLvUp(id)
	if nResult ~= 0 then
		if not self.objSwf then return end
		local btn = bFirst and self.objSwf.curInfo.btn_lvUp or self.objSwf.curInfo.btn_lvUpAuto

		if nResult == -1 then
			FloatManager:AddNormal(StrConfig['xingtu6'], btn)
		elseif nResult == -2 then
			FloatManager:AddNormal(StrConfig['xingtu7'], btn)
		else
			FloatManager:AddNormal(StrConfig['xingtu8'], btn);--银两不足
		end
		self.isAuto = false
		self:SetLvUpBtn()
		return
	end
	if isAuto then
		self.isAuto = not self.isAuto
		self:SetLvUpBtn()
		if not self.isAuto then
			return
		else
			self.timerKey = TimerManager:RegisterTimer( function()
				self:AutoLvUp()
			end, 600, 0 )
		end
	end
	
	XingtuController:AskLvUp(id)
end

function UIXingtu:DrawModel()
	local objSwf = self.objSwf;
	if not objSwf then return end 
	
	local cfg = t_xingtuscene[(self.showPage - 1) *7 + self.showIndex];
	if not cfg then return; end
	local vector = split(cfg.vector, ",")
	if not self.objUIDraw then
		local viewPort = _Vector2.new(toint(vector[1]), toint(vector[2]))
		self.objUIDraw = UISceneDraw:new( "UIXingtu", objSwf.load_boss, viewPort )
	else
		self.objUIDraw:SetUILoader(objSwf.load_boss)
	end
	self.objUIDraw:SetScene(cfg.sen, function() self:PlayAnimal() self:ShowStarInfo() end)
	-- 模型旋转
	self.objUIDraw:SetDraw(true)
end

function UIXingtu:IsShowSound()
	return true
end

function UIXingtu:PlayAnimal()
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	if not objUIDraw.sceneLoaded then return; end
	if not objUIDraw.objScene then return; end

	local nodes = objUIDraw.objScene:getNodes();
	local node = nil
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(s_playerSkl[self.showPage]) then
			node = v;
			break;
		end
	end
	if not node then return; end
	local cfg = t_xingtuscene[(self.showPage - 1) *7 + self.showIndex]
	if not cfg.leisure_animal then
		return
	end
	local anima = node.mesh.skeleton:getAnima(cfg.leisure_animal);
	if not anima then
		anima = node.mesh.skeleton:addAnima(cfg.leisure_animal);
	end
	anima:play();
end

function UIXingtu:SetStarPos()
	local objSwf = self.objSwf;
	if not objSwf then return end

	local cfg = XingtuStarPos[(self.showPage - 1) *7 + self.showIndex];
	if not cfg then return end
	for i = 1, 7 do
		local pos = cfg[i]
		objSwf["star" ..i]._x = toint(pos[1])
		objSwf["star" ..i]._y = toint(pos[2])
	end

	local info = XingtuModel:GetInfoById((self.showPage - 1) *7 + self.showIndex)
	local cfg1 = t_xingtu[info.id * 10000 + info.nLev * 100 + (info.nSize == 0 and 1 or info.nSize)]
	if cfg1 then
		local icon = ResUtil:GetXingtuIcon(cfg1.name_2)
		if objSwf.titleIcon.source ~= icon then
			objSwf.titleIcon.source = icon
		end
	end
end

function UIXingtu:OnHide()
	RemindController:AddRemind(RemindConsts.Type_XingTu, 0);
	if self.objUIDraw then
		self:ClearPfx()
		self.objUIDraw:SetDraw(false)
	end
	self.isAuto = false

	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	if self.pfxTime then
		TimerManager:UnRegisterTimer(self.pfxTime)
		self.pfxTime = nil
	end
	if self.xingtuTimerKey then
		TimerManager:UnRegisterTimer(self.xingtuTimerKey)
		self.xingtuTimerKey = nil;
	end
end

function UIXingtu:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end


function UIXingtu:IsTween()
	return true;
end

--面板类型
function UIXingtu:GetPanelType()
	return 1;
end

local s_PfxSuccess = {"v_xingtu_baozha_lanse.pfx", "v_xingtu_baozha_zise.pfx", "v_xingtu_baozha_chengse.pfx"}
function UIXingtu:PlaySuccessPfx(body)
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	if not objUIDraw.sceneLoaded then return; end
	if not objUIDraw.objScene then return; end

	local nodes = objUIDraw.objScene:getNodes();
	local node = nil;
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(s_skl[self.showPage]) then
			node = v;
			break;
		end
	end
	if not node then return; end
	
	asyncLoad(true); --异步

	local pfx = node.mesh.skeleton.pfxPlayer:play(s_PfxSuccess[math.ceil(body[3]/3)])
	local BindMat  = node.mesh.skeleton:getBone("v_xingtu" ..body[4]);
    if BindMat then
        pfx.transform = BindMat
    end

    local cfg = XingtuStarPos[(self.showPage - 1) *7 + self.showIndex];
	if not cfg then return end
	local pos = cfg[body[4]]
    self.objSwf.successPfx._x = toint(pos[1]) - 85
    self.objSwf.successPfx._y = toint(pos[2]) - 62
    self.objSwf.successPfx:gotoAndPlay(2)
    if body[4] == 7 then
    	if body[3] ~= 9 then
    		self.objSwf.starUpPfx:gotoAndPlay(2)
    		for i = 2, 9 do
    			if i == body[3] + 1 then
    				self.objSwf.starUpPfx.pfx["num" ..i]._visible = true
    			else
    				self.objSwf.starUpPfx.pfx["num" ..i]._visible = false
    			end
    		end
    	end
    end
end

function UIXingtu:PlayFailPfx(body)
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	if not objUIDraw.sceneLoaded then return; end
	if not objUIDraw.objScene then return; end

	local nodes = objUIDraw.objScene:getNodes();
	local node = nil;
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(s_skl[self.showPage]) then
			node = v;
			break;
		end
	end
	if not node then return; end
	
	asyncLoad(true); --异步

	local pfx = node.mesh.skeleton.pfxPlayer:play("v_xingtu_baozha_shibai.pfx")
	local BindMat  = node.mesh.skeleton:getBone("v_xingtu" ..(body[4] + 1));
    if BindMat then
        pfx.transform = BindMat
    end
end


function UIXingtu:HandleNotification(name,body)
	if name == NotifyConsts.XingtuLvUpResult then
		local btn = not self.isAuto and self.objSwf.curInfo.btn_lvUp or self.objSwf.curInfo.btn_lvUpAuto
		-- FloatManager:AddNormal(StrConfig['xingtu9'], btn);
		self:ShowFightInfo()
		self:ShowStarInfo(true)
		self:ShowLvUpInfo()
		self:ShowXingtuList()
		self:PlaySuccessPfx(body)
		self:CheckShowOrHide(false)
		self:CheckShowOrHide(true)
		self:ShowStarLightInfo()
		SoundManager:PlaySfx(2055)
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel or body.type == enAttrType.eaBindGold then
			self:ShowLvUpInfo()
			self:ShowXingtuList()
		end
	elseif name == NotifyConsts.XingtuLvUpResultFail then
		self:ShowXingtuList()
		local btn = not self.isAuto and self.objSwf.curInfo.btn_lvUp or self.objSwf.curInfo.btn_lvUpAuto
		FloatManager:AddNormal(StrConfig['xingtu10'], btn)
		local info = XingtuModel:GetInfoById((self.showPage - 1) *7 + self.showIndex)
		if not info then return end
		if body[2] == info.id then
			local nSize = body[4]
			local nLev = body[3]
			if nSize == 7 and nLev < XingtuModel.nMaxLev then
				nLev = nLev + 1
				nSize = 0
			end
			nSize = nSize + 1
			if nSize > 0 and nSize < 7 then
				self:PlayPfxBeforeLine(nSize, nLev)
			end
		end
		self:PlayFailPfx(body)
	end
end
function UIXingtu:ListNotificationInterests()
	return {
		NotifyConsts.XingtuLvUpResult,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.XingtuLvUpResultFail,
	}
end