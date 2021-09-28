-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_strengthen_self = i3k_class("wnd_strengthen_self", ui.wnd_base)

local CHANNALJUMPTYPE_UI = 1
local CHANNALJUMPTYPE_NPC = 2

local clickFunction = 
{
	[g_WANT_STRONG] = {"onWantStrongClick"},
	[g_WANT_OTHER] = {"onWantOtherClick"},
}

function wnd_strengthen_self:ctor()
end

function wnd_strengthen_self:configure()
	local widgets = self._layout.vars
	self.first_info = i3k_game_context:getStrengthenSelfFirstListInfo() --左侧大类列表
	widgets.current_score:setText(g_i3k_game_context:GetRolePower())
	widgets.recommend_score:setText(i3k_db_want_improve_recommendPower[g_i3k_game_context:GetLevel()].power)
	widgets.rank_img:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_want_improve_judgeCfg[g_i3k_db.i3k_db_get_power_rank()].iconID))
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_strengthen_self:onShow()
	self._widgets = self._layout.vars
	self.first_dropDownList = g_i3k_ui_mgr:createDropDownList(self._widgets.scr_list1, self.first_info, i3k_getDropDownWidgetsMap(g_DROPDOWNLIST_STRENGTHEN_SELF_IMPROVE))
	self.first_dropDownList:rgSelectedHandlers(self, clickFunction) -- 注册点击事件表
	self.first_dropDownList:show() -- 要放在注册回调之后
end 

function wnd_strengthen_self:onWantStrongClick(sender,args)
	self.second_info = i3k_game_context:getStrengthenSelfSecondListInfo(g_i3k_get_commend_mission())
	self.second_dropDownList = g_i3k_ui_mgr:createDropDownList(self._widgets.scr_list2, self.second_info, i3k_getDropDownWidgetsMap(g_DROPDOWNLIST_STRENGTHEN_SELF_DETAIL))
	self.second_dropDownList:setOnOpenChildItems(self.onOpenChildItems)
	self.second_dropDownList:setOnCloseChildItems(self.onCloseChildItems)
	self.second_dropDownList:show() -- 要放在注册回调之后
	self:initStrongNode(self.second_dropDownList)
	--刷新宠物按战力降序排序的列表
	g_i3k_game_context:SortPetByPower()
end

function wnd_strengthen_self:onWantOtherClick(sender,args)
	if args then
		self.second_info = i3k_game_context:getOtherSecondListInfo(args)
		self.second_dropDownList = g_i3k_ui_mgr:createDropDownList(self._widgets.scr_list2, self.second_info, i3k_getDropDownWidgetsMap(g_DROPDOWNLIST_STRENGTHEN_SELF_OTHER))
		self.second_dropDownList:show() -- 要放在注册回调之后
		self:initOtherNode(self.second_dropDownList)
	end
end

function wnd_strengthen_self:onLeaveForButtonClick(sender,args)
	local info = args.m_data
	local jumpID = info.jumpID  
	if jumpID then
		if info.jumpType == CHANNALJUMPTYPE_UI then
			g_i3k_logic:JumpUIID(jumpID)
		elseif info.jumpType == CHANNALJUMPTYPE_NPC then			
			g_i3k_game_context:GotoNpc(jumpID, nil, true)
		end			
	end
	g_i3k_ui_mgr:CloseUI(eUIID_StrengthenSelf)
end

function wnd_strengthen_self:initStrongNode(dropDownList)
	local nodes = dropDownList.m_root_node.m_children
	--对被点击按钮下的每个widget进行初始化
	for k,v in ipairs(nodes) do
		local view = v.view.vars
		local m_data = v.m_data
		if v.m_groupID ~= g_WANT_STRONG_DETAIL then
			view.name:setText(m_data.name)
			view.desc:setText(m_data.describe)
			view.goto_btn:onClick(self.second_dropDownList, self.onLeaveForButtonClick, v)
			view.btn_txt:setText(i3k_db_want_improve_btnNameEnum[m_data.fontType].btnName)
			view.img:setImage(g_i3k_db.i3k_db_get_icon_path(m_data.iconID))
			self:setSliderDesc(v)
    else
			view.openImg:setVisible(false)
			view.pickupImg:setVisible(true)
			view.img:setImage(g_i3k_db.i3k_db_get_icon_path(m_data.iconID))
    end 
    end
  end

function wnd_strengthen_self:initOtherNode(dropDownList)
	local nodes = dropDownList.m_root_node.m_children
	--对被点击按钮下的每个widget进行初始化
	for k,v in ipairs(nodes) do
		local view = v.view.vars
		local m_data = v.m_data
		view.name:setText(m_data.name)
		view.desc:setText(m_data.describe)
		view.goto_btn:onClick(self.second_dropDownList, self.onLeaveForButtonClick, v)
		view.btn_txt:setText(i3k_db_want_improve_btnNameEnum[m_data.btnFontType].btnName)
		view.img:setImage(g_i3k_db.i3k_db_get_icon_path(m_data.iconID))
		local recommendDegree = m_data.recommendDegree
		for i = 1,5 do
			if recommendDegree >= i then
				view["star" .. i]:setVisible(true)
			else
				view["star" .. i]:setVisible(false)
end
		end
  end 
  
end

function wnd_strengthen_self.onOpenChildItems(sender)
	local widget = sender.view
	if widget then
		widget.vars.openImg:setVisible(true)
		widget.vars.pickupImg:setVisible(false)
		--对被点击按钮下的每个widget进行赋值
		for k,v in ipairs(sender.m_children) do
			local view = v.view.vars
			local m_data = sender.m_children[k].m_data
			local recommend_mission = g_i3k_get_commend_mission()
			view.name:setText(m_data.name)
			view.desc:setText(m_data.describe)
			view.goto_btn:onClick(sender.m_children[k], wnd_strengthen_self.onLeaveForButtonClick, sender.m_children[k])
			view.btn_txt:setText(i3k_db_want_improve_btnNameEnum[m_data.fontType].btnName)
			view.img:setImage(g_i3k_db.i3k_db_get_icon_path(m_data.iconID))
			view.recommend:setVisible(false)
			if recommend_mission then
				for k2,v2 in ipairs(recommend_mission) do
					if m_data.id == v2 then
						view.recommend:setVisible(true)
      break
    end 
  end
end

			wnd_strengthen_self:setSliderDesc(v)
		end
        end  
      end 
function wnd_strengthen_self.onCloseChildItems(sender)
	if sender.m_groupID ~= -1 then
		local widget = sender.view.vars
		widget.openImg:setVisible(false)
		widget.pickupImg:setVisible(true)
  end
end

function wnd_strengthen_self:setSliderDesc(node)
	local percent, v1, v2 = g_i3k_game_context:GetWantImproveProgress(node.m_data.id)
	local widget = node.view.vars
	if percent then
		--测试用代码
		--widget.text1:show()   --测试用就打开这行，不用了就注释掉
		widget.text1:setText(v1.."/"..v2)
		widget.slider:setPercent(percent * 100)
		local info = g_i3k_db.i3k_db_get_StrengthenSelf_Slider_Info(percent * 100)
		if info then
			widget.sliderDesc:setText(info.judgeText)
			widget.sliderDesc:setTextColor(info.color)
			widget.slider:setImage(g_i3k_db.i3k_db_get_icon_path(info.iconID))
    
		end
	else
		widget.slider:setVisible(false)
		widget.sliderImg:setVisible(false)
		widget.sliderDesc:setVisible(false)
  end 
end

function wnd_create(layout,...)
	local wnd = wnd_strengthen_self.new();
		wnd:create(layout,...)
	return wnd;
end
