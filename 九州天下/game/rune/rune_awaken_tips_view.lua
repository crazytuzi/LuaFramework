RuneAwakenTipsView = RuneAwakenTipsView or BaseClass(BaseView)
function RuneAwakenTipsView:__init()
	self.ui_config = {"uis/views/rune", "RuneAwakenTipsView"}
end

function RuneAwakenTipsView:__delete()
	-- body
end

function RuneAwakenTipsView:LoadCallBack()
	self.type_name = self:FindVariable("typename")		
	self.progress = self:FindVariable("progress")					
	self.describe = self:FindVariable("describe")
	self.pic = self:FindVariable("pic")
	self.txt_type = self:FindVariable("txttype")
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
end

-- 销毁前调用
function RuneAwakenTipsView:ReleaseCallBack()
	self.type_name = nil	
	self.progress = nil		
	self.describe  = nil
	self.txt_type = nil
	self.pic = nil
end

function RuneAwakenTipsView:OnClickClose()
	self:Close()
end
-- 打开后调用
function RuneAwakenTipsView:OpenCallBack()
	if self.open_callback then
		self.current_cell_index, self.awaken_type = self.open_callback()
		self.is_property = RuneData.Instance:GetIsPropertyByIndex(self.current_cell_index)
	end
	if 1 == self.is_property then
		self.pic:SetAsset(ResPath.GetRuneRes("awaken_icon_"..self.awaken_type..2))
	end
	if 0 == self.is_property then
		self.pic:SetAsset(ResPath.GetRuneRes("awaken_icon_"..self.awaken_type))
	end
	self.awaken_seq_index = RuneData.Instance:GetAwakenTypeIndex()		-- 获取当前点击的是哪个奖励
	self:Flush("content")
end

-- 关闭前调用
function RuneAwakenTipsView:CloseCallBack()
	if self.callback then
		self.callback()
	end
	self.asset_id = nil
end

function RuneAwakenTipsView:SetOpenCallBack(callback)
	self.open_callback = callback
end

function RuneAwakenTipsView:FlushContent(awaken_seq_index)
	--当前索引对应的表
	self.awaken_type_info = RuneData.Instance:GetAwakenTypeInfoByIndex(awaken_seq_index)
	--获取到的表中取到该奖励类型  如果为属性奖励 awaken_seq_index为当前奖励的type索引
	local awaken_type = self.awaken_type_info.awaken_type
	-- 奖励类型
	if 5 <= awaken_type then
		self.txt_type:SetValue(Language.Rune.AwakenReward)
		local str = string.format("<color=#00ff00>%d</color>", self.awaken_type_info.add_value)	
		self.progress:SetValue(str)
	-- 属性类型
	else
		-- 符文塔等级
		local layer = RuneData.Instance:GetPassLayer()
		local awaken_limit = RuneData.Instance:GetAwakenLimitByLevel(layer)
		local gongji_limit = awaken_limit.gongji_limit
		local fangyu_limit = awaken_limit.fangyu_limit
		local maxhp_limit = awaken_limit.maxhp_limit
		local addper_limit = awaken_limit.addper_limit

		local data_table = RuneData.Instance:GetAwakenAttrInfoByIndex(RuneData.Instance:GetCellIndex())
		if nil == data_table then
			return 
		end
		local curren_limit = 0
		local current_value = 0
		if 1 == awaken_type then
			--攻击
			curren_limit = awaken_limit.gongji_limit
			current_value = data_table.gongji
		end
		if 2 == awaken_type then
			--防御
			curren_limit = awaken_limit.fangyu_limit
			current_value = data_table.fangyu
		end
		if 3 == awaken_type then
			--血量
			curren_limit = awaken_limit.maxhp_limit
			current_value = data_table.maxhp
		end
		if 4 == awaken_type then
			--增幅
			curren_limit = awaken_limit.addper_limit
			current_value = data_table.add_per
		end
		local str = string.format("<color=#00ff00>%d</color><color=#6098cb>/%d</color>", current_value, curren_limit)	
		self.progress:SetValue(str)
		self.txt_type:SetValue(Language.Rune.AwakenRate)
	end

	self.type_name:SetValue(self.awaken_type_info.awaken_name)
	self.describe:SetValue(self.awaken_type_info.awaken_dec)
end

function RuneAwakenTipsView:SetCloseCallBack(callback)
	self.callback = callback
end

-- 刷新
function RuneAwakenTipsView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "content" then
			self:FlushContent(self.awaken_seq_index)
		end
	end
end
