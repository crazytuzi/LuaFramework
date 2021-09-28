-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_expTreeWater = i3k_class("wnd_expTreeWater", ui.wnd_base)

function wnd_expTreeWater:ctor()
	self.getExpNum = 0;
	self.getLilianNum = 0;
end

function wnd_expTreeWater:configure()
	local vars = self._layout.vars
	vars.close_btn:onClick(self,self.onClose)
	vars.getWaterBtn:onClick(self, function ()
		self:onClose()
		local waterPos = i3k_db_exptree_common.waterPos
		--前往水桶
		local point = g_i3k_db.i3k_db_get_res_pos(waterPos);
		local mapID = g_i3k_db.i3k_db_get_res_map_id(waterPos);
		local needValue = {flage = 2, mapId = mapID, areaId=waterPos, pos = point}
		
		local isCan = g_i3k_game_context:doTransport(needValue) --判断能否传送
		if not isCan then
			g_i3k_game_context:SeachPathWithMap(mapID,point,nil,nil,needValue)
		end
	end)
	
	local waterItem = i3k_db_exptree_common.waterItem
	vars.costBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(waterItem))
	vars.costIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(waterItem,i3k_game_context:IsFemaleRole()))
	vars.costBtn:onClick(self,function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(waterItem)
	end)
	
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
	
	--历练
	local lilianId = g_BASE_ITEM_EMP;
	local lilianCfg = g_i3k_db.i3k_db_get_base_item_cfg(lilianId);
	vars.rewardBg2:setImage(g_i3k_db.g_i3k_get_icon_frame_path_by_rank(lilianCfg.rank))
	vars.rewardIcon2:setImage(g_i3k_db.i3k_db_get_icon_path(lilianCfg.icon))
	vars.rewardBtn2:onClick(self,function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(lilianId)
	end)
	
	vars.desc:setText(i3k_get_string(15498));
	
	vars.waterBtn:onClick(self, function ()
		if g_i3k_game_context:getExpTreeLevel() >= #i3k_db_exptree_level then
			g_i3k_ui_mgr:RefreshUI(eUIID_NpcDialogue,eExpTreeId,2)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15513))
			return
		end
		
		if g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_exptree_common.waterItem) < 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(402))
			return
		end
		local curWateringTimes = g_i3k_game_context:getWateringTimes()
		if curWateringTimes < i3k_db_exptree_common.waterNum then
			i3k_sbean.request_exp_tree_watering_req(function ()
				local award = nil;
				if self.getLilianNum == 0 then
					award = {
						[1] = {id=g_BASE_ITEM_EXP,count=self.getExpNum}
					};
				else
					award = {
						[1] = {id=g_BASE_ITEM_EXP,count=self.getExpNum},
						[2] = {id=g_BASE_ITEM_EMP,count=self.getLilianNum}
					};					
				end

				
				g_i3k_ui_mgr:ShowGainItemInfo(award)
				g_i3k_game_context:UseCommonItem(i3k_db_exptree_common.waterItem,1,AT_WATER_EXPTREE)
				g_i3k_game_context:setWateringTimes(curWateringTimes + 1)
				--同步状态
				i3k_sbean.request_exp_tree_sync_req()
			end)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15501))
		end
	end)
end

function wnd_expTreeWater:refresh()
	local treeInfo = g_i3k_game_context:getExpTreeInfo();
	
	if treeInfo.level >= #i3k_db_exptree_level then
		g_i3k_ui_mgr:RefreshUI(eUIID_NpcDialogue,eExpTreeId,2)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15513))
	end
		
	local vars = self._layout.vars
	local userLevel = g_i3k_game_context:GetLevel();
	
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_exptree_common.waterItem)
	vars.costNum:setText(haveCount .. "/1")
	vars.costNum:setTextColor(g_i3k_get_cond_color(haveCount>=1))
	
	local exp = math.floor(i3k_db_exp[userLevel].expTreeBaseExp * i3k_db_exptree_level[treeInfo.level].expRate)
	self.getExpNum = exp;
	vars.rewardNum1:setText("X" .. exp);
	vars.rewardNum3:setText("X" .. exp);
	
	local lilian = math.floor(i3k_db_exp[userLevel].expTreeBaseLilian * i3k_db_exptree_level[treeInfo.level].lilianRate)
	
	self.getLilianNum = lilian;
	vars.rewardNum2:setText("X" .. lilian)
	
	vars.rewardBg1:setVisible(not (lilian == 0))
	vars.rewardBg2:setVisible(not (lilian == 0))
	vars.rewardBg3:setVisible(lilian == 0)
	
	vars.flowerLevel:setText("Lv." .. treeInfo.level);
	vars.leftTimes:setText(string.format("今日剩余%d次",i3k_db_exptree_common.waterNum - g_i3k_game_context:getWateringTimes()));
	if treeInfo.level >= #i3k_db_exptree_level then
		vars.expbarCount:setText(i3k_get_string(15512))
		vars.expbar:setPercent(100)
	else
		vars.expbarCount:setText(treeInfo.exp .. "/" .. i3k_db_exptree_level[treeInfo.level + 1].exp)
		vars.expbar:setPercent(treeInfo.exp/i3k_db_exptree_level[treeInfo.level + 1].exp * 100)
	end

end

function wnd_expTreeWater:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_ExpTreeWater)
end

function wnd_create(layout, ...)
	local wnd = wnd_expTreeWater.new()
		wnd:create(layout, ...)
	return wnd
end
