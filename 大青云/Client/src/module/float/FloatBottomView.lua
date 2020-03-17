--[[
漂浮文字
Bottom层
lizhuangzhuang
2015年5月13日15:05:16
]]

_G.UIFloatBottom = BaseUI:new("UIFloatBottom");

UIFloatBottom.userInfoArr = {};--VO:{mc:显示对象,lastTime:剩余时间}

function UIFloatBottom:Create()
	self:AddSWF("floatbottom.swf",false,"bottom2");
end

function UIFloatBottom:GetWidth()
	return 0;
end

function UIFloatBottom:GetHeight()
	return 0;
end


--显示个人信息类漂浮文字
function UIFloatBottom:ShowUserInfo(text)
	local objSwf = self.objSwf;
	if not objSwf then return;end
	local depth = objSwf:getNextHighestDepth();
	local mc = objSwf:attachMovie("userInfo",self:GetMcName(),depth);
	mc.tf.htmlText = text;
	mc._x = _rd.w-430;
	mc._y = _rd.h-155;
	--
	local vo = {mc=mc,lastTime=3000};
	table.insert(self.userInfoArr,1,vo);
end


function UIFloatBottom:Update(dwInterval)
	--处理玩家信息列表
	while #self.userInfoArr > 3 do
		local vo = table.remove(self.userInfoArr);
		Tween:To(vo.mc,0.5,{_y=_rd.h-355,_alpha=0},{
			onComplete = function()
				vo.mc:removeMovieClip();
				vo.mc = nil;
			end});
	end
	for index,vo in ipairs(self.userInfoArr) do
		vo.mc._y = _rd.h-155 + index * -19;
	end
	local len = #self.userInfoArr;
	for i=len,1,-1 do
		local vo = self.userInfoArr[i];
		vo.lastTime = vo.lastTime - dwInterval;
		if vo.lastTime <= 0 then
			table.remove(self.userInfoArr,i);
			Tween:To(vo.mc,0.5,{_y=_rd.h-355,_alpha=0},{
				onComplete = function()
					vo.mc:removeMovieClip();
					vo.mc = nil;
				end});
		end
	end
end

UIFloatBottom.mcIndex = 0;
function UIFloatBottom:GetMcName()
	self.mcIndex = self.mcIndex + 1;
	return self.mcIndex;
end