-- 文件名:	WB_UI_BaXianFilter.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	facebook邀请好友奖励界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
function onClick_Button_Share()
    if g_GamePlatformSystem.m_PlatformInterface ~=nil and  
    g_GamePlatformSystem.m_PlatformInterface.FBShare ~=nil
    then
        g_GamePlatformSystem.m_PlatformInterface:FBShare()
    end
end


Game_FacebookShare = class("Game_FacebookShare")
Game_FacebookShare.__index = Game_FacebookShare

function Game_FacebookShare:ctor()

end

function Game_FacebookShare:initWnd()
    g_FormMsgSystem:RegisterFormMsg(FormMsg_Facebook_updateShare, handler(self, self.UIMsg_updateShare))
end

function Game_FacebookShare:releaseWnd()
    g_FormMsgSystem:UnRegistFormMsg(FormMsg_Facebook_updateShare)
end

function Game_FacebookShare:openWnd()

    local ListView_RewardItems = tolua.cast(self.rootWidget:getChildAllByName("ListView_RewardItems"), "ListViewEx")
	local Panel_RewardItem = tolua.cast(ListView_RewardItems:getChildByName("Panel_RewardItem"), "Layout")
	local function updataRewardList(widget,nIndex)
		self:setListViewRewardItem(widget,nIndex)
	end
	self.ListView_RewardItems = registerListViewEvent(ListView_RewardItems, Panel_RewardItem, updataRewardList)
    
    g_SetBtn(self.rootWidget, "Button_Share", onClick_Button_Share, true)--  

    self:UIMsg_updateShare()
end

function Game_FacebookShare:closeWnd()

end

function Game_FacebookShare:UIMsg_updateShare()
    self.ListView_RewardItems:updateItems(#g_FacebookRewardSys.ShareReward)
end

function Game_FacebookShare:setListViewRewardItem(widget, nIndex)
	local tbDrop = g_FacebookRewardSys.ShareReward[nIndex]
    if tbDrop  == nil then return end

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

function Game_FacebookShare:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_FacebookSharePNL = tolua.cast(self.rootWidget:getChildByName("Image_FacebookSharePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_FacebookSharePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_FacebookShare:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_FacebookSharePNL = tolua.cast(self.rootWidget:getChildByName("Image_FacebookSharePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_FacebookSharePNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end