--------------------------------------------------------
-- 绝版限购
--------------------------------------------------------

OutOfPrintData = OutOfPrintData or BaseClass()

OutOfPrintData.INFO_CHANGE = "INFO_CHANGE"

function OutOfPrintData:__init()
	if OutOfPrintData.Instance then
		ErrorLog("[OutOfPrintData]:Attempt to create singleton twice!")
	end
	OutOfPrintData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.buy_tag = {}
	self.out_of_print = false --有购买的档位

	GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.OutOfPrint, BindTool.Bind(self.CondOutOfPrint, self))
end

function OutOfPrintData:__delete()
	OutOfPrintData.Instance = nil
end

----------设置----------

--设置购买标志
function OutOfPrintData:SetOutOfPrintInfo(protocol)
	local cfg = JueBanQiangGouConfig or {}
	local awards = cfg.JBQGAwards or {}
	-- 判断有没未购买的档位
	self.out_of_print = false
	local list = bit:d2b(protocol.buy_tag)
	for i = 1, #awards do
		self.buy_tag[i] = list[#list + 1 - i]
		if self.buy_tag[i] == 0 then
			self.out_of_print = true
		end
	end
	self:DispatchEvent(OutOfPrintData.INFO_CHANGE, self.buy_tag)

	GameCondMgr.Instance:CheckCondType(GameCondType.OutOfPrint)
end

function OutOfPrintData:CondOutOfPrint()
	return self.out_of_print
end

--获取是否开放
function OutOfPrintData:GetIsOpen()
	local v_open_cond = ViewDef.OutOfPrint.v_open_cond or "CondId137"
	return GameCondMgr.Instance:GetValue(v_open_cond)
end

function OutOfPrintData:IsShow()
	if self:GetIsOpen() then
		local cfg = JueBanQiangGouConfig or {}
		local awards = cfg.JBQGAwards or {}
		if self.data.buy_gear <= 0 then
			return true
		end
	end
end

--获取购买标志
function OutOfPrintData:GetOutOfPrintBuyTag()
	return self.buy_tag
end

function OutOfPrintData:GetCurPage()
	for k, v in pairs(self.buy_tag) do
		if v == 0 then
			return k 
		end
	end
	return 1
end

--------------------
