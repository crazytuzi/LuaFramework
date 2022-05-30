--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-09-20 15:30:15
-- @description    : 
		-- 花火大会开启提示
---------------------------------
local _controller = PetardActionController:getInstance()
local _model = _controller:getModel()

PetardActionTips = PetardActionTips or BaseClass(BaseView)

function PetardActionTips:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "petard/petard_action_tips"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_petard_open"), type = ResourcesType.single },
	}
end

function PetardActionTips:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 1)

	self.petard_btn = main_container:getChildByName("petard_btn")
	self.petard_btn:getChildByName("label"):setString(TI18N("燃放烟花"))
	self.close_btn = main_container:getChildByName("close_btn")

	self.tips_txt = main_container:getChildByName("tips_txt")
	self.tips_txt:setString(TI18N("燃放烟花后将获得全服红包"))
end

function PetardActionTips:register_event(  )
	registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)

	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)

	registerButtonEventListener(self.petard_btn, handler(self, self.onClickPetardBtn), true)
end

function PetardActionTips:onClickPetardBtn(  )
	_controller:openSelectItemWindow(true)
	_controller:openPetardActionTips(false)
end

function PetardActionTips:onClickCloseBtn(  )
	_controller:openPetardActionTips(false)
end

function PetardActionTips:openRootWnd(  )
	_controller:sender27000() -- 这里请求一下花火大会基础数据，因为点击燃放烟花时，需要需要判断协议中的数据
end

function PetardActionTips:close_callback(  )
	_controller:openPetardActionTips(false)
end