---------------------------------------
-- 导航通用render
---------------------------------------
FUBNE_MAX_LINE = 7
FUBEN_BASE_H = math.floor((MainuiTask.Size.height - 62) / FUBNE_MAX_LINE) + 1

BaseTaskGuideRender = BaseTaskGuideRender or BaseClass(BaseRender)
function BaseTaskGuideRender:__init(w, h)
	w = w or MainuiTask.Size.width
	h = h or (MainuiTask.Size.height - 62)
	self.view:setContentWH(w, h)

	self.text = {}
	self.item_cell_list = {}
	self.countdown_list = {}
	self.btn_list = {}
	self.item_cfg_req_t = {}
	self.item_config_bind = BindTool.Bind(self.ItemConfigCallBack, self)
	self.on_cfg_listen = false
end

function BaseTaskGuideRender:__delete()	
	self.text = {}
	self.btn_list = {}

	if self.item_cell_list then
		for k,v in pairs(self.item_cell_list) do
			v.cell:DeleteMe()
		end
		self.item_cell_list = nil
	end

	for k,v in pairs(self.countdown_list) do
		-- if CountDownManager.Instance:HasCountDown(v) then
		-- 	CountDownManager.Instance:RemoveCountDown(v)
		-- end
	end

	if ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
	end
end

function BaseTaskGuideRender:CreateChild()
	BaseRender.CreateChild(self)

	local img_line = XUI.CreateImageView(MainuiTask.Size.width / 2, FUBEN_BASE_H, ResPath.GetMainui("task_line"), true)
	self.view:addChild(img_line, -1)

	img_line = XUI.CreateImageView(MainuiTask.Size.width / 2, FUBEN_BASE_H * 5, ResPath.GetMainui("task_line"), true)
	self.view:addChild(img_line, -1)
end

function BaseTaskGuideRender:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	self:ParseItemData()
	self:ParseText()
	self:ParseBtns()
end

function BaseTaskGuideRender:CreateSelectEffect()
end

function BaseTaskGuideRender:ParseText()
	for k, v in pairs(self.text) do
		v:setVisible(false)
	end

	for k, v in pairs(self.data.texts or {}) do
		self:CreateText(v)
	end
end

function BaseTaskGuideRender:CreateText(t)
	if t == nil or type(t) ~= "table" then return end

	local line = t.line or 1
	local x = t.x or 10
	local y = t.y or FUBEN_BASE_H * 0.5 + (line - 1) * FUBEN_BASE_H
	local w = t.w or MainuiTask.Size.width
	local h = t.h or FUBEN_BASE_H
	local font_size = t.font_size or 20
	local color = t.color or COLOR3B.WHITE

	if self.text[line] == nil then
		self.text[line] = XUI.CreateRichText(x, y, w, h, true)
		self.text[line]:setAnchorPoint(0, 0.5)
		self.text[line]:setHorizontalAlignment(RichHAlignment.HA_LEFT)
		self.text[line]:setVerticalAlignment(RichVAlignment.VA_CENTER)
		self.view:addChild(self.text[line])
	else
		self.text[line]:setVisible(true)
	end

	-- if CountDownManager.Instance:HasCountDown(self.countdown_list[line]) then
	-- 	CountDownManager.Instance:RemoveCountDown(self.countdown_list[line])
	-- end
	if t.timer then
		self.countdown_list[line] = "other_task_countdown_" .. line .. self:GetIndex()
		local time = t.timer > 1000000 and t.timer or (t.timer + TimeCtrl.Instance:GetServerTime())
		self:UpdateCallBack(line, 0, time - TimeCtrl.Instance:GetServerTime())
		if time > TimeCtrl.Instance:GetServerTime() then
			-- CountDownManager.Instance:AddCountDown(
			-- 	self.countdown_list[line],
			-- 	BindTool.Bind(self.UpdateCallBack, self, line),
			-- 	BindTool.Bind(self.CompleteCallBack, self, line),
			-- 	time, nil, 1)
		else
			self:CompleteCallBack(line)
		end
		return
	end

	RichTextUtil.ParseRichText(self.text[line], t.content or "", font_size, color, x, y, w, h)
end

function BaseTaskGuideRender:GetTextData(line)
	for k, v in pairs(self.data.texts or {}) do
		if v.line == line then
			return v
		end
	end
end

function BaseTaskGuideRender:UpdateCallBack(line, elapse_time, total_time)
	elapse_time = math.floor(elapse_time)
	total_time = math.floor(total_time)
	local text_data = self:GetTextData(line)
	if self.text[line] and text_data then
		local str = string.format(text_data.content, TimeUtil.FormatSecond(total_time - elapse_time, 3))
		RichTextUtil.ParseRichText(self.text[line], str)
	else
		-- CountDownManager.Instance:RemoveCountDown(self.countdown_list[line])
	end
end

function BaseTaskGuideRender:CompleteCallBack(line)
	local data = self:GetTextData(line)
	if self.text[line] and data then
		local str = string.format(data.content, TimeUtil.FormatSecond(0, 3))
		RichTextUtil.ParseRichText(self.text[line], str)
		if data.complete_func then
			data.complete_func()
		end
	end
end

function BaseTaskGuideRender:ParseItemData()
	for k, v in pairs(self.item_cell_list) do
		v.cell:SetVisible(false)
		if v.text then
			v.text:setVisible(false)
		end
	end

	if self.data == nil or next(self.data) == nil then
		return
	end

	for k, v in pairs(self.data.items or {}) do
		local is_bind = v.bind and v.bind or 0
		local item_id = ItemData.GetVirtualItemId(v.type) or v.id or 0

		if self.item_cell_list[k] == nil then
			self:CreateItemCell(k, v)
		else
			self.item_cell_list[k].cell:SetVisible(true)
			if self.item_cell_list[k].text then
				self.item_cell_list[k].text:setVisible(true)
			end
		end
		local item_data = TableCopy(v)
		item_data.item_id = item_id
		item_data.is_bind = is_bind
		item_data.num = v.count or 0
		self.item_cell_list[k].cell:SetData(item_data)

		local item_config = ItemData.Instance:GetItemConfig(item_id)
		
		if nil == item_config then
			self.item_cfg_req_t[item_id] = 1
			if self.on_cfg_listen == false then
				ItemData.Instance:NotifyItemConfigCallBack(self.item_config_bind)
				self.on_cfg_listen = true
			end
		else
			v.item_config = item_config
			self:SetItemDescText(self.item_cell_list[k].text, v)
			self.item_cfg_req_t[item_id] = nil
		end
	end
end

function BaseTaskGuideRender:SetItemDescText(text_node, data)
	if nil == text_node or data.no_text then return end

	local content = "{wordcolor;" .. string.sub(string.format("%06x", data.item_config.color), 1, 6) ..  ";" .. data.item_config.name .. "x" .. data.count .. "}"
	if data.item_desc_format then
		content = string.format(data.item_desc_format, content)
	end
	RichTextUtil.ParseRichText(text_node, content, data.front_size or 20)
end

function BaseTaskGuideRender:CreateItemCell(line, data)
	if self.item_cell_list[line] then return end

	local offset_x = data.offset_x or 0
	local x, y = data.x or (FUBEN_BASE_H + 5 + offset_x), data.y or (FUBEN_BASE_H * (6 - 2 * line))
	local cell_szie = FUBEN_BASE_H * 2 - 12
	local item_cell = BaseCell.New()
	item_cell:SetPosition(x, y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:GetCell():setScale(cell_szie / BaseCell.SIZE)
	item_cell:SetIsShowTips(true)
	self.view:addChild(item_cell:GetCell())

	local text = XUI.CreateRichText(x + cell_szie * 0.5 + 5, y, 200, 24, true)
	text:setAnchorPoint(0, 0.5)
	text:setHorizontalAlignment(RichHAlignment.HA_LEFT)
	text:setVerticalAlignment(RichVAlignment.VA_CENTER)
	self.view:addChild(text)

	self.item_cell_list[line] = {
		cell = item_cell,
		text = text
	}
end

function BaseTaskGuideRender:ItemConfigCallBack(item_config_t)
	self:ParseItemData()
	self:FlushListener()
end

function BaseTaskGuideRender:FlushListener()
	if next(self.item_cfg_req_t) == nil then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
		self.on_cfg_listen = false
	end
end

function BaseTaskGuideRender:ParseBtns()
	for k, v in pairs(self.btn_list) do
		v:setVisible(false)
	end

	for k, v in pairs(self.data.btns or {}) do
		if self.btn_list[k] == nil then
			local path = v.path or ResPath.GetCommon("btn_123")
			local x = v.x or MainuiTask.Size.width * 0.5
			local y = v.y or 20
			local btn = XUI.CreateButton(x, y, 0, 0, false, path, path)
			btn:setTitleText(v.title or "")
			btn:setTitleFontSize(v.font_size or 20)
			btn:setTitleFontName(COMMON_CONSTS.FONT)
			btn:setTitleColor(COLOR3B.WHITE)
			btn:setScale(v.scale or 1)
			if v.event then
				XUI.AddClickEventListener(btn, BindTool.Bind(v.event, btn), true)
			end
			-- if v.effect then
			-- 	v.effect.node = btn
			-- 	self:CreateBtnEffect(v.effect)
			-- end
			self.view:addChild(btn, 99)
			self.btn_list[k] = btn
		end
		if v.effect then
			v.effect.node = self.btn_list[k]
			self:CreateBtnEffect(v.effect)
		end
		self.btn_list[k]:setVisible(true)
	end
end

function BaseTaskGuideRender:CreateBtnEffect(effect)
	UiInstanceMgr.AddRectEffect(effect)
end

---------------------------------------
-- 任务导航Bottom render
---------------------------------------
TaskBottomRender = TaskBottomRender or BaseClass(BaseTaskGuideRender)
function TaskBottomRender:CreateChild()
	BaseRender.CreateChild(self)
end

---------------------------------------
-- 活动-巨魔之巢render
---------------------------------------
ActJuMoRender = ActJuMoRender or BaseClass(BaseTaskGuideRender)
function ActJuMoRender:SetItemDescText(text_node, data)
	local content = "{wordcolor;" .. string.sub(string.format("%06x", data.item_config.color), 1, 6) ..  ";" .. data.item_config.name .. "}"
	RichTextUtil.ParseRichText(text_node, content, data.front_size or 20)
end

---------------------------------------
-- 活动-武林争霸render
---------------------------------------
ActWLZBRender = ActWLZBRender or BaseClass(BaseTaskGuideRender)
function ActWLZBRender:__init()
	self.item_text = {}
end

function ActWLZBRender:OnFlush()
	BaseTaskGuideRender.OnFlush(self)

	self:ParseItemText()
end

function ActWLZBRender:ParseItemText()
	for k, v in pairs(self.item_text) do
		v:setVisible(false)
	end

	for k, v in pairs(self.data.item_texts or {}) do
		self:CreateItemText(v)
	end
end

function ActWLZBRender:CreateItemText(t)
	if t == nil or type(t) ~= "table" then return end

	local line = t.line or 1
	local x = t.x or 10
	local y = t.y or FUBEN_BASE_H * 0.5 + (line - 1) * FUBEN_BASE_H
	local w = t.w or MainuiTask.Size.width
	local h = t.h or FUBEN_BASE_H
	local font_size = t.font_size or 20
	local color = t.color or COLOR3B.WHITE

	if self.item_text[line] == nil then
		self.item_text[line] = XUI.CreateRichText(x, y, w, h, true)
		self.item_text[line]:setAnchorPoint(0, 0.5)
		self.item_text[line]:setHorizontalAlignment(RichHAlignment.HA_LEFT)
		self.item_text[line]:setVerticalAlignment(RichVAlignment.VA_CENTER)
		self.view:addChild(self.item_text[line])
	else
		self.item_text[line]:setVisible(true)
	end

	local content = ""
	local item_id = t.item_data.id or 0
	local item_config = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_config then
		self.item_cfg_req_t[item_id] = 1
		if self.on_cfg_listen == false then
			ItemData.Instance:NotifyItemConfigCallBack(self.item_config_bind)
			self.on_cfg_listen = true
		end
	else
		self.item_cfg_req_t[item_id] = nil
		t.item_cfg = item_config
		content = self:CreateContent(t)
	end

	RichTextUtil.ParseRichText(self.item_text[line], content or "", font_size, color, x, y, w, h)
end

function ActWLZBRender:CreateContent(t)
	return "{wordcolor;" .. string.sub(string.format("%06x", t.item_cfg.color), 1, 6) ..  ";" .. t.item_cfg.name .. " x " .. t.item_data.count .. "}"
end

function ActWLZBRender:ItemConfigCallBack(item_config_t)
	self:ParseItemData()
	self:ParseItemText()

	self:FlushListener()
end

---------------------------------------
-- 活动-王城危机render
---------------------------------------
ActWCWJRender = ActWCWJRender or BaseClass(ActWLZBRender)
function ActWCWJRender:CreateContent(t)
	return "{wordcolor;" .. string.sub(string.format("%06x", t.item_cfg.color), 1, 6) ..  ";" .. t.item_cfg.name .. "}"
end

---------------------------------------
-- 活动-攻城战render
---------------------------------------
ActGCZRender = ActGCZRender or BaseClass(BaseTaskGuideRender)

-- function ActGCZRender:CreateChild()
-- 	BaseTaskGuideRender.CreateChild(self)
-- 	self.out_time_color_lines = {}
-- end

function ActGCZRender:ParseText()
	for k, v in pairs(self.text) do
		v:setVisible(false)
	end

	self.out_time_color_lines = {}
	for k, v in pairs(self.data.texts or {}) do
		self:CreateText(v)
	end
end

function ActGCZRender:CreateText(t)
	if t == nil or type(t) ~= "table" then return end

	local line = t.line or 1
	local x = t.x or 10
	local y = t.y or FUBEN_BASE_H * 0.5 + (line - 1) * FUBEN_BASE_H
	local w = t.w or MainuiTask.Size.width
	local h = t.h or FUBEN_BASE_H
	local font_size = t.font_size or 20
	local color = t.color or COLOR3B.WHITE

	if self.text[line] == nil then
		self.text[line] = XUI.CreateRichText(x, y, w, h, true)
		self.text[line]:setAnchorPoint(0, 0.5)
		self.text[line]:setHorizontalAlignment(RichHAlignment.HA_LEFT)
		self.text[line]:setVerticalAlignment(RichVAlignment.VA_CENTER)
		self.view:addChild(self.text[line])
	else
		self.text[line]:setVisible(true)
	end

	if t.time_colors then
		self.out_time_color_lines[line] = {}
		self.out_time_color_lines[line][1] = t.time_colors[1]
		self.out_time_color_lines[line][2] = t.time_colors[2]
	end

	-- if CountDownManager.Instance:HasCountDown(self.countdown_list[line]) then
	-- 	CountDownManager.Instance:RemoveCountDown(self.countdown_list[line])
	-- end
	if t.timer then
		self.countdown_list[line] = "other_task_countdown_" .. line .. self:GetIndex()
		local time = t.timer > 1000000 and t.timer or (t.timer + TimeCtrl.Instance:GetServerTime())
		self:UpdateCallBack(line, 0, time - TimeCtrl.Instance:GetServerTime())
		if time > TimeCtrl.Instance:GetServerTime() then
			-- CountDownManager.Instance:AddCountDown(
			-- 	self.countdown_list[line],
			-- 	BindTool.Bind(self.UpdateCallBack, self, line),
			-- 	BindTool.Bind(self.CompleteCallBack, self, line),
			-- 	time, nil, 1)
		else
			self:CompleteCallBack(line)
		end

		return
	end

	RichTextUtil.ParseRichText(self.text[line], t.content or "", font_size, color, x, y, w, h)
end

function ActGCZRender:UpdateCallBack(line, elapse_time, total_time)
	elapse_time = math.floor(elapse_time)
	total_time = math.floor(total_time)
	local text_data = self:GetTextData(line)
	if self.text[line] and text_data then
		local str = ""
		if self.out_time_color_lines[line] then
			str = string.format(text_data.content, self.out_time_color_lines[line][1] or "ff2828", TimeUtil.FormatSecond(total_time - elapse_time, 3))
		else
			str = string.format(text_data.content, TimeUtil.FormatSecond(total_time - elapse_time, 3))
		end
		RichTextUtil.ParseRichText(self.text[line], str)
	else
		-- CountDownManager.Instance:RemoveCountDown(self.countdown_list[line])
	end
end

function ActGCZRender:CompleteCallBack(line)
	local data = self:GetTextData(line)
	if self.text[line] and data then
		local str = ""
		if self.out_time_color_lines[line] then
			str = string.format(data.content, self.out_time_color_lines[line][2] or "ffffff", TimeUtil.FormatSecond(0, 3))
		else
			str = string.format(data.content, TimeUtil.FormatSecond(0, 3))
		end
		RichTextUtil.ParseRichText(self.text[line], str)
		if data.complete_func then
			data.complete_func()
		end
	end
end

---------------------------------------
-- 活动-召唤boss令render
---------------------------------------
CallBossRender = CallBossRender or BaseClass(BaseTaskGuideRender)
CallBossRender.BOSS_AWARD_NUM = 0

function CallBossRender:CreateChild()
	BaseRender.CreateChild(self)

	local img_line = XUI.CreateImageView(MainuiTask.Size.width / 2, FUBEN_BASE_H, ResPath.GetMainui("task_line"), true)
	self.view:addChild(img_line, -1)

	img_line = XUI.CreateImageView(MainuiTask.Size.width / 2, FUBEN_BASE_H * 5, ResPath.GetMainui("task_line"), true)
	self.view:addChild(img_line, -1)
end

function CallBossRender:CreateItemCell(line, data)
	if self.item_cell_list[line] then return end

	self.BOSS_AWARD_NUM = self.BOSS_AWARD_NUM + 1

	local x, y = self.BOSS_AWARD_NUM * 60 - 25, 140
	if self.BOSS_AWARD_NUM > 4 then
		x = (self.BOSS_AWARD_NUM - 4) * 60 - 25
		y = 70
	end

	local cell_szie = FUBEN_BASE_H * 2 - 20
	local item_cell = BaseCell.New()
	item_cell:SetPosition(x, y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:GetCell():setScale(cell_szie / BaseCell.SIZE)
	item_cell:SetIsShowTips(true)
	self.view:addChild(item_cell:GetCell())

	self.item_cell_list[line] = {
		cell = item_cell,
	}
end

function CallBossRender:ParseItemData()
	for k, v in pairs(self.item_cell_list) do
		v.cell:SetVisible(false)
	end

	if self.data == nil or next(self.data) == nil then
		return
	end

	for k, v in pairs(self.data.items or {}) do
		if k > 8 then return end
		local is_bind = v.bind and v.bind or 0
		local item_id = ItemData.GetVirtualItemId(v.type) or v.id or 0

		if self.item_cell_list[k] == nil then
			self:CreateItemCell(k, v)
		else
			self.item_cell_list[k].cell:SetVisible(true)
		end
		local item_data = TableCopy(v)
		item_data.item_id = item_id
		item_data.is_bind = is_bind
		item_data.num = 0
		self.item_cell_list[k].cell:SetData(item_data)

		local item_config = ItemData.Instance:GetItemConfig(item_id)
		
		if nil == item_config then
			self.item_cfg_req_t[item_id] = 1
			if self.on_cfg_listen == false then
				ItemData.Instance:NotifyItemConfigCallBack(self.item_config_bind)
				self.on_cfg_listen = true
			end
		else
			v.item_config = item_config
			self:SetItemDescText(self.item_cell_list[k].text, v)
			self.item_cfg_req_t[item_id] = nil
		end
	end
end

function CallBossRender:UpdateCallBack(line, elapse_time, total_time)
	elapse_time = math.floor(elapse_time)
	total_time = math.floor(total_time)

	--自动退出
	if 1 >= total_time - elapse_time then
		FubenCtrl.OutFubenReq(FubenData.Instance:GetFubenId()) 
	end
	
	local text_data = self:GetTextData(line)
	if self.text[line] and text_data then
		local str = string.format(text_data.content, TimeUtil.FormatSecond(total_time - elapse_time, 3))
		RichTextUtil.ParseRichText(self.text[line], str)
	else
		-- CountDownManager.Instance:RemoveCountDown(self.countdown_list[line])
	end
end
-- 魔界秘境
MJMJGuideBottomRender = BaseClass(TaskBottomRender)
function MJMJGuideBottomRender:OnFlush()
	TaskBottomRender.OnFlush(self)

	if nil ~= self.btn_list["buy_integral"] then
		self.btn_list["buy_integral"]:setEnabled(BossData.Instance:GetBuyFamIntegralCount() > 0)
	end
end

---------------------------------------
-- 神界废墟render 增加切换场景后任务栏变化
---------------------------------------
FeixuBossRender = FeixuBossRender or BaseClass(CallBossRender)

function FeixuBossRender:__init()
	self.eh_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, function ()
		if not BossData.Instance:IsFeixuScene() and not BossData.Instance:IsMojieScene() then
			GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE)
			GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, MainuiTask.SHOW_TYPE.LEFT)
		end
	end)
end

function FeixuBossRender:__delete()
	GlobalEventSystem:UnBind(self.eh_load_quit)
end

----------------------镖车render--------------------
HuSongRender = HuSongRender or BaseClass(BaseTaskGuideRender)

function HuSongRender:CreateItemCell(line, data)
	if self.item_cell_list[line] then return end

	local offset_x = data.offset_x or 0
	local x, y = FUBEN_BASE_H + 5 + offset_x, FUBEN_BASE_H * 2
	local cell_szie = FUBEN_BASE_H * 2 - 12
	local item_cell = BaseCell.New()
	item_cell:SetPosition(x, y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:GetCell():setScale(cell_szie / BaseCell.SIZE)
	item_cell:SetIsShowTips(true)
	self.view:addChild(item_cell:GetCell(), 100)


	self.item_cell_list[line] = {
		cell = item_cell,
	}
end

function HuSongRender:OnFlush()
	BaseTaskGuideRender.OnFlush(self)

	if nil == self.txt_get_stuff then
		self.txt_get_stuff = RichTextUtil.CreateLinkText(Language.Activity.GiveUpCar, 20, COLOR3B.RED)
		self.txt_get_stuff:setPosition(FUBEN_BASE_H + 30, FUBEN_BASE_H * 6 + 10)
		self.view:addChild(self.txt_get_stuff, 20)

		XUI.AddClickEventListener(self.txt_get_stuff, BindTool.Bind(self.OnClickGiveUpHuSong, self), true)
	end

	if nil == self.hp_bar then
		self.hp_bar = XLoadingBar:create()
		self.hp_bar:setPosition(FUBEN_BASE_H * 2 + 35, FUBEN_BASE_H * 6 - 20)
		self.hp_bar:loadTexture(ResPath.GetCommon("prog_hp"), true)
		self.hp_bar:loadBgTexture(ResPath.GetCommon("prog_bg"), true)
		self.view:addChild(self.hp_bar, 10)
		self.hp_bar:setScaleX(0.8)
		self.hp_bar:setPercent(100)

		self.hp_text = XUI.CreateText(FUBEN_BASE_H * 2 + 35, FUBEN_BASE_H * 6 - 20, 0, 0, nil, "")
		self.view:addChild(self.hp_text, 10)
	end

	self.hp_bar:setPercent((self.data.left_hp / self.data.max_hp) * 100)
	self.hp_text:setString(self.data.left_hp .. "/" .. self.data.max_hp)
end

function HuSongRender:FlushCarHp(cur_hp)
	if nil ~= self.hp_bar then
		self.hp_bar:setPercent((cur_hp / self.data.max_hp) * 100)
	end
	if nil ~= self.hp_text then
		self.hp_text:setString(cur_hp .. "/" .. self.data.max_hp)
	end
end

function HuSongRender:OnClickGiveUpHuSong()
	self.fuben_alert = self.fuben_alert or Alert.New()
	self.fuben_alert:SetLableString(Language.Activity.GiveUpCarAlert)
	self.fuben_alert:SetOkFunc(function()
		ActivityCtrl.SentQuitEscortReq()
	end)
	self.fuben_alert:SetCancelString(Language.Common.Cancel)
	self.fuben_alert:SetOkString(Language.Common.Confirm)
	self.fuben_alert:SetShowCheckBox(false)
	self.fuben_alert:Open()
end

-- 多人副本
FubenMutilRender = FubenMutilRender or BaseClass(BaseTaskGuideRender)
function FubenMutilRender:CreateChild()
	BaseTaskGuideRender.CreateChild(self)

	self.lbl_cur_floor = XUI.CreateText(MainuiTask.Size.width / 2, FUBEN_BASE_H * 4 - 15, MainuiTask.Size.width - 20, 20)
	self.lbl_cur_floor:setAnchorPoint(0.5, 0.5)
	self.lbl_cur_floor:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.view:addChild(self.lbl_cur_floor)

	self.lbl_team_menber = XUI.CreateText(75, FUBEN_BASE_H * 5 - 15)
	self.view:addChild(self.lbl_team_menber)

	self.lbl_turns_cutdown = XUI.CreateText(MainuiTask.Size.width / 2 - 10, FUBEN_BASE_H * 7 - 20)
	self.view:addChild(self.lbl_turns_cutdown)

	self.progress = XUI.CreateLoadingBar(MainuiTask.Size.width / 2 - 15, FUBEN_BASE_H * 6 - 15, ResPath.GetCommon("prog_hp"),true,ResPath.GetCommon("prog_bg"))
	self.progress:setPercent(100)
	self.progress:setScaleX(0.8)
	self.view:addChild(self.progress)
	self.lbl_progress = XUI.CreateText(MainuiTask.Size.width / 2 - 15, FUBEN_BASE_H * 6 - 17)
	self.view:addChild(self.lbl_progress)

	self.lbl_left_times = XUI.CreateText(MainuiTask.Size.width / 2, FUBEN_BASE_H - 15)
	self.view:addChild(self.lbl_left_times)
end

function FubenMutilRender:CreateItemCell(line, data)
	if self.item_cell_list[line] then return end

	local cell = BaseCell.New()
	cell:SetAnchorPoint(0, 0.5)
	cell:GetView():setScale(0.9)
	cell:SetPosition( (BaseCell.SIZE + 5) * (line - 1) + 10, FUBEN_BASE_H * 2.2)
	cell:SetData({item_id = data.id, num = data.count, is_bind = data.bind})
	self.view:addChild(cell:GetView())

	self.item_cell_list[line] = {cell = cell}
end

function FubenMutilRender:OnFlush()
	BaseTaskGuideRender.OnFlush(self)

	self.lbl_cur_floor:setString(self.data.fuben_id == FubenMutilId.Team and Language.FubenMutil.TaskGuideText[2] or Language.FubenMutil.TaskGuideText[1])
	if self.data.team_info then
		self.lbl_team_menber:setString(string.format(Language.FubenMutil.OnlineTeamate, self.data.team_info.menber_count, self.data.team_info.max_men_count))
	end

	if self.data.fuben_id == FubenMutilId.Team then
		self.lbl_progress:setString(string.format("%s/%s", self.data.cur_kill_num, self.data.max_kill_num))
	elseif self.data.fuben_id == FubenMutilId.Team_2 then
		self.lbl_progress:setString(string.format(Language.FubenMutil.KillBossNumText, self.data.cur_kill_num, self.data.max_kill_num))
	end

	self.progress:setVisible(self.data.fuben_id == FubenMutilId.Team)
	self.progress:setPercent(math.ceil(self.data.cur_kill_num * 100 / self.data.max_kill_num))

	self.lbl_turns_cutdown:setVisible(self.data.fuben_id == FubenMutilId.Team)

	if self.data.turns_time then
		self.lbl_turns_cutdown:setString(TimeUtil.FormatSecond2HMS(self.data.turns_time))
		self.lbl_turns_cutdown:setColor(self.data.turns_time <= 10 and COLOR3B.RED or COLOR3B.GREEN)
	end

	self.lbl_left_times:setString(Language.FubenMutil.LeftTimes .. TimeUtil.FormatSecond2HMS(self.data.total_time))
	self.lbl_left_times:setColor(self.data.total_time <= 10 and COLOR3B.RED or COLOR3B.GREEN)
end


