
-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
-- [文件功能：战斗中的buff的tips部分]
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

BattleBuffTips = BattleBuffTips or BaseClass()
function BattleBuffTips:__init(delay)
	self.delay = delay or 3
	self.WIDTH = 380  --界面的宽度
	self.HEIGHT = 250
	self.SPACE_H = 10    --上下顶端的偏移量
	self.title_space = 22 --标题偏移量
	self.space_x = 30 --偏移量
	self:createRootWnd()
end
function BattleBuffTips:createRootWnd()
	self:LoadLayoutFinish()
	self:registerCallBack()
end
function BattleBuffTips:LoadLayoutFinish()
	self.screen_bg = ccui.Layout:create()
	self.screen_bg:setAnchorPoint(cc.p(0, 0))
	self.screen_bg:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
	self.screen_bg:setTouchEnabled(true)
	self.screen_bg:setSwallowTouches(false)
	self.root_wnd = ccui.Widget:create()
	self.root_wnd:setTouchEnabled(true)
	self.root_wnd:setAnchorPoint(cc.p(0, 0))
	self.root_wnd:setPosition(cc.p(0, 0))
	self.screen_bg:addChild(self.root_wnd)
	self.background = createScale9Sprite(PathTool.getResFrame("common", "common_90005"), 0, 0)
	self.background:setContentSize(self.WIDTH,77)
	self.background:setPositionX(self.WIDTH / 2)
    self.background:setCapInsets(cc.rect(24, 29, 27, 18))
	self.root_wnd:addChild(self.background)
end
function BattleBuffTips:registerCallBack()
	self.screen_bg:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.began then
			TipsManager:getInstance():hideTips()
		end
	end)
end
function BattleBuffTips:setPosition(x, y)
	self.root_wnd:setAnchorPoint(cc.p(0, 1))
	self.root_wnd:setPosition(cc.p(x, y))
end
function BattleBuffTips:setPos(x, y)
	self.root_wnd:setPosition(cc.p(x, y))
end
function BattleBuffTips:getContentSize()
	return self.root_wnd:getContentSize()
end
function BattleBuffTips:getScreenBg()
	return self.screen_bg
end
--设置数据部分
function BattleBuffTips:showTipsByVo(vo)
	local name = vo.name
	local cur_round = vo.cur_round
	local buff_icon = vo.buff_icon
	local buff_list = vo.buff_list
	local buff_num = 0
	for key, v in pairs(buff_icon) do
		buff_num = buff_num + 1
	end
	-- --tips部分
	self.HEIGHT = 0   --总高度 (scrollView部分)
	self._height = 0  --显示高度 (scrollView部分)
	local buff_height = self.SPACE_H --整个buff的高度
	-- --创建scroll_view部分
	self.scroll_view = createScrollView(self.WIDTH -30, self._height, 20, buff_height + 30, self.root_wnd)
	local index = 0
	--for key, v in pairs(buff_icon) do
		--index = index + 1
		local _height = self:createSingleTips(key, v, buff_list, cur_round)
		-- if index < buff_num then
		-- 	_height = _height + 5
		-- end
		-- if index > buff_num - 2 then
			self._height = self._height + _height
		--end
		self.HEIGHT = self.HEIGHT + _height
	--end
	buff_height = buff_height + 15 + self._height
	if self._height > 0 then
		--下划线
		local line = createScale9Sprite(PathTool.getResFrame("common", "common_1016"), self.WIDTH / 2, buff_height + 25)
		line:setContentSize(cc.size(self.WIDTH - 30, 1))
		line:setAnchorPoint(0.5, 1)
		self.root_wnd:addChild(line)
		--标题部分
		buff_height = buff_height + 10
	end
	local content = "<div fontcolor=#14b4f0>    {0}  </div>"
	local str = StringFormat(content, name)
	-- --创建下富文本
	local richLabel = createRichLabel(22, 10, cc.p(0.5, 0), cc.p(self.WIDTH/2 - 15, buff_height + 25), nil, nil, self.WIDTH - 20)
	richLabel:setString(str)
	self.root_wnd:addChild(richLabel)
	buff_height = buff_height + richLabel:getContentSize().height
	-- --创建下富文本
	local base_data 
	if vo.data_vo.object_type == 2 then --伙伴
		base_data = Config.PartnerData.data_partner_base[vo.data_vo.object_bid]
	elseif vo.data_vo.object_type == 3 then --怪物
		base_data = Config.UnitData.data_unit(vo.data_vo.object_bid)
	end
	local desc_list = {
		  ["5"] =  TI18N("物")
		, ["4"] =  TI18N("法")
		, ["1"] =  TI18N("辅")
		, ["3"] =  TI18N("体")
		, ["2"] =  TI18N("防")
	}
	if base_data ~= nil then
		local partial = base_data.partial
		local lev_str = "Lv."..	vo.lev..desc_list[partial]
		local label_Label = createRichLabel(18, 39, cc.p(1, 0), cc.p(self.WIDTH - 20, 15), nil, nil, self.WIDTH - self.title_space)
		label_Label:setString(lev_str)
		self.root_wnd:addChild(label_Label)
		buff_height = buff_height + label_Label:getContentSize().height
	end
	--调整部分
	self:adjustPos(buff_height)
end
function BattleBuffTips:adjustPos(buff_height)
	self.root_wnd:setContentSize(cc.size(self.WIDTH, buff_height + self.SPACE_H))
	local background_width = buff_height + self.SPACE_H
	if background_width <= 77 then
		background_width = 77
	end
	self.background:setContentSize(cc.size(self.WIDTH, background_width))
	self.background:setPositionY((buff_height + self.SPACE_H) / 2)
	self.scroll_view:setContentSize(cc.size(self.WIDTH - 30, self._height))
	self.scroll_view:setInnerContainerSize(cc.size(self.WIDTH, self.HEIGHT))
end
--创建下单个buff部分
function BattleBuffTips:createSingleTips(key, v, buff_list, cur_round)
	local _height = 0
	local tips_container = ccui.Widget:create()
	tips_container:setAnchorPoint(cc.p(0, 0))
	tips_container:setContentSize(cc.size(self.WIDTH, _height))
	tips_container:setPosition(cc.p(0, self.HEIGHT))
	self.scroll_view:addChild(tips_container, 2222)
	--解析下文本
	local str = ""
	local buff_desc = ""
	local round = ""
	local str_list = {}
	for i, v in pairs(buff_list) do
			if Config.SkillData.data_get_buff[v.bid] and Config.SkillData.data_get_buff[v.bid].desc ~= "" then
				if not str_list[i] then
					local str_ = string.format("<div><img src='%s'/></div><div fontcolor=#64e678 fontsize=18> %s </div>%s\n", PathTool.getBuffRes(Config.SkillData.data_get_buff[v.bid].icon),Config.SkillData.data_get_buff[v.bid].name..":",Config.SkillData.data_get_buff[v.bid].desc)
					str = str..str_
				end

			end
	end
	local richLabel = createRichLabel(18, 4, cc.p(0, 0), cc.p(0, _height), 5, nil, self.WIDTH - self.space_x)
	richLabel:setString(str)
	tips_container:addChild(richLabel)
	_height = richLabel:getSize().height
	return _height
end
function BattleBuffTips:open()
	local parent = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
	parent:addChild(self.screen_bg)
	doStopAllActions(self.screen_bg)
	delayRun(self.screen_bg, self.delay, function()
		TipsManager:getInstance():hideTips()
	end)
end
function BattleBuffTips:close()
	doStopAllActions(self.screen_bg)
	self.screen_bg:removeFromParent()
end