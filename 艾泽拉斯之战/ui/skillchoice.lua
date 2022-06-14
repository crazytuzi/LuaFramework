local skillchoice = class( "skillchoice", layout );

global_event.SKILLCHOICE_SHOW = "SKILLCHOICE_SHOW";
global_event.SKILLCHOICE_HIDE = "SKILLCHOICE_HIDE";

function skillchoice:ctor( id )
	skillchoice.super.ctor( self, id );
	self:addEvent({ name = global_event.SKILLCHOICE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SKILLCHOICE_HIDE, eventHandler = self.onHide});
end

function skillchoice:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	self.alphaValue = 1;
	self.alphaOperator = -1;
		
	function skillchoiceAlphaTick(dt)
		self:updateProgressAlpha(dt);
	end
	
	-- 启动一个alpha计算的计时器 
	self.alphaTimer = scheduler.scheduleGlobal(skillchoiceAlphaTick, 0);
		
	function onskillchoiceClickGain(args)
		local window = LORD.toWindowEventArgs(args).window;
		local magicID = window:GetUserData();
		
		if magicID > 0 then
			sendChooseMagicResult(magicID);
			self:onHide();
		end
		
	end
	
	-- 底框
	self.skillchoice_skill = {};
	-- 名字
	self.skillchoice_skill_name = {};
	-- 图标
	self.skillchoice_skill_tu = {};
	-- 获取按钮
	self.skillchoice_skill_button = {};
	-- 碎片数量
	self.skillchoice_skill_suipiannum = {};
	-- 新字
	self.skillchoice_skill_new = {};
	-- exp
	self.skillchoice_skill_exp_bar = {};
	-- star
	self.skillchoice_skill_star = {};
	
	-- 获取的3个备选的数据
	local magicChoiceData = event.choosesData;
	
	-- 品质框
	local skillchoice_skill_equity = {};
	
	-- 
	local skillchoice_skill_exp_barthen = {};
	
	for i=1, 3 do

		-- 底框
		self.skillchoice_skill[i] = self:Child("skillchoice-skillcard"..i.."-dw");
		-- 名字
		self.skillchoice_skill_name[i] = self:Child("skillchoice-skill"..i.."-name");
		-- 图标
		self.skillchoice_skill_tu[i] = LORD.toStaticImage(self:Child("skillchoice-skill"..i.."-tu"));
		-- 获取按钮
		self.skillchoice_skill_button[i] = self:Child("skillchoice-skill"..i.."-button");
		
		self.skillchoice_skill_button[i]:subscribeEvent("ButtonClick", "onskillchoiceClickGain");
		
		-- 星级对应的经验
		self.skillchoice_skill_suipiannum[i] = self:Child("skillchoice-skill"..i.."-suipiannum");
		-- 新字
		self.skillchoice_skill_new[i] = self:Child("skillchoice-skill"..i.."-new");
		-- exp
		self.skillchoice_skill_exp_bar[i] = self:Child("skillchoice-skill"..i.."-exp-bar");
		-- star
		self.skillchoice_skill_star[i] = {};
		for j=1, 5 do
			self.skillchoice_skill_star[i][j] = self:Child("skillchoice-skill"..i.."-star"..j);
		end
		
		-- 品质框
		skillchoice_skill_equity[i] = LORD.toStaticImage(self:Child("skillchoice-skill"..i.."-equity"));
		
		-- 预计增长熟练度
		skillchoice_skill_exp_barthen[i] = self:Child("skillchoice-skill"..i.."-exp-barthen");
		
		if magicChoiceData[i] then
			-- 查找身上有没有这个技能
			self.skillchoice_skill[i]:SetVisible(true);
			
			local magicID = magicChoiceData[i].id;
			self.skillchoice_skill_button[i]:SetUserData(magicID);
			
			local magicStar = magicChoiceData[i].star;
			
			local magicInstance = dataManager.kingMagic:getMagic(magicID);
			local magicInfo = dataConfig.configs.magicConfig[magicID];
			
			
			if magicInfo and magicInstance then
			
				-- 刷新ui上的信息
				self.skillchoice_skill_name[i]:SetText(magicInfo.name);
				self.skillchoice_skill_tu[i]:SetImage(magicInfo.icon);
				
				self.skillchoice_skill_tu[i]:SetUserData(magicInfo.id);
				
				local userdata2 = 0;
				
				if magicInstance:isActive() then
					userdata2 = dataManager.kingMagic:mergeLevelIntelligence(magicInstance:getStar(), dataManager.playerData:getIntelligence());
				else
					userdata2 = dataManager.kingMagic:mergeLevelIntelligence(magicStar, dataManager.playerData:getIntelligence());
				end
				
				self.skillchoice_skill_tu[i]:SetUserData2(userdata2);
				global.onSkillTipsShow(self.skillchoice_skill_tu[i], "magic", "free");
				global.onTipsHide(self.skillchoice_skill_tu[i]);
		
				
				-- 显示玩家当前所拥有的该魔法的品质，如果玩家尚未获得该魔法则按照获得魔法品质显示
				if magicInstance:isActive() then
					
					skillchoice_skill_equity[i]:SetImage(itemManager.getImageWithStar(magicInstance:getStar()));

				else
					
					skillchoice_skill_equity[i]:SetImage(itemManager.getImageWithStar(magicStar));
					
				end
				
				-- 显示玩家当前所拥有的该魔法的星级，如果玩家尚未获得该魔法则按照获得魔法星级显示。
				if magicInstance:isActive() then								
					
					for k = 1, 5 do
						self.skillchoice_skill_star[i][k]:SetVisible(k <= magicInstance:getStar());
					end
				
				else
					
					for k = 1, 5 do
						self.skillchoice_skill_star[i][k]:SetVisible(k <= magicStar);
					end
									
				end
				
				-- 显示玩家当前所拥有的该魔法的熟练度（即经验）的进度，如果玩家尚未获得该魔法则按照空显示
				local currentExp = magicInstance:getCurrentExp();
				local nextExp = magicInstance:getNextExp();
				local configInfo = dataConfig.configs.ConfigConfig[0].magicLevelExp;
				local chooseMagicExp = configInfo[magicStar];
				-- 计算新的星级
				local newStar = dataManager.kingMagic:getStarByExp(magicInstance:getExp()+chooseMagicExp);
				
				--显示玩家当前所拥有的该魔法的熟练度的数字，AAA/BBB，AAA为当前数字，BBB为升级所需数字，如果玩家尚未获得该魔法则按照0/XX显示,XX为获得魔法品质的经验上限
				local skillchoice_skill_exp_text = self:Child("skillchoice-skill"..i.."-exp-text");
													
				if magicInstance:isActive() then	
					
					self.skillchoice_skill_exp_bar[i]:SetProperty("Progress", currentExp/nextExp);
					
					skillchoice_skill_exp_text:SetText(currentExp.."/"..nextExp);
									
				else
					
					self.skillchoice_skill_exp_bar[i]:SetProperty("Progress", 0);
					
					local newgetCurrentExp, newgetNextExp = dataManager.kingMagic:getCurrentAndNextByExp(chooseMagicExp);
					
					skillchoice_skill_exp_text:SetText("0/"..newgetNextExp);
					
				end
				
				-- 熟练条位置显示预估增长条，即如果选择该选项卡，数量读条将拥有的长度
				skillchoice_skill_exp_barthen[i]:SetProperty("Progress", (currentExp+chooseMagicExp)/nextExp);
				skillchoice_skill_exp_barthen[i]:SetVisible(magicInstance:isActive());
				
				-- 当冥想选项为玩家尚未获得魔法时（1星的都没有算尚未获得），显示该控件，对应skillchoice-skillX-suipian、skillchoice-skillX-jinghua隐藏
				local skillchoice_skill_newget = self:Child("skillchoice-skill"..i.."-newget");
				skillchoice_skill_newget:SetVisible(not magicInstance:isActive());
				
				-- 当冥想选项为玩家已获得魔法并且魔法星级已达满星时，将显示该控件，并将给予的经验是换算成魔法精华数量在子控件skillchoice-skill1-jinghuanum下显示
				local skillchoice_skill_jinghua = self:Child("skillchoice-skill"..i.."-jinghua");
				skillchoice_skill_jinghua:SetVisible(magicInstance:isTopLevel());
				local skillchoice_skill_jinghuanum = self:Child("skillchoice-skill"..i.."-jinghuanum");
				skillchoice_skill_jinghuanum:SetVisible(magicInstance:isTopLevel());
				skillchoice_skill_jinghuanum:SetText(chooseMagicExp);
				
				--当冥想选项为玩家已获得魔法时，将原有逻辑中的获得的星级魔法换算成经验（即熟练度）在子控件skillchoice-skill1至3-suipiannum中显示对应数字。
				local skillchoice_skill_suipian = self:Child("skillchoice-skill"..i.."-suipian");
				skillchoice_skill_suipian:SetVisible(not magicInstance:isTopLevel() and magicInstance:isActive());				
				local skillchoice_skill_suipiannum = self:Child("skillchoice-skill"..i.."-suipiannum");
				skillchoice_skill_suipiannum:SetText(chooseMagicExp);
				
				-- 如果玩家选择该选项，会是对应魔法提升星级，则显示该控件。
				
				local showspecial2 = (magicInstance:getStar() == #configInfo-1 and ( newStar == #configInfo) and chooseMagicExp > (nextExp-currentExp));
				
				local skillchoice_skill_speicaltext = self:Child("skillchoice-skill"..i.."-speicaltext");
				skillchoice_skill_speicaltext:SetVisible( magicInstance:isActive() and chooseMagicExp >= (nextExp-currentExp) and not magicInstance:isTopLevel() and not showspecial2 );
				
				-- 如果玩家选择该选项，会使对应魔法升至5星，且有盈余经验值，则显示该控件。
				local skillchoice_skill_speicaltext2 = self:Child("skillchoice-skill"..i.."-speicaltext2");
				
				skillchoice_skill_speicaltext2:SetVisible(showspecial2);
				
			end
			
		else
			self.skillchoice_skill[i]:SetVisible(false);
		end
		
	end
	
end

function skillchoice:onHide(event)
	
	if self.alphaTimer and self.alphaTimer > 0 then
		
		scheduler.unscheduleGlobal(self.alphaTimer);
		self.alphaTimer = nil;
	end
	
	self:Close();
end

function skillchoice:updateProgressAlpha(dt)
	
	if not self._show then
		
		return;
		
	end
	
	self.alphaValue = self.alphaValue + self.alphaOperator*dt*2;
	
	if self.alphaValue > 1 then
		self.alphaValue = 1;
		self.alphaOperator =  self.alphaOperator * -1;
	end

	if self.alphaValue < 0 then
		self.alphaValue = 0;
		self.alphaOperator =  self.alphaOperator * -1;
	end
		
	for i=1, 3 do
		
		local window = self:Child("skillchoice-skill"..i.."-exp-barthen");
		if window then
			window:SetAlpha(self.alphaValue);
		end
	end
	
end

return skillchoice;
