--[[
	2015Ã„Ãª8Ã”Ã‚17ÃˆÃ•, PM 10:25:58
	wangyanwei
	Â¶Â¨ÃŠÂ±Â¸Â±Â±Â¾Â¿ÂªÃŠÂ¼ÃŒÃ¡ÃŠÂ¾
]]

_G.UITimeDungeonStartTip = BaseUI:new('UITimeDungeonStartTip');

function UITimeDungeonStartTip:Create()
	self:AddSWF('timeDungeonStartTip.swf',true,'center');
end

function UITimeDungeonStartTip:OnLoaded(objSwf,name)
	objSwf.btn_out.click = function () self:OnOutClick(); end
	objSwf.btn_enter.click = function () self:OnEnterClick(); end
	objSwf.btn_close.click = function () self:OnOutClick(); end
end

function UITimeDungeonStartTip:OnShow()
	self:onTxtInfo();
end

--ÃŽÃ„Â±Â¾ÃÃ”ÃŠÂ¾info
function UITimeDungeonStartTip:onTxtInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local ndID = self.ndID;
	-- ×é¶ÓÉý¼¶¸±±¾ndIDÈ¡Öµ·¶Î§1¡ª¡ª5,×é¶ÓÌôÕ½¸±±¾ndIDÈ¡ÖµÎª1001
	objSwf.pataIcon._visible = false;
	objSwf.lingguangIcon._visible = false;
	objSwf.muyeIcon._visible = false;
	if ndID >= 1 and ndID <= 5 then
		local ndData = t_monkeytime[ndID];
		if not ndData then return end
		local itemID = ndData.key_id;
		local itemCfg = t_item[itemID];
		if not itemCfg then return end
		local color = TipsConsts:GetItemQualityColor(itemCfg.quality);
		objSwf.txt_info.htmlText = string.format(StrConfig['timeDungeon1100'],color);  --StrConfig['timeDungeon101' .. ndID]
		objSwf.lingguangIcon._visible = true;
	elseif ndID == 1001 then
		local color = '#00ff00'
		objSwf.txt_info.htmlText = string.format(StrConfig['timeDungeon1102'],color);
		objSwf.pataIcon._visible = true;
	elseif ndID == 2002 then
		local color = '#00ff00'
		objSwf.txt_info.htmlText = string.format(StrConfig['timeDungeon1102'],color);
		objSwf.muyeIcon._visible = true;
	end
end

function UITimeDungeonStartTip:OnHide()

end

UITimeDungeonStartTip.ndID = 0;
function UITimeDungeonStartTip:OnOpen(ndID)
	if ndID >=1 and ndID <= 5 then
		local cfg = t_monkeytime[ndID];
		if not cfg then return end
		self.ndID = ndID;
		if self:IsShow() then
			self:OnShow();
		else
			self:Show();
		end
	else
		self.ndID = ndID;
		print("------",self.ndID)
		if self:IsShow() then
			self:OnShow();
		else
			self:Show();
		end
	end
	
end

--Â¾ÃœÂ¾Ã¸
function UITimeDungeonStartTip:OnOutClick()
	TimeDungeonController:OnSendTipData(1);
	self:Hide();
end

--Â½Ã“ÃŠÃœÂ½Ã¸ÃˆÃ«
function UITimeDungeonStartTip:OnEnterClick()
	local capData = TeamModel:GetCaptainInfo();
	if not capData then self:Hide(); return end
	local line = capData.line;
	local myLine = CPlayerMap:GetCurLineID();
	if myLine ~= line then
		MainPlayerController:ReqChangeLine(line);
	else
		TimeDungeonController:OnSendTipData(0);
		TimeDungeonController:TimeDungeonRoomPrepare(0);
		self:Hide();
	end
end

--Â»Â»ÃÃŸÂ½Ã¡ÃŠÃ¸ÂºÃ³Â»Ã˜ÂµÃ·
function UITimeDungeonStartTip:OnChangeLineHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local myLine = CPlayerMap:GetCurLineID();
	local capData = TeamModel:GetCaptainInfo();
	if not capData then self:Hide(); return end
	local line = capData.line;
	if myLine ~= line then
		return   --Â»Â»ÃÃŸÃŠÂ§Â°Ãœ
	else
		TimeDungeonController:OnSendTipData(0);
		TimeDungeonController:TimeDungeonRoomPrepare(0);
		self:Hide();
	end
end

function UITimeDungeonStartTip:HandleNotification(name,body)
	if name == NotifyConsts.SceneLineChanged then
		self:OnChangeLineHandler();
	end
end
function UITimeDungeonStartTip:ListNotificationInterests()
	return {
		NotifyConsts.SceneLineChanged,
	}
end