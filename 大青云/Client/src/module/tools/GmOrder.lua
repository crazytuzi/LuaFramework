--[[
	author:houxudong
	date: 2016/6/22
	GM 指令
]]

_G.GmOrder = BaseUI:new("GmOrder")

GmOrder.sequence = nil;
function GmOrder:Create()
	self:AddSWF("gmOrder.swf",true,"center")
end

function GmOrder:OnLoaded(objSwf)
	objSwf.btnClose.click = function()self:Hide()end
	objSwf.btnSend.click = function() self:OnBtnSendClick()end;
	local dmHp = objSwf.dmHp;
	dmHp.dataProvider:cleanUp();
	for i, dataItem in ipairs(AutoBattleUtils:GetGMSeqProvider()) do
		dmHp:decodeItem( UIData.encode(dataItem) );
	end
	dmHp.change = function(e) self:OnDmHpChange(e) end
end;

function GmOrder:OnShow()
	local objSwf = self.objSwf;
	self.objSwf.id.text = "";
	self.objSwf.num.text = "";
	self.objSwf.time.htmlText = "";
	self.sequence ="createitem";
	self:ShowTime()
	self:RegisterTimes()
	self:OnTime()
end;

function GmOrder:ShowTime( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local nowTime = GetServerTime();
	local y, m, d, hour, min, sec= CTimeFormat:todate(nowTime,true,true)
	if min < 10 then
		min = 0 ..min
	end
	if sec < 10 then
		sec = 0 ..sec
	end
	objSwf.time.htmlText = y..'/'..m..'/'..d..' '..hour..':'..min..':'..sec  
end

function GmOrder:OnTime( )
	self.timerKey = TimerManager:RegisterTimer(function()
		self:ShowTime()
	end,1000,0); 
end

function GmOrder:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function GmOrder:OnDmHpChange(e)
	self.sequence = e.data.seq;
end

function GmOrder:OnHide()
	self:RegisterTimes()
end;

function GmOrder:OnBtnSendClick()
	local objSwf = self.objSwf
	if not objSwf then return; end
	local info = "/"
	local id = objSwf.id.text
	local num = objSwf.num.text
	info = info..self.sequence..'/'..id..'/'..num
	ChatController:SendChat(ChatConsts.Channel_World,info)  ---发送聊天信息
end