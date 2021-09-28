-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_expTreeFlower = i3k_class("wnd_expTreeFlower", ui.wnd_base)

function wnd_expTreeFlower:ctor()
	self._scheduler = nil;
	self._time = 0;
end

function wnd_expTreeFlower:configure()
	self._layout.vars.close_btn:onClick(self,self.onClose)
	local vars = self._layout.vars
	--经验
	local expId = g_BASE_ITEM_EXP;
	local expCfg = g_i3k_db.i3k_db_get_base_item_cfg(expId);
	vars.rewardBg1:setImage(g_i3k_db.g_i3k_get_icon_frame_path_by_rank(expCfg.rank))
	vars.rewardIcon1:setImage(g_i3k_db.i3k_db_get_icon_path(expCfg.icon))
	vars.rewardBtn1:onClick(self,function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(expId)
	end)
	
	vars.rewardBg3:setImage(g_i3k_db.g_i3k_get_icon_frame_path_by_rank(expCfg.rank))
	vars.rewardIcon3:setImage(g_i3k_db.i3k_db_get_icon_path(expCfg.icon))
	vars.rewardBtn3:onClick(self,function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(expId)
	end)
	
	local userLevel = g_i3k_game_context:GetLevel();
	local treeInfo = g_i3k_game_context:getExpTreeInfo();
	local exp = math.floor(i3k_db_exp[userLevel].expTreeBaseExp * i3k_db_exptree_common.flowerExpRate)
	vars.rewardNum1:setText("X" .. exp);
	vars.rewardNum3:setText("X" .. exp);
	
	--历练
	local lilianId = g_BASE_ITEM_EMP;
	local lilianCfg = g_i3k_db.i3k_db_get_base_item_cfg(lilianId);
	vars.rewardBg2:setImage(g_i3k_db.g_i3k_get_icon_frame_path_by_rank(lilianCfg.rank))
	vars.rewardIcon2:setImage(g_i3k_db.i3k_db_get_icon_path(lilianCfg.icon))
	vars.rewardBtn2:onClick(self,function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(lilianId)
	end)
	local lilian = math.floor(i3k_db_exp[userLevel].expTreeBaseLilian * i3k_db_exptree_common.flowerLilianRate)
	vars.rewardNum2:setText("X" .. lilian)
	
	vars.rewardBg1:setVisible(not (lilian == 0))
	vars.rewardBg2:setVisible(not (lilian == 0))
	vars.rewardBg3:setVisible(lilian == 0)
	
	vars.expbarCount:setText(i3k_get_string(15512))
	vars.expbar:setPercent(100)
	vars.flowerLevel:setText("Lv." .. #i3k_db_exptree_level);
	
	local harvestTime = g_i3k_game_context:getExpTreeInfo().harvestTime;
	local function getTime()
		local curTime = i3k_game_get_time()
		local time =  i3k_db_exptree_common.rebornTime + harvestTime - curTime
		if time < 0 then
			time = 0
		end
		self._time = time
		
		local hour = math.floor(time / (60*60))
		local min = math.floor((time - hour * 60 * 60)/60)
		local sec = time - hour*60*60 - min*60
		return hour ,min ,sec;
	end
	vars.desc:setText(i3k_get_string(15499, getTime()));
	self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
		print("schedule")
		vars.desc:setText(i3k_get_string(15499, getTime()));
	end, 1, false)

	vars.getReward:onClick(self, function ()
		if self._time <=0 or g_i3k_game_context:getExpTreeInfo().level < #i3k_db_exptree_level then
			g_i3k_ui_mgr:RefreshUI(eUIID_NpcDialogue,eExpTreeId, 2)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15514))
			return
		end
		
		local curHarvestTimes = g_i3k_game_context:getHarvestTimes()
		if curHarvestTimes < i3k_db_exptree_common.flowerNum then
			i3k_sbean.request_exp_tree_mature_reward_req(function ()
				local award = nil;
				if lilian == 0 then
					award = {
						[1] = {id=g_BASE_ITEM_EXP,count=exp}
					};
				else
					award = {
						[1] = {id=g_BASE_ITEM_EXP,count=exp},
						[2] = {id=g_BASE_ITEM_EMP,count=lilian}
					};					
				end
				g_i3k_ui_mgr:ShowGainItemInfo(award)
				g_i3k_game_context:setHarvestTimes(curHarvestTimes + 1)
				self:refresh()
			end)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15502))
		end
	end)
end

function wnd_expTreeFlower:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_ExpTreeFlower)
end

function wnd_expTreeFlower:onHide()
	if self._scheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler)
		self._scheduler = nil
	end
end

function wnd_expTreeFlower:refresh()
	local vars = self._layout.vars
	vars.leftTimes:setText(string.format("今日剩余%d次",i3k_db_exptree_common.flowerNum - g_i3k_game_context:getHarvestTimes()));
	
	if self._time <=0 or g_i3k_game_context:getExpTreeInfo().level < 10 then
		g_i3k_ui_mgr:RefreshUI(eUIID_NpcDialogue,eExpTreeId,2)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15514))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_expTreeFlower.new()
		wnd:create(layout, ...)
	return wnd
end
