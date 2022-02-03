--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-16 19:09:44
-- @description    : 
		-- 符文奖励领取
---------------------------------

ArtifactAwardWindow = ArtifactAwardWindow or BaseClass(BaseView)

local _controller = HeroController:getInstance()

function ArtifactAwardWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Mini  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.layout_name = "forgehouse/artifact_award_window"
end

function ArtifactAwardWindow:open_callback(  )
	local background_panel = self.root_wnd:getChildByName("background_panel")
	self.background = background_panel:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(main_panel, 2)
	local main_container  = main_panel:getChildByName("main_container")

	local title_container = main_panel:getChildByName("title_container")
	title_container:getChildByName("title_label"):setString(TI18N("熔炼奖励"))

	self.close_btn = main_panel:getChildByName("close_btn")
	self.ok_btn = main_panel:getChildByName("ok_btn")
	self.ok_btn_label = self.ok_btn:getChildByName("label")
	self.ok_btn_label:setString(TI18N("领取"))

	local content_label = main_container:getChildByName("content_label")

	local lucky_cfg = Config.PartnerArtifactData.data_artifact_const["change_condition"]
	local award_cfg = Config.PartnerArtifactData.data_artifact_const["change_gift"]
	if lucky_cfg and award_cfg and award_cfg.val and award_cfg.val[1] then
		local bid = award_cfg.val[1][1]
		local num = award_cfg.val[1][2]
		local item_config = Config.ItemData.data_get_data(bid)
		if item_config then
			self.award_item_bid = bid
			content_label:setString(string.format(TI18N("熔炼值达到%d点后可领取[%s]x%d"), lucky_cfg.val, item_config.name, num))
			if not self.award_item then
				self.award_item = BackPackItem.new(false, true, false, nil, true, false)
				self.award_item:addCallBack(handler(self, self._onClickItemCallBack))
				self.award_item:setBaseData(bid, num)
				self.award_item:setPosition(cc.p(290, 80))
				main_container:addChild(self.award_item)
			end
		end
	end
end

function ArtifactAwardWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.ok_btn, handler(self, self._onClickOkBtn), true)
end

function ArtifactAwardWindow:_onClickCloseBtn(  )
	_controller:openArtifactAwardWindow(false)
end

function ArtifactAwardWindow:_onClickOkBtn(  )
	_controller:sender11038()
	_controller:openArtifactAwardWindow(false)
end

function ArtifactAwardWindow:_onClickItemCallBack(  )
	if self.award_item_bid then
		_controller:openArtifactComTipsWindow(true, self.award_item_bid)
	end
end

-- 刷新领取按钮状态
function ArtifactAwardWindow:refreshBtnStatus(  )
	local cur_lucky = HeroController:getInstance():getModel():getArtifactLucky()
	local max_lucky = 0
	local lucky_cfg = Config.PartnerArtifactData.data_artifact_const["change_condition"]
	if lucky_cfg and lucky_cfg.val then
		max_lucky = lucky_cfg.val
	end
	if cur_lucky >= max_lucky then
		setChildUnEnabled(false, self.ok_btn)
    	self.ok_btn:setTouchEnabled(true)
	else
		setChildUnEnabled(true, self.ok_btn)
    	self.ok_btn:setTouchEnabled(false)
	    self.ok_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
	end
end

function ArtifactAwardWindow:openRootWnd(  )
	self:refreshBtnStatus()
end

function ArtifactAwardWindow:close_callback(  )
	_controller:openArtifactAwardWindow(false)
end