--[[
	新天神
]]

_G.UINewTianshenOper = BaseUI:new('UINewTianshenOper');

function UINewTianshenOper:Create()
	self:AddSWF('newTianshenOper.swf',true,"center");
end

function UINewTianshenOper:OnLoaded(objSwf)
	objSwf.btn1.click = function()
		UIConfirm:Hide()
		if not self.tianshen then
			return
		end
		if self.tianshen:GetPos() == -1 then
			if not NewTianshenModel:GetNoTianshenPos() or NewTianshenModel:HaveFightByTianshenID(self.tianshen:GetTianshenID()) then
				local changeTianshen = NewTianshenModel:GetCanChangeTianshen(self.tianshen)
				if changeTianshen then
					local goFunc = function ()
						if self.tianshen and changeTianshen then
							NewTianshenController:AskFight(self.tianshen:GetId(), changeTianshen:GetPos())
						end
					end
					local str = string.format(StrConfig['newtianshen42'], self.tianshen:GetColor(), self.tianshen:GetHtmlName(), self.tianshen:GetColor(), self.tianshen:GetHtmlZizhi(),
					changeTianshen:GetColor(), changeTianshen:GetHtmlName(), changeTianshen:GetColor(), changeTianshen:GetHtmlZizhi())
					local bLv, bStar = NewTianshenUtil:IsCanAcceptLvAndStar(changeTianshen, self.tianshen)
					str = str .. '\n'
					if bLv then
						str = str .. '\n' .. StrConfig['newtianshen48']
					end
					if bStar then
						str = str .. '\n' .. StrConfig['newtianshen49']
					end
					UIConfirm:Open(str,goFunc)
					self:Hide()
					return
				else
					FloatManager:AddNormal(StrConfig['newtianshen107'])
					self:Hide()
					return
				end
			end
			NewTianshenController:AskFight(self.tianshen:GetId(), NewTianshenModel:GetNoTianshenPos())
		else
			NewTianshenController:AskFight(self.tianshen:GetId(), -1)
		end
		self:Hide()
	end
	objSwf.btn2.click = function()
		if not self.tianshen then
			return
		end
		if self.tianshen:GetPos() == -1 then
			if MainPlayerModel.humanDetailInfo.eaLevel < 80 then
				FloatManager:AddNormal(StrConfig['newtianshen111'])
				self:Hide()
				return
			end
			local goFunc = function()
				if self.tianshen then
					NewTianshenController:AskDis(self.tianshen:GetId())
				end
			end
			local str = string.format(StrConfig['newtianshen19'], 
				TipsConsts:GetItemQualityColor(self.tianshen:GetQuality()), self.tianshen:GetName(), 
				TipsConsts:GetItemQualityColor(self.tianshen:GetQuality()),self.tianshen:GetZizhi())
			local str1
			if self.tianshen:GetQuality() == 0 then
				str = str .. StrConfig['newtianshen46']
				str1 = nil
			else
				str = str .. StrConfig['newtianshen47']
				str1 = (152200000 + self.tianshen:GetQuality()) .. ",1,1"
			end
			UIConfirm:Open(str,goFunc,nil,nil,nil,nil,nil,nil,str1)
		else
			UINewTianshenBasic:OnPageBtnClick(2, self.tianshen:GetPos())
		end
		self:Hide()
	end
	objSwf.btn3.click = function()
		if not self.tianshen then
			return
		end
		if self.tianshen:GetPos() == -1 then
			UINewTianshenResp:Show(self.tianshen:GetId())
		end
		self:Hide()
	end
end

function UINewTianshenOper:OnShow()
	if self.tianshen:GetPos() == -1 and NewTianshenUtil:IsCanResp(self.tianshen) then
		self.objSwf.btn1.label = UIStrConfig['newtianshen20']
		self.objSwf.btn2.label = UIStrConfig['newtianshen21']
		self.objSwf.btn3.label = UIStrConfig['newtianshen28']
		self.objSwf.btn3._visible = true
		self.objSwf.bg._height = 78
	elseif self.tianshen:GetPos() == -1 then
		self.objSwf.btn1.label = UIStrConfig['newtianshen20']
		self.objSwf.btn2.label = UIStrConfig['newtianshen21']
		self.objSwf.btn3._visible = false
		self.objSwf.bg._height = 55
	else
		self.objSwf.btn1.label = UIStrConfig['newtianshen23']
		self.objSwf.btn2.label = UIStrConfig['newtianshen24']
		self.objSwf.btn3._visible = false
		self.objSwf.bg._height = 55
	end
	self.objSwf._x = self.pos.x
	self.objSwf._y = self.pos.y - self.objSwf.bg._height
end

function UINewTianshenOper:Open(tianshen, pos)
	self.tianshen = tianshen
	self.pos = pos
	if not self.tianshen then
		return
	end
	if self:IsShow() then
		self:Top()
		self:OnShow()
	else
		self:Show()
	end
end

--点击其他地方,关闭
function UINewTianshenOper:HandleNotification(name,body)
	local objSwf = self.objSwf
	if not objSwf then return end

	-- self:Hide()
end

function UINewTianshenOper:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end