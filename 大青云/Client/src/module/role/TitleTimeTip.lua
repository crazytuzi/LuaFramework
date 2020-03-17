--[[
	称号时间提醒
	2014年11月26日, PM 05:32:54
	wangyanwei
]]

_G.TitleTimeTip =  BaseUI:new("TitleTimeTip");

TitleTimeTip.panelTimeData = {};

function TitleTimeTip:Create()
	self:AddSWF("titleTimeTips.swf",true,"top");
end

function TitleTimeTip:OnLoaded(objSwf)
	objSwf.btnClose.click  = function() self: OnClosepanelClick(); end;
	objSwf.confBtn.click  = function() self: OnConfDataClick(); end;
	
	objSwf.txt_Tip.text = UIStrConfig['title004'];
end

TitleTimeTip.indexNume = 1;
function TitleTimeTip:OnShow()
	local objSwf = self:GetSWF("TitleTimeTip");
	if not objSwf then return end;
	self.indexNume = self.indexNume + 1;
	if not self.panelTimeData[self.indexNume] then
		self.indexNume = self.indexNume - 1;
	end
	local nowData = self.panelTimeData[self.indexNume];
	nowData.idNameTime = string.format(StrConfig['title5'],nowData.idNameTime);
	objSwf.txt_TitleInfo.htmlText = "<font color='#f9680c'>\"<u>" .. nowData.idNameStr .. "</u>\"</font>" .. nowData.idNameTime;
end

--时间到期的文本
function TitleTimeTip:Open(cfg)
	local idName ={};
	idName.idNameStr = cfg.name;
	idName.idNameTime = 10;
	idName.timeID = id;
	table.push(self.panelTimeData,idName);
	self:Show();
end

--移除的文本
function TitleTimeTip:OpenRemove(idNameS,titleTime,id)
	local idName ={};
	idName.idNameStr = idNameS;
	idName.idNameTime = titleTime;
	idName.timeID = id;
	table.push(self.panelTimeData,idName);
	self:Show();
end

--关掉
function TitleTimeTip:OnClosepanelClick()
	self.indexNume = 1;
	self.panelTimeData = {};
	self:Hide();
end
--确定按钮事件
function TitleTimeTip:OnConfDataClick()
	self:Hide();
end

--侦听人物称号信息来改变称号面板信息
-- function TitleTimeTip:HandleNotification(name,body)
	-- if name == NotifyConsts.TitleRemoveTime then
		-- local numTime = body.time - GetServerTime();
		-- local idNameS = t_title[body.id].name;
		-- if body.time == -1 then return end
		-- if body.time == -2 then  
			-- self:Open(idNameS,toint(numTime/60,1),body.id);
			-- self:Show();
		-- end; 
		-- if body.state == 0 then 
			-- self:OpenRemove(idNameS,StrConfig['title6'],body.id);
			-- self:Show();
			-- return;
		-- end
		-- if numTime <= 600 then
			-- if numTime > 0 then
				-- self:Open(idNameS,toint(numTime/60,1),body.id);
				-- self:Show();
			-- end
		-- end
	-- end
	-- if name == NotifyConsts.TitleTipTime then
			-- if not self.bShowState then return; end
			-- local numTime = body.time - GetServerTime();
			-- local idName ={};
			-- idName.idNameStr = t_title[body.id].name;
			-- idName.timeID = body.id;
			-- if toint(numTime/60,1) > 0 then 
				-- idName.idNameTime = toint(numTime/60,1);
			-- else
				-- return;
			-- end
			-- table.push(self.panelTimeData,idName);
			-- self:OnShow();
		
	-- end
-- end
-- function TitleTimeTip:ListNotificationInterests()
	-- return {
		-- NotifyConsts.TitleRemoveTime,NotifyConsts.TitleTipTime
	-- }
-- end