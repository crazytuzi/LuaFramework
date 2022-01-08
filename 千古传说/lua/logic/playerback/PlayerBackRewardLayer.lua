--[[
******老玩家回归奖励界面*******
    -- by yao
    -- 2016/2/16
]]

local PlayerBackRewardLayer = class("PlayerBackRewardLayer", BaseLayer)

function PlayerBackRewardLayer:ctor(data)
    self.super.ctor(self,data)
    self.btn_close      = nil       --关闭按钮
    self.btn_ok         = nil       --确定按钮
    self.img_wenben     = nil       --标题文本
    self.txt_inviteddesc= nil
    self.txt_shurukuang1= nil       --输入框
    self:init("lua.uiconfig_mango_new.playerback.PlayerBackReward")
end

function PlayerBackRewardLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close      = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_ok         = TFDirector:getChildByPath(ui, "btn_ok")
    self.img_wenben     = TFDirector:getChildByPath(ui, "img_wenben")
    self.txt_inviteddesc= TFDirector:getChildByPath(ui, "txt_inviteddesc")
    self.txt_shurukuang1= TFDirector:getChildByPath(ui, "txt_shurukuang1")
    self.img_res_icon   = TFDirector:getChildByPath(ui, "img_res_icon")
    self.txt_num        = TFDirector:getChildByPath(ui, "txt_num")

    self.txt_inviteddesc:setVisible(false)
    self.txt_shurukuang1.logic = self
    self.txt_shurukuang1:setMaxLengthEnabled(true)
    self.txt_shurukuang1:setMaxLength(18)
    self.txt_shurukuang1:setCursorEnabled(true)
    --self.txt_shurukuang1:setPlaceHolder("请输入好友邀请码")
    self.txt_shurukuang1:setPlaceHolder(localizable.playerbackReward_code)

    self.btn_ok.logic = self
    local numstr = recallConf:objectByID(1).return_reward
    local numtable = stringToNumberTable(numstr, '_')
    --self.txt_num:setText(numtable[3])

    local data = {}
    data.type = tonumber(numtable[1])
    data.itemId = tonumber(numtable[2])
    data.number = tonumber(numtable[3])
    local reward = BaseDataManager:getReward(data)
    --print("reward =",reward)
    self.img_res_icon:setTexture(reward.path)
    self.img_res_icon:setScale(0.5)
    self.txt_num:setText("x" .. reward.number)
end

function PlayerBackRewardLayer:loadData()
    
end

function PlayerBackRewardLayer:removeUI()
    self.super.removeUI(self)
end

-----断线重连支持方法
function PlayerBackRewardLayer:onShow()
    self.super.onShow(self)
end

function PlayerBackRewardLayer:registerEvents()
    self.super.registerEvents(self)
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseBtnCallBack))
    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onQuedingBtnCallBack))

    --提交邀请码成功
    self.lingquSuccess = function(event)
        AlertManager:close()
    end
    TFDirector:addMEGlobalListener(PlayBackManager.LIBAOLINGQUSUCCESS ,self.lingquSuccess)
end

function PlayerBackRewardLayer:removeEvents()
    self.btn_close:removeMEListener(TFWIDGET_CLICK)
    self.btn_ok:removeMEListener(TFWIDGET_CLICK)
    
    TFDirector:removeMEGlobalListener(PlayBackManager.LIBAOLINGQUSUCCESS ,self.lingquSuccess)
    self.lingquSuccess = nil

    self.super.removeEvents(self)
end

function PlayerBackRewardLayer:dispose()
    self.super.dispose(self)
end

--关闭按钮回调
function PlayerBackRewardLayer.onCloseBtnCallBack(sender)
    AlertManager:close()
end

--确定按钮回调
function PlayerBackRewardLayer.onQuedingBtnCallBack(sender)
    local self = sender.logic
    local text = self.txt_shurukuang1:getText()
    --print("text ==",text)
    if text == "" then
        --toastMessage("邀请码不能为空")
        toastMessage(localizable.playerbackReward_code_null)
    else
        PlayBackManager:requestApplyRecallInviteCode(text)
    end
end

return PlayerBackRewardLayer