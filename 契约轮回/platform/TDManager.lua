--
-- @Author: LaoY
-- @Date:   2018-12-27 19:28:17
-- 平台数据相关
TDManager = TDManager or class("TDManager", BaseManager)

-- 是否要上传数据
TDManager.IsSendMessage = true

if not Application.isMobilePlatform then
    TDManager.IsSendMessage = false
end

local Gender = {
    UNKNOW = 0,
    MALE = 1,
    FEMALE = 2
}

local AccountType = {
    ANONYMOUS = 0,
    REGISTERED = 1,
    SINA_WEIBO = 2,
    QQ = 3,
    QQ_WEIBO = 4,
    ND91 = 5,
    WEIXIN = 6,
    TYPE1 = 11,
    TYPE2 = 12,
    TYPE3 = 13,
    TYPE4 = 14,
    TYPE5 = 15,
    TYPE6 = 16,
    TYPE7 = 17,
    TYPE8 = 18,
    TYPE9 = 19,
    TYPE10 = 20
}

function TDManager:ctor()
    TDManager.Instance = self

    if AppConfig.isOutServer then
        local channelId = PlatformManager:GetInstance():GetChannelID() or "xwgame_out"
        self:OnStart(channelId)
    else
        self:OnStart("xwgame")
    end

    self:Reset()
    self:AddEvent()
end

function TDManager:Reset()
    -- tdMgr
    TDManager.IS_SET_ACCOUNT = false
    self.main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
end

function TDManager.GetInstance()
    if TDManager.Instance == nil then
        TDManager()
    end
    return TDManager.Instance
end

function TDManager:AddEvent()
    -- 切换账号要改变
    if not TDManager.IsSendMessage then
        return
    end

    -- local function call_back()
        
    -- end
    -- GlobalEvent:AddListener(event_name, call_back)

    local function call_back()
        if not TDManager.IS_SET_ACCOUNT then
            self:SetAccount(self.main_role_data.id)
        end
        self:SetLevel(self.main_role_data.level)
    end
    self.main_role_data:BindData("level", call_back)

    local function call_back()
        if not TDManager.IS_SET_ACCOUNT then
            self:SetAccount(self.main_role_data.id)
        end
        self:SetGameServer(self.main_role_data.suid)
    end
    self.main_role_data:BindData("suid", call_back)

    local function call_back()
        if not TDManager.IS_SET_ACCOUNT then
            self:SetAccount(self.main_role_data.id)
        end
        self:SetAccountName(self.main_role_data.name)
    end
    self.main_role_data:BindData("name", call_back)

    local function call_back()
        if not TDManager.IS_SET_ACCOUNT then
            self:SetAccount(self.main_role_data.id)
        end
        self:SetGender(self.main_role_data.gender)
    end
    self.main_role_data:BindData("gender", call_back)

    -- self.main_role_data:BindData("age",call_back)
end


--[[	@author LaoY
	@des	
	@param1 channelId 	渠道
--]]
function TDManager:OnStart(channelId)
    if not TDManager.IsSendMessage then
        return
    end

	---启用的数据收集
	---1,TalkingData
	---2,Umeng
	local enabledCollector = {1, 2 }

    for _, v in ipairs(enabledCollector) do
		tdMgr:SetCollectorEnabled(v)
    end

    tdMgr:OnStart(channelId)
end

function TDManager:SetAccount(accountId)
    if not TDManager.IsSendMessage then
        return
    end
    if not accountId then
        return
    end
    TDManager.IS_SET_ACCOUNT = true
    tdMgr:SetAccount(accountId)
    self:SetAccountType(AccountType.TYPE1)
end

--[[	@author LaoY
	@des	
	@param1 accountType 账号类型 见：文件首 AccountType
--]]
function TDManager:SetAccountType(accountType)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:SetAccountType(accountType)
end

function TDManager:SetLevel(level)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:SetLevel(level)
end

--[[	@author LaoY
	@des	
	@param1 服
--]]
function TDManager:SetGameServer(server)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:SetGameServer(server)
end

function TDManager:SetAccountName(name)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:SetAccountName(name)
end

function TDManager:SetGender(gender)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:SetGender(gender)
end

function TDManager:SetAge(age)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:SetAge(age)
end

--[[	@author LaoY
	@des	请求充值 充值成功另外上传数据 需要二次确认
	@param1 orderId 				string 订单ID 最多64个字符
	@param2 iapId  					string 充值包 ID,最多 32 个字符。唯一标识一类充值包。例如：VIP3 礼包
	@param3 currencyAmount 			number 现金金额或现金等价物的额度
	@param4 currencyType 			string 货币类型，人民币 CNY；美元 USD；欧元 EUR
	@param5 virtualCurrencyAmount   number 虚拟币金额
	@param6 paymentType  			string 支付的途径，最多16个字符
--]]
function TDManager:OnChargeRequest(orderId, iapId, currencyAmount, currencyType, virtualCurrencyAmount, paymentType)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:OnChargeRequest(orderId, iapId, currencyAmount, currencyType, virtualCurrencyAmount, paymentType)
end

--[[	@author LaoY
	@des	充值成功
	@param1 orderId  唯一ID
--]]
function TDManager:OnChargeSuccess(orderId)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:OnChargeSuccess(orderId)
end

--[[	@author LaoY
	@des	奖励
	@param1 virtualCurrencyAmount  	虚拟货币数量
	@param2 reason 					原因
--]]
function TDManager:OnReward(virtualCurrencyAmount, reason)
    if not TDManager.IsSendMessage then
        return
    end
    reason = reason or ""
    tdMgr:OnReward(virtualCurrencyAmount, reason)
end

--[[	@author LaoY
	@des	购买物品
	@param1 item 					string 物品ID
	@param2 itemNumber 				number 物品数量
	@param3 priceInVirtualCurrency 	number 单价
--]]
function TDManager:OnPurchase(item, itemNumber, priceInVirtualCurrency)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:OnPurchase(item, itemNumber, priceInVirtualCurrency)
end

--[[	@author LaoY
	@des	使用物品
	@param1 item 					string 物品ID
	@param2 itemNumber 				number 物品数量
--]]
function TDManager:OnUse(item, itemNumber)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:OnUse(item, itemNumber)
end

--[[	@author LaoY
	@des	开始任务或者副本
	@param1 missionId  string ID
--]]
function TDManager:OnBegin(missionId)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:OnBegin(missionId)
end

--[[	@author LaoY
	@des	完成任务或者副本
	@param1 missionId string ID
--]]
function TDManager:onCompleted(missionId)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:onCompleted(missionId)
end

--[[	@author LaoY
	@des	任务或者副本 失败
	@param1 missionId  string ID
	@param1 cause 原因 可不填
--]]
function TDManager:onFailed(missionId, cause)
    if not TDManager.IsSendMessage then
        return
    end
    if cause then
        tdMgr:onFailed(missionId, cause)
    else
        tdMgr:onFailed(missionId)
    end
end

function TDManager:OnEvent(actionId, parameters)
    if not TDManager.IsSendMessage then
        return
    end
    tdMgr:OnEvent(actionId, parameters)
end