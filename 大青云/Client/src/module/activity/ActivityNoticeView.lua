--[[
»î¶¯ÌáÐÑ
lizhuangzhuang
2015Äê3ÔÂ3ÈÕ22:07:13
]]

_G.UIActivityNotice = BaseUI:new("UIActivityNotice");

--Î»ÖÃÊý×é
UIActivityNotice.PosMap = {
	[1] = {x =-140, y =0},
	[2] = {x =-280,y =0},
	[3] = {x =-420, y =0},
	[4] = {x =-560, y =0},
	[5] = {x =-700, y=0}
};

--ÕýÔÚÏÔÊ¾µÄ»î¶¯Item
UIActivityNotice.itemsMap = {};

function UIActivityNotice:Create()
	self:AddSWF("activityNotice.swf",true,"bottom2");
end

function UIActivityNotice:OnDelete()
	for k,_ in pairs(self.itemsMap) do
		self.itemsMap[k] = nil;
	end
end

function UIActivityNotice:GetWidth()
	return 0;
end

function UIActivityNotice:GetHeight()
	return 0;
end

function UIActivityNotice:NeverDeleteWhenHide()
	return true;
end

--ÉèÖÃ»î¶¯ÌáÐÑÔÚÄ£ÐÍÌØÊâÀàµØÍ¼ÊÇ·ñÏÔÊ¾ --changer:hoxudong date;2016/8/8 17:55:35
function UIActivityNotice:ShowWhenActivity(inActivity)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--[[
	local mapId = MainPlayerController:GetMapId();
	if mapId == 11403001 then
		objSwf.content._visible =  true;
		objSwf.content.hitTestDisable = false;
		return;
	end
	local isHave = false;
	if mapId ~= 11403001 then 
		for k,activity in pairs(ActivityModel.list) do
			if activity:GetId() == ActivityConsts.RobBox then
				self.isHave = true;
			end
		end
	end
	if self.isHave then
		objSwf.content._visible =  false;
		objSwf.content.hitTestDisable = true;
	else
		objSwf.content._visible =  not inActivity;
		objSwf.content.hitTestDisable = inActivity;
	end
	
	local mapId = MainPlayerController:GetMapId();
	if mapId == 11403001 then
		for k,activity in pairs(ActivityModel.list) do
			if activity:GetId() == ActivityConsts.RobBox then
				objSwf.content._visible =  true;
				objSwf.content.hitTestDisable = false;
				return;
			end
		end
	end
	--]]
	objSwf.content._visible =  not inActivity;
	objSwf.content.hitTestDisable = inActivity;
end

function UIActivityNotice:OnShow()
	self:DoShowList(self.waitList);
	self.waitList = nil;
end

function UIActivityNotice:ShowNoticeList(list)
	if self:IsShow() then
		self:DoDeleteCheck(list);
		if #list > 0 then    --ÓÐÐèÒªÏÔÊ¾µÄ»î¶¯list
			-- trace(list)
			-- self.isHave = false;
			-- for k,v in pairs(list) do
			-- 	if v == ActivityConsts.RobBox then
			-- 		self.isHave = true;
			-- 	end
			-- end
			-- local mapId = MainPlayerController:GetMapId();
			-- if mapId == 11403001 and self.isHave then
			-- 	table.push(list,{1,ActivityConsts.RobBox})
			-- 	self:DoShowList(list)
			-- 	return;
			-- end
			self:DoShowList(list);
		else
			self:Hide();
		end
	else
		if #list > 0 then
			self.waitList = list;
			self:Show();
		end
	end
end

function UIActivityNotice:DoShowList(list)
	--[[
	self.isHave = false;
	local mapId = MainPlayerController:GetMapId();
	for i,activityId in ipairs(list) do
		if activityId == ActivityConsts.RobBox and mapId == 11403001 then
			self.isHave = true
		end
	end
	--]]
	for i,activityId in ipairs(list) do
		local activity = ActivityModel:GetActivity(activityId);
		if activity then
			local uiItem = self.itemsMap[activityId];
			if not uiItem then
				uiItem = self:CreateNewItem(activity);
				self.itemsMap[activityId] = uiItem;
				SoundManager:PlaySfx(2047);
			end
			local pos = self.PosMap[i];
			if not pos then
				pos = self.PosMap[#self.PosMap];
			end
			uiItem._x = pos.x;
			uiItem._y = pos.y;
			activity:DoNoticeShow(uiItem);
		end
	end
end

--´´½¨»î¶¯Í¼±ê°´Å¥
function UIActivityNotice:CreateNewItem(activity)
	local objSwf = self.objSwf;
	local depth = objSwf.content:getNextHighestDepth();
	local uiItem = objSwf.content:attachMovie(activity:NoticeLibLink(),"item"..depth,depth);
	if uiItem.button then
		uiItem.button.click = function() activity:DoNoticeClick(); end
		uiItem.button.rollOver = function() activity:OnRollOver() end;
		uiItem.button.rollOut  = function() activity:OnRollOut () end;
	end
	if uiItem.btnClose then
		uiItem.btnClose.click = function() activity:DoNoticeCloseClick(); end  --¹Ø±Õ»î¶¯ÌáÊ¾
	end
	return uiItem;
end


--¼ì²éÇå³þ¶àÓàItem
function UIActivityNotice:DoDeleteCheck(list)
	local deletelist = {};
	for id,_ in pairs(self.itemsMap) do
		local needDelete = true;
		for i,activityId in ipairs(list) do
			if id == activityId then
				needDelete = false;
				break;
			end
		end
		if needDelete then
			table.push(deletelist,id);
		end
	end
	--
	if #deletelist ~= 0 then
		UIActivityNoticeTips:Hide()
	end
	for i,id in ipairs(deletelist) do
		local uiItem = self.itemsMap[id];
		if uiItem then
			if uiItem.button then
				uiItem.button.click = nil;
			end
			if uiItem.btnClose then
				uiItem.btnClose.click = nil;
			end
			uiItem:removeMovieClip();
			self.itemsMap[id] = nil;
		end
	end
end