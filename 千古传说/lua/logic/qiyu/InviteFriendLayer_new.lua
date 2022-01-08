
local InviteLayer = class("InviteLayer", BaseLayer)
--local HelpDesc = "低于%d级的玩家可以接受他人邀请，成功受邀会有丰厚奖励！"
local HelpDesc = localizable.InFriendLayerNew_desc;

function InviteLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.CodeLayer")
    -- QiyuManager:GetInviteCodeDataRequest()

    self.inviteConfig = require("lua.table.t_s_invite_config")

-- t_s_invite_config

end

function InviteLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.btn_shouyao        = TFDirector:getChildByPath(ui, 'btn_shouyao')
    self.btn_woyao          = TFDirector:getChildByPath(ui, 'btn_woyao')
    self.btn_Copy           = TFDirector:getChildByPath(ui, 'btn_fuzhi')
    self.input_Copy         = TFDirector:getChildByPath(ui, 'txt_code')
    self.lbl_InviteNum      = TFDirector:getChildByPath(ui, 'txt_friendnum')  -- 已邀请人的个数
    self.panle_Invite       = TFDirector:getChildByPath(ui, 'panel_yaoqing')

    self.img_invitetotal    = TFDirector:getChildByPath(ui, 'img_invitetotal')

    self.img_wenben         = TFDirector:getChildByPath(ui, 'img_wenben')

    self.txt_wenben2        = TFDirector:getChildByPath(ui, 'txt_wenben2')

    self.img_wenben:setVisible(false)
    self.img_invitetotal:setVisible(false)



    
end

function InviteLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function InviteLayer:registerEvents(ui)
    self.super.registerEvents(self)

    self.btn_Copy.logic = self
    self.btn_Copy:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickCopyBtn),1)


    self.btn_shouyao.logic = self
    self.btn_shouyao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickAcceptInvite),1)
    self.btn_woyao.logic = self
    self.btn_woyao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickSendToFriend),1)

    TFDirector:addMEGlobalListener("CheckInviteCode", function() self:refreshUI() end)

    TFDirector:addMEGlobalListener("UpdateInviteCodeInfo", function() self:refreshUI() end)

end

function InviteLayer:removeEvents()
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener("CheckInviteCode")
    TFDirector:removeMEGlobalListener("UpdateInviteCodeInfo")

end

function InviteLayer:refreshUI()
    -- required int32 myCode = 1;                   //自己的邀请码
    -- required bool invited = 2;                   //自己是否验证过别人的邀请码
    -- required bool invitedAward = 3;              //是否已领受邀奖
    -- required int32 inviteCount = 4;          //邀请好友次数
    -- required string getRewardRecord = 5;         //邀请领奖记录，格式:id_达到条件次数_已领次数&id_次数...

    self.InviteCodeInfo = QiyuManager:GetInviteCodeData()

    self.InviteCode = self.InviteCodeInfo.myCode

    self.input_Copy:setText(self.InviteCode)

    local invited = self.InviteCodeInfo.invited

    self.lbl_InviteNum:setText(self.InviteCodeInfo.inviteCount)

    -- print("getRewardRecord = ", self.InviteCodeInfo.getRewardRecord)
    local tblOfReward = string.split(self.InviteCodeInfo.getRewardRecord,'&')

    self.rewardStatusList = MEMapArray:new()
    for k,v in pairs(tblOfReward) do
        local rewardInfo = string.split(v,'_')
        local id         = tonumber(rewardInfo[1])
        local numTotal   = tonumber(rewardInfo[2])      -- 可以领取总数
        local numGet     = tonumber(rewardInfo[3])      --已经领取次数
        local data = 
        {
            id = id,
            numTotal = numTotal,
            numGet = numGet,
            times  = numTotal - numGet
        }
        self.rewardStatusList:pushbyid(id,data)
    end

    local function cmpTimes(reward1, reward2)
        if reward1.times > reward2.times then
            return true
        elseif reward1.times == reward2.times then
            if reward1.id < reward2.id then
                return true
            end
        end

        return false
    end

    self.rewardStatusList:sort(cmpTimes)

    self:drawRewardList()


    local bIsGetReward = self.InviteCodeInfo.invited
    -- self.btn_shouyao:setVisible(not bIsGetReward)

    local bShowAcceptBtn = true
    local levelLimit = ConstantData:getValue("Invite.Validate.Level")
    if MainPlayer:getLevel() > levelLimit or bIsGetReward then
        bShowAcceptBtn = false
    end

    self.btn_shouyao:setVisible(bShowAcceptBtn)
    CommonManager:setRedPoint(self.btn_shouyao, bShowAcceptBtn,"bShowAcceptBtn",ccp(0,0))
    


    -- self.txt_wenben2:setVisible(false)
    local desc = stringUtils.format(HelpDesc,levelLimit)
    self.txt_wenben2:setText(desc)
    print("InviteLayer:refreshUI = ", bIsGetReward)
end


function InviteLayer:drawRewardList()
    if self.titleTableView ~= nil then
        self.titleTableView:reloadData()
        return
    end

    local  titleTableView =  TFTableView:create()
    titleTableView:setTableViewSize(self.panle_Invite:getContentSize())
    titleTableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    titleTableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    titleTableView:setPosition(self.panle_Invite:getPosition())
    self.titleTableView = titleTableView
    self.titleTableView.logic = self

    titleTableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    titleTableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    titleTableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    titleTableView:reloadData()

    self.panle_Invite:getParent():addChild(self.titleTableView,1)
end


function InviteLayer.numberOfCellsInTableView(table)
    local self  = table.logic
    -- local num   = #self.titleList

    return self.inviteConfig:length()
end

function InviteLayer.cellSizeForTable(table,idx)
    return 200, 174+20
end

function InviteLayer.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        node = self.img_wenben:clone()

        node:setPosition(ccp(20 + 35, 120))
        cell:addChild(node)
        node:setTag(617)
        node.logic = self
        node:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickTitle))
    end

    node = cell:getChildByTag(617)
    node.index = idx + 1
    self:drawInviteNode(node)

    node:setVisible(true)
    return cell
end


function InviteLayer:drawInviteNode(node)
    -- btn_libao
    -- txt_wenben2
    -- btn_lingqu  txt_lv
    -- txt_level 
    local index =  node.index

    local btn_lingqu = TFDirector:getChildByPath(node, 'btn_lingqu')
    local txt_num    = TFDirector:getChildByPath(node, 'txt_lv')
    local btn_libao  = TFDirector:getChildByPath(node, 'btn_libao')
    local txt_desc   = TFDirector:getChildByPath(node, 'txt_level')
    local txt_reward = TFDirector:getChildByPath(node, 'txt_wenben2')

    -- local data = self.inviteConfig:objectAt(index)
    local rewardInfo = self.rewardStatusList:objectAt(index)
    local data       = self.inviteConfig:objectByID(rewardInfo.id)
    print("rewardInfo = ", rewardInfo)

    -- local desc = toVerticalString(data.target_desc)
    -- txt_desc:setText(desc)

    txt_desc:setText(data.target_desc)
     if data.target_type == 2 then
        txt_desc:setTextAreaSize(CCSizeMake(0,0))
        txt_desc:setRotation(90)
    else
        txt_desc:setTextAreaSize(CCSizeMake(24,100))
        txt_desc:setRotation(0)
    end

    
    btn_libao:addMEListener(TFWIDGET_CLICK,  audioClickfun(function(sender)
                RewardManager:showGiftListLayer(data.reward_id, false,         
                    function()

                    
                    end
                 )

        end),1)


    -- local rewardInfo = self.rewardStatusList:objectByID(data.id)
    local id         = rewardInfo.id
    local numTotal   = rewardInfo.numTotal -- 可以领取总数
    local numGet     = rewardInfo.numGet    --已经领取次数

    txt_num:setText(numTotal - numGet)
    txt_reward:setText(numTotal.."/"..data.reward_get_count)
    
    local bCanGetReward = true
    if numGet >= data.reward_get_count or numTotal <= numGet then
        bCanGetReward = false
    end

    btn_lingqu:setGrayEnabled(not bCanGetReward)
    btn_lingqu:setTouchEnabled(bCanGetReward)

    btn_lingqu:addMEListener(TFWIDGET_CLICK,  audioClickfun(function(sender)
                QiyuManager:requestInviteCodeGift(data.id)
        end),1)
    
end


function InviteLayer.onClickCopyBtn(sender)
    local self = sender.logic

    -- 复制到手机的验证码
    print("复制到手机的验证码 ---- ", self.InviteCode)
    local content = self.InviteCode..""
    TFDeviceInfo:copyToPasteBord(content)

    --toastMessage("复制成功")
    toastMessage(localizable.vipQQLayer_copy_suc)
end

function InviteLayer.onClickAcceptInvite(sender)
    local self = sender.logic

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.qiyu.InviteFriendAcceptLayer", AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()
end

function InviteLayer.onClickSendToFriend(sender)
    local self = sender.logic

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.qiyu.InviteFriendSendLayer", AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()
end

-- InviteFriendAcceptLayer
return InviteLayer