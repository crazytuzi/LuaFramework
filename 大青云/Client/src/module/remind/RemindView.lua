--[[
下方提醒面板
lizhuangzhuang
2014年10月21日15:48:29
]]

_G.UIRemind = BaseUI:new("UIRemind");

--按钮显示方向
UIRemind.Pos = {
	[1] = { x=1, y=0},
	[2] = { x=1, y=0},
	[3] = { x=-1, y=0},
	[4] = { x=-1, y=0}
}

UIRemind.buttons = {};

function UIRemind:Create()
	self:AddSWF("remindPanel.swf",true,"bottom2");
end

function UIRemind:OnLoaded(objSwf)
	for k,vo in pairs(UIRemind.Pos) do
		local depth = objSwf:getNextHighestDepth();
		objSwf:createEmptyMovieClip("content"..k,depth);
	end
end

--按钮位置
function UIRemind:GetBtnXY(pos)
	local wWidth, wHeight = UIManager:GetWinSize();
	-- print('======================pos',wWidth, wHeight)
	if pos == 1 then
		return 405,wHeight-250;
	elseif pos == 2 then
		return wWidth/2 +200,wHeight-205;
	elseif pos == 3 then
		return wWidth - 380,470;
	elseif pos == 4 then--帮派战
		return wWidth/2 +400, wHeight-325;
	else
		return 0,0;
	end
end

function UIRemind:OnResize(wWidth,wHeight)
	self:Refresh();
end

function UIRemind:GetHeight()
	return 0;
end

function UIRemind:GetWidth()
	return 0;
end

function UIRemind:NeverDeleteWhenHide()
	return true;
end

--设置在模型活动类地图是否显示
function UIRemind:ShowWhenActivity(inActivity)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local activityRemind = objSwf.content3;
	if not activityRemind then return; end
	activityRemind._visible = not inActivity;
	activityRemind.hitTestDisable = inActivity;
end

function UIRemind:OnShow()
	self:Refresh();
end

function UIRemind:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.RemindRefresh then
		self:Refresh();
	elseif name == NotifyConsts.AcrossDayInform then
		RemindController:ClearRemind( RemindConsts.Type_GuildZhaoji )
	end
end

function UIRemind:ListNotificationInterests()
	return { NotifyConsts.RemindRefresh, NotifyConsts.AcrossDayInform };
end

--刷新显示
function UIRemind:Refresh()
	--按位置分组
	local poslist = {};
	for k,remindQueue in pairs(RemindModel.queueList) do
		local pos = remindQueue:GetPos();
		if not poslist[pos] then
			poslist[pos] = {};
		end
		table.push(poslist[pos],remindQueue);
	end
	--组内按showIndex排序
	for pos,queuelist in pairs(poslist) do
		table.sort( queuelist, function(A,B) return A:GetShowIndex() < B:GetShowIndex(); end );
	end
	--显示
	for pos, queuelist in pairs(poslist) do
		self:ShowQueueList(pos, queuelist);
	end
end

function UIRemind:ShowQueueList(pos,list)
	local posX,posY = self:GetBtnXY(pos);
	local offsetX,offsetY = UIRemind.Pos[pos].x,UIRemind.Pos[pos].y;--偏移量
	local x = posX;
	local y = posY;
	local index = 1;
	for i,remindQueue in ipairs(list) do
		if remindQueue:GetIsShow() then
			local button = remindQueue:GetButton();
			if not button then
				button = self:CreateButton(remindQueue:GetType());
				remindQueue:SetButton(button);
			end
			remindQueue:ShowButton();
			local showNum = remindQueue:GetShowNum();
			if showNum then
				button.num = showNum;
			end
			local buttonWidth = remindQueue:GetBtnWidth();
			if not buttonWidth then
				buttonWidth = button.width;
			end
			local buttonHeight = remindQueue:GetBtnHeight()
			if not buttonHeight then
				buttonHeight = button.height;
			end

			--换行
			buttonHeight = 60;
			x = posX + (buttonWidth * offsetX * ((index - 1) % 5));
			y = posY - (buttonHeight * math.floor((index - 1) / 5));
			button._y = y;
			button._x = x;
			index = index + 1;
		else
			local button = remindQueue:GetButton();
			remindQueue:HideButton();
		end
	end
end

--创建按钮
function UIRemind:CreateButton(type)
	local buttonName = "btn"..type;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local remindQueue = RemindModel:GetQueue(type);
	if not remindQueue then return; end
	local librayLink = remindQueue:GetLibraryLink();
	if not librayLink then return; end
	local pos = remindQueue:GetPos();
	local content = objSwf["content"..pos];
	if not content then
		print("Error:Add remind.Cannot find content.Pos:",pos);
		return;
	end
	
	local depth = content:getNextHighestDepth();
	local button = content:attachMovie(librayLink,buttonName,depth);
	return button;
end
