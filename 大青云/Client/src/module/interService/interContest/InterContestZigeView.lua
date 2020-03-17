--[[
跨服擂台预选赛资格
liyuan
]]

_G.UIInterContestZige = BaseUI:new("UIInterContestZige");

function UIInterContestZige:Create()
	self:AddSWF("interContestzige.swf", true, "center");
end

function UIInterContestZige:OnLoaded(objSwf)
	
	objSwf.btnExit.click = function()
		self:Hide()
	end
	objSwf.btnClose.click = function()
		self:Hide()
	end
	
	local constCfg = t_consts[172]
	local startArr = {}
	local startStr = '20:30'
	if constCfg then
		startArr = split(constCfg.param, '#')
		startStr = string.sub(startArr[1],1,#startArr[1]-3)
	end
	
	objSwf.txt1.text = StrConfig['interServiceDungeon74']
	objSwf.txt2.text = StrConfig['interServiceDungeon75']
	
	objSwf.txt3.text = string.format(StrConfig['interServiceDungeon73'], startStr)
end

-----------------------------------------------------------------------
function UIInterContestZige:IsTween()
	return false;
end

function UIInterContestZige:GetPanelType()
	return 0;
end

function UIInterContestZige:IsShowSound()
	return false;
end

function UIInterContestZige:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	self:UpdateInfo()	
end

function UIInterContestZige:UpdateInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end		

	local list = InterContestModel.zigeList
	if not list then return end	

	objSwf.listtxt.dataProvider:cleanUp();
	objSwf.listtxt.dataProvider:push(unpack(list));
	objSwf.listtxt:invalidateData();
end

function UIInterContestZige:OnHide()
end

function UIInterContestZige:GetWidth()
	return 378;
end

function UIInterContestZige:GetHeight()
	return 460;
end

function UIInterContestZige:OnBtnCloseClick()
	self:Hide();
end

function UIInterContestZige:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterContestZige:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterContestZige:HandleNotification(name, body)
	
end

