local dialogue = class( "dialogue", layout );

global_event.DIALOGUE_SHOW = "DIALOGUE_SHOW";
global_event.DIALOGUE_HIDE = "DIALOGUE_HIDE";

function dialogue:ctor( id )
	dialogue.super.ctor( self, id );
	self:addEvent({ name = global_event.DIALOGUE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.DIALOGUE_HIDE, eventHandler = self.onHide});
end

function dialogue:onShow(event)
	if self._show then
		return;
	end
	--屏蔽强制指引
	eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE})
	--
	self:Show();
	
	-- 播放的时候不加速, 结束的时候恢复到应该有的速度
	-- 目前只有战斗中的对话需要处理
	local actorManager = LORD.ActorManager:Instance();
	actorManager:SetSpeedUp(1);
	
	self.callFun = event.fun
	
	function onClickDialogue()
		
		-- 区分是正在播放，还是已经播放完了
		-- 正在播放，就停止播放，然后显示最后播放结尾的状态
		-- 如果已经播放完了就getnextsentence
		
		print("onClickDialogue");
		
		local data = self.dialogueData[self.currentSentenceIndex];
				
		if self.isPlay then
			
			if self.playTextTimer > 0 then
				scheduler.unscheduleGlobal(self.playTextTimer);
				self.playTextTimer = -1;
				
				local dialogue_text = self:Child("dialogue-text");
				dialogue_text:SetText(data.sentence);
				
			end
			
			self.isPlay = false;
			
			print("self.isPlay  ")
		else
			print("onClickDialogue getNextSentence");
			self:getNextSentence();
		end
		
	end
	
	function onClickSkipDialogue()
		self:endDialogue();
	end
	
	self.dialogue = LORD.toStaticImage(self:Child("dialogue"));
	self.dialogue:subscribeEvent("WindowTouchUp", "onClickDialogue");
	
	self.dialogue_skip_clickregion = self:Child("dialogue-skip-clickregion");
	self.dialogue_skip_clickregion:subscribeEvent("WindowTouchUp", "onClickSkipDialogue");
	
	self.dialogueType = event.dialogueType;

	-- 隐藏相关界面，之后还要恢复
	self:checkOtherUIShow("BattleView", false);
	self:checkOtherUIShow("instanceinfor", false);
	
	-- 开始初始化对话		
	self.dialogueData = {};
	self.currentSentenceIndex = 0;
	self.playTextTimer = -1;
	self.showTextCount = 0;
	self.isPlay = false;
	
	self:initDialogue(event.dialogueID);
	
	self:getNextSentence();
		
end

function dialogue:checkOtherUIShow(name, flag)
	
	local layout = layoutManager.getUI(name);
	if layout and layout._view then
		layout._view:SetVisible(flag);
	end	
		
end

function dialogue:onHide(event)
	
	if self.playTextTimer > 0 then
		scheduler.unscheduleGlobal(self.playTextTimer);
		self.playTextTimer = -1;
		self.showTextCount = 0;
	end
			
	self:Close();
end

-- 根据表格初始化对话
-- stringarray 有三个元素，id， 出现位置，内容
function dialogue:formateDialogData(sentence)
		
	local data = {};
	
	if #sentence ~= 3 then
		return nil;
	end
	
	data.characterID = tonumber(sentence[1]);
	data.position = tonumber(sentence[2]);
	data.sentence = sentence[3];
	data.sentence = string.gsub(data.sentence, "@player@", dataManager.playerData:getName());
	data.sentence = string.gsub(data.sentence, "@castle@", dataManager.playerData:getCastleName());
	
	local characterConfig = dataConfig.configs.characterConfig[data.characterID];
	data.name = characterConfig.name;
	data.image = characterConfig.path;
	
	dump(data);
	
	return data;
	
end

-- 初始化对话相关的数据，通过表格解析
function dialogue:initDialogue(dialogueID)

	self.dialogueData = {};
	
	print("dialogueID "..dialogueID);
	
	local dialogueConfigInfo = dataConfig.configs.dialogueConfig[dialogueID];
	if dialogueConfigInfo then
		for i=1, 20 do
			local sentence = dialogueConfigInfo["dialogue"..i];
			if sentence then
				local data = self:formateDialogData(sentence);
				if data then
					table.insert(self.dialogueData, data);
				end
			else
				-- 如果下一条没有的话就直接跳出了
				break;
			end
		end
	end

end

-- 播放下一条对话
function dialogue:getNextSentence()

	self.currentSentenceIndex = self.currentSentenceIndex + 1;
	local sentenceData = self.dialogueData[self.currentSentenceIndex];
	if sentenceData then
		self:startPlaySentence(sentenceData);
	else
		self.currentSentenceIndex = 0;
		-- 没有了就结束
		self:endDialogue();
	end
end

-- 结束对话
function dialogue:endDialogue()
	
	if self.dialogueType == "incident" then
		
		dataManager.mainBase:onEndIncidentDialogue();
	
	elseif self.dialogueType == "adventurePrepare" then
		
		battlePrepareScene.onEnter();
			
	elseif self.dialogueType == "adventureBefore" then
		
		if sceneManager.battlePlayer() then
			sceneManager.battlePlayer():onEndDialogue();
			
		end

		if sceneManager.battlePlayer() then
			local speed = tonumber(getClientVariable( "gameSpeed",SPEED_UP_GAME[1]));
				print("speed "..speed);
			sceneManager.battlePlayer():speedGame(speed);
		end
				
		self:checkOtherUIShow("BattleView", true);		
			
	elseif self.dialogueType == "adventureAfter" then	
		
		self:checkOtherUIShow("instanceinfor", true);
	
	end
	
	if self.callFun then
	
		self.callFun();

		if sceneManager.battlePlayer() and sceneManager.battlePlayer():isEndBattle() == false then
			local speed = tonumber(getClientVariable( "gameSpeed",SPEED_UP_GAME[1]));
				print("speed "..speed);
			sceneManager.battlePlayer():speedGame(speed);
		end
			
	end
	
	self:onHide();
	
end

-- 半身像飞入飞出效果
-- inFlag: true 飞入， false 飞出
-- position : 0, 左， 1 右
function dialogue:playImageFly(inFlag, data)
	
	print("playImageFly "..tostring(inFlag).." data "..data.position);
	
	function onDialogueImageFlyoutEnd(args)
		self:onDialogueImageFlyoutEnd(args);
	end
	
	function onDialogueImageFlyawayEnd(args)
		self:onDialogueImageFlyawayEnd(args);
	end
	
	local position = data.position;
	
	local rate = 1;
	
	--if sceneManager.battlePlayer() then
		--rate = sceneManager.battlePlayer():getSpeed();
	--end
	--print("rate");
	
	if position == 0 then
		
		dialogue_person_left = LORD.toStaticImage(self:Child( "dialogue-person-left" ));
		dialogue_person_left:SetImage(data.image);
		
		local xpos = dialogue_person_left:GetXPosition();
		local width = dialogue_person_left:GetWidth();
		
		local startPos = -(xpos.offset + width.offset);
		local endPos = 0;
		
		--if not inFlag then
		--	startPos, endPos = endPos, startPos;
		--end
						
		dialogue_person_left:removeEvent("UIActionEnd");
		dialogue_person_left:SetVisible(true);
		
		if inFlag then
			local tim = 5*rate;
			local inaction = LORD.GUIAction:new();
			--匀变速运动
			for i = 0, 5 do
			inaction:addKeyFrame(LORD.Vector3(startPos+(50+endPos-startPos)/5*i, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, i*i*tim);
			end
			inaction:addKeyFrame(LORD.Vector3(endPos, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 160*rate);
					
			dialogue_person_left:subscribeEvent("UIActionEnd", "onDialogueImageFlyoutEnd");
			dialogue_person_left:playAction(inaction);
		else
		
			local outaction = LORD.GUIAction:new();
			outaction:addKeyFrame(LORD.Vector3(endPos, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
			outaction:addKeyFrame(LORD.Vector3(startPos, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 100*rate);
			
			dialogue_person_left:subscribeEvent("UIActionEnd", "onDialogueImageFlyawayEnd");
			dialogue_person_left:playAction(outaction);
		end
		
		
				
	elseif position == 1 then
		
		dialogue_person_right = LORD.toStaticImage(self:Child( "dialogue-person-right" ));
		dialogue_person_right:SetImage(data.image);
		
		local xpos = dialogue_person_right:GetXPosition();
		
		local startPos = (engine.rootUiSize.w - xpos.offset);
		local endPos = 0;
		
		--if not inFlag then
		--	startPos, endPos = endPos, startPos;
		--end
				
		dialogue_person_right:removeEvent("UIActionEnd");
		dialogue_person_right:SetVisible(true);
		
		if inFlag then
			local tim = 5*rate;
			local inaction = LORD.GUIAction:new();
			--匀加速运动
			for i = 0, 5 do
			inaction:addKeyFrame(LORD.Vector3(startPos-(50+startPos-endPos)/5*i, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, i*i*tim);
			end
			inaction:addKeyFrame(LORD.Vector3(endPos, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 160*rate);
				
			dialogue_person_right:subscribeEvent("UIActionEnd", "onDialogueImageFlyoutEnd");
			dialogue_person_right:playAction(inaction);	
		else
		
			local outaction = LORD.GUIAction:new();		
			outaction:addKeyFrame(LORD.Vector3(endPos, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
			outaction:addKeyFrame(LORD.Vector3(startPos, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 100*rate);
				
			dialogue_person_right:subscribeEvent("UIActionEnd", "onDialogueImageFlyawayEnd");
			dialogue_person_right:playAction(outaction);
		end
				
				
	end
end

function dialogue:onDialogueImageFlyoutEnd(args)
	
	if not self._show then
		return;
	end
	
	-- 开始出现名字 和 对话
	self:startPlayDialogueWordByWord();
	
end

function dialogue:onDialogueImageFlyawayEnd(args)
	
	if not self._show then
		return;
	end
	
	local window = LORD.toWindowEventArgs(args).window;
	if window then
		window:SetVisible(false);
	end
	
	-- 必须延迟一帧，因为playfly里会清除UIActionEnd
	-- 所以不能在回调里清除自己
	
	scheduler.performWithDelayGlobal(function() 
		
		if self._show then
			
			-- 开始播放下一条 飞入
			local data = self.dialogueData[self.currentSentenceIndex];
			self:playImageFly(true, data);
		
		end
		
	end, 0);
	
end

-- 逐字播放对话
function dialogue:startPlayDialogueWordByWord()
	
	-- 得到下一个非转义需要跳过的count
	function getNextNoneEscapeCount(code)
		if code == 94 then -- '^FFFFFF'
			return 7;
		else
			return 1;
		end
	end
		
	function dialoguePlayTextTimerFun(dt)
	
		local data = self.dialogueData[self.currentSentenceIndex];
		
		if data.sentence then
			
			local tempString = LORD.GUIString(data.sentence);
			local wholeCount = tempString:length();
			
			if self.showTextCount < wholeCount then
				self.showTextCount = self.showTextCount + getNextNoneEscapeCount(tempString[self.showTextCount-1]);
				if self.showTextCount > wholeCount then
					self.showTextCount = wholeCount;
				end
				
				local showText = tempString:substr(0, self.showTextCount);
				local dialogue_text = self:Child( "dialogue-text" );
				if dialogue_text then
					dialogue_text:SetText(showText:c_str());
				end
				
				print("dialoguePlayTextTimerFun dt "..self.showTextCount);
				
			else
				
				-- 自动停止
				if self.playTextTimer > 0 then
					scheduler.unscheduleGlobal(self.playTextTimer);
					self.playTextTimer = -1;
					self.showTextCount = 0;
				end

				local dialogue_text = self:Child( "dialogue-text" );
				if dialogue_text then
					dialogue_text:SetText(data.sentence);
				end
								
				-- 这一个dialogue结束的标志,
				self.isPlay = false;
				print("dialoguePlayTextTimerFun end ");
			end
			
		end
	end
		
	local data = self.dialogueData[self.currentSentenceIndex];
	
	-- 如果有老的计时器，先释放
	if self.playTextTimer and self.playTextTimer > 0 then
		scheduler.unscheduleGlobal(self.playTextTimer);
		self.playTextTimer = -1;
	end
	
	if data then
		
		local dt = 1/60;
		
		--if sceneManager.battlePlayer() then
		--	local rate = sceneManager.battlePlayer():getSpeed()/SPEED_UP_GAME[1]
		--	dt = dt * rate;
		--end
		
		self.playTextTimer = scheduler.scheduleGlobal(dialoguePlayTextTimerFun, dt);
		local dialogue_name_text = self:Child("dialogue-name-text");
		dialogue_name_text:SetText(data.name);
		
	end
	
end


-- 开始播放这一条
function dialogue:startPlaySentence(data)
	
	-- 如果不是第一条，要处理前一条的消失逻辑
	-- 1. 前一条对话信息，名字先清空，
	-- 2. 如果前一条半身像需要消失，就处理飞出，飞出结束后，开始下一条的播放，飞入 - 》名字 -》 文本
	-- 3. 如果不需要消失， 直接名字， 文本
	-- 第一条的话，直接 飞入 - 》 名字 - 》文本
	
	self.isPlay = true;
	
	if self.currentSentenceIndex == 1 then
		
		self:playImageFly(true, data);
		
	else
		
		local dialogue_name_text = self:Child("dialogue-name-text");
		dialogue_name_text:SetText("");
				
		local dialogue_text = self:Child("dialogue-text");
		dialogue_text:SetText("");
		
		local preData = self.dialogueData[self.currentSentenceIndex-1];
		local nowData = self.dialogueData[self.currentSentenceIndex];
		
		if nowData.characterID == preData.characterID and 
			nowData.position == preData.position then
			
			-- 不需要飞出
			self:startPlayDialogueWordByWord();
		
		else
		
			-- 先飞出
			self:playImageFly(false, preData);
			
		end
		
	end
	
	--[==[
	[[
	self.disappearPostion = {
		['left'] = false,
		['middle'] = false,
		['right'] = false,
	};
	
	self.lastSentenceData = self.dialogueData[self.currentSentenceIndex-1];
	
	local shouldPlayImage = false;
	
	if self.lastSentenceData then
			
		if self.lastSentenceData.leftID ~= data.leftID then
			self.disappearPostion.left = true;
			shouldPlayImage = true;
			self.playFigureState = "disappear";
		end

		if self.lastSentenceData.middleID ~= data.middleID then
			self.disappearPostion.middle = true;
			shouldPlayImage = true;
			self.playFigureState = "disappear";
		end
		
		if self.lastSentenceData.rightID ~= data.rightID then
			self.disappearPostion.right = true;
			shouldPlayImage = true;
			self.playFigureState = "disappear";
		end
						
	else
		shouldPlayImage = true;
		self.disappearPostion.left = true;
		self.disappearPostion.middle = true;
		self.disappearPostion.right = true;
		self.playFigureState = "appear";
	end
	
	-- 得到下一个非转义需要跳过的count
	function getNextNoneEscapeCount(code)
		if code == 94 then -- '^FFFFFF'
			return 7;
		else
			return 1;
		end
	end
	
	function dialoguePlayTextTimerFun(dt)
		local data = self.dialogueData[self.currentSentenceIndex];
		if data.sentence then
			
			if self.isPlayText == true then
				local tempString = LORD.GUIString(data.sentence);
				local wholeCount = tempString:length();
				if self.showTextCount < wholeCount then
					self.showTextCount = self.showTextCount + getNextNoneEscapeCount(tempString[self.showTextCount-1]);
					if self.showTextCount > wholeCount then
						self.showTextCount = wholeCount;
					end
					local showText = tempString:substr(0, self.showTextCount);
					self.dialogue_text:SetText(showText:c_str());
				else
					self.isPlayText = false;
				end			
			else
				if self.playTextTimer > 0 then
					scheduler.unscheduleGlobal(self.playTextTimer);
					self.playTextTimer = -1;
				end
				self.showTextCount = 0;
				self.dialogue_text:SetText(data.sentence);			
			end
			
		end
	end
	
	function dialogPlayFigureTimerFun(dt)
		local DISAPPEAR_TIME = 0.5;
		local APPEAR_TIME = 0.5;
		self.playFigureTimeStamp = self.playFigureTimeStamp + dt;
		
		local alpha = 1;
		if self.playFigureState == "disappear" then
			
			if self.playFigureTimeStamp >= DISAPPEAR_TIME then
				-- 消失时间到
				
				self.playFigureTimeStamp = 0;
				self.playFigureState = "appear";
				alpha = 0;
			else
				alpha = 1 - self.playFigureTimeStamp / DISAPPEAR_TIME;
			end
		elseif self.playFigureState == "appear" then
			--print("self.playFigureState appear");
			if self.playFigureTimeStamp >= APPEAR_TIME then
				self.playFigureState = "null";
				self.playFigureTimeStamp = 0;
				alpha = 1;
			else
				alpha = self.playFigureTimeStamp / APPEAR_TIME;
				-- 刷新下一句的信息
				self:updateCurrentSentenceUIInfo();
			end
		else
			self:updateCurrentSentenceUIInfo(true);
			-- 最后状态，停掉计时器
			if self.playFigureTimer > 0 then
				scheduler.unscheduleGlobal(self.playFigureTimer);
				self.playFigureTimer = -1;
				self.playTextTimer = scheduler.scheduleGlobal(dialoguePlayTextTimerFun, 1/60);
			end
		end
		
		if self.disappearPostion.left then
			self.dialogue_person_left:SetAlpha(alpha);
		end
		
		if self.disappearPostion.middle then
			self.dialogue_person_middle:SetAlpha(alpha);
		end
		
		if self.disappearPostion.right then
			self.dialogue_person_right:SetAlpha(alpha);
		end
					
	end	
	
	-- 启动一个计时器，播放文字和图片的动画
	if self.playTextTimer > 0 then
		print("dialogue timer error, old not play over!");
		scheduler.unscheduleGlobal(self.playTextTimer);
		self.playTextTimer = -1;
		self.showTextCount = 0;
	end
	
	if self.playFigureTimer > 0 then
		print("dialogue timer error, old not play over!");
		scheduler.unscheduleGlobal(self.playFigureTimer);
		self.playFigureTimer = -1;
	end
	
	self.dialogue_text:SetText("");
	--self.playTextTimer = scheduler.scheduleGlobal(dialoguePlayTextTimerFun, 1/60);
	self.isPlayText = true;
	
	-- 设置播放渐隐渐现
	if shouldPlayImage then
		self.playFigureTimer = scheduler.scheduleGlobal(dialogPlayFigureTimerFun, 1/60);
		self.playFigureTimeStamp = 0;
	else
		self.playTextTimer = scheduler.scheduleGlobal(dialoguePlayTextTimerFun, 1/60);
		self:updateCurrentSentenceUIInfo();
	end
	]]
	--]==]
	
	
end

--[==[
[[
function dialogue:updateCurrentSentenceUIInfo(isFinal)
	
	local data = self.dialogueData[self.currentSentenceIndex];
	if data then
		local leftInfo = dataConfig.configs.characterConfig[data.leftID];
		local middleInfo = dataConfig.configs.characterConfig[data.middleID];
		local rightInfo = dataConfig.configs.characterConfig[data.rightID];
		
		local randomVoice = "voice"..math.random(0, 2);
		
		if data.lightIndex == "l" then
			
			if self.voiceFlag[data.leftID] == nil and leftInfo[randomVoice] then
				LORD.SoundSystem:Instance():playEffect(leftInfo[randomVoice]);
				self.voiceFlag[data.leftID] = true;
			end
			
		elseif data.lightIndex == "r" then

			if self.voiceFlag[data.rightID] == nil and rightInfo[randomVoice] then
				LORD.SoundSystem:Instance():playEffect(rightInfo[randomVoice]);
				self.voiceFlag[data.rightID] = true;
			end
					
		else

			if self.voiceFlag[data.middleID] == nil and middleInfo[randomVoice] then
				LORD.SoundSystem:Instance():playEffect(middleInfo[randomVoice]);
				self.voiceFlag[data.middleID] = true;
			end
					
		end
		
		if leftInfo and leftInfo.path and leftInfo.name then
			-- 左边
			self.dialogue_person_left:SetVisible(true);
			self.dialogue_person_left:SetImage(leftInfo.path);
			self.dialogue_name_left_text:SetText(leftInfo.name);
			self.dialogue_name_left:SetVisible(true);
			
			--print("updateCurrentSentenceUIInfo left "..data.lightIndex);
			if data.lightIndex == "l" then
				self.dialogue_person_left:SetEnabled(true);
				self.dialogue_name_left_text:SetEnabled(true);
			else
				self.dialogue_person_left:SetEnabled(false);
				self.dialogue_name_left_text:SetEnabled(false);
			end
		else
			self.dialogue_name_left:SetVisible(false);
			self.dialogue_person_left:SetVisible(false);
		end
		
		if middleInfo and middleInfo.path then
			-- 中间
			self.dialogue_person_middle:SetVisible(true);
			self.dialogue_name_middle:SetVisible(true);
			self.dialogue_person_middle:SetImage(middleInfo.path);
			self.dialogue_name_middle_text:SetText(middleInfo.name);
			self.dialogue_person_middle:SetEnabled(true);
			self.dialogue_name_middle:SetEnabled(true);
		else
			self.dialogue_name_middle:SetVisible(false);
			self.dialogue_person_middle:SetVisible(false);
		end
		
		if rightInfo and rightInfo.path then
			-- 右边
			self.dialogue_person_right:SetVisible(true);
			self.dialogue_name_right:SetVisible(true);
			self.dialogue_person_right:SetImage(rightInfo.path);
			self.dialogue_name_right_text:SetText(rightInfo.name);
			
			if data.lightIndex == "r" then
				self.dialogue_person_right:SetEnabled(true);
				self.dialogue_name_right_text:SetEnabled(true);
			else
				self.dialogue_person_right:SetEnabled(false);
				self.dialogue_name_right_text:SetEnabled(false);
			end
		else
			self.dialogue_name_right:SetVisible(false);
			self.dialogue_person_right:SetVisible(false);
		end
		
		if isFinal then
			self.dialogue_person_left:SetAlpha(1);
			self.dialogue_person_middle:SetAlpha(1);
			self.dialogue_person_right:SetAlpha(1);
		end
			
	end
	
end
]]
--]==]

return dialogue;
 