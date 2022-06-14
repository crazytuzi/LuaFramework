
local skilltips = class("skilltips",layout)

global_event.SKILL_TIPS_SHOW = "SKILL_TIPS_SHOW";
global_event.SKILL_TIPS_HIDE = "SKILL_TIPS_HIDE";

function skilltips:ctor( id )
	 skilltips.super.ctor(self,id)	
	 self:addEvent({ name = global_event.SKILL_TIPS_SHOW, eventHandler = self.onShow})				
	 self:addEvent({ name = global_event.SKILL_TIPS_HIDE, eventHandler = self.onHide})
end	

function skilltips:onShow(event)
	
	if self._show then
		return;
	end
	
	self:Show();
	
	event.offsetX = event.offsetX or 0;
	event.offsetY = event.offsetY or 0;
	self:init(event);
	
	--新手引导事件：查看技能信息
    eventManager.dispatchEvent({name = global_event.GUIDE_ON_CORPSDETAIL_SKILLINFO_OPEN ,arg1 = args })
end

function skilltips:onHide(event)
	
	if self.timeTickHandle and self.timeTickHandle > 0 then
		scheduler.unscheduleGlobal(self.timeTickHandle);
		self.timeTickHandle = -1;
	end
	
	self:Close();
end

function skilltips:init(event)

	self.timeTickHandle = -1;
	
	-- init window
	self.layout = LORD.toLayout(self:Child("skilltips"));
	self.skilltips_word = self:Child("skilltips-word");
	self.skilltips_name = self:Child("skilltips-name");
	self.skilltips_cooltime = self:Child("skilltips-cooltime");
	self.skilltips_cooltime_num = self:Child("skilltips-cooltime-num");
	self.skilltips_lasttime = self:Child("skilltips-lasttime");
	self.skilltips_lasttime_num = self:Child("skilltips-lasttime-num");
	self.skilltips_starback = self:Child("skilltips-starback");
	self.skilltips_starback:SetVisible(false);
	self.skilltips_magic = self:Child("skilltips-magic");
	self.skilltips_magic:SetVisible(false);
	self.skilltips_magic_num = self:Child("skilltips-magic-num");
	
	-- 主界面上的时间
	function onTipsTimeTick()
		local text = self:getTimeText();
		self.skilltips_word:SetText(text);
		self.layout:LayoutChild();
	end
	
	--  根据类型区分
	local text = "";
	local name = "";
	
	if event.tipsType == "magic" then
		
		-- 根据需要显示
		self.skilltips_cooltime:SetVisible(true);
		self.skilltips_lasttime:SetVisible(false);
		self.skilltips_starback:SetVisible(true);
		self.skilltips_magic:SetVisible(true);
		
		local magicInfo = dataConfig.configs.magicConfig[event.id];
		if magicInfo then
			text = dataManager.playerData:parseText(magicInfo.text, event.id, event.magicLevel, event.intelligence);
			name = magicInfo.name;
			
			if event.magicInstance then
				--self.skilltips_cooltime_num:
			else
				self.skilltips_cooltime_num:SetText(magicInfo.cooldown);
			end
			
			for i=1, 5 do
				self:Child("skilltips-star"..i):SetVisible(i<=event.magicLevel);
			end
			
			print("magicInfo.cost[event.magicLevel]");
			self.skilltips_magic_num:SetText(magicInfo.cost[event.magicLevel]);
			
		end
		
	elseif event.tipsType == "skill" then
	
		-- 根据需要显示
		self.skilltips_cooltime:SetVisible(false);
		self.skilltips_lasttime:SetVisible(false);
		
		local skillInfo = dataConfig.configs.skillConfig[event.id];
		if skillInfo then
			text = skillInfo.text;
			name = skillInfo.name;
		end
	elseif event.tipsType == "buff" then
		-- 根据需要显示
		self.skilltips_cooltime:SetVisible(false);
		self.skilltips_lasttime:SetVisible(true);
		
		local buffInfo = dataConfig.configs.buffConfig[event.id];
	
		if buffInfo and buffInfo.desc and event.buffInstance then
			if event.buffInstance:GetBuffSource() == enum.SOURCE.SOURCE_MAGIC then
				local magiclevel = 0;
				local intelligence = 0;
				
				if dataManager.battleKing[event.buffInstance.buffCasterForce] then
					intelligence = dataManager.battleKing[event.buffInstance.buffCasterForce]:getIntelligence();
				end
				
				magiclevel = global.getBattleMagicLevel(event.buffInstance.buffCasterForce, event.buffInstance:GetSourceSkillOrMagicID());
				
				text = dataManager.playerData:parseText(buffInfo.desc, event.buffInstance:GetSourceSkillOrMagicID(), magiclevel, intelligence);
			else
				text = buffInfo.desc;
			end
			
			name = buffInfo.name;
			
			local cd = event.buffInstance:getCD();
			if cd <= 100 then
				self.skilltips_lasttime_num:SetText(cd);
			else
				self.skilltips_lasttime_num:SetText("");
			end
		end
	elseif event.tipsType == "time" then

		-- 根据需要显示
		self.skilltips_cooltime:SetVisible(false);
		self.skilltips_lasttime:SetVisible(false);
		self.skilltips_name:SetVisible(false);
		
		text = self:getTimeText();
		
		self.timeTickHandle = scheduler.scheduleGlobal(onTipsTimeTick, 1);
	
	elseif event.tipsType == "miracle" then
		
		-- 奇迹系统
		self.skilltips_cooltime:SetVisible(false);
		self.skilltips_lasttime:SetVisible(false);
		self.skilltips_name:SetVisible(true);
		self.skilltips_starback:SetVisible(true);
		
		local nowLevel = dataManager.miracleData:getLevel();
		
		local raceText = enum.RACE_TEXT[event.id];
		
		name = "\""..raceText.."军团\"所需星级"
		

		for i=1, 5 do
			self:Child("skilltips-star"..i):SetVisible(i<=nowLevel);
		end
		
		text = "需要收集所有"..nowLevel.."星"..raceText.."军团";
	
	elseif event.tipsType == "guildWar" then
		
		-- 公会战鼓舞
		self.skilltips_starback:SetVisible(false);
		self.skilltips_cooltime:SetVisible(false);
		self.skilltips_lasttime:SetVisible(false);
		self.skilltips_name:SetVisible(true);
		
		local spot = dataManager.guildWarData:getSpot(event.id);
		
		name = "集结呐喊【"..spot:getNowDefenceBuffCount().."】";
		text = "全体守军收到集结呐喊的鼓舞，全体军团数量增加"..spot:getNowDefenceAddUnitCount().."%";
		
	else
		
		self.skilltips_cooltime:SetVisible(false);
		self.skilltips_lasttime:SetVisible(false);
		self.skilltips_name:SetVisible(false)
		
		text = event.text;
		
		local size = self.layout:GetPixelSize();
		
		--计算文本的宽度，如果比默认的小，就设置成小的
		local font = self.skilltips_word:GetFont();
		local width = font:GetTextExtent(text);
		
		print("width "..width);
		print("size "..size.x);
		
		if width < size.x then
			
			self.skilltips_word:SetWidth(LORD.UDim(0, width + 80));
			self.layout:SetWidth(LORD.UDim(0, width + 80));
			
		end
		
	end

	self.skilltips_word:SetText(text);
	self.skilltips_name:SetText(name);
	self.layout:LayoutChild();
	
	if event.dir == "free" then
		self:calcTipsPositionFree(event);
	else
		self:calcTipsPosition(event);
	end
	
end

-- 新的计算tips的规则
function skilltips:calcTipsPositionFree(event)
	
	local clickWindowRect = event.windowRect;
	local clickWindowWidth = clickWindowRect:getWidth();
	local clickWindowHeight = clickWindowRect:getHeight();

	local layoutWidth = self.layout:GetWidth().offset;
	local layoutHeight = self.layout:GetHeight().offset;

	local x = clickWindowRect.left - layoutWidth*0.5;
	local y = clickWindowRect.top - layoutHeight;
	

	local layoutSize = self.layout:GetPixelSize();
	
	if y < 0 then
		
		x = clickWindowRect.right;
		y = clickWindowRect.top;
		
		if x + layoutSize.x > engine.rootUiSize.w then
			x = clickWindowRect.left - layoutWidth;
			y = clickWindowRect.top;
		end
	
	elseif x < 0 then
		
		x = 0;
	
	elseif x + layoutSize.x > engine.rootUiSize.w then
		
		x = engine.rootUiSize.w - layoutSize.x;
			
	end
	
		
	self.layout:SetXPosition(LORD.UDim(0, x));
	self.layout:SetYPosition(LORD.UDim(0, y));
	
end

function skilltips:calcTipsPosition(event)
	
	local clickWindowRect = event.windowRect;
	local clickWindowWidth = clickWindowRect:getWidth();
	local clickWindowHeight = clickWindowRect:getHeight();
	
	local layoutWidth = self.layout:GetWidth().offset;
	local layoutHeight = self.layout:GetHeight().offset;
	
	local x = clickWindowRect.left;
	local y = clickWindowRect.top;
		
	if event.dir == "left" then
		x = LORD.UDim(0, clickWindowRect.left) - self.layout:GetWidth();
		y = LORD.UDim(0, clickWindowRect.top - 0.5*(layoutHeight - clickWindowHeight));
	elseif event.dir == "right" then
	
		x = LORD.UDim(0, clickWindowRect.right);
		y = LORD.UDim(0, clickWindowRect.top - 0.5*(layoutHeight - clickWindowHeight));
	elseif event.dir == "top" then
		
		x = LORD.UDim(0, clickWindowRect.left - 0.5*(layoutWidth - clickWindowWidth));
		y = LORD.UDim(0, clickWindowRect.top) - self.layout:GetHeight();
	elseif event.dir == "bottom" then

		x = LORD.UDim(0, clickWindowRect.left - 0.5*(layoutWidth - clickWindowWidth));
		y = LORD.UDim(0, clickWindowRect.bottom);
	end
	
	x = x + LORD.UDim(0, event.offsetX);
	y = y + LORD.UDim(0, event.offsetY);
	
	local s = self.layout:GetPixelSize()
	if( x.offset + s.x > engine.rootUiSize.w)then
		x.offset = engine.rootUiSize.w - s.x -5
	end
	
	if ( x.offset < 0 ) then
		x.offset = 0;
	end
	
	if( y.offset + s.y > engine.rootUiSize.h)then
		y.offset = engine.rootUiSize.h - s.y -5
	end
	
	if y.offset < 0 then
		y.offset = 0;
	end
	
	self.layout:SetXPosition(x);
	self.layout:SetYPosition(y);
end

function skilltips:getTimeText()
	local h,m,s = dataManager.getLocalTime();
	local	nowTimeText = string.format("当前时间:%02d:%02d:%02d\n", h, m, s);
	
	local nextFreeVigorTime = dataManager.playerData:getNextFreeVigorTime();
	local	nextVigorTimeText = string.format("下次体力回复:"..formatTime(nextFreeVigorTime).."\n");
	local fullVigorTime = dataManager.playerData:getFullVigorTime();
	
	local	vigorFullRequireTimeText = string.format("回满所需时间:"..formatTime(fullVigorTime).."\n");
	local getTimeInterval = math.floor(dataConfig.configs.ConfigConfig[0].vigorRegenerationInterval / 60); 
	local vigorGetInfo = string.format("每隔%d分钟回复1点体力", getTimeInterval);
	return nowTimeText..nextVigorTimeText..vigorFullRequireTimeText..vigorGetInfo;
end

return skilltips