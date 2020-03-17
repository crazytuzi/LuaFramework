--[[
图鉴面板
2016-5-19
chenyujia
]]

_G.UIFumo = BaseUI:new("UIFumo");

UIFumo.curIndex = 1;
UIFumo.maxIndex = 1;
UIFumo.lastFumoOldLV = -2;
UIFumo.nPage = 1

UIFumo.curLv = 0
UIFumo.allLv = 0
function UIFumo:Create()
	self:AddSWF("fuMoPanel.swf", true, "center");
end

function UIFumo:OnLoaded(objSwf)
	self:RegisterEventHandler(objSwf);
end

function UIFumo:RegisterEventHandler(objSwf)
	--暂定只有野外
	objSwf.PageBtn1.selected = true

	objSwf.btn_close.click     	= function() self:Hide() end
	objSwf.btnPre.click        	= function() self:ChangePage(-4) end
	objSwf.btnNext.click       	= function() self:ChangePage(4) end
	objSwf.btnPagePre.click     = function() self:OnBtnPreClick(); end
	objSwf.btnPageNext.click    = function() self:OnBtnNextClick(); end
	for i = 1, 4 do
		objSwf["fumo" ..i].btnTeleport.rollOver = function() MapUtils:ShowTeleportTips() end
		objSwf["fumo" ..i].btnTeleport.rollOut = function() TipsManager:Hide() end
	end
	for i = 1, 6 do
		objSwf['item' ..i].click = function()
			self:OnFumoChange(false, i)
		end
	end
	for i = 1, 3 do
		objSwf["PageBtn" ..i].click = function()
			if self.nPage == i then
				return
			end
			self.nPage = i
			self:ShowFumoList(true)
			self:OnFumoChange(false)
			self:showBtnValue()
		end
	end
	objSwf.panelBtn.rollOver = function() self:ShowFightTips() end
	objSwf.panelBtn.rollOut = function() TipsManager:Hide() end
	objSwf.curbtn.rollOver = function() self:ShowCurLinkTips() end
	objSwf.allbtn.rollOver = function() self:ShowAllLinkTips() end
	objSwf.allbtn.rollOut = function() TipsManager:Hide() end
	objSwf.curbtn.rollOut = function() TipsManager:Hide() end

	objSwf.btnVipLvUp.click = function() UIVip:Show() end	
	objSwf.btnVipLvUp.rollOver = function(e) 
		local attMap = PublicUtil.GetVipShowPro(FumoUtil:GetAllPro())
		VipController:ShowAttrTips( attMap, UIVipAttrTips.tj,VipConsts.TYPE_SUPREME)
	end
	objSwf.btnVipLvUp.rollOut = function(e) VipController:HideAttrTips() end
end

function UIFumo:ShowCurLinkTips()
	-- local id, pro = FumoUtil:GetLinkIdByMap(self.showList[self.startIndex + self.selectIndex - 1].map)
	-- if id == 0 then return end
	if not self.showList then
		return
	end
	TipsManager:ShowBtnTips(FumoUtil:GetCurLinkStr(self.showList[self.startIndex + self.selectIndex - 1].map),TipsConsts.Dir_RightUp)
end

function UIFumo:ShowAllLinkTips()
	-- local id, pro = FumoUtil:GetLinkIdAll()
	-- if id == 0 then return end
	-- PublicUtil:ShowProTips(pro, TipsConsts.Dir_RightUp)
	TipsManager:ShowBtnTips(FumoUtil:GetAllLinkStr(),TipsConsts.Dir_RightUp)
end

function UIFumo:ShowFightTips()
	PublicUtil:ShowProTips(FumoUtil:GetAllPro(), TipsConsts.Dir_RightDown)
end

function UIFumo:OnBtnPreClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	if self.startIndex ~= 1 then
		self.startIndex = self.startIndex - 1
		self.selectIndex = self.selectIndex + 1
		self:ShowFumoList()
		self:UpdateBtnState()
	end
end

function UIFumo:OnBtnNextClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.startIndex ~= (#self.showList - 5) then
		self.startIndex = self.startIndex + 1
		self.selectIndex = self.selectIndex - 1
		self:ShowFumoList()
		self:UpdateBtnState()
	end
end

function UIFumo:UpdateBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local numBoss = 6
	objSwf.btnPagePre.disabled = self.startIndex == 1
	if #self.showList <= 6 then
		objSwf.btnPageNext.disabled = true
	else
		objSwf.btnPageNext.disabled = self.startIndex == (#self.showList - 5)
	end
end

function UIFumo:OnShow()
	self.nPage = FumoUtil:GetCanOperatePage()
	self.objSwf["PageBtn" ..self.nPage].selected = true
	self:ShowFumoList(true)
	self:OnFumoChange()
	self:ShowFightInfo()
	self:showBtnValue()
	for i = 1, 3 do
		self.objSwf['PageBtn' ..i].visible = #FumoUtil:GetShowList(i) ~= 0
	end
end

function UIFumo:OnFumoChange(bNotice, i)
	if not bNotice then
		if i and i == self.selectIndex then
			return
		elseif i then
			self.selectIndex = i
		end
		self.curIndex = FumoUtil:GetCanOperateOne(self.showList[self.startIndex + self.selectIndex - 1].map)
		self.maxIndex = self.showList[self.startIndex + self.selectIndex - 1] and FumoModel:GetCountByMap(self.showList[self.startIndex + self.selectIndex - 1].map) - 3 or 1
		if self.maxIndex < 1 then
			self.maxIndex = 1
		end
	end
	self:ShowFumoList()
	self:SetPageBtnState()
	self:RefreshInfo(bNotice)
	self:UpdateBtnState()
end

function UIFumo:ChangePage(count)
	if (self.curIndex == 1 and count == -4) or (self.curIndex == self.maxIndex and count == 4) then return end
	self.lastFumoOldLV = -2;
	self.curIndex = self.curIndex + count
	if self.curIndex < 1 then
		self.curIndex = 1
	end
	if self.curIndex > self.maxIndex then
		self.curIndex = self.maxIndex
	end
	self:SetPageBtnState()
	self:RefreshInfo()
end

function UIFumo:SetPageBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	if FumoModel:GetCountByMap(self.showList[self.startIndex + self.selectIndex - 1].map) <= 4 then
		objSwf.btnPre.visible = false
		objSwf.btnNext.visible = false
		return
	else
		objSwf.btnPre.visible = true
		objSwf.btnNext.visible = true
	end
	if self.curIndex == 1 then
		objSwf.btnPre.disabled = true
	else
		objSwf.btnPre.disabled = false
	end
	if self.curIndex == self.maxIndex then
		objSwf.btnNext.disabled = true
	else
		objSwf.btnNext.disabled = false
	end
end

function UIFumo:ShowFumoList(init)
	local objSwf = self.objSwf
	if not objSwf then return end
	if init then
		self.startIndex, self.selectIndex = FumoUtil:GetCanOperateIndex(self.nPage)
	end

	self.showList = self:GetShowList()
	for i = 1, 6 do
		local info = self.showList[self.startIndex + i - 1]
		if info then
			objSwf['item' ..i]._visible = true
			objSwf['item' ..i]:setData(UIData.encode(info))
		else
			objSwf['item' ..i]._visible = false
		end
		if self.selectIndex == i then
			objSwf['item' ..i].selected = true
		else
			objSwf['item' ..i].selected = false
		end
	end
end

function UIFumo:GetShowList()
	local showList = FumoUtil:GetShowList(self.nPage)
	local list = {}
	for k, v in pairs(showList) do
		local vo = {}
		local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
		vo.bNoClick = myLevel < v.lv
		vo.gress = myLevel < v.lv and "" or v.gress
		vo.value = v.value
		vo.maxValue = v.maxValue
		vo.headUrl = myLevel < v.lv and ImgUtil:GetGrayImgUrl(v.headUrl) or v.headUrl
		vo.nameStr = string.format("<font color = '#e6ad5c'>%s</font>", v.nameStr)
		vo.lv = myLevel < v.lv and string.format("%s级可激活", v.lv) or ""
		vo.bCanUp = v.bCanUp
		vo.nameUrl = v.nameUrl
		vo.map = v.map
		table.push(list, vo)
	end
	return list
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
function UIFumo:ShowFightInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local tPro = FumoUtil:GetAllPro()

	-- local slot = {}
	-- for i = 1, 7 do
	-- 	table.insert(slot, objSwf["txt_pro" ..i].txt_pro)
	-- 	-- UI.txt_pro.htmlText = string.format(s_str1, StrConfig["fumo" ..s_pro[i]], getProValue(tPro, s_pro[i]))
	-- end
	-- PublicUtil:ShowProInfoForUI(tPro, slot, addPro)

	objSwf.fightLoader.num = PublicUtil:GetFigthValue(tPro)
end

function UIFumo:ShowCurFightInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local tPro =  FumoUtil:GetProByMap(self.showList[self.startIndex + self.selectIndex - 1].map)
	local id, pro = FumoUtil:GetLinkIdByMap(self.showList[self.startIndex + self.selectIndex - 1].map)
	local allPro = PublicUtil:GetFightListPlus(tPro, pro)
	local count = 0
	for k, v in pairs(allPro) do
		count = count + 1
	end
	local slot = {}
	for i = 1, 5 do
		table.insert(slot, objSwf["txt_pro" ..i].txt_pro)
		if i <= count then
			objSwf['proIcon' ..i]._visible = true
		else
			objSwf['proIcon' ..i]._visible = false
		end
	end
	
	local fight = PublicUtil:GetFigthValue(allPro)
	objSwf.fightLoader1.num = fight
	objSwf.fightLoader1._x = 955 - string.len(tostring(fight)) * 10
	PublicUtil:ShowProInfoForUI(allPro, slot, nil, nil, nil, true,"#e6ad5c","#d9d9d9")
	local info = self.showList[self.startIndex + self.selectIndex - 1]
	objSwf.progress:setProgress(info.value, info.maxValue)
	objSwf.progress.txt.text = info.value .. "/" .. info.maxValue
end

local s_str = "<font color = '#f8a42e'>%s:  </font><font color = '#cdb64b'>%s</font>"

--- 刷新具体显示
function UIFumo:RefreshInfo(bNotice)
	local objSwf = self.objSwf
	if not objSwf then return end
	if not bNotice then
		self.list = self.showList[self.startIndex + self.selectIndex - 1] and FumoUtil:getMapListBymap(self.showList[self.startIndex + self.selectIndex - 1].map) or {}
	end
	for i = 1, 4 do
		local UI = objSwf["fumo" .. i]
		if UI then
			local info = self.list[self.curIndex - 1 + i]
			if info then
				UI._visible = true
				local cfg = info:GetCfg()
				local monsterCfg = t_monster[cfg.monid]
				-- if not monsterCfg then
				-- 	print(cfg.monid)
				-- end
				-- assert(monsterCfg, cfg.monid)
				UI.btnViewReward.htmlLabel = string.format("<u>%s</u>", monsterCfg.name)
				UI.btnViewReward.click 	= function() info:GotoTheMonster() end
				if info:IsCanFly() then
					UI.btnTeleport.visible = true
					UI.btnTeleport.click	= function() info:FlytoTheMonster() end
				else
					UI.btnTeleport.visible = false
				end
				--点击以下两个按钮记录下 目前的等级，一会等返回消息的时候用来判断是否显示升级进度条动画
				UI.jiohuoBtn.click 		= function()
						if info:AskFumoLvUp() then
							self.lastFumoOldLV = info:GetLv();
						end
					end
				UI.shengjiBtn.click 	= function()
					if info:AskFumoLvUp() then
						self.lastFumoOldLV = info:GetLv();
					end
				end
				local pro = info:GetPro()
				for i = 1, 3 do
					UI['pro' ..i].txt_pro.htmlText = PublicAttrConfig.proSpaceName[pro[i].name] .."："--, pro[1].val)
					UI['pro' ..i].txt_pro1.htmlText = pro[i].val .. "/" .. info:GetMaxProVal(i)
				end
				
				-- UI.txt_curLv.htmlText = string.format(s_str, StrConfig['fumo106'], info:GetLv() ~= -1 and info:GetLv() or StrConfig['fumo107'])
				if info:bCanLvUp() then
					-- UI.btn_notice._visible = true
					UI.shengjiBtn:showEffect(ResUtil:GetButtonEffect7())
					UI.jiohuoBtn:showEffect(ResUtil:GetButtonEffect7())
				else
					-- UI.btn_notice._visible = false
					UI.shengjiBtn:clearEffect()
					UI.jiohuoBtn:clearEffect()
				end
				for i = 1, 3 do
					UI['pro' ..i].addPro._visible = false
				end
				
				UI.txt_exp.htmlText = "经 验："
				UI.txt_count.htmlText = ""
				UI.txt_txt.text = info:GetCfg().txt
				if not info:GetNextLvCfg() then
					UI.jiohuoBtn.visible = false
					UI.shengjiBtn.visible = false
					UI.txt_manji._visible = true
					UI.jihuo._visible = false
					-- UI.addPro._visible = false
					-- UI.t_costLabel._visible = false
					UI.tfNeedItem._visible = false
					UI.btnTeleport.visible = false
					UI.progress.txt.text = info:GetShowLv() .. "/" .. info:GetMaxLv()
					UI.progress:setProgress(info:GetMaxLv(), info:GetMaxLv())
					for i = 1, 3 do
						UI['pro' ..i].progress1:setProgress(info:GetShowLv(), info:GetMaxLv())
					end
				elseif not info:IsActive() then
					UI.jiohuoBtn.rollOver = function() 
						for i = 1, 3 do
							UI['pro' ..i].addPro._visible = true
						end
					end
					UI.jiohuoBtn.rollOut = function() 
						for i = 1, 3 do
							UI['pro' ..i].addPro._visible = false
						end
					end
					-- UI.t_costLabel._visible = true
					UI.tfNeedItem._visible = true
					UI.jiohuoBtn.visible = true
					UI.shengjiBtn.visible = false
					UI.txt_manji._visible = false
					UI.jihuo._visible = true
					local pro = info:GetNextPro()
					-- UI.addPro._visible = true
					for i = 1, 3 do
						UI['pro' ..i].addPro.txt_pro.text = pro[i].val
					end
					
					UI.progress.txt.text = info:GetShowLv() .. "/" .. info:GetMaxLv()
					UI.progress:setProgress(info:GetShowLv(), info:GetMaxLv())
					for i = 1, 3 do
						UI['pro' ..i].progress1:setProgress(info:GetShowLv(), info:GetMaxLv())
					end
				else
					UI.shengjiBtn.rollOver = function() 
						for i = 1, 3 do
							UI['pro' ..i].addPro._visible = true
						end
					end
					UI.shengjiBtn.rollOut = function() 
						for i = 1, 3 do
							UI['pro' ..i].addPro._visible = false
						end
					end
					UI.tfNeedItem._visible = true
					UI.jiohuoBtn.visible = false
					UI.shengjiBtn.visible = true
					UI.jihuo._visible = false
					UI.txt_manji._visible = false
					for i = 1, 3 do
						UI['pro' ..i].progress1:setProgress(info:GetShowLv(), info:GetMaxLv())
					end
					UI.progress:setProgress(info:GetShowLv(), info:GetMaxLv())
					UI.progress.txt.text = info:GetShowLv() .. "/" .. info:GetMaxLv()
					local nextPro = info:GetNextPro()
					for i = 1, 3 do
						UI['pro' ..i].addPro.txt_pro.text = nextPro[i].val - pro[i].val
					end
					
				end

				local itemCost, number = info:GetCost()
				if itemCost then
					local color = (number > 0) and '#00ff00' or '#ff0000'
					UI.tfNeedItem.htmlLabel = string.format("<font color = '%s'><u>%s</u></font>", color, t_item[itemCost].name .. "x1")
					UI.tfNeedItem._x = 83 - (string.len(t_item[itemCost].name) - 6)/2 * 5
					UI.tfNeedItem.rollOver = function(e) TipsManager:ShowItemTips(itemCost); end
					UI.tfNeedItem.rollOut = function(e) TipsManager:Hide() end
					UI.txt_count.htmlText = "拥有：".. number
				else
					UI.tfNeedItem.rollOver = function(e) end
				end

				if not bNotice then
					self:DrawMonster(UI, info, i)
				else
					if info:GetLv() == 0 then
						if self.drawList[i] then
							self.drawList[i].objUIDraw:SetGrey(false)
						end
					end
				end
			else
				UI._visible = false
			end
		end
	end
	self:ShowCurFightInfo()
	self:ShowFumoLink(bNotice)
end

function UIFumo:ShowFumoLink(bNotice)
	local objSwf = self.objSwf
	if not objSwf then return end
	local curLv = FumoUtil:GetLinkIdByMap(self.showList[self.startIndex + self.selectIndex - 1].map)
	local allLv = FumoUtil:GetLinkIdAll()
	if self.curLv ~= curLv then
		if bNotice then
			objSwf.linkPfx1:gotoAndPlay(2)
		end
		self.curLv = curLv
	end
	if self.allLv ~= allLv then
		if bNotice then
			objSwf.linkPfx2:gotoAndPlay(2)
		end
		self.allLv = allLv
	end
	if curLv == 0 then
		objSwf.curbtn.icon0._visible = true
		objSwf.curbtn.icon1._visible = false
	else
		objSwf.curbtn.icon0._visible = false
		objSwf.curbtn.icon1._visible = true
	end
	if allLv == 0 then
		objSwf.allbtn.icon0._visible = true
		objSwf.allbtn.icon1._visible = false
	else
		objSwf.allbtn.icon0._visible = false
		objSwf.allbtn.icon1._visible = true
	end
	objSwf.txt_cur.text = "lv." .. curLv
	objSwf.txt_all.text = "lv." .. allLv
end

function UIFumo:OnHide()
	self.lastFumoOldLV = -2;
	RemindController:AddRemind(RemindConsts.Type_FuMo, 0);
	if self.drawList then
		for i = 1, 4 do
			if self.drawList[i] then
				if self.drawList[i].objUIDraw then
					self.drawList[i].objUIDraw:SetDraw(false);
					self.drawList[i].objUIDraw:SetMesh(nil);
				end
				self.drawList[i].monsterAvater = nil
				self.drawList[i].monid = nil
			end
		end
	end
	self.nPage = 1
	self.startIndex = 1
	self.selectIndex = 1
	self.curIndex = 1
end

function UIFumo:IsShowSound()
	return true
end

function UIFumo:OnDelete()
	if self.drawList then
		for i = 1, 4 do
			if self.drawList[i] then
				if self.drawList[i].objUIDraw then
					self.drawList[i].objUIDraw:SetUILoader(nil);
				end
			end
		end
	end
end

function UIFumo:DrawMonster(UI, info, i)
	if not UI then return end
	if not self.drawList then self.drawList = {} end
	if not self.drawList[i] then self.drawList[i] = {} end
	local monsterAvater = {}
	local drawList = self.drawList[i]
	if drawList.monid ~= info:GetCfg().monid then
		drawList.monid = info:GetCfg().monid
	    drawList.monsterAvater = MonsterAvatar:NewMonsterAvatar(nil, info:GetCfg().monid);
		drawList.monsterAvater:InitAvatar();
	end
	local drawCfg = UIDrawFumoConfig[info:GetCfg().monid]
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
	end
	local rotation = drawCfg.Rotation or 0;
	if not drawList.objUIDraw then
		drawList.objUIDraw = UIDraw:new("UIFumo" .. i,drawList.monsterAvater, UI.load_boss,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000);
		
		drawList.monsterAvater.objMesh.transform:setRotation( 0, 0, 1, rotation );
	else
		if drawList.objUIDraw:SetMesh(drawList.monsterAvater) and drawList.objUIDraw:SetUILoader(UI.load_boss) then
			drawList.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
			drawList.monsterAvater.objMesh.transform:setRotation( 0, 0, 1, rotation );
		end
	end
	if not info:IsActive() then
		drawList.objUIDraw:SetGrey(true)
	else
		drawList.objUIDraw:SetGrey(false)
	end
	drawList.objUIDraw:SetDraw(true);
end

UIFumo.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	VPort = _Vector2.new(190,450),
	Rotation = 0
};
function UIFumo:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIFumo:showBtnValue()
	local objSwf = self.objSwf
	if not objSwf then return end

	objSwf.btn_notice1._visible = FumoUtil:isCanUpMap(1)
	objSwf.btn_notice2._visible = FumoUtil:isCanUpMap(2)
	objSwf.btn_notice3._visible = FumoUtil:isCanUpMap(3)
end

function UIFumo:IsTween()
	return true;
end

--面板类型
function UIFumo:GetPanelType()
	return 1;
end


function UIFumo:HandleNotification(name,body)
	self:ShowFumoList()
	self:showBtnValue()
	if name == NotifyConsts.FumoLvUpResult then
		self:ShowFightInfo()
		self.UpLvFumoId = body[1]
	end
	self:OnFumoChange(true)
end

function UIFumo:ListNotificationInterests()
	return {
		NotifyConsts.FumoLvUpResult,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	}
end