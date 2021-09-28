-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_actvity_open_aryifact = i3k_class("wnd_actvity_open_aryifact", ui.wnd_base)

local SPEED = 400
function wnd_actvity_open_aryifact:ctor()
	self.inCDtime = false
	self.isRefresh = true
	self.moveflag = false
	self.canUp = true
	self._showPopTimes = 0
	self._strengthLv = 1
end

function wnd_actvity_open_aryifact:configure( )
	local widgets = self._layout.vars
	self.coloseBtn = widgets.close
	self.barimage = widgets.barimage
	self.jiantouview = widgets.jiantouview
	self.getWord = widgets.getWord
	self.curpurcent = widgets.curpurcent
	self.haveTimes = widgets.haveTimes
	self.modle = widgets.modle
	self.upLvlBtn = widgets.upLvlBtn
	self.chuizi = widgets.chuizi
	self.npc = widgets.npc
	self.range = widgets.range
	self.piaozi1 = widgets.piaozi1
	self.piaozi2 = widgets.piaozi2
	self.descBtn = widgets.descBtn
	self.descBtn:onClick(self, self.onHelp)	
	self.listView = widgets.listView	
	self.curwmd = widgets.curwmd	
	self.nextwmd = widgets.nextwmd	
	self.jiantou = widgets.jiantou
	self.property = widgets.property	
	self.property1 = widgets.property1	
	self.atkBar = widgets.atkBar
	self.atkTaxt = widgets.atkTaxt
	self.defBar = widgets.defBar
	self.defTaxt = widgets.defTaxt
	self.hpBar = widgets.hpBar
	self.hpTaxt = widgets.hpTaxt
	self.layer = widgets.layer
	self.purcentIcon = widgets.purcentIcon
	self.headline = widgets.headline;
	self.atkBarText = widgets.atkBarText;
	self.defBarText = widgets.defBarText;
	self.hpBarText = widgets.hpBarText;
	for i = 1 , 5 do
		self["state"..i] = widgets["state"..i]
	end
	self.pzanimation = self._layout.anis.c_pz
	self.jfanimation = self._layout.anis.c_jf
	self.fzanimation = self._layout.anis.c_shan
	self.upgrade	= self._layout.anis.c_shenji
	self:updateModelState(widgets.texiao , 426,"stand")
	self:updateModelState(self.chuizi , 1289,"stand",math.pi/6 - math.pi/0.5)
	

	local roleType = g_i3k_game_context:GetRoleType()
	self:updateModelState(self.modle , i3k_db_chuanjiabao.cfg["modleId"..roleType],"stand01")
	local rotate = self.modle:getRotation()
	self.modle:setRotation(rotate.y  , rotate.x+math.pi/0.36
	)

	self.coloseBtn:onClick(self, self.onCloseUI,function()
		if self.type == 1 then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_KeepActivity,"updateArtifactInfo")
		elseif self.type == 2 then
			g_i3k_ui_mgr:RefreshUI(eUIID_OpenArtufact1)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy, "updateHeirloomIcon")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "updateHeirloomIcon")
		end
	end)	
	self.upLvlBtn:onClick(self, self.onClickupLvlBtn)	
	-- self.findEnemyBtn:onClick(self, self.onClickfindEnemyBtn)	
	-- self.centerBtn:onClick(self, self.onClickcenterBtn)	
	self.isadd = true
	self.info = {}
	
	local randCnt = math.random(1,#i3k_db_chuanjiabao.cfg.barstyles)
	local cfg = i3k_db_chuanjiabao.cfg.barstyles[randCnt]
	local counts = {};
	local poss = {}
	for i = 1 , 10 do
		if i % 2 == 0 then
			table.insert(counts,cfg[i])
		else
			table.insert(poss,cfg[i])
		end
	end
	self.info.counts = counts
	self.info.poss = poss
	 
end

function wnd_actvity_open_aryifact:onHelp(sender)
	local heirloom = g_i3k_game_context:getHeirloomData()
	if heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount then
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15178))
	else
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15463))
	end
end

function wnd_actvity_open_aryifact:updateModelState(model, showId, action, rotation)
	--ui_set_hero_model(model, showId)		
	local path = i3k_db_models[showId].path
	local uiscale = i3k_db_models[showId].uiscale
	model:setSprite(path)
	model:setSprSize(uiscale)
	model:pushActionList(action, -1)
	model:playActionList()
	if rotation then
		model:setRotation(rotation,-0.2)
	end
end

function wnd_actvity_open_aryifact:releaseScheduler()
	if self.moveflag  then
		self.moveflag = false
	end 
end

function wnd_actvity_open_aryifact:updateHaveTimes(haveTimes, dayWipeTimes)
	local str = "剩余次数"..(haveTimes - dayWipeTimes).."/"..haveTimes.."次"
	if haveTimes == dayWipeTimes then
		str = string.format("剩余次数<c=%s>%s</c>/%s次",g_i3k_get_red_color(),(haveTimes - dayWipeTimes), haveTimes)
		self.jfanimation.stop()
	else
		self.jfanimation.play()
	end
	self.haveTimes:setText(str)
end

function wnd_actvity_open_aryifact:refresh()
	local heirloom = g_i3k_game_context:getHeirloomData()
	local lvl = g_i3k_game_context:GetLevel();
	if (heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount) or (heirloom.perfectDegree == i3k_db_chuanjiabao.cfg.topcount and lvl < i3k_db_chuanjiabao_strength.cfg.levelLimit) then
		self.property1:hide();
		self.property:show();
		self:updateProperty()
		self.headline:setImage(i3k_db_icons[3809].path);
		self.barimage:setImage(i3k_db_icons[3816].path);
		self:updateModelState(self.npc, 1290,"stand")
		self.curpurcent:setText("当前完美度："..heirloom.perfectDegree)
		self:updateHaveTimes(i3k_db_chuanjiabao.cfg.haveTimes, heirloom.dayWipeTimes);
		self.getWord:setText("强化解封")	
	else
		if lvl >= i3k_db_chuanjiabao_strength.cfg.levelLimit then
			local heirloomStrength = g_i3k_game_context:getHeirloomStrengthData()
			self.atkTaxt:hide();
			self.defTaxt:hide();
			self.hpTaxt:hide();
			self.property:hide();
			self.property1:show();
			self.purcentIcon:hide();
			self:updateProperty1();
			self.headline:setImage(i3k_db_icons[3810].path);
			self.barimage:setImage(i3k_db_icons[3817].path);
			self.getWord:setText("精炼强化")
			self:updateModelState(self.npc, 1304,"chuanshi01")
			self:updateHaveTimes(i3k_db_chuanjiabao_strength.cfg.dayStrengthTime, heirloomStrength.dayStrengthTime);
		end
	end
end

function wnd_actvity_open_aryifact:updateProperty( )
	local nextvalue = nil
	local heirloom = g_i3k_game_context:getHeirloomData()
	local cfg = nil
	local nextcfg = nil
	for i = #i3k_db_chuanjiabao.props , 1 , -1 do
		if  heirloom.perfectDegree >= i3k_db_chuanjiabao.props[i].wanmeidu  then
			cfg = i3k_db_chuanjiabao.props[i]
			if i3k_db_chuanjiabao.props[i+1] then
				nextcfg = i3k_db_chuanjiabao.props[i+1]
			end
			break
		end
	end
	if cfg == nil  then
		nextcfg = i3k_db_chuanjiabao.props[1]
		cfg = {}
	end
	self.listView:removeAllChildren()
	self.listView:setBounceEnabled(false)
	self.addValue = {}
	self.curwmdvalue = 0
	self.nextwmdvalue  = 0
	for i = 1 , 5 do
		if nextcfg and nextcfg["property"..i.."id"] and nextcfg["property"..i.."id"] > 0  and nextcfg["property"..i.."value"] > 0 then
			local item = require("ui/widgets/jfsqt")()
			self.listView:addItem(item)
			item.vars.desc:setText(i3k_db_prop_id[nextcfg["property"..i.."id"]].desc.."：")
			local value1 = cfg["property"..i.."value"]or 0
			local value2 = nextcfg["property"..i.."value"] - (cfg["property"..i.."value"]or 0)
			item.vars.curvalue:setText(value1)
			item.vars.nextvalue:setText("+"..value2)
			local fadeout = item.vars.nextvalue:createFadeOut(2)
			local fadein = item.vars.nextvalue:createFadeIn(2)
			local seq = item.vars.nextvalue:createSequence(fadeout, fadein)
			local repeatForever = item.vars.nextvalue:createRepeatForever(seq)
			item.vars.nextvalue:runAction(repeatForever)
			self.curwmdvalue = heirloom.perfectDegree
			self.nextwmdvalue = nextcfg.wanmeidu
			table.insert(self.addValue,{item.vars.curvalue , item.vars.nextvalue ,value1 , value2 })
		elseif cfg and cfg["property"..i.."id"] and cfg["property"..i.."id"] > 0  and cfg["property"..i.."value"] > 0 then
			local item = require("ui/widgets/jfsqt")()
			self.listView:addItem(item)
			item.vars.desc:setText(i3k_db_prop_id[cfg["property"..i.."id"]].desc.."：")
			item.vars.curvalue:setText(cfg["property"..i.."value"]or 0)
			item.vars.nextvalue:setText("")
		end
	end
	if nextcfg then
		self.curwmd:setText(cfg.wanmeidu or 0) 
		self.nextwmd:setText(nextcfg.wanmeidu or 10) 
	else
		self.curwmd:setText(cfg.wanmeidu.."(最大)")
		self.nextwmd:setText("")
		self.jiantou:hide()
	end
end

function wnd_actvity_open_aryifact:onClickupLvlBtn()
	if not self.moveflag   then
		self.moveflag = true
	else
		self.moveflag = false
	end

	local heirloom = g_i3k_game_context:getHeirloomData()
	local lvl = g_i3k_game_context:GetLevel();
	if heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount then
		self.callbackvalue = 0
		if heirloom.dayWipeTimes >= i3k_db_chuanjiabao.cfg.haveTimes then
			self.canUp = false
			return g_i3k_ui_mgr:PopupTipMessage("今日次数已用完")
		end
	else
		if lvl >= i3k_db_chuanjiabao_strength.cfg.levelLimit then
			self.atkTaxt:hide();
			self.defTaxt:hide();
			self.hpTaxt:hide();
			local heirloomStreng = g_i3k_game_context:getHeirloomStrengthData();
			if heirloomStreng.dayStrengthTime >= i3k_db_chuanjiabao_strength.cfg.dayStrengthTime then
				return g_i3k_ui_mgr:PopupTipMessage("今日次数已用完")
			end
			if heirloomStreng.curStrengthIndex and heirloomStreng.curStrengthIndex > 0 then
				self:OpenUIStrengthSelect()
				return g_i3k_ui_mgr:PopupTipMessage("请您先选择上次未完成的精炼")
			end
			if self:IsClearHeirloomStrength() then
				return g_i3k_ui_mgr:PopupTipMessage("恭喜您精炼升级到下一层")
			end
			if (heirloomStreng.layer > #i3k_db_chuanjiabao_strength.strength) or ((heirloomStreng.layer == #i3k_db_chuanjiabao_strength.strength) and (g_i3k_game_context:CheckHeirloomStrengMax())) then
				return g_i3k_ui_mgr:PopupTipMessage("恭喜您现在已经精炼到圆满")
			end
		else
			self:isShowMessage();
		end
	end

	if self.moveflag == true then
		self.jfanimation.stop()
		self.chuizi:pushActionList("qianghua01", 1)
		self.chuizi:pushActionList("qianghua02", -1)
		self.chuizi:playActionList()
		if heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount then
			self.getWord:setText("确定")
		end
	else
		if heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount then
			if self.inCDtime == true then
				return
			end
		end
		self:releaseScheduler()
		local posx = self.jiantouview:getPositionY() - self.range:getPositionY()
		local height  = self.range:getSize().height
		local value =  posx/height*100
		if value < 0 then
			value = 0
		end
		if value >  99 then
			value = 99
		end
		local curindex = nil	
		for i = 1 , #self.info.poss  do
			if self.info.poss[i - 1] then
				if value >= self.info.poss[i-1] and value < self.info.poss[i] then
					curindex = self.info.counts[i]
					break
				end 
			else
				if value >= 0 and value < self.info.poss[i] then
					curindex = self.info.counts[i]
					break
				end
			end
		end
		if curindex then
			local cfg = nil
			if heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount then
				if heirloom.isOpen == 0 then
					cfg = i3k_db_chuanjiabao.cfg.beforecount
				else
					cfg = i3k_db_chuanjiabao.cfg.aftercount
				end
				self.callbackvalue = cfg[curindex]
				i3k_sbean.wipeHeirloom(curindex)
				self._showPopTimes = 3
				self._strengthLv = curindex
			elseif lvl >= i3k_db_chuanjiabao_strength.cfg.levelLimit then 
				i3k_sbean.lookHeirloom(curindex);
			end
		end
		self.inCDtime = true
	end
end

function wnd_actvity_open_aryifact:onUpdate(dTime)
	 
	if self.moveflag and self.canUp then
		self:JiantouMove(dTime)
	end
	if self._showPopTimes > 0 then
		self._showPopTimes = self._showPopTimes - dTime
		self._layout.vars.wordRoot:show()
		self._layout.vars.word:setText(i3k_get_string(i3k_db_chuanjiabao.cfg.popTextId[self._strengthLv]))
	else
		self._layout.vars.wordRoot:hide()
	end
	
end

function wnd_actvity_open_aryifact:OpenUIStrengthSelect()
	local heirloom = g_i3k_game_context:getHeirloomStrengthData();
	if heirloom.curStrengthIndex and heirloom.curStrengthIndex > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_ArtifactStrengthSelect) 
		g_i3k_ui_mgr:RefreshUI(eUIID_ArtifactStrengthSelect, heirloom.curStrengthIndex)
	end
end

function wnd_actvity_open_aryifact:IsClearHeirloomStrength()
	local heirloom = g_i3k_game_context:getHeirloomStrengthData();
	if g_i3k_game_context:CheckHeirloomStrengMax() then
		if heirloom.layer < #i3k_db_chuanjiabao_strength.strength then
			g_i3k_game_context:ClearHeirloomStrengthData();
			self:playUpgradeEffect()
			return true;
		end
	end  	
	return false;
end

function wnd_actvity_open_aryifact:JiantouMove(dTime)
	if self.jiantouview:getPositionY() < self.range:getPositionY() + self.range:getSize().height and self.isadd then
		self.isadd = true
		self.jiantouview:setPositionY(self.jiantouview:getPositionY() + SPEED * dTime)
	else
		self.jiantouview:setPositionY(self.jiantouview:getPositionY() - SPEED * dTime)
		self.isadd = false
		if self.jiantouview:getPositionY() < self.range:getPositionY() then
			self.isadd = true
		end
	end
end

function wnd_actvity_open_aryifact:playUpgradeEffect()
	local delay = cc.DelayTime:create(1.2)--序列动作 动画播了1.2秒后刷新界面
	local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
		self.upgrade.play()
	end), delay, cc.CallFunc:create(function ()
		self:updateProperty1();
	end))
	self:runAction(seq)
end

function wnd_actvity_open_aryifact:onHideImpl( )
	self:releaseScheduler()
	self:releaseScheduler2()
	self:releaseScheduler3()
end

function wnd_actvity_open_aryifact:releaseScheduler2()
	if self._scheduler2 then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler2)
		self._scheduler2 = nil
	end
end

function wnd_actvity_open_aryifact:PlayAction(isStrength)
	self.chuizi:pushActionList("qianghua", 1)
	self.chuizi:pushActionList("stand", -1)
	self.chuizi:playActionList()

	self.modle:pushActionList("qianghua", 1)
	self.modle:pushActionList("stand01", -1)
	self.modle:playActionList()
	
	if isStrength then
		self.npc:pushActionList("chuanshi03", 1)
		self.npc:pushActionList("chuanshi01", -1)
		self.npc:playActionList()
	else
		self.npc:pushActionList("qianghua", 1)
		self.npc:pushActionList("stand", -1)
		self.npc:playActionList()
	end
end

function wnd_actvity_open_aryifact:callback()
	g_i3k_game_context:setHeirloomDataInfo( self.callbackvalue )
	self:PlayAction();
	if self.callbackvalue < 10 then
		self.piaozi1:setImage("cjb#"..self.callbackvalue)
		self.piaozi2:hide()
	else
		self.piaozi2:show()
		self.piaozi1:setImage("cjb#"..math.ceil(self.callbackvalue / 10))
		self.piaozi2:setImage("cjb#"..(self.callbackvalue % 10))
	end
	self._scheduler2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		self:releaseScheduler2()
		self.pzanimation.play()
		self.jiantouview:setPositionY(self.range:getPositionY())
		self:showAnimation()
	end, 0.8 , false)
	self:isShowMessage();
end

function wnd_actvity_open_aryifact:isShowMessage()
	local heirloom = g_i3k_game_context:getHeirloomData()
	local lvl = g_i3k_game_context:GetLevel();	
	if heirloom.perfectDegree == i3k_db_chuanjiabao.cfg.topcount then
		if lvl >= i3k_db_chuanjiabao_strength.cfg.levelLimit then
			self:ShowMessage()	
		else
			self:ShowMessage(i3k_db_chuanjiabao_strength.cfg.levelLimit)
		end
	end
end

function wnd_actvity_open_aryifact:ShowMessage(lvl)
	self.isRefresh = false;
	local callback = function ()
		local heirloom = g_i3k_game_context:getHeirloomData()	
		g_i3k_ui_mgr:CloseUI(eUIID_OpenArtufact);
		if heirloom.isOpen == 0 then
			g_i3k_ui_mgr:RefreshUI(eUIID_KeepActivity, true);
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_OpenArtufact1);
		end
	end

	if lvl then
		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(15462, lvl), callback)
	else
		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(15461), callback)
	end
end

function wnd_actvity_open_aryifact:strength()
	self.jiantouview:setPositionY(self.range:getPositionY())
	self:updatePropertyText();
	g_i3k_game_context:setHeirloomStrengthData()
	local heirloomStrength = g_i3k_game_context:getHeirloomStrengthData()
	self:updateHaveTimes(i3k_db_chuanjiabao_strength.cfg.dayStrengthTime, heirloomStrength.dayStrengthTime);
	self:PlayAction(true);
	self:updateProperty1();
	self.inCDtime = false;
end

function wnd_actvity_open_aryifact:updateProperty1()
	local isMax = false;
	local strengthPor = g_i3k_game_context:getHeirloomStrengthData();
	local strengthData = nil;
	if strengthPor.layer > #i3k_db_chuanjiabao_strength.strength  then
		isMax = true;
	end
	if isMax then
		strengthData = i3k_db_chuanjiabao_strength.strength[strengthPor.layer-1];
	else
		strengthData = i3k_db_chuanjiabao_strength.strength[strengthPor.layer];
	end
	
	local atkPro = 0;
	local defPro = 0;
	local hpPro = 0;
	
	if strengthPor.StrengthPro and strengthPor.StrengthPro[ePropID_atkN] then
		if strengthPor.StrengthPro[ePropID_atkN] <= strengthData.pro1 then
			atkPro = atkPro + strengthPor.StrengthPro[ePropID_atkN];
		else
			atkPro = strengthData.pro1;
		end
	end
	if strengthPor.StrengthPro and strengthPor.StrengthPro[ePropID_defN] then
		if strengthPor.StrengthPro[ePropID_defN] <= strengthData.pro2 then
			defPro = defPro + strengthPor.StrengthPro[ePropID_defN];
		else
			defPro = strengthData.pro2;
		end
	end
	if strengthPor.StrengthPro and strengthPor.StrengthPro[ePropID_maxHP] then
		if strengthPor.StrengthPro[ePropID_maxHP] <= strengthData.pro3 then
			hpPro = hpPro + strengthPor.StrengthPro[ePropID_maxHP];
		else
			hpPro = strengthData.pro3;
		end
	end
	
	if isMax then
		atkPro = strengthData.pro1;
		defPro = strengthData.pro2;
		hpPro = strengthData.pro3;
		local layer = strengthPor.layer - 1;
		self.layer:setText("第"..layer.."层");
	else
		self.layer:setText("第"..strengthPor.layer.."层");
	end
	self.atkBarText:setText(atkPro.."/"..strengthData.pro1);
	self.defBarText:setText(defPro.."/"..strengthData.pro2);
	self.hpBarText:setText(hpPro.."/"..strengthData.pro3);
	
	self.atkBar:setPercent(atkPro / strengthData.pro1 * 100)
	self.defBar:setPercent(defPro / strengthData.pro2 * 100)
	self.hpBar:setPercent(hpPro / strengthData.pro3 * 100)
end

function wnd_actvity_open_aryifact:updatePropertyText()
	local Strength = g_i3k_game_context:getHeirloomStrengthData();
	local value = i3k_db_chuanjiabao_strength.pros[Strength.PropIndex].value;
	local strengthData = i3k_db_chuanjiabao_strength.strength[Strength.layer];
	local colorBet = i3k_db_chuanjiabao_strength.colorBet[Strength.curStrengthIndex].rate;
	value = value * colorBet;
	if Strength.percent then
		value = value * Strength.percent;
	end
	local checkNum = nil;
	if Strength.PropIndex == g_ATK then 
		if Strength.StrengthPro then 
			if Strength.StrengthPro[ePropID_atkN] then
				checkNum = i3k_check_heirloom_strength(Strength.StrengthPro[ePropID_atkN], value, strengthData.pro1);
			else
				checkNum = i3k_check_heirloom_strength(0, value, strengthData.pro1);
			end
			
			if checkNum then
				value = checkNum
			end
		end 
		self.atkTaxt:show();
		self.atkTaxt:setText("+"..value);
	elseif Strength.PropIndex == g_DEF then
		if Strength.StrengthPro then
			if Strength.StrengthPro[ePropID_defN] then
				checkNum = i3k_check_heirloom_strength(Strength.StrengthPro[ePropID_defN], value, strengthData.pro2);
			else
				checkNum = i3k_check_heirloom_strength(0, value, strengthData.pro2);
			end
		
			if checkNum then
				value = checkNum
			end
		end
		self.defTaxt:show();
		self.defTaxt:setText("+"..value);
	elseif Strength.PropIndex == g_HP then 
		if Strength.StrengthPro then
			if Strength.StrengthPro[ePropID_maxHP] then
				checkNum = i3k_check_heirloom_strength(Strength.StrengthPro[ePropID_maxHP], value, strengthData.pro3);
			else
				checkNum = i3k_check_heirloom_strength(0, value, strengthData.pro3);
			end
			
			if checkNum then
				value = checkNum
			end	
		end
		self.hpTaxt:show();
		self.hpTaxt:setText("+"..value);
	end
end

function wnd_actvity_open_aryifact:showAnimation( ... )
	local _time = 0
	if self.curwmdvalue + self.callbackvalue >= self.nextwmdvalue and self.addValue and #self.addValue == 3 then--
		self.fzanimation.play()
		self._scheduler3 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
			if _time > 30 then
				if self.releaseScheduler3 then
					self:releaseScheduler3()
					if self.isRefresh then
						self:refresh()
					end
					self.inCDtime = false
				end
			else
				_time = _time + 1
				for k,v in pairs(self.addValue) do
					local t = tonumber(v[1]:getText()) + math.ceil(v[4]/30)
					if t < v[3]+v[4]  then
						v[1]:setText(t)
						v[2]:setText("")
					else
						v[1]:setText(v[3]+v[4])
					end
				end
			end
		end, 0.02 , false)
	else
		self:refresh()
		self.inCDtime = false
	end
end

function wnd_actvity_open_aryifact:setType(mtype)
	self.type = mtype
	self:refresh()
	self.jiantouview:setPositionY(self.range:getPositionY())
	for i = 1 , 5 do
		local state = self["state"..i]
		local posx1 = state:getPositionY() 
		local height = self.range:getSize().height
		local height2 = self.info.poss[i]/100 * height
		if self["state"..(i - 1)] then
			posx1 = self["state"..(i - 1)]:getPositionY() + self["state"..(i - 1)]:getSize().height
			height2 = (self.info.poss[i] - self.info.poss[i - 1])/100 * height
		end
		state:setContentSize(self.range:getSize().width,height2)
		state:setPositionY( posx1 )
		if i3k_db_chuanjiabao.cfg.colorImages[self.info.counts[i]] then
			state:setImage(i3k_db_icons[i3k_db_chuanjiabao.cfg.colorImages[self.info.counts[i]]].path)
		end
	end
end

function wnd_actvity_open_aryifact:releaseScheduler3()
	if self._scheduler3 then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler3)
		self._scheduler3 = nil
	end
end

function wnd_create(layout)
	local wnd = wnd_actvity_open_aryifact.new()
	wnd:create(layout)
	return wnd
end

--[[
	local info = i3k_db_chuanjiabao.cfg.barstyles[math.random(1,#i3k_db_chuanjiabao.cfg.barstyles)]
	local counts = {};
	local poss = {}
	for i = 1 , 10 do
		if i % 2 == 0 then
			table.insert(counts,info[i])
		else
			table.insert(poss,info[i])
		end
	end

	if #counts > 0 then
		local total = 0;
		for j = 1, #poss do
			total = total + poss[j];
		end
		local rand = math.random(total);
		total = 0;
		local iindex = -1;
		for j = 1, #poss do
			total = total + poss[j];
			if total >= rand then
				iindex = j;
				break;
			end
		end
		if iindex == -1 then
			iindex = 1;
		end
		self.curpurcent:setText("当然完美度："..counts[iindex])
	end
]]
