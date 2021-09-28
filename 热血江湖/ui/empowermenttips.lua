module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_empowermentTips = i3k_class("wnd_empowermentTips", ui.wnd_base)


function wnd_empowermentTips:ctor()
	self.nullCount = nil
	self.coin = nil
	self.dayTimes = 0
	self.data = nil
end



function wnd_empowermentTips:configure()
	local widgets = self._layout.vars
	
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self.extractBtn    = widgets.saveBtn     --提炼
	self.desc		   = widgets.desc
	self.residueTimes  = widgets.times_desc
	self.nullIron      = widgets.nullIron
	self.nullLab       = widgets.nullLab
	self.nullName  	   = widgets.nullName
	self.needCoinName  = widgets.needCoinName
	self.needCoinIron  = widgets.needCoinIron
	self.needCoinLab   = widgets.needCoinLab
	self.nullIronBg	   = widgets.nullIronBg
	self.needCoinIronBg= widgets.needCoinIronBg
	self.bt1		   = widgets.bt1
	self.bt2		   = widgets.bt2
	self.bg3 		   = widgets.bg3
	self.icon3		   = widgets.icon3
	self.name3 		   = widgets.name3
	self.count3 	   = widgets.count3
	self.bt3           = widgets.bt3
	self.name3 		   = widgets.name3
end
function wnd_empowermentTips:onShowData()
	local info = i3k_db_experience_args
	local times = g_i3k_game_context:GetExperienceDayTakeTimes()  --提取的次数
	local nullID = info.experienceCorrelation.nullID
	self.nullCount = info.experienceCorrelation.nullCount
	local fullID = info.experienceCorrelation.fullID
	local fullCount = info.experienceCorrelation.fullCount
	local item_cfgF = g_i3k_db.i3k_db_get_other_item_cfg(fullID)
	local item_cfgN = g_i3k_db.i3k_db_get_other_item_cfg(nullID)
	self.needCoin = item_cfgF.args1 
	local needNullID = item_cfgN.id    --历练瓶（空）相关
	local needNullIron = item_cfgN.icon
	local coinID = g_i3k_db.i3k_db_get_base_item_cfg(43).id
	local coinIron = g_i3k_db.i3k_db_get_base_item_cfg(43).icon
	local coinName = g_i3k_db.i3k_db_get_base_item_cfg(43).name
	local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(needNullID)
	local coinUseCount = g_i3k_game_context:GetBaseItemCanUseCount(coinID)
	self.nullIron:setImage(g_i3k_db.i3k_db_get_icon_path(needNullIron))
	self.nullIronBg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needNullID)))
	self.bt1:onClick(self, self.clickItem, needNullID)
	self.nullLab:setText(canUseCount.. "/" .. self.nullCount)
	self.nullLab:setTextColor(g_i3k_get_cond_color(canUseCount >= self.nullCount))
	self.nullName:setText(item_cfgN.name)
	self.nullName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needNullID)))
	self.needCoinIron:setImage(g_i3k_db.i3k_db_get_icon_path(coinIron))
	self.needCoinIronBg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(coinID)))
	self.bt2:onClick(self, self.clickItem, coinID)
	self.needCoinLab:setText(self.needCoin)
	self.needCoinLab:setTextColor(g_i3k_get_cond_color(coinUseCount >= self.needCoin))
	self.needCoinName:setText(coinName)
	self.needCoinName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(coinID)))
	self.bg3:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(item_cfgF.id)))
	self.icon3:setImage(g_i3k_db.i3k_db_get_icon_path(item_cfgF.icon))
	self.bt3:onClick(self, self.clickItem, item_cfgF.id)
	self.count3:setText(fullCount)
	self.count3:setTextColor(g_i3k_get_green_color())
	self.name3:setText(item_cfgF.name)
	self.name3:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(item_cfgF.id)))
	self.residueTimes:setText("本日剩余提取次数：" .. times)
	self.desc:setText(i3k_get_string(679))
	if times > 0 then
		self.extractBtn:onClick(self,self.extractExperience,{coinID = coinID, needNullID = needNullID, isCanUse = canUseCount >= self.nullCount or nil, isCanCoin = coinUseCount >= self.needCoin or nil, times = times , fullID = fullID,fullCount = fullCount})
		self.extractBtn:enableWithChildren()				
	else
		self.extractBtn:disableWithChildren()
	end
end

function wnd_empowermentTips:refresh()
	self:onShowData()
end

function wnd_empowermentTips:extractExperience(sender, data)
	if self.nullCount and self.needCoin then
		if data.isCanUse == true and data.isCanCoin == true then
			local callfunc = function ()
				g_i3k_game_context:UseCommonItem(data.coinID, self.needCoin,AT_EXTRACT_EXPCOIN)
				g_i3k_game_context:UseCommonItem(data.needNullID, self.nullCount,AT_EXTRACT_EXPCOIN)
			end
			local temp = {}
			temp[data.fullID] = data.fullCount
			if g_i3k_game_context:IsBagEnough(temp) then
				i3k_sbean.goto_expcoin_extract(callfunc, data.times - 1)                     --提取协议
			else
				g_i3k_ui_mgr:PopupTipMessage("背包已满，无法提取历练")
				return
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(471))
		end
	end
end

function wnd_empowermentTips:clickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_empowermentTips.new();
		wnd:create(layout);

	return wnd;
end
