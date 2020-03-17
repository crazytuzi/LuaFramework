--[[
属性加点提示
wangshaui
2015年2月5日21:49:44
]]
_G.RemindEaLeftPointQueue = setmetatable({},{__index=RemindQueue});

function RemindEaLeftPointQueue:GetType()
	return RemindConsts.Type_EaLeftPoint;
end;

function RemindEaLeftPointQueue:GetLibraryLink()
	return "RemindEaleftPoint";
end;

function RemindEaLeftPointQueue:GetPos()
	return 2;
end

function RemindEaLeftPointQueue:GetShowIndex()
	return 2;
end;

function RemindEaLeftPointQueue:GetBtnWidth()
	return 60;
end
function RemindEaLeftPointQueue:GetTConstsID()
	return 221;
end

function RemindEaLeftPointQueue:CheckCondition()
	return RoleController:RemindAddPoint();
end
function RemindEaLeftPointQueue:AddData()
	table.push( self.datalist, true )
end;

function RemindEaLeftPointQueue:DoClick()
	QuestScriptManager:DoScript( "roleleftpointguide" )
end;

--鼠标移上
function RemindEaLeftPointQueue:DoRollOver()
	TipsManager:ShowBtnTips( StrConfig["remind001"] );
end

--鼠标移出处理
function RemindEaLeftPointQueue:DoRollOut()
	TipsManager:Hide();
end