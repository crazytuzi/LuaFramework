module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_empowerment = i3k_class("wnd_empowerment", ui.wnd_base)


function wnd_empowerment:ctor()
	self.nullCount = nil
	self.coin = nil
	self.dayTimes = 0
	self.data = nil
end



function wnd_empowerment:configure()
	local widgets = self._layout.vars
	
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self.extractBtn    = widgets.saveBtn     --提炼
	self.desc1         = widgets.desc1
	self.percent       = widgets.myHeroBlood5
	self.nowCurExpCoin = widgets.nowCurExpCoin
	self.maxCurExpCoin = widgets.maxCurExpCoin
	
	self.model		   = widgets.model
	self.empowerment_btn   = widgets.empowerment_btn
	self.library_btn   = widgets.library_btn 
	self.penetrate_btn = widgets.penetrate_btn
	self.red_point = widgets.red_point
	self.red_point2 = widgets.red_point2
	self.red_point3 = widgets.red_point3
	self.penetrate_btn:onClick(self,self.penetrateBtn)
	self.library_btn:onClick(self,self.libraryBtn)
	self.penetrate     = widgets.penetrate
	self.penetrate_btn:stateToNormal()
	self.library_btn:stateToNormal()
	self.library_btn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_experience_args.args.libraryHideLevel)
	self.empowerment_btn:stateToPressed()

	widgets.qiankunBtn:onClick(self,self.qiankunBtn)
	widgets.qiankunBtn:stateToNormal()
	widgets.qiankunBtn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_experience_args.experienceUniverse.showLevel)
end

function wnd_empowerment:onShowData()
	local info = i3k_db_experience_args
	local maxSaveExperience = info.args.maxSaveExperience
	local needExp = info.args.needExp
	local coinID = g_i3k_db.i3k_db_get_base_item_cfg(43).id
	local coinUseCount = g_i3k_game_context:GetBaseItemCanUseCount(coinID)
	self.nowCurExpCoin:setText(coinUseCount)
	self.maxCurExpCoin:setText(maxSaveExperience)
	local item_cfgF = g_i3k_db.i3k_db_get_other_item_cfg(info.experienceCorrelation.fullID)
	self.percent:setPercent(coinUseCount/maxSaveExperience * 100)
	self.red_point:setVisible(g_i3k_game_context:redPointForAllCheats() or g_i3k_game_context:redPointForBooks()) --红点逻辑
	self.red_point2:setVisible(g_i3k_game_context:qiankunRedPoints() ) --红点逻辑
	self.red_point3:setVisible(g_i3k_game_context:isShowCunWnRed())
	self.extractBtn:setVisible(coinUseCount >= item_cfgF.args1)
	self.extractBtn:onClick(self,self.extractExperience)
	self.desc1:setText(i3k_get_string(678, needExp))
end

function wnd_empowerment:refresh()
	self:onShowData()
	self:showModel()
end

function wnd_empowerment:extractExperience(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_EmpowermentTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_EmpowermentTips)
end

function wnd_empowerment:showModel()
	local id = i3k_db_experience_args.args.modelID
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self.model:setSprite(path)
	self.model:setSprSize(uiscale)
	self.model:playAction(i3k_db_experience_args.args.model)
end

function wnd_empowerment:clickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_empowerment:libraryBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_experience_args.args.libraryShowLevel then
		local str = string.format("等级达到%s时藏书开启", i3k_db_experience_args.args.libraryShowLevel)
		g_i3k_ui_mgr:PopupTipMessage(str)
		return
	end
	i3k_sbean.goto_rarebook_sync()   --同步藏书协议
end
function wnd_empowerment:qiankunBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_experience_args.experienceUniverse.openLevel then
		local str = string.format("等级达到%s时乾坤开启", i3k_db_experience_args.experienceUniverse.openLevel)
		g_i3k_ui_mgr:PopupTipMessage(str)
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_Qiankun)
	g_i3k_ui_mgr:RefreshUI(eUIID_Qiankun)
	g_i3k_ui_mgr:CloseUI(eUIID_Empowerment)
end

function wnd_empowerment:penetrateBtn()
	i3k_sbean.goto_grasp_sync()      --同步参悟协议
end
--[[function wnd_empowerment:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Empowerment)
end--]]

function wnd_create(layout)
	local wnd = wnd_empowerment.new();
		wnd:create(layout);

	return wnd;
end
