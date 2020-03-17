--[[
主界面,聊天
lizhuangzhuang
2014年7月29日11:02:53
]]

_G.UIChat = BaseUI:new("UIChat");

UIChat.channels = {};--所有显示的频道
UIChat.currChannel = 0;--当前频道
UIChat.inputChannels = {};--所有可输入的频道
UIChat.currInputChannel = 0;--当前输入频道

UIChat.isAutoHide = false;--是否是自动隐藏状态
UIChat.outTime = 0;--鼠标离开UI的时间

UIChat.lastSendTime = 0;--上次发送时间
UIChat.lastSendText = nil;--上次发送的内容

UIChat.currLink = "";--当前链接
UIChat.quickSend = nil;--存储快捷发送

UIChat.RefreshTime = 500;--聊天刷新时间(ms)
UIChat.lastRefreshTime = 0;--聊天上次刷新时间
UIChat.refreshState = 0;--刷新状态:0正常,1等待刷新

function UIChat:Create()
	self:AddSWF("chat.swf",true,"interserver");
end

function UIChat:OnLoaded(objSwf,name)
	ChatUtil:InitFilter();
	objSwf.btnHide.click = function() self:OnBtnHideClick();end
	objSwf.mcAlwaysNotice.hrefEvent = function(e) self:OnAlwayNoticeClick(e); end
	objSwf.top.chatText.linkOver = function(e) self:OnLinkOver(e); end
	objSwf.top.chatText.linkOut = function() self:OnLinkOut(); end
	objSwf.top.chatText.linkClick = function() self:OnLinkClick(); end
	objSwf.top.panelResize = function() self:OnChatResize(); end
	--objSwf.cbChannel.cbChannelWorld.click = function() self:OnCBChannelClick(); end
	--objSwf.cbChannel.cbChannelGuild.click = function() self:OnCBChannelClick(); end
	objSwf.bottom.btnSetting.click = function() TipsManager:Hide();self:OnBtnSettingClick();end
	objSwf.bottom.btnPos.click = function() TipsManager:Hide();self:OnBtnPosClick();end
	objSwf.bottom.btnHorn.click = function() TipsManager:Hide();self:OnBtnHornClick();end
	objSwf.bottom.btnFace.click = function() TipsManager:Hide();self:OnBtnFaceClick();end
	objSwf.bottom.btnEnter.click = function() self:OnBtnEnterClick();end
	objSwf.bottom.ddChannel.change = function(e) self:OnDDChannelClick(e);end
	objSwf.channelBar.itemClick = function(e) self:OnChannelItemClick(e);end
	objSwf.bottom.input.restrict = ChatConsts.Restrict;
	objSwf.bottom.input.textChange = function() self:OnInputChange(); end
	objSwf.bottom.input.pressKeyUp = function() self:OnInputKeyUp(); end
	objSwf.bottom.btnSetting.rollOver = function() TipsManager:ShowBtnTips(StrConfig['chat105']); end
	objSwf.bottom.btnSetting.rollOut = function() TipsManager:Hide(); end
	objSwf.btnHide.rollOver = function()
								if objSwf.btnHide.selected then
									TipsManager:ShowBtnTips(StrConfig['chat104']);
								else
									TipsManager:ShowBtnTips(StrConfig['chat103']);
								end
							end
	objSwf.btnHide.rollOut = function() TipsManager:Hide(); end
	objSwf.bottom.btnPos.rollOver = function() TipsManager:ShowBtnTips(string.format(StrConfig['chat106'],ChatConsts.UsePosInterval)); end
	objSwf.bottom.btnPos.rollOut = function() TipsManager:Hide(); end
	objSwf.bottom.btnHorn.rollOver = function() TipsManager:ShowBtnTips(StrConfig['chat107']); end
	objSwf.bottom.btnHorn.rollOut = function() TipsManager:Hide(); end
	objSwf.bottom.btnFace.rollOver = function() TipsManager:ShowBtnTips(StrConfig["chat111"]); end
	objSwf.bottom.btnFace.rollOut = function() TipsManager:Hide(); end
	self:HideHorn();
end

function UIChat:OnResize(wWidth,wHeight)
	self:SetUIPos();
end

function UIChat:SetUIPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf._x = 0;
	objSwf._y = wHeight-352;
end

function UIChat:GetHeight()
	local objSwf = self.objSwf;
	if not objSwf then return 0; end
	return 38+objSwf.top._height+objSwf.hornPanel._height;
end

--聊天窗口缩放
function UIChat:OnChatResize()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.hornPanel._y = objSwf.bottom._y - objSwf.top._height - 85;
	--objSwf.cbChannel._y = objSwf.bottom._y - objSwf.top._height-5;
	objSwf.channelBar._y=objSwf.bottom._y - objSwf.top._height+10
	self:OnAlwaysNoticeResize();
end

--调整提示信息位置
function UIChat:OnAlwaysNoticeResize()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if objSwf.hornPanel._visible then
		objSwf.mcAlwaysNotice._y = objSwf.hornPanel._y - objSwf.mcAlwaysNotice._height;
	else
		objSwf.mcAlwaysNotice._y = objSwf.bottom._y - objSwf.top._height - objSwf.mcAlwaysNotice._height;
	end
end

--设置常置公告内容
function UIChat:SetAlwaysNotice()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if ChatModel.alwaysNotice == "" then
		objSwf.mcAlwaysNotice.tfText.htmlText = "";
		objSwf.mcAlwaysNotice.tfText._height = 20;
		objSwf.mcAlwaysNotice.mcNormal._visible = true;
	else
		objSwf.mcAlwaysNotice.mcNormal._visible = false;
		objSwf.mcAlwaysNotice.tfText.htmlText = ChatModel.alwaysNotice;
		objSwf.mcAlwaysNotice.tfText._height = objSwf.mcAlwaysNotice.tfText.textHeight + 5;
	end
	self:OnAlwaysNoticeResize();
end

function UIChat:OnAlwayNoticeClick(e)
	_sys:browse(e.param);
end

function UIChat:OnShow()
	self:SetUIPos();
	self:OnChatResize();
	self:ShowChannels();
	self:ShowDropDownChannels();
	self:ShowChat();
	self:SetAlwaysNotice();
	if self.autoHideTimerKey then
		TimerManager:UnRegisterTimer(self.autoHideTimerKey);
		self.autoHideTimerKey = nil;
	end
	self.autoHideTimerKey = TimerManager:RegisterTimer(function()
		self:AutoHideCheck();
	end,500,0);
end

function UIChat:OnHide()
	if self.autoHideTimerKey then
		TimerManager:UnRegisterTimer(self.autoHideTimerKey);
		self.autoHideTimerKey = nil;
	end
end

function UIChat:Update(e)
	if self.refreshState == 1 then
		if GetCurTime()-self.lastRefreshTime > UIChat.RefreshTime then
			self:ShowChat();
			self.lastRefreshTime = GetCurTime();
			self.refreshState = 0;
		end
	end
end

function UIChat:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.ChatChannelRefresh then
		if body.channel == self.currChannel then
			if GetCurTime()-self.lastRefreshTime > UIChat.RefreshTime then
				self:ShowChat();
				self.lastRefreshTime = GetCurTime();
				self.refreshState = 0;
			else
				self.refreshState = 1;
			end
		end
	elseif name == NotifyConsts.ChatChannelNewMsg then
		self:ShowChannelEffect(body.channel);
	elseif name==NotifyConsts.TeamJoin or name==NotifyConsts.TeamQuit then
		self:OnChannelOpenClose(ChatConsts.Channel_Team);	
	elseif name == NotifyConsts.MyUnionInfoUpdate then
		self:OnChannelOpenClose(ChatConsts.Channel_Guild);
	elseif name == NotifyConsts.StageClick then
		local inputTarget = string.gsub(self.objSwf.bottom.input._target,"/",".");
		if string.find(body.target,inputTarget) then
			return;
		end
		self:SetFocus(false);
	elseif name == NotifyConsts.StageFocusOut then
		self:SetFocus(false);
	end
end

function UIChat:ListNotificationInterests()
	return {NotifyConsts.ChatChannelRefresh,
			NotifyConsts.ChatChannelNewMsg,
			NotifyConsts.TeamJoin,NotifyConsts.TeamQuit,NotifyConsts.MyUnionInfoUpdate,
			NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end

--聊天获取焦点
function UIChat:SetFocus(focuse)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bottom.input.focused = focuse;
	if focuse then
		self:DoAutoHide(false);
	end
end

--显示聊天
function UIChat:ShowChat()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local channel = ChatModel:GetChannel(self.currChannel);
	if not channel then return; end
	local text = "";
	for i,chatVO in ipairs(channel.chatList) do
		if self.currChannel~=ChatConsts.Channel_All or chatVO:GetType()~=0 then
			text = text .. chatVO:GetText();
			if i < #channel.chatList then
				text = text .. "<br/>";
			end
		else
			-- if (chatVO.channel==ChatConsts.Channel_World and not objSwf.cbChannel.cbChannelWorld.selected) or
			-- 	(chatVO.channel == ChatConsts.Channel_Guild and not objSwf.cbChannel.cbChannelGuild.selected) or
			-- 	(chatVO.channel~=ChatConsts.Channel_World and chatVO.channel~=ChatConsts.Channel_Guild) then
				text = text .. chatVO:GetText();
				if i < #channel.chatList then
					text = text .. "<br/>";
				end
			--end
		end
	end
	objSwf.top.chatText.htmlText = text;
	objSwf.top.chatText.position = objSwf.top.chatText.maxscroll;
end

function UIChat:OnCBChannelClick()
	if self.currChannel == ChatConsts.Channel_All then
		self:ShowChat();
	end
end

--显示频道
function UIChat:ShowChannels()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bar = objSwf.channelBar;
	self.channels = ChatUtil:GetShowChannels();
	local listStr = "";
	for i,channelListVO in ipairs(self.channels) do
		local uiDataStr = UIData.encode(channelListVO);
		listStr = listStr .. uiDataStr;
		if i < #self.channels then
			listStr = listStr .. ",";
		end
	end
	bar:setList(listStr);
	--
	for i,vo in ipairs(self.channels) do
		if self.currChannel == vo.channel then
			bar.selectedIndex = i-1;
			return;
		end
	end
	bar.selectedIndex = 0;
	self.currChannel = self.channels[1].channel;
	--self:DoShowCBChannel();
end

--设置选择频道列表
function UIChat:ShowDropDownChannels()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local dropDown = objSwf.bottom.ddChannel;
	self.inputChannels = ChatUtil:GetShowChannels(true);
	if #self.inputChannels <=0 then return; end
	dropDown.dataProvider:cleanUp();
	for i,vo in ipairs(self.inputChannels) do
		dropDown.dataProvider:push(vo.name);
	end
	--
	for i,vo in ipairs(self.inputChannels) do
		if self.currInputChannel == vo.channel then
			dropDown.selectedIndex = i-1;
			return;
		end
	end
	dropDown.selectedIndex = 0;
	self.currInputChannel = self.inputChannels[1].channel;
end

--点击选择频道
function UIChat:OnChannelItemClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.channels[e.index+1] then return; end
	local channelListVO = self.channels[e.index+1];
	if self.currChannel == channelListVO.channel then
		return;
	end
	self.currChannel = channelListVO.channel;
	--如果频道被过滤，添加提示
	if ChatModel.chatSetting.channel[self.currChannel] then
		local channelVO = ChatModel:GetChannel(self.currChannel);
		if channelVO then
			channelVO:AddFilterTips();
		end
	end
	self:ShowChat();
	--取消特效
	local button = objSwf.channelBar:getButtonAtIndex(e.index);
	if button then
		button.eff:stopEffect();
	end
	--切换频道时输入频道自动切换
	local dropDown = objSwf.bottom.ddChannel;
	for i,vo in ipairs(self.inputChannels) do
		if vo.channel == self.currChannel then
			dropDown.selectedIndex = i-1;
		end
	end
	--
	--self:DoShowCBChannel();
end

function UIChat:DoShowCBChannel()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.currChannel == ChatConsts.Channel_All then

		objSwf.cbChannel.cbChannelWorld.visible = true;
		objSwf.cbChannel.cbChannelGuild.visible = true;
	else
		objSwf.cbChannel.cbChannelWorld.visible = false;
		objSwf.cbChannel.cbChannelGuild.visible = false;
	end
end

--点击切换输入频道
function UIChat:OnDDChannelClick(e)
	if not self.inputChannels[e.index+1] then return; end
	local channelListVO = self.inputChannels[e.index+1];
	if self.currInputChannel == channelListVO.channel then
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local color = ChatConsts:GetChannelColor(channelListVO.channel);
	color = "0x" .. string.sub(color,2,#color);
	objSwf.bottom.input.textField.textColor = color;
	self.currInputChannel = channelListVO.channel;
end

--显示频道新消息特效
function UIChat:ShowChannelEffect(channel)
	if channel == self.currChannel then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,vo in ipairs(self.channels) do
		if vo.channel == channel then
			local button = objSwf.channelBar:getButtonAtIndex(i-1);
			if button then
				button.eff:playEffect(0);
				return;
			end
		end
	end
end

--某个频道开启
function UIChat:OnChannelOpenClose(channel)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bar = objSwf.channelBar;
	self.channels = ChatUtil:GetShowChannels();
	for i,vo in ipairs(self.channels) do
		if vo.channel == channel then
			if vo.state==0 and self.currChannel==channel then
				bar.selectedIndex = 0;
				self.currChannel = self.channels[1].channel;
			end
			bar:setChannelState(i-1,vo.state);
			break;
		end
	end
	self:ShowDropDownChannels();
end

--点击收缩聊天
function UIChat:OnBtnHideClick()
	TipsManager:Hide();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local show = not objSwf.btnHide.selected;
	objSwf.bottom._visible = show;
	objSwf.bottom.hitTestDisable = not show;
	objSwf.top.visible = show;
	objSwf.channelBar._visible=show;
	objSwf.channelBar.hitTestDisable = not show;
	--objSwf.cbChannel._visible = show;
	--objSwf.cbChannel.hitTestDisable = not show;
end

--点击设置聊天
function UIChat:OnBtnSettingClick()
	if UIChatSetting:IsShow() then
		UIChatSetting:Hide();
	else
		UIChatSetting:Show();
	end
end

--点击发送位置
function UIChat:OnBtnPosClick()
	if not ChatQuickSend:SendPos() then
		FloatManager:AddNormal(StrConfig["chat116"]);
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bottom.btnPos.disabled = true;
	TimerManager:RegisterTimer(
		function()
			objSwf.bottom.btnPos.disabled = false;
		end,ChatConsts.UsePosInterval*1000,1);
end

--点击喇叭
function UIChat:OnBtnHornClick()
	 FloatManager:AddNormal( StrConfig['chat120'] );
	--[[
	if UIChatHornSend:IsShow() then
		UIChatHornSend:Hide();
	else
		UIChatHornSend:Open();
	end
	--]]
end

--点击表情
function UIChat:OnBtnFaceClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	UIChatFace:Open(function(text)
		objSwf.bottom.input:appendText(text);
		objSwf.bottom.input.focused = true;
	end,objSwf.bottom.btnFace);
end

--点击回车
function UIChat:OnBtnEnterClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local text = objSwf.bottom.input.text;
	if text == "" then return; end
	if GetServerTime()-self.lastSendTime < ChatConsts.InputInterval then
		ChatController:AddSysNotice(self.currChannel,2001201,"",true);
		objSwf.bottom.input.text = "";
		self.lastSendText = text;
		return;
	end
	self:SendChat(text);
	objSwf.bottom.input.text = "";
	self.lastSendTime = GetServerTime();
	self.lastSendText = text;
end

--输入内容改变时
function UIChat:OnInputChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local text = objSwf.bottom.input.text;
	if text=="" then return; end
	local hasEnter = false;
	text,hasEnter = ChatUtil:FilterInput(text);
	local len = 0;
	text,len = ChatUtil:CheckInputLength(text);
	if hasEnter or text:tail("\r") then
		if text:tail("\r") then
			local textLen = text:len();
			text = string.sub(text,1,textLen-1);
		end
		if text=="" then 
			objSwf.bottom.input.text = "";
			return;
		end
		if GetServerTime()-self.lastSendTime < ChatConsts.InputInterval then
			ChatController:AddSysNotice(self.currChannel,2001201,"",true);
			self.lastSendText = text;
			objSwf.bottom.input.text = "";
			return;
		end
		self:SendChat(text);
		objSwf.bottom.input.text = "";
		self.lastSendTime = GetServerTime();
		self.lastSendText = text;
	else
		objSwf.bottom.input.text = text;
	end
end

--发送聊天
function UIChat:SendChat(text)
	if self.quickSend then
		text = string.gsub(text,"%[[^%[%]]+%]",
			function(pattern)
				local t = self.quickSend[pattern];
				if not t then return pattern; end
				if #t<=0 then return pattern; end
				return table.remove(t,1);
			end);
	end
	hack(text);
	ChatController:SendChat(self.currInputChannel,text);
	self.quickSend = nil;
end

--按上翻页
function UIChat:OnInputKeyUp()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.lastSendText then return; end
	if objSwf.bottom.input.text ~= "" then return; end
	objSwf.bottom.input.text = self.lastSendText;
end

-----------自动隐藏处理-----------
local leftUpPoint = {x=0,y=0}
function UIChat:AutoHideCheck()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if objSwf.bottom.input.focused then 
		self.outTime = 0;
		return; 
	end
	if objSwf.btnHide.selected then
		self.outTime = 0;
		return;
	end
	local mousePos = _sys:getRelativeMouse();
	UIManager:PosLtoG(objSwf,0,objSwf.bottom._y - objSwf.top._height,leftUpPoint);
	if mousePos.x > leftUpPoint.x and mousePos.y > leftUpPoint.y and mousePos.x <  leftUpPoint.x + objSwf.top._width then
		self:DoAutoHide(false);
		self.outTime = 0;
	else
		self.outTime = self.outTime + 500;
		if self.outTime > ChatConsts.PanelAutoHideTime then
			self:DoAutoHide(true);
		end
	end
end

function UIChat:DoAutoHide(hide)
	if self.isAutoHide == hide then return; end
	self.isAutoHide = hide;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if hide then
		Tween:To(objSwf.bottom,0.5,{_alpha=0},{onComplete=function() objSwf.top.bg._visible = false; end});
		Tween:To(objSwf.btnHide,0.5,{_alpha=0},{onComplete=function() objSwf.btnHide._visible=false; end});
		Tween:To(objSwf.top.bg,0.5,{_alpha=0},{onComplete=function() 
											objSwf.top.bg._visible=false;
											objSwf.top.btnResize.visible = false;
											end});
	else
		objSwf.bottom._visible = true;
		Tween:To(objSwf.bottom,0.5,{_alpha=100});
		objSwf.btnHide._visible = true;
		Tween:To(objSwf.btnHide,0.5,{_alpha=100});
		Tween:To(objSwf.top.bg,0.5,{_alpha=100});
		objSwf.top.bg._visible = true;
		objSwf.top.btnResize.visible = true;
	end
end


-----------链接处理---------------
function UIChat:OnLinkOver(e)
	if e.url==self.currLink then return; end
	self.currLink = e.url;
	local params = split(self.currLink,",");
	if #params<=0 then return; end
	local type = toint(params[1]);
	local parseClass = ChatConsts.ChatParamMap[type];
	if not parseClass then return; end
	local parser = parseClass:new();
	parser:DoLinkOver(self.currLink);
end
function UIChat:OnLinkOut()
	self.currLink = "";
	TipsManager:Hide();
end
function UIChat:OnLinkClick()
	if self.currLink=="" then return; end
	local params = split(self.currLink,",");
	if #params<=0 then return; end
	local type = toint(params[1]);
	local parseClass = ChatConsts.ChatParamMap[type];
	if not parseClass then return; end
	local parser = parseClass:new();
	parser:DoLink(self.currLink);
end

-----------------------快捷发送的处理---------------
--快捷发送规则
function UIChat:AddQuickSend(key,val)
	if not key then return; end
	if not val then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.quickSend then
		self.quickSend = {};
	end
	if not self.quickSend[key] then
		self.quickSend[key] = {};
	end
	table.push(self.quickSend[key],val);
	objSwf.bottom.input:appendText(key);
	self:SetFocus(true);
	self:OnInputChange();
end

--通过聊天发送一段话
function UIChat:AddSend(text,channel)
	if not channel then channel = self.currInputChannel; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currInputChannel = channel;
	self:ShowDropDownChannels();
	objSwf.bottom.input.text = text;
	self:OnBtnEnterClick();
end

--------------------------喇叭的处理--------------------------
--显示喇叭
function UIChat:ShowHorn(text)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.hornPanel.visible = true; 
	objSwf.hornPanel.text = text;
	objSwf.hornPanel.hornEffect:playEffect(1)
	self:OnAlwaysNoticeResize();
end
--隐藏喇叭
function UIChat:HideHorn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.hornPanel.hornEffect:stopEffect()
	Tween:To(objSwf.hornPanel,0.5,{_alpha=0},
								{onComplete=function()
									objSwf.hornPanel.visible = false;
									objSwf.hornPanel._alpha = 100;
									self:OnAlwaysNoticeResize();
								end});
end

function UIChat:ClientText(text)
	if not isDebug then
		return;
	end
	if not self.objSwf then
		return;
	end
	if not text then
		return;
	end
	text = text.."<br/>"
	self.objSwf.top.chatText.htmlText = text;
	self.objSwf.top.chatText.position = self.objSwf.top.chatText.maxscroll;
end
