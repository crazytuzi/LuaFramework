--
-- @Author: chk
-- @Date:   2019-01-15 16:38:12
--

GoodsTipController = GoodsTipController or class("GoodsTipController",BaseController)
local this = GoodsTipController

function GoodsTipController:ctor()
	GoodsTipController.Instance = self
	self.model = GoodsModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function GoodsTipController:dctor()
end

function GoodsTipController:GetInstance()
	if not GoodsTipController.Instance then
		GoodsTipController.new()
	end
	return GoodsTipController.Instance
end

function GoodsTipController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = ""
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function GoodsTipController:AddEvents()
	-- --请求基本信息
	-- local function ON_REQ_BASE_INFO()
		-- self:RequestLoginVerify()
	-- end
	-- self.model:AddListener(GoodsTipModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)
end

-- overwrite
function GoodsTipController:GameStart()
	
end

--设置购买回调
-- param_tbl   存回调的表
function GoodsTipController:SetBuyCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Buy")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置续期回调
-- param_tbl   存回调的表
function GoodsTipController:SetValidateCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Validate")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置上架回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetPutOnSellCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("PutOnSell")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置下架回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetPutDownSellCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("PutDownSell")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

function GoodsTipController:SetChangePriceSellCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("ChangePrice")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end


--设置续费回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetRenewCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Renew")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置捐献回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetDonateCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Donate")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end


--设置兑换回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetExchangeCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Exchange")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置批量兑换回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetBatchExchangeCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("BatchExchange")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end


--设置取出回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetTakeOutCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("TakeOut")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置存入回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetStoreCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Store")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置出售回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetSellCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Sell")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置吞噬回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetDestroyCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Destroy")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end


--设置分解回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetDecomposeCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Decompose")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end


--设置卸下回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetTakeOffCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("TakeOff")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end


--设置镶嵌回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetInlayCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Inlay")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end


--设置合成回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetComposeCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Compose")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置修练回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetClearCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Clear")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end


--设置强化回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetStrongCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Strong")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end


--设置穿上回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetPutOnCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("PutOn")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end


--设置使用回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetUseCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Use")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

function GoodsTipController:SetRefuseCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Refuse")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置佩戴回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetWearCB(param_tbl,call_back,call_back_param)
    local param = self.model:GetOperation("Wear")
    param.callBack = call_back
    param.callBackParam = call_back_param
    table.insert(param_tbl,param)

    self:SortOperateParam(param_tbl)
end

--设置凝聚回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetCohesionCB(param_tbl,call_back,call_back_param)
    local param = self.model:GetOperation("Cohesion")
    param.callBack = call_back
    param.callBackParam = call_back_param
    table.insert(param_tbl,param)

    self:SortOperateParam(param_tbl)
end

--设置进阶回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetMoveUpCB(param_tbl,call_back,call_back_param)
    local param = self.model:GetOperation("MoveUp")
    param.callBack = call_back
    param.callBackParam = call_back_param
    table.insert(param_tbl,param)

    self:SortOperateParam(param_tbl)
end

--设置升级回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetLevelUpCB(param_tbl,call_back,call_back_param)
    local param = self.model:GetOperation("LevelUp")
    param.callBack = call_back
    param.callBackParam = call_back_param
    table.insert(param_tbl,param)

    self:SortOperateParam(param_tbl)
end

--设置拆解回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetDismantleCB(param_tbl,call_back,call_back_param)
    local param = self.model:GetOperation("Dismantle")
    param.callBack = call_back
    param.callBackParam = call_back_param
    table.insert(param_tbl,param)

    self:SortOperateParam(param_tbl)
end

function GoodsTipController:SortOperateParam(operate_param)
	if table.nums(operate_param) then
		local function call_back(p1,p2 )
			return p1.sort > p2.sort
		end

		table.sort(operate_param,call_back)
	end
end

function GoodsTipController:SetBabyDismantleCb(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Dismantle")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--替换
function GoodsTipController:SetDeplaceCB(param_tbl,call_back,call_back_param)
	local param = self.model:GetOperation("Deplace")
	param.callBack = call_back
	param.callBackParam = call_back_param
	table.insert(param_tbl,param)

	self:SortOperateParam(param_tbl)
end

--设置继承回调
-- param_tbl   存回调的表
-- call_back_param 回调的参数
function GoodsTipController:SetInheritCB(param_tbl,call_back,call_back_param)
    local param = self.model:GetOperation("Inherit")
    param.callBack = call_back
    param.callBackParam = call_back_param
    table.insert(param_tbl,param)

    self:SortOperateParam(param_tbl)
end
