-- @Author: lwj
-- @Date:   2019-12-07 13:55:19 
-- @Last Modified time: 2019-12-07 13:55:21

RechargeDialPanel = RechargeDialPanel or class("RechargeDialPanel", BaseDialPanel)
local RechargeDialPanel = RechargeDialPanel

function RechargeDialPanel:ctor()
    self.abName = "dial"
    self.assetName = "RechargeDialPanel"
    self.layer = "UI"

    self.model = DialModel.GetInstance()
end

function RechargeDialPanel:StartTurn(act_id,hit)
    if act_id == OperateModel.GetInstance():GetActIdByType(750) then
        if not self.turn_table then
            return
        end
        self.turn_table:SetTurnToIndex(hit,handler(self,self.OnTurnCallBack))
    end
end