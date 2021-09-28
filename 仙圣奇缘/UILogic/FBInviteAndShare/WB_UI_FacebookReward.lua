--------------------------------------------------------------------------------------
-- 文件名:	WB_UI_BaXianFilter.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	facebook邀请好友奖励界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

function onClick_Button_Invite()
--g_FacebookRewardSys:ReqInviteReward("to[]to[]to[]to[]to[]")
--if true then return end
    if g_GamePlatformSystem.m_PlatformInterface ~=nil and  
    g_GamePlatformSystem.m_PlatformInterface.FBInvite ~=nil
    then
        g_GamePlatformSystem.m_PlatformInterface:FBInvite()
    end
end


Game_FacebookReward = class("Game_FacebookReward")
Game_FacebookReward.__index = Game_FacebookReward

function Game_FacebookReward:ctor()

end

function Game_FacebookReward:initWnd()
    g_FormMsgSystem:RegisterFormMsg(FormMsg_Facebook_updateInvite, handler(self, self.UIMsg_updateInvite))
end

function Game_FacebookReward:releaseWnd()
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_Facebook_updateInvite)
end

function Game_FacebookReward:openWnd()

    self.Label_InviteCount = tolua.cast(self.rootWidget:getChildAllByName("Label_InviteCount"), "Label")

    local ListView_RewardItems = tolua.cast(self.rootWidget:getChildAllByName("ListView_RewardItems"), "ListViewEx")
	local Panel_RewardItem = tolua.cast(ListView_RewardItems:getChildByName("Panel_RewardItem"), "Layout")
	local function updataRewardList(widget,nIndex)
		self:setListViewRewardItem(widget,nIndex)
	end
	self.ListView_RewardItems = registerListViewEvent(ListView_RewardItems, Panel_RewardItem, updataRewardList)
    
    g_SetBtn(self.rootWidget, "Button_Invite", onClick_Button_Invite, true)--

    self:UIMsg_updateInvite()
end

function Game_FacebookReward:closeWnd()

end

function Game_FacebookReward:UIMsg_updateInvite()

    self.Label_InviteCount:setText(string.format(_T("今天您已在Facebook邀请了%d个好友"),g_FacebookRewardSys.InviteCnt ))
    self.ListView_RewardItems:updateItems(1)--只有一种奖励，体力
end

function Game_FacebookReward:setListViewRewardItem(widget, nIndex)
	local tbDrop = {}

	tbDrop.DropItemType = macro_pb.ITEM_TYPE_MASTER_ENERGY --道具
	tbDrop.DropItemStarLevel =0
	tbDrop.DropItemID = 0
	tbDrop.DropItemNum = g_FacebookRewardSys:getSurplusReward()

	local itemModel = g_CloneDropItemModel(tbDrop)
	if itemModel then
		widget:removeAllChildren()
		widget:addChild(itemModel)
		itemModel:setPosition(ccp(60,80))
		itemModel:setScale(0.9)
		
		local function onClick(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			g_ShowDropItemTip(tbDrop)
			end
		end
		itemModel:setTouchEnabled(true)
		itemModel:addTouchEventListener(onClick)
	end
end

function Game_FacebookReward:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_FacebookRewardPNL = tolua.cast(self.rootWidget:getChildByName("Image_FacebookRewardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_FacebookRewardPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_FacebookReward:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_FacebookRewardPNL = tolua.cast(self.rootWidget:getChildByName("Image_FacebookRewardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_FacebookRewardPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

