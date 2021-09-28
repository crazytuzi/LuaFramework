require("game/goddess/goddess_shouhu/goddess_shouhu_data")
GoddessShouhuCtrl = GoddessShouhuCtrl or BaseClass(BaseController)
function GoddessShouhuCtrl:__init()
	if GoddessShouhuCtrl.Instance then
		print_error("[GoddessShouhuCtrl] Attemp to create a singleton twice !")
	end
	GoddessShouhuCtrl.Instance = self
	self.data = GoddessShouhuData.New()

	self:RegisterAllProtocols()
end

function GoddessShouhuCtrl:__delete()
	self.data:DeleteMe()
	GoddessShouhuCtrl.Instance = nil
end

function GoddessShouhuCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCXiannvShouhuInfo, "SCXiannvShouhuInfo")
end

--仙女守护信息返回
function GoddessShouhuCtrl:SCXiannvShouhuInfo(protocol)
	self.data:SCXiannvShouhuInfo(protocol)
	-- local goddess_view = GoddessCtrl.Instance:GetView()
	-- if goddess_view:IsOpen() then
	-- 	goddess_view:SetRedPoint()
	-- end
	local shouhu_view = GoddessShouHuView.Instance
	if shouhu_view ~= nil then
		shouhu_view:FlushView()
	end
end

--请求使用形象
function GoddessShouhuCtrl:SendUseXiannvShouhuImage(image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseXiannvShouhuImage)
	send_protocol.reserve_sh = 0
	send_protocol.image_id = image_id
	send_protocol:EncodeAndSend()
end

--请求守护信息
function GoddessShouhuCtrl:SendXiannvShouhuGetInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvShouhuGetInfo)
	send_protocol:EncodeAndSend()
end

--升星级请求
function GoddessShouhuCtrl:SendXiannvShouhuUpStarLevel(stuff_index, is_auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvShouhuUpStarLevel)
	send_protocol.stuff_index = stuff_index
	send_protocol.is_auto_buy = is_auto_buy
	send_protocol:EncodeAndSend()
end

function GoddessShouhuCtrl:OnUppGradeOptResult(result)
	local shouhu_view = GoddessShouHuView.Instance
	if result == 1 then
		local item_num = ItemData.Instance:GetItemNumInBagById(shouhu_view:GetSelectItemId())
		if item_num > 0 then
			if shouhu_view:GetAutoJinJieState() then
				shouhu_view:AutoUpGradeOnce()
			end
		else
			shouhu_view:AutoJInjieFail()
			-- TipsCtrl.Instance:ShowSystemMsg("物品不足,无法继续进阶")
		end
	else
		shouhu_view:AutoJInjieFail()
	end
end
