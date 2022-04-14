--
-- @Author: chk
-- @Date:   2018-08-31 19:01:34
--
GoodsModel = GoodsModel or class("GoodsModel",BaseBagModel)
local GoodsModel = GoodsModel

function GoodsModel:ctor()
	GoodsModel.Instance = self
	self:Reset()


end

function GoodsModel:Reset()
	self.isOpenWarePanel = false      --是否打开仓库界面
	self.operation = {}
	self.goodsItem = nil
	self:SetOperations()
end

function GoodsModel.GetInstance()
	if GoodsModel.Instance == nil then
		GoodsModel()
	end
	return GoodsModel.Instance
end


function GoodsModel:SetOperations()
	 self.operation["Buy"] = {sort = 99,name = ConfigLanguage.GoodsOperate.Buy,callBack = nil,callBackParam = nil}--购买
	 self.operation["PutOnSell"] = {sort = 50,name = ConfigLanguage.GoodsOperate.PutOnSell,callBack = nil,callBackParam = nil}--上架
	 self.operation["PutDownSell"] = {sort = 92,name = ConfigLanguage.GoodsOperate.PutDownSell,callBack = nil,callBackParam = nil}--下架
	 self.operation["ChangePrice"] = {sort = 93,name = ConfigLanguage.GoodsOperate.ChangePrice,callBack = nil,callBackParam = nil}--修改价格
	 self.operation["Renew"] = {sort = 75,name = ConfigLanguage.GoodsOperate.Renew,callBack = nil,callBackParam = nil}--续费
	 self.operation["Donate"] = {sort = 98,name = ConfigLanguage.GoodsOperate.Donate,callBack = nil,callBackParam = nil}--捐献
	 self.operation["Destroy"] = {sort = 39 ,name = ConfigLanguage.GoodsOperate.Destroy,callBack = nil,callBackParam = nil}--销毁
	 self.operation["Exchange"] = {sort = 97,name = ConfigLanguage.GoodsOperate.Exchange,callBack = nil,callBackParam = nil}--兑换
	 self.operation["BatchExchange"] = {sort = 96,name = ConfigLanguage.GoodsOperate.BatchExchange,callBack = nil,callBackParam = nil}--批量兑换
	 self.operation["TakeOut"] = {sort = 95,name = ConfigLanguage.GoodsOperate.TakeOut,callBack = nil,callBackParam = nil}--取出
	 self.operation["Store"] = {sort = 94,name = ConfigLanguage.GoodsOperate.Store,callBack = nil,callBackParam = nil}--存入
	 self.operation["Sell"] = {sort = 2,name = ConfigLanguage.GoodsOperate.Sell,callBack = nil,callBackParam = nil}--出售
	 self.operation["Engulf"] = {sort = 40,name = ConfigLanguage.GoodsOperate.Engulf,callBack = nil,callBackParam = nil}--吞噬
	 self.operation["Decompose"] = {sort = 5,name = ConfigLanguage.GoodsOperate.Decompose,callBack = nil,callBackParam = nil}--分解
	 self.operation["TakeOff"] = {sort = 1,name = ConfigLanguage.GoodsOperate.TakeOff,callBack = nil,callBackParam = nil}--卸下
	 self.operation["Inlay"] = {sort = 88,name = ConfigLanguage.GoodsOperate.Inlay,callBack = nil,callBackParam = nil}--镶嵌
	 self.operation["Compose"] = {sort = 60,name = ConfigLanguage.GoodsOperate.Compose,callBack = nil,callBackParam = nil}--合成
	 self.operation["Clear"] = {sort = 77,name = ConfigLanguage.GoodsOperate.Clear,callBack = nil,callBackParam = nil}--洗练
	 self.operation["Strong"] = {sort = 74,name = ConfigLanguage.GoodsOperate.Strong,callBack = nil,callBackParam = nil}--强化
	 self.operation["PutOn"] = {sort = 79,name = ConfigLanguage.GoodsOperate.PutOn,callBack = nil,callBackParam = nil}--穿上
	 self.operation["Use"] = {sort = 80,name = ConfigLanguage.GoodsOperate.Use,callBack = nil,callBackParam = nil}--使用
	 self.operation["Validate"] = {sort = 84,name = ConfigLanguage.GoodsOperate.Validate,callBack = nil,callBackParam = nil}--续期
	 self.operation["Refuse"] = {sort = 6,name = ConfigLanguage.GoodsOperate.Refuse,callBack = nil,callBackParam = nil}--拒绝
    self.operation["Wear"] = {sort = 75,name = ConfigLanguage.GoodsOperate.Wear,callBack = nil,callBackParam = nil}--佩戴
    self.operation["Cohesion"] = {sort = 65,name = ConfigLanguage.GoodsOperate.Cohesion,callBack = nil,callBackParam = nil}--合成
    self.operation["MoveUp"] = {sort = 70,name = ConfigLanguage.GoodsOperate.MoveUp,callBack = nil,callBackParam = nil}--进阶
    self.operation["LevelUp"] = {sort = 69,name = ConfigLanguage.GoodsOperate.LevelUp,callBack = nil,callBackParam = nil}--升级
    self.operation["Dismantle"] = {sort = 78,name = ConfigLanguage.GoodsOperate.Dismantle,callBack = nil,callBackParam = nil}--拆解
	self.operation["Deplace"] = {sort = 100,name = ConfigLanguage.GoodsOperate.Deplace,callBack = nil,callBackParam = nil}--替换
	self.operation["Inherit"] = {sort = 101,name = ConfigLanguage.GoodsOperate.Inherit,callBack = nil,callBackParam = nil}--继承
end

function GoodsModel:GetOperation(operate)
	local _operation = {}
	_operation.sort = self.operation[operate].sort
	_operation.name = self.operation[operate].name
	_operation.callBack = self.operation[operate].callBack
	_operation.callBackParam = self.operation[operate].callBackParam
	return _operation
end

function GoodsModel:GetGiftConfig(goods_id)
	return Config.db_item_gift[goods_id]
end

--[[
	@author LaoY
	@des	物品获得途径 快速跳转
	@param1 id 物品ID，可以是gold等或者配置表id
	@return number
--]]
function GoodsModel:GoodsJumpConfig(id)
	if id and Constant.GoldTypeMap[id] then
		id = Constant.GoldTypeMap[id]
	end
	local cf = Config.db_item[id]

	if cf and cf.jump then
		UnpackLinkConfig(cf.jump)
	end
end
