--[[
漂浮文字UI
lizhuangzhuang
2014年8月29日15:52:01
]]

_G.UIFloat = BaseUI:new("UIFloat");

UIFloat.announceSpeed = 80;--公告速度,每秒钟前进像素
UIFloat.currSkillInfoVO = nil;--当前技能信息,{mc:显示对象,lastTime:剩余时间,text:文字内容}
UIFloat.normalList = {};--普通漂浮文字队列,VO:{mc:显示对象,lastTime:剩余时间,text:文字内容,state:状态(12)}

UIFloat.centerStartPos = 0;

UIFloat.isShowActivity = false;--是否正在显示活动公告
UIFloat.activitylist = {};--活动公告等待队列
UIFloat.activityLunchList = {};--大摆筵席活动中冒字队列
UIFloat.dungeonList = {};--副本中冒字队列

function UIFloat:Create()
	self:AddSWF("float.swf",true,"float");
end

function UIFloat:OnLoaded(objSwf)
	objSwf.top.hitTestDisable = true;
	objSwf.bottom.hitTestDisable = true;
	objSwf.top.mcAllServerAnnounce._visible = false;
	objSwf.top.mcAnnounce._visible = false;
	objSwf.top._y = 100;
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.bottom._y = wHeight;
end

function UIFloat:OnResize(wWidth,wHeight)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.top._y = 100;
	objSwf.bottom._y = wHeight;
end

function UIFloat:GetWidth()
	return 683;
end

--添加全屏公告
function UIFloat:AddAllServerAnnounce(text)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.top.mcAllServerAnnounce._visible = true;
	local tf = objSwf.top.mcAllServerAnnounce.tf;
	tf.htmlText = text;
	tf._width = tf.textWidth + 5;
	tf._x = 673;
	Tween:To(tf,(tf._width+673)/self.announceSpeed,{_x=-tf._width+20,ease=Linear.easeNone},
			{onComplete=function()
				objSwf.top.mcAllServerAnnounce._visible = false;
				TimerManager:RegisterTimer(function()
					FloatManager:ShowNextAllServerAnn();
				end,1000,1);
			end});
end

--添加公告
function UIFloat:AddAnnounce(text)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.top.mcAnnounce._visible = true;
	local tf = objSwf.top.mcAnnounce.tf;
	tf.htmlText = text;
	tf._width = tf.textWidth + 5;
	tf._x = 537;
	Tween:To(tf,(tf._width+537)/self.announceSpeed,{_x=-tf._width+20,ease=Linear.easeNone},
			{onComplete=function()
				objSwf.top.mcAnnounce._visible = false;
				TimerManager:RegisterTimer(function()
					FloatManager:ShowNextAnn();
				end,1000,1);
			end});
end

--显示普通漂浮文字
function UIFloat:ShowNormal(text,stageX,stageY)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local pos = nil;
	if #self.normalList > 0 then
		local vo = self.normalList[#self.normalList];
		if vo.text == text  then
			pos = UIManager:PosGtoL(objSwf.top,stageX,stageY);
			if math.abs(pos.x-vo.mc._x) < 50 and math.abs(pos.y-vo.mc._y) < 60 then
				vo.mc.bg:gotoAndPlay(2);
				if vo.state == 2 then
					vo.lastTime = 500;
				end
				return;
			end
		end
	end
	--
	if not pos then pos = UIManager:PosGtoL(objSwf.top,stageX,stageY); end
	local depth = objSwf.top:getNextHighestDepth();
	local mc = objSwf.top:attachMovie("normal",self:GetMcName(),depth);
	mc.tf.htmlText = text;
	mc.tf._width = mc.tf.textWidth+7;
	mc.tf._x = -mc.tf._width/2;
	mc.bg._width = mc.tf._width + 40;
	mc._x = pos.x;
	mc._y = pos.y-mc._height;
	mc._x = mc._x-mc._width/2 < self:GetWidth()/2-_rd.w/2 and self:GetWidth()/2-_rd.w/2+mc._width/2 or mc._x;
	mc._x = mc._x+mc._width/2 > self:GetWidth()/2+_rd.w/2 and self:GetWidth()/2+_rd.w/2-mc._width/2 or mc._x;
	--
	local vo = {};
	vo.mc = mc;
	vo.state = 1;
	vo.text = text;
	vo.lastTime = 0;
	table.push(self.normalList,vo);
	Tween:To(mc,0.4,{_y=mc._y-20},{
		onComplete = function()
			vo.lastTime = 500;
			vo.state = 2;
		end});
end

--显示屏幕中央的漂浮文字
function UIFloat:ShowCenter(text)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local pos = {x=152,y=185};
	local depth = objSwf.top:getNextHighestDepth();
	local mc = objSwf.top:attachMovie("center",self:GetMcName(),depth);
	mc.tf.htmlText = text;
	mc.bg._width = mc.tf.textWidth + 50;
	mc._x = pos.x;
	mc._y = pos.y;
	mc._y = mc._y + self.centerStartPos*38;
	self.centerStartPos = self.centerStartPos + 1;
	if self.centerStartPos >= 3 then
		self.centerStartPos = 0;
	end
	Tween:To(mc,0.4,{_y=mc._y-20},{
		onComplete = function()
			TimerManager:RegisterTimer(function()
				Tween:To(mc,0.5,{_y=mc._y-80,_alpha=0},{
					onComplete = function()
						mc:removeMovieClip();
						mc = nil;
						self.centerStartPos = 0;
					end});
			end,500,1);
		end});
end

--显示活动内公告
function UIFloat:ShowActivity(text)
	if self.isShowActivity then
		table.push(self.activitylist,text);
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local depth = objSwf.bottom:getNextHighestDepth();
	local mc = objSwf.bottom:attachMovie("activityInfo",self:GetMcName(),depth);
	mc.tf.htmlText = text;
	mc.tf._height = mc.tf.textHeight + 5;
	--
	local scale = 30;
	local endX,endY = 0,-300;

	local startX = 0;
	local startY = endY + mc._height/2 + mc._height*scale/100/2;
	--
	mc._x = startX;
	mc._y = startY;
	mc._alpha = 50;
	mc._xscale = scale;
	mc._yscale = scale;
	self.isShowActivity = true;
	--
	Tween:To(mc,0.3,{_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},{
		onComplete = function()
			TimerManager:RegisterTimer(function()
				self.isShowActivity = false;
				self:ShowNextActivity();
				Tween:To(mc,0.2,{_alpha=0},{
					onComplete = function()
						mc:removeMovieClip();
						mc = nil;
					end});
			end,2000,1);
		end});

end

--adder:houxudong date:2016/8/25 PM 17:50:20
--随机产生颜色
function UIFloat:RandomColor()
	local colors = {0,1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f"};
	local color = "";
	for i=1,6 do
		local n = math.ceil(math.random()*15);
		color = color .. colors[n]
	end
	return '#'..color
end

--显示活动内公告--大摆筵席
function UIFloat:ShowActivityLunch(text)
	if self.isShowlunchText then
		table.push(self.activityLunchList,text);
		return;
	end
	if text == nil then
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local depth = objSwf.bottom:getNextHighestDepth();
	local mc = objSwf.bottom:attachMovie("activityInfo",self:GetMcName(),depth);
	mc.tf.htmlText = string.format(StrConfig['lunchColor'],self:RandomColor(),text);
	mc.tf._height = mc.tf.textHeight + 5;
	--
	local x ,y = UIManager:GetWinSize();
	local scale = 30;
	local endX,endY = 0,-y/2-150;
	local startX = 0;
	local startY = endY + mc._height/2 + mc._height*scale/100/2;
	--
	mc._x = startX;
	mc._y = startY;
	mc._alpha = 50;
	mc._xscale = scale;
	mc._yscale = scale;
	self.isShowlunchText = true;
	Tween:To(mc,0.3,{_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},{
		onComplete = function()
		Tween:To(mc,0.2,{_alpha=100,_xscale=130,_yscale=130,_x=endX,_y=endY+5,ease=Back.easeInOut},{
		onComplete = function()
			Tween:To(mc,0.2,{_alpha=100,_xscale=130,_yscale=130,_x=endX,_y=endY-5,ease=Back.easeInOut},{
				onComplete = function()
					Tween:To(mc,0.2,{_alpha=100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeIn},{
					onComplete = function()
						TimerManager:RegisterTimer(function()
						Tween:To(mc,1,{_alpha=0,_xscale=10,_yscale=10,_y=endY-200,ease=Back.easeIn},{
						onComplete = function()
							self:ShowNextLunchText();
							self.isShowlunchText = false;
							mc:removeMovieClip();
							mc = nil;
						end});
						end,2000,1);
					end});
				end});
			end});
		end});

end

--显示下一个冒字内容
function UIFloat:ShowNextLunchText()
	if #self.activityLunchList > 0 then
		local text = table.remove(self.activityLunchList,1);
		self:ShowActivityLunch(text);
	end
end

-- adder:houxudong
-- date: 2016/10/24 17:23:38
-- 显示副本内公告--牧野之战
function UIFloat:ShowDungeonText( text )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.isShowDungeonText then
		table.push(self.dungeonList,text);
		return;
	end
	objSwf.top.mcAnnounce._visible = true;
	local tf = objSwf.top.mcAnnounce.tf;
	tf.htmlText = text;
	tf._width = tf.textWidth + 5;
	tf._x = 537;
	self.isShowDungeonText = true
	Tween:To(tf,(tf._width+537)/self.announceSpeed,{_x=-tf._width+20,ease=Linear.easeNone},
			{onComplete=function()
				objSwf.top.mcAnnounce._visible = false;
				TimerManager:RegisterTimer(function()
					self.isShowDungeonText = false
					self:ShowDungeonNextText();
				end,1000,1);
			end});	
end

--显示下一个副本内公告
function UIFloat:ShowDungeonNextText()
	if #self.dungeonList > 0 then
		local text = table.remove(self.dungeonList,1);
		self:ShowDungeonText(text);
	end
end

-- 清空副本内所有的公告
function UIFloat:ClearAllDungeonText( )
	self.dungeonList = {}
end


--显示剧情用公告
function UIFloat:ShowStoryActivity(text)	
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local depth = objSwf.bottom:getNextHighestDepth();
	local mc = objSwf.bottom:attachMovie("storyInfo",self:GetMcName(),depth);
	mc.tf.htmlText = "<img src='img://resfile/icon/"..text..".png'/>"
	mc.tf._height = mc.tf.textHeight + 5;
	--
	local scale = 30;
	local endX,endY = 0,-300;
	local startX = 0;
	local startY = endY + mc._height/2 + mc._height*scale/100/2;
	--
	mc._x = startX;
	mc._y = startY;
	mc._alpha = 50;
	mc._xscale = scale;
	mc._yscale = scale;
	self.isShowActivity = true;
	--
	Tween:To(mc,0.3,{_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},{
		onComplete = function()
			TimerManager:RegisterTimer(function()
				self.isShowActivity = false;
				self:ShowNextActivity();
				Tween:To(mc,0.2,{_alpha=0},{
					onComplete = function()
						mc:removeMovieClip();
						mc = nil;
					end});
			end,2000,1);
		end});
end

--显示下一个活动公告
function UIFloat:ShowNextActivity()
	if #self.activitylist > 0 then
		local text = table.remove(self.activitylist,1,1);
		self:ShowActivity(text);
	end
end

--清除所有活动公告
function UIFloat:ClearAllActivity()
	self.activitylist = {};
end

--显示技能类漂浮文字
function UIFloat:ShowSkillInfo(text)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.currSkillInfoVO then
		if self.currSkillInfoVO.text == text then--相同的亮一下
			self.currSkillInfoVO.mc:gotoAndPlay(2);
			self.currSkillInfoVO.lastTime = 2000;
			return;
		else
			local vo = self.currSkillInfoVO;
			self.currSkillInfoVO = nil;
			vo.mc:gotoAndStop(1);
			Tween:To(vo.mc,0.5,{_y=vo.mc._y-100,_alpha=0},{
				onComplete = function()
					vo.mc:removeMovieClip();
					vo.mc = nil;
				end});
		end
	end
	local vo = {};
	local depth = objSwf.bottom:getNextHighestDepth();
	vo.mc = objSwf.bottom:attachMovie("skill",self:GetMcName(),depth);
	vo.mc._y = -135;
	vo.mc._x = -300;
	vo.text = text;
	vo.mc.tf.htmlText = text;
	vo.lastTime = 1500;
	self.currSkillInfoVO = vo;
	Tween:To(vo.mc,0.3,{_y=vo.mc._y-20});
end

function UIFloat:Update(dwInterval)
	--处理技能
	if self.currSkillInfoVO then
		self.currSkillInfoVO.lastTime = self.currSkillInfoVO.lastTime-dwInterval;
		if self.currSkillInfoVO.lastTime < 0 then
			local vo = self.currSkillInfoVO;
			self.currSkillInfoVO = nil;
			Tween:To(vo.mc,0.5,{_y=vo.mc._y-100,_alpha=0},{
				onComplete = function()
					vo.mc:removeMovieClip();
					vo.mc = nil;
				end});
		end
	end
	--处理普通漂浮
	local len = #self.normalList;
	for i=len,1,-1 do
		local vo = self.normalList[i];
		if vo.state == 2 then
			vo.lastTime = vo.lastTime - dwInterval;
			if vo.lastTime < 0 then
				Tween:To(vo.mc,1,{delay=0.3,_y=vo.mc._y-50,_alpha=0},{
				onComplete = function()
					vo.mc:removeMovieClip();
					vo.mc = nil;
				end});
				table.remove(self.normalList,i,1);
			end
		end
	end
end

UIFloat.mcIndex = 0;
function UIFloat:GetMcName()
	self.mcIndex = self.mcIndex + 1;
	return self.mcIndex;
end