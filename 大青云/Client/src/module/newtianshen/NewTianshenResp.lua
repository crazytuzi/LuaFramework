--[[
	新天神
]]

_G.UINewTianshenResp = BaseUI:new('UINewTianshenResp');

function UINewTianshenResp:Create()
	self:AddSWF('newTianShenResp.swf',true,nil);
end

function UINewTianshenResp:OnLoaded(objSwf)
	objSwf.closeBtn.click = function()
		self:Hide()
	end
	objSwf.respBtn.click = function()
		self:AskResp()
	end
	objSwf.lvBtn.click = function()
		local lv = NewTianshenModel:GetTianshen(self.id):GetLv()
		objSwf.txt_des.htmlText = string.format(StrConfig['newtianshen15'], lv, lv)
		self.selecteState = 1
		self:ShowTianshenList()
	end
	objSwf.starBtn.click = function()
		local star = NewTianshenModel:GetTianshen(self.id):GetStar()
		objSwf.txt_des.htmlText = string.format(StrConfig['newtianshen16'], star, star)
		self.selecteState = 2
		self:ShowTianshenList()
	end

	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["newtianshen206"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end
end

function UINewTianshenResp:OnShow()
	if not self.args or not self.args[1] then
		self:Hide()
		return
	end
	self.id = self.args[1]
	self:InitSelectInfo()
	self:ShowTianshenList()
end

function UINewTianshenResp:InitSelectInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local tianshen = NewTianshenModel:GetTianshen(self.id)
	if not tianshen then self:Hide() return end
	local bSelect = false
	if NewTianshenUtil:IsCanRespLv(tianshen) then
		self.selecteState = 1
		objSwf.lvBtn.selected = true
		objSwf.lvBtn.disabled = false
		local lv = NewTianshenModel:GetTianshen(self.id):GetLv()
		objSwf.txt_des.htmlText = string.format(StrConfig['newtianshen15'], lv, lv)
		bSelect = true
	else
		self.selecteState = 2
		objSwf.lvBtn.disabled = true
		objSwf.lvBtn.selected = false
	end
	if NewTianshenUtil:IsCanRespStar(tianshen) then
		if not bSelect then
			objSwf.starBtn.selected = true
			local star = NewTianshenModel:GetTianshen(self.id):GetStar()
			objSwf.txt_des.htmlText = string.format(StrConfig['newtianshen16'], star, star)
		end
		objSwf.starBtn.disabled = false
	else
		objSwf.starBtn.disabled = true
		objSwf.starBtn.selected = false
	end
	return
end

function UINewTianshenResp:ShowTianshenList()
	local objSwf = self.objSwf
	if not objSwf then return end
	local tianshen1 = NewTianshenModel:GetTianshen(self.id)
	local list = {}
	local fightList = NewTianshenModel:GetFightList()

	local bSelect = false
	local count = 0
	for i = 0, 5 do
		local tianshen = fightList[i]
		local UI = objSwf['tianshenBtn' ..count]
		if tianshen then
			count = count + 1
			UI._visible = true
			UI.id = tianshen:GetId()
			UI.txt_name.htmlText = tianshen:GetHtmlName()
			UI.txt_lv.htmlText = tianshen:GetLv() .. "级"
			UI.txt_zizhi.htmlText = "资质：" ..tianshen:GetZizhi()
			UI.txt_fight.htmlText = "战斗力：" ..tianshen:GetFightValue()
			UI.txt_star.text = "+" .. tianshen:GetStar()
			
			if UI.icon.source ~= tianshen:GetIcon() then
				UI.icon.source = tianshen:GetIcon()
				UI.icon.loaded = function()
					UI.icon._width = 58
					UI.icon._height = 58
				end
			end
			UI.pfx1:gotoAndStop(tianshen:GetQuality() + 1)
			UI.pfx:gotoAndStop(tianshen:GetQuality() + 1)
			if self.selecteState == 1 then
				if tianshen:GetLv() < tianshen1:GetLv() then
					UI.disabled = false
					if not bSelect then
						UI.selected = true
					end
				else
					UI.disabled = true
					UI.selected = false
				end
			elseif self.selecteState == 2 then
				if tianshen:GetQuality() == tianshen1:GetQuality() then
					UI.disabled = false
					if not bSelect then
						UI.selected = true
					end
				else
					UI.disabled = true
					UI.selected = false
				end
			end
		end
	end
	for i = count, 5 do
		objSwf['tianshenBtn' ..i]._visible = false
	end
end

function UINewTianshenResp:AskResp()
	for i = 0, 5 do
		if self.objSwf['tianshenBtn' ..i].selected then
			NewTianshenController:AskResp(self.id, self.objSwf['tianshenBtn' ..i].id, self.selecteState)
			self:Hide()
			return
		end
	end
	if self.selecteState == 1 then
		FloatManager:AddNormal(StrConfig['newtianshen113'])
	else
		FloatManager:AddNormal(StrConfig['newtianshen114'])
	end
end