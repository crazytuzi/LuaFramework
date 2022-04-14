ResFindCountPanel = ResFindCountPanel or class("ResFindCountPanel",WindowPanel)
local ResFindCountPanel = ResFindCountPanel

function ResFindCountPanel:ctor()
	self.abName = "daily"
	self.assetName = "ResFindCountPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 4								--窗体样式  1 1280*720  2 850*545
	self.model = DailyModel:GetInstance()
	self.cur_count = 0
	self.total_count = 0
end

function ResFindCountPanel:dctor()
end

--data:p_findback
function ResFindCountPanel:Open(data)
	self.data = data
	ResFindCountPanel.super.Open(self)
end

function ResFindCountPanel:LoadCallBack()
	self.nodes = {
		"bg/Slider/Handle Slide Area/Handle/num","bg/Slider","bg/price",
		"bg/addbtn", "bg/minusbtn","btnok","btncancel","bg/name",
	}
	self:GetChildren(self.nodes)
	self.num = GetText(self.num)
	self.price = GetText(self.price)
	self.name = GetText(self.name)
	self.Slider_com = GetSlider(self.Slider)
	self:AddEvent()

	self:SetTileTextImage("daily_image", "findback_sub_title")
end

function ResFindCountPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btncancel.gameObject,call_back)

	local function call_back(target,x,y)
		local gold_type = Constant.GoldType.BGold
		local message = string.format("Retrieve by spend %s bound diamond?", self.total_price)
		if self.model.findback_type == 1 then
			gold_type = Constant.GoldType.Coin
			message = string.format("Retrieve by spend %s gold?", self.total_price)
		end
		local function ok_func( ... )
			local bo = RoleInfoModel:GetInstance():CheckGold(self.total_price, gold_type)
		    if not bo then
		        return
		    end
		    DailyController:GetInstance():RequestRefindback(self.data.key, self.model.findback_type, self.cur_count)
		end
	    Dialog.ShowTwo("Tip", message, nil, ok_func)
		self:Close()
	end
	AddClickEvent(self.btnok.gameObject,call_back)

	local function call_back(target,x,y)
		local cur_count = self.cur_count + 1
		cur_count = (cur_count >= self.total_count and self.total_count or cur_count)
		self.Slider_com.value = cur_count
	end
	AddClickEvent(self.addbtn.gameObject,call_back)

	local function call_back(target,x,y)
		local cur_count = self.cur_count - 1
		cur_count = (cur_count <= 1 and 1 or cur_count)
		self.Slider_com.value = cur_count
	end
	AddClickEvent(self.minusbtn.gameObject,call_back)

	local function call_back(target, value)
		self.cur_count = value
		self:UpdatePrice()
	end
	AddValueChange(self.Slider.gameObject, call_back)
end

function ResFindCountPanel:OpenCallBack()
	self:UpdateView()
end

function ResFindCountPanel:UpdateView( )
	local findbackcfg = Config.db_findback[self.data.key]
	local count1, count2 = self.model:GetFindCount(self.data.key)
	local total_count = count1+count2
	self.total_count = total_count
	self.name.text = string.format("%s<color=#7C513E>(Available </color>%s<color=#7C513E>Times)</color>", findbackcfg.name, total_count)
	self.Slider_com.maxValue = total_count
	self.Slider_com.value = total_count
	self.cur_count = total_count
	self:UpdatePrice()
end

function ResFindCountPanel:CloseCallBack(  )

end

function ResFindCountPanel:UpdatePrice()
	local findbackcfg = Config.db_findback[self.data.key]
	local cost = String2Table(findbackcfg.cost)[self.model.findback_type]
	local item_id = cost[1]
	local num = cost[2]
	local name = Config.db_item[item_id].name
	local total_price = self.cur_count * num
	self.num.text = self.cur_count
	self.total_price = total_price
	self.price.text = string.format("Total Price: %s %s (Unit Price: %s %s)", total_price, name, num, name)
end
