TipsFloatingManager = TipsFloatingManager or BaseClass()

local SPECIAL_LIMLIT_TIME = 10
local SPECIAL_LIMLIT_NUM = 20

function TipsFloatingManager:__init()
	if TipsFloatingManager.Instance ~= nil then
		error("[TipsFloatingManager] attempt to create singleton twice!")
		return
	end
	TipsFloatingManager.Instance = self
	self.floating_view = TipsFloatingView.New()
	self.next_time = 0.0
	self.list = {}
	Runner.Instance:AddRunObj(self, 3)
	self.play_audio = true

	self.show_length = 3
	self.float_count = 0
end

function TipsFloatingManager:__delete()
	self.list = {}
	self.next_time = nil  
	if self.floating_view then
		self.floating_view:DeleteMe()
		self.floating_view = nil
	end
	Runner.Instance:RemoveRunObj(self)

	self.float_count = 0
	if self.float_tip ~= nil then
		for k,v in pairs(self.float_tip) do
			if v ~= nil then
				if v.float ~= nil then
					v.float:DeleteMe()
				end

				if v.timer ~= nil then
					GlobalTimerQuest:CancelQuest(v.timer)
				end
			end
		end

		self.float_tip = nil
	end
end

function TipsFloatingManager:Update()
	if self.next_time > 0.0 then
		self.next_time = self.next_time - 0.2
	else
		self.next_time = 0.0
	end
	if #self.list > self.show_length then
		table.remove(self.list, 1)
	end
	if #self.list > 0 and self.next_time <= 0.0 then
		self.floating_view = TipsFloatingView.New()
		self.floating_view:Show(self.list[1].msg, self.list[1].pos_x or 200, self.list[1].pos_y or -250, self.list[1].show_spec_text or false, self.list[1].show_spec_img or false, self.list[1].spec_img_bundle, self.list[1].spec_img_asset)
		table.remove(self.list, 1)
		self.next_time = 4.0
	end
end

function TipsFloatingManager:ShowFloatingTips(msg, pos_x, pos_y, show_spec_text, show_spec_img, spec_img_bundle, spec_img_asset, show_length)
	self.show_length = show_length or 3
	if self.next_time > 0.0 then
		local msg_info = {
			msg = msg,
			pos_x = pos_x,
			pos_y = pos_y,
			show_spec_text = show_spec_text,
			show_spec_img = show_spec_img,
			spec_img_bundle = spec_img_bundle,
			spec_img_asset = spec_img_asset,
		}
		table.insert(self.list, msg_info)
	else
		self.floating_view = TipsFloatingView.New()
		self.floating_view:Show(msg, pos_x, pos_y, show_spec_text, show_spec_img, spec_img_bundle, spec_img_asset)
		self.pos_x = pos_x
		self.pos_y = pos_y
		self.show_spec_text = show_spec_text
		self.next_time = 4.0
	end
end

function TipsFloatingManager:ShowSpecialFloatTip(str)
	if str == nil then
		return
	end

	if self.float_tip == nil then
		self.float_tip = {}
	end

	table.insert(self.float_tip, str)
	if #self.float_tip == 1 and self.special_timer == nil then
		self:ShowFloat()
	end
end

function TipsFloatingManager:ShowFloat(str)
	if self.special_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.special_timer)
		self.special_timer = nil
	end

	if #self.float_tip > 0 then
		local str = table.remove(self.float_tip, 1)
		local special_float = TipsFloatingView.New()
		special_float:Show(str, nil, nil, nil, nil, nil, nil, nil, function()
			if special_float ~= nil then
				special_float:DeleteMe()
				special_float = nil
			end
		end)

		self.special_timer = GlobalTimerQuest:AddDelayTimer(
			BindTool.Bind(self.ShowFloat, self), 0.5)
	end
end
