--------------------------------------------------------------------------------------
-- 文件名:	WB_UI_BaXianGuoHai.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	facebook邀请好友奖励逻辑
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

----------------Npc简要信息类------------------------
FacebookRewardSys = class("FacebookRewardSys")
FacebookRewardSys.__index = FacebookRewardSys

function FacebookRewardSys:ctor()
    self.InviteCnt = 0 --当前邀请好友数量
    self.MaxInviteCnt = g_DataMgr:getCsvConfigByOneKey("GlobalCfg", 115).Data --每日最大邀请人数
    self.energy_bas = g_DataMgr:getCsvConfigByOneKey("GlobalCfg", 116).Data --邀请好友体力奖励基数
    self.bShare = false --是否已经分享过

    self.tmpInviteCnt = 0 --邀请好友数量缓存

    self.ShareReward = {}
    local dropID = g_DataMgr:getCsvConfigByOneKey("GlobalCfg", 118).Data
    local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient",dropID )--g_DataMgr:getCsvConfigByOneKey("DropSubPackClient", nDropSubPackClientID)
    if CSV_DropSubPackClient then
        local int i = 1;
	    for k, v in pairs (CSV_DropSubPackClient) do
		    if v.DropItemID > 0 or v.DropItemType >0 then
                local tbDrop = {}

	            tbDrop.DropItemType = v.DropItemType --道具
	            tbDrop.DropItemStarLevel = v.DropItemStarLevel
	            tbDrop.DropItemID = v.DropItemID
	            tbDrop.DropItemNum = v.DropItemNum

			    self.ShareReward[i] = tbDrop
                i = i+1
		    end
	    end
    end
    
end

function FacebookRewardSys:init(FB_info)
    self.InviteCnt = FB_info.invite_count
    if FB_info.share_status == macro_pb.FacebookShareStatus_False then
        self.bShare = false
    else
        self.bShare = true
    end
end
function FacebookRewardSys:ShowInviteView()
    g_WndMgr:showWnd("Game_FacebookReward")
end

function FacebookRewardSys:ShowShareView()
    g_WndMgr:showWnd("Game_FacebookShare")
end

function FacebookRewardSys:getSurplusReward()

    local SurplusReward = (self.MaxInviteCnt - self.InviteCnt) * self.energy_bas;
    if SurplusReward < 0 then 
        SurplusReward = 0
    end
    return SurplusReward
end

------------------------------------------------------------------------------------
--网络消息请求函数
------------------------------------------------------------------------------------
--邀请好友成功，请求奖励接口
function FacebookRewardSys:ReqInviteReward(args)

    local i = 0
    for k in string.gmatch(args, "to") do
        i = i +1
    end


    g_MsgNetWorkWarning:showWarningText(true)
    self.tmpInviteCnt = i
    local msg = zone_pb.FacebookInviteReq()
    msg.invite_count = self.tmpInviteCnt
    g_MsgMgr:sendMsg(msgid_pb.MSGID_FACEBOOK_INVITE_FRIEND_REQUEST,msg)
end

--分享成功，请求奖励
function FacebookRewardSys:ReqShareReward(args)
    g_MsgNetWorkWarning:showWarningText(true)
   g_MsgMgr:sendMsg(msgid_pb.MSGID_FACEBOOK_SHARE_REQUEST,nil)
end
------------------------------------------------------------------------------------
--网络消息响应函数
------------------------------------------------------------------------------------
--邀请好友奖励返回
function FacebookRewardSys:ResponseInviteReward(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()
    self.InviteCnt = self.InviteCnt + self.tmpInviteCnt
    self.tmpInviteCnt = 0
    --更新UI
   g_FormMsgSystem:SendFormMsg(FormMsg_Facebook_updateInvite, nil)
end

--分享奖励返回
function FacebookRewardSys:ResponseShareReward(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()
    self.bShare = true
    local tmpWnd = g_WndMgr:getWnd("Game_System1")
    if tmpWnd ~= nil and tmpWnd.OnFacebookShare ~= nil then
        tmpWnd:OnFacebookShare()
    end
   --更新UI
   g_FormMsgSystem:SendFormMsg(FormMsg_Facebook_updateShare, nil)
end

-----------------------------------------------------------------------

g_FacebookRewardSys = FacebookRewardSys.new()
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_FACEBOOK_INVITE_FRIEND_RESPONSE, handler(g_FacebookRewardSys,g_FacebookRewardSys.ResponseInviteReward)) 
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_FACEBOOK_SHARE_RESPONSE, handler(g_FacebookRewardSys,g_FacebookRewardSys.ResponseShareReward)) 