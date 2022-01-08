
local InviteLayer = class("InviteLayer", BaseLayer)

function InviteLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.CodeLayer")
    QiyuManager:GetInviteCodeDataRequest()

    self.inviteConfig = require("lua.table.t_s_invite_code_reward_config")
    
    --for test
    self:setInviteData()
    self:Draw()

end

function InviteLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.btn_Baoxiang       = TFDirector:getChildByPath(ui, 'btn_baoxiang')
    self.btn_Verification   = TFDirector:getChildByPath(ui, 'btn_yanzheng')
    self.input_Verification = TFDirector:getChildByPath(ui, 'txt_shurukuang1')
    self.txt_inviteddesc    = TFDirector:getChildByPath(ui, 'txt_inviteddesc')

    self.btn_Copy           = TFDirector:getChildByPath(ui, 'btn_fuzhi')
    -- self.input_Copy         = TFDirector:getChildByPath(ui, 'txt_shurukuang2')
    self.input_Copy         = TFDirector:getChildByPath(ui, 'txt_code')

    self.lbl_Desc           = TFDirector:getChildByPath(ui, 'txt_wenben1')
    self.lbl_InviteNum      = TFDirector:getChildByPath(ui, 'txt_num')

    self.panle_Invite       = TFDirector:getChildByPath(ui, 'panel_yaoqing')

    -- 给按钮设置属性
    self.btn_Verification.tag   = 1
    self.btn_Verification.logic = self
    self.btn_Copy.tag           = 2
    self.btn_Copy.logic         = self
    self.btn_Baoxiang.tag       = 3
    self.btn_Baoxiang.logic     = self


    self.input_Verification:setMaxLengthEnabled(true)
    self.input_Verification:setMaxLength(12)

    self.bFirstTouchInInput = false
    local function onTextFieldAttachHandle(input)
        if self.bFirstTouchInInput == false then
            self.bFirstTouchInInput = true
            self.input_Verification:setText("")
        end
    end

    self.input_Verification:addMEListener(TFTEXTFIELD_ATTACH, onTextFieldAttachHandle)

end

function InviteLayer:registerEvents(ui)
    self.super.registerEvents(self)
    self.btn_Verification:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickHandle),1)
    self.btn_Copy:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickHandle),1)
    self.btn_Baoxiang:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickHandle),1)

    TFDirector:addMEGlobalListener("UpdateInviteCodeInfo", function() self:Refresh() end)
    TFDirector:addMEGlobalListener("CheckInviteCode",      function() 
    print("验证成功")
    end)
end

function InviteLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener("UpdateInviteCodeInfo")
    TFDirector:removeMEGlobalListener("CheckInviteCode")
end

function InviteLayer:Refresh()
    self:setInviteData()
    self:Draw()

    -- 刷新小红点
    if self.logic then
        self.logic:redraw()
    end
end

function InviteLayer.BtnClickHandle(sender)
    local self = sender.logic
    local tag  = sender.tag

    --验证
    if tag == 1 then

        if self.Invited ~= true then
            local code = self.input_Verification:getText()
            print("code = ", code)
            if string.len(code) == 0 then
                --toastMessage("请输入邀请码")
                toastMessage(localizable.InFriendAccLayer_input_invite_code)
            else
                QiyuManager:CheckInviteCode(code)
            end
        else
            --toastMessage("已经被邀请过了")
            toastMessage(localizable.InFriendAccLayer_already)
        end
        
    --拷贝
    elseif tag == 2 then
        -- 复制到手机的验证码
        print("复制到手机的验证码 ---- ", self.InviteCode)
        TFDeviceInfo:copyToPasteBord(self.InviteCode)

    elseif tag == 3 then
        local beInvitedRewardId = ConstantData:getValue("Invite.Receive.RewardId")
        RewardManager:showGiftListLayer(beInvitedRewardId, false,         
                function()
                 end
        )
    end
end

function InviteLayer:DrawInivteArea()
    local function drawArea(index)
        local data = self:getInviteData(index)

        local InviteArea    = string.format("img_wenben%d", index)
        local node          = TFDirector:getChildByPath(self.panle_Invite, InviteArea)

        local btn_gift          = TFDirector:getChildByPath(node, 'btn_libao')
        local img_lingqu        = TFDirector:getChildByPath(node, 'img_yilingqu')
        local lbl_kelingqu      = TFDirector:getChildByPath(node, 'txt_wenben1')
        local lbl_bukelingqu    = TFDirector:getChildByPath(node, 'txt_wenben2')
        local lbl_num           = TFDirector:getChildByPath(node, 'txt_num')
        local lbl_suffix        = TFDirector:getChildByPath(node, 'txt_wenben')


        btn_gift.tag = index
        btn_gift:addMEListener(TFWIDGET_CLICK,  audioClickfun(function(sender)
            local tag = sender.tag
            print("tag = ", tag)
            local canReceiveGift = false
            -- 领取奖励
            if data.complete == true then
                if data.receive == false then
                    -- QiyuManager:GetInviteCodePrizeRequest(index)
                    canReceiveGift = true
                else
                    -- 查询礼包
                end
            else
                -- toastMessage("没有达到要求") 
                -- -- 查询礼包    
                -- giftWatch = true          
            end

                RewardManager:showGiftListLayer(data.rewardid, canReceiveGift,         
                    function()

                        print("领取奖励1：", index)
                        if canReceiveGift then
                            print("领取奖励2：", index)
                            QiyuManager:GetInviteCodePrizeRequest(index)
                        end
                    end
                 )

        end),1)

        -- 可以领奖
        if data.complete == true then
            --  未领奖
            if data.receive == false then
                lbl_kelingqu:setVisible(true)
                img_lingqu:setVisible(false)
                -- print("未领奖")
            --  已领奖
            else
                img_lingqu:setVisible(true)
                lbl_kelingqu:setVisible(false)
                -- print("已领奖")
            end

            lbl_bukelingqu:setVisible(false)

        -- 不可领奖
        else
            img_lingqu:setVisible(false)
            lbl_bukelingqu:setVisible(true)
            lbl_kelingqu:setVisible(false)

            lbl_num:setText(string.format("%d", data.people))
        end


    end

    for i=1,4 do
        drawArea(i)
    end
end

function InviteLayer:Draw()
    self:DrawInivteArea()

    -- 绘制已邀请的人数
    self.lbl_InviteNum:setText(string.format("%d", self.inviteCount))

    -- 绘制code
    self.input_Copy:setText(self.InviteCode)
end

function InviteLayer:setInviteData()

    -- if self.ReceiRewardList == nil then
    --     self.ReceiRewardList = TFArray:new()
    -- else
    --     self.ReceiRewardList:clear()
    -- end

    self.InviteData = {}
    -- 邀请码 code
    self.InviteCode         = QiyuManager.InviteCodeInfo.code
    self.Invited            = QiyuManager.InviteCodeInfo.invited
    self.inviteCount        = QiyuManager.InviteCodeInfo.inviteCount 
    self.getRewardRecord    = QiyuManager.InviteCodeInfo.getRewardRecord

    -- for test
    -- self.getRewardRecord    = "1,2"
    -- self.inviteCount        = 2
    print("self.getRewardRecord = ",self.getRewardRecord)

    local rewardList        = string.split(self.getRewardRecord, ',') 

    -- for i=1,#rewardList do
    --     if rewardList[i] ~= nil and string.len(rewardList[i]) >= 1 then
    --         local info = {index = rewardList[i]}
    --         self.ReceiRewardList:pushBack(info)        
    --         -- print("rewardList = ",rewardList[i])
    --     end
    -- end

    local function checkPrizeIsGet(id)
        if rewardList == nil or #rewardList == 0 or id == nil then
            return false
        end
        local index = string.format("%d", id)
        for i=1,#rewardList do
            if rewardList[i] ~= nil and string.len(rewardList[i]) >= 1 then
                print("id = ", rewardList[i])
               if rewardList[i] == index then
                    -- print("已领取 id = ", rewardList[i])
                    return true
                end
            end
        end

        return false
    end

    -- 初始化奖励数据
    for i=1,4 do
        local config = self.inviteConfig:getObjectAt(i)
        local complete_ = false
        -- 计算邀请人数
        local people_ = config.invite_time - self.inviteCount
        if people_ <= 0 then
            people_ = 0
            complete_ = true
        end

        -- 是否领过奖
        local receive_ = false
        -- if self.ReceiRewardList:getObjectAt(i) == nil then
        if  checkPrizeIsGet(i) == true then
            receive_ = true
        end

        local reward = {complete = complete_, receive = receive_, people = people_, rewardid = config.reward_id}
        table.insert(self.InviteData, reward)

        -- if complete_ then
        --     print("已完成")
        -- else
        --     print("未完成")
        -- end

        -- if receive_ then
        --     print("已领取")
        -- else
        --     print("未领取")
        -- end
    end

    -- 已被邀请
    if self.Invited then
        self.btn_Verification:setTouchEnabled(false)
        self.btn_Verification:setGrayEnabled(true)
        self.input_Verification:setVisible(false)
        self.txt_inviteddesc:setVisible(true)

        -- self.txt_inviteddesc:setText("你已被邀请")
        print("已被邀请")
    else
        print("没有被邀请")
        self.txt_inviteddesc:setVisible(false)
        self.input_Verification:setVisible(true)

        -- self.input_Verification:setText("请输入邀请码")
        --self.input_Verification:setPlaceHolder("请输入邀请码")
        self.input_Verification:setPlaceHolder(localizable.InFriendAccLayer_input_invite_code)
        
    end
end


function InviteLayer:getInviteData(index)
    return self.InviteData[index]
end

return InviteLayer