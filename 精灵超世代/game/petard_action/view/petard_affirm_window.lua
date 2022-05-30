--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-09-20 10:15:43
-- @description    : 
		-- 花火大会放烟花确认框
---------------------------------
local _controller = PetardActionController:getInstance()
local _model = _controller:getModel()

PetardAffirmWindow = PetardAffirmWindow or BaseClass(BaseView)

function PetardAffirmWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "petard/petard_affirm_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("actionpetard", "actionpetard"), type = ResourcesType.plist},
	}
end

function PetardAffirmWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 2)

	self.affirm_btn = main_container:getChildByName("affirm_btn")
	self.affirm_btn:getChildByName("label"):setString(TI18N("确定"))
	self.cancel_btn = main_container:getChildByName("cancel_btn")
	self.cancel_btn:getChildByName("label"):setString(TI18N("取消"))

	main_container:getChildByName("win_title"):setString(TI18N("提示"))
	main_container:getChildByName("tips_txt"):setString(TI18N("即将返回主城燃放庆典烟花，是否继续？燃放烟花后，您将获得一个红包。"))
end

function PetardAffirmWindow:register_event(  )
	registerButtonEventListener(self.affirm_btn, handler(self, self.onClickAffirmBtn), true)

	registerButtonEventListener(self.cancel_btn, handler(self, self.onClickCancelBtn), true, 2)
end

function PetardAffirmWindow:onClickAffirmBtn(  )
	if self.item_bid and self.item_num then
		PetardActionController:getInstance():sender27001(self.item_bid, self.item_num)
	end
end

function PetardAffirmWindow:onClickCancelBtn(  )
	_controller:openAffirmWindow(false)
end

function PetardAffirmWindow:openRootWnd( item_bid, item_num )
	self.item_bid = item_bid
	self.item_num = item_num
end

function PetardAffirmWindow:close_callback(  )
	_controller:openAffirmWindow(false)
end